/// Benchmarks for chain management (phase-4-blockchain).
///
/// Measures throughput and latency for:
///   1. Sequential block insertion (putBlock)
///   2. Canonical head updates (setCanonicalHead)
///
/// Run:
///   zig build bench-blockchain -Doptimize=ReleaseFast
///
/// Notes:
///   - Uses empty blocks (no transactions) to isolate chain-store overhead.
///   - Arena allocator is used for transaction-scoped memory.
const std = @import("std");
const chain_mod = @import("chain.zig");
const Chain = chain_mod.Chain;
const primitives = @import("primitives");
const Block = primitives.Block;
const BlockHeader = primitives.BlockHeader;
const BlockBody = primitives.BlockBody;
const Hash = primitives.Hash;
const bench_utils = @import("bench_utils");
const BenchResult = bench_utils.BenchResult;
const format_ns = bench_utils.format_ns;
const print_result = bench_utils.print_result;

/// Number of warmup iterations before timing.
const WARMUP_ITERS: usize = 2;
/// Number of timed iterations to average.
const BENCH_ITERS: usize = 3;

/// Benchmark sizes.
const SMALL_N: usize = 1_000;
const MEDIUM_N: usize = 5_000;
const LARGE_N: usize = 20_000;

fn make_result(name: []const u8, ops: usize, elapsed_ns: u64) BenchResult {
    const per_op = if (ops > 0) elapsed_ns / ops else 0;
    const ops_sec = if (elapsed_ns > 0) @as(f64, @floatFromInt(ops)) / (@as(f64, @floatFromInt(elapsed_ns)) / 1e9) else 0;
    return .{
        .name = name,
        .ops = ops,
        .elapsed_ns = elapsed_ns,
        .per_op_ns = per_op,
        .ops_per_sec = ops_sec,
    };
}

fn init_chain_with_blocks(
    n: usize,
    allocator: std.mem.Allocator,
    chain: *Chain,
) ![]Block.Block {
    chain.* = try Chain.init(allocator, null);
    return build_blocks(n, allocator);
}

fn process_blocks(chain: *Chain, blocks: []Block.Block) !void {
    for (blocks) |block| {
        try chain.putBlock(block);
        try chain.setCanonicalHead(block.hash);
    }
}

fn build_blocks(n: usize, allocator: std.mem.Allocator) ![]Block.Block {
    const blocks = try allocator.alloc(Block.Block, n);
    if (n == 0) return blocks;

    blocks[0] = try Block.genesis(1, allocator);
    var parent_hash = blocks[0].hash;

    var i: usize = 1;
    while (i < n) : (i += 1) {
        var header = BlockHeader.init();
        header.number = @intCast(i);
        header.parent_hash = parent_hash;
        header.ommers_hash = BlockHeader.EMPTY_OMMERS_HASH;
        header.transactions_root = BlockHeader.EMPTY_TRANSACTIONS_ROOT;
        header.receipts_root = BlockHeader.EMPTY_RECEIPTS_ROOT;

        const body = BlockBody.init();
        blocks[i] = try Block.from(&header, &body, allocator);
        parent_hash = blocks[i].hash;
    }
    return blocks;
}

/// Benchmark: process N blocks through Chain (putBlock + setCanonicalHead).
fn bench_block_processing(n: usize) !u64 {
    // Warmup
    for (0..WARMUP_ITERS) |_| {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const allocator = arena.allocator();

        var chain: Chain = undefined;
        const blocks = try init_chain_with_blocks(n, allocator, &chain);
        defer chain.deinit();

        try process_blocks(&chain, blocks);
    }

    // Timed
    var total_ns: u64 = 0;
    for (0..BENCH_ITERS) |_| {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const allocator = arena.allocator();

        var chain: Chain = undefined;
        const blocks = try init_chain_with_blocks(n, allocator, &chain);
        defer chain.deinit();

        var timer = try std.time.Timer.start();
        try process_blocks(&chain, blocks);
        total_ns += timer.read();
    }
    return total_ns / BENCH_ITERS;
}

// ============================================================================
// Main benchmark entry point
// ============================================================================

/// Benchmark entry point.
pub fn main() !void {
    if (@import("builtin").is_test) return;
    std.debug.print("\n", .{});
    std.debug.print("=" ** 100 ++ "\n", .{});
    std.debug.print("  Guillotine Phase-4 Blockchain Benchmarks (Chain Management)\n", .{});
    std.debug.print("  Warmup: {d} iters, Timed: {d} iters (averaged)\n", .{ WARMUP_ITERS, BENCH_ITERS });
    std.debug.print("=" ** 100 ++ "\n\n", .{});

    // -- Block processing --
    std.debug.print("--- Block Processing (putBlock + setCanonicalHead) ---\n", .{});
    var large_result: ?BenchResult = null;
    const sizes = [_]struct { n: usize, name: []const u8 }{
        .{ .n = SMALL_N, .name = "block processing (1K blocks)" },
        .{ .n = MEDIUM_N, .name = "block processing (5K blocks)" },
        .{ .n = LARGE_N, .name = "block processing (20K blocks)" },
    };
    for (sizes) |s| {
        const elapsed = try bench_block_processing(s.n);
        const result = make_result(s.name, s.n, elapsed);
        print_result(result);
        if (s.n == LARGE_N) {
            large_result = result;
        }
    }
    std.debug.print("\n", .{});

    // -- Throughput analysis --
    std.debug.print("--- Throughput Analysis ---\n", .{});
    if (large_result) |result| {
        const blocks_per_sec = if (result.elapsed_ns > 0)
            @as(f64, @floatFromInt(result.ops)) / (@as(f64, @floatFromInt(result.elapsed_ns)) / 1e9)
        else
            0.0;
        const effective_mgas = blocks_per_sec * 15.0;

        std.debug.print("  Block processing time:     {s}\n", .{&format_ns(result.elapsed_ns)});
        std.debug.print("  Block throughput:           {d:.0} blocks/s\n", .{blocks_per_sec});
        std.debug.print("  Effective MGas/s (15M gas):  {d:.0} MGas/s\n", .{effective_mgas});
        std.debug.print("  Nethermind target:           700 MGas/s (full client)\n", .{});
        std.debug.print("  Note: This measures chain-store overhead only (no tx execution).\n", .{});
    }
    std.debug.print("\n", .{});

    std.debug.print("=" ** 100 ++ "\n", .{});
    std.debug.print("  Notes:\n", .{});
    std.debug.print("  - Blocks are empty and pre-built; timing isolates putBlock/setCanonicalHead.\n", .{});
    std.debug.print("  - Fork cache is disabled (local-only chain).\n", .{});
    std.debug.print("  - Arena allocator scopes all per-iteration allocations.\n", .{});
    std.debug.print("=" ** 100 ++ "\n\n", .{});
}

test "bench main entrypoint" {
    try main();
}
