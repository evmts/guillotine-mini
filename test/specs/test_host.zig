/// Test host implementation for execution-specs tests
/// This maintains multi-account state (balances, code, storage) for testing
const std = @import("std");
const primitives = @import("primitives");
const evm_mod = @import("evm");
const Address = primitives.Address.Address;
const HostInterface = evm_mod.HostInterface;
const CallResult = evm_mod.CallResult;

/// Storage slot key for tracking
pub const StorageSlotKey = struct {
    address: Address,
    slot: u256,

    pub fn hash(self: @This(), key: StorageSlotKey) u32 {
        _ = self;
        var hasher = std.hash.Wyhash.init(0);
        hasher.update(&key.address.bytes);
        hasher.update(std.mem.asBytes(&key.slot));
        return @truncate(hasher.final());
    }

    pub fn eql(self: @This(), a: StorageSlotKey, b: StorageSlotKey, b_index: usize) bool {
        _ = self;
        _ = b_index;
        return a.address.equals(b) and a.slot == b.slot;
    }
};

const AddressContext = std.array_hash_map.AutoContext(Address);
const StorageContext = std.hash_map.AutoContext(StorageSlotKey);

pub const TestHost = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    balances: std.AutoHashMap(Address, u256),
    code: std.AutoHashMap(Address, []const u8),
    storage: std.AutoHashMap(StorageSlotKey, u256),
    nonces: std.AutoHashMap(Address, u64),

    pub fn init(allocator: std.mem.Allocator) !Self {
        return .{
            .allocator = allocator,
            .balances = std.AutoHashMap(Address, u256).init(allocator),
            .code = std.AutoHashMap(Address, []const u8).init(allocator),
            .storage = std.AutoHashMap(StorageSlotKey, u256).init(allocator),
            .nonces = std.AutoHashMap(Address, u64).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        // Free all allocated code
        var it = self.code.valueIterator();
        while (it.next()) |code_ptr| {
            self.allocator.free(code_ptr.*);
        }
        self.balances.deinit();
        self.code.deinit();
        self.storage.deinit();
        self.nonces.deinit();
    }

    pub fn hostInterface(self: *Self) HostInterface {
        return .{
            .ptr = self,
            .vtable = &.{
                .innerCall = innerCall,
                .getBalance = getBalance,
                .getCode = getCode,
                .getStorage = getStorage,
                .setStorage = setStorage,
            },
        };
    }

    // Pre-state setup methods
    pub fn setBalance(self: *Self, address: Address, balance: u256) !void {
        try self.balances.put(address, balance);
    }

    pub fn setCode(self: *Self, address: Address, code: []const u8) !void {
        const owned_code = try self.allocator.dupe(u8, code);
        try self.code.put(address, owned_code);
    }

    pub fn setStorageSlot(self: *Self, address: Address, slot: u256, value: u256) !void {
        const key = StorageSlotKey{ .address = address, .slot = slot };
        try self.storage.put(key, value);
    }

    pub fn setNonce(self: *Self, address: Address, nonce: u64) !void {
        try self.nonces.put(address, nonce);
    }

    // Post-state validation methods
    pub fn getNonce(self: *Self, address: Address) u64 {
        return self.nonces.get(address) orelse 0;
    }

    // HostInterface vtable implementations
    fn innerCall(ptr: *anyopaque, gas: u64, address: Address, value: u256, input: []const u8, call_type: HostInterface.CallType) CallResult {
        _ = ptr;
        _ = address;
        _ = value;
        _ = input;
        _ = call_type;
        // For now, just return success
        // TODO: Implement nested calls if needed
        return .{
            .success = true,
            .gas_left = gas,
            .output = &[_]u8{},
        };
    }

    fn getBalance(ptr: *anyopaque, address: Address) u256 {
        const self: *Self = @ptrCast(@alignCast(ptr));
        return self.balances.get(address) orelse 0;
    }

    fn getCode(ptr: *anyopaque, address: Address) []const u8 {
        const self: *Self = @ptrCast(@alignCast(ptr));
        return self.code.get(address) orelse &[_]u8{};
    }

    fn getStorage(ptr: *anyopaque, address: Address, slot: u256) u256 {
        const self: *Self = @ptrCast(@alignCast(ptr));
        const key = StorageSlotKey{ .address = address, .slot = slot };
        return self.storage.get(key) orelse 0;
    }

    fn setStorage(ptr: *anyopaque, address: Address, slot: u256, value: u256) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        const key = StorageSlotKey{ .address = address, .slot = slot };
        self.storage.put(key, value) catch {
            // In a test context, we should not fail silently
            // But the interface doesn't allow errors
            return;
        };
    }
};
