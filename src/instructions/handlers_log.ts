/**
 * Log opcode handlers for the EVM (LOG0-LOG4)
 *
 * Implements event logging opcodes with full EIP support:
 * - EIP-214: Static call context restrictions
 * - Event emission with indexed topics (0-4)
 * - Memory expansion and gas metering
 *
 * Port of src/instructions/handlers_log.zig to TypeScript
 */

import { CallError, EvmError } from '../errors';

/**
 * Gas constants for LOG operations
 * Must match primitives/gas_constants.zig exactly
 */
export const GasConstants = {
  LogGas: 375n,           // Base cost for LOG operation
  LogTopicGas: 375n,      // Cost per indexed topic
  LogDataGas: 8n,         // Cost per byte of data
} as const;

/**
 * Address type - 20 bytes
 */
export type Address = Uint8Array;

/**
 * Log entry structure for EVM events
 * Matches call_result.zig::Log
 */
export interface Log {
  address: Address;
  topics: bigint[];
  data: Uint8Array;
}

/**
 * EVM interface (subset needed for log handlers)
 * Provides access to logs array
 */
export interface EvmInterface {
  logs: Log[];
}

/**
 * Frame interface (subset needed for log handlers)
 * Represents a single execution context (stack, memory, PC, gas)
 */
export interface FrameInterface {
  // Stack operations
  popStack(): bigint;

  // Gas management
  gas_remaining: bigint;
  consumeGas(amount: bigint): void;

  // Memory operations
  readMemory(offset: number): number;
  memoryExpansionCost(endBytes: bigint): bigint;
  memory_size: number;

  // Context
  address: Address;
  is_static: boolean;
  pc: number;

  // EVM access
  getEvm(): EvmInterface;
}

/**
 * Calculate LOG operation gas cost
 *
 * Formula: 375 + 375*topic_count + 8*data_size
 *
 * @param topic_count - Number of indexed topics (0-4)
 * @param data_size - Size of event data in bytes
 * @returns Total gas cost for LOG operation
 */
export function logGasCost(topic_count: number, data_size: number): bigint {
  const base_cost = GasConstants.LogGas;
  const topic_cost = BigInt(topic_count) * GasConstants.LogTopicGas;
  const data_cost = BigInt(data_size) * GasConstants.LogDataGas;
  return base_cost + topic_cost + data_cost;
}

/**
 * Calculate word count (32-byte words) for memory size calculations
 *
 * @param bytes - Number of bytes
 * @returns Number of 32-byte words (rounded up)
 */
export function wordCount(bytes: bigint): bigint {
  return (bytes + 31n) / 32n;
}

/**
 * Calculate word-aligned memory size for EVM compliance
 * Memory is always aligned to 32-byte word boundaries
 *
 * @param bytes - Number of bytes
 * @returns Word-aligned size (multiple of 32)
 */
export function wordAlignedSize(bytes: bigint): number {
  const words = wordCount(bytes);
  return Number(words * 32n);
}

/**
 * LOG0-LOG4 opcodes (0xa0-0xa4) - Emit log entries with 0-4 indexed topics
 *
 * Opcodes:
 * - LOG0 (0xa0): No indexed topics
 * - LOG1 (0xa1): 1 indexed topic
 * - LOG2 (0xa2): 2 indexed topics
 * - LOG3 (0xa3): 3 indexed topics
 * - LOG4 (0xa4): 4 indexed topics
 *
 * Gas cost: 375 + 375*topic_count + 8*data_size + memory_expansion
 *
 * Stack:
 * - Input: [offset, length, topic0?, topic1?, topic2?, topic3?]
 * - Output: []
 *
 * Behavior:
 * - Reads data from memory at [offset, offset+length)
 * - Pops topic_count topics from stack (in reverse order)
 * - Appends log entry to EVM logs array
 * - Charges gas for operation and memory expansion
 *
 * Errors:
 * - StaticCallViolation: If is_static is true (EIP-214)
 * - OutOfGas: If insufficient gas
 * - OutOfBounds: If offset or length exceed u32 range
 *
 * @param frame - Execution frame
 * @param opcode - Opcode byte (0xa0-0xa4) to determine topic count
 */
export function log(frame: FrameInterface, opcode: number): void {
  // EIP-214: LOG opcodes cannot be executed in static call context
  if (frame.is_static) {
    throw new EvmError(CallError.StaticCallViolation);
  }

  const topic_count = opcode - 0xa0;
  const offset = frame.popStack();
  const length = frame.popStack();

  // Validate offset and length fit in u32 range
  if (offset > 0xffffffffn) {
    throw new EvmError(CallError.OutOfBounds);
  }
  if (length > 0xffffffffn) {
    throw new EvmError(CallError.OutOfBounds);
  }

  const off_u32 = Number(offset);
  const length_u32 = Number(length);

  // Gas cost for LOG operation
  const log_cost = logGasCost(topic_count, length_u32);
  frame.consumeGas(log_cost);

  // Memory expansion cost (if needed)
  if (length_u32 > 0) {
    const end_bytes = BigInt(off_u32) + BigInt(length_u32);
    const mem_cost = frame.memoryExpansionCost(end_bytes);
    frame.consumeGas(mem_cost);

    // Update memory size if expanded
    const aligned = wordAlignedSize(end_bytes);
    if (aligned > frame.memory_size) {
      frame.memory_size = aligned;
    }
  }

  const evm = frame.getEvm();

  // Pop topics from stack (in order: topic0, topic1, topic2, topic3)
  // Topics are indexed parameters of the event
  const topics: bigint[] = [];
  for (let i = 0; i < topic_count; i++) {
    topics.push(frame.popStack());
  }

  // Read data from memory
  let data: Uint8Array;
  if (length_u32 > 0) {
    data = new Uint8Array(length_u32);
    for (let i = 0; i < length_u32; i++) {
      data[i] = frame.readMemory(off_u32 + i);
    }
  } else {
    data = new Uint8Array(0);
  }

  // Append log entry to EVM logs array
  const log_entry: Log = {
    address: frame.address,
    topics,
    data,
  };
  evm.logs.push(log_entry);

  frame.pc += 1;
}

/**
 * LOG0 opcode (0xa0) - Emit log with 0 indexed topics
 *
 * Stack: [offset, length] -> []
 *
 * @param frame - Execution frame
 */
export function log0(frame: FrameInterface): void {
  log(frame, 0xa0);
}

/**
 * LOG1 opcode (0xa1) - Emit log with 1 indexed topic
 *
 * Stack: [offset, length, topic0] -> []
 *
 * @param frame - Execution frame
 */
export function log1(frame: FrameInterface): void {
  log(frame, 0xa1);
}

/**
 * LOG2 opcode (0xa2) - Emit log with 2 indexed topics
 *
 * Stack: [offset, length, topic0, topic1] -> []
 *
 * @param frame - Execution frame
 */
export function log2(frame: FrameInterface): void {
  log(frame, 0xa2);
}

/**
 * LOG3 opcode (0xa3) - Emit log with 3 indexed topics
 *
 * Stack: [offset, length, topic0, topic1, topic2] -> []
 *
 * @param frame - Execution frame
 */
export function log3(frame: FrameInterface): void {
  log(frame, 0xa3);
}

/**
 * LOG4 opcode (0xa4) - Emit log with 4 indexed topics
 *
 * Stack: [offset, length, topic0, topic1, topic2, topic3] -> []
 *
 * @param frame - Execution frame
 */
export function log4(frame: FrameInterface): void {
  log(frame, 0xa4);
}
