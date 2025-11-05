/**
 * Async execution orchestrator for the EVM
 *
 * Handles yielding for async data requests (storage, balance, code, nonce)
 * and resuming execution when data is provided.
 *
 * Port of src/async_executor.zig to TypeScript
 */

import type { Address } from './host';

/**
 * Async data request types - written when cache miss occurs
 */
export type AsyncDataRequest =
  | { type: 'none' }
  | { type: 'storage'; address: Address; slot: bigint }
  | { type: 'balance'; address: Address }
  | { type: 'code'; address: Address }
  | { type: 'nonce'; address: Address };

/**
 * Storage key for HashMap lookups
 * Combination of address and slot
 */
export interface StorageKey {
  address: Uint8Array; // 20 bytes
  slot: bigint;        // u256
}

/**
 * Call parameters - initial execution input
 * Simplified version matching CallParams union structure
 */
export type CallParams =
  | {
      type: 'call';
      caller: Address;
      to: Address;
      value: bigint;
      input: Uint8Array;
      gas: bigint;
    }
  | {
      type: 'callcode';
      caller: Address;
      to: Address;
      value: bigint;
      input: Uint8Array;
      gas: bigint;
    }
  | {
      type: 'delegatecall';
      caller: Address;
      to: Address;
      input: Uint8Array;
      gas: bigint;
    }
  | {
      type: 'staticcall';
      caller: Address;
      to: Address;
      input: Uint8Array;
      gas: bigint;
    }
  | {
      type: 'create';
      caller: Address;
      value: bigint;
      init_code: Uint8Array;
      gas: bigint;
    }
  | {
      type: 'create2';
      caller: Address;
      value: bigint;
      init_code: Uint8Array;
      salt: bigint;
      gas: bigint;
    };

/**
 * Call result - execution output
 */
export interface CallResult {
  success: boolean;
  gas_left: bigint;
  output: Uint8Array;
  refund_counter?: bigint;
  logs?: Log[];
  selfdestructs?: SelfDestructRecord[];
  accessed_addresses?: Address[];
  accessed_storage?: StorageAccess[];
  trace?: ExecutionTrace;
  error_info?: string;
  created_address?: Address;
}

/**
 * Log entry (EIP-2200)
 */
export interface Log {
  address: Address;
  topics: bigint[];
  data: Uint8Array;
}

/**
 * Self-destruct record (EIP-6780)
 */
export interface SelfDestructRecord {
  address: Address;
  target: Address;
  balance: bigint;
}

/**
 * Storage access record (EIP-2929)
 */
export interface StorageAccess {
  address: Address;
  slot: bigint;
}

/**
 * Execution trace (EIP-3155)
 */
export interface ExecutionTrace {
  steps: TraceStep[];
}

/**
 * Single trace step
 */
export interface TraceStep {
  pc: number;
  op: number;
  gas: bigint;
  gasCost: bigint;
  stack: bigint[];
  depth: number;
  returnData?: Uint8Array;
  error?: string;
}

/**
 * Input to callOrContinue - tagged union for starting or continuing execution
 */
export type CallOrContinueInput =
  | { type: 'call'; params: CallParams }
  | {
      type: 'continue_with_storage';
      address: Address;
      slot: bigint;
      value: bigint;
    }
  | {
      type: 'continue_with_balance';
      address: Address;
      balance: bigint;
    }
  | {
      type: 'continue_with_code';
      address: Address;
      code: Uint8Array;
    }
  | {
      type: 'continue_with_nonce';
      address: Address;
      nonce: bigint;
    }
  | { type: 'continue_after_commit' };

/**
 * Output from callOrContinue - tagged union for result or async request
 */
export type CallOrContinueOutput =
  | { type: 'result'; result: CallResult }
  | { type: 'need_storage'; address: Address; slot: bigint }
  | { type: 'need_balance'; address: Address }
  | { type: 'need_code'; address: Address }
  | { type: 'need_nonce'; address: Address }
  | { type: 'ready_to_commit'; changes_json: string };

/**
 * EVM interface required by AsyncExecutor
 */
export interface EvmInterface {
  // Transaction initialization
  initTransactionState(accessList: AccessListItem[] | null): Promise<void>;

  // Address computation
  computeCreate2Address(
    caller: Address,
    salt: bigint,
    initCode: Uint8Array
  ): Promise<Address>;
  computeCreateAddress(caller: Address, nonce: bigint): Promise<Address>;

  // State access
  getNonce(address: Address): bigint;

  // Transaction setup
  preWarmTransaction(address: Address): Promise<void>;
  preWarmFromAccessList(list: AccessListItem[]): Promise<void>;

  // Balance transfers
  getBalance(address: Address): bigint;
  setBalance(address: Address, balance: bigint): void;

  // Execution
  executeUntilYieldOrComplete(): Promise<CallOrContinueOutput>;
  finalizeAndReturnResult(): Promise<CallOrContinueOutput>;

  // State management
  pending_bytecode: Uint8Array;
  pending_access_list: AccessListItem[] | null;

  // Storage injector (optional)
  storage?: {
    storage_injector?: StorageInjectorInterface;
    putInCache(address: Address, slot: bigint, value: bigint): Promise<void>;
  };

  // Code storage
  code: Map<string, Uint8Array>;

  // Nonce storage
  nonces: Map<string, bigint>;
}

/**
 * Access list item (EIP-2930)
 */
export interface AccessListItem {
  address: Address;
  storageKeys: bigint[];
}

/**
 * Storage injector interface for async data fetching
 */
export interface StorageInjectorInterface {
  storage_cache: Map<string, bigint>;
  balance_cache: Map<string, bigint>;
  code_cache: Map<string, Uint8Array>;
  nonce_cache: Map<string, bigint>;
  clearCache(): void;
}

/**
 * Creates a string key for address lookups
 */
function addressToString(address: Address): string {
  return Array.from(address)
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

/**
 * Creates a string key for storage lookups
 */
function storageKeyToString(address: Address, slot: bigint): string {
  const addrHex = addressToString(address);
  const slotHex = slot.toString(16).padStart(64, '0');
  return `${addrHex}:${slotHex}`;
}

/**
 * AsyncExecutor - manages async execution state and control flow
 *
 * Handles yielding when the EVM needs external data (storage, balance, code, nonce)
 * and resuming execution once that data is provided.
 */
export class AsyncExecutor {
  private evm: EvmInterface;
  private async_data_request: AsyncDataRequest;

  /**
   * Initialize async executor
   *
   * @param evm - EVM instance to manage
   */
  constructor(evm: EvmInterface) {
    this.evm = evm;
    this.async_data_request = { type: 'none' };
  }

  /**
   * Main async execution method - supports yielding for async requests
   *
   * This is the primary entry point for async EVM execution. It handles:
   * - Starting new calls
   * - Resuming after async data is provided
   * - Finalizing after state commits
   *
   * @param input - Call params or continuation data
   * @returns Result or async data request
   */
  async callOrContinue(
    input: CallOrContinueInput
  ): Promise<CallOrContinueOutput> {
    switch (input.type) {
      case 'call':
        // Start new call - delegate to EVM's call setup
        return await this.startNewCall(input.params);

      case 'continue_with_storage': {
        const key = storageKeyToString(input.address, input.slot);

        // Store value in both cache and storage
        if (this.evm.storage?.storage_injector) {
          this.evm.storage.storage_injector.storage_cache.set(key, input.value);
        }

        // Also put in self.storage so get_storage can find it
        if (this.evm.storage) {
          await this.evm.storage.putInCache(
            input.address,
            input.slot,
            input.value
          );
        }

        // Clear the request
        this.async_data_request = { type: 'none' };

        // Continue execution
        return await this.executeUntilYieldOrComplete();
      }

      case 'continue_with_balance': {
        if (this.evm.storage?.storage_injector) {
          const key = addressToString(input.address);
          this.evm.storage.storage_injector.balance_cache.set(
            key,
            input.balance
          );
        }

        // Clear the request
        this.async_data_request = { type: 'none' };

        return await this.executeUntilYieldOrComplete();
      }

      case 'continue_with_code': {
        if (this.evm.storage?.storage_injector) {
          const key = addressToString(input.address);
          // Make a copy of the code
          const code_copy = new Uint8Array(input.code);
          this.evm.storage.storage_injector.code_cache.set(key, code_copy);
        }

        // Also store in EVM's code map
        const key = addressToString(input.address);
        const code_copy2 = new Uint8Array(input.code);
        this.evm.code.set(key, code_copy2);

        // Clear the request
        this.async_data_request = { type: 'none' };

        return await this.executeUntilYieldOrComplete();
      }

      case 'continue_with_nonce': {
        if (this.evm.storage?.storage_injector) {
          const key = addressToString(input.address);
          this.evm.storage.storage_injector.nonce_cache.set(key, input.nonce);
        }

        // Also store in EVM's nonce map
        const key = addressToString(input.address);
        this.evm.nonces.set(key, input.nonce);

        // Clear the request
        this.async_data_request = { type: 'none' };

        return await this.executeUntilYieldOrComplete();
      }

      case 'continue_after_commit':
        // Commit done - finalize and return result
        return await this.finalizeAndReturnResult();
    }
  }

  /**
   * Start a new call and begin execution
   *
   * Initializes transaction state, sets up the execution context,
   * and begins EVM execution.
   *
   * @param params - Call parameters
   * @returns Result or async data request
   */
  private async startNewCall(
    params: CallParams
  ): Promise<CallOrContinueOutput> {
    // Initialize transaction state in EVM
    await this.evm.initTransactionState(null);

    if (this.evm.storage?.storage_injector) {
      console.debug(
        'callOrContinue: Storage injector enabled, clearing cache'
      );
      this.evm.storage.storage_injector.clearCache();
    } else {
      console.debug('callOrContinue: No storage injector');
    }

    // Extract common parameters
    const caller = this.getCaller(params);
    const gas = this.getGas(params);
    const is_create = this.isCreate(params);

    // Determine target address and value
    let address: Address;
    if (is_create) {
      if (params.type === 'create2') {
        const init_code = params.init_code;
        const salt = params.salt;
        address = await this.evm.computeCreate2Address(caller, salt, init_code);
      } else if (params.type === 'create') {
        const nonce = this.evm.getNonce(caller);
        address = await this.evm.computeCreateAddress(caller, nonce);
      } else {
        throw new Error('Invalid create params');
      }
    } else {
      if (params.type === 'call' || params.type === 'callcode') {
        address = params.to;
      } else if (params.type === 'delegatecall' || params.type === 'staticcall') {
        address = params.to;
      } else {
        throw new Error('Invalid call params');
      }
    }

    const value = this.getValue(params);
    const calldata = this.getInput(params);
    const bytecode = this.evm.pending_bytecode;

    await this.evm.preWarmTransaction(address);

    // Pre-warm access list if present (EIP-2929/EIP-2930)
    if (this.evm.pending_access_list) {
      await this.evm.preWarmFromAccessList(this.evm.pending_access_list);
    }

    // Transfer value if needed
    if (value > 0n) {
      const sender_balance = this.evm.getBalance(caller);
      if (sender_balance < value) {
        throw new Error('InsufficientBalance');
      }
      this.evm.setBalance(caller, sender_balance - value);
      const recipient_balance = this.evm.getBalance(address);
      this.evm.setBalance(address, recipient_balance + value);
    }

    // NOTE: In the Zig version, this creates a Frame and appends it to frames
    // In TypeScript, we delegate this to the EVM's internal implementation
    console.debug(`callOrContinue: Creating frame with address=${addressToString(address)}`);

    // Execute (may yield)
    return await this.executeUntilYieldOrComplete();
  }

  /**
   * Execute until we hit a yield point or complete
   *
   * Delegates to EVM's internal helper method.
   *
   * @returns Result or async data request
   */
  private async executeUntilYieldOrComplete(): Promise<CallOrContinueOutput> {
    // Delegate to EVM's internal helper method
    return await this.evm.executeUntilYieldOrComplete();
  }

  /**
   * Finalize execution and return result
   *
   * Called only when we're truly done (after commit if needed).
   * Delegates to EVM's internal helper method.
   *
   * @returns Final call result
   */
  private async finalizeAndReturnResult(): Promise<CallOrContinueOutput> {
    // Delegate to EVM's internal helper method
    return await this.evm.finalizeAndReturnResult();
  }

  // Helper methods to extract call parameters

  private getCaller(params: CallParams): Address {
    return params.caller;
  }

  private getGas(params: CallParams): bigint {
    return params.gas;
  }

  private isCreate(params: CallParams): boolean {
    return params.type === 'create' || params.type === 'create2';
  }

  private getValue(params: CallParams): bigint {
    switch (params.type) {
      case 'call':
      case 'callcode':
      case 'create':
      case 'create2':
        return params.value;
      case 'delegatecall':
      case 'staticcall':
        return 0n;
    }
  }

  private getInput(params: CallParams): Uint8Array {
    switch (params.type) {
      case 'call':
      case 'callcode':
      case 'delegatecall':
      case 'staticcall':
        return params.input;
      case 'create':
      case 'create2':
        return params.init_code;
    }
  }

  private getTo(params: CallParams): Address | null {
    switch (params.type) {
      case 'call':
      case 'callcode':
      case 'delegatecall':
      case 'staticcall':
        return params.to;
      case 'create':
      case 'create2':
        return null;
    }
  }
}
