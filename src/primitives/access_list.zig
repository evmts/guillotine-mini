const std = @import("std");
const testing = std.testing;
const address = @import("address.zig");
const crypto_pkg = @import("crypto");
const hash = crypto_pkg.Hash;
const rlp = @import("rlp.zig");
const gas_constants = @import("gas_constants.zig");
const Address = address.Address;
const Hash = hash.Hash;
const Allocator = std.mem.Allocator;

// EIP-2930 Access List
pub const AccessListEntry = struct {
    address: Address,
    storage_keys: []const Hash,
};

pub const AccessList = []const AccessListEntry;

// Access list gas costs
pub const ACCESS_LIST_ADDRESS_COST = 2400;
pub const ACCESS_LIST_STORAGE_KEY_COST = 1900;
pub const COLD_ACCOUNT_ACCESS_COST = 2600;
pub const COLD_STORAGE_ACCESS_COST = 2100;
pub const WARM_STORAGE_ACCESS_COST = 100;

// Access list error types
pub const AccessListError = error{
    OutOfMemory,
};

// Calculate total gas cost for access list
pub fn calculate_access_list_gas_cost(accessList: AccessList) u64 {
    var totalCost: u64 = 0;

    for (accessList) |entry| {
        // Cost per address
        totalCost += ACCESS_LIST_ADDRESS_COST;

        // Cost per storage key
        totalCost += ACCESS_LIST_STORAGE_KEY_COST * entry.storage_keys.len;
    }

    return totalCost;
}

// Check if address is in access list
pub fn is_address_in_access_list(accessList: AccessList, addr: Address) bool {
    for (accessList) |entry| {
        if (entry.address.eql(addr)) {
            return true;
        }
    }
    return false;
}

// Check if storage key is in access list
pub fn is_storage_key_in_access_list(
    accessList: AccessList,
    addr: Address,
    storage_key: Hash,
) bool {
    for (accessList) |entry| {
        if (entry.address.eql(addr)) {
            for (entry.storage_keys) |key| {
                if (key.eql(storage_key)) {
                    return true;
                }
            }
        }
    }
    return false;
}

// RLP encode access list
pub fn encode_access_list(allocator: Allocator, accessList: AccessList) ![]u8 {
    // First, encode each entry as a list of [address, [storageKeys...]]
    var entries = std.array_list.AlignedManaged([]const u8, null).init(allocator);
    defer {
        for (entries.items) |item| {
            allocator.free(item);
        }
        entries.deinit();
    }

    for (accessList) |entry| {
        // Encode the address
        const encodedAddress = try rlp.encodeBytes(allocator, &entry.address.bytes);
        defer allocator.free(encodedAddress);

        // Encode storage keys
        var encodedKeys = std.array_list.AlignedManaged([]const u8, null).init(allocator);
        defer {
            for (encodedKeys.items) |item| {
                allocator.free(item);
            }
            encodedKeys.deinit();
        }

        for (entry.storage_keys) |key| {
            const encodedKey = try rlp.encodeBytes(allocator, &key.bytes);
            try encodedKeys.append(encodedKey);
        }

        // Encode the list of storage keys
        const keysListEncoded = try rlp.encode(allocator, encodedKeys.items);
        defer allocator.free(keysListEncoded);

        // Create entry as [address, storageKeysList]
        var entryItems = [_][]const u8{ encodedAddress, keysListEncoded };
        const entryEncoded = try rlp.encode(allocator, &entryItems);
        try entries.append(entryEncoded);
    }

    // Encode the entire access list
    return try rlp.encode(allocator, entries.items);
}

// Calculate gas savings from access list
pub fn calculate_gas_savings(accessList: AccessList) u64 {
    var savings: u64 = 0;

    for (accessList) |entry| {
        // Save on cold account access
        savings += COLD_ACCOUNT_ACCESS_COST - ACCESS_LIST_ADDRESS_COST;

        // Save on cold storage access
        for (entry.storage_keys) |_| {
            savings += COLD_STORAGE_ACCESS_COST - ACCESS_LIST_STORAGE_KEY_COST;
        }
    }

    return savings;
}

// Deduplicate access list entries
pub fn deduplicate_access_list(
    allocator: Allocator,
    accessList: AccessList,
) ![]AccessListEntry {
    var result = std.array_list.AlignedManaged(AccessListEntry, null).init(allocator);
    defer result.deinit();

    for (accessList) |entry| {
        // Check if address already exists
        var found = false;
        for (result.items) |*existing| {
            if (existing.address.eql(entry.address)) {
                // Merge storage keys
                var keys = std.array_list.AlignedManaged(Hash, null).init(allocator);
                defer keys.deinit();

                // Add existing keys
                try keys.appendSlice(existing.storage_keys);

                // Add new keys if not duplicate
                for (entry.storage_keys) |newKey| {
                    var isDuplicate = false;
                    for (existing.storage_keys) |existingKey| {
                        if (newKey.eql(existingKey)) {
                            isDuplicate = true;
                            break;
                        }
                    }
                    if (!isDuplicate) {
                        try keys.append(newKey);
                    }
                }

                existing.storage_keys = try keys.toOwnedSlice();
                found = true;
                break;
            }
        }

        if (!found) {
            try result.append(.{
                .address = entry.address,
                .storage_keys = try allocator.dupe(Hash, entry.storage_keys),
            });
        }
    }

    return result.toOwnedSlice();
}

// ============================================================================
// EIP-2929 Warm/Cold Access Tracking
// ============================================================================

/// Storage slot key for tracking warm/cold access (EIP-2929)
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
        return a.address.eql(b.address) and a.slot == b.slot;
    }
};

/// Context for hashing/equality of StorageSlotKey for ArrayHashMap
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

/// Context for Address ArrayHashMap
const AddressContext = std.array_hash_map.AutoContext(Address);

/// Warm/cold access tracking manager (EIP-2929)
/// Manages warm address and storage slot sets for gas cost calculation
pub const AccessListManager = struct {
    warm_addresses: std.array_hash_map.ArrayHashMap(Address, void, AddressContext, false),
    warm_storage_slots: std.array_hash_map.ArrayHashMap(StorageSlotKey, void, StorageSlotKeyContext, false),
    allocator: Allocator,

    pub fn init(allocator: Allocator) AccessListManager {
        return .{
            .warm_addresses = std.array_hash_map.ArrayHashMap(Address, void, AddressContext, false).init(allocator),
            .warm_storage_slots = std.array_hash_map.ArrayHashMap(StorageSlotKey, void, StorageSlotKeyContext, false).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *AccessListManager) void {
        self.warm_addresses.deinit();
        self.warm_storage_slots.deinit();
    }

    /// Access an address and return gas cost (warm=100, cold=2600)
    /// EIP-2929: First access is cold, subsequent accesses are warm
    pub fn accessAddress(self: *AccessListManager, addr: Address) !u64 {
        const entry = try self.warm_addresses.getOrPut(addr);
        return if (entry.found_existing)
            gas_constants.WarmStorageReadCost
        else
            gas_constants.ColdAccountAccessCost;
    }

    /// Access a storage slot and return gas cost (warm=100, cold=2100)
    /// EIP-2929: First access is cold, subsequent accesses are warm
    pub fn accessStorageSlot(self: *AccessListManager, addr: Address, slot: u256) !u64 {
        const key = StorageSlotKey{ .address = addr, .slot = slot };
        const entry = try self.warm_storage_slots.getOrPut(key);
        return if (entry.found_existing)
            gas_constants.WarmStorageReadCost
        else
            gas_constants.ColdSloadCost;
    }

    /// Pre-warm multiple addresses (marks them as already accessed)
    pub fn preWarmAddresses(self: *AccessListManager, addresses: []const Address) !void {
        for (addresses) |addr| {
            _ = try self.warm_addresses.getOrPut(addr);
        }
    }

    /// Pre-warm multiple storage slots (marks them as already accessed)
    pub fn preWarmStorageSlots(self: *AccessListManager, slots: []const StorageSlotKey) !void {
        for (slots) |slot| {
            _ = try self.warm_storage_slots.getOrPut(slot);
        }
    }

    /// Pre-warm from EIP-2930 access list
    pub fn preWarmFromAccessList(self: *AccessListManager, access_list: AccessList) !void {
        for (access_list) |entry| {
            // Pre-warm address
            _ = try self.warm_addresses.getOrPut(entry.address);

            // Pre-warm storage keys (convert Hash to u256)
            for (entry.storage_keys) |key_hash| {
                const slot = std.mem.readInt(u256, &key_hash, .big);
                const key = StorageSlotKey{ .address = entry.address, .slot = slot };
                _ = try self.warm_storage_slots.getOrPut(key);
            }
        }
    }

    /// Check if address is warm
    pub fn isAddressWarm(self: *const AccessListManager, addr: Address) bool {
        return self.warm_addresses.contains(addr);
    }

    /// Check if storage slot is warm
    pub fn isStorageSlotWarm(self: *const AccessListManager, addr: Address, slot: u256) bool {
        const key = StorageSlotKey{ .address = addr, .slot = slot };
        return self.warm_storage_slots.contains(key);
    }

    /// Clear all warm sets (used at transaction boundaries)
    pub fn clear(self: *AccessListManager) void {
        self.warm_addresses.clearRetainingCapacity();
        self.warm_storage_slots.clearRetainingCapacity();
    }

    /// Create snapshot for nested call revert handling
    pub fn snapshot(self: *const AccessListManager) !AccessListSnapshot {
        var addr_snapshot = std.AutoHashMap(Address, void).init(self.allocator);
        var addr_it = self.warm_addresses.iterator();
        while (addr_it.next()) |entry| {
            try addr_snapshot.put(entry.key_ptr.*, {});
        }

        var slot_snapshot = std.array_hash_map.ArrayHashMap(StorageSlotKey, void, StorageSlotKeyContext, false).init(self.allocator);
        var slot_it = self.warm_storage_slots.iterator();
        while (slot_it.next()) |entry| {
            _ = try slot_snapshot.put(entry.key_ptr.*, {});
        }

        return .{
            .addresses = addr_snapshot,
            .slots = slot_snapshot,
        };
    }

    /// Restore from snapshot (for nested call reverts)
    pub fn restore(self: *AccessListManager, snap: AccessListSnapshot) !void {
        self.warm_addresses.clearRetainingCapacity();
        var addr_it = snap.addresses.iterator();
        while (addr_it.next()) |entry| {
            try self.warm_addresses.put(entry.key_ptr.*, {});
        }

        self.warm_storage_slots.clearRetainingCapacity();
        var slot_it = snap.slots.iterator();
        while (slot_it.next()) |entry| {
            _ = try self.warm_storage_slots.put(entry.key_ptr.*, {});
        }
    }
};

/// Snapshot of warm sets for nested call revert handling
pub const AccessListSnapshot = struct {
    addresses: std.AutoHashMap(Address, void),
    slots: std.array_hash_map.ArrayHashMap(StorageSlotKey, void, StorageSlotKeyContext, false),

    pub fn deinit(self: *AccessListSnapshot) void {
        self.addresses.deinit();
        self.slots.deinit();
    }
};

// Tests

test "access list gas calculation" {
    _ = testing.allocator;

    const storage_keys = [_]Hash{
        try Hash.fromHex("0x0000000000000000000000000000000000000000000000000000000000000001"),
        try Hash.fromHex("0x0000000000000000000000000000000000000000000000000000000000000002"),
    };

    const accessList = [_]AccessListEntry{
        .{
            .address = try Address.fromHex("0x1111111111111111111111111111111111111111"),
            .storage_keys = &storage_keys,
        },
        .{
            .address = try Address.fromHex("0x2222222222222222222222222222222222222222"),
            .storage_keys = &.{},
        },
    };

    const gasCost = calculate_access_list_gas_cost(&accessList);

    // Expected: 2 addresses * 2400 + 2 storage keys * 1900 = 8600
    try testing.expectEqual(@as(u64, 8600), gasCost);
}

test "access list membership checks" {
    const storage_keys = [_]Hash{
        try Hash.fromHex("0x0000000000000000000000000000000000000000000000000000000000000001"),
        try Hash.fromHex("0x0000000000000000000000000000000000000000000000000000000000000002"),
    };

    const accessList = [_]AccessListEntry{
        .{
            .address = try Address.fromHex("0x1111111111111111111111111111111111111111"),
            .storage_keys = &storage_keys,
        },
    };

    // Test address membership
    const addr1 = try Address.fromHex("0x1111111111111111111111111111111111111111");
    const addr2 = try Address.fromHex("0x2222222222222222222222222222222222222222");

    try testing.expect(is_address_in_access_list(&accessList, addr1));
    try testing.expect(!is_address_in_access_list(&accessList, addr2));

    // Test storage key membership
    const key1 = try Hash.fromHex("0x0000000000000000000000000000000000000000000000000000000000000001");
    const key3 = try Hash.fromHex("0x0000000000000000000000000000000000000000000000000000000000000003");

    try testing.expect(is_storage_key_in_access_list(&accessList, addr1, key1));
    try testing.expect(!is_storage_key_in_access_list(&accessList, addr1, key3));
    try testing.expect(!is_storage_key_in_access_list(&accessList, addr2, key1));
}

test "empty access list" {
    const accessList: AccessList = &.{};

    const gasCost = calculate_access_list_gas_cost(accessList);
    try testing.expectEqual(@as(u64, 0), gasCost);

    const addr = try Address.fromHex("0x1111111111111111111111111111111111111111");
    try testing.expect(!is_address_in_access_list(accessList, addr));
}

test "access list RLP encoding" {
    const allocator = testing.allocator;

    const storage_keys = [_]Hash{
        try Hash.fromHex("0x0000000000000000000000000000000000000000000000000000000000000001"),
    };

    const accessList = [_]AccessListEntry{
        .{
            .address = try Address.fromHex("0x1111111111111111111111111111111111111111"),
            .storage_keys = &storage_keys,
        },
    };

    const encoded = try encode_access_list(allocator, &accessList);
    defer allocator.free(encoded);

    // Should produce valid RLP
    try testing.expect(encoded.len > 0);
    try testing.expect(encoded[0] >= 0xc0); // RLP list prefix
}

test "access list gas savings" {
    const storage_keys = [_]Hash{
        try Hash.fromHex("0x0000000000000000000000000000000000000000000000000000000000000001"),
        try Hash.fromHex("0x0000000000000000000000000000000000000000000000000000000000000002"),
    };

    const accessList = [_]AccessListEntry{
        .{
            .address = try Address.fromHex("0x1111111111111111111111111111111111111111"),
            .storage_keys = &storage_keys,
        },
    };

    const savings = calculate_gas_savings(&accessList);

    // Expected savings:
    // Account: 2600 - 2400 = 200
    // Storage keys: 2 * (2100 - 1900) = 400
    // Total: 600
    try testing.expectEqual(@as(u64, 600), savings);
}

test "complex access list" {
    const allocator = testing.allocator;

    // Multiple addresses with varying storage keys
    const keys1 = [_]Hash{
        try Hash.fromHex("0x0000000000000000000000000000000000000000000000000000000000000001"),
        try Hash.fromHex("0x0000000000000000000000000000000000000000000000000000000000000002"),
        try Hash.fromHex("0x0000000000000000000000000000000000000000000000000000000000000003"),
    };

    const keys2 = [_]Hash{
        try Hash.fromHex("0x0000000000000000000000000000000000000000000000000000000000000004"),
    };

    const accessList = [_]AccessListEntry{
        .{
            .address = try Address.fromHex("0x1111111111111111111111111111111111111111"),
            .storage_keys = &keys1,
        },
        .{
            .address = try Address.fromHex("0x2222222222222222222222222222222222222222"),
            .storage_keys = &keys2,
        },
        .{
            .address = try Address.fromHex("0x3333333333333333333333333333333333333333"),
            .storage_keys = &.{}, // No storage keys
        },
    };

    const gasCost = calculate_access_list_gas_cost(&accessList);

    // Expected:
    // 3 addresses * 2400 = 7200
    // 4 storage keys * 1900 = 7600
    // Total: 14800
    try testing.expectEqual(@as(u64, 14800), gasCost);

    // Test encoding
    const encoded = try encode_access_list(allocator, &accessList);
    defer allocator.free(encoded);

    try testing.expect(encoded.len > 0);
}

test "deduplicate access list" {
    const allocator = testing.allocator;

    const keys1 = [_]Hash{
        try Hash.fromHex("0x0000000000000000000000000000000000000000000000000000000000000001"),
        try Hash.fromHex("0x0000000000000000000000000000000000000000000000000000000000000002"),
    };

    const keys2 = [_]Hash{
        try Hash.fromHex("0x0000000000000000000000000000000000000000000000000000000000000002"), // Duplicate
        try Hash.fromHex("0x0000000000000000000000000000000000000000000000000000000000000003"),
    };

    const accessList = [_]AccessListEntry{
        .{
            .address = try Address.fromHex("0x1111111111111111111111111111111111111111"),
            .storage_keys = &keys1,
        },
        .{
            .address = try Address.fromHex("0x1111111111111111111111111111111111111111"), // Same address
            .storage_keys = &keys2,
        },
    };

    const deduped = try deduplicate_access_list(allocator, &accessList);
    defer {
        for (deduped) |entry| {
            allocator.free(entry.storage_keys);
        }
        allocator.free(deduped);
    }

    // Should have one entry with three unique keys
    try testing.expectEqual(@as(usize, 1), deduped.len);
    try testing.expectEqual(@as(usize, 3), deduped[0].storage_keys.len);
}
