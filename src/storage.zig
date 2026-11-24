/// Storage management for the EVM
/// Handles persistent storage, transient storage (EIP-1153), and original storage tracking
const std = @import("std");
const primitives = @import("voltaire");
const host = @import("host.zig");
const errors = @import("errors.zig");
const log = @import("logger.zig");
const storage_injector = @import("storage_injector.zig");
const async_executor = @import("async_executor.zig");

/// Re-export StorageKey from primitives for convenience.
pub const StorageKey = primitives.State.StorageKey;
/// Backwards compatibility alias for StorageKey (prefer StorageKey for new code).
pub const StorageSlotKey = StorageKey;

/// Re-export AsyncDataRequest from async_executor.
pub const AsyncDataRequest = async_executor.AsyncDataRequest;

/// Storage manager - handles all storage operations for the EVM
///
/// Async (storage injector) mode:
///   `storage` is the authoritative transaction overlay. It holds every slot the
///   host supplied (`put_in_cache`) and every slot written (`set`), including
///   explicit zeros, so reads never fall back to a stale fetch. The injector's
///   `storage_cache` holds only what the host holds: fetched values and the
///   writes of transactions that succeeded (`commitInjectorWrites`). A write in
///   flight never reaches it, so a reverted, halted or cancelled transaction
///   cannot leak a value into the next one (R3-001). The cache is consulted
///   only for slots the overlay does not hold.
pub const Storage = struct {
    /// Persistent storage (current transaction state)
    storage: std.AutoHashMap(StorageSlotKey, u256),
    /// Original storage values (snapshot at transaction start)
    original_storage: std.AutoHashMap(StorageSlotKey, u256),
    /// Transient storage (EIP-1153, cleared at transaction boundaries)
    transient: std.AutoHashMap(StorageSlotKey, u256),
    /// Host interface (optional, for external state backends)
    host: ?host.HostInterface,
    /// Storage injector for async data fetching
    storage_injector: ?*storage_injector.StorageInjector,
    /// Async data request state
    async_data_request: AsyncDataRequest,
    /// Arena allocator for transaction-scoped memory
    allocator: std.mem.Allocator,

    /// Initialize storage manager
    ///
    /// Parameters:
    ///   - allocator: Arena allocator for transaction-scoped memory
    ///   - h: Optional host interface for external state backend
    ///   - injector: Optional storage injector for async data fetching
    pub fn init(allocator: std.mem.Allocator, h: ?host.HostInterface, injector: ?*storage_injector.StorageInjector) Storage {
        return Storage{
            .storage = std.AutoHashMap(StorageSlotKey, u256).init(allocator),
            .original_storage = std.AutoHashMap(StorageSlotKey, u256).init(allocator),
            .transient = std.AutoHashMap(StorageSlotKey, u256).init(allocator),
            .host = h,
            .storage_injector = injector,
            .async_data_request = .none,
            .allocator = allocator,
        };
    }

    /// Clean up storage maps when using a non-arena allocator.
    pub fn deinit(self: *Storage) void {
        self.storage.deinit();
        self.original_storage.deinit();
        self.transient.deinit();
    }

    /// Clear injector cache (call at transaction start)
    pub fn clear_injector_cache(self: *Storage) void {
        if (self.storage_injector) |injector| {
            log.debug("Storage: Clearing injector cache", .{});
            injector.clearCache();
        }
    }

    /// Value of a slot in injector mode without yielding, or null when the slot
    /// has not been loaded yet.
    fn injectedValue(self: *Storage, injector: *storage_injector.StorageInjector, key: StorageSlotKey) ?u256 {
        if (self.storage.get(key)) |value| return value;
        // A written slot always lives in the overlay. If it is gone, an account
        // deletion removed it, so the slot now reads zero. The injector cache
        // still holds the value from before the deletion and must not be read.
        if (injector.dirty_storage.contains(key)) return 0;
        return injector.storage_cache.get(key);
    }

    /// Current value without ever yielding (unloaded injector slots read as 0).
    ///
    /// Use this for reporting (commit dumps, C ABI getters). Opcode handlers
    /// must use `ensureSlotLoaded` + `get` so missing data suspends execution.
    pub fn peek(self: *Storage, address: primitives.Address, slot: u256) u256 {
        const key = StorageSlotKey{ .address = address.bytes, .slot = slot };
        if (self.storage_injector) |injector| {
            if (self.injectedValue(injector, key)) |value| return value;
        }
        if (self.host) |h| return h.getStorage(address, slot);
        return self.storage.get(key) orelse 0;
    }

    /// Ensure a slot is available before an opcode mutates its frame (Contract C).
    ///
    /// With a storage injector, returns `error.NeedAsyncData` and records the
    /// request in `async_data_request` when the slot is in neither `storage`
    /// nor the injector cache. It never touches the frame, the access list or
    /// gas, so SLOAD/SSTORE can call it on a peeked key and re-run unchanged
    /// once the host supplies the value. Without an injector it is a no-op.
    pub fn ensureSlotLoaded(self: *Storage, address: primitives.Address, slot: u256) !void {
        const injector = self.storage_injector orelse return;
        const key = StorageSlotKey{ .address = address.bytes, .slot = slot };
        if (self.storage.contains(key) or injector.dirty_storage.contains(key)) return;
        if (injector.storage_cache.get(key)) |value| {
            // Promote into the overlay so call-revert snapshots cover the slot.
            try self.storage.put(key, value);
            return;
        }

        log.debug("ensureSlotLoaded: slot {} not loaded, yielding", .{slot});
        self.async_data_request = .{ .storage = .{
            .address = address,
            .slot = slot,
        } };
        return errors.CallError.NeedAsyncData;
    }

    /// Get storage value
    ///
    /// Behavior depends on configuration:
    ///   - With storage injector: reads the transaction overlay, then the fetch
    ///     cache; yields with NeedAsyncData when the slot was never loaded
    ///   - With host interface: Delegates to host.getStorage()
    ///   - Without host: Uses internal HashMap, returns 0 for empty slots
    ///
    /// Errors:
    ///   - NeedAsyncData: When using injector and value not loaded (yields for fetch)
    pub fn get(self: *Storage, address: primitives.Address, slot: u256) !u256 {
        const key = StorageSlotKey{ .address = address.bytes, .slot = slot };

        if (self.storage_injector) |injector| {
            if (self.injectedValue(injector, key)) |value| return value;

            // Never loaded - yield to fetch from async source
            log.debug("get_storage: slot {} not loaded, yielding", .{slot});
            self.async_data_request = .{ .storage = .{
                .address = address,
                .slot = slot,
            } };
            return errors.CallError.NeedAsyncData;
        }

        // No injector - use host or internal HashMap
        if (self.host) |h| {
            return h.getStorage(address, slot);
        }
        return self.storage.get(key) orelse 0;
    }

    /// Set storage value
    ///
    /// Sets a contract's persistent storage slot to a new value. Automatically tracks
    /// the original value (before transaction modifications) for SSTORE gas calculations.
    ///
    /// EVM semantics: Setting a slot to 0 deletes it. In injector mode the zero is
    /// kept as an explicit overlay entry so later reads and the commit dump see the
    /// write instead of the previously fetched value.
    ///
    /// Errors:
    ///   - OutOfMemory: If tracking allocation fails
    pub fn set(self: *Storage, address: primitives.Address, slot: u256, value: u256) !void {
        const key = StorageSlotKey{ .address = address.bytes, .slot = slot };

        // Track original value on first write in transaction
        if (!self.original_storage.contains(key)) {
            try self.original_storage.put(key, self.peek(address, slot));
        }

        if (self.storage_injector) |injector| {
            // Mark first: `dirty_storage` only grows, so a failed overlay write
            // cannot leave a written slot unmarked.
            try injector.markStorageDirty(address, slot);
            // The value lives in the overlay only. The injector cache keeps the
            // fetched original until the transaction commits, so a rollback has
            // nothing to undo there (R3-001).
            try self.storage.put(key, value);
            if (self.host) |h| h.setStorage(address, slot, value);
            return;
        }

        if (self.host) |h| {
            h.setStorage(address, slot, value);
            return;
        }

        // EVM spec: storage slots with value 0 should be deleted, not stored
        if (value == 0) {
            _ = self.storage.remove(key);
        } else {
            try self.storage.put(key, value);
        }
    }

    /// Get original storage value (before transaction modifications)
    ///
    /// Returns the storage value as it existed at the start of the transaction,
    /// before any SSTORE modifications. Used for SSTORE gas calculation (EIP-2200, EIP-2929).
    pub fn get_original(self: *Storage, address: primitives.Address, slot: u256) u256 {
        const key = StorageSlotKey{ .address = address.bytes, .slot = slot };
        // If we have tracked the original, return it
        if (self.original_storage.get(key)) |original| {
            return original;
        }
        // Otherwise the slot is unchanged in this transaction.
        return self.peek(address, slot);
    }

    /// Get transient storage value (EIP-1153)
    pub fn get_transient(self: *Storage, address: primitives.Address, slot: u256) u256 {
        const key = StorageSlotKey{ .address = address.bytes, .slot = slot };
        return self.transient.get(key) orelse 0;
    }

    /// Set transient storage value (EIP-1153). Setting to 0 deletes the slot.
    pub fn set_transient(self: *Storage, address: primitives.Address, slot: u256, value: u256) !void {
        const key = StorageSlotKey{ .address = address.bytes, .slot = slot };
        if (value == 0) {
            _ = self.transient.remove(key);
        } else {
            try self.transient.put(key, value);
        }
    }

    /// Put storage value directly in cache (for async continuation)
    ///
    /// Stores a fetched value into the injector cache and the overlay without
    /// triggering original_storage tracking. Used when resuming from async data fetch.
    pub fn put_in_cache(self: *Storage, address: primitives.Address, slot: u256, value: u256) !void {
        const key = StorageSlotKey{ .address = address.bytes, .slot = slot };

        if (self.storage_injector) |injector| {
            try injector.storage_cache.put(key, value);
        }

        // Also put in self.storage so get() can find it
        try self.storage.put(key, value);
    }

    /// A transaction succeeded: fold every slot it wrote into the injector cache,
    /// so the cache keeps describing what the host holds. A written slot whose
    /// overlay entry is gone belonged to a deleted account and now reads zero.
    /// Call after end-of-transaction deletions. No-op without an injector.
    /// Never fails (see `StorageInjector.commitStorageWrite`).
    pub fn commitInjectorWrites(self: *Storage) void {
        const injector = self.storage_injector orelse return;
        var written_it = injector.dirty_storage.keyIterator();
        while (written_it.next()) |key| {
            injector.commitStorageWrite(key.*, self.storage.get(key.*) orelse 0);
        }
    }

    /// Clear transient storage (called at transaction boundaries)
    pub fn clear_transient(self: *Storage) void {
        self.transient.clearRetainingCapacity();
    }

    /// Clear async data request
    ///
    /// Resets the async data request state to .none. Called after successfully
    /// handling a NeedAsyncData yield and resuming execution.
    pub fn clear_async_request(self: *Storage) void {
        self.async_data_request = .none;
    }
};

// Tests
test "Storage: init creates empty storage" {
    const allocator = std.testing.allocator;
    var storage = Storage.init(allocator, null, null);
    defer storage.deinit();

    try std.testing.expectEqual(@as(usize, 0), storage.storage.count());
    try std.testing.expectEqual(@as(usize, 0), storage.original_storage.count());
    try std.testing.expectEqual(@as(usize, 0), storage.transient.count());
}

test "Storage: get returns 0 for empty slot" {
    const allocator = std.testing.allocator;
    var storage = Storage.init(allocator, null, null);
    defer storage.deinit();

    const addr = primitives.Address{ .bytes = [_]u8{0xab} ** 20 };
    const value = try storage.get(addr, 123);
    try std.testing.expectEqual(@as(u256, 0), value);
}

test "Storage: set and get persistent storage" {
    const allocator = std.testing.allocator;
    var storage = Storage.init(allocator, null, null);
    defer storage.deinit();

    const addr = primitives.Address{ .bytes = [_]u8{0xab} ** 20 };
    const slot: u256 = 42;
    const value: u256 = 0x1234567890abcdef;

    // Set value
    try storage.set(addr, slot, value);

    // Get value back
    const retrieved = try storage.get(addr, slot);
    try std.testing.expectEqual(value, retrieved);

    // Verify original storage was tracked
    const original = storage.get_original(addr, slot);
    try std.testing.expectEqual(@as(u256, 0), original);
}

test "Storage: set to zero deletes slot" {
    const allocator = std.testing.allocator;
    var storage = Storage.init(allocator, null, null);
    defer storage.deinit();

    const addr = primitives.Address{ .bytes = [_]u8{0xab} ** 20 };
    const slot: u256 = 42;

    // Set non-zero value
    try storage.set(addr, slot, 999);
    try std.testing.expectEqual(@as(u256, 999), try storage.get(addr, slot));

    // Set to zero (should delete)
    try storage.set(addr, slot, 0);
    try std.testing.expectEqual(@as(u256, 0), try storage.get(addr, slot));
}

test "Storage: get_original returns current for unmodified slots" {
    const allocator = std.testing.allocator;
    var storage = Storage.init(allocator, null, null);
    defer storage.deinit();

    const addr = primitives.Address{ .bytes = [_]u8{0xab} ** 20 };
    const slot: u256 = 42;

    // Set initial value
    try storage.set(addr, slot, 100);

    // First write tracks original as 0
    const original = storage.get_original(addr, slot);
    try std.testing.expectEqual(@as(u256, 0), original);

    // Modify again
    try storage.set(addr, slot, 200);

    // Original should still be 0 (first value before transaction)
    try std.testing.expectEqual(@as(u256, 0), storage.get_original(addr, slot));
}

test "Storage: transient storage get/set" {
    const allocator = std.testing.allocator;
    var storage = Storage.init(allocator, null, null);
    defer storage.deinit();

    const addr = primitives.Address{ .bytes = [_]u8{0xcd} ** 20 };
    const slot: u256 = 789;
    const value: u256 = 0xdeadbeef;

    // Get empty transient slot
    try std.testing.expectEqual(@as(u256, 0), storage.get_transient(addr, slot));

    // Set transient value
    try storage.set_transient(addr, slot, value);

    // Get transient value back
    try std.testing.expectEqual(value, storage.get_transient(addr, slot));

    // Verify it doesn't affect persistent storage
    try std.testing.expectEqual(@as(u256, 0), try storage.get(addr, slot));
}

test "Storage: transient storage set to zero deletes slot" {
    const allocator = std.testing.allocator;
    var storage = Storage.init(allocator, null, null);
    defer storage.deinit();

    const addr = primitives.Address{ .bytes = [_]u8{0xef} ** 20 };
    const slot: u256 = 100;

    // Set transient value
    try storage.set_transient(addr, slot, 12345);
    try std.testing.expectEqual(@as(u256, 12345), storage.get_transient(addr, slot));

    // Set to zero (should delete)
    try storage.set_transient(addr, slot, 0);
    try std.testing.expectEqual(@as(u256, 0), storage.get_transient(addr, slot));
}

test "Storage: clear_transient removes all transient storage" {
    const allocator = std.testing.allocator;
    var storage = Storage.init(allocator, null, null);
    defer storage.deinit();

    const addr1 = primitives.Address{ .bytes = [_]u8{0x11} ** 20 };
    const addr2 = primitives.Address{ .bytes = [_]u8{0x22} ** 20 };

    // Set multiple transient values
    try storage.set_transient(addr1, 1, 100);
    try storage.set_transient(addr1, 2, 200);
    try storage.set_transient(addr2, 1, 300);

    // Verify they exist
    try std.testing.expectEqual(@as(u256, 100), storage.get_transient(addr1, 1));
    try std.testing.expectEqual(@as(u256, 200), storage.get_transient(addr1, 2));
    try std.testing.expectEqual(@as(u256, 300), storage.get_transient(addr2, 1));

    // Clear transient storage
    storage.clear_transient();

    // Verify all are gone
    try std.testing.expectEqual(@as(u256, 0), storage.get_transient(addr1, 1));
    try std.testing.expectEqual(@as(u256, 0), storage.get_transient(addr1, 2));
    try std.testing.expectEqual(@as(u256, 0), storage.get_transient(addr2, 1));
}

test "Storage: multiple addresses with same slot" {
    const allocator = std.testing.allocator;
    var storage = Storage.init(allocator, null, null);
    defer storage.deinit();

    const addr1 = primitives.Address{ .bytes = [_]u8{0xaa} ** 20 };
    const addr2 = primitives.Address{ .bytes = [_]u8{0xbb} ** 20 };
    const slot: u256 = 1;

    // Set different values for same slot on different addresses
    try storage.set(addr1, slot, 111);
    try storage.set(addr2, slot, 222);

    // Verify they're independent
    try std.testing.expectEqual(@as(u256, 111), try storage.get(addr1, slot));
    try std.testing.expectEqual(@as(u256, 222), try storage.get(addr2, slot));
}

test "Storage: put_in_cache stores in cache and storage" {
    const allocator = std.testing.allocator;
    var injector = try storage_injector.StorageInjector.init(allocator);
    defer injector.deinit();

    var storage = Storage.init(allocator, null, &injector);
    defer storage.deinit();

    const addr = primitives.Address{ .bytes = [_]u8{0x12} ** 20 };
    const slot: u256 = 9;
    const value: u256 = 0xdead;

    try storage.put_in_cache(addr, slot, value);

    try std.testing.expectEqual(value, injector.getStorageFromCache(addr, slot).?);
    try std.testing.expectEqual(value, try storage.get(addr, slot));
}

test "Storage: clear_injector_cache clears injector cache" {
    const allocator = std.testing.allocator;
    var injector = try storage_injector.StorageInjector.init(allocator);
    defer injector.deinit();

    var storage = Storage.init(allocator, null, &injector);
    defer storage.deinit();

    const addr = primitives.Address{ .bytes = [_]u8{0x34} ** 20 };
    const slot: u256 = 2;
    const value: u256 = 0xbeef;

    try injector.cacheStorage(addr, slot, value);
    try std.testing.expectEqual(value, injector.getStorageFromCache(addr, slot).?);

    storage.clear_injector_cache();
    try std.testing.expect(injector.getStorageFromCache(addr, slot) == null);
}

test "Storage: clear_async_request resets pending request" {
    const allocator = std.testing.allocator;
    var storage = Storage.init(allocator, null, null);
    defer storage.deinit();

    const addr = primitives.Address{ .bytes = [_]u8{0x56} ** 20 };
    storage.async_data_request = .{ .storage = .{ .address = addr, .slot = 1 } };

    storage.clear_async_request();

    try std.testing.expect(switch (storage.async_data_request) {
        .none => true,
        else => false,
    });
}

test "Storage: ensureSlotLoaded is a no-op without an injector" {
    var storage = Storage.init(std.testing.allocator, null, null);
    defer storage.deinit();

    const addr = primitives.Address{ .bytes = [_]u8{0x01} ** 20 };
    try storage.ensureSlotLoaded(addr, 7);
    try std.testing.expect(storage.async_data_request == .none);
}

test "Storage: ensureSlotLoaded yields for an unloaded slot and passes once supplied" {
    const allocator = std.testing.allocator;
    var injector = try storage_injector.StorageInjector.init(allocator);
    defer injector.deinit();
    var storage = Storage.init(allocator, null, &injector);
    defer storage.deinit();

    const addr = primitives.Address{ .bytes = [_]u8{0x02} ** 20 };

    try std.testing.expectError(error.NeedAsyncData, storage.ensureSlotLoaded(addr, 7));
    try std.testing.expect(storage.async_data_request == .storage);
    try std.testing.expectEqual(@as(u256, 7), storage.async_data_request.storage.slot);
    try std.testing.expectEqualSlices(u8, &addr.bytes, &storage.async_data_request.storage.address.bytes);
    // The probe must not invent state.
    try std.testing.expectEqual(@as(usize, 0), storage.storage.count());
    try std.testing.expectEqual(@as(usize, 0), injector.dirty_storage.count());

    storage.clear_async_request();
    try storage.put_in_cache(addr, 7, 99);
    try storage.ensureSlotLoaded(addr, 7);
    try std.testing.expect(storage.async_data_request == .none);
    try std.testing.expectEqual(@as(u256, 99), try storage.get(addr, 7));
}

test "Storage: ensureSlotLoaded accepts a slot held only by the injector cache" {
    const allocator = std.testing.allocator;
    var injector = try storage_injector.StorageInjector.init(allocator);
    defer injector.deinit();
    var storage = Storage.init(allocator, null, &injector);
    defer storage.deinit();

    const addr = primitives.Address{ .bytes = [_]u8{0x03} ** 20 };
    try injector.cacheStorage(addr, 1, 55);

    try storage.ensureSlotLoaded(addr, 1);
    try std.testing.expect(storage.async_data_request == .none);
    try std.testing.expectEqual(@as(u256, 55), try storage.get(addr, 1));
}

test "Storage: injector write is visible to get and dumpChanges, and reaches the cache only on commit" {
    const allocator = std.testing.allocator;
    var injector = try storage_injector.StorageInjector.init(allocator);
    defer injector.deinit();
    var storage = Storage.init(allocator, null, &injector);
    defer storage.deinit();

    const addr = primitives.Address{ .bytes = [_]u8{0x04} ** 20 };

    // Host supplies slot 0 = 5, then SSTORE(0, 7).
    try storage.put_in_cache(addr, 0, 5);
    try storage.set(addr, 0, 7);

    try std.testing.expectEqual(@as(u256, 7), try storage.get(addr, 0));
    // R3-001: the fetched original survives the speculative write.
    try std.testing.expectEqual(@as(u256, 5), injector.getStorageFromCache(addr, 0).?);
    try std.testing.expectEqual(@as(u256, 5), storage.get_original(addr, 0));
    try std.testing.expect(injector.dirty_storage.contains(.{ .address = addr.bytes, .slot = 0 }));

    const Fake = struct {
        storage: *Storage,
        balances: std.AutoHashMap(primitives.Address, u256),
        nonces: std.AutoHashMap(primitives.Address, u64),
        code: std.AutoHashMap(primitives.Address, []const u8),
    };
    var fake = Fake{
        .storage = &storage,
        .balances = std.AutoHashMap(primitives.Address, u256).init(allocator),
        .nonces = std.AutoHashMap(primitives.Address, u64).init(allocator),
        .code = std.AutoHashMap(primitives.Address, []const u8).init(allocator),
    };
    const json = try injector.dumpChanges(&fake);
    defer allocator.free(json);
    try std.testing.expect(std.mem.indexOf(u8, json, "\"originalValue\":\"0x5\",\"newValue\":\"0x7\"") != null);

    storage.commitInjectorWrites();
    try std.testing.expectEqual(@as(u256, 7), injector.getStorageFromCache(addr, 0).?);
}

test "Storage: a rolled back injector write leaves the fetched original for the next transaction" {
    const allocator = std.testing.allocator;
    var injector = try storage_injector.StorageInjector.init(allocator);
    defer injector.deinit();
    var storage = Storage.init(allocator, null, &injector);
    defer storage.deinit();

    const addr = primitives.Address{ .bytes = [_]u8{0x08} ** 20 };
    const key = StorageSlotKey{ .address = addr.bytes, .slot = 5 };

    // Host supplies slot 5 = 5; the transaction writes 7 and is rolled back.
    try storage.put_in_cache(addr, 5, 5);
    try storage.set(addr, 5, 7);
    try storage.storage.put(key, 5);
    injector.clearDirty();

    // Next transaction: the overlay and the original-value tracking start empty.
    storage.storage.clearRetainingCapacity();
    storage.original_storage.clearRetainingCapacity();

    try storage.ensureSlotLoaded(addr, 5);
    try std.testing.expectEqual(@as(u256, 5), try storage.get(addr, 5));
    try std.testing.expectEqual(@as(u256, 5), storage.peek(addr, 5));
}

test "Storage: injector write of zero is not shadowed by the fetched value" {
    const allocator = std.testing.allocator;
    var injector = try storage_injector.StorageInjector.init(allocator);
    defer injector.deinit();
    var storage = Storage.init(allocator, null, &injector);
    defer storage.deinit();

    const addr = primitives.Address{ .bytes = [_]u8{0x05} ** 20 };
    try storage.put_in_cache(addr, 3, 42);
    try storage.set(addr, 3, 0);

    try std.testing.expectEqual(@as(u256, 0), try storage.get(addr, 3));
    try std.testing.expectEqual(@as(u256, 0), storage.peek(addr, 3));
    try std.testing.expectEqual(@as(u256, 42), storage.get_original(addr, 3));
}

test "Storage: injector overlay survives eviction of the written slot from the LRU cache" {
    const allocator = std.testing.allocator;
    var injector = try storage_injector.StorageInjector.init(allocator);
    defer injector.deinit();
    var storage = Storage.init(allocator, null, &injector);
    defer storage.deinit();

    const addr = primitives.Address{ .bytes = [_]u8{0x06} ** 20 };
    try storage.put_in_cache(addr, 0, 1);
    try storage.set(addr, 0, 2);

    // Push more entries than the cache holds so slot 0 is evicted.
    var slot: u256 = 1;
    while (slot <= 1100) : (slot += 1) try injector.cacheStorage(addr, slot, slot);
    try std.testing.expect(injector.getStorageFromCache(addr, 0) == null);

    try std.testing.expectEqual(@as(u256, 2), try storage.get(addr, 0));
}

test "Storage: a write removed from the overlay by a revert reads as zero, not the cached write" {
    const allocator = std.testing.allocator;
    var injector = try storage_injector.StorageInjector.init(allocator);
    defer injector.deinit();
    var storage = Storage.init(allocator, null, &injector);
    defer storage.deinit();

    const addr = primitives.Address{ .bytes = [_]u8{0x07} ** 20 };
    const key = StorageSlotKey{ .address = addr.bytes, .slot = 9 };

    try storage.put_in_cache(addr, 9, 0);
    try storage.set(addr, 9, 7);
    // Evm.restore_call_revert_state drops slots whose original value is zero.
    _ = storage.storage.remove(key);
    _ = storage.original_storage.remove(key);

    try std.testing.expectEqual(@as(u256, 0), try storage.get(addr, 9));
    try storage.ensureSlotLoaded(addr, 9);
}
