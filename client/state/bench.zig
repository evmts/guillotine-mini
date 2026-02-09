/// Benchmarks for the World State Journal (phase-2-world-state).
///
/// Measures throughput and latency for:
///   1. Journal append: insert N state change entries
///   2. Snapshot creation: O(1) snapshot (position-based)
///   3. Restore: truncate back to a snapshot position
///   4. Restore with just_cache preservation: slow path with re-append
///   5. Commit: finalize entries with callback sweep
///   6. Mixed snapshot/restore cycles (simulating nested EVM calls)
///   7. Simulated block processing: 200 txs with nested calls
///
/// Run:
///   zig build bench-state                         # Debug mode
///   zig build bench-state -Doptimize=ReleaseFast  # Release mode (accurate numbers)
///
/// Target: Nethermind processes ~700 MGas/s. The journal must handle state changes
/// for ~200 txs/block with nested CALL depths up to 1024, each requiring
/// snapshot/restore. Journal overhead must be negligible compared to EVM execution.
const std = @import("std");
const journal_mod = @import("journal.zig");
const Journal = journal_mod.Journal;
const ChangeTag = journal_mod.ChangeTag;
const Entry = journal_mod.Entry;
const bench_utils = @import("../bench_utils.zig");
const format_ns = bench_utils.format_ns;
const print_result = bench_utils.print_result;

/// Number of iterations for each benchmark tier.
const TINY_N: usize = 100;
const SMALL_N: usize = 1_000;
const MEDIUM_N: usize = 10_000;
const LARGE_N: usize = 100_000;
const XLARGE_N: usize = 1_000_000;

/// Number of warmup iterations before timing.
const WARMUP_ITERS: usize = 3;
/// Number of timed iterations to average.
const BENCH_ITERS: usize = 10;

/// We use u128 as a value stand-in (same perf characteristics as a larger struct for copy).
/// In practice, journal values are AccountState or u256 storage values.
const ValueType = u128;

/// Use u64 keys (simulating Address or StorageSlotKey hashes) and u128 values.
/// In practice, journal keys are Address (20 bytes) or (Address, u256) pairs.
/// We use u64 as a compact proxy since the journal itself is key-type-agnostic.
const JournalU64 = Journal(u64, ValueType);
const EntryU64 = Entry(u64, ValueType);

// ============================================================================
// Benchmark implementations
// ============================================================================

/// Benchmark 1: Sequential append (simulating state changes during block processing)
fn bench_append(n: usize) u64 {
    // Warmup
    for (0..WARMUP_ITERS) |_| {
        var j = JournalU64.init(std.heap.page_allocator);
        for (0..n) |i| {
            _ = j.append(.{ .key = @intCast(i), .value = @intCast(i * 100), .tag = .update }) catch unreachable;
        }
        j.deinit();
    }

    // Timed
    var total_ns: u64 = 0;
    for (0..BENCH_ITERS) |_| {
        var j = JournalU64.init(std.heap.page_allocator);
        var timer = std.time.Timer.start() catch unreachable;
        for (0..n) |i| {
            _ = j.append(.{ .key = @intCast(i), .value = @intCast(i * 100), .tag = .update }) catch unreachable;
        }
        total_ns += timer.read();
        j.deinit();
    }
    return total_ns / BENCH_ITERS;
}

/// Benchmark 2: Snapshot creation (should be O(1))
fn bench_snapshot(n: usize) u64 {
    var j = JournalU64.init(std.heap.page_allocator);
    defer j.deinit();

    // Pre-populate
    for (0..n) |i| {
        _ = j.append(.{ .key = @intCast(i), .value = @intCast(i), .tag = .update }) catch unreachable;
    }

    // Warmup
    for (0..WARMUP_ITERS) |_| {
        _ = j.take_snapshot();
    }

    // Timed: take N snapshots
    var timer = std.time.Timer.start() catch unreachable;
    for (0..n) |_| {
        _ = j.take_snapshot();
    }
    return timer.read();
}

/// Benchmark 3: Restore (fast path, no just_cache entries)
fn bench_restore_fast_path(n: usize) u64 {
    // Warmup
    for (0..WARMUP_ITERS) |_| {
        var j = JournalU64.init(std.heap.page_allocator);
        for (0..n) |i| {
            _ = j.append(.{ .key = @intCast(i), .value = @intCast(i), .tag = .update }) catch unreachable;
        }
        const snap = j.take_snapshot();
        // Add entries to be restored
        for (0..100) |i| {
            _ = j.append(.{ .key = @intCast(n + i), .value = @intCast(i), .tag = .update }) catch unreachable;
        }
        j.restore(snap, null) catch unreachable;
        j.deinit();
    }

    // Timed: repeatedly append entries and restore
    var total_ns: u64 = 0;
    for (0..BENCH_ITERS) |_| {
        var j = JournalU64.init(std.heap.page_allocator);
        // Build base state
        for (0..100) |i| {
            _ = j.append(.{ .key = @intCast(i), .value = @intCast(i), .tag = .update }) catch unreachable;
        }
        const snap = j.take_snapshot();

        var timer = std.time.Timer.start() catch unreachable;
        for (0..n) |iter| {
            // Append some entries
            for (0..10) |i| {
                _ = j.append(.{ .key = @intCast(100 + iter * 10 + i), .value = @intCast(i), .tag = .update }) catch unreachable;
            }
            // Restore to snapshot
            j.restore(snap, null) catch unreachable;
        }
        total_ns += timer.read();
        j.deinit();
    }
    return total_ns / BENCH_ITERS;
}

/// Benchmark 4: Restore (slow path, with just_cache entries to preserve)
fn bench_restore_slow_path(n: usize) u64 {
    var total_ns: u64 = 0;
    for (0..BENCH_ITERS) |_| {
        var j = JournalU64.init(std.heap.page_allocator);
        // Build base state
        for (0..100) |i| {
            _ = j.append(.{ .key = @intCast(i), .value = @intCast(i), .tag = .update }) catch unreachable;
        }
        const snap = j.take_snapshot();

        var timer = std.time.Timer.start() catch unreachable;
        for (0..n) |iter| {
            // Append mix of just_cache and mutations (25% just_cache)
            for (0..8) |i| {
                const tag: ChangeTag = if (i % 4 == 0) .just_cache else .update;
                _ = j.append(.{ .key = @intCast(100 + iter * 8 + i), .value = @intCast(i), .tag = tag }) catch unreachable;
            }
            // Restore — triggers slow path (just_cache re-append)
            j.restore(snap, null) catch unreachable;
        }
        total_ns += timer.read();
        j.deinit();
    }
    return total_ns / BENCH_ITERS;
}

/// Benchmark 5: Commit with callback
fn bench_commit(n: usize) u64 {
    const Counter = struct {
        var count: usize = 0;
        fn cb(_: *const EntryU64) void {
            count += 1;
        }
    };

    var total_ns: u64 = 0;
    for (0..BENCH_ITERS) |_| {
        var j = JournalU64.init(std.heap.page_allocator);
        // Pre-populate
        for (0..n) |i| {
            _ = j.append(.{ .key = @intCast(i), .value = @intCast(i * 100), .tag = .update }) catch unreachable;
        }

        Counter.count = 0;
        var timer = std.time.Timer.start() catch unreachable;
        j.commit(JournalU64.empty_snapshot, &Counter.cb);
        total_ns += timer.read();
        j.deinit();
    }
    return total_ns / BENCH_ITERS;
}

/// Benchmark 6: Nested snapshot/restore cycles (simulating EVM nested CALL stack)
/// Each "call" takes a snapshot, does some state changes, then either commits or reverts.
fn bench_nested_calls(depth: usize) u64 {
    var total_ns: u64 = 0;
    for (0..BENCH_ITERS) |_| {
        var j = JournalU64.init(std.heap.page_allocator);

        var timer = std.time.Timer.start() catch unreachable;

        // Simulate nested CALLs: snapshot → mutations → snapshot → mutations → ... → restore chain
        var snapshots: [1024]usize = undefined;
        const actual_depth = @min(depth, 1024);

        for (0..actual_depth) |d| {
            snapshots[d] = j.take_snapshot();
            // Each call frame does ~5 state changes
            for (0..5) |i| {
                _ = j.append(.{ .key = @intCast(d * 5 + i), .value = @intCast(d * 100 + i), .tag = .update }) catch unreachable;
            }
        }

        // Unwind: restore deepest half (simulating reverts), commit rest
        var d: usize = actual_depth;
        while (d > actual_depth / 2) {
            d -= 1;
            j.restore(snapshots[d], null) catch unreachable;
        }
        // Commit remaining
        if (d > 0) {
            j.commit(snapshots[0], null);
        }

        total_ns += timer.read();
        j.deinit();
    }
    return total_ns / BENCH_ITERS;
}

/// Benchmark 7: Simulated block processing
/// Simulates processing 200 transactions, each with:
///   - 1 account change (balance, nonce)
///   - ~5 storage writes
///   - ~2 nested calls (some revert)
///   - Snapshot at tx start, commit at tx end
fn bench_block_processing(_: usize) u64 {
    const txs_per_block: usize = 200;
    const storage_writes_per_tx: usize = 5;
    const nested_calls_per_tx: usize = 2;
    const changes_per_nested_call: usize = 3;

    var total_ns: u64 = 0;
    for (0..BENCH_ITERS) |_| {
        var j = JournalU64.init(std.heap.page_allocator);

        var timer = std.time.Timer.start() catch unreachable;

        for (0..txs_per_block) |tx_idx| {
            const tx_snap = j.take_snapshot();

            // Account changes (balance + nonce)
            _ = j.append(.{ .key = @intCast(tx_idx), .value = @intCast(tx_idx * 1000), .tag = .update }) catch unreachable;
            _ = j.append(.{ .key = @intCast(tx_idx + 10000), .value = @intCast(tx_idx), .tag = .update }) catch unreachable;

            // Storage writes
            for (0..storage_writes_per_tx) |s| {
                _ = j.append(.{ .key = @intCast(tx_idx * 100 + s + 20000), .value = @intCast(s * 42), .tag = .update }) catch unreachable;
            }

            // Nested calls
            for (0..nested_calls_per_tx) |call_idx| {
                const call_snap = j.take_snapshot();

                // Nested call changes
                for (0..changes_per_nested_call) |c| {
                    _ = j.append(.{
                        .key = @intCast(tx_idx * 1000 + call_idx * 100 + c + 50000),
                        .value = @intCast(c),
                        .tag = .update,
                    }) catch unreachable;
                }

                // 30% of nested calls revert
                if ((tx_idx * 7 + call_idx * 13) % 10 < 3) {
                    j.restore(call_snap, null) catch unreachable;
                }
            }

            // Commit transaction
            j.commit(tx_snap, null);
        }

        total_ns += timer.read();
        j.deinit();
    }
    return total_ns / BENCH_ITERS;
}

/// Benchmark 8: Arena allocator pattern — measure overhead of allocating
/// journal within an arena vs page_allocator directly.
fn bench_arena_pattern(n: usize) u64 {
    var total_ns: u64 = 0;
    for (0..BENCH_ITERS) |_| {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

        var timer = std.time.Timer.start() catch unreachable;
        var j = JournalU64.init(arena.allocator());
        for (0..n) |i| {
            _ = j.append(.{ .key = @intCast(i), .value = @intCast(i), .tag = .update }) catch unreachable;
        }
        // Arena frees everything at once (simulating transaction boundary)
        arena.deinit();
        total_ns += timer.read();
    }
    return total_ns / BENCH_ITERS;
}

/// Benchmark 9: Memory usage measurement
fn bench_memory_usage(n: usize) struct { elapsed_ns: u64, peak_bytes: usize } {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .enable_memory_limit = true }){};
    defer _ = gpa.deinit();

    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    var j = JournalU64.init(arena.allocator());

    var timer = std.time.Timer.start() catch unreachable;
    for (0..n) |i| {
        _ = j.append(.{ .key = @intCast(i), .value = @intCast(i * 100), .tag = .update }) catch unreachable;
    }
    const elapsed = timer.read();
    const total_allocated = gpa.total_requested_bytes;

    arena.deinit();

    return .{
        .elapsed_ns = elapsed,
        .peak_bytes = total_allocated,
    };
}

/// Benchmark 10: Restore with on_revert callback (simulating undo side-effects)
fn bench_restore_with_callback(n: usize) u64 {
    const Counter = struct {
        var count: usize = 0;
        fn cb(_: *const EntryU64) void {
            count += 1;
        }
    };

    var total_ns: u64 = 0;
    for (0..BENCH_ITERS) |_| {
        var j = JournalU64.init(std.heap.page_allocator);
        // Build base state
        for (0..100) |i| {
            _ = j.append(.{ .key = @intCast(i), .value = @intCast(i), .tag = .update }) catch unreachable;
        }
        const snap = j.take_snapshot();

        Counter.count = 0;
        var timer = std.time.Timer.start() catch unreachable;
        for (0..n) |iter| {
            // Append entries
            for (0..10) |i| {
                _ = j.append(.{ .key = @intCast(100 + iter * 10 + i), .value = @intCast(i), .tag = .update }) catch unreachable;
            }
            // Restore with callback
            j.restore(snap, &Counter.cb) catch unreachable;
        }
        total_ns += timer.read();
        j.deinit();
    }
    return total_ns / BENCH_ITERS;
}

// ============================================================================
// Main benchmark entry point
// ============================================================================

/// Benchmark entry point.
pub fn main() !void {
    std.debug.print("\n", .{});
    std.debug.print("=" ** 100 ++ "\n", .{});
    std.debug.print("  Guillotine Phase-2 World State Benchmarks (Journal + Snapshot/Restore)\n", .{});
    std.debug.print("  Entry size: {d} bytes (u64 key + u128 value + tag)\n", .{@sizeOf(EntryU64)});
    std.debug.print("  Warmup: {d} iters, Timed: {d} iters (averaged)\n", .{ WARMUP_ITERS, BENCH_ITERS });
    std.debug.print("=" ** 100 ++ "\n\n", .{});

    // -- Core operations --
    std.debug.print("--- Journal Append ---\n", .{});
    {
        const sizes = [_]struct { n: usize, name: []const u8 }{
            .{ .n = SMALL_N, .name = "append (1K entries)" },
            .{ .n = MEDIUM_N, .name = "append (10K entries)" },
            .{ .n = LARGE_N, .name = "append (100K entries)" },
            .{ .n = XLARGE_N, .name = "append (1M entries)" },
        };
        for (sizes) |s| {
            const elapsed = bench_append(s.n);
            const per_op = if (s.n > 0) elapsed / s.n else 0;
            print_result(.{
                .name = s.name,
                .ops = s.n,
                .elapsed_ns = elapsed,
                .per_op_ns = per_op,
                .ops_per_sec = if (elapsed > 0) @as(f64, @floatFromInt(s.n)) / (@as(f64, @floatFromInt(elapsed)) / 1e9) else 0,
            });
        }
    }
    std.debug.print("\n", .{});

    // -- Snapshot (O(1)) --
    std.debug.print("--- Snapshot (O(1) expected) ---\n", .{});
    {
        const sizes = [_]struct { n: usize, name: []const u8 }{
            .{ .n = SMALL_N, .name = "take_snapshot (1K calls, 1K entries)" },
            .{ .n = MEDIUM_N, .name = "take_snapshot (10K calls, 10K entries)" },
            .{ .n = LARGE_N, .name = "take_snapshot (100K calls, 100K entries)" },
            .{ .n = XLARGE_N, .name = "take_snapshot (1M calls, 1M entries)" },
        };
        for (sizes) |s| {
            const elapsed = bench_snapshot(s.n);
            const per_op = if (s.n > 0) elapsed / s.n else 0;
            print_result(.{
                .name = s.name,
                .ops = s.n,
                .elapsed_ns = elapsed,
                .per_op_ns = per_op,
                .ops_per_sec = if (elapsed > 0) @as(f64, @floatFromInt(s.n)) / (@as(f64, @floatFromInt(elapsed)) / 1e9) else 0,
            });
        }
    }
    std.debug.print("\n", .{});

    // -- Restore (fast path) --
    std.debug.print("--- Restore (fast path, no just_cache) ---\n", .{});
    {
        const sizes = [_]struct { n: usize, name: []const u8 }{
            .{ .n = SMALL_N, .name = "restore fast (1K cycles, 10 entries each)" },
            .{ .n = MEDIUM_N, .name = "restore fast (10K cycles, 10 entries each)" },
            .{ .n = LARGE_N, .name = "restore fast (100K cycles, 10 entries each)" },
        };
        for (sizes) |s| {
            const elapsed = bench_restore_fast_path(s.n);
            const per_op = if (s.n > 0) elapsed / s.n else 0;
            print_result(.{
                .name = s.name,
                .ops = s.n,
                .elapsed_ns = elapsed,
                .per_op_ns = per_op,
                .ops_per_sec = if (elapsed > 0) @as(f64, @floatFromInt(s.n)) / (@as(f64, @floatFromInt(elapsed)) / 1e9) else 0,
            });
        }
    }
    std.debug.print("\n", .{});

    // -- Restore (slow path with just_cache) --
    // NOTE: The slow path accumulates just_cache entries across restore cycles
    // (they survive restore by design). This means repeated restore cycles cause
    // the journal to grow linearly, causing O(n*k) total work where n = cycles
    // and k = just_cache entries per cycle. We cap at 10K to keep bench reasonable.
    std.debug.print("--- Restore (slow path, with just_cache preservation) ---\n", .{});
    {
        const sizes = [_]struct { n: usize, name: []const u8 }{
            .{ .n = TINY_N, .name = "restore slow (100 cycles, 8 entries, 25% cache)" },
            .{ .n = SMALL_N, .name = "restore slow (1K cycles, 8 entries, 25% cache)" },
            .{ .n = 5_000, .name = "restore slow (5K cycles, 8 entries, 25% cache)" },
        };
        for (sizes) |s| {
            const elapsed = bench_restore_slow_path(s.n);
            const per_op = if (s.n > 0) elapsed / s.n else 0;
            print_result(.{
                .name = s.name,
                .ops = s.n,
                .elapsed_ns = elapsed,
                .per_op_ns = per_op,
                .ops_per_sec = if (elapsed > 0) @as(f64, @floatFromInt(s.n)) / (@as(f64, @floatFromInt(elapsed)) / 1e9) else 0,
            });
        }
    }
    std.debug.print("\n", .{});

    // -- Restore with callback --
    std.debug.print("--- Restore (with on_revert callback) ---\n", .{});
    {
        const sizes = [_]struct { n: usize, name: []const u8 }{
            .{ .n = SMALL_N, .name = "restore+callback (1K cycles, 10 entries each)" },
            .{ .n = MEDIUM_N, .name = "restore+callback (10K cycles, 10 entries each)" },
        };
        for (sizes) |s| {
            const elapsed = bench_restore_with_callback(s.n);
            const per_op = if (s.n > 0) elapsed / s.n else 0;
            print_result(.{
                .name = s.name,
                .ops = s.n,
                .elapsed_ns = elapsed,
                .per_op_ns = per_op,
                .ops_per_sec = if (elapsed > 0) @as(f64, @floatFromInt(s.n)) / (@as(f64, @floatFromInt(elapsed)) / 1e9) else 0,
            });
        }
    }
    std.debug.print("\n", .{});

    // -- Commit --
    std.debug.print("--- Commit (with callback) ---\n", .{});
    {
        const sizes = [_]struct { n: usize, name: []const u8 }{
            .{ .n = SMALL_N, .name = "commit (1K entries)" },
            .{ .n = MEDIUM_N, .name = "commit (10K entries)" },
            .{ .n = LARGE_N, .name = "commit (100K entries)" },
        };
        for (sizes) |s| {
            const elapsed = bench_commit(s.n);
            const per_op = if (s.n > 0) elapsed / s.n else 0;
            print_result(.{
                .name = s.name,
                .ops = s.n,
                .elapsed_ns = elapsed,
                .per_op_ns = per_op,
                .ops_per_sec = if (elapsed > 0) @as(f64, @floatFromInt(s.n)) / (@as(f64, @floatFromInt(elapsed)) / 1e9) else 0,
            });
        }
    }
    std.debug.print("\n", .{});

    // -- Nested calls (EVM CALL stack simulation) --
    std.debug.print("--- Nested CALL Simulation (snapshot + 5 changes per depth) ---\n", .{});
    {
        const depths = [_]struct { depth: usize, name: []const u8 }{
            .{ .depth = 4, .name = "nested calls (depth=4, typical)" },
            .{ .depth = 16, .name = "nested calls (depth=16, moderate)" },
            .{ .depth = 64, .name = "nested calls (depth=64, deep)" },
            .{ .depth = 256, .name = "nested calls (depth=256, very deep)" },
            .{ .depth = 1024, .name = "nested calls (depth=1024, max EVM)" },
        };
        for (depths) |d| {
            const elapsed = bench_nested_calls(d.depth);
            const per_depth = if (d.depth > 0) elapsed / d.depth else 0;
            print_result(.{
                .name = d.name,
                .ops = d.depth,
                .elapsed_ns = elapsed,
                .per_op_ns = per_depth,
                .ops_per_sec = if (elapsed > 0) @as(f64, @floatFromInt(d.depth)) / (@as(f64, @floatFromInt(elapsed)) / 1e9) else 0,
            });
        }
    }
    std.debug.print("\n", .{});

    // -- Arena allocator pattern --
    std.debug.print("--- Arena Allocator (transaction-scoped) ---\n", .{});
    {
        const sizes = [_]struct { n: usize, name: []const u8 }{
            .{ .n = SMALL_N, .name = "arena append+free (1K entries)" },
            .{ .n = MEDIUM_N, .name = "arena append+free (10K entries)" },
            .{ .n = LARGE_N, .name = "arena append+free (100K entries)" },
        };
        for (sizes) |s| {
            const elapsed = bench_arena_pattern(s.n);
            const per_op = if (s.n > 0) elapsed / s.n else 0;
            print_result(.{
                .name = s.name,
                .ops = s.n,
                .elapsed_ns = elapsed,
                .per_op_ns = per_op,
                .ops_per_sec = if (elapsed > 0) @as(f64, @floatFromInt(s.n)) / (@as(f64, @floatFromInt(elapsed)) / 1e9) else 0,
            });
        }
    }
    std.debug.print("\n", .{});

    // -- Memory usage --
    std.debug.print("--- Memory Usage ---\n", .{});
    {
        const entry_size = @sizeOf(EntryU64);
        std.debug.print("  Entry struct size: {d} bytes\n", .{entry_size});

        const sizes = [_]usize{ 100, 1_000, 10_000, 100_000 };
        for (sizes) |n| {
            const result = bench_memory_usage(n);
            const bytes_per_entry = if (n > 0) result.peak_bytes / n else 0;
            const theoretical = entry_size * n;
            const overhead_pct = if (theoretical > 0)
                (@as(f64, @floatFromInt(result.peak_bytes)) / @as(f64, @floatFromInt(theoretical)) - 1.0) * 100.0
            else
                0.0;
            std.debug.print("  {d:>8} entries: {d:>10} bytes ({d} bytes/entry, {d:.1}%% overhead vs theoretical {d})\n", .{
                n,
                result.peak_bytes,
                bytes_per_entry,
                overhead_pct,
                entry_size,
            });
        }
    }
    std.debug.print("\n", .{});

    // -- Block processing simulation --
    std.debug.print("--- Block Processing Simulation ---\n", .{});
    std.debug.print("  (200 txs/block, 7 changes/tx + 2 nested calls * 3 changes, 30%% revert)\n", .{});
    {
        const elapsed = bench_block_processing(0);
        const elapsed_str = format_ns(elapsed);
        const blocks_per_sec = if (elapsed > 0)
            1_000_000_000.0 / @as(f64, @floatFromInt(elapsed))
        else
            0.0;
        std.debug.print("  Block journal time:        {s}\n", .{&elapsed_str});
        std.debug.print("  Block throughput (journal): {d:.0} blocks/s\n", .{blocks_per_sec});
    }
    std.debug.print("\n", .{});

    // -- Throughput analysis vs Nethermind target --
    std.debug.print("--- Throughput Analysis ---\n", .{});
    {
        // Target: 700 MGas/s, block = 15M gas → ~46.7 blocks/s
        // Journal overhead should be negligible compared to EVM execution
        const block_elapsed = bench_block_processing(0);
        const blocks_per_sec = if (block_elapsed > 0)
            1_000_000_000.0 / @as(f64, @floatFromInt(block_elapsed))
        else
            0.0;
        const effective_mgas = blocks_per_sec * 15.0;

        std.debug.print("  Block journal time:          {s}\n", .{&format_ns(block_elapsed)});
        std.debug.print("  Block throughput (journal):   {d:.0} blocks/s\n", .{blocks_per_sec});
        std.debug.print("  Effective MGas/s (journal):   {d:.0} MGas/s\n", .{effective_mgas});
        std.debug.print("  Nethermind target:            700 MGas/s (full client)\n", .{});
        std.debug.print("  Required blocks/s for target: ~47 blocks/s\n", .{});

        // Journal should be <1% of total budget → need >4700 blocks/s
        const comfortable = blocks_per_sec >= 4700.0;
        const meets_target = blocks_per_sec >= 47.0;

        if (comfortable) {
            std.debug.print("  Status:                       PASS - negligible overhead (<1%% of budget)\n", .{});
        } else if (meets_target) {
            std.debug.print("  Status:                       PASS - meets target but journal overhead significant\n", .{});
        } else {
            std.debug.print("  Status:                       FAIL - journal alone cannot keep up!\n", .{});
        }

        // Total journal ops per block
        // 200 txs * (2 account + 5 storage + 2*3 nested + 1 snapshot + 1 commit) = ~200 * 16 = 3200 journal ops
        const journal_ops_per_block: usize = 200 * 16;
        const journal_ops_per_sec = blocks_per_sec * @as(f64, @floatFromInt(journal_ops_per_block));
        std.debug.print("  Journal ops/block:            ~{d}\n", .{journal_ops_per_block});
        std.debug.print("  Journal ops/sec:              {d:.0} ({d:.2} M ops/s)\n", .{ journal_ops_per_sec, journal_ops_per_sec / 1e6 });
    }

    std.debug.print("\n" ++ "=" ** 100 ++ "\n", .{});
    std.debug.print("  Notes:\n", .{});
    std.debug.print("  - Journal is append-only (ArrayListUnmanaged) — O(1) amortized append\n", .{});
    std.debug.print("  - Snapshots are O(1) — just record position index\n", .{});
    std.debug.print("  - Restore fast path is O(k) where k = entries to remove (shrinkRetainingCapacity)\n", .{});
    std.debug.print("  - Restore slow path allocates scratch buffer for just_cache entries\n", .{});
    std.debug.print("  - Arena allocator ensures no per-entry heap fragmentation\n", .{});
    std.debug.print("  - In production, journal key types will be Address (20 bytes) and\n", .{});
    std.debug.print("    StorageSlotKey (20+32 bytes) — slightly larger but same perf characteristics\n", .{});
    std.debug.print("=" ** 100 ++ "\n\n", .{});
}
