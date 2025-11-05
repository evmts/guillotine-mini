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

import { Storage, type StorageKey } from './storage';
import { AccessListManager, type AccessListSnapshot } from './access-list-manager';
import { CallError, EvmError } from './errors';
import type { HostInterface, Address } from './host';
import type { CallResult, Log } from './call-result';
import { CallResultHelpers } from './call-result';
import { Hardfork } from './instructions/handlers_storage'; // Import Hardfork enum
import type { CallParamsUnion } from './call-params';
import { Frame, type FrameParams } from './frame';

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
  selfdestructedAccounts: Set<string> = new Set();
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
   * Check if an address is warm (already accessed in this transaction)
   *
   * @param address - Address to check
   * @returns true if address is warm, false if cold
   */
  isAddressWarm(address: Address): boolean {
    return this.accessListManager.isAddressWarm(address);
  }

  /**
   * Mark an address as warm (accessed)
   *
   * @param address - Address to mark as warm
   */
  warmAddress(address: Address): void {
    this.accessListManager.accessAddress(address);
  }

  /**
   * Check if an address was created in this transaction
   *
   * Used for EIP-6780 SELFDESTRUCT logic (Cancun+)
   *
   * @param address - Address to check
   * @returns true if created in this transaction, false otherwise
   */
  wasCreatedThisTransaction(address: Address): boolean {
    const key = this.addressKey(address);
    return this.createdAccounts.has(key);
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
   * Convert address key string back to Address (inverse of addressKey)
   */
  private addressFromKey(key: string): Address {
    const bytes = new Uint8Array(20);
    for (let i = 0; i < 20; i++) {
      bytes[i] = parseInt(key.slice(i * 2, i * 2 + 2), 16);
    }
    return bytes;
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
   * Compute keccak256 hash using @noble/hashes
   */
  private keccak256(data: Uint8Array): Uint8Array {
    // Try Bun's native crypto first (faster)
    try {
      if (typeof Bun !== 'undefined' && Bun.CryptoHasher) {
        const hasher = new Bun.CryptoHasher('keccak256');
        hasher.update(data);
        return new Uint8Array(hasher.digest());
      }
    } catch {
      // Fall through to @noble/hashes
    }

    // Fallback to @noble/hashes
    const { keccak_256 } = require('@noble/hashes/sha3');
    return keccak_256(data);
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
   */
  call(params: CallParamsUnion): CallResult {
    // Handle CREATE/CREATE2
    if (params.type === 'create' || params.type === 'create2') {
      const salt = params.type === 'create2' ? params.salt : undefined;
      const result = this.inner_create(params.value, params.initCode, params.gas, salt);
      return {
        success: result.success,
        gas_left: result.gas_left,
        output: result.output,
        refund_counter: this.gasRefund,
        logs: [...this.logs],
        selfdestructs: [],
        accessed_addresses: [],
        accessed_storage: [],
        created_address: result.address,
      };
    }

    // Extract parameters
    const caller = params.caller;
    const address = params.to;
    const value = (params.type === 'call' || params.type === 'callcode') ? params.value : 0n;
    const calldata = params.input;
    const gas = params.gas;

    this.origin = caller;
    this.gasPrice = 0n;

    // Init transaction
    this.initTransactionState();
    this.preWarmTransaction(address);

    // Transfer value
    if (value > 0n) {
      const senderBalance = this.getBalance(caller);
      if (senderBalance < value) {
        return CallResultHelpers.failure(gas);
      }
      this.setBalanceWithSnapshot(caller, senderBalance - value);
      const recipientBalance = this.getBalance(address);
      this.setBalanceWithSnapshot(address, recipientBalance + value);
    }

    // Get code
    const code = this.getCode(address);
    if (code.length === 0) {
      return CallResultHelpers.successEmpty(gas);
    }

    // Create frame
    const frame = new Frame({
      bytecode: code,
      gas,
      caller,
      address,
      value,
      calldata,
      evmPtr: this,
      hardfork: this.hardfork,
      isStatic: params.type === 'staticcall',
      callDepth: 0,
    });

    this.frames.push(frame);
    try {
      frame.execute();
    } catch (error) {
      return CallResultHelpers.failureWithError(frame.gasRemaining, String(error));
    } finally {
      this.frames.pop();
    }

    if (frame.reverted) {
      return CallResultHelpers.revertWithData(frame.gasRemaining, frame.output);
    }

    // Prepare result before cleanup (capture logs and selfdestructs)
    const result = {
      success: !frame.reverted,
      gas_left: frame.gasRemaining,
      output: frame.output,
      refund_counter: this.gasRefund,
      logs: [...this.logs],
      selfdestructs: Array.from(this.selfdestructedAccounts).map(key => this.addressFromKey(key)),
      accessed_addresses: [],
      accessed_storage: [],
    };

    // Transaction cleanup (must happen after result construction)

    // 1. Clear access list manager (EIP-2929)
    this.accessListManager.clear();

    // 2. Clear transient storage at end of transaction (EIP-1153)
    this.storage.clearTransient();

    // 3. Clear logs buffer for next transaction
    this.logs = [];

    // 4. Delete selfdestructed accounts at end of transaction (EIP-6780)
    // This must happen AFTER transient storage is cleared since transient storage
    // should be accessible during the transaction even after SELFDESTRUCT
    for (const addrKey of this.selfdestructedAccounts) {
      const addr = this.addressFromKey(addrKey);

      if (this.host) {
        // Host mode: Clear all account state via host interface
        this.host.setBalance(addr, 0n);
        this.host.setCode(addr, new Uint8Array(0));
        this.host.setNonce(addr, 0n);

        // Clear all storage slots for this address via host
        // Note: We can't iterate host storage, so we rely on the host
        // implementation to handle storage cleanup properly
        // For now, we clear what we know about in our local storage tracker
        this.storage.clearStorageForAddress(addr);
      } else {
        // Non-host mode: Clear all account state from EVM maps
        this.balances.delete(addrKey);
        this.code.delete(addrKey);
        this.nonces.delete(addrKey);

        // Clear all storage slots for this address
        this.storage.clearStorageForAddress(addr);
      }
    }

    // 5. Clear transaction-scoped sets at end of transaction
    // These must be cleared to avoid incorrectly treating accounts as created/selfdestructed
    // in subsequent transactions within the same block
    this.createdAccounts.clear();
    this.selfdestructedAccounts.clear();

    return result;
  }

  /**
   * Handle inner call from frame (nested CALL/CALLCODE/DELEGATECALL/STATICCALL)
   */
  inner_call(params: CallParamsUnion): CallResult {
    if (params.type === 'create' || params.type === 'create2') {
      throw new Error('CREATE operations should use inner_create()');
    }

    const address = params.to;
    const value = (params.type === 'call' || params.type === 'callcode') ? params.value : 0n;
    const input = params.input;
    const gas = params.gas;

    if (this.frames.length >= 1024) {
      return CallResultHelpers.failure(gas);
    }

    const currentFrame = this.getCurrentFrame();
    const frameCaller = currentFrame ? currentFrame.address : this.origin;
    const frameCallerCaller = currentFrame ? currentFrame.caller : this.origin;
    const currentValue = currentFrame ? currentFrame.value : 0n;

    let executionCaller: Address;
    let executionAddress: Address;
    let executionValue: bigint;

    switch (params.type) {
      case 'call':
      case 'staticcall':
        executionCaller = frameCaller;
        executionAddress = address;
        executionValue = value;
        break;
      case 'delegatecall':
        executionCaller = frameCallerCaller;
        executionAddress = frameCaller;
        executionValue = currentValue;
        break;
      case 'callcode':
        executionCaller = frameCaller;
        executionAddress = frameCaller;
        executionValue = value;
        break;
      default:
        throw new Error(`Unknown call type: ${params.type}`);
    }

    const refundSnapshot = this.gasRefund;
    const storageSnapshot = this.storage.snapshot();
    const accessListSnapshot = this.accessListManager.snapshot();
    const balanceSnapshot = new Map<string, bigint>();
    this.balanceSnapshotStack.push(balanceSnapshot);

    try {
      if (value > 0n && params.type === 'call') {
        const callerBalance = this.getBalance(frameCaller);
        if (callerBalance < value) {
          return CallResultHelpers.failure(gas);
        }
        this.setBalanceWithSnapshot(frameCaller, callerBalance - value);
        const calleeBalance = this.getBalance(address);
        this.setBalanceWithSnapshot(address, calleeBalance + value);
      }

      const code = this.getCode(address);
      if (code.length === 0) {
        return CallResultHelpers.successEmpty(gas);
      }

      const frame = new Frame({
        bytecode: code,
        gas,
        caller: executionCaller,
        address: executionAddress,
        value: executionValue,
        calldata: input,
        evmPtr: this,
        hardfork: this.hardfork,
        isStatic: params.type === 'staticcall' || (currentFrame?.isStatic ?? false),
        callDepth: this.frames.length,
      });

      this.frames.push(frame);
      try {
        frame.execute();
      } finally {
        this.frames.pop();
      }

      if (frame.reverted) {
        this.gasRefund = refundSnapshot;
        this.storage.restore(storageSnapshot);
        this.accessListManager.restore(accessListSnapshot);
        for (const [addrKey, balance] of balanceSnapshot.entries()) {
          const addr = this.addressFromKey(addrKey);
          if (this.host) {
            this.host.setBalance(addr, balance);
          } else {
            this.balances.set(addrKey, balance);
          }
        }
        return CallResultHelpers.revertWithData(frame.gasRemaining, frame.output);
      }

      if (currentFrame) {
        currentFrame.returnData = frame.output;
      }

      return {
        success: true,
        gas_left: frame.gasRemaining,
        output: frame.output,
        refund_counter: this.gasRefund,
        logs: [...this.logs],
        selfdestructs: [],
        accessed_addresses: [],
        accessed_storage: [],
      };
    } finally {
      this.balanceSnapshotStack.pop();
    }
  }

  /**
   * Handle CREATE operation (contract creation)
   */
  inner_create(
    value: bigint,
    initCode: Uint8Array,
    gas: bigint,
    salt?: bigint
  ): { address: Address; success: boolean; gas_left: bigint; output: Uint8Array } {
    const isTopLevel = this.frames.length === 0;

    if (this.frames.length >= 1024) {
      return { address: ZERO_ADDRESS, success: false, gas_left: gas, output: new Uint8Array(0) };
    }

    const caller = this.getCurrentFrame()?.address ?? this.origin;
    const senderNonce = this.getNonce(caller);

    if (senderNonce >= 2n ** 64n - 1n) {
      return { address: ZERO_ADDRESS, success: false, gas_left: gas, output: new Uint8Array(0) };
    }

    if (value > 0n && this.getBalance(caller) < value) {
      return { address: ZERO_ADDRESS, success: false, gas_left: gas, output: new Uint8Array(0) };
    }

    let newAddress: Address;
    if (salt !== undefined) {
      newAddress = this.computeCreate2Address(caller, salt, initCode);
    } else {
      let nonce = this.getNonce(caller);
      if (isTopLevel) nonce -= 1n;
      newAddress = this.computeCreateAddress(caller, nonce);
    }

    const MAX_INITCODE_SIZE = 49152;
    if (this.hardfork >= Hardfork.SHANGHAI && initCode.length > MAX_INITCODE_SIZE) {
      throw new EvmError(CallError.OutOfGas, 'Init code size exceeds maximum');
    }

    if (this.hardfork >= Hardfork.BERLIN) {
      this.accessAddress(newAddress);
    }

    const hasCode = this.getCode(newAddress).length > 0;
    const hasNonce = this.getNonce(newAddress) > 0n;
    if (hasCode || hasNonce) {
      if (!isTopLevel) {
        const currentNonce = this.getNonce(caller);
        if (this.host) {
          this.host.setNonce(caller, Number(currentNonce + 1n));
        } else {
          this.nonces.set(this.addressKey(caller), currentNonce + 1n);
        }
      }
      return { address: ZERO_ADDRESS, success: false, gas_left: gas, output: new Uint8Array(0) };
    }

    if (!isTopLevel) {
      const currentNonce = this.getNonce(caller);
      if (this.host) {
        this.host.setNonce(caller, Number(currentNonce + 1n));
      } else {
        this.nonces.set(this.addressKey(caller), currentNonce + 1n);
      }
    }

    if (this.host) {
      this.host.setNonce(newAddress, 1);
    } else {
      this.nonces.set(this.addressKey(newAddress), 1n);
    }

    this.createdAccounts.add(this.addressKey(newAddress));

    const refundSnapshot = this.gasRefund;
    const storageSnapshot = this.storage.snapshot();
    const accessListSnapshot = this.accessListManager.snapshot();
    const balanceSnapshot = new Map<string, bigint>();
    this.balanceSnapshotStack.push(balanceSnapshot);

    try {
      if (value > 0n) {
        const callerBalance = this.getBalance(caller);
        this.setBalanceWithSnapshot(caller, callerBalance - value);
        const contractBalance = this.getBalance(newAddress);
        this.setBalanceWithSnapshot(newAddress, contractBalance + value);
      }

      const frame = new Frame({
        bytecode: initCode,
        gas,
        caller,
        address: newAddress,
        value,
        calldata: new Uint8Array(0),
        evmPtr: this,
        hardfork: this.hardfork,
        isStatic: false,
        callDepth: this.frames.length,
      });

      this.frames.push(frame);
      try {
        frame.execute();
      } finally {
        this.frames.pop();
      }

      if (frame.reverted || !frame.stopped) {
        this.gasRefund = refundSnapshot;
        this.storage.restore(storageSnapshot);
        this.accessListManager.restore(accessListSnapshot);
        for (const [addrKey, balance] of balanceSnapshot.entries()) {
          const addr = this.addressFromKey(addrKey);
          if (this.host) {
            this.host.setBalance(addr, balance);
          } else {
            this.balances.set(addrKey, balance);
          }
        }
        this.createdAccounts.delete(this.addressKey(newAddress));
        return { address: ZERO_ADDRESS, success: false, gas_left: frame.gasRemaining, output: frame.output };
      }

      const deployedCode = frame.output;
      const MAX_CODE_SIZE = 24576;

      if (deployedCode.length > MAX_CODE_SIZE) {
        this.gasRefund = refundSnapshot;
        this.storage.restore(storageSnapshot);
        this.accessListManager.restore(accessListSnapshot);
        for (const [addrKey, balance] of balanceSnapshot.entries()) {
          const addr = this.addressFromKey(addrKey);
          if (this.host) {
            this.host.setBalance(addr, balance);
          } else {
            this.balances.set(addrKey, balance);
          }
        }
        this.createdAccounts.delete(this.addressKey(newAddress));
        return { address: ZERO_ADDRESS, success: false, gas_left: frame.gasRemaining, output: new Uint8Array(0) };
      }

      const depositCost = BigInt(deployedCode.length) * 200n;
      if (frame.gasRemaining < depositCost) {
        this.gasRefund = refundSnapshot;
        this.storage.restore(storageSnapshot);
        this.accessListManager.restore(accessListSnapshot);
        for (const [addrKey, balance] of balanceSnapshot.entries()) {
          const addr = this.addressFromKey(addrKey);
          if (this.host) {
            this.host.setBalance(addr, balance);
          } else {
            this.balances.set(addrKey, balance);
          }
        }
        this.createdAccounts.delete(this.addressKey(newAddress));
        return { address: ZERO_ADDRESS, success: false, gas_left: 0n, output: new Uint8Array(0) };
      }

      if (this.host) {
        this.host.setCode(newAddress, deployedCode);
      } else {
        this.code.set(this.addressKey(newAddress), deployedCode);
      }

      return { address: newAddress, success: true, gas_left: frame.gasRemaining - depositCost, output: deployedCode };
    } finally {
      this.balanceSnapshotStack.pop();
    }
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
