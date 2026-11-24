/// Comparison opcode handlers for the EVM
const std = @import("std");
const HandlerConfig = @import("frame_interface.zig").HandlerConfig;
const primitives = @import("voltaire");
const GasConstants = primitives.GasConstants;

/// Handlers struct - provides comparison operation handlers for a Frame type
/// The FrameType must implement the core frame interface (see frame_interface.zig):
/// popStack, peekStack, setStackTop, consumeGas (when charging gas)
/// and a field: pc (program counter)
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

        /// LT opcode (0x10) - Less than comparison (unsigned)
        pub fn lt(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasFastestStep);
            const a = try frame.popStack(); // Top of stack
            const b = try frame.peekStack(0); // Second from top
            frame.setStackTop(if (a < b) 1 else 0); // Compare a < b
            frame.pc += 1;
        }

        /// GT opcode (0x11) - Greater than comparison (unsigned)
        pub fn gt(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasFastestStep);
            const a = try frame.popStack(); // Top of stack
            const b = try frame.peekStack(0); // Second from top
            frame.setStackTop(if (a > b) 1 else 0); // Compare a > b
            frame.pc += 1;
        }

        /// SLT opcode (0x12) - Signed less than comparison
        pub fn slt(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasFastestStep);
            const a = try frame.popStack(); // Top of stack
            const b = try frame.peekStack(0); // Second from top
            const a_signed = @as(i256, @bitCast(a));
            const b_signed = @as(i256, @bitCast(b));
            frame.setStackTop(if (a_signed < b_signed) 1 else 0); // Compare a < b (signed)
            frame.pc += 1;
        }

        /// SGT opcode (0x13) - Signed greater than comparison
        pub fn sgt(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasFastestStep);
            const a = try frame.popStack(); // Top of stack
            const b = try frame.peekStack(0); // Second from top
            const a_signed = @as(i256, @bitCast(a));
            const b_signed = @as(i256, @bitCast(b));
            frame.setStackTop(if (a_signed > b_signed) 1 else 0); // Compare a > b (signed)
            frame.pc += 1;
        }

        /// EQ opcode (0x14) - Equality comparison
        pub fn eq(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasFastestStep);
            const top = try frame.popStack();
            const second = try frame.peekStack(0);
            frame.setStackTop(if (top == second) 1 else 0); // EQ is symmetric
            frame.pc += 1;
        }

        /// ISZERO opcode (0x15) - Check if value is zero
        pub fn iszero(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasFastestStep);
            const a = try frame.peekStack(0);
            frame.setStackTop(if (a == 0) 1 else 0);
            frame.pc += 1;
        }
    };
}
