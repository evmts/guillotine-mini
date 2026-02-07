/// Database adapter interface for persistent key-value storage.
///
/// Follows the vtable pattern from `src/host.zig` (ptr + vtable comptime DI).
/// Modeled after Nethermind's IKeyValueStore / IDb interface hierarchy,
/// simplified for Zig: a single `Database` struct that combines read + write
/// operations behind a type-erased vtable.
///
/// All operations use byte slices (`[]const u8`) as keys and optional byte
/// slices as values. A `get` returning `null` means "key not found".
/// A `put` with a `null` value is equivalent to `delete` (Nethermind pattern).
///
/// Error handling: all operations return error unions — never use `catch {}`.
const std = @import("std");

/// Errors that database operations can produce.
pub const Error = error{
    /// The underlying storage backend encountered an I/O or corruption error.
    StorageError,
    /// The key was too large for the backend to handle.
    KeyTooLarge,
    /// The value was too large for the backend to handle.
    ValueTooLarge,
    /// The database has been closed or is in an invalid state.
    DatabaseClosed,
};

/// Standard database column/partition names, mirroring Nethermind's `DbNames`.
///
/// Each name identifies a logical partition of the database. Backends may
/// implement these as separate column families (RocksDB) or separate
/// HashMap instances (MemoryDatabase).
pub const DbName = enum {
    /// World state (account trie nodes)
    state,
    /// Contract storage (storage trie nodes)
    storage,
    /// Contract bytecode
    code,
    /// Block bodies (transactions + ommers)
    blocks,
    /// Block headers
    headers,
    /// Block number → block hash mapping
    block_numbers,
    /// Transaction receipts
    receipts,
    /// Block metadata (total difficulty, etc.)
    block_infos,
    /// Invalid / rejected blocks
    bad_blocks,
    /// Bloom filter index
    bloom,
    /// Client metadata (sync state, etc.)
    metadata,
    /// EIP-4844 blob transactions
    blob_transactions,

    /// Returns the string representation matching Nethermind's DbNames constants.
    pub fn toString(self: DbName) []const u8 {
        return switch (self) {
            .state => "state",
            .storage => "storage",
            .code => "code",
            .blocks => "blocks",
            .headers => "headers",
            .block_numbers => "blockNumbers",
            .block_infos => "blockInfos",
            .receipts => "receipts",
            .bad_blocks => "badBlocks",
            .bloom => "bloom",
            .metadata => "metadata",
            .blob_transactions => "blobTransactions",
        };
    }
};

/// Generic key-value database interface using type-erased vtable dispatch.
///
/// This is the fundamental storage abstraction for the Guillotine execution
/// client. All persistent storage (trie nodes, block data, receipts, etc.)
/// goes through this interface.
///
/// ## Usage
///
/// ```zig
/// // Create a concrete backend (e.g. MemoryDatabase)
/// var mem_db = try MemoryDatabase.init(allocator);
/// defer mem_db.deinit();
///
/// // Get the type-erased Database interface
/// const db = mem_db.database();
///
/// // Use the interface
/// try db.put("key", "value");
/// const val = try db.get("key"); // returns ?[]const u8
/// ```
pub const Database = struct {
    /// Type-erased pointer to the concrete backend implementation.
    ptr: *anyopaque,
    /// Pointer to the static vtable for the concrete backend.
    vtable: *const VTable,

    /// Virtual function table for database operations.
    ///
    /// Mirrors Nethermind's IReadOnlyKeyValueStore + IWriteOnlyKeyValueStore,
    /// combined into a single vtable for simplicity.
    pub const VTable = struct {
        /// Retrieve the value associated with `key`.
        /// Returns `null` if the key does not exist.
        /// The returned slice is owned by the database and valid until
        /// the next mutation or database destruction.
        get: *const fn (ptr: *anyopaque, key: []const u8) Error!?[]const u8,

        /// Store a key-value pair. If `value` is `null`, this is equivalent
        /// to calling `delete`. Overwrites any existing value for the key.
        put: *const fn (ptr: *anyopaque, key: []const u8, value: ?[]const u8) Error!void,

        /// Remove the entry for `key`. No-op if the key does not exist.
        delete: *const fn (ptr: *anyopaque, key: []const u8) Error!void,

        /// Check whether `key` exists in the database.
        contains: *const fn (ptr: *anyopaque, key: []const u8) Error!bool,
    };

    /// Retrieve the value associated with `key`.
    /// Returns `null` if the key does not exist.
    pub fn get(self: Database, key: []const u8) Error!?[]const u8 {
        return self.vtable.get(self.ptr, key);
    }

    /// Store a key-value pair. If `value` is `null`, this is equivalent
    /// to calling `delete`.
    pub fn put(self: Database, key: []const u8, value: ?[]const u8) Error!void {
        return self.vtable.put(self.ptr, key, value);
    }

    /// Remove the entry for `key`. No-op if the key does not exist.
    pub fn delete(self: Database, key: []const u8) Error!void {
        return self.vtable.delete(self.ptr, key);
    }

    /// Check whether `key` exists in the database.
    pub fn contains(self: Database, key: []const u8) Error!bool {
        return self.vtable.contains(self.ptr, key);
    }
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

/// Minimal mock database for testing the vtable dispatch mechanism.
/// This is NOT the full MemoryDatabase (that goes in memory.zig).
const MockDb = struct {
    call_count: usize = 0,

    fn getImpl(ptr: *anyopaque, _: []const u8) Error!?[]const u8 {
        const self: *MockDb = @ptrCast(@alignCast(ptr));
        self.call_count += 1;
        return null;
    }

    fn putImpl(ptr: *anyopaque, _: []const u8, _: ?[]const u8) Error!void {
        const self: *MockDb = @ptrCast(@alignCast(ptr));
        self.call_count += 1;
    }

    fn deleteImpl(ptr: *anyopaque, _: []const u8) Error!void {
        const self: *MockDb = @ptrCast(@alignCast(ptr));
        self.call_count += 1;
    }

    fn containsImpl(ptr: *anyopaque, _: []const u8) Error!bool {
        const self: *MockDb = @ptrCast(@alignCast(ptr));
        self.call_count += 1;
        return false;
    }

    const vtable = Database.VTable{
        .get = getImpl,
        .put = putImpl,
        .delete = deleteImpl,
        .contains = containsImpl,
    };

    fn database(self: *MockDb) Database {
        return .{
            .ptr = @ptrCast(self),
            .vtable = &vtable,
        };
    }
};

test "Database vtable dispatches get" {
    var mock = MockDb{};
    const db = mock.database();

    const result = try db.get("test_key");
    try std.testing.expectEqual(null, result);
    try std.testing.expectEqual(@as(usize, 1), mock.call_count);
}

test "Database vtable dispatches put" {
    var mock = MockDb{};
    const db = mock.database();

    try db.put("key", "value");
    try std.testing.expectEqual(@as(usize, 1), mock.call_count);
}

test "Database vtable dispatches put with null (delete semantics)" {
    var mock = MockDb{};
    const db = mock.database();

    try db.put("key", null);
    try std.testing.expectEqual(@as(usize, 1), mock.call_count);
}

test "Database vtable dispatches delete" {
    var mock = MockDb{};
    const db = mock.database();

    try db.delete("key");
    try std.testing.expectEqual(@as(usize, 1), mock.call_count);
}

test "Database vtable dispatches contains" {
    var mock = MockDb{};
    const db = mock.database();

    const result = try db.contains("key");
    try std.testing.expectEqual(false, result);
    try std.testing.expectEqual(@as(usize, 1), mock.call_count);
}

test "Database vtable dispatches multiple operations" {
    var mock = MockDb{};
    const db = mock.database();

    _ = try db.get("a");
    try db.put("b", "val");
    try db.delete("c");
    _ = try db.contains("d");

    try std.testing.expectEqual(@as(usize, 4), mock.call_count);
}

test "DbName toString matches Nethermind constants" {
    try std.testing.expectEqualStrings("state", DbName.state.toString());
    try std.testing.expectEqualStrings("storage", DbName.storage.toString());
    try std.testing.expectEqualStrings("code", DbName.code.toString());
    try std.testing.expectEqualStrings("blocks", DbName.blocks.toString());
    try std.testing.expectEqualStrings("headers", DbName.headers.toString());
    try std.testing.expectEqualStrings("blockNumbers", DbName.block_numbers.toString());
    try std.testing.expectEqualStrings("receipts", DbName.receipts.toString());
    try std.testing.expectEqualStrings("blockInfos", DbName.block_infos.toString());
    try std.testing.expectEqualStrings("badBlocks", DbName.bad_blocks.toString());
    try std.testing.expectEqualStrings("bloom", DbName.bloom.toString());
    try std.testing.expectEqualStrings("metadata", DbName.metadata.toString());
    try std.testing.expectEqualStrings("blobTransactions", DbName.blob_transactions.toString());
}

test "DbName enum has all expected variants" {
    // Verify we can iterate all variants (compile-time check)
    const fields = std.meta.fields(DbName);
    try std.testing.expectEqual(@as(usize, 12), fields.len);
}
