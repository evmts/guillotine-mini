/// Stack manipulation opcode handlers for the EVM
const std = @import("std");
const HandlerConfig = @import("frame_interface.zig").HandlerConfig;
const primitives = @import("voltaire");
const GasConstants = primitives.GasConstants;
const hardfork_hooks = @import("../hardfork_hooks.zig");

/// Handlers struct - provides stack operation handlers for a Frame type
/// The FrameType must have methods: consumeGas, popStack, pushStack
/// and fields: pc (program counter), stack, bytecode
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

        /// POP opcode (0x50) - Remove top item from stack
        pub fn pop(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasQuickStep);
            _ = try frame.popStack();
            frame.pc += 1;
        }

        /// PUSH0-PUSH32 opcodes (0x5f-0x7f) - Push immediate value onto stack
        /// Opcode determines number of bytes to read from bytecode
        /// PUSH0 (0x5f) costs 2 gas, PUSH1-PUSH32 (0x60-0x7f) cost 3 gas
        pub fn push(frame: *FrameType, opcode: u8) FrameType.EvmError!void {
            const push_size = opcode - 0x5f;

            // EIP-3855: PUSH0 was introduced in Shanghai hardfork
            if (push_size == 0) {
                const evm = frame.getEvm();
                if (evm.hardfork.isBefore(.SHANGHAI)) {
                    return error.InvalidOpcode;
                }
                try charge(frame, GasConstants.GasQuickStep);
            } else {
                try charge(frame, GasConstants.GasFastestStep);
            }

            // Use the bytecode module's readImmediate method
            const value = frame.readImmediate(push_size) orelse return error.InvalidPush;

            try frame.pushStack(value);
            frame.pc += 1 + push_size;
        }

        /// DUP1-DUP16 opcodes (0x80-0x8f) - Duplicate stack item at position n
        /// DUP1 duplicates top item, DUP2 duplicates second item, etc.
        pub fn dup(frame: *FrameType, opcode: u8) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasFastestStep);
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
            try charge(frame, GasConstants.GasFastestStep);
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

        inline fn readEip8024Immediate(frame: *const FrameType) u8 {
            const next_pc = @as(usize, frame.pc) + 1;
            return if (next_pc < frame.bytecode.code.len) frame.bytecode.code[next_pc] else 0;
        }

        /// DUPN opcode (0xe6) - Duplicate stack item at depth 17..235 (EIP-8024, Amsterdam+)
        pub fn dupn(frame: *FrameType) FrameType.EvmError!void {
            const evm = frame.getEvm();
            if (!hardfork_hooks.supportsAmsterdam(evm.hardfork)) return error.InvalidOpcode;

            const imm = readEip8024Immediate(frame);
            const n = hardfork_hooks.eip8024.decodeSingle(imm) orelse return error.InvalidOpcode;

            try charge(frame, GasConstants.GasFastestStep);
            if (frame.stack.items.len < n) return error.StackUnderflow;
            const value = frame.stack.items[frame.stack.items.len - n];
            try frame.pushStack(value);
            frame.pc += 2;
        }

        /// SWAPN opcode (0xe7) - Swap top item with item at depth 17..235 (EIP-8024, Amsterdam+)
        pub fn swapn(frame: *FrameType) FrameType.EvmError!void {
            const evm = frame.getEvm();
            if (!hardfork_hooks.supportsAmsterdam(evm.hardfork)) return error.InvalidOpcode;

            const imm = readEip8024Immediate(frame);
            const n = hardfork_hooks.eip8024.decodeSingle(imm) orelse return error.InvalidOpcode;

            try charge(frame, GasConstants.GasFastestStep);
            if (frame.stack.items.len <= n) return error.StackUnderflow;
            const top_idx = frame.stack.items.len - 1;
            const swap_idx = top_idx - n;
            const temp = frame.stack.items[top_idx];
            frame.stack.items[top_idx] = frame.stack.items[swap_idx];
            frame.stack.items[swap_idx] = temp;
            frame.pc += 2;
        }

        /// EXCHANGE opcode (0xe8) - Swap two arbitrary stack items (EIP-8024, Amsterdam+)
        pub fn exchange(frame: *FrameType) FrameType.EvmError!void {
            const evm = frame.getEvm();
            if (!hardfork_hooks.supportsAmsterdam(evm.hardfork)) return error.InvalidOpcode;

            const imm = readEip8024Immediate(frame);
            const pair = hardfork_hooks.eip8024.decodePair(imm) orelse return error.InvalidOpcode;

            try charge(frame, GasConstants.GasFastestStep);
            if (frame.stack.items.len <= pair.m) return error.StackUnderflow;
            const top_idx = frame.stack.items.len - 1;
            const idx_n = top_idx - pair.n;
            const idx_m = top_idx - pair.m;
            const temp = frame.stack.items[idx_n];
            frame.stack.items[idx_n] = frame.stack.items[idx_m];
            frame.stack.items[idx_m] = temp;
            frame.pc += 2;
        }
    };
}
