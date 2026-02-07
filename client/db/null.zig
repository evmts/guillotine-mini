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
const Error = adapter.Error;

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
        .get = getImpl,
        .put = putImpl,
        .delete = deleteImpl,
        .contains = containsImpl,
    };

    fn getImpl(_: *anyopaque, _: []const u8) Error!?[]const u8 {
        // Null database: no data stored, always returns null.
        return null;
    }

    fn putImpl(_: *anyopaque, _: []const u8, _: ?[]const u8) Error!void {
        // Null database: writes are not supported.
        return error.StorageError;
    }

    fn deleteImpl(_: *anyopaque, _: []const u8) Error!void {
        // Null database: deletes are not supported.
        return error.StorageError;
    }

    fn containsImpl(_: *anyopaque, _: []const u8) Error!bool {
        // Null database: no data stored, key never exists.
        return false;
    }
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

test "NullDb: get always returns null" {
    var ndb = NullDb{};
    defer ndb.deinit();

    const iface = ndb.database();
    const result = try iface.get("any_key");
    try std.testing.expectEqual(null, result);
}

test "NullDb: contains always returns false" {
    var ndb = NullDb{};
    defer ndb.deinit();

    const iface = ndb.database();
    const result = try iface.contains("any_key");
    try std.testing.expect(!result);
}

test "NullDb: put returns StorageError" {
    var ndb = NullDb{};
    defer ndb.deinit();

    const iface = ndb.database();
    try std.testing.expectError(error.StorageError, iface.put("key", "value"));
}

test "NullDb: put with null returns StorageError" {
    var ndb = NullDb{};
    defer ndb.deinit();

    const iface = ndb.database();
    try std.testing.expectError(error.StorageError, iface.put("key", null));
}

test "NullDb: delete returns StorageError" {
    var ndb = NullDb{};
    defer ndb.deinit();

    const iface = ndb.database();
    try std.testing.expectError(error.StorageError, iface.delete("key"));
}

test "NullDb: multiple instances are independent" {
    var ndb1 = NullDb{};
    defer ndb1.deinit();

    var ndb2 = NullDb{};
    defer ndb2.deinit();

    const iface1 = ndb1.database();
    const iface2 = ndb2.database();

    try std.testing.expectEqual(null, try iface1.get("key"));
    try std.testing.expectEqual(null, try iface2.get("key"));
}
