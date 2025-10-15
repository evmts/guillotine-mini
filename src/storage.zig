/// Storage management for the EVM
/// Handles persistent storage, transient storage (EIP-1153), and original storage tracking
const std = @import("std");
const primitives = @import("primitives");
const host = @import("host.zig");
const errors = @import("errors.zig");
const log = @import("logger.zig");
const storage_injector = @import("storage_injector.zig");
const async_executor = @import("async_executor.zig");

// Re-export from primitives for convenience
pub const StorageSlotKey = primitives.AccessList.StorageSlotKey;

// Re-export AsyncDataRequest from async_executor
pub const AsyncDataRequest = async_executor.AsyncDataRequest;

/// Storage manager - handles all storage operations for the EVM
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

    /// Clear injector cache (call at transaction start)
    pub fn clearInjectorCache(self: *Storage) void {
        if (self.storage_injector) |injector| {
            log.debug("Storage: Clearing injector cache", .{});
            injector.clearCache();
        }
    }

    /// Get storage value
    pub fn get(self: *Storage, address: primitives.Address, slot: u256) !u256 {
        const key = StorageSlotKey{ .address = address, .slot = slot };

        // If using storage injector, check cache first
        if (self.storage_injector) |injector| {
            log.debug("get_storage: Using storage injector for slot {}", .{slot});
            // Check cache first
            if (injector.storage_cache.get(key)) |value| {
                log.debug("get_storage: Cache HIT for slot {}, value={}", .{ slot, value });
                return value; // Cache hit
            }

            // Cache miss - yield to fetch from async source
            log.debug("get_storage: Cache MISS for slot {}, yielding", .{slot});
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
    pub fn set(self: *Storage, address: primitives.Address, slot: u256, value: u256) !void {
        const key = StorageSlotKey{ .address = address, .slot = slot };

        // Track original value on first write in transaction
        if (!self.original_storage.contains(key)) {
            const current = if (self.host) |h|
                h.getStorage(address, slot)
            else
                self.storage.get(key) orelse 0;
            try self.original_storage.put(key, current);
        }

        // Mark dirty if using injector
        if (self.storage_injector) |injector| {
            try injector.markStorageDirty(address, slot);
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
    pub fn getOriginal(self: *Storage, address: primitives.Address, slot: u256) u256 {
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
    pub fn getTransient(self: *Storage, address: primitives.Address, slot: u256) u256 {
        const key = StorageSlotKey{ .address = address, .slot = slot };
        return self.transient.get(key) orelse 0;
    }

    /// Set transient storage value (EIP-1153)
    pub fn setTransient(self: *Storage, address: primitives.Address, slot: u256, value: u256) !void {
        const key = StorageSlotKey{ .address = address, .slot = slot };
        if (value == 0) {
            _ = self.transient.remove(key);
        } else {
            try self.transient.put(key, value);
        }
    }

    /// Put storage value directly in cache (for async continuation)
    pub fn putInCache(self: *Storage, address: primitives.Address, slot: u256, value: u256) !void {
        const key = StorageSlotKey{ .address = address, .slot = slot };

        // Store value in both cache and storage
        if (self.storage_injector) |injector| {
            _ = try injector.storage_cache.put(key, value);
        }

        // Also put in self.storage so get() can find it
        try self.storage.put(key, value);
    }

    /// Clear transient storage (called at transaction boundaries)
    pub fn clearTransient(self: *Storage) void {
        self.transient.clearRetainingCapacity();
    }

    /// Clear async data request
    pub fn clearAsyncRequest(self: *Storage) void {
        self.async_data_request = .none;
    }
};
