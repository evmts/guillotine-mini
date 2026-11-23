//! JSON-RPC parameter parsing and result encoding for the simulation
//! namespaces (`eth_call` family, `debug_trace*`, `trace_*`).
//!
//! Parsers that produce simulation types take the simulation module as a
//! comptime `Sim` parameter (in the client: `@import("evm").simulation`), so
//! this file builds without the EVM module.
const std = @import("std");
const primitives = @import("voltaire");
const envelope = @import("envelope.zig");
const errors = @import("error.zig");
const Response = @import("response.zig").Response;

const Address = primitives.Address;
const Value = std.json.Value;
const Allocator = std.mem.Allocator;

/// Block selector for state-reading methods (execution-apis `BlockNumberOrTagOrHash`).
pub const BlockTag = union(enum) {
    latest,
    earliest,
    pending,
    safe,
    finalized,
    number: u64,
    hash: [32]u8,
};

// ---------------------------------------------------------------------------
// Request plumbing
// ---------------------------------------------------------------------------

pub const Request = struct {
    /// Freed after the response is written.
    arena: Allocator,
    /// For simulation calls; their results are freed before returning.
    gpa: Allocator,
    params: []const Value,

    /// Positional param `i`, or null when absent or JSON null.
    pub fn param(self: Request, i: usize) ?Value {
        if (i >= self.params.len) return null;
        return if (self.params[i] == .null) null else self.params[i];
    }
};

pub const Failure = struct {
    code: errors.JsonRpcErrorCode,
    message: []const u8,
    /// Pre-encoded JSON fragment.
    data: ?[]const u8 = null,
};

pub const Outcome = union(enum) {
    /// Pre-encoded JSON fragment.
    result: []const u8,
    failure: Failure,
};

/// Parse `request_bytes`, run `body(context, request)`, and write one
/// JSON-RPC response. Errors from `body` become EIP-1474 error objects.
pub fn serve(
    comptime Sim: type,
    gpa: Allocator,
    writer: anytype,
    request_bytes: []const u8,
    context: anytype,
    /// `fn (@TypeOf(context), Request) !Outcome`
    comptime body: anytype,
) !void {
    const id = switch (envelope.extract_request_id(request_bytes)) {
        .id => |id| id,
        .err => |code| return Response.write_error(writer, .null, code, code.default_message(), null),
    };
    var arena_state = std.heap.ArenaAllocator.init(gpa);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    const root = std.json.parseFromSliceLeaky(Value, arena, request_bytes, .{}) catch
        return Response.write_error(writer, id, .parse_error, errors.JsonRpcErrorCode.parse_error.default_message(), null);
    const params: []const Value = switch (root) {
        .object => |obj| if (obj.get("params")) |p| switch (p) {
            .array => |a| a.items,
            .null => &.{},
            else => return Response.write_error(writer, id, .invalid_params, "params must be an array", null),
        } else &.{},
        else => return Response.write_error(writer, id, .invalid_request, errors.JsonRpcErrorCode.invalid_request.default_message(), null),
    };

    const outcome = body(context, .{ .arena = arena, .gpa = gpa, .params = params }) catch |err| Outcome{ .failure = failureFor(Sim, err) };
    switch (outcome) {
        .result => |raw| try Response.write_success_raw(writer, id, raw),
        .failure => |f| try Response.write_error(writer, id, f.code, f.message, f.data),
    }
}

/// Error codes follow execution-apis `eth_simulateV1` where it defines one.
pub fn failureFor(comptime Sim: type, err: anyerror) Failure {
    return switch (err) {
        error.InvalidParams => .{ .code = .invalid_params, .message = "invalid params" },
        error.UnknownTracer => .{ .code = .invalid_params, .message = "tracer not found" },
        error.NestedMuxTracer => .{ .code = .invalid_params, .message = "muxTracer cannot nest muxTracer" },
        error.DuplicateStructLogger => .{ .code = .invalid_params, .message = "muxTracer allows one struct logger" },
        error.ConflictingStateOverrides => .{ .code = .invalid_params, .message = Sim.invalidMessage(err) },
        error.UnknownBlock => .{ .code = .invalid_input, .message = "header not found" },
        error.TransactionNotFound => .{ .code = .invalid_input, .message = "transaction not found" },
        error.IntrinsicGasTooLow => .{ .code = .insufficient_intrinsic_gas, .message = Sim.invalidMessage(err) },
        error.InsufficientFunds, error.FeeCapTooLow, error.NonceOverflow => .{ .code = .invalid_transaction, .message = Sim.invalidMessage(err) },
        error.AuthorizationRequiresRecipient, error.EmptyAuthorizationList => .{ .code = .invalid_params, .message = Sim.invalidMessage(err) },
        error.NonceTooLow => .{ .code = .nonce_too_low, .message = Sim.invalidMessage(err) },
        error.NonceTooHigh => .{ .code = .nonce_too_high, .message = Sim.invalidMessage(err) },
        error.InitcodeTooLarge => .{ .code = .max_init_code_size_exceeded, .message = Sim.invalidMessage(err) },
        error.BlockGasLimitReached => .{ .code = .block_gas_limit_reached, .message = Sim.invalidMessage(err) },
        error.BlockNumberNotIncreasing => .{ .code = .invalid_input_blocks_out_of_order, .message = Sim.invalidMessage(err) },
        error.BlockTimestampNotIncreasing => .{ .code = .block_timestamp_not_increased, .message = Sim.invalidMessage(err) },
        error.TooManyBlocks => .{ .code = .invalid_input_too_many_blocks, .message = Sim.invalidMessage(err) },
        error.OutOfMemory => .{ .code = .internal_error, .message = "out of memory" },
        else => .{ .code = .internal_error, .message = @errorName(err) },
    };
}

/// eth_call / eth_estimateGas failure: revert is code 3 with the revert
/// payload as `data`; other VM errors are -32000 with Geth's message.
pub fn executionFailure(arena: Allocator, message: []const u8, reverted: bool, revert_data: []const u8) !Outcome {
    if (reverted) return .{ .failure = .{ .code = .execution_reverted, .message = message, .data = try hexString(arena, revert_data) } };
    return .{ .failure = .{ .code = .invalid_input, .message = message } };
}

// ---------------------------------------------------------------------------
// Scalar parsers
// ---------------------------------------------------------------------------

fn hexDigits(s: []const u8) ![]const u8 {
    if (s.len < 2 or s[0] != '0' or (s[1] != 'x' and s[1] != 'X')) return error.InvalidParams;
    return s[2..];
}

/// QUANTITY: `"0x…"` hex string (JSON integers accepted for leniency).
pub fn parseQuantity(comptime T: type, v: Value) !T {
    switch (v) {
        .string => |s| {
            const digits = try hexDigits(s);
            if (digits.len == 0) return error.InvalidParams;
            return std.fmt.parseInt(T, digits, 16) catch error.InvalidParams;
        },
        .integer => |i| return std.math.cast(T, i) orelse error.InvalidParams,
        else => return error.InvalidParams,
    }
}

/// DATA: even-length `"0x…"` hex string.
pub fn parseData(arena: Allocator, v: Value) ![]u8 {
    const s = switch (v) {
        .string => |s| s,
        else => return error.InvalidParams,
    };
    const digits = try hexDigits(s);
    if (digits.len % 2 != 0) return error.InvalidParams;
    const out = try arena.alloc(u8, digits.len / 2);
    _ = std.fmt.hexToBytes(out, digits) catch return error.InvalidParams;
    return out;
}

fn parseFixed(comptime n: usize, v: Value) ![n]u8 {
    const s = switch (v) {
        .string => |s| s,
        else => return error.InvalidParams,
    };
    const digits = try hexDigits(s);
    if (digits.len != n * 2) return error.InvalidParams;
    var out: [n]u8 = undefined;
    _ = std.fmt.hexToBytes(&out, digits) catch return error.InvalidParams;
    return out;
}

pub fn parseAddress(v: Value) !Address {
    return .{ .bytes = try parseFixed(20, v) };
}

pub fn parseHash(v: Value) ![32]u8 {
    return parseFixed(32, v);
}

pub fn parseBool(v: ?Value) !bool {
    const value = v orelse return false;
    return switch (value) {
        .bool => |b| b,
        .null => false,
        else => error.InvalidParams,
    };
}

/// Storage keys and values: a 32-byte word as DATA or QUANTITY.
pub fn parseWord(v: Value) !u256 {
    return parseQuantity(u256, v);
}

/// A block param with its EIP-1898 `requireCanonical` flag.
pub const BlockSelector = struct {
    tag: BlockTag,
    /// Only meaningful for `.hash`.
    require_canonical: bool = false,
};

pub fn parseBlockTag(v: ?Value) !BlockTag {
    return (try parseBlockSelector(v)).tag;
}

/// `BlockNumberOrTagOrHash`. An EIP-1898 object carries exactly one of
/// `blockHash` (with optional `requireCanonical`) or `blockNumber` (QUANTITY).
pub fn parseBlockSelector(v: ?Value) !BlockSelector {
    const value = v orelse return .{ .tag = .latest };
    switch (value) {
        .null => return .{ .tag = .latest },
        .object => |obj| {
            const hash = field(obj, &.{"blockHash"});
            const number = field(obj, &.{"blockNumber"});
            if ((hash == null) == (number == null)) return error.InvalidParams;
            if (hash) |h| return .{ .tag = .{ .hash = try parseHash(h) }, .require_canonical = try parseBool(obj.get("requireCanonical")) };
            if (number.? != .string) return error.InvalidParams;
            return .{ .tag = .{ .number = try parseQuantity(u64, number.?) } };
        },
        else => return .{ .tag = try parseBlockName(value) },
    }
}

fn parseBlockName(value: Value) !BlockTag {
    switch (value) {
        .string => |s| {
            const names = std.StaticStringMap(BlockTag).initComptime(.{
                .{ "latest", .latest },
                .{ "earliest", .earliest },
                .{ "pending", .pending },
                .{ "safe", .safe },
                .{ "finalized", .finalized },
            });
            if (names.get(s)) |tag| return tag;
            if (s.len == 66) return .{ .hash = try parseHash(value) };
            return .{ .number = try parseQuantity(u64, value) };
        },
        else => return error.InvalidParams,
    }
}

pub const TraceFilterParams = struct {
    from_block: ?BlockTag,
    to_block: ?BlockTag,
    from_address: ?[]const Address,
    to_address: ?[]const Address,
    after: usize,
    count: ?usize,
};

pub fn parseTraceFilter(arena: Allocator, v: Value) !TraceFilterParams {
    const obj = try object(v);
    return .{
        .from_block = if (field(obj, &.{"fromBlock"})) |x| try parseBlockTag(x) else null,
        .to_block = if (field(obj, &.{"toBlock"})) |x| try parseBlockTag(x) else null,
        .from_address = if (field(obj, &.{"fromAddress"})) |x| try parseAddressList(arena, x) else null,
        .to_address = if (field(obj, &.{"toAddress"})) |x| try parseAddressList(arena, x) else null,
        .after = if (field(obj, &.{"after"})) |x| try parsePageIndex(x) else 0,
        .count = if (field(obj, &.{"count"})) |x| try parsePageIndex(x) else null,
    };
}

fn parseAddressList(arena: Allocator, v: Value) ![]const Address {
    if (v == .string) {
        const address = try parseAddress(v);
        return arena.dupe(Address, &.{address});
    }
    if (v != .array) return error.InvalidParams;
    const out = try arena.alloc(Address, v.array.items.len);
    for (v.array.items, out) |item, *address| address.* = try parseAddress(item);
    return out;
}

/// `after` / `count`: a hex QUANTITY string or a JSON integer (Parity and
/// Erigon accept both).
fn parsePageIndex(v: Value) !usize {
    return switch (v) {
        .integer, .string => parseQuantity(usize, v),
        .number_string => |s| std.fmt.parseInt(usize, s, 10) catch error.InvalidParams,
        else => error.InvalidParams,
    };
}

fn object(v: Value) !std.json.ObjectMap {
    return switch (v) {
        .object => |o| o,
        else => error.InvalidParams,
    };
}

fn field(obj: std.json.ObjectMap, names: []const []const u8) ?Value {
    for (names) |name| {
        if (obj.get(name)) |v| if (v != .null) return v;
    }
    return null;
}

// ---------------------------------------------------------------------------
// Simulation-type parsers
// ---------------------------------------------------------------------------

pub fn parseSimulateV1Options(comptime Sim: type, payload: std.json.ObjectMap) !Sim.SimulateV1Options {
    return .{
        .validation = try parseBool(payload.get("validation")),
        .trace_transfers = try parseBool(payload.get("traceTransfers")),
        .return_full_transactions = try parseBool(payload.get("returnFullTransactions")),
    };
}

/// execution-apis `GenericTransaction`. Without `gasPrice`, EIP-1559 fields
/// price the call at `min(maxFeePerGas, base_fee + maxPriorityFeePerGas)`.
pub fn parseCallRequest(comptime Sim: type, arena: Allocator, v: Value, base_fee: u256) !Sim.CallRequest {
    const obj = try object(v);
    var req: Sim.CallRequest = .{};
    if (field(obj, &.{"from"})) |x| req.from = try parseAddress(x);
    if (field(obj, &.{"to"})) |x| req.to = try parseAddress(x);
    if (field(obj, &.{"gas"})) |x| req.gas = try parseQuantity(u64, x);
    if (field(obj, &.{"value"})) |x| req.value = try parseQuantity(u256, x);
    if (field(obj, &.{"nonce"})) |x| req.nonce = try parseQuantity(u64, x);
    if (field(obj, &.{ "input", "data" })) |x| req.input = try parseData(arena, x);
    if (field(obj, &.{"gasPrice"})) |x| {
        req.gas_price = try parseQuantity(u256, x);
    } else if (field(obj, &.{"maxFeePerGas"})) |x| {
        req.dynamic_fee = true;
        const max_fee = try parseQuantity(u256, x);
        const tip = if (field(obj, &.{"maxPriorityFeePerGas"})) |t| try parseQuantity(u256, t) else 0;
        if (tip > max_fee) return error.InvalidParams;
        req.gas_price = @min(max_fee, base_fee +| tip);
        req.max_fee_per_gas = max_fee;
        req.max_priority_fee_per_gas = tip;
    }
    if (field(obj, &.{"accessList"})) |x| req.access_list = try parseAccessList(Sim, arena, x);
    if (field(obj, &.{"authorizationList"})) |x| req.authorization_list = try parseAuthorizationList(Sim, arena, x);
    if (field(obj, &.{"maxFeePerBlobGas"})) |x| req.max_fee_per_blob_gas = try parseQuantity(u256, x);
    if (field(obj, &.{"blobVersionedHashes"})) |x| {
        if (x != .array) return error.InvalidParams;
        const hashes = try arena.alloc([32]u8, x.array.items.len);
        for (x.array.items, hashes) |item, *hash| hash.* = try parseHash(item);
        req.blob_versioned_hashes = hashes;
    }
    return req;
}

/// execution-apis `AuthorizationListEntry`: every tuple is signed. The
/// authority is always recovered from `yParity` (or legacy `v`), `r`, `s`;
/// an `authority` field is ignored, so a caller cannot skip recovery.
fn parseAuthorizationList(comptime Sim: type, arena: Allocator, v: Value) ![]const Sim.AuthorizationTuple {
    if (v != .array) return error.InvalidParams;
    const out = try arena.alloc(Sim.AuthorizationTuple, v.array.items.len);
    for (v.array.items, out) |item, *tuple| {
        const obj = try object(item);
        const y_parity: u8 = if (field(obj, &.{"yParity"})) |x|
            try parseQuantity(u8, x)
        else if (field(obj, &.{"v"})) |x| blk: {
            const parity = try parseQuantity(u8, x);
            break :blk if (parity == 27 or parity == 28) parity - 27 else parity;
        } else return error.InvalidParams;
        tuple.* = .{
            .chain_id = try parseQuantity(u256, field(obj, &.{"chainId"}) orelse return error.InvalidParams),
            .address = try parseAddress(field(obj, &.{"address"}) orelse return error.InvalidParams),
            .nonce = try parseQuantity(u64, field(obj, &.{"nonce"}) orelse return error.InvalidParams),
            .y_parity = y_parity,
            .r = try parseQuantity(u256, field(obj, &.{"r"}) orelse return error.InvalidParams),
            .s = try parseQuantity(u256, field(obj, &.{"s"}) orelse return error.InvalidParams),
        };
    }
    return out;
}

fn parseAccessList(comptime Sim: type, arena: Allocator, v: Value) ![]const Sim.AccessListInput {
    const items = switch (v) {
        .array => |a| a.items,
        else => return error.InvalidParams,
    };
    const out = try arena.alloc(Sim.AccessListInput, items.len);
    for (items, out) |item, *dst| {
        const obj = try object(item);
        const keys_json = if (field(obj, &.{"storageKeys"})) |k| switch (k) {
            .array => |a| a.items,
            else => return error.InvalidParams,
        } else &.{};
        const keys = try arena.alloc([32]u8, keys_json.len);
        for (keys_json, keys) |k, *key| std.mem.writeInt(u256, key, try parseWord(k), .big);
        dst.* = .{ .address = try parseAddress(obj.get("address") orelse return error.InvalidParams), .storage_keys = keys };
    }
    return out;
}

fn parseSlots(comptime Sim: type, arena: Allocator, v: Value) ![]const Sim.SlotEntry {
    const obj = try object(v);
    const out = try arena.alloc(Sim.SlotEntry, obj.count());
    var it = obj.iterator();
    var i: usize = 0;
    while (it.next()) |e| : (i += 1) {
        out[i] = .{ .slot = try parseWord(.{ .string = e.key_ptr.* }), .value = try parseWord(e.value_ptr.*) };
    }
    return out;
}

/// Geth `StateOverride`: `{address: {balance, nonce, code, state, stateDiff}}`.
pub fn parseStateOverride(comptime Sim: type, arena: Allocator, v: ?Value) !?Sim.StateOverride {
    const value = v orelse return null;
    const obj = try object(value);
    const out = try arena.alloc(Sim.AccountOverrideEntry, obj.count());
    var it = obj.iterator();
    var i: usize = 0;
    while (it.next()) |e| : (i += 1) {
        const acct = try object(e.value_ptr.*);
        var o: Sim.AccountOverride = .{};
        if (field(acct, &.{"balance"})) |x| o.balance = try parseQuantity(u256, x);
        if (field(acct, &.{"nonce"})) |x| o.nonce = try parseQuantity(u64, x);
        if (field(acct, &.{"code"})) |x| o.code = try parseData(arena, x);
        if (field(acct, &.{"state"})) |x| o.state = try parseSlots(Sim, arena, x);
        if (field(acct, &.{"stateDiff"})) |x| o.state_diff = try parseSlots(Sim, arena, x);
        out[i] = .{ .address = try parseAddress(.{ .string = e.key_ptr.* }), .override = o };
    }
    return out;
}

/// Geth `BlockOverrides`, accepting the older field names too.
pub fn parseBlockOverride(comptime Sim: type, v: ?Value) !?Sim.BlockOverride {
    const value = v orelse return null;
    const obj = try object(value);
    var o: Sim.BlockOverride = .{};
    if (field(obj, &.{"number"})) |x| o.number = try parseQuantity(u64, x);
    if (field(obj, &.{ "time", "timestamp" })) |x| o.time = try parseQuantity(u64, x);
    if (field(obj, &.{"gasLimit"})) |x| o.gas_limit = try parseQuantity(u64, x);
    if (field(obj, &.{ "feeRecipient", "coinbase" })) |x| o.fee_recipient = try parseAddress(x);
    if (field(obj, &.{ "prevRandao", "random" })) |x| o.prev_randao = try parseWord(x);
    if (field(obj, &.{ "baseFeePerGas", "baseFee" })) |x| o.base_fee = try parseQuantity(u256, x);
    if (field(obj, &.{"blobBaseFee"})) |x| o.blob_base_fee = try parseQuantity(u256, x);
    return o;
}

/// Geth tracer config: `{tracer, tracerConfig, disableStack, ...}`. No
/// `tracer` selects the struct logger.
pub fn parseTracerChoice(comptime Sim: type, arena: Allocator, config: ?Value) !Sim.TracerChoice {
    const value = config orelse return .{ .struct_logger = .{} };
    const obj = try object(value);
    const name = if (field(obj, &.{"tracer"})) |t| switch (t) {
        .string => |s| s,
        else => return error.InvalidParams,
    } else return .{ .struct_logger = try parseStructLogger(Sim, obj) };
    return namedTracer(Sim, arena, name, field(obj, &.{"tracerConfig"}), true);
}

fn parseStructLogger(comptime Sim: type, obj: std.json.ObjectMap) !Sim.StructLoggerOptions {
    return .{
        .disable_stack = try parseBool(field(obj, &.{"disableStack"})),
        .disable_storage = try parseBool(field(obj, &.{"disableStorage"})),
        .enable_memory = try parseBool(field(obj, &.{"enableMemory"})),
        .enable_return_data = try parseBool(field(obj, &.{"enableReturnData"})),
        .limit = if (field(obj, &.{"limit"})) |l| try parseQuantity(usize, l) else 0,
    };
}

fn namedTracer(comptime Sim: type, arena: Allocator, name: []const u8, cfg_value: ?Value, allow_mux: bool) !Sim.TracerChoice {
    const empty: std.json.ObjectMap = .init(arena);
    const cfg = if (cfg_value) |c| try object(c) else empty;
    if (std.mem.eql(u8, name, "callTracer")) return .{ .call_tracer = .{
        .only_top_call = try parseBool(field(cfg, &.{"onlyTopCall"})),
        .with_log = try parseBool(field(cfg, &.{"withLog"})),
    } };
    if (std.mem.eql(u8, name, "flatCallTracer")) return .{ .flat_call_tracer = .{} };
    if (std.mem.eql(u8, name, "prestateTracer")) return .{ .prestate_tracer = .{
        .diff_mode = try parseBool(field(cfg, &.{"diffMode"})),
        .disable_code = try parseBool(field(cfg, &.{"disableCode"})),
        .disable_storage = try parseBool(field(cfg, &.{"disableStorage"})),
    } };
    if (std.mem.eql(u8, name, "4byteTracer")) return .four_byte_tracer;
    if (std.mem.eql(u8, name, "gasProfiler")) return .gas_profiler;
    if (std.mem.eql(u8, name, "coverageTracer")) return .coverage;
    if (std.mem.eql(u8, name, "structLogger")) return .{ .struct_logger = try parseStructLogger(Sim, cfg) };
    if (std.mem.eql(u8, name, "muxTracer")) {
        if (!allow_mux) return error.NestedMuxTracer;
        const entries = try arena.alloc(Sim.MuxEntry, cfg.count());
        var it = cfg.iterator();
        var i: usize = 0;
        while (it.next()) |e| : (i += 1) {
            const child_cfg: ?Value = if (e.value_ptr.* == .null) null else e.value_ptr.*;
            entries[i] = .{ .name = e.key_ptr.*, .choice = try namedTracer(Sim, arena, e.key_ptr.*, child_cfg, false) };
        }
        return .{ .mux = entries };
    }
    return error.UnknownTracer;
}

// ---------------------------------------------------------------------------
// Encoders
// ---------------------------------------------------------------------------

pub fn hexString(arena: Allocator, bytes: []const u8) ![]u8 {
    return std.fmt.allocPrint(arena, "\"0x{x}\"", .{bytes});
}

pub fn quantityString(arena: Allocator, value: anytype) ![]u8 {
    return std.fmt.allocPrint(arena, "\"0x{x}\"", .{value});
}

pub fn writeJsonString(w: *std.Io.Writer, s: []const u8) !void {
    try std.json.Stringify.encodeJsonString(s, .{}, w);
}

// ===========================================================================
// Tests
// ===========================================================================

const testing = std.testing;

fn parse(text: []const u8) !std.json.Parsed(Value) {
    return std.json.parseFromSlice(Value, testing.allocator, text, .{});
}

test "parseQuantity accepts 0x hex and rejects malformed input" {
    try testing.expectEqual(@as(u64, 0x1a), try parseQuantity(u64, .{ .string = "0x1a" }));
    try testing.expectEqual(@as(u64, 0), try parseQuantity(u64, .{ .string = "0x0" }));
    try testing.expectError(error.InvalidParams, parseQuantity(u64, .{ .string = "0x" }));
    try testing.expectError(error.InvalidParams, parseQuantity(u64, .{ .string = "26" }));
    try testing.expectError(error.InvalidParams, parseQuantity(u8, .{ .string = "0x100" }));
}

test "parseData and parseAddress validate length" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    try testing.expectEqualSlices(u8, &.{ 0xde, 0xad }, try parseData(arena.allocator(), .{ .string = "0xdead" }));
    try testing.expectEqual(@as(usize, 0), (try parseData(arena.allocator(), .{ .string = "0x" })).len);
    try testing.expectError(error.InvalidParams, parseData(arena.allocator(), .{ .string = "0xabc" }));
    const a = try parseAddress(.{ .string = "0x00000000000000000000000000000000000000ff" });
    try testing.expectEqual(@as(u8, 0xff), a.bytes[19]);
    try testing.expectError(error.InvalidParams, parseAddress(.{ .string = "0xff" }));
}

test "parseBlockTag: names, numbers, hashes, EIP-1898 objects" {
    try testing.expect(try parseBlockTag(null) == .latest);
    try testing.expect(try parseBlockTag(.{ .string = "pending" }) == .pending);
    try testing.expectEqual(@as(u64, 16), (try parseBlockTag(.{ .string = "0x10" })).number);
    const hash = "0x" ++ "ab" ** 32;
    try testing.expectEqual(@as(u8, 0xab), (try parseBlockTag(.{ .string = hash })).hash[0]);
    var parsed = try parse("{\"blockNumber\":\"0x5\"}");
    defer parsed.deinit();
    try testing.expectEqual(@as(u64, 5), (try parseBlockTag(parsed.value)).number);
    try testing.expectError(error.InvalidParams, parseBlockTag(.{ .bool = true }));
}

test "parseBlockSelector: EIP-1898 objects need exactly one selector; blockNumber is a QUANTITY" {
    const hash = "\"0x" ++ "ab" ** 32 ++ "\"";
    var canonical = try parse("{\"blockHash\":" ++ hash ++ ",\"requireCanonical\":true}");
    defer canonical.deinit();
    const selector = try parseBlockSelector(canonical.value);
    try testing.expectEqual(@as(u8, 0xab), selector.tag.hash[31]);
    try testing.expect(selector.require_canonical);
    var plain = try parse("{\"blockHash\":" ++ hash ++ "}");
    defer plain.deinit();
    try testing.expect(!(try parseBlockSelector(plain.value)).require_canonical);
    try testing.expect(!(try parseBlockSelector(.{ .string = "latest" })).require_canonical);

    for ([_][]const u8{
        "{\"blockHash\":" ++ hash ++ ",\"blockNumber\":\"0x1\"}",
        "{}",
        "{\"blockNumber\":\"latest\"}",
        "{\"blockNumber\":5}",
        "{\"blockNumber\":\"0x\"}",
        "{\"blockHash\":" ++ hash ++ ",\"requireCanonical\":\"yes\"}",
    }) |text| {
        var bad = try parse(text);
        defer bad.deinit();
        try testing.expectError(error.InvalidParams, parseBlockSelector(bad.value));
    }
}

test "parseTraceFilter: after and count accept hex quantities and integers" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    var hex = try parse("{\"after\":\"0x2\",\"count\":\"0xa\"}");
    defer hex.deinit();
    const from_hex = try parseTraceFilter(arena.allocator(), hex.value);
    try testing.expectEqual(@as(usize, 2), from_hex.after);
    try testing.expectEqual(@as(usize, 10), from_hex.count.?);
    var int = try parse("{\"after\":3,\"count\":4}");
    defer int.deinit();
    const from_int = try parseTraceFilter(arena.allocator(), int.value);
    try testing.expectEqual(@as(usize, 3), from_int.after);
    try testing.expectEqual(@as(usize, 4), from_int.count.?);
    for ([_][]const u8{ "{\"after\":-1}", "{\"count\":\"1\"}", "{\"count\":\"0x\"}", "{\"count\":true}" }) |text| {
        var bad = try parse(text);
        defer bad.deinit();
        try testing.expectError(error.InvalidParams, parseTraceFilter(arena.allocator(), bad.value));
    }
}

test "parseCallRequest: authorization tuples need a signature and ignore authority" {
    const Stub = struct {
        pub const AccessListInput = struct { address: Address, storage_keys: []const [32]u8 };
        pub const AuthorizationTuple = struct {
            chain_id: u256,
            address: Address,
            nonce: u64,
            authority: ?Address = null,
            y_parity: u8 = 0,
            r: u256 = 0,
            s: u256 = 0,
        };
        pub const CallRequest = struct {
            from: Address = primitives.ZERO_ADDRESS,
            to: ?Address = null,
            gas: ?u64 = null,
            gas_price: u256 = 0,
            dynamic_fee: bool = false,
            value: u256 = 0,
            input: []const u8 = &.{},
            access_list: ?[]const AccessListInput = null,
            authorization_list: ?[]const AuthorizationTuple = null,
            max_fee_per_gas: ?u256 = null,
            max_priority_fee_per_gas: ?u256 = null,
            max_fee_per_blob_gas: ?u256 = null,
            blob_versioned_hashes: ?[]const [32]u8 = null,
            nonce: ?u64 = null,
        };
    };
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const target = "\"address\":\"0x00000000000000000000000000000000000000aa\"";
    const authority = "\"authority\":\"0x00000000000000000000000000000000000000bb\"";
    var signed = try parse("{\"authorizationList\":[{\"chainId\":\"0x1\"," ++ target ++ ",\"nonce\":\"0x2\",\"v\":\"0x1c\",\"r\":\"0x3\",\"s\":\"0x4\"," ++ authority ++ "}]}");
    defer signed.deinit();
    const req = try parseCallRequest(Stub, arena.allocator(), signed.value, 0);
    const tuple = req.authorization_list.?[0];
    try testing.expect(tuple.authority == null);
    try testing.expectEqual(@as(u8, 1), tuple.y_parity);
    try testing.expectEqual(@as(u256, 3), tuple.r);
    try testing.expectEqual(@as(u256, 4), tuple.s);

    var empty = try parse("{\"authorizationList\":[]}");
    defer empty.deinit();
    try testing.expectEqual(@as(usize, 0), (try parseCallRequest(Stub, arena.allocator(), empty.value, 0)).authorization_list.?.len);
    var absent = try parse("{}");
    defer absent.deinit();
    try testing.expect((try parseCallRequest(Stub, arena.allocator(), absent.value, 0)).authorization_list == null);

    for ([_][]const u8{
        "{\"chainId\":\"0x1\"," ++ target ++ ",\"nonce\":\"0x0\"," ++ authority ++ "}",
        "{\"chainId\":\"0x1\"," ++ target ++ ",\"nonce\":\"0x0\",\"r\":\"0x3\",\"s\":\"0x4\"}",
        "{\"chainId\":\"0x1\"," ++ target ++ ",\"nonce\":\"0x0\",\"yParity\":\"0x0\",\"s\":\"0x4\"}",
        "{\"chainId\":\"0x1\"," ++ target ++ ",\"nonce\":\"0x0\",\"yParity\":\"0x0\",\"r\":\"0x3\"}",
    }) |tuple_json| {
        const text = try std.fmt.allocPrint(arena.allocator(), "{{\"authorizationList\":[{s}]}}", .{tuple_json});
        var bad = try parse(text);
        defer bad.deinit();
        try testing.expectError(error.InvalidParams, parseCallRequest(Stub, arena.allocator(), bad.value, 0));
    }

    var fees = try parse("{\"maxFeePerGas\":\"0x9\",\"maxPriorityFeePerGas\":\"0x2\",\"maxFeePerBlobGas\":\"0x5\",\"blobVersionedHashes\":[\"0x" ++ "01" ** 32 ++ "\"]}");
    defer fees.deinit();
    const fee_req = try parseCallRequest(Stub, arena.allocator(), fees.value, 3);
    try testing.expectEqual(@as(u256, 5), fee_req.gas_price);
    try testing.expectEqual(@as(u256, 9), fee_req.max_fee_per_gas.?);
    try testing.expectEqual(@as(u256, 2), fee_req.max_priority_fee_per_gas.?);
    try testing.expectEqual(@as(u256, 5), fee_req.max_fee_per_blob_gas.?);
    try testing.expectEqual(@as(u8, 1), fee_req.blob_versioned_hashes.?[0][0]);
}
