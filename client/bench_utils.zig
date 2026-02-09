/// Shared helpers for benchmark output formatting.
const std = @import("std");

/// Benchmark result metrics used for printing.
pub const BenchResult = struct {
    /// Display name for the benchmark row.
    name: []const u8,
    /// Number of operations performed.
    ops: usize,
    /// Total elapsed time in nanoseconds.
    elapsed_ns: u64,
    /// Average time per operation in nanoseconds.
    per_op_ns: u64,
    /// Operations per second.
    ops_per_sec: f64,
};

/// Format nanoseconds into a human-readable string.
pub fn format_ns(ns: u64) [32]u8 {
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

/// Format operations per second into a human-readable string.
pub fn format_ops_per_sec(ops: usize, elapsed_ns: u64) [32]u8 {
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

/// Print a benchmark result row with formatted timing and throughput.
pub fn print_result(r: BenchResult) void {
    const total_str = format_ns(r.elapsed_ns);
    const per_op_str = format_ns(r.per_op_ns);
    const ops_str = format_ops_per_sec(r.ops, r.elapsed_ns);
    std.debug.print("  {s:<55} {d:>8} ops  total={s}  per-op={s}  {s}\n", .{
        r.name,
        r.ops,
        &total_str,
        &per_op_str,
        &ops_str,
    });
}

test "format_ns renders expected units" {
    const ns = format_ns(999);
    const ns_end = std.mem.indexOfScalar(u8, ns[0..], 0) orelse ns.len;
    try std.testing.expectEqualStrings("999 ns", ns[0..ns_end]);

    const us = format_ns(1_500);
    const us_end = std.mem.indexOfScalar(u8, us[0..], 0) orelse us.len;
    try std.testing.expectEqualStrings("1.5 us", us[0..us_end]);

    const ms = format_ns(2_500_000);
    const ms_end = std.mem.indexOfScalar(u8, ms[0..], 0) orelse ms.len;
    try std.testing.expectEqualStrings("2.50 ms", ms[0..ms_end]);

    const s = format_ns(3_000_000_000);
    const s_end = std.mem.indexOfScalar(u8, s[0..], 0) orelse s.len;
    try std.testing.expectEqualStrings("3.000 s", s[0..s_end]);
}

test "format_ops_per_sec renders expected units" {
    const inf = format_ops_per_sec(1, 0);
    const inf_end = std.mem.indexOfScalar(u8, inf[0..], 0) orelse inf.len;
    try std.testing.expectEqualStrings("inf ops/s", inf[0..inf_end]);

    const k = format_ops_per_sec(1_000, 1_000_000_000);
    const k_end = std.mem.indexOfScalar(u8, k[0..], 0) orelse k.len;
    try std.testing.expectEqualStrings("1.0 K ops/s", k[0..k_end]);
}

test "print_result does not crash" {
    print_result(.{
        .name = "sample",
        .ops = 10,
        .elapsed_ns = 1000,
        .per_op_ns = 100,
        .ops_per_sec = 10_000.0,
    });
}
