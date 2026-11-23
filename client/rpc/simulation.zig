//! `eth_call`, `eth_estimateGas`, `eth_createAccessList`, `eth_simulateV1`.
//!
//! Handlers parse JSON-RPC params, run the simulation engine
//! (`src/simulation.zig`, injected as `Sim`), and write one JSON-RPC
//! envelope. State overrides and block overrides follow Geth's shapes.
//!
//! `Provider` must define
//! `pub fn resolveBlock(self: *const Provider, tag: BlockTag) ?Sim.BlockState`.
const std = @import("std");
const codec = @import("codec.zig");

pub const BlockTag = codec.BlockTag;

/// Compile-time check that `Provider` has `name` as a method.
pub fn requireProviderMethod(comptime Provider: type, comptime api: []const u8, comptime name: []const u8) void {
    if (!@hasDecl(Provider, name)) @compileError(api ++ " Provider must define " ++ name);
    if (@typeInfo(@TypeOf(@field(Provider, name))) != .@"fn") @compileError(name ++ " must be a function");
}

pub fn SimulationApi(comptime Sim: type, comptime Provider: type) type {
    comptime requireProviderMethod(Provider, "SimulationApi", "resolveBlock");

    return struct {
        const Self = @This();

        provider: *const Provider,

        /// `eth_call(call, block?, stateOverrides?, blockOverrides?)`.
        pub fn handle_call(self: *const Self, allocator: std.mem.Allocator, writer: anytype, request_bytes: []const u8) !void {
            try codec.serve(Sim, allocator, writer, request_bytes, self, callBody);
        }

        /// `eth_estimateGas(call, block?, stateOverrides?, blockOverrides?)`.
        pub fn handle_estimate_gas(self: *const Self, allocator: std.mem.Allocator, writer: anytype, request_bytes: []const u8) !void {
            try codec.serve(Sim, allocator, writer, request_bytes, self, estimateBody);
        }

        /// `eth_createAccessList(call, block?, stateOverrides?)`.
        pub fn handle_create_access_list(self: *const Self, allocator: std.mem.Allocator, writer: anytype, request_bytes: []const u8) !void {
            try codec.serve(Sim, allocator, writer, request_bytes, self, accessListBody);
        }

        /// `eth_simulateV1({blockStateCalls, validation, traceTransfers, returnFullTransactions}, block?)`.
        pub fn handle_simulate_v1(self: *const Self, allocator: std.mem.Allocator, writer: anytype, request_bytes: []const u8) !void {
            try codec.serve(Sim, allocator, writer, request_bytes, self, simulateBody);
        }

        fn resolve(self: *const Self, req: codec.Request, index: usize) !Sim.BlockState {
            return self.provider.resolveBlock(try codec.parseBlockTag(req.param(index))) orelse error.UnknownBlock;
        }

        const Prepared = struct {
            state: Sim.BlockState,
            call: Sim.CallRequest,
            overrides: ?Sim.StateOverride,
            block_override: ?Sim.BlockOverride,
        };

        fn prepare(self: *const Self, req: codec.Request, with_block_override: bool) !Prepared {
            const call_json = req.param(0) orelse return error.InvalidParams;
            const state = try self.resolve(req, 1);
            const block_override = if (with_block_override) try codec.parseBlockOverride(Sim, req.param(3)) else null;
            const base_fee = if (block_override) |o| o.base_fee orelse state.block.block_base_fee else state.block.block_base_fee;
            return .{
                .state = state,
                .call = try codec.parseCallRequest(Sim, req.arena, call_json, base_fee),
                .overrides = try codec.parseStateOverride(Sim, req.arena, req.param(2)),
                .block_override = block_override,
            };
        }

        fn callBody(self: *const Self, req: codec.Request) !codec.Outcome {
            const p = try self.prepare(req, true);
            var res = try Sim.simulateCall(req.gpa, p.state.host, p.state.block, p.state.hardfork, p.call, p.overrides, p.block_override, null);
            defer res.deinit(req.gpa);
            if (!res.success) return codec.executionFailure(req.arena, try Sim.revertMessage(req.arena, &res), res.reverted(), res.output);
            return .{ .result = try codec.hexString(req.arena, res.output) };
        }

        fn estimateBody(self: *const Self, req: codec.Request) !codec.Outcome {
            const p = try self.prepare(req, true);
            var outcome = try Sim.estimateGasDetailed(req.gpa, p.state.host, p.state.block, p.state.hardfork, p.call, p.overrides, p.block_override);
            defer outcome.deinit(req.gpa);
            return switch (outcome) {
                .gas => |g| .{ .result = try codec.quantityString(req.arena, g) },
                .reverted => |r| codec.executionFailure(
                    req.arena,
                    if (r.reason) |reason| try std.fmt.allocPrint(req.arena, "execution reverted: {s}", .{reason}) else "execution reverted",
                    true,
                    r.data,
                ),
                .failed => |msg| codec.executionFailure(req.arena, try req.arena.dupe(u8, msg), false, &.{}),
            };
        }

        fn accessListBody(self: *const Self, req: codec.Request) !codec.Outcome {
            const p = try self.prepare(req, false);
            var list = try Sim.createAccessList(req.gpa, p.state.host, p.state.block, p.state.hardfork, p.call, p.overrides, null);
            defer list.deinit(req.gpa);

            var aw: std.Io.Writer.Allocating = .init(req.arena);
            const w = &aw.writer;
            try w.writeAll("{\"accessList\":[");
            for (list.entries, 0..) |entry, i| {
                if (i > 0) try w.writeByte(',');
                try w.print("{{\"address\":\"0x{x}\",\"storageKeys\":[", .{@as([]const u8, &entry.address.bytes)});
                for (entry.storage_keys, 0..) |key, j| {
                    if (j > 0) try w.writeByte(',');
                    try w.print("\"0x{x}\"", .{@as([]const u8, &key)});
                }
                try w.writeAll("]}");
            }
            try w.print("],\"gasUsed\":\"0x{x}\"", .{list.gas_used});
            if (list.error_msg) |msg| {
                try w.writeAll(",\"error\":");
                try codec.writeJsonString(w, msg);
            }
            try w.writeByte('}');
            return .{ .result = aw.written() };
        }

        fn simulateBody(self: *const Self, req: codec.Request) !codec.Outcome {
            const payload = switch (req.param(0) orelse return error.InvalidParams) {
                .object => |o| o,
                else => return error.InvalidParams,
            };
            const state = try self.resolve(req, 1);
            const options = try codec.parseSimulateV1Options(Sim, payload);
            const block_calls = switch (payload.get("blockStateCalls") orelse return error.InvalidParams) {
                .array => |a| a.items,
                else => return error.InvalidParams,
            };
            if (block_calls.len > Sim.MAX_SIMULATED_BLOCKS) return error.TooManyBlocks;

            const blocks = try req.arena.alloc(Sim.SimulatedBlockInput, block_calls.len);
            for (block_calls, blocks) |entry, *dst| {
                const obj = switch (entry) {
                    .object => |o| o,
                    else => return error.InvalidParams,
                };
                const block_override = try codec.parseBlockOverride(Sim, nonNull(obj.get("blockOverrides")));
                const default_fee: u256 = if (options.validation) state.block.block_base_fee else 0;
                const base_fee = if (block_override) |o| o.base_fee orelse default_fee else default_fee;
                const calls_json: []const std.json.Value = if (nonNull(obj.get("calls"))) |c| switch (c) {
                    .array => |a| a.items,
                    else => return error.InvalidParams,
                } else &.{};
                const calls = try req.arena.alloc(Sim.CallRequest, calls_json.len);
                for (calls_json, calls) |c, *call| call.* = try codec.parseCallRequest(Sim, req.arena, c, base_fee);
                dst.* = .{
                    .block_override = block_override,
                    .state_overrides = try codec.parseStateOverride(Sim, req.arena, nonNull(obj.get("stateOverrides"))),
                    .calls = calls,
                };
            }

            var result = try Sim.simulateV1(req.gpa, state.host, state.block, state.hardfork, blocks, options);
            defer result.deinit(req.gpa);
            return .{ .result = try encodeSimulateResult(req.arena, result, blocks, options.return_full_transactions, state.block.chain_id) };
        }

        fn encodeSimulateResult(
            arena: std.mem.Allocator,
            result: Sim.SimulateV1Result,
            inputs: []const Sim.SimulatedBlockInput,
            full_transactions: bool,
            chain_id: u256,
        ) ![]u8 {
            var aw: std.Io.Writer.Allocating = .init(arena);
            const w = &aw.writer;
            try w.writeByte('[');
            for (result.blocks, inputs, 0..) |b, input, i| {
                if (i > 0) try w.writeByte(',');
                try w.print(
                    "{{\"number\":\"0x{x}\",\"hash\":\"0x{x}\",\"parentHash\":\"0x{x}\",\"timestamp\":\"0x{x}\",\"gasLimit\":\"0x{x}\",\"gasUsed\":\"0x{x}\",\"miner\":\"0x{x}\",\"baseFeePerGas\":\"0x{x}\",\"blobBaseFee\":\"0x{x}\",\"mixHash\":\"0x{x:0>64}\",\"transactions\":[",
                    .{ b.number, @as([]const u8, &b.hash), @as([]const u8, &b.parent_hash), b.timestamp, b.gas_limit, b.gas_used, @as([]const u8, &b.fee_recipient.bytes), b.base_fee, b.blob_base_fee, b.prev_randao },
                );
                var tx_index: usize = 0;
                for (b.calls, input.calls) |c, request| {
                    const tx = c.transaction orelse continue;
                    if (tx_index > 0) try w.writeByte(',');
                    if (full_transactions) {
                        try writeTransaction(w, b, request, tx, tx_index, chain_id);
                    } else {
                        try w.print("\"0x{x}\"", .{@as([]const u8, &tx.hash)});
                    }
                    tx_index += 1;
                }
                try w.writeAll("],\"calls\":[");
                var log_index: usize = 0;
                tx_index = 0;
                for (b.calls, 0..) |c, call_index| {
                    if (call_index > 0) try w.writeByte(',');
                    try w.print("{{\"status\":\"0x{x}\",\"returnData\":\"0x{x}\",\"gasUsed\":\"0x{x}\",\"logs\":[", .{ @intFromBool(c.status), c.return_data, c.gas_used });
                    for (c.logs, 0..) |entry, j| {
                        if (j > 0) try w.writeByte(',');
                        try w.print("{{\"address\":\"0x{x}\",\"topics\":[", .{@as([]const u8, &entry.address.bytes)});
                        for (entry.topics, 0..) |topic, k| {
                            if (k > 0) try w.writeByte(',');
                            try w.print("\"0x{x}\"", .{@as([]const u8, &topic)});
                        }
                        try w.print(
                            "],\"data\":\"0x{x}\",\"blockNumber\":\"0x{x}\",\"blockHash\":\"0x{x}\",\"blockTimestamp\":\"0x{x}\",\"transactionHash\":\"0x{x}\",\"transactionIndex\":\"0x{x}\",\"logIndex\":\"0x{x}\",\"removed\":false}}",
                            .{ entry.data, b.number, @as([]const u8, &b.hash), b.timestamp, @as([]const u8, &c.transaction.?.hash), tx_index, log_index },
                        );
                        log_index += 1;
                    }
                    try w.writeByte(']');
                    if (c.err) |e| {
                        const failure: codec.Failure = switch (e.kind) {
                            .reverted => .{ .code = .execution_reverted, .message = e.message },
                            .vm_error => .{ .code = .execution_error, .message = e.message },
                            .invalid => blk: {
                                var f = codec.failureFor(Sim, c.invalid_error orelse error.InvalidTransaction);
                                f.message = e.message;
                                break :blk f;
                            },
                        };
                        try w.print(",\"error\":{{\"code\":{d},\"message\":", .{@intFromEnum(failure.code)});
                        try codec.writeJsonString(w, failure.message);
                        if (e.kind == .reverted) try w.print(",\"data\":\"0x{x}\"", .{c.return_data});
                        try w.writeByte('}');
                    }
                    try w.writeByte('}');
                    if (c.transaction != null) tx_index += 1;
                }
                try w.writeAll("]}");
            }
            try w.writeByte(']');
            return aw.written();
        }

        /// Geth `internal/ethapi` `RPCTransaction` for a simulated call.
        /// Simulated transactions are unsigned, so `v`, `r`, `s` (and
        /// `yParity` for typed transactions) are zero. `gasPrice` is the
        /// effective price; typed fee caps are the request's own values.
        fn writeTransaction(
            w: *std.Io.Writer,
            block: Sim.SimulatedBlockResult,
            request: Sim.CallRequest,
            tx: Sim.SimulatedTransaction,
            index: usize,
            chain_id: u256,
        ) !void {
            try w.print(
                "{{\"type\":\"0x{x}\",\"chainId\":\"0x{x}\",\"nonce\":\"0x{x}\",\"hash\":\"0x{x}\",\"blockHash\":\"0x{x}\",\"blockNumber\":\"0x{x}\",\"transactionIndex\":\"0x{x}\",\"from\":\"0x{x}\",\"to\":",
                .{ tx.tx_type, chain_id, tx.nonce, @as([]const u8, &tx.hash), @as([]const u8, &block.hash), block.number, index, @as([]const u8, &request.from.bytes) },
            );
            if (request.to) |to| {
                try w.print("\"0x{x}\"", .{@as([]const u8, &to.bytes)});
            } else try w.writeAll("null");
            try w.print(
                ",\"gas\":\"0x{x}\",\"gasPrice\":\"0x{x}\",\"value\":\"0x{x}\",\"input\":\"0x{x}\"",
                .{ tx.gas_limit, request.gas_price, request.value, request.input },
            );
            if (tx.tx_type >= 2) {
                try w.print(",\"maxFeePerGas\":\"0x{x}\",\"maxPriorityFeePerGas\":\"0x{x}\"", .{
                    request.max_fee_per_gas orelse request.gas_price,
                    request.max_priority_fee_per_gas orelse request.gas_price,
                });
            }
            if (tx.tx_type >= 1) {
                try w.writeAll(",\"accessList\":[");
                for (request.access_list orelse &.{}, 0..) |entry, i| {
                    if (i > 0) try w.writeByte(',');
                    try w.print("{{\"address\":\"0x{x}\",\"storageKeys\":[", .{@as([]const u8, &entry.address.bytes)});
                    for (entry.storage_keys, 0..) |key, j| {
                        if (j > 0) try w.writeByte(',');
                        try w.print("\"0x{x}\"", .{@as([]const u8, &key)});
                    }
                    try w.writeAll("]}");
                }
                try w.writeByte(']');
            }
            if (tx.tx_type == 3) {
                try w.print(",\"maxFeePerBlobGas\":\"0x{x}\",\"blobVersionedHashes\":[", .{request.max_fee_per_blob_gas orelse 0});
                for (request.blob_versioned_hashes orelse &.{}, 0..) |hash, i| {
                    if (i > 0) try w.writeByte(',');
                    try w.print("\"0x{x}\"", .{@as([]const u8, &hash)});
                }
                try w.writeByte(']');
            }
            if (tx.tx_type == 4) {
                try w.writeAll(",\"authorizationList\":[");
                for (request.authorizations(), 0..) |auth, i| {
                    if (i > 0) try w.writeByte(',');
                    try w.print(
                        "{{\"chainId\":\"0x{x}\",\"address\":\"0x{x}\",\"nonce\":\"0x{x}\",\"yParity\":\"0x{x}\",\"r\":\"0x{x}\",\"s\":\"0x{x}\"}}",
                        .{ auth.chain_id, @as([]const u8, &auth.address.bytes), auth.nonce, auth.y_parity, auth.r, auth.s },
                    );
                }
                try w.writeByte(']');
            }
            if (tx.tx_type >= 1) try w.writeAll(",\"yParity\":\"0x0\"");
            try w.writeAll(",\"v\":\"0x0\",\"r\":\"0x0\",\"s\":\"0x0\"}");
        }
    };
}

fn nonNull(v: ?std.json.Value) ?std.json.Value {
    const value = v orelse return null;
    return if (value == .null) null else value;
}

test {
    _ = codec;
}
