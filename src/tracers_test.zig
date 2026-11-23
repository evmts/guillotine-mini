const std = @import("std");
const primitives = @import("voltaire");
const evm_mod = @import("evm.zig");
const insp = @import("inspector.zig");
const tracers = @import("tracers.zig");

const testing = std.testing;
const Address = primitives.Address;
const Evm = evm_mod.Evm(.{});
const CallResult = Evm.CallResult;
const HostInterface = @import("host.zig").HostInterface;

const CallTracer = tracers.CallTracer;
const FourByteTracer = tracers.FourByteTracer;
const PrestateTracer = tracers.PrestateTracer;
const AccessListInspector = tracers.AccessListInspector;
const GasProfiler = tracers.GasProfiler;
const CoverageInspector = tracers.CoverageInspector;

// ---------------------------------------------------------------------------
// Bytecode assembler
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

    /// Store `len` bytes of `value` left-aligned in the word at `offset`.
    fn mstoreLeft(self: *Asm, offset: u256, value: u256, len: u8) !void {
        const shift: u8 = @intCast((32 - @as(u16, len)) * 8);
        try self.push(value << shift);
        try self.push(offset);
        try self.op(&.{0x52});
    }

    fn call(self: *Asm, to: u256, value: u256, in_off: u256, in_len: u256, out_off: u256, out_len: u256) !void {
        for ([_]u256{ out_len, out_off, in_len, in_off, value, to }) |v| try self.push(v);
        try self.op(&.{ 0x5a, 0xf1, 0x50 });
    }

    fn callNoValue(self: *Asm, opcode: u8, to: u256, in_off: u256, in_len: u256, out_off: u256, out_len: u256) !void {
        for ([_]u256{ out_len, out_off, in_len, in_off, to }) |v| try self.push(v);
        try self.op(&.{ 0x5a, opcode, 0x50 });
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

    fn log(self: *Asm, topic: ?u256) !void {
        if (topic) |t| try self.push(t);
        try self.push(0);
        try self.push(0);
        try self.op(&.{if (topic == null) 0xa0 else 0xa1});
    }

    fn returnWord(self: *Asm, value: u256) !void {
        try self.push(value);
        try self.push(0);
        try self.op(&.{0x52});
        try self.push(32);
        try self.push(0);
        try self.op(&.{0xf3});
    }

    fn revertError(self: *Asm, comptime reason: []const u8) !void {
        comptime std.debug.assert(reason.len <= 32);
        try self.mstoreLeft(0, 0x08c379a0, 4);
        try self.push(32);
        try self.push(4);
        try self.op(&.{0x52});
        try self.push(reason.len);
        try self.push(36);
        try self.op(&.{0x52});
        var word: [32]u8 = @splat(0);
        @memcpy(word[0..reason.len], reason);
        try self.push(std.mem.readInt(u256, &word, .big));
        try self.push(68);
        try self.op(&.{0x52});
        try self.push(100);
        try self.push(0);
        try self.op(&.{0xfd});
    }

    fn revertPanic(self: *Asm, code: u256) !void {
        try self.mstoreLeft(0, 0x4e487b71, 4);
        try self.push(code);
        try self.push(4);
        try self.op(&.{0x52});
        try self.push(36);
        try self.push(0);
        try self.op(&.{0xfd});
    }
};

// ---------------------------------------------------------------------------
// In-memory host: Evm.call() resets its built-in maps, so pre-state lives here.
// ---------------------------------------------------------------------------

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

    fn outOfMemory() noreturn {
        @panic("test host out of memory");
    }

    fn from(ptr: *anyopaque) *TestHost {
        return @ptrCast(@alignCast(ptr));
    }

    fn getBalance(ptr: *anyopaque, address: Address) u256 {
        return from(ptr).balances.get(address) orelse 0;
    }
    fn setBalance(ptr: *anyopaque, address: Address, balance: u256) void {
        from(ptr).balances.put(testing.allocator, address, balance) catch outOfMemory();
    }
    fn getCode(ptr: *anyopaque, address: Address) []const u8 {
        return from(ptr).code.get(address) orelse &.{};
    }
    fn setCode(ptr: *anyopaque, address: Address, code: []const u8) void {
        const copy = testing.allocator.dupe(u8, code) catch outOfMemory();
        const old = from(ptr).code.fetchPut(testing.allocator, address, copy) catch outOfMemory();
        if (old) |entry| testing.allocator.free(entry.value);
    }
    fn getStorage(ptr: *anyopaque, address: Address, slot: u256) u256 {
        return from(ptr).storage.get(.{ .address = address.bytes, .slot = slot }) orelse 0;
    }
    fn setStorage(ptr: *anyopaque, address: Address, slot: u256, value: u256) void {
        from(ptr).storage.put(testing.allocator, .{ .address = address.bytes, .slot = slot }, value) catch outOfMemory();
    }
    fn getNonce(ptr: *anyopaque, address: Address) u64 {
        return from(ptr).nonces.get(address) orelse 0;
    }
    fn setNonce(ptr: *anyopaque, address: Address, nonce: u64) void {
        from(ptr).nonces.put(testing.allocator, address, nonce) catch outOfMemory();
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

/// Host plus EVM. Must not move after `init`.
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

// ---------------------------------------------------------------------------
// Shared scenario
// ---------------------------------------------------------------------------

const ORIGIN: u256 = 0x1000;
const ROOT: u256 = 0x2000;
const CHILD_OK: u256 = 0x3000;
const CHILD_REVERT: u256 = 0x4000;
const LOGGER: u256 = 0x4100;
const LIB: u256 = 0x5000;
const VIEW: u256 = 0x6000;
const PANIC: u256 = 0x7000;
const IDENTITY: u256 = 0x04;

fn addr(n: u256) Address {
    return Address.fromU256(n);
}

/// ROOT logs, writes slot 1, then CALLs (with value), CALLs a reverting
/// child that logs and calls LOGGER, STATICCALLs, DELEGATECALLs (writing
/// slot 2), CALLs the identity precompile, CALLs a Panic(0x12) contract,
/// and CREATEs a 1-byte contract.
const Scenario = struct {
    root: Asm = .{},
    child_ok: Asm = .{},
    child_revert: Asm = .{},
    logger: Asm = .{},
    lib: Asm = .{},
    view: Asm = .{},
    panic: Asm = .{},

    const top_input = [_]u8{ 0x01, 0x02, 0x03, 0x04 };
    const init_code: u256 = 0x60005f5360015ff3; // PUSH1 0 PUSH0 MSTORE8 PUSH1 1 PUSH0 RETURN

    fn build() !Scenario {
        var s: Scenario = .{};
        errdefer s.deinit();
        const r = &s.root;
        try r.log(0xaa);
        try r.sstore(1, 0x11);
        try r.mstoreLeft(0, 0x11223344, 4);
        try r.call(CHILD_OK, 5, 0, 36, 0, 0);
        try r.mstoreLeft(0, 0xdeadbeef, 4);
        try r.call(CHILD_REVERT, 0, 0, 4, 0, 0);
        try r.mstoreLeft(0, 0x11223344, 4);
        try r.callNoValue(0xfa, VIEW, 0, 4, 0, 32);
        try r.callNoValue(0xf4, LIB, 0, 2, 0, 0);
        try r.mstoreLeft(0, 0xaabbccdd, 4);
        try r.call(IDENTITY, 0, 0, 4, 64, 4);
        try r.mstoreLeft(0, 0xcafebabe, 4);
        try r.call(PANIC, 0, 0, 68, 0, 0);
        try r.mstoreLeft(0, init_code, 8);
        try r.push(8);
        try r.push(0);
        try r.push(0);
        try r.op(&.{ 0xf0, 0x50, 0x00 });

        try s.child_ok.sload(0);
        try s.child_ok.sstore(0, 7);
        try s.child_ok.op(&.{0x00});

        try s.child_revert.log(null);
        try s.child_revert.mstoreLeft(0, 0x11223344, 4);
        try s.child_revert.call(LOGGER, 0, 0, 36, 0, 0);
        try s.child_revert.sstore(9, 1);
        try s.child_revert.revertError("nope");

        try s.logger.log(0xbb);
        try s.logger.op(&.{0x00});

        try s.lib.sstore(2, 0x22);
        try s.lib.op(&.{0x00});

        try s.view.returnWord(0x2a);
        try s.panic.revertPanic(0x12);
        return s;
    }

    fn deinit(self: *Scenario) void {
        inline for (.{ "root", "child_ok", "child_revert", "logger", "lib", "view", "panic" }) |name| @field(self, name).deinit();
    }

    /// Initializes `chain`, installs state, and runs the transaction.
    fn run(self: *const Scenario, chain: *Chain, sink: ?insp.Inspector) !CallResult {
        try chain.init(addr(ORIGIN));
        chain.setCode(addr(ROOT), self.root.bytes());
        chain.setCode(addr(CHILD_OK), self.child_ok.bytes());
        chain.setCode(addr(CHILD_REVERT), self.child_revert.bytes());
        chain.setCode(addr(LOGGER), self.logger.bytes());
        chain.setCode(addr(LIB), self.lib.bytes());
        chain.setCode(addr(VIEW), self.view.bytes());
        chain.setCode(addr(PANIC), self.panic.bytes());
        TestHost.setBalance(&chain.host, addr(ROOT), 100);
        TestHost.setStorage(&chain.host, addr(CHILD_OK), 0, 3);
        return chain.call(addr(ORIGIN), addr(ROOT), &top_input, 1_000_000, sink);
    }
};

fn writeOwned(tracer: anytype, comptime method: []const u8) ![]u8 {
    var aw: std.Io.Writer.Allocating = .init(testing.allocator);
    defer aw.deinit();
    try @field(@TypeOf(tracer.*), method)(tracer, &aw.writer);
    return aw.toOwnedSlice();
}

fn parseJson(text: []const u8) !std.json.Parsed(std.json.Value) {
    return std.json.parseFromSlice(std.json.Value, testing.allocator, text, .{});
}

fn hexKey(buf: []u8, n: u256, width: usize) []const u8 {
    var bytes: [32]u8 = undefined;
    std.mem.writeInt(u256, &bytes, n, .big);
    return std.fmt.bufPrint(buf, "0x{x}", .{@as([]const u8, bytes[32 - width ..])}) catch unreachable;
}

fn addrKey(buf: *[42]u8, n: u256) []const u8 {
    return hexKey(buf, n, 20);
}

fn slotKey(buf: *[66]u8, n: u256) []const u8 {
    return hexKey(buf, n, 32);
}

// ---------------------------------------------------------------------------
// CallTracer
// ---------------------------------------------------------------------------

test "CallTracer builds nested frames, decodes reverts and suppresses rolled-back logs" {
    var scenario = try Scenario.build();
    defer scenario.deinit();
    var tracer = CallTracer.init(testing.allocator, .{ .with_log = true });
    defer tracer.deinit();
    var instance: Chain = undefined;
    const result = try scenario.run(&instance, tracer.inspector());
    defer instance.deinit();
    try testing.expect(result.success);
    try testing.expect(tracer.err == null);

    const root = tracer.root().?;
    try testing.expectEqual(insp.CallType.call, root.call_type);
    try testing.expect(root.from.equals(addr(ORIGIN)) and root.to.equals(addr(ROOT)));
    try testing.expectEqualSlices(u8, &Scenario.top_input, root.input);
    try testing.expect(!root.reverted and root.gas_used > 0);
    try testing.expectEqual(@as(usize, 1), root.logs.items.len);
    try testing.expectEqual(@as(usize, 0), root.logs.items[0].position);

    const calls = root.calls.items;
    try testing.expectEqual(@as(usize, 7), calls.len);
    const expected_types = [_]insp.CallType{ .call, .call, .staticcall, .delegatecall, .call, .call, .create };
    for (calls, expected_types) |frame, kind| try testing.expectEqual(kind, frame.call_type);

    try testing.expect(calls[0].to.equals(addr(CHILD_OK)) and calls[0].value == 5 and !calls[0].reverted);
    try testing.expectEqual(@as(usize, 36), calls[0].input.len);

    const reverted = calls[1];
    try testing.expect(reverted.reverted);
    try testing.expectEqualStrings("execution reverted", reverted.error_msg.?);
    try testing.expectEqualStrings("nope", reverted.revert_reason.?);
    try testing.expectEqual(@as(usize, 1), reverted.logs.items.len);
    try testing.expectEqual(@as(usize, 1), reverted.calls.items.len);
    const logger = reverted.calls.items[0];
    try testing.expect(logger.to.equals(addr(LOGGER)) and !logger.reverted);
    try testing.expectEqual(@as(usize, 1), logger.logs.items.len);

    try testing.expect(calls[2].to.equals(addr(VIEW)));
    try testing.expectEqual(@as(usize, 32), calls[2].output.len);
    try testing.expectEqual(@as(u8, 0x2a), calls[2].output[31]);
    try testing.expect(calls[3].code_address.equals(addr(LIB)));
    try testing.expect(calls[4].is_precompile and calls[4].to.equals(addr(IDENTITY)));
    try testing.expectEqualSlices(u8, &.{ 0xaa, 0xbb, 0xcc, 0xdd }, calls[4].output);
    try testing.expect(calls[5].reverted);
    try testing.expectEqualStrings("panic 0x12: division or modulo by zero", calls[5].revert_reason.?);
    try testing.expect(calls[6].created_address != null);
    try testing.expectEqualSlices(u8, &.{0x00}, calls[6].output);

    // Geth JSON: valid, reverted-frame logs dropped, parent log kept.
    const geth = try writeOwned(&tracer, "writeGethJson");
    defer testing.allocator.free(geth);
    const parsed = try parseJson(geth);
    defer parsed.deinit();
    const top = parsed.value.object;
    try testing.expectEqualStrings("CALL", top.get("type").?.string);
    try testing.expectEqual(@as(usize, 1), top.get("logs").?.array.items.len);
    const json_calls = top.get("calls").?.array.items;
    try testing.expectEqual(@as(usize, 7), json_calls.len);
    const json_reverted = json_calls[1].object;
    try testing.expect(json_reverted.get("logs") == null);
    try testing.expectEqualStrings("nope", json_reverted.get("revertReason").?.string);
    try testing.expect(json_reverted.get("calls").?.array.items[0].object.get("logs") == null);
    try testing.expectEqualStrings("STATICCALL", json_calls[2].object.get("type").?.string);
    try testing.expect(json_calls[2].object.get("value") == null);
    try testing.expectEqualStrings("DELEGATECALL", json_calls[3].object.get("type").?.string);
    try testing.expectEqualStrings("panic 0x12: division or modulo by zero", json_calls[5].object.get("revertReason").?.string);
    try testing.expectEqualStrings("CREATE", json_calls[6].object.get("type").?.string);
    try testing.expectEqualStrings("0x00", json_calls[6].object.get("output").?.string);

    // Flat JSON: precompile omitted, Parity error names, trace addresses.
    const flat = try writeOwned(&tracer, "writeFlatJson");
    defer testing.allocator.free(flat);
    const parsed_flat = try parseJson(flat);
    defer parsed_flat.deinit();
    const entries = parsed_flat.value.array.items;
    try testing.expectEqual(@as(usize, 8), entries.len);
    try testing.expectEqual(@as(i64, 6), entries[0].object.get("subtraces").?.integer);
    try testing.expectEqual(@as(usize, 0), entries[0].object.get("traceAddress").?.array.items.len);
    const reverted_entry = entries[2].object;
    try testing.expectEqualStrings("Reverted", reverted_entry.get("error").?.string);
    try testing.expect(reverted_entry.get("result") == null);
    const logger_entry = entries[3].object;
    const logger_address = logger_entry.get("traceAddress").?.array.items;
    try testing.expectEqual(@as(usize, 2), logger_address.len);
    try testing.expectEqual(@as(i64, 1), logger_address[0].integer);
    try testing.expectEqual(@as(i64, 0), logger_address[1].integer);
    try testing.expectEqualStrings("staticcall", entries[4].object.get("action").?.object.get("callType").?.string);
    const create_entry = entries[7].object;
    try testing.expectEqualStrings("create", create_entry.get("type").?.string);
    try testing.expectEqualStrings("create", create_entry.get("action").?.object.get("creationMethod").?.string);
    try testing.expectEqualStrings("0x00", create_entry.get("result").?.object.get("code").?.string);
    try testing.expectEqual(@as(i64, 5), entries[7].object.get("traceAddress").?.array.items[0].integer);
}

test "CallTracer only_top_call omits children and their logs" {
    var scenario = try Scenario.build();
    defer scenario.deinit();
    var tracer = CallTracer.init(testing.allocator, .{ .only_top_call = true, .with_log = true });
    defer tracer.deinit();
    var instance: Chain = undefined;
    const result = try scenario.run(&instance, tracer.inspector());
    defer instance.deinit();
    try testing.expect(result.success);
    const root = tracer.root().?;
    try testing.expectEqual(@as(usize, 0), root.calls.items.len);
    try testing.expectEqual(@as(usize, 1), root.logs.items.len);
    try testing.expectEqual(result.gas_left, 1_000_000 - root.gas_used);

    const geth = try writeOwned(&tracer, "writeGethJson");
    defer testing.allocator.free(geth);
    const parsed = try parseJson(geth);
    defer parsed.deinit();
    try testing.expect(parsed.value.object.get("calls") == null);
    const flat = try writeOwned(&tracer, "writeFlatJson");
    defer testing.allocator.free(flat);
    const parsed_flat = try parseJson(flat);
    defer parsed_flat.deinit();
    try testing.expectEqual(@as(usize, 1), parsed_flat.value.array.items.len);
}

test "CallTracer records SELFDESTRUCT as a child frame" {
    const victim = addr(0x8000);
    const beneficiary = addr(0x8001);
    var tracer = CallTracer.init(testing.allocator, .{});
    defer tracer.deinit();
    var chain: Chain = undefined;
    try chain.init(victim);
    defer chain.deinit();
    TestHost.setBalance(&chain.host, victim, 9);
    chain.setCode(victim, &.{ 0x61, 0x80, 0x01, 0xff });
    const result = chain.call(victim, victim, &.{}, 100_000, tracer.inspector());
    try testing.expect(result.success);
    const child = tracer.root().?.calls.items[0];
    try testing.expectEqual(insp.CallType.selfdestruct, child.call_type);
    try testing.expect(child.to.equals(beneficiary) and child.value == 9);
    const flat = try writeOwned(&tracer, "writeFlatJson");
    defer testing.allocator.free(flat);
    const parsed = try parseJson(flat);
    defer parsed.deinit();
    try testing.expectEqualStrings("suicide", parsed.value.array.items[1].object.get("type").?.string);
}

// ---------------------------------------------------------------------------
// FourByteTracer
// ---------------------------------------------------------------------------

test "FourByteTracer counts selectors by argument size and skips short input and precompiles" {
    var scenario = try Scenario.build();
    defer scenario.deinit();
    var tracer = FourByteTracer.init(testing.allocator);
    defer tracer.deinit();
    var instance: Chain = undefined;
    const result = try scenario.run(&instance, tracer.inspector());
    defer instance.deinit();
    try testing.expect(result.success);

    try testing.expectEqual(@as(u64, 1), tracer.getCount(.{ 1, 2, 3, 4 }, 0));
    try testing.expectEqual(@as(u64, 2), tracer.getCount(.{ 0x11, 0x22, 0x33, 0x44 }, 32));
    try testing.expectEqual(@as(u64, 1), tracer.getCount(.{ 0x11, 0x22, 0x33, 0x44 }, 0));
    try testing.expectEqual(@as(u64, 1), tracer.getCount(.{ 0xde, 0xad, 0xbe, 0xef }, 0));
    try testing.expectEqual(@as(u64, 1), tracer.getCount(.{ 0xca, 0xfe, 0xba, 0xbe }, 64));
    try testing.expectEqual(@as(u64, 0), tracer.getCount(.{ 0xaa, 0xbb, 0xcc, 0xdd }, 0));
    try testing.expectEqual(@as(u32, 5), tracer.counts.count());

    const text = try writeOwned(&tracer, "writeJson");
    defer testing.allocator.free(text);
    try testing.expectEqualStrings(
        \\{"0x01020304-0":1,"0x11223344-0":1,"0x11223344-32":2,"0xcafebabe-64":1,"0xdeadbeef-0":1}
    , text);
    const parsed = try parseJson(text);
    defer parsed.deinit();
    try testing.expectEqual(@as(usize, 5), parsed.value.object.count());
}

// ---------------------------------------------------------------------------
// PrestateTracer
// ---------------------------------------------------------------------------

test "PrestateTracer reports first-seen pre-state including reverted reads" {
    var scenario = try Scenario.build();
    defer scenario.deinit();
    var tracer = PrestateTracer.init(testing.allocator, .{});
    defer tracer.deinit();
    var instance: Chain = undefined;
    const result = try scenario.run(&instance, tracer.inspector());
    defer instance.deinit();
    try testing.expect(result.success);

    const text = try writeOwned(&tracer, "writeJson");
    defer testing.allocator.free(text);
    const parsed = try parseJson(text);
    defer parsed.deinit();
    const state = parsed.value.object;
    var a: [42]u8 = undefined;
    var k: [66]u8 = undefined;

    const root = state.get(addrKey(&a, ROOT)).?.object;
    try testing.expectEqualStrings("0x64", root.get("balance").?.string);
    const code_hex = try std.fmt.allocPrint(testing.allocator, "0x{x}", .{scenario.root.bytes()});
    defer testing.allocator.free(code_hex);
    try testing.expectEqualStrings(code_hex, root.get("code").?.string);
    const root_storage = root.get("storage").?.object;
    var v: [66]u8 = undefined;
    try testing.expectEqualStrings(slotKey(&v, 0), root_storage.get(slotKey(&k, 1)).?.string);

    const child = state.get(addrKey(&a, CHILD_OK)).?.object;
    try testing.expectEqualStrings(slotKey(&v, 3), child.get("storage").?.object.get(slotKey(&k, 0)).?.string);
    try testing.expect(child.get("balance") != null);

    // Reverted frames still reveal pre-state.
    const reverted = state.get(addrKey(&a, CHILD_REVERT)).?.object;
    try testing.expectEqualStrings(slotKey(&v, 0), reverted.get("storage").?.object.get(slotKey(&k, 9)).?.string);
    try testing.expect(state.get(addrKey(&a, IDENTITY)) == null);
    try testing.expect(state.get(addrKey(&a, ORIGIN)) != null);
}

test "PrestateTracer diff mode excludes reverted writes and reports created accounts in post only" {
    var scenario = try Scenario.build();
    defer scenario.deinit();
    var tracer = PrestateTracer.init(testing.allocator, .{ .diff_mode = true });
    defer tracer.deinit();
    var call_tracer = CallTracer.init(testing.allocator, .{});
    defer call_tracer.deinit();
    const children = [_]insp.Inspector{ tracer.inspector(), call_tracer.inspector() };
    var mux = insp.MuxInspector.init(&children);
    var instance: Chain = undefined;
    const result = try scenario.run(&instance, mux.inspector());
    defer instance.deinit();
    try testing.expect(result.success);
    const created = call_tracer.root().?.calls.items[6].created_address.?;

    const text = try writeOwned(&tracer, "writeJson");
    defer testing.allocator.free(text);
    const parsed = try parseJson(text);
    defer parsed.deinit();
    const pre = parsed.value.object.get("pre").?.object;
    const post = parsed.value.object.get("post").?.object;
    var a: [42]u8 = undefined;
    var k: [66]u8 = undefined;
    var v: [66]u8 = undefined;

    const root_pre = pre.get(addrKey(&a, ROOT)).?.object;
    const root_post = post.get(addrKey(&a, ROOT)).?.object;
    try testing.expectEqualStrings("0x64", root_pre.get("balance").?.string);
    try testing.expectEqualStrings("0x5f", root_post.get("balance").?.string);
    try testing.expect(root_pre.get("nonce") == null); // Geth omits a zero nonce.
    try testing.expectEqual(@as(i64, 1), root_post.get("nonce").?.integer);
    try testing.expect(root_pre.get("code") == null and root_post.get("code") == null);
    const root_post_storage = root_post.get("storage").?.object;
    try testing.expectEqualStrings(slotKey(&v, 0x11), root_post_storage.get(slotKey(&k, 1)).?.string);
    try testing.expectEqualStrings(slotKey(&v, 0x22), root_post_storage.get(slotKey(&k, 2)).?.string);
    try testing.expectEqual(@as(usize, 2), root_post_storage.count());

    const child_pre = pre.get(addrKey(&a, CHILD_OK)).?.object;
    const child_post = post.get(addrKey(&a, CHILD_OK)).?.object;
    try testing.expectEqualStrings(slotKey(&v, 3), child_pre.get("storage").?.object.get(slotKey(&k, 0)).?.string);
    try testing.expectEqualStrings(slotKey(&v, 7), child_post.get("storage").?.object.get(slotKey(&k, 0)).?.string);
    try testing.expectEqualStrings("0x5", child_post.get("balance").?.string);

    // CHILD_REVERT's SSTORE was rolled back, so it has no diff at all.
    try testing.expect(pre.get(addrKey(&a, CHILD_REVERT)) == null);
    try testing.expect(post.get(addrKey(&a, CHILD_REVERT)) == null);
    try testing.expect(pre.get(addrKey(&a, VIEW)) == null and post.get(addrKey(&a, VIEW)) == null);

    var created_key: [42]u8 = undefined;
    const created_name = std.fmt.bufPrint(&created_key, "0x{x}", .{@as([]const u8, &created.bytes)}) catch unreachable;
    try testing.expect(pre.get(created_name) == null);
    const created_post = post.get(created_name).?.object;
    try testing.expectEqualStrings("0x00", created_post.get("code").?.string);
    try testing.expectEqual(@as(i64, 1), created_post.get("nonce").?.integer);
}

test "PrestateTracer rolls back nested writes when an ancestor reverts" {
    const outer = addr(0x9000);
    const inner = addr(0x9001);
    var outer_code: Asm = .{};
    defer outer_code.deinit();
    try outer_code.call(0x9001, 0, 0, 0, 0, 0);
    try outer_code.push(0);
    try outer_code.push(0);
    try outer_code.op(&.{0xfd});
    var inner_code: Asm = .{};
    defer inner_code.deinit();
    try inner_code.sstore(4, 0x44);
    try inner_code.op(&.{0x00});

    var tracer = PrestateTracer.init(testing.allocator, .{ .diff_mode = true });
    defer tracer.deinit();
    var chain: Chain = undefined;
    try chain.init(outer);
    defer chain.deinit();
    chain.setCode(outer, outer_code.bytes());
    chain.setCode(inner, inner_code.bytes());
    const result = chain.call(outer, outer, &.{}, 200_000, tracer.inspector());
    try testing.expect(!result.success);
    try testing.expectEqual(@as(?u256, 0), tracer.account(inner).?.pre.storage.get(4));
    try testing.expect(tracer.account(inner).?.post.storage.get(4) == null);
    // The host must agree with the tracer: the root revert undoes the child's write.
    try testing.expectEqual(@as(u256, 0), TestHost.getStorage(&chain.host, inner, 4));
    const text = try writeOwned(&tracer, "writeJson");
    defer testing.allocator.free(text);
    try testing.expectEqualStrings("{\"post\":{},\"pre\":{}}", text);
}

// ---------------------------------------------------------------------------
// AccessListInspector
// ---------------------------------------------------------------------------

test "AccessListInspector keeps reverted accesses, excludes tx endpoints and precompiles, sorts output" {
    var scenario = try Scenario.build();
    defer scenario.deinit();
    var tracer = AccessListInspector.init(testing.allocator, .{});
    defer tracer.deinit();
    var instance: Chain = undefined;
    const result = try scenario.run(&instance, tracer.inspector());
    defer instance.deinit();
    try testing.expect(result.success);

    const entries = try tracer.toOwnedEntries(testing.allocator);
    defer tracers.freeAccessListEntries(testing.allocator, entries);
    for (entries[1..], entries[0 .. entries.len - 1]) |next, prev| {
        try testing.expect(std.mem.order(u8, &prev.address.bytes, &next.address.bytes) == .lt);
    }
    var expected_present = [_]bool{false} ** 7;
    const wanted = [_]u256{ ROOT, CHILD_OK, CHILD_REVERT, LOGGER, LIB, VIEW, PANIC };
    for (entries) |entry| {
        try testing.expect(!entry.address.equals(addr(ORIGIN)));
        try testing.expect(!entry.address.equals(addr(IDENTITY)));
        for (wanted, 0..) |w, i| {
            if (entry.address.equals(addr(w))) expected_present[i] = true;
        }
        if (entry.address.equals(addr(ROOT))) {
            // The excluded target is kept because its storage was touched.
            try testing.expectEqual(@as(usize, 2), entry.storage_keys.len);
            try testing.expectEqual(@as(u8, 1), entry.storage_keys[0][31]);
            try testing.expectEqual(@as(u8, 2), entry.storage_keys[1][31]);
        }
        if (entry.address.equals(addr(CHILD_REVERT))) {
            try testing.expectEqual(@as(usize, 1), entry.storage_keys.len);
            try testing.expectEqual(@as(u8, 9), entry.storage_keys[0][31]);
        }
        if (entry.address.equals(addr(CHILD_OK))) try testing.expectEqual(@as(usize, 1), entry.storage_keys.len);
        if (entry.address.equals(addr(VIEW))) try testing.expectEqual(@as(usize, 0), entry.storage_keys.len);
    }
    try testing.expectEqualDeep([_]bool{true} ** 7, expected_present);
    // The CREATE target is accessed but, as in Geth, never listed.
    try testing.expectEqual(@as(usize, 7), entries.len);

    const text = try writeOwned(&tracer, "writeJson");
    defer testing.allocator.free(text);
    const parsed = try parseJson(text);
    defer parsed.deinit();
    const list = parsed.value.array.items;
    try testing.expectEqual(entries.len, list.len);
    var a: [42]u8 = undefined;
    var k: [66]u8 = undefined;
    try testing.expectEqualStrings(addrKey(&a, ROOT), list[0].object.get("address").?.string);
    try testing.expectEqualStrings(slotKey(&k, 1), list[0].object.get("storageKeys").?.array.items[0].string);

    // Disabling exclusions brings back the precompile.
    var open = AccessListInspector.init(testing.allocator, .{ .exclude_precompiles = false, .exclude_origin = false });
    defer open.deinit();
    var second: Chain = undefined;
    _ = try scenario.run(&second, open.inspector());
    defer second.deinit();
    const all = try open.toOwnedEntries(testing.allocator);
    defer tracers.freeAccessListEntries(testing.allocator, all);
    try testing.expect(all[0].address.equals(addr(IDENTITY)));
    try testing.expectEqual(@as(usize, 8), all.len);
}

// ---------------------------------------------------------------------------
// GasProfiler
// ---------------------------------------------------------------------------

test "GasProfiler counts opcodes, memory expansion and faults" {
    const target = addr(0x123);
    const code = [_]u8{ 0x60, 42, 0x5f, 0x52, 0x00 }; // PUSH1 42 PUSH0 MSTORE STOP
    {
        var profiler = GasProfiler.init(testing.allocator);
        defer profiler.deinit();
        var chain: Chain = undefined;
        try chain.init(target);
        defer chain.deinit();
        chain.setCode(target, &code);
        const result = chain.call(target, target, &.{}, 100, profiler.inspector());
        try testing.expect(result.success);
        try testing.expectEqualDeep(tracers.OpcodeStats{ .count = 1, .total_gas = 6, .memory_expansion_gas = 3 }, profiler.opcodes[0x52]);
        try testing.expectEqual(@as(u64, 1), profiler.opcodes[0x60].count);
        try testing.expectEqual(@as(u64, 1), profiler.opcodes[0x00].count);
        try testing.expectEqual(@as(usize, 1), profiler.frames.items.len);
        const frame = profiler.frames.items[0];
        try testing.expectEqual(@as(u64, 4), frame.opcode_count);
        try testing.expectEqual(@as(u64, 100) - result.gas_left, frame.inclusive_gas);
        try testing.expectEqual(frame.inclusive_gas, frame.exclusive_gas);
    }
    {
        var profiler = GasProfiler.init(testing.allocator);
        defer profiler.deinit();
        var chain: Chain = undefined;
        try chain.init(target);
        defer chain.deinit();
        chain.setCode(target, &code);
        const result = chain.call(target, target, &.{}, 9, profiler.inspector());
        try testing.expect(!result.success);
        try testing.expectEqual(@as(u64, 1), profiler.opcodes[0x52].fault_count);
        try testing.expectEqual(@as(u64, 3), profiler.opcodes[0x52].memory_expansion_gas);
        try testing.expect(profiler.frames.items[0].reverted);
    }
}

test "GasProfiler separates inclusive and exclusive frame gas" {
    var scenario = try Scenario.build();
    defer scenario.deinit();
    var profiler = GasProfiler.init(testing.allocator);
    defer profiler.deinit();
    var instance: Chain = undefined;
    const result = try scenario.run(&instance, profiler.inspector());
    defer instance.deinit();
    try testing.expect(result.success);

    const frames = profiler.frames.items;
    try testing.expectEqual(@as(usize, 9), frames.len);
    for (frames) |frame| {
        var children: u64 = 0;
        for (frames) |other| {
            if (other.parent_id != null and other.parent_id.? == frame.frame_id) children += other.inclusive_gas;
        }
        try testing.expectEqual(frame.inclusive_gas - children, frame.exclusive_gas);
    }
    try testing.expectEqual(@as(u64, 1_000_000) - result.gas_left, frames[0].inclusive_gas);
    try testing.expect(frames[0].exclusive_gas < frames[0].inclusive_gas);
    try testing.expectEqual(@as(u64, 4), profiler.opcodes[0x55].count);
    try testing.expectEqual(@as(u64, 5), profiler.opcodes[0xf1].count);
    try testing.expectEqual(@as(u64, 2), profiler.opcodes[0xfd].count);
    try testing.expectEqual(@as(u64, 2), profiler.opcodes[0xfd].fault_count);
    var opcode_total: u64 = 0;
    for (frames) |frame| opcode_total += frame.opcode_count;
    var histogram_total: u64 = 0;
    for (profiler.opcodes) |stats| histogram_total += stats.count;
    try testing.expectEqual(histogram_total, opcode_total);

    const top = try profiler.topOpcodes(testing.allocator, 3);
    defer testing.allocator.free(top);
    try testing.expectEqual(@as(usize, 3), top.len);
    try testing.expect(top[0].stats.total_gas >= top[1].stats.total_gas and top[1].stats.total_gas >= top[2].stats.total_gas);

    const text = try writeOwned(&profiler, "writeJson");
    defer testing.allocator.free(text);
    const parsed = try parseJson(text);
    defer parsed.deinit();
    try testing.expectEqual(@as(usize, 9), parsed.value.object.get("frames").?.array.items.len);
    try testing.expect(parsed.value.object.get("frames").?.array.items[0].object.get("parentId").? == .null);
}

// ---------------------------------------------------------------------------
// CoverageInspector
// ---------------------------------------------------------------------------

test "CoverageInspector records JUMPI branches and never links edges across frames" {
    const parent = addr(0xa000);
    const child = addr(0xa001);
    const parent_code = [_]u8{
        0x5f, 0x60, 10, 0x57, // 0: JUMPI not taken at pc 3
        0x60, 1, 0x60, 10, 0x57, // 4: JUMPI taken at pc 8
        0xfe, // 9: unreachable
        0x5b, // 10: JUMPDEST
        0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x61, 0xa0, 0x01, 0x5a, 0xf1, // 11: CALL at pc 20
        0x50, 0x00, // 21: POP STOP
    };
    const child_code = [_]u8{ 0x5f, 0x50, 0x00 };
    var coverage = CoverageInspector.init(testing.allocator);
    defer coverage.deinit();
    var chain: Chain = undefined;
    try chain.init(parent);
    defer chain.deinit();
    chain.setCode(parent, &parent_code);
    chain.setCode(child, &child_code);
    const result = chain.call(parent, parent, &.{}, 100_000, coverage.inspector());
    try testing.expect(result.success);

    const ph = CoverageInspector.codeHash(&parent_code);
    const ch = CoverageInspector.codeHash(&child_code);
    try testing.expectEqual(tracers.JumpiBranch{ .taken = 0, .not_taken = 1 }, coverage.jumpiStats(ph, 3).?);
    try testing.expectEqual(tracers.JumpiBranch{ .taken = 1, .not_taken = 0 }, coverage.jumpiStats(ph, 8).?);
    try testing.expect(coverage.jumpiStats(ph, 4) == null);
    try testing.expectEqual(@as(u64, 0), coverage.pcHits(ph, 9));
    try testing.expectEqual(@as(u64, 1), coverage.pcHits(ph, 10));
    try testing.expectEqual(@as(u64, 1), coverage.edgeHits(ph, 3, 4));
    try testing.expectEqual(@as(u64, 1), coverage.edgeHits(ph, 8, 10));
    try testing.expectEqual(@as(u64, 1), coverage.edgeHits(ph, 20, 21));
    try testing.expectEqual(@as(u64, 1), coverage.edgeHits(ch, 0, 1));
    try testing.expectEqual(@as(u64, 1), coverage.edgeHits(ch, 1, 2));
    try testing.expectEqual(@as(u64, 1), coverage.pcHits(ch, 0));

    var it = coverage.edges.keyIterator();
    var parent_edges: usize = 0;
    var child_edges: usize = 0;
    while (it.next()) |edge| {
        if (std.mem.eql(u8, &edge.code_hash, &ph)) {
            parent_edges += 1;
            if (edge.from_pc == 20) try testing.expectEqual(@as(u64, 21), edge.to_pc);
        } else {
            try testing.expect(std.mem.eql(u8, &edge.code_hash, &ch));
            try testing.expect(edge.to_pc != 0);
            child_edges += 1;
        }
    }
    try testing.expectEqual(@as(usize, 2), child_edges);
    // 17 opcodes executed in the parent give 16 consecutive edges.
    try testing.expectEqual(@as(usize, 16), parent_edges);

    const text = try writeOwned(&coverage, "writeJson");
    defer testing.allocator.free(text);
    const parsed = try parseJson(text);
    defer parsed.deinit();
    var key: [66]u8 = undefined;
    const parent_json = parsed.value.object.get(std.fmt.bufPrint(&key, "0x{x}", .{@as([]const u8, &ph)}) catch unreachable).?.object;
    try testing.expectEqual(@as(i64, 1), parent_json.get("jumpis").?.object.get("8").?.object.get("taken").?.integer);
    try testing.expectEqual(@as(i64, 1), parent_json.get("jumpis").?.object.get("3").?.object.get("notTaken").?.integer);
    try testing.expectEqual(@as(usize, 2), parsed.value.object.count());
}

// ---------------------------------------------------------------------------
// MuxInspector equivalence
// ---------------------------------------------------------------------------

const Outputs = struct {
    call_geth: []u8,
    call_flat: []u8,
    four_byte: []u8,
    prestate: []u8,
    access_list: []u8,
    gas: []u8,
    coverage: []u8,

    fn deinit(self: Outputs) void {
        inline for (@typeInfo(Outputs).@"struct".fields) |field| testing.allocator.free(@field(self, field.name));
    }
};

const TracerSet = struct {
    call: CallTracer,
    four_byte: FourByteTracer,
    prestate: PrestateTracer,
    access_list: AccessListInspector,
    gas: GasProfiler,
    coverage: CoverageInspector,

    fn init() TracerSet {
        return .{
            .call = CallTracer.init(testing.allocator, .{ .with_log = true }),
            .four_byte = FourByteTracer.init(testing.allocator),
            .prestate = PrestateTracer.init(testing.allocator, .{ .diff_mode = true }),
            .access_list = AccessListInspector.init(testing.allocator, .{}),
            .gas = GasProfiler.init(testing.allocator),
            .coverage = CoverageInspector.init(testing.allocator),
        };
    }

    fn deinit(self: *TracerSet) void {
        self.call.deinit();
        self.four_byte.deinit();
        self.prestate.deinit();
        self.access_list.deinit();
        self.gas.deinit();
        self.coverage.deinit();
    }

    fn inspectors(self: *TracerSet) [6]insp.Inspector {
        return .{
            self.call.inspector(),
            self.four_byte.inspector(),
            self.prestate.inspector(),
            self.access_list.inspector(),
            self.gas.inspector(),
            self.coverage.inspector(),
        };
    }

    fn outputs(self: *TracerSet) !Outputs {
        var out: Outputs = undefined;
        out.call_geth = try writeOwned(&self.call, "writeGethJson");
        errdefer testing.allocator.free(out.call_geth);
        out.call_flat = try writeOwned(&self.call, "writeFlatJson");
        errdefer testing.allocator.free(out.call_flat);
        out.four_byte = try writeOwned(&self.four_byte, "writeJson");
        errdefer testing.allocator.free(out.four_byte);
        out.prestate = try writeOwned(&self.prestate, "writeJson");
        errdefer testing.allocator.free(out.prestate);
        out.access_list = try writeOwned(&self.access_list, "writeJson");
        errdefer testing.allocator.free(out.access_list);
        out.gas = try writeOwned(&self.gas, "writeJson");
        errdefer testing.allocator.free(out.gas);
        out.coverage = try writeOwned(&self.coverage, "writeJson");
        return out;
    }
};

fn expectSameResult(expected: CallResult, actual: CallResult) !void {
    try testing.expectEqual(expected.success, actual.success);
    try testing.expectEqual(expected.gas_left, actual.gas_left);
    try testing.expectEqual(expected.refund_counter, actual.refund_counter);
    try testing.expectEqualSlices(u8, expected.output, actual.output);
    try testing.expectEqual(expected.logs.len, actual.logs.len);
    for (expected.logs, actual.logs) |left, right| {
        try testing.expect(left.address.equals(right.address));
        try testing.expectEqualSlices(u256, left.topics, right.topics);
        try testing.expectEqualSlices(u8, left.data, right.data);
    }
}

fn expectSameState(expected: *const TestHost, actual: *const TestHost) !void {
    try testing.expectEqual(expected.storage.count(), actual.storage.count());
    var storage = expected.storage.iterator();
    while (storage.next()) |entry| try testing.expectEqual(entry.value_ptr.*, actual.storage.get(entry.key_ptr.*).?);
    try testing.expectEqual(expected.balances.count(), actual.balances.count());
    var balances = expected.balances.iterator();
    while (balances.next()) |entry| try testing.expectEqual(entry.value_ptr.*, actual.balances.get(entry.key_ptr.*).?);
    try testing.expectEqual(expected.nonces.count(), actual.nonces.count());
    var nonces = expected.nonces.iterator();
    while (nonces.next()) |entry| try testing.expectEqual(entry.value_ptr.*, actual.nonces.get(entry.key_ptr.*).?);
    try testing.expectEqual(expected.code.count(), actual.code.count());
    var code = expected.code.iterator();
    while (code.next()) |entry| try testing.expectEqualSlices(u8, entry.value_ptr.*, actual.code.get(entry.key_ptr.*).?);
}

test "MuxInspector runs all six tracers in one pass with identical results and outputs" {
    var scenario = try Scenario.build();
    defer scenario.deinit();

    // Untraced baseline.
    var plain: Chain = undefined;
    const baseline = try scenario.run(&plain, null);
    defer plain.deinit();
    try testing.expect(baseline.success);

    // One execution, six tracers.
    var muxed = TracerSet.init();
    defer muxed.deinit();
    const children = muxed.inspectors();
    var mux = insp.MuxInspector.init(&children);
    const sink = mux.inspector();
    try testing.expect(sink.opcode_mask.contains(0x00) and !sink.capture_memory);
    var traced: Chain = undefined;
    const traced_result = try scenario.run(&traced, sink);
    defer traced.deinit();
    try expectSameResult(baseline, traced_result);
    try expectSameState(&plain.host, &traced.host);
    const mux_out = try muxed.outputs();
    defer mux_out.deinit();

    // Each tracer alone must produce byte-identical JSON.
    var solo = TracerSet.init();
    defer solo.deinit();
    for (solo.inspectors()) |single| {
        var instance: Chain = undefined;
        const result = try scenario.run(&instance, single);
        defer instance.deinit();
        try expectSameResult(baseline, result);
    }
    const solo_out = try solo.outputs();
    defer solo_out.deinit();
    inline for (@typeInfo(Outputs).@"struct".fields) |field| {
        const text = @field(mux_out, field.name);
        try testing.expectEqualStrings(@field(solo_out, field.name), text);
        const parsed = try parseJson(text);
        parsed.deinit();
    }
}

// ---------------------------------------------------------------------------
// Regression tests: Phase 5 review findings
// ---------------------------------------------------------------------------

/// PUSH0 PUSH0 REVERT
const REVERTING_INIT: u256 = 0x5f5ffd;
const REVERTING_INIT_LEN: u8 = 3;
/// STOP: deploys empty code.
const EMPTY_INIT: u256 = 0x00;
const EMPTY_INIT_LEN: u8 = 1;

fn initBytes(comptime init: u256, comptime len: u8) [len]u8 {
    var word: [32]u8 = undefined;
    std.mem.writeInt(u256, &word, init, .big);
    return word[32 - len ..][0..len].*;
}

fn create2Address(sender: Address, salt: u256, init_code: []const u8) Address {
    const Keccak256 = std.crypto.hash.sha3.Keccak256;
    var buf: [85]u8 = undefined;
    buf[0] = 0xff;
    buf[1..21].* = sender.bytes;
    std.mem.writeInt(u256, buf[21..53], salt, .big);
    Keccak256.hash(init_code, buf[53..85], .{});
    var out: [32]u8 = undefined;
    Keccak256.hash(&buf, &out, .{});
    return .{ .bytes = out[12..32].* };
}

fn emitCreate(code: *Asm, init: u256, len: u8, value: u256) !void {
    try code.mstoreLeft(0, init, len);
    try code.push(len);
    try code.push(0);
    try code.push(value);
    try code.op(&.{ 0xf0, 0x50 });
}

fn emitCreate2(code: *Asm, init: u256, len: u8, value: u256, salt: u256) !void {
    try code.mstoreLeft(0, init, len);
    try code.push(salt);
    try code.push(len);
    try code.push(0);
    try code.push(value);
    try code.op(&.{ 0xf5, 0x50 });
}

fn emitBalance(code: *Asm, target: Address) !void {
    try code.push(target.toU256());
    try code.op(&.{ 0x31, 0x50 });
}

fn hexAddress(buf: *[42]u8, address: Address) []const u8 {
    return std.fmt.bufPrint(buf, "0x{x}", .{@as([]const u8, &address.bytes)}) catch unreachable;
}

test "CallTracer streams call trees deeper than std.json.Stringify's nesting limit" {
    const depth = 150;
    var tracer = CallTracer.init(testing.allocator, .{});
    defer tracer.deinit();
    var parent: ?*tracers.CallFrame = null;
    for (0..depth) |i| {
        const frame = try testing.allocator.create(tracers.CallFrame);
        frame.* = .{
            .frame_id = i,
            .call_type = .call,
            .from = addr(0x10),
            .to = addr(0x20),
            .code_address = addr(0x20),
            .is_delegated = false,
            .is_precompile = false,
            .value = 0,
            .gas = 1000,
        };
        if (parent) |p| {
            p.calls.append(testing.allocator, frame) catch |err| {
                testing.allocator.destroy(frame);
                return err;
            };
        } else {
            tracer.root_frame = frame;
        }
        parent = frame;
    }

    const geth = try writeOwned(&tracer, "writeGethJson");
    defer testing.allocator.free(geth);
    const parsed = try parseJson(geth);
    defer parsed.deinit();
    var node = parsed.value;
    var seen: usize = 1;
    while (node.object.get("calls")) |calls| : (seen += 1) {
        try testing.expectEqual(@as(usize, 1), calls.array.items.len);
        node = calls.array.items[0];
    }
    try testing.expectEqual(@as(usize, depth), seen);
    try testing.expectEqualStrings("CALL", node.object.get("type").?.string);

    const flat = try writeOwned(&tracer, "writeFlatJson");
    defer testing.allocator.free(flat);
    const parsed_flat = try parseJson(flat);
    defer parsed_flat.deinit();
    const entries = parsed_flat.value.array.items;
    try testing.expectEqual(@as(usize, depth), entries.len);
    try testing.expectEqual(@as(usize, depth - 1), entries[depth - 1].object.get("traceAddress").?.array.items.len);
}

test "CallTracer serializes a real self-recursive call chain" {
    // CALL(GAS, ADDRESS, 0, 0, 0, 0, 0) recurses until the 63/64 rule stops it.
    const target = addr(0xd000);
    const code = [_]u8{ 0x5f, 0x5f, 0x5f, 0x5f, 0x5f, 0x30, 0x5a, 0xf1, 0x00 };
    var tracer = CallTracer.init(testing.allocator, .{});
    defer tracer.deinit();
    var chain: Chain = undefined;
    try chain.init(target);
    defer chain.deinit();
    chain.setCode(target, &code);
    const result = chain.call(target, target, &.{}, 10_000_000, tracer.inspector());
    try testing.expect(result.success);
    var frames: usize = 1;
    var node = tracer.root().?;
    while (node.calls.items.len > 0) : (frames += 1) node = node.calls.items[0];
    try testing.expect(frames > 129);
    const geth = try writeOwned(&tracer, "writeGethJson");
    defer testing.allocator.free(geth);
    const parsed = try parseJson(geth);
    defer parsed.deinit();
}

test "writeJsonString escapes quotes, backslashes and control characters and repairs bad UTF-8" {
    var aw: std.Io.Writer.Allocating = .init(testing.allocator);
    defer aw.deinit();
    try tracers.writeJsonString(&aw.writer, "a\"b\\c\n\t\x00\x1f\xc3\xa9\xff");
    try testing.expectEqualStrings("\"a\\\"b\\\\c\\n\\t\\u0000\\u001f\xc3\xa9\\ufffd\"", aw.written());
    const parsed = try std.json.parseFromSlice([]const u8, testing.allocator, aw.written(), .{});
    defer parsed.deinit();
    try testing.expectEqualStrings("a\"b\\c\n\t\x00\x1f\xc3\xa9\xef\xbf\xbd", parsed.value);
}

fn runRevertReason(comptime reason: []const u8, tracer: *CallTracer) ![]u8 {
    const root = addr(0xb000);
    const child = addr(0xb001);
    var root_code: Asm = .{};
    defer root_code.deinit();
    try root_code.call(0xb001, 0, 0, 0, 0, 0);
    try root_code.op(&.{0x00});
    var child_code: Asm = .{};
    defer child_code.deinit();
    try child_code.revertError(reason);
    var chain: Chain = undefined;
    try chain.init(root);
    defer chain.deinit();
    chain.setCode(root, root_code.bytes());
    chain.setCode(child, child_code.bytes());
    const result = chain.call(root, root, &.{}, 200_000, tracer.inspector());
    try testing.expect(result.success);
    return writeOwned(tracer, "writeGethJson");
}

test "CallTracer drops Error(string) reasons that are not UTF-8 and keeps JSON valid" {
    var tracer = CallTracer.init(testing.allocator, .{});
    defer tracer.deinit();
    const text = try runRevertReason("bad\xff\xfeutf8", &tracer);
    defer testing.allocator.free(text);
    const child = tracer.root().?.calls.items[0];
    try testing.expect(child.reverted);
    try testing.expect(child.revert_reason == null);
    const parsed = try parseJson(text);
    defer parsed.deinit();
    const json_child = parsed.value.object.get("calls").?.array.items[0].object;
    try testing.expect(json_child.get("revertReason") == null);
    try testing.expectEqualStrings("execution reverted", json_child.get("error").?.string);
    try testing.expect(json_child.get("output").? == .string);
}

test "CallTracer escapes quotes and control characters in revert reasons" {
    var tracer = CallTracer.init(testing.allocator, .{});
    defer tracer.deinit();
    const reason = "say \"hi\"\\\n\x01";
    const text = try runRevertReason(reason, &tracer);
    defer testing.allocator.free(text);
    try testing.expect(std.mem.indexOf(u8, text, "\"revertReason\":\"say \\\"hi\\\"\\\\\\n\\u0001\"") != null);
    const parsed = try parseJson(text);
    defer parsed.deinit();
    const json_child = parsed.value.object.get("calls").?.array.items[0].object;
    try testing.expectEqualStrings(reason, json_child.get("revertReason").?.string);
}

/// PARENT (nonce 1) CREATEs with reverting initcode, then STOPs or REVERTs.
fn runFailedCreate(parent_reverts: bool, prestate: *PrestateTracer, call_tracer: *CallTracer, chain: *Chain) !CallResult {
    const parent = addr(0xc000);
    var code: Asm = .{};
    defer code.deinit();
    try emitCreate(&code, REVERTING_INIT, REVERTING_INIT_LEN, 0);
    if (parent_reverts) {
        try code.push(0);
        try code.push(0);
        try code.op(&.{0xfd});
    } else {
        try code.op(&.{0x00});
    }
    try chain.init(parent);
    chain.setCode(parent, code.bytes());
    TestHost.setNonce(&chain.host, parent, 1);
    const children = [_]insp.Inspector{ prestate.inspector(), call_tracer.inspector() };
    var mux = insp.MuxInspector.init(&children);
    return chain.call(parent, parent, &.{}, 300_000, mux.inspector());
}

test "PrestateTracer keeps the creator nonce bump of a failed CREATE when the parent succeeds" {
    const parent = addr(0xc000);
    var prestate = PrestateTracer.init(testing.allocator, .{ .diff_mode = true });
    defer prestate.deinit();
    var call_tracer = CallTracer.init(testing.allocator, .{});
    defer call_tracer.deinit();
    var chain: Chain = undefined;
    const result = try runFailedCreate(false, &prestate, &call_tracer, &chain);
    defer chain.deinit();
    try testing.expect(result.success);

    const create_frame = call_tracer.root().?.calls.items[0];
    try testing.expect(create_frame.reverted and create_frame.created_address == null);
    try testing.expectEqual(@as(u64, 2), TestHost.getNonce(&chain.host, parent));
    try testing.expectEqual(@as(?u64, 2), prestate.account(parent).?.post.nonce);

    const text = try writeOwned(&prestate, "writeJson");
    defer testing.allocator.free(text);
    const parsed = try parseJson(text);
    defer parsed.deinit();
    var a: [42]u8 = undefined;
    const key = hexAddress(&a, parent);
    try testing.expectEqual(@as(i64, 1), parsed.value.object.get("pre").?.object.get(key).?.object.get("nonce").?.integer);
    try testing.expectEqual(@as(i64, 2), parsed.value.object.get("post").?.object.get(key).?.object.get("nonce").?.integer);

    // Geth omits `to` on a failed CREATE.
    const geth = try writeOwned(&call_tracer, "writeGethJson");
    defer testing.allocator.free(geth);
    const parsed_geth = try parseJson(geth);
    defer parsed_geth.deinit();
    const json_create = parsed_geth.value.object.get("calls").?.array.items[0].object;
    try testing.expectEqualStrings("CREATE", json_create.get("type").?.string);
    try testing.expect(json_create.get("to") == null);
    try testing.expectEqualStrings("execution reverted", json_create.get("error").?.string);
    try testing.expect(parsed_geth.value.object.get("to") != null);
}

test "PrestateTracer rolls back the creator nonce bump of a failed CREATE when the parent reverts" {
    const parent = addr(0xc000);
    var prestate = PrestateTracer.init(testing.allocator, .{ .diff_mode = true });
    defer prestate.deinit();
    var call_tracer = CallTracer.init(testing.allocator, .{});
    defer call_tracer.deinit();
    var chain: Chain = undefined;
    const result = try runFailedCreate(true, &prestate, &call_tracer, &chain);
    defer chain.deinit();
    try testing.expect(!result.success);
    try testing.expectEqual(@as(u64, 1), TestHost.getNonce(&chain.host, parent));
    try testing.expect(prestate.account(parent).?.post.nonce == null);
    const text = try writeOwned(&prestate, "writeJson");
    defer testing.allocator.free(text);
    try testing.expectEqualStrings("{\"post\":{},\"pre\":{}}", text);
}

test "PrestateTracer keeps the observed pre-state of a prefunded CREATE2 target" {
    const parent = addr(0xc100);
    const init = initBytes(EMPTY_INIT, EMPTY_INIT_LEN);
    const target = create2Address(parent, 7, &init);
    var code: Asm = .{};
    defer code.deinit();
    try emitCreate2(&code, EMPTY_INIT, EMPTY_INIT_LEN, 5, 7);
    try code.op(&.{0x00});

    var prestate = PrestateTracer.init(testing.allocator, .{ .diff_mode = true });
    defer prestate.deinit();
    var call_tracer = CallTracer.init(testing.allocator, .{});
    defer call_tracer.deinit();
    const children = [_]insp.Inspector{ prestate.inspector(), call_tracer.inspector() };
    var mux = insp.MuxInspector.init(&children);
    var chain: Chain = undefined;
    try chain.init(parent);
    defer chain.deinit();
    chain.setCode(parent, code.bytes());
    TestHost.setNonce(&chain.host, parent, 1);
    TestHost.setBalance(&chain.host, parent, 50);
    TestHost.setBalance(&chain.host, target, 100);
    const result = chain.call(parent, parent, &.{}, 300_000, mux.inspector());
    try testing.expect(result.success);
    try testing.expect(call_tracer.root().?.calls.items[0].created_address.?.equals(target));
    try testing.expectEqual(@as(u256, 105), TestHost.getBalance(&chain.host, target));

    const text = try writeOwned(&prestate, "writeJson");
    defer testing.allocator.free(text);
    const parsed = try parseJson(text);
    defer parsed.deinit();
    var a: [42]u8 = undefined;
    const key = hexAddress(&a, target);
    const pre = parsed.value.object.get("pre").?.object.get(key).?.object;
    try testing.expectEqualStrings("0x64", pre.get("balance").?.string);
    try testing.expect(pre.get("nonce") == null and pre.get("code") == null);
    const post = parsed.value.object.get("post").?.object.get(key).?.object;
    try testing.expectEqualStrings("0x69", post.get("balance").?.string);
    try testing.expectEqual(@as(i64, 1), post.get("nonce").?.integer);
}

fn jumpiCoverage(code: []const u8, jumpi_pc: u64) !?tracers.JumpiBranch {
    const target = addr(0xe000);
    var coverage = CoverageInspector.init(testing.allocator);
    defer coverage.deinit();
    var chain: Chain = undefined;
    try chain.init(target);
    defer chain.deinit();
    chain.setCode(target, code);
    _ = chain.call(target, target, &.{}, 100_000, coverage.inspector());
    try testing.expect(coverage.err == null);
    return coverage.jumpiStats(CoverageInspector.codeHash(code), jumpi_pc);
}

test "CoverageInspector uses the JUMPI condition when the destination is pc + 1" {
    // PUSH1 cond PUSH1 5 JUMPI(pc 4) JUMPDEST(pc 5) STOP
    const not_taken = [_]u8{ 0x60, 0, 0x60, 5, 0x57, 0x5b, 0x00 };
    try testing.expectEqual(tracers.JumpiBranch{ .taken = 0, .not_taken = 1 }, (try jumpiCoverage(&not_taken, 4)).?);
    const taken = [_]u8{ 0x60, 1, 0x60, 5, 0x57, 0x5b, 0x00 };
    try testing.expectEqual(tracers.JumpiBranch{ .taken = 1, .not_taken = 0 }, (try jumpiCoverage(&taken, 4)).?);
}

test "CoverageInspector records no branch for a faulting JUMPI and fallthrough for a terminal one" {
    // Taken JUMPI to pc 6, which is not a JUMPDEST.
    const faulting = [_]u8{ 0x60, 1, 0x60, 6, 0x57, 0x5b, 0x00 };
    try testing.expect((try jumpiCoverage(&faulting, 4)) == null);
    // Stack underflow.
    const underflow = [_]u8{ 0x5f, 0x57, 0x00 };
    try testing.expect((try jumpiCoverage(&underflow, 1)) == null);
    // Not-taken JUMPI as the last byte runs into the implicit STOP.
    const terminal = [_]u8{ 0x5f, 0x5f, 0x57 };
    try testing.expectEqual(tracers.JumpiBranch{ .taken = 0, .not_taken = 1 }, (try jumpiCoverage(&terminal, 2)).?);
}

test "AccessListInspector starts each transaction with a fresh list" {
    const first_root = addr(0xf000);
    const second_root = addr(0xf001);
    const first_seen = addr(0xbeef);
    const second_seen = addr(0xcafe);
    var first_code: Asm = .{};
    defer first_code.deinit();
    try emitBalance(&first_code, first_seen);
    try first_code.sload(3);
    try emitCreate(&first_code, EMPTY_INIT, EMPTY_INIT_LEN, 0);
    try first_code.op(&.{0x00});
    var second_code: Asm = .{};
    defer second_code.deinit();
    try emitBalance(&second_code, second_seen);
    try emitBalance(&second_code, first_root);
    try second_code.op(&.{0x00});

    var tracer = AccessListInspector.init(testing.allocator, .{});
    defer tracer.deinit();
    var chain: Chain = undefined;
    try chain.init(addr(ORIGIN));
    defer chain.deinit();
    chain.setCode(first_root, first_code.bytes());
    chain.setCode(second_root, second_code.bytes());

    try testing.expect(chain.call(addr(ORIGIN), first_root, &.{}, 300_000, tracer.inspector()).success);
    const first = try tracer.toOwnedEntries(testing.allocator);
    defer tracers.freeAccessListEntries(testing.allocator, first);
    try testing.expectEqual(@as(usize, 2), first.len);

    try testing.expect(chain.call(addr(ORIGIN), second_root, &.{}, 300_000, tracer.inspector()).success);
    const second = try tracer.toOwnedEntries(testing.allocator);
    defer tracers.freeAccessListEntries(testing.allocator, second);
    // Only this transaction's accesses; the first target is no longer excluded.
    try testing.expectEqual(@as(usize, 2), second.len);
    try testing.expect(second[0].address.equals(second_seen) or second[1].address.equals(second_seen));
    try testing.expect(second[0].address.equals(first_root) or second[1].address.equals(first_root));
    for (second) |entry| {
        try testing.expect(!entry.address.equals(first_seen));
        try testing.expectEqual(@as(usize, 0), entry.storage_keys.len);
    }
}

fn accessListAfterCreate2(collide: bool, init: u256, init_len: u8) !bool {
    const root = addr(0xf100);
    const init_bytes = switch (init_len) {
        REVERTING_INIT_LEN => &initBytes(REVERTING_INIT, REVERTING_INIT_LEN),
        else => &initBytes(EMPTY_INIT, EMPTY_INIT_LEN),
    };
    const target = create2Address(root, 9, init_bytes);
    var code: Asm = .{};
    defer code.deinit();
    try emitBalance(&code, target);
    try emitCreate2(&code, init, init_len, 0, 9);
    try code.op(&.{0x00});

    var tracer = AccessListInspector.init(testing.allocator, .{});
    defer tracer.deinit();
    var chain: Chain = undefined;
    try chain.init(addr(ORIGIN));
    defer chain.deinit();
    chain.setCode(root, code.bytes());
    if (collide) chain.setCode(target, &.{0x00});
    try testing.expect(chain.call(addr(ORIGIN), root, &.{}, 300_000, tracer.inspector()).success);
    const entries = try tracer.toOwnedEntries(testing.allocator);
    defer tracers.freeAccessListEntries(testing.allocator, entries);
    for (entries) |entry| if (entry.address.equals(target)) return true;
    return false;
}

test "AccessListInspector keeps a cold access to a CREATE2 target that collides or reverts" {
    try testing.expect(try accessListAfterCreate2(true, EMPTY_INIT, EMPTY_INIT_LEN));
    try testing.expect(try accessListAfterCreate2(false, REVERTING_INIT, REVERTING_INIT_LEN));
    // A successful CREATE2 creates the account, so it is excluded.
    try testing.expect(!try accessListAfterCreate2(false, EMPTY_INIT, EMPTY_INIT_LEN));
}

test "AccessListInspector precompile exclusions follow the transaction hardfork" {
    try testing.expect(!tracers.isPrecompile(addr(0x0a), .SHANGHAI));
    try testing.expect(tracers.isPrecompile(addr(0x0a), .CANCUN));
    try testing.expect(!tracers.isPrecompile(addr(0x0100), .PRAGUE));
    try testing.expect(tracers.isPrecompile(addr(0x0100), .OSAKA));
}
