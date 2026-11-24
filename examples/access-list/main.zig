const std = @import("std");
const ex = @import("../common.zig");

pub fn run(allocator: std.mem.Allocator, out: *std.Io.Writer) !void {
    var evm: ex.Evm = undefined;
    try evm.init(allocator, null, .BERLIN, null, ex.alice, 0, null);
    defer evm.deinit();

    // At the low-level API, the first access warms that account or slot.
    try evm.initTransactionState(null);
    const address_cold = try evm.accessAddress(ex.contract);
    const address_warm = try evm.accessAddress(ex.contract);
    const slot_cold = try evm.accessStorageSlot(ex.contract, 0);
    const slot_warm = try evm.accessStorageSlot(ex.contract, 0);
    try out.print("address={d}/{d} slot={d}/{d}\n", .{ address_cold, address_warm, slot_cold, slot_warm });

    // Each call starts a fresh transaction. Compare identical zero-valued slots.
    // SLOAD and no-op SSTORE need separate runs so one cannot warm the other.
    const slots = [_][32]u8{@splat(0)};
    for ([_][]const u8{ &.{ 0x60, 0, 0x54, 0 }, &.{ 0x60, 0, 0x60, 0, 0x55, 0 } }, [_][]const u8{ "SLOAD", "SSTORE" }) |code, name| {
        evm.setAccessList(null);
        const cold = evm.callWithBytecodeOverride(ex.message(ex.contract), code);
        evm.setAccessList(&.{.{ .address = ex.contract, .storage_keys = &slots }});
        const warm = evm.callWithBytecodeOverride(ex.message(ex.contract), code);
        try ex.requireSuccess(cold);
        try ex.requireSuccess(warm);
        try std.testing.expect(warm.gas_left > cold.gas_left);
        try out.print("{s} cold={d} listed={d}\n", .{ name, cold.gasConsumed(ex.gas), warm.gasConsumed(ex.gas) });
    }
}
