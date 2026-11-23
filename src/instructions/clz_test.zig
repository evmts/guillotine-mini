const std = @import("std");
const testing = std.testing;
const Hardfork = @import("voltaire").Hardfork;
const TestHelper = @import("test_helpers.zig").TestHelper;

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
