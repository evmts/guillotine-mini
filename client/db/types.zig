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
