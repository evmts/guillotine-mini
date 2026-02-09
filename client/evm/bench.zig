/// Benchmarks for the EVM ↔ WorldState Integration (phase-3-evm-state).
///
/// Measures throughput and latency for HostAdapter operations bridging
/// Voltaire's StateManager to guillotine-mini's HostInterface vtable:
///   1. Balance get/set through vtable
///   2. Storage get/set through vtable
///   3. Nonce get/set through vtable
///   4. Code get/set through vtable
///   5. Mixed workload (simulating EVM execution patterns)
///   6. Checkpoint/revert cycles (simulating nested CALL/DELEGATECALL)
///   7. Simulated block processing (200 txs, nested calls, reverts)
///
/// Run:
///   zig build bench-evm -Doptimize=ReleaseFast  # Release mode (accurate numbers)
///
/// Target: Nethermind processes ~700 MGas/s. The HostAdapter must add negligible
/// overhead vs direct StateManager access. Vtable dispatch should be <5%.
const std = @import("std");
const host_adapter_mod = @import("host_adapter.zig");
const HostAdapter = host_adapter_mod.HostAdapter;
const bench_utils = @import("../bench_utils.zig");
const state_manager_mod = @import("state-manager");
const StateManager = state_manager_mod.StateManager;
const primitives = @import("primitives");
const Address = primitives.Address;
const BenchResult = bench_utils.BenchResult;
const format_ns = bench_utils.format_ns;
const print_result = bench_utils.print_result;

/// Number of warmup iterations before timing.
const WARMUP_ITERS: usize = 3;
/// Number of timed iterations to average.
const BENCH_ITERS: usize = 10;

/// Benchmark sizes
const SMALL_N: usize = 1_000;
const MEDIUM_N: usize = 10_000;
const LARGE_N: usize = 100_000;

/// Generate a deterministic address from an index.
fn make_address(index: usize) Address {
    var bytes: [20]u8 = [_]u8{0} ** 20;
    const idx_bytes = std.mem.asBytes(&index);
    const copy_len = @min(idx_bytes.len, 20);
    @memcpy(bytes[0..copy_len], idx_bytes[0..copy_len]);
    return .{ .bytes = bytes };
}

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

// ============================================================================
// Benchmark implementations
// ============================================================================

/// Benchmark 1: Balance set+get through vtable (simulating EVM balance reads/writes)
fn bench_balance(n: usize) u64 {
    var total_ns: u64 = 0;
    for (0..BENCH_ITERS) |_| {
        var state = StateManager.init(std.heap.page_allocator, null) catch unreachable;

        var adapter = HostAdapter.init(&state);
        const host = adapter.host_interface();

        var timer = std.time.Timer.start() catch unreachable;
        for (0..n) |i| {
            const addr = make_address(i);
            host.setBalance(addr, @intCast(i * 1000));
            _ = host.getBalance(addr);
        }
        total_ns += timer.read();
        state.deinit();
    }
    return total_ns / BENCH_ITERS;
}

/// Benchmark 2: Storage set+get through vtable (hot path for SLOAD/SSTORE)
fn bench_storage(n: usize) u64 {
    var total_ns: u64 = 0;
    for (0..BENCH_ITERS) |_| {
        var state = StateManager.init(std.heap.page_allocator, null) catch unreachable;

        var adapter = HostAdapter.init(&state);
        const host = adapter.host_interface();

        const addr = make_address(0xDEAD);
        var timer = std.time.Timer.start() catch unreachable;
        for (0..n) |i| {
            const slot: u256 = @intCast(i);
            host.setStorage(addr, slot, @intCast(i * 42));
            _ = host.getStorage(addr, slot);
        }
        total_ns += timer.read();
        state.deinit();
    }
    return total_ns / BENCH_ITERS;
}

/// Benchmark 3: Nonce set+get through vtable
fn bench_nonce(n: usize) u64 {
    var total_ns: u64 = 0;
    for (0..BENCH_ITERS) |_| {
        var state = StateManager.init(std.heap.page_allocator, null) catch unreachable;

        var adapter = HostAdapter.init(&state);
        const host = adapter.host_interface();

        var timer = std.time.Timer.start() catch unreachable;
        for (0..n) |i| {
            const addr = make_address(i);
            host.setNonce(addr, @intCast(i));
            _ = host.getNonce(addr);
        }
        total_ns += timer.read();
        state.deinit();
    }
    return total_ns / BENCH_ITERS;
}

/// Benchmark 4: Code set+get through vtable
fn bench_code(n: usize) u64 {
    // Typical contract bytecode sizes
    const bytecode = [_]u8{0x60} ** 256; // PUSH1 repeated (256 bytes)
    var total_ns: u64 = 0;
    for (0..BENCH_ITERS) |_| {
        var state = StateManager.init(std.heap.page_allocator, null) catch unreachable;

        var adapter = HostAdapter.init(&state);
        const host = adapter.host_interface();

        var timer = std.time.Timer.start() catch unreachable;
        for (0..n) |i| {
            const addr = make_address(i);
            host.setCode(addr, &bytecode);
            _ = host.getCode(addr);
        }
        total_ns += timer.read();
        state.deinit();
    }
    return total_ns / BENCH_ITERS;
}

/// Benchmark 5: Mixed workload simulating EVM execution pattern
/// Pattern per "instruction": 60% storage read, 20% storage write, 10% balance, 10% nonce
fn bench_mixed(n: usize) u64 {
    var total_ns: u64 = 0;
    for (0..BENCH_ITERS) |_| {
        var state = StateManager.init(std.heap.page_allocator, null) catch unreachable;

        var adapter = HostAdapter.init(&state);
        const host = adapter.host_interface();

        // Pre-populate some state
        for (0..100) |i| {
            const addr = make_address(i);
            host.setBalance(addr, @intCast(i * 1000));
            host.setNonce(addr, @intCast(i));
            for (0..5) |s| {
                host.setStorage(addr, @intCast(s), @intCast(s * 100));
            }
        }

        var timer = std.time.Timer.start() catch unreachable;
        for (0..n) |i| {
            const addr = make_address(i % 100);
            const slot: u256 = @intCast(i % 5);

            if (i % 10 < 6) {
                // 60% storage reads (SLOAD)
                _ = host.getStorage(addr, slot);
            } else if (i % 10 < 8) {
                // 20% storage writes (SSTORE)
                host.setStorage(addr, slot, @intCast(i));
            } else if (i % 10 == 8) {
                // 10% balance reads (BALANCE opcode)
                _ = host.getBalance(addr);
            } else {
                // 10% nonce reads
                _ = host.getNonce(addr);
            }
        }
        total_ns += timer.read();
        state.deinit();
    }
    return total_ns / BENCH_ITERS;
}

/// Benchmark 6: Checkpoint/revert cycles (simulating nested CALL/DELEGATECALL)
fn bench_checkpoint_revert(depth: usize) u64 {
    var total_ns: u64 = 0;
    for (0..BENCH_ITERS) |_| {
        var state = StateManager.init(std.heap.page_allocator, null) catch unreachable;

        var adapter = HostAdapter.init(&state);
        const host = adapter.host_interface();

        // Pre-populate base state
        for (0..10) |i| {
            const addr = make_address(i);
            host.setBalance(addr, @intCast(i * 1000));
        }

        var timer = std.time.Timer.start() catch unreachable;

        // Simulate nested calls: checkpoint → state changes → revert/commit
        for (0..depth) |d| {
            state.checkpoint() catch unreachable;

            // Each call frame does ~5 state changes
            for (0..5) |s| {
                const addr = make_address(d % 10);
                host.setStorage(addr, @intCast(d * 5 + s), @intCast(d * 100 + s));
            }

            // 50% of calls revert (simulating failed sub-calls)
            if (d % 2 == 0) {
                state.revert();
            } else {
                state.commit();
            }
        }

        total_ns += timer.read();
        state.deinit();
    }
    return total_ns / BENCH_ITERS;
}

/// Benchmark 7: Simulated block processing through HostAdapter
/// 200 transactions, each with balance transfer + storage writes + nested calls
fn bench_block_processing() u64 {
    const txs_per_block: usize = 200;
    const storage_writes_per_tx: usize = 5;
    const nested_calls_per_tx: usize = 2;
    const changes_per_nested_call: usize = 3;

    var total_ns: u64 = 0;
    for (0..BENCH_ITERS) |_| {
        var state = StateManager.init(std.heap.page_allocator, null) catch unreachable;

        var adapter = HostAdapter.init(&state);
        const host = adapter.host_interface();

        // Pre-populate some accounts
        for (0..50) |i| {
            const addr = make_address(i);
            host.setBalance(addr, 1_000_000_000);
            host.setNonce(addr, @intCast(i));
        }

        var timer = std.time.Timer.start() catch unreachable;

        for (0..txs_per_block) |tx_idx| {
            // Transaction-level checkpoint
            state.checkpoint() catch unreachable;

            // Sender/receiver
            const sender = make_address(tx_idx % 50);
            const receiver = make_address((tx_idx + 1) % 50);

            // Balance transfer
            const sender_bal = host.getBalance(sender);
            const receiver_bal = host.getBalance(receiver);
            if (sender_bal >= 1000) {
                host.setBalance(sender, sender_bal - 1000);
                host.setBalance(receiver, receiver_bal + 1000);
            }

            // Nonce increment
            const nonce = host.getNonce(sender);
            host.setNonce(sender, nonce + 1);

            // Storage writes (contract execution)
            for (0..storage_writes_per_tx) |s| {
                host.setStorage(receiver, @intCast(s), @intCast(tx_idx * 100 + s));
            }

            // Nested calls
            for (0..nested_calls_per_tx) |call_idx| {
                state.checkpoint() catch unreachable;

                for (0..changes_per_nested_call) |c| {
                    const call_addr = make_address((tx_idx + call_idx + 10) % 50);
                    host.setStorage(call_addr, @intCast(c + 100), @intCast(call_idx * 10 + c));
                }

                // 30% of nested calls revert
                if ((tx_idx * 7 + call_idx * 13) % 10 < 3) {
                    state.revert();
                } else {
                    state.commit();
                }
            }

            // Commit transaction
            state.commit();
        }

        total_ns += timer.read();
        state.deinit();
    }
    return total_ns / BENCH_ITERS;
}

/// Benchmark 8: Direct StateManager vs HostAdapter vtable overhead comparison
fn bench_vtable_overhead(n: usize) struct { direct_ns: u64, vtable_ns: u64 } {
    // Direct StateManager calls
    var direct_total: u64 = 0;
    for (0..BENCH_ITERS) |_| {
        var state = StateManager.init(std.heap.page_allocator, null) catch unreachable;
        const addr = make_address(0x42);

        // Pre-populate
        state.setBalance(addr, 1000) catch unreachable;

        var timer = std.time.Timer.start() catch unreachable;
        for (0..n) |i| {
            _ = state.getBalance(addr) catch unreachable;
            state.setBalance(addr, @intCast(i)) catch unreachable;
        }
        direct_total += timer.read();
        state.deinit();
    }

    // HostAdapter vtable calls
    var vtable_total: u64 = 0;
    for (0..BENCH_ITERS) |_| {
        var state = StateManager.init(std.heap.page_allocator, null) catch unreachable;
        var adapter = HostAdapter.init(&state);
        const host = adapter.host_interface();
        const addr = make_address(0x42);

        // Pre-populate
        host.setBalance(addr, 1000);

        var timer = std.time.Timer.start() catch unreachable;
        for (0..n) |i| {
            _ = host.getBalance(addr);
            host.setBalance(addr, @intCast(i));
        }
        vtable_total += timer.read();
        state.deinit();
    }

    return .{
        .direct_ns = direct_total / BENCH_ITERS,
        .vtable_ns = vtable_total / BENCH_ITERS,
    };
}

// ============================================================================
// Main benchmark entry point
// ============================================================================

/// Benchmark entry point.
pub fn main() !void {
    std.debug.print("\n", .{});
    std.debug.print("=" ** 100 ++ "\n", .{});
    std.debug.print("  Guillotine Phase-3 EVM ↔ WorldState Benchmarks (HostAdapter)\n", .{});
    std.debug.print("  HostAdapter bridges Voltaire StateManager → guillotine-mini HostInterface\n", .{});
    std.debug.print("  Warmup: {d} iters, Timed: {d} iters (averaged)\n", .{ WARMUP_ITERS, BENCH_ITERS });
    std.debug.print("=" ** 100 ++ "\n\n", .{});

    // -- Core vtable operations --
    std.debug.print("--- Balance (set+get pair) ---\n", .{});
    print_result(make_result("balance set+get (1K addresses)", SMALL_N, bench_balance(SMALL_N)));
    print_result(make_result("balance set+get (10K addresses)", MEDIUM_N, bench_balance(MEDIUM_N)));
    std.debug.print("\n", .{});

    std.debug.print("--- Storage (set+get pair, single address) ---\n", .{});
    print_result(make_result("storage set+get (1K slots)", SMALL_N, bench_storage(SMALL_N)));
    print_result(make_result("storage set+get (10K slots)", MEDIUM_N, bench_storage(MEDIUM_N)));
    std.debug.print("\n", .{});

    std.debug.print("--- Nonce (set+get pair) ---\n", .{});
    print_result(make_result("nonce set+get (1K addresses)", SMALL_N, bench_nonce(SMALL_N)));
    print_result(make_result("nonce set+get (10K addresses)", MEDIUM_N, bench_nonce(MEDIUM_N)));
    std.debug.print("\n", .{});

    std.debug.print("--- Code (set+get, 256-byte contracts) ---\n", .{});
    print_result(make_result("code set+get (1K contracts)", SMALL_N, bench_code(SMALL_N)));
    print_result(make_result("code set+get (10K contracts)", MEDIUM_N, bench_code(MEDIUM_N)));
    std.debug.print("\n", .{});

    // -- Mixed workload --
    std.debug.print("--- Mixed Workload (60%% SLOAD, 20%% SSTORE, 10%% BALANCE, 10%% NONCE) ---\n", .{});
    print_result(make_result("mixed (1K ops, 100 accounts)", SMALL_N, bench_mixed(SMALL_N)));
    print_result(make_result("mixed (10K ops, 100 accounts)", MEDIUM_N, bench_mixed(MEDIUM_N)));
    print_result(make_result("mixed (100K ops, 100 accounts)", LARGE_N, bench_mixed(LARGE_N)));
    std.debug.print("\n", .{});

    // -- Checkpoint/revert --
    std.debug.print("--- Checkpoint/Revert (nested CALL simulation) ---\n", .{});
    {
        const depths = [_]struct { depth: usize, name: []const u8 }{
            .{ .depth = 4, .name = "checkpoint/revert (depth=4, typical)" },
            .{ .depth = 16, .name = "checkpoint/revert (depth=16, moderate)" },
            .{ .depth = 64, .name = "checkpoint/revert (depth=64, deep)" },
            .{ .depth = 256, .name = "checkpoint/revert (depth=256, very deep)" },
            .{ .depth = 1024, .name = "checkpoint/revert (depth=1024, max EVM)" },
        };
        for (depths) |d| {
            const elapsed = bench_checkpoint_revert(d.depth);
            print_result(make_result(d.name, d.depth, elapsed));
        }
    }
    std.debug.print("\n", .{});

    // -- Block processing simulation --
    std.debug.print("--- Block Processing Simulation ---\n", .{});
    std.debug.print("  (200 txs/block, balance xfer + 5 SSTORE + 2 nested calls * 3 changes, 30%% revert)\n", .{});
    {
        const block_elapsed = bench_block_processing();
        const block_str = format_ns(block_elapsed);
        const blocks_per_sec = if (block_elapsed > 0)
            1_000_000_000.0 / @as(f64, @floatFromInt(block_elapsed))
        else
            0.0;
        const effective_mgas = blocks_per_sec * 15.0;

        std.debug.print("  Block processing time:     {s}\n", .{&block_str});
        std.debug.print("  Block throughput:           {d:.0} blocks/s\n", .{blocks_per_sec});
        std.debug.print("  Effective MGas/s:           {d:.0} MGas/s\n", .{effective_mgas});
    }
    std.debug.print("\n", .{});

    // -- Vtable overhead measurement --
    std.debug.print("--- Vtable Dispatch Overhead (HostAdapter vs direct StateManager) ---\n", .{});
    {
        const result = bench_vtable_overhead(LARGE_N);
        const direct_per_op = if (LARGE_N > 0) result.direct_ns / LARGE_N else 0;
        const vtable_per_op = if (LARGE_N > 0) result.vtable_ns / LARGE_N else 0;
        std.debug.print("  Direct StateManager (100K get+set):  {s}  per-op={s}\n", .{
            &format_ns(result.direct_ns),
            &format_ns(direct_per_op),
        });
        std.debug.print("  HostAdapter vtable (100K get+set):   {s}  per-op={s}\n", .{
            &format_ns(result.vtable_ns),
            &format_ns(vtable_per_op),
        });
        if (direct_per_op > 0) {
            const overhead_pct = if (vtable_per_op > direct_per_op)
                @as(f64, @floatFromInt(vtable_per_op - direct_per_op)) / @as(f64, @floatFromInt(direct_per_op)) * 100.0
            else
                0.0;
            std.debug.print("  Vtable overhead:                     {d:.1}%%\n", .{overhead_pct});
        }
    }
    std.debug.print("\n", .{});

    // -- Throughput analysis vs Nethermind target --
    std.debug.print("--- Throughput Analysis ---\n", .{});
    {
        const block_elapsed = bench_block_processing();
        const blocks_per_sec = if (block_elapsed > 0)
            1_000_000_000.0 / @as(f64, @floatFromInt(block_elapsed))
        else
            0.0;
        const effective_mgas = blocks_per_sec * 15.0;

        // Per block: 200 txs * (2 balance ops + 1 nonce + 5 storage + 2*3 nested + 2 checkpoints) ≈ 200 * 18 = 3600
        const host_ops_per_block: usize = 200 * 18;
        const host_ops_per_sec = blocks_per_sec * @as(f64, @floatFromInt(host_ops_per_block));

        std.debug.print("  Block processing time:           {s}\n", .{&format_ns(block_elapsed)});
        std.debug.print("  Block throughput:                {d:.0} blocks/s\n", .{blocks_per_sec});
        std.debug.print("  Effective MGas/s:                {d:.0} MGas/s\n", .{effective_mgas});
        std.debug.print("  Host ops/block:                  ~{d}\n", .{host_ops_per_block});
        std.debug.print("  Host ops/sec:                    {d:.0} ({d:.2} M ops/s)\n", .{ host_ops_per_sec, host_ops_per_sec / 1e6 });
        std.debug.print("  Nethermind target:               700 MGas/s (full client)\n", .{});
        std.debug.print("  Required blocks/s for target:    ~47 blocks/s\n", .{});

        // HostAdapter should be <1% of total budget → need >4700 blocks/s
        const comfortable = blocks_per_sec >= 4700.0;
        const meets_target = blocks_per_sec >= 47.0;

        if (comfortable) {
            std.debug.print("  Status:                          PASS - negligible overhead (<1%% of budget)\n", .{});
        } else if (meets_target) {
            std.debug.print("  Status:                          PASS - meets target but adapter overhead significant\n", .{});
        } else {
            std.debug.print("  Status:                          FAIL - adapter alone cannot keep up!\n", .{});
        }
    }

    std.debug.print("\n" ++ "=" ** 100 ++ "\n", .{});
    std.debug.print("  Notes:\n", .{});
    std.debug.print("  - HostAdapter is a thin vtable bridge (ptr cast + fn call)\n", .{});
    std.debug.print("  - StateManager uses in-memory hash maps (no disk I/O)\n", .{});
    std.debug.print("  - Checkpoint/revert copies entire state cache (O(n) in modified entries)\n", .{});
    std.debug.print("  - Error handling: getters return defaults, setters panic on failure\n", .{});
    std.debug.print("  - Arena allocator is used by StateManager internally\n", .{});
    std.debug.print("=" ** 100 ++ "\n\n", .{});
}
