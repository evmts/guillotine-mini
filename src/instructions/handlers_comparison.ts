/**
 * Comparison opcode handlers for the EVM
 *
 * This module implements all comparison operations:
 * - LT (0x10): Unsigned less than
 * - GT (0x11): Unsigned greater than
 * - SLT (0x12): Signed less than
 * - SGT (0x13): Signed greater than
 * - EQ (0x14): Equality
 * - ISZERO (0x15): Check if zero
 *
 * All comparison operations:
 * - Consume GasFastestStep (3 gas)
 * - Pop operands from stack
 * - Push result (1n for true, 0n for false)
 * - Increment program counter
 */

const GasFastestStep = 3n;

/**
 * Maximum value for u256 (2^256 - 1)
 * Used for two's complement signed integer conversion
 */
const MAX_U256 = (1n << 256n) - 1n;

/**
 * Sign bit threshold for u256 (2^255)
 * Values >= this are negative in two's complement
 */
const SIGN_BIT = 1n << 255n;

/**
 * Frame interface that handlers operate on
 */
export interface Frame {
  consumeGas(amount: bigint): void;
  popStack(): bigint;
  pushStack(value: bigint): void;
  pc: number;
}

/**
 * Convert unsigned u256 to signed i256 using two's complement
 *
 * In two's complement representation:
 * - Values 0 to 2^255-1 are positive (0 to 0x7fff...ffff)
 * - Values 2^255 to 2^256-1 are negative (-2^255 to -1)
 *
 * @param value - Unsigned 256-bit value
 * @returns Signed interpretation of the value
 */
function toSigned(value: bigint): bigint {
  // If sign bit is set (value >= 2^255), it's negative
  if (value >= SIGN_BIT) {
    // Convert to negative: value - 2^256
    return value - (1n << 256n);
  }
  return value;
}

/**
 * LT opcode (0x10) - Less than comparison (unsigned)
 *
 * Pops two values from stack and pushes 1 if first < second, else 0.
 * Both operands are treated as unsigned 256-bit integers.
 *
 * Gas: 3 (GasFastestStep)
 * Stack: [a, b] -> [a < b ? 1 : 0]
 */
export function lt(frame: Frame): void {
  frame.consumeGas(GasFastestStep);
  const a = frame.popStack(); // Top of stack
  const b = frame.popStack(); // Second from top
  frame.pushStack(a < b ? 1n : 0n); // Compare a < b
  frame.pc += 1;
}

/**
 * GT opcode (0x11) - Greater than comparison (unsigned)
 *
 * Pops two values from stack and pushes 1 if first > second, else 0.
 * Both operands are treated as unsigned 256-bit integers.
 *
 * Gas: 3 (GasFastestStep)
 * Stack: [a, b] -> [a > b ? 1 : 0]
 */
export function gt(frame: Frame): void {
  frame.consumeGas(GasFastestStep);
  const a = frame.popStack(); // Top of stack
  const b = frame.popStack(); // Second from top
  frame.pushStack(a > b ? 1n : 0n); // Compare a > b
  frame.pc += 1;
}

/**
 * SLT opcode (0x12) - Signed less than comparison
 *
 * Pops two values from stack and pushes 1 if first < second (signed), else 0.
 * Operands are interpreted as two's complement signed 256-bit integers.
 *
 * Two's complement interpretation:
 * - 0x0000...0000 to 0x7FFF...FFFF = 0 to 2^255-1 (positive)
 * - 0x8000...0000 to 0xFFFF...FFFF = -2^255 to -1 (negative)
 *
 * Gas: 3 (GasFastestStep)
 * Stack: [a, b] -> [signed(a) < signed(b) ? 1 : 0]
 */
export function slt(frame: Frame): void {
  frame.consumeGas(GasFastestStep);
  const a = frame.popStack(); // Top of stack
  const b = frame.popStack(); // Second from top
  const a_signed = toSigned(a);
  const b_signed = toSigned(b);
  frame.pushStack(a_signed < b_signed ? 1n : 0n); // Compare a < b (signed)
  frame.pc += 1;
}

/**
 * SGT opcode (0x13) - Signed greater than comparison
 *
 * Pops two values from stack and pushes 1 if first > second (signed), else 0.
 * Operands are interpreted as two's complement signed 256-bit integers.
 *
 * Two's complement interpretation:
 * - 0x0000...0000 to 0x7FFF...FFFF = 0 to 2^255-1 (positive)
 * - 0x8000...0000 to 0xFFFF...FFFF = -2^255 to -1 (negative)
 *
 * Gas: 3 (GasFastestStep)
 * Stack: [a, b] -> [signed(a) > signed(b) ? 1 : 0]
 */
export function sgt(frame: Frame): void {
  frame.consumeGas(GasFastestStep);
  const a = frame.popStack(); // Top of stack
  const b = frame.popStack(); // Second from top
  const a_signed = toSigned(a);
  const b_signed = toSigned(b);
  frame.pushStack(a_signed > b_signed ? 1n : 0n); // Compare a > b (signed)
  frame.pc += 1;
}

/**
 * EQ opcode (0x14) - Equality comparison
 *
 * Pops two values from stack and pushes 1 if equal, else 0.
 *
 * Gas: 3 (GasFastestStep)
 * Stack: [a, b] -> [a == b ? 1 : 0]
 */
export function eq(frame: Frame): void {
  frame.consumeGas(GasFastestStep);
  const top = frame.popStack();
  const second = frame.popStack();
  frame.pushStack(top === second ? 1n : 0n); // EQ is symmetric
  frame.pc += 1;
}

/**
 * ISZERO opcode (0x15) - Check if value is zero
 *
 * Pops one value from stack and pushes 1 if zero, else 0.
 * This is equivalent to logical NOT.
 *
 * Gas: 3 (GasFastestStep)
 * Stack: [a] -> [a == 0 ? 1 : 0]
 */
export function iszero(frame: Frame): void {
  frame.consumeGas(GasFastestStep);
  const a = frame.popStack();
  frame.pushStack(a === 0n ? 1n : 0n);
  frame.pc += 1;
}
