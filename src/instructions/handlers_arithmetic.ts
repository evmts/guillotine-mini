/**
 * Arithmetic opcode handlers for the EVM
 *
 * This module provides all arithmetic operations (ADD, MUL, SUB, DIV, SDIV, MOD, SMOD, ADDMOD, MULMOD, EXP, SIGNEXTEND)
 * implemented with proper u256 wrapping semantics and gas metering.
 */

// Gas constants from primitives library
const GAS_FASTEST_STEP = 3n;
const GAS_FAST_STEP = 5n;
const GAS_MID_STEP = 8n;
const GAS_SLOW_STEP = 10n;
const EXP_BYTE_COST = 50n;

// u256 constants
const MAX_U256 = (1n << 256n) - 1n;
const MIN_SIGNED = 1n << 255n;
const MAX_SIGNED = MIN_SIGNED - 1n;

/**
 * Frame interface - minimal subset required for arithmetic handlers
 */
export interface Frame {
  pc: number;
  consumeGas(amount: bigint): void;
  popStack(): bigint;
  pushStack(value: bigint): void;
}

/**
 * Wraps a bigint to u256 (0 to 2^256-1)
 */
function toU256(value: bigint): bigint {
  return value & MAX_U256;
}

/**
 * Converts u256 to signed i256 representation
 */
function toSigned(value: bigint): bigint {
  if (value > MAX_SIGNED) {
    return value - (1n << 256n);
  }
  return value;
}

/**
 * Converts signed i256 to u256 representation
 */
function toUnsigned(value: bigint): bigint {
  if (value < 0n) {
    return (1n << 256n) + value;
  }
  return value;
}

/**
 * ADD opcode (0x01) - Addition with overflow wrapping
 * Gas: 3 (GasFastestStep)
 */
export function add(frame: Frame): void {
  frame.consumeGas(GAS_FASTEST_STEP);
  const a = frame.popStack();
  const b = frame.popStack();
  frame.pushStack(toU256(a + b));
  frame.pc += 1;
}

/**
 * MUL opcode (0x02) - Multiplication with overflow wrapping
 * Gas: 5 (GasFastStep)
 */
export function mul(frame: Frame): void {
  frame.consumeGas(GAS_FAST_STEP);
  const a = frame.popStack();
  const b = frame.popStack();
  frame.pushStack(toU256(a * b));
  frame.pc += 1;
}

/**
 * SUB opcode (0x03) - Subtraction with underflow wrapping
 * Gas: 3 (GasFastestStep)
 */
export function sub(frame: Frame): void {
  frame.consumeGas(GAS_FASTEST_STEP);
  const top = frame.popStack();
  const second = frame.popStack();
  frame.pushStack(toU256(top - second));
  frame.pc += 1;
}

/**
 * DIV opcode (0x04) - Integer division (division by zero returns 0)
 * Gas: 5 (GasFastStep)
 */
export function div(frame: Frame): void {
  frame.consumeGas(GAS_FAST_STEP);
  const top = frame.popStack();
  const second = frame.popStack();
  const result = second === 0n ? 0n : top / second;
  frame.pushStack(result);
  frame.pc += 1;
}

/**
 * SDIV opcode (0x05) - Signed integer division
 * Gas: 5 (GasFastStep)
 *
 * Special cases:
 * - Division by zero returns 0
 * - MIN_SIGNED / -1 returns MIN_SIGNED (overflow case)
 */
export function sdiv(frame: Frame): void {
  frame.consumeGas(GAS_FAST_STEP);
  const top = frame.popStack();
  const second = frame.popStack();

  let result: bigint;
  if (second === 0n) {
    result = 0n;
  } else if (top === MIN_SIGNED && second === MAX_U256) {
    // Special case: -2^255 / -1 would overflow, returns -2^255
    result = MIN_SIGNED;
  } else {
    const topSigned = toSigned(top);
    const secondSigned = toSigned(second);
    result = toUnsigned(topSigned / secondSigned);
  }

  frame.pushStack(result);
  frame.pc += 1;
}

/**
 * MOD opcode (0x06) - Modulo operation (mod by zero returns 0)
 * Gas: 5 (GasFastStep)
 */
export function mod(frame: Frame): void {
  frame.consumeGas(GAS_FAST_STEP);
  const top = frame.popStack();
  const second = frame.popStack();
  const result = second === 0n ? 0n : top % second;
  frame.pushStack(result);
  frame.pc += 1;
}

/**
 * SMOD opcode (0x07) - Signed modulo operation
 * Gas: 5 (GasFastStep)
 *
 * Special cases:
 * - Mod by zero returns 0
 * - MIN_SIGNED % -1 returns 0
 */
export function smod(frame: Frame): void {
  frame.consumeGas(GAS_FAST_STEP);
  const top = frame.popStack();
  const second = frame.popStack();

  let result: bigint;
  if (second === 0n) {
    result = 0n;
  } else if (top === MIN_SIGNED && second === MAX_U256) {
    // Special case: -2^255 % -1 returns 0
    result = 0n;
  } else {
    const topSigned = toSigned(top);
    const secondSigned = toSigned(second);
    result = toUnsigned(topSigned % secondSigned);
  }

  frame.pushStack(result);
  frame.pc += 1;
}

/**
 * ADDMOD opcode (0x08) - Addition modulo n (mod by zero returns 0)
 * Gas: 8 (GasMidStep)
 *
 * Uses u512 intermediate to avoid overflow: (a + b) % n
 */
export function addmod(frame: Frame): void {
  frame.consumeGas(GAS_MID_STEP);
  const a = frame.popStack();
  const b = frame.popStack();
  const n = frame.popStack();

  const result = n === 0n ? 0n : (a + b) % n;
  frame.pushStack(result);
  frame.pc += 1;
}

/**
 * MULMOD opcode (0x09) - Multiplication modulo n (mod by zero returns 0)
 * Gas: 8 (GasMidStep)
 *
 * Uses u512 intermediate to avoid overflow: (a * b) % n
 */
export function mulmod(frame: Frame): void {
  frame.consumeGas(GAS_MID_STEP);
  const a = frame.popStack();
  const b = frame.popStack();
  const n = frame.popStack();

  const result = n === 0n ? 0n : (a * b) % n;
  frame.pushStack(result);
  frame.pc += 1;
}

/**
 * EXP opcode (0x0a) - Exponential operation
 * Gas: 10 + 50 * byte_length(exponent)
 *
 * Implements exponentiation by squaring with wrapping overflow.
 * Dynamic gas cost based on exponent byte length (EIP-160).
 */
export function exp(frame: Frame): void {
  const base = frame.popStack();
  const exponent = frame.popStack();

  // Calculate dynamic gas cost based on exponent byte length
  // Per Zig implementation: if exponent is 0, byte_len is 0
  const byteLen = (() => {
    if (exponent === 0n) return 0n;
    let tempExp = exponent;
    let len = 0n;
    while (tempExp > 0n) {
      len += 1n;
      tempExp >>= 8n;
    }
    return len;
  })();

  const dynamicGas = EXP_BYTE_COST * byteLen;
  frame.consumeGas(GAS_SLOW_STEP + dynamicGas);

  // Compute result using exponentiation by squaring (wrapping on overflow)
  let result = 1n;
  let b = base;
  let e = exponent;

  while (e > 0n) {
    if ((e & 1n) === 1n) {
      result = toU256(result * b);
    }
    b = toU256(b * b);
    e >>= 1n;
  }

  frame.pushStack(result);
  frame.pc += 1;
}

/**
 * SIGNEXTEND opcode (0x0b) - Sign extension
 * Gas: 5 (GasFastStep)
 *
 * Extends the sign bit of a value from byte position `byteIndex`.
 * If byteIndex >= 31, no extension is needed (value unchanged).
 */
export function signextend(frame: Frame): void {
  frame.consumeGas(GAS_FAST_STEP);
  const byteIndex = frame.popStack();
  const value = frame.popStack();

  let result: bigint;
  if (byteIndex >= 31n) {
    // No sign extension needed
    result = value;
  } else {
    const bitIndex = Number(byteIndex * 8n + 7n);
    const signBit = 1n << BigInt(bitIndex);
    const mask = signBit - 1n;

    // Check if sign bit is set
    const isNegative = (value & signBit) !== 0n;

    if (isNegative) {
      // Sign extend with 1s
      result = value | ~mask;
    } else {
      // Zero extend (clear upper bits)
      result = value & mask;
    }
    result = toU256(result);
  }

  frame.pushStack(result);
  frame.pc += 1;
}

/**
 * Export all handlers as a single object for easy import
 */
export const ArithmeticHandlers = {
  add,
  mul,
  sub,
  div,
  sdiv,
  mod,
  smod,
  addmod,
  mulmod,
  exp,
  signextend,
};
