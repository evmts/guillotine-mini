//! Parity / OpenEthereum / Reth `trace_call`, `trace_transaction`,
//! `trace_block` and `trace_filter`.
//!
//! `trace_call` accepts trace types `"trace"` and `"stateDiff"`; `"vmTrace"`
//! is accepted and answered with `null`. Reth's optional 4th/5th params
//! (state and block overrides) are supported.
//!
//! `Provider` must define
//! `pub fn resolveBlock(self: *const Provider, tag: BlockTag) ?Sim.BlockState`
//! and, for `trace_transaction`,
//! `pub fn getTransactionReplay(self: *const Provider, hash: [32]u8) ?Sim.TransactionReplay`.
//! The block and filter handlers accept either `traceStore()` returning a
//! possibly optional pointer to a TraceStore, or `filterTraces(allocator,
//! query)` returning a slice of entry pointers allocated with that allocator.
//! A provider may also define
//! `pub fn resolveBlockCanonical(self: *const Provider, tag: BlockTag, require_canonical: bool) ?Sim.BlockState`;
//! `trace_block` and `trace_filter` then pass EIP-1898 `requireCanonical`
//! through. Without it, `resolveBlock` is used and the flag is ignored.
const std = @import("std");
const codec = @import("codec.zig");
const trace_store = @import("evm").trace_store;
const requireProviderMethod = @import("simulation.zig").requireProviderMethod;

pub fn TraceApi(comptime Sim: type, comptime Provider: type) type {
    comptime requireProviderMethod(Provider, "TraceApi", "resolveBlock");

    return struct {
        const Self = @This();

        provider: *const Provider,

        /// `trace_call(call, traceTypes, block?, stateOverrides?, blockOverrides?)`.
        pub fn handle_trace_call(self: *const Self, allocator: std.mem.Allocator, writer: anytype, request_bytes: []const u8) !void {
            try codec.serve(Sim, allocator, writer, request_bytes, self, traceCallBody);
        }

        /// `trace_transaction(hash)`: flat call traces tagged with block and
        /// transaction position.
        pub fn handle_trace_transaction(self: *const Self, allocator: std.mem.Allocator, writer: anytype, request_bytes: []const u8) !void {
            comptime requireProviderMethod(Provider, "TraceApi.handle_trace_transaction", "getTransactionReplay");
            try codec.serve(Sim, allocator, writer, request_bytes, self, traceTransactionBody);
        }

        pub fn handle_trace_block(self: *const Self, allocator: std.mem.Allocator, writer: anytype, request_bytes: []const u8) !void {
            try codec.serve(Sim, allocator, writer, request_bytes, self, traceBlockBody);
        }

        pub fn handle_trace_filter(self: *const Self, allocator: std.mem.Allocator, writer: anytype, request_bytes: []const u8) !void {
            try codec.serve(Sim, allocator, writer, request_bytes, self, traceFilterBody);
        }

        fn resolve(self: *const Self, selector: codec.BlockSelector) ?Sim.BlockState {
            if (@hasDecl(Provider, "resolveBlockCanonical")) return self.provider.resolveBlockCanonical(selector.tag, selector.require_canonical);
            return self.provider.resolveBlock(selector.tag);
        }

        fn blockNumber(self: *const Self, selector: codec.BlockSelector) !u64 {
            return switch (selector.tag) {
                .number => |n| n,
                .earliest => if (self.resolve(selector)) |state| state.block.block_number else 0,
                else => (self.resolve(selector) orelse return error.UnknownBlock).block.block_number,
            };
        }

        /// Parity takes exactly one positional param.
        fn onlyParam(req: codec.Request) !std.json.Value {
            if (req.params.len != 1) return error.InvalidParams;
            return req.param(0) orelse error.InvalidParams;
        }

        fn traceBlockBody(self: *const Self, req: codec.Request) !codec.Outcome {
            const selector = try codec.parseBlockSelector(try onlyParam(req));
            const number = try self.blockNumber(selector);
            const block_hash: ?[32]u8 = if (selector.tag == .hash) selector.tag.hash else null;
            return self.filterJson(req.arena, .{ .from_block = number, .to_block = number }, block_hash);
        }

        fn traceFilterBody(self: *const Self, req: codec.Request) !codec.Outcome {
            const filter = try codec.parseTraceFilter(req.arena, try onlyParam(req));
            return self.filterJson(req.arena, .{
                .from_block = if (filter.from_block) |tag| try self.blockNumber(.{ .tag = tag }) else null,
                .to_block = if (filter.to_block) |tag| try self.blockNumber(.{ .tag = tag }) else null,
                .from_address = filter.from_address,
                .to_address = filter.to_address,
                .after = filter.after,
                .count = filter.count,
            }, null);
        }

        /// `block_hash` keeps only rows stored under that hash, so a hash
        /// request never returns another block at the same height.
        fn filterJson(self: *const Self, arena: std.mem.Allocator, query: trace_store.TraceFilter, block_hash: ?[32]u8) !codec.Outcome {
            const unavailable: codec.Outcome = .{ .failure = .{ .code = .method_not_found, .message = "trace storage is unavailable" } };
            const found = if (@hasDecl(Provider, "filterTraces"))
                try self.provider.filterTraces(arena, query)
            else if (@hasDecl(Provider, "traceStore")) blk: {
                const store: ?*const trace_store.TraceStore = self.provider.traceStore();
                break :blk try (store orelse return unavailable).filter(arena, query);
            } else return unavailable;

            var matches: []const *const trace_store.StoredTraceEntry = found;
            if (block_hash) |hash| {
                const kept = try arena.alloc(*const trace_store.StoredTraceEntry, found.len);
                var len: usize = 0;
                for (found) |entry| if (std.mem.eql(u8, &entry.block_hash, &hash)) {
                    kept[len] = entry;
                    len += 1;
                };
                matches = kept[0..len];
            }

            var output: std.Io.Writer.Allocating = .init(arena);
            try trace_store.TraceStore.writeFilterJson(&output.writer, matches);
            return .{ .result = output.written() };
        }

        fn traceCallBody(self: *const Self, req: codec.Request) !codec.Outcome {
            const call_json = req.param(0) orelse return error.InvalidParams;
            const types = try parseTraceTypes(Sim, req.param(1) orelse return error.InvalidParams);
            const state = self.provider.resolveBlock(try codec.parseBlockTag(req.param(2))) orelse return error.UnknownBlock;
            const overrides = try codec.parseStateOverride(Sim, req.arena, req.param(3));
            const block_override = try codec.parseBlockOverride(Sim, req.param(4));
            const base_fee = if (block_override) |o| o.base_fee orelse state.block.block_base_fee else state.block.block_base_fee;
            const call = try codec.parseCallRequest(Sim, req.arena, call_json, base_fee);

            const json = try Sim.traceCallParityJson(req.gpa, state.host, state.block, state.hardfork, call, overrides, block_override, types);
            defer req.gpa.free(json);
            return .{ .result = try req.arena.dupe(u8, json) };
        }

        fn traceTransactionBody(self: *const Self, req: codec.Request) !codec.Outcome {
            const hash = try codec.parseHash(req.param(0) orelse return error.InvalidParams);
            const replay = self.provider.getTransactionReplay(hash) orelse return error.TransactionNotFound;
            const flat = try Sim.traceCallJson(req.gpa, replay.state.host, replay.state.block, replay.state.hardfork, replay.request, null, null, .{ .flat_call_tracer = .{} });
            defer req.gpa.free(flat);

            const traces = try std.json.parseFromSliceLeaky(std.json.Value, req.arena, flat, .{});
            if (traces != .array) return error.InvalidTraceOutput;
            const block_hash = try std.fmt.allocPrint(req.arena, "0x{x}", .{@as([]const u8, &replay.state.block_hash)});
            const tx_hash = try std.fmt.allocPrint(req.arena, "0x{x}", .{@as([]const u8, &replay.tx_hash)});
            for (traces.array.items) |*item| {
                if (item.* != .object) return error.InvalidTraceOutput;
                try item.object.put("blockHash", .{ .string = block_hash });
                try item.object.put("blockNumber", .{ .integer = @intCast(replay.state.block.block_number) });
                try item.object.put("transactionHash", .{ .string = tx_hash });
                try item.object.put("transactionPosition", .{ .integer = @intCast(replay.tx_index) });
            }
            return .{ .result = try std.json.Stringify.valueAlloc(req.arena, traces, .{}) };
        }
    };
}

/// `["trace", "stateDiff", "vmTrace"]` in any order; anything else is invalid.
pub fn parseTraceTypes(comptime Sim: type, v: std.json.Value) !Sim.ParityTraceTypes {
    const items = switch (v) {
        .array => |a| a.items,
        else => return error.InvalidParams,
    };
    var types: Sim.ParityTraceTypes = .{};
    for (items) |item| {
        const name = switch (item) {
            .string => |s| s,
            else => return error.InvalidParams,
        };
        if (std.mem.eql(u8, name, "trace")) {
            types.trace = true;
        } else if (std.mem.eql(u8, name, "stateDiff")) {
            types.state_diff = true;
        } else if (std.mem.eql(u8, name, "vmTrace")) {
            types.vm_trace = true;
        } else return error.InvalidParams;
    }
    return types;
}

test "parseTraceTypes accepts Parity names and rejects others" {
    const Stub = struct {
        pub const ParityTraceTypes = struct { trace: bool = false, state_diff: bool = false, vm_trace: bool = false };
    };
    var parsed = try std.json.parseFromSlice(std.json.Value, std.testing.allocator, "[\"stateDiff\",\"trace\"]", .{});
    defer parsed.deinit();
    const types = try parseTraceTypes(Stub, parsed.value);
    try std.testing.expect(types.trace and types.state_diff and !types.vm_trace);

    var bad = try std.json.parseFromSlice(std.json.Value, std.testing.allocator, "[\"bogus\"]", .{});
    defer bad.deinit();
    try std.testing.expectError(error.InvalidParams, parseTraceTypes(Stub, bad.value));
}
