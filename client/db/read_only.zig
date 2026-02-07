/// Read-only database decorator implementing the `Database` interface.
///
/// Modeled after Nethermind's `ReadOnlyDb` (`Nethermind.Db/ReadOnlyDb.cs`),
/// simplified for the initial implementation: wraps any `Database` and
/// delegates all read operations (get, contains) to the underlying database,
/// while blocking all write operations (put, delete) with `error.StorageError`.
///
/// Nethermind's full `ReadOnlyDb` also supports an optional in-memory write
/// overlay (`MemDb`) with `ClearTempChanges()` for execution snapshots. That
/// can be added in a future pass when needed for state execution.
///
/// ## Usage
///
/// ```zig
/// var mem = MemoryDatabase.init(allocator);
/// defer mem.deinit();
///
/// // Populate some data
/// try mem.database().put("key", "value");
///
/// // Create a read-only view
/// var ro = ReadOnlyDb.init(mem.database());
/// const iface = ro.database();
///
/// const val = try iface.get("key");     // returns "value"
/// try iface.put("key", "new");          // error.StorageError
/// try iface.delete("key");              // error.StorageError
/// ```
const std = @import("std");
const adapter = @import("adapter.zig");
const Database = adapter.Database;
const Error = adapter.Error;

/// Read-only wrapper around any `Database` — reads pass through, writes error.
///
/// This is a decorator (Nethermind pattern): it holds a reference to a
/// wrapped `Database` and delegates reads. Writes return `error.StorageError`
/// to enforce immutability at the interface level.
///
/// The wrapper is zero-allocation: it only stores the wrapped `Database`
/// value (which is itself just a pointer + vtable pointer).
pub const ReadOnlyDb = struct {
    /// The underlying database to delegate reads to.
    wrapped: Database,

    /// Create a new read-only view over the given database.
    pub fn init(wrapped: Database) ReadOnlyDb {
        return .{ .wrapped = wrapped };
    }

    /// No-op — ReadOnlyDb holds no owned resources.
    pub fn deinit(self: *ReadOnlyDb) void {
        _ = self;
    }

    /// Return a `Database` vtable interface backed by this ReadOnlyDb.
    pub fn database(self: *ReadOnlyDb) Database {
        return .{
            .ptr = @ptrCast(self),
            .vtable = &vtable,
        };
    }

    // -- Direct (non-vtable) methods ------------------------------------------

    /// Retrieve the value for `key` from the wrapped database.
    pub fn get(self: *ReadOnlyDb, key: []const u8) Error!?[]const u8 {
        return self.wrapped.get(key);
    }

    /// Check whether `key` exists in the wrapped database.
    pub fn contains(self: *ReadOnlyDb, key: []const u8) Error!bool {
        return self.wrapped.contains(key);
    }

    // -- VTable implementation ------------------------------------------------

    const vtable = Database.VTable{
        .get = getImpl,
        .put = putImpl,
        .delete = deleteImpl,
        .contains = containsImpl,
    };

    fn getImpl(ptr: *anyopaque, key: []const u8) Error!?[]const u8 {
        const self: *ReadOnlyDb = @ptrCast(@alignCast(ptr));
        return self.get(key);
    }

    fn putImpl(_: *anyopaque, _: []const u8, _: ?[]const u8) Error!void {
        // Read-only: writes are not permitted.
        return error.StorageError;
    }

    fn deleteImpl(_: *anyopaque, _: []const u8) Error!void {
        // Read-only: deletes are not permitted.
        return error.StorageError;
    }

    fn containsImpl(ptr: *anyopaque, key: []const u8) Error!bool {
        const self: *ReadOnlyDb = @ptrCast(@alignCast(ptr));
        return self.contains(key);
    }
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

const MemoryDatabase = @import("memory.zig").MemoryDatabase;

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

test "ReadOnlyDb: put returns StorageError" {
    var mem = MemoryDatabase.init(std.testing.allocator);
    defer mem.deinit();

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    const iface = ro.database();
    try std.testing.expectError(error.StorageError, iface.put("key", "value"));
}

test "ReadOnlyDb: put with null returns StorageError" {
    var mem = MemoryDatabase.init(std.testing.allocator);
    defer mem.deinit();

    var ro = ReadOnlyDb.init(mem.database());
    defer ro.deinit();

    const iface = ro.database();
    try std.testing.expectError(error.StorageError, iface.put("key", null));
}

test "ReadOnlyDb: delete returns StorageError" {
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
