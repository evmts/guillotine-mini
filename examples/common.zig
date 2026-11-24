const std = @import("std");
pub const mini = @import("guillotine_mini");
pub const Address = @import("voltaire").Address;
pub const Evm = mini.Evm(.{});
pub const alice = Address.fromU256(0x100);
pub const contract = Address.fromU256(0x200);
pub const gas: u64 = 100_000;

pub fn message(to: Address) Evm.CallParams {
    return .{ .call = .{ .caller = alice, .to = to, .value = 0, .input = &.{}, .gas = gas } };
}

pub fn requireSuccess(result: Evm.CallResult) !void {
    if (!result.isSuccess()) {
        std.log.err("EVM call failed: {s} (output 0x{x})", .{ result.error_info orelse "REVERT", result.output });
        return error.CallFailed;
    }
}

pub fn outputWord(result: Evm.CallResult) !u256 {
    try requireSuccess(result);
    if (result.output.len != 32) return error.ExpectedWord;
    return std.mem.readInt(u256, result.output[0..32], .big);
}
