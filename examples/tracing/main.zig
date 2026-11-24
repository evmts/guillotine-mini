const std = @import("std");
const ex = @import("../common.zig");

pub fn run(allocator: std.mem.Allocator, out: *std.Io.Writer) !void {
    var tracer = ex.mini.Tracer.init(allocator);
    defer tracer.deinit();
    tracer.config.disable_memory = true;
    tracer.config.disable_storage = true;
    tracer.enable();
    var evm: ex.Evm = undefined;
    try evm.init(allocator, null, .CANCUN, null, ex.alice, 0, null);
    defer evm.deinit();
    evm.setTracer(&tracer);

    // The POP entry sees 42 on the stack because trace snapshots precede execution.
    const result = evm.callWithBytecodeOverride(ex.message(ex.contract), &.{ 0x60, 42, 0x50, 0x00 });
    try ex.requireSuccess(result);
    try std.testing.expectEqual(3, tracer.entries.items.len);
    try tracer.writeEip3155Jsonl(out, .{ .output = result.output, .gas_used = result.gasConsumed(ex.gas) });
}
