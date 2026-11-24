/// Memory opcode handlers for the EVM
const std = @import("std");
const primitives = @import("voltaire");
const GasConstants = primitives.GasConstants;

/// Helper function for u32 addition with overflow check
fn add_u32(a: u32, b: u32) error{OutOfBounds}!u32 {
    return std.math.add(u32, a, b) catch error.OutOfBounds;
}

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
/// The FrameType must have methods: consumeGas, popStack, pushStack, readMemory, writeMemory,
/// memoryExpansionCost, and fields: pc, memory_size, allocator, address, is_static
pub fn Handlers(FrameType: type) type {
    return struct {
        /// MLOAD opcode (0x51) - Load word from memory
        pub fn mload(frame: *FrameType) FrameType.EvmError!void {
            const offset = try frame.popStack();
            const off = std.math.cast(u32, offset) orelse return error.OutOfBounds;

            // Charge base + memory expansion for reading 32 bytes
            const end_bytes: u64 = @as(u64, off) + 32;
            const mem_cost = frame.memoryExpansionCost(end_bytes);
            try frame.consumeGas(GasConstants.GasFastestStep + mem_cost);
            const aligned_size = wordAlignedSize(end_bytes);
            const aligned_size_u32 = std.math.cast(u32, aligned_size) orelse return error.OutOfBounds;
            if (aligned_size_u32 > frame.memory_size) frame.memory_size = aligned_size_u32;

            // Read word from memory
            var result: u256 = 0;
            var idx: u32 = 0;
            while (idx < 32) : (idx += 1) {
                const addr = try add_u32(off, idx);
                const byte = frame.readMemory(addr);
                result = (result << 8) | byte;
            }
            try frame.pushStack(result);
            frame.pc += 1;
        }

        /// MSTORE opcode (0x52) - Save word to memory
        pub fn mstore(frame: *FrameType) FrameType.EvmError!void {
            const offset = try frame.popStack();
            const value = try frame.popStack();

            const off = std.math.cast(u32, offset) orelse return error.OutOfBounds;

            // Charge base + memory expansion for writing 32 bytes
            const end_bytes: u64 = @as(u64, off) + 32;
            const mem_cost = frame.memoryExpansionCost(end_bytes);
            try frame.consumeGas(GasConstants.GasFastestStep + mem_cost);

            // Update memory size after charging expansion (spec-compliant)
            const aligned_size = wordAlignedSize(end_bytes);
            const aligned_size_u32 = std.math.cast(u32, aligned_size) orelse return error.OutOfBounds;
            if (aligned_size_u32 > frame.memory_size) frame.memory_size = aligned_size_u32;

            // Write word to memory
            var idx: u32 = 0;
            while (idx < 32) : (idx += 1) {
                const byte = @as(u8, @truncate(value >> @intCast((31 - idx) * 8)));
                const addr = try add_u32(off, idx);
                try frame.writeMemory(addr, byte);
            }
            frame.pc += 1;
        }

        /// MSTORE8 opcode (0x53) - Save byte to memory
        pub fn mstore8(frame: *FrameType) FrameType.EvmError!void {
            const offset = try frame.popStack();
            const value = try frame.popStack();

            const off = std.math.cast(u32, offset) orelse return error.OutOfBounds;
            const end_bytes: u64 = @as(u64, off) + 1;
            const mem_cost = frame.memoryExpansionCost(end_bytes);
            try frame.consumeGas(GasConstants.GasFastestStep + mem_cost);

            // Update memory size after charging expansion
            const aligned_size = wordAlignedSize(end_bytes);
            const aligned_size_u32 = std.math.cast(u32, aligned_size) orelse return error.OutOfBounds;
            if (aligned_size_u32 > frame.memory_size) frame.memory_size = aligned_size_u32;
            const byte_value = @as(u8, @truncate(value));
            try frame.writeMemory(off, byte_value);
            frame.pc += 1;
        }

        /// MSIZE opcode (0x59) - Get size of active memory in bytes
        pub fn msize(frame: *FrameType) FrameType.EvmError!void {
            try frame.consumeGas(GasConstants.GasQuickStep);
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
            try frame.consumeGas(GasConstants.GasFastestStep +| mem_cost +| copyGasCost(len_u32));

            if (dest_range) |d| {
                const s_range = src_range.?;
                try frame.expandMemory(max_end);
                // Copy via temporary buffer to handle overlapping regions
                const tmp = try frame.readMemoryAlloc(frame.allocator, s_range);
                defer frame.allocator.free(tmp);
                try frame.writeMemorySlice(d.offset, tmp);
            }

            frame.pc += 1;
        }
    };
}
