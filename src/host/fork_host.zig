/// Fork-enabled host implementation that lazily fetches state from a remote RPC
/// Implements 3-tier lookup: local cache → fork cache → remote RPC
const std = @import("std");
const primitives = @import("primitives");
const Address = primitives.Address.Address;
const HostInterface = @import("../host.zig").HostInterface;
const json_rpc = @import("json_rpc.zig");
const BlockTag = json_rpc.BlockTag;

/// Storage key for HashMap lookups
pub const StorageKey = struct {
    address: Address,
    slot: u256,

    pub fn hash(self: StorageKey, key: StorageKey) u32 {
        _ = self;
        var hasher = std.hash.Wyhash.init(0);
        hasher.update(&key.address.bytes);
        hasher.update(std.mem.asBytes(&key.slot));
        return @truncate(hasher.final());
    }

    pub fn eql(self: StorageKey, a: StorageKey, b: StorageKey, b_index: usize) bool {
        _ = self;
        _ = b_index;
        return a.address.equals(b.address) and a.slot == b.slot;
    }
};

/// User-provided RPC request function signature
/// This function must make a JSON-RPC request and return the result
///
/// Parameters:
/// - context: User-provided context pointer (can be null)
/// - method: JSON-RPC method name (null-terminated C string)
/// - params_json: JSON array of parameters (null-terminated C string)
/// - response_buffer: Buffer to write the response into
/// - response_capacity: Size of the response buffer
///
/// Returns:
/// - Positive: Number of bytes written to response_buffer
/// - Negative: Error code
///
/// The response should contain ONLY the "result" field from the JSON-RPC response,
/// not the full JSON-RPC wrapper. For example:
/// - Request: {"jsonrpc":"2.0","id":1,"method":"eth_getStorageAt","params":["0x...","0x0","latest"]}
/// - Full response: {"jsonrpc":"2.0","id":1,"result":"0x0000..."}
/// - User should write to buffer: "0x0000..."
pub const RpcRequestFn = *const fn (
    context: ?*anyopaque,
    method: [*:0]const u8,
    params_json: [*:0]const u8,
    response_buffer: [*]u8,
    response_capacity: usize,
) isize;

/// Fork-enabled host that lazily fetches state from a remote RPC endpoint
pub const ForkHost = struct {
    const Self = @This();

    allocator: std.mem.Allocator,

    // Local state (modifications)
    local_balances: std.AutoHashMap(Address, u256),
    local_code: std.AutoHashMap(Address, []const u8),
    local_storage: std.AutoHashMap(StorageKey, u256),
    local_nonces: std.AutoHashMap(Address, u64),

    // Fork cache (pristine remote data)
    fork_cache_balances: std.AutoHashMap(Address, u256),
    fork_cache_code: std.AutoHashMap(Address, []const u8),
    fork_cache_storage: std.AutoHashMap(StorageKey, u256),
    fork_cache_nonces: std.AutoHashMap(Address, u64),

    // Fork configuration
    fork_block: BlockTag,

    // User-provided RPC request function
    rpc_request_fn: RpcRequestFn,
    rpc_context: ?*anyopaque,

    /// Initialize a new ForkHost
    pub fn init(
        allocator: std.mem.Allocator,
        fork_block: BlockTag,
        rpc_request_fn: RpcRequestFn,
        rpc_context: ?*anyopaque,
    ) !Self {
        return Self{
            .allocator = allocator,
            .local_balances = std.AutoHashMap(Address, u256).init(allocator),
            .local_code = std.AutoHashMap(Address, []const u8).init(allocator),
            .local_storage = std.AutoHashMap(StorageKey, u256).init(allocator),
            .local_nonces = std.AutoHashMap(Address, u64).init(allocator),
            .fork_cache_balances = std.AutoHashMap(Address, u256).init(allocator),
            .fork_cache_code = std.AutoHashMap(Address, []const u8).init(allocator),
            .fork_cache_storage = std.AutoHashMap(StorageKey, u256).init(allocator),
            .fork_cache_nonces = std.AutoHashMap(Address, u64).init(allocator),
            .fork_block = fork_block,
            .rpc_request_fn = rpc_request_fn,
            .rpc_context = rpc_context,
        };
    }

    /// Clean up resources
    pub fn deinit(self: *Self) void {
        // Free code allocations in local cache
        var local_code_it = self.local_code.valueIterator();
        while (local_code_it.next()) |code| {
            if (code.len > 0) {
                self.allocator.free(code.*);
            }
        }

        // Free code allocations in fork cache
        var fork_code_it = self.fork_cache_code.valueIterator();
        while (fork_code_it.next()) |code| {
            if (code.len > 0) {
                self.allocator.free(code.*);
            }
        }

        self.local_balances.deinit();
        self.local_code.deinit();
        self.local_storage.deinit();
        self.local_nonces.deinit();
        self.fork_cache_balances.deinit();
        self.fork_cache_code.deinit();
        self.fork_cache_storage.deinit();
        self.fork_cache_nonces.deinit();
    }

    /// Get HostInterface for this ForkHost
    pub fn hostInterface(self: *Self) HostInterface {
        return .{
            .ptr = self,
            .vtable = &.{
                .getBalance = getBalanceVTable,
                .setBalance = setBalanceVTable,
                .getCode = getCodeVTable,
                .setCode = setCodeVTable,
                .getStorage = getStorageVTable,
                .setStorage = setStorageVTable,
                .getNonce = getNonceVTable,
                .setNonce = setNonceVTable,
            },
        };
    }

    /// Make an RPC request via user-provided function
    fn rpcRequest(
        self: *Self,
        method: []const u8,
        params: []const u8,
        response_buffer: []u8,
    ) !usize {
        // Convert method to null-terminated string
        const method_z = try self.allocator.dupeZ(u8, method);
        defer self.allocator.free(method_z);

        // Convert params to null-terminated string
        const params_z = try self.allocator.dupeZ(u8, params);
        defer self.allocator.free(params_z);

        // Call user's RPC function
        const result = self.rpc_request_fn(
            self.rpc_context,
            method_z.ptr,
            params_z.ptr,
            response_buffer.ptr,
            response_buffer.len,
        );

        if (result < 0) return error.RpcRequestFailed;
        return @intCast(result);
    }

    /// Fetch storage from remote RPC
    fn fetchStorageFromRpc(self: *Self, address: Address, slot: u256) !u256 {
        // Build params JSON
        const params = try json_rpc.buildGetStorageAtParams(
            self.allocator,
            address,
            slot,
            self.fork_block,
        );
        defer self.allocator.free(params);

        // Make RPC request
        var response_buffer: [4096]u8 = undefined;
        const response_len = try self.rpcRequest("eth_getStorageAt", params, &response_buffer);

        // Parse response
        return try json_rpc.parseStorageResponse(response_buffer[0..response_len]);
    }

    /// Fetch balance from remote RPC
    fn fetchBalanceFromRpc(self: *Self, address: Address) !u256 {
        const params = try json_rpc.buildGetBalanceParams(
            self.allocator,
            address,
            self.fork_block,
        );
        defer self.allocator.free(params);

        var response_buffer: [4096]u8 = undefined;
        const response_len = try self.rpcRequest("eth_getBalance", params, &response_buffer);

        return try json_rpc.parseBalanceResponse(response_buffer[0..response_len]);
    }

    /// Fetch code from remote RPC
    fn fetchCodeFromRpc(self: *Self, address: Address) ![]const u8 {
        const params = try json_rpc.buildGetCodeParams(
            self.allocator,
            address,
            self.fork_block,
        );
        defer self.allocator.free(params);

        var response_buffer: [65536]u8 = undefined; // Larger buffer for code
        const response_len = try self.rpcRequest("eth_getCode", params, &response_buffer);

        return try json_rpc.parseCodeResponse(self.allocator, response_buffer[0..response_len]);
    }

    /// Fetch nonce from remote RPC
    fn fetchNonceFromRpc(self: *Self, address: Address) !u64 {
        const params = try json_rpc.buildGetTransactionCountParams(
            self.allocator,
            address,
            self.fork_block,
        );
        defer self.allocator.free(params);

        var response_buffer: [4096]u8 = undefined;
        const response_len = try self.rpcRequest("eth_getTransactionCount", params, &response_buffer);

        return try json_rpc.parseTransactionCountResponse(response_buffer[0..response_len]);
    }

    // HostInterface vtable implementations

    fn getBalanceVTable(ptr: *anyopaque, address: Address) u256 {
        const self: *Self = @ptrCast(@alignCast(ptr));

        // 1. Check local cache (modifications)
        if (self.local_balances.get(address)) |balance| {
            return balance;
        }

        // 2. Check fork cache (pristine remote data)
        if (self.fork_cache_balances.get(address)) |balance| {
            // Copy to local cache for future lookups
            self.local_balances.put(address, balance) catch return 0;
            return balance;
        }

        // 3. Fetch from remote via RPC
        const balance = self.fetchBalanceFromRpc(address) catch return 0;

        // Store in BOTH caches
        self.local_balances.put(address, balance) catch {};
        self.fork_cache_balances.put(address, balance) catch {};

        return balance;
    }

    fn setBalanceVTable(ptr: *anyopaque, address: Address, balance: u256) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        // Only update local cache (modifications)
        self.local_balances.put(address, balance) catch {};
    }

    fn getCodeVTable(ptr: *anyopaque, address: Address) []const u8 {
        const self: *Self = @ptrCast(@alignCast(ptr));

        // 1. Check local cache (modifications)
        if (self.local_code.get(address)) |code| {
            return code;
        }

        // 2. Check fork cache (pristine remote data)
        if (self.fork_cache_code.get(address)) |code| {
            // Copy to local cache for future lookups
            const code_copy = self.allocator.dupe(u8, code) catch return &[_]u8{};
            self.local_code.put(address, code_copy) catch {
                self.allocator.free(code_copy);
                return &[_]u8{};
            };
            return code_copy;
        }

        // 3. Fetch from remote via RPC
        const code = self.fetchCodeFromRpc(address) catch return &[_]u8{};

        // Store in BOTH caches (code is already allocated for local cache)
        self.local_code.put(address, code) catch {
            self.allocator.free(code);
            return &[_]u8{};
        };

        // Duplicate for fork cache
        const fork_code = self.allocator.dupe(u8, code) catch return code;
        self.fork_cache_code.put(address, fork_code) catch {
            self.allocator.free(fork_code);
        };

        return code;
    }

    fn setCodeVTable(ptr: *anyopaque, address: Address, code: []const u8) void {
        const self: *Self = @ptrCast(@alignCast(ptr));

        // Free old code if present
        if (self.local_code.fetchRemove(address)) |kv| {
            if (kv.value.len > 0) {
                self.allocator.free(kv.value);
            }
        }

        // Store new code (duplicate to own memory)
        if (code.len == 0) {
            self.local_code.put(address, &[_]u8{}) catch {};
            return;
        }

        const owned_code = self.allocator.dupe(u8, code) catch return;
        self.local_code.put(address, owned_code) catch {
            self.allocator.free(owned_code);
        };
    }

    fn getStorageVTable(ptr: *anyopaque, address: Address, slot: u256) u256 {
        const self: *Self = @ptrCast(@alignCast(ptr));

        const key = StorageKey{ .address = address, .slot = slot };

        // 1. Check local cache (modifications)
        if (self.local_storage.get(key)) |value| {
            return value;
        }

        // 2. Check fork cache (pristine remote data)
        if (self.fork_cache_storage.get(key)) |value| {
            // Copy to local cache for future lookups
            self.local_storage.put(key, value) catch return 0;
            return value;
        }

        // 3. Fetch from remote via RPC
        const value = self.fetchStorageFromRpc(address, slot) catch return 0;

        // Store in BOTH caches
        self.local_storage.put(key, value) catch {};
        self.fork_cache_storage.put(key, value) catch {};

        return value;
    }

    fn setStorageVTable(ptr: *anyopaque, address: Address, slot: u256, value: u256) void {
        const self: *Self = @ptrCast(@alignCast(ptr));

        const key = StorageKey{ .address = address, .slot = slot };

        // Only update local cache (modifications)
        // EVM spec: zero values should be removed
        if (value == 0) {
            _ = self.local_storage.remove(key);
        } else {
            self.local_storage.put(key, value) catch {};
        }
    }

    fn getNonceVTable(ptr: *anyopaque, address: Address) u64 {
        const self: *Self = @ptrCast(@alignCast(ptr));

        // 1. Check local cache (modifications)
        if (self.local_nonces.get(address)) |nonce| {
            return nonce;
        }

        // 2. Check fork cache (pristine remote data)
        if (self.fork_cache_nonces.get(address)) |nonce| {
            // Copy to local cache for future lookups
            self.local_nonces.put(address, nonce) catch return 0;
            return nonce;
        }

        // 3. Fetch from remote via RPC
        const nonce = self.fetchNonceFromRpc(address) catch return 0;

        // Store in BOTH caches
        self.local_nonces.put(address, nonce) catch {};
        self.fork_cache_nonces.put(address, nonce) catch {};

        return nonce;
    }

    fn setNonceVTable(ptr: *anyopaque, address: Address, nonce: u64) void {
        const self: *Self = @ptrCast(@alignCast(ptr));

        // Only update local cache (modifications)
        if (nonce == 0) {
            _ = self.local_nonces.remove(address);
        } else {
            self.local_nonces.put(address, nonce) catch {};
        }
    }
};

// Unit tests
test "ForkHost basic operations with mocked RPC" {
    const allocator = std.testing.allocator;

    // Mock RPC function that returns hardcoded values
    const MockRpc = struct {
        fn rpcFn(
            ctx: ?*anyopaque,
            method: [*:0]const u8,
            params: [*:0]const u8,
            buffer: [*]u8,
            capacity: usize,
        ) isize {
            _ = ctx;
            _ = params;

            const method_str = std.mem.span(method);

            if (std.mem.eql(u8, method_str, "eth_getBalance")) {
                const response = "\"0x1234\"";
                if (response.len > capacity) return -1;
                @memcpy(buffer[0..response.len], response);
                return @intCast(response.len);
            } else if (std.mem.eql(u8, method_str, "eth_getStorageAt")) {
                const response = "\"0x5678\"";
                if (response.len > capacity) return -1;
                @memcpy(buffer[0..response.len], response);
                return @intCast(response.len);
            } else if (std.mem.eql(u8, method_str, "eth_getTransactionCount")) {
                const response = "\"0xa\"";
                if (response.len > capacity) return -1;
                @memcpy(buffer[0..response.len], response);
                return @intCast(response.len);
            } else if (std.mem.eql(u8, method_str, "eth_getCode")) {
                const response = "\"0x6060\"";
                if (response.len > capacity) return -1;
                @memcpy(buffer[0..response.len], response);
                return @intCast(response.len);
            }

            return -1;
        }
    };

    var fork_host = try ForkHost.init(allocator, .latest, MockRpc.rpcFn, null);
    defer fork_host.deinit();

    const test_addr = Address{ .bytes = [_]u8{0x12} ++ [_]u8{0} ** 19 };

    const host = fork_host.hostInterface();

    // Test balance fetch
    const balance = host.getBalance(test_addr);
    try std.testing.expectEqual(@as(u256, 0x1234), balance);

    // Test storage fetch
    const storage = host.getStorage(test_addr, 0);
    try std.testing.expectEqual(@as(u256, 0x5678), storage);

    // Test nonce fetch
    const nonce = host.getNonce(test_addr);
    try std.testing.expectEqual(@as(u64, 10), nonce);

    // Test code fetch
    const code = host.getCode(test_addr);
    try std.testing.expectEqual(@as(usize, 2), code.len);
    try std.testing.expectEqual(@as(u8, 0x60), code[0]);
}

test "ForkHost caching behavior" {
    const allocator = std.testing.allocator;

    var call_count: usize = 0;

    const MockRpc = struct {
        fn rpcFn(
            ctx: ?*anyopaque,
            method: [*:0]const u8,
            params: [*:0]const u8,
            buffer: [*]u8,
            capacity: usize,
        ) isize {
            const count_ptr: *usize = @ptrCast(@alignCast(ctx.?));
            count_ptr.* += 1;

            _ = params;
            const method_str = std.mem.span(method);

            if (std.mem.eql(u8, method_str, "eth_getBalance")) {
                const response = "\"0x1234\"";
                if (response.len > capacity) return -1;
                @memcpy(buffer[0..response.len], response);
                return @intCast(response.len);
            }

            return -1;
        }
    };

    var fork_host = try ForkHost.init(allocator, .latest, MockRpc.rpcFn, @ptrCast(&call_count));
    defer fork_host.deinit();

    const test_addr = Address{ .bytes = [_]u8{0x12} ++ [_]u8{0} ** 19 };

    const host = fork_host.hostInterface();

    // First call - should hit RPC
    _ = host.getBalance(test_addr);
    try std.testing.expectEqual(@as(usize, 1), call_count);

    // Second call - should hit cache
    _ = host.getBalance(test_addr);
    try std.testing.expectEqual(@as(usize, 1), call_count); // No additional call
}
