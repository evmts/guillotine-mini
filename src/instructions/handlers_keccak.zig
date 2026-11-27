/// Keccak256 (SHA3) opcode handler for the EVM
const std = @import("std");
const HandlerConfig = @import("frame_interface.zig").HandlerConfig;
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
/// The FrameType must have methods: consumeGas, popStack, pushStack, memoryRange,
/// memoryRangeCost, expandMemory, readMemorySlice
/// and field: pc
pub fn Handlers(FrameType: type) type {
    return HandlersWithConfig(FrameType, .{});
}

/// `Handlers` with comptime `HandlerConfig`. `.charge_gas = false` removes every
/// `consumeGas` call so callers can meter gas themselves.
pub fn HandlersWithConfig(FrameType: type, comptime config: HandlerConfig) type {
    return struct {
        inline fn charge(frame: *FrameType, amount: u64) FrameType.EvmError!void {
            if (config.charge_gas) try frame.consumeGas(amount);
        }

        /// SHA3/KECCAK256 opcode (0x20) - Compute Keccak-256 hash
        pub fn sha3(frame: *FrameType) FrameType.EvmError!void {
            const offset = try frame.popStack();
            const size = try frame.popStack();

            // Zero-length input charges no expansion and ignores the offset.
            const range = try frame.memoryRange(offset, size);
            const size_u32: u32 = if (range) |r| r.len else 0;
            try charge(frame, keccak256GasCost(size_u32) +| frame.memoryRangeCost(range));

            if (range) |r| {
                try frame.expandMemory(r.end);
                // Zero-copy slice directly from contiguous EVM memory
                const data = try frame.readMemorySlice(r.offset, r.len);
                const hash_bytes = primitives.Hash.keccak256(data);
                try frame.pushStack(std.mem.readInt(u256, &hash_bytes, .big));
            } else {
                const empty_keccak: u256 = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
                try frame.pushStack(empty_keccak);
            }
            frame.pc += 1;
        }
    };
}
