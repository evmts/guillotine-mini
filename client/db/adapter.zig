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
///
/// ## Relationship to Voltaire
///
/// This module provides a *low-level persistence abstraction* (raw key-value
/// storage for trie nodes, block data, receipts, etc.) that sits below
/// Voltaire's state management layer. Voltaire's `StateManager`,
/// `JournaledState`, and cache types (AccountCache, StorageCache,
/// ContractCache) operate on typed, in-memory state and delegate to this
/// persistence layer for durable storage. The two are complementary:
///
///   Voltaire StateManager → (typed state ops) → DB adapter → (raw KV) → backend
///
/// The `Database` / `WriteBatch` / `DbName` types defined here are
/// intentionally backend-agnostic — Voltaire does not provide a raw KV
/// persistence interface, so this abstraction fills that gap.
const std = @import("std");

/// Errors that database operations can produce.
///
/// `OutOfMemory` is kept separate (via Zig's error union mechanism) so that
/// callers can distinguish allocation failures from backend I/O errors.
pub const Error = error{
    /// The underlying storage backend encountered an I/O or corruption error.
    StorageError,
    /// The key was too large for the backend to handle.
    KeyTooLarge,
    /// The value was too large for the backend to handle.
    ValueTooLarge,
    /// The database has been closed or is in an invalid state.
    DatabaseClosed,
    /// Allocation failure — propagated directly, never masked as StorageError.
    OutOfMemory,
};

/// Standard database column/partition names, mirroring Nethermind's `DbNames`.
///
/// Each name identifies a logical partition of the database. Backends may
/// implement these as separate column families (RocksDB) or separate
/// HashMap instances (MemoryDatabase).
///
/// Matches Nethermind's `DbNames` constants from
/// `Nethermind.Db/DbNames.cs` — all 15 database names are included.
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
    /// Discovery Protocol v4 node cache (devp2p)
    discovery_nodes,
    /// Discovery Protocol v5 node cache (devp2p, UDP-based)
    discovery_v5_nodes,
    /// RLPx peer database (P2P networking)
    peers,

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
            .discovery_nodes => "discoveryNodes",
            .discovery_v5_nodes => "discoveryV5Nodes",
            .peers => "peers",
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

        /// Apply a batch of write operations atomically.
        ///
        /// Backends that support native batch writes (e.g. RocksDB WriteBatch)
        /// should implement this to provide true all-or-nothing semantics.
        /// If `null`, WriteBatch.commit will fall back to sequential application
        /// with best-effort error reporting (partial writes possible on error).
        ///
        /// On success, all operations in `ops` are applied. On error, the
        /// backend must guarantee that NO operations were applied (rollback).
        writeBatch: ?*const fn (ptr: *anyopaque, ops: []const WriteBatchOp) Error!void = null,
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

/// A single write operation for use with `Database.VTable.writeBatch`.
pub const WriteBatchOp = union(enum) {
    /// Store a key-value pair.
    put: struct { key: []const u8, value: []const u8 },
    /// Remove a key.
    del: struct { key: []const u8 },
};

/// Batch context for accumulating multiple write operations and applying
/// them atomically to a `Database`.
///
/// Modeled after Nethermind's `IWriteBatch` / `RocksDbWriteBatch`:
///   - `put()` / `delete()` accumulate operations without touching the DB.
///   - `commit()` applies all pending operations to the target database.
///   - `clear()` discards all pending operations and frees arena memory.
///   - `deinit()` releases all memory (must be called even after commit).
///
/// ## Atomicity
///
/// If the target database implements `VTable.writeBatch`, commit uses it
/// for true all-or-nothing semantics. Otherwise, operations are applied
/// sequentially; on error, already-applied operations are NOT rolled back
/// and the batch is NOT cleared (caller can inspect/retry).
///
/// ## Usage
///
/// ```zig
/// var batch = WriteBatch.init(allocator, db);
/// defer batch.deinit();
///
/// try batch.put("key1", "value1");
/// try batch.put("key2", "value2");
/// try batch.delete("key3");
/// try batch.commit(); // atomic apply (if backend supports it)
/// ```
pub const WriteBatch = struct {
    /// Pending operations, in order of insertion.
    ops: std.ArrayListUnmanaged(WriteBatchOp) = .{},
    /// Arena for owned copies of keys/values within this batch.
    arena: std.heap.ArenaAllocator,
    /// The target database to apply operations to on `commit()`.
    target: Database,

    /// Create a new empty WriteBatch targeting the given database.
    pub fn init(backing_allocator: std.mem.Allocator, target: Database) WriteBatch {
        return .{
            .arena = std.heap.ArenaAllocator.init(backing_allocator),
            .target = target,
        };
    }

    /// Release all memory owned by this batch (pending ops, copied keys/values).
    pub fn deinit(self: *WriteBatch) void {
        // ops list memory is in the arena, so no separate deinit needed.
        self.arena.deinit();
    }

    /// Queue a put operation. Both key and value are copied into the batch arena.
    pub fn put(self: *WriteBatch, key: []const u8, value: []const u8) Error!void {
        const alloc = self.arena.allocator();
        const owned_key = alloc.dupe(u8, key) catch return error.OutOfMemory;
        const owned_val = alloc.dupe(u8, value) catch return error.OutOfMemory;
        self.ops.append(alloc, .{ .put = .{ .key = owned_key, .value = owned_val } }) catch return error.OutOfMemory;
    }

    /// Queue a delete operation. The key is copied into the batch arena.
    pub fn delete(self: *WriteBatch, key: []const u8) Error!void {
        const alloc = self.arena.allocator();
        const owned_key = alloc.dupe(u8, key) catch return error.OutOfMemory;
        self.ops.append(alloc, .{ .del = .{ .key = owned_key } }) catch return error.OutOfMemory;
    }

    /// Apply all pending operations to the target database.
    ///
    /// If the backend provides `writeBatch`, all operations are applied
    /// atomically (all-or-nothing). Otherwise, operations are applied
    /// sequentially; on error, already-applied operations remain and the
    /// batch retains its pending ops for inspection or retry.
    ///
    /// On success, pending ops are cleared. `deinit()` must still be
    /// called to free arena memory.
    pub fn commit(self: *WriteBatch) Error!void {
        if (self.ops.items.len == 0) return;

        if (self.target.vtable.writeBatch) |batch_fn| {
            // Atomic path: backend handles all-or-nothing semantics.
            try batch_fn(self.target.ptr, self.ops.items);
        } else {
            // Sequential fallback: apply one-by-one.
            // On error, ops are NOT cleared so caller can inspect/retry.
            for (self.ops.items) |op| {
                switch (op) {
                    .put => |p| try self.target.put(p.key, p.value),
                    .del => |d| try self.target.delete(d.key),
                }
            }
        }
        // Only clear on success.
        self.ops.items.len = 0;
    }

    /// Discard all pending operations without applying them.
    /// Resets the arena to free accumulated key/value memory, preventing
    /// unbounded memory retention for long-lived batches.
    pub fn clear(self: *WriteBatch) void {
        self.ops.items.len = 0;
        // Reset arena to free all accumulated key/value copies.
        // This prevents unbounded memory growth for long-lived batches
        // that repeatedly accumulate and clear operations.
        _ = self.arena.reset(.retain_capacity);
        // After reset, the ops ArrayList's buffer is invalidated,
        // so reset it to empty state.
        self.ops = .{};
    }

    /// Return the number of pending operations.
    pub fn pending(self: *const WriteBatch) usize {
        return self.ops.items.len;
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
    try std.testing.expectEqualStrings("discoveryNodes", DbName.discovery_nodes.toString());
    try std.testing.expectEqualStrings("discoveryV5Nodes", DbName.discovery_v5_nodes.toString());
    try std.testing.expectEqualStrings("peers", DbName.peers.toString());
}

test "DbName enum has all expected variants" {
    // Verify we can iterate all variants (compile-time check).
    // 15 = 12 original + 3 networking (discovery_nodes, discovery_v5_nodes, peers)
    const fields = std.meta.fields(DbName);
    try std.testing.expectEqual(@as(usize, 15), fields.len);
}

// -- WriteBatch tests -------------------------------------------------------

/// A tracking mock database for WriteBatch tests.
/// Records every put/delete so we can verify commit behavior.
const TrackingDb = struct {
    puts: std.ArrayListUnmanaged(struct { key: []const u8, value: ?[]const u8 }) = .{},
    deletes: std.ArrayListUnmanaged([]const u8) = .{},
    alloc: std.mem.Allocator,

    fn init(allocator: std.mem.Allocator) TrackingDb {
        return .{ .alloc = allocator };
    }

    fn deinit(self: *TrackingDb) void {
        self.puts.deinit(self.alloc);
        self.deletes.deinit(self.alloc);
    }

    fn getImpl(_: *anyopaque, _: []const u8) Error!?[]const u8 {
        return null;
    }

    fn putImpl(ptr: *anyopaque, key: []const u8, value: ?[]const u8) Error!void {
        const self: *TrackingDb = @ptrCast(@alignCast(ptr));
        self.puts.append(self.alloc, .{ .key = key, .value = value }) catch return error.OutOfMemory;
    }

    fn deleteImpl(ptr: *anyopaque, key: []const u8) Error!void {
        const self: *TrackingDb = @ptrCast(@alignCast(ptr));
        self.deletes.append(self.alloc, key) catch return error.OutOfMemory;
    }

    fn containsImpl(_: *anyopaque, _: []const u8) Error!bool {
        return false;
    }

    const vtable = Database.VTable{
        .get = getImpl,
        .put = putImpl,
        .delete = deleteImpl,
        .contains = containsImpl,
    };

    fn database(self: *TrackingDb) Database {
        return .{
            .ptr = @ptrCast(self),
            .vtable = &vtable,
        };
    }
};

test "WriteBatch: commit applies put operations" {
    var tracker = TrackingDb.init(std.testing.allocator);
    defer tracker.deinit();

    var batch = WriteBatch.init(std.testing.allocator, tracker.database());
    defer batch.deinit();

    try batch.put("key1", "val1");
    try batch.put("key2", "val2");
    try std.testing.expectEqual(@as(usize, 2), batch.pending());

    try batch.commit();
    try std.testing.expectEqual(@as(usize, 0), batch.pending());
    try std.testing.expectEqual(@as(usize, 2), tracker.puts.items.len);
    try std.testing.expectEqualStrings("key1", tracker.puts.items[0].key);
    try std.testing.expectEqualStrings("val1", tracker.puts.items[0].value.?);
    try std.testing.expectEqualStrings("key2", tracker.puts.items[1].key);
    try std.testing.expectEqualStrings("val2", tracker.puts.items[1].value.?);
}

test "WriteBatch: commit applies delete operations" {
    var tracker = TrackingDb.init(std.testing.allocator);
    defer tracker.deinit();

    var batch = WriteBatch.init(std.testing.allocator, tracker.database());
    defer batch.deinit();

    try batch.delete("gone");
    try std.testing.expectEqual(@as(usize, 1), batch.pending());

    try batch.commit();
    try std.testing.expectEqual(@as(usize, 1), tracker.deletes.items.len);
    try std.testing.expectEqualStrings("gone", tracker.deletes.items[0]);
}

test "WriteBatch: commit applies mixed operations in order" {
    var tracker = TrackingDb.init(std.testing.allocator);
    defer tracker.deinit();

    var batch = WriteBatch.init(std.testing.allocator, tracker.database());
    defer batch.deinit();

    try batch.put("a", "1");
    try batch.delete("b");
    try batch.put("c", "3");
    try std.testing.expectEqual(@as(usize, 3), batch.pending());

    try batch.commit();
    // 2 puts, 1 delete
    try std.testing.expectEqual(@as(usize, 2), tracker.puts.items.len);
    try std.testing.expectEqual(@as(usize, 1), tracker.deletes.items.len);
}

test "WriteBatch: clear discards pending operations" {
    var tracker = TrackingDb.init(std.testing.allocator);
    defer tracker.deinit();

    var batch = WriteBatch.init(std.testing.allocator, tracker.database());
    defer batch.deinit();

    try batch.put("key", "value");
    try batch.delete("other");
    try std.testing.expectEqual(@as(usize, 2), batch.pending());

    batch.clear();
    try std.testing.expectEqual(@as(usize, 0), batch.pending());

    // Commit after clear should apply nothing
    try batch.commit();
    try std.testing.expectEqual(@as(usize, 0), tracker.puts.items.len);
    try std.testing.expectEqual(@as(usize, 0), tracker.deletes.items.len);
}

test "WriteBatch: empty batch commit is no-op" {
    var tracker = TrackingDb.init(std.testing.allocator);
    defer tracker.deinit();

    var batch = WriteBatch.init(std.testing.allocator, tracker.database());
    defer batch.deinit();

    try std.testing.expectEqual(@as(usize, 0), batch.pending());
    try batch.commit();
    try std.testing.expectEqual(@as(usize, 0), tracker.puts.items.len);
    try std.testing.expectEqual(@as(usize, 0), tracker.deletes.items.len);
}

test "WriteBatch: deinit frees all memory (leak check)" {
    var tracker = TrackingDb.init(std.testing.allocator);
    defer tracker.deinit();

    var batch = WriteBatch.init(std.testing.allocator, tracker.database());

    try batch.put("key1", "longvalue1");
    try batch.put("key2", "longvalue2");
    try batch.delete("key3");

    // If deinit doesn't free properly, testing allocator will report a leak
    batch.deinit();
}

// -- Atomicity and error behavior tests ------------------------------------

/// A mock database that fails after N successful writes (for atomicity testing).
const FailingDb = struct {
    /// Number of writes to succeed before failing.
    succeed_count: usize,
    /// Tracks how many writes have been applied.
    applied: usize = 0,

    fn getImpl(_: *anyopaque, _: []const u8) Error!?[]const u8 {
        return null;
    }

    fn putImpl(ptr: *anyopaque, _: []const u8, _: ?[]const u8) Error!void {
        const self: *FailingDb = @ptrCast(@alignCast(ptr));
        if (self.applied >= self.succeed_count) {
            return Error.StorageError;
        }
        self.applied += 1;
    }

    fn deleteImpl(ptr: *anyopaque, _: []const u8) Error!void {
        const self: *FailingDb = @ptrCast(@alignCast(ptr));
        if (self.applied >= self.succeed_count) {
            return Error.StorageError;
        }
        self.applied += 1;
    }

    fn containsImpl(_: *anyopaque, _: []const u8) Error!bool {
        return false;
    }

    const vtable = Database.VTable{
        .get = getImpl,
        .put = putImpl,
        .delete = deleteImpl,
        .contains = containsImpl,
    };

    fn database(self: *FailingDb) Database {
        return .{
            .ptr = @ptrCast(self),
            .vtable = &vtable,
        };
    }
};

test "WriteBatch: sequential fallback retains ops on error for retry" {
    // FailingDb will succeed for 1 write, then fail on the 2nd.
    var failing = FailingDb{ .succeed_count = 1 };

    var batch = WriteBatch.init(std.testing.allocator, failing.database());
    defer batch.deinit();

    try batch.put("key1", "val1");
    try batch.put("key2", "val2");
    try batch.put("key3", "val3");

    // Commit should fail (2nd op fails after 1st succeeds)
    try std.testing.expectError(Error.StorageError, batch.commit());

    // Ops should be RETAINED on failure (not cleared)
    try std.testing.expectEqual(@as(usize, 3), batch.pending());
    // The failing db applied 1 write before failing
    try std.testing.expectEqual(@as(usize, 1), failing.applied);
}

/// A mock database that supports atomic writeBatch (all-or-nothing).
const AtomicDb = struct {
    /// Tracks how many ops were committed atomically.
    committed_count: usize = 0,
    /// When true, writeBatch will fail (to test rollback).
    should_fail: bool = false,

    fn getImpl(_: *anyopaque, _: []const u8) Error!?[]const u8 {
        return null;
    }

    fn putImpl(ptr: *anyopaque, _: []const u8, _: ?[]const u8) Error!void {
        const self: *AtomicDb = @ptrCast(@alignCast(ptr));
        self.committed_count += 1;
    }

    fn deleteImpl(ptr: *anyopaque, _: []const u8) Error!void {
        const self: *AtomicDb = @ptrCast(@alignCast(ptr));
        self.committed_count += 1;
    }

    fn containsImpl(_: *anyopaque, _: []const u8) Error!bool {
        return false;
    }

    fn writeBatchImpl(ptr: *anyopaque, ops: []const WriteBatchOp) Error!void {
        const self: *AtomicDb = @ptrCast(@alignCast(ptr));
        if (self.should_fail) {
            return Error.StorageError;
        }
        // Atomic: apply all or none.
        self.committed_count += ops.len;
    }

    const vtable = Database.VTable{
        .get = getImpl,
        .put = putImpl,
        .delete = deleteImpl,
        .contains = containsImpl,
        .writeBatch = writeBatchImpl,
    };

    fn database(self: *AtomicDb) Database {
        return .{
            .ptr = @ptrCast(self),
            .vtable = &vtable,
        };
    }
};

test "WriteBatch: uses writeBatch vtable for atomic commit" {
    var atomic = AtomicDb{};

    var batch = WriteBatch.init(std.testing.allocator, atomic.database());
    defer batch.deinit();

    try batch.put("key1", "val1");
    try batch.put("key2", "val2");
    try batch.delete("key3");

    try batch.commit();

    // All 3 ops committed atomically via writeBatch
    try std.testing.expectEqual(@as(usize, 3), atomic.committed_count);
    try std.testing.expectEqual(@as(usize, 0), batch.pending());
}

test "WriteBatch: atomic commit retains ops on failure (no partial apply)" {
    var atomic = AtomicDb{ .should_fail = true };

    var batch = WriteBatch.init(std.testing.allocator, atomic.database());
    defer batch.deinit();

    try batch.put("key1", "val1");
    try batch.put("key2", "val2");

    try std.testing.expectError(Error.StorageError, batch.commit());

    // No ops committed (atomic rollback)
    try std.testing.expectEqual(@as(usize, 0), atomic.committed_count);
    // Ops retained for retry
    try std.testing.expectEqual(@as(usize, 2), batch.pending());
}

test "WriteBatch: clear resets arena memory (reusable after clear)" {
    var tracker = TrackingDb.init(std.testing.allocator);
    defer tracker.deinit();

    var batch = WriteBatch.init(std.testing.allocator, tracker.database());
    defer batch.deinit();

    // Add many ops, clear, then add more — should not leak
    var i: usize = 0;
    while (i < 50) : (i += 1) {
        try batch.put("key", "value_with_some_length_to_force_alloc");
    }
    try std.testing.expectEqual(@as(usize, 50), batch.pending());

    batch.clear();
    try std.testing.expectEqual(@as(usize, 0), batch.pending());

    // Batch is reusable after clear
    try batch.put("new_key", "new_value");
    try std.testing.expectEqual(@as(usize, 1), batch.pending());

    try batch.commit();
    try std.testing.expectEqual(@as(usize, 1), tracker.puts.items.len);
}

test "WriteBatch: put propagates OutOfMemory not StorageError" {
    // Use a failing allocator to trigger OOM in put/delete
    var batch = WriteBatch.init(std.testing.failing_allocator, Database{
        .ptr = undefined,
        .vtable = &MockDb.vtable,
    });
    defer batch.deinit();

    // First put should fail with OutOfMemory from the failing allocator
    try std.testing.expectError(error.OutOfMemory, batch.put("key", "value"));
}

test "WriteBatch: delete propagates OutOfMemory not StorageError" {
    var batch = WriteBatch.init(std.testing.failing_allocator, Database{
        .ptr = undefined,
        .vtable = &MockDb.vtable,
    });
    defer batch.deinit();

    try std.testing.expectError(error.OutOfMemory, batch.delete("key"));
}
