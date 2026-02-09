/// Null database backend implementing the `Database` interface.
///
/// Follows the Null Object pattern from Nethermind's `NullDb`
/// (`Nethermind.Db/NullDb.cs`):
///   - All read operations return `null` / `false` (no data stored).
///   - All write operations return `error.StorageError` (not supported).
///   - `deinit()` is a no-op (no resources to release).
///
/// Use this backend when a `Database` interface is required but no
/// persistence is needed (e.g., tests that only exercise in-memory state,
/// or components that must satisfy a database dependency without storage).
///
/// For actual in-memory storage, use `MemoryDatabase` instead.
const std = @import("std");
const adapter = @import("adapter.zig");
const Database = adapter.Database;
const DbMetric = adapter.DbMetric;
const DbName = adapter.DbName;
const DbSnapshot = adapter.DbSnapshot;
const DbValue = adapter.DbValue;
const Error = adapter.Error;
const ReadFlags = adapter.ReadFlags;
const WriteFlags = adapter.WriteFlags;

/// Null database — satisfies the `Database` interface without storing data.
///
/// Mirrors Nethermind's `NullDb` singleton pattern. In Zig we use a simple
/// zero-sized struct instead of a singleton since there is no shared mutable
/// state.
///
/// ## Usage
///
/// ```zig
/// var ndb = NullDb{};
/// const iface = ndb.database();
/// const result = try iface.get("any_key"); // always null
/// ```
pub const NullDb = struct {
    name: DbName,

    pub fn init(name: DbName) NullDb {
        return .{ .name = name };
    }

    /// Return a `Database` vtable interface backed by this NullDb.
    pub fn database(self: *NullDb) Database {
        return .{
            .ptr = @ptrCast(self),
            .vtable = &vtable,
        };
    }

    /// No-op — NullDb holds no resources.
    pub fn deinit(self: *NullDb) void {
        _ = self;
    }

    // -- VTable implementation (Null Object pattern) --------------------------

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

    fn name_impl(ptr: *anyopaque) DbName {
        const self: *NullDb = @ptrCast(@alignCast(ptr));
        return self.name;
    }

    fn get_impl(_: *anyopaque, _: []const u8, _: ReadFlags) Error!?DbValue {
        // Null database: no data stored, always returns null.
        return null;
    }

    fn put_impl(_: *anyopaque, _: []const u8, _: ?[]const u8, _: WriteFlags) Error!void {
        // Null database: writes are not supported.
        return error.StorageError;
    }

    fn delete_impl(_: *anyopaque, _: []const u8, _: WriteFlags) Error!void {
        // Null database: deletes are not supported.
        return error.StorageError;
    }

    fn contains_impl(_: *anyopaque, _: []const u8) Error!bool {
        // Null database: no data stored, key never exists.
        return false;
    }

    const EmptyIterator = struct {
        fn next_impl(_: *anyopaque) Error!?adapter.DbEntry {
            return null;
        }

        fn deinit_impl(_: *anyopaque) void {}

        const vtable = adapter.DbIterator.VTable{
            .next = next_impl,
            .deinit = deinit_impl,
        };
    };

    fn iterator_impl(_: *anyopaque, _: bool) Error!adapter.DbIterator {
        return .{
            .ptr = @ptrCast(@constCast(&empty_iterator)),
            .vtable = &EmptyIterator.vtable,
        };
    }

    const NullSnapshot = struct {
        fn snapshot_get_impl(_: *anyopaque, _: []const u8, _: ReadFlags) Error!?DbValue {
            return null;
        }

        fn snapshot_contains_impl(_: *anyopaque, _: []const u8) Error!bool {
            return false;
        }

        fn snapshot_iterator_impl(_: *anyopaque, _: bool) Error!adapter.DbIterator {
            return .{
                .ptr = @ptrCast(@constCast(&empty_iterator)),
                .vtable = &EmptyIterator.vtable,
            };
        }

        fn snapshot_deinit_impl(_: *anyopaque) void {}

        const snapshot_vtable = DbSnapshot.VTable{
            .get = snapshot_get_impl,
            .contains = snapshot_contains_impl,
            .iterator = snapshot_iterator_impl,
            .deinit = snapshot_deinit_impl,
        };
    };

    fn snapshot_impl(_: *anyopaque) Error!DbSnapshot {
        return .{
            .ptr = @ptrCast(@constCast(&null_snapshot)),
            .vtable = &NullSnapshot.snapshot_vtable,
        };
    }

    fn flush_impl(_: *anyopaque, _: bool) Error!void {}

    fn clear_impl(_: *anyopaque) Error!void {}

    fn compact_impl(_: *anyopaque) Error!void {}

    fn gather_metric_impl(_: *anyopaque) Error!DbMetric {
        return .{};
    }
};

const empty_iterator = NullDb.EmptyIterator{};
const null_snapshot = NullDb.NullSnapshot{};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

test "NullDb: get always returns null" {
    var ndb = NullDb.init(.state);
    defer ndb.deinit();

    const iface = ndb.database();
    const result = try iface.get("any_key");
    try std.testing.expect(result == null);
}

test "NullDb: contains always returns false" {
    var ndb = NullDb.init(.state);
    defer ndb.deinit();

    const iface = ndb.database();
    const result = try iface.contains("any_key");
    try std.testing.expect(!result);
}

test "NullDb: put returns StorageError" {
    var ndb = NullDb.init(.state);
    defer ndb.deinit();

    const iface = ndb.database();
    try std.testing.expectError(error.StorageError, iface.put("key", "value"));
}

test "NullDb: put with null returns StorageError" {
    var ndb = NullDb.init(.state);
    defer ndb.deinit();

    const iface = ndb.database();
    try std.testing.expectError(error.StorageError, iface.put("key", null));
}

test "NullDb: delete returns StorageError" {
    var ndb = NullDb.init(.state);
    defer ndb.deinit();

    const iface = ndb.database();
    try std.testing.expectError(error.StorageError, iface.delete("key"));
}

test "NullDb: multiple instances are independent" {
    var ndb1 = NullDb.init(.state);
    defer ndb1.deinit();

    var ndb2 = NullDb.init(.state);
    defer ndb2.deinit();

    const iface1 = ndb1.database();
    const iface2 = ndb2.database();

    try std.testing.expectEqual(null, try iface1.get("key"));
    try std.testing.expectEqual(null, try iface2.get("key"));
}

test "NullDb: name is accessible via interface" {
    var ndb = NullDb.init(.headers);
    defer ndb.deinit();

    const iface = ndb.database();
    try std.testing.expectEqual(DbName.headers, iface.name());
}

test "NullDb: iterator yields no entries" {
    var ndb = NullDb.init(.state);
    defer ndb.deinit();

    const iface = ndb.database();
    var it = try iface.iterator(false);
    defer it.deinit();

    try std.testing.expect((try it.next()) == null);
}

test "NullDb: snapshot returns null and empty iterator" {
    var ndb = NullDb.init(.state);
    defer ndb.deinit();

    const iface = ndb.database();
    var snap = try iface.snapshot();
    defer snap.deinit();

    try std.testing.expect((try snap.get("key", .none)) == null);
    try std.testing.expect(!try snap.contains("key"));

    var it = try snap.iterator(false);
    defer it.deinit();
    try std.testing.expect((try it.next()) == null);
}
