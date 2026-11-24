//! Round 1 review regressions for Frame dispatch, memory bounds, CALL-family gas,
//! historical fork rules, and refund accounting (F-01/F-02/F-12/F-13, C-01/C-03/C-11,
//! C-18, R1-003/R1-013/R1-014/R1-015/R1-027/R1-028).
const std = @import("std");
const testing = std.testing;
const primitives = @import("voltaire");
const GasConstants = primitives.GasConstants;
const Hardfork = primitives.Hardfork;
const Address = primitives.Address.Address;
const evm_mod = @import("../evm.zig");
const Evm = evm_mod.Evm(.{});
const Frame = @import("../frame.zig").Frame(.{});
const System = @import("handlers_system.zig").Handlers(Frame);
const Context = @import("handlers_context.zig").Handlers(Frame);
const Memory = @import("handlers_memory.zig").Handlers(Frame);
const Log = @import("handlers_log.zig").Handlers(Frame);
const Keccak = @import("handlers_keccak.zig").Handlers(Frame);
const ControlFlow = @import("handlers_control_flow.zig").Handlers(Frame);

const max_u256 = std.math.maxInt(u256);
const two_32: u256 = 1 << 32;
const two_64: u256 = 1 << 64;

const Harness = struct {
    evm: *Evm,
    allocator: std.mem.Allocator,

    fn init(allocator: std.mem.Allocator, hardfork: Hardfork) !Harness {
        const evm = try allocator.create(Evm);
        errdefer allocator.destroy(evm);
        const block_context = evm_mod.BlockContext{
            .chain_id = 1,
            .block_number = 1,
            .block_timestamp = 1000,
            .block_difficulty = 0,
            .block_prevrandao = 0,
            .block_coinbase = primitives.ZERO_ADDRESS,
            .block_gas_limit = 30_000_000,
            .block_base_fee = 1,
            .blob_base_fee = 1,
        };
        try evm.init(allocator, null, hardfork, block_context, primitives.ZERO_ADDRESS, 0, null);
        errdefer evm.deinit();
        try evm.initTransactionState(null);
        return .{ .evm = evm, .allocator = allocator };
    }

    /// Register a frame on the EVM frame stack (as the interpreter does) and return it.
    fn frame(self: *Harness, code: []const u8, gas: i64, calldata: []const u8) !*Frame {
        try self.evm.frames.append(self.evm.arena.allocator(), try Frame.init(
            self.allocator,
            code,
            gas,
            try Address.fromHex("0x1111111111111111111111111111111111111111"),
            try Address.fromHex("0x2222222222222222222222222222222222222222"),
            0,
            calldata,
            @ptrCast(self.evm),
            self.evm.hardfork,
            false,
        ));
        return self.evm.getCurrentFrame().?;
    }

    fn deinit(self: *Harness) void {
        for (self.evm.frames.items) |*f| f.deinit();
        self.evm.deinit();
        self.allocator.destroy(self.evm);
    }
};

/// Push operands so the handler pops them in the listed order.
fn pushOperands(f: *Frame, operands: []const u256) !void {
    var i = operands.len;
    while (i > 0) {
        i -= 1;
        try f.pushStack(operands[i]);
    }
}

fn addressWord(hex: []const u8) !u256 {
    const a = try Address.fromHex(hex);
    var v: u256 = 0;
    for (a.bytes) |b| v = (v << 8) | b;
    return v;
}

// ---------------------------------------------------------------- dispatch

test "R1 Frame.execute dispatches CLZ on Osaka" {
    var h = try Harness.init(testing.allocator, .OSAKA);
    defer h.deinit();
    // PUSH1 1; CLZ; STOP
    const f = try h.frame(&[_]u8{ 0x60, 0x01, 0x1e, 0x00 }, 100, &.{});
    try f.execute();
    try testing.expectEqual(@as(u256, 255), try f.peekStack(0));
    try testing.expectEqual(@as(i64, 100 - 3 - 5), f.gas_remaining);
}

test "R1 Frame.executeOpcode rejects CLZ before Osaka" {
    var h = try Harness.init(testing.allocator, .PRAGUE);
    defer h.deinit();
    const f = try h.frame(&[_]u8{0x1e}, 100, &.{});
    try f.pushStack(1);
    try testing.expectError(error.InvalidOpcode, f.executeOpcode(0x1e));
}

test "R1 peekStack indexes from the top" {
    var h = try Harness.init(testing.allocator, .OSAKA);
    defer h.deinit();
    const f = try h.frame(&.{}, 100, &.{});
    try f.pushStack(7);
    try f.pushStack(9);
    try testing.expectEqual(@as(u256, 9), try f.peekStack(0));
    try testing.expectEqual(@as(u256, 7), try f.peekStack(1));
    try testing.expectError(error.StackUnderflow, f.peekStack(2));
}

// ---------------------------------------------------------------- memory model

test "R1 memoryRange: zero length ignores any offset; huge ranges are OutOfGas" {
    var h = try Harness.init(testing.allocator, .OSAKA);
    defer h.deinit();
    const f = try h.frame(&.{}, 1000, &.{});
    try testing.expect((try f.memoryRange(max_u256, 0)) == null);
    try testing.expectError(error.OutOfGas, f.memoryRange(two_32, 1));
    try testing.expectEqual(@as(i64, 0), f.gas_remaining);
    f.gas_remaining = 1000;
    try testing.expectError(error.OutOfGas, f.memoryRange(0, max_u256));
    f.gas_remaining = 1000;
    try testing.expectError(error.OutOfGas, f.memoryRange(std.math.maxInt(u32) - 31, 1));
    try testing.expectError(error.OutOfGas, Frame.wordAlignedSize(std.math.maxInt(u64)));
    try testing.expectError(error.OutOfGas, Frame.wordAlignedSize(std.math.maxInt(u32)));
    try testing.expectEqual(@as(u32, 64), try Frame.wordAlignedSize(33));
}

// ---------------------------------------------------------------- copy ops

test "R1 CALLDATACOPY zero length to dest 2^256-1 costs 3 gas and keeps MSIZE" {
    var h = try Harness.init(testing.allocator, .OSAKA);
    defer h.deinit();
    const f = try h.frame(&.{}, 100, &.{});
    try pushOperands(f, &.{ max_u256, 0, 0 });
    try Context.calldatacopy(f);
    try testing.expectEqual(@as(i64, 97), f.gas_remaining);
    try testing.expectEqual(@as(u32, 0), f.memory_size);
}

test "R1 CALLDATACOPY zero length to offset 256 charges no expansion" {
    var h = try Harness.init(testing.allocator, .OSAKA);
    defer h.deinit();
    const f = try h.frame(&.{}, 100, &.{});
    try pushOperands(f, &.{ 256, 0, 0 });
    try Context.calldatacopy(f);
    try testing.expectEqual(@as(i64, 97), f.gas_remaining);
    try testing.expectEqual(@as(u32, 0), f.memory_size);
}

test "R1 CALLDATACOPY source past 2^32 and 2^256-1 zero-pads" {
    var h = try Harness.init(testing.allocator, .OSAKA);
    defer h.deinit();
    const f = try h.frame(&.{}, 1000, &[_]u8{ 0xaa, 0xbb });
    // Dirty memory first so zero-padding is observable.
    try f.writeMemorySlice(0, &([_]u8{0xff} ** 32));
    try pushOperands(f, &.{ 0, two_32, 1 });
    try Context.calldatacopy(f);
    try testing.expectEqual(@as(u8, 0), f.readMemory(0));
    try testing.expectEqual(@as(u8, 0xff), f.readMemory(1));
    try pushOperands(f, &.{ 0, max_u256, 32 });
    try Context.calldatacopy(f);
    try testing.expectEqual(@as(u8, 0), f.readMemory(31));
}

test "R1 CALLDATACOPY copies the in-range prefix then zero-pads" {
    var h = try Harness.init(testing.allocator, .OSAKA);
    defer h.deinit();
    const f = try h.frame(&.{}, 1000, &[_]u8{ 1, 2, 3 });
    try f.writeMemorySlice(0, &([_]u8{0xff} ** 4));
    try pushOperands(f, &.{ 0, 1, 4 });
    try Context.calldatacopy(f);
    try testing.expectEqual(@as(u8, 2), f.readMemory(0));
    try testing.expectEqual(@as(u8, 3), f.readMemory(1));
    try testing.expectEqual(@as(u8, 0), f.readMemory(2));
    try testing.expectEqual(@as(u8, 0), f.readMemory(3));
    try testing.expectEqual(@as(u32, 32), f.memory_size);
}

test "R1 CODECOPY source past 2^64 copies a zero byte" {
    var h = try Harness.init(testing.allocator, .OSAKA);
    defer h.deinit();
    const f = try h.frame(&[_]u8{0x39}, 1000, &.{});
    try pushOperands(f, &.{ 0, two_64, 1 });
    try Context.codecopy(f);
    try testing.expectEqual(@as(u8, 0), f.readMemory(0));
    try testing.expectEqual(@as(u32, 32), f.memory_size);
    try testing.expectEqual(@as(i64, 1000 - 3 - 3 - 3), f.gas_remaining);
}

test "R1 CALLDATALOAD near and past u32 max pushes zero" {
    var h = try Harness.init(testing.allocator, .OSAKA);
    defer h.deinit();
    const f = try h.frame(&.{}, 1000, &[_]u8{ 1, 2, 3 });
    for ([_]u256{ 0xfffffff0, std.math.maxInt(u32), two_64, max_u256 }) |off| {
        try f.pushStack(off);
        try Context.calldataload(f);
        try testing.expectEqual(@as(u256, 0), try f.popStack());
    }
    try f.pushStack(1);
    try Context.calldataload(f);
    try testing.expectEqual(@as(u256, 0x0203) << 240, try f.popStack());
}

test "R1 EXTCODECOPY zero length to dest 2^32 is a no-op" {
    var h = try Harness.init(testing.allocator, .OSAKA);
    defer h.deinit();
    const f = try h.frame(&.{}, 10_000, &.{});
    try pushOperands(f, &.{ 0x1234, two_32, 0, 0 });
    try Context.extcodecopy(f);
    try testing.expectEqual(@as(u32, 0), f.memory_size);
    try testing.expectEqual(@as(i64, 10_000 - GasConstants.ColdAccountAccessCost), f.gas_remaining);
}

test "R1 RETURNDATACOPY zero length ignores dest but enforces the source bound" {
    var h = try Harness.init(testing.allocator, .OSAKA);
    defer h.deinit();
    const f = try h.frame(&.{}, 1000, &.{});
    try pushOperands(f, &.{ two_32, 0, 0 });
    try Context.returndatacopy(f);
    try testing.expectEqual(@as(u32, 0), f.memory_size);
    try testing.expectEqual(@as(i64, 997), f.gas_remaining);
    try pushOperands(f, &.{ 0, 1, 0 });
    try testing.expectError(error.OutOfBounds, Context.returndatacopy(f));
}

test "R1 MCOPY of 0xffffffff bytes is OutOfGas, not a panic" {
    var h = try Harness.init(testing.allocator, .OSAKA);
    defer h.deinit();
    const f = try h.frame(&.{}, 1_000_000, &.{});
    try pushOperands(f, &.{ 0, 0, std.math.maxInt(u32) });
    try testing.expectError(error.OutOfGas, Memory.mcopy(f));
}

test "R1 MCOPY zero length with huge offsets is a 3-gas no-op" {
    var h = try Harness.init(testing.allocator, .OSAKA);
    defer h.deinit();
    const f = try h.frame(&.{}, 100, &.{});
    try pushOperands(f, &.{ max_u256, max_u256, 0 });
    try Memory.mcopy(f);
    try testing.expectEqual(@as(i64, 97), f.gas_remaining);
    try testing.expectEqual(@as(u32, 0), f.memory_size);
}

test "R1 LOG0 with offset 2^32 and size 0 emits a log" {
    var h = try Harness.init(testing.allocator, .OSAKA);
    defer h.deinit();
    const f = try h.frame(&.{}, 1000, &.{});
    try pushOperands(f, &.{ two_32, 0 });
    try Log.log(f, 0xa0);
    try testing.expectEqual(@as(usize, 1), h.evm.logs.items.len);
    try testing.expectEqual(@as(usize, 0), h.evm.logs.items[0].data.len);
    try testing.expectEqual(@as(u32, 0), f.memory_size);
    try testing.expectEqual(@as(i64, 1000 - GasConstants.LogGas), f.gas_remaining);
}

test "R1 KECCAK256 zero length at 2^256-1 hashes empty input" {
    var h = try Harness.init(testing.allocator, .OSAKA);
    defer h.deinit();
    const f = try h.frame(&.{}, 1000, &.{});
    try pushOperands(f, &.{ max_u256, 0 });
    try Keccak.sha3(f);
    try testing.expectEqual(@as(u256, 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470), try f.popStack());
    try testing.expectEqual(@as(u32, 0), f.memory_size);
}

test "R1 RETURN and REVERT zero length at 2^256-1 halt without expansion" {
    var h = try Harness.init(testing.allocator, .OSAKA);
    defer h.deinit();
    const f = try h.frame(&.{}, 1000, &.{});
    try pushOperands(f, &.{ max_u256, 0 });
    try ControlFlow.ret(f);
    try testing.expect(f.stopped);
    try testing.expectEqual(@as(usize, 0), f.output.len);
    try pushOperands(f, &.{ max_u256, 0 });
    try ControlFlow.revert(f);
    try testing.expect(f.reverted);
    try testing.expectEqual(@as(u32, 0), f.memory_size);
    try testing.expectEqual(@as(i64, 1000), f.gas_remaining);
}

test "R1 JUMP to a destination past u32 is InvalidJumpDestination" {
    var h = try Harness.init(testing.allocator, .OSAKA);
    defer h.deinit();
    const f = try h.frame(&[_]u8{0x56}, 1000, &.{});
    try f.pushStack(two_32);
    try testing.expectError(error.InvalidJumpDestination, ControlFlow.jump(f));
}

// ---------------------------------------------------------------- CALL family bounds

test "R1 CALL with in_offset 2^64 is OutOfGas, not a panic" {
    var h = try Harness.init(testing.allocator, .OSAKA);
    defer h.deinit();
    const f = try h.frame(&.{}, 100_000, &.{});
    // gas, to, value, in_off, in_len, out_off, out_len
    try pushOperands(f, &.{ 0, 0x99, 0, two_64, 1, 0, 0 });
    try testing.expectError(error.OutOfGas, System.call(f));
}

test "R1 CALL with out_offset 2^64 and out_len 1 is OutOfGas" {
    var h = try Harness.init(testing.allocator, .OSAKA);
    defer h.deinit();
    const f = try h.frame(&.{}, 100_000, &.{});
    try pushOperands(f, &.{ 0, 0x99, 0, 0, 0, two_64, 1 });
    try testing.expectError(error.OutOfGas, System.call(f));
}

test "R1 CALL family with in_length 2^32 is OutOfGas for every variant" {
    inline for (.{ "call", "callcode", "delegatecall", "staticcall" }) |name| {
        var h = try Harness.init(testing.allocator, .OSAKA);
        defer h.deinit();
        const f = try h.frame(&.{}, 1000, &.{});
        const has_value = comptime std.mem.eql(u8, name, "call") or std.mem.eql(u8, name, "callcode");
        if (has_value) {
            try pushOperands(f, &.{ 0, 0x99, 0, 0, two_32, 0, 0 });
        } else {
            try pushOperands(f, &.{ 0, 0x99, 0, two_32, 0, 0 });
        }
        try testing.expectError(error.OutOfGas, @field(System, name)(f));
    }
}

test "R1 CALL zero-length regions at 2^256-1 charge no expansion" {
    var h = try Harness.init(testing.allocator, .OSAKA);
    defer h.deinit();
    const f = try h.frame(&.{}, 100_000, &.{});
    try pushOperands(f, &.{ 0, 0x99, 0, max_u256, 0, max_u256, 0 });
    try System.call(f);
    try testing.expectEqual(@as(u256, 1), try f.popStack());
    try testing.expectEqual(@as(u32, 0), f.memory_size);
    try testing.expectEqual(@as(i64, 100_000 - GasConstants.ColdAccountAccessCost), f.gas_remaining);
}

test "R1 CREATE zero-length init code at offset 2^256-1 does not expand memory" {
    var h = try Harness.init(testing.allocator, .OSAKA);
    defer h.deinit();
    const f = try h.frame(&.{}, 1_000_000, &.{});
    try h.evm.setNonceWithSnapshot(f.address, 1);
    try pushOperands(f, &.{ 0, max_u256, 0 });
    try System.create(f);
    try testing.expectEqual(@as(u32, 0), f.memory_size);
}

// ---------------------------------------------------------------- historical gas

test "R1 Homestead CALL requesting more gas than remains is OutOfGas" {
    var h = try Harness.init(testing.allocator, .HOMESTEAD);
    defer h.deinit();
    const f = try h.frame(&.{}, 50_000, &.{});
    const to = try addressWord("0x2222222222222222222222222222222222222222"); // exists (self)
    try h.evm.balances.put(try Address.fromHex("0x2222222222222222222222222222222222222222"), 1);
    try pushOperands(f, &.{ 60_000, to, 0, 0, 0, 0, 0 });
    try testing.expectError(error.OutOfGas, System.call(f));
}

test "R1 Homestead zero-value CALL to a missing account pays 25000" {
    var h = try Harness.init(testing.allocator, .HOMESTEAD);
    defer h.deinit();
    const f = try h.frame(&.{}, 50_000, &.{});
    try pushOperands(f, &.{ 0, 0x9999, 0, 0, 0, 0, 0 });
    try System.call(f);
    try testing.expectEqual(@as(i64, 50_000 - 40 - 25_000), f.gas_remaining);
}

test "R1 Spurious Dragon zero-value CALL to a missing account pays no surcharge" {
    var h = try Harness.init(testing.allocator, .SPURIOUS_DRAGON);
    defer h.deinit();
    const f = try h.frame(&.{}, 50_000, &.{});
    try pushOperands(f, &.{ 0, 0x9999, 0, 0, 0, 0, 0 });
    try System.call(f);
    try testing.expectEqual(@as(i64, 50_000 - 700), f.gas_remaining);
}

fn selfdestructGas(hardfork: Hardfork, self_balance: u256) !i64 {
    var h = try Harness.init(testing.allocator, hardfork);
    defer h.deinit();
    const f = try h.frame(&.{}, 100_000, &.{});
    if (self_balance > 0) try h.evm.balances.put(f.address, self_balance);
    try f.pushStack(0x9999); // beneficiary does not exist
    try System.selfdestruct(f);
    return 100_000 - f.gas_remaining;
}

test "R1 SELFDESTRUCT new-beneficiary surcharge follows EIP-150 and EIP-161" {
    // Before Tangerine Whistle: free, even funded.
    try testing.expectEqual(@as(i64, 0), try selfdestructGas(.HOMESTEAD, 1));
    // Tangerine Whistle: 5000 + 25000 for a missing beneficiary, even unfunded.
    try testing.expectEqual(@as(i64, 30_000), try selfdestructGas(.TANGERINE_WHISTLE, 0));
    // Spurious Dragon+: surcharge only when the balance is non-zero.
    try testing.expectEqual(@as(i64, 5_000), try selfdestructGas(.SPURIOUS_DRAGON, 0));
    try testing.expectEqual(@as(i64, 30_000), try selfdestructGas(.SPURIOUS_DRAGON, 1));
}

// ---------------------------------------------------------------- CallParams

test "R1 CallParams.validate imposes no calldata or pre-Shanghai initcode cap" {
    const Params = Evm.CallParams;
    const big = try testing.allocator.alloc(u8, 4 * 1024 * 1024 + 1);
    defer testing.allocator.free(big);
    const p_call = Params{ .call = .{ .caller = primitives.ZERO_ADDRESS, .to = primitives.ZERO_ADDRESS, .value = 0, .input = big, .gas = 1 } };
    try p_call.validate();
    const p_create = Params{ .create = .{ .caller = primitives.ZERO_ADDRESS, .value = 0, .init_code = big[0..49_153], .gas = 1 } };
    try p_create.validate();
}

test "R1 CallParams.delegatecall carries the inherited value through clone" {
    const Params = Evm.CallParams;
    const p = Params{ .delegatecall = .{ .caller = primitives.ZERO_ADDRESS, .to = primitives.ZERO_ADDRESS, .input = &.{}, .gas = 1, .value = 42 } };
    const c = try p.clone(testing.allocator);
    defer c.deinit(testing.allocator);
    try testing.expectEqual(@as(u256, 42), c.delegatecall.value);
}
