/// EIP-2929 Warm/Cold Access Tracking
///
/// This module manages the warm/cold access state for addresses and storage slots
/// according to EIP-2929. It's EVM-specific logic, not a primitive type.
const std = @import("std");
const primitives = @import("voltaire");
const Address = primitives.Address.Address;
const StorageKey = primitives.State.StorageKey;
const AccessList = primitives.AccessList.AccessList;
const gas_constants = primitives.GasConstants;
const Allocator = std.mem.Allocator;
const evm_mod = @import("evm.zig");

/// Context for hashing StorageKey in hash maps
const StorageKeyContext = struct {
    pub fn hash(_: @This(), key: StorageKey) u32 {
        var hasher = std.hash.Wyhash.init(0);
        key.hash(&hasher);
        return @truncate(hasher.final());
    }
    pub fn eql(_: @This(), a: StorageKey, b: StorageKey, _: usize) bool {
        return StorageKey.eql(a, b);
    }
};

/// Manages warm/cold access state for EIP-2929.
/// Both maps are insertion-ordered `ArrayHashMap`s so nested-call snapshots are
/// O(1) zero-allocation length checkpoints and reverts simply pop newly warmed entries.
pub const AccessListManager = struct {
    allocator: Allocator,
    warm_addresses: std.AutoArrayHashMap(Address, void),
    warm_storage_slots: std.ArrayHashMap(StorageKey, void, StorageKeyContext, false),
    /// When set (Berlin+), active precompiles for this hardfork are implicitly warm in O(1)
    /// without inserting ~20 addresses into `warm_addresses` on every transaction.
    precompile_hardfork: ?primitives.Hardfork = null,

    /// Initialize empty access list manager
    pub fn init(allocator: Allocator) AccessListManager {
        return .{
            .allocator = allocator,
            .warm_addresses = std.AutoArrayHashMap(Address, void).init(allocator),
            .warm_storage_slots = std.ArrayHashMap(StorageKey, void, StorageKeyContext, false).init(allocator),
            .precompile_hardfork = null,
        };
    }

    /// Clean up resources
    pub fn deinit(self: *AccessListManager) void {
        self.warm_addresses.deinit();
        self.warm_storage_slots.deinit();
    }

    /// O(1) check whether `addr` is an implicitly-warm active precompile.
    /// Rejects non-precompile addresses in 2 loads (first 18 bytes != 0).
    pub inline fn isPrecompileWarm(self: *const AccessListManager, addr: Address) bool {
        const hf = self.precompile_hardfork orelse return false;
        const head0 = std.mem.readInt(u64, addr.bytes[0..8], .little);
        const head1 = std.mem.readInt(u64, addr.bytes[8..16], .little);
        const head2 = std.mem.readInt(u16, addr.bytes[16..18], .little);
        if ((head0 | head1 | head2) != 0) return false;
        return evm_mod.isPrecompileAddress(addr, hf);
    }

    /// Access an address and return gas cost (warm=100, cold=2600)
    /// EIP-2929: First access is cold, subsequent accesses are warm
    pub fn access_address(self: *AccessListManager, addr: Address) !u64 {
        if (self.isPrecompileWarm(addr)) return gas_constants.WarmStorageReadCost;
        const entry = try self.warm_addresses.getOrPut(addr);
        return if (entry.found_existing)
            gas_constants.WarmStorageReadCost
        else
            gas_constants.ColdAccountAccessCost;
    }

    /// Access a storage slot and return gas cost (warm=100, cold=2100)
    /// EIP-2929: First access is cold, subsequent accesses are warm
    pub fn access_storage_slot(self: *AccessListManager, addr: Address, slot: u256) !u64 {
        const key = StorageKey{ .address = addr.bytes, .slot = slot };
        const entry = try self.warm_storage_slots.getOrPut(key);
        return if (entry.found_existing)
            gas_constants.WarmStorageReadCost
        else
            gas_constants.ColdSloadCost;
    }

    /// Pre-warm multiple addresses (marks them as already accessed)
    pub fn pre_warm_addresses(self: *AccessListManager, addresses: []const Address) !void {
        for (addresses) |addr| {
            if (self.isPrecompileWarm(addr)) continue;
            _ = try self.warm_addresses.getOrPut(addr);
        }
    }

    /// Pre-warm multiple storage slots (marks them as already accessed)
    pub fn pre_warm_storage_slots(self: *AccessListManager, slots: []const StorageKey) !void {
        for (slots) |slot| {
            _ = try self.warm_storage_slots.getOrPut(slot);
        }
    }

    /// Pre-warm from EIP-2930 access list
    pub fn pre_warm_from_access_list(self: *AccessListManager, access_list: AccessList) !void {
        for (access_list) |entry| {
            // Pre-warm address
            if (!self.isPrecompileWarm(entry.address)) {
                _ = try self.warm_addresses.getOrPut(entry.address);
            }

            // Pre-warm storage keys (convert Hash to u256)
            for (entry.storage_keys) |key_hash| {
                const slot = std.mem.readInt(u256, &key_hash, .big);
                const key = StorageKey{ .address = entry.address.bytes, .slot = slot };
                _ = try self.warm_storage_slots.getOrPut(key);
            }
        }
    }

    /// Compatibility wrapper for camelCase API expected by spec runner
    /// Delegates to snake_case implementation to avoid duplicate logic
    pub fn preWarmFromAccessList(self: *AccessListManager, access_list: AccessList) !void {
        return self.pre_warm_from_access_list(access_list);
    }
    /// Check if address is warm
    pub fn is_address_warm(self: *const AccessListManager, addr: Address) bool {
        if (self.isPrecompileWarm(addr)) return true;
        return self.warm_addresses.contains(addr);
    }

    /// Check if storage slot is warm
    pub fn is_storage_slot_warm(self: *const AccessListManager, addr: Address, slot: u256) bool {
        const key = StorageKey{ .address = addr.bytes, .slot = slot };
        return self.warm_storage_slots.contains(key);
    }

    /// Clear all warm sets (call at transaction boundaries).
    /// Warm state does not persist across transactions per EIP-2929.
    pub fn clear(self: *AccessListManager) void {
        self.warm_addresses.clearRetainingCapacity();
        self.warm_storage_slots.clearRetainingCapacity();
        self.precompile_hardfork = null;
    }

    /// Create O(1) zero-allocation snapshot for nested call revert handling.
    /// Warm sets only grow during a call frame and are truncated back on revert.
    pub fn snapshot(self: *const AccessListManager) !AccessListSnapshot {
        return .{
            .addresses_len = self.warm_addresses.count(),
            .slots_len = self.warm_storage_slots.count(),
        };
    }

    /// Restore from snapshot in O(k) time with zero allocations (k = newly warmed entries).
    pub fn restore(self: *AccessListManager, snap: AccessListSnapshot) !void {
        while (self.warm_addresses.count() > snap.addresses_len) {
            _ = self.warm_addresses.pop();
        }
        while (self.warm_storage_slots.count() > snap.slots_len) {
            _ = self.warm_storage_slots.pop();
        }
    }
};

/// O(1) checkpoint of warm sets for nested call revert handling.
pub const AccessListSnapshot = struct {
    addresses_len: usize,
    slots_len: usize,

    /// Release snapshot resources (no-op; kept for API compatibility).
    pub fn deinit(_: *AccessListSnapshot) void {}
};

test "AccessListManager: init creates empty warm sets" {
    const allocator = std.testing.allocator;
    var manager = AccessListManager.init(allocator);
    defer manager.deinit();

    try std.testing.expectEqual(@as(usize, 0), manager.warm_addresses.count());
    try std.testing.expectEqual(@as(usize, 0), manager.warm_storage_slots.count());
}

test "AccessListManager: access_address returns cold then warm" {
    const allocator = std.testing.allocator;
    var manager = AccessListManager.init(allocator);
    defer manager.deinit();

    const addr = Address{ .bytes = [_]u8{1} ** 20 };
    const cold = try manager.access_address(addr);
    try std.testing.expectEqual(gas_constants.ColdAccountAccessCost, cold);

    const warm = try manager.access_address(addr);
    try std.testing.expectEqual(gas_constants.WarmStorageReadCost, warm);
}

test "AccessListManager: access_storage_slot returns cold then warm" {
    const allocator = std.testing.allocator;
    var manager = AccessListManager.init(allocator);
    defer manager.deinit();

    const addr = Address{ .bytes = [_]u8{2} ** 20 };
    const slot: u256 = 42;
    const cold = try manager.access_storage_slot(addr, slot);
    try std.testing.expectEqual(gas_constants.ColdSloadCost, cold);

    const warm = try manager.access_storage_slot(addr, slot);
    try std.testing.expectEqual(gas_constants.WarmStorageReadCost, warm);
}

test "AccessListManager: pre_warm_addresses marks warm" {
    const allocator = std.testing.allocator;
    var manager = AccessListManager.init(allocator);
    defer manager.deinit();

    const addr1 = Address{ .bytes = [_]u8{1} ** 20 };
    const addr2 = Address{ .bytes = [_]u8{2} ** 20 };
    const addresses = [_]Address{ addr1, addr2 };

    try manager.pre_warm_addresses(&addresses);

    try std.testing.expect(manager.is_address_warm(addr1));
    try std.testing.expect(manager.is_address_warm(addr2));
}

test "AccessListManager: pre_warm_storage_slots marks warm" {
    const allocator = std.testing.allocator;
    var manager = AccessListManager.init(allocator);
    defer manager.deinit();

    const addr = Address{ .bytes = [_]u8{3} ** 20 };
    const slot1: u256 = 1;
    const slot2: u256 = 2;
    const slots = [_]StorageKey{
        .{ .address = addr.bytes, .slot = slot1 },
        .{ .address = addr.bytes, .slot = slot2 },
    };

    try manager.pre_warm_storage_slots(&slots);

    try std.testing.expect(manager.is_storage_slot_warm(addr, slot1));
    try std.testing.expect(manager.is_storage_slot_warm(addr, slot2));
}

test "AccessListManager: pre_warm_from_access_list marks addresses and slots" {
    const allocator = std.testing.allocator;
    var manager = AccessListManager.init(allocator);
    defer manager.deinit();

    const addr = Address{ .bytes = [_]u8{4} ** 20 };
    const slot_hash: primitives.Hash.Hash = [_]u8{0xaa} ** 32;
    const access_list = [_]primitives.AccessList.AccessListEntry{
        .{
            .address = addr,
            .storage_keys = &[_]primitives.Hash.Hash{slot_hash},
        },
    };

    try manager.pre_warm_from_access_list(&access_list);

    try std.testing.expect(manager.is_address_warm(addr));
    const slot = std.mem.readInt(u256, &slot_hash, .big);
    try std.testing.expect(manager.is_storage_slot_warm(addr, slot));
}

test "AccessListManager: clear resets warm state" {
    const allocator = std.testing.allocator;
    var manager = AccessListManager.init(allocator);
    defer manager.deinit();

    const addr = Address{ .bytes = [_]u8{5} ** 20 };
    const slot: u256 = 7;
    _ = try manager.access_address(addr);
    _ = try manager.access_storage_slot(addr, slot);

    manager.clear();

    try std.testing.expect(!manager.is_address_warm(addr));
    try std.testing.expect(!manager.is_storage_slot_warm(addr, slot));
}

test "AccessListManager: snapshot and restore" {
    const allocator = std.testing.allocator;
    var manager = AccessListManager.init(allocator);
    defer manager.deinit();

    const addr1 = Address{ .bytes = [_]u8{6} ** 20 };
    const addr2 = Address{ .bytes = [_]u8{7} ** 20 };

    _ = try manager.access_address(addr1);

    var snap = try manager.snapshot();
    defer snap.deinit();

    _ = try manager.access_address(addr2);
    try std.testing.expect(manager.is_address_warm(addr2));

    try manager.restore(snap);
    try std.testing.expect(manager.is_address_warm(addr1));
    try std.testing.expect(!manager.is_address_warm(addr2));

    // Nested snapshot + revert + re-warm test
    const addr3 = Address{ .bytes = [_]u8{8} ** 20 };
    const snap1 = try manager.snapshot();
    _ = try manager.access_address(addr2);
    _ = try manager.access_storage_slot(addr2, 99);
    const snap2 = try manager.snapshot();
    _ = try manager.access_address(addr3);
    _ = try manager.access_storage_slot(addr3, 100);
    try manager.restore(snap2);
    try std.testing.expect(manager.is_address_warm(addr2));
    try std.testing.expect(manager.is_storage_slot_warm(addr2, 99));
    try std.testing.expect(!manager.is_address_warm(addr3));
    try std.testing.expect(!manager.is_storage_slot_warm(addr3, 100));
    // Re-warming addr3 after revert must charge cold cost
    try std.testing.expectEqual(gas_constants.ColdAccountAccessCost, try manager.access_address(addr3));
    try manager.restore(snap1);
    try std.testing.expect(manager.is_address_warm(addr1));
    try std.testing.expect(!manager.is_address_warm(addr2));
    try std.testing.expect(!manager.is_address_warm(addr3));
    try std.testing.expect(!manager.is_storage_slot_warm(addr2, 99));
}
