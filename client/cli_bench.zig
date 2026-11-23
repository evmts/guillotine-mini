/// Benchmarks for CLI argument parsing and RunnerConfig resolution.
const std = @import("std");
const bench = @import("bench_utils");
const cli = @import("cli.zig");
const config_mod = @import("config.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var suite = bench.BenchSuite.init(allocator, "client/cli");
    defer suite.deinit();

    const argv = [_][]const u8{
        "guillotine-mini",
        "--chain-id",
        "1",
        "--network-id",
        "1",
        "--hardfork",
        "Osaka",
        "--trace",
        "--trace-tracer",
        "callTracer",
        "--trace-timeout",
        "5s",
    };

    suite.section("CLI Argument Parsing");
    {
        const n: usize = 200_000;
        var sink_buf: [256]u8 = undefined;
        var timer = try std.time.Timer.start();
        var acc: u64 = 0;
        for (0..n) |_| {
            var cfg = config_mod.RunnerConfig{};
            var trace_enabled = false;
            var stream = std.io.fixedBufferStream(&sink_buf);
            try cli.parse_args(&argv, &cfg, &trace_enabled, stream.writer());
            acc +%= cfg.effective_network_id() +% @intFromBool(trace_enabled);
        }
        std.mem.doNotOptimizeAway(acc);
        try suite.record(bench.make_result("cli.parse_args (full option set)", n, timer.read()));
    }

    try suite.finish();
}
