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
/// The `Database` / `WriteBatch` types (and shared types in `types.zig`) are
/// intentionally backend-agnostic — Voltaire does not provide a raw KV
/// persistence interface, so this abstraction fills that gap.
const std = @import("std");
const types = @import("types.zig");
pub const DbEntry = types.DbEntry;
pub const DbIterator = types.DbIterator;
pub const DbMetric = types.DbMetric;
pub const DbName = types.DbName;
pub const DbSnapshot = types.DbSnapshot;
pub const DbValue = types.DbValue;
pub const Error = types.Error;
pub const ReadFlags = types.ReadFlags;
pub const WriteFlags = types.WriteFlags;

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
/// var mem_db = MemoryDatabase.init(allocator, .state);
/// defer mem_db.deinit();
///
/// // Get the type-erased Database interface
/// const db = mem_db.database();
///
/// // Use the interface
/// try db.put("key", "value");
/// const view = try db.get("key"); // returns ?DbValue
/// if (view) |val| {
///     defer val.release();
///     _ = val.bytes;
/// }
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
        /// Logical database name (Nethermind IDb.Name).
        name: *const fn (ptr: *anyopaque) DbName,

        /// Retrieve the value associated with `key`.
        /// Returns `null` if the key does not exist.
        /// The returned value may require an explicit release.
        get: *const fn (ptr: *anyopaque, key: []const u8, flags: ReadFlags) Error!?DbValue,

        /// Store a key-value pair. If `value` is `null`, this is equivalent
        /// to calling `delete`. Overwrites any existing value for the key.
        put: *const fn (ptr: *anyopaque, key: []const u8, value: ?[]const u8, flags: WriteFlags) Error!void,

        /// Remove the entry for `key`. No-op if the key does not exist.
        delete: *const fn (ptr: *anyopaque, key: []const u8, flags: WriteFlags) Error!void,

        /// Check whether `key` exists in the database.
        contains: *const fn (ptr: *anyopaque, key: []const u8) Error!bool,

        /// Return an iterator over all key/value pairs.
        iterator: ?*const fn (ptr: *anyopaque, ordered: bool) Error!DbIterator = null,

        /// Create a read-only snapshot of the database.
        snapshot: ?*const fn (ptr: *anyopaque) Error!DbSnapshot = null,

        /// Apply a batch of write operations atomically.
        ///
        /// Backends that support native batch writes (e.g. RocksDB WriteBatch)
        /// should implement this to provide true all-or-nothing semantics.
        /// If `null`, WriteBatch.commit will fall back to sequential application
        /// with best-effort error reporting (partial writes possible on error).
        ///
        /// On success, all operations in `ops` are applied. On error, the
        /// backend must guarantee that NO operations were applied (rollback).
        write_batch: ?*const fn (ptr: *anyopaque, ops: []const WriteBatchOp) Error!void = null,

        /// Flush pending writes to disk (optional).
        flush: ?*const fn (ptr: *anyopaque, only_wal: bool) Error!void = null,

        /// Clear all stored entries (optional).
        clear: ?*const fn (ptr: *anyopaque) Error!void = null,

        /// Compact the database storage (optional).
        compact: ?*const fn (ptr: *anyopaque) Error!void = null,

        /// Gather database metrics (optional).
        gather_metric: ?*const fn (ptr: *anyopaque) Error!DbMetric = null,
    };

    /// Return the logical database name.
    pub fn name(self: Database) DbName {
        return self.vtable.name(self.ptr);
    }

    /// Retrieve the value associated with `key`.
    /// Returns `null` if the key does not exist.
    ///
    /// Call `DbValue.release()` on any non-null return before dropping it.
    pub fn get(self: Database, key: []const u8) Error!?DbValue {
        return self.vtable.get(self.ptr, key, .none);
    }

    /// Retrieve the value associated with `key` with explicit read flags.
    pub fn get_with_flags(self: Database, key: []const u8, flags: ReadFlags) Error!?DbValue {
        return self.vtable.get(self.ptr, key, flags);
    }

    /// Retrieve a value and copy it into caller-owned memory.
    pub fn get_copy(self: Database, allocator: std.mem.Allocator, key: []const u8) Error!?[]u8 {
        return self.get_copy_with_flags(allocator, key, .none);
    }

    /// Retrieve a value and copy it into caller-owned memory with explicit flags.
    pub fn get_copy_with_flags(self: Database, allocator: std.mem.Allocator, key: []const u8, flags: ReadFlags) Error!?[]u8 {
        const view = try self.get_with_flags(key, flags) orelse return null;
        defer view.release();

        const out = allocator.alloc(u8, view.bytes.len) catch return error.OutOfMemory;
        @memcpy(out, view.bytes);
        return out;
    }

    /// Store a key-value pair. If `value` is `null`, this is equivalent
    /// to calling `delete`.
    pub fn put(self: Database, key: []const u8, value: ?[]const u8) Error!void {
        return self.vtable.put(self.ptr, key, value, .none);
    }

    /// Store a key-value pair with explicit write flags.
    pub fn put_with_flags(self: Database, key: []const u8, value: ?[]const u8, flags: WriteFlags) Error!void {
        return self.vtable.put(self.ptr, key, value, flags);
    }

    /// Remove the entry for `key`. No-op if the key does not exist.
    pub fn delete(self: Database, key: []const u8) Error!void {
        return self.vtable.delete(self.ptr, key, .none);
    }

    /// Remove the entry for `key` with explicit write flags.
    pub fn delete_with_flags(self: Database, key: []const u8, flags: WriteFlags) Error!void {
        return self.vtable.delete(self.ptr, key, flags);
    }

    /// Check whether `key` exists in the database.
    pub fn contains(self: Database, key: []const u8) Error!bool {
        return self.vtable.contains(self.ptr, key);
    }

    /// Return an iterator over all key/value pairs.
    pub fn iterator(self: Database, ordered: bool) Error!DbIterator {
        if (self.vtable.iterator) |iter_fn| {
            return iter_fn(self.ptr, ordered);
        }
        return error.UnsupportedOperation;
    }

    /// Create a read-only snapshot of the database.
    pub fn snapshot(self: Database) Error!DbSnapshot {
        if (self.vtable.snapshot) |snap_fn| {
            return snap_fn(self.ptr);
        }
        return error.UnsupportedOperation;
    }

    /// Flush pending writes to disk (optional).
    pub fn flush(self: Database, only_wal: bool) Error!void {
        if (self.vtable.flush) |flush_fn| {
            return flush_fn(self.ptr, only_wal);
        }
    }

    /// Clear all stored entries (optional).
    pub fn clear(self: Database) Error!void {
        if (self.vtable.clear) |clear_fn| {
            return clear_fn(self.ptr);
        }
    }

    /// Compact the database storage (optional).
    pub fn compact(self: Database) Error!void {
        if (self.vtable.compact) |compact_fn| {
            return compact_fn(self.ptr);
        }
    }

    /// Gather database metrics (optional).
    pub fn gather_metric(self: Database) Error!DbMetric {
        if (self.vtable.gather_metric) |metric_fn| {
            return metric_fn(self.ptr);
        }
        return DbMetric{};
    }

    /// Create a new WriteBatch targeting this database.
    pub fn start_write_batch(self: Database, allocator: std.mem.Allocator) WriteBatch {
        return WriteBatch.init(allocator, self);
    }
};

/// A single write operation for use with `Database.VTable.write_batch`.
///
/// Each operation represents either a key-value insertion or a key deletion.
/// Operations are accumulated in a `WriteBatch` and applied together via
/// `WriteBatch.commit()`.
pub const WriteBatchOp = union(enum) {
    /// Store a key-value pair. Overwrites any existing value for the key.
    put: struct {
        /// The key to store. Owned by the `WriteBatch` arena.
        key: []const u8,
        /// The value to associate with the key. Owned by the `WriteBatch` arena.
        value: []const u8,
        /// Per-write flags (Nethermind WriteFlags).
        flags: WriteFlags,
    },
    /// Remove the entry for a key. No-op if the key does not exist.
    del: struct {
        /// The key to remove. Owned by the `WriteBatch` arena.
        key: []const u8,
        /// Per-write flags (Nethermind WriteFlags).
        flags: WriteFlags,
    },
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
/// If the target database implements `VTable.write_batch`, commit uses it
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
        return self.put_with_flags(key, value, .none);
    }

    /// Queue a put operation with explicit write flags.
    pub fn put_with_flags(self: *WriteBatch, key: []const u8, value: []const u8, flags: WriteFlags) Error!void {
        const alloc = self.arena.allocator();
        const owned_key = alloc.dupe(u8, key) catch return error.OutOfMemory;
        const owned_val = alloc.dupe(u8, value) catch return error.OutOfMemory;
        self.ops.append(alloc, .{ .put = .{ .key = owned_key, .value = owned_val, .flags = flags } }) catch return error.OutOfMemory;
    }

    /// Queue a delete operation. The key is copied into the batch arena.
    pub fn delete(self: *WriteBatch, key: []const u8) Error!void {
        return self.delete_with_flags(key, .none);
    }

    /// Queue a delete operation with explicit write flags.
    pub fn delete_with_flags(self: *WriteBatch, key: []const u8, flags: WriteFlags) Error!void {
        const alloc = self.arena.allocator();
        const owned_key = alloc.dupe(u8, key) catch return error.OutOfMemory;
        self.ops.append(alloc, .{ .del = .{ .key = owned_key, .flags = flags } }) catch return error.OutOfMemory;
    }

    /// Apply all pending operations to the target database.
    ///
    /// If the backend provides `write_batch`, all operations are applied
    /// atomically (all-or-nothing). Otherwise, operations are applied
    /// sequentially; on error, already-applied operations remain and the
    /// batch retains its pending ops for inspection or retry.
    ///
    /// On success, pending ops are cleared. `deinit()` must still be
    /// called to free arena memory.
    pub fn commit(self: *WriteBatch) Error!void {
        if (self.ops.items.len == 0) return;

        if (self.target.vtable.write_batch) |batch_fn| {
            // Atomic path: backend handles all-or-nothing semantics.
            try batch_fn(self.target.ptr, self.ops.items);
        } else {
            // Sequential fallback: apply one-by-one.
            // On error, ops are NOT cleared so caller can inspect/retry.
            for (self.ops.items) |op| {
                switch (op) {
                    .put => |p| try self.target.put_with_flags(p.key, p.value, p.flags),
                    .del => |d| try self.target.delete_with_flags(d.key, d.flags),
                }
            }
        }
        // Only clear on success.
        _ = self.arena.reset(.free_all);
        self.ops = .{};
    }

    /// Discard all pending operations without applying them.
    /// Resets the arena to free accumulated key/value memory, preventing
    /// unbounded memory retention for long-lived batches.
    pub fn clear(self: *WriteBatch) void {
        // Reset arena to free all accumulated key/value copies.
        // This prevents unbounded memory growth for long-lived batches
        // that repeatedly accumulate and clear operations.
        _ = self.arena.reset(.free_all);
        // After reset, the ops ArrayList's buffer is invalidated,
        // so reset it to empty state.
        self.ops = .{};
    }

    /// Return the number of pending operations.
    fn pending(self: *const WriteBatch) usize {
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
    name: DbName = .state,

    fn name_impl(ptr: *anyopaque) DbName {
        const self: *MockDb = @ptrCast(@alignCast(ptr));
        self.call_count += 1;
        return self.name;
    }

    fn get_impl(ptr: *anyopaque, _: []const u8, _: ReadFlags) Error!?DbValue {
        const self: *MockDb = @ptrCast(@alignCast(ptr));
        self.call_count += 1;
        return null;
    }

    fn put_impl(ptr: *anyopaque, _: []const u8, _: ?[]const u8, _: WriteFlags) Error!void {
        const self: *MockDb = @ptrCast(@alignCast(ptr));
        self.call_count += 1;
    }

    fn delete_impl(ptr: *anyopaque, _: []const u8, _: WriteFlags) Error!void {
        const self: *MockDb = @ptrCast(@alignCast(ptr));
        self.call_count += 1;
    }

    fn contains_impl(ptr: *anyopaque, _: []const u8) Error!bool {
        const self: *MockDb = @ptrCast(@alignCast(ptr));
        self.call_count += 1;
        return false;
    }

    const vtable = Database.VTable{
        .name = name_impl,
        .get = get_impl,
        .put = put_impl,
        .delete = delete_impl,
        .contains = contains_impl,
    };

    fn database(self: *MockDb) Database {
        return .{
            .ptr = @ptrCast(self),
            .vtable = &vtable,
        };
    }
};

/// Mock database that returns a value with a release callback.
const ValueDb = struct {
    released: bool = false,
    value: []const u8,

    fn name_impl(_: *anyopaque) DbName {
        return .state;
    }

    fn get_impl(ptr: *anyopaque, _: []const u8, _: ReadFlags) Error!?DbValue {
        const self: *ValueDb = @ptrCast(@alignCast(ptr));
        return DbValue{
            .bytes = self.value,
            .release_ctx = self,
            .release_fn = release_impl,
        };
    }

    fn release_impl(ctx: ?*anyopaque, _: []const u8) void {
        const ctx_ptr = ctx orelse return;
        const self: *ValueDb = @ptrCast(@alignCast(ctx_ptr));
        self.released = true;
    }

    fn put_impl(_: *anyopaque, _: []const u8, _: ?[]const u8, _: WriteFlags) Error!void {}

    fn delete_impl(_: *anyopaque, _: []const u8, _: WriteFlags) Error!void {}

    fn contains_impl(_: *anyopaque, _: []const u8) Error!bool {
        return true;
    }

    const vtable = Database.VTable{
        .name = name_impl,
        .get = get_impl,
        .put = put_impl,
        .delete = delete_impl,
        .contains = contains_impl,
    };

    fn database(self: *ValueDb) Database {
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
    try std.testing.expect(result == null);
    try std.testing.expectEqual(@as(usize, 1), mock.call_count);
}

test "Database vtable dispatches get_with_flags" {
    var mock = MockDb{};
    const db = mock.database();

    _ = try db.get_with_flags("test_key", .none);
    try std.testing.expectEqual(@as(usize, 1), mock.call_count);
}

test "Database vtable dispatches name" {
    var mock = MockDb{};
    const db = mock.database();

    const name = db.name();
    try std.testing.expectEqual(DbName.state, name);
    try std.testing.expectEqual(@as(usize, 1), mock.call_count);
}

test "Database get_copy releases view and copies bytes" {
    var value_db = ValueDb{ .value = "value" };
    const db = value_db.database();

    const copy = try db.get_copy(std.testing.allocator, "key");
    defer if (copy) |bytes| std.testing.allocator.free(bytes);

    try std.testing.expect(copy != null);
    try std.testing.expectEqualStrings("value", copy.?);
    try std.testing.expect(value_db.released);
}

test "Database get_copy_with_flags releases view and copies bytes" {
    var value_db = ValueDb{ .value = "value" };
    const db = value_db.database();

    const copy = try db.get_copy_with_flags(std.testing.allocator, "key", .none);
    defer if (copy) |bytes| std.testing.allocator.free(bytes);

    try std.testing.expect(copy != null);
    try std.testing.expectEqualStrings("value", copy.?);
    try std.testing.expect(value_db.released);
}

test "Database iterator returns UnsupportedOperation when missing" {
    var mock = MockDb{};
    const db = mock.database();

    try std.testing.expectError(error.UnsupportedOperation, db.iterator(false));
}

test "Database snapshot returns UnsupportedOperation when missing" {
    var mock = MockDb{};
    const db = mock.database();

    try std.testing.expectError(error.UnsupportedOperation, db.snapshot());
}

test "Database meta methods are no-ops when not implemented" {
    var mock = MockDb{};
    const db = mock.database();

    try db.flush(false);
    try db.clear();
    try db.compact();
    const metric = try db.gather_metric();
    try std.testing.expectEqual(@as(u64, 0), metric.size);
}

test "Database vtable dispatches put" {
    var mock = MockDb{};
    const db = mock.database();

    try db.put("key", "value");
    try std.testing.expectEqual(@as(usize, 1), mock.call_count);
}

test "Database vtable dispatches put_with_flags" {
    var mock = MockDb{};
    const db = mock.database();

    try db.put_with_flags("key", "value", .none);
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

test "Database vtable dispatches delete_with_flags" {
    var mock = MockDb{};
    const db = mock.database();

    try db.delete_with_flags("key", .none);
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

test "Database: start_write_batch targets the database" {
    var mock = MockDb{};
    const db = mock.database();

    var batch = db.start_write_batch(std.testing.allocator);
    defer batch.deinit();

    try batch.put("key", "value");
    try batch.commit();

    try std.testing.expectEqual(@as(usize, 1), mock.call_count);
}

// -- WriteBatch tests -------------------------------------------------------

/// A tracking mock database for WriteBatch tests.
/// Records every put/delete so we can verify commit behavior.
const TrackingDb = struct {
    puts: std.ArrayListUnmanaged(struct { key: []const u8, value: ?[]const u8, flags: WriteFlags }) = .{},
    deletes: std.ArrayListUnmanaged(struct { key: []const u8, flags: WriteFlags }) = .{},
    alloc: std.mem.Allocator,
    name: DbName = .state,

    fn init(allocator: std.mem.Allocator) TrackingDb {
        return .{ .alloc = allocator };
    }

    fn deinit(self: *TrackingDb) void {
        for (self.puts.items) |item| {
            self.alloc.free(item.key);
            if (item.value) |val| {
                self.alloc.free(val);
            }
        }
        self.puts.deinit(self.alloc);

        for (self.deletes.items) |item| {
            self.alloc.free(item.key);
        }
        self.deletes.deinit(self.alloc);
    }

    fn name_impl(ptr: *anyopaque) DbName {
        const self: *TrackingDb = @ptrCast(@alignCast(ptr));
        return self.name;
    }

    fn get_impl(_: *anyopaque, _: []const u8, _: ReadFlags) Error!?DbValue {
        return null;
    }

    fn put_impl(ptr: *anyopaque, key: []const u8, value: ?[]const u8, flags: WriteFlags) Error!void {
        const self: *TrackingDb = @ptrCast(@alignCast(ptr));
        const owned_key = self.alloc.dupe(u8, key) catch return error.OutOfMemory;
        var owned_val: ?[]const u8 = null;
        if (value) |val| {
            owned_val = self.alloc.dupe(u8, val) catch {
                self.alloc.free(owned_key);
                return error.OutOfMemory;
            };
        }

        self.puts.append(self.alloc, .{ .key = owned_key, .value = owned_val, .flags = flags }) catch {
            if (owned_val) |val| self.alloc.free(val);
            self.alloc.free(owned_key);
            return error.OutOfMemory;
        };
    }

    fn delete_impl(ptr: *anyopaque, key: []const u8, flags: WriteFlags) Error!void {
        const self: *TrackingDb = @ptrCast(@alignCast(ptr));
        const owned_key = self.alloc.dupe(u8, key) catch return error.OutOfMemory;
        self.deletes.append(self.alloc, .{ .key = owned_key, .flags = flags }) catch {
            self.alloc.free(owned_key);
            return error.OutOfMemory;
        };
    }

    fn contains_impl(_: *anyopaque, _: []const u8) Error!bool {
        return false;
    }

    const vtable = Database.VTable{
        .name = name_impl,
        .get = get_impl,
        .put = put_impl,
        .delete = delete_impl,
        .contains = contains_impl,
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
    try std.testing.expectEqualStrings("gone", tracker.deletes.items[0].key);
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

test "WriteBatch: preserves per-op flags" {
    var tracker = TrackingDb.init(std.testing.allocator);
    defer tracker.deinit();

    var batch = WriteBatch.init(std.testing.allocator, tracker.database());
    defer batch.deinit();

    try batch.put_with_flags("key", "value", WriteFlags.low_priority);
    try batch.delete_with_flags("gone", WriteFlags.disable_wal);
    try batch.commit();

    try std.testing.expectEqual(@as(usize, 1), tracker.puts.items.len);
    try std.testing.expect(tracker.puts.items[0].flags.has(WriteFlags.low_priority));
    try std.testing.expectEqual(@as(usize, 1), tracker.deletes.items.len);
    try std.testing.expect(tracker.deletes.items[0].flags.has(WriteFlags.disable_wal));
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
    name: DbName = .state,

    fn name_impl(ptr: *anyopaque) DbName {
        const self: *FailingDb = @ptrCast(@alignCast(ptr));
        return self.name;
    }

    fn get_impl(_: *anyopaque, _: []const u8, _: ReadFlags) Error!?DbValue {
        return null;
    }

    fn put_impl(ptr: *anyopaque, _: []const u8, _: ?[]const u8, _: WriteFlags) Error!void {
        const self: *FailingDb = @ptrCast(@alignCast(ptr));
        if (self.applied >= self.succeed_count) {
            return Error.StorageError;
        }
        self.applied += 1;
    }

    fn delete_impl(ptr: *anyopaque, _: []const u8, _: WriteFlags) Error!void {
        const self: *FailingDb = @ptrCast(@alignCast(ptr));
        if (self.applied >= self.succeed_count) {
            return Error.StorageError;
        }
        self.applied += 1;
    }

    fn contains_impl(_: *anyopaque, _: []const u8) Error!bool {
        return false;
    }

    const vtable = Database.VTable{
        .name = name_impl,
        .get = get_impl,
        .put = put_impl,
        .delete = delete_impl,
        .contains = contains_impl,
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

/// A mock database that supports atomic write_batch (all-or-nothing).
const AtomicDb = struct {
    /// Tracks how many ops were committed atomically.
    committed_count: usize = 0,
    /// When true, write_batch will fail (to test rollback).
    should_fail: bool = false,
    name: DbName = .state,

    fn name_impl(ptr: *anyopaque) DbName {
        const self: *AtomicDb = @ptrCast(@alignCast(ptr));
        return self.name;
    }

    fn get_impl(_: *anyopaque, _: []const u8, _: ReadFlags) Error!?DbValue {
        return null;
    }

    fn put_impl(ptr: *anyopaque, _: []const u8, _: ?[]const u8, _: WriteFlags) Error!void {
        const self: *AtomicDb = @ptrCast(@alignCast(ptr));
        self.committed_count += 1;
    }

    fn delete_impl(ptr: *anyopaque, _: []const u8, _: WriteFlags) Error!void {
        const self: *AtomicDb = @ptrCast(@alignCast(ptr));
        self.committed_count += 1;
    }

    fn contains_impl(_: *anyopaque, _: []const u8) Error!bool {
        return false;
    }

    fn write_batch_impl(ptr: *anyopaque, ops: []const WriteBatchOp) Error!void {
        const self: *AtomicDb = @ptrCast(@alignCast(ptr));
        if (self.should_fail) {
            return Error.StorageError;
        }
        // Atomic: apply all or none.
        self.committed_count += ops.len;
    }

    const vtable = Database.VTable{
        .name = name_impl,
        .get = get_impl,
        .put = put_impl,
        .delete = delete_impl,
        .contains = contains_impl,
        .write_batch = write_batch_impl,
    };

    fn database(self: *AtomicDb) Database {
        return .{
            .ptr = @ptrCast(self),
            .vtable = &vtable,
        };
    }
};

test "WriteBatch: uses write_batch vtable for atomic commit" {
    var atomic = AtomicDb{};

    var batch = WriteBatch.init(std.testing.allocator, atomic.database());
    defer batch.deinit();

    try batch.put("key1", "val1");
    try batch.put("key2", "val2");
    try batch.delete("key3");

    try batch.commit();

    // All 3 ops committed atomically via write_batch
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
