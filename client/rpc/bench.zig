/// Benchmarks for the JSON-RPC module (envelope extraction, namespace dispatch,
/// eth_chainId handler, and response serialization).
const std = @import("std");
const bench = @import("bench_utils");
const envelope = @import("envelope.zig");
const dispatch = @import("dispatch.zig");
const response = @import("response.zig");
const eth = @import("eth.zig");

const StubProvider = struct {
    chain_id: u64 = 1,
    pub fn getChainId(self: *const @This()) u64 {
        return self.chain_id;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var suite = bench.BenchSuite.init(allocator, "client/rpc");
    defer suite.deinit();

    const requests = [_][]const u8{
        "{\"jsonrpc\":\"2.0\",\"method\":\"eth_blockNumber\",\"params\":[],\"id\":1}",
        "{\"jsonrpc\":\"2.0\",\"method\":\"eth_chainId\",\"params\":[],\"id\":\"req-42\"}",
        "{\"jsonrpc\":\"2.0\",\"method\":\"engine_newPayloadV3\",\"params\":[],\"id\":99}",
        "{\"jsonrpc\":\"2.0\",\"method\":\"debug_traceTransaction\",\"params\":[],\"id\":100}",
    };

    const methods = [_][]const u8{
        "eth_blockNumber",
        "eth_call",
        "eth_getBalance",
        "engine_newPayloadV3",
        "engine_forkchoiceUpdatedV3",
        "engine_getClientVersionV1",
        "debug_traceTransaction",
        "unknown_customMethod",
    };

    suite.section("Envelope & Method Dispatch");
    {
        const n: usize = 500_000;
        var timer = try std.time.Timer.start();
        var acc: usize = 0;
        for (0..n) |i| {
            const req = requests[i & 3];
            const res = envelope.extract_request_id(req);
            acc +%= @intFromEnum(res);
        }
        std.mem.doNotOptimizeAway(acc);
        try suite.record(bench.make_result("envelope.extract_request_id", n, timer.read()));
    }

    {
        const n: usize = 500_000;
        var timer = try std.time.Timer.start();
        var acc: usize = 0;
        for (0..n) |i| {
            const m = methods[i & 7];
            const ns = dispatch.resolve_namespace(m);
            acc +%= if (ns != null) 1 else 0;
        }
        std.mem.doNotOptimizeAway(acc);
        try suite.record(bench.make_result("dispatch.resolve_namespace (mixed)", n, timer.read()));
    }

    {
        const n: usize = 300_000;
        var timer = try std.time.Timer.start();
        var acc: usize = 0;
        for (0..n) |i| {
            const req = requests[i & 3];
            const res = dispatch.parse_request_namespace(req);
            acc +%= @intFromEnum(res);
        }
        std.mem.doNotOptimizeAway(acc);
        try suite.record(bench.make_result("dispatch.parse_request_namespace", n, timer.read()));
    }

    suite.section("Response Serialization & EthApi");
    {
        const n: usize = 500_000;
        var buf: [256]u8 = undefined;
        var timer = try std.time.Timer.start();
        var total_bytes: usize = 0;
        for (0..n) |i| {
            var stream = std.io.fixedBufferStream(&buf);
            try response.Response.write_success_quantity_u64(stream.writer(), .{ .number = "1" }, @intCast(i));
            total_bytes +%= stream.pos;
        }
        std.mem.doNotOptimizeAway(total_bytes);
        try suite.record(bench.make_result("Response.write_success_quantity_u64", n, timer.read()));
    }

    {
        const provider = StubProvider{ .chain_id = 1 };
        const api = eth.EthApi(StubProvider){ .provider = &provider };
        const n: usize = 300_000;
        var buf: [256]u8 = undefined;
        var timer = try std.time.Timer.start();
        var total_bytes: usize = 0;
        for (0..n) |_| {
            var stream = std.io.fixedBufferStream(&buf);
            try api.handle_chain_id(stream.writer(), requests[1]);
            total_bytes +%= stream.pos;
        }
        std.mem.doNotOptimizeAway(total_bytes);
        try suite.record(bench.make_result("EthApi.handle_chain_id (parse + format)", n, timer.read()));
    }

    try suite.finish();
}
