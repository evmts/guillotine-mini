/**
 * EVM Orchestrator (Part 1: State Management & Initialization)
 *
 * This is the EVM orchestrator that manages state, storage, and nested calls.
 * It does NOT execute bytecode - that's the responsibility of Frame.
 *
 * Architecture:
 * - EVM: State management (balances, nonces, code, storage, refunds)
 * - Frame: Bytecode interpreter (stack, memory, PC, opcode execution)
 * - Host: External state backend interface (optional)
 *
 * Port of src/evm.zig to TypeScript
 *
 * References:
 * - execution-specs/forks/cancun/vm/__init__.py (Python reference)
 * - src/evm.zig (Zig implementation)
 */

import { Storage, type StorageKey } from './storage.js';
import { AccessListManager, type AccessListSnapshot } from './access-list-manager.js';
import { CallError, EvmError } from './errors.js';
import type { HostInterface, Address } from './host.js';
import type { CallResult, Log } from './call-result.js';
import { Hardfork } from './instructions/handlers_storage.js'; // Import Hardfork enum

/**
 * Block context information
 * Provides blockchain-level data for opcodes (COINBASE, TIMESTAMP, etc.)
 */
export interface BlockContext {
  /** Chain ID (EIP-155) */
  chain_id: bigint;
  /** Current block number */
  block_number: bigint;
  /** Block timestamp (seconds since epoch) */
  block_timestamp: bigint;
  /** Block difficulty (pre-Merge) */
  block_difficulty: bigint;
  /** PREVRANDAO value (Merge+) */
  block_prevrandao: bigint;
  /** Coinbase address (block miner/validator) */
  block_coinbase: Address;
  /** Block gas limit */
  block_gas_limit: bigint;
  /** Base fee per gas (EIP-1559, London+) */
  block_base_fee: bigint;
  /** Blob base fee (EIP-4844, Cancun+) */
  blob_base_fee: bigint;
  /**
   * Recent block hashes (last 256 blocks)
   * For BLOCKHASH opcode
   * Python reference: execution-specs/forks/cancun/vm/__init__.py:42
   */
  block_hashes: Uint8Array[]; // Array of 32-byte hashes
}

/**
 * Fork transition configuration
 * Allows runtime fork switching based on block number/timestamp
 */
export interface ForkTransition {
  /** Starting fork */
  from: Hardfork;
  /** Target fork */
  to: Hardfork;
  /** Block number for transition */
  blockNumber?: bigint;
  /** Timestamp for transition */
  timestamp?: bigint;
}

/**
 * Zero address constant (0x0000...0000)
 */
export const ZERO_ADDRESS: Address = new Uint8Array(20);

/**
 * EVM Orchestrator
 *
 * Responsibilities:
 * - State management (balances, nonces, code, storage)
 * - Gas refunds (SSTORE refunds, capped at 1/2 or 1/5 of gas used)
 * - Warm/cold access tracking (EIP-2929, Berlin+)
 * - Transient storage (EIP-1153, Cancun+)
 * - Nested call management (CALL, CREATE, etc.)
 * - Transaction-scoped tracking (created accounts, selfdestructs, touched accounts)
 *
 * Frame (separate class) handles:
 * - Stack, memory, PC
 * - Bytecode interpretation
 * - Per-opcode execution
 */
export class Evm {
  // === Frame Management ===
  /** Call stack (nested CALL/CREATE contexts) */
  private frames: any[] = []; // Frame type to be added in Part 2

  // === Storage Management ===
  /** Persistent + transient storage manager */
  storage: Storage;

  // === Account Tracking ===
  /** Accounts created in this transaction (EIP-6780 tracking) */
  private createdAccounts: Set<string> = new Set();
  /** Accounts marked for deletion (SELFDESTRUCT) */
  private selfdestructedAccounts: Set<string> = new Set();
  /** Accounts touched (pre-Paris, for empty account deletion) */
  private touchedAccounts: Set<string> = new Set();

  // === State Caches ===
  /** Balance cache (address -> balance) */
  private balances: Map<string, bigint> = new Map();
  /** Nonce cache (address -> nonce) */
  private nonces: Map<string, bigint> = new Map();
  /** Code cache (address -> bytecode) */
  private code: Map<string, Uint8Array> = new Map();

  // === EIP-2929 Warm/Cold Tracking ===
  /** Warm/cold access manager (Berlin+) */
  private accessListManager: AccessListManager;

  // === Gas Refunds ===
  /** Gas refund counter (SSTORE refunds) */
  private gasRefund: bigint = 0n;

  // === Balance Snapshots (for SELFDESTRUCT reverts) ===
  /**
   * Stack of balance snapshots for nested calls
   * Each call pushes a snapshot, reverts restore from it
   */
  private balanceSnapshotStack: Map<string, bigint>[] = [];

  // === Protocol Configuration ===
  /** Current hardfork */
  hardfork: Hardfork;
  /** Optional fork transition config */
  private forkTransition: ForkTransition | null = null;

  // === Transaction Context ===
  /** Transaction origin (sender) */
  origin: Address;
  /** Gas price for this transaction */
  gasPrice: bigint;

  // === External State Backend ===
  /** Optional host interface for external state */
  private host: HostInterface | null = null;

  // === Block Context ===
  /** Block-level information */
  blockContext: BlockContext;

  // === EIP-4844 Blob Support ===
  /** Blob versioned hashes (Cancun+) */
  private blobVersionedHashes: Uint8Array[] = [];

  // === Transaction Logs ===
  /** Accumulated logs for current transaction */
  logs: Log[] = [];

  /**
   * Initialize EVM
   *
   * @param host - Optional host interface for external state backend
   * @param hardfork - Hardfork version (default: CANCUN)
   * @param blockContext - Optional block context
   */
  constructor(
    host?: HostInterface | null,
    hardfork: Hardfork = Hardfork.CANCUN,
    blockContext?: BlockContext | null
  ) {
    this.host = host ?? null;
    this.hardfork = hardfork;
    this.storage = new Storage(this.host);
    this.accessListManager = new AccessListManager();
    this.origin = ZERO_ADDRESS;
    this.gasPrice = 0n;

    // Default block context
    this.blockContext = blockContext ?? {
      chain_id: 1n,
      block_number: 0n,
      block_timestamp: 0n,
      block_difficulty: 0n,
      block_prevrandao: 0n,
      block_coinbase: ZERO_ADDRESS,
      block_gas_limit: 30_000_000n, // Default block gas limit
      block_base_fee: 0n,
      blob_base_fee: 0n,
      block_hashes: [],
    };
  }

  /**
   * Initialize transaction state
   *
   * Must be called before any transaction execution (call or create).
   * Clears per-transaction state and prepares for new execution.
   *
   * @param blobVersionedHashes - Optional EIP-4844 blob hashes
   */
  initTransactionState(blobVersionedHashes?: Uint8Array[] | null): void {
    // Clear per-transaction state
    this.storage = new Storage(this.host);
    this.balances.clear();
    this.nonces.clear();
    this.code.clear();
    this.accessListManager = new AccessListManager();
    this.frames = [];
    this.logs = [];
    this.createdAccounts.clear();
    this.selfdestructedAccounts.clear();
    this.touchedAccounts.clear();
    this.balanceSnapshotStack = [];
    this.gasRefund = 0n;

    // Set blob versioned hashes for EIP-4844
    // Deep copy to ensure caller can't modify after passing
    if (blobVersionedHashes && blobVersionedHashes.length > 0) {
      this.blobVersionedHashes = blobVersionedHashes.map((hash) =>
        new Uint8Array(hash)
      );
    } else {
      this.blobVersionedHashes = [];
    }
  }

  /**
   * Get active fork (handles fork transitions)
   *
   * @returns Current hardfork based on block context
   */
  getActiveFork(): Hardfork {
    if (this.forkTransition) {
      const { to, blockNumber, timestamp } = this.forkTransition;

      // Check block number transition
      if (
        blockNumber !== undefined &&
        this.blockContext.block_number >= blockNumber
      ) {
        return to;
      }

      // Check timestamp transition
      if (
        timestamp !== undefined &&
        this.blockContext.block_timestamp >= timestamp
      ) {
        return to;
      }
    }

    return this.hardfork;
  }

  /**
   * Access an address (EIP-2929 warm/cold tracking)
   *
   * Pre-Berlin: No warm/cold distinction, returns 0
   * Berlin+: First access is cold (2600 gas), subsequent warm (100 gas)
   *
   * @param address - Address to access
   * @returns Gas cost: 0 (pre-Berlin), 2600 (cold), or 100 (warm)
   */
  accessAddress(address: Address): bigint {
    if (this.hardfork < Hardfork.BERLIN) {
      // Pre-Berlin: No warm/cold access costs
      return 0n;
    }

    return BigInt(this.accessListManager.accessAddress(address));
  }

  /**
   * Access a storage slot (EIP-2929 warm/cold tracking)
   *
   * Pre-Berlin: Fixed cost (200 gas pre-Istanbul, 800 gas Istanbul+)
   * Berlin+: First access is cold (2100 gas), subsequent warm (100 gas)
   *
   * @param contractAddress - Contract address
   * @param slot - Storage slot (u256)
   * @returns Gas cost
   */
  accessStorageSlot(contractAddress: Address, slot: bigint): bigint {
    if (this.hardfork < Hardfork.BERLIN) {
      // EIP-1884 (Istanbul): SLOAD increased from 200 to 800 gas
      if (this.hardfork >= Hardfork.ISTANBUL) {
        return 800n;
      } else {
        return 200n;
      }
    }

    return BigInt(this.accessListManager.accessStorageSlot(contractAddress, slot));
  }

  /**
   * Set balance with copy-on-write snapshot for revert handling
   *
   * This should be called instead of direct host.setBalance() when inside a frame.
   * Uses copy-on-write semantics to track balance changes for proper revert handling.
   *
   * IMPORTANT: Snapshots the balance in ALL active snapshots on the stack, not just the current one.
   * This ensures that parent frames can restore state when they revert, even if the balance
   * was modified in a nested call.
   *
   * @param address - Address whose balance to modify
   * @param newBalance - New balance value to set
   */
  setBalanceWithSnapshot(address: Address, newBalance: bigint): void {
    const addrKey = this.addressKey(address);

    // Snapshot in ALL active snapshots (from outermost to innermost)
    // This ensures parent frames can restore state even if modified in nested calls
    for (const snapshot of this.balanceSnapshotStack) {
      if (!snapshot.has(addrKey)) {
        // Snapshot the current balance before modifying
        const currentBalance = this.host
          ? this.host.getBalance(address)
          : this.balances.get(addrKey) ?? 0n;
        snapshot.set(addrKey, currentBalance);
      }
    }

    // Now set the new balance
    if (this.host) {
      this.host.setBalance(address, newBalance);
    } else {
      this.balances.set(addrKey, newBalance);
    }
  }

  /**
   * Pre-warm addresses for transaction initialization
   *
   * EIP-2929 (Berlin+): Pre-warm addresses at transaction start
   * Pre-warmed addresses:
   * - Transaction origin (sender)
   * - Transaction target (if not zero address)
   * - Coinbase address (Shanghai+, EIP-3651)
   * - Precompile addresses (0x01-0x09 Berlin-Istanbul, 0x01-0x0A Cancun+, 0x01-0x12 Prague+)
   *
   * Pre-Berlin: No-op (no warm/cold distinction)
   *
   * @param target - Transaction target address
   */
  private preWarmAddresses(addresses: Address[]): void {
    this.accessListManager.preWarmAddresses(addresses);
  }

  /**
   * Get nonce for an address
   *
   * @param address - Account address
   * @returns Account nonce (0 if not set)
   */
  getNonce(address: Address): bigint {
    if (this.host) {
      return this.host.getNonce(address);
    }
    const key = this.addressKey(address);
    return this.nonces.get(key) ?? 0n;
  }

  /**
   * Get balance for an address
   *
   * @param address - Account address
   * @returns Account balance (0 if not set)
   */
  getBalance(address: Address): bigint {
    if (this.host) {
      return this.host.getBalance(address);
    }
    const key = this.addressKey(address);
    return this.balances.get(key) ?? 0n;
  }

  /**
   * Get code for an address
   *
   * EIP-7702 (Prague+): Handle delegation designation (0xef0100 + address)
   * If code starts with 0xef0100, it's a delegation - recursively fetch delegated code
   *
   * @param address - Account address
   * @returns Contract bytecode (empty if no code)
   */
  getCode(address: Address): Uint8Array {
    const rawCode = this.host
      ? this.host.getCode(address)
      : this.code.get(this.addressKey(address)) ?? new Uint8Array(0);

    // EIP-7702: Check for delegation designation (Prague+)
    if (
      this.hardfork >= Hardfork.PRAGUE &&
      rawCode.length === 23 &&
      rawCode[0] === 0xef &&
      rawCode[1] === 0x01 &&
      rawCode[2] === 0x00
    ) {
      // Extract delegated address (bytes 3-22, 20 bytes)
      const delegatedAddr = rawCode.slice(3, 23);

      // Recursively get code from delegated address
      // Note: We don't recurse infinitely - if delegated address also has
      // delegation designation, we return its delegation code as-is
      const delegatedCode = this.host
        ? this.host.getCode(delegatedAddr)
        : this.code.get(this.addressKey(delegatedAddr)) ?? new Uint8Array(0);

      return delegatedCode;
    }

    return rawCode;
  }

  /**
   * Compute CREATE address: keccak256(rlp([sender, nonce]))[12:]
   *
   * Calculates the address for a new contract created via CREATE opcode or
   * contract creation transaction. Uses RLP encoding of [sender_address, nonce]
   * and takes the last 20 bytes of the keccak256 hash.
   *
   * Reference: Yellow Paper Eq. (82)
   *
   * @param sender - Address of the account creating the contract
   * @param nonce - Nonce value of the sender at creation time
   * @returns Computed contract address
   */
  computeCreateAddress(sender: Address, nonce: bigint): Address {
    // RLP encoding of [sender (20 bytes), nonce]
    const buffer: number[] = [];

    // Calculate nonce encoding length
    let nonceLen: number;
    if (nonce === 0n) {
      nonceLen = 1;
    } else if (nonce < 128n) {
      nonceLen = 1;
    } else {
      // Count bytes needed for nonce
      let n = nonce;
      let len = 0;
      while (n > 0n) {
        len++;
        n >>= 8n;
      }
      nonceLen = len + 1; // +1 for length prefix
    }

    // RLP list prefix
    const listLen = 21 + nonceLen;
    buffer.push(0xc0 + listLen);

    // RLP encode sender address (20 bytes, so 0x80 + 20 = 0x94)
    buffer.push(0x94);
    buffer.push(...Array.from(sender));

    // RLP encode nonce
    if (nonce === 0n) {
      buffer.push(0x80);
    } else if (nonce < 128n) {
      buffer.push(Number(nonce));
    } else {
      // Convert nonce to big-endian bytes
      const nonceBytes: number[] = [];
      let n = nonce;
      while (n > 0n) {
        nonceBytes.unshift(Number(n & 0xffn));
        n >>= 8n;
      }
      buffer.push(0x80 + nonceBytes.length);
      buffer.push(...nonceBytes);
    }

    // Compute keccak256 hash
    const rlpData = new Uint8Array(buffer);
    const hash = this.keccak256(rlpData);

    // Take last 20 bytes as address
    return hash.slice(12, 32);
  }

  /**
   * Compute CREATE2 address: keccak256(0xff ++ sender ++ salt ++ keccak256(init_code))[12:]
   *
   * Reference: EIP-1014
   *
   * @param sender - Address of the account creating the contract
   * @param salt - 32-byte salt value
   * @param initCode - Initialization code (bytecode)
   * @returns Computed contract address
   */
  computeCreate2Address(
    sender: Address,
    salt: bigint,
    initCode: Uint8Array
  ): Address {
    // Compute keccak256(init_code)
    const initCodeHash = this.keccak256(initCode);

    // Compute keccak256(0xff ++ sender ++ salt ++ init_code_hash)
    const buffer = new Uint8Array(85); // 1 + 20 + 32 + 32
    buffer[0] = 0xff;
    buffer.set(sender, 1);

    // Convert salt to bytes (big-endian, 32 bytes)
    const saltBytes = new Uint8Array(32);
    let s = salt;
    for (let i = 31; i >= 0; i--) {
      saltBytes[i] = Number(s & 0xffn);
      s >>= 8n;
    }
    buffer.set(saltBytes, 21);

    buffer.set(initCodeHash, 53);

    const hash = this.keccak256(buffer);

    // Take last 20 bytes as address
    return hash.slice(12, 32);
  }

  /**
   * Pre-warm addresses at transaction start (EIP-2929, EIP-3651)
   *
   * Marks specific addresses as "warm" before transaction execution begins.
   * This affects gas costs for subsequent accesses to these addresses.
   *
   * Pre-warmed addresses (Berlin+):
   * - Transaction origin (sender)
   * - Transaction target (if not zero address)
   * - Coinbase address (Shanghai+, EIP-3651)
   * - All precompile addresses (0x01-0x09 Berlin-Istanbul, 0x01-0x0A Cancun+, 0x01-0x12 Prague+)
   *
   * Pre-Berlin: No-op (no warm/cold distinction)
   *
   * @param target - Transaction target address
   */
  preWarmTransaction(target: Address): void {
    // EIP-2929 (Berlin+): Pre-warm addresses at transaction start
    // Pre-Berlin: no warm/cold distinction, so skip this entirely
    if (this.hardfork < Hardfork.BERLIN) return;

    const warm: Address[] = [];

    warm.push(this.origin);

    if (!this.addressEquals(target, ZERO_ADDRESS)) {
      warm.push(target);
    }

    // EIP-3651 (Shanghai+): Coinbase address is pre-warmed at transaction start
    if (this.hardfork >= Hardfork.SHANGHAI) {
      warm.push(this.blockContext.block_coinbase);
    }

    // Pre-warm origin, target, and coinbase
    this.preWarmAddresses(warm);

    // Pre-warm precompiles
    // EIP-2929: Precompiles are always warm at transaction start
    // Determine number of precompiles based on hardfork
    // Berlin-Istanbul: 0x01-0x09 (9 precompiles: ECRECOVER through BLAKE2F)
    // Cancun+: 0x01-0x0A (10 precompiles, added KZG point evaluation at 0x0A via EIP-4844)
    // Prague+: 0x01-0x12 (19 precompiles, added BLS12-381 operations at 0x0B-0x12 via EIP-2537)
    let precompileCount: number;
    if (this.hardfork >= Hardfork.PRAGUE) {
      precompileCount = 0x12; // Prague: All precompiles including BLS12-381
    } else if (this.hardfork >= Hardfork.CANCUN) {
      precompileCount = 0x0a; // Cancun: Includes KZG point evaluation
    } else {
      precompileCount = 0x09; // Berlin-Istanbul: Up to BLAKE2F
    }

    const precompileAddrs: Address[] = [];
    for (let i = 1; i <= precompileCount; i++) {
      precompileAddrs.push(this.addressFromU256(BigInt(i)));
    }
    this.preWarmAddresses(precompileAddrs);
  }

  /**
   * Get current frame (top of the frame stack)
   *
   * @returns Current frame or null if no frames
   */
  getCurrentFrame(): any | null {
    if (this.frames.length > 0) {
      return this.frames[this.frames.length - 1];
    }
    return null;
  }

  /**
   * Get current frame's PC (for tracer)
   *
   * @returns Program counter of current frame (0 if no frames)
   */
  getPC(): number {
    const frame = this.getCurrentFrame();
    return frame ? frame.pc : 0;
  }

  /**
   * Get current frame's bytecode (for tracer)
   *
   * @returns Bytecode of current frame (empty if no frames)
   */
  getBytecode(): Uint8Array {
    const frame = this.getCurrentFrame();
    return frame ? frame.bytecode : new Uint8Array(0);
  }

  // === Helper Methods ===

  /**
   * Convert address to string key for Map storage
   */
  private addressKey(address: Address): string {
    return Array.from(address)
      .map((b) => b.toString(16).padStart(2, '0'))
      .join('');
  }

  /**
   * Compare two addresses for equality
   */
  private addressEquals(a: Address, b: Address): boolean {
    if (a.length !== 20 || b.length !== 20) return false;
    for (let i = 0; i < 20; i++) {
      if (a[i] !== b[i]) return false;
    }
    return true;
  }

  /**
   * Create address from u256 value
   */
  private addressFromU256(value: bigint): Address {
    const bytes = new Uint8Array(20);
    let v = value;
    for (let i = 19; i >= 0; i--) {
      bytes[i] = Number(v & 0xffn);
      v >>= 8n;
    }
    return bytes;
  }

  /**
   * Compute keccak256 hash
   * TODO: Use proper keccak256 implementation (from @noble/hashes or similar)
   */
  private keccak256(data: Uint8Array): Uint8Array {
    // Placeholder - must be replaced with actual keccak256 implementation
    // For now, return a dummy hash
    throw new Error('keccak256 not implemented - must use @noble/hashes or similar');
  }

  /**
   * Dispose EVM resources (cleanup)
   *
   * In TypeScript, this is less critical than Zig due to garbage collection,
   * but we clear Maps/Sets to help GC.
   */
  dispose(): void {
    this.balances.clear();
    this.nonces.clear();
    this.code.clear();
    this.createdAccounts.clear();
    this.selfdestructedAccounts.clear();
    this.touchedAccounts.clear();
    this.frames = [];
    this.logs = [];
    this.balanceSnapshotStack = [];
    this.blobVersionedHashes = [];
  }

  // ========================================================================
  // PART 2: Call & Create Methods (Complex EVM Operations)
  // ========================================================================
  // These methods implement the most critical EVM operations:
  // - call(): Top-level transaction entry point
  // - inner_call(): Nested CALL/CALLCODE/DELEGATECALL/STATICCALL operations
  // - inner_create(): Contract creation (CREATE/CREATE2)
  //
  // CRITICAL IMPLEMENTATION DETAILS:
  // - Snapshot ALL mutable state before nested calls
  // - Restore state on revert (storage, balances, refunds, access lists, selfdestructed)
  // - EIP-150: 63/64 gas forwarding rule for calls
  // - EIP-6780: SELFDESTRUCT only deletes if created in same tx
  // - EIP-3860: Init code size limits (Shanghai+)
  // - Call depth limit: 1024 (STACK_DEPTH_LIMIT)
  // - Gas stipend for value transfers: 2300
  //
  // Reference: execution-specs/forks/cancun/vm/instructions/system.py
  // ========================================================================

  /**
   * Main entry point: Execute bytecode (top-level transaction)
   *
   * This is the primary execution method for EVM transactions. It handles:
   * - Parameter validation
   * - Transaction state initialization
   * - Address pre-warming (EIP-2929)
   * - Value transfers
   * - Precompile execution
   * - Frame creation and execution
   * - Transaction cleanup (access lists, transient storage, selfdestructed accounts)
   *
   * NOTE: This method signature is a placeholder. The actual call() method will accept
   * CallParams union and return CallResult. For now, this shows the structure.
   *
   * @param params - Call parameters (from call-params.ts)
   * @returns CallResult with execution outcome (from call-result.ts)
   */
  call(params: any): any {
    throw new Error('call() method not yet implemented - Part 2 continuation needed');
  }

  /**
   * Handle inner call from frame (nested CALL/CALLCODE/DELEGATECALL/STATICCALL)
   *
   * This implements nested EVM calls within a transaction. It handles:
   * - Call depth checking (max 1024)
   * - State snapshots before execution
   * - Value transfers (for CALL)
   * - Precompile execution
   * - Frame creation with proper context (caller, address, static mode)
   * - State restoration on revert
   *
   * CRITICAL: Must snapshot ALL mutable state:
   * - Gas refunds
   * - Transient storage (EIP-1153)
   * - Selfdestructed accounts (EIP-6780)
   * - Access lists (EIP-2929)
   * - Original storage
   * - Persistent storage
   * - Balances
   *
   * @param params - Call parameters
   * @returns CallResult with execution outcome
   */
  inner_call(params: any): any {
    throw new Error('inner_call() method not yet implemented - Part 2 continuation needed');
  }

  /**
   * Handle CREATE operation (contract creation)
   *
   * This implements contract creation via CREATE or CREATE2 opcodes. It handles:
   * - Call depth checking (max 1024)
   * - Address computation (CREATE vs CREATE2)
   * - Init code size validation (EIP-3860, Shanghai+)
   * - Address collision detection (EIP-684)
   * - Nonce management
   * - State snapshots before execution
   * - Init code execution
   * - Code deployment validation (size, deposit cost)
   * - State restoration on failure
   *
   * CRITICAL DETAILS:
   * - Created account is marked as warm (EIP-2929)
   * - Account collision check happens BEFORE nonce increment
   * - Nonce set to 1 for new contract (EVM spec)
   * - EIP-6780: Account marked as created BEFORE execution
   * - Deposit cost: 200 gas per byte of deployed code
   * - Max code size: 24576 bytes (EIP-170)
   * - Top-level creates: nonce already incremented by transaction processor
   * - Opcode creates: nonce incremented here
   *
   * @param value - Value to transfer to new contract
   * @param initCode - Initialization code
   * @param gas - Gas available for execution
   * @param salt - Salt for CREATE2 (optional)
   * @returns Object with address, success, gas_left, output
   */
  inner_create(
    value: bigint,
    initCode: Uint8Array,
    gas: bigint,
    salt?: bigint
  ): { address: Address; success: boolean; gas_left: bigint; output: Uint8Array } {
    throw new Error('inner_create() method not yet implemented - Part 2 continuation needed');
  }

  /**
   * Add gas refund (called by frame)
   *
   * Increments the gas refund counter for SSTORE operations.
   * Refunds are capped at transaction end:
   * - Pre-London: 1/2 of gas used
   * - London+: 1/5 of gas used (EIP-3529)
   *
   * @param amount - Refund amount to add
   */
  addRefund(amount: bigint): void {
    this.gasRefund += amount;
  }

  /**
   * Subtract gas refund (called by frame)
   *
   * Decrements the gas refund counter (for SSTORE operations that remove refunds).
   *
   * @param amount - Refund amount to subtract
   */
  subRefund(amount: bigint): void {
    this.gasRefund -= amount;
  }
}
