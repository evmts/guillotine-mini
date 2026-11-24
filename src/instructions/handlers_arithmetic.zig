/// Arithmetic opcode handlers for the EVM
const std = @import("std");
const HandlerConfig = @import("frame_interface.zig").HandlerConfig;
const primitives = @import("voltaire");
const GasConstants = primitives.GasConstants;

/// Handlers struct - provides arithmetic operation handlers for a Frame type
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

        /// ADD opcode (0x01) - Addition with overflow wrapping
        pub fn add(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasFastestStep);
            const a = try frame.popStack();
            const b = try frame.peekStack(0);
            frame.setStackTop(a +% b);
            frame.pc += 1;
        }

        /// MUL opcode (0x02) - Multiplication with overflow wrapping
        pub fn mul(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasFastStep);
            const a = try frame.popStack();
            const b = try frame.peekStack(0);
            frame.setStackTop(a *% b);
            frame.pc += 1;
        }

        /// SUB opcode (0x03) - Subtraction with underflow wrapping
        pub fn sub(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasFastestStep);
            const top = try frame.popStack();
            const second = try frame.peekStack(0);
            frame.setStackTop(top -% second);
            frame.pc += 1;
        }

        /// DIV opcode (0x04) - Integer division (division by zero returns 0)
        pub fn div(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasFastStep);
            const top = try frame.popStack();
            const second = try frame.peekStack(0);
            const result = if (second == 0) 0 else top / second;
            frame.setStackTop(result);
            frame.pc += 1;
        }

        /// SDIV opcode (0x05) - Signed integer division
        pub fn sdiv(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasFastStep);
            const top = try frame.popStack();
            const second = try frame.peekStack(0);
            const top_signed = @as(i256, @bitCast(top));
            const second_signed = @as(i256, @bitCast(second));
            const MIN_SIGNED = @as(u256, 1) << 255;
            const result = if (second == 0)
                0
            else if (top == MIN_SIGNED and second == std.math.maxInt(u256))
                MIN_SIGNED
            else
                @as(u256, @bitCast(@divTrunc(top_signed, second_signed)));
            frame.setStackTop(result);
            frame.pc += 1;
        }

        /// MOD opcode (0x06) - Modulo operation (mod by zero returns 0)
        pub fn mod(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasFastStep);
            const top = try frame.popStack();
            const second = try frame.peekStack(0);
            const result = if (second == 0) 0 else top % second;
            frame.setStackTop(result);
            frame.pc += 1;
        }

        /// SMOD opcode (0x07) - Signed modulo operation
        pub fn smod(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasFastStep);
            const top = try frame.popStack();
            const second = try frame.peekStack(0);
            const top_signed = @as(i256, @bitCast(top));
            const second_signed = @as(i256, @bitCast(second));
            const MIN_SIGNED = @as(u256, 1) << 255;
            const result = if (second == 0)
                0
            else if (top == MIN_SIGNED and second == std.math.maxInt(u256))
                0
            else
                @as(u256, @bitCast(@rem(top_signed, second_signed)));
            frame.setStackTop(result);
            frame.pc += 1;
        }

        /// ADDMOD opcode (0x08) - Addition modulo n (mod by zero returns 0)
        pub fn addmod(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasMidStep);
            const a = try frame.popStack();
            const b = try frame.popStack();
            const n = try frame.peekStack(0);
            const result = if (n == 0) 0 else blk: {
                // Overflow-free u256 modular addition (avoids slow u512 division)
                const am = a % n;
                const bm = b % n;
                const space = n - am;
                break :blk if (bm >= space) bm - space else am + bm;
            };
            frame.setStackTop(result);
            frame.pc += 1;
        }

        /// MULMOD opcode (0x09) - Multiplication modulo n (mod by zero returns 0)
        pub fn mulmod(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasMidStep);
            const a = try frame.popStack();
            const b = try frame.popStack();
            const n = try frame.peekStack(0);
            const result = if (n == 0) 0 else blk: {
                // Use u512 to avoid overflow
                const a_wide = @as(u512, a);
                const b_wide = @as(u512, b);
                const n_wide = @as(u512, n);
                break :blk @as(u256, @truncate((a_wide * b_wide) % n_wide));
            };
            frame.setStackTop(result);
            frame.pc += 1;
        }

        /// EXP opcode (0x0a) - Exponential operation
        pub fn exp(frame: *FrameType) FrameType.EvmError!void {
            const base = try frame.popStack();
            const exponent = try frame.peekStack(0);

            // Calculate dynamic gas cost based on exponent byte length in O(1) via @clz
            // Per EIP-160: GAS_EXP_BYTE * byte_length(exponent)
            const byte_len: u64 = if (exponent == 0)
                0
            else
                (@as(u64, 256 - @clz(exponent)) + 7) >> 3;
            // EIP-160 (Spurious Dragon) raised the EXP per-byte cost from 10 to 50.
            const EXP_BYTE_COST: u64 = if (frame.hardfork.isAtLeast(.SPURIOUS_DRAGON)) 50 else 10;
            const dynamic_gas = EXP_BYTE_COST * byte_len;
            try charge(frame, GasConstants.GasSlowStep + dynamic_gas);

            // Compute result (wrapping on overflow)
            var result: u256 = 1;
            var b = base;
            var e = exponent;
            while (e > 0) {
                if (e & 1 == 1) {
                    result = result *% b;
                }
                b = b *% b;
                e >>= 1;
            }

            frame.setStackTop(result);
            frame.pc += 1;
        }

        /// SIGNEXTEND opcode (0x0b) - Sign extension
        pub fn signextend(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasFastStep);
            const byte_index = try frame.popStack();
            const value = try frame.peekStack(0);

            // If byte_index >= 31, no sign extension needed
            const result = if (byte_index >= 31) value else blk: {
                const bit_index = @as(u8, @truncate(byte_index * 8 + 7));
                const sign_bit = @as(u256, 1) << @as(u8, bit_index);
                const mask = sign_bit - 1;

                // Check if sign bit is set
                const is_negative = (value & sign_bit) != 0;

                if (is_negative) {
                    // Sign extend with 1s
                    break :blk value | ~mask;
                } else {
                    // Zero extend (clear upper bits)
                    break :blk value & mask;
                }
            };

            frame.setStackTop(result);
            frame.pc += 1;
        }
    };
}
