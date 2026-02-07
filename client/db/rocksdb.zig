/// RocksDB database backend stub implementing the `Database` interface.
///
/// This is a placeholder for the eventual RocksDB FFI backend. It is
/// intentionally NOT functional — all operations return errors or null.
/// This stub exists so that higher-level code can reference the type and
/// compile against it before the real RocksDB C API bindings are added.
///
/// For the Null Object pattern (no-data, no-error reads), use `NullDb`.
/// For actual in-memory storage, use `MemoryDatabase`.
///
/// ## Relationship to Nethermind
///
/// Nethermind separates `NullDb` (null object) from `DbOnTheRocks` (real
/// RocksDB backend). This stub corresponds to the *unimplemented*
/// `DbOnTheRocks` — it will be replaced with RocksDB C API FFI calls.
/// `NullDb` is in `null.zig`.
///
/// ## Future Work
///
/// - Replace stub vtable functions with RocksDB C API calls
/// - Add column family support (`IColumnsDb<T>` equivalent)
/// - Implement native `writeBatch` via RocksDB WriteBatch
/// - Add `ReadFlags` / `WriteFlags` hint enums for tuning
/// - Add `DbMetric` for monitoring (size, cache, reads, writes)
/// - Add configuration struct with RocksDB tuning parameters
const std = @import("std");
const adapter = @import("adapter.zig");
const Database = adapter.Database;
const DbName = adapter.DbName;
const Error = adapter.Error;

/// Stub RocksDB database implementing the `Database` vtable interface.
///
/// Identified by a `DbName` enum variant (e.g., `.state`, `.code`),
/// matching Nethermind's pattern where each database partition is opened
/// with a known name.
///
/// Currently all operations return errors — this is a compile-time
/// placeholder, not a null object. Use `NullDb` for the null object
/// pattern or `MemoryDatabase` for test storage.
pub const RocksDatabase = struct {
    /// Which logical database partition this instance represents.
    name: DbName,

    /// Create a new RocksDatabase stub for the given partition.
    ///
    /// In the real implementation, this would open a RocksDB instance
    /// at a derived path. Currently, no resources are allocated.
    pub fn init(name: DbName) RocksDatabase {
        return .{ .name = name };
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

    // -- VTable implementation (stub — all ops error) -------------------------

    const vtable = Database.VTable{
        .get = getImpl,
        .put = putImpl,
        .delete = deleteImpl,
        .contains = containsImpl,
    };

    fn getImpl(_: *anyopaque, _: []const u8) Error!?[]const u8 {
        // Stub: RocksDB backend not implemented yet.
        return error.StorageError;
    }

    fn putImpl(_: *anyopaque, _: []const u8, _: ?[]const u8) Error!void {
        // Stub: RocksDB backend not implemented yet.
        return error.StorageError;
    }

    fn deleteImpl(_: *anyopaque, _: []const u8) Error!void {
        // Stub: RocksDB backend not implemented yet.
        return error.StorageError;
    }

    fn containsImpl(_: *anyopaque, _: []const u8) Error!bool {
        // Stub: RocksDB backend not implemented yet.
        return error.StorageError;
    }
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

test "RocksDatabase: get returns StorageError (unimplemented stub)" {
    var db = RocksDatabase.init(.state);
    defer db.deinit();

    const iface = db.database();
    try std.testing.expectError(error.StorageError, iface.get("any_key"));
}

test "RocksDatabase: put returns StorageError (unimplemented stub)" {
    var db = RocksDatabase.init(.code);
    defer db.deinit();

    const iface = db.database();
    try std.testing.expectError(error.StorageError, iface.put("key", "value"));
}

test "RocksDatabase: put with null returns StorageError (unimplemented stub)" {
    var db = RocksDatabase.init(.headers);
    defer db.deinit();

    const iface = db.database();
    try std.testing.expectError(error.StorageError, iface.put("key", null));
}

test "RocksDatabase: delete returns StorageError (unimplemented stub)" {
    var db = RocksDatabase.init(.blocks);
    defer db.deinit();

    const iface = db.database();
    try std.testing.expectError(error.StorageError, iface.delete("key"));
}

test "RocksDatabase: contains returns StorageError (unimplemented stub)" {
    var db = RocksDatabase.init(.receipts);
    defer db.deinit();

    const iface = db.database();
    try std.testing.expectError(error.StorageError, iface.contains("key"));
}

test "RocksDatabase: name is accessible after init" {
    var db = RocksDatabase.init(.headers);
    defer db.deinit();

    try std.testing.expectEqual(DbName.headers, db.name);
    try std.testing.expectEqualStrings("headers", db.name.toString());
}

test "RocksDatabase: multiple instances with different names" {
    var db1 = RocksDatabase.init(.state);
    defer db1.deinit();

    var db2 = RocksDatabase.init(.code);
    defer db2.deinit();

    try std.testing.expectEqual(DbName.state, db1.name);
    try std.testing.expectEqual(DbName.code, db2.name);
}
