const std = @import("std");
const ex = @import("../common.zig");

pub fn run(allocator: std.mem.Allocator, out: *std.Io.Writer) !void {
    var evm: ex.Evm = undefined;
    try evm.init(allocator, null, .CANCUN, null, ex.alice, 0, null);
    defer evm.deinit();
    try evm.initTransactionState(null);

    // Store 42 at memory offset zero, one opcode at a time.
    const code = [_]u8{ 0x60, 42, 0x5f, 0x52, 0x00 };
    var frame = try ex.mini.Frame(.{}).init(allocator, &code, 100, ex.alice, ex.contract, 0, &.{}, &evm, .CANCUN, false);
    defer frame.deinit();
    while (!frame.stopped and !frame.reverted) {
        const op = frame.getCurrentOpcode() orelse break;
        const pc = frame.pc;
        try frame.step();
        try out.print("pc={d} {s} stack={any} memory={d} gas={d}\n", .{
            pc, ex.mini.getOpName(op), frame.stack.items, frame.memory_size, frame.gas_remaining,
        });
    }
    try std.testing.expect(frame.stopped);
    try std.testing.expectEqual(42, frame.memory.items[31]);
}
