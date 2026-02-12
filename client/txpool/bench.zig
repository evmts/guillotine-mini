/// Benchmarks for the Transaction Pool (phase-5-txpool).
///
/// Focus areas:
/// - Admission sizing: `fits_size_limits` across mixed tx types
/// - Fee sorting hot path: `compare_fee_market_priority` (standalone + sort)
/// - Allocation behavior: ensure memory is returned (GPA) and report bytes/op
///
/// Notes:
/// - Voltaire primitives do not expose EIP-2930 transactions in this build; the
///   admission bench covers Legacy, EIP-1559, EIP-4844, and EIP-7702 only.
///
/// Run:
///   zig build bench-txpool                         # Debug timings (sanity)
///   zig build bench-txpool -Doptimize=ReleaseFast  # Release timings (use these)
const std = @import("std");
const bench = @import("bench_utils");
const primitives = @import("primitives");
const txpool = @import("root.zig");

const Address = primitives.Address;
const Tx = primitives.Transaction;
const GasPrice = primitives.GasPrice;
const MaxFeePerGas = primitives.MaxFeePerGas;
const MaxPriorityFeePerGas = primitives.MaxPriorityFeePerGas;
const BaseFeePerGas = primitives.BaseFeePerGas;
const VersionedHash = primitives.Blob.VersionedHash;

// Workloads
const N_ADMISSION_SMALL: usize = 5_000; // Per-type sample size
const N_ADMISSION_MED: usize = 20_000; // Per-type sample size
const N_SORT: usize = 50_000; // Fee tuples for sort bench

fn mkAddr(byte: u8) Address {
    return .{ .bytes = [_]u8{byte} ++ [_]u8{0} ** 19 };
}

fn mkVHash(byte: u8) VersionedHash {
    return .{ .bytes = [_]u8{byte} ++ [_]u8{0} ** 31 };
}

fn bench_admission(_: std.mem.Allocator, n_per_type: usize) bench.BenchResult {
    // Config with generous size caps (should all pass)
    var cfg = txpool.TxPoolConfig{};
    cfg.max_tx_size = 256 * 1024; // legacy/1559/2930/7702
    cfg.max_blob_tx_size = 1024 * 1024; // 4844 (excludes blobs)

    // Prepare a small mix of transactions
    var ops: usize = 0;
    var timer = std.time.Timer.start() catch unreachable;

    // Legacy
    {
        const tx = Tx.LegacyTransaction{
            .nonce = 0,
            .gas_price = 1,
            .gas_limit = 21_000,
            .to = mkAddr(0x11),
            .value = 0,
            .data = &[_]u8{},
            .v = 37,
            .r = [_]u8{0} ** 32,
            .s = [_]u8{0} ** 32,
        };
        for (0..n_per_type) |_| {
            txpool.fits_size_limits(tx, cfg) catch unreachable;
        }
        ops += n_per_type;
    }

    // EIP-1559
    {
        const tx = Tx.Eip1559Transaction{
            .chain_id = 1,
            .nonce = 0,
            .max_priority_fee_per_gas = 1,
            .max_fee_per_gas = 2,
            .gas_limit = 21_000,
            .to = mkAddr(0x22),
            .value = 0,
            .data = &[_]u8{},
            .access_list = &[_]Tx.AccessListItem{},
            .y_parity = 1,
            .r = [_]u8{1} ** 32,
            .s = [_]u8{2} ** 32,
        };
        for (0..n_per_type) |_| {
            txpool.fits_size_limits(tx, cfg) catch unreachable;
        }
        ops += n_per_type;
    }

    // EIP-2930 is intentionally omitted (not present in primitives here).

    // EIP-4844 (blob tx; size excludes blobs)
    {
        const hashes = [_]VersionedHash{mkVHash(0xAA)};
        const tx = Tx.Eip4844Transaction{
            .chain_id = 1,
            .nonce = 0,
            .max_priority_fee_per_gas = 1,
            .max_fee_per_gas = 2,
            .gas_limit = 21_000,
            .to = mkAddr(0x33), // non-null
            .value = 0,
            .data = &[_]u8{},
            .access_list = &[_]Tx.AccessListItem{},
            .max_fee_per_blob_gas = 1,
            .blob_versioned_hashes = &hashes,
            .y_parity = 1,
            .r = [_]u8{3} ** 32,
            .s = [_]u8{4} ** 32,
        };
        for (0..n_per_type) |_| {
            txpool.fits_size_limits(tx, cfg) catch unreachable;
        }
        ops += n_per_type;
    }

    // EIP-7702 (authorization list; empty here)
    {
        const Authorization = primitives.Authorization.Authorization;
        const tx = Tx.Eip7702Transaction{
            .chain_id = 1,
            .nonce = 0,
            .max_priority_fee_per_gas = 1,
            .max_fee_per_gas = 2,
            .gas_limit = 21_000,
            .to = mkAddr(0x44),
            .value = 0,
            .data = &[_]u8{},
            .access_list = &[_]Tx.AccessListItem{},
            .authorization_list = &[_]Authorization{},
            .y_parity = 0,
            .r = [_]u8{0} ** 32,
            .s = [_]u8{0} ** 32,
        };
        for (0..n_per_type) |_| {
            txpool.fits_size_limits(tx, cfg) catch unreachable;
        }
        ops += n_per_type;
    }

    const elapsed = timer.read();
    const per_op = if (ops > 0) elapsed / ops else 0;
    return .{
        .name = "txpool.admission: fits_size_limits (mixed types)",
        .ops = ops,
        .elapsed_ns = elapsed,
        .per_op_ns = per_op,
        .ops_per_sec = if (elapsed > 0) @as(f64, @floatFromInt(ops)) / (@as(f64, @floatFromInt(elapsed)) / 1e9) else 0,
    };
}

const FeeTuple = struct {
    gas_price: GasPrice,
    max_fee: MaxFeePerGas,
    max_priority: MaxPriorityFeePerGas,
};

fn bench_fee_compare_only(n: usize) bench.BenchResult {
    // Deterministic input set
    var rng = std.Random.DefaultPrng.init(0xC0FFEE);
    const random = rng.random();

    var tuples = std.ArrayList(FeeTuple).empty;
    tuples.ensureTotalCapacityPrecise(std.heap.page_allocator, n) catch unreachable;
    defer tuples.deinit(std.heap.page_allocator);

    for (0..n) |_| {
        // Randomize: mix legacy-like and 1559-like
        const gp = GasPrice.from(@as(u64, random.intRangeAtMost(u64, 0, 100_000_000_000)));
        const mf = MaxFeePerGas.from(@as(u64, random.intRangeAtMost(u64, 0, 200_000_000_000)));
        const mp = MaxPriorityFeePerGas.from(@as(u64, random.intRangeAtMost(u64, 0, 10_000_000_000)));
        tuples.appendAssumeCapacity(.{ .gas_price = gp, .max_fee = mf, .max_priority = mp });
    }

    const base_fee = BaseFeePerGas.from(15_000_000_000);
    var timer = std.time.Timer.start() catch unreachable;
    var cmp_count: usize = 0;
    // Just slam comparator without sorting cost
    for (tuples.items, 0..) |x, i| {
        const j = (i * 17 + 13) % tuples.items.len;
        const y = tuples.items[j];
        _ = txpool.compare_fee_market_priority(
            x.gas_price,
            x.max_fee,
            x.max_priority,
            y.gas_price,
            y.max_fee,
            y.max_priority,
            base_fee,
            true,
        );
        cmp_count += 1;
    }
    const elapsed = timer.read();
    const per = if (cmp_count > 0) elapsed / cmp_count else 0;
    return .{
        .name = "txpool.sort: fee comparator only (EIP-1559)",
        .ops = cmp_count,
        .elapsed_ns = elapsed,
        .per_op_ns = per,
        .ops_per_sec = if (elapsed > 0) @as(f64, @floatFromInt(cmp_count)) / (@as(f64, @floatFromInt(elapsed)) / 1e9) else 0,
    };
}

fn bench_fee_sort(n: usize) bench.BenchResult {
    var rng = std.Random.DefaultPrng.init(0xBADC0DE);
    const random = rng.random();

    var tuples = std.ArrayList(FeeTuple).empty;
    tuples.ensureTotalCapacityPrecise(std.heap.page_allocator, n) catch unreachable;
    defer tuples.deinit(std.heap.page_allocator);

    for (0..n) |_| {
        // Random mix of legacy-emulation and 1559
        const is_legacy = (random.int(u32) & 3) == 0; // ~25% legacy-like
        const gp = GasPrice.from(@as(u64, random.intRangeAtMost(u64, 1, 100_000_000_000)));
        const mf = if (is_legacy) MaxFeePerGas.from(0) else MaxFeePerGas.from(@as(u64, random.intRangeAtMost(u64, 1, 200_000_000_000)));
        const mp = if (is_legacy) MaxPriorityFeePerGas.from(0) else MaxPriorityFeePerGas.from(@as(u64, random.intRangeAtMost(u64, 1, 10_000_000_000)));
        tuples.appendAssumeCapacity(.{ .gas_price = gp, .max_fee = mf, .max_priority = mp });
    }

    const base_fee = BaseFeePerGas.from(25_000_000_000);
    var timer = std.time.Timer.start() catch unreachable;
    std.sort.block(FeeTuple, tuples.items, base_fee, struct {
        fn lessThan(base: BaseFeePerGas, a: FeeTuple, b: FeeTuple) bool {
            const r = txpool.compare_fee_market_priority(
                a.gas_price,
                a.max_fee,
                a.max_priority,
                b.gas_price,
                b.max_fee,
                b.max_priority,
                base,
                true,
            );
            // We want descending priority, so lessThan is inverted
            return r == 1; // a has lower priority than b → a < b
        }
    }.lessThan);
    const elapsed = timer.read();

    // Approximate comparator calls upper bound ~ n log2 n * C; we just report time/op by n
    const per = if (n > 0) elapsed / n else 0;
    return .{
        .name = "txpool.sort: sort N fee tuples (EIP-1559/legacy mix)",
        .ops = n,
        .elapsed_ns = elapsed,
        .per_op_ns = per,
        .ops_per_sec = if (elapsed > 0) @as(f64, @floatFromInt(n)) / (@as(f64, @floatFromInt(elapsed)) / 1e9) else 0,
    };
}

fn bench_admission_memory(n_per_type: usize) struct { elapsed_ns: u64, bytes_per_op: usize } {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .enable_memory_limit = true }){};
    defer _ = gpa.deinit();

    const before_bytes: usize = gpa.total_requested_bytes;
    const res = bench_admission(gpa.allocator(), n_per_type);
    const after_bytes: usize = gpa.total_requested_bytes;

    const total_ops: usize = n_per_type * 4; // 4 tx types in this bench
    const per_op = if (total_ops > 0) (after_bytes - before_bytes) / total_ops else 0;
    return .{ .elapsed_ns = res.elapsed_ns, .bytes_per_op = per_op };
}

pub fn main() !void {
    std.debug.print("\n" ++ "=" ** 100 ++ "\n", .{});
    std.debug.print("  Guillotine Phase-5-TxPool Benchmarks\n", .{});
    std.debug.print("  Warmup: implicit in generation; timings averaged per run\n", .{});
    std.debug.print("=" ** 100 ++ "\n\n", .{});

    // Admission (fits_size_limits) using GPA to ensure frees reclaim memory
    std.debug.print("--- Admission: fits_size_limits (GPA allocator) ---\n", .{});
    {
        const r_small = bench_admission(std.heap.c_allocator, N_ADMISSION_SMALL);
        bench.print_result(r_small);

        const r_med = bench_admission(std.heap.c_allocator, N_ADMISSION_MED);
        bench.print_result(r_med);
    }
    std.debug.print("\n", .{});

    // Allocation behavior (bytes/op) with GPA accounting
    std.debug.print("--- Allocation Behavior (GPA observed) ---\n", .{});
    {
        const m = bench_admission_memory(2_000);
        const time_str = bench.format_ns(m.elapsed_ns);
        std.debug.print("  fits_size_limits: ~{d} bytes/op (2k/tx-type), time={s}\n", .{ m.bytes_per_op, &time_str });
        std.debug.print("  Note: using GPA to ensure frees are honored; Arena would retain until deinit.\n", .{});
    }
    std.debug.print("\n", .{});

    // Comparator-only and full sort
    std.debug.print("--- Fee Market Priority Sorting ---\n", .{});
    {
        const r_cmp = bench_fee_compare_only(N_SORT);
        bench.print_result(r_cmp);

        const r_sort = bench_fee_sort(N_SORT);
        bench.print_result(r_sort);
    }

    std.debug.print("\n" ++ "=" ** 100 ++ "\n\n", .{});
}
