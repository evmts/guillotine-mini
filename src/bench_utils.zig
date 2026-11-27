/// Shared helpers for benchmark output formatting and JSON reporting.
const std = @import("std");

/// Benchmark result metrics used for printing and JSON serialization.
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

/// Build a `BenchResult` from operation count and elapsed nanoseconds.
pub fn make_result(name: []const u8, ops: usize, elapsed_ns: u64) BenchResult {
    const per_op: u64 = if (ops > 0) elapsed_ns / ops else 0;
    const ops_sec: f64 = if (elapsed_ns > 0)
        @as(f64, @floatFromInt(ops)) / (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0)
    else
        0.0;
    return .{
        .name = name,
        .ops = ops,
        .elapsed_ns = elapsed_ns,
        .per_op_ns = per_op,
        .ops_per_sec = ops_sec,
    };
}

/// Format nanoseconds into a slice backed by `buf` (no trailing NUL bytes).
pub fn format_ns_buf(buf: *[32]u8, ns: u64) []const u8 {
    if (ns < 1_000) {
        return std.fmt.bufPrint(buf, "{d} ns", .{ns}) catch unreachable;
    } else if (ns < 1_000_000) {
        return std.fmt.bufPrint(buf, "{d:.1} us", .{@as(f64, @floatFromInt(ns)) / 1_000.0}) catch unreachable;
    } else if (ns < 1_000_000_000) {
        return std.fmt.bufPrint(buf, "{d:.2} ms", .{@as(f64, @floatFromInt(ns)) / 1_000_000.0}) catch unreachable;
    } else {
        return std.fmt.bufPrint(buf, "{d:.3} s", .{@as(f64, @floatFromInt(ns)) / 1_000_000_000.0}) catch unreachable;
    }
}

/// Format operations per second into a slice backed by `buf` (no trailing NUL bytes).
pub fn format_ops_per_sec_buf(buf: *[32]u8, ops: usize, elapsed_ns: u64) []const u8 {
    if (elapsed_ns == 0) {
        return std.fmt.bufPrint(buf, "inf ops/s", .{}) catch unreachable;
    }
    const ops_per_sec = @as(f64, @floatFromInt(ops)) / (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0);
    if (ops_per_sec >= 1_000_000) {
        return std.fmt.bufPrint(buf, "{d:.2} M ops/s", .{ops_per_sec / 1_000_000.0}) catch unreachable;
    } else if (ops_per_sec >= 1_000) {
        return std.fmt.bufPrint(buf, "{d:.1} K ops/s", .{ops_per_sec / 1_000.0}) catch unreachable;
    } else {
        return std.fmt.bufPrint(buf, "{d:.0} ops/s", .{ops_per_sec}) catch unreachable;
    }
}

/// Format nanoseconds into a NUL-padded fixed array (kept for existing callers).
pub fn format_ns(ns: u64) [32]u8 {
    var buf: [32]u8 = [_]u8{0} ** 32;
    _ = format_ns_buf(&buf, ns);
    return buf;
}

/// Format operations per second into a NUL-padded fixed array (kept for existing callers).
pub fn format_ops_per_sec(ops: usize, elapsed_ns: u64) [32]u8 {
    var buf: [32]u8 = [_]u8{0} ** 32;
    _ = format_ops_per_sec_buf(&buf, ops, elapsed_ns);
    return buf;
}

var active_suite: ?*BenchSuite = null;

/// Print a benchmark result row with formatted timing and throughput (no NUL bytes).
pub fn print_result(r: BenchResult) void {
    var total_buf: [32]u8 = undefined;
    var per_op_buf: [32]u8 = undefined;
    var ops_buf: [32]u8 = undefined;
    const total_str = format_ns_buf(&total_buf, r.elapsed_ns);
    const per_op_str = format_ns_buf(&per_op_buf, r.per_op_ns);
    const ops_str = format_ops_per_sec_buf(&ops_buf, r.ops, r.elapsed_ns);
    std.debug.print("  {s:<55} {d:>10} ops  total={s:<10}  per-op={s:<10}  {s}\n", .{
        r.name,
        r.ops,
        total_str,
        per_op_str,
        ops_str,
    });
    if (active_suite) |s| {
        s.results.append(s.allocator, r) catch {};
    }
}

/// Collector for a suite of benchmarks that prints human-readable tables and
/// optionally writes a JSON summary to `BENCH_JSON_OUT` (for Smithers `outFiles`).
pub const BenchSuite = struct {
    allocator: std.mem.Allocator,
    suite_name: []const u8,
    results: std.ArrayListUnmanaged(BenchResult) = .{},

    pub fn init(allocator: std.mem.Allocator, suite_name: []const u8) BenchSuite {
        std.debug.print("\n", .{});
        std.debug.print("=" ** 104 ++ "\n", .{});
        std.debug.print("  Benchmark Suite: {s}\n", .{suite_name});
        std.debug.print("=" ** 104 ++ "\n", .{});
        return .{
            .allocator = allocator,
            .suite_name = suite_name,
        };
    }

    /// Initialize without printing a banner (useful for legacy benchmarks with custom headers).
    pub fn initQuiet(allocator: std.mem.Allocator, suite_name: []const u8) BenchSuite {
        return .{
            .allocator = allocator,
            .suite_name = suite_name,
        };
    }

    pub fn deinit(self: *BenchSuite) void {
        if (active_suite == self) active_suite = null;
        self.results.deinit(self.allocator);
    }

    /// Attach as the active suite so standalone `print_result` calls also feed JSON output.
    pub fn attach(self: *BenchSuite) void {
        active_suite = self;
    }

    pub fn section(_: *BenchSuite, title: []const u8) void {
        std.debug.print("\n--- {s} ---\n", .{title});
    }

    pub fn record(self: *BenchSuite, result: BenchResult) !void {
        const prev = active_suite;
        active_suite = null;
        defer active_suite = prev;
        print_result(result);
        try self.results.append(self.allocator, result);
    }

    /// Record a result without printing it again.
    pub fn add(self: *BenchSuite, result: BenchResult) !void {
        try self.results.append(self.allocator, result);
    }

    /// Write JSON report if `BENCH_JSON_OUT` env var is set (prints closing banner).
    pub fn finish(self: *BenchSuite) !void {
        std.debug.print("=" ** 104 ++ "\n\n", .{});
        try self.writeJsonIfRequested();
    }

    /// Write JSON report if `BENCH_JSON_OUT` env var is set (no banner).
    pub fn writeJsonIfRequested(self: *BenchSuite) !void {
        const out_path = std.process.getEnvVarOwned(self.allocator, "BENCH_JSON_OUT") catch |err| switch (err) {
            error.EnvironmentVariableNotFound => return,
            else => return err,
        };
        defer self.allocator.free(out_path);
        if (out_path.len == 0) return;

        if (std.fs.path.dirname(out_path)) |dir_path| {
            if (dir_path.len > 0) {
                try std.fs.cwd().makePath(dir_path);
            }
        }

        var json_buf: std.ArrayListUnmanaged(u8) = .{};
        defer json_buf.deinit(self.allocator);
        const writer = json_buf.writer(self.allocator);

        try writer.writeAll("{\n  \"suite\": ");
        try writeJsonString(writer, self.suite_name);
        try writer.writeAll(",\n  \"benchmarks\": [\n");
        for (self.results.items, 0..) |r, idx| {
            try writer.writeAll("    { \"name\": ");
            try writeJsonString(writer, r.name);
            try writer.print(", \"ops\": {d}, \"elapsed_ns\": {d}, \"per_op_ns\": {d}, \"ops_per_sec\": {d:.2} }}", .{
                r.ops,
                r.elapsed_ns,
                r.per_op_ns,
                r.ops_per_sec,
            });
            if (idx + 1 < self.results.items.len) {
                try writer.writeAll(",\n");
            } else {
                try writer.writeAll("\n");
            }
        }
        try writer.writeAll("  ]\n}\n");

        const file = try std.fs.cwd().createFile(out_path, .{ .truncate = true });
        defer file.close();
        try file.writeAll(json_buf.items);
    }
};

fn writeJsonString(writer: anytype, s: []const u8) !void {
    try writer.writeByte('"');
    for (s) |c| {
        switch (c) {
            '"' => try writer.writeAll("\\\""),
            '\\' => try writer.writeAll("\\\\"),
            '\n' => try writer.writeAll("\\n"),
            '\r' => try writer.writeAll("\\r"),
            '\t' => try writer.writeAll("\\t"),
            else => {
                if (c < 0x20) {
                    try writer.print("\\u{x:0>4}", .{c});
                } else {
                    try writer.writeByte(c);
                }
            },
        }
    }
    try writer.writeByte('"');
}

/// Compute the median of a slice of timing samples (sorts in place).
pub fn median_ns(samples: []u64) u64 {
    if (samples.len == 0) return 0;
    std.mem.sort(u64, samples, {}, std.sort.asc(u64));
    return samples[samples.len / 2];
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
