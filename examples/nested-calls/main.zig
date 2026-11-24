const std = @import("std");
const ex = @import("../common.zig");

// CALL with empty buffers, forwarding this frame's value to a two-byte address.
fn forward(comptime address: u16) [10]u8 {
    return .{ 0x5f, 0x5f, 0x5f, 0x5f, 0x34, 0x61, @intCast(address >> 8), @truncate(address), 0x5a, 0xf1 };
}

pub fn run(allocator: std.mem.Allocator, out: *std.Io.Writer) !void {
    var state = ex.mini.StateOverlayHost.init(allocator, null);
    defer state.deinit();
    const b = ex.Address.fromU256(0x300);
    const c = ex.Address.fromU256(0x400);
    state.setBalance(ex.alice, 10);
    // A returns B's CALL success bit. B jumps to STOP on success and otherwise reverts.
    state.setCode(ex.contract, &(forward(0x300) ++ [_]u8{ 0x5f, 0x52, 0x60, 32, 0x5f, 0xf3 }));
    state.setCode(b, &(forward(0x400) ++ [_]u8{ 0x60, 16, 0x57, 0x5f, 0x5f, 0xfd, 0x5b, 0x00 }));
    var tracer = ex.mini.CallTracer.init(allocator, .{});
    defer tracer.deinit();
    var evm: ex.Evm = undefined;
    try evm.init(allocator, state.host(), .CANCUN, null, ex.alice, 0, null);
    defer evm.deinit();
    evm.setInspector(tracer.inspector());

    var params = ex.message(ex.contract);
    params.call.value = 1;
    for ([_][]const u8{ &.{0x00}, &.{ 0x5f, 0x5f, 0xfd } }, 0..) |leaf, i| {
        state.setCode(c, leaf);
        const ok = try ex.outputWord(evm.call(params));
        try std.testing.expectEqual(@intFromBool(i == 0), ok);
        if (tracer.err) |err| return err;
        const root = tracer.root() orelse return error.MissingRoot;
        try std.testing.expectEqual(1, root.calls.items.len);
        const middle = root.calls.items[0];
        try std.testing.expectEqual(1, middle.calls.items.len);
        const child = middle.calls.items[0];
        try std.testing.expectEqual(b, child.from);
        try std.testing.expectEqual(c, child.to);
        try std.testing.expectEqual(1, child.value);
        try std.testing.expectEqual(i == 1, middle.reverted);
        try std.testing.expectEqual(i == 1, child.reverted);
        try out.print("A -> B -> C: leaf depth=2 caller=0x{x} value={d} reverted={} A returned {d}\n", .{
            std.mem.readInt(u160, &child.from.bytes, .big), child.value, child.reverted, ok,
        });
    }
}
