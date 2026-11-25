/// Memory opcode handlers for the EVM
const std = @import("std");
const HandlerConfig = @import("frame_interface.zig").HandlerConfig;
const primitives = @import("voltaire");
const GasConstants = primitives.GasConstants;

/// Helper function to calculate word-aligned size
fn wordAlignedSize(byte_size: u64) u64 {
    return ((byte_size + 31) / 32) * 32;
}

/// Helper function to calculate copy gas cost (3 gas per word)
fn copyGasCost(size_bytes: u32) u64 {
    const words = (@as(u64, size_bytes) + 31) / 32;
    return words * GasConstants.CopyGas;
}

/// Handlers struct - provides memory operation handlers for a Frame type
/// The FrameType must have methods: consumeGas, popStack, pushStack, getEvm, memoryRange,
/// memoryRangeCost, memoryExpansionCost, expandMemory, readMemoryWord, writeMemoryWord,
/// writeMemory, copyMemory, and field: pc, memory_size
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

        /// MLOAD opcode (0x51) - Load word from memory
        pub fn mload(frame: *FrameType) FrameType.EvmError!void {
            const offset = try frame.popStack();
            // An offset past the u32 memory model is an exceptional halt (OutOfGas, gas burned).
            const range = (try frame.memoryRange(offset, 32)).?;
            try charge(frame, GasConstants.GasFastestStep +| frame.memoryRangeCost(range));
            try frame.expandMemory(range.end);

            const result = try frame.readMemoryWord(range.offset);
            try frame.pushStack(result);
            frame.pc += 1;
        }

        /// MSTORE opcode (0x52) - Save word to memory
        pub fn mstore(frame: *FrameType) FrameType.EvmError!void {
            const offset = try frame.popStack();
            const value = try frame.popStack();
            const range = (try frame.memoryRange(offset, 32)).?;
            try charge(frame, GasConstants.GasFastestStep +| frame.memoryRangeCost(range));

            try frame.writeMemoryWord(range.offset, value);
            frame.pc += 1;
        }

        /// MSTORE8 opcode (0x53) - Save byte to memory
        pub fn mstore8(frame: *FrameType) FrameType.EvmError!void {
            const offset = try frame.popStack();
            const value = try frame.popStack();
            const range = (try frame.memoryRange(offset, 1)).?;
            try charge(frame, GasConstants.GasFastestStep +| frame.memoryRangeCost(range));

            try frame.writeMemory(range.offset, @truncate(value));
            frame.pc += 1;
        }

        /// MSIZE opcode (0x59) - Get size of active memory in bytes
        pub fn msize(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasQuickStep);
            // Memory size is already tracked as word-aligned in memory_size field
            try frame.pushStack(frame.memory_size);
            frame.pc += 1;
        }

        /// MCOPY opcode (0x5e) - Copy memory (EIP-5656, Cancun+)
        pub fn mcopy(frame: *FrameType) FrameType.EvmError!void {
            const evm = frame.getEvm();
            // EIP-5656: MCOPY was introduced in Cancun hardfork
            if (evm.hardfork.isBefore(.CANCUN)) return error.InvalidOpcode;

            // Stack order (top to bottom): dest, src, len
            const dest = try frame.popStack();
            const src = try frame.popStack();
            const len = try frame.popStack();

            // EIP-5656: a zero-length copy expands nothing, whatever src/dest are.
            // Otherwise memory must cover BOTH src+len and dest+len.
            const dest_range = try frame.memoryRange(dest, len);
            const src_range = try frame.memoryRange(src, len);
            const max_end: u64 = @max(
                if (dest_range) |r| r.end else 0,
                if (src_range) |r| r.end else 0,
            );
            const mem_cost: u64 = if (max_end > 0) frame.memoryExpansionCost(max_end) else 0;
            const len_u32: u32 = if (dest_range) |r| r.len else 0;
            try charge(frame, GasConstants.GasFastestStep +| mem_cost +| copyGasCost(len_u32));

            if (dest_range) |d| {
                const s = src_range.?;
                try frame.expandMemory(max_end);
                // In-place overlap-safe copy with zero heap allocations
                try frame.copyMemory(d.offset, s.offset, d.len);
            }

            frame.pc += 1;
        }
    };
}
