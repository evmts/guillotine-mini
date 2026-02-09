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
/// var mem = MemoryDatabase.init(allocator, .state);
/// defer mem.deinit();
/// try mem.database().put("key", "value");
///
/// var ro = ReadOnlyDb.init(mem.database());
/// const iface = ro.database();
///
/// const view = try iface.get("key");
/// if (view) |val| {
///     defer val.release();
///     _ = val.bytes; // "value"
/// }
/// try iface.put("key", "new");          // error.StorageError
/// ```
///
/// ## Usage (write overlay for snapshot execution)
///
/// ```zig
/// var mem = MemoryDatabase.init(allocator, .state);
/// defer mem.deinit();
/// try mem.put("key", "original");
///
/// var ro = ReadOnlyDb.init_with_write_store(mem.database(), allocator);
/// defer ro.deinit();
/// const iface = ro.database();
///
/// try iface.put("key", "temp");          // writes to overlay only
/// const view = try iface.get("key");
/// if (view) |val| {
///     defer val.release();
///     _ = val.bytes; // "temp" (overlay wins)
/// }
/// ro.clear_temp_changes();               // discard overlay writes
/// const view2 = try iface.get("key");
/// if (view2) |val| {
///     defer val.release();
///     _ = val.bytes; // "original" (wrapped db)
/// }
/// ```
const std = @import("std");
const primitives = @import("primitives");
const adapter = @import("adapter.zig");
const ByteSliceContext = @import("byte_slice_context.zig").ByteSliceContext;
const Database = adapter.Database;
const DbEntry = adapter.DbEntry;
const DbIterator = adapter.DbIterator;
const DbMetric = adapter.DbMetric;
const DbSnapshot = adapter.DbSnapshot;
const DbValue = adapter.DbValue;
const Error = adapter.Error;
const ReadFlags = adapter.ReadFlags;
const WriteFlags = adapter.WriteFlags;
const MemoryDatabase = @import("memory.zig").MemoryDatabase;
const Bytes = primitives.Bytes;

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
        overlay.* = MemoryDatabase.init(allocator, wrapped.name());
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
    pub fn get(self: *ReadOnlyDb, key: []const u8) Error!?DbValue {
        return self.get_with_flags(key, .none);
    }

    /// Retrieve the value for `key` with explicit read flags.
    pub fn get_with_flags(self: *ReadOnlyDb, key: []const u8, flags: ReadFlags) Error!?DbValue {
        if (self.overlay) |ov| {
            if (ov.get_with_flags(key, flags)) |val| {
                return val;
            }
        }
        return self.wrapped.get_with_flags(key, flags);
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

    // -- Iterators and snapshots ----------------------------------------------

    const ReadOnlyIterator = struct {
        overlay_iter: DbIterator,
        wrapped_iter: DbIterator,
        seen: std.HashMapUnmanaged([]const u8, void, ByteSliceContext, 80) = .{},
        allocator: std.mem.Allocator,
        phase: Phase = .overlay,

        const Phase = enum { overlay, wrapped };

        fn next_impl(ptr: *anyopaque) Error!?DbEntry {
            const self: *ReadOnlyIterator = @ptrCast(@alignCast(ptr));
            while (true) {
                switch (self.phase) {
                    .overlay => {
                        const entry_opt = try self.overlay_iter.next();
                        if (entry_opt) |entry| {
                            self.seen.put(self.allocator, entry.key.bytes, {}) catch {
                                entry.release();
                                return error.OutOfMemory;
                            };
                            return entry;
                        }
                        self.phase = .wrapped;
                    },
                    .wrapped => {
                        const entry_opt = try self.wrapped_iter.next();
                        if (entry_opt) |entry| {
                            if (self.seen.contains(entry.key.bytes)) {
                                entry.release();
                                continue;
                            }
                            return entry;
                        }
                        return null;
                    },
                }
            }
        }

        fn deinit_impl(ptr: *anyopaque) void {
            const self: *ReadOnlyIterator = @ptrCast(@alignCast(ptr));
            self.overlay_iter.deinit();
            self.wrapped_iter.deinit();
            self.seen.deinit(self.allocator);
            self.allocator.destroy(self);
        }

        const vtable = DbIterator.VTable{
            .next = next_impl,
            .deinit = deinit_impl,
        };
    };

    const ReadOnlySnapshot = struct {
        wrapped: DbSnapshot,
        overlay: ?DbSnapshot,
        allocator: std.mem.Allocator,

        fn init(wrapped: DbSnapshot, overlay: ?DbSnapshot, allocator: std.mem.Allocator) Error!*ReadOnlySnapshot {
            const snapshot_ptr = allocator.create(ReadOnlySnapshot) catch return error.OutOfMemory;
            snapshot_ptr.* = .{
                .wrapped = wrapped,
                .overlay = overlay,
                .allocator = allocator,
            };
            return snapshot_ptr;
        }

        fn snapshot(self: *ReadOnlySnapshot) DbSnapshot {
            return .{
                .ptr = @ptrCast(self),
                .vtable = &snapshot_vtable,
            };
        }

        fn snapshot_get_impl(ptr: *anyopaque, key: []const u8, flags: ReadFlags) Error!?DbValue {
            const self: *ReadOnlySnapshot = @ptrCast(@alignCast(ptr));
            if (self.overlay) |ov| {
                if (try ov.get(key, flags)) |val| {
                    return val;
                }
            }
            return self.wrapped.get(key, flags);
        }

        fn snapshot_contains_impl(ptr: *anyopaque, key: []const u8) Error!bool {
            const self: *ReadOnlySnapshot = @ptrCast(@alignCast(ptr));
            if (self.overlay) |ov| {
                if (try ov.contains(key)) {
                    return true;
                }
            }
            return self.wrapped.contains(key);
        }

        fn snapshot_deinit_impl(ptr: *anyopaque) void {
            const self: *ReadOnlySnapshot = @ptrCast(@alignCast(ptr));
            if (self.overlay) |*ov| {
                ov.deinit();
            }
            self.wrapped.deinit();
            self.allocator.destroy(self);
        }

        const snapshot_vtable = DbSnapshot.VTable{
            .get = snapshot_get_impl,
            .contains = snapshot_contains_impl,
            .deinit = snapshot_deinit_impl,
        };
    };

    // -- VTable implementation ------------------------------------------------

    const vtable = Database.VTable{
        .name = name_impl,
        .get = get_impl,
        .put = put_impl,
        .delete = delete_impl,
        .contains = contains_impl,
        .iterator = iterator_impl,
        .snapshot = snapshot_impl,
        .flush = flush_impl,
        .clear = clear_impl,
        .compact = compact_impl,
        .gather_metric = gather_metric_impl,
    };

    fn name_impl(ptr: *anyopaque) adapter.DbName {
        const self: *ReadOnlyDb = @ptrCast(@alignCast(ptr));
        return self.wrapped.name();
    }

    fn get_impl(ptr: *anyopaque, key: []const u8, flags: ReadFlags) Error!?DbValue {
        const self: *ReadOnlyDb = @ptrCast(@alignCast(ptr));
        return self.get_with_flags(key, flags);
    }

    fn put_impl(ptr: *anyopaque, key: []const u8, value: ?[]const u8, flags: WriteFlags) Error!void {
        const self: *ReadOnlyDb = @ptrCast(@alignCast(ptr));
        if (self.overlay) |ov| {
            // Write to overlay only — never touches the wrapped database.
            // Mirrors Nethermind's `_memDb.Set(key, value, flags)`.
            return ov.put_with_flags(key, value, flags);
        }
        // No overlay — strict read-only mode, writes are not permitted.
        return error.StorageError;
    }

    fn delete_impl(ptr: *anyopaque, key: []const u8, flags: WriteFlags) Error!void {
        const self: *ReadOnlyDb = @ptrCast(@alignCast(ptr));
        if (self.overlay) |ov| {
            // Delete from overlay only.
            return ov.delete_with_flags(key, flags);
        }
        // No overlay — strict read-only mode, deletes are not permitted.
        return error.StorageError;
    }

    fn contains_impl(ptr: *anyopaque, key: []const u8) Error!bool {
        const self: *ReadOnlyDb = @ptrCast(@alignCast(ptr));
        return self.contains(key);
    }

    fn iterator_impl(ptr: *anyopaque, ordered: bool) Error!DbIterator {
        const self: *ReadOnlyDb = @ptrCast(@alignCast(ptr));
        if (self.overlay) |ov| {
            if (ordered) return error.UnsupportedOperation;
            const allocator = self.overlay_allocator orelse return error.OutOfMemory;
            var overlay_iter = try ov.database().iterator(false);
            errdefer overlay_iter.deinit();
            var wrapped_iter = try self.wrapped.iterator(false);
            errdefer wrapped_iter.deinit();

            const ro_iter = allocator.create(ReadOnlyIterator) catch return error.OutOfMemory;
            ro_iter.* = .{
                .overlay_iter = overlay_iter,
                .wrapped_iter = wrapped_iter,
                .allocator = allocator,
            };
            return .{
                .ptr = @ptrCast(ro_iter),
                .vtable = &ReadOnlyIterator.vtable,
            };
        }
        return self.wrapped.iterator(ordered);
    }

    fn snapshot_impl(ptr: *anyopaque) Error!DbSnapshot {
        const self: *ReadOnlyDb = @ptrCast(@alignCast(ptr));
        var wrapped_snapshot = try self.wrapped.snapshot();
        if (self.overlay) |ov| {
            errdefer wrapped_snapshot.deinit();
            var overlay_snapshot = try ov.database().snapshot();
            errdefer overlay_snapshot.deinit();
            const allocator = self.overlay_allocator orelse return error.OutOfMemory;
            const ro_snapshot = try ReadOnlySnapshot.init(wrapped_snapshot, overlay_snapshot, allocator);
            return ro_snapshot.snapshot();
        }
        return wrapped_snapshot;
    }

    fn flush_impl(_: *anyopaque, _: bool) Error!void {}

    fn clear_impl(_: *anyopaque) Error!void {
        return error.UnsupportedOperation;
    }

    fn compact_impl(_: *anyopaque) Error!void {
        return error.UnsupportedOperation;
    }

    fn gather_metric_impl(ptr: *anyopaque) Error!DbMetric {
        const self: *ReadOnlyDb = @ptrCast(@alignCast(ptr));
        return self.wrapped.gather_metric();
    }
};

// ---------------------------------------------------------------------------
// Tests — Strict read-only mode (no overlay)
// ---------------------------------------------------------------------------

test "ReadOnlyDb: get delegates to wrapped database" {
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
    defer mem.deinit();

    try mem.put("hello", "world");

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    const val = try ro.get("hello");
    try std.testing.expect(val != null);
    defer val.?.release();
    try std.testing.expectEqualStrings("world", val.?.bytes);
}

test "ReadOnlyDb: get_with_flags delegates to wrapped database" {
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
    defer mem.deinit();

    try mem.put("hello", "world");

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    const val = try ro.get_with_flags("hello", .none);
    try std.testing.expect(val != null);
    defer val.?.release();
    try std.testing.expectEqualStrings("world", val.?.bytes);
}

test "ReadOnlyDb: get missing key returns null" {
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
    defer mem.deinit();

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    const val = try ro.get("nonexistent");
    try std.testing.expect(val == null);
}

test "ReadOnlyDb: contains delegates to wrapped database" {
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
    defer mem.deinit();

    try mem.put("key", "val");

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    try std.testing.expect(try ro.contains("key"));
    try std.testing.expect(!try ro.contains("missing"));
}

test "ReadOnlyDb: put returns StorageError (no overlay)" {
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
    defer mem.deinit();

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    const iface = ro.database();
    try std.testing.expectError(error.StorageError, iface.put("key", "value"));
}

test "ReadOnlyDb: put with null returns StorageError (no overlay)" {
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
    defer mem.deinit();

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    const iface = ro.database();
    try std.testing.expectError(error.StorageError, iface.put("key", null));
}

test "ReadOnlyDb: delete returns StorageError (no overlay)" {
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
    defer mem.deinit();

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    const iface = ro.database();
    try std.testing.expectError(error.StorageError, iface.delete("key"));
}

test "ReadOnlyDb: vtable get dispatches correctly" {
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
    defer mem.deinit();

    try mem.put("key", "value");

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    const iface = ro.database();
    const val = try iface.get("key");
    try std.testing.expect(val != null);
    defer val.?.release();
    try std.testing.expectEqualStrings("value", val.?.bytes);
}

test "ReadOnlyDb: vtable contains dispatches correctly" {
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
    defer mem.deinit();

    try mem.put("key", "val");

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    const iface = ro.database();
    try std.testing.expect(try iface.contains("key"));
    try std.testing.expect(!try iface.contains("missing"));
}

test "ReadOnlyDb: reflects changes in underlying database" {
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
    defer mem.deinit();

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    // Initially empty
    try std.testing.expect((try ro.get("key")) == null);

    // Write to underlying database directly
    try mem.put("key", "value");

    // Read-only view should see the new data
    const val = try ro.get("key");
    try std.testing.expect(val != null);
    defer val.?.release();
    try std.testing.expectEqualStrings("value", val.?.bytes);
}

test "ReadOnlyDb: does not modify underlying database on write attempts" {
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
    defer mem.deinit();

    try mem.put("key", "original");

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    const iface = ro.database();

    // Attempt to overwrite — should fail
    try std.testing.expectError(error.StorageError, iface.put("key", "modified"));

    // Original value should be unchanged
    const original = mem.get("key").?;
    defer original.release();
    try std.testing.expectEqualStrings("original", original.bytes);

    // Attempt to delete — should fail
    try std.testing.expectError(error.StorageError, iface.delete("key"));

    // Original value still intact
    const still_original = mem.get("key").?;
    defer still_original.release();
    try std.testing.expectEqualStrings("original", still_original.bytes);
}

test "ReadOnlyDb: has_write_overlay is false without overlay" {
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
    defer mem.deinit();

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    try std.testing.expect(!ro.has_write_overlay());
}

test "ReadOnlyDb: clear_temp_changes is no-op without overlay" {
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
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
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
    defer mem.deinit();

    var ro = try ReadOnlyDb.init_with_write_store(mem.database(), std.testing.allocator);
    defer ro.deinit();

    try std.testing.expect(ro.has_write_overlay());
}

test "ReadOnlyDb: overlay put succeeds and get returns overlay value" {
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
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
    defer val.?.release();
    try std.testing.expectEqualStrings("new_val", val.?.bytes);

    // Should still find base value
    const base_val = try iface.get("base_key");
    try std.testing.expect(base_val != null);
    defer base_val.?.release();
    try std.testing.expectEqualStrings("base_val", base_val.?.bytes);
}

test "ReadOnlyDb: overlay value takes precedence over wrapped" {
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
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
    defer val.?.release();
    try std.testing.expectEqualStrings("overlay_value", val.?.bytes);

    // Wrapped database is untouched
    const original = mem.get("key").?;
    defer original.release();
    try std.testing.expectEqualStrings("original", original.bytes);
}

test "ReadOnlyDb: clear_temp_changes discards overlay writes" {
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
    defer mem.deinit();

    try mem.put("key", "original");

    var ro = try ReadOnlyDb.init_with_write_store(mem.database(), std.testing.allocator);
    defer ro.deinit();

    const iface = ro.database();

    // Write to overlay
    try iface.put("key", "temp_value");
    try iface.put("extra", "extra_val");

    // Verify overlay values are visible
    const temp_val = (try iface.get("key")).?;
    defer temp_val.release();
    try std.testing.expectEqualStrings("temp_value", temp_val.bytes);
    try std.testing.expect(try iface.contains("extra"));

    // Clear overlay
    ro.clear_temp_changes();

    // Overlay values are gone — falls back to wrapped
    const orig = (try iface.get("key")).?;
    defer orig.release();
    try std.testing.expectEqualStrings("original", orig.bytes);
    try std.testing.expect((try iface.get("extra")) == null);
    try std.testing.expect(!try iface.contains("extra"));
}

test "ReadOnlyDb: overlay delete does not affect wrapped database" {
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
    defer mem.deinit();

    try mem.put("key", "value");

    var ro = try ReadOnlyDb.init_with_write_store(mem.database(), std.testing.allocator);
    defer ro.deinit();

    const iface = ro.database();

    // Write a key to overlay, then delete it
    try iface.put("overlay_key", "overlay_val");
    try iface.delete("overlay_key");

    // Overlay key is gone
    try std.testing.expect((try iface.get("overlay_key")) == null);

    // Wrapped database is untouched
    const wrapped_val = mem.get("key").?;
    defer wrapped_val.release();
    try std.testing.expectEqualStrings("value", wrapped_val.bytes);
}

test "ReadOnlyDb: contains checks overlay then wrapped" {
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
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
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
    defer mem.deinit();

    var ro = try ReadOnlyDb.init_with_write_store(mem.database(), std.testing.allocator);
    defer ro.deinit();

    const iface = ro.database();

    // First round of writes
    try iface.put("key1", "val1");
    const first = (try iface.get("key1")).?;
    defer first.release();
    try std.testing.expectEqualStrings("val1", first.bytes);

    // Clear
    ro.clear_temp_changes();
    try std.testing.expect((try iface.get("key1")) == null);

    // Second round of writes — overlay should work again
    try iface.put("key2", "val2");
    const second = (try iface.get("key2")).?;
    defer second.release();
    try std.testing.expectEqualStrings("val2", second.bytes);

    // Clear again
    ro.clear_temp_changes();
    try std.testing.expect((try iface.get("key2")) == null);
}

test "ReadOnlyDb: iterator merges overlay and wrapped without duplicates" {
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
    defer mem.deinit();

    try mem.put("a", "base_a");
    try mem.put("b", "base_b");

    var ro = try ReadOnlyDb.init_with_write_store(mem.database(), std.testing.allocator);
    defer ro.deinit();

    const iface = ro.database();
    try iface.put("b", "overlay_b");
    try iface.put("c", "overlay_c");

    var it = try iface.iterator(false);
    defer it.deinit();

    var seen_a = false;
    var seen_b = false;
    var seen_c = false;
    while (try it.next()) |entry| {
        defer entry.release();
        if (Bytes.equals(entry.key.bytes, "a")) {
            seen_a = true;
            try std.testing.expectEqualStrings("base_a", entry.value.bytes);
        } else if (Bytes.equals(entry.key.bytes, "b")) {
            seen_b = true;
            try std.testing.expectEqualStrings("overlay_b", entry.value.bytes);
        } else if (Bytes.equals(entry.key.bytes, "c")) {
            seen_c = true;
            try std.testing.expectEqualStrings("overlay_c", entry.value.bytes);
        }
    }

    try std.testing.expect(seen_a);
    try std.testing.expect(seen_b);
    try std.testing.expect(seen_c);
}

test "ReadOnlyDb: iterator ordered is unsupported with overlay" {
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
    defer mem.deinit();

    var ro = try ReadOnlyDb.init_with_write_store(mem.database(), std.testing.allocator);
    defer ro.deinit();

    const iface = ro.database();
    try std.testing.expectError(error.UnsupportedOperation, iface.iterator(true));
}

test "ReadOnlyDb: snapshot captures overlay and wrapped state" {
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
    defer mem.deinit();

    try mem.put("base", "old");

    var ro = try ReadOnlyDb.init_with_write_store(mem.database(), std.testing.allocator);
    defer ro.deinit();

    const iface = ro.database();
    try iface.put("overlay", "ov1");

    var snap = try iface.snapshot();
    defer snap.deinit();

    try mem.put("base", "new");
    try iface.put("overlay", "ov2");

    const base_val = (try snap.get("base", .none)).?;
    defer base_val.release();
    try std.testing.expectEqualStrings("old", base_val.bytes);

    const overlay_val = (try snap.get("overlay", .none)).?;
    defer overlay_val.release();
    try std.testing.expectEqualStrings("ov1", overlay_val.bytes);

    try std.testing.expect(try snap.contains("overlay"));
    try std.testing.expect(!try snap.contains("missing"));
    try std.testing.expectError(error.UnsupportedOperation, snap.iterator(false));
}

test "ReadOnlyDb: wrapped database never modified by overlay writes" {
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
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
    const existing = mem.get("existing").?;
    defer existing.release();
    try std.testing.expectEqualStrings("original", existing.bytes);
    try std.testing.expect(mem.get("new_key") == null);

    // Even after clearing overlay, wrapped database is still pristine
    ro.clear_temp_changes();
    const existing_after = mem.get("existing").?;
    defer existing_after.release();
    try std.testing.expectEqualStrings("original", existing_after.bytes);
    try std.testing.expect(mem.get("new_key") == null);
}

test "ReadOnlyDb: deinit frees overlay memory (leak check)" {
    var mem = MemoryDatabase.init(std.testing.allocator, .state);
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
