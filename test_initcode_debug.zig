const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Simulate the single_byte_exact_intrinsic_gas test
    const sender_addr_str = "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b";
    const contract_addr_str = "0x6295ee1b4f6dd65047762f924ecd367c17eabf8f";

    std.debug.print("=== Test: single_byte_exact_intrinsic_gas ===\n", .{});
    std.debug.print("Sender: {s} (nonce 0)\n", .{sender_addr_str});
    std.debug.print("Expected contract: {s} (nonce should be 1)\n", .{contract_addr_str});

    std.debug.print("\n=== Transaction ===\n", .{});
    std.debug.print("To: null (CREATE)\n", .{});
    std.debug.print("Data: 0x00 (1 byte, STOP opcode)\n", .{});
    std.debug.print("Gas Limit: 1197806\n", .{});
    std.debug.print("Gas Price: 10\n", .{});

    std.debug.print("\n=== Gas Calculation ===\n", .{});
    std.debug.print("Intrinsic gas:\n", .{});
    std.debug.print("  Base (create): 53000\n", .{});
    std.debug.print("  Data (1 zero byte): 4\n", .{});
    std.debug.print("  EIP-3860 initcode: ceil(1/32) * 2 = 1 * 2 = 2\n", .{});
    std.debug.print("  Total intrinsic: 53006\n", .{});
    std.debug.print("Execution gas: 1197806 - 53006 = 1144800\n", .{});

    std.debug.print("\n=== Expected Behavior ===\n", .{});
    std.debug.print("1. Charge sender for full gas limit upfront\n", .{});
    std.debug.print("2. Increment sender nonce: 0 -> 1\n", .{});
    std.debug.print("3. Call inner_create with initcode=0x00, gas=1144800\n", .{});
    std.debug.print("4. inner_create:\n", .{});
    std.debug.print("   a. Calculate contract address from sender+nonce\n", .{});
    std.debug.print("   b. Check collision (none)\n", .{});
    std.debug.print("   c. Increment sender nonce: 1 -> 2\n", .{});
    std.debug.print("   d. Set contract nonce: 0 -> 1\n", .{});
    std.debug.print("   e. Execute initcode (STOP)\n", .{});
    std.debug.print("   f. STOP returns empty output\n", .{});
    std.debug.print("   g. No code to deploy, no deposit cost\n", .{});
    std.debug.print("   h. Success! Return gas_left\n", .{});

    std.debug.print("\n=== ISSUE IDENTIFIED ===\n", .{});
    std.debug.print("The problem is in step 4c!\n", .{});
    std.debug.print("inner_create increments the SENDER's nonce again!\n", .{});
    std.debug.print("But the sender's nonce was already incremented in step 2!\n", .{});
    std.debug.print("\nFor CREATE opcodes, the CALLER nonce should be incremented.\n", .{});
    std.debug.print("But for top-level CREATE transactions, the sender nonce is incremented BEFORE calling inner_create.\n", .{});
    std.debug.print("So inner_create should NOT increment the sender nonce again for top-level creates!\n", .{});

    _ = allocator;
}
