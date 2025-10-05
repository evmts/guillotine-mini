const std = @import("std");
const guillotine = @import("guillotine-mini");

/// Example: Capture EIP-3155 trace for a simple EVM execution
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Initialize tracer
    var tracer = guillotine.Tracer.init(allocator);
    defer tracer.deinit();
    tracer.enable();

    // Create EVM instance
    var evm = try guillotine.Evm.init(
        allocator,
        null, // No host
        null, // Default hardfork
        null, // Default block context
    );
    defer evm.deinit();

    // Set tracer
    evm.setTracer(&tracer);

    // Simple bytecode: PUSH1 0x01, PUSH1 0x02, ADD, STOP
    const bytecode = [_]u8{
        0x60, 0x01, // PUSH1 1
        0x60, 0x02, // PUSH1 2
        0x01,       // ADD
        0x00,       // STOP
    };

    // Execute
    const result = try evm.call(
        &bytecode,
        1_000_000, // 1M gas
        guillotine.primitives.ZERO_ADDRESS, // caller
        guillotine.primitives.ZERO_ADDRESS, // address
        0, // value
        &[_]u8{}, // calldata
        null, // no access list
    );

    std.debug.print("Execution result: success={}, gas_left={}\n", .{
        result.success,
        result.gas_left,
    });
    std.debug.print("Captured {} trace entries\n", .{tracer.entries.items.len});

    // Save trace to JSON file
    try tracer.writeToFile("trace_output.json");
    std.debug.print("Trace saved to trace_output.json\n", .{});
}
