/// RocksDB database backend stub implementing the `Database` interface.
///
/// This is a placeholder for the eventual RocksDB FFI backend. Currently
/// behaves as a "null database" (reads return null, writes return
/// `StorageError`) following Nethermind's `NullDb` pattern from
/// `Nethermind.Db/NullDb.cs`.
///
/// The `DbSettings` struct mirrors Nethermind's `RocksDbSettings` and will
/// be used to configure the real RocksDB backend when FFI bindings are added.
///
/// ## Future Work
///
/// - Replace stub vtable functions with RocksDB C API calls
/// - Add column family support (`IColumnsDb<T>` equivalent)
/// - Implement native `writeBatch` via RocksDB WriteBatch
/// - Add `ReadFlags` / `WriteFlags` hint enums for tuning
/// - Add `DbMetric` for monitoring (size, cache, reads, writes)
const std = @import("std");
const adapter = @import("adapter.zig");
const Database = adapter.Database;
const DbName = adapter.DbName;
const Error = adapter.Error;

/// Configuration for a RocksDB database instance.
///
/// Mirrors Nethermind's `RocksDbSettings` (`Nethermind.Db/RocksDbSettings.cs`):
/// constructor takes (name, path), plus optional flags for lifecycle management.
///
/// When the real RocksDB backend is implemented, this struct will be extended
/// with tuning parameters (block cache size, write buffer count, compression
/// type, etc.).
pub const DbSettings = struct {
    /// Logical database name (matches a `DbName` variant, e.g. "state", "code").
    name: []const u8,
    /// Filesystem path for the RocksDB data directory.
    path: []const u8,
    /// If true, delete existing data on startup (fresh sync).
    delete_on_start: bool = false,
    /// If true, the data folder can be deleted during cleanup.
    can_delete_folder: bool = true,

    /// Create a copy of these settings with a new name and path.
    /// Mirrors Nethermind's `DbSettings.Clone(name, path)`.
    pub fn clone(self: DbSettings, name: []const u8, path: []const u8) DbSettings {
        return .{
            .name = name,
            .path = path,
            .delete_on_start = self.delete_on_start,
            .can_delete_folder = self.can_delete_folder,
        };
    }
};

/// Stub RocksDB database implementing the `Database` vtable interface.
///
/// Follows the Null Object pattern (Nethermind's `NullDb`):
///   - All read operations return `null` / `false` (no data).
///   - All write operations return `error.StorageError` (not supported).
///   - `deinit()` is a no-op (no resources to release).
///
/// This allows higher-level code to depend on the `Database` interface
/// while the real RocksDB backend is not yet implemented. Tests that need
/// actual storage should use `MemoryDatabase` instead.
pub const RocksDatabase = struct {
    /// Settings used to configure this database instance.
    settings: DbSettings,

    /// Create a new RocksDatabase stub with the given settings.
    ///
    /// In the real implementation, this would open a RocksDB instance at
    /// `settings.path`. Currently, no resources are allocated.
    pub fn init(settings: DbSettings) RocksDatabase {
        return .{ .settings = settings };
    }

    /// Release all resources. Currently a no-op (stub has no resources).
    pub fn deinit(self: *RocksDatabase) void {
        _ = self;
    }

    /// Return a `Database` vtable interface backed by this RocksDatabase.
    pub fn database(self: *RocksDatabase) Database {
        return .{
            .ptr = @ptrCast(self),
            .vtable = &vtable,
        };
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
        // Stub: writes are not supported.
        return error.StorageError;
    }

    fn deleteImpl(_: *anyopaque, _: []const u8) Error!void {
        // Stub: deletes are not supported.
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

test "DbSettings: init with name and path" {
    const settings = DbSettings{
        .name = "state",
        .path = "/data/guillotine/state",
    };

    try std.testing.expectEqualStrings("state", settings.name);
    try std.testing.expectEqualStrings("/data/guillotine/state", settings.path);
    try std.testing.expect(!settings.delete_on_start);
    try std.testing.expect(settings.can_delete_folder);
}

test "DbSettings: clone with new name and path preserves flags" {
    const original = DbSettings{
        .name = "state",
        .path = "/data/state",
        .delete_on_start = true,
        .can_delete_folder = false,
    };

    const cloned = original.clone("code", "/data/code");

    try std.testing.expectEqualStrings("code", cloned.name);
    try std.testing.expectEqualStrings("/data/code", cloned.path);
    try std.testing.expect(cloned.delete_on_start);
    try std.testing.expect(!cloned.can_delete_folder);
}

test "RocksDatabase: get always returns null (null object)" {
    var db = RocksDatabase.init(.{ .name = "test", .path = "/tmp/test" });
    defer db.deinit();

    const iface = db.database();
    const result = try iface.get("any_key");
    try std.testing.expectEqual(null, result);
}

test "RocksDatabase: contains always returns false (null object)" {
    var db = RocksDatabase.init(.{ .name = "test", .path = "/tmp/test" });
    defer db.deinit();

    const iface = db.database();
    const result = try iface.contains("any_key");
    try std.testing.expect(!result);
}

test "RocksDatabase: put returns StorageError (stub)" {
    var db = RocksDatabase.init(.{ .name = "test", .path = "/tmp/test" });
    defer db.deinit();

    const iface = db.database();
    try std.testing.expectError(error.StorageError, iface.put("key", "value"));
}

test "RocksDatabase: put with null returns StorageError (stub)" {
    var db = RocksDatabase.init(.{ .name = "test", .path = "/tmp/test" });
    defer db.deinit();

    const iface = db.database();
    try std.testing.expectError(error.StorageError, iface.put("key", null));
}

test "RocksDatabase: delete returns StorageError (stub)" {
    var db = RocksDatabase.init(.{ .name = "test", .path = "/tmp/test" });
    defer db.deinit();

    const iface = db.database();
    try std.testing.expectError(error.StorageError, iface.delete("key"));
}

test "RocksDatabase: settings are accessible after init" {
    const settings = DbSettings{
        .name = "headers",
        .path = "/var/lib/guillotine/headers",
        .delete_on_start = true,
    };

    var db = RocksDatabase.init(settings);
    defer db.deinit();

    try std.testing.expectEqualStrings("headers", db.settings.name);
    try std.testing.expectEqualStrings("/var/lib/guillotine/headers", db.settings.path);
    try std.testing.expect(db.settings.delete_on_start);
}

test "RocksDatabase: multiple instances are independent" {
    var db1 = RocksDatabase.init(.{ .name = "state", .path = "/tmp/state" });
    defer db1.deinit();

    var db2 = RocksDatabase.init(.{ .name = "code", .path = "/tmp/code" });
    defer db2.deinit();

    try std.testing.expectEqualStrings("state", db1.settings.name);
    try std.testing.expectEqualStrings("code", db2.settings.name);

    // Both return null (independent null objects)
    const iface1 = db1.database();
    const iface2 = db2.database();
    try std.testing.expectEqual(null, try iface1.get("key"));
    try std.testing.expectEqual(null, try iface2.get("key"));
}
