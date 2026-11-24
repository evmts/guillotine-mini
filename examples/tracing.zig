//! Capture opcode steps and optionally export the trace as JSON.
const std = @import("std");
const mini = @import("guillotine_mini");
const primitives = @import("voltaire");

const bytecode = [_]u8{
    0x60, 0x2a, // PUSH1 42
    0x60, 0x00, // PUSH1 0
    0x52, // MSTORE
    0x60, 0x20, // PUSH1 32
    0x60, 0x00, // PUSH1 0
    0xf3, // RETURN
};

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    if (args.len > 2) return error.ExpectedOneOutputPath;

    var tracer = mini.Tracer.init(allocator);
    defer tracer.deinit();
    tracer.config.enable_memory = true;
    tracer.enable();

    const caller = primitives.Address.fromU256(0x1000);
    const contract = primitives.Address.fromU256(0x2000);
    var evm: mini.Evm(.{}) = undefined;
    try evm.init(allocator, null, .CANCUN, null, caller, 0, null);
    defer evm.deinit();
    evm.setTracer(&tracer);
    try evm.code.put(contract, &bytecode);

    const result = evm.call(.{ .call = .{
        .caller = caller,
        .to = contract,
        .value = 0,
        .input = &.{},
        .gas = 100_000,
    } });
    if (!result.isSuccess()) return error.CallFailed;
    if (tracer.entries.items.len != 6) return error.UnexpectedTraceLength;

    for (tracer.entries.items) |entry| {
        std.debug.print("pc={d} {s} gas={d} cost={d} stack={any} memory={d} bytes\n", .{
            entry.pc,
            entry.opName,
            entry.gas,
            entry.gasCost,
            entry.stack,
            entry.memSize,
        });
    }
    if (args.len == 2) {
        try tracer.writeToFile(args[1]);
        std.debug.print("Wrote trace to {s}\n", .{args[1]});
    }
}
