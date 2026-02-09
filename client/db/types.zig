/// Shared database types modeled after Nethermind's Db and KeyValueStore APIs.
///
/// Re-exported from Voltaire primitives to enforce the "no local primitives"
/// requirement for the database abstraction layer.
const std = @import("std");
const primitives = @import("primitives");
const Db = primitives.Db;

pub const Error = Db.Error;
pub const DbName = Db.DbName;
pub const ReadFlags = Db.ReadFlags;
pub const WriteFlags = Db.WriteFlags;
pub const DbMetric = Db.DbMetric;
pub const ReleaseFn = Db.ReleaseFn;
pub const DbValue = Db.DbValue;
pub const DbEntry = Db.DbEntry;
pub const DbIterator = Db.DbIterator;
pub const DbSnapshot = Db.DbSnapshot;

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

test "DbName to_string matches Nethermind constants" {
    try std.testing.expectEqualStrings("state", DbName.state.to_string());
    try std.testing.expectEqualStrings("storage", DbName.storage.to_string());
    try std.testing.expectEqualStrings("code", DbName.code.to_string());
    try std.testing.expectEqualStrings("blocks", DbName.blocks.to_string());
    try std.testing.expectEqualStrings("headers", DbName.headers.to_string());
    try std.testing.expectEqualStrings("blockNumbers", DbName.block_numbers.to_string());
    try std.testing.expectEqualStrings("receipts", DbName.receipts.to_string());
    try std.testing.expectEqualStrings("blockInfos", DbName.block_infos.to_string());
    try std.testing.expectEqualStrings("badBlocks", DbName.bad_blocks.to_string());
    try std.testing.expectEqualStrings("bloom", DbName.bloom.to_string());
    try std.testing.expectEqualStrings("metadata", DbName.metadata.to_string());
    try std.testing.expectEqualStrings("blobTransactions", DbName.blob_transactions.to_string());
    try std.testing.expectEqualStrings("discoveryNodes", DbName.discovery_nodes.to_string());
    try std.testing.expectEqualStrings("discoveryV5Nodes", DbName.discovery_v5_nodes.to_string());
    try std.testing.expectEqualStrings("peers", DbName.peers.to_string());
}

test "DbName enum has all expected variants" {
    // Verify we can iterate all variants (compile-time check).
    // 15 = 12 original + 3 networking (discovery_nodes, discovery_v5_nodes, peers)
    const fields = std.meta.fields(DbName);
    try std.testing.expectEqual(@as(usize, 15), fields.len);
}

test "ReadFlags: union and contains" {
    var flags = ReadFlags.none;
    flags = flags.merge(ReadFlags.hint_cache_miss);
    flags = flags.merge(ReadFlags.skip_duplicate_read);

    try std.testing.expect(flags.has(ReadFlags.hint_cache_miss));
    try std.testing.expect(flags.has(ReadFlags.skip_duplicate_read));
    try std.testing.expect(!flags.has(ReadFlags.hint_read_ahead));
    const composite = ReadFlags.hint_cache_miss.merge(ReadFlags.hint_read_ahead);
    try std.testing.expect(!ReadFlags.hint_cache_miss.has(composite));
}

test "WriteFlags: union and contains" {
    var flags = WriteFlags.none;
    flags = flags.merge(WriteFlags.low_priority);
    try std.testing.expect(!flags.has(WriteFlags.low_priority_and_no_wal));
    flags = flags.merge(WriteFlags.disable_wal);

    try std.testing.expect(flags.has(WriteFlags.low_priority));
    try std.testing.expect(flags.has(WriteFlags.disable_wal));
    try std.testing.expect(flags.has(WriteFlags.low_priority_and_no_wal));
}

test "DbValue: release invokes callback" {
    const Ctx = struct { called: bool = false };
    var ctx = Ctx{};

    const release_fn = struct {
        fn call(ptr: ?*anyopaque, _: []const u8) void {
            const ctx_ptr = ptr orelse return;
            const c: *Ctx = @ptrCast(@alignCast(ctx_ptr));
            c.called = true;
        }
    }.call;

    const value = DbValue{
        .bytes = "hello",
        .release_ctx = &ctx,
        .release_fn = release_fn,
    };

    value.release();
    try std.testing.expect(ctx.called);
}

test "DbValue: borrowed returns bytes without release" {
    const value = DbValue.borrowed("hello");
    try std.testing.expectEqualStrings("hello", value.bytes);
    try std.testing.expect(value.release_ctx == null);
    try std.testing.expect(value.release_fn == null);
}

test "DbEntry: release invokes key and value callbacks" {
    const Ctx = struct { called: bool = false };
    var key_ctx = Ctx{};
    var val_ctx = Ctx{};

    const release_fn = struct {
        fn call(ptr: ?*anyopaque, _: []const u8) void {
            const ctx_ptr = ptr orelse return;
            const c: *Ctx = @ptrCast(@alignCast(ctx_ptr));
            c.called = true;
        }
    }.call;

    const entry = DbEntry{
        .key = .{ .bytes = "k", .release_ctx = &key_ctx, .release_fn = release_fn },
        .value = .{ .bytes = "v", .release_ctx = &val_ctx, .release_fn = release_fn },
    };

    entry.release();
    try std.testing.expect(key_ctx.called);
    try std.testing.expect(val_ctx.called);
}

test "DbIterator: next and deinit dispatch" {
    const Iter = struct {
        next_calls: usize = 0,
        deinit_calls: usize = 0,

        fn next(self: *Iter) Error!?DbEntry {
            self.next_calls += 1;
            return null;
        }

        fn deinit(self: *Iter) void {
            self.deinit_calls += 1;
        }
    };

    var iter = Iter{};
    var db_iter = DbIterator.init(Iter, &iter, Iter.next, Iter.deinit);

    _ = try db_iter.next();
    db_iter.deinit();

    try std.testing.expectEqual(@as(usize, 1), iter.next_calls);
    try std.testing.expectEqual(@as(usize, 1), iter.deinit_calls);
}

test "DbSnapshot: get/contains/iterator/deinit dispatch" {
    const Iter = struct {
        next_calls: usize = 0,

        fn next(self: *Iter) Error!?DbEntry {
            self.next_calls += 1;
            return null;
        }

        fn deinit(_: *Iter) void {}
    };

    const Snap = struct {
        iter: *Iter,
        get_calls: usize = 0,
        contains_calls: usize = 0,
        iterator_calls: usize = 0,
        deinit_calls: usize = 0,

        fn get(self: *Snap, key: []const u8, flags: ReadFlags) Error!?DbValue {
            _ = flags;
            self.get_calls += 1;
            if (std.mem.eql(u8, key, "hit")) {
                return DbValue.borrowed("value");
            }
            return null;
        }

        fn contains(self: *Snap, key: []const u8) Error!bool {
            self.contains_calls += 1;
            return std.mem.eql(u8, key, "hit");
        }

        fn iterator(self: *Snap, ordered: bool) Error!DbIterator {
            _ = ordered;
            self.iterator_calls += 1;
            return DbIterator.init(Iter, self.iter, Iter.next, Iter.deinit);
        }

        fn deinit(self: *Snap) void {
            self.deinit_calls += 1;
        }
    };

    var iter = Iter{};
    var snap = Snap{ .iter = &iter };
    var db_snap = DbSnapshot.init(Snap, &snap, Snap.get, Snap.contains, Snap.iterator, Snap.deinit);

    const miss = try db_snap.get("miss", .none);
    try std.testing.expect(miss == null);

    const hit = (try db_snap.get("hit", .none)).?;
    defer hit.release();
    try std.testing.expectEqualStrings("value", hit.bytes);

    try std.testing.expect(try db_snap.contains("hit"));
    try std.testing.expect(!try db_snap.contains("miss"));

    var it = try db_snap.iterator(false);
    _ = try it.next();
    it.deinit();

    db_snap.deinit();

    try std.testing.expectEqual(@as(usize, 2), snap.get_calls);
    try std.testing.expectEqual(@as(usize, 2), snap.contains_calls);
    try std.testing.expectEqual(@as(usize, 1), snap.iterator_calls);
    try std.testing.expectEqual(@as(usize, 1), snap.deinit_calls);
    try std.testing.expectEqual(@as(usize, 1), iter.next_calls);
}

test "DbSnapshot: iterator returns UnsupportedOperation when unset" {
    const Snap = struct {
        fn get(_: *Snap, _: []const u8, _: ReadFlags) Error!?DbValue {
            return null;
        }

        fn contains(_: *Snap, _: []const u8) Error!bool {
            return false;
        }

        fn deinit(_: *Snap) void {}
    };

    var snap = Snap{};
    var db_snap = DbSnapshot.init(Snap, &snap, Snap.get, Snap.contains, null, Snap.deinit);

    try std.testing.expectError(error.UnsupportedOperation, db_snap.iterator(false));
    db_snap.deinit();
}
