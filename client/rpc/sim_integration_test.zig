//! End-to-end JSON-RPC tests for `SimulationApi`, `DebugApi` and `TraceApi`
//! against the real simulation engine (`@import("evm").simulation`).
const std = @import("std");
const primitives = @import("voltaire");
const evm = @import("evm");
const Sim = evm.simulation;
const codec = @import("codec.zig");
const SimulationApi = @import("simulation.zig").SimulationApi;
const DebugApi = @import("debug.zig").DebugApi;
const TraceApi = @import("trace.zig").TraceApi;

const testing = std.testing;
const Address = primitives.Address;
const crypto = @import("crypto").Crypto;

const SENDER = "0x0000000000000000000000000000000000001000";
const CONTRACT = "0x0000000000000000000000000000000000002000";
const OTHER = "0x0000000000000000000000000000000000003000";
const SLOT0 = "0x0000000000000000000000000000000000000000000000000000000000000000";

/// slot0 += 1; return the new value.
const counter_code = [_]u8{ 0x5f, 0x54, 0x60, 0x01, 0x01, 0x80, 0x5f, 0x55, 0x5f, 0x52, 0x60, 0x20, 0x5f, 0xf3 };
/// Revert with payload 0xdeadbeef.
const revert_code = [_]u8{ 0x63, 0xde, 0xad, 0xbe, 0xef, 0x5f, 0x52, 0x60, 0x04, 0x60, 0x1c, 0xfd };

/// Read-only base state; any write fails the test via `writes`.
const BaseHost = struct {
    code: std.AutoHashMapUnmanaged(Address, []const u8) = .{},
    storage: std.AutoHashMapUnmanaged([52]u8, u256) = .{},
    balances: std.AutoHashMapUnmanaged(Address, u256) = .{},
    writes: usize = 0,

    fn deinit(self: *BaseHost) void {
        self.code.deinit(testing.allocator);
        self.storage.deinit(testing.allocator);
        self.balances.deinit(testing.allocator);
    }

    fn key(a: Address, slot: u256) [52]u8 {
        var k: [52]u8 = undefined;
        k[0..20].* = a.bytes;
        std.mem.writeInt(u256, k[20..52], slot, .big);
        return k;
    }

    fn me(p: *anyopaque) *BaseHost {
        return @ptrCast(@alignCast(p));
    }
    fn getBalance(p: *anyopaque, a: Address) u256 {
        return me(p).balances.get(a) orelse 0;
    }
    fn getCode(p: *anyopaque, a: Address) []const u8 {
        return me(p).code.get(a) orelse &.{};
    }
    fn getStorage(p: *anyopaque, a: Address, s: u256) u256 {
        return me(p).storage.get(key(a, s)) orelse 0;
    }
    fn getNonce(_: *anyopaque, _: Address) u64 {
        return 0;
    }
    fn setBalance(p: *anyopaque, _: Address, _: u256) void {
        me(p).writes += 1;
    }
    fn setCode(p: *anyopaque, _: Address, _: []const u8) void {
        me(p).writes += 1;
    }
    fn setStorage(p: *anyopaque, _: Address, _: u256, _: u256) void {
        me(p).writes += 1;
    }
    fn setNonce(p: *anyopaque, _: Address, _: u64) void {
        me(p).writes += 1;
    }
    const vtable: Sim.HostInterface.VTable = .{
        .getBalance = getBalance,
        .setBalance = setBalance,
        .getCode = getCode,
        .setCode = setCode,
        .getStorage = getStorage,
        .setStorage = setStorage,
        .getNonce = getNonce,
        .setNonce = setNonce,
    };
    fn iface(self: *BaseHost) Sim.HostInterface {
        return .{ .ptr = self, .vtable = &vtable };
    }
};

fn addr(comptime hex: []const u8) Address {
    return Address.fromHex(hex) catch unreachable;
}

const Provider = struct {
    base: *BaseHost,
    hardfork: Sim.Hardfork = .CANCUN,

    fn block() Sim.BlockContext {
        return .{
            .chain_id = 1,
            .block_number = 100,
            .block_timestamp = 1_000,
            .block_difficulty = 0,
            .block_prevrandao = 0,
            .block_coinbase = Address.fromU256(0xc0),
            .block_gas_limit = 30_000_000,
            .block_base_fee = 0,
            .blob_base_fee = 1,
        };
    }

    pub fn resolveBlock(self: *const Provider, tag: codec.BlockTag) ?Sim.BlockState {
        return switch (tag) {
            .latest, .pending, .safe, .finalized => .{ .host = self.base.iface(), .block = block(), .hardfork = self.hardfork, .block_hash = @splat(0xbb) },
            .number => |n| if (n == 100) .{ .host = self.base.iface(), .block = block(), .hardfork = self.hardfork } else null,
            else => null,
        };
    }

    pub fn getTransactionReplay(self: *const Provider, hash: [32]u8) ?Sim.TransactionReplay {
        if (hash[0] != 0xaa) return null;
        return .{
            .state = .{ .host = self.base.iface(), .block = block(), .hardfork = .CANCUN, .block_hash = @splat(0xbb) },
            .request = .{ .from = addr(SENDER), .to = addr(CONTRACT), .gas = 100_000 },
            .tx_hash = hash,
            .tx_index = 3,
        };
    }
};

const Fixture = struct {
    base: BaseHost = .{},
    provider: Provider = undefined,

    fn init(self: *Fixture) !void {
        self.* = .{};
        self.provider = .{ .base = &self.base };
        try self.base.code.put(testing.allocator, addr(CONTRACT), &counter_code);
        try self.base.code.put(testing.allocator, addr(OTHER), &revert_code);
        try self.base.storage.put(testing.allocator, BaseHost.key(addr(CONTRACT), 0), 4);
        try self.base.storage.put(testing.allocator, BaseHost.key(addr(CONTRACT), 1), 9);
    }

    fn deinit(self: *Fixture) void {
        testing.expectEqual(@as(usize, 0), self.base.writes) catch @panic("base host was written");
        self.base.deinit();
    }
};

const Response = struct {
    buf: std.array_list.Managed(u8),
    parsed: std.json.Parsed(std.json.Value),

    fn deinit(self: *Response) void {
        self.parsed.deinit();
        self.buf.deinit();
    }

    fn result(self: *const Response) std.json.Value {
        if (self.parsed.value.object.get("error")) |e| {
            std.debug.print("unexpected error: {s}\n", .{self.buf.items});
            _ = e;
            @panic("expected result");
        }
        return self.parsed.value.object.get("result").?;
    }

    fn errorCode(self: *const Response) i64 {
        return self.parsed.value.object.get("error").?.object.get("code").?.integer;
    }

    fn errorField(self: *const Response, name: []const u8) std.json.Value {
        return self.parsed.value.object.get("error").?.object.get(name).?;
    }
};

fn call(api: anytype, comptime handler: []const u8, comptime method: []const u8, params: []const u8) !Response {
    var buf = std.array_list.Managed(u8).init(testing.allocator);
    errdefer buf.deinit();
    const req = try std.fmt.allocPrint(testing.allocator, "{{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"" ++ method ++ "\",\"params\":{s}}}", .{params});
    defer testing.allocator.free(req);
    try @field(@TypeOf(api.*), handler)(api, testing.allocator, buf.writer(), req);
    const parsed = try std.json.parseFromSlice(std.json.Value, testing.allocator, buf.items, .{});
    return .{ .buf = buf, .parsed = parsed };
}

fn obj(v: std.json.Value, name: []const u8) std.json.Value {
    return v.object.get(name).?;
}

const counter_call = "{\"from\":\"" ++ SENDER ++ "\",\"to\":\"" ++ CONTRACT ++ "\",\"gas\":\"0x186a0\"}";
const ret_4 = "0x0000000000000000000000000000000000000000000000000000000000000005";

// ---------------------------------------------------------------------------
// eth_call
// ---------------------------------------------------------------------------

test "eth_call: executes against the provider state without writing it" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    const api = SimulationApi(Sim, Provider){ .provider = &f.provider };
    var r = try call(&api, "handle_call", "eth_call", "[" ++ counter_call ++ ",\"latest\"]");
    defer r.deinit();
    try testing.expectEqualStrings(ret_4, r.result().string);
}

test "eth_call: balance, code and nonce overrides" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    const api = SimulationApi(Sim, Provider){ .provider = &f.provider };
    // SELFBALANCE PUSH0 MSTORE PUSH1 32 PUSH0 RETURN
    var r = try call(&api, "handle_call", "eth_call", "[" ++ counter_call ++ ",\"latest\",{\"" ++ CONTRACT ++ "\":{\"balance\":\"0x2a\",\"code\":\"0x475f5260205ff3\"}}]");
    defer r.deinit();
    try testing.expectEqualStrings("0x000000000000000000000000000000000000000000000000000000000000002a", r.result().string);

    // CREATE from a sender with nonce 7 returns the deployed (empty) runtime.
    var n = try call(&api, "handle_call", "eth_call", "[{\"from\":\"" ++ SENDER ++ "\",\"input\":\"0x00\"},\"latest\",{\"" ++ SENDER ++ "\":{\"nonce\":\"0x7\"}}]");
    defer n.deinit();
    try testing.expectEqualStrings("0x", n.result().string);
}

test "eth_call: state replaces storage, stateDiff patches it" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    const api = SimulationApi(Sim, Provider){ .provider = &f.provider };
    // PUSH1 1 SLOAD PUSH0 MSTORE PUSH1 32 PUSH0 RETURN reads slot 1 (base: 9).
    const reader = "\"code\":\"0x6001545f5260205ff3\"";
    var full = try call(&api, "handle_call", "eth_call", "[" ++ counter_call ++ ",\"latest\",{\"" ++ CONTRACT ++ "\":{" ++ reader ++ ",\"state\":{\"" ++ SLOT0 ++ "\":\"0x1\"}}}]");
    defer full.deinit();
    try testing.expectEqualStrings("0x0000000000000000000000000000000000000000000000000000000000000000", full.result().string);

    var diff = try call(&api, "handle_call", "eth_call", "[" ++ counter_call ++ ",\"latest\",{\"" ++ CONTRACT ++ "\":{" ++ reader ++ ",\"stateDiff\":{\"" ++ SLOT0 ++ "\":\"0x1\"}}}]");
    defer diff.deinit();
    try testing.expectEqualStrings("0x0000000000000000000000000000000000000000000000000000000000000009", diff.result().string);

    var both = try call(&api, "handle_call", "eth_call", "[" ++ counter_call ++ ",\"latest\",{\"" ++ CONTRACT ++ "\":{\"state\":{},\"stateDiff\":{}}}]");
    defer both.deinit();
    try testing.expectEqual(@as(i64, -32602), both.errorCode());
}

test "eth_call: block overrides number, timestamp, coinbase, baseFee, prevRandao" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    const api = SimulationApi(Sim, Provider){ .provider = &f.provider };
    const overrides = "{\"number\":\"0x77\",\"timestamp\":\"0x99\",\"coinbase\":\"" ++ OTHER ++ "\",\"baseFee\":\"0x5\",\"prevRandao\":\"0x1234\"}";
    const cases = .{
        .{ "43", "0x0000000000000000000000000000000000000000000000000000000000000077" },
        .{ "42", "0x0000000000000000000000000000000000000000000000000000000000000099" },
        .{ "41", "0x0000000000000000000000000000000000000000000000000000000000003000" },
        .{ "48", "0x0000000000000000000000000000000000000000000000000000000000000005" },
        .{ "44", "0x0000000000000000000000000000000000000000000000000000000000001234" },
    };
    inline for (cases) |case| {
        const params = "[" ++ counter_call ++ ",\"latest\",{\"" ++ CONTRACT ++ "\":{\"code\":\"0x" ++ case[0] ++ "5f5260205ff3\"}}," ++ overrides ++ "]";
        var r = try call(&api, "handle_call", "eth_call", params);
        defer r.deinit();
        try testing.expectEqualStrings(case[1], r.result().string);
    }
}

test "eth_call: revert is code 3 with revert data; unknown block is an error" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    const api = SimulationApi(Sim, Provider){ .provider = &f.provider };
    var r = try call(&api, "handle_call", "eth_call", "[{\"from\":\"" ++ SENDER ++ "\",\"to\":\"" ++ OTHER ++ "\"},\"latest\"]");
    defer r.deinit();
    try testing.expectEqual(@as(i64, 3), r.errorCode());
    try testing.expectEqualStrings("execution reverted", r.errorField("message").string);
    try testing.expectEqualStrings("0xdeadbeef", r.errorField("data").string);

    var missing = try call(&api, "handle_call", "eth_call", "[" ++ counter_call ++ ",\"0x5\"]");
    defer missing.deinit();
    try testing.expectEqual(@as(i64, -32000), missing.errorCode());

    var bad = try call(&api, "handle_call", "eth_call", "[{\"to\":\"0x12\"}]");
    defer bad.deinit();
    try testing.expectEqual(@as(i64, -32602), bad.errorCode());
}

// ---------------------------------------------------------------------------
// eth_estimateGas / eth_createAccessList
// ---------------------------------------------------------------------------

test "eth_estimateGas: transfer is 0x5208; revert is code 3" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    const api = SimulationApi(Sim, Provider){ .provider = &f.provider };
    var r = try call(&api, "handle_estimate_gas", "eth_estimateGas", "[{\"from\":\"" ++ SENDER ++ "\",\"to\":\"0x0000000000000000000000000000000000009999\"}]");
    defer r.deinit();
    try testing.expectEqualStrings("0x5208", r.result().string);

    var counter = try call(&api, "handle_estimate_gas", "eth_estimateGas", "[{\"from\":\"" ++ SENDER ++ "\",\"to\":\"" ++ CONTRACT ++ "\"}]");
    defer counter.deinit();
    const gas = try codec.parseQuantity(u64, counter.result());
    try testing.expect(gas > 21_000 + 2_900);

    var rev = try call(&api, "handle_estimate_gas", "eth_estimateGas", "[{\"from\":\"" ++ SENDER ++ "\",\"to\":\"" ++ OTHER ++ "\"}]");
    defer rev.deinit();
    try testing.expectEqual(@as(i64, 3), rev.errorCode());
    try testing.expectEqualStrings("0xdeadbeef", rev.errorField("data").string);
}

test "eth_createAccessList: lists the target slot and reports gasUsed" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    const api = SimulationApi(Sim, Provider){ .provider = &f.provider };
    var r = try call(&api, "handle_create_access_list", "eth_createAccessList", "[" ++ counter_call ++ "]");
    defer r.deinit();
    const list = obj(r.result(), "accessList").array.items;
    try testing.expectEqual(@as(usize, 1), list.len);
    try testing.expectEqualStrings(CONTRACT, obj(list[0], "address").string);
    try testing.expectEqualStrings(SLOT0, obj(list[0], "storageKeys").array.items[0].string);
    try testing.expect(obj(r.result(), "gasUsed") == .string);
    try testing.expect(r.result().object.get("error") == null);
}

// ---------------------------------------------------------------------------
// eth_simulateV1
// ---------------------------------------------------------------------------

test "eth_simulateV1: sequential calls share state across blocks; reverts carry code 3" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    const api = SimulationApi(Sim, Provider){ .provider = &f.provider };
    const revert_call = "{\"from\":\"" ++ SENDER ++ "\",\"to\":\"" ++ OTHER ++ "\"}";
    const payload = "{\"blockStateCalls\":[" ++
        "{\"calls\":[" ++ counter_call ++ "," ++ revert_call ++ "," ++ counter_call ++ "]}," ++
        "{\"blockOverrides\":{\"number\":\"0x200\",\"time\":\"0x5000\"},\"stateOverrides\":{\"" ++ CONTRACT ++ "\":{\"stateDiff\":{\"" ++ SLOT0 ++ "\":\"0x10\"}}},\"calls\":[" ++ counter_call ++ "]}" ++
        "],\"validation\":false}";
    var r = try call(&api, "handle_simulate_v1", "eth_simulateV1", "[" ++ payload ++ ",\"latest\"]");
    defer r.deinit();
    const blocks = r.result().array.items;
    try testing.expectEqual(@as(usize, 2), blocks.len);
    try testing.expectEqualStrings("0x65", obj(blocks[0], "number").string);
    const calls = obj(blocks[0], "calls").array.items;
    try testing.expectEqualStrings("0x1", obj(calls[0], "status").string);
    try testing.expectEqualStrings(ret_4, obj(calls[0], "returnData").string);
    try testing.expectEqualStrings("0x0", obj(calls[1], "status").string);
    try testing.expectEqual(@as(i64, 3), obj(obj(calls[1], "error"), "code").integer);
    try testing.expectEqualStrings("0x0000000000000000000000000000000000000000000000000000000000000006", obj(calls[2], "returnData").string);

    try testing.expectEqualStrings("0x200", obj(blocks[1], "number").string);
    try testing.expectEqualStrings("0x5000", obj(blocks[1], "timestamp").string);
    try testing.expectEqualStrings(obj(blocks[0], "hash").string, obj(blocks[1], "parentHash").string);
    const b2 = obj(blocks[1], "calls").array.items;
    try testing.expectEqualStrings("0x0000000000000000000000000000000000000000000000000000000000000011", obj(b2[0], "returnData").string);
}

test "eth_simulateV1: out-of-order blocks are -38020" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    const api = SimulationApi(Sim, Provider){ .provider = &f.provider };
    var r = try call(&api, "handle_simulate_v1", "eth_simulateV1", "[{\"blockStateCalls\":[{\"blockOverrides\":{\"number\":\"0x10\"}}]}]");
    defer r.deinit();
    try testing.expectEqual(@as(i64, -38020), r.errorCode());
}

// ---------------------------------------------------------------------------
// debug_traceCall / debug_traceTransaction
// ---------------------------------------------------------------------------

test "debug_traceCall: callTracer and default struct logger" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    const api = DebugApi(Sim, Provider){ .provider = &f.provider };
    var r = try call(&api, "handle_trace_call", "debug_traceCall", "[" ++ counter_call ++ ",\"latest\",{\"tracer\":\"callTracer\"}]");
    defer r.deinit();
    try testing.expectEqualStrings("CALL", obj(r.result(), "type").string);
    try testing.expectEqualStrings(CONTRACT, obj(r.result(), "to").string);
    try testing.expectEqualStrings("0x186a0", obj(r.result(), "gas").string);

    var logs = try call(&api, "handle_trace_call", "debug_traceCall", "[" ++ counter_call ++ ",\"latest\",{\"disableStack\":true}]");
    defer logs.deinit();
    const steps = obj(logs.result(), "structLogs").array.items;
    try testing.expectEqual(@as(usize, 12), steps.len);
    try testing.expect(steps[0].object.get("stack") == null);
}

test "debug_traceCall: prestateTracer diffMode with state and block overrides" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    const api = DebugApi(Sim, Provider){ .provider = &f.provider };
    const config = "{\"tracer\":\"prestateTracer\",\"tracerConfig\":{\"diffMode\":true}," ++
        "\"stateOverrides\":{\"" ++ CONTRACT ++ "\":{\"stateDiff\":{\"" ++ SLOT0 ++ "\":\"0x40\"}}},\"blockOverrides\":{\"number\":\"0x1\"}}";
    var r = try call(&api, "handle_trace_call", "debug_traceCall", "[" ++ counter_call ++ ",\"latest\"," ++ config ++ "]");
    defer r.deinit();
    const pre = obj(obj(obj(r.result(), "pre"), CONTRACT), "storage");
    const post = obj(obj(obj(r.result(), "post"), CONTRACT), "storage");
    try testing.expectEqualStrings("0x0000000000000000000000000000000000000000000000000000000000000040", obj(pre, SLOT0).string);
    try testing.expectEqualStrings("0x0000000000000000000000000000000000000000000000000000000000000041", obj(post, SLOT0).string);
}

test "debug_traceCall: 4byteTracer, flatCallTracer, muxTracer" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    const api = DebugApi(Sim, Provider){ .provider = &f.provider };
    const selector_call = "{\"from\":\"" ++ SENDER ++ "\",\"to\":\"" ++ CONTRACT ++ "\",\"input\":\"0xa9059cbb00\"}";

    var four = try call(&api, "handle_trace_call", "debug_traceCall", "[" ++ selector_call ++ ",\"latest\",{\"tracer\":\"4byteTracer\"}]");
    defer four.deinit();
    try testing.expectEqual(@as(i64, 1), obj(four.result(), "0xa9059cbb-1").integer);

    var flat = try call(&api, "handle_trace_call", "debug_traceCall", "[" ++ selector_call ++ ",\"latest\",{\"tracer\":\"flatCallTracer\"}]");
    defer flat.deinit();
    const first = flat.result().array.items[0];
    try testing.expectEqualStrings("call", obj(first, "type").string);
    try testing.expectEqualStrings("0xa9059cbb00", obj(obj(first, "action"), "input").string);

    const mux_cfg = "{\"tracer\":\"muxTracer\",\"tracerConfig\":{\"callTracer\":{\"onlyTopCall\":true},\"4byteTracer\":null,\"prestateTracer\":{}}}";
    var mux = try call(&api, "handle_trace_call", "debug_traceCall", "[" ++ selector_call ++ ",\"latest\"," ++ mux_cfg ++ "]");
    defer mux.deinit();
    try testing.expectEqualStrings("CALL", obj(obj(mux.result(), "callTracer"), "type").string);
    try testing.expectEqual(@as(i64, 1), obj(obj(mux.result(), "4byteTracer"), "0xa9059cbb-1").integer);
    try testing.expect(obj(mux.result(), "prestateTracer").object.get(CONTRACT) != null);

    var unknown = try call(&api, "handle_trace_call", "debug_traceCall", "[" ++ selector_call ++ ",\"latest\",{\"tracer\":\"jsTracer\"}]");
    defer unknown.deinit();
    try testing.expectEqual(@as(i64, -32602), unknown.errorCode());
}

test "debug_traceTransaction: replays through the provider" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    const api = DebugApi(Sim, Provider){ .provider = &f.provider };
    const hash = "\"0x" ++ "aa" ** 32 ++ "\"";
    var r = try call(&api, "handle_trace_transaction", "debug_traceTransaction", "[" ++ hash ++ ",{\"tracer\":\"callTracer\"}]");
    defer r.deinit();
    try testing.expectEqualStrings(ret_4, obj(r.result(), "output").string);

    var missing = try call(&api, "handle_trace_transaction", "debug_traceTransaction", "[\"0x" ++ "11" ** 32 ++ "\"]");
    defer missing.deinit();
    try testing.expectEqual(@as(i64, -32000), missing.errorCode());
}

// ---------------------------------------------------------------------------
// trace_call / trace_transaction
// ---------------------------------------------------------------------------

test "trace_call: [trace, stateDiff]" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    const api = TraceApi(Sim, Provider){ .provider = &f.provider };
    var r = try call(&api, "handle_trace_call", "trace_call", "[" ++ counter_call ++ ",[\"trace\",\"stateDiff\"],\"latest\"]");
    defer r.deinit();
    const res = r.result();
    try testing.expectEqualStrings(ret_4, obj(res, "output").string);
    try testing.expect(obj(res, "vmTrace") == .null);
    const t = obj(res, "trace").array.items[0];
    try testing.expectEqualStrings("call", obj(t, "type").string);
    try testing.expectEqualStrings(ret_4, obj(obj(t, "result"), "output").string);
    const slot = obj(obj(obj(obj(obj(res, "stateDiff"), CONTRACT), "storage"), SLOT0), "*");
    try testing.expectEqualStrings("0x0000000000000000000000000000000000000000000000000000000000000004", obj(slot, "from").string);
    try testing.expectEqualStrings(ret_4, obj(slot, "to").string);

    var only = try call(&api, "handle_trace_call", "trace_call", "[" ++ counter_call ++ ",[\"stateDiff\"]]");
    defer only.deinit();
    try testing.expectEqual(@as(usize, 0), obj(only.result(), "trace").array.items.len);
    try testing.expect(obj(only.result(), "stateDiff") == .object);

    var bad = try call(&api, "handle_trace_call", "trace_call", "[" ++ counter_call ++ ",[\"bogus\"]]");
    defer bad.deinit();
    try testing.expectEqual(@as(i64, -32602), bad.errorCode());
}

test "trace_transaction: flat traces carry block and tx position" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    const api = TraceApi(Sim, Provider){ .provider = &f.provider };
    var r = try call(&api, "handle_trace_transaction", "trace_transaction", "[\"0x" ++ "aa" ** 32 ++ "\"]");
    defer r.deinit();
    const t = r.result().array.items[0];
    try testing.expectEqual(@as(i64, 100), obj(t, "blockNumber").integer);
    try testing.expectEqual(@as(i64, 3), obj(t, "transactionPosition").integer);
    try testing.expectEqualStrings("0x" ++ "bb" ** 32, obj(t, "blockHash").string);
    try testing.expectEqualStrings("0x" ++ "aa" ** 32, obj(t, "transactionHash").string);
}

const StoredTraceProvider = struct {
    state: *const Provider,
    store: *const evm.TraceStore,

    /// Hash 0x64.. is block 100 as stored; 0x99.. is a sibling at the same
    /// height whose traces are not in the store.
    pub fn resolveBlock(self: *const StoredTraceProvider, tag: codec.BlockTag) ?Sim.BlockState {
        if (tag == .hash) {
            const canonical = std.mem.eql(u8, &tag.hash, &@as([32]u8, @splat(0x64)));
            const sibling = std.mem.eql(u8, &tag.hash, &@as([32]u8, @splat(0x99)));
            if (!canonical and !sibling) return null;
            var state = self.state.resolveBlock(.{ .number = 100 }).?;
            state.block_hash = tag.hash;
            return state;
        }
        return self.state.resolveBlock(tag);
    }

    pub fn traceStore(self: *const StoredTraceProvider) *const evm.TraceStore {
        return self.store;
    }
};

fn storeTrace(store: *evm.TraceStore, provider: *const Provider, block_number: u64, index: u32, from: Address, to: Address) !void {
    var tracer = Sim.tracers.CallTracer.init(testing.allocator, .{});
    defer tracer.deinit();
    var result = try Sim.simulateCall(testing.allocator, provider.base.iface(), Provider.block(), provider.hardfork, .{
        .from = from,
        .to = to,
        .gas = 100_000,
    }, null, null, tracer.inspector());
    defer result.deinit(testing.allocator);
    try store.recordCallTrace(block_number, @splat(@intCast(block_number)), @splat(@intCast(index + 1)), index, &tracer);
}

test "trace_block by hash returns only that block's rows; requireCanonical reaches the provider" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    var store = evm.TraceStore.init(testing.allocator, .{});
    defer store.deinit();
    try storeTrace(&store, &f.provider, 100, 0, addr(SENDER), addr(OTHER));
    const provider: StoredTraceProvider = .{ .state = &f.provider, .store = &store };
    const api = TraceApi(Sim, StoredTraceProvider){ .provider = &provider };
    const canonical = "\"0x" ++ "64" ** 32 ++ "\"";
    const sibling = "\"0x" ++ "99" ** 32 ++ "\"";

    for ([_][]const u8{ "[" ++ canonical ++ "]", "[{\"blockHash\":" ++ canonical ++ "}]", "[{\"blockNumber\":\"0x64\"}]" }) |params| {
        var found = try call(&api, "handle_trace_block", "trace_block", params);
        defer found.deinit();
        try testing.expectEqual(@as(usize, 1), found.result().array.items.len);
    }
    // Same height, different hash: no rows from block 0x64.. leak through.
    for ([_][]const u8{ "[" ++ sibling ++ "]", "[{\"blockHash\":" ++ sibling ++ "}]" }) |params| {
        var other = try call(&api, "handle_trace_block", "trace_block", params);
        defer other.deinit();
        try testing.expectEqual(@as(usize, 0), other.result().array.items.len);
    }
    for ([_][]const u8{
        "[{\"blockHash\":" ++ canonical ++ ",\"blockNumber\":\"0x64\"}]",
        "[{\"blockNumber\":100}]",
        "[{\"blockNumber\":\"latest\"}]",
        "[{}]",
    }) |params| {
        var invalid = try call(&api, "handle_trace_block", "trace_block", params);
        defer invalid.deinit();
        try testing.expectEqual(@as(i64, -32602), invalid.errorCode());
    }

    const CanonicalProvider = struct {
        traces: StoredTraceProvider,
        last_require_canonical: *?bool,

        pub fn resolveBlock(self: *const @This(), tag: codec.BlockTag) ?Sim.BlockState {
            return self.traces.resolveBlock(tag);
        }

        /// 0x99.. is not canonical.
        pub fn resolveBlockCanonical(self: *const @This(), tag: codec.BlockTag, require_canonical: bool) ?Sim.BlockState {
            self.last_require_canonical.* = require_canonical;
            if (require_canonical and tag == .hash and tag.hash[0] == 0x99) return null;
            return self.traces.resolveBlock(tag);
        }

        pub fn traceStore(self: *const @This()) *const evm.TraceStore {
            return self.traces.store;
        }
    };
    var seen: ?bool = null;
    const canonical_provider: CanonicalProvider = .{ .traces = provider, .last_require_canonical = &seen };
    const canonical_api = TraceApi(Sim, CanonicalProvider){ .provider = &canonical_provider };
    var required = try call(&canonical_api, "handle_trace_block", "trace_block", "[{\"blockHash\":" ++ sibling ++ ",\"requireCanonical\":true}]");
    defer required.deinit();
    try testing.expectEqual(@as(i64, -32000), required.errorCode());
    try testing.expectEqual(true, seen.?);
    var relaxed = try call(&canonical_api, "handle_trace_block", "trace_block", "[{\"blockHash\":" ++ sibling ++ "}]");
    defer relaxed.deinit();
    try testing.expectEqual(@as(usize, 0), relaxed.result().array.items.len);
    try testing.expectEqual(false, seen.?);
}

test "trace_block and trace_filter query the provider's indexed traces" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    var store = evm.TraceStore.init(testing.allocator, .{});
    defer store.deinit();
    try storeTrace(&store, &f.provider, 100, 1, addr(CONTRACT), addr(OTHER));
    try storeTrace(&store, &f.provider, 99, 0, addr(SENDER), addr(CONTRACT));
    try storeTrace(&store, &f.provider, 100, 0, addr(SENDER), addr(OTHER));
    try storeTrace(&store, &f.provider, 98, 0, addr(SENDER), addr(CONTRACT));
    const provider: StoredTraceProvider = .{ .state = &f.provider, .store = &store };
    const api = TraceApi(Sim, StoredTraceProvider){ .provider = &provider };

    for ([_][]const u8{ "[\"latest\"]", "[\"pending\"]", "[\"safe\"]", "[\"finalized\"]", "[\"0x64\"]" }) |params| {
        var response = try call(&api, "handle_trace_block", "trace_block", params);
        defer response.deinit();
        const entries = response.result().array.items;
        try testing.expectEqual(@as(usize, 2), entries.len);
        try testing.expectEqual(@as(i64, 100), obj(entries[0], "blockNumber").integer);
        try testing.expectEqualStrings("0x" ++ "64" ** 32, obj(entries[0], "blockHash").string);
        try testing.expectEqual(@as(i64, 0), obj(entries[0], "transactionPosition").integer);
        try testing.expectEqualStrings("0x" ++ "01" ** 32, obj(entries[0], "transactionHash").string);
        try testing.expectEqualStrings(SENDER, obj(obj(entries[0], "action"), "from").string);
        try testing.expectEqualStrings("Reverted", obj(entries[1], "error").string);
    }
    var empty = try call(&api, "handle_trace_block", "trace_block", "[\"earliest\"]");
    defer empty.deinit();
    try testing.expectEqual(@as(usize, 0), empty.result().array.items.len);

    const FilterProvider = struct {
        traces: StoredTraceProvider,

        pub fn resolveBlock(self: *const @This(), tag: codec.BlockTag) ?Sim.BlockState {
            return self.traces.resolveBlock(tag);
        }

        pub fn filterTraces(self: *const @This(), allocator: std.mem.Allocator, query: evm.TraceFilter) ![]const *const evm.trace_store.StoredTraceEntry {
            return self.traces.store.filter(allocator, query);
        }
    };
    const filter_provider: FilterProvider = .{ .traces = provider };
    const filter_api = TraceApi(Sim, FilterProvider){ .provider = &filter_provider };
    var direct = try call(&filter_api, "handle_trace_block", "trace_block", "[\"0x63\"]");
    defer direct.deinit();
    try testing.expectEqual(@as(i64, 99), obj(direct.result().array.items[0], "blockNumber").integer);

    const page_params = "[{\"fromBlock\":\"0x63\",\"toBlock\":\"latest\",\"fromAddress\":\"" ++ SENDER ++
        "\",\"toAddress\":[\"" ++ CONTRACT ++ "\",\"" ++ OTHER ++ "\"],\"after\":1,\"count\":1}]";
    var page = try call(&api, "handle_trace_filter", "trace_filter", page_params);
    defer page.deinit();
    const entries = page.result().array.items;
    try testing.expectEqual(@as(usize, 1), entries.len);
    try testing.expectEqual(@as(i64, 100), obj(entries[0], "blockNumber").integer);
    try testing.expectEqualStrings(OTHER, obj(obj(entries[0], "action"), "to").string);

    const address_params = "[{\"fromAddress\":[\"" ++ CONTRACT ++ "\"],\"toAddress\":\"" ++ OTHER ++ "\"}]";
    var address_match = try call(&api, "handle_trace_filter", "trace_filter", address_params);
    defer address_match.deinit();
    try testing.expectEqual(@as(usize, 1), address_match.result().array.items.len);
    try testing.expectEqual(@as(i64, 1), obj(address_match.result().array.items[0], "transactionPosition").integer);

    const hex_page = "[{\"fromBlock\":\"0x63\",\"toBlock\":\"latest\",\"fromAddress\":\"" ++ SENDER ++
        "\",\"toAddress\":[\"" ++ CONTRACT ++ "\",\"" ++ OTHER ++ "\"],\"after\":\"0x1\",\"count\":\"0x1\"}]";
    var hex = try call(&api, "handle_trace_filter", "trace_filter", hex_page);
    defer hex.deinit();
    try testing.expectEqualStrings(page.buf.items, hex.buf.items);

    for ([_][]const u8{ "[{\"after\":-1}]", "[{\"count\":\"1\"}]", "[{\"toAddress\":[42]}]", "[{},{}]", "[]" }) |params| {
        var invalid = try call(&api, "handle_trace_filter", "trace_filter", params);
        defer invalid.deinit();
        try testing.expectEqual(@as(i64, -32602), invalid.errorCode());
    }
    for ([_][]const u8{ "[\"latest\",{}]", "[\"0x64\",null]", "[]" }) |params| {
        var invalid = try call(&api, "handle_trace_block", "trace_block", params);
        defer invalid.deinit();
        try testing.expectEqual(@as(i64, -32602), invalid.errorCode());
    }
    const old_api = TraceApi(Sim, Provider){ .provider = &f.provider };
    var unsupported = try call(&old_api, "handle_trace_filter", "trace_filter", "[{}]");
    defer unsupported.deinit();
    try testing.expectEqual(@as(i64, -32601), unsupported.errorCode());
}

fn valueCall(comptime target: u16, comptime value: u8) [14]u8 {
    return .{ 0x5f, 0x5f, 0x5f, 0x5f, 0x60, value, 0x61, target >> 8, @truncate(target), 0x61, 0xff, 0xff, 0xf1, 0x50 };
}

test "eth_simulateV1: traceTransfers puts a value call's Transfer before the callee's LOG" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    try f.base.balances.put(testing.allocator, addr(SENDER), 100);
    // LOG1(topic 0x2a) STOP.
    try f.base.code.put(testing.allocator, addr(CONTRACT), &.{ 0x60, 0x2a, 0x5f, 0x5f, 0xa1, 0x00 });
    const api = SimulationApi(Sim, Provider){ .provider = &f.provider };
    const params = "[{\"traceTransfers\":true,\"blockStateCalls\":[{\"calls\":[" ++
        "{\"from\":\"" ++ SENDER ++ "\",\"to\":\"" ++ CONTRACT ++ "\",\"value\":\"0x5\"}," ++
        "{\"from\":\"" ++ SENDER ++ "\",\"to\":\"" ++ CONTRACT ++ "\",\"value\":\"0x6\"}]}]}]";
    var response = try call(&api, "handle_simulate_v1", "eth_simulateV1", params);
    defer response.deinit();
    const calls = obj(response.result().array.items[0], "calls").array.items;
    var log_index: usize = 0;
    for (calls, [_]u256{ 5, 6 }) |entry, value| {
        const logs = obj(entry, "logs").array.items;
        try testing.expectEqual(@as(usize, 2), logs.len);
        try testing.expectEqualStrings("0x" ++ "ee" ** 20, obj(logs[0], "address").string);
        try testing.expectEqual(value, try codec.parseWord(obj(logs[0], "data")));
        try testing.expectEqualStrings(CONTRACT, obj(logs[1], "address").string);
        try testing.expectEqual(@as(u256, 0x2a), try codec.parseWord(obj(logs[1], "topics").array.items[0]));
        for (logs) |log| {
            try testing.expectEqual(log_index, try codec.parseQuantity(usize, obj(log, "logIndex")));
            log_index += 1;
        }
    }
}

test "eth_simulateV1: traceTransfers preserves native logs and skips reverted frames" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    try f.base.balances.put(testing.allocator, addr(SENDER), 100);
    try f.base.balances.put(testing.allocator, Address.fromU256(0x6000), 7);
    const root = valueCall(0x4000, 1) ++ valueCall(0x3000, 2) ++ valueCall(0x6000, 0) ++ [_]u8{ 0x5f, 0x5f, 0xa0, 0x00 };
    // The reverted frame's transfers and its LOG0 must both disappear.
    const reverter = valueCall(0x5000, 1) ++ [_]u8{ 0x5f, 0x5f, 0xa0, 0x5f, 0x5f, 0xfd };
    try f.base.code.put(testing.allocator, addr(CONTRACT), &root);
    try f.base.code.put(testing.allocator, addr(OTHER), &reverter);
    try f.base.code.put(testing.allocator, Address.fromU256(0x6000), &.{ 0x61, 0x70, 0x00, 0xff });
    const api = SimulationApi(Sim, Provider){ .provider = &f.provider };
    const transfer_call = "{\"from\":\"" ++ SENDER ++ "\",\"to\":\"" ++ CONTRACT ++ "\",\"value\":\"0xa\"}";
    const root_revert = "{\"from\":\"" ++ SENDER ++ "\",\"to\":\"" ++ OTHER ++ "\",\"value\":\"0x3\"}";
    const input = "\"blockStateCalls\":[{\"calls\":[" ++ transfer_call ++ "," ++ root_revert ++ "]}]";
    var response = try call(&api, "handle_simulate_v1", "eth_simulateV1", "[{\"traceTransfers\":true," ++ input ++ "}]");
    defer response.deinit();
    const block = response.result().array.items[0];
    const calls = obj(block, "calls").array.items;
    try testing.expectEqualStrings("0x1", obj(calls[0], "status").string);
    try testing.expectEqualStrings("0x0", obj(calls[1], "status").string);
    try testing.expectEqual(@as(usize, 0), obj(calls[1], "logs").array.items.len);
    // Emission order: entry transfer, nested call transfer, SELFDESTRUCT
    // transfer, then the root's LOG0.
    const logs = obj(calls[0], "logs").array.items;
    try testing.expectEqual(@as(usize, 4), logs.len);
    try testing.expectEqualStrings(CONTRACT, obj(logs[3], "address").string);
    try testing.expectEqual(@as(usize, 3), try codec.parseQuantity(usize, obj(logs[3], "logIndex")));
    const tx_hash = obj(block, "transactions").array.items[0].string;
    for (logs[0..3], [_]u256{ 0x1000, 0x2000, 0x6000 }, [_]u256{ 0x2000, 0x4000, 0x7000 }, [_]u256{ 10, 1, 7 }, 0..) |log, from, to, value, index| {
        try testing.expectEqualStrings("0x" ++ "ee" ** 20, obj(log, "address").string);
        const topics = obj(log, "topics").array.items;
        try testing.expectEqual(@as(usize, 3), topics.len);
        try testing.expectEqualStrings("0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef", topics[0].string);
        try testing.expectEqual(from, try codec.parseWord(topics[1]));
        try testing.expectEqual(to, try codec.parseWord(topics[2]));
        try testing.expectEqual(value, try codec.parseWord(obj(log, "data")));
        try testing.expectEqual(@as(usize, 66), topics[1].string.len);
        try testing.expectEqual(@as(usize, 66), topics[2].string.len);
        try testing.expectEqual(@as(usize, 66), obj(log, "data").string.len);
        try testing.expectEqualStrings(tx_hash, obj(log, "transactionHash").string);
        try testing.expectEqualStrings("0x0", obj(log, "transactionIndex").string);
        try testing.expectEqual(index, try codec.parseQuantity(usize, obj(log, "logIndex")));
    }
    var defaults = try call(&api, "handle_simulate_v1", "eth_simulateV1", "[{" ++ input ++ "}]");
    defer defaults.deinit();
    try testing.expectEqual(@as(usize, 1), obj(obj(defaults.result().array.items[0], "calls").array.items[0], "logs").array.items.len);
}

test "eth_simulateV1: returnFullTransactions expands mined transaction hashes" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    try f.base.balances.put(testing.allocator, addr(SENDER), 10_000_000);
    const api = SimulationApi(Sim, Provider){ .provider = &f.provider };
    const input = "\"blockStateCalls\":[{\"blockOverrides\":{\"baseFeePerGas\":\"0x2\"},\"calls\":[" ++
        "{\"from\":\"" ++ SENDER ++ "\",\"to\":\"" ++ CONTRACT ++ "\",\"gas\":\"0x1\"}," ++
        "{\"from\":\"" ++ SENDER ++ "\",\"to\":\"" ++ CONTRACT ++ "\",\"gas\":\"0x186a0\",\"maxFeePerGas\":\"0x4\",\"maxPriorityFeePerGas\":\"0x1\",\"value\":\"0x4\",\"input\":\"0x1234\"}," ++
        "{\"from\":\"" ++ SENDER ++ "\",\"gas\":\"0x186a0\",\"gasPrice\":\"0x2\"}," ++
        "{\"from\":\"" ++ SENDER ++ "\",\"to\":\"" ++ CONTRACT ++ "\",\"gas\":\"0x186a0\",\"gasPrice\":\"0x2\",\"accessList\":[{\"address\":\"" ++ OTHER ++ "\",\"storageKeys\":[\"" ++ SLOT0 ++ "\"]}]}," ++
        "{\"from\":\"" ++ SENDER ++ "\",\"to\":\"" ++ CONTRACT ++ "\",\"gas\":\"0x186a0\",\"maxFeePerGas\":\"0x4\",\"maxPriorityFeePerGas\":\"0x1\",\"maxFeePerBlobGas\":\"0x3\",\"blobVersionedHashes\":[\"0x01" ++ "00" ** 31 ++ "\"]}]}]";
    var full = try call(&api, "handle_simulate_v1", "eth_simulateV1", "[{\"returnFullTransactions\":true," ++ input ++ "}]");
    defer full.deinit();
    var hashes = try call(&api, "handle_simulate_v1", "eth_simulateV1", "[{" ++ input ++ "}]");
    defer hashes.deinit();
    const block = full.result().array.items[0];
    const transactions = obj(block, "transactions").array.items;
    const tx_hashes = obj(hashes.result().array.items[0], "transactions").array.items;
    try testing.expectEqual(@as(usize, 4), transactions.len);
    try testing.expectEqual(transactions.len, tx_hashes.len);
    for (transactions, tx_hashes, 0..) |tx, hash, index| {
        _ = try codec.parseHash(hash);
        try testing.expectEqualStrings(hash.string, obj(tx, "hash").string);
        try testing.expectEqualStrings(obj(block, "hash").string, obj(tx, "blockHash").string);
        try testing.expectEqualStrings("0x65", obj(tx, "blockNumber").string);
        try testing.expectEqual(index, try codec.parseQuantity(usize, obj(tx, "transactionIndex")));
        try testing.expectEqual(index, try codec.parseQuantity(usize, obj(tx, "nonce")));
        try testing.expectEqualStrings(SENDER, obj(tx, "from").string);
        try testing.expectEqualStrings("0x186a0", obj(tx, "gas").string);
        try testing.expectEqualStrings("0x1", obj(tx, "chainId").string);
        for ([_][]const u8{ "v", "r", "s" }) |name| try testing.expectEqualStrings("0x0", obj(tx, name).string);
    }
    try testing.expect(!std.mem.eql(u8, tx_hashes[0].string, tx_hashes[1].string));
    try testing.expectEqualStrings(CONTRACT, obj(transactions[0], "to").string);
    try testing.expectEqualStrings("0x3", obj(transactions[0], "gasPrice").string);
    try testing.expectEqualStrings("0x4", obj(transactions[0], "value").string);
    try testing.expectEqualStrings("0x1234", obj(transactions[0], "input").string);
    try testing.expectEqualStrings("0x2", obj(transactions[0], "type").string);
    try testing.expectEqualStrings("0x4", obj(transactions[0], "maxFeePerGas").string);
    try testing.expectEqualStrings("0x1", obj(transactions[0], "maxPriorityFeePerGas").string);
    try testing.expectEqual(@as(usize, 0), obj(transactions[0], "accessList").array.items.len);
    try testing.expectEqualStrings("0x0", obj(transactions[0], "yParity").string);

    const legacy = transactions[1].object;
    try testing.expect(obj(transactions[1], "to") == .null);
    try testing.expectEqualStrings("0x0", obj(transactions[1], "type").string);
    try testing.expectEqualStrings("0x2", obj(transactions[1], "gasPrice").string);
    for ([_][]const u8{ "maxFeePerGas", "accessList", "yParity", "authorizationList", "blobVersionedHashes" }) |name| try testing.expect(legacy.get(name) == null);

    const access = transactions[2];
    try testing.expectEqualStrings("0x1", obj(access, "type").string);
    try testing.expectEqualStrings("0x2", obj(access, "gasPrice").string);
    try testing.expect(access.object.get("maxFeePerGas") == null);
    const entry = obj(access, "accessList").array.items[0];
    try testing.expectEqualStrings(OTHER, obj(entry, "address").string);
    try testing.expectEqualStrings(SLOT0, obj(entry, "storageKeys").array.items[0].string);

    const blob = transactions[3];
    try testing.expectEqualStrings("0x3", obj(blob, "type").string);
    try testing.expectEqualStrings("0x4", obj(blob, "maxFeePerGas").string);
    try testing.expectEqualStrings("0x3", obj(blob, "maxFeePerBlobGas").string);
    try testing.expectEqualStrings("0x01" ++ "00" ** 31, obj(blob, "blobVersionedHashes").array.items[0].string);
    try testing.expect(blob.object.get("authorizationList") == null);
    try testing.expectEqual(@as(usize, 5), obj(block, "calls").array.items.len);
}

/// Address of `SIGNER_KEY`.
const SIGNER = "0x7e5f4552091a69125d5dfcb7b8c2659029395bdf";
const SIGNER_KEY = [_]u8{0} ** 31 ++ [_]u8{1};
const OTHER_KEY = [_]u8{0} ** 31 ++ [_]u8{2};

const Parity = enum { y_parity, v };

/// A real EIP-7702 tuple JSON: `key` signs
/// keccak256(0x05 || rlp([chain_id, address, nonce])).
fn signedTuple(arena: std.mem.Allocator, key: [32]u8, chain_id: u64, address: Address, nonce: u64, parity: Parity) ![]const u8 {
    const chain = try primitives.Rlp.encode(arena, chain_id);
    const target = try primitives.Rlp.encodeBytes(arena, &address.bytes);
    const n = try primitives.Rlp.encode(arena, nonce);
    const payload_len = chain.len + target.len + n.len;
    std.debug.assert(payload_len < 56);
    const preimage = try std.mem.concat(arena, u8, &.{ &.{ 0x05, @as(u8, @intCast(0xc0 + payload_len)) }, chain, target, n });
    var digest: [32]u8 = undefined;
    std.crypto.hash.sha3.Keccak256.hash(preimage, &digest, .{});
    const sig = try crypto.unaudited_signHash(digest, key);
    const parity_json = switch (parity) {
        .y_parity => try std.fmt.allocPrint(arena, "\"yParity\":\"0x{x}\"", .{sig.yParity()}),
        .v => try std.fmt.allocPrint(arena, "\"v\":\"0x{x}\"", .{@as(u16, sig.yParity()) + 27}),
    };
    return std.fmt.allocPrint(arena, "{{\"chainId\":\"0x{x}\",\"address\":\"0x{x}\",\"nonce\":\"0x{x}\",{s},\"r\":\"0x{x}\",\"s\":\"0x{x}\"}}", .{
        chain_id, @as([]const u8, &address.bytes), nonce, parity_json, sig.r, sig.s,
    });
}

/// `eth_call` from SENDER to SIGNER with `tuples` as the authorization list.
fn delegatedCall(arena: std.mem.Allocator, tuples: []const []const u8) ![]const u8 {
    return std.fmt.allocPrint(arena, "[{{\"from\":\"" ++ SENDER ++ "\",\"to\":\"" ++ SIGNER ++ "\",\"authorizationList\":[{s}]}}]", .{
        try std.mem.join(arena, ",", tuples),
    });
}

test "authorizationList: signed eth_call delegation and clearing" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    f.provider.hardfork = .PRAGUE;
    var arena_state = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();
    const api = SimulationApi(Sim, Provider){ .provider = &f.provider };
    const install = try signedTuple(arena, SIGNER_KEY, 1, addr(CONTRACT), 0, .v);
    const clear = try signedTuple(arena, SIGNER_KEY, 0, Address.ZERO, 1, .y_parity);

    var installed = try call(&api, "handle_call", "eth_call", try delegatedCall(arena, &.{install}));
    defer installed.deinit();
    try testing.expectEqualStrings("0x" ++ "00" ** 31 ++ "01", installed.result().string);

    var cleared = try call(&api, "handle_call", "eth_call", try delegatedCall(arena, &.{ install, clear }));
    defer cleared.deinit();
    try testing.expectEqualStrings("0x", cleared.result().string);

    const wrong_chain = try signedTuple(arena, SIGNER_KEY, 2, addr(CONTRACT), 0, .y_parity);
    const wrong_nonce = try signedTuple(arena, SIGNER_KEY, 1, addr(CONTRACT), 1, .y_parity);
    var skipped = try call(&api, "handle_call", "eth_call", try delegatedCall(arena, &.{ wrong_chain, wrong_nonce }));
    defer skipped.deinit();
    try testing.expectEqualStrings("0x", skipped.result().string);
}

test "authorizationList: RPC authority never bypasses signature recovery" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    f.provider.hardfork = .PRAGUE;
    var arena_state = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();
    const api = SimulationApi(Sim, Provider){ .provider = &f.provider };

    // Signed by another key, but claims SIGNER as authority: SIGNER stays
    // undelegated, so the call returns no data.
    const other = try signedTuple(arena, OTHER_KEY, 1, addr(CONTRACT), 0, .y_parity);
    const forged = try std.fmt.allocPrint(arena, "{s},\"authority\":\"" ++ SIGNER ++ "\"}}", .{other[0 .. other.len - 1]});
    var ignored = try call(&api, "handle_call", "eth_call", try delegatedCall(arena, &.{forged}));
    defer ignored.deinit();
    try testing.expectEqualStrings("0x", ignored.result().string);

    // High-s twin of a valid signature is rejected (EIP-2 low-s rule).
    const valid = try signedTuple(arena, SIGNER_KEY, 1, addr(CONTRACT), 0, .y_parity);
    var valid_parsed = try std.json.parseFromSlice(std.json.Value, arena, valid, .{});
    defer valid_parsed.deinit();
    const s_value = try codec.parseQuantity(u256, valid_parsed.value.object.get("s").?);
    const y_value = try codec.parseQuantity(u8, valid_parsed.value.object.get("yParity").?);
    const high_s = try std.fmt.allocPrint(arena, "{{\"chainId\":\"0x1\",\"address\":\"" ++ CONTRACT ++ "\",\"nonce\":\"0x0\",\"yParity\":\"0x{x}\",\"r\":{s},\"s\":\"0x{x}\"}}", .{
        y_value ^ 1, try std.json.Stringify.valueAlloc(arena, valid_parsed.value.object.get("r").?, .{}), crypto.SECP256K1_N - s_value,
    });
    var rejected_s = try call(&api, "handle_call", "eth_call", try delegatedCall(arena, &.{high_s}));
    defer rejected_s.deinit();
    try testing.expectEqualStrings("0x", rejected_s.result().string);

    const bad_parity = try std.fmt.allocPrint(arena, "{{\"chainId\":\"0x1\",\"address\":\"" ++ CONTRACT ++ "\",\"nonce\":\"0x0\",\"yParity\":\"0x2\",\"r\":{s},\"s\":\"0x{x}\"}}", .{
        try std.json.Stringify.valueAlloc(arena, valid_parsed.value.object.get("r").?, .{}), s_value,
    });
    var rejected_parity = try call(&api, "handle_call", "eth_call", try delegatedCall(arena, &.{bad_parity}));
    defer rejected_parity.deinit();
    try testing.expectEqualStrings("0x", rejected_parity.result().string);

    const unsigned = "{\"chainId\":\"0x1\",\"address\":\"" ++ CONTRACT ++ "\",\"nonce\":\"0x0\",\"authority\":\"" ++ SIGNER ++ "\"}";
    var missing_signature = try call(&api, "handle_call", "eth_call", try delegatedCall(arena, &.{unsigned}));
    defer missing_signature.deinit();
    try testing.expectEqual(@as(i64, -32602), missing_signature.errorCode());
}

test "authorizationList: an explicitly empty list is an invalid set-code transaction" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    f.provider.hardfork = .PRAGUE;
    const api = SimulationApi(Sim, Provider){ .provider = &f.provider };
    const empty_call = "{\"from\":\"" ++ SENDER ++ "\",\"to\":\"" ++ CONTRACT ++ "\",\"authorizationList\":[]}";

    var rejected = try call(&api, "handle_call", "eth_call", "[" ++ empty_call ++ "]");
    defer rejected.deinit();
    try testing.expectEqual(@as(i64, -32602), rejected.errorCode());
    try testing.expectEqualStrings("EIP-7702 transaction with empty auth list", rejected.errorField("message").string);

    var simulated = try call(&api, "handle_simulate_v1", "eth_simulateV1", "[{\"blockStateCalls\":[{\"calls\":[" ++ empty_call ++ "]}]}]");
    defer simulated.deinit();
    const entry = obj(simulated.result().array.items[0], "calls").array.items[0];
    try testing.expectEqualStrings("0x0", obj(entry, "status").string);
    try testing.expectEqual(@as(i64, -32602), obj(obj(entry, "error"), "code").integer);
    try testing.expectEqual(@as(usize, 0), obj(simulated.result().array.items[0], "transactions").array.items.len);

    // Before Prague the field is ignored, as it is not a set-code fork.
    f.provider.hardfork = .CANCUN;
    var cancun = try call(&api, "handle_call", "eth_call", "[" ++ empty_call ++ "]");
    defer cancun.deinit();
    try testing.expectEqualStrings(ret_4, cancun.result().string);
}

test "authorizationList: eth_simulateV1 applies valid tuples across blocks, including on revert" {
    var f: Fixture = undefined;
    try f.init();
    defer f.deinit();
    f.provider.hardfork = .PRAGUE;
    var arena_state = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();
    const api = SimulationApi(Sim, Provider){ .provider = &f.provider };
    const skip_chain = try signedTuple(arena, SIGNER_KEY, 2, addr(CONTRACT), 0, .y_parity);
    const skip_nonce = try signedTuple(arena, SIGNER_KEY, 1, addr(CONTRACT), 1, .y_parity);
    const install = try signedTuple(arena, SIGNER_KEY, 1, addr(CONTRACT), 0, .y_parity);
    const clear = try signedTuple(arena, SIGNER_KEY, 0, Address.ZERO, 1, .y_parity);
    const delegate_call = "{\"from\":\"" ++ SENDER ++ "\",\"to\":\"" ++ SIGNER ++ "\"}";
    const call_with_auth = "{{\"from\":\"" ++ SENDER ++ "\",\"to\":\"" ++ SIGNER ++ "\",\"authorizationList\":[{s}]}}";
    const reverting_install = "{{\"from\":\"" ++ SENDER ++ "\",\"to\":\"" ++ OTHER ++ "\",\"authorizationList\":[{s}]}}";
    const params = try std.fmt.allocPrint(arena, "[{{\"returnFullTransactions\":true,\"blockStateCalls\":[{{\"calls\":[" ++
        call_with_auth ++ "," ++ call_with_auth ++ "," ++ reverting_install ++ "]}},{{\"calls\":[{s}," ++ call_with_auth ++ ",{s}]}}]}}]", .{
        skip_chain, skip_nonce, install, delegate_call, clear, delegate_call,
    });
    var response = try call(&api, "handle_simulate_v1", "eth_simulateV1", params);
    defer response.deinit();
    const blocks = response.result().array.items;
    const first = obj(blocks[0], "calls").array.items;
    try testing.expectEqualStrings("0x", obj(first[0], "returnData").string);
    try testing.expectEqualStrings("0x", obj(first[1], "returnData").string);
    try testing.expectEqualStrings("0x0", obj(first[2], "status").string);
    const second = obj(blocks[1], "calls").array.items;
    for (second, [_][]const u8{ "0x" ++ "00" ** 31 ++ "01", "0x", "0x" }) |entry, expected| {
        try testing.expectEqualStrings("0x1", obj(entry, "status").string);
        try testing.expectEqualStrings(expected, obj(entry, "returnData").string);
    }
    const txs = obj(blocks[1], "transactions").array.items;
    try testing.expectEqualStrings("0x3", obj(txs[0], "nonce").string);
    try testing.expectEqualStrings("0x4", obj(txs[1], "type").string);

    // The full set-code transaction echoes the signed tuple.
    var clear_parsed = try std.json.parseFromSlice(std.json.Value, arena, clear, .{});
    defer clear_parsed.deinit();
    const echoed = obj(txs[1], "authorizationList").array.items;
    try testing.expectEqual(@as(usize, 1), echoed.len);
    for ([_][]const u8{ "chainId", "address", "nonce", "yParity", "r", "s" }) |name| {
        try testing.expectEqualStrings(clear_parsed.value.object.get(name).?.string, obj(echoed[0], name).string);
    }
    try testing.expectEqualStrings("0x0", obj(txs[1], "maxFeePerGas").string);
    try testing.expectEqual(@as(usize, 0), obj(txs[1], "accessList").array.items.len);
}
