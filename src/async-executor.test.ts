/**
 * Test suite for AsyncExecutor
 *
 * Tests async execution flow including:
 * - Starting new calls
 * - Yielding for async data (storage, balance, code, nonce)
 * - Resuming after data is provided
 * - State preservation across yields
 *
 * Port of async executor test patterns from Zig
 */

import { describe, it, expect, beforeEach } from 'bun:test';
import {
  AsyncExecutor,
  type CallOrContinueInput,
  type CallOrContinueOutput,
  type CallParams,
  type CallResult,
  type Address,
  type EvmInterface,
  type AccessListItem,
  type StorageInjectorInterface,
} from './async-executor';

/**
 * Mock storage injector for testing
 */
class MockStorageInjector implements StorageInjectorInterface {
  storage_cache = new Map<string, bigint>();
  balance_cache = new Map<string, bigint>();
  code_cache = new Map<string, Uint8Array>();
  nonce_cache = new Map<string, bigint>();

  clearCache(): void {
    this.storage_cache.clear();
    this.balance_cache.clear();
    this.code_cache.clear();
    this.nonce_cache.clear();
  }
}

/**
 * Mock EVM for testing async executor
 */
class MockEvm implements EvmInterface {
  pending_bytecode: Uint8Array = new Uint8Array();
  pending_access_list: AccessListItem[] | null = null;
  code = new Map<string, Uint8Array>();
  nonces = new Map<string, bigint>();

  private balances = new Map<string, bigint>();
  private execution_state: 'running' | 'need_storage' | 'complete' = 'running';
  private execution_result: CallResult | null = null;
  private storage_request: { address: Address; slot: bigint } | null = null;

  storage?: {
    storage_injector?: StorageInjectorInterface;
    putInCache(address: Address, slot: bigint, value: bigint): Promise<void>;
  };

  constructor() {
    this.storage = {
      storage_injector: new MockStorageInjector(),
      putInCache: async (address: Address, slot: bigint, value: bigint) => {
        // No-op for mock
      },
    };
  }

  async initTransactionState(accessList: AccessListItem[] | null): Promise<void> {
    // Only reset if not already in a yield state
    if (this.execution_state !== 'need_storage') {
      this.execution_state = 'running';
      this.execution_result = null;
    }
  }

  async computeCreate2Address(
    caller: Address,
    salt: bigint,
    initCode: Uint8Array
  ): Promise<Address> {
    // Mock implementation - return deterministic address
    const addr = new Uint8Array(20);
    addr[0] = 0xc2; // CREATE2 marker
    return addr;
  }

  async computeCreateAddress(caller: Address, nonce: bigint): Promise<Address> {
    // Mock implementation - return deterministic address
    const addr = new Uint8Array(20);
    addr[0] = 0xc1; // CREATE marker
    return addr;
  }

  getNonce(address: Address): bigint {
    const key = this.addressToString(address);
    return this.nonces.get(key) ?? 0n;
  }

  async preWarmTransaction(address: Address): Promise<void> {
    // No-op for mock
  }

  async preWarmFromAccessList(list: AccessListItem[]): Promise<void> {
    // No-op for mock
  }

  getBalance(address: Address): bigint {
    const key = this.addressToString(address);
    return this.balances.get(key) ?? 0n;
  }

  setBalance(address: Address, balance: bigint): void {
    const key = this.addressToString(address);
    this.balances.set(key, balance);
  }

  async executeUntilYieldOrComplete(): Promise<CallOrContinueOutput> {
    // Simulate execution behavior
    if (this.execution_state === 'need_storage' && this.storage_request) {
      // Yield for storage
      const result = {
        type: 'need_storage' as const,
        address: this.storage_request.address,
        slot: this.storage_request.slot,
      };
      // Clear request after returning it once
      this.storage_request = null;
      return result;
    } else if (this.execution_state === 'complete' && this.execution_result) {
      // Execution complete
      return {
        type: 'result',
        result: this.execution_result,
      };
    } else {
      // Default: complete successfully
      this.execution_state = 'complete';
      this.execution_result = {
        success: true,
        gas_left: 1000n,
        output: new Uint8Array(),
      };
      return {
        type: 'result',
        result: this.execution_result,
      };
    }
  }

  async finalizeAndReturnResult(): Promise<CallOrContinueOutput> {
    if (!this.execution_result) {
      throw new Error('No result to finalize');
    }
    return {
      type: 'result',
      result: this.execution_result,
    };
  }

  // Test helpers

  simulateStorageRequest(address: Address, slot: bigint): void {
    this.execution_state = 'need_storage';
    this.storage_request = { address, slot };
  }

  setExecutionResult(result: CallResult): void {
    this.execution_state = 'complete';
    this.execution_result = result;
  }

  private addressToString(address: Address): string {
    return Array.from(address)
      .map((b) => b.toString(16).padStart(2, '0'))
      .join('');
  }
}

describe('AsyncExecutor', () => {
  let evm: MockEvm;
  let executor: AsyncExecutor;

  beforeEach(() => {
    evm = new MockEvm();
    executor = new AsyncExecutor(evm);
  });

  describe('startNewCall', () => {
    it('should start a new CALL and execute', async () => {
      const caller = new Uint8Array(20);
      caller[0] = 0xaa;
      const to = new Uint8Array(20);
      to[0] = 0xbb;

      const params: CallParams = {
        type: 'call',
        caller,
        to,
        value: 100n,
        input: new Uint8Array([1, 2, 3]),
        gas: 10000n,
      };

      // Set up sender balance
      evm.setBalance(caller, 1000n);

      const output = await executor.callOrContinue({ type: 'call', params });

      // Should complete successfully
      expect(output.type).toBe('result');
      if (output.type === 'result') {
        expect(output.result.success).toBe(true);
        expect(output.result.gas_left).toBe(1000n);
      }

      // Check value was transferred
      expect(evm.getBalance(caller)).toBe(900n);
      expect(evm.getBalance(to)).toBe(100n);
    });

    it('should fail with insufficient balance', async () => {
      const caller = new Uint8Array(20);
      caller[0] = 0xaa;
      const to = new Uint8Array(20);
      to[0] = 0xbb;

      const params: CallParams = {
        type: 'call',
        caller,
        to,
        value: 100n,
        input: new Uint8Array(),
        gas: 10000n,
      };

      // Sender has no balance
      evm.setBalance(caller, 50n); // Less than value

      await expect(
        executor.callOrContinue({ type: 'call', params })
      ).rejects.toThrow('InsufficientBalance');
    });

    it('should handle CREATE', async () => {
      const caller = new Uint8Array(20);
      caller[0] = 0xaa;

      const params: CallParams = {
        type: 'create',
        caller,
        value: 0n,
        init_code: new Uint8Array([0x60, 0x00]), // PUSH1 0
        gas: 10000n,
      };

      const output = await executor.callOrContinue({ type: 'call', params });

      expect(output.type).toBe('result');
      if (output.type === 'result') {
        expect(output.result.success).toBe(true);
      }
    });

    it('should handle CREATE2', async () => {
      const caller = new Uint8Array(20);
      caller[0] = 0xaa;

      const params: CallParams = {
        type: 'create2',
        caller,
        value: 0n,
        init_code: new Uint8Array([0x60, 0x00]),
        salt: 123n,
        gas: 10000n,
      };

      const output = await executor.callOrContinue({ type: 'call', params });

      expect(output.type).toBe('result');
      if (output.type === 'result') {
        expect(output.result.success).toBe(true);
      }
    });

    it('should handle DELEGATECALL (no value transfer)', async () => {
      const caller = new Uint8Array(20);
      caller[0] = 0xaa;
      const to = new Uint8Array(20);
      to[0] = 0xbb;

      const params: CallParams = {
        type: 'delegatecall',
        caller,
        to,
        input: new Uint8Array(),
        gas: 10000n,
      };

      evm.setBalance(caller, 1000n);

      const output = await executor.callOrContinue({ type: 'call', params });

      expect(output.type).toBe('result');
      // No value transfer for DELEGATECALL
      expect(evm.getBalance(caller)).toBe(1000n);
    });

    it('should handle STATICCALL (no value transfer)', async () => {
      const caller = new Uint8Array(20);
      caller[0] = 0xaa;
      const to = new Uint8Array(20);
      to[0] = 0xbb;

      const params: CallParams = {
        type: 'staticcall',
        caller,
        to,
        input: new Uint8Array(),
        gas: 10000n,
      };

      evm.setBalance(caller, 1000n);

      const output = await executor.callOrContinue({ type: 'call', params });

      expect(output.type).toBe('result');
      // No value transfer for STATICCALL
      expect(evm.getBalance(caller)).toBe(1000n);
    });
  });

  describe('async data requests', () => {
    it('should yield for storage data', async () => {
      const caller = new Uint8Array(20);
      caller[0] = 0xaa;
      const to = new Uint8Array(20);
      to[0] = 0xbb;

      const params: CallParams = {
        type: 'call',
        caller,
        to,
        value: 0n,
        input: new Uint8Array(),
        gas: 10000n,
      };

      // Simulate storage request
      evm.simulateStorageRequest(to, 42n);

      const output = await executor.callOrContinue({ type: 'call', params });

      expect(output.type).toBe('need_storage');
      if (output.type === 'need_storage') {
        expect(output.address).toEqual(to);
        expect(output.slot).toBe(42n);
      }
    });

    it('should resume after storage data is provided', async () => {
      const caller = new Uint8Array(20);
      caller[0] = 0xaa;
      const to = new Uint8Array(20);
      to[0] = 0xbb;

      // First call yields for storage
      const params: CallParams = {
        type: 'call',
        caller,
        to,
        value: 0n,
        input: new Uint8Array(),
        gas: 10000n,
      };

      evm.simulateStorageRequest(to, 42n);
      const output1 = await executor.callOrContinue({ type: 'call', params });

      expect(output1.type).toBe('need_storage');

      // Provide storage value and resume
      evm.setExecutionResult({
        success: true,
        gas_left: 900n,
        output: new Uint8Array([0x01, 0x02]),
      });

      const output2 = await executor.callOrContinue({
        type: 'continue_with_storage',
        address: to,
        slot: 42n,
        value: 999n,
      });

      expect(output2.type).toBe('result');
      if (output2.type === 'result') {
        expect(output2.result.success).toBe(true);
        expect(output2.result.gas_left).toBe(900n);
        expect(output2.result.output).toEqual(new Uint8Array([0x01, 0x02]));
      }
    });

    it('should resume after balance data is provided', async () => {
      const caller = new Uint8Array(20);
      caller[0] = 0xaa;

      evm.setExecutionResult({
        success: true,
        gas_left: 800n,
        output: new Uint8Array(),
      });

      const output = await executor.callOrContinue({
        type: 'continue_with_balance',
        address: caller,
        balance: 5000n,
      });

      expect(output.type).toBe('result');
      if (output.type === 'result') {
        expect(output.result.success).toBe(true);
        expect(output.result.gas_left).toBe(800n);
      }

      // Check cache was updated
      if (evm.storage?.storage_injector) {
        const key = Array.from(caller)
          .map((b) => b.toString(16).padStart(2, '0'))
          .join('');
        expect(evm.storage.storage_injector.balance_cache.get(key)).toBe(5000n);
      }
    });

    it('should resume after code data is provided', async () => {
      const caller = new Uint8Array(20);
      caller[0] = 0xaa;
      const code = new Uint8Array([0x60, 0x01, 0x60, 0x02, 0x01]); // PUSH1 1 PUSH1 2 ADD

      evm.setExecutionResult({
        success: true,
        gas_left: 700n,
        output: new Uint8Array(),
      });

      const output = await executor.callOrContinue({
        type: 'continue_with_code',
        address: caller,
        code,
      });

      expect(output.type).toBe('result');

      // Check cache was updated
      if (evm.storage?.storage_injector) {
        const key = Array.from(caller)
          .map((b) => b.toString(16).padStart(2, '0'))
          .join('');
        expect(evm.storage.storage_injector.code_cache.get(key)).toEqual(code);
      }

      // Check EVM's code map was updated
      const key = Array.from(caller)
        .map((b) => b.toString(16).padStart(2, '0'))
        .join('');
      expect(evm.code.get(key)).toEqual(code);
    });

    it('should resume after nonce data is provided', async () => {
      const caller = new Uint8Array(20);
      caller[0] = 0xaa;

      evm.setExecutionResult({
        success: true,
        gas_left: 600n,
        output: new Uint8Array(),
      });

      const output = await executor.callOrContinue({
        type: 'continue_with_nonce',
        address: caller,
        nonce: 42n,
      });

      expect(output.type).toBe('result');

      // Check cache was updated
      if (evm.storage?.storage_injector) {
        const key = Array.from(caller)
          .map((b) => b.toString(16).padStart(2, '0'))
          .join('');
        expect(evm.storage.storage_injector.nonce_cache.get(key)).toBe(42n);
      }

      // Check EVM's nonce map was updated
      const key = Array.from(caller)
        .map((b) => b.toString(16).padStart(2, '0'))
        .join('');
      expect(evm.nonces.get(key)).toBe(42n);
    });

    it('should handle continue_after_commit', async () => {
      evm.setExecutionResult({
        success: true,
        gas_left: 500n,
        output: new Uint8Array([0xff]),
      });

      const output = await executor.callOrContinue({
        type: 'continue_after_commit',
      });

      expect(output.type).toBe('result');
      if (output.type === 'result') {
        expect(output.result.success).toBe(true);
        expect(output.result.gas_left).toBe(500n);
        expect(output.result.output).toEqual(new Uint8Array([0xff]));
      }
    });
  });

  describe('cache management', () => {
    it('should clear storage injector cache on new call', async () => {
      const caller = new Uint8Array(20);
      caller[0] = 0xaa;
      const to = new Uint8Array(20);
      to[0] = 0xbb;

      // Pre-populate cache
      if (evm.storage?.storage_injector) {
        evm.storage.storage_injector.storage_cache.set('key1', 999n);
        evm.storage.storage_injector.balance_cache.set('key2', 888n);
        expect(evm.storage.storage_injector.storage_cache.size).toBe(1);
        expect(evm.storage.storage_injector.balance_cache.size).toBe(1);
      }

      const params: CallParams = {
        type: 'call',
        caller,
        to,
        value: 0n,
        input: new Uint8Array(),
        gas: 10000n,
      };

      await executor.callOrContinue({ type: 'call', params });

      // Cache should be cleared
      if (evm.storage?.storage_injector) {
        expect(evm.storage.storage_injector.storage_cache.size).toBe(0);
        expect(evm.storage.storage_injector.balance_cache.size).toBe(0);
      }
    });
  });

  describe('state preservation', () => {
    it('should preserve EVM state across yields', async () => {
      const caller = new Uint8Array(20);
      caller[0] = 0xaa;
      const to = new Uint8Array(20);
      to[0] = 0xbb;

      // Set initial state
      evm.setBalance(caller, 1000n);
      evm.nonces.set(
        Array.from(caller)
          .map((b) => b.toString(16).padStart(2, '0'))
          .join(''),
        5n
      );

      const params: CallParams = {
        type: 'call',
        caller,
        to,
        value: 100n,
        input: new Uint8Array(),
        gas: 10000n,
      };

      // First call (transfers value)
      evm.simulateStorageRequest(to, 42n);
      await executor.callOrContinue({ type: 'call', params });

      // State should be preserved
      expect(evm.getBalance(caller)).toBe(900n); // Value transferred
      expect(evm.getBalance(to)).toBe(100n);
      expect(evm.getNonce(caller)).toBe(5n); // Nonce unchanged

      // Resume and complete
      evm.setExecutionResult({
        success: true,
        gas_left: 800n,
        output: new Uint8Array(),
      });

      const output = await executor.callOrContinue({
        type: 'continue_with_storage',
        address: to,
        slot: 42n,
        value: 999n,
      });

      expect(output.type).toBe('result');

      // State still preserved
      expect(evm.getBalance(caller)).toBe(900n);
      expect(evm.getBalance(to)).toBe(100n);
    });
  });
});
