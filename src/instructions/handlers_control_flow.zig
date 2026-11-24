/// Control flow opcode handlers for the EVM
const std = @import("std");
const primitives = @import("voltaire");
const GasConstants = primitives.GasConstants;

/// Handlers struct - provides control flow operation handlers for a Frame type
/// The FrameType must have methods: consumeGas, popStack, pushStack, readMemory
/// and fields: pc (program counter), stopped, reverted, bytecode (with isValidJumpDest),
/// output, memory_size, allocator, evm_ptr
pub fn Handlers(FrameType: type) type {
    return struct {
        /// STOP opcode (0x00) - Halts execution
        pub fn stop(frame: *FrameType) FrameType.EvmError!void {
            frame.stopped = true;
            return;
        }

        /// JUMP opcode (0x56) - Unconditional jump
        pub fn jump(frame: *FrameType) FrameType.EvmError!void {
            try frame.consumeGas(GasConstants.GasMidStep);
            const dest = try frame.popStack();
            const dest_pc = std.math.cast(u32, dest) orelse return error.InvalidJumpDestination;

            // Validate jump destination
            if (!frame.bytecode.isValidJumpDest(dest_pc)) return error.InvalidJump;

            frame.pc = dest_pc;
        }

        /// JUMPI opcode (0x57) - Conditional jump
        pub fn jumpi(frame: *FrameType) FrameType.EvmError!void {
            try frame.consumeGas(GasConstants.GasSlowStep);
            const dest = try frame.popStack();
            const condition = try frame.popStack();

            if (condition != 0) {
                const dest_pc = std.math.cast(u32, dest) orelse return error.InvalidJumpDestination;

                // Validate jump destination
                if (!frame.bytecode.isValidJumpDest(dest_pc)) return error.InvalidJump;

                frame.pc = dest_pc;
            } else {
                frame.pc += 1;
            }
        }

        /// JUMPDEST opcode (0x5b) - Jump destination marker
        pub fn jumpdest(frame: *FrameType) FrameType.EvmError!void {
            try frame.consumeGas(GasConstants.JumpdestGas);
            frame.pc += 1;
        }

        /// PC opcode (0x58) - Get program counter
        pub fn pc(frame: *FrameType) FrameType.EvmError!void {
            try frame.consumeGas(GasConstants.GasQuickStep);
            try frame.pushStack(frame.pc);
            frame.pc += 1;
        }

        /// RETURN opcode (0xf3) - Halt execution and return output data
        pub fn ret(frame: *FrameType) FrameType.EvmError!void {
            const offset = try frame.popStack();
            const length = try frame.popStack();
            try captureOutput(frame, offset, length);
            frame.stopped = true;
        }

        /// REVERT opcode (0xfd) - Halt execution and revert state changes
        pub fn revert(frame: *FrameType) FrameType.EvmError!void {
            // EIP-140: REVERT was introduced in Byzantium hardfork
            const evm = frame.getEvm();
            if (evm.hardfork.isBefore(.BYZANTIUM)) return error.InvalidOpcode;

            const offset = try frame.popStack();
            const length = try frame.popStack();
            try captureOutput(frame, offset, length);
            frame.reverted = true;
        }

        /// Charge expansion for `[offset, offset+length)` and copy it to `frame.output`.
        /// Zero-length output charges nothing and ignores the offset.
        fn captureOutput(frame: *FrameType, offset: u256, length: u256) FrameType.EvmError!void {
            const range = try frame.memoryRange(offset, length) orelse return;
            try frame.consumeGas(frame.memoryExpansionCost(range.end));
            try frame.expandMemory(range.end);
            frame.output = try frame.readMemoryAlloc(frame.allocator, range);
        }
    };
}
