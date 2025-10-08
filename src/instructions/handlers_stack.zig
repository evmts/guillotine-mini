/// Stack manipulation opcode handlers for the EVM
const std = @import("std");
const primitives = @import("primitives");
const GasConstants = primitives.GasConstants;

/// Handlers struct - provides stack operation handlers for a Frame type
/// The FrameType must have methods: consumeGas, popStack, pushStack
/// and fields: pc (program counter), stack, bytecode
pub fn Handlers(FrameType: type) type {
    return struct {
        /// POP opcode (0x50) - Remove top item from stack
        pub fn pop(frame: *FrameType) FrameType.EvmError!void {
            try frame.consumeGas(GasConstants.GasQuickStep);
            _ = try frame.popStack();
            frame.pc += 1;
        }

        /// PUSH1-PUSH32 opcodes (0x60-0x7f) - Push immediate value onto stack
        /// Opcode determines number of bytes to read from bytecode
        pub fn push(frame: *FrameType, opcode: u8) FrameType.EvmError!void {
            try frame.consumeGas(GasConstants.GasFastestStep);
            const push_size = opcode - 0x5f;

            // Check bounds - need to read push_size bytes after the opcode
            const pc_usize: usize = @intCast(frame.pc);
            const ps_usize: usize = push_size;
            if (pc_usize + ps_usize >= frame.bytecode.len) {
                return error.InvalidPush;
            }

            // Read immediate value from bytecode
            var value: u256 = 0;
            for (0..push_size) |i| {
                value = (value << 8) | frame.bytecode[pc_usize + 1 + i];
            }

            try frame.pushStack(value);
            frame.pc += 1 + push_size;
        }

        /// DUP1-DUP16 opcodes (0x80-0x8f) - Duplicate stack item at position n
        /// DUP1 duplicates top item, DUP2 duplicates second item, etc.
        pub fn dup(frame: *FrameType, opcode: u8) FrameType.EvmError!void {
            try frame.consumeGas(GasConstants.GasFastestStep);
            const n = opcode - 0x7f;
            if (frame.stack.items.len < n) {
                return error.StackUnderflow;
            }
            const value = frame.stack.items[frame.stack.items.len - n];
            try frame.pushStack(value);
            frame.pc += 1;
        }

        /// SWAP1-SWAP16 opcodes (0x90-0x9f) - Swap top stack item with item at position n+1
        /// SWAP1 swaps top with second, SWAP2 swaps top with third, etc.
        pub fn swap(frame: *FrameType, opcode: u8) FrameType.EvmError!void {
            try frame.consumeGas(GasConstants.GasFastestStep);
            const n = opcode - 0x8f;
            if (frame.stack.items.len <= n) {
                return error.StackUnderflow;
            }
            const top_idx = frame.stack.items.len - 1;
            const swap_idx = frame.stack.items.len - 1 - n;
            const temp = frame.stack.items[top_idx];
            frame.stack.items[top_idx] = frame.stack.items[swap_idx];
            frame.stack.items[swap_idx] = temp;
            frame.pc += 1;
        }
    };
}
