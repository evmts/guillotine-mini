const std = @import("std");
const ex = @import("../common.zig");
const Store = @import("custom-host.zig");

pub fn run(allocator: std.mem.Allocator, out: *std.Io.Writer) !void {
    var store = Store.init(allocator);
    defer store.deinit();
    const host = store.host();
    // Load slot zero, increment it, and store the result.
    host.setCode(ex.contract, &.{ 0x5f, 0x54, 0x60, 1, 0x01, 0x5f, 0x55, 0x00 });
    host.setStorage(ex.contract, 0, 40);
    if (store.err) |err| return err;

    var evm: ex.Evm = undefined;
    try evm.init(allocator, host, .CANCUN, null, ex.alice, 0, null);
    defer evm.deinit();
    try ex.requireSuccess(evm.call(ex.message(ex.contract)));
    if (store.err) |err| return err;
    try std.testing.expectEqual(41, host.getStorage(ex.contract, 0));

    // A second EVM can simulate against the same backend with an isolated overlay.
    var overlay = ex.mini.StateOverlayHost.init(allocator, host);
    defer overlay.deinit();
    var simulation: ex.Evm = undefined;
    try simulation.init(allocator, overlay.host(), .CANCUN, null, ex.alice, 0, null);
    defer simulation.deinit();
    try ex.requireSuccess(simulation.call(ex.message(ex.contract)));
    if (overlay.err) |err| return err;
    try std.testing.expectEqual(41, host.getStorage(ex.contract, 0));
    try std.testing.expectEqual(42, overlay.getStorage(ex.contract, 0));
    try out.print("initial=40 committed={d} simulated={d}\n", .{ host.getStorage(ex.contract, 0), overlay.getStorage(ex.contract, 0) });
}
