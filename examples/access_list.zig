//! Measure the effect of pre-warming an account and a storage slot.
const std = @import("std");
const mini = @import("guillotine_mini");
const primitives = @import("voltaire");

const Evm = mini.Evm(.{});
const caller = primitives.Address.fromU256(0x1000);
const contract = primitives.Address.fromU256(0x2000);
const external_account = primitives.Address.fromU256(0x3000);

const bytecode = [_]u8{
    0x61, 0x30, 0x00, // PUSH2 0x3000
    0x3b, // EXTCODESIZE
    0x50, // POP
    0x60, 0x00, // PUSH1 0
    0x54, // SLOAD
    0x50, // POP
    0x00, // STOP
};

fn gasUsed(evm: *Evm, access_list: ?primitives.AccessList.AccessList) !u64 {
    try evm.code.put(contract, &bytecode);
    evm.setAccessList(access_list);
    const gas_limit = 100_000;
    const result = evm.call(.{ .call = .{
        .caller = caller,
        .to = contract,
        .value = 0,
        .input = &.{},
        .gas = gas_limit,
    } });
    if (!result.isSuccess()) return error.CallFailed;
    return result.gasConsumed(gas_limit);
}

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer std.debug.assert(gpa.deinit() == .ok);

    var evm: Evm = undefined;
    try evm.init(gpa.allocator(), null, .BERLIN, null, caller, 0, null);
    defer evm.deinit();

    const slot_zero: [32]u8 = @splat(0);
    const access_list: primitives.AccessList.AccessList = &.{
        .{ .address = contract, .storage_keys = &.{slot_zero} },
        .{ .address = external_account, .storage_keys = &.{} },
    };

    const cold = try gasUsed(&evm, null);
    const warm = try gasUsed(&evm, access_list);
    const intrinsic = primitives.AccessList.calculateAccessListGasCost(access_list);

    // EIP-2929 charges 2,600 vs 100 for the account and 2,100 vs 100 for the slot.
    if (cold != warm + 4_500) return error.UnexpectedGas;
    std.debug.print("Cold execution: {d} gas\nWarm execution: {d} gas\n", .{ cold, warm });
    std.debug.print("EIP-2930 intrinsic surcharge: {d} gas\n", .{intrinsic});
}
