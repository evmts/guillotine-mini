/// Test host implementation for execution-specs tests
/// This maintains multi-account state (balances, code, storage) for testing
const std = @import("std");
const primitives = @import("voltaire");
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
        return a.address.equals(b.address) and a.slot == b.slot;
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
                .getBalance = getBalance,
                .setBalance = setBalanceVTable,
                .getCode = getCode,
                .setCode = setCodeVTable,
                .getStorage = getStorage,
                .setStorage = setStorage,
                .getNonce = getNonceVTable,
                .setNonce = setNonceVTable,
                .accountHasStorage = accountHasStorageVTable,
                .deleteAccount = deleteAccountVTable,
            },
        };
    }

    // Pre-state setup methods
    pub fn setBalance(self: *Self, address: Address, balance: u256) !void {
        try self.balances.put(address, balance);
    }

    pub fn setCode(self: *Self, address: Address, code: []const u8) !void {
        const owned_code = try self.allocator.dupe(u8, code);
        errdefer self.allocator.free(owned_code);
        const previous = try self.code.fetchPut(address, owned_code);
        if (previous) |kv| self.allocator.free(kv.value);
    }

    /// True when any storage slot of `address` holds a non-zero value.
    /// Zero-valued slots are never stored, so presence implies non-zero.
    pub fn accountHasStorage(self: *const Self, address: Address) bool {
        var it = self.storage.keyIterator();
        while (it.next()) |key| {
            if (key.address.equals(address)) return true;
        }
        return false;
    }

    /// Remove every trace of `address`: balance, nonce, code, and all storage
    /// slots. SELFDESTRUCT and failed-CREATE cleanup rely on the storage wipe so
    /// a recreated account starts with empty storage.
    pub fn deleteAccount(self: *Self, address: Address) void {
        var it = self.storage.iterator();
        while (it.next()) |entry| {
            if (entry.key_ptr.address.equals(address)) {
                // removeByPtr keeps the iterator valid: it tombstones the slot
                // without rehashing.
                self.storage.removeByPtr(entry.key_ptr);
            }
        }
        _ = self.balances.remove(address);
        _ = self.nonces.remove(address);
        if (self.code.fetchRemove(address)) |kv| self.allocator.free(kv.value);
    }

    pub fn setStorageSlot(self: *Self, address: Address, slot: u256, value: u256) !void {
        const key = StorageSlotKey{ .address = address, .slot = slot };
        // EVM spec: storage slots with value 0 should be deleted, not stored
        if (value == 0) {
            _ = self.storage.remove(key);
        } else {
            try self.storage.put(key, value);
        }
    }

    pub fn setNonce(self: *Self, address: Address, nonce: u64) !void {
        if (nonce == 0) {
            // Remove entry when nonce is 0 to properly handle account deletion/revert
            // This matches Ethereum semantics where an account with nonce=0, balance=0, and no code doesn't exist
            _ = self.nonces.remove(address);
        } else {
            try self.nonces.put(address, nonce);
        }
    }

    // Post-state validation methods
    pub fn getNonce(self: *Self, address: Address) u64 {
        return self.nonces.get(address) orelse 0;
    }

    // HostInterface vtable implementations
    fn getBalance(ptr: *anyopaque, address: Address) u256 {
        const self: *Self = @ptrCast(@alignCast(ptr));
        return self.balances.get(address) orelse 0;
    }

    fn setBalanceVTable(ptr: *anyopaque, address: Address, balance: u256) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        self.balances.put(address, balance) catch {
            return;
        };
    }

    fn getCode(ptr: *anyopaque, address: Address) []const u8 {
        const self: *Self = @ptrCast(@alignCast(ptr));
        return self.code.get(address) orelse &[_]u8{};
    }

    fn setCodeVTable(ptr: *anyopaque, address: Address, code: []const u8) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        // Note: We need to duplicate code to own it, as the passed slice may be temporary
        // For empty code, just clear the entry
        if (code.len == 0) {
            if (self.code.fetchRemove(address)) |kv| {
                self.allocator.free(kv.value);
            }
            return;
        }
        // Free existing code if present
        if (self.code.fetchRemove(address)) |kv| {
            self.allocator.free(kv.value);
        }
        // Store new code (duplicate to own the memory - the caller may free their copy)
        const owned_code = self.allocator.dupe(u8, code) catch {
            return; // In a test context, we should not fail silently, but the interface doesn't allow errors
        };
        self.code.put(address, owned_code) catch {
            self.allocator.free(owned_code);
            return;
        };
    }

    fn getStorage(ptr: *anyopaque, address: Address, slot: u256) u256 {
        const self: *Self = @ptrCast(@alignCast(ptr));
        const key = StorageSlotKey{ .address = address, .slot = slot };
        return self.storage.get(key) orelse 0;
    }

    fn setStorage(ptr: *anyopaque, address: Address, slot: u256, value: u256) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        const key = StorageSlotKey{ .address = address, .slot = slot };
        // std.debug.print("DEBUG HOST: setStorage called, addr={any} slot={} value={}\n", .{address.bytes, slot, value});
        // EVM spec: storage slots with value 0 should be deleted, not stored
        if (value == 0) {
            _ = self.storage.remove(key);
        } else {
            self.storage.put(key, value) catch {
                // In a test context, we should not fail silently
                // But the interface doesn't allow errors
                // std.debug.print("DEBUG HOST: setStorage FAILED to put!\n", .{});
                return;
            };
        }
    }

    fn getNonceVTable(ptr: *anyopaque, address: Address) u64 {
        const self: *Self = @ptrCast(@alignCast(ptr));
        return self.getNonce(address);
    }

    fn accountHasStorageVTable(ptr: *anyopaque, address: Address) bool {
        const self: *Self = @ptrCast(@alignCast(ptr));
        return self.accountHasStorage(address);
    }

    fn deleteAccountVTable(ptr: *anyopaque, address: Address) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        self.deleteAccount(address);
    }

    fn setNonceVTable(ptr: *anyopaque, address: Address, nonce: u64) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        self.setNonce(address, nonce) catch {
            // In a test context, we should not fail silently
            // But the interface doesn't allow errors
            return;
        };
    }
};

// =============================================================================
// Tests
// =============================================================================

fn testAddress(byte: u8) Address {
    return .{ .bytes = [_]u8{byte} ++ [_]u8{0} ** 19 };
}

test "TestHost deleteAccount removes storage, balance, nonce, and code" {
    var host = try TestHost.init(std.testing.allocator);
    defer host.deinit();
    const victim = testAddress(0xAA);
    const bystander = testAddress(0xBB);

    try host.setBalance(victim, 1000);
    try host.setNonce(victim, 3);
    try host.setCode(victim, &[_]u8{ 0x60, 0x00 });
    try host.setStorageSlot(victim, 1, 11);
    try host.setStorageSlot(victim, 2, 22);
    try host.setStorageSlot(victim, std.math.maxInt(u256), 33);
    try host.setStorageSlot(bystander, 1, 99);

    const iface = host.hostInterface();
    try std.testing.expect(iface.accountHasStorage(victim));
    iface.deleteAccount(victim);

    try std.testing.expectEqual(@as(u256, 0), iface.getStorage(victim, 1));
    try std.testing.expectEqual(@as(u256, 0), iface.getStorage(victim, 2));
    try std.testing.expectEqual(@as(u256, 0), iface.getStorage(victim, std.math.maxInt(u256)));
    try std.testing.expectEqual(@as(u256, 0), iface.getBalance(victim));
    try std.testing.expectEqual(@as(u64, 0), iface.getNonce(victim));
    try std.testing.expectEqual(@as(usize, 0), iface.getCode(victim).len);
    try std.testing.expect(!iface.accountHasStorage(victim));
    try std.testing.expect(!iface.accountExists(victim));

    // Other accounts keep their storage.
    try std.testing.expectEqual(@as(u256, 99), iface.getStorage(bystander, 1));
    try std.testing.expectEqual(@as(usize, 1), host.storage.count());
}

test "TestHost recreated account does not see previous incarnation's storage" {
    var host = try TestHost.init(std.testing.allocator);
    defer host.deinit();
    const addr = testAddress(0xCC);
    const iface = host.hostInterface();

    iface.setStorage(addr, 7, 0xdead);
    iface.deleteAccount(addr);
    iface.setCode(addr, &[_]u8{0x00});
    iface.setNonce(addr, 1);

    try std.testing.expectEqual(@as(u256, 0), iface.getStorage(addr, 7));
}

test "TestHost accountExists counts storage-only accounts" {
    var host = try TestHost.init(std.testing.allocator);
    defer host.deinit();
    const addr = testAddress(0xDD);
    const iface = host.hostInterface();

    try std.testing.expect(!iface.accountExists(addr));
    iface.setStorage(addr, 1, 1);
    try std.testing.expect(iface.accountExists(addr));
}

test "TestHost setCode replaces code without leaking" {
    var host = try TestHost.init(std.testing.allocator);
    defer host.deinit();
    const addr = testAddress(0xEE);

    try host.setCode(addr, &[_]u8{ 0x01, 0x02 });
    try host.setCode(addr, &[_]u8{0x03});
    try std.testing.expectEqualSlices(u8, &[_]u8{0x03}, host.hostInterface().getCode(addr));
}
