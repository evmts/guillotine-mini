//! Execute a contract call and read its ABI-encoded return value.
const std = @import("std");
const mini = @import("guillotine_mini");
const primitives = @import("voltaire");

const Evm = mini.Evm(.{});
const bytecode = [_]u8{
    0x60, 0x00, // PUSH1 0
    0x35, // CALLDATALOAD
    0x60, 0x01, // PUSH1 1
    0x01, // ADD
    0x60, 0x00, // PUSH1 0
    0x52, // MSTORE
    0x60, 0x20, // PUSH1 32
    0x60, 0x00, // PUSH1 0
    0xf3, // RETURN
};

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer std.debug.assert(gpa.deinit() == .ok);

    const caller = primitives.Address.fromU256(0x1000);
    const contract = primitives.Address.fromU256(0x2000);
    var evm: Evm = undefined;
    try evm.init(gpa.allocator(), null, .CANCUN, null, caller, 0, null);
    defer evm.deinit();

    // Without a host, install the contract code in the EVM's in-memory state.
    try evm.code.put(contract, &bytecode);

    var input: [32]u8 = undefined;
    std.mem.writeInt(u256, &input, 41, .big);
    const params: Evm.CallParams = .{ .call = .{
        .caller = caller,
        .to = contract,
        .value = 0,
        .input = &input,
        .gas = 100_000,
    } };
    const result = evm.call(params);
    if (!result.isSuccess()) {
        std.debug.print("Call failed ({s})\n", .{result.error_info orelse "execution reverted"});
        return error.CallFailed;
    }

    // The EVM owns the output buffer. Decode it before evm.deinit().
    if (result.output.len != 32) return error.UnexpectedOutput;
    const value = std.mem.readInt(u256, result.output[0..32], .big);
    if (value != 42) return error.UnexpectedOutput;

    std.debug.print("Returned {d} using {d} execution gas\n", .{ value, result.gasConsumed(params.getGas()) });
}
