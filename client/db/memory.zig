/// In-memory database backend implementing the `Database` interface.
///
/// Modeled after Nethermind's `MemDb` (ConcurrentDictionary-backed), simplified
/// for single-threaded Zig. Uses a `std.HashMapUnmanaged` keyed by byte slices
/// with an arena allocator for all stored keys and values.
///
/// Tracks `reads_count` and `writes_count` for diagnostics, mirroring
/// Nethermind's `ReadsCount` / `WritesCount` properties.
///
/// ## Usage
///
/// ```zig
/// var db = MemoryDatabase.init(allocator);
/// defer db.deinit();
///
/// const iface = db.database();
/// try iface.put("key", "value");
/// const val = try iface.get("key"); // "value"
/// ```
const std = @import("std");
const adapter = @import("adapter.zig");
const Database = adapter.Database;
const Error = adapter.Error;

/// Byte-slice hash/equality context for HashMap, comparing slice contents.
/// Private to this module — only used as the HashMap context type.
const ByteSliceContext = struct {
    pub fn hash(_: ByteSliceContext, key: []const u8) u64 {
        return std.hash.Wyhash.hash(0, key);
    }

    pub fn eql(_: ByteSliceContext, a: []const u8, b: []const u8) bool {
        return std.mem.eql(u8, a, b);
    }
};

/// Unmanaged HashMap type — allocator is passed explicitly to each operation,
/// avoiding the dangling-pointer problem when the containing struct is moved.
const Map = std.HashMapUnmanaged([]const u8, []const u8, ByteSliceContext, 80);

/// In-memory key-value database implementing the `Database` vtable interface.
///
/// All keys and values are copied into `arena` on `put`. On `delete` or
/// overwrite, old allocations remain in the arena and are freed together
/// when `deinit()` is called. This is consistent with the project's
/// arena-based allocation strategy (transaction-scoped memory).
pub const MemoryDatabase = struct {
    /// Underlying storage map (unmanaged — allocator passed per-call).
    map: Map = .{},
    /// Arena allocator that owns all stored key/value memory AND the map's
    /// internal table.
    arena: std.heap.ArenaAllocator,
    /// Number of `get` / `contains` calls (read operations).
    reads_count: u64 = 0,
    /// Number of `put` / `delete` calls (write operations).
    writes_count: u64 = 0,

    /// Create a new empty MemoryDatabase backed by the given allocator.
    pub fn init(backing_allocator: std.mem.Allocator) MemoryDatabase {
        return .{
            .arena = std.heap.ArenaAllocator.init(backing_allocator),
        };
    }

    /// Release all memory owned by this database (keys, values, hash map).
    pub fn deinit(self: *MemoryDatabase) void {
        // No need to deinit the map separately — all its memory is in the arena.
        self.arena.deinit();
    }

    /// Return the number of entries currently stored.
    pub fn count(self: *const MemoryDatabase) usize {
        return self.map.count();
    }

    /// Remove all entries and free accumulated memory.
    ///
    /// After `clear()`, the database is empty and reusable. The arena is
    /// reset (freeing all stored keys/values and map buckets), and the map
    /// is re-initialized to an empty state.
    ///
    /// Mirrors Nethermind's `MemDb.Clear()` which wipes the underlying
    /// ConcurrentDictionary. Used by `ReadOnlyDb.clear_temp_changes()` to
    /// discard temporary write-overlay data.
    pub fn clear(self: *MemoryDatabase) void {
        // Reset arena — frees all key/value copies and map internal tables.
        _ = self.arena.reset(.retain_capacity);
        // Re-initialize map to empty (its internal buffer was in the arena).
        self.map = .{};
        // Reset diagnostic counters (Nethermind does not reset these, but
        // for a clear/reuse cycle it makes sense to start fresh).
        self.reads_count = 0;
        self.writes_count = 0;
    }

    /// Return a `Database` vtable interface backed by this MemoryDatabase.
    pub fn database(self: *MemoryDatabase) Database {
        return .{
            .ptr = @ptrCast(self),
            .vtable = &vtable,
        };
    }

    // -- Direct (non-vtable) methods ------------------------------------------

    /// Retrieve the value for `key`, or `null` if not found.
    pub fn get(self: *MemoryDatabase, key: []const u8) ?[]const u8 {
        self.reads_count += 1;
        return self.map.get(key);
    }

    /// Store a key-value pair. If `value` is `null`, behaves as `delete`.
    /// Copies both key and value into the arena.
    pub fn put(self: *MemoryDatabase, key: []const u8, value: ?[]const u8) Error!void {
        self.writes_count += 1;
        if (value) |val| {
            const alloc = self.arena.allocator();
            // Copy key and value into arena
            const owned_key = alloc.dupe(u8, key) catch return error.OutOfMemory;
            const owned_val = alloc.dupe(u8, val) catch return error.OutOfMemory;
            // Insert (overwrites any existing entry; old key/value stay in arena)
            self.map.put(alloc, owned_key, owned_val) catch return error.OutOfMemory;
        } else {
            // put(key, null) behaves as delete (Nethermind pattern)
            _ = self.map.remove(key);
        }
    }

    /// Remove the entry for `key`. No-op if the key does not exist.
    pub fn delete(self: *MemoryDatabase, key: []const u8) void {
        self.writes_count += 1;
        _ = self.map.remove(key);
    }

    /// Check whether `key` exists in the database.
    pub fn contains(self: *MemoryDatabase, key: []const u8) bool {
        self.reads_count += 1;
        return self.map.contains(key);
    }

    // -- VTable implementation ------------------------------------------------

    const vtable = Database.VTable{
        .get = getImpl,
        .put = putImpl,
        .delete = deleteImpl,
        .contains = containsImpl,
    };

    fn getImpl(ptr: *anyopaque, key: []const u8) Error!?[]const u8 {
        const self: *MemoryDatabase = @ptrCast(@alignCast(ptr));
        return self.get(key);
    }

    fn putImpl(ptr: *anyopaque, key: []const u8, value: ?[]const u8) Error!void {
        const self: *MemoryDatabase = @ptrCast(@alignCast(ptr));
        return self.put(key, value);
    }

    fn deleteImpl(ptr: *anyopaque, key: []const u8) Error!void {
        const self: *MemoryDatabase = @ptrCast(@alignCast(ptr));
        self.delete(key);
    }

    fn containsImpl(ptr: *anyopaque, key: []const u8) Error!bool {
        const self: *MemoryDatabase = @ptrCast(@alignCast(ptr));
        return self.contains(key);
    }
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

test "MemoryDatabase: put then get round-trip" {
    var db = MemoryDatabase.init(std.testing.allocator);
    defer db.deinit();

    try db.put("hello", "world");
    const val = db.get("hello");
    try std.testing.expect(val != null);
    try std.testing.expectEqualStrings("world", val.?);
}

test "MemoryDatabase: get missing key returns null" {
    var db = MemoryDatabase.init(std.testing.allocator);
    defer db.deinit();

    const val = db.get("nonexistent");
    try std.testing.expectEqual(null, val);
}

test "MemoryDatabase: delete existing key" {
    var db = MemoryDatabase.init(std.testing.allocator);
    defer db.deinit();

    try db.put("key", "value");
    try std.testing.expect(db.contains("key"));

    db.delete("key");
    try std.testing.expectEqual(null, db.get("key"));
    try std.testing.expect(!db.contains("key"));
}

test "MemoryDatabase: delete non-existing key is no-op" {
    var db = MemoryDatabase.init(std.testing.allocator);
    defer db.deinit();

    // Should not panic or error
    db.delete("missing");
    try std.testing.expectEqual(@as(usize, 0), db.count());
}

test "MemoryDatabase: contains returns true/false correctly" {
    var db = MemoryDatabase.init(std.testing.allocator);
    defer db.deinit();

    try std.testing.expect(!db.contains("key"));
    try db.put("key", "val");
    try std.testing.expect(db.contains("key"));
}

test "MemoryDatabase: put with null value behaves as delete" {
    var db = MemoryDatabase.init(std.testing.allocator);
    defer db.deinit();

    try db.put("key", "value");
    try std.testing.expect(db.contains("key"));

    try db.put("key", null);
    try std.testing.expect(!db.contains("key"));
    try std.testing.expectEqual(null, db.get("key"));
}

test "MemoryDatabase: overwrite existing key" {
    var db = MemoryDatabase.init(std.testing.allocator);
    defer db.deinit();

    try db.put("key", "first");
    try std.testing.expectEqualStrings("first", db.get("key").?);

    try db.put("key", "second");
    try std.testing.expectEqualStrings("second", db.get("key").?);
}

test "MemoryDatabase: reads_count and writes_count tracking" {
    var db = MemoryDatabase.init(std.testing.allocator);
    defer db.deinit();

    try std.testing.expectEqual(@as(u64, 0), db.reads_count);
    try std.testing.expectEqual(@as(u64, 0), db.writes_count);

    // Writes: put increments writes_count
    try db.put("a", "1");
    try db.put("b", "2");
    try std.testing.expectEqual(@as(u64, 2), db.writes_count);

    // Reads: get increments reads_count
    _ = db.get("a");
    _ = db.get("b");
    _ = db.get("missing");
    try std.testing.expectEqual(@as(u64, 3), db.reads_count);

    // Reads: contains increments reads_count
    _ = db.contains("a");
    try std.testing.expectEqual(@as(u64, 4), db.reads_count);

    // Writes: delete increments writes_count
    db.delete("a");
    try std.testing.expectEqual(@as(u64, 3), db.writes_count);

    // Writes: put(key, null) increments writes_count
    try db.put("b", null);
    try std.testing.expectEqual(@as(u64, 4), db.writes_count);
}

test "MemoryDatabase: count returns correct number of entries" {
    var db = MemoryDatabase.init(std.testing.allocator);
    defer db.deinit();

    try std.testing.expectEqual(@as(usize, 0), db.count());

    try db.put("a", "1");
    try std.testing.expectEqual(@as(usize, 1), db.count());

    try db.put("b", "2");
    try std.testing.expectEqual(@as(usize, 2), db.count());

    db.delete("a");
    try std.testing.expectEqual(@as(usize, 1), db.count());
}

test "MemoryDatabase: vtable interface dispatches correctly" {
    var db = MemoryDatabase.init(std.testing.allocator);
    defer db.deinit();

    const iface = db.database();

    // put via vtable
    try iface.put("key", "value");
    // get via vtable
    const val = try iface.get("key");
    try std.testing.expect(val != null);
    try std.testing.expectEqualStrings("value", val.?);

    // contains via vtable
    const exists = try iface.contains("key");
    try std.testing.expect(exists);

    // delete via vtable
    try iface.delete("key");
    const after = try iface.get("key");
    try std.testing.expectEqual(null, after);
}

test "MemoryDatabase: vtable put null deletes via interface" {
    var db = MemoryDatabase.init(std.testing.allocator);
    defer db.deinit();

    const iface = db.database();

    try iface.put("key", "value");
    try std.testing.expect((try iface.get("key")) != null);

    try iface.put("key", null);
    try std.testing.expectEqual(null, try iface.get("key"));
}

test "MemoryDatabase: empty key and value" {
    var db = MemoryDatabase.init(std.testing.allocator);
    defer db.deinit();

    // Empty key
    try db.put("", "value");
    try std.testing.expectEqualStrings("value", db.get("").?);

    // Empty value
    try db.put("key", "");
    try std.testing.expectEqualStrings("", db.get("key").?);

    // Empty key + empty value
    try db.put("", "");
    try std.testing.expectEqualStrings("", db.get("").?);
}

test "MemoryDatabase: binary keys and values" {
    var db = MemoryDatabase.init(std.testing.allocator);
    defer db.deinit();

    const key = &[_]u8{ 0x00, 0xFF, 0xDE, 0xAD, 0xBE, 0xEF };
    const val = &[_]u8{ 0xCA, 0xFE, 0xBA, 0xBE };

    try db.put(key, val);
    const result = db.get(key);
    try std.testing.expect(result != null);
    try std.testing.expectEqualSlices(u8, val, result.?);
}

test "MemoryDatabase: deinit frees all memory (leak check)" {
    // std.testing.allocator detects leaks on deinit
    var db = MemoryDatabase.init(std.testing.allocator);

    try db.put("key1", "value1");
    try db.put("key2", "value2");
    try db.put("key3", "value3");
    db.delete("key2");
    try db.put("key1", "overwritten");

    // If deinit doesn't free properly, testing allocator will report a leak
    db.deinit();
}

test "MemoryDatabase: many entries" {
    var db = MemoryDatabase.init(std.testing.allocator);
    defer db.deinit();

    // Insert 100 entries
    var i: usize = 0;
    while (i < 100) : (i += 1) {
        var key_buf: [8]u8 = undefined;
        const key = std.fmt.bufPrint(&key_buf, "{d}", .{i}) catch unreachable;
        try db.put(key, key); // value = key for simplicity
    }

    try std.testing.expectEqual(@as(usize, 100), db.count());

    // Verify a few entries
    try std.testing.expectEqualStrings("0", db.get("0").?);
    try std.testing.expectEqualStrings("50", db.get("50").?);
    try std.testing.expectEqualStrings("99", db.get("99").?);
}

test "MemoryDatabase: clear removes all entries and resets counters" {
    var db = MemoryDatabase.init(std.testing.allocator);
    defer db.deinit();

    try db.put("a", "1");
    try db.put("b", "2");
    try db.put("c", "3");
    _ = db.get("a");
    _ = db.get("b");

    try std.testing.expectEqual(@as(usize, 3), db.count());
    try std.testing.expectEqual(@as(u64, 2), db.reads_count);
    try std.testing.expectEqual(@as(u64, 3), db.writes_count);

    db.clear();

    try std.testing.expectEqual(@as(usize, 0), db.count());
    try std.testing.expectEqual(@as(u64, 0), db.reads_count);
    try std.testing.expectEqual(@as(u64, 0), db.writes_count);
    try std.testing.expectEqual(null, db.get("a"));
    try std.testing.expectEqual(null, db.get("b"));
    try std.testing.expectEqual(null, db.get("c"));
}

test "MemoryDatabase: clear then reuse" {
    var db = MemoryDatabase.init(std.testing.allocator);
    defer db.deinit();

    try db.put("old_key", "old_value");
    try std.testing.expectEqual(@as(usize, 1), db.count());

    db.clear();
    try std.testing.expectEqual(@as(usize, 0), db.count());

    // Database should be fully reusable after clear
    try db.put("new_key", "new_value");
    try std.testing.expectEqual(@as(usize, 1), db.count());
    try std.testing.expectEqualStrings("new_value", db.get("new_key").?);
    try std.testing.expectEqual(null, db.get("old_key"));
}
