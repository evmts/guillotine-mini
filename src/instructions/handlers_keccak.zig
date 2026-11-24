/// Keccak256 (SHA3) opcode handler for the EVM
const std = @import("std");
const primitives = @import("voltaire");
const GasConstants = primitives.GasConstants;

/// Helper function to calculate word count (needed for gas calculation)
inline fn wordCount(bytes: u64) u64 {
    return (bytes + 31) / 32;
}

/// Calculate KECCAK256 gas cost
fn keccak256GasCost(data_size: u32) u64 {
    const words = wordCount(@as(u64, data_size));
    return GasConstants.Keccak256Gas + words * GasConstants.Keccak256WordGas;
}

/// Handlers struct - provides keccak256 operation handler for a Frame type
/// The FrameType must have methods: consumeGas, popStack, pushStack, readMemory, memoryExpansionCost
/// and fields: pc, memory_size, allocator
pub fn Handlers(FrameType: type) type {
    return struct {
        /// SHA3/KECCAK256 opcode (0x20) - Compute Keccak-256 hash
        pub fn sha3(frame: *FrameType) FrameType.EvmError!void {
            const offset = try frame.popStack();
            const size = try frame.popStack();

            // Zero-length input charges no expansion and ignores the offset.
            const range = try frame.memoryRange(offset, size);
            const size_u32: u32 = if (range) |r| r.len else 0;
            try frame.consumeGas(keccak256GasCost(size_u32) +| frame.memoryRangeCost(range));

            var hash_bytes: [32]u8 = undefined;
            if (range) |r| {
                try frame.expandMemory(r.end);
                const data = try frame.readMemoryAlloc(frame.allocator, r);
                defer frame.allocator.free(data);
                std.crypto.hash.sha3.Keccak256.hash(data, &hash_bytes, .{});
            } else {
                std.crypto.hash.sha3.Keccak256.hash(&[_]u8{}, &hash_bytes, .{});
            }
            try frame.pushStack(std.mem.readInt(u256, &hash_bytes, .big));
            frame.pc += 1;
        }
    };
}
