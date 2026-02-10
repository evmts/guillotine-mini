/// Micro-benchmarks for RLPx frame size encode/decode helpers.
const std = @import("std");
const bench = @import("bench_utils");
const client_network = @import("client_network");

fn benchDecode(iterations: usize) bench.BenchResult {
    var sum: usize = 0; // prevent optimization-out
    const bytes: [3]u8 = .{ 0x12, 0x34, 0x56 };
    const start = std.time.nanoTimestamp();
    var i: usize = 0;
    while (i < iterations) : (i += 1) {
        // Inline decode of constant header bytes
        sum +%= client_network.Frame.decode_frame_size_24(bytes);
    }
    const end = std.time.nanoTimestamp();
    const elapsed: u64 = @intCast(end - start);
    return .{
        .name = "RLPx decode_frame_size_24([3]u8)",
        .ops = iterations,
        .elapsed_ns = elapsed,
        .per_op_ns = if (iterations == 0) 0 else @as(u64, @intCast(elapsed / iterations)),
        .ops_per_sec = if (elapsed == 0) std.math.inf(f64) else @as(f64, @floatFromInt(iterations)) / (@as(f64, @floatFromInt(elapsed)) / 1_000_000_000.0),
    };
}

fn benchEncode(iterations: usize) bench.BenchResult {
    var sink: u8 = 0; // prevent optimization-out
    const size: usize = 0x12_34_56;
    const start = std.time.nanoTimestamp();
    var i: usize = 0;
    while (i < iterations) : (i += 1) {
        const out = client_network.Frame.encode_frame_size_24(size) catch unreachable;
        sink = sink ^ out[0] ^ out[1] ^ out[2];
    }
    const end = std.time.nanoTimestamp();
    const elapsed: u64 = @intCast(end - start);
    std.mem.doNotOptimizeAway(sink);
    return .{
        .name = "RLPx encode_frame_size_24(usize)",
        .ops = iterations,
        .elapsed_ns = elapsed,
        .per_op_ns = if (iterations == 0) 0 else @as(u64, @intCast(elapsed / iterations)),
        .ops_per_sec = if (elapsed == 0) std.math.inf(f64) else @as(f64, @floatFromInt(iterations)) / (@as(f64, @floatFromInt(elapsed)) / 1_000_000_000.0),
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    // Allow tuning via env var; default to a safe, sub-second count in ReleaseFast.
    var iters: usize = 10_000_000;
    if (std.process.getEnvVarOwned(alloc, "RLPX_BENCH_ITERS")) |val| {
        defer alloc.free(val);
        iters = std.fmt.parseInt(usize, val, 10) catch iters;
    } else |_| {}

    std.debug.print("RLPx Frame Encode/Decode Benchmarks (iters={d})\n", .{iters});
    bench.print_result(benchDecode(iters));
    bench.print_result(benchEncode(iters));
}
