/// EVM implementation for tracing and validation
/// This is a simplified, unoptimized EVM that orchestrates execution.
/// Architecture mirrors evm.zig - Evm orchestrates, Frame executes
const std = @import("std");
const log = @import("logger.zig");
const primitives = @import("primitives");
const GasConstants = primitives.GasConstants;
const Frame = @import("frame.zig").Frame;
const Hardfork = @import("hardfork.zig").Hardfork;
const host = @import("host.zig");
const errors = @import("errors.zig");
const trace = @import("trace.zig");
const blake2 = @import("blake2.zig");
const precompiles = @import("precompiles/precompiles.zig");

const Address = primitives.Address.Address;

// Re-export host types for compatibility
pub const HostInterface = host.HostInterface;
pub const CallResult = host.CallResult;
pub const Host = host.Host;

/// Access list storage key slot type
pub const AccessListStorageKey = struct {
    address: Address,
    slot: u256,
};

/// Access list parameter type for EIP-2930
pub const AccessListParam = struct {
    addresses: []const Address,
    storage_keys: []const AccessListStorageKey,
};

/// Storage slot key for tracking
pub const StorageSlotKey = struct {
    address: Address,
    slot: u256,

    pub fn hash(key: StorageSlotKey) u32 {
        var hasher = std.hash.Wyhash.init(0);
        hasher.update(&key.address.bytes);
        hasher.update(std.mem.asBytes(&key.slot));
        return @truncate(hasher.final());
    }

    pub fn eql(a: StorageSlotKey, b: StorageSlotKey) bool {
        return a.address.equals(b.address) and a.slot == b.slot;
    }
};

// Context for Address ArrayHashMap
const AddressContext = std.array_hash_map.AutoContext(Address);

// Context for hashing/equality of StorageSlotKey for ArrayHashMap
const StorageSlotKeyContext = struct {
    pub fn hash(self: @This(), key: StorageSlotKey) u32 {
        _ = self;
        return StorageSlotKey.hash(key);
    }

    pub fn eql(self: @This(), a: StorageSlotKey, b: StorageSlotKey, b_index: usize) bool {
        _ = self;
        _ = b_index;
        return StorageSlotKey.eql(a, b);
    }
};

pub const BlockContext = struct {
    chain_id: u256,
    block_number: u64,
    block_timestamp: u64,
    block_difficulty: u256,
    block_prevrandao: u256,
    block_coinbase: Address,
    block_gas_limit: u64,
    block_base_fee: u256,
    blob_base_fee: u256,
};

/// EVM - Orchestrates execution like evm.zig
pub const Evm = struct {
    const Self = @This();

    frames: std.ArrayList(Frame),
    storage: std.AutoHashMap(StorageSlotKey, u256),
    original_storage: std.AutoHashMap(StorageSlotKey, u256),
    transient_storage: std.AutoHashMap(StorageSlotKey, u256),
    created_accounts: std.AutoHashMap(Address, void),
    balances: std.AutoHashMap(Address, u256),
    nonces: std.AutoHashMap(Address, u64),
    code: std.AutoHashMap(Address, []const u8),
    warm_addresses: std.array_hash_map.ArrayHashMap(Address, void, AddressContext, false),
    warm_storage_slots: std.array_hash_map.ArrayHashMap(StorageSlotKey, void, StorageSlotKeyContext, false),
    gas_refund: u64,
    hardfork: Hardfork = Hardfork.DEFAULT,
    origin: Address,
    gas_price: u256,
    host: ?HostInterface,
    arena: std.heap.ArenaAllocator,
    allocator: std.mem.Allocator,
    tracer: ?*trace.Tracer = null,
    block_context: BlockContext = .{
        .chain_id = 1,
        .block_number = 0,
        .block_timestamp = 0,
        .block_difficulty = 0,
        .block_prevrandao = 0,
        .block_coinbase = primitives.ZERO_ADDRESS,
        .block_gas_limit = 30_000_000,
        .block_base_fee = 0,
        .blob_base_fee = 0,
    },
    blob_versioned_hashes: []const [32]u8 = &[_][32]u8{},

    pub fn init(allocator: std.mem.Allocator, h: ?HostInterface, hardfork: ?Hardfork, block_context: ?BlockContext) !Self {
        return Self{
            .frames = undefined,
            .storage = undefined,
            .original_storage = undefined,
            .transient_storage = undefined,
            .created_accounts = undefined,
            .balances = undefined,
            .nonces = undefined,
            .code = undefined,
            .warm_addresses = undefined,
            .warm_storage_slots = undefined,
            .gas_refund = 0,
            .hardfork = hardfork orelse Hardfork.DEFAULT,
            .block_context = block_context orelse .{
                .chain_id = 1,
                .block_number = 0,
                .block_timestamp = 0,
                .block_difficulty = 0,
                .block_prevrandao = 0,
                .block_coinbase = primitives.ZERO_ADDRESS,
                .block_gas_limit = 30_000_000,
                .block_base_fee = 0,
                .blob_base_fee = 0,
            },
            .origin = primitives.ZERO_ADDRESS,
            .gas_price = 0,
            .host = h,
            .arena = std.heap.ArenaAllocator.init(allocator),
            .allocator = allocator,
            .tracer = null,
        };
    }

    /// Clean up resources
    pub fn deinit(self: *Self) void {
        self.arena.deinit();
    }

    /// Set tracer for EIP-3155 trace capture
    pub fn setTracer(self: *Self, tracer: *trace.Tracer) void {
        self.tracer = tracer;
    }

    pub fn accessAddress(self: *Self, address: Address) !u64 {
        if (self.hardfork.isBefore(.BERLIN)) {
            @branchHint(.cold);
            // Pre-Berlin: No warm/cold access costs (EIP-2929 introduced in Berlin)
            // The base call cost is already charged in the CALL opcode
            return 0;
        }

        const entry = try self.warm_addresses.getOrPut(address);
        return if (entry.found_existing)
            GasConstants.WarmStorageReadCost
        else
            GasConstants.ColdAccountAccessCost;
    }

    /// Access a storage slot and return the gas cost (EIP-2929 warm/cold)
    pub fn accessStorageSlot(self: *Self, contract_address: Address, slot: u256) !u64 {
        if (self.hardfork.isBefore(.BERLIN)) {
            @branchHint(.cold);
            // EIP-1884 (Istanbul): SLOAD increased from 200 to 800 gas
            if (self.hardfork.isAtLeast(.ISTANBUL)) {
                return 800;
            } else {
                return 200;
            }
        }

        const key = StorageSlotKey{ .address = contract_address, .slot = slot };
        const entry = try self.warm_storage_slots.getOrPut(key);
        return if (entry.found_existing)
            GasConstants.WarmStorageReadCost
        else
            GasConstants.ColdSloadCost;
    }

    /// Pre-warm addresses for transaction initialization
    fn preWarmAddresses(self: *Self, addresses: []const Address) !void {
        for (addresses) |addr| {
            _ = self.warm_addresses.getOrPut(addr) catch {
                return errors.CallError.StorageError;
            };
        }
    }

    fn preWarmTransaction(self: *Self, target: Address) errors.CallError!void {
        var warm: [3]Address = undefined;
        var count: usize = 0;

        warm[count] = self.origin;
        count += 1;

        if (!target.equals(primitives.ZERO_ADDRESS)) {
            warm[count] = target;
            count += 1;
        }

        if (self.hardfork.isAtLeast(.SHANGHAI)) {
            @branchHint(.likely);
            warm[count] = self.block_context.block_coinbase;
            count += 1;
        }

        // Pre-warm origin, target, and coinbase
        try self.preWarmAddresses(warm[0..count]);

        // Pre-warm precompiles if Berlin+
        // EIP-2929: Precompiles are always warm at transaction start
        if (!self.hardfork.isAtLeast(.BERLIN)) return;

        // Determine number of precompiles based on hardfork
        // Berlin-Cancun: 0x01-0x09 (9 precompiles)
        // Prague+: 0x01-0x0A (10 precompiles, added BLS12-381 operations)
        const precompile_count: usize = if (self.hardfork.isAtLeast(.PRAGUE)) 10 else 9;

        var precompile_addrs: [10]Address = undefined;
        var i: usize = 0;
        while (i < precompile_count) : (i += 1) {
            precompile_addrs[i] = Address.from_u256(i + 1);
        }
        try self.preWarmAddresses(precompile_addrs[0..precompile_count]);
    }

    /// Execute bytecode (main entry point like evm.execute)
    pub fn call(
        self: *Self,
        bytecode: []const u8,
        gas: i64,
        caller: Address,
        address: Address,
        value: u256,
        calldata: []const u8,
        access_list: ?AccessListParam,
        blob_versioned_hashes: ?[]const [32]u8,
    ) errors.CallError!CallResult {
        const arena_allocator = self.arena.allocator();
        self.storage = std.AutoHashMap(StorageSlotKey, u256).init(arena_allocator);
        self.balances = std.AutoHashMap(Address, u256).init(arena_allocator);
        self.nonces = std.AutoHashMap(Address, u64).init(arena_allocator);
        self.code = std.AutoHashMap(Address, []const u8).init(arena_allocator);
        self.warm_addresses = std.array_hash_map.ArrayHashMap(Address, void, AddressContext, false).init(arena_allocator);
        self.warm_storage_slots = std.array_hash_map.ArrayHashMap(StorageSlotKey, void, StorageSlotKeyContext, false).init(arena_allocator);
        self.frames = std.ArrayList(Frame){};
        try self.frames.ensureTotalCapacity(arena_allocator, 16);
        self.original_storage = std.AutoHashMap(StorageSlotKey, u256).init(arena_allocator);
        self.transient_storage = std.AutoHashMap(StorageSlotKey, u256).init(arena_allocator);
        self.created_accounts = std.AutoHashMap(Address, void).init(arena_allocator);

        // Set blob versioned hashes for EIP-4844
        if (blob_versioned_hashes) |hashes| {
            self.blob_versioned_hashes = hashes;
        } else {
            self.blob_versioned_hashes = &[_][32]u8{};
        }

        try self.preWarmTransaction(address);

        // Pre-warm access list (EIP-2930)
        if (access_list) |list| {
            // Pre-warm all addresses in access list
            for (list.addresses) |addr| {
                _ = try self.warm_addresses.getOrPut(addr);
            }

            // Pre-warm all storage keys in access list
            for (list.storage_keys) |entry| {
                const key = StorageSlotKey{
                    .address = entry.address,
                    .slot = entry.slot,
                };
                _ = try self.warm_storage_slots.getOrPut(key);
            }
        }

        // Transfer value from caller to recipient (if value > 0)
        if (value > 0 and self.host != null) {
            const sender_balance = if (self.host) |h| h.getBalance(caller) else 0;
            if (sender_balance < value) {
                return CallResult{
                    .success = false,
                    .gas_left = 0,
                    .output = &[_]u8{},
                };
            }
            if (self.host) |h| {
                h.setBalance(caller, sender_balance - value);
                const recipient_balance = h.getBalance(address);
                h.setBalance(address, recipient_balance + value);
            }
        }

        // Note: intrinsic gas should be deducted by the caller (e.g., test runner)
        // before calling this function. This function receives gas that's already
        // net of intrinsic costs, similar to inner_call().

        // Create and push frame onto stack
        try self.frames.append(self.arena.allocator(), try Frame.init(
            self.arena.allocator(),
            bytecode,
            gas,
            caller,
            address,
            value,
            calldata,
            @as(*anyopaque, @ptrCast(self)),
            self.hardfork,
            false, // Top-level transaction is never static
        ));
        defer _ = self.frames.pop();

        // Execute the frame (don't cache pointer - it may become invalid during nested calls)
        self.frames.items[self.frames.items.len - 1].execute() catch {
            // Error case - reverse value transfer if needed
            if (value > 0 and self.host != null) {
                if (self.host) |h| {
                    const sender_balance = h.getBalance(caller);
                    const recipient_balance = h.getBalance(address);
                    h.setBalance(caller, sender_balance + value);
                    h.setBalance(address, recipient_balance - value);
                }
            }
            // Return failure (arena will clean up)
            return CallResult{
                .success = false,
                .gas_left = 0,
                .output = &[_]u8{},
            };
        };

        // Get frame results (refetch pointer after execution)
        const frame = &self.frames.items[self.frames.items.len - 1];
        const output = try self.arena.allocator().alloc(u8, frame.output.len);
        @memcpy(output, frame.output);

        const gas_left = @as(u64, @intCast(@max(frame.gas_remaining, 0)));
        // Note: Gas refunds are NOT applied here. They should be applied by the caller
        // (test runner) after calculating coinbase payment based on gas actually consumed.
        // The refund counter is NOT reset here - caller needs access to it.

        // Reverse value transfer if transaction reverted
        if (frame.reverted and value > 0 and self.host != null) {
            if (self.host) |h| {
                const sender_balance = h.getBalance(caller);
                const recipient_balance = h.getBalance(address);
                h.setBalance(caller, sender_balance + value);
                h.setBalance(address, recipient_balance - value);
            }
        }

        // Return result (execution gas left; intrinsic gas handled by caller)
        const result = CallResult{
            .success = !frame.reverted,
            .gas_left = gas_left,
            .output = output,
        };

        // Reset transaction-scoped caches
        self.warm_addresses.clearRetainingCapacity();
        self.warm_storage_slots.clearRetainingCapacity();

        // Clear transient storage at end of transaction (EIP-1153)
        self.transient_storage.clearRetainingCapacity();

        // No cleanup needed - arena handles it
        return result;
    }

    /// Handle inner call from frame (like evm.inner_call)
    pub fn inner_call(
        self: *Self,
        address: Address,
        value: u256,
        input: []const u8,
        gas: u64,
        call_type: HostInterface.CallType,
    ) errors.CallError!CallResult {
        if (self.frames.items.len >= 1024) {
            return CallResult{
                .success = false,
                .gas_left = 0,
                .output = &[_]u8{},
            };
        }

        // Snapshot transient storage before the call (EIP-1153)
        // Transient storage must be reverted on call failure
        var transient_snapshot = std.AutoHashMap(StorageSlotKey, u256).init(self.arena.allocator());
        var it = self.transient_storage.iterator();
        while (it.next()) |entry| {
            try transient_snapshot.put(entry.key_ptr.*, entry.value_ptr.*);
        }

        // Get caller and execution context address based on call type
        // For CALL: caller = current frame's address, execution address = target address
        // For DELEGATECALL: caller = current frame's caller, execution address = current frame's address (code from target)
        // For CALLCODE: caller = current frame's address, execution address = current frame's address (code from target)
        // For STATICCALL: same as CALL but with static mode
        const current_frame = self.getCurrentFrame();
        const frame_caller = if (current_frame) |frame| frame.address else self.origin;
        const frame_caller_caller = if (current_frame) |frame| frame.caller else self.origin;

        const execution_caller: Address = switch (call_type) {
            .Call, .StaticCall, .Create, .Create2 => frame_caller,
            .DelegateCall => frame_caller_caller,
            .CallCode => frame_caller,
        };

        const execution_address: Address = switch (call_type) {
            .Call, .StaticCall, .Create, .Create2 => address,
            .DelegateCall, .CallCode => frame_caller,
        };

        // Handle balance transfer if value > 0 (only for regular CALL)
        if (value > 0 and call_type == .Call) {
            const caller_balance = if (self.host) |h| h.getBalance(frame_caller) else self.balances.get(frame_caller) orelse 0;
            if (caller_balance < value) {
                // Insufficient balance - call fails
                // std.debug.print("CALL FAILED: insufficient balance (caller={any} needs {} has {})\n", .{frame_caller.bytes, value, caller_balance});
                return CallResult{
                    .success = false,
                    .gas_left = gas,
                    .output = &[_]u8{},
                };
            }

            // Transfer balance
            if (self.host) |h| {
                // std.debug.print("TRANSFER: from={any} to={any} value={} (caller_bal={} callee_bal={})\n", .{frame_caller.bytes, address.bytes, value, caller_balance, h.getBalance(address)});
                h.setBalance(frame_caller, caller_balance - value);
                const callee_balance = h.getBalance(address);
                h.setBalance(address, callee_balance + value);
            } else {
                try self.balances.put(frame_caller, caller_balance - value);
                const callee_balance = self.balances.get(address) orelse 0;
                try self.balances.put(address, callee_balance + value);
            }
        }

        // Get code for the target address
        const code = self.get_code(address);
        // std.debug.print("DEBUG inner_call: address={any} code.len={} frames={}\n", .{address.bytes, code.len, self.frames.items.len});
        if (code.len == 0) {
            // Check if this is a precompile address (hardfork-aware)
            if (precompiles.is_precompile(address, self.hardfork)) {
                // Use the precompiles module to handle all precompile execution
                const result = precompiles.execute_precompile(
                    self.arena.allocator(),
                    address,
                    input,
                    gas,
                    self.hardfork,
                ) catch |err| {
                    // On error, return failure
                    std.debug.print("Precompile execution error: {}\n", .{err});
                    return CallResult{
                        .success = false,
                        .gas_left = 0,
                        .output = &[_]u8{},
                    };
                };

                return CallResult{
                    .success = result.success,
                    .gas_left = if (result.success) gas - result.gas_used else 0,
                    .output = result.output,
                };
            }

            // For non-precompile empty accounts, return success with no output
            return CallResult{
                .success = true,
                .gas_left = gas,
                .output = &[_]u8{},
            };
        }

        // Create and push frame onto stack
        // Use execution_caller and execution_address which are determined by call_type

        // Determine if this call should be static
        // STATICCALL creates a static context, and static context propagates to all nested calls
        const parent_is_static = if (self.getCurrentFrame()) |frame| frame.is_static else false;
        const is_static = parent_is_static or call_type == .StaticCall;

        // Safely cast gas to i64 - if it exceeds i64::MAX, cap it (shouldn't happen in practice)
        const frame_gas = std.math.cast(i64, gas) orelse std.math.maxInt(i64);
        try self.frames.append(self.arena.allocator(), try Frame.init(
            self.arena.allocator(),
            code,
            frame_gas,
            execution_caller,
            execution_address,
            value,
            input,
            @as(*anyopaque, @ptrCast(self)),
            self.hardfork,
            is_static,
        ));
        errdefer _ = self.frames.pop();

        // Execute frame (don't cache pointer - it may become invalid during nested calls)
        self.frames.items[self.frames.items.len - 1].execute() catch {
            // std.debug.print("CALL FAILED: execution error {} (addr={any})\n", .{err, address.bytes});
            _ = self.frames.pop();

            // Reverse value transfer on failure
            if (value > 0 and call_type == .Call) {
                if (self.host) |h| {
                    const caller_balance = h.getBalance(frame_caller);
                    const callee_balance = h.getBalance(address);
                    h.setBalance(frame_caller, caller_balance + value);
                    h.setBalance(address, callee_balance - value);
                } else {
                    const caller_balance = self.balances.get(frame_caller) orelse 0;
                    const callee_balance = self.balances.get(address) orelse 0;
                    try self.balances.put(frame_caller, caller_balance + value);
                    try self.balances.put(address, callee_balance - value);
                }
            }

            // Restore transient storage on failure (EIP-1153)
            self.transient_storage.clearRetainingCapacity();
            var restore_it = transient_snapshot.iterator();
            while (restore_it.next()) |entry| {
                try self.transient_storage.put(entry.key_ptr.*, entry.value_ptr.*);
            }

            return CallResult{
                .success = false,
                .gas_left = 0,
                .output = &[_]u8{},
            };
        };

        // Get frame results (refetch pointer after execution)
        const frame = &self.frames.items[self.frames.items.len - 1];

        // Store return data
        const output = if (frame.output.len > 0) blk: {
            const output_copy = try self.arena.allocator().alloc(u8, frame.output.len);
            @memcpy(output_copy, frame.output);
            break :blk output_copy;
        } else &[_]u8{};

        // Return result
        const result = CallResult{
            .success = !frame.reverted,
            .gas_left = @as(u64, @intCast(@max(frame.gas_remaining, 0))),
            .output = output,
        };
        // std.debug.print("DEBUG inner_call result: address={any} success={} reverted={} frames={}\n", .{address.bytes, result.success, frame.reverted, self.frames.items.len});

        // Restore transient storage on revert (EIP-1153)
        if (frame.reverted) {
            self.transient_storage.clearRetainingCapacity();
            var restore_it = transient_snapshot.iterator();
            while (restore_it.next()) |entry| {
                try self.transient_storage.put(entry.key_ptr.*, entry.value_ptr.*);
            }
        }

        // Reverse value transfer if call reverted
        if (frame.reverted and value > 0 and call_type == .Call) {
            // std.debug.print("REVERT: reversing transfer from={any} to={any} value={}\n", .{frame_caller.bytes, address.bytes, value});
            if (self.host) |h| {
                const caller_balance = h.getBalance(frame_caller);
                const callee_balance = h.getBalance(address);
                h.setBalance(frame_caller, caller_balance + value);
                h.setBalance(address, callee_balance - value);
            } else {
                const caller_balance = self.balances.get(frame_caller) orelse 0;
                const callee_balance = self.balances.get(address) orelse 0;
                try self.balances.put(frame_caller, caller_balance + value);
                try self.balances.put(address, callee_balance - value);
            }
        }

        // if (frame.reverted) {
        //     std.debug.print("CALL FAILED: reverted (addr={any})\n", .{address.bytes});
        // }

        // Pop frame from stack
        _ = self.frames.pop();

        // std.debug.print("RETURN: addr={any} success={} gas_left={}\n", .{address.bytes, result.success, result.gas_left});
        // No cleanup needed - arena handles it
        return result;
    }

    /// Handle CREATE operation (contract creation)
    pub fn inner_create(
        self: *Self,
        value: u256,
        init_code: []const u8,
        gas: u64,
        salt: ?u256,
    ) errors.CallError!struct { address: Address, success: bool, gas_left: u64, output: []const u8 } {
        // Track if this is a top-level create (contract-creation transaction)
        // We detect this when there is no active frame yet.
        const is_top_level_create = self.frames.items.len == 0;
        // Check call depth
        if (self.frames.items.len >= 1024) {
            return .{
                .address = primitives.ZERO_ADDRESS,
                .success = false,
                .gas_left = 0,
                .output = &[_]u8{},
            };
        }

        // Get caller from current frame
        const caller = if (self.getCurrentFrame()) |frame| frame.address else self.origin;

        // Check sender's nonce for overflow (max nonce is 2^64 - 1)
        const sender_nonce = if (self.host) |h|
            h.getNonce(caller)
        else
            self.nonces.get(caller) orelse 0;

        if (sender_nonce == std.math.maxInt(u64)) {
            // Nonce overflow - CREATE fails, return gas
            return .{
                .address = primitives.ZERO_ADDRESS,
                .success = false,
                .gas_left = gas,
                .output = &[_]u8{},
            };
        }

        // Handle balance transfer if value > 0
        if (value > 0) {
            const caller_balance = if (self.host) |h| h.getBalance(caller) else self.balances.get(caller) orelse 0;
            if (caller_balance < value) {
                // Insufficient balance - CREATE fails
                return .{
                    .address = primitives.ZERO_ADDRESS,
                    .success = false,
                    .gas_left = gas,
                    .output = &[_]u8{},
                };
            }
            // Note: balance transfer happens after we know the new address
        }

        // Calculate new contract address
        const new_address = if (salt) |s| blk: {
            // CREATE2: keccak256(0xff ++ caller ++ salt ++ keccak256(init_code))[12:]
            var hash_input = std.ArrayList(u8){};
            defer hash_input.deinit(self.allocator);

            try hash_input.append(self.allocator, 0xff);
            try hash_input.appendSlice(self.allocator, &caller.bytes);

            // Add salt (32 bytes, big-endian)
            var salt_bytes: [32]u8 = undefined;
            var i: usize = 0;
            while (i < 32) : (i += 1) {
                salt_bytes[31 - i] = @as(u8, @truncate(s >> @intCast(i * 8)));
            }
            try hash_input.appendSlice(self.allocator, &salt_bytes);

            // Add keccak256(init_code)
            var code_hash: [32]u8 = undefined;
            std.crypto.hash.sha3.Keccak256.hash(init_code, &code_hash, .{});
            try hash_input.appendSlice(self.allocator, &code_hash);

            // Hash and take last 20 bytes
            var addr_hash: [32]u8 = undefined;
            std.crypto.hash.sha3.Keccak256.hash(hash_input.items, &addr_hash, .{});

            var addr_bytes: [20]u8 = undefined;
            @memcpy(&addr_bytes, addr_hash[12..32]);
            break :blk Address{ .bytes = addr_bytes };
        } else blk: {
            // CREATE: keccak256(rlp([sender, nonce]))[12:]
            // Get caller's nonce (don't increment yet - that happens after collision check)
            const nonce = if (self.host) |h|
                h.getNonce(caller)
            else
                self.nonces.get(caller) orelse 0;

            // Manually construct RLP encoding of [address_bytes, nonce]
            // Address is 20 bytes, nonce is variable length
            var rlp_data = std.ArrayList(u8){};
            defer rlp_data.deinit(self.allocator);

            // Encode address (20 bytes, 0x80 + 20 = 0x94)
            try rlp_data.append(self.allocator, 0x94);
            try rlp_data.appendSlice(self.allocator, &caller.bytes);

            // Encode nonce (RLP encoding for integers)
            if (nonce == 0) {
                try rlp_data.append(self.allocator, 0x80); // Empty byte string
            } else if (nonce < 0x80) {
                try rlp_data.append(self.allocator, @as(u8, @intCast(nonce)));
            } else {
                // Multi-byte nonce - encode as big-endian bytes with length prefix
                // First, determine the minimum number of bytes needed
                var nonce_bytes: [8]u8 = undefined;
                var nonce_len: usize = 0;
                var temp_nonce = nonce;

                // Convert to big-endian bytes, skipping leading zeros
                var i: usize = 8;
                while (i > 0) : (i -= 1) {
                    const byte = @as(u8, @truncate(temp_nonce & 0xFF));
                    nonce_bytes[i - 1] = byte;
                    temp_nonce >>= 8;
                    if (temp_nonce == 0 and nonce_len == 0) {
                        nonce_len = i;
                    }
                }

                const start_idx = nonce_len;
                const byte_count = 8 - start_idx;

                // RLP: 0x80 + length, then the bytes
                try rlp_data.append(self.allocator, @as(u8, @intCast(0x80 + byte_count)));
                try rlp_data.appendSlice(self.allocator, nonce_bytes[start_idx..]);
            }

            // Wrap in list prefix
            const total_len = rlp_data.items.len;
            var final_rlp = std.ArrayList(u8){};
            defer final_rlp.deinit(self.allocator);
            try final_rlp.append(self.allocator, @as(u8, @intCast(0xc0 + total_len))); // List with length
            try final_rlp.appendSlice(self.allocator, rlp_data.items);

            // Hash and take last 20 bytes
            var addr_hash: [32]u8 = undefined;
            std.crypto.hash.sha3.Keccak256.hash(final_rlp.items, &addr_hash, .{});

            var addr_bytes: [20]u8 = undefined;
            @memcpy(&addr_bytes, addr_hash[12..32]);
            break :blk Address{ .bytes = addr_bytes };
        };

        // EIP-3860: Check init code size limit (Shanghai and later)
        // Per Python reference (line 81-82): This check happens IMMEDIATELY after reading call_data
        // and BEFORE any nonce increments or child call gas calculation
        // When this check fails, it raises OutOfGasError BEFORE deducting child call gas
        if (self.hardfork.isAtLeast(.SHANGHAI)) {
            // Check must use >= to match reference implementation exactly
            // MAX_INITCODE_SIZE is the maximum ALLOWED, so > is correct
            if (init_code.len > primitives.GasConstants.MaxInitcodeSize) {
                // CREATE/CREATE2 fails - return failure without incrementing nonce
                // The initcode gas was already charged in frame.zig
                // Return all the child call gas unused (gas) since OutOfGasError happens
                // before max_message_call_gas is deducted
                return .{
                    .address = primitives.ZERO_ADDRESS,
                    .success = false,
                    .gas_left = gas,
                    .output = &[_]u8{},
                };
            }
        }

        // For top-level creates in Shanghai+, charge EIP-3860 initcode per-word gas here
        // CREATE/CREATE2 opcodes already charge this in frame.zig before calling inner_create.
        var child_gas: u64 = gas;
        if (is_top_level_create and self.hardfork.isAtLeast(.SHANGHAI)) {
            const words = primitives.GasConstants.wordCount(init_code.len);
            const initcode_word_cost = words * GasConstants.InitcodeWordGas;
            if (child_gas <= initcode_word_cost) {
                // Not enough gas to cover initcode word cost
                return .{
                    .address = primitives.ZERO_ADDRESS,
                    .success = false,
                    .gas_left = 0,
                    .output = &[_]u8{},
                };
            }
            child_gas -= initcode_word_cost;
        }

        // EIP-2929 (Berlin): Mark created address as warm
        // Per Python reference: accessed_addresses.add(contract_address) happens
        // BEFORE collision check and nonce increment
        if (self.hardfork.isAtLeast(.BERLIN)) {
            _ = try self.warm_addresses.getOrPut(new_address);
        }

        // Check for address collision (code, nonce, or storage already exists)
        // Per EIP-684: If account has code or nonce, CREATE fails
        const has_collision = blk: {
            if (self.host) |h| {
                const has_code = h.getCode(new_address).len > 0;
                const has_nonce = h.getNonce(new_address) > 0;
                break :blk has_code or has_nonce;
            } else {
                const has_code = (self.code.get(new_address) orelse &[_]u8{}).len > 0;
                const has_nonce = (self.nonces.get(new_address) orelse 0) > 0;
                break :blk has_code or has_nonce;
            }
        };

        if (has_collision) {
            // Collision detected - increment caller's nonce and return failure
            // Per Python reference (line 107-110): nonce is incremented even on collision
            // This applies to BOTH CREATE and CREATE2
            const caller_nonce = if (self.host) |h|
                h.getNonce(caller)
            else
                self.nonces.get(caller) orelse 0;

            if (self.host) |h| {
                h.setNonce(caller, caller_nonce + 1);
            } else {
                try self.nonces.put(caller, caller_nonce + 1);
            }

            return .{
                .address = primitives.ZERO_ADDRESS,
                .success = false,
                .gas_left = gas,
                .output = &[_]u8{},
            };
        }

        // No collision - increment caller's nonce before proceeding
        // Per Python reference (line 113): nonce is incremented for both CREATE and CREATE2
        const caller_nonce = if (self.host) |h|
            h.getNonce(caller)
        else
            self.nonces.get(caller) orelse 0;

        if (self.host) |h| {
            h.setNonce(caller, caller_nonce + 1);
        } else {
            try self.nonces.put(caller, caller_nonce + 1);
        }


        // Set nonce of new contract to 1 (EVM spec: contracts start with nonce 1)
        if (self.host) |h| {
            h.setNonce(new_address, 1);
        } else {
            try self.nonces.put(new_address, 1);
        }

        // Transfer balance if value > 0
        if (value > 0) {
            if (self.host) |h| {
                const caller_balance = h.getBalance(caller);
                h.setBalance(caller, caller_balance - value);
                const new_addr_balance = h.getBalance(new_address);
                h.setBalance(new_address, new_addr_balance + value);
            } else {
                const caller_balance = self.balances.get(caller) orelse 0;
                try self.balances.put(caller, caller_balance - value);
                const new_addr_balance = self.balances.get(new_address) orelse 0;
                try self.balances.put(new_address, new_addr_balance + value);
            }
        }

        // Execute initialization code
        try self.frames.append(self.arena.allocator(), try Frame.init(
            self.arena.allocator(),
            init_code,
            @intCast(child_gas),
            caller,
            new_address,
            value,
            &[_]u8{}, // no calldata for CREATE
            @as(*anyopaque, @ptrCast(self)),
            self.hardfork,
            false, // CREATE/CREATE2 are never static (can't create contracts in static context)
        ));
        errdefer _ = self.frames.pop();

        // Execute frame
        // Debug: trace inner_create gas flow
        std.debug.print("DEBUG[CREATE]: start child_gas={} init_len={}\n", .{child_gas, init_code.len});
        self.frames.items[self.frames.items.len - 1].execute() catch {
            const failed_frame = &self.frames.items[self.frames.items.len - 1];
            const error_output = failed_frame.output; // Capture output before popping
            _ = self.frames.pop();

            // Revert nonce on execution error
            if (self.host) |h| {
                h.setNonce(new_address, 0);
            } else {
                _ = self.nonces.remove(new_address);
            }

            // Reverse value transfer on error
            if (value > 0) {
                if (self.host) |h| {
                    const caller_balance = h.getBalance(caller);
                    const new_addr_balance = h.getBalance(new_address);
                    h.setBalance(caller, caller_balance + value);
                    h.setBalance(new_address, new_addr_balance - value);
                } else {
                    const caller_balance = self.balances.get(caller) orelse 0;
                    const new_addr_balance = self.balances.get(new_address) orelse 0;
                    try self.balances.put(caller, caller_balance + value);
                    try self.balances.put(new_address, new_addr_balance - value);
                }
            }

            return .{
                .address = primitives.ZERO_ADDRESS,
                .success = false,
                .gas_left = 0,
                .output = error_output,
            };
        };

        // Get frame results
        const frame = &self.frames.items[self.frames.items.len - 1];
        var gas_left = @as(u64, @intCast(@max(frame.gas_remaining, 0)));
        var success = !frame.reverted;
        const frame_output = frame.output; // Capture output

        // If successful, check deposit cost and code size, then deploy
        if (success) {
            // Charge code deposit cost (200 gas per byte) if there's output
            if (frame_output.len > 0) {
                const deposit_cost = @as(u64, @intCast(frame_output.len)) * GasConstants.CreateDataGas;
                std.debug.print("DEBUG[CREATE]: frame_ok out_len={} gas_left_before_deposit={} deposit_cost={}\n", .{frame_output.len, gas_left, deposit_cost});
                if (gas_left < deposit_cost) {
                    // Out of gas during code deposit -> creation fails
                    success = false;
                    gas_left = 0;
                }
            }

            if (success and frame_output.len > 0) {
                // Check code size limit (EIP-170: 24576 bytes)
                const max_code_size = 24576;
                if (frame_output.len > max_code_size) {
                    _ = self.frames.pop();

                    // Revert nonce on failure
                    if (self.host) |h| {
                        h.setNonce(new_address, 0);
                    } else {
                        _ = self.nonces.remove(new_address);
                    }

                    // Reverse value transfer on code size failure
                    if (value > 0) {
                        if (self.host) |h| {
                            const caller_balance = h.getBalance(caller);
                            const new_addr_balance = h.getBalance(new_address);
                            h.setBalance(caller, caller_balance + value);
                            h.setBalance(new_address, new_addr_balance - value);
                        } else {
                            const caller_balance = self.balances.get(caller) orelse 0;
                            const new_addr_balance = self.balances.get(new_address) orelse 0;
                            try self.balances.put(caller, caller_balance + value);
                            try self.balances.put(new_address, new_addr_balance - value);
                        }
                    }

                    return .{
                        .address = primitives.ZERO_ADDRESS,
                        .success = false,
                        .gas_left = gas_left,
                        .output = frame_output,
                    };
                }

                // Deploy code and deduct deposit gas
                if (self.host) |h| {
                    // When using a host, update host's code directly
                    h.setCode(new_address, frame_output);
                } else {
                    // When not using a host, store in EVM's code map
                    const code_copy = try self.arena.allocator().alloc(u8, frame_output.len);
                    @memcpy(code_copy, frame_output);
                    try self.code.put(new_address, code_copy);
                }
                const deposit_cost = @as(u64, @intCast(frame_output.len)) * GasConstants.CreateDataGas;
                gas_left -= deposit_cost;
                std.debug.print("DEBUG[CREATE]: deposit_applied new_gas_left={}\n", .{gas_left});
            } else if (success) {
                // Deploy empty code (output.len == 0)
                if (self.host) |h| {
                    h.setCode(new_address, &[_]u8{});
                } else {
                    try self.code.put(new_address, &[_]u8{});
                }
            }

            // Mark account as created in this transaction (EIP-6780) if successful
            if (success) {
                try self.created_accounts.put(new_address, {});
            }
        } else {
            // Reverse state changes on revert
            // Revert nonce to 0
            if (self.host) |h| {
                h.setNonce(new_address, 0);
            } else {
                _ = self.nonces.remove(new_address);
            }

            // Reverse value transfer
            if (value > 0) {
                if (self.host) |h| {
                    const caller_balance = h.getBalance(caller);
                    const new_addr_balance = h.getBalance(new_address);
                    h.setBalance(caller, caller_balance + value);
                    h.setBalance(new_address, new_addr_balance - value);
                } else {
                    const caller_balance = self.balances.get(caller) orelse 0;
                    const new_addr_balance = self.balances.get(new_address) orelse 0;
                    try self.balances.put(caller, caller_balance + value);
                    try self.balances.put(new_address, new_addr_balance - value);
                }
            }
        }

        // Pop frame
        _ = self.frames.pop();

        // According to EIP-1014 and CREATE semantics:
        // - On success: return_data should be empty
        // - On failure/revert: return_data should contain the child's output
        std.debug.print("DEBUG[CREATE]: end success={} gas_left={}\n", .{success, gas_left});
        return .{
            .address = if (success) new_address else primitives.ZERO_ADDRESS,
            .success = success,
            .gas_left = gas_left,
            .output = if (success) &[_]u8{} else frame_output,
        };
    }

    /// Add gas refund (called by frame)
    pub fn add_refund(self: *Self, amount: u64) void {
        self.gas_refund += amount;
    }

    pub fn sub_refund(self: *Self, amount: u64) void {
        self.gas_refund -= amount;
    }

    /// Get balance of an address (called by frame)
    pub fn get_balance(self: *Self, address: Address) u256 {
        if (self.host) |h| return h.getBalance(address);
        return self.balances.get(address) orelse 0;
    }

    /// Get code for an address
    /// EIP-7702: Handle delegation designation (0xef0100 + address)
    pub fn get_code(self: *Self, address: Address) []const u8 {
        const raw_code = if (self.host) |h|
            h.getCode(address)
        else
            self.code.get(address) orelse &[_]u8{};

        // EIP-7702: Check for delegation designation (Prague+)
        if (self.hardfork.isAtLeast(.PRAGUE) and raw_code.len == 23 and
            raw_code[0] == 0xef and raw_code[1] == 0x01 and raw_code[2] == 0x00)
        {
            // Extract delegated address (bytes 3-22, 20 bytes)
            var delegated_addr: Address = undefined;
            @memcpy(&delegated_addr.bytes, raw_code[3..23]);

            // Recursively get code from delegated address
            // Note: We don't recurse infinitely - if delegated address also has
            // delegation designation, we return its delegation code as-is
            const delegated_code = if (self.host) |h|
                h.getCode(delegated_addr)
            else
                self.code.get(delegated_addr) orelse &[_]u8{};

            return delegated_code;
        }

        return raw_code;
    }

    /// Get storage value (called by frame)
    pub fn get_storage(self: *Self, address: Address, slot: u256) u256 {
        if (self.host) |h| {
            return h.getStorage(address, slot);
        }
        const key = StorageSlotKey{ .address = address, .slot = slot };
        return self.storage.get(key) orelse 0;
    }

    /// Set storage value (called by frame)
    pub fn set_storage(self: *Self, address: Address, slot: u256, value: u256) !void {
        const key = StorageSlotKey{ .address = address, .slot = slot };

        // Track original value on first write in transaction
        if (!self.original_storage.contains(key)) {
            const current = if (self.host) |h|
                h.getStorage(address, slot)
            else
                self.storage.get(key) orelse 0;
            try self.original_storage.put(key, current);
        }

        if (self.host) |h| {
            h.setStorage(address, slot, value);
            return;
        }

        try self.storage.put(key, value);
    }

    /// Get original storage value (before transaction modifications)
    pub fn get_original_storage(self: *Self, address: Address, slot: u256) u256 {
        const key = StorageSlotKey{ .address = address, .slot = slot };
        // If we have tracked the original, return it
        if (self.original_storage.get(key)) |original| {
            return original;
        }
        // Otherwise return current value (unchanged in this transaction)
        // Use host if available
        if (self.host) |h| {
            return h.getStorage(address, slot);
        }
        return self.storage.get(key) orelse 0;
    }

    /// Get transient storage value (EIP-1153)
    pub fn get_transient_storage(self: *Self, address: Address, slot: u256) u256 {
        const key = StorageSlotKey{ .address = address, .slot = slot };
        return self.transient_storage.get(key) orelse 0;
    }

    /// Set transient storage value (EIP-1153)
    pub fn set_transient_storage(self: *Self, address: Address, slot: u256, value: u256) !void {
        const key = StorageSlotKey{ .address = address, .slot = slot };
        if (value == 0) {
            _ = self.transient_storage.remove(key);
        } else {
            try self.transient_storage.put(key, value);
        }
    }

    /// Get current frame (top of the frame stack)
    pub fn getCurrentFrame(self: *Self) ?*Frame {
        if (self.frames.items.len > 0) return &self.frames.items[self.frames.items.len - 1];
        return null;
    }

    /// Get current frame's PC (for tracer)
    pub fn getPC(self: *const Self) u32 {
        if (self.frames.items.len > 0) {
            return self.frames.items[self.frames.items.len - 1].pc;
        }
        return 0;
    }

    /// Get current frame's bytecode (for tracer)
    pub fn getBytecode(self: *const Self) []const u8 {
        if (self.frames.items.len > 0) {
            return self.frames.items[self.frames.items.len - 1].bytecode;
        }
        return &[_]u8{};
    }

    /// Execute a single step (for tracer)
    pub fn step(self: *Self) !void {
        if (self.getCurrentFrame()) |frame| {
            try frame.step();
        }
    }
};
