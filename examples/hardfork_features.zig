//! Run the same programs on four forks to check PUSH0 and MCOPY activation.
const std = @import("std");
const mini = @import("guillotine_mini");
const primitives = @import("voltaire");

const Evm = mini.Evm(.{});
const caller = primitives.Address.fromU256(0x1000);
const contract = primitives.Address.fromU256(0x2000);

const push0_program = [_]u8{
    0x5f, // PUSH0
    0x00, // STOP
};

const mcopy_program = [_]u8{
    0x60, 0x2a, // PUSH1 42
    0x60, 0x00, // PUSH1 0
    0x52, // MSTORE
    0x60, 0x20, // PUSH1 32 (length)
    0x60, 0x00, // PUSH1 0 (source)
    0x60, 0x20, // PUSH1 32 (destination)
    0x5e, // MCOPY
    0x60, 0x20, // PUSH1 32 (length)
    0x60, 0x20, // PUSH1 32 (offset)
    0xf3, // RETURN
};

fn execute(evm: *Evm, bytecode: []const u8) !Evm.CallResult {
    try evm.code.put(contract, bytecode);
    return evm.call(.{ .call = .{
        .caller = caller,
        .to = contract,
        .value = 0,
        .input = &.{},
        .gas = 100_000,
    } });
}

fn checkActivation(result: Evm.CallResult, supported: bool) !void {
    if (result.isSuccess() != supported) return error.UnexpectedOpcodeSupport;
    if (!supported and !std.mem.eql(u8, result.error_info orelse "", "InvalidOpcode")) {
        return error.UnexpectedExecutionError;
    }
}

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer std.debug.assert(gpa.deinit() == .ok);

    const forks = [_]mini.Hardfork{ .BERLIN, .LONDON, .SHANGHAI, .CANCUN };
    for (forks) |fork| {
        var evm: Evm = undefined;
        try evm.init(gpa.allocator(), null, fork, null, caller, 0, null);
        defer evm.deinit();

        const push0 = try execute(&evm, &push0_program);
        try checkActivation(push0, fork == .SHANGHAI or fork == .CANCUN);
        const mcopy = try execute(&evm, &mcopy_program);
        try checkActivation(mcopy, fork == .CANCUN);
        if (mcopy.isSuccess()) {
            if (mcopy.output.len != 32) return error.UnexpectedOutput;
            if (std.mem.readInt(u256, mcopy.output[0..32], .big) != 42) return error.UnexpectedOutput;
        }

        std.debug.print("{s}: PUSH0 {s}, MCOPY {s}\n", .{
            @tagName(fork),
            if (push0.isSuccess()) "enabled" else "invalid",
            if (mcopy.isSuccess()) "enabled" else "invalid",
        });
    }
}
