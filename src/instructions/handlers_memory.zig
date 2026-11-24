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
    const words = (size_bytes + 31) / 32;
    return @as(u64, words) * 3;
}

/// Handlers struct - provides memory operation handlers for a Frame type
/// The FrameType must have methods: consumeGas, popStack, pushStack, readMemory, writeMemory,
/// memoryExpansionCost, and fields: pc, memory_size, allocator, address, is_static
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
            const off = std.math.cast(u32, offset) orelse return error.OutOfBounds;

            // Charge base + memory expansion for reading 32 bytes
            const end_bytes: u64 = @as(u64, off) + 32;
            const mem_cost = frame.memoryExpansionCost(end_bytes);
            try charge(frame, GasConstants.GasFastestStep +| mem_cost);
            const aligned_size = wordAlignedSize(end_bytes);
            const aligned_size_u32 = std.math.cast(u32, aligned_size) orelse return error.OutOfBounds;
            if (aligned_size_u32 > frame.memory_size) frame.memory_size = aligned_size_u32;

            // Read word from memory
            const result = try frame.readMemoryWord(off);
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
            try charge(frame, GasConstants.GasFastestStep +| mem_cost);

            // Update memory size after charging expansion (spec-compliant)
            const aligned_size = wordAlignedSize(end_bytes);
            const aligned_size_u32 = std.math.cast(u32, aligned_size) orelse return error.OutOfBounds;
            if (aligned_size_u32 > frame.memory_size) frame.memory_size = aligned_size_u32;

            // Write word to memory
            try frame.writeMemoryWord(off, value);
            frame.pc += 1;
        }

        /// MSTORE8 opcode (0x53) - Save byte to memory
        pub fn mstore8(frame: *FrameType) FrameType.EvmError!void {
            const offset = try frame.popStack();
            const value = try frame.popStack();

            const off = std.math.cast(u32, offset) orelse return error.OutOfBounds;
            const end_bytes: u64 = @as(u64, off) + 1;
            const mem_cost = frame.memoryExpansionCost(end_bytes);
            try charge(frame, GasConstants.GasFastestStep +| mem_cost);

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
            // Pop order: dest (first), src (second), len (third)
            const dest = try frame.popStack();
            const src = try frame.popStack();
            const len = try frame.popStack();

            // Calculate memory expansion cost BEFORE bounds checking
            // Per EIP-5656, if len == 0, no memory expansion occurs regardless of src/dest values
            // Otherwise, memory must be expanded to accommodate BOTH src+len and dest+len

            const mem_cost = if (len == 0)
                0 // Zero-length copies don't expand memory
            else blk: {
                // Safe conversion: if values don't fit in u64, use maxInt(u64) which will trigger
                // massive gas cost in memoryExpansionCost
                const dest_u64 = std.math.cast(u64, dest) orelse std.math.maxInt(u64);
                const src_u64 = std.math.cast(u64, src) orelse std.math.maxInt(u64);
                const len_u64 = std.math.cast(u64, len) orelse std.math.maxInt(u64);

                // Calculate end positions for both source and destination
                const end_dest: u64 = dest_u64 +| len_u64; // saturating add to prevent overflow
                const end_src: u64 = src_u64 +| len_u64;

                // Memory expansion must cover BOTH ranges - use the maximum
                const max_end = @max(end_dest, end_src);
                break :blk frame.memoryExpansionCost(max_end);
            };

            // For copy cost, we need to handle len > u32::MAX specially
            // If len doesn't fit in u32, the copy cost will be astronomical
            const copy_cost: u64 = if (len <= std.math.maxInt(u32))
                copyGasCost(@intCast(len))
            else
                std.math.maxInt(u64); // Huge value that will trigger OutOfGas

            // Use saturating arithmetic to prevent overflow when adding gas costs
            const total_gas = GasConstants.GasFastestStep +| mem_cost +| copy_cost;
            try charge(frame, total_gas);

            // Fast path: zero length - gas charged but no copy needed
            if (len == 0) {
                frame.pc += 1;
                return;
            }

            // Now that gas is charged, do bounds checking for actual memory operations
            const dest_u32 = std.math.cast(u32, dest) orelse return error.OutOfBounds;
            const src_u32 = std.math.cast(u32, src) orelse return error.OutOfBounds;
            const len_u32 = std.math.cast(u32, len) orelse return error.OutOfBounds;

            // Expand memory to cover BOTH source and destination ranges
            // Per EIP-5656, memory expansion happens before the copy operation
            const src_end: u64 = @as(u64, src_u32) + @as(u64, len_u32);
            const dest_end: u64 = @as(u64, dest_u32) + @as(u64, len_u32);
            const max_memory_end = @max(src_end, dest_end);
            const required_size = wordAlignedSize(max_memory_end);
            const required_size_u32 = std.math.cast(u32, required_size) orelse return error.OutOfBounds;
            if (required_size_u32 > frame.memory_size) {
                frame.memory_size = required_size_u32;
            }

            // In-place overlap-safe copy with zero heap allocations
            try frame.copyMemory(dest_u32, src_u32, len_u32);

            frame.pc += 1;
        }
    };
}
