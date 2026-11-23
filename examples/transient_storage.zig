//! Use transient storage within one transaction and check that the next starts empty.
const std = @import("std");
const mini = @import("guillotine_mini");
const primitives = @import("voltaire");

const Evm = mini.Evm(.{});
const caller = primitives.Address.fromU256(0x1000);
const contract = primitives.Address.fromU256(0x2000);

const bytecode = [_]u8{
    0x36, // CALLDATASIZE
    0x60, 0x09, // PUSH1 read
    0x57, // JUMPI (skip TSTORE when calldata is nonempty)
    0x60, 0x2a, // PUSH1 42
    0x60, 0x00, // PUSH1 0
    0x5d, // TSTORE
    0x5b, // JUMPDEST (read)
    0x60, 0x00, // PUSH1 0
    0x5c, // TLOAD
    0x60, 0x00, // PUSH1 0
    0x52, // MSTORE
    0x60, 0x20, // PUSH1 32
    0x60, 0x00, // PUSH1 0
    0xf3, // RETURN
};

fn readSlot(evm: *Evm, input: []const u8) !u256 {
    // Supply the same contract code for each top-level transaction.
    try evm.code.put(contract, &bytecode);
    const result = evm.call(.{ .call = .{
        .caller = caller,
        .to = contract,
        .value = 0,
        .input = input,
        .gas = 100_000,
    } });
    if (!result.isSuccess()) return error.CallFailed;
    if (result.output.len != 32) return error.UnexpectedOutput;
    return std.mem.readInt(u256, result.output[0..32], .big);
}

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer std.debug.assert(gpa.deinit() == .ok);

    var evm: Evm = undefined;
    try evm.init(gpa.allocator(), null, .CANCUN, null, caller, 0, null);
    defer evm.deinit();

    const written = try readSlot(&evm, &.{});
    const next_transaction = try readSlot(&evm, &.{1});
    if (written != 42 or next_transaction != 0) return error.UnexpectedTransientValue;

    std.debug.print("TSTORE then TLOAD: {d}\nTLOAD in the next transaction: {d}\n", .{ written, next_transaction });
}
