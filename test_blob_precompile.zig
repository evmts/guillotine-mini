const std = @import("std");
const precompiles = @import("src/precompiles/precompiles.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("Testing KZG point evaluation precompile...\n", .{});

    // Test 1: Wrong input length (should return gas_used = 0, success = false)
    {
        const input = [_]u8{0} ** 100; // Wrong length
        const result = try precompiles.execute_point_evaluation(allocator, &input, 100000);
        defer if (result.output.len > 0) allocator.free(result.output);

        std.debug.print("Test 1 (wrong length): gas_used={}, success={}\n", .{result.gas_used, result.success});
        if (result.gas_used != 0 or result.success != false) {
            std.debug.print("FAIL: Expected gas_used=0, success=false for wrong input length\n", .{});
            return error.TestFailed;
        }
    }

    // Test 2: Correct input length but invalid data
    {
        const input = [_]u8{0} ** 192; // Correct length, all zeros
        const result = try precompiles.execute_point_evaluation(allocator, &input, 100000);
        defer if (result.output.len > 0) allocator.free(result.output);

        std.debug.print("Test 2 (invalid data): gas_used={}, success={}\n", .{result.gas_used, result.success});
        // Should charge gas and return failure (versioned hash won't match)
    }

    std.debug.print("All tests completed!\n", .{});
}
