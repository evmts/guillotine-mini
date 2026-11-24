//! Round 2 review regressions for opcode halts and frame tracing
//! (R2-04, R2-11, R2-12, R2-16, R2-043, R2-054, F-38).
const std = @import("std");
const testing = std.testing;
const primitives = @import("voltaire");
const GasConstants = primitives.GasConstants;
const Hardfork = primitives.Hardfork;
const Address = primitives.Address.Address;
const evm_mod = @import("../evm.zig");
const trace = @import("../trace.zig");
const Evm = evm_mod.Evm(.{});
const Frame = @import("../frame.zig").Frame(.{});
const System = @import("handlers_system.zig").Handlers(Frame);
const Storage = @import("handlers_storage.zig").Handlers(Frame);
const Memory = @import("handlers_memory.zig").Handlers(Frame);
const Log = @import("handlers_log.zig").Handlers(Frame);

const Harness = struct {
    evm: *Evm,
    allocator: std.mem.Allocator,

    fn init(allocator: std.mem.Allocator, hardfork: Hardfork) !Harness {
        const evm = try allocator.create(Evm);
        errdefer allocator.destroy(evm);
        try evm.init(allocator, null, hardfork, null, primitives.ZERO_ADDRESS, 0, null);
        errdefer evm.deinit();
        try evm.initTransactionState(null);
        return .{ .evm = evm, .allocator = allocator };
    }

    /// Register a frame on the EVM frame stack (as `Evm.call` does) and return it.
    fn frame(self: *Harness, code: []const u8, gas: i64) !*Frame {
        try self.evm.frames.append(self.evm.tx_arena.allocator(), try Frame.init(
            self.allocator,
            code,
            gas,
            try Address.fromHex("0x1111111111111111111111111111111111111111"),
            try Address.fromHex("0x2222222222222222222222222222222222222222"),
            0,
            &.{},
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

test "R2-04 SELFDESTRUCT touches an existing empty beneficiary on a 0-wei transfer" {
    var h = try Harness.init(testing.allocator, .SPURIOUS_DRAGON);
    defer h.deinit();
    const beneficiary = try Address.fromHex("0x0000000000000000000000000000000000009999");
    try h.evm.balances.put(beneficiary, 0);
    const f = try h.frame(&.{}, 100_000);
    try f.pushStack(0x9999);
    try System.selfdestruct(f);
    try testing.expect(h.evm.touched_accounts.contains(beneficiary));
    try testing.expectEqual(beneficiary, h.evm.touched_journal.items[h.evm.touched_journal.items.len - 1]);
}

test "R2-11 SSTORE sentry halt burns all gas" {
    var h = try Harness.init(testing.allocator, .ISTANBUL);
    defer h.deinit();
    const f = try h.frame(&.{}, GasConstants.SstoreSentryGas);
    try pushOperands(f, &.{ 1, 1 });
    try testing.expectError(error.OutOfGas, Storage.sstore(f));
    try testing.expectEqual(@as(i64, 0), f.gas_remaining);
}

test "R2-043 SSTORE with a short stack is StackUnderflow even below the sentry" {
    var h = try Harness.init(testing.allocator, .CANCUN);
    defer h.deinit();
    const f = try h.frame(&.{}, 100);
    try f.pushStack(1);
    try testing.expectError(error.StackUnderflow, Storage.sstore(f));
}

test "R2-11 CREATE and CREATE2 reject oversize initcode before expanding memory" {
    inline for (.{ false, true }) |is_create2| {
        var h = try Harness.init(testing.allocator, .SHANGHAI);
        defer h.deinit();
        const f = try h.frame(&.{}, 30_000_000);
        if (is_create2) try f.pushStack(0); // salt
        try pushOperands(f, &.{ 0, 0, GasConstants.MaxInitcodeSize + 1 });
        const result = if (is_create2) System.create2(f) else System.create(f);
        try testing.expectError(error.OutOfGas, result);
        try testing.expectEqual(@as(i64, 0), f.gas_remaining);
        try testing.expectEqual(@as(u32, 0), f.memory_size);
    }
}

test "R2-11 LOG4 with two stack items is StackUnderflow, not OutOfGas" {
    var h = try Harness.init(testing.allocator, .CANCUN);
    defer h.deinit();
    const f = try h.frame(&.{}, 1_000);
    try pushOperands(f, &.{ 0, 1 << 32 });
    try testing.expectError(error.StackUnderflow, Log.log(f, 0xa4));
}

test "R2-11 LOG data and topics live in the transaction arena" {
    var h = try Harness.init(testing.allocator, .CANCUN);
    defer h.deinit();
    const f = try h.frame(&.{}, 10_000);
    try pushOperands(f, &.{ 0, 32, 0xaa, 0xbb });
    try Log.log(f, 0xa2);
    try testing.expectEqual(@as(usize, 1), h.evm.logs.items.len);
    const lg = h.evm.logs.items[0];
    try testing.expectEqualSlices(u256, &.{ 0xaa, 0xbb }, lg.topics);
    try testing.expectEqual(@as(usize, 32), lg.data.len);
}

test "R2-12 MLOAD, MSTORE and MSTORE8 past the u32 memory model halt with OutOfGas" {
    const offsets = [_]u256{ std.math.maxInt(u32), std.math.maxInt(u32) - 16, 1 << 40 };
    for (offsets) |offset| {
        var h = try Harness.init(testing.allocator, .CANCUN);
        defer h.deinit();
        const f = try h.frame(&.{}, 1_000_000);
        try f.pushStack(offset);
        try testing.expectError(error.OutOfGas, Memory.mload(f));
        try testing.expectEqual(@as(i64, 0), f.gas_remaining);

        f.gas_remaining = 1_000_000;
        try pushOperands(f, &.{ offset, 0x42 });
        try testing.expectError(error.OutOfGas, Memory.mstore(f));
        try testing.expectEqual(@as(i64, 0), f.gas_remaining);

        f.gas_remaining = 1_000_000;
        try pushOperands(f, &.{ offset, 0x42 });
        try testing.expectError(error.OutOfGas, Memory.mstore8(f));
        try testing.expectEqual(@as(i64, 0), f.gas_remaining);
    }
}

test "R2-12 MSTORE then MLOAD round-trips a word and expands memory by one word" {
    var h = try Harness.init(testing.allocator, .CANCUN);
    defer h.deinit();
    const f = try h.frame(&.{}, 1_000);
    const word: u256 = 0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20;
    try pushOperands(f, &.{ 1, word });
    try Memory.mstore(f);
    try testing.expectEqual(@as(u32, 64), f.memory_size);
    try testing.expectEqual(@as(i64, 1_000 - 3 - 6), f.gas_remaining);
    try f.pushStack(1);
    try Memory.mload(f);
    try testing.expectEqual(word, try f.popStack());
    try pushOperands(f, &.{ 70, 0x1ff });
    try Memory.mstore8(f);
    try testing.expectEqual(@as(u8, 0xff), f.readMemory(70));
    try testing.expectEqual(@as(u32, 96), f.memory_size);
}

test "R2-054 trace memSize reports logical memory when memory capture is off" {
    var h = try Harness.init(testing.allocator, .CANCUN);
    defer h.deinit();
    var tracer = trace.Tracer.init(testing.allocator);
    defer tracer.deinit();
    tracer.enabled = true;
    tracer.config.disable_memory = true;
    tracer.config.enable_memory = false;
    h.evm.setTracer(&tracer);

    // PUSH1 0, MLOAD, STOP
    const f = try h.frame(&.{ 0x60, 0x00, 0x51, 0x00 }, 1_000);
    try f.execute();
    try testing.expectEqual(@as(usize, 3), tracer.entries.items.len);
    try testing.expect(tracer.entries.items[2].memory == null);
    try testing.expectEqual(@as(usize, 32), tracer.entries.items[2].memSize);
    try testing.expect(tracer.entries.items[2].error_msg == null);
}
