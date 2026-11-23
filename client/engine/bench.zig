/// Benchmarks for the Engine API module (method name validation & capability dispatch).
const std = @import("std");
const bench = @import("bench_utils");
const method_name = @import("method_name.zig");
const api_mod = @import("api.zig");

const StubEngine = struct {
    result: api_mod.ExchangeCapabilitiesResult,
    client_version_result: api_mod.ClientVersionV1Result = .{ .value = &.{} },
    transition_result: api_mod.ExchangeTransitionConfigurationV1Result = undefined,

    fn exchangeCapabilities(
        ptr: *anyopaque,
        _: api_mod.ExchangeCapabilitiesParams,
    ) api_mod.EngineApi.Error!api_mod.ExchangeCapabilitiesResult {
        const self: *@This() = @ptrCast(@alignCast(ptr));
        return self.result;
    }

    fn getClientVersionV1(
        ptr: *anyopaque,
        _: api_mod.ClientVersionV1Params,
    ) api_mod.EngineApi.Error!api_mod.ClientVersionV1Result {
        const self: *@This() = @ptrCast(@alignCast(ptr));
        return self.client_version_result;
    }

    fn exchangeTransitionConfigurationV1(
        ptr: *anyopaque,
        _: api_mod.ExchangeTransitionConfigurationV1Params,
    ) api_mod.EngineApi.Error!api_mod.ExchangeTransitionConfigurationV1Result {
        const self: *@This() = @ptrCast(@alignCast(ptr));
        return self.transition_result;
    }

    const vtable = api_mod.EngineApi.VTable{
        .exchange_capabilities = exchangeCapabilities,
        .get_client_version_v1 = getClientVersionV1,
        .exchange_transition_configuration_v1 = exchangeTransitionConfigurationV1,
    };

    fn engineApi(self: *@This()) api_mod.EngineApi {
        return .{ .ptr = @ptrCast(self), .vtable = &vtable };
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var suite = bench.BenchSuite.init(allocator, "client/engine");
    defer suite.deinit();

    const names = [_][]const u8{
        "engine_newPayloadV3",
        "engine_forkchoiceUpdatedV3",
        "engine_getPayloadBodiesByHashV1",
        "engine_exchangeCapabilities",
        "eth_blockNumber",
        "engine_invalidNoVersion",
        "engine_getBlobsV2",
        "engine_getClientVersionV1",
    };

    suite.section("Engine Method Name Validation");
    {
        const n: usize = 2_000_000;
        var timer = try std.time.Timer.start();
        var acc: usize = 0;
        for (0..n) |i| {
            const name = names[i & 7];
            acc +%= @intFromBool(method_name.isEngineVersionedMethodName(name));
            acc +%= @intFromBool(method_name.isValidAdvertisableEngineMethodName(name));
        }
        std.mem.doNotOptimizeAway(acc);
        try suite.record(bench.make_result("method_name versioned + advertisable checks", n, timer.read()));
    }

    suite.section("EngineApi VTable Dispatch");
    {
        var arena = std.heap.ArenaAllocator.init(allocator);
        defer arena.deinit();
        const a = arena.allocator();

        var req_arr = std.json.Array.init(a);
        try req_arr.append(.{ .string = "engine_newPayloadV3" });
        try req_arr.append(.{ .string = "engine_forkchoiceUpdatedV3" });
        try req_arr.append(.{ .string = "engine_getPayloadV3" });
        try req_arr.append(.{ .string = "engine_getBlobsV1" });
        const req_qty = try std.json.innerParseFromValue(
            @FieldType(api_mod.ExchangeCapabilitiesParams, "consensus_client_methods"),
            a,
            .{ .array = req_arr },
            .{},
        );

        var res_arr = std.json.Array.init(a);
        try res_arr.append(.{ .string = "engine_newPayloadV3" });
        try res_arr.append(.{ .string = "engine_forkchoiceUpdatedV3" });
        try res_arr.append(.{ .string = "engine_getPayloadV3" });
        const res_qty = try std.json.innerParseFromValue(
            @FieldType(api_mod.ExchangeCapabilitiesResult, "value"),
            a,
            .{ .array = res_arr },
            .{},
        );

        var stub = StubEngine{ .result = .{ .value = res_qty } };
        const api = stub.engineApi();
        const n: usize = 500_000;
        var timer = try std.time.Timer.start();
        var acc: usize = 0;
        for (0..n) |_| {
            const res = try api.exchange_capabilities(.{ .consensus_client_methods = req_qty });
            acc +%= res.value.value.array.items.len;
        }
        std.mem.doNotOptimizeAway(acc);
        try suite.record(bench.make_result("EngineApi.exchange_capabilities (4 caps)", n, timer.read()));
    }

    try suite.finish();
}
