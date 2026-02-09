/// Shared database types modeled after Nethermind's Db and KeyValueStore APIs.
///
/// These types are used across adapter and backend implementations to keep
/// the DB surface consistent and testable.
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
    /// Operation is not supported by this backend.
    UnsupportedOperation,
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
    pub fn to_string(self: DbName) []const u8 {
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

/// Read flags (Nethermind `ReadFlags`).
pub const ReadFlags = struct {
    bits: u8 = 0,

    pub const none = ReadFlags{ .bits = 0 };
    pub const hint_cache_miss = ReadFlags{ .bits = 1 << 0 };
    pub const hint_read_ahead = ReadFlags{ .bits = 1 << 1 };
    pub const hint_read_ahead2 = ReadFlags{ .bits = 1 << 2 };
    pub const hint_read_ahead3 = ReadFlags{ .bits = 1 << 3 };
    pub const skip_duplicate_read = ReadFlags{ .bits = 1 << 4 };

    pub fn has(self: ReadFlags, flag: ReadFlags) bool {
        return (self.bits & flag.bits) != 0;
    }

    pub fn merge(self: ReadFlags, flag: ReadFlags) ReadFlags {
        return .{ .bits = self.bits | flag.bits };
    }
};

/// Write flags (Nethermind `WriteFlags`).
pub const WriteFlags = struct {
    bits: u8 = 0,

    pub const none = WriteFlags{ .bits = 0 };
    pub const low_priority = WriteFlags{ .bits = 1 << 0 };
    pub const disable_wal = WriteFlags{ .bits = 1 << 1 };
    pub const low_priority_and_no_wal = WriteFlags{ .bits = (1 << 0) | (1 << 1) };

    pub fn has(self: WriteFlags, flag: WriteFlags) bool {
        return (self.bits & flag.bits) != 0;
    }

    pub fn merge(self: WriteFlags, flag: WriteFlags) WriteFlags {
        return .{ .bits = self.bits | flag.bits };
    }
};

/// Database metrics (Nethermind `DbMetric`).
pub const DbMetric = struct {
    size: u64 = 0,
    cache_size: u64 = 0,
    index_size: u64 = 0,
    memtable_size: u64 = 0,
    total_reads: u64 = 0,
    total_writes: u64 = 0,
};

/// Release callback for borrowed database values.
pub const ReleaseFn = *const fn (ctx: *anyopaque, bytes: []const u8) void;

/// Borrowed DB value with explicit release semantics.
///
/// Some backends can return zero-copy slices that must be released after use
/// (e.g., RocksDB pinning). For such backends, `release_fn` must be set.
pub const DbValue = struct {
    bytes: []const u8,
    release_ctx: ?*anyopaque = null,
    release_fn: ?ReleaseFn = null,

    pub fn borrowed(bytes: []const u8) DbValue {
        return .{ .bytes = bytes };
    }

    pub fn release(self: DbValue) void {
        if (self.release_fn) |func| {
            if (self.release_ctx) |ctx| {
                func(ctx, self.bytes);
            }
        }
    }
};

/// Key/value pair returned from iteration.
pub const DbEntry = struct {
    key: DbValue,
    value: DbValue,

    pub fn release(self: DbEntry) void {
        self.key.release();
        self.value.release();
    }
};

/// Type-erased iterator over DB entries.
pub const DbIterator = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        next: *const fn (ptr: *anyopaque) Error!?DbEntry,
        deinit: *const fn (ptr: *anyopaque) void,
    };

    pub fn next(self: *DbIterator) Error!?DbEntry {
        return self.vtable.next(self.ptr);
    }

    pub fn deinit(self: *DbIterator) void {
        self.vtable.deinit(self.ptr);
    }
};

/// Type-erased read-only snapshot.
pub const DbSnapshot = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        get: *const fn (ptr: *anyopaque, key: []const u8, flags: ReadFlags) Error!?DbValue,
        contains: *const fn (ptr: *anyopaque, key: []const u8) Error!bool,
        iterator: ?*const fn (ptr: *anyopaque, ordered: bool) Error!DbIterator = null,
        deinit: *const fn (ptr: *anyopaque) void,
    };

    pub fn get(self: DbSnapshot, key: []const u8, flags: ReadFlags) Error!?DbValue {
        return self.vtable.get(self.ptr, key, flags);
    }

    pub fn contains(self: DbSnapshot, key: []const u8) Error!bool {
        return self.vtable.contains(self.ptr, key);
    }

    pub fn iterator(self: DbSnapshot, ordered: bool) Error!DbIterator {
        if (self.vtable.iterator) |iter_fn| {
            return iter_fn(self.ptr, ordered);
        }
        return error.UnsupportedOperation;
    }

    pub fn deinit(self: *DbSnapshot) void {
        self.vtable.deinit(self.ptr);
    }
};

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
}

test "WriteFlags: union and contains" {
    var flags = WriteFlags.none;
    flags = flags.merge(WriteFlags.low_priority);
    flags = flags.merge(WriteFlags.disable_wal);

    try std.testing.expect(flags.has(WriteFlags.low_priority));
    try std.testing.expect(flags.has(WriteFlags.disable_wal));
    try std.testing.expect(flags.has(WriteFlags.low_priority_and_no_wal));
}

test "DbValue: release invokes callback" {
    const Ctx = struct { called: bool = false };
    var ctx = Ctx{};

    const release_fn = struct {
        fn call(ptr: *anyopaque, _: []const u8) void {
            const c: *Ctx = @ptrCast(@alignCast(ptr));
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

test "DbEntry: release invokes key and value callbacks" {
    const Ctx = struct { called: bool = false };
    var key_ctx = Ctx{};
    var val_ctx = Ctx{};

    const release_fn = struct {
        fn call(ptr: *anyopaque, _: []const u8) void {
            const c: *Ctx = @ptrCast(@alignCast(ptr));
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
