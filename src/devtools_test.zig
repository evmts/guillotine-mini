const std = @import("std");
const primitives = @import("voltaire");
const evm_mod = @import("evm.zig");
const host_mod = @import("host.zig");
const insp = @import("inspector.zig");
const tracers = @import("tracers.zig");
const debugger = @import("debugger.zig");
const flamegraph = @import("flamegraph.zig");
const evmc = @import("evmc_adapter.zig");

const testing = std.testing;
const Address = primitives.Address;
const Hardfork = primitives.Hardfork;
const Evm = evm_mod.Evm(.{});
const CallResult = Evm.CallResult;
const HostInterface = host_mod.HostInterface;

// ---------------------------------------------------------------------------
// Minimal bytecode assembler & in-memory test host
// ---------------------------------------------------------------------------

const Asm = struct {
    list: std.ArrayList(u8) = .{},

    fn deinit(self: *Asm) void {
        self.list.deinit(testing.allocator);
    }

    fn bytes(self: *const Asm) []const u8 {
        return self.list.items;
    }

    fn op(self: *Asm, code: []const u8) !void {
        try self.list.appendSlice(testing.allocator, code);
    }

    fn push(self: *Asm, value: u256) !void {
        if (value == 0) return self.op(&.{0x5f});
        const bits: usize = 256 - @as(usize, @clz(value));
        const n = (bits + 7) / 8;
        try self.list.append(testing.allocator, @intCast(0x5f + n));
        var buf: [32]u8 = undefined;
        std.mem.writeInt(u256, &buf, value, .big);
        try self.op(buf[32 - n ..]);
    }

    fn mstore(self: *Asm, offset: u256, value: u256) !void {
        try self.push(value);
        try self.push(offset);
        try self.op(&.{0x52});
    }

    fn sstore(self: *Asm, slot: u256, value: u256) !void {
        try self.push(value);
        try self.push(slot);
        try self.op(&.{0x55});
    }

    fn sload(self: *Asm, slot: u256) !void {
        try self.push(slot);
        try self.op(&.{ 0x54, 0x50 });
    }

    fn call(self: *Asm, to: u256, value: u256, in_off: u256, in_len: u256, out_off: u256, out_len: u256) !void {
        for ([_]u256{ out_len, out_off, in_len, in_off, value, to }) |v| try self.push(v);
        try self.op(&.{ 0x5a, 0xf1, 0x50 });
    }

    fn staticcall(self: *Asm, to: u256, in_off: u256, in_len: u256, out_off: u256, out_len: u256) !void {
        for ([_]u256{ out_len, out_off, in_len, in_off, to }) |v| try self.push(v);
        try self.op(&.{ 0x5a, 0xfa, 0x50 });
    }
};

const TestHost = struct {
    const SlotKey = struct { address: [20]u8, slot: u256 };

    balances: std.AutoHashMapUnmanaged(Address, u256) = .{},
    nonces: std.AutoHashMapUnmanaged(Address, u64) = .{},
    code: std.AutoHashMapUnmanaged(Address, []const u8) = .{},
    storage: std.AutoHashMapUnmanaged(SlotKey, u256) = .{},

    fn deinit(self: *TestHost) void {
        var it = self.code.valueIterator();
        while (it.next()) |code| testing.allocator.free(code.*);
        self.code.deinit(testing.allocator);
        self.balances.deinit(testing.allocator);
        self.nonces.deinit(testing.allocator);
        self.storage.deinit(testing.allocator);
    }

    fn oom() noreturn {
        @panic("test host out of memory");
    }

    fn from(ptr: *anyopaque) *TestHost {
        return @ptrCast(@alignCast(ptr));
    }

    fn getBalance(ptr: *anyopaque, address: Address) u256 {
        return from(ptr).balances.get(address) orelse 0;
    }
    fn setBalance(ptr: *anyopaque, address: Address, balance: u256) void {
        from(ptr).balances.put(testing.allocator, address, balance) catch oom();
    }
    fn getCode(ptr: *anyopaque, address: Address) []const u8 {
        return from(ptr).code.get(address) orelse &.{};
    }
    fn setCode(ptr: *anyopaque, address: Address, code: []const u8) void {
        const copy = testing.allocator.dupe(u8, code) catch oom();
        const old = from(ptr).code.fetchPut(testing.allocator, address, copy) catch oom();
        if (old) |entry| testing.allocator.free(entry.value);
    }
    fn getStorage(ptr: *anyopaque, address: Address, slot: u256) u256 {
        return from(ptr).storage.get(.{ .address = address.bytes, .slot = slot }) orelse 0;
    }
    fn setStorage(ptr: *anyopaque, address: Address, slot: u256, value: u256) void {
        from(ptr).storage.put(testing.allocator, .{ .address = address.bytes, .slot = slot }, value) catch oom();
    }
    fn getNonce(ptr: *anyopaque, address: Address) u64 {
        return from(ptr).nonces.get(address) orelse 0;
    }
    fn setNonce(ptr: *anyopaque, address: Address, nonce: u64) void {
        from(ptr).nonces.put(testing.allocator, address, nonce) catch oom();
    }

    const vtable: HostInterface.VTable = .{
        .getBalance = getBalance,
        .setBalance = setBalance,
        .getCode = getCode,
        .setCode = setCode,
        .getStorage = getStorage,
        .setStorage = setStorage,
        .getNonce = getNonce,
        .setNonce = setNonce,
    };

    fn interface(self: *TestHost) HostInterface {
        return .{ .ptr = self, .vtable = &vtable };
    }
};

const Chain = struct {
    host: TestHost,
    evm: Evm,

    fn init(self: *Chain, origin: Address) !void {
        self.host = .{};
        errdefer self.host.deinit();
        try self.evm.init(testing.allocator, self.host.interface(), .CANCUN, null, origin, 0, null);
    }

    fn deinit(self: *Chain) void {
        self.evm.deinit();
        self.host.deinit();
    }

    fn setCode(self: *Chain, address: Address, code: []const u8) void {
        TestHost.setCode(&self.host, address, code);
    }

    fn call(self: *Chain, caller: Address, to: Address, input: []const u8, gas: u64, sink: ?insp.Inspector) CallResult {
        if (sink) |s| self.evm.setInspector(s) else self.evm.clearInspector();
        return self.evm.call(.{ .call = .{ .caller = caller, .to = to, .value = 0, .input = input, .gas = gas } });
    }
};

fn addr(n: u256) Address {
    return Address.fromU256(n);
}

const ORIGIN: u256 = 0x1000;
const ROOT: u256 = 0x2000;
const CHILD_OK: u256 = 0x3000;
const CHILD_REVERT: u256 = 0x4000;
const VIEW: u256 = 0x5000;
const IDENTITY_PRECOMPILE: u256 = 0x04;

// ---------------------------------------------------------------------------
// 1. Debugger tests
// ---------------------------------------------------------------------------

test "Debugger records nested EVM execution and supports stepInto, stepOver, stepOut, stepBack, jumpToStep" {
    var root_code: Asm = .{};
    defer root_code.deinit();
    try root_code.mstore(0, 0xabcdef);
    try root_code.sstore(1, 0x42);
    try root_code.call(CHILD_OK, 0, 0, 4, 0, 0);
    try root_code.call(CHILD_REVERT, 0, 0, 0, 0, 0);
    try root_code.op(&.{0x00}); // STOP

    var child_ok: Asm = .{};
    defer child_ok.deinit();
    try child_ok.sload(0);
    try child_ok.sstore(0, 0x99);
    try child_ok.op(&.{0x00});

    var child_revert: Asm = .{};
    defer child_revert.deinit();
    try child_revert.push(0);
    try child_revert.push(0);
    try child_revert.op(&.{0xfd}); // REVERT

    const MockSourceMap = struct {
        root_addr: Address,

        fn resolve(ctx: *anyopaque, code_address: Address, pc: u64) ?debugger.SourceLocation {
            const self: *@This() = @ptrCast(@alignCast(ctx));
            return .{
                .file_id = if (code_address.equals(self.root_addr)) 1 else 2,
                .offset = @intCast(pc * 4),
                .length = 4,
                .jump = if (pc == 0) .in else .regular,
            };
        }

        const vtable: debugger.SourceMapResolver.VTable = .{ .resolve = resolve };

        fn resolver(self: *@This()) debugger.SourceMapResolver {
            return .{ .ptr = self, .vtable = &vtable };
        }
    };

    var smap: MockSourceMap = .{ .root_addr = addr(ROOT) };
    var recorder = debugger.ExecutionRecorder.init(testing.allocator, .{
        .capture_memory = true,
        .source_map = smap.resolver(),
    });
    defer recorder.deinit();

    var chain: Chain = undefined;
    try chain.init(addr(ORIGIN));
    defer chain.deinit();
    chain.setCode(addr(ROOT), root_code.bytes());
    chain.setCode(addr(CHILD_OK), child_ok.bytes());
    chain.setCode(addr(CHILD_REVERT), child_revert.bytes());
    TestHost.setStorage(&chain.host, addr(CHILD_OK), 0, 7);

    const res = chain.call(addr(ORIGIN), addr(ROOT), &.{ 0x11, 0x22, 0x33, 0x44 }, 500_000, recorder.inspector());
    try testing.expect(res.success);
    try testing.expect(recorder.err == null);
    try testing.expect(recorder.steps.items.len > 15);
    try testing.expectEqual(@as(usize, 3), recorder.call_frames.items.len);
    try testing.expect(recorder.storage_events.items.len >= 3);

    var session = recorder.session(testing.allocator);
    defer session.deinit();

    // Cursor starts at step 0 with resolved source location.
    const step0 = session.current().?;
    try testing.expectEqual(@as(usize, 0), step0.step_index);
    try testing.expectEqual(@as(usize, 1), step0.depth);
    try testing.expectEqual(@as(u32, 1), step0.source_loc.?.file_id);
    try testing.expectEqual(debugger.SourceLocation.Jump.in, step0.source_loc.?.jump);
    try testing.expect(session.stepBack() == null);

    // Step forward via stepInto until the first CALL opcode (0xf1).
    const bp_call = try session.addBreakpoint(.{ .opcode = 0xf1 });
    const call_step = session.continueUntilBreakpoint().?;
    try testing.expectEqual(@as(u8, 0xf1), call_step.op);
    try testing.expectEqual(@as(usize, 1), call_step.depth);
    try testing.expect(call_step.memory != null);
    try testing.expect(call_step.memory.?.len >= 32);
    const call_idx = call_step.step_index;

    // stepOver from CALL skips the entire CHILD_OK frame (depth 2) and lands back at depth 1.
    const after_over = session.stepOver().?;
    try testing.expectEqual(@as(usize, 1), after_over.depth);
    try testing.expect(after_over.step_index > call_idx + 1);
    try testing.expectEqual(@as(u8, 0x50), after_over.op); // POP call success flag

    // Time-travel jump back to the CALL opcode, then stepInto enters CHILD_OK (depth 2).
    _ = session.jumpToStep(call_idx).?;
    const child_entry = session.stepInto().?;
    try testing.expectEqual(@as(usize, 2), child_entry.depth);
    try testing.expect(child_entry.address.equals(addr(CHILD_OK)));
    try testing.expectEqual(@as(u32, 2), child_entry.source_loc.?.file_id);

    // stepBack rewinds back out of CHILD_OK to the parent's CALL opcode.
    const rewound = session.stepBack().?;
    try testing.expectEqual(call_idx, rewound.step_index);
    try testing.expectEqual(@as(usize, 1), rewound.depth);

    // Re-enter CHILD_OK and test stepOut returns to depth 1 at the exact same POP step.
    _ = session.stepInto().?;
    const after_out = session.stepOut().?;
    try testing.expectEqual(after_over.step_index, after_out.step_index);
    try testing.expectEqual(@as(usize, 1), after_out.depth);

    // Remove the CALL breakpoint and verify removal works.
    session.removeBreakpoint(bp_call);
    try testing.expectEqual(@as(usize, 0), session.breakpointCount());

    // Jump to start and test storage_slot breakpoint (slot 0 in CHILD_OK).
    _ = session.jumpToStep(0).?;
    const bp_slot = try session.addBreakpoint(.{ .storage_slot = .{ .address = addr(CHILD_OK), .slot = 0 } });
    const sload_hit = session.continueUntilBreakpoint().?;
    try testing.expectEqual(@as(u8, 0x54), sload_hit.op); // SLOAD slot 0
    try testing.expect(sload_hit.address.equals(addr(CHILD_OK)));
    const sstore_hit = session.continueUntilBreakpoint().?;
    try testing.expectEqual(@as(u8, 0x55), sstore_hit.op); // SSTORE slot 0
    session.removeBreakpoint(bp_slot);

    // Test on_revert breakpoint hits REVERT inside CHILD_REVERT.
    _ = session.jumpToStep(0).?;
    const bp_rev = try session.addBreakpoint(.on_revert);
    const rev_hit = session.continueUntilBreakpoint().?;
    try testing.expectEqual(@as(u8, 0xfd), rev_hit.op);
    try testing.expect(rev_hit.address.equals(addr(CHILD_REVERT)));
    try testing.expectEqualStrings("execution reverted", rev_hit.error_name.?);
    session.removeBreakpoint(bp_rev);

    // Test call_target breakpoint stops at first opcode inside CHILD_OK.
    _ = session.jumpToStep(0).?;
    const bp_target = try session.addBreakpoint(.{ .call_target = addr(CHILD_OK) });
    const target_hit = session.continueUntilBreakpoint().?;
    try testing.expect(target_hit.address.equals(addr(CHILD_OK)));
    try testing.expectEqual(@as(u64, 0), target_hit.pc);
    session.removeBreakpoint(bp_target);

    // Test PC breakpoint with address filter + backward breakpoint search.
    const bp_pc = try session.addBreakpoint(.{ .pc = .{ .address = addr(ROOT), .pc = 0 } });
    const back_hit = session.continueBackUntilBreakpoint().?;
    try testing.expectEqual(@as(usize, 0), back_hit.step_index);
    session.removeBreakpoint(bp_pc);

    // Test depth_at_most breakpoint from inside CHILD_OK returns to depth 1.
    _ = session.jumpToStep(child_entry.step_index).?;
    const bp_depth = try session.addBreakpoint(.{ .depth_at_most = 1 });
    const depth_hit = session.continueUntilBreakpoint().?;
    try testing.expectEqual(@as(usize, 1), depth_hit.depth);
    session.removeBreakpoint(bp_depth);

    // Test out-of-bounds jumpToStep returns null.
    try testing.expect(session.jumpToStep(recorder.steps.items.len) == null);

    // Verify human-readable state summary contains PC, op, gas, depth, stack, memory, and source.
    _ = session.jumpToStep(call_idx).?;
    var aw: std.Io.Writer.Allocating = .init(testing.allocator);
    defer aw.deinit();
    try session.writeCurrentStateSummary(&aw.writer);
    const summary = aw.written();
    try testing.expect(std.mem.indexOf(u8, summary, "CALL (0xf1)") != null);
    try testing.expect(std.mem.indexOf(u8, summary, "depth 1") != null);
    try testing.expect(std.mem.indexOf(u8, summary, "Gas:") != null);
    try testing.expect(std.mem.indexOf(u8, summary, "Stack (") != null);
    try testing.expect(std.mem.indexOf(u8, summary, "Memory (") != null);
    try testing.expect(std.mem.indexOf(u8, summary, "Source: file=1") != null);
}

test "Debugger respects max_steps, capture_memory=false, and on_fault breakpoints" {
    var code: Asm = .{};
    defer code.deinit();
    try code.push(1);
    try code.push(2);
    try code.op(&.{0x01}); // ADD
    try code.op(&.{0xfe}); // INVALID (fault!)

    // First verify on_fault catches INVALID opcode.
    var rec_full = debugger.ExecutionRecorder.init(testing.allocator, .{ .capture_memory = false });
    defer rec_full.deinit();
    var chain: Chain = undefined;
    try chain.init(addr(ORIGIN));
    defer chain.deinit();
    chain.setCode(addr(ROOT), code.bytes());

    const res = chain.call(addr(ORIGIN), addr(ROOT), &.{}, 100_000, rec_full.inspector());
    try testing.expect(!res.success);
    try testing.expectEqual(@as(usize, 4), rec_full.steps.items.len);
    for (rec_full.steps.items) |step| try testing.expect(step.memory == null);

    var sess = rec_full.session(testing.allocator);
    defer sess.deinit();
    _ = try sess.addBreakpoint(.on_fault);
    const fault_step = sess.continueUntilBreakpoint().?;
    try testing.expectEqual(@as(u8, 0xfe), fault_step.op);
    try testing.expectEqualStrings("invalid opcode", fault_step.error_name.?);

    // Now verify max_steps cap truncates cleanly.
    var rec_capped = debugger.ExecutionRecorder.init(testing.allocator, .{ .max_steps = 2, .capture_memory = false });
    defer rec_capped.deinit();
    _ = chain.call(addr(ORIGIN), addr(ROOT), &.{}, 100_000, rec_capped.inspector());
    try testing.expect(rec_capped.truncated);
    try testing.expectEqual(@as(usize, 2), rec_capped.steps.items.len);
}

// ---------------------------------------------------------------------------
// 2. FlamegraphCollector tests
// ---------------------------------------------------------------------------

test "FlamegraphCollector exports folded stacks with exact gas sum and valid escaped SVG" {
    var root_code: Asm = .{};
    defer root_code.deinit();
    try root_code.mstore(0, 0x11223344);
    try root_code.staticcall(VIEW, 0, 4, 0, 32);
    try root_code.call(IDENTITY_PRECOMPILE, 0, 0, 4, 32, 4);
    try root_code.op(&.{0x00});

    var view_code: Asm = .{};
    defer view_code.deinit();
    try view_code.sload(5);
    try view_code.mstore(0, 0xdeadbeef);
    try view_code.op(&.{0x00});

    const Labeler = struct {
        fn label(_: *anyopaque, address: Address, _: ?[4]u8, _: []u8) ?[]const u8 {
            if (address.equals(addr(ROOT))) return "Router<A&B>;main";
            if (address.equals(addr(VIEW))) return "Vault.read";
            if (address.equals(addr(IDENTITY_PRECOMPILE))) return "Identity";
            return null;
        }

        const vtable: flamegraph.AddressLabeler.VTable = .{ .label = label };

        fn interface(self: *@This()) flamegraph.AddressLabeler {
            return .{ .ptr = self, .vtable = &vtable };
        }
    };

    var labeler: Labeler = .{};
    var collector = flamegraph.FlamegraphCollector.init(testing.allocator, .{
        .labeler = labeler.interface(),
    });
    defer collector.deinit();

    var chain: Chain = undefined;
    try chain.init(addr(ORIGIN));
    defer chain.deinit();
    chain.setCode(addr(ROOT), root_code.bytes());
    chain.setCode(addr(VIEW), view_code.bytes());
    TestHost.setStorage(&chain.host, addr(VIEW), 5, 123);

    const res = chain.call(addr(ORIGIN), addr(ROOT), &.{ 0xaa, 0xbb, 0xcc, 0xdd }, 500_000, collector.inspector());
    try testing.expect(res.success);
    try testing.expect(collector.err == null);

    // 1) Opcode-level folded stacks.
    var folded_ops: std.Io.Writer.Allocating = .init(testing.allocator);
    defer folded_ops.deinit();
    try collector.writeFoldedStacks(&folded_ops.writer, true);
    const ops_text = folded_ops.written();
    try testing.expect(ops_text.len > 0);
    // Semicolon in user label "Router<A&B>;main" must be sanitized to ':'.
    try testing.expect(std.mem.indexOf(u8, ops_text, "CALL:Router<A&B>:main;STATICCALL:Vault.read;SLOAD ") != null);
    try testing.expect(std.mem.indexOf(u8, ops_text, "CALL:Router<A&B>:main;STATICCALL:Vault.read;MSTORE ") != null);
    try testing.expect(std.mem.indexOf(u8, ops_text, "CALL:Router<A&B>:main;PRECOMPILE:Identity ") != null);

    // Parse every folded-stack line and verify format + gas sum.
    var ops_sum: u64 = 0;
    var lines = std.mem.splitScalar(u8, ops_text, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        const space = std.mem.lastIndexOfScalar(u8, line, ' ').?;
        const gas_val = try std.fmt.parseInt(u64, line[space + 1 ..], 10);
        try testing.expect(gas_val > 0);
        ops_sum += gas_val;
    }
    try testing.expectEqual(collector.totalGas(true), ops_sum);
    try testing.expect(ops_sum > 0);

    // 2) Frame-only folded stacks.
    var folded_frames: std.Io.Writer.Allocating = .init(testing.allocator);
    defer folded_frames.deinit();
    try collector.writeFoldedStacks(&folded_frames.writer, false);
    const frames_text = folded_frames.written();
    try testing.expect(std.mem.indexOf(u8, frames_text, ";SLOAD ") == null);
    var frame_sum: u64 = 0;
    var flines = std.mem.splitScalar(u8, frames_text, '\n');
    while (flines.next()) |line| {
        if (line.len == 0) continue;
        const space = std.mem.lastIndexOfScalar(u8, line, ' ').?;
        frame_sum += try std.fmt.parseInt(u64, line[space + 1 ..], 10);
    }
    try testing.expectEqual(collector.totalGas(false), frame_sum);
    try testing.expectEqual(ops_sum, frame_sum);

    // 3) Interactive SVG export with XML escaping and <title> tooltips.
    var svg_buf: std.Io.Writer.Allocating = .init(testing.allocator);
    defer svg_buf.deinit();
    try collector.writeSvg(&svg_buf.writer, "Gas <Flame> & Profile \"v1\"", true);
    const svg = svg_buf.written();
    try testing.expect(std.mem.startsWith(u8, svg, "<svg "));
    try testing.expect(std.mem.endsWith(u8, svg, "</svg>\n"));
    try testing.expect(std.mem.indexOf(u8, svg, "Gas &lt;Flame&gt; &amp; Profile &quot;v1&quot;") != null);
    try testing.expect(std.mem.indexOf(u8, svg, "<title>CALL:Router&lt;A&amp;B&gt;:main;STATICCALL:Vault.read;SLOAD (") != null);
    try testing.expect(std.mem.indexOf(u8, svg, " gas, ") != null);
    try testing.expect(std.mem.indexOf(u8, svg, "%)</title>") != null);
    try testing.expect(std.mem.indexOf(u8, svg, "<rect ") != null);
}

test "FlamegraphCollector handles empty run cleanly" {
    var collector = flamegraph.FlamegraphCollector.init(testing.allocator, .{});
    defer collector.deinit();

    var svg_buf: std.Io.Writer.Allocating = .init(testing.allocator);
    defer svg_buf.deinit();
    try collector.writeSvg(&svg_buf.writer, "Empty", true);
    const svg = svg_buf.written();
    try testing.expect(std.mem.startsWith(u8, svg, "<svg "));
    try testing.expect(std.mem.endsWith(u8, svg, "</svg>\n"));
    try testing.expect(std.mem.indexOf(u8, svg, "No gas samples recorded") != null);
}

// ---------------------------------------------------------------------------
// 3. EVMC adapter & EvmcHostBridge tests
// ---------------------------------------------------------------------------

test "EVMC C-ABI types have exact byte layout and big-endian conversions" {
    try testing.expectEqual(@as(usize, 20), @sizeOf(evmc.EvmcAddress));
    try testing.expectEqual(@as(usize, 1), @alignOf(evmc.EvmcAddress));
    try testing.expectEqual(@as(usize, 32), @sizeOf(evmc.EvmcBytes32));
    try testing.expectEqual(@as(usize, 1), @alignOf(evmc.EvmcBytes32));
    try testing.expectEqual(@sizeOf(c_int), @sizeOf(evmc.EvmcCallKind));
    try testing.expectEqual(@sizeOf(c_int), @sizeOf(evmc.EvmcStatusCode));
    try testing.expectEqual(@sizeOf(c_int), @sizeOf(evmc.EvmcRevision));
    try testing.expectEqual(@sizeOf(c_int), @sizeOf(evmc.EvmcAccessStatus));
    try testing.expectEqual(@sizeOf(c_int), @sizeOf(evmc.EvmcStorageStatus));

    const val: u256 = 0x01020304_05060708_00000000_00000000_00000000_00000000_00000000_deadbeef;
    const word = evmc.EvmcBytes32.fromU256(val);
    try testing.expectEqual(@as(u8, 0x01), word.bytes[0]);
    try testing.expectEqual(@as(u8, 0x02), word.bytes[1]);
    try testing.expectEqual(@as(u8, 0xef), word.bytes[31]);
    try testing.expectEqual(val, word.toU256());

    const a = addr(0x1234567890abcdef);
    const ea = evmc.EvmcAddress.fromAddress(a);
    try testing.expect(ea.toAddress().equals(a));
}

test "EVMC revision converters round-trip Frontier through Osaka" {
    const revisions = std.meta.tags(evmc.EvmcRevision);
    for (revisions) |rev| {
        if (rev == .experimental) continue;
        const hf = evmc.toHardfork(rev);
        try testing.expectEqual(rev, evmc.fromHardfork(hf));
    }
    try testing.expectEqual(evmc.EvmcRevision.homestead, evmc.fromHardfork(.DAO));
    try testing.expectEqual(evmc.EvmcRevision.istanbul, evmc.fromHardfork(.MUIR_GLACIER));
    try testing.expectEqual(evmc.EvmcRevision.london, evmc.fromHardfork(.ARROW_GLACIER));
    try testing.expectEqual(evmc.EvmcRevision.london, evmc.fromHardfork(.GRAY_GLACIER));
    try testing.expectEqual(evmc.EvmcRevision.paris, evmc.fromHardfork(.MERGE));
    try testing.expectEqual(evmc.EvmcRevision.osaka, evmc.fromHardfork(.OSAKA));
    try testing.expectEqual(Hardfork.OSAKA, evmc.toHardfork(.osaka));
}

test "EVMC experimental revision maps to the newest Voltaire fork" {
    const newest = evmc.toHardfork(.experimental);
    try testing.expect(@intFromEnum(newest) >= @intFromEnum(Hardfork.OSAKA));
    const expected: evmc.EvmcRevision = if (newest == .OSAKA) .osaka else .experimental;
    try testing.expectEqual(expected, evmc.fromHardfork(newest));
}

test "EvmcHostBridge round-trips host state operations and emits Inspector events" {
    const EventCounter = struct {
        storage_reads: usize = 0,
        storage_writes: usize = 0,
        transient_reads: usize = 0,
        transient_writes: usize = 0,
        logs: usize = 0,
        cold_accesses: usize = 0,
        warm_accesses: usize = 0,
        balance_changes: usize = 0,
        selfdestructs: usize = 0,

        fn onStorage(ptr: *anyopaque, ev: insp.StorageChangeEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            if (ev.is_read) self.storage_reads += 1 else self.storage_writes += 1;
        }
        fn onTransient(ptr: *anyopaque, ev: insp.TransientStorageEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            if (ev.is_write) self.transient_writes += 1 else self.transient_reads += 1;
        }
        fn onLog(ptr: *anyopaque, _: insp.LogEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            self.logs += 1;
        }
        fn onAccess(ptr: *anyopaque, ev: insp.AccessEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            if (ev.was_warm) self.warm_accesses += 1 else self.cold_accesses += 1;
        }
        fn onBalance(ptr: *anyopaque, _: insp.BalanceChangeEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            self.balance_changes += 1;
        }
        fn onSelfDestruct(ptr: *anyopaque, _: insp.SelfDestructEvent) void {
            const self: *@This() = @ptrCast(@alignCast(ptr));
            self.selfdestructs += 1;
        }

        const vtable: insp.Inspector.VTable = .{
            .onStorageChange = onStorage,
            .onTransientStorageChange = onTransient,
            .onLog = onLog,
            .onAccess = onAccess,
            .onBalanceChange = onBalance,
            .onSelfDestruct = onSelfDestruct,
        };

        fn inspector(self: *@This()) insp.Inspector {
            return .{ .ptr = self, .vtable = &vtable };
        }
    };

    var host: TestHost = .{};
    defer host.deinit();

    const contract = addr(0xaaaa);
    const beneficiary = addr(0xbbbb);
    const missing = addr(0xcccc);
    const sample_code = [_]u8{ 0x60, 0x01, 0x60, 0x02, 0x01, 0x00 };

    TestHost.setBalance(&host, contract, 500);
    TestHost.setCode(&host, contract, &sample_code);
    TestHost.setStorage(&host, contract, 10, 77);

    var counter: EventCounter = .{};
    const tx_ctx: evmc.EvmcTxContext = .{
        .block_number = 12345,
        .block_timestamp = 1700000000,
        .chain_id = evmc.EvmcBytes32.fromU256(1),
    };
    var bridge = evmc.EvmcHostBridge.init(testing.allocator, host.interface(), .{
        .inspector = counter.inspector(),
        .tx_context = tx_ctx,
        .frame_id = 7,
    });
    defer bridge.deinit();

    const block_hash = [_]u8{0xab} ** 32;
    try bridge.setBlockHash(12344, block_hash);

    const iface = evmc.EvmcHostBridge.hostInterface();
    const ctx = bridge.hostContext();

    const e_contract = evmc.EvmcAddress.fromAddress(contract);
    const e_ben = evmc.EvmcAddress.fromAddress(beneficiary);
    const e_missing = evmc.EvmcAddress.fromAddress(missing);

    // account_exists & get_balance
    try testing.expect(iface.account_exists(ctx, &e_contract));
    try testing.expect(!iface.account_exists(ctx, &e_missing));
    try testing.expectEqual(@as(u256, 500), iface.get_balance(ctx, &e_contract).toU256());

    // code size, hash, and copy
    try testing.expectEqual(sample_code.len, iface.get_code_size(ctx, &e_contract));
    var expected_hash: [32]u8 = undefined;
    std.crypto.hash.sha3.Keccak256.hash(&sample_code, &expected_hash, .{});
    try testing.expectEqualSlices(u8, &expected_hash, &iface.get_code_hash(ctx, &e_contract).bytes);
    try testing.expect(iface.get_code_hash(ctx, &e_missing).isZero());

    var code_buf: [4]u8 = undefined;
    try testing.expectEqual(@as(usize, 4), iface.copy_code(ctx, &e_contract, 1, &code_buf, code_buf.len));
    try testing.expectEqualSlices(u8, sample_code[1..5], &code_buf);
    try testing.expectEqual(@as(usize, 0), iface.copy_code(ctx, &e_contract, 99, &code_buf, code_buf.len));

    // storage reads & writes + EIP-2200 status classification
    const slot1 = evmc.EvmcBytes32.fromU256(1);
    const slot10 = evmc.EvmcBytes32.fromU256(10);
    const zero = evmc.EvmcBytes32.fromU256(0);
    const v1 = evmc.EvmcBytes32.fromU256(0x1234);
    const v2 = evmc.EvmcBytes32.fromU256(0x5678);
    const orig10 = evmc.EvmcBytes32.fromU256(77);

    try testing.expectEqual(@as(u256, 77), iface.get_storage(ctx, &e_contract, &slot10).toU256());
    try testing.expectEqual(evmc.EvmcStorageStatus.added, iface.set_storage(ctx, &e_contract, &slot1, &v1));
    try testing.expectEqual(evmc.EvmcStorageStatus.assigned, iface.set_storage(ctx, &e_contract, &slot1, &v1));
    try testing.expectEqual(evmc.EvmcStorageStatus.added_deleted, iface.set_storage(ctx, &e_contract, &slot1, &zero));
    try testing.expectEqual(evmc.EvmcStorageStatus.modified, iface.set_storage(ctx, &e_contract, &slot10, &v2));
    try testing.expectEqual(evmc.EvmcStorageStatus.modified_restored, iface.set_storage(ctx, &e_contract, &slot10, &orig10));
    try testing.expectEqual(@as(u256, 77), host.interface().getStorage(contract, 10));

    // transient storage (EIP-1153)
    const tslot = evmc.EvmcBytes32.fromU256(99);
    try testing.expectEqual(@as(u256, 0), iface.get_transient_storage(ctx, &e_contract, &tslot).toU256());
    iface.set_transient_storage(ctx, &e_contract, &tslot, &v2);
    try testing.expectEqual(@as(u256, 0x5678), iface.get_transient_storage(ctx, &e_contract, &tslot).toU256());
    bridge.clearTransientStorage();
    try testing.expectEqual(@as(u256, 0), iface.get_transient_storage(ctx, &e_contract, &tslot).toU256());

    // access_account & access_storage (cold -> warm)
    try testing.expectEqual(evmc.EvmcAccessStatus.cold, iface.access_account(ctx, &e_contract));
    try testing.expectEqual(evmc.EvmcAccessStatus.warm, iface.access_account(ctx, &e_contract));
    try testing.expectEqual(evmc.EvmcAccessStatus.cold, iface.access_storage(ctx, &e_contract, &slot1));
    try testing.expectEqual(evmc.EvmcAccessStatus.warm, iface.access_storage(ctx, &e_contract, &slot1));

    // emit_log
    const topics = [_]evmc.EvmcBytes32{evmc.EvmcBytes32.fromU256(0xaa)};
    const log_data = [_]u8{ 0xde, 0xad, 0xbe, 0xef };
    iface.emit_log(ctx, &e_contract, &log_data, log_data.len, &topics, topics.len);
    try testing.expectEqual(@as(usize, 1), bridge.logs.items.len);
    try testing.expectEqualSlices(u8, &log_data, bridge.logs.items[0].data);

    // tx context & block hash
    const got_ctx = iface.get_tx_context(ctx);
    try testing.expectEqual(tx_ctx.block_number, got_ctx.block_number);
    try testing.expectEqualSlices(u8, &block_hash, &iface.get_block_hash(ctx, 12344).bytes);
    try testing.expect(iface.get_block_hash(ctx, 99999).isZero());

    // selfdestruct transfers balance and reports first-registration boolean
    try testing.expect(iface.selfdestruct(ctx, &e_contract, &e_ben));
    try testing.expect(!iface.selfdestruct(ctx, &e_contract, &e_ben));
    try testing.expectEqual(@as(u256, 0), host.interface().getBalance(contract));
    try testing.expectEqual(@as(u256, 500), host.interface().getBalance(beneficiary));

    // Inspector callbacks fired for every category
    try testing.expectEqual(@as(usize, 1), counter.storage_reads);
    try testing.expectEqual(@as(usize, 5), counter.storage_writes);
    try testing.expectEqual(@as(usize, 3), counter.transient_reads);
    try testing.expectEqual(@as(usize, 1), counter.transient_writes);
    try testing.expectEqual(@as(usize, 1), counter.logs);
    try testing.expectEqual(@as(usize, 2), counter.cold_accesses);
    try testing.expectEqual(@as(usize, 2), counter.warm_accesses);
    try testing.expectEqual(@as(usize, 2), counter.balance_changes);
    try testing.expectEqual(@as(usize, 2), counter.selfdestructs);
    try testing.expect(bridge.err == null);
}

// ---------------------------------------------------------------------------
// 4. Review tests for GasProfiler saturation and FourByteTracer leading zeros
// ---------------------------------------------------------------------------

test "GasProfiler saturates total_gas, memory_expansion_gas, and exclusive_gas without overflow" {
    var profiler = tracers.GasProfiler.init(testing.allocator);
    defer profiler.deinit();
    const sink = profiler.inspector();

    sink.onEnter(.{
        .frame_id = 0,
        .parent_id = null,
        .depth = 1,
        .call_type = .call,
        .from = addr(ORIGIN),
        .to = addr(ROOT),
        .code_address = addr(ROOT),
        .value = 0,
        .gas = 1000,
        .input = &.{},
        .is_static = false,
        .is_precompile = false,
        .is_delegated = false,
        .code = &.{},
    });

    const huge = std.math.maxInt(u64) - 5;
    sink.onOpcodeEnd(.{
        .frame_id = 0,
        .pc = 0,
        .op = 0x52, // MSTORE
        .gas_cost = huge,
        .gas_after = 0,
        .memory_expansion_gas = huge,
        .error_name = null,
    });
    sink.onOpcodeEnd(.{
        .frame_id = 0,
        .pc = 1,
        .op = 0x52, // MSTORE
        .gas_cost = 100,
        .gas_after = 0,
        .memory_expansion_gas = 100,
        .error_name = null,
    });

    // Nested child claiming more gas than parent should saturate parent's exclusive_gas at 0.
    sink.onEnter(.{
        .frame_id = 1,
        .parent_id = 0,
        .depth = 2,
        .call_type = .call,
        .from = addr(ROOT),
        .to = addr(CHILD_OK),
        .code_address = addr(CHILD_OK),
        .value = 0,
        .gas = 500,
        .input = &.{},
        .is_static = false,
        .is_precompile = false,
        .is_delegated = false,
        .code = &.{},
    });
    sink.onExit(.{
        .frame_id = 1,
        .parent_id = 0,
        .depth = 2,
        .output = &.{},
        .gas_used = 500,
        .gas_left = 0,
        .reverted = false,
        .error_name = null,
        .created_address = null,
    });
    sink.onExit(.{
        .frame_id = 0,
        .parent_id = null,
        .depth = 1,
        .output = &.{},
        .gas_used = 100,
        .gas_left = 900,
        .reverted = false,
        .error_name = null,
        .created_address = null,
    });

    try testing.expectEqual(@as(u64, 2), profiler.opcodes[0x52].count);
    try testing.expectEqual(std.math.maxInt(u64), profiler.opcodes[0x52].total_gas);
    try testing.expectEqual(std.math.maxInt(u64), profiler.opcodes[0x52].memory_expansion_gas);
    try testing.expectEqual(@as(u64, 0), profiler.frames.items[0].exclusive_gas);
}

test "FourByteTracer preserves leading zeros in exact 0x00000001-0 JSON key" {
    var tracer = tracers.FourByteTracer.init(testing.allocator);
    defer tracer.deinit();
    const sink = tracer.inspector();

    sink.onEnter(.{
        .frame_id = 0,
        .parent_id = null,
        .depth = 1,
        .call_type = .call,
        .from = addr(ORIGIN),
        .to = addr(ROOT),
        .code_address = addr(ROOT),
        .value = 0,
        .gas = 100_000,
        .input = &.{ 0x00, 0x00, 0x00, 0x01 },
        .is_static = false,
        .is_precompile = false,
        .is_delegated = false,
        .code = &.{},
    });

    try testing.expectEqual(@as(u64, 1), tracer.getCount(.{ 0x00, 0x00, 0x00, 0x01 }, 0));

    var aw: std.Io.Writer.Allocating = .init(testing.allocator);
    defer aw.deinit();
    try tracer.writeJson(&aw.writer);
    try testing.expectEqualStrings("{\"0x00000001-0\":1}", aw.written());
}

test "refAllDecls compiles every public declaration in debugger, flamegraph, and evmc_adapter" {
    testing.refAllDecls(debugger);
    testing.refAllDecls(flamegraph);
    testing.refAllDecls(evmc);
}

test "FlamegraphCollector compact_addresses formats unlabeled addresses as 0xaaaa..bbbb" {
    var collector = flamegraph.FlamegraphCollector.init(testing.allocator, .{
        .compact_addresses = true,
    });
    defer collector.deinit();
    const sink = collector.inspector();

    sink.onEnter(.{
        .frame_id = 0,
        .parent_id = null,
        .depth = 1,
        .call_type = .call,
        .from = addr(ORIGIN),
        .to = addr(0x1111000000000000000000000000000000002222),
        .code_address = addr(0x1111000000000000000000000000000000002222),
        .value = 0,
        .gas = 10_000,
        .input = &.{},
        .is_static = false,
        .is_precompile = false,
        .is_delegated = false,
        .code = &.{},
    });
    sink.onOpcode(.{
        .frame_id = 0,
        .pc = 0,
        .op = 0x54,
        .op_name = "SLOAD",
        .gas = 10_000,
        .memory_size = 0,
        .memory = null,
        .stack = &.{},
        .return_data = &.{},
        .depth = 1,
        .refund = 0,
        .address = addr(0x1111000000000000000000000000000000002222),
        .code_address = addr(0x1111000000000000000000000000000000002222),
    });
    sink.onOpcodeEnd(.{
        .frame_id = 0,
        .pc = 0,
        .op = 0x54,
        .gas_cost = 2100,
        .gas_after = 7900,
        .memory_expansion_gas = 0,
        .error_name = null,
    });
    sink.onExit(.{
        .frame_id = 0,
        .parent_id = null,
        .depth = 1,
        .output = &.{},
        .gas_used = 2100,
        .gas_left = 7900,
        .reverted = false,
        .error_name = null,
        .created_address = null,
    });

    var aw: std.Io.Writer.Allocating = .init(testing.allocator);
    defer aw.deinit();
    try collector.writeFoldedStacks(&aw.writer, true);
    try testing.expectEqualStrings("CALL:0x1111..2222;SLOAD 2100\n", aw.written());
}

test "EvmcHostBridge covers remaining EIP-2200 storage transitions and call handler" {
    var host: TestHost = .{};
    defer host.deinit();
    const contract = addr(0xdddd);
    TestHost.setStorage(&host, contract, 20, 50);
    TestHost.setStorage(&host, contract, 21, 60);

    const CustomCall = struct {
        called: bool = false,
        fn handle(ctx: ?*anyopaque, msg: *const evmc.EvmcMessage) evmc.EvmcResult {
            const self: *@This() = @ptrCast(@alignCast(ctx.?));
            self.called = true;
            return .{
                .status_code = .success,
                .gas_left = msg.gas - 10,
                .gas_refund = 0,
                .output_data = null,
                .output_size = 0,
                .release = null,
                .create_address = .{},
            };
        }
    };
    var custom: CustomCall = .{};
    var bridge = evmc.EvmcHostBridge.init(testing.allocator, host.interface(), .{
        .call_handler = CustomCall.handle,
        .call_handler_ctx = &custom,
    });
    defer bridge.deinit();

    const iface = evmc.EvmcHostBridge.hostInterface();
    const ctx = bridge.hostContext();
    const e_c = evmc.EvmcAddress.fromAddress(contract);
    const s20 = evmc.EvmcBytes32.fromU256(20);
    const s21 = evmc.EvmcBytes32.fromU256(21);
    const zero = evmc.EvmcBytes32.fromU256(0);
    const v50 = evmc.EvmcBytes32.fromU256(50);
    const v99 = evmc.EvmcBytes32.fromU256(99);

    // 50 -> 0 (deleted) -> 99 (deleted_added) -> 0 (modified_deleted) -> 50 (deleted_restored)
    try testing.expectEqual(evmc.EvmcStorageStatus.deleted, iface.set_storage(ctx, &e_c, &s20, &zero));
    try testing.expectEqual(evmc.EvmcStorageStatus.deleted_added, iface.set_storage(ctx, &e_c, &s20, &v99));
    try testing.expectEqual(evmc.EvmcStorageStatus.modified_deleted, iface.set_storage(ctx, &e_c, &s20, &zero));
    try testing.expectEqual(evmc.EvmcStorageStatus.deleted_restored, iface.set_storage(ctx, &e_c, &s20, &v50));

    // 60 -> 99 (modified) -> 0 (modified_deleted)
    try testing.expectEqual(evmc.EvmcStorageStatus.modified, iface.set_storage(ctx, &e_c, &s21, &v99));
    try testing.expectEqual(evmc.EvmcStorageStatus.modified_deleted, iface.set_storage(ctx, &e_c, &s21, &zero));

    // Call dispatch through custom call handler
    const msg: evmc.EvmcMessage = .{
        .kind = .call,
        .flags = 0,
        .depth = 0,
        .gas = 1000,
        .recipient = e_c,
        .sender = e_c,
        .input_data = null,
        .input_size = 0,
        .value = zero,
        .create2_salt = zero,
        .code_address = e_c,
    };
    const res = iface.call(ctx, &msg);
    try testing.expect(custom.called);
    try testing.expectEqual(evmc.EvmcStatusCode.success, res.status_code);
    try testing.expectEqual(@as(i64, 990), res.gas_left);
}
