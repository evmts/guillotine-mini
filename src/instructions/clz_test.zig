/// Unit tests for the CLZ opcode (EIP-7939, Osaka+)
const std = @import("std");
const testing = std.testing;
const primitives = @import("voltaire");
const GasConstants = primitives.GasConstants;
const Hardfork = primitives.Hardfork;
const Address = primitives.Address.Address;
const evm_mod = @import("../evm.zig");
const Evm = evm_mod.Evm(.{});
const Frame = @import("../frame.zig").Frame(.{});
const BitwiseHandlers = @import("handlers_bitwise.zig").Handlers(Frame);
const TestHelper = @import("test_helpers.zig").TestHelper;

const Harness = struct {
    evm: *Evm,
    frame: Frame,

    fn init(allocator: std.mem.Allocator, hardfork: Hardfork, gas: i64) !Harness {
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

        const frame = try Frame.init(
            allocator,
            &[_]u8{0x1e},
            gas,
            try Address.fromHex("0x1111111111111111111111111111111111111111"),
            try Address.fromHex("0x2222222222222222222222222222222222222222"),
            0,
            &.{},
            @ptrCast(evm),
            hardfork,
            false,
        );
        return .{ .evm = evm, .frame = frame };
    }

    fn deinit(self: *Harness, allocator: std.mem.Allocator) void {
        self.frame.deinit();
        self.evm.deinit();
        allocator.destroy(self.evm);
    }
};

fn expectClz(input: u256, expected: u256) !void {
    const allocator = testing.allocator;
    var h = try Harness.init(allocator, .OSAKA, 1_000_000);
    defer h.deinit(allocator);

    try h.frame.pushStack(input);
    const gas_before = h.frame.gas_remaining;
    try BitwiseHandlers.clz(&h.frame);

    try testing.expectEqual(@as(usize, 1), h.frame.stack.items.len);
    try testing.expectEqual(expected, h.frame.stack.items[0]);
    try testing.expectEqual(@as(i64, GasConstants.GasFastStep), gas_before - h.frame.gas_remaining);
    try testing.expectEqual(@as(u32, 1), h.frame.pc);
}

test "CLZ: 0 -> 256" {
    try expectClz(0, 256);
}

test "CLZ: 1 -> 255" {
    try expectClz(1, 255);
}

test "CLZ: maxInt(u256) -> 0" {
    try expectClz(std.math.maxInt(u256), 0);
}

test "CLZ: 1 << 255 -> 0" {
    try expectClz(@as(u256, 1) << 255, 0);
}

test "CLZ: 1 << 128 -> 127" {
    try expectClz(@as(u256, 1) << 128, 127);
}

test "CLZ: 1 << 254 -> 1" {
    try expectClz(@as(u256, 1) << 254, 1);
}

test "CLZ: costs 5 gas" {
    try testing.expectEqual(@as(u64, 5), GasConstants.GasFastStep);
}

test "CLZ: invalid before Osaka (Prague)" {
    const allocator = testing.allocator;
    var h = try Harness.init(allocator, .PRAGUE, 1_000_000);
    defer h.deinit(allocator);

    try h.frame.pushStack(1);
    const gas_before = h.frame.gas_remaining;
    try testing.expectError(error.InvalidOpcode, BitwiseHandlers.clz(&h.frame));
    try testing.expectEqual(gas_before, h.frame.gas_remaining);
    try testing.expectEqual(@as(u32, 0), h.frame.pc);
}

test "CLZ: out of gas with 4 gas" {
    const allocator = testing.allocator;
    var h = try Harness.init(allocator, .OSAKA, 4);
    defer h.deinit(allocator);

    try h.frame.pushStack(1);
    try testing.expectError(error.OutOfGas, BitwiseHandlers.clz(&h.frame));
}

test "CLZ: stack underflow on empty stack" {
    const allocator = testing.allocator;
    var h = try Harness.init(allocator, .OSAKA, 1_000_000);
    defer h.deinit(allocator);

    try testing.expectError(error.StackUnderflow, BitwiseHandlers.clz(&h.frame));
}

// ---- Dispatch-level CLZ tests through Frame.executeOpcode ----

test "CLZ counts leading zeros across the 256-bit word" {
    var helper = try TestHelper.init(testing.allocator);
    defer helper.deinit();
    helper.withHardfork(.OSAKA);
    try helper.withBytecode(&.{ 0x1e, 0x00 });

    const cases = [_]struct { input: u256, expected: u256 }{
        .{ .input = 0, .expected = 256 },
        .{ .input = 1, .expected = 255 },
        .{ .input = @as(u256, 1) << 255, .expected = 0 },
        .{ .input = std.math.maxInt(u256), .expected = 0 },
        .{ .input = @as(u256, 1) << 254, .expected = 1 },
        .{ .input = (@as(u256, 1) << 128) | 0x55, .expected = 127 },
        .{ .input = @as(u256, 1) << 63, .expected = 192 },
        .{ .input = 0xff, .expected = 248 },
    };
    for (cases) |case| {
        helper.frame.pc = 0;
        helper.withGas(5);
        try helper.frame.pushStack(42);
        try helper.frame.pushStack(case.input);

        try helper.frame.executeOpcode(0x1e);

        try testing.expectEqual(@as(i64, 0), helper.frame.gas_remaining);
        try testing.expectEqual(@as(usize, 1), helper.frame.pc);
        try testing.expectEqualSlices(u256, &.{ 42, case.expected }, helper.frame.stack.items);
        helper.frame.stack.clearRetainingCapacity();
    }
}

test "CLZ rejects insufficient gas and inactive forks before popping the stack" {
    var helper = try TestHelper.init(testing.allocator);
    defer helper.deinit();
    try helper.withBytecode(&.{0x1e});
    try helper.frame.pushStack(1);

    for ([_]Hardfork{ .CANCUN, .PRAGUE }) |fork| {
        helper.withHardfork(fork);
        helper.withGas(5);
        try testing.expectError(error.InvalidOpcode, helper.frame.executeOpcode(0x1e));
        try testing.expectEqual(@as(i64, 5), helper.frame.gas_remaining);
        try testing.expectEqual(@as(usize, 0), helper.frame.pc);
        try testing.expectEqualSlices(u256, &.{1}, helper.frame.stack.items);
    }

    helper.withHardfork(.OSAKA);
    helper.withGas(4);
    try testing.expectError(error.OutOfGas, helper.frame.executeOpcode(0x1e));
    try testing.expectEqual(@as(usize, 0), helper.frame.pc);
    try testing.expectEqualSlices(u256, &.{1}, helper.frame.stack.items);
}

test "CLZ requires one stack word" {
    var helper = try TestHelper.init(testing.allocator);
    defer helper.deinit();
    helper.withHardfork(.OSAKA);
    try helper.withBytecode(&.{0x1e});
    helper.withGas(5);
    try testing.expectError(error.StackUnderflow, helper.frame.executeOpcode(0x1e));
}
