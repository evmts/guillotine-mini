/**
 * Guillotine Mini - TypeScript EVM Library
 *
 * Minimal, correct, and well-tested Ethereum Virtual Machine implementation.
 * Prioritizes specification compliance, clarity, and hardfork support.
 *
 * @packageDocumentation
 */

/**
 * Library version
 */
export const VERSION = '0.1.0';

// ============================================================================
// Core Classes
// ============================================================================

/**
 * Main EVM orchestrator - manages state, storage, gas refunds, nested calls
 * @see {@link Evm}
 */
export { Evm, BlockContext, ForkTransition, ZERO_ADDRESS } from './evm.js';

/**
 * Bytecode interpreter - handles stack, memory, PC, opcode execution
 * @see {@link Frame}
 */
export {
  Frame,
  FrameParams,
  Hardfork as FrameHardfork,
  HardforkUtils,
  GasConstants,
} from './frame.js';

/**
 * Storage manager - persistent storage, transient storage (EIP-1153), original storage tracking
 * @see {@link Storage}
 */
export {
  Storage,
  StorageKey,
  AsyncDataRequest,
  StorageInjector,
} from './storage.js';

/**
 * EIP-2929 warm/cold access tracking
 * @see {@link AccessListManager}
 */
export { AccessListManager, AccessListSnapshot } from './access-list-manager.js';

/**
 * Bytecode analysis and jump destination tracking
 * @see {@link Bytecode}
 */
export { Bytecode } from './bytecode.js';

// ============================================================================
// Types and Interfaces
// ============================================================================

/**
 * Call parameter types for all EVM operations
 * @see {@link CallParamsUnion}
 */
export type {
  CallParamsUnion,
  CallParams,
  CallCodeParams,
  DelegateCallParams,
  StaticCallParams,
  CreateParams,
  Create2Params,
} from './call-params.js';

/**
 * Call parameter utilities and validation
 */
export {
  validate,
  getGas,
  setGas,
  getCaller,
  getInput,
  hasValue,
  isReadOnly,
  isCreate,
  getTo,
  clone,
  MAX_INITCODE_SIZE,
  MAX_INPUT_SIZE,
  ValidationError,
  GasZeroError,
  InvalidInputSizeError,
  InvalidInitCodeSizeError,
} from './call-params.js';

/**
 * Call result types
 * @see {@link CallResult}
 */
export type {
  CallResult,
  Log,
  SelfDestructRecord,
  StorageAccess,
  StorageRead,
  StorageWrite,
  TraceStep,
  ExecutionTrace,
} from './call-result.js';

/**
 * Call result helpers
 */
export {
  CallResultHelpers,
  successWithOutput,
  successEmpty,
  failure,
  failureWithError,
  revertWithData,
  successWithLogs,
  isSuccess,
  isFailure,
  hasOutput,
  gasConsumed,
  emptyTrace,
  ZERO_ADDRESS as CALL_RESULT_ZERO_ADDRESS,
} from './call-result.js';

/**
 * Host interface for external state backends
 * @see {@link HostInterface}
 */
export type { HostInterface, Address } from './host.js';

/**
 * Address utilities
 */
export { addressFromHex, addressToHex, addressEquals } from './host.js';

/**
 * EVM configuration and hardfork management
 * @see {@link EvmConfig}
 */
export type {
  EvmConfig,
  PrecompileOutput,
  PrecompileOverride,
  OpcodeOverride,
} from './evm-config.js';

/**
 * EVM configuration utilities
 */
export {
  Hardfork,
  DEFAULT_HARDFORK,
  DEFAULT_CONFIG,
  createConfig,
  parseHardfork,
  isAtLeast,
  isBefore,
  ConfigPresets,
} from './evm-config.js';

// ============================================================================
// Error Types
// ============================================================================

/**
 * Error types for EVM execution
 * @see {@link CallError}
 */
export { CallError, EvmError } from './errors.js';

// ============================================================================
// Utilities
// ============================================================================

/**
 * BigInt utilities for EVM operations
 * @module bigint
 */
export {
  // Constants
  MAX_U256,
  MAX_U128,
  MAX_U64,
  MAX_U32,
  MIN_SIGNED_256,
  MAX_SIGNED_256,

  // Wrapping operations
  wrap256,
  wrap128,
  wrap64,
  wrap32,
  toU256,

  // Modular arithmetic
  addMod256,
  subMod256,
  mulMod256,
  divMod256,
  modMod256,

  // Signed/unsigned conversions
  isNegative,
  toSigned,
  toUnsigned,
  abs256,

  // Signed arithmetic
  sdivMod256,
  smodMod256,

  // Comparison helpers
  slt,
  sgt,
} from './utils/bigint.js';

/**
 * Memory expansion utilities
 * @module memory
 */
export {
  wordCount,
  wordAlignedSize,
  memoryGasCost,
  calculateMemoryExpansionCost,
  expandMemory,
  readMemory,
  writeMemory,
  copyMemory,
} from './utils/memory.js';

/**
 * Opcode constants and utilities
 * @module opcode
 */
export {
  // Arithmetic operations
  STOP,
  ADD,
  MUL,
  SUB,
  DIV,
  SDIV,
  MOD,
  SMOD,
  ADDMOD,
  MULMOD,
  EXP,
  SIGNEXTEND,

  // Comparison operations
  LT,
  GT,
  SLT,
  SGT,
  EQ,
  ISZERO,

  // Bitwise operations
  AND,
  OR,
  XOR,
  NOT,
  BYTE,
  SHL,
  SHR,
  SAR,

  // Hash operations
  KECCAK256,

  // Context operations
  ADDRESS,
  BALANCE,
  ORIGIN,
  CALLER,
  CALLVALUE,
  CALLDATALOAD,
  CALLDATASIZE,
  CALLDATACOPY,
  CODESIZE,
  CODECOPY,
  GASPRICE,
  EXTCODESIZE,
  EXTCODECOPY,
  RETURNDATASIZE,
  RETURNDATACOPY,
  EXTCODEHASH,

  // Block operations
  BLOCKHASH,
  COINBASE,
  TIMESTAMP,
  NUMBER,
  DIFFICULTY,
  GASLIMIT,
  CHAINID,
  SELFBALANCE,
  BASEFEE,
  BLOBHASH,
  BLOBBASEFEE,

  // Stack, memory, and storage operations
  POP,
  MLOAD,
  MSTORE,
  MSTORE8,
  SLOAD,
  SSTORE,
  JUMP,
  JUMPI,
  PC,
  MSIZE,
  GAS,
  JUMPDEST,
  TLOAD,
  TSTORE,
  MCOPY,

  // PUSH operations
  PUSH0,
  PUSH1,
  PUSH2,
  PUSH3,
  PUSH4,
  PUSH5,
  PUSH6,
  PUSH7,
  PUSH8,
  PUSH9,
  PUSH10,
  PUSH11,
  PUSH12,
  PUSH13,
  PUSH14,
  PUSH15,
  PUSH16,
  PUSH17,
  PUSH18,
  PUSH19,
  PUSH20,
  PUSH21,
  PUSH22,
  PUSH23,
  PUSH24,
  PUSH25,
  PUSH26,
  PUSH27,
  PUSH28,
  PUSH29,
  PUSH30,
  PUSH31,
  PUSH32,

  // DUP operations
  DUP1,
  DUP2,
  DUP3,
  DUP4,
  DUP5,
  DUP6,
  DUP7,
  DUP8,
  DUP9,
  DUP10,
  DUP11,
  DUP12,
  DUP13,
  DUP14,
  DUP15,
  DUP16,

  // SWAP operations
  SWAP1,
  SWAP2,
  SWAP3,
  SWAP4,
  SWAP5,
  SWAP6,
  SWAP7,
  SWAP8,
  SWAP9,
  SWAP10,
  SWAP11,
  SWAP12,
  SWAP13,
  SWAP14,
  SWAP15,
  SWAP16,

  // LOG operations
  LOG0,
  LOG1,
  LOG2,
  LOG3,
  LOG4,

  // System operations
  CREATE,
  CALL,
  CALLCODE,
  RETURN,
  DELEGATECALL,
  CREATE2,
  STATICCALL,
  REVERT,
  INVALID,
  SELFDESTRUCT,

  // Utilities
  getOpName,
} from './opcode.js';

// ============================================================================
// Re-exports from external libraries
// ============================================================================

/**
 * Re-export commonly used external utilities
 * (Actual implementation depends on your build setup)
 */

// Note: The library currently has dependencies on:
// - @noble/hashes (for keccak256)
// - ox (for various utilities)
// These should be properly typed and re-exported as needed

// ============================================================================
// Default Export
// ============================================================================

/**
 * Default export with all core classes
 */
export default {
  VERSION,
  Evm,
  Frame,
  Storage,
  AccessListManager,
  Bytecode,
  Hardfork,
  CallError,
  EvmError,
};
