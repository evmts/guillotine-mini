/// Micro-benchmarks for RLPx frame size encode/decode helpers.
const std = @import("std");
const bench = @import("bench_utils");
const client_network = @import("client_network");

fn benchDecode(iterations: usize) bench.BenchResult {
    var sum: usize = 0; // prevent optimization-out
    var bytes: [3]u8 = .{ 0x12, 0x34, 0x56 };
    const start = std.time.nanoTimestamp();
    var i: usize = 0;
    while (i < iterations) : (i += 1) {
        bytes[2] = @truncate(i);
        sum +%= client_network.Frame.decode_frame_size_24(bytes);
    }
    const end = std.time.nanoTimestamp();
    std.mem.doNotOptimizeAway(sum);
    const elapsed: u64 = @intCast(end - start);
    return bench.make_result("RLPx decode_frame_size_24([3]u8)", iterations, elapsed);
}

fn benchEncode(iterations: usize) bench.BenchResult {
    var sink: u8 = 0; // prevent optimization-out
    const start = std.time.nanoTimestamp();
    var i: usize = 0;
    while (i < iterations) : (i += 1) {
        const size: usize = 0x12_34_00 | (i & 0xff);
        const out = client_network.Frame.encode_frame_size_24(size) catch unreachable;
        sink = sink ^ out[0] ^ out[1] ^ out[2];
    }
    const end = std.time.nanoTimestamp();
    const elapsed: u64 = @intCast(end - start);
    std.mem.doNotOptimizeAway(sink);
    return bench.make_result("RLPx encode_frame_size_24(usize)", iterations, elapsed);
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

    var suite = bench.BenchSuite.init(alloc, "client/network-rlpx");
    defer suite.deinit();
    suite.section("RLPx Frame Encode/Decode");
    try suite.record(benchDecode(iters));
    try suite.record(benchEncode(iters));
    try suite.finish();
}
