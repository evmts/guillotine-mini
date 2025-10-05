const std = @import("std");
const guillotine = @import("guillotine");
const primitives = @import("primitives");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("=== EIP-3155 Trace Capture Test ===\n\n", .{});

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

    std.debug.print("Executing bytecode: PUSH1 1, PUSH1 2, ADD, STOP\n", .{});

    // Execute
    const result = try evm.call(
        &bytecode,
        1_000_000, // 1M gas
        primitives.ZERO_ADDRESS, // caller
        primitives.ZERO_ADDRESS, // address
        0, // value
        &[_]u8{}, // calldata
        null, // no access list
    );

    std.debug.print("\nExecution result:\n", .{});
    std.debug.print("  Success: {}\n", .{result.success});
    std.debug.print("  Gas left: {}\n", .{result.gas_left});
    std.debug.print("  Captured {} trace entries\n\n", .{tracer.entries.items.len});

    // Print trace entries
    std.debug.print("Trace entries:\n", .{});
    for (tracer.entries.items, 0..) |entry, i| {
        std.debug.print("  [{d}] PC={d} OP=0x{x:0>2} ({s}) Gas=0x{x} GasCost=0x{x} Stack=[", .{
            i,
            entry.pc,
            entry.op,
            entry.opName,
            entry.gas,
            entry.gasCost,
        });
        for (entry.stack, 0..) |val, j| {
            if (j > 0) std.debug.print(", ", .{});
            std.debug.print("0x{x}", .{val});
        }
        std.debug.print("]\n", .{});
    }

    // Save trace to JSON file
    std.debug.print("\nSaving trace to trace_test.json...\n", .{});
    try tracer.writeToFile("trace_test.json");
    std.debug.print("Done!\n", .{});
}
