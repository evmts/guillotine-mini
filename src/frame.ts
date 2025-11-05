/**
 * Frame implementation for EVM bytecode execution
 *
 * This module provides the Frame class which represents a single execution context
 * in the EVM, managing:
 * - Stack operations (push/pop/peek/swap/dup)
 * - Memory operations (read/write/expansion)
 * - Program counter (PC) and gas tracking
 * - Bytecode interpretation and execution loop
 *
 * The Frame is the core bytecode interpreter, while the Evm (not yet ported) handles
 * state management, storage, and nested calls.
 */

import { Bytecode } from './bytecode';
import { CallError, EvmError } from './errors';
import type { Address } from './host';

// Import instruction handlers
import * as ArithmeticHandlers from './instructions/handlers_arithmetic';
import * as ComparisonHandlers from './instructions/handlers_comparison';
import * as BitwiseHandlers from './instructions/handlers_bitwise';
import * as KeccakHandlers from './instructions/handlers_keccak';
import * as ContextHandlers from './instructions/handlers_context';
import * as BlockHandlers from './instructions/handlers_block';
import * as StackHandlers from './instructions/handlers_stack';
import * as MemoryHandlers from './instructions/handlers_memory';
import * as StorageHandlers from './instructions/handlers_storage';
import * as ControlFlowHandlers from './instructions/handlers_control_flow';
import * as LogHandlers from './instructions/handlers_log';
import * as SystemHandlers from './instructions/handlers_system';

/**
 * Hardfork enumeration for protocol version detection
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
 * Hardfork utility methods
 */
export const HardforkUtils = {
  /**
   * Check if current hardfork is at least the specified version
   */
  isAtLeast(current: Hardfork, target: Hardfork): boolean {
    return current >= target;
  },

  /**
   * Check if current hardfork is before the specified version
   */
  isBefore(current: Hardfork, target: Hardfork): boolean {
    return current < target;
  },
};

/**
 * Gas constants for common operations
 */
export const GasConstants = {
  MemoryGas: 3,
  QuadCoeffDiv: 512,
  SelfdestructGas: 5000,
  SelfdestructRefundGas: 24000,
  CreateGas: 32000,
  InitcodeWordGas: 2,
  Keccak256Gas: 30,
  Keccak256WordGas: 6,
  CopyGas: 3,
  LogGas: 375,
  LogTopicGas: 375,
  LogDataGas: 8,
};

/**
 * Frame initialization parameters
 */
export interface FrameParams {
  /** Raw bytecode to execute */
  bytecode: Uint8Array;
  /** Initial gas available (signed for gas refunds) */
  gas: bigint;
  /** Address that initiated this call */
  caller: Address;
  /** Address being executed (contract address) */
  address: Address;
  /** Wei value transferred with this call */
  value: bigint;
  /** Input data for the call */
  calldata: Uint8Array;
  /** Opaque pointer to parent EVM instance (for nested calls) */
  evmPtr: unknown;
  /** Active hardfork for gas metering and feature flags */
  hardfork: Hardfork;
  /** Whether this is a static call (no state modifications allowed) */
  isStatic: boolean;
  /** EIP-7702 authorization (optional) */
  authorized?: bigint;
  /** Current call depth (for depth limit checks) */
  callDepth?: number;
}

/**
 * Frame represents a single execution context in the EVM
 *
 * Responsibilities:
 * - Stack management (LIFO, max 1024 items)
 * - Memory management (sparse, word-aligned expansion)
 * - Program counter (PC) tracking
 * - Gas consumption and tracking
 * - Bytecode interpretation (execute loop)
 * - Opcode dispatch to handlers
 *
 * Does NOT handle:
 * - Storage operations (delegated to EVM)
 * - Nested calls (delegated to EVM)
 * - State management (delegated to EVM)
 */
export class Frame {
  /** Stack of 256-bit unsigned integers (LIFO) */
  private readonly _stack: bigint[] = [];

  /** Sparse memory map (only stores non-zero bytes) */
  private readonly memory: Map<number, number> = new Map();

  /** Current memory size (word-aligned, 32-byte boundaries) */
  private memorySize: number = 0;

  /** Program counter (current bytecode position) */
  public pc: number = 0;

  /** Remaining gas (signed to allow negative during calculations) */
  public gasRemaining: bigint;

  /** Analyzed bytecode with jump destination metadata */
  public readonly bytecode: Bytecode;

  /** Address that initiated this call */
  public readonly caller: Address;

  /** Address being executed (contract address) */
  public readonly address: Address;

  /** Wei value transferred with this call */
  public readonly value: bigint;

  /** Input data for the call */
  public readonly calldata: Uint8Array;

  /** Output data (set by RETURN/REVERT) */
  public output: Uint8Array = new Uint8Array(0);

  /** Return data from last call/create (for RETURNDATASIZE/RETURNDATACOPY) */
  public returnData: Uint8Array = new Uint8Array(0);

  /** Whether execution has stopped (STOP/RETURN) */
  public stopped: boolean = false;

  /** Whether execution reverted (REVERT) */
  public reverted: boolean = false;

  /** Opaque pointer to parent EVM instance */
  private readonly evmPtr: unknown;

  /** EIP-7702 authorization */
  public readonly authorized: bigint | null;

  /** Current call depth */
  public readonly callDepth: number;

  /** Active hardfork */
  public readonly hardfork: Hardfork;

  /** Whether this is a static call */
  public readonly isStatic: boolean;

  /**
   * Initialize a new frame for bytecode execution
   *
   * Creates a new execution frame with the given parameters. Performs bytecode analysis
   * to identify valid jump destinations (JUMPDEST opcodes).
   */
  constructor(params: FrameParams) {
    this.gasRemaining = params.gas;
    this.bytecode = new Bytecode(params.bytecode);
    this.caller = params.caller;
    this.address = params.address;
    this.value = params.value;
    this.calldata = params.calldata;
    this.evmPtr = params.evmPtr;
    this.hardfork = params.hardfork;
    this.isStatic = params.isStatic;
    this.authorized = params.authorized ?? null;
    this.callDepth = params.callDepth ?? 0;
  }

  // ================================ STACK OPERATIONS ================================

  /**
   * Push value onto stack
   * @throws {EvmError} StackOverflow if stack exceeds 1024 items
   */
  pushStack(value: bigint): void {
    if (this._stack.length >= 1024) {
      throw new EvmError(CallError.StackOverflow);
    }
    this._stack.push(value);
  }

  /**
   * Pop value from stack
   * @throws {EvmError} StackUnderflow if stack is empty
   */
  popStack(): bigint {
    if (this._stack.length === 0) {
      throw new EvmError(CallError.StackUnderflow);
    }
    return this._stack.pop()!;
  }

  /**
   * Peek at stack value at given depth (0 = top)
   * @throws {EvmError} StackUnderflow if index out of bounds
   */
  peekStack(index: number): bigint {
    if (index >= this._stack.length) {
      throw new EvmError(CallError.StackUnderflow);
    }
    return this._stack[this._stack.length - 1 - index];
  }

  /**
   * Get stack as readonly array (for tracing/debugging)
   */
  get stack(): readonly bigint[] {
    return this._stack;
  }

  // ================================ MEMORY OPERATIONS ================================

  /**
   * Calculate word-aligned memory size for EVM compliance
   */
  private static wordAlignedSize(bytes: number): number {
    const words = Math.ceil(bytes / 32);
    return words * 32;
  }

  /**
   * Read byte from memory (returns 0 for uninitialized)
   */
  readMemory(offset: number): number {
    return this.memory.get(offset) ?? 0;
  }

  /**
   * Write byte to memory
   * @throws {EvmError} OutOfBounds if offset causes overflow
   */
  writeMemory(offset: number, value: number): void {
    this.memory.set(offset, value & 0xff);

    // EVM memory expands to word-aligned (32-byte) boundaries
    const endOffset = offset + 1;
    const wordAlignedSize = Frame.wordAlignedSize(endOffset);
    if (wordAlignedSize > this.memorySize) {
      this.memorySize = wordAlignedSize;
    }
  }

  /**
   * Get memory contents as a slice (for tracing)
   */
  getMemorySlice(): Uint8Array {
    if (this.memorySize === 0) {
      return new Uint8Array(0);
    }

    const memSlice = new Uint8Array(this.memorySize);
    for (let i = 0; i < this.memorySize; i++) {
      memSlice[i] = this.readMemory(i);
    }
    return memSlice;
  }

  // ================================ GAS OPERATIONS ================================

  /**
   * Consume gas
   * @throws {EvmError} OutOfGas if insufficient gas
   */
  consumeGas(amount: bigint): void {
    if (this.gasRemaining < amount) {
      this.gasRemaining = 0n;
      throw new EvmError(CallError.OutOfGas);
    }
    this.gasRemaining -= amount;
  }

  /**
   * Calculate memory expansion cost
   * The total memory cost for n words is: 3n + n²/512, where a word is 32 bytes.
   */
  memoryExpansionCost(endBytes: number): bigint {
    const currentSize = this.memorySize;

    if (endBytes <= currentSize) {
      return 0n;
    }

    // Cap memory size to prevent gas calculation overflow
    // Max reasonable memory is 16MB (0x1000000 bytes)
    const maxMemory = 0x1000000;
    if (endBytes > maxMemory) {
      return BigInt(Number.MAX_SAFE_INTEGER); // Return large value to trigger OutOfGas
    }

    const currentWords = Math.ceil(currentSize / 32);
    const newWords = Math.ceil(endBytes / 32);

    // Check for overflow in word * word calculation
    if (newWords > Number.MAX_SAFE_INTEGER / newWords) {
      return BigInt(Number.MAX_SAFE_INTEGER);
    }

    const currentWordsSquared = currentWords * currentWords;
    const newWordsSquared = newWords * newWords;

    // Calculate cost for each size
    const currentLinear = GasConstants.MemoryGas * currentWords;
    const currentQuadratic = Math.floor(currentWordsSquared / GasConstants.QuadCoeffDiv);
    const currentCost = currentLinear + currentQuadratic;

    const newLinear = GasConstants.MemoryGas * newWords;
    const newQuadratic = Math.floor(newWordsSquared / GasConstants.QuadCoeffDiv);
    const newCost = newLinear + newQuadratic;

    const expansionCost = newCost - currentCost;
    return BigInt(Math.max(0, expansionCost));
  }

  // ================================ GAS COST HELPERS ================================

  /**
   * Calculate gas cost for external account operations (EIP-150, EIP-1884, EIP-2929 aware)
   * Note: This returns 700 for Tangerine Whistle+ (EXTCODESIZE/EXTCODECOPY use this)
   * BALANCE and EXTCODEHASH have their own gas cost calculations
   *
   * NOTE: This method requires access to the EVM for warm/cold tracking (EIP-2929).
   * For now, we'll throw an error indicating this needs EVM integration.
   * @throws {Error} Not yet implemented (requires EVM integration)
   */
  externalAccountGasCost(_address: Address): bigint {
    // TODO: This requires EVM integration for warm/cold address tracking (EIP-2929)
    // For Berlin+: return evm.accessAddress(address) (cold=2600, warm=100)
    // For Tangerine Whistle-Berlin: return 700
    // For pre-Tangerine Whistle: return 20
    throw new Error('externalAccountGasCost requires EVM integration (not yet ported)');
  }

  /**
   * Calculate SELFDESTRUCT gas cost (EIP-150 aware)
   */
  selfdestructGasCost(): bigint {
    if (HardforkUtils.isBefore(this.hardfork, Hardfork.TANGERINE)) {
      return 0n; // Pre-EIP-150: Free operation
    }
    return BigInt(GasConstants.SelfdestructGas); // Post-EIP-150: 5000 gas
  }

  /**
   * Calculate SELFDESTRUCT refund (EIP-3529 aware)
   */
  selfdestructRefund(): bigint {
    if (HardforkUtils.isAtLeast(this.hardfork, Hardfork.LONDON)) {
      return 0n; // EIP-3529: No refund in London+
    }
    return BigInt(GasConstants.SelfdestructRefundGas); // Pre-London: 24,000 refund
  }

  /**
   * Calculate CREATE gas cost (EIP-3860 aware)
   */
  createGasCost(initCodeSize: number): bigint {
    let gasCost = BigInt(GasConstants.CreateGas); // Base 32,000 gas

    if (HardforkUtils.isAtLeast(this.hardfork, Hardfork.SHANGHAI)) {
      const wordCount = Math.ceil(initCodeSize / 32);
      gasCost += BigInt(wordCount * GasConstants.InitcodeWordGas);
    }

    return gasCost;
  }

  /**
   * Calculate CREATE2 gas cost (EIP-3860 aware)
   */
  create2GasCost(initCodeSize: number): bigint {
    let gasCost = BigInt(GasConstants.CreateGas); // Base 32,000 gas

    // Keccak256 hash cost for hashing init_code (per-word only, no base cost)
    const initCodeWordCount = Math.ceil(initCodeSize / 32);
    gasCost += BigInt(initCodeWordCount * GasConstants.Keccak256WordGas);

    if (HardforkUtils.isAtLeast(this.hardfork, Hardfork.SHANGHAI)) {
      // Additional init code word cost (EIP-3860)
      gasCost += BigInt(initCodeWordCount * GasConstants.InitcodeWordGas);
    }

    return gasCost;
  }

  // ================================ BYTECODE OPERATIONS ================================

  /**
   * Get current opcode at PC
   */
  getCurrentOpcode(): number | null {
    return this.bytecode.getOpcode(this.pc);
  }

  /**
   * Read immediate data for PUSH operations
   */
  readImmediate(size: number): bigint | null {
    return this.bytecode.readImmediate(this.pc, size);
  }

  // ================================ OPCODE EXECUTION ================================

  /**
   * Execute a single opcode
   *
   * Executes one EVM opcode instruction. Delegates to instruction handler modules
   * organized by category (arithmetic, comparison, bitwise, etc.).
   *
   * @param opcode - The opcode byte to execute (0x00-0xFF)
   * @throws {EvmError} Various errors depending on opcode requirements
   */
  executeOpcode(opcode: number): void {
    // Opcode dispatch to handler modules
    switch (opcode) {
      // Arithmetic (0x01-0x0b)
      case 0x01:
        return ArithmeticHandlers.add(this);
      case 0x02:
        return ArithmeticHandlers.mul(this);
      case 0x03:
        return ArithmeticHandlers.sub(this);
      case 0x04:
        return ArithmeticHandlers.div(this);
      case 0x05:
        return ArithmeticHandlers.sdiv(this);
      case 0x06:
        return ArithmeticHandlers.mod(this);
      case 0x07:
        return ArithmeticHandlers.smod(this);
      case 0x08:
        return ArithmeticHandlers.addmod(this);
      case 0x09:
        return ArithmeticHandlers.mulmod(this);
      case 0x0a:
        return ArithmeticHandlers.exp(this);
      case 0x0b:
        return ArithmeticHandlers.signextend(this);

      // Comparison (0x10-0x15)
      case 0x10:
        return ComparisonHandlers.lt(this);
      case 0x11:
        return ComparisonHandlers.gt(this);
      case 0x12:
        return ComparisonHandlers.slt(this);
      case 0x13:
        return ComparisonHandlers.sgt(this);
      case 0x14:
        return ComparisonHandlers.eq(this);
      case 0x15:
        return ComparisonHandlers.iszero(this);

      // Bitwise (0x16-0x1d)
      case 0x16:
        return BitwiseHandlers.and(this);
      case 0x17:
        return BitwiseHandlers.or(this);
      case 0x18:
        return BitwiseHandlers.xor(this);
      case 0x19:
        return BitwiseHandlers.not(this);
      case 0x1a:
        return BitwiseHandlers.byte(this);
      case 0x1b:
        return BitwiseHandlers.shl(this);
      case 0x1c:
        return BitwiseHandlers.shr(this);
      case 0x1d:
        return BitwiseHandlers.sar(this);

      // Keccak (0x20)
      case 0x20:
        return KeccakHandlers.sha3(this);

      // Context (0x30-0x3f)
      case 0x30:
        return ContextHandlers.address(this);
      case 0x31:
        return ContextHandlers.balance(this);
      case 0x32:
        return ContextHandlers.origin(this);
      case 0x33:
        return ContextHandlers.caller(this);
      case 0x34:
        return ContextHandlers.callvalue(this);
      case 0x35:
        return ContextHandlers.calldataload(this);
      case 0x36:
        return ContextHandlers.calldatasize(this);
      case 0x37:
        return ContextHandlers.calldatacopy(this);
      case 0x38:
        return ContextHandlers.codesize(this);
      case 0x39:
        return ContextHandlers.codecopy(this);
      case 0x3a:
        return ContextHandlers.gasprice(this);
      case 0x3b:
        return ContextHandlers.extcodesize(this);
      case 0x3c:
        return ContextHandlers.extcodecopy(this);
      case 0x3d:
        return ContextHandlers.returndatasize(this);
      case 0x3e:
        return ContextHandlers.returndatacopy(this);
      case 0x3f:
        return ContextHandlers.extcodehash(this);

      // Block (0x40-0x4a)
      case 0x40:
        return BlockHandlers.blockhash(this);
      case 0x41:
        return BlockHandlers.coinbase(this);
      case 0x42:
        return BlockHandlers.timestamp(this);
      case 0x43:
        return BlockHandlers.number(this);
      case 0x44:
        return BlockHandlers.difficulty(this);
      case 0x45:
        return BlockHandlers.gaslimit(this);
      case 0x46:
        return BlockHandlers.chainid(this);
      case 0x47:
        return BlockHandlers.selfbalance(this);
      case 0x48:
        return BlockHandlers.basefee(this);
      case 0x49:
        return BlockHandlers.blobhash(this);
      case 0x4a:
        return BlockHandlers.blobbasefee(this);

      // Stack and Memory (0x50-0x5e)
      case 0x50:
        return StackHandlers.pop(this);
      case 0x51:
        return MemoryHandlers.mload(this);
      case 0x52:
        return MemoryHandlers.mstore(this);
      case 0x53:
        return MemoryHandlers.mstore8(this);
      case 0x54:
        return StorageHandlers.sload(this);
      case 0x55:
        return StorageHandlers.sstore(this);
      case 0x56:
        return ControlFlowHandlers.jump(this);
      case 0x57:
        return ControlFlowHandlers.jumpi(this);
      case 0x58:
        return ControlFlowHandlers.pc(this);
      case 0x59:
        return MemoryHandlers.msize(this);
      case 0x5a:
        return ContextHandlers.gas(this);
      case 0x5b:
        return ControlFlowHandlers.jumpdest(this);
      case 0x5c:
        return StorageHandlers.tload(this);
      case 0x5d:
        return StorageHandlers.tstore(this);
      case 0x5e:
        return MemoryHandlers.mcopy(this);

      // PUSH0-PUSH32 (0x5f-0x7f)
      case 0x5f:
      case 0x60:
      case 0x61:
      case 0x62:
      case 0x63:
      case 0x64:
      case 0x65:
      case 0x66:
      case 0x67:
      case 0x68:
      case 0x69:
      case 0x6a:
      case 0x6b:
      case 0x6c:
      case 0x6d:
      case 0x6e:
      case 0x6f:
      case 0x70:
      case 0x71:
      case 0x72:
      case 0x73:
      case 0x74:
      case 0x75:
      case 0x76:
      case 0x77:
      case 0x78:
      case 0x79:
      case 0x7a:
      case 0x7b:
      case 0x7c:
      case 0x7d:
      case 0x7e:
      case 0x7f:
        return StackHandlers.push(this, opcode);

      // DUP1-DUP16 (0x80-0x8f)
      case 0x80:
      case 0x81:
      case 0x82:
      case 0x83:
      case 0x84:
      case 0x85:
      case 0x86:
      case 0x87:
      case 0x88:
      case 0x89:
      case 0x8a:
      case 0x8b:
      case 0x8c:
      case 0x8d:
      case 0x8e:
      case 0x8f:
        return StackHandlers.dup(this, opcode);

      // SWAP1-SWAP16 (0x90-0x9f)
      case 0x90:
      case 0x91:
      case 0x92:
      case 0x93:
      case 0x94:
      case 0x95:
      case 0x96:
      case 0x97:
      case 0x98:
      case 0x99:
      case 0x9a:
      case 0x9b:
      case 0x9c:
      case 0x9d:
      case 0x9e:
      case 0x9f:
        return StackHandlers.swap(this, opcode);

      // LOG0-LOG4 (0xa0-0xa4)
      case 0xa0:
      case 0xa1:
      case 0xa2:
      case 0xa3:
      case 0xa4:
        return LogHandlers.log(this, opcode);

      // System (0xf0-0xff)
      case 0xf0:
        return SystemHandlers.create(this);
      case 0xf1:
        return SystemHandlers.call(this);
      case 0xf2:
        return SystemHandlers.callcode(this);
      case 0xf3:
        return ControlFlowHandlers.ret(this);
      case 0xf4:
        return SystemHandlers.delegatecall(this);
      case 0xf5:
        return SystemHandlers.create2(this);
      case 0xfa:
        return SystemHandlers.staticcall(this);
      case 0xfd:
        return ControlFlowHandlers.revert(this);
      case 0xff:
        return SystemHandlers.selfdestruct(this);

      // Control flow
      case 0x00:
        return ControlFlowHandlers.stop(this);

      // Invalid opcode
      default:
        throw new EvmError(CallError.InvalidOpcode, `Invalid opcode: 0x${opcode.toString(16).padStart(2, '0')}`);
    }
  }

  /**
   * Execute a single step (one opcode)
   *
   * This method is used for single-stepping execution (e.g., for tracing/debugging).
   * It executes one instruction and advances the PC appropriately.
   *
   * Note: Tracing support requires EVM integration (not yet ported)
   */
  step(): void {
    if (this.stopped || this.reverted || this.pc >= this.bytecode.length) {
      return;
    }

    const opcode = this.getCurrentOpcode();
    if (opcode === null) {
      return;
    }

    // TODO: Tracing support requires EVM integration
    // For now, just execute the opcode directly
    this.executeOpcode(opcode);
  }

  /**
   * Main execution loop
   *
   * Executes bytecode until:
   * - STOP/RETURN/REVERT is encountered
   * - End of bytecode is reached
   * - Error occurs (out of gas, stack underflow, etc.)
   * - Iteration limit exceeded (prevents infinite loops)
   */
  execute(): void {
    let iterationCount = 0;
    const maxIterations = 10_000_000; // Reasonable limit ~10M ops

    while (!this.stopped && !this.reverted && this.pc < this.bytecode.length) {
      iterationCount++;
      if (iterationCount > maxIterations) {
        throw new EvmError(CallError.ExecutionTimeout, 'Execution exceeded maximum iteration count');
      }
      this.step();
    }
  }

  /**
   * Get the parent EVM instance
   *
   * NOTE: This requires the EVM to be ported to TypeScript.
   * For now, this returns the opaque pointer for future integration.
   */
  getEvm(): unknown {
    return this.evmPtr;
  }
}
