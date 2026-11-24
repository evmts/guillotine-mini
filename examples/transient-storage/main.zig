const std = @import("std");
const ex = @import("../common.zig");

// Check slot zero on entry, set it while the guarded code runs, then release it.
// Leave the lock value on the stack to return as evidence of the critical section.
const guarded = [_]u8{
    0x5f, 0x5c, 0x60, 20, 0x57, // JUMPI to REVERT if TLOAD(0) is non-zero
    0x60, 1, 0x5f, 0x5d, // TSTORE(0, 1)
    0x5f, 0x5c, // TLOAD(0) inside the guard
    0x5f, 0x5f, 0x5d, // TSTORE(0, 0) on exit
    0x5f, 0x52, 0x60, 32, 0x5f, 0xf3, // return the observed value
    0x5b, 0x5f, 0x5f, 0xfd, // JUMPDEST; REVERT
};

pub fn run(allocator: std.mem.Allocator, out: *std.Io.Writer) !void {
    var evm: ex.Evm = undefined;
    try evm.init(allocator, null, .CANCUN, null, ex.alice, 0, null);
    defer evm.deinit();
    const params = ex.message(ex.contract);
    const inside = try ex.outputWord(evm.callWithBytecodeOverride(params, &guarded));
    try std.testing.expectEqual(1, inside);

    // Write one into the same numbered slot in both namespaces. Deliberately
    // leave the transient slot set to observe the transaction boundary.
    const temporary = evm.callWithBytecodeOverride(params, &.{ 0x60, 1, 0x5f, 0x5d, 0 });
    const persistent = evm.callWithBytecodeOverride(params, &.{ 0x60, 1, 0x5f, 0x55, 0 });
    try ex.requireSuccess(temporary);
    try ex.requireSuccess(persistent);
    const ret = [_]u8{ 0x5f, 0x52, 0x60, 32, 0x5f, 0xf3 };
    const t = try ex.outputWord(evm.callWithBytecodeOverride(params, &([_]u8{ 0x5f, 0x5c } ++ ret)));
    const s = try ex.outputWord(evm.callWithBytecodeOverride(params, &([_]u8{ 0x5f, 0x54 } ++ ret)));
    try std.testing.expectEqual(0, t);
    try std.testing.expectEqual(1, s);
    try out.print("inside guard={d}\nTSTORE gas={d}; SSTORE gas={d}\nlater TLOAD={d}; SLOAD={d}\n", .{
        inside, temporary.gasConsumed(ex.gas), persistent.gasConsumed(ex.gas), t, s,
    });
}
