const std = @import("std");
const ex = @import("../common.zig");

pub fn run(allocator: std.mem.Allocator, out: *std.Io.Writer) !void {
    var state = ex.mini.StateOverlayHost.init(allocator, null);
    defer state.deinit();
    state.setBalance(ex.alice, 100);
    // PUSH1 40, PUSH1 2, ADD, MSTORE at offset 0, RETURN 32 bytes.
    state.setCode(ex.contract, &.{ 0x60, 40, 0x60, 2, 0x01, 0x5f, 0x52, 0x60, 32, 0x5f, 0xf3 });

    var evm: ex.Evm = undefined;
    try evm.init(allocator, state.host(), .CANCUN, null, ex.alice, 0, null);
    defer evm.deinit();
    const params: ex.Evm.CallParams = .{ .call = .{
        .caller = ex.alice,
        .to = ex.contract,
        .value = 7,
        .input = &.{},
        .gas = ex.gas,
    } };
    try params.validate();
    const result = evm.call(params);
    const word = try ex.outputWord(result);
    try std.testing.expectEqual(42, word);
    try std.testing.expectEqual(93, state.getBalance(ex.alice));
    try std.testing.expectEqual(7, state.getBalance(ex.contract));
    try out.print("output={d} gas_used={d} balances={d}/{d}\n", .{
        word, result.gasConsumed(ex.gas), state.getBalance(ex.alice), state.getBalance(ex.contract),
    });

    // An exceptional halt consumes the message gas and rolls back the transfer.
    var too_small = params;
    too_small.setGas(1);
    const failed = evm.call(too_small);
    try std.testing.expect(failed.isFailure());
    const reason = failed.error_info orelse return error.ExpectedError;
    try std.testing.expectEqualStrings("OutOfGas", reason);
    try std.testing.expectEqual(7, state.getBalance(ex.contract));
    try out.print("failure={s}\n", .{reason});
}
