/**
 * Bitwise opcode handlers for the EVM
 * Port of src/instructions/handlers_bitwise.zig to TypeScript
 *
 * Implements bitwise operations: AND, OR, XOR, NOT, BYTE, SHL, SHR, SAR
 */

import {
  mask256,
  shl256,
  shr256,
  sar256,
  byte256,
} from '../utils/bigint-bitwise';

/**
 * Frame interface for opcode handlers
 * Handlers operate on a Frame that provides stack, memory, PC, gas, and EVM access
 */
export interface Frame {
  /** Consume gas for an operation */
  consumeGas(amount: bigint): void;

  /** Pop a value from the stack */
  popStack(): bigint;

  /** Push a value to the stack */
  pushStack(value: bigint): void;

  /** Program counter */
  pc: number;

  /** Get the parent EVM instance */
  getEvm(): Evm;
}

/**
 * EVM interface for hardfork checks
 */
export interface Evm {
  /** Hardfork for this EVM instance */
  hardfork: Hardfork;
}

/**
 * Hardfork interface
 */
export interface Hardfork {
  /** Check if hardfork is before a specific fork */
  isBefore(fork: string): boolean;
}

/**
 * Gas constants
 * GasFastestStep is 3 gas (EVM Yellow Paper)
 */
const GAS_FASTEST_STEP = 3n;

/**
 * AND opcode (0x16) - Bitwise AND operation
 *
 * Pops two values from stack, performs bitwise AND, pushes result.
 * Result is masked to 256 bits.
 *
 * Gas: GasFastestStep (3)
 * Stack: [a, b] → [a & b]
 */
export function op_and(frame: Frame): void {
  frame.consumeGas(GAS_FASTEST_STEP);
  const a = frame.popStack();
  const b = frame.popStack();
  frame.pushStack(mask256(a & b));
  frame.pc += 1;
}

/**
 * OR opcode (0x17) - Bitwise OR operation
 *
 * Pops two values from stack, performs bitwise OR, pushes result.
 * Result is masked to 256 bits.
 *
 * Gas: GasFastestStep (3)
 * Stack: [a, b] → [a | b]
 */
export function op_or(frame: Frame): void {
  frame.consumeGas(GAS_FASTEST_STEP);
  const a = frame.popStack();
  const b = frame.popStack();
  frame.pushStack(mask256(a | b));
  frame.pc += 1;
}

/**
 * XOR opcode (0x18) - Bitwise XOR operation
 *
 * Pops two values from stack, performs bitwise XOR, pushes result.
 * Result is masked to 256 bits.
 *
 * Gas: GasFastestStep (3)
 * Stack: [a, b] → [a ^ b]
 */
export function op_xor(frame: Frame): void {
  frame.consumeGas(GAS_FASTEST_STEP);
  const a = frame.popStack();
  const b = frame.popStack();
  frame.pushStack(mask256(a ^ b));
  frame.pc += 1;
}

/**
 * NOT opcode (0x19) - Bitwise NOT operation
 *
 * Pops one value from stack, performs bitwise NOT (complement), pushes result.
 * Result is masked to 256 bits (flips all 256 bits).
 *
 * Gas: GasFastestStep (3)
 * Stack: [a] → [~a]
 */
export function op_not(frame: Frame): void {
  frame.consumeGas(GAS_FASTEST_STEP);
  const a = frame.popStack();
  // Bitwise NOT with 256-bit mask
  // ~a is equivalent to (2^256 - 1) - a
  frame.pushStack(mask256(~a));
  frame.pc += 1;
}

/**
 * BYTE opcode (0x1a) - Extract byte from word
 *
 * Pops byte index i and value x from stack.
 * Extracts the i-th byte from x (counting from most significant byte).
 * If i >= 32, returns 0.
 *
 * Gas: GasFastestStep (3)
 * Stack: [i, x] → [byte at index i]
 *
 * Example:
 * - x = 0xff00000000000000000000000000000000000000000000000000000000000000
 * - i = 0 → result = 0xff (most significant byte)
 * - i = 1 → result = 0x00
 * - i = 31 → result = 0x00 (least significant byte)
 * - i = 32 → result = 0x00 (out of bounds)
 */
export function byte(frame: Frame): void {
  frame.consumeGas(GAS_FASTEST_STEP);
  const i = frame.popStack();
  const x = frame.popStack();
  const result = byte256(i, x);
  frame.pushStack(result);
  frame.pc += 1;
}

/**
 * SHL opcode (0x1b) - Shift left operation (EIP-145)
 *
 * Pops shift amount and value from stack.
 * Performs left shift, masking result to 256 bits.
 * If shift >= 256, result is 0.
 *
 * Introduced in Constantinople hardfork (EIP-145).
 *
 * Gas: GasFastestStep (3)
 * Stack: [shift, value] → [value << shift]
 *
 * Example:
 * - value = 0x1, shift = 4 → result = 0x10
 * - value = 0x1, shift = 256 → result = 0x0
 */
export function shl(frame: Frame): void {
  const evm = frame.getEvm();
  // EIP-145: SHL opcode was introduced in Constantinople hardfork
  if (evm.hardfork.isBefore('CONSTANTINOPLE')) {
    throw new Error('InvalidOpcode');
  }

  frame.consumeGas(GAS_FASTEST_STEP);
  // Pop shift (TOS), then value
  const shift = frame.popStack();
  const value = frame.popStack();
  const result = shl256(value, shift);
  frame.pushStack(result);
  frame.pc += 1;
}

/**
 * SHR opcode (0x1c) - Logical shift right operation (EIP-145)
 *
 * Pops shift amount and value from stack.
 * Performs logical right shift (zero-fill).
 * If shift >= 256, result is 0.
 *
 * Introduced in Constantinople hardfork (EIP-145).
 *
 * Gas: GasFastestStep (3)
 * Stack: [shift, value] → [value >> shift]
 *
 * Example:
 * - value = 0x10, shift = 4 → result = 0x1
 * - value = 0xff, shift = 256 → result = 0x0
 */
export function shr(frame: Frame): void {
  const evm = frame.getEvm();
  // EIP-145: SHR opcode was introduced in Constantinople hardfork
  if (evm.hardfork.isBefore('CONSTANTINOPLE')) {
    throw new Error('InvalidOpcode');
  }

  frame.consumeGas(GAS_FASTEST_STEP);
  // Pop shift (TOS), then value
  const shift = frame.popStack();
  const value = frame.popStack();
  const result = shr256(value, shift);
  frame.pushStack(result);
  frame.pc += 1;
}

/**
 * SAR opcode (0x1d) - Arithmetic shift right operation (EIP-145)
 *
 * Pops shift amount and value from stack.
 * Performs arithmetic right shift (sign-extending).
 * If shift >= 256, result is all 1s (if negative) or all 0s (if positive).
 *
 * Introduced in Constantinople hardfork (EIP-145).
 *
 * Gas: GasFastestStep (3)
 * Stack: [shift, value] → [value >> shift (sign-extended)]
 *
 * Example:
 * - value = 0x10, shift = 4 → result = 0x1 (positive)
 * - value = 0x8000...0000 (negative), shift = 4 → result = 0xf800...0000 (sign extended)
 * - value = 0x8000...0000, shift = 256 → result = 0xffff...ffff (all 1s)
 */
export function sar(frame: Frame): void {
  const evm = frame.getEvm();
  // EIP-145: SAR opcode was introduced in Constantinople hardfork
  if (evm.hardfork.isBefore('CONSTANTINOPLE')) {
    throw new Error('InvalidOpcode');
  }

  frame.consumeGas(GAS_FASTEST_STEP);
  // Pop shift (TOS), then value
  const shift = frame.popStack();
  const value = frame.popStack();
  const result = sar256(value, shift);
  frame.pushStack(result);
  frame.pc += 1;
}
