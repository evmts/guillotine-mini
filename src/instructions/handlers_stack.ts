/**
 * Stack manipulation opcode handlers for the EVM
 * Port of src/instructions/handlers_stack.zig to TypeScript
 *
 * This module provides handlers for:
 * - POP (0x50): Remove top stack item
 * - PUSH0-PUSH32 (0x5f-0x7f): Push immediate values onto stack
 * - DUP1-DUP16 (0x80-0x8f): Duplicate stack items
 * - SWAP1-SWAP16 (0x90-0x9f): Swap stack items
 */

import { CallError, EvmError } from '../errors';
import type { Bytecode } from '../bytecode';

/**
 * Hardfork enumeration for feature detection
 */
export enum Hardfork {
  FRONTIER = 0,
  HOMESTEAD = 1,
  TANGERINE = 2,
  SPURIOUS = 3,
  BYZANTIUM = 4,
  CONSTANTINOPLE = 5,
  ISTANBUL = 6,
  BERLIN = 7,
  LONDON = 8,
  MERGE = 9,
  SHANGHAI = 10,
  CANCUN = 11,
  PRAGUE = 12,
  OSAKA = 13,
}

/**
 * Gas constants for stack operations
 */
export const GAS_QUICKSTEP = 2; // POP, PUSH0
export const GAS_FASTESTSTEP = 3; // PUSH1-PUSH32, DUP1-DUP16, SWAP1-SWAP16

/**
 * Frame interface required by stack handlers
 * Represents a single execution context with stack, memory, PC, and gas tracking
 */
export interface FrameInterface {
  /** Stack of 256-bit unsigned integers */
  stack: bigint[];

  /** Program counter */
  pc: number;

  /** Remaining gas for execution */
  gasRemaining: bigint;

  /** Bytecode being executed */
  bytecode: Bytecode;

  /** Active hardfork for feature detection */
  hardfork: Hardfork;

  /** Consume gas from frame */
  consumeGas(amount: bigint): void;

  /** Pop value from stack */
  popStack(): bigint;

  /** Push value onto stack */
  pushStack(value: bigint): void;

  /** Read immediate data from bytecode */
  readImmediate(size: number): bigint | null;
}

/**
 * POP opcode (0x50) - Remove top item from stack
 * Gas cost: 2 (GasQuickStep)
 *
 * @param frame - Execution frame
 * @throws {EvmError} StackUnderflow if stack is empty
 * @throws {EvmError} OutOfGas if insufficient gas
 */
export function pop(frame: FrameInterface): void {
  frame.consumeGas(BigInt(GAS_QUICKSTEP));
  frame.popStack();
  frame.pc += 1;
}

/**
 * PUSH0-PUSH32 opcodes (0x5f-0x7f) - Push immediate value onto stack
 * Opcode determines number of bytes to read from bytecode
 *
 * PUSH0 (0x5f): Push zero (Shanghai+), costs 2 gas
 * PUSH1-PUSH32 (0x60-0x7f): Push N bytes from bytecode, costs 3 gas
 *
 * @param frame - Execution frame
 * @param opcode - The PUSH opcode (0x5f to 0x7f)
 * @throws {EvmError} InvalidOpcode if PUSH0 used before Shanghai hardfork
 * @throws {EvmError} InvalidPush if bytecode has insufficient bytes
 * @throws {EvmError} OutOfGas if insufficient gas
 * @throws {EvmError} StackOverflow if stack is full
 */
export function push(frame: FrameInterface, opcode: number): void {
  const pushSize = opcode - 0x5f;

  // EIP-3855: PUSH0 was introduced in Shanghai hardfork
  if (pushSize === 0) {
    if (frame.hardfork < Hardfork.SHANGHAI) {
      throw new EvmError(CallError.InvalidOpcode, 'PUSH0 requires Shanghai hardfork');
    }
    frame.consumeGas(BigInt(GAS_QUICKSTEP));
    frame.pushStack(0n);
    frame.pc += 1;
  } else {
    frame.consumeGas(BigInt(GAS_FASTESTSTEP));

    // Read immediate bytes from bytecode
    const value = frame.readImmediate(pushSize);
    if (value === null) {
      throw new EvmError(CallError.InvalidPush, `PUSH${pushSize} has insufficient bytecode`);
    }

    frame.pushStack(value);
    frame.pc += 1 + pushSize;
  }
}

/**
 * DUP1-DUP16 opcodes (0x80-0x8f) - Duplicate stack item at position n
 * DUP1 duplicates top item, DUP2 duplicates second item, etc.
 * Gas cost: 3 (GasFastestStep)
 *
 * @param frame - Execution frame
 * @param opcode - The DUP opcode (0x80 to 0x8f)
 * @throws {EvmError} StackUnderflow if stack has fewer than n items
 * @throws {EvmError} OutOfGas if insufficient gas
 * @throws {EvmError} StackOverflow if stack is full after duplication
 */
export function dup(frame: FrameInterface, opcode: number): void {
  frame.consumeGas(BigInt(GAS_FASTESTSTEP));

  const n = opcode - 0x7f; // DUP1=1, DUP2=2, ..., DUP16=16
  if (frame.stack.length < n) {
    throw new EvmError(
      CallError.StackUnderflow,
      `DUP${n} requires ${n} items on stack, found ${frame.stack.length}`
    );
  }

  // Duplicate the nth item from the top (1-indexed)
  const value = frame.stack[frame.stack.length - n];
  frame.pushStack(value);
  frame.pc += 1;
}

/**
 * SWAP1-SWAP16 opcodes (0x90-0x9f) - Swap top stack item with item at position n+1
 * SWAP1 swaps top with second, SWAP2 swaps top with third, etc.
 * Gas cost: 3 (GasFastestStep)
 *
 * @param frame - Execution frame
 * @param opcode - The SWAP opcode (0x90 to 0x9f)
 * @throws {EvmError} StackUnderflow if stack has fewer than n+1 items
 * @throws {EvmError} OutOfGas if insufficient gas
 */
export function swap(frame: FrameInterface, opcode: number): void {
  frame.consumeGas(BigInt(GAS_FASTESTSTEP));

  const n = opcode - 0x8f; // SWAP1=1, SWAP2=2, ..., SWAP16=16
  if (frame.stack.length <= n) {
    throw new EvmError(
      CallError.StackUnderflow,
      `SWAP${n} requires ${n + 1} items on stack, found ${frame.stack.length}`
    );
  }

  // Swap top with the (n+1)th item from the top
  const topIdx = frame.stack.length - 1;
  const swapIdx = frame.stack.length - 1 - n;
  const temp = frame.stack[topIdx];
  frame.stack[topIdx] = frame.stack[swapIdx];
  frame.stack[swapIdx] = temp;
  frame.pc += 1;
}
