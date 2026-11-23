//! Allocation-failure safety suite for the tracing and debugging stack.
//!
//! Every scenario drives a tracer with synthetic inspector events and then
//! serializes it, all through one allocator. `checkAllAllocationFailures`
//! reruns the scenario once per allocation, failing that allocation (and
//! every later one). Each run must return `error.OutOfMemory`, free every
//! byte it allocated, and never double-free: the backing
//! `std.testing.allocator` panics on a double free and reports leaks.
//!
//! Inspector callbacks return void, so tracers park the first failure in
//! `err`. Scenarios surface it with `try check(tracer.err)`, which also proves
//! the failure was reported rather than swallowed.
const std = @import("std");
const primitives = @import("voltaire");
const insp = @import("inspector.zig");
const tracers = @import("tracers.zig");
const trace = @import("trace.zig");
const trace_store = @import("trace_store.zig");
const live_tracer = @import("live_tracer.zig");
const debugger = @import("debugger.zig");
const flamegraph = @import("flamegraph.zig");

const testing = std.testing;
const Allocator = std.mem.Allocator;
const Address = primitives.Address;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

fn addr(n: u256) Address {
    return Address.fromU256(n);
}

fn check(err: ?anyerror) anyerror!void {
    if (err) |e| return e;
}

/// Runs `method(target, writer, extra...)` into a growable buffer owned by
/// `allocator`. The allocating writer reports its own OOM as `WriteFailed`;
/// map it back so the failure is visible to `checkAllAllocationFailures`.
fn render(allocator: Allocator, target: anytype, comptime method: anytype, extra: anytype) anyerror![]u8 {
    var out: std.Io.Writer.Allocating = .init(allocator);
    defer out.deinit();
    @call(.auto, method, .{ target, &out.writer } ++ extra) catch |e| switch (e) {
        error.WriteFailed => return error.OutOfMemory,
        else => return e,
    };
    return out.toOwnedSlice();
}

/// Like `render`, but also checks the output parses as JSON.
fn renderJson(allocator: Allocator, target: anytype, comptime method: anytype, extra: anytype) anyerror!void {
    const text = try render(allocator, target, method, extra);
    defer allocator.free(text);
    if (!try std.json.validate(allocator, text)) return error.InvalidJson;
}

const Frame = struct {
    id: u64,
    parent: ?u64,
    depth: usize,
    kind: insp.CallType = .call,
    from: Address,
    to: Address,
    input: []const u8 = &.{},
    code: []const u8 = &.{},
    precompile: bool = false,
    value: u256 = 0,
};

fn enter(i: insp.Inspector, f: Frame) void {
    i.onEnter(.{
        .frame_id = f.id,
        .parent_id = f.parent,
        .depth = f.depth,
        .call_type = f.kind,
        .from = f.from,
        .to = f.to,
        .code_address = f.to,
        .value = f.value,
        .gas = 100_000 / (f.depth + 1),
        .input = f.input,
        .is_static = f.kind == .staticcall,
        .is_precompile = f.precompile,
        .is_delegated = false,
        .code = f.code,
    });
}

const Exit = struct {
    output: []const u8 = &.{},
    gas_used: u64 = 0,
    reverted: bool = false,
    error_name: ?[]const u8 = null,
    created: ?Address = null,
};

fn exit(i: insp.Inspector, f: Frame, e: Exit) void {
    i.onExit(.{
        .frame_id = f.id,
        .parent_id = f.parent,
        .depth = f.depth,
        .output = e.output,
        .gas_used = e.gas_used,
        .gas_left = 1000,
        .reverted = e.reverted,
        .error_name = e.error_name,
        .created_address = e.created,
    });
}

fn opcode(i: insp.Inspector, frame_id: u64, depth: usize, pc: u64, op: u8, gas: u64, stack: []const u256, memory: ?[]const u8) void {
    i.onOpcode(.{
        .frame_id = frame_id,
        .pc = pc,
        .op = op,
        .op_name = @import("opcode.zig").getOpName(op),
        .gas = gas,
        .memory_size = if (memory) |m| m.len else 0,
        .memory = memory,
        .stack = stack,
        .return_data = &.{ 0xde, 0xad },
        .depth = depth,
        .refund = 0,
        .address = addr(0xc0de),
        .code_address = addr(0xc0de),
    });
}

fn opcodeEnd(i: insp.Inspector, frame_id: u64, pc: u64, op: u8, gas_before: u64, cost: u64, error_name: ?[]const u8) void {
    i.onOpcodeEnd(.{
        .frame_id = frame_id,
        .pc = pc,
        .op = op,
        .gas_cost = cost,
        .gas_after = gas_before -| cost,
        .memory_expansion_gas = cost / 2,
        .error_name = error_name,
    });
}

/// ABI `Error(string)` payload for "nope".
const revert_payload = blk: {
    var data: [4 + 32 + 32 + 32]u8 = @splat(0);
    data[0..4].* = .{ 0x08, 0xc3, 0x79, 0xa0 };
    data[4 + 31] = 0x20;
    data[4 + 32 + 31] = 4;
    data[4 + 64 ..][0..4].* = "nope".*;
    break :blk data;
};

const selector_a = [_]u8{ 0xa9, 0x05, 0x9c, 0xbb, 1, 2, 3, 4 };
const selector_b = [_]u8{ 0x70, 0xa0, 0x82, 0x31 };
const runtime_code = [_]u8{ 0x60, 0x01, 0x60, 0x00, 0x55, 0x00 };

const root_frame: Frame = .{ .id = 1, .parent = null, .depth = 0, .from = addr(0xaa), .to = addr(0xc0de), .input = &selector_a, .code = &runtime_code };
const call_child: Frame = .{ .id = 2, .parent = 1, .depth = 1, .from = addr(0xc0de), .to = addr(0xb0b), .input = &selector_b, .code = &runtime_code, .value = 7 };
const reverted_grandchild: Frame = .{ .id = 3, .parent = 2, .depth = 2, .kind = .staticcall, .from = addr(0xb0b), .to = addr(0xdead), .input = &selector_a, .code = &runtime_code };
const precompile_child: Frame = .{ .id = 4, .parent = 1, .depth = 1, .from = addr(0xc0de), .to = addr(0x02), .input = "hash me", .precompile = true };
const create_child: Frame = .{ .id = 5, .parent = 1, .depth = 1, .kind = .create2, .from = addr(0xc0de), .to = addr(0xc4ea7e), .input = &runtime_code, .code = &runtime_code, .value = 3 };

fn emitLog(i: insp.Inspector, frame_id: u64, address: Address, topic: u8) void {
    const topics = [_][32]u8{ @splat(topic), @splat(topic +% 1) };
    i.onLog(.{ .frame_id = frame_id, .address = address, .topics = &topics, .data = "log payload" });
}

/// Nested CALL -> (reverted STATICCALL), precompile, CREATE2, LOG and
/// SELFDESTRUCT, with storage/balance/nonce/code mutations at every level.
fn driveCallTree(i: insp.Inspector) void {
    enter(i, root_frame);
    emitLog(i, 1, addr(0xc0de), 1);
    i.onStorageChange(.{ .frame_id = 1, .address = addr(0xc0de), .slot = 1, .prev_value = 0, .new_value = 11, .is_read = false });
    i.onBalanceChange(.{ .frame_id = 1, .address = addr(0xaa), .prev_balance = 1000, .new_balance = 993 });
    i.onNonceChange(.{ .frame_id = 1, .address = addr(0xaa), .prev_nonce = 4, .new_nonce = 5 });

    enter(i, call_child);
    i.onBalanceChange(.{ .frame_id = 2, .address = addr(0xb0b), .prev_balance = 0, .new_balance = 7 });
    i.onStorageChange(.{ .frame_id = 2, .address = addr(0xb0b), .slot = 9, .prev_value = 5, .new_value = 5, .is_read = true });
    emitLog(i, 2, addr(0xb0b), 2);

    enter(i, reverted_grandchild);
    i.onStorageChange(.{ .frame_id = 3, .address = addr(0xdead), .slot = 2, .prev_value = 1, .new_value = 2, .is_read = false });
    i.onCodeChange(.{ .frame_id = 3, .address = addr(0xdead), .prev_code = &runtime_code, .new_code = "replaced code" });
    i.onCodeChange(.{ .frame_id = 3, .address = addr(0xdead), .prev_code = "replaced code", .new_code = "replaced twice" });
    i.onNonceChange(.{ .frame_id = 3, .address = addr(0xdead), .prev_nonce = 0, .new_nonce = 1 });
    emitLog(i, 3, addr(0xdead), 3);
    exit(i, reverted_grandchild, .{ .output = &revert_payload, .gas_used = 300, .reverted = true, .error_name = "execution reverted" });

    i.onSelfDestruct(.{ .frame_id = 2, .address = addr(0xb0b), .beneficiary = addr(0xbe4e), .value = 7 });
    exit(i, call_child, .{ .output = &.{ 0, 1, 2, 3 }, .gas_used = 900 });

    enter(i, precompile_child);
    exit(i, precompile_child, .{ .output = &@as([32]u8, @splat(0x5a)), .gas_used = 72 });

    enter(i, create_child);
    i.onNonceChange(.{ .frame_id = 5, .address = addr(0xc4ea7e), .prev_nonce = 0, .new_nonce = 1 });
    i.onCodeChange(.{ .frame_id = 5, .address = addr(0xc4ea7e), .prev_code = &.{}, .new_code = &runtime_code });
    i.onStorageChange(.{ .frame_id = 5, .address = addr(0xc4ea7e), .slot = 0, .prev_value = 0, .new_value = 1, .is_read = false });
    exit(i, create_child, .{ .output = &runtime_code, .gas_used = 32_000, .created = addr(0xc4ea7e) });

    exit(i, root_frame, .{ .output = &.{0x01}, .gas_used = 50_000 });
}

// ---------------------------------------------------------------------------
// 1. CallTracer
// ---------------------------------------------------------------------------

fn callTracerScenario(allocator: Allocator, options: tracers.CallTracer.Options) anyerror!void {
    var tracer = tracers.CallTracer.init(allocator, options);
    defer tracer.deinit();
    // Two transactions: the second replaces the first root, exercising the
    // destroy of a complete nested tree while a new one is being built.
    driveCallTree(tracer.inspector());
    driveCallTree(tracer.inspector());
    try check(tracer.err);
    try renderJson(allocator, &tracer, tracers.CallTracer.writeGethJson, .{});
    try renderJson(allocator, &tracer, tracers.CallTracer.writeFlatJson, .{});
}

test "OOM: CallTracer nested CALL/CREATE/LOG/revert and both JSON writers" {
    try testing.checkAllAllocationFailures(testing.allocator, callTracerScenario, .{tracers.CallTracer.Options{ .with_log = true }});
    try testing.checkAllAllocationFailures(testing.allocator, callTracerScenario, .{tracers.CallTracer.Options{ .only_top_call = true }});
}

test "OOM: CallTracer reports the parked error from both writers" {
    var fail_index: usize = 0;
    while (fail_index < 64) : (fail_index += 1) {
        var failing = testing.FailingAllocator.init(testing.allocator, .{ .fail_index = fail_index });
        var tracer = tracers.CallTracer.init(failing.allocator(), .{ .with_log = true });
        defer tracer.deinit();
        driveCallTree(tracer.inspector());
        if (!failing.has_induced_failure) break;
        try testing.expectEqual(@as(?anyerror, error.OutOfMemory), tracer.err);
        var sink: std.Io.Writer.Discarding = .init(&.{});
        try testing.expectError(error.OutOfMemory, tracer.writeGethJson(&sink.writer));
        try testing.expectError(error.OutOfMemory, tracer.writeFlatJson(&sink.writer));
    } else return error.ScenarioTooLarge;
}

// ---------------------------------------------------------------------------
// 2. PrestateTracer
// ---------------------------------------------------------------------------

fn prestateScenario(allocator: Allocator, options: tracers.PrestateTracer.Options) anyerror!void {
    var tracer = tracers.PrestateTracer.init(allocator, options);
    defer tracer.deinit();
    const i = tracer.inspector();
    // Code changes outside any frame free the previous post code directly.
    i.onCodeChange(.{ .frame_id = 0, .address = addr(0xdead), .prev_code = "genesis", .new_code = "pre-tx code" });
    driveCallTree(i);
    // A second top-level frame that reverts after replacing code twice: the
    // undo log owns both displaced code slices until rollback frees them.
    enter(i, root_frame);
    i.onCodeChange(.{ .frame_id = 1, .address = addr(0xc0de), .prev_code = &runtime_code, .new_code = "first" });
    i.onCodeChange(.{ .frame_id = 1, .address = addr(0xc0de), .prev_code = "first", .new_code = "second" });
    i.onStorageChange(.{ .frame_id = 1, .address = addr(0xc0de), .slot = 77, .prev_value = 0, .new_value = 1, .is_read = false });
    exit(i, root_frame, .{ .reverted = true, .error_name = "execution reverted" });
    try check(tracer.err);
    try renderJson(allocator, &tracer, tracers.PrestateTracer.writeJson, .{});
}

fn prestateOpenFrameScenario(allocator: Allocator) anyerror!void {
    // Execution aborted with frames still open: deinit must free the code
    // slices held only by the undo log.
    var tracer = tracers.PrestateTracer.init(allocator, .{ .diff_mode = true });
    defer tracer.deinit();
    const i = tracer.inspector();
    enter(i, root_frame);
    enter(i, call_child);
    i.onCodeChange(.{ .frame_id = 2, .address = addr(0xb0b), .prev_code = "a", .new_code = "bb" });
    i.onCodeChange(.{ .frame_id = 2, .address = addr(0xb0b), .prev_code = "bb", .new_code = "ccc" });
    i.onCodeChange(.{ .frame_id = 2, .address = addr(0xb0b), .prev_code = "ccc", .new_code = "dddd" });
    try check(tracer.err);
}

test "OOM: PrestateTracer mutations, child revert undo, diff mode and writeJson" {
    try testing.checkAllAllocationFailures(testing.allocator, prestateScenario, .{tracers.PrestateTracer.Options{}});
    try testing.checkAllAllocationFailures(testing.allocator, prestateScenario, .{tracers.PrestateTracer.Options{ .diff_mode = true }});
    try testing.checkAllAllocationFailures(testing.allocator, prestateScenario, .{tracers.PrestateTracer.Options{ .diff_mode = true, .disable_code = true, .disable_storage = true }});
    try testing.checkAllAllocationFailures(testing.allocator, prestateOpenFrameScenario, .{});
}

// ---------------------------------------------------------------------------
// 3. AccessListInspector
// ---------------------------------------------------------------------------

fn accessListScenario(allocator: Allocator) anyerror!void {
    var tracer = tracers.AccessListInspector.init(allocator, .{});
    defer tracer.deinit();
    const i = tracer.inspector();
    i.onTxStart(.{
        .hardfork = .CANCUN,
        .origin = addr(0xaa),
        .target = addr(0xc0de),
        .coinbase = addr(0xc01b),
        .is_create = false,
        .value = 0,
        .gas_limit = 1_000_000,
        .gas_price = 1,
        .input = &.{},
        .block_number = 1,
        .block_timestamp = 1,
        .chain_id = 1,
        .blob_base_fee = 0,
        .blob_hash_count = 0,
    });
    var n: u256 = 0;
    while (n < 6) : (n += 1) {
        i.onAccess(.{ .frame_id = 1, .address = addr(0x1000 + n), .slot = null, .was_warm = false });
        var slot: u256 = 0;
        while (slot < n) : (slot += 1) {
            i.onAccess(.{ .frame_id = 1, .address = addr(0x1000 + n), .slot = slot * 0x100, .was_warm = false });
        }
    }
    // Excluded origin/target/precompile, plus a slot on the excluded target.
    i.onAccess(.{ .frame_id = 1, .address = addr(0xaa), .slot = null, .was_warm = true });
    i.onAccess(.{ .frame_id = 1, .address = addr(0x01), .slot = null, .was_warm = false });
    i.onAccess(.{ .frame_id = 1, .address = addr(0xc0de), .slot = 5, .was_warm = false });
    exit(i, create_child, .{ .created = addr(0x1005) });
    try check(tracer.err);

    const entries = try tracer.toOwnedEntries(allocator);
    defer tracers.freeAccessListEntries(allocator, entries);
    try testing.expectEqual(@as(usize, 7), entries.len);
    try renderJson(allocator, &tracer, tracers.AccessListInspector.writeJson, .{});
}

test "OOM: AccessListInspector entries and writeJson free partial slices" {
    try testing.checkAllAllocationFailures(testing.allocator, accessListScenario, .{});
}

// ---------------------------------------------------------------------------
// 4. FourByteTracer, GasProfiler, CoverageInspector
// ---------------------------------------------------------------------------

/// Root frame with JUMPI branches, a nested call and a faulting opcode.
fn driveOpcodes(i: insp.Inspector) void {
    enter(i, root_frame);
    opcode(i, 1, 0, 0, 0x60, 1000, &.{}, null);
    opcodeEnd(i, 1, 0, 0x60, 1000, 3, null);
    opcode(i, 1, 0, 2, 0x57, 997, &.{ 1, 8 }, null);
    opcodeEnd(i, 1, 2, 0x57, 997, 10, null);
    opcode(i, 1, 0, 8, 0x54, 987, &.{1}, &@as([64]u8, @splat(0x11)));
    opcodeEnd(i, 1, 8, 0x54, 987, 2100, null);
    opcode(i, 1, 0, 9, 0xf1, 800, &.{ 0, 0, 0, 0, 7, 0xb0b, 500 }, null);
    enter(i, call_child);
    opcode(i, 2, 1, 0, 0x57, 400, &.{ 0, 8 }, null);
    opcodeEnd(i, 2, 0, 0x57, 400, 10, null);
    opcode(i, 2, 1, 1, 0xfe, 390, &.{}, null);
    opcodeEnd(i, 2, 1, 0xfe, 390, 390, "invalid opcode");
    i.onFault(.{ .frame_id = 2, .pc = 1, .op = 0xfe, .gas_cost = 390, .gas_after = 0, .memory_expansion_gas = 0, .error_name = "invalid opcode" });
    exit(i, call_child, .{ .gas_used = 400, .reverted = true, .error_name = "invalid opcode" });
    opcodeEnd(i, 1, 9, 0xf1, 800, 500, null);
    enter(i, precompile_child);
    exit(i, precompile_child, .{ .gas_used = 72 });
    enter(i, .{ .id = 6, .parent = 1, .depth = 1, .from = addr(0xc0de), .to = addr(0xb0b), .input = &selector_b, .code = &runtime_code });
    exit(i, .{ .id = 6, .parent = 1, .depth = 1, .from = addr(0xc0de), .to = addr(0xb0b) }, .{ .gas_used = 30 });
    opcode(i, 1, 0, 10, 0x00, 200, &.{}, null);
    opcodeEnd(i, 1, 10, 0x00, 200, 0, null);
    exit(i, root_frame, .{ .gas_used = 3000 });
}

fn fourByteScenario(allocator: Allocator) anyerror!void {
    var tracer = tracers.FourByteTracer.init(allocator);
    defer tracer.deinit();
    driveOpcodes(tracer.inspector());
    driveCallTree(tracer.inspector());
    try check(tracer.err);
    try testing.expectEqual(@as(u64, 3), tracer.getCount(selector_b, 0));
    try renderJson(allocator, &tracer, tracers.FourByteTracer.writeJson, .{});
}

fn gasProfilerScenario(allocator: Allocator) anyerror!void {
    var profiler = tracers.GasProfiler.init(allocator);
    defer profiler.deinit();
    driveOpcodes(profiler.inspector());
    driveOpcodes(profiler.inspector());
    try check(profiler.err);
    const top = try profiler.topOpcodes(allocator, 3);
    defer allocator.free(top);
    try testing.expectEqual(@as(u8, 0x54), top[0].op);
    const all = try profiler.topOpcodes(allocator, 256);
    defer allocator.free(all);
    try renderJson(allocator, &profiler, tracers.GasProfiler.writeJson, .{});
}

fn coverageScenario(allocator: Allocator) anyerror!void {
    var coverage = tracers.CoverageInspector.init(allocator);
    defer coverage.deinit();
    driveOpcodes(coverage.inspector());
    driveOpcodes(coverage.inspector());
    try check(coverage.err);
    const hash = tracers.CoverageInspector.codeHash(&runtime_code);
    try testing.expectEqual(@as(u64, 2), coverage.jumpiStats(hash, 2).?.taken);
    try renderJson(allocator, &coverage, tracers.CoverageInspector.writeJson, .{});
}

test "OOM: FourByteTracer, GasProfiler.topOpcodes and CoverageInspector writers" {
    try testing.checkAllAllocationFailures(testing.allocator, fourByteScenario, .{});
    try testing.checkAllAllocationFailures(testing.allocator, gasProfilerScenario, .{});
    try testing.checkAllAllocationFailures(testing.allocator, coverageScenario, .{});
}

// ---------------------------------------------------------------------------
// 5. Tracer (EIP-3155) and TraceDiff
// ---------------------------------------------------------------------------

fn captureSteps(tracer: *trace.Tracer, count: u64, gas_skew: u64) !void {
    var pc: u64 = 0;
    while (pc < count) : (pc += 1) {
        const memory: [40]u8 = @splat(@truncate(pc));
        const stack = [_]u256{ pc, pc * 2, std.math.maxInt(u256) };
        try tracer.captureState(pc, 0x52, 10_000 - pc - gas_skew, 3, &memory, &stack, &.{ 1, 2, 3 }, 1, 0, "MSTORE");
        const step: trace.TraceEntry = .{
            .pc = pc,
            .op = 0x55,
            .gas = 9000,
            .gasCost = 0,
            .memory = &memory,
            .memSize = memory.len,
            .stack = &stack,
            .returnData = &.{9},
            .depth = 2,
            .refund = 4800,
            .opName = "SSTORE",
            .error_msg = "pending",
            .storage = &.{ .{ .slot = pc, .value = 1 }, .{ .slot = pc + 1, .value = 2 } },
        };
        const token = try tracer.capture(step, pc % 2 == 0);
        if (token) |t| tracer.finishStep(t, 20_000, if (pc % 3 == 0) "out of gas" else null);
    }
}

fn traceScenario(allocator: Allocator, ring_buffer: bool) anyerror!void {
    var ours = trace.Tracer.init(allocator);
    defer ours.deinit();
    var reference = trace.Tracer.init(allocator);
    defer reference.deinit();
    for ([_]*trace.Tracer{ &ours, &reference }) |t| {
        t.enable();
        t.config = primitives.TraceConfig.enableAll();
        t.ring_buffer = ring_buffer;
        t.max_entries = 5;
    }
    try captureSteps(&ours, 6, 0);
    try captureSteps(&reference, 6, 1);
    try testing.expectEqual(@as(usize, 5), ours.entries.items.len);

    const jsonl = try render(allocator, &ours, trace.Tracer.writeEip3155Jsonl, .{trace.TraceSummary{
        .output = "out",
        .gas_used = 21_000,
        .pass = false,
        .error_msg = "out of gas",
        .state_root = @splat(0xab),
    }});
    defer allocator.free(jsonl);
    var lines = std.mem.splitScalar(u8, jsonl, '\n');
    while (lines.next()) |line| {
        if (line.len > 0 and !try std.json.validate(allocator, line)) return error.InvalidJson;
    }

    var diff = try trace.TraceDiff.compare(allocator, &ours, &reference);
    defer diff.deinit(allocator);
    try testing.expectEqualStrings("gas", diff.diff_field.?);
    var same = try trace.TraceDiff.compare(allocator, &ours, &ours);
    defer same.deinit(allocator);
    try testing.expect(same.diff_field == null);
    var shorter = trace.Tracer.init(allocator);
    defer shorter.deinit();
    var length = try trace.TraceDiff.compare(allocator, &ours, &shorter);
    defer length.deinit(allocator);
    try testing.expectEqualStrings("trace_length", length.diff_field.?);
}

test "OOM: Tracer.captureState, ring-buffer eviction, JSONL and TraceDiff" {
    try testing.checkAllAllocationFailures(testing.allocator, traceScenario, .{true});
    try testing.checkAllAllocationFailures(testing.allocator, traceScenario, .{false});
}

// ---------------------------------------------------------------------------
// 6. TraceStore
// ---------------------------------------------------------------------------

fn recordBlock(store: *trace_store.TraceStore, call_tracer: *const tracers.CallTracer, block: u64) !void {
    try store.recordCallTrace(block, @splat(@truncate(block)), @splat(@truncate(block + 1)), @truncate(block % 3), call_tracer);
}

fn traceStoreScenario(allocator: Allocator, tree_allocator: Allocator, config: trace_store.RetentionConfig) anyerror!void {
    var call_tracer = tracers.CallTracer.init(tree_allocator, .{ .with_log = true });
    defer call_tracer.deinit();
    driveCallTree(call_tracer.inspector());
    try check(call_tracer.err);

    var store = trace_store.TraceStore.init(allocator, config);
    defer store.deinit();
    var block: u64 = 1;
    while (block <= 5) : (block += 1) try recordBlock(&store, &call_tracer, block);
    try testing.expect(store.blockCount() <= config.max_blocks);
    try testing.expect(store.entryCount() <= config.max_entries);

    const queries = [_]trace_store.TraceFilter{
        .{},
        .{ .from_block = 3, .to_block = 5, .after = 1, .count = 4 },
        .{ .from_address = &.{ addr(0xc0de), addr(0xc0de) } },
        .{ .to_address = &.{ addr(0xdead), addr(0xbe4e) }, .from_block = 4 },
    };
    for (queries) |query| {
        const matches = try store.filter(allocator, query);
        defer allocator.free(matches);
        var out: std.Io.Writer.Allocating = .init(allocator);
        defer out.deinit();
        trace_store.writeFilterJson(&out.writer, matches) catch return error.OutOfMemory;
        if (!try std.json.validate(allocator, out.written())) return error.InvalidJson;
    }
    store.rollbackReorg(3);
}

test "OOM: TraceStore recordCallTrace, eviction, filter and writeFilterJson" {
    const configs = [_]trace_store.RetentionConfig{
        .{},
        .{ .max_blocks = 2 },
        .{ .max_entries = 7 },
        .{ .max_entries = 3, .keep_reverted = false },
    };
    for (configs) |config| {
        // Store and tree share the failing allocator.
        try testing.checkAllAllocationFailures(testing.allocator, traceStoreScenarioShared, .{config});
        // Only the store's allocations fail.
        try testing.checkAllAllocationFailures(testing.allocator, traceStoreScenario, .{ testing.allocator, config });
    }
}

fn traceStoreScenarioShared(allocator: Allocator, config: trace_store.RetentionConfig) anyerror!void {
    return traceStoreScenario(allocator, allocator, config);
}

test "OOM: TraceStore.recordCallTrace is atomic: a failed insert leaves no partial transaction" {
    var call_tracer = tracers.CallTracer.init(testing.allocator, .{});
    defer call_tracer.deinit();
    driveCallTree(call_tracer.inspector());

    var reference = trace_store.TraceStore.init(testing.allocator, .{});
    defer reference.deinit();
    try recordBlock(&reference, &call_tracer, 1);
    const per_tx = reference.entryCount();

    var fail_index: usize = 0;
    while (true) : (fail_index += 1) {
        var failing = testing.FailingAllocator.init(testing.allocator, .{});
        var store = trace_store.TraceStore.init(failing.allocator(), .{});
        defer store.deinit();
        try recordBlock(&store, &call_tracer, 1);

        failing.fail_index = failing.alloc_index + fail_index;
        const result = recordBlock(&store, &call_tracer, 2);
        if (!failing.has_induced_failure) {
            try result;
            try testing.expectEqual(2 * per_tx, store.entryCount());
            break;
        }
        try testing.expectError(error.OutOfMemory, result);
        // Block 1 is intact and block 2 left nothing behind in any index.
        try testing.expectEqual(per_tx, store.entryCount());
        try testing.expectEqual(@as(usize, 1), store.blockCount());
        try testing.expect(!store.hasBlock(2));
        failing.fail_index = std.math.maxInt(usize);
        for ([_]trace_store.TraceFilter{
            .{},
            .{ .from_address = &.{ addr(0xc0de), addr(0xaa), addr(0xb0b) } },
            .{ .to_address = &.{ addr(0xc0de), addr(0xb0b), addr(0xdead), addr(0x02), addr(0xc4ea7e), addr(0xbe4e) } },
        }) |query| {
            const matches = try store.filter(testing.allocator, query);
            defer testing.allocator.free(matches);
            for (matches) |entry| try testing.expectEqual(@as(u64, 1), entry.block_number);
        }
        // The store still accepts the transaction once memory is available.
        try recordBlock(&store, &call_tracer, 2);
        try testing.expectEqual(2 * per_tx, store.entryCount());
    }
}

// ---------------------------------------------------------------------------
// 7. SupplyTracer
// ---------------------------------------------------------------------------

fn driveSupplyChain(hooks: live_tracer.BlockHooks, blocks: u64) void {
    hooks.onBlockchainInit(.{ .chain_id = 1, .hardfork = .CANCUN, .genesis_hash = @splat(0) });
    hooks.onGenesisBlock(.{ .block_hash = @splat(0), .allocs = &.{
        .{ .address = addr(0xaa), .balance = 1_000_000 },
        .{ .address = addr(0xbb), .balance = 5, .nonce = 1, .code = &runtime_code },
    } });
    var number: u64 = 1;
    while (number <= blocks) : (number += 1) {
        hooks.onBlockStart(.{
            .number = number,
            .hash = @splat(@truncate(number)),
            .parent_hash = @splat(@truncate(number - 1)),
            .timestamp = number * 12,
            .coinbase = addr(0xc01b),
            .gas_limit = 30_000_000,
            .base_fee = 7,
            .blob_base_fee = 1,
            .hardfork = .CANCUN,
            .tx_count = 1,
        });
        if (hooks.tx_inspector) |tx| tx.onTxStart(.{
            .hardfork = .CANCUN,
            .origin = addr(0xaa),
            .target = addr(0xbb),
            .coinbase = addr(0xc01b),
            .is_create = false,
            .value = 0,
            .gas_limit = 100_000,
            .gas_price = 10,
            .input = &.{},
            .block_number = number,
            .block_timestamp = number * 12,
            .chain_id = 1,
            .blob_base_fee = 1,
            .blob_hash_count = 2,
        });
        hooks.onBlockBalanceChange(.{ .address = addr(0xc01b), .prev = 0, .new = 2_000_000, .reason = .block_reward });
        hooks.onBlockBalanceChange(.{ .address = addr(0xaa), .prev = 10, .new = 110, .reason = .withdrawal });
        if (number % 2 == 0) hooks.onBlockBalanceChange(.{ .address = addr(0xaa), .prev = 500, .new = 0, .reason = .fee_burn });
        hooks.onBlockEnd(.{ .number = number, .hash = @splat(@truncate(number)), .gas_used = 21_000, .tx_count = 1, .error_name = if (number == 3) "invalid block" else null });
    }
    hooks.onSkippedBlock(.{ .number = blocks + 1, .hash = @splat(0xff), .reason = "bad parent" });
    hooks.onClose();
}

fn supplyScenario(allocator: Allocator) anyerror!void {
    var supply = live_tracer.SupplyTracer.init(allocator, .{ .infer_eip1559_burn = true });
    defer supply.deinit();
    const children = [_]live_tracer.BlockHooks{supply.blockHooks()};
    var mux = live_tracer.MuxBlockHooks.init(&children);
    driveSupplyChain(mux.blockHooks(), 6);
    try check(supply.err);
    try testing.expectEqual(@as(usize, 6), supply.records.items.len);
    const jsonl = try render(allocator, &supply, live_tracer.SupplyTracer.writeJsonlRecord, .{});
    defer allocator.free(jsonl);
    try renderJson(allocator, &supply, live_tracer.SupplyTracer.writeSummaryJson, .{});
}

test "OOM: SupplyTracer block lifecycle, JSONL records and summary" {
    try testing.checkAllAllocationFailures(testing.allocator, supplyScenario, .{});
}

test "OOM: SupplyTracer totals never count a block whose record was not stored" {
    var fail_index: usize = 0;
    while (true) : (fail_index += 1) {
        var failing = testing.FailingAllocator.init(testing.allocator, .{ .fail_index = fail_index });
        var supply = live_tracer.SupplyTracer.init(failing.allocator(), .{});
        defer supply.deinit();
        driveSupplyChain(supply.blockHooks(), 8);
        if (!failing.has_induced_failure) break;
        try testing.expectEqual(@as(?anyerror, error.OutOfMemory), supply.err);
        const last = supply.latestRecord() orelse {
            try testing.expectEqual(@as(u256, 0), supply.total_issuance);
            continue;
        };
        try testing.expectEqual(last.cumulative_issuance, supply.total_issuance);
        try testing.expectEqual(last.cumulative_burn, supply.total_burn);
    }
}

// ---------------------------------------------------------------------------
// 8. ExecutionRecorder, DebugSession and FlamegraphCollector
// ---------------------------------------------------------------------------

fn debuggerScenario(allocator: Allocator, max_steps: ?usize) anyerror!void {
    var recorder = debugger.ExecutionRecorder.init(allocator, .{ .max_steps = max_steps });
    defer recorder.deinit();
    const i = recorder.inspector();
    driveOpcodes(i);
    i.onStorageChange(.{ .frame_id = 1, .address = addr(0xc0de), .slot = 1, .prev_value = 0, .new_value = 1, .is_read = false });
    driveCallTree(i);
    // Orphan opcode with no open frame.
    opcode(i, 99, 0, 0, 0xfd, 50, &.{ 0, 0 }, &.{});
    opcodeEnd(i, 99, 0, 0xfd, 50, 0, "execution reverted");
    try check(recorder.err);

    var session = recorder.session(allocator);
    defer session.deinit();
    _ = try session.addBreakpoint(.{ .pc = .{ .pc = 8 } });
    _ = try session.addBreakpoint(.{ .call_target = addr(0xb0b) });
    _ = try session.addBreakpoint(.{ .storage_slot = .{ .slot = 1 } });
    _ = try session.addBreakpoint(.on_fault);
    const revert_bp = try session.addBreakpoint(.on_revert);
    _ = try session.addBreakpoint(.{ .depth_at_most = 0 });
    session.removeBreakpoint(revert_bp);
    while (session.continueUntilBreakpoint()) |_| {
        const text = try render(allocator, &session, debugger.DebugSession.writeCurrentStateSummary, .{});
        allocator.free(text);
    }
    _ = session.continueBackUntilBreakpoint();
    _ = session.jumpToStep(0);
    _ = session.stepOver();
    _ = session.stepOut();
    const text = try render(allocator, &session, debugger.DebugSession.writeCurrentStateSummary, .{});
    allocator.free(text);
}

test "OOM: ExecutionRecorder timeline and DebugSession breakpoints and dumps" {
    try testing.checkAllAllocationFailures(testing.allocator, debuggerScenario, .{@as(?usize, null)});
    try testing.checkAllAllocationFailures(testing.allocator, debuggerScenario, .{@as(?usize, 4)});
}

const TestLabeler = struct {
    fn label(_: *anyopaque, address: Address, selector: ?[4]u8, buf: []u8) ?[]const u8 {
        if (!address.equals(addr(0xb0b))) return null;
        const sel = selector orelse return "Bob<fallback>";
        return std.fmt.bufPrint(buf, "Bob; fn 0x{x} & \"more\"", .{@as([]const u8, &sel)}) catch null;
    }
    const vtable: flamegraph.AddressLabeler.VTable = .{ .label = label };
};

fn flamegraphScenario(allocator: Allocator, compact: bool) anyerror!void {
    var dummy: u8 = 0;
    var collector = flamegraph.FlamegraphCollector.init(allocator, .{
        .labeler = .{ .ptr = &dummy, .vtable = &TestLabeler.vtable },
        .compact_addresses = compact,
    });
    defer collector.deinit();
    driveOpcodes(collector.inspector());
    driveCallTree(collector.inspector());
    driveOpcodes(collector.inspector());
    try check(collector.err);
    for ([_]bool{ false, true }) |include_opcodes| {
        const folded = try render(allocator, &collector, flamegraph.FlamegraphCollector.writeFoldedStacks, .{include_opcodes});
        defer allocator.free(folded);
        try testing.expect(folded.len > 0);
        const svg = try render(allocator, &collector, flamegraph.FlamegraphCollector.writeSvg, .{ "OOM <flame> & \"gas\"", include_opcodes });
        defer allocator.free(svg);
        try testing.expect(std.mem.endsWith(u8, svg, "</svg>\n"));
    }
}

fn flamegraphOpenFramesScenario(allocator: Allocator) anyerror!void {
    // Execution aborted mid-call: deinit frees the active frames' paths.
    var collector = flamegraph.FlamegraphCollector.init(allocator, .{});
    defer collector.deinit();
    const i = collector.inspector();
    enter(i, root_frame);
    enter(i, call_child);
    enter(i, reverted_grandchild);
    opcode(i, 3, 2, 0, 0x54, 500, &.{1}, null);
    opcodeEnd(i, 3, 0, 0x54, 500, 2100 / 10, null);
    try check(collector.err);
    const svg = try render(allocator, &collector, flamegraph.FlamegraphCollector.writeSvg, .{ "open", true });
    allocator.free(svg);
}

test "OOM: FlamegraphCollector samples, writeFoldedStacks and writeSvg" {
    try testing.checkAllAllocationFailures(testing.allocator, flamegraphScenario, .{false});
    try testing.checkAllAllocationFailures(testing.allocator, flamegraphScenario, .{true});
    try testing.checkAllAllocationFailures(testing.allocator, flamegraphOpenFramesScenario, .{});
}
