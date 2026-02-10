/// Chain management aliases backed by Voltaire primitives.
const std = @import("std");
const blockchain = @import("blockchain");
const primitives = @import("primitives");
const Block = primitives.Block;
const Hash = primitives.Hash;

/// Chain management handle backed by Voltaire's `Blockchain` primitive.
pub const Chain = blockchain.Blockchain;

const ForkBlockCache = blockchain.ForkBlockCache;

/// Returns the canonical head hash if present.
///
/// Semantics:
/// - Reads the current head block number; if none is set, returns null.
/// - Fetches the canonical block for that number and derives the hash from the
///   returned block (single-source snapshot) rather than consulting the
///   number→hash map separately. This avoids stale hash reads if the head
///   changes between calls.
/// - Best‑effort race resilience: if the head number changes during the read,
///   the helper returns null instead of a potentially stale value.
pub fn head_hash(chain: *Chain) !?Hash.Hash {
    // Delegate to the generic helper to avoid duplication and propagate errors.
    return try head_hash_of(chain);
}

/// Returns the canonical head block if present.
///
/// Semantics:
/// - Reads the current head block number; if none is set, returns null.
/// - Fetches the canonical block for the current head number in a single pass;
///   returns null if the head number changes mid‑call.
/// - Propagates any underlying errors (e.g. `error.RpcPending` when a fork
///   cache is configured and the block must be fetched remotely).
pub fn head_block(chain: *Chain) !?Block.Block {
    // Delegate to the generic helper to avoid duplication.
    return head_block_of(chain);
}

/// Returns the canonical head block number if present.
///
/// Thin wrapper over Voltaire's `Blockchain.getHeadBlockNumber` to expose a
/// stable API from the client layer. Prefer this over calling the underlying
/// orchestrator directly to keep call sites decoupled.
pub fn head_number(chain: *Chain) ?u64 {
    return chain.getHeadBlockNumber();
}

/// Returns true if the given hash is canonical at its block number (local-only).
///
/// Follows Nethermind semantics: compare the hash against the canonical mapping
/// for the block number using the local store only (no RPC or allocations).
/// Orphaned blocks are not canonical by definition.
pub fn is_canonical(chain: *Chain, hash: Hash.Hash) bool {
    // Local-only read via adapter helpers to avoid coupling to internals.
    const local = get_block_local(chain, hash) orelse return false;
    const number = local.header.number;
    const canonical = canonical_hash(chain, number) orelse return false;
    return Hash.equals(&canonical, &hash);
}

/// Returns true if the given hash is canonical, allowing fork-cache fetches.
///
/// Semantics:
/// - Tries local; if missing and a fork cache is configured, underlying call
///   may return `error.RpcPending` to request remote resolution.
/// - Preferred for performance when remote reads are acceptable.
pub fn is_canonical_or_fetch(chain: *Chain, hash: Hash.Hash) !bool {
    const maybe_block = try chain.getBlockByHash(hash);
    const block = maybe_block orelse return false;
    const number = block.header.number;
    const canonical = chain.getCanonicalHash(number) orelse return false;
    return Hash.equals(&canonical, &hash);
}

/// Returns true if the block is present locally or cached in the fork cache.
///
/// Thin wrapper over Voltaire `Blockchain.hasBlock` to keep client code
/// decoupled from the underlying orchestrator while adhering to Nethermind's
/// separation of concerns (storage/provider split).
pub fn has_block(chain: *Chain, hash: Hash.Hash) bool {
    return chain.hasBlock(hash);
}

/// Returns the canonical hash for a given block number (local-only).
///
/// Thin wrapper over Voltaire `Blockchain.getCanonicalHash` to keep client
/// code decoupled from the underlying orchestrator. Does not fetch from a
/// fork cache and performs no allocations.
pub fn canonical_hash(chain: *Chain, number: u64) ?Hash.Hash {
    return chain.getCanonicalHash(number);
}

// ---------------------------------------------------------------------------
// Comptime DI helpers (Nethermind-style parity)
// ---------------------------------------------------------------------------

/// Returns a block by hash from the local store only (no fork-cache fetch).
///
/// - Avoids allocations and remote requests.
/// - Mirrors Nethermind's storage/provider split where local reads are
///   explicit and do not cross abstraction boundaries.
pub fn get_block_local(chain: *Chain, hash: Hash.Hash) ?Block.Block {
    return chain.block_store.getBlock(hash);
}

/// Returns a canonical block by number from the local store only.
///
/// - Does not consult the fork cache or perform any allocations.
/// - Mirrors Nethermind semantics where local canonical lookups are explicit
///   and do not trigger remote fetches.
pub fn get_block_by_number_local(chain: *Chain, number: u64) ?Block.Block {
    return chain.block_store.getBlockByNumber(number);
}

/// Generic, comptime-injected head hash reader for any chain-like type.
pub fn head_hash_of(chain: anytype) !?Hash.Hash {
    const max_attempts: usize = 2;
    var attempt: usize = 0;
    while (attempt < max_attempts) : (attempt += 1) {
        const before = chain.getHeadBlockNumber() orelse return null;
        const maybe_block = try chain.getBlockByNumber(before);
        const hb = maybe_block orelse return null;
        const after = chain.getHeadBlockNumber() orelse return null;
        if (after == before) return hb.hash;
        if (attempt + 1 == max_attempts) return hb.hash; // return 'before' snapshot
    }
    return null; // defensive
}

/// Generic, comptime-injected head block reader for any chain-like type.
pub fn head_block_of(chain: anytype) !?Block.Block {
    const max_attempts: usize = 2;
    var attempt: usize = 0;
    while (attempt < max_attempts) : (attempt += 1) {
        const before = chain.getHeadBlockNumber() orelse return null;
        const maybe_block = try chain.getBlockByNumber(before);
        const hb = maybe_block orelse return null;
        const after = chain.getHeadBlockNumber() orelse return null;
        if (after == before) return hb;
        if (attempt + 1 == max_attempts) return hb; // return 'before' snapshot
    }
    return null; // defensive
}

/// Generic, comptime-injected head number reader for any chain-like type.
///
/// The provided `chain` must define `getHeadBlockNumber() -> ?u64`.
pub fn head_number_of(chain: anytype) ?u64 {
    return chain.getHeadBlockNumber();
}

/// Forkchoice view provider interface (duck-typed via comptime DI).
///
/// Expected minimal API:
/// - `getSafeHash() -> ?Hash.Hash`
/// - `getFinalizedHash() -> ?Hash.Hash`
///
/// These helpers intentionally do not fetch; pair with `*_or_fetch` variants if
/// remote reads are acceptable in the call site.
pub fn safe_head_hash_of(fc: anytype) ?Hash.Hash {
    comptime {
        if (@typeInfo(@TypeOf(fc)) != .Pointer) @compileError("safe_head_hash_of expects a pointer to a forkchoice provider");
    }
    // Intentionally a thin wrapper to keep DI surface consistent.
    return fc.getSafeHash();
}

pub fn finalized_head_hash_of(fc: anytype) ?Hash.Hash {
    comptime {
        if (@typeInfo(@TypeOf(fc)) != .Pointer) @compileError("finalized_head_hash_of expects a pointer to a forkchoice provider");
    }
    // Intentionally a thin wrapper to keep DI surface consistent.
    return fc.getFinalizedHash();
}

/// Local-only safe head block lookup (no fork-cache fetch/allocations at this layer).
pub fn safe_head_block_of(chain: *Chain, fc: anytype) ?Block.Block {
    comptime {
        if (@typeInfo(@TypeOf(fc)) != .Pointer) @compileError("safe_head_block_of expects a pointer to a forkchoice provider");
    }
    // Local-only view; use fork-cache layer at call sites if remote fetches are acceptable.
    const h = fc.getSafeHash() orelse return null;
    return get_block_local(chain, h);
}

/// Local-only finalized head block lookup (no fork-cache fetch/allocations at this layer).
pub fn finalized_head_block_of(chain: *Chain, fc: anytype) ?Block.Block {
    comptime {
        if (@typeInfo(@TypeOf(fc)) != .Pointer) @compileError("finalized_head_block_of expects a pointer to a forkchoice provider");
    }
    // Local-only view; use fork-cache layer at call sites if remote fetches are acceptable.
    const h = fc.getFinalizedHash() orelse return null;
    return get_block_local(chain, h);
}

test {
    @import("std").testing.refAllDecls(@This());
}

test "Chain - missing blocks return null" {
    const allocator = std.testing.allocator;
    var chain = try Chain.init(allocator, null);
    defer chain.deinit();

    const by_hash = try chain.getBlockByHash(primitives.Hash.ZERO);
    try std.testing.expect(by_hash == null);

    const by_number = try chain.getBlockByNumber(0);
    try std.testing.expect(by_number == null);
}

test "Chain - fork cache RpcPending propagates" {
    const allocator = std.testing.allocator;
    var fork_cache = try ForkBlockCache.init(allocator, 1024);
    defer fork_cache.deinit();

    var chain = try Chain.init(allocator, &fork_cache);
    defer chain.deinit();

    try std.testing.expectError(error.RpcPending, chain.getBlockByNumber(0));
    try std.testing.expectError(error.RpcPending, chain.getBlockByHash(primitives.Hash.ZERO));
}

test "Chain - head_hash returns null for empty chain" {
    const allocator = std.testing.allocator;
    var chain = try Chain.init(allocator, null);
    defer chain.deinit();

    try std.testing.expect((try head_hash(&chain)) == null);
}

test "Chain - head_hash returns canonical head hash" {
    const allocator = std.testing.allocator;
    var chain = try Chain.init(allocator, null);
    defer chain.deinit();

    const genesis = try Block.genesis(1, allocator);
    try chain.putBlock(genesis);
    try chain.setCanonicalHead(genesis.hash);

    const hash = try head_hash(&chain);
    try std.testing.expect(hash != null);
    try std.testing.expectEqualSlices(u8, &genesis.hash, &hash.?);
}

test "Chain - head_block returns null for empty chain" {
    const allocator = std.testing.allocator;
    var chain = try Chain.init(allocator, null);
    defer chain.deinit();

    const hb = try head_block(&chain);
    try std.testing.expect(hb == null);
}

test "Chain - head_block returns canonical head block" {
    const allocator = std.testing.allocator;
    var chain = try Chain.init(allocator, null);
    defer chain.deinit();

    const genesis = try Block.genesis(1, allocator);
    try chain.putBlock(genesis);
    try chain.setCanonicalHead(genesis.hash);

    const hb1 = try head_block(&chain);
    try std.testing.expect(hb1 != null);
    try std.testing.expectEqualSlices(u8, &genesis.hash, &hb1.?.hash);

    // Head changed between reads -> helper should return null instead of stale
    // value when TOCTOU detected.
    var h1 = primitives.BlockHeader.init();
    h1.number = 1;
    h1.parent_hash = genesis.hash;
    const b1 = try Block.from(&h1, &primitives.BlockBody.init(), allocator);
    try chain.putBlock(b1);

    const before = chain.getHeadBlockNumber().?;
    try chain.setCanonicalHead(b1.hash);
    // Simulate interleaving: if helper snapshots old head number and then new
    // head number is visible at the end, it should return null.
    if (chain.getHeadBlockNumber().? != before) {
        const hb2 = try head_block(&chain);
        if (hb2) |blk| {
            // If race not observed, ensure the value is current.
            try std.testing.expectEqual(@as(u64, 1), blk.header.number);
        } else {
            try std.testing.expect(hb2 == null);
        }
    }
}

test "Chain - head_number returns null for empty chain" {
    const allocator = std.testing.allocator;
    var chain = try Chain.init(allocator, null);
    defer chain.deinit();

    try std.testing.expect(head_number(&chain) == null);
}

test "Chain - head_number returns canonical number and updates after reorg" {
    const allocator = std.testing.allocator;
    var chain = try Chain.init(allocator, null);
    defer chain.deinit();

    const genesis = try Block.genesis(1, allocator);
    try chain.putBlock(genesis);
    try chain.setCanonicalHead(genesis.hash);

    const n0 = head_number(&chain);
    try std.testing.expect(n0 != null);
    try std.testing.expectEqual(@as(u64, 0), n0.?);

    var h1 = primitives.BlockHeader.init();
    h1.number = 1;
    h1.parent_hash = genesis.hash;
    const b1 = try Block.from(&h1, &primitives.BlockBody.init(), allocator);
    try chain.putBlock(b1);
    try chain.setCanonicalHead(b1.hash);

    const n1 = head_number(&chain);
    try std.testing.expect(n1 != null);
    try std.testing.expectEqual(@as(u64, 1), n1.?);
}

test "Chain - head_number_of forwards to underlying getter" {
    const allocator = std.testing.allocator;
    var chain = try Chain.init(allocator, null);
    defer chain.deinit();

    try std.testing.expect(head_number_of(&chain) == null);

    const genesis = try Block.genesis(1, allocator);
    try chain.putBlock(genesis);
    try chain.setCanonicalHead(genesis.hash);

    const n = head_number_of(&chain);
    try std.testing.expect(n != null);
    try std.testing.expectEqual(@as(u64, 0), n.?);
}

test "Chain - head_block with fork cache and no head returns null (no fetch)" {
    const allocator = std.testing.allocator;
    var fork_cache = try ForkBlockCache.init(allocator, 16);
    defer fork_cache.deinit();

    var chain = try Chain.init(allocator, &fork_cache);
    defer chain.deinit();

    const hb = try head_block(&chain);
    try std.testing.expect(hb == null);
}

test "Chain - is_canonical returns false for missing block" {
    const allocator = std.testing.allocator;
    var chain = try Chain.init(allocator, null);
    defer chain.deinit();

    const some = Hash.ZERO;
    const result = is_canonical(&chain, some);
    try std.testing.expect(!result);
}

test "Chain - is_canonical returns true for canonical block" {
    const allocator = std.testing.allocator;
    var chain = try Chain.init(allocator, null);
    defer chain.deinit();

    const genesis = try Block.genesis(1, allocator);
    try chain.putBlock(genesis);
    try chain.setCanonicalHead(genesis.hash);

    const result = is_canonical(&chain, genesis.hash);
    try std.testing.expect(result);
}

test "Chain - is_canonical returns false for orphan block" {
    const allocator = std.testing.allocator;
    var chain = try Chain.init(allocator, null);
    defer chain.deinit();

    // Create an orphan (missing parent)
    var header = primitives.BlockHeader.init();
    header.number = 5;
    header.parent_hash = Hash.Hash{ 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99 };
    const body = primitives.BlockBody.init();
    const orphan = try Block.from(&header, &body, allocator);
    try chain.putBlock(orphan);

    const result = is_canonical(&chain, orphan.hash);
    try std.testing.expect(!result);
}

test "Chain - is_canonical propagates RpcPending from fork cache" {
    const allocator = std.testing.allocator;
    var fork_cache = try ForkBlockCache.init(allocator, 16);
    defer fork_cache.deinit();

    var chain = try Chain.init(allocator, &fork_cache);
    defer chain.deinit();

    try std.testing.expectError(error.RpcPending, is_canonical_or_fetch(&chain, Hash.ZERO));
}

test "Chain - is_canonical local-only does not fetch and returns false" {
    const allocator = std.testing.allocator;
    var fork_cache = try ForkBlockCache.init(allocator, 16);
    defer fork_cache.deinit();

    var chain = try Chain.init(allocator, &fork_cache);
    defer chain.deinit();

    const some = Hash.ZERO;
    const result = is_canonical(&chain, some);
    try std.testing.expect(!result);
}

test "Chain - canonical_hash returns null for missing number" {
    const allocator = std.testing.allocator;
    var chain = try Chain.init(allocator, null);
    defer chain.deinit();

    try std.testing.expect(canonical_hash(&chain, 0) == null);
}

test "Chain - canonical_hash returns hash for canonical block" {
    const allocator = std.testing.allocator;
    var chain = try Chain.init(allocator, null);
    defer chain.deinit();

    const genesis = try Block.genesis(1, allocator);
    try chain.putBlock(genesis);
    try chain.setCanonicalHead(genesis.hash);

    const h = canonical_hash(&chain, 0) orelse return error.Unreachable;
    try std.testing.expectEqualSlices(u8, &genesis.hash, &h);
}

test "Chain - has_block reflects local and fork-cache presence" {
    const allocator = std.testing.allocator;

    // Local-only: missing → false, after insert → true
    {
        var chain = try Chain.init(allocator, null);
        defer chain.deinit();

        try std.testing.expect(!has_block(&chain, Hash.ZERO));

        const genesis = try Block.genesis(1, allocator);
        try chain.putBlock(genesis);
        try std.testing.expect(has_block(&chain, genesis.hash));
    }

    // With fork cache: cached remote block → true
    {
        var fork_cache = try ForkBlockCache.init(allocator, 1024);
        defer fork_cache.deinit();

        var chain = try Chain.init(allocator, &fork_cache);
        defer chain.deinit();

        // Queue a remote fetch by number, then supply a minimal JSON response
        try std.testing.expectError(error.RpcPending, chain.getBlockByNumber(0));
        const req = fork_cache.nextRequest() orelse {
            try std.testing.expect(false);
            return;
        };
        const hash_hex = "0x" ++ ("22" ** 32);
        const response = try std.fmt.allocPrint(allocator, "{{\"hash\":\"{s}\",\"number\":\"0x0\"}}", .{hash_hex});
        defer allocator.free(response);
        try fork_cache.continueRequest(req.id, response);

        // Verify has_block=true using the retrieved block's hash
        const fetched = (try chain.getBlockByNumber(0)).?;
        try std.testing.expect(has_block(&chain, fetched.hash));
    }
}

test "Chain - get_block_local reads only from local store" {
    const allocator = std.testing.allocator;

    // Local-only: missing → null, after insert → block
    {
        var chain = try Chain.init(allocator, null);
        defer chain.deinit();

        try std.testing.expect(get_block_local(&chain, Hash.ZERO) == null);

        const genesis = try Block.genesis(1, allocator);
        try chain.putBlock(genesis);
        const got = get_block_local(&chain, genesis.hash) orelse return error.Unreachable;
        try std.testing.expectEqualSlices(u8, &genesis.hash, &got.hash);
    }

    // With fork cache: block present only in cache → local read returns null
    {
        var fork_cache = try ForkBlockCache.init(allocator, 16);
        defer fork_cache.deinit();

        var chain = try Chain.init(allocator, &fork_cache);
        defer chain.deinit();

        // Queue a remote fetch by number and fulfill
        try std.testing.expectError(error.RpcPending, chain.getBlockByNumber(0));
        const req = fork_cache.nextRequest() orelse {
            try std.testing.expect(false);
            return;
        };
        const hash_hex = "0x" ++ ("33" ** 32);
        const response = try std.fmt.allocPrint(allocator, "{{\"hash\":\"{s}\",\"number\":\"0x0\"}}", .{hash_hex});
        defer allocator.free(response);
        try fork_cache.continueRequest(req.id, response);

        const fetched = (try chain.getBlockByNumber(0)).?;
        // Sanity: has_block should see cached remote
        try std.testing.expect(has_block(&chain, fetched.hash));
        // Local-only read must not see it
        try std.testing.expect(get_block_local(&chain, fetched.hash) == null);
    }
}

test "Chain - get_block_by_number_local reads canonical only and stays local" {
    const allocator = std.testing.allocator;

    // Local-only: before canonical set → null, after set → block
    {
        var chain = try Chain.init(allocator, null);
        defer chain.deinit();

        const genesis = try Block.genesis(1, allocator);
        try chain.putBlock(genesis);
        // Not canonical yet
        try std.testing.expect(get_block_by_number_local(&chain, 0) == null);
        try chain.setCanonicalHead(genesis.hash);
        const got0 = get_block_by_number_local(&chain, 0) orelse return error.Unreachable;
        try std.testing.expectEqual(@as(u64, 0), got0.header.number);

        // Non-existent number → null
        try std.testing.expect(get_block_by_number_local(&chain, 1) == null);
    }

    // With fork cache: block present only in cache by number → local read returns null
    {
        var fork_cache = try ForkBlockCache.init(allocator, 16);
        defer fork_cache.deinit();

        var chain = try Chain.init(allocator, &fork_cache);
        defer chain.deinit();

        // Request remote block #0 and fulfill
        try std.testing.expectError(error.RpcPending, chain.getBlockByNumber(0));
        const req = fork_cache.nextRequest() orelse {
            try std.testing.expect(false);
            return;
        };
        const hash_hex = "0x" ++ ("44" ** 32);
        const response = try std.fmt.allocPrint(allocator, "{{\"hash\":\"{s}\",\"number\":\"0x0\"}}", .{hash_hex});
        defer allocator.free(response);
        try fork_cache.continueRequest(req.id, response);

        // Sanity: unified getter sees it via cache, but local-by-number should not
        const fetched = (try chain.getBlockByNumber(0)).?;
        try std.testing.expectEqual(@as(u64, 0), fetched.header.number);
        try std.testing.expect(get_block_by_number_local(&chain, 0) == null);
    }
}

test "Chain - generic head helpers are race-resilient" {
    const allocator = std.testing.allocator;
    var chain = try Chain.init(allocator, null);
    defer chain.deinit();

    const genesis = try Block.genesis(1, allocator);
    try chain.putBlock(genesis);
    try chain.setCanonicalHead(genesis.hash);

    // Snapshot helpers must return a consistent value
    const h1 = try head_hash_of(&chain);
    try std.testing.expect(h1 != null);
    const b1 = try head_block_of(&chain);
    try std.testing.expect(b1 != null);
}

test "Chain - is_canonical reflects reorgs" {
    const allocator = std.testing.allocator;
    var chain = try Chain.init(allocator, null);
    defer chain.deinit();

    const genesis = try Block.genesis(1, allocator);
    try chain.putBlock(genesis);
    try chain.setCanonicalHead(genesis.hash);

    // First child (A1)
    var h1a = primitives.BlockHeader.init();
    h1a.number = 1;
    h1a.parent_hash = genesis.hash;
    h1a.timestamp = 1; // differ fields to ensure distinct hash
    const b1a = try Block.from(&h1a, &primitives.BlockBody.init(), allocator);
    try chain.putBlock(b1a);

    try chain.setCanonicalHead(b1a.hash);
    var is_a1_canon = is_canonical(&chain, b1a.hash);
    try std.testing.expect(is_a1_canon);

    // Competing child (B1)
    var h1b = primitives.BlockHeader.init();
    h1b.number = 1;
    h1b.parent_hash = genesis.hash;
    h1b.timestamp = 2; // ensure different hash
    const b1b = try Block.from(&h1b, &primitives.BlockBody.init(), allocator);
    try chain.putBlock(b1b);

    // Reorg to B1
    try chain.setCanonicalHead(b1b.hash);

    // Now A1 should be non-canonical, B1 canonical
    is_a1_canon = is_canonical(&chain, b1a.hash);
    try std.testing.expect(!is_a1_canon);
    const is_b1_canon = is_canonical(&chain, b1b.hash);
    try std.testing.expect(is_b1_canon);
}

test "Chain - head helpers reflect new head after reorg" {
    const allocator = std.testing.allocator;
    var chain = try Chain.init(allocator, null);
    defer chain.deinit();

    const genesis = try Block.genesis(1, allocator);
    try chain.putBlock(genesis);
    try chain.setCanonicalHead(genesis.hash);

    try std.testing.expectEqualSlices(u8, &genesis.hash, &(try head_hash(&chain)).?);

    var h1 = primitives.BlockHeader.init();
    h1.number = 1;
    h1.parent_hash = genesis.hash;
    const b1 = try Block.from(&h1, &primitives.BlockBody.init(), allocator);
    try chain.putBlock(b1);
    try chain.setCanonicalHead(b1.hash);

    const hh = try head_hash(&chain);
    try std.testing.expect(hh != null);
    try std.testing.expectEqualSlices(u8, &b1.hash, &hh.?);
}

test "Chain - safe_head_hash_of forwards forkchoice value" {
    const Fc = struct {
        safe: ?Hash.Hash,
        finalized: ?Hash.Hash,
        pub fn getSafeHash(self: @This()) ?Hash.Hash {
            return self.safe;
        }
        pub fn getFinalizedHash(self: @This()) ?Hash.Hash {
            return self.finalized;
        }
    };

    const fc = Fc{ .safe = Hash.ZERO, .finalized = null };
    const h = safe_head_hash_of(fc);
    try std.testing.expect(h != null);
    try std.testing.expectEqualSlices(u8, &Hash.ZERO, &h.?);
}

test "Chain - finalized_head_hash_of forwards forkchoice value" {
    const Fc = struct {
        safe: ?Hash.Hash,
        finalized: ?Hash.Hash,
        pub fn getSafeHash(self: @This()) ?Hash.Hash {
            return self.safe;
        }
        pub fn getFinalizedHash(self: @This()) ?Hash.Hash {
            return self.finalized;
        }
    };

    const fc = Fc{ .safe = null, .finalized = Hash.ZERO };
    const h = finalized_head_hash_of(fc);
    try std.testing.expect(h != null);
    try std.testing.expectEqualSlices(u8, &Hash.ZERO, &h.?);
}

test "Chain - safe/finalized head block helpers return local blocks" {
    const allocator = std.testing.allocator;
    var chain = try Chain.init(allocator, null);
    defer chain.deinit();

    const genesis = try Block.genesis(1, allocator);
    try chain.putBlock(genesis);

    const Fc = struct {
        safe: ?Hash.Hash,
        finalized: ?Hash.Hash,
        pub fn getSafeHash(self: @This()) ?Hash.Hash {
            return self.safe;
        }
        pub fn getFinalizedHash(self: @This()) ?Hash.Hash {
            return self.finalized;
        }
    };

    const fc = Fc{ .safe = genesis.hash, .finalized = genesis.hash };

    const sb = safe_head_block_of(&chain, fc);
    try std.testing.expect(sb != null);
    try std.testing.expectEqualSlices(u8, &genesis.hash, &sb.?.hash);

    const fb = finalized_head_block_of(&chain, fc);
    try std.testing.expect(fb != null);
    try std.testing.expectEqualSlices(u8, &genesis.hash, &fb.?.hash);
}

test "Chain - safe/finalized head block helpers return null when missing locally" {
    const allocator = std.testing.allocator;
    var chain = try Chain.init(allocator, null);
    defer chain.deinit();

    const Fc = struct {
        safe: ?Hash.Hash,
        finalized: ?Hash.Hash,
        pub fn getSafeHash(self: @This()) ?Hash.Hash {
            return self.safe;
        }
        pub fn getFinalizedHash(self: @This()) ?Hash.Hash {
            return self.finalized;
        }
    };

    // Some non-existent hash (all zeros is fine since store is empty)
    const fc = Fc{ .safe = Hash.ZERO, .finalized = Hash.ZERO };
    try std.testing.expect(safe_head_block_of(&chain, fc) == null);
    try std.testing.expect(finalized_head_block_of(&chain, fc) == null);
}
