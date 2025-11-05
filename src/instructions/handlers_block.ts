/**
 * Block context opcode handlers for the EVM
 * Port of src/instructions/handlers_block.zig to TypeScript
 *
 * This module provides handlers for opcodes that read from the blockchain context:
 * - BLOCKHASH (0x40): Hash of recent blocks (last 256 only)
 * - COINBASE (0x41): Block beneficiary address
 * - TIMESTAMP (0x42): Block timestamp (Unix epoch)
 * - NUMBER (0x43): Current block number
 * - DIFFICULTY/PREVRANDAO (0x44): Pre-Merge: difficulty, Post-Merge: prevrandao
 * - GASLIMIT (0x45): Block gas limit
 * - CHAINID (0x46): Chain ID (EIP-1344, Istanbul+)
 * - SELFBALANCE (0x47): Balance of executing contract (EIP-1884, Istanbul+)
 * - BASEFEE (0x48): Base fee per gas (EIP-3198, London+)
 * - BLOBHASH (0x49): Blob versioned hash (EIP-4844, Cancun+)
 * - BLOBBASEFEE (0x4a): Blob base fee (EIP-7516, Cancun+)
 */

import { CallError, EvmError } from '../errors';

/**
 * Gas constants for block operations
 * These must match src/primitives/gas_constants.zig
 */
const GasConstants = {
  GasQuickStep: 2n,      // G_BASE (COINBASE, TIMESTAMP, NUMBER, etc.)
  GasExtStep: 20n,       // BLOCKHASH
  GasFastStep: 5n,       // SELFBALANCE
  GasFastestStep: 3n,    // BLOBHASH
};

/**
 * Hardfork enum for feature detection
 * Matches src/hardfork.zig
 */
export enum Hardfork {
  FRONTIER = 0,
  HOMESTEAD,
  TANGERINE,
  SPURIOUS,
  BYZANTIUM,
  CONSTANTINOPLE,
  ISTANBUL,
  BERLIN,
  LONDON,
  MERGE,
  SHANGHAI,
  CANCUN,
  PRAGUE,
}

/**
 * Block context - contains blockchain-level state
 * Read-only for EVM execution
 */
export interface BlockContext {
  block_number: bigint;           // Current block number
  block_timestamp: bigint;        // Block timestamp (Unix seconds)
  block_coinbase: Uint8Array;     // Beneficiary address (20 bytes)
  block_difficulty: bigint;       // Pre-Merge: PoW difficulty
  block_prevrandao: bigint;       // Post-Merge: beacon chain randomness
  block_gas_limit: bigint;        // Maximum gas for block
  block_base_fee: bigint;         // EIP-1559 base fee per gas
  chain_id: bigint;               // Chain identifier
  block_hashes: Uint8Array[];     // Recent block hashes (last 256)
  blob_base_fee: bigint;          // EIP-4844 blob base fee
}

/**
 * EVM interface required by block handlers
 */
export interface EvmInterface {
  block_context: BlockContext;
  hardfork: Hardfork;
  blob_versioned_hashes: Uint8Array[];  // EIP-4844 blob hashes
  get_balance(address: Uint8Array): bigint;
}

/**
 * Frame interface required by block handlers
 * The FrameType must have methods: consumeGas, popStack, pushStack
 * and fields: pc (program counter), address, evm (EVM context)
 */
export interface FrameInterface {
  pc: number;
  address: Uint8Array;
  consumeGas(amount: bigint): void;
  popStack(): bigint;
  pushStack(value: bigint): void;
  getEvm(): EvmInterface;
}

/**
 * BLOCKHASH opcode (0x40) - Get hash of recent block
 * Per Python reference (cancun/vm/instructions/block.py:21-64):
 * - Charges GAS_BLOCK_HASH (20 gas)
 * - Returns hash of one of the 256 most recent complete blocks
 * - Returns 0 if block number is out of range (too old or >= current)
 * - Access block_hashes with negative index: [-(current - target)]
 */
export function blockhash(frame: FrameInterface): void {
  const evm = frame.getEvm();
  // GAS_BLOCK_HASH = 20 (GasExtStep)
  frame.consumeGas(GasConstants.GasExtStep);

  const block_number = frame.popStack();
  const current_block = evm.block_context.block_number;

  // Per Python reference (block.py:46-59):
  // Return 0 if:
  // 1. Requested block >= current block
  // 2. Requested block is more than 256 blocks old
  const max_block_number = block_number + 256n;
  if (block_number >= current_block || current_block > max_block_number) {
    // Out of range - return zero
    frame.pushStack(0n);
  } else {
    // In range - get hash from block_hashes array
    // Per Python: block_hashes[-(current_block - block_number)]
    const index = Number(current_block - block_number);

    if (index > 0 && index <= evm.block_context.block_hashes.length) {
      // Access with negative index: block_hashes[-(current - target)]
      const actual_index = evm.block_context.block_hashes.length - index;
      const block_hash = evm.block_context.block_hashes[actual_index];

      // Convert 32-byte hash to u256
      let hash_value = 0n;
      for (const byte of block_hash) {
        hash_value = (hash_value << 8n) | BigInt(byte);
      }
      frame.pushStack(hash_value);
    } else {
      // Hash not available - return zero
      frame.pushStack(0n);
    }
  }
  frame.pc += 1;
}

/**
 * COINBASE opcode (0x41) - Get block coinbase address
 * Returns the beneficiary address for the current block
 */
export function coinbase(frame: FrameInterface): void {
  const evm = frame.getEvm();
  frame.consumeGas(GasConstants.GasQuickStep);

  // Convert 20-byte address to u256
  const coinbase_bytes = evm.block_context.block_coinbase;
  let coinbase_u256 = 0n;
  for (const byte of coinbase_bytes) {
    coinbase_u256 = (coinbase_u256 << 8n) | BigInt(byte);
  }

  frame.pushStack(coinbase_u256);
  frame.pc += 1;
}

/**
 * TIMESTAMP opcode (0x42) - Get block timestamp
 * Returns the current block's timestamp (Unix epoch seconds)
 */
export function timestamp(frame: FrameInterface): void {
  const evm = frame.getEvm();
  frame.consumeGas(GasConstants.GasQuickStep);
  frame.pushStack(evm.block_context.block_timestamp);
  frame.pc += 1;
}

/**
 * NUMBER opcode (0x43) - Get block number
 * Returns the current block number
 */
export function number(frame: FrameInterface): void {
  const evm = frame.getEvm();
  frame.consumeGas(GasConstants.GasQuickStep);
  frame.pushStack(evm.block_context.block_number);
  frame.pc += 1;
}

/**
 * DIFFICULTY/PREVRANDAO opcode (0x44) - Get block difficulty or prevrandao
 * Pre-Merge: returns block difficulty (PoW)
 * Post-Merge: returns prevrandao value (beacon chain randomness)
 */
export function difficulty(frame: FrameInterface): void {
  const evm = frame.getEvm();
  frame.consumeGas(GasConstants.GasQuickStep);

  if (evm.hardfork >= Hardfork.MERGE) {
    frame.pushStack(evm.block_context.block_prevrandao);
  } else {
    frame.pushStack(evm.block_context.block_difficulty);
  }

  frame.pc += 1;
}

/**
 * GASLIMIT opcode (0x45) - Get block gas limit
 * Returns the maximum gas allowed for the current block
 */
export function gaslimit(frame: FrameInterface): void {
  const evm = frame.getEvm();
  frame.consumeGas(GasConstants.GasQuickStep);
  frame.pushStack(evm.block_context.block_gas_limit);
  frame.pc += 1;
}

/**
 * CHAINID opcode (0x46) - Get chain ID (EIP-1344, Istanbul+)
 * Returns the chain identifier (e.g., 1 for mainnet, 5 for goerli)
 * @throws {EvmError} InvalidOpcode if hardfork < Istanbul
 */
export function chainid(frame: FrameInterface): void {
  const evm = frame.getEvm();

  // EIP-1344: CHAINID was introduced in Istanbul hardfork
  if (evm.hardfork < Hardfork.ISTANBUL) {
    throw new EvmError(CallError.InvalidOpcode, 'CHAINID not available before Istanbul');
  }

  frame.consumeGas(GasConstants.GasQuickStep);
  frame.pushStack(evm.block_context.chain_id);
  frame.pc += 1;
}

/**
 * SELFBALANCE opcode (0x47) - Get balance of currently executing account (EIP-1884, Istanbul+)
 * More gas-efficient than ADDRESS + BALANCE (5 gas vs 2+700 gas)
 * @throws {EvmError} InvalidOpcode if hardfork < Istanbul
 */
export function selfbalance(frame: FrameInterface): void {
  const evm = frame.getEvm();

  // EIP-1884: SELFBALANCE was introduced in Istanbul hardfork
  if (evm.hardfork < Hardfork.ISTANBUL) {
    throw new EvmError(CallError.InvalidOpcode, 'SELFBALANCE not available before Istanbul');
  }

  frame.consumeGas(GasConstants.GasFastStep);
  const balance = evm.get_balance(frame.address);
  frame.pushStack(balance);
  frame.pc += 1;
}

/**
 * BASEFEE opcode (0x48) - Get base fee per gas (EIP-3198, London+)
 * Returns the current block's EIP-1559 base fee
 * @throws {EvmError} InvalidOpcode if hardfork < London
 */
export function basefee(frame: FrameInterface): void {
  const evm = frame.getEvm();

  // EIP-3198: BASEFEE was introduced in London hardfork
  if (evm.hardfork < Hardfork.LONDON) {
    throw new EvmError(CallError.InvalidOpcode, 'BASEFEE not available before London');
  }

  frame.consumeGas(GasConstants.GasQuickStep);
  frame.pushStack(evm.block_context.block_base_fee);
  frame.pc += 1;
}

/**
 * BLOBHASH opcode (0x49) - Get versioned blob hash (EIP-4844, Cancun+)
 * Per Python reference (cancun/vm/gas.py:68):
 * - GAS_BLOBHASH_OPCODE = 3 (same as GasFastestStep)
 * - Returns the blob hash at the given index
 * - Returns 0 if index is out of bounds
 * @throws {EvmError} InvalidOpcode if hardfork < Cancun
 */
export function blobhash(frame: FrameInterface): void {
  const evm = frame.getEvm();

  // EIP-4844: BLOBHASH was introduced in Cancun hardfork
  if (evm.hardfork < Hardfork.CANCUN) {
    throw new EvmError(CallError.InvalidOpcode, 'BLOBHASH not available before Cancun');
  }

  // GAS_BLOBHASH_OPCODE = 3 (GasFastestStep is correct)
  frame.consumeGas(GasConstants.GasFastestStep);
  const index = frame.popStack();

  // Return the blob hash at the given index, or 0 if out of bounds
  // Check if index can be represented as a number (not > Number.MAX_SAFE_INTEGER)
  let hash_value: bigint;
  if (index > BigInt(Number.MAX_SAFE_INTEGER)) {
    // Index too large, definitely out of bounds
    hash_value = 0n;
  } else {
    const index_num = Number(index);
    if (index_num < evm.blob_versioned_hashes.length) {
      // Convert the 32-byte blob hash to u256
      const blob_hash = evm.blob_versioned_hashes[index_num];
      hash_value = 0n;
      for (const byte of blob_hash) {
        hash_value = (hash_value << 8n) | BigInt(byte);
      }
    } else {
      // Index out of bounds, return 0
      hash_value = 0n;
    }
  }

  frame.pushStack(hash_value);
  frame.pc += 1;
}

/**
 * BLOBBASEFEE opcode (0x4a) - Get blob base fee (EIP-7516, Cancun+)
 * Per Python reference (cancun/vm/gas.py and BlobBaseFeeGas constant):
 * - GAS_BASE = 2 (same as GasQuickStep)
 * - Returns blob_base_fee calculated from excess_blob_gas
 * - Formula: fake_exponential(MIN_BLOB_GASPRICE, excess_blob_gas, BLOB_BASE_FEE_UPDATE_FRACTION)
 * @throws {EvmError} InvalidOpcode if hardfork < Cancun
 */
export function blobbasefee(frame: FrameInterface): void {
  const evm = frame.getEvm();

  // EIP-7516: BLOBBASEFEE was introduced in Cancun hardfork
  if (evm.hardfork < Hardfork.CANCUN) {
    throw new EvmError(CallError.InvalidOpcode, 'BLOBBASEFEE not available before Cancun');
  }

  // GAS_BASE = 2 (GasQuickStep is correct)
  frame.consumeGas(GasConstants.GasQuickStep);
  // blob_base_fee is pre-calculated from excess_blob_gas in BlockContext
  frame.pushStack(evm.block_context.blob_base_fee);
  frame.pc += 1;
}

/**
 * Block handlers namespace
 * Export all handlers in a single object for convenience
 */
export const BlockHandlers = {
  blockhash,
  coinbase,
  timestamp,
  number,
  difficulty,
  gaslimit,
  chainid,
  selfbalance,
  basefee,
  blobhash,
  blobbasefee,
};
