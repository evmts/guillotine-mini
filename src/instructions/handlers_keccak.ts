/**
 * Keccak256 (SHA3) opcode handler for the EVM
 * Port of src/instructions/handlers_keccak.zig to TypeScript
 */

import { keccak256 } from 'viem';

/**
 * Gas constants for KECCAK256 operation
 */
const KECCAK256_GAS = 30n;
const KECCAK256_WORD_GAS = 6n;

/**
 * Helper function to calculate word count (needed for gas calculation)
 * Words are 32-byte aligned
 */
function wordCount(bytes: bigint): bigint {
  return (bytes + 31n) / 32n;
}

/**
 * Helper function to calculate word-aligned memory size
 */
function wordAlignedSize(bytes: bigint): number {
  const words = wordCount(bytes);
  return Number(words * 32n);
}

/**
 * Calculate KECCAK256 gas cost
 * Gas = 30 + 6 * word_count
 */
function keccak256GasCost(dataSize: bigint): bigint {
  const words = wordCount(dataSize);
  return KECCAK256_GAS + words * KECCAK256_WORD_GAS;
}

/**
 * Frame interface that handlers operate on
 * Minimal interface needed for KECCAK256 operation
 */
export interface Frame {
  pc: number;
  memory: Uint8Array;
  memorySize: number;
  stack: bigint[];
  gasRemaining: bigint;

  consumeGas(amount: bigint): void;
  popStack(): bigint;
  pushStack(value: bigint): void;
  readMemory(offset: number): number;
  memoryExpansionCost(endAddress: bigint): bigint;
}

/**
 * Keccak256 error types
 */
export class Keccak256Error extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'Keccak256Error';
  }
}

export class OutOfBoundsError extends Keccak256Error {
  constructor() {
    super('Memory offset or size out of bounds');
    this.name = 'OutOfBoundsError';
  }
}

export class OutOfGasError extends Keccak256Error {
  constructor() {
    super('Out of gas during KECCAK256 operation');
    this.name = 'OutOfGasError';
  }
}

export class StackUnderflowError extends Keccak256Error {
  constructor() {
    super('Stack underflow during KECCAK256 operation');
    this.name = 'StackUnderflowError';
  }
}

export class StackOverflowError extends Keccak256Error {
  constructor() {
    super('Stack overflow during KECCAK256 operation');
    this.name = 'StackOverflowError';
  }
}

/**
 * SHA3/KECCAK256 opcode (0x20) - Compute Keccak-256 hash
 *
 * Stack inputs:
 *   - offset: Memory offset to start reading from
 *   - size: Number of bytes to read
 *
 * Stack output:
 *   - hash: 32-byte Keccak-256 hash as u256
 *
 * Gas cost: 30 + 6 * word_count + memory_expansion_cost
 *
 * Special case: KECCAK256("") = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470
 */
export function sha3(frame: Frame): void {
  // Pop offset and size from stack
  const offset = frame.popStack();
  const size = frame.popStack();

  // Validate bounds BEFORE charging gas (prevent arithmetic overflow in gas calculation)
  const MAX_U32 = 0xFFFFFFFF;
  if (offset > MAX_U32 || size > MAX_U32) {
    throw new OutOfBoundsError();
  }

  // Calculate and charge gas for computation
  const gasCost = keccak256GasCost(size);
  frame.consumeGas(gasCost);

  // Handle empty data case (size = 0)
  if (size === 0n) {
    // Keccak-256("") = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470
    const emptyHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470n;
    frame.pushStack(emptyHash);
    frame.pc += 1;
    return;
  }

  const offsetNum = Number(offset);
  const sizeNum = Number(size);

  // Charge memory expansion cost to cover [offset, offset+size)
  const endAddr = offset + size;
  const memCost = frame.memoryExpansionCost(endAddr);
  frame.consumeGas(memCost);

  // Update memory size if expanded
  const alignedSize = wordAlignedSize(endAddr);
  if (alignedSize > frame.memorySize) {
    frame.memorySize = alignedSize;
  }

  // Read data from memory
  const data = new Uint8Array(sizeNum);
  for (let i = 0; i < sizeNum; i++) {
    const addr = offsetNum + i;
    if (addr > MAX_U32) {
      throw new OutOfBoundsError();
    }
    data[i] = frame.readMemory(addr);
  }

  // Compute Keccak-256 hash using viem
  const hashHex = keccak256(data);

  // Convert hash hex string to u256 (big-endian)
  // Remove '0x' prefix and parse as bigint
  const hashU256 = BigInt(hashHex);

  // Push result onto stack
  frame.pushStack(hashU256);
  frame.pc += 1;
}

/**
 * Handlers object for compatibility with Zig pattern
 */
export const Handlers = {
  sha3,
};
