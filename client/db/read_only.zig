/// Read-only database decorator implementing the `Database` interface.
///
/// Modeled after Nethermind's `ReadOnlyDb` (`Nethermind.Db/ReadOnlyDb.cs`):
/// wraps any `Database` and optionally provides an in-memory write overlay
/// (`MemoryDatabase`) for temporary changes during snapshot execution.
///
/// ## Modes
///
/// - **Strict read-only** (`init`): All writes return `error.StorageError`.
///   Reads delegate directly to the wrapped database.
///
/// - **Write overlay** (`init_with_write_store`): Writes go to an in-memory
///   overlay (`MemoryDatabase`). Reads check the overlay first, then fall
///   back to the wrapped database. Call `clear_temp_changes()` to discard all
///   overlay writes without affecting the wrapped database.
///
/// This matches Nethermind's `ReadOnlyDb(wrappedDb, createInMemWriteStore)`
/// constructor pattern and `ClearTempChanges()` method.
///
/// ## Usage (strict read-only)
///
/// ```zig
/// var mem = MemoryDatabase.init(allocator);
/// defer mem.deinit();
/// try mem.database().put("key", "value");
///
/// var ro = ReadOnlyDb.init(mem.database());
/// const iface = ro.database();
///
/// const val = try iface.get("key");     // returns "value"
/// try iface.put("key", "new");          // error.StorageError
/// ```
///
/// ## Usage (write overlay for snapshot execution)
///
/// ```zig
/// var mem = MemoryDatabase.init(allocator);
/// defer mem.deinit();
/// try mem.put("key", "original");
///
/// var ro = ReadOnlyDb.init_with_write_store(mem.database(), allocator);
/// defer ro.deinit();
/// const iface = ro.database();
///
/// try iface.put("key", "temp");          // writes to overlay only
/// const val = try iface.get("key");      // returns "temp" (overlay wins)
/// ro.clear_temp_changes();               // discard overlay writes
/// const val2 = try iface.get("key");     // returns "original" (wrapped db)
/// ```
const std = @import("std");
const adapter = @import("adapter.zig");
const Database = adapter.Database;
const Error = adapter.Error;
const MemoryDatabase = @import("memory.zig").MemoryDatabase;

/// Read-only wrapper around any `Database` with optional in-memory write overlay.
///
/// Mirrors Nethermind's `ReadOnlyDb`:
/// - Reads: check overlay first (if present), then fall back to wrapped database.
/// - Writes: buffer in overlay if `create_in_mem_write_store` was set, else error.
/// - `clear_temp_changes()`: wipe overlay without touching wrapped database.
///
/// When `overlay` is null, the struct is zero-allocation (strict read-only mode).
/// When `overlay` is non-null, it owns the MemoryDatabase and frees it on `deinit`.
pub const ReadOnlyDb = struct {
    /// The underlying database to delegate reads to.
    wrapped: Database,
    /// Optional in-memory write overlay for temporary changes.
    /// When non-null, writes go here and reads check here first.
    /// Mirrors Nethermind's `_memDb` field in `ReadOnlyDb.cs`.
    overlay: ?*MemoryDatabase,
    /// Allocator used to free the overlay on deinit (only set when overlay is owned).
    overlay_allocator: ?std.mem.Allocator,

    /// Create a strict read-only view over the given database (no write overlay).
    ///
    /// All write operations (put, delete) return `error.StorageError`.
    /// Equivalent to Nethermind's `ReadOnlyDb(wrappedDb, createInMemWriteStore: false)`.
    pub fn init(wrapped: Database) ReadOnlyDb {
        return .{
            .wrapped = wrapped,
            .overlay = null,
            .overlay_allocator = null,
        };
    }

    /// Create a read-only view with an in-memory write overlay.
    ///
    /// Writes are buffered in the overlay and do not touch the wrapped database.
    /// Reads check the overlay first, then fall back to the wrapped database.
    /// Call `clear_temp_changes()` to discard all overlay writes.
    ///
    /// Equivalent to Nethermind's `ReadOnlyDb(wrappedDb, createInMemWriteStore: true)`.
    pub fn init_with_write_store(wrapped: Database, allocator: std.mem.Allocator) Error!ReadOnlyDb {
        const overlay = allocator.create(MemoryDatabase) catch return error.OutOfMemory;
        overlay.* = MemoryDatabase.init(allocator);
        return .{
            .wrapped = wrapped,
            .overlay = overlay,
            .overlay_allocator = allocator,
        };
    }

    /// Release owned resources. If an overlay was created, frees it.
    pub fn deinit(self: *ReadOnlyDb) void {
        if (self.overlay) |ov| {
            ov.deinit();
            if (self.overlay_allocator) |alloc| {
                alloc.destroy(ov);
            }
            self.overlay = null;
        }
    }

    /// Return a `Database` vtable interface backed by this ReadOnlyDb.
    pub fn database(self: *ReadOnlyDb) Database {
        return .{
            .ptr = @ptrCast(self),
            .vtable = &vtable,
        };
    }

    // -- Direct (non-vtable) methods ------------------------------------------

    /// Retrieve the value for `key`.
    ///
    /// If a write overlay is present, checks it first (overlay values take
    /// precedence). Falls back to the wrapped database if not found in overlay.
    /// Mirrors Nethermind's `_memDb.Get(key) ?? wrappedDb.Get(key)`.
    pub fn get(self: *ReadOnlyDb, key: []const u8) Error!?[]const u8 {
        if (self.overlay) |ov| {
            if (ov.get(key)) |val| {
                return val;
            }
        }
        return self.wrapped.get(key);
    }

    /// Check whether `key` exists in the overlay or wrapped database.
    ///
    /// Mirrors Nethermind's `_memDb.KeyExists(key) || wrappedDb.KeyExists(key)`.
    pub fn contains(self: *ReadOnlyDb, key: []const u8) Error!bool {
        if (self.overlay) |ov| {
            if (ov.contains(key)) {
                return true;
            }
        }
        return self.wrapped.contains(key);
    }

    /// Discard all temporary writes in the overlay without affecting the
    /// wrapped database.
    ///
    /// No-op if no write overlay was created.
    /// Mirrors Nethermind's `ClearTempChanges()` which calls `_memDb.Clear()`.
    pub fn clear_temp_changes(self: *ReadOnlyDb) void {
        if (self.overlay) |ov| {
            ov.clear();
        }
    }

    /// Return whether this ReadOnlyDb has a write overlay enabled.
    pub fn has_write_overlay(self: *const ReadOnlyDb) bool {
        return self.overlay != null;
    }

    // -- VTable implementation ------------------------------------------------

    const vtable = Database.VTable{
        .get = get_impl,
        .put = put_impl,
        .delete = delete_impl,
        .contains = contains_impl,
    };

    fn get_impl(ptr: *anyopaque, key: []const u8) Error!?[]const u8 {
        const self: *ReadOnlyDb = @ptrCast(@alignCast(ptr));
        return self.get(key);
    }

    fn put_impl(ptr: *anyopaque, key: []const u8, value: ?[]const u8) Error!void {
        const self: *ReadOnlyDb = @ptrCast(@alignCast(ptr));
        if (self.overlay) |ov| {
            // Write to overlay only — never touches the wrapped database.
            // Mirrors Nethermind's `_memDb.Set(key, value, flags)`.
            return ov.put(key, value);
        }
        // No overlay — strict read-only mode, writes are not permitted.
        return error.StorageError;
    }

    fn delete_impl(ptr: *anyopaque, key: []const u8) Error!void {
        const self: *ReadOnlyDb = @ptrCast(@alignCast(ptr));
        if (self.overlay) |ov| {
            // Delete from overlay only.
            ov.delete(key);
            return;
        }
        // No overlay — strict read-only mode, deletes are not permitted.
        return error.StorageError;
    }

    fn contains_impl(ptr: *anyopaque, key: []const u8) Error!bool {
        const self: *ReadOnlyDb = @ptrCast(@alignCast(ptr));
        return self.contains(key);
    }
};

// ---------------------------------------------------------------------------
// Tests — Strict read-only mode (no overlay)
// ---------------------------------------------------------------------------

test "ReadOnlyDb: get delegates to wrapped database" {
    var mem = MemoryDatabase.init(std.testing.allocator);
    defer mem.deinit();

    try mem.put("hello", "world");

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    const val = try ro.get("hello");
    try std.testing.expect(val != null);
    try std.testing.expectEqualStrings("world", val.?);
}

test "ReadOnlyDb: get missing key returns null" {
    var mem = MemoryDatabase.init(std.testing.allocator);
    defer mem.deinit();

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    const val = try ro.get("nonexistent");
    try std.testing.expectEqual(null, val);
}

test "ReadOnlyDb: contains delegates to wrapped database" {
    var mem = MemoryDatabase.init(std.testing.allocator);
    defer mem.deinit();

    try mem.put("key", "val");

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    try std.testing.expect(try ro.contains("key"));
    try std.testing.expect(!try ro.contains("missing"));
}

test "ReadOnlyDb: put returns StorageError (no overlay)" {
    var mem = MemoryDatabase.init(std.testing.allocator);
    defer mem.deinit();

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    const iface = ro.database();
    try std.testing.expectError(error.StorageError, iface.put("key", "value"));
}

test "ReadOnlyDb: put with null returns StorageError (no overlay)" {
    var mem = MemoryDatabase.init(std.testing.allocator);
    defer mem.deinit();

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    const iface = ro.database();
    try std.testing.expectError(error.StorageError, iface.put("key", null));
}

test "ReadOnlyDb: delete returns StorageError (no overlay)" {
    var mem = MemoryDatabase.init(std.testing.allocator);
    defer mem.deinit();

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    const iface = ro.database();
    try std.testing.expectError(error.StorageError, iface.delete("key"));
}

test "ReadOnlyDb: vtable get dispatches correctly" {
    var mem = MemoryDatabase.init(std.testing.allocator);
    defer mem.deinit();

    try mem.put("key", "value");

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    const iface = ro.database();
    const val = try iface.get("key");
    try std.testing.expect(val != null);
    try std.testing.expectEqualStrings("value", val.?);
}

test "ReadOnlyDb: vtable contains dispatches correctly" {
    var mem = MemoryDatabase.init(std.testing.allocator);
    defer mem.deinit();

    try mem.put("key", "val");

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    const iface = ro.database();
    try std.testing.expect(try iface.contains("key"));
    try std.testing.expect(!try iface.contains("missing"));
}

test "ReadOnlyDb: reflects changes in underlying database" {
    var mem = MemoryDatabase.init(std.testing.allocator);
    defer mem.deinit();

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    // Initially empty
    try std.testing.expectEqual(null, try ro.get("key"));

    // Write to underlying database directly
    try mem.put("key", "value");

    // Read-only view should see the new data
    const val = try ro.get("key");
    try std.testing.expect(val != null);
    try std.testing.expectEqualStrings("value", val.?);
}

test "ReadOnlyDb: does not modify underlying database on write attempts" {
    var mem = MemoryDatabase.init(std.testing.allocator);
    defer mem.deinit();

    try mem.put("key", "original");

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    const iface = ro.database();

    // Attempt to overwrite — should fail
    try std.testing.expectError(error.StorageError, iface.put("key", "modified"));

    // Original value should be unchanged
    try std.testing.expectEqualStrings("original", mem.get("key").?);

    // Attempt to delete — should fail
    try std.testing.expectError(error.StorageError, iface.delete("key"));

    // Original value still intact
    try std.testing.expectEqualStrings("original", mem.get("key").?);
}

test "ReadOnlyDb: has_write_overlay is false without overlay" {
    var mem = MemoryDatabase.init(std.testing.allocator);
    defer mem.deinit();

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    try std.testing.expect(!ro.has_write_overlay());
}

test "ReadOnlyDb: clear_temp_changes is no-op without overlay" {
    var mem = MemoryDatabase.init(std.testing.allocator);
    defer mem.deinit();

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    // Should not panic or crash
    ro.clear_temp_changes();
}

// ---------------------------------------------------------------------------
// Tests — Write overlay mode (Nethermind ClearTempChanges pattern)
// ---------------------------------------------------------------------------

test "ReadOnlyDb: init_with_write_store enables overlay" {
    var mem = MemoryDatabase.init(std.testing.allocator);
    defer mem.deinit();

    var ro = try ReadOnlyDb.init_with_write_store(mem.database(), std.testing.allocator);
    defer ro.deinit();

    try std.testing.expect(ro.has_write_overlay());
}

test "ReadOnlyDb: overlay put succeeds and get returns overlay value" {
    var mem = MemoryDatabase.init(std.testing.allocator);
    defer mem.deinit();

    try mem.put("base_key", "base_val");

    var ro = try ReadOnlyDb.init_with_write_store(mem.database(), std.testing.allocator);
    defer ro.deinit();

    const iface = ro.database();

    // Write to overlay
    try iface.put("new_key", "new_val");

    // Should find overlay value
    const val = try iface.get("new_key");
    try std.testing.expect(val != null);
    try std.testing.expectEqualStrings("new_val", val.?);

    // Should still find base value
    const base_val = try iface.get("base_key");
    try std.testing.expect(base_val != null);
    try std.testing.expectEqualStrings("base_val", base_val.?);
}

test "ReadOnlyDb: overlay value takes precedence over wrapped" {
    var mem = MemoryDatabase.init(std.testing.allocator);
    defer mem.deinit();

    try mem.put("key", "original");

    var ro = try ReadOnlyDb.init_with_write_store(mem.database(), std.testing.allocator);
    defer ro.deinit();

    const iface = ro.database();

    // Overwrite in overlay
    try iface.put("key", "overlay_value");

    // Overlay wins
    const val = try iface.get("key");
    try std.testing.expect(val != null);
    try std.testing.expectEqualStrings("overlay_value", val.?);

    // Wrapped database is untouched
    try std.testing.expectEqualStrings("original", mem.get("key").?);
}

test "ReadOnlyDb: clear_temp_changes discards overlay writes" {
    var mem = MemoryDatabase.init(std.testing.allocator);
    defer mem.deinit();

    try mem.put("key", "original");

    var ro = try ReadOnlyDb.init_with_write_store(mem.database(), std.testing.allocator);
    defer ro.deinit();

    const iface = ro.database();

    // Write to overlay
    try iface.put("key", "temp_value");
    try iface.put("extra", "extra_val");

    // Verify overlay values are visible
    try std.testing.expectEqualStrings("temp_value", (try iface.get("key")).?);
    try std.testing.expect(try iface.contains("extra"));

    // Clear overlay
    ro.clear_temp_changes();

    // Overlay values are gone — falls back to wrapped
    try std.testing.expectEqualStrings("original", (try iface.get("key")).?);
    try std.testing.expectEqual(null, try iface.get("extra"));
    try std.testing.expect(!try iface.contains("extra"));
}

test "ReadOnlyDb: overlay delete does not affect wrapped database" {
    var mem = MemoryDatabase.init(std.testing.allocator);
    defer mem.deinit();

    try mem.put("key", "value");

    var ro = try ReadOnlyDb.init_with_write_store(mem.database(), std.testing.allocator);
    defer ro.deinit();

    const iface = ro.database();

    // Write a key to overlay, then delete it
    try iface.put("overlay_key", "overlay_val");
    try iface.delete("overlay_key");

    // Overlay key is gone
    try std.testing.expectEqual(null, try iface.get("overlay_key"));

    // Wrapped database is untouched
    try std.testing.expectEqualStrings("value", mem.get("key").?);
}

test "ReadOnlyDb: contains checks overlay then wrapped" {
    var mem = MemoryDatabase.init(std.testing.allocator);
    defer mem.deinit();

    try mem.put("wrapped_key", "val");

    var ro = try ReadOnlyDb.init_with_write_store(mem.database(), std.testing.allocator);
    defer ro.deinit();

    const iface = ro.database();

    // Key only in wrapped
    try std.testing.expect(try iface.contains("wrapped_key"));

    // Key only in overlay
    try iface.put("overlay_key", "oval");
    try std.testing.expect(try iface.contains("overlay_key"));

    // Missing from both
    try std.testing.expect(!try iface.contains("missing"));
}

test "ReadOnlyDb: overlay reusable after clear_temp_changes" {
    var mem = MemoryDatabase.init(std.testing.allocator);
    defer mem.deinit();

    var ro = try ReadOnlyDb.init_with_write_store(mem.database(), std.testing.allocator);
    defer ro.deinit();

    const iface = ro.database();

    // First round of writes
    try iface.put("key1", "val1");
    try std.testing.expectEqualStrings("val1", (try iface.get("key1")).?);

    // Clear
    ro.clear_temp_changes();
    try std.testing.expectEqual(null, try iface.get("key1"));

    // Second round of writes — overlay should work again
    try iface.put("key2", "val2");
    try std.testing.expectEqualStrings("val2", (try iface.get("key2")).?);

    // Clear again
    ro.clear_temp_changes();
    try std.testing.expectEqual(null, try iface.get("key2"));
}

test "ReadOnlyDb: wrapped database never modified by overlay writes" {
    var mem = MemoryDatabase.init(std.testing.allocator);
    defer mem.deinit();

    try mem.put("existing", "original");

    var ro = try ReadOnlyDb.init_with_write_store(mem.database(), std.testing.allocator);
    defer ro.deinit();

    const iface = ro.database();

    // Overlay write to existing key
    try iface.put("existing", "modified");
    // Overlay write to new key
    try iface.put("new_key", "new_val");

    // Wrapped database should have NO changes
    try std.testing.expectEqualStrings("original", mem.get("existing").?);
    try std.testing.expectEqual(null, mem.get("new_key"));

    // Even after clearing overlay, wrapped database is still pristine
    ro.clear_temp_changes();
    try std.testing.expectEqualStrings("original", mem.get("existing").?);
    try std.testing.expectEqual(null, mem.get("new_key"));
}

test "ReadOnlyDb: deinit frees overlay memory (leak check)" {
    var mem = MemoryDatabase.init(std.testing.allocator);
    defer mem.deinit();

    var ro = try ReadOnlyDb.init_with_write_store(mem.database(), std.testing.allocator);

    // Write some data to the overlay
    const iface = ro.database();
    try iface.put("key1", "value1_with_some_length");
    try iface.put("key2", "value2_with_some_length");
    try iface.put("key3", "value3_with_some_length");

    // If deinit doesn't free properly, testing allocator will report a leak
    ro.deinit();
}
