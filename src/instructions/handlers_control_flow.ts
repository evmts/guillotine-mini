/**
 * Control flow opcode handlers for the EVM
 *
 * This module implements control flow operations including:
 * - STOP: Halts execution
 * - JUMP: Unconditional jump to JUMPDEST
 * - JUMPI: Conditional jump if condition != 0
 * - JUMPDEST: Jump destination marker (no-op)
 * - PC: Returns current program counter
 * - GAS: Returns remaining gas
 * - RETURN: Halts execution and returns output data
 * - REVERT: Halts execution and reverts state changes
 *
 * Port of src/instructions/handlers_control_flow.zig to TypeScript
 */

import { Bytecode } from '../bytecode';
import { CallError, EvmError } from '../errors';
import { GasConstants } from '../utils/voltaire-imports';

/**
 * Frame interface that must be implemented by the execution context
 * This defines the minimal interface needed for control flow operations
 */
export interface Frame {
  /** Program counter */
  pc: number;

  /** Execution stopped flag */
  stopped: boolean;

  /** Execution reverted flag */
  reverted: boolean;

  /** Bytecode being executed */
  bytecode: Bytecode;

  /** Output data */
  output: Uint8Array;

  /** Current memory size (in bytes, word-aligned) */
  memory_size: number;

  /** Consume gas for operation */
  consumeGas(amount: bigint): void;

  /** Pop value from stack */
  popStack(): bigint;

  /** Push value to stack */
  pushStack(value: bigint): void;

  /** Read byte from memory at address */
  readMemory(address: number): number;

  /** Calculate memory expansion cost */
  memoryExpansionCost(endBytes: bigint): bigint;

  /** Get reference to EVM (for hardfork checks) */
  getEvm(): { hardfork: { isBefore: (fork: string) => boolean } };
}

/**
 * STOP opcode (0x00) - Halts execution
 * Gas: 0
 */
export function stop(frame: Frame): void {
  frame.stopped = true;
}

/**
 * JUMP opcode (0x56) - Unconditional jump
 * Gas: 8 (GasMidStep)
 *
 * Pops destination from stack and jumps to it if it's a valid JUMPDEST
 */
export function jump(frame: Frame): void {
  frame.consumeGas(GasConstants.G_MID);
  const dest = frame.popStack();

  // Convert to u32, checking for overflow
  if (dest > 0xFFFFFFFFn) {
    throw new EvmError(CallError.OutOfBounds);
  }
  const dest_pc = Number(dest);

  // Validate jump destination
  if (!frame.bytecode.isValidJumpDest(dest_pc)) {
    throw new EvmError(CallError.InvalidJump);
  }

  frame.pc = dest_pc;
}

/**
 * JUMPI opcode (0x57) - Conditional jump
 * Gas: 10 (GasSlowStep)
 *
 * Stack: [dest, condition, ...] (top to bottom after pops)
 * Pops destination first, then condition.
 * Jumps to destination if condition != 0, otherwise continues to next instruction
 */
export function jumpi(frame: Frame): void {
  frame.consumeGas(GasConstants.G_HIGH);
  const dest = frame.popStack();       // Pop destination first (top of stack)
  const condition = frame.popStack();  // Pop condition second

  if (condition !== 0n) {
    // Convert to u32, checking for overflow
    if (dest > 0xFFFFFFFFn) {
      throw new EvmError(CallError.OutOfBounds);
    }
    const dest_pc = Number(dest);

    // Validate jump destination
    if (!frame.bytecode.isValidJumpDest(dest_pc)) {
      throw new EvmError(CallError.InvalidJump);
    }

    frame.pc = dest_pc;
  } else {
    // Don't jump, just increment PC
    frame.pc += 1;
  }
}

/**
 * JUMPDEST opcode (0x5b) - Jump destination marker
 * Gas: 1 (JumpdestGas)
 *
 * This is a no-op that marks a valid jump destination.
 * The actual validation happens during bytecode analysis.
 */
export function jumpdest(frame: Frame): void {
  frame.consumeGas(GasConstants.G_JUMPDEST);
  frame.pc += 1;
}

/**
 * PC opcode (0x58) - Get program counter
 * Gas: 2 (GasQuickStep)
 *
 * Pushes the current program counter value onto the stack
 */
export function pc(frame: Frame): void {
  frame.consumeGas(GasConstants.G_BASE);
  frame.pushStack(BigInt(frame.pc));
  frame.pc += 1;
}

/**
 * GAS opcode (0x5a) - Get remaining gas
 * Gas: 2 (GasQuickStep)
 *
 * Note: This is implemented in the Frame itself since it needs access to gas_left
 * This is a placeholder that should be implemented by the Frame
 *
 * @throws Error if not implemented by Frame
 */
export function gas(frame: Frame): void {
  throw new Error('GAS opcode must be implemented by Frame (requires access to gas_left)');
}

/**
 * RETURN opcode (0xf3) - Halt execution and return output data
 * Gas: Memory expansion cost
 *
 * Pops offset and length from stack, copies that memory region to output,
 * and halts execution with success
 */
export function ret(frame: Frame): void {
  const offset = frame.popStack();
  const length = frame.popStack();

  if (length > 0n) {
    // Convert to u32, checking for overflow
    if (offset > 0xFFFFFFFFn || length > 0xFFFFFFFFn) {
      throw new EvmError(CallError.OutOfBounds);
    }
    const off = Number(offset);
    const len = Number(length);

    // Check if off + len would overflow
    const end_offset = off + len;
    if (end_offset < off) {
      throw new EvmError(CallError.OutOfBounds);
    }

    // Charge memory expansion for the return slice
    const end_bytes = BigInt(off) + BigInt(len);
    const mem_cost = frame.memoryExpansionCost(end_bytes);
    frame.consumeGas(mem_cost);

    // Update memory size if needed
    const aligned_size = wordAlignedSize(end_bytes);
    if (aligned_size > frame.memory_size) {
      frame.memory_size = aligned_size;
    }

    // Copy memory to output
    const output = new Uint8Array(len);
    for (let idx = 0; idx < len; idx++) {
      const addr = off + idx;
      output[idx] = frame.readMemory(addr);
    }
    frame.output = output;
  }

  frame.stopped = true;
}

/**
 * REVERT opcode (0xfd) - Halt execution and revert state changes
 * Gas: Memory expansion cost
 *
 * Introduced in Byzantium (EIP-140)
 * Pops offset and length from stack, copies that memory region to output,
 * and halts execution with revert flag set
 */
export function revert(frame: Frame): void {
  // EIP-140: REVERT was introduced in Byzantium hardfork
  const evm = frame.getEvm();
  if (evm.hardfork.isBefore('Byzantium')) {
    throw new EvmError(CallError.InvalidOpcode);
  }

  const offset = frame.popStack();
  const length = frame.popStack();

  if (length > 0n) {
    // Convert to u32, checking for overflow
    if (offset > 0xFFFFFFFFn || length > 0xFFFFFFFFn) {
      throw new EvmError(CallError.OutOfBounds);
    }
    const off = Number(offset);
    const len = Number(length);

    // Charge memory expansion for the revert slice
    const end_bytes = BigInt(off) + BigInt(len);
    const mem_cost = frame.memoryExpansionCost(end_bytes);
    frame.consumeGas(mem_cost);

    // Update memory size if needed
    const aligned_size = wordAlignedSize(end_bytes);
    if (aligned_size > frame.memory_size) {
      frame.memory_size = aligned_size;
    }

    // Copy memory to output
    const output = new Uint8Array(len);
    for (let idx = 0; idx < len; idx++) {
      const addr = off + idx;
      output[idx] = frame.readMemory(addr);
    }
    frame.output = output;
  }

  frame.reverted = true;
}

// Helper functions

/**
 * Calculate word count from byte count
 * Words are 32 bytes each, rounded up
 */
function wordCount(bytes: bigint): bigint {
  return (bytes + 31n) / 32n;
}

/**
 * Calculate word-aligned size
 * Returns size in bytes, aligned to 32-byte boundaries
 */
function wordAlignedSize(bytes: bigint): number {
  const words = wordCount(bytes);
  return Number(words * 32n);
}
