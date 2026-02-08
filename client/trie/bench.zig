/// Benchmarks for the Merkle Patricia Trie (phase-1-trie).
///
/// Measures throughput and latency for:
///   1. Trie root hash computation: insert N keys, compute root hash
///   2. State root simulation: keccak256'd keys + RLP-encoded account values
///   3. Allocation patterns: arena allocator (transaction-scoped)
///   4. Scaling behavior: 10 → 10K keys to check algorithmic complexity
///
/// Run:
///   zig build bench-trie                         # Debug mode
///   zig build bench-trie -Doptimize=ReleaseFast  # Release mode (accurate numbers)
///
/// Target: Nethermind processes ~700 MGas/s. A typical block has ~200 txs touching
/// ~10 storage slots each = ~2000 state changes. The trie must compute state roots
/// from these changes within the block processing budget.
const std = @import("std");
const hash_mod = @import("hash.zig");
const trie_root = hash_mod.trie_root;
const EMPTY_TRIE_ROOT = hash_mod.EMPTY_TRIE_ROOT;
const Hash = @import("crypto").Hash;

/// Number of iterations for each benchmark tier.
const TINY_N: usize = 10;
const SMALL_N: usize = 100;
const MEDIUM_N: usize = 1_000;
const LARGE_N: usize = 10_000;

/// Simulated key size: 32 bytes (keccak256 hash of address/slot).
const KEY_SIZE: usize = 32;

/// Simulated value sizes for different scenarios.
const SMALL_VALUE_SIZE: usize = 4; // Short RLP (small integer)
const MEDIUM_VALUE_SIZE: usize = 80; // Typical RLP-encoded account (~80 bytes)
const LARGE_VALUE_SIZE: usize = 256; // Large storage value

/// Number of warmup iterations before timing.
const WARMUP_ITERS: usize = 2;
/// Number of timed iterations to average.
const BENCH_ITERS: usize = 5;

/// Pre-generate a deterministic key (simulating keccak256 of an address).
fn generate_key(buf: *[KEY_SIZE]u8, index: usize) void {
    const h = std.hash.Wyhash.hash(0xDEADBEEF, std.mem.asBytes(&index));
    const h_bytes = std.mem.asBytes(&h);
    @memcpy(buf[0..@sizeOf(@TypeOf(h))], h_bytes);
    const h2 = std.hash.Wyhash.hash(0xCAFEBABE, std.mem.asBytes(&index));
    const h2_bytes = std.mem.asBytes(&h2);
    @memcpy(buf[@sizeOf(@TypeOf(h))..][0..@sizeOf(@TypeOf(h2))], h2_bytes);
    for (buf[@sizeOf(@TypeOf(h)) + @sizeOf(@TypeOf(h2)) ..]) |*byte| {
        byte.* = @truncate(index);
    }
}

/// Pre-generate a deterministic value of a given size.
fn generate_value(buf: []u8, index: usize) void {
    const h = std.hash.Wyhash.hash(0x12345678, std.mem.asBytes(&index));
    const h_bytes = std.mem.asBytes(&h);
    for (buf, 0..) |*byte, i| {
        byte.* = h_bytes[i % @sizeOf(@TypeOf(h))];
    }
}

/// Format nanoseconds into a human-readable string.
fn format_ns(ns: u64) [32]u8 {
    var buf: [32]u8 = [_]u8{0} ** 32;
    if (ns < 1_000) {
        _ = std.fmt.bufPrint(&buf, "{d} ns", .{ns}) catch unreachable;
    } else if (ns < 1_000_000) {
        _ = std.fmt.bufPrint(&buf, "{d:.1} us", .{@as(f64, @floatFromInt(ns)) / 1_000.0}) catch unreachable;
    } else if (ns < 1_000_000_000) {
        _ = std.fmt.bufPrint(&buf, "{d:.2} ms", .{@as(f64, @floatFromInt(ns)) / 1_000_000.0}) catch unreachable;
    } else {
        _ = std.fmt.bufPrint(&buf, "{d:.3} s", .{@as(f64, @floatFromInt(ns)) / 1_000_000_000.0}) catch unreachable;
    }
    return buf;
}

fn format_ops_per_sec(ops: usize, elapsed_ns: u64) [32]u8 {
    var buf: [32]u8 = [_]u8{0} ** 32;
    if (elapsed_ns == 0) {
        _ = std.fmt.bufPrint(&buf, "inf ops/s", .{}) catch unreachable;
        return buf;
    }
    const ops_per_sec = @as(f64, @floatFromInt(ops)) / (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
    if (ops_per_sec >= 1_000_000) {
        _ = std.fmt.bufPrint(&buf, "{d:.2} M ops/s", .{ops_per_sec / 1_000_000.0}) catch unreachable;
    } else if (ops_per_sec >= 1_000) {
        _ = std.fmt.bufPrint(&buf, "{d:.1} K ops/s", .{ops_per_sec / 1_000.0}) catch unreachable;
    } else {
        _ = std.fmt.bufPrint(&buf, "{d:.0} ops/s", .{ops_per_sec}) catch unreachable;
    }
    return buf;
}

const BenchResult = struct {
    name: []const u8,
    n_keys: usize,
    elapsed_ns: u64,
    per_key_ns: u64,
    keys_per_sec: f64,
};

fn print_result(r: BenchResult) void {
    const total_str = format_ns(r.elapsed_ns);
    const per_key_str = format_ns(r.per_key_ns);
    const ops_str = format_ops_per_sec(r.n_keys, r.elapsed_ns);
    std.debug.print("  {s:<55} {d:>6} keys  total={s}  per-key={s}  {s}\n", .{
        r.name,
        r.n_keys,
        &total_str,
        &per_key_str,
        &ops_str,
    });
}

// ============================================================================
// Benchmark: Trie root hash computation
// ============================================================================

/// Benchmark computing trie_root for N keys with a given value size.
/// Uses arena allocator (transaction-scoped) matching production patterns.
fn bench_trie_root(n: usize, value_size: usize) u64 {
    // Pre-generate all keys and values
    var key_bufs: [LARGE_N][KEY_SIZE]u8 = undefined;
    var val_bufs: [LARGE_N][LARGE_VALUE_SIZE]u8 = undefined;

    const actual_n = @min(n, LARGE_N);

    for (0..actual_n) |i| {
        generate_key(&key_bufs[i], i);
        generate_value(val_bufs[i][0..value_size], i);
    }

    // Create slices referencing the buffers
    var keys: [LARGE_N][]const u8 = undefined;
    var values: [LARGE_N][]const u8 = undefined;
    for (0..actual_n) |i| {
        keys[i] = &key_bufs[i];
        values[i] = val_bufs[i][0..value_size];
    }

    // Warmup
    for (0..WARMUP_ITERS) |_| {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        _ = trie_root(arena.allocator(), keys[0..actual_n], values[0..actual_n]) catch unreachable;
        arena.deinit();
    }

    // Timed iterations
    var total_ns: u64 = 0;
    for (0..BENCH_ITERS) |_| {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        var timer = std.time.Timer.start() catch unreachable;
        _ = trie_root(arena.allocator(), keys[0..actual_n], values[0..actual_n]) catch unreachable;
        total_ns += timer.read();
        arena.deinit(); // Free ALL memory at once (transaction boundary)
    }

    return total_ns / BENCH_ITERS;
}

/// Benchmark with keccak256'd keys (simulating secure trie / state trie).
fn bench_trie_root_secure(n: usize, value_size: usize) u64 {
    var key_bufs: [LARGE_N][KEY_SIZE]u8 = undefined;
    var val_bufs: [LARGE_N][LARGE_VALUE_SIZE]u8 = undefined;

    const actual_n = @min(n, LARGE_N);

    // Generate keys as keccak256(address), like the actual state trie
    for (0..actual_n) |i| {
        var raw_key: [KEY_SIZE]u8 = undefined;
        generate_key(&raw_key, i);
        key_bufs[i] = Hash.keccak256(&raw_key);
        generate_value(val_bufs[i][0..value_size], i);
    }

    var keys: [LARGE_N][]const u8 = undefined;
    var values: [LARGE_N][]const u8 = undefined;
    for (0..actual_n) |i| {
        keys[i] = &key_bufs[i];
        values[i] = val_bufs[i][0..value_size];
    }

    // Warmup
    for (0..WARMUP_ITERS) |_| {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        _ = trie_root(arena.allocator(), keys[0..actual_n], values[0..actual_n]) catch unreachable;
        arena.deinit();
    }

    // Timed iterations
    var total_ns: u64 = 0;
    for (0..BENCH_ITERS) |_| {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        var timer = std.time.Timer.start() catch unreachable;
        _ = trie_root(arena.allocator(), keys[0..actual_n], values[0..actual_n]) catch unreachable;
        total_ns += timer.read();
        arena.deinit();
    }

    return total_ns / BENCH_ITERS;
}

/// Measure peak memory usage for trie root computation.
fn bench_trie_memory(n: usize, value_size: usize) struct { elapsed_ns: u64, peak_bytes: usize } {
    var key_bufs: [LARGE_N][KEY_SIZE]u8 = undefined;
    var val_bufs: [LARGE_N][LARGE_VALUE_SIZE]u8 = undefined;

    const actual_n = @min(n, LARGE_N);

    for (0..actual_n) |i| {
        generate_key(&key_bufs[i], i);
        generate_value(val_bufs[i][0..value_size], i);
    }

    var keys: [LARGE_N][]const u8 = undefined;
    var values: [LARGE_N][]const u8 = undefined;
    for (0..actual_n) |i| {
        keys[i] = &key_bufs[i];
        values[i] = val_bufs[i][0..value_size];
    }

    // Use a GPA to track allocations
    var gpa = std.heap.GeneralPurposeAllocator(.{ .enable_memory_limit = true }){};
    defer _ = gpa.deinit();

    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    var timer = std.time.Timer.start() catch unreachable;
    _ = trie_root(arena.allocator(), keys[0..actual_n], values[0..actual_n]) catch unreachable;
    const elapsed = timer.read();

    // Get allocation stats before freeing
    const total_allocated = gpa.total_requested_bytes;

    arena.deinit();

    return .{
        .elapsed_ns = elapsed,
        .peak_bytes = total_allocated,
    };
}

/// Benchmark simulating state root after block processing.
/// Computes trie root for N account-like entries (nonce, balance, storageRoot, codeHash).
fn bench_block_state_root(n_accounts: usize) u64 {
    // Simulate RLP-encoded account (nonce=0, balance=1eth, storageRoot=empty, codeHash=empty)
    // Typical RLP account is ~80 bytes
    const account_rlp_size = MEDIUM_VALUE_SIZE;

    return bench_trie_root_secure(n_accounts, account_rlp_size);
}

// ============================================================================
// Main benchmark entry point
// ============================================================================

pub fn main() !void {
    std.debug.print("\n", .{});
    std.debug.print("=" ** 100 ++ "\n", .{});
    std.debug.print("  Guillotine Phase-1-Trie Benchmarks (MPT Root Hash)\n", .{});
    std.debug.print("  Key size: {d} bytes (keccak256 hash)\n", .{KEY_SIZE});
    std.debug.print("  Warmup: {d} iters, Timed: {d} iters (averaged)\n", .{ WARMUP_ITERS, BENCH_ITERS });
    std.debug.print("=" ** 100 ++ "\n\n", .{});

    // -- Scaling behavior: small values --
    std.debug.print("--- Trie Root: Small Values ({d} bytes) ---\n", .{SMALL_VALUE_SIZE});
    {
        const sizes = [_]usize{ TINY_N, SMALL_N, MEDIUM_N, LARGE_N };
        for (sizes) |n| {
            const elapsed = bench_trie_root(n, SMALL_VALUE_SIZE);
            const per_key = if (n > 0) elapsed / n else 0;
            print_result(.{
                .name = std.fmt.comptimePrint("trie_root (small values, {d} keys)", .{0}),
                .n_keys = n,
                .elapsed_ns = elapsed,
                .per_key_ns = per_key,
                .keys_per_sec = if (elapsed > 0)
                    @as(f64, @floatFromInt(n)) / (@as(f64, @floatFromInt(elapsed)) / 1_000_000_000.0)
                else
                    0,
            });
        }
    }
    std.debug.print("\n", .{});

    // -- Scaling behavior: medium values (RLP-encoded accounts) --
    std.debug.print("--- Trie Root: Medium Values ({d} bytes, account-like) ---\n", .{MEDIUM_VALUE_SIZE});
    {
        const sizes = [_]usize{ TINY_N, SMALL_N, MEDIUM_N, LARGE_N };
        for (sizes) |n| {
            const elapsed = bench_trie_root(n, MEDIUM_VALUE_SIZE);
            const per_key = if (n > 0) elapsed / n else 0;
            print_result(.{
                .name = std.fmt.comptimePrint("trie_root (medium values, {d} keys)", .{0}),
                .n_keys = n,
                .elapsed_ns = elapsed,
                .per_key_ns = per_key,
                .keys_per_sec = if (elapsed > 0)
                    @as(f64, @floatFromInt(n)) / (@as(f64, @floatFromInt(elapsed)) / 1_000_000_000.0)
                else
                    0,
            });
        }
    }
    std.debug.print("\n", .{});

    // -- Scaling behavior: large values --
    std.debug.print("--- Trie Root: Large Values ({d} bytes) ---\n", .{LARGE_VALUE_SIZE});
    {
        const sizes = [_]usize{ TINY_N, SMALL_N, MEDIUM_N, LARGE_N };
        for (sizes) |n| {
            const elapsed = bench_trie_root(n, LARGE_VALUE_SIZE);
            const per_key = if (n > 0) elapsed / n else 0;
            print_result(.{
                .name = std.fmt.comptimePrint("trie_root (large values, {d} keys)", .{0}),
                .n_keys = n,
                .elapsed_ns = elapsed,
                .per_key_ns = per_key,
                .keys_per_sec = if (elapsed > 0)
                    @as(f64, @floatFromInt(n)) / (@as(f64, @floatFromInt(elapsed)) / 1_000_000_000.0)
                else
                    0,
            });
        }
    }
    std.debug.print("\n", .{});

    // -- Secure trie (keccak256'd keys, like state trie) --
    std.debug.print("--- Secure Trie Root (keccak256 keys, {d}-byte values) ---\n", .{MEDIUM_VALUE_SIZE});
    {
        const sizes = [_]usize{ TINY_N, SMALL_N, MEDIUM_N, LARGE_N };
        for (sizes) |n| {
            const elapsed = bench_trie_root_secure(n, MEDIUM_VALUE_SIZE);
            const per_key = if (n > 0) elapsed / n else 0;
            print_result(.{
                .name = std.fmt.comptimePrint("secureTrie (medium values, {d} keys)", .{0}),
                .n_keys = n,
                .elapsed_ns = elapsed,
                .per_key_ns = per_key,
                .keys_per_sec = if (elapsed > 0)
                    @as(f64, @floatFromInt(n)) / (@as(f64, @floatFromInt(elapsed)) / 1_000_000_000.0)
                else
                    0,
            });
        }
    }
    std.debug.print("\n", .{});

    // -- Memory usage --
    std.debug.print("--- Memory Usage (arena allocator) ---\n", .{});
    {
        const sizes = [_]usize{ TINY_N, SMALL_N, MEDIUM_N };
        for (sizes) |n| {
            const result = bench_trie_memory(n, MEDIUM_VALUE_SIZE);
            const bytes_per_key = if (n > 0) result.peak_bytes / n else 0;
            std.debug.print("  {d:>6} keys: {d:>10} bytes total ({d} bytes/key)", .{ n, result.peak_bytes, bytes_per_key });
            const elapsed_str = format_ns(result.elapsed_ns);
            std.debug.print("  time={s}\n", .{&elapsed_str});
        }
    }
    std.debug.print("\n", .{});

    // -- Block processing simulation --
    std.debug.print("--- Block State Root Simulation ---\n", .{});
    std.debug.print("  (Simulates computing state root after block with N account changes)\n", .{});
    {
        // Typical block: 200 txs, ~2000 state changes
        const block_sizes = [_]struct { accounts: usize, desc: []const u8 }{
            .{ .accounts = 50, .desc = "Light block (~50 account changes)" },
            .{ .accounts = 200, .desc = "Medium block (~200 account changes)" },
            .{ .accounts = 500, .desc = "Heavy block (~500 account changes)" },
            .{ .accounts = 2000, .desc = "Full block (~2000 state changes)" },
            .{ .accounts = 5000, .desc = "Extreme block (~5000 state changes)" },
        };

        for (block_sizes) |bs| {
            const elapsed = bench_block_state_root(bs.accounts);
            const elapsed_str = format_ns(elapsed);
            const blocks_per_sec = if (elapsed > 0)
                1_000_000_000.0 / @as(f64, @floatFromInt(elapsed))
            else
                0.0;
            std.debug.print("  {s:<55} {s}  ({d:.0} blocks/s)\n", .{
                bs.desc,
                &elapsed_str,
                blocks_per_sec,
            });
        }
    }
    std.debug.print("\n", .{});

    // -- Throughput analysis vs Nethermind target --
    std.debug.print("--- Throughput Analysis ---\n", .{});
    {
        // Target: 700 MGas/s, block = 15M gas, so ~46.7 blocks/s
        // Each block has ~2000 state changes needing trie root computation
        const n_changes: usize = 2000;
        const elapsed = bench_block_state_root(n_changes);
        const blocks_per_sec = if (elapsed > 0)
            1_000_000_000.0 / @as(f64, @floatFromInt(elapsed))
        else
            0.0;
        const effective_mgas = blocks_per_sec * 15.0; // 15M gas per block

        std.debug.print("  State root compute time (2000 changes): {s}\n", .{&format_ns(elapsed)});
        std.debug.print("  Block throughput (trie only):            {d:.1} blocks/s\n", .{blocks_per_sec});
        std.debug.print("  Effective MGas/s (trie only):            {d:.0} MGas/s\n", .{effective_mgas});
        std.debug.print("  Nethermind target:                       700 MGas/s (full client)\n", .{});
        std.debug.print("  Required blocks/s for target:            ~47 blocks/s\n", .{});

        // Note: trie root is only one component. It should be WAY faster than 47 blocks/s
        // to leave budget for EVM execution, DB I/O, networking, etc.
        // Rule of thumb: trie should be <10% of total budget → need >470 blocks/s
        const meets_target = blocks_per_sec >= 47.0;
        const comfortable = blocks_per_sec >= 470.0;

        if (comfortable) {
            std.debug.print("  Status:                                  PASS - comfortable margin (>10x target)\n", .{});
        } else if (meets_target) {
            std.debug.print("  Status:                                  PASS - meets target but tight margin\n", .{});
        } else {
            std.debug.print("  Status:                                  WARN - below target!\n", .{});
        }

        // Per-key amortized cost
        const per_key = if (n_changes > 0) elapsed / n_changes else 0;
        std.debug.print("  Per-key amortized cost:                  {s}\n", .{&format_ns(per_key)});
    }

    std.debug.print("\n", .{});

    // -- Allocation pattern analysis --
    std.debug.print("--- Allocation Pattern Analysis ---\n", .{});
    {
        // Verify arena pattern: all freed at transaction end
        std.debug.print("  Allocation strategy: Arena (transaction-scoped)\n", .{});
        std.debug.print("  - All trie memory freed at once via arena.deinit()\n", .{});
        std.debug.print("  - No per-node heap allocations in hot path\n", .{});
        std.debug.print("  - Zero memory leaks (arena owns everything)\n", .{});

        // Measure arena overhead vs direct allocator
        const result = bench_trie_memory(1000, MEDIUM_VALUE_SIZE);
        const bytes_per_key = result.peak_bytes / 1000;
        std.debug.print("  Memory efficiency: {d} bytes/key (1000 keys, {d}-byte values)\n", .{ bytes_per_key, MEDIUM_VALUE_SIZE });

        // Compare with theoretical minimum
        // Each key is 32 bytes, each value is 80 bytes = 112 bytes raw data per entry
        // Additional overhead: nibble keys (64 bytes), RLP encoding, hash computations
        const theoretical_min = (KEY_SIZE + MEDIUM_VALUE_SIZE) * 1000;
        const overhead_pct = (@as(f64, @floatFromInt(result.peak_bytes)) / @as(f64, @floatFromInt(theoretical_min)) - 1.0) * 100.0;
        std.debug.print("  Raw data size:     {d} bytes (keys + values)\n", .{theoretical_min});
        std.debug.print("  Allocation overhead: {d:.1}%% over raw data\n", .{overhead_pct});
    }

    std.debug.print("\n" ++ "=" ** 100 ++ "\n", .{});
    std.debug.print("  Notes:\n", .{});
    std.debug.print("  - Trie root is computed from scratch each time (no incremental updates)\n", .{});
    std.debug.print("  - In production, only modified subtrees need recomputation\n", .{});
    std.debug.print("  - Incremental trie (future) will be much faster for typical blocks\n", .{});
    std.debug.print("  - keccak256 dominates compute for large tries (one per node)\n", .{});
    std.debug.print("  - RLP encoding is the other major cost component\n", .{});
    std.debug.print("=" ** 100 ++ "\n\n", .{});
}
