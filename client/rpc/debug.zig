//! `debug_traceCall` and `debug_traceTransaction` (Geth tracer API).
//!
//! Tracers: struct logger (default), `callTracer`, `flatCallTracer`,
//! `prestateTracer` (with `diffMode`), `4byteTracer`, `muxTracer`, plus the
//! native `gasProfiler` and `coverageTracer`.
//!
//! `Provider` must define
//! `pub fn resolveBlock(self: *const Provider, tag: BlockTag) ?Sim.BlockState`
//! and, for `debug_traceTransaction`,
//! `pub fn getTransactionReplay(self: *const Provider, hash: [32]u8) ?Sim.TransactionReplay`
//! returning the transaction and the state just before it executed.
const std = @import("std");
const codec = @import("codec.zig");
const requireProviderMethod = @import("simulation.zig").requireProviderMethod;

pub fn DebugApi(comptime Sim: type, comptime Provider: type) type {
    comptime requireProviderMethod(Provider, "DebugApi", "resolveBlock");

    return struct {
        const Self = @This();

        provider: *const Provider,

        /// `debug_traceCall(call, block, {tracer, tracerConfig, stateOverrides, blockOverrides, ...})`.
        pub fn handle_trace_call(self: *const Self, allocator: std.mem.Allocator, writer: anytype, request_bytes: []const u8) !void {
            try codec.serve(Sim, allocator, writer, request_bytes, self, traceCallBody);
        }

        /// `debug_traceTransaction(hash, {tracer, tracerConfig, ...})`.
        pub fn handle_trace_transaction(self: *const Self, allocator: std.mem.Allocator, writer: anytype, request_bytes: []const u8) !void {
            comptime requireProviderMethod(Provider, "DebugApi.handle_trace_transaction", "getTransactionReplay");
            try codec.serve(Sim, allocator, writer, request_bytes, self, traceTransactionBody);
        }

        fn traceCallBody(self: *const Self, req: codec.Request) !codec.Outcome {
            const call_json = req.param(0) orelse return error.InvalidParams;
            const state = self.provider.resolveBlock(try codec.parseBlockTag(req.param(1))) orelse return error.UnknownBlock;
            const config = req.param(2);
            const cfg_obj: ?std.json.ObjectMap = if (config) |c| switch (c) {
                .object => |o| o,
                else => return error.InvalidParams,
            } else null;
            const choice = try codec.parseTracerChoice(Sim, req.arena, config);
            const overrides = try codec.parseStateOverride(Sim, req.arena, if (cfg_obj) |o| nonNull(o.get("stateOverrides")) else null);
            const block_override = try codec.parseBlockOverride(Sim, if (cfg_obj) |o| nonNull(o.get("blockOverrides")) else null);
            const base_fee = if (block_override) |o| o.base_fee orelse state.block.block_base_fee else state.block.block_base_fee;
            const call = try codec.parseCallRequest(Sim, req.arena, call_json, base_fee);

            const json = try Sim.traceCallJson(req.gpa, state.host, state.block, state.hardfork, call, overrides, block_override, choice);
            defer req.gpa.free(json);
            return .{ .result = try req.arena.dupe(u8, json) };
        }

        fn traceTransactionBody(self: *const Self, req: codec.Request) !codec.Outcome {
            const hash = try codec.parseHash(req.param(0) orelse return error.InvalidParams);
            const replay = self.provider.getTransactionReplay(hash) orelse return error.TransactionNotFound;
            const choice = try codec.parseTracerChoice(Sim, req.arena, req.param(1));
            const json = try Sim.traceCallJson(req.gpa, replay.state.host, replay.state.block, replay.state.hardfork, replay.request, null, null, choice);
            defer req.gpa.free(json);
            return .{ .result = try req.arena.dupe(u8, json) };
        }
    };
}

fn nonNull(v: ?std.json.Value) ?std.json.Value {
    const value = v orelse return null;
    return if (value == .null) null else value;
}
