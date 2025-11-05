/**
 * Test suite for storage opcode handlers
 * Tests SLOAD, SSTORE, TLOAD, TSTORE with full EIP coverage
 */

import { describe, it, expect, beforeEach } from 'bun:test';
import {
  sload,
  sstore,
  tload,
  tstore,
  GasConstants,
  Hardfork,
  sstoreGasCostWithHardfork,
  storageKeyToString,
  type FrameInterface,
  type EvmInterface,
  type StorageInterface,
} from './handlers_storage';
import { CallError, EvmError } from '../errors';
import type { Address } from '../host';

/**
 * Mock Storage implementation for testing
 */
class MockStorage implements StorageInterface {
  private storage = new Map<string, bigint>();
  private original = new Map<string, bigint>();
  private transient = new Map<string, bigint>();

  private makeKey(address: Address, slot: bigint): string {
    return storageKeyToString({ address, slot });
  }

  get(address: Address, slot: bigint): bigint {
    return this.storage.get(this.makeKey(address, slot)) ?? 0n;
  }

  set(address: Address, slot: bigint, value: bigint): void {
    const key = this.makeKey(address, slot);
    // Track original on first write (via SSTORE)
    if (!this.original.has(key)) {
      this.original.set(key, this.get(address, slot));
    }
    if (value === 0n) {
      this.storage.delete(key);
    } else {
      this.storage.set(key, value);
    }
  }

  getOriginal(address: Address, slot: bigint): bigint {
    const key = this.makeKey(address, slot);
    return this.original.get(key) ?? this.get(address, slot);
  }

  getTransient(address: Address, slot: bigint): bigint {
    return this.transient.get(this.makeKey(address, slot)) ?? 0n;
  }

  setTransient(address: Address, slot: bigint, value: bigint): void {
    const key = this.makeKey(address, slot);
    if (value === 0n) {
      this.transient.delete(key);
    } else {
      this.transient.set(key, value);
    }
  }

  clearTransient(): void {
    this.transient.clear();
  }

  reset(): void {
    this.storage.clear();
    this.original.clear();
    this.transient.clear();
  }

  /**
   * Pre-populate storage without tracking as original (for test setup)
   * Simulates storage that existed before transaction start
   */
  prePopulate(address: Address, slot: bigint, value: bigint): void {
    const key = this.makeKey(address, slot);
    if (value === 0n) {
      this.storage.delete(key);
    } else {
      this.storage.set(key, value);
    }
    // Don't set original - let it be tracked on first SSTORE
  }
}

/**
 * Mock EVM implementation for testing
 */
class MockEvm implements EvmInterface {
  hardfork: Hardfork = Hardfork.CANCUN;
  storage: StorageInterface = new MockStorage();
  gas_refund = 0n;
  private warm_slots = new Set<string>();

  accessStorageSlot(address: Address, slot: bigint): bigint {
    const key = storageKeyToString({ address, slot });
    if (this.warm_slots.has(key)) {
      return GasConstants.WarmStorageReadCost; // 100
    }
    this.warm_slots.add(key);
    return GasConstants.ColdSloadCost; // 2100
  }

  addRefund(amount: bigint): void {
    this.gas_refund += amount;
  }

  subtractRefund(amount: bigint): void {
    this.gas_refund = this.gas_refund >= amount ? this.gas_refund - amount : 0n;
  }

  reset(): void {
    this.gas_refund = 0n;
    this.warm_slots.clear();
    (this.storage as MockStorage).reset();
  }
}

/**
 * Mock Frame implementation for testing
 */
class MockFrame implements FrameInterface {
  private stack: bigint[] = [];
  gas_remaining = 1000000n;
  address: Address = new Uint8Array(20); // Zero address
  is_static = false;
  pc = 0;
  private evm: EvmInterface;

  constructor(evm: EvmInterface) {
    this.evm = evm;
  }

  popStack(): bigint {
    const value = this.stack.pop();
    if (value === undefined) {
      throw new EvmError(CallError.StackUnderflow);
    }
    return value;
  }

  pushStack(value: bigint): void {
    if (this.stack.length >= 1024) {
      throw new EvmError(CallError.StackOverflow);
    }
    this.stack.push(value);
  }

  consumeGas(amount: bigint): void {
    if (this.gas_remaining < amount) {
      throw new EvmError(CallError.OutOfGas);
    }
    this.gas_remaining -= amount;
  }

  getEvm(): EvmInterface {
    return this.evm;
  }

  reset(): void {
    this.stack = [];
    this.gas_remaining = 1000000n;
    this.is_static = false;
    this.pc = 0;
  }
}

describe('Storage Handlers', () => {
  let evm: MockEvm;
  let frame: MockFrame;

  beforeEach(() => {
    evm = new MockEvm();
    frame = new MockFrame(evm);
  });

  describe('storageKeyToString', () => {
    it('should create unique keys for different addresses', () => {
      const addr1 = new Uint8Array(20);
      addr1[19] = 1;
      const addr2 = new Uint8Array(20);
      addr2[19] = 2;

      const key1 = storageKeyToString({ address: addr1, slot: 0n });
      const key2 = storageKeyToString({ address: addr2, slot: 0n });

      expect(key1).not.toBe(key2);
    });

    it('should create unique keys for different slots', () => {
      const addr = new Uint8Array(20);
      const key1 = storageKeyToString({ address: addr, slot: 0n });
      const key2 = storageKeyToString({ address: addr, slot: 1n });

      expect(key1).not.toBe(key2);
    });

    it('should handle large slot values', () => {
      const addr = new Uint8Array(20);
      const largeSlot = 2n ** 256n - 1n; // Max u256
      const key = storageKeyToString({ address: addr, slot: largeSlot });

      expect(key).toContain(':');
      expect(key.length).toBeGreaterThan(40); // Address (40) + delimiter + slot
    });
  });

  describe('sstoreGasCostWithHardfork', () => {
    it('should charge SET cost for fresh 0 → non-zero (Istanbul+)', () => {
      const cost = sstoreGasCostWithHardfork(
        0n,     // current
        0n,     // original
        100n,   // new value
        false,  // not cold
        true,   // Berlin+
        true    // Istanbul+
      );
      expect(cost).toBe(GasConstants.SstoreSetGas); // 20,000
    });

    it('should charge RESET cost for fresh non-zero → different (Istanbul+)', () => {
      const cost = sstoreGasCostWithHardfork(
        100n,   // current
        100n,   // original
        200n,   // new value
        false,  // not cold
        true,   // Berlin+
        true    // Istanbul+
      );
      expect(cost).toBe(GasConstants.SstoreResetGas); // 5,000
    });

    it('should charge warm cost for no-op (Istanbul+)', () => {
      const cost = sstoreGasCostWithHardfork(
        100n,   // current
        100n,   // original
        100n,   // new value (unchanged)
        false,  // not cold
        true,   // Berlin+
        true    // Istanbul+
      );
      expect(cost).toBe(GasConstants.WarmStorageReadCost); // 100
    });

    it('should charge warm cost when restoring to original (Istanbul+)', () => {
      const cost = sstoreGasCostWithHardfork(
        200n,   // current (dirty)
        100n,   // original
        100n,   // new value (restoring)
        false,  // not cold
        true,   // Berlin+
        true    // Istanbul+
      );
      expect(cost).toBe(GasConstants.WarmStorageReadCost); // 100
    });

    it('should charge warm cost when value already dirty (Istanbul+)', () => {
      const cost = sstoreGasCostWithHardfork(
        200n,   // current (already changed)
        100n,   // original
        300n,   // new value (changing again)
        false,  // not cold
        true,   // Berlin+
        true    // Istanbul+
      );
      expect(cost).toBe(GasConstants.WarmStorageReadCost); // 100
    });

    it('should add cold cost when slot is cold (Berlin+)', () => {
      const cost = sstoreGasCostWithHardfork(
        0n,     // current
        0n,     // original
        100n,   // new value
        true,   // COLD access
        true,   // Berlin+
        true    // Istanbul+
      );
      expect(cost).toBe(GasConstants.SstoreSetGas + GasConstants.ColdSloadCost); // 20,000 + 2,100
    });

    it('should use simple logic pre-Istanbul', () => {
      // 0 → non-zero should cost 20,000
      const cost1 = sstoreGasCostWithHardfork(
        0n, 0n, 100n,
        false, false, false
      );
      expect(cost1).toBe(GasConstants.SstoreSetGas); // 20,000

      // Any other change should cost 5,000
      const cost2 = sstoreGasCostWithHardfork(
        100n, 100n, 200n,
        false, false, false
      );
      expect(cost2).toBe(GasConstants.SstoreResetGas); // 5,000
    });
  });

  describe('SLOAD (0x54)', () => {
    beforeEach(() => {
      frame.reset();
      evm.reset();
    });

    it('should load value from storage', () => {
      (evm.storage as MockStorage).prePopulate(frame.address, 5n, 42n);
      frame.pushStack(5n); // slot

      sload(frame);

      expect(frame.popStack()).toBe(42n);
      expect(frame.pc).toBe(1);
    });

    it('should return 0 for empty slot', () => {
      frame.pushStack(10n); // slot (not set)

      sload(frame);

      expect(frame.popStack()).toBe(0n);
    });

    it('should charge cold access cost (2100) on first access', () => {
      frame.pushStack(5n);
      const gas_before = frame.gas_remaining;

      sload(frame);

      const gas_used = gas_before - frame.gas_remaining;
      expect(gas_used).toBe(GasConstants.ColdSloadCost); // 2100
    });

    it('should charge warm access cost (100) on second access', () => {
      // First access (cold)
      frame.pushStack(5n);
      sload(frame);
      frame.popStack(); // Clear result

      // Second access (warm)
      frame.pushStack(5n);
      const gas_before = frame.gas_remaining;
      sload(frame);

      const gas_used = gas_before - frame.gas_remaining;
      expect(gas_used).toBe(GasConstants.WarmStorageReadCost); // 100
    });

    it('should throw on stack underflow', () => {
      // No value on stack
      expect(() => sload(frame)).toThrow(EvmError);
      expect(() => sload(frame)).toThrow(CallError.StackUnderflow);
    });
  });

  describe('SSTORE (0x55)', () => {
    beforeEach(() => {
      frame.reset();
      evm.reset();
      evm.hardfork = Hardfork.CANCUN; // Default to latest
    });

    describe('Basic operation', () => {
      it('should store value in storage', () => {
        frame.pushStack(100n); // value
        frame.pushStack(5n);   // slot

        sstore(frame);

        expect(evm.storage.get(frame.address, 5n)).toBe(100n);
        expect(frame.pc).toBe(1);
      });

      it('should throw in static call context', () => {
        frame.is_static = true;
        frame.pushStack(100n); // value
        frame.pushStack(5n);   // slot

        expect(() => sstore(frame)).toThrow(EvmError);
        expect(() => sstore(frame)).toThrow(CallError.StaticCallViolation);
      });

      it('should throw if gas < 2300 (Istanbul+ sentry check)', () => {
        evm.hardfork = Hardfork.ISTANBUL;
        frame.gas_remaining = 2300n; // Exactly at limit
        frame.pushStack(100n);
        frame.pushStack(5n);

        expect(() => sstore(frame)).toThrow(EvmError);
        expect(() => sstore(frame)).toThrow(CallError.OutOfGas);
      });

      it('should succeed if gas > 2300 (Istanbul+)', () => {
        evm.hardfork = Hardfork.ISTANBUL;
        frame.gas_remaining = 25000n;
        frame.pushStack(100n);
        frame.pushStack(5n);

        expect(() => sstore(frame)).not.toThrow();
      });
    });

    describe('Gas costs (Cancun)', () => {
      beforeEach(() => {
        evm.hardfork = Hardfork.CANCUN;
      });

      it('should charge 20,000 + 2,100 for cold 0 → non-zero', () => {
        frame.pushStack(100n); // value
        frame.pushStack(5n);   // slot (cold)
        const gas_before = frame.gas_remaining;

        sstore(frame);

        const gas_used = gas_before - frame.gas_remaining;
        expect(gas_used).toBe(GasConstants.SstoreSetGas + GasConstants.ColdSloadCost); // 22,100
      });

      it('should charge 100 for warm 0 → non-zero second time (dirty)', () => {
        // First write: 0 → 100 (costs 22,100)
        frame.pushStack(100n);
        frame.pushStack(5n);
        sstore(frame);

        // Second write: 100 → 200 (costs 100, value already dirty)
        frame.pushStack(200n);
        frame.pushStack(5n);
        const gas_before = frame.gas_remaining;
        sstore(frame);

        const gas_used = gas_before - frame.gas_remaining;
        expect(gas_used).toBe(GasConstants.WarmStorageReadCost); // 100
      });

      it('should charge 5,000 + 2,100 for cold non-zero → different', () => {
        // Pre-populate storage (simulates storage before transaction)
        (evm.storage as MockStorage).prePopulate(frame.address, 5n, 100n);

        frame.pushStack(200n); // value
        frame.pushStack(5n);   // slot (cold)
        const gas_before = frame.gas_remaining;

        sstore(frame);

        const gas_used = gas_before - frame.gas_remaining;
        expect(gas_used).toBe(GasConstants.SstoreResetGas + GasConstants.ColdSloadCost); // 7,100
      });

      it('should charge 100 for no-op (same value)', () => {
        // Pre-populate storage (simulates storage before transaction)
        (evm.storage as MockStorage).prePopulate(frame.address, 5n, 100n);
        // Warm the slot
        evm.accessStorageSlot(frame.address, 5n);

        frame.pushStack(100n); // same value
        frame.pushStack(5n);
        const gas_before = frame.gas_remaining;

        sstore(frame);

        const gas_used = gas_before - frame.gas_remaining;
        expect(gas_used).toBe(GasConstants.WarmStorageReadCost); // 100
      });
    });

    describe('Refunds (London+)', () => {
      beforeEach(() => {
        evm.hardfork = Hardfork.LONDON;
      });

      it('should refund 4,800 when clearing storage (non-zero → 0)', () => {
        // Pre-populate storage (simulates storage before transaction)
        (evm.storage as MockStorage).prePopulate(frame.address, 5n, 100n);
        // Warm the slot
        evm.accessStorageSlot(frame.address, 5n);

        frame.pushStack(0n); // clear
        frame.pushStack(5n);
        sstore(frame);

        expect(evm.gas_refund).toBe(GasConstants.SstoreRefundGas); // 4,800
      });

      it('should subtract 4,800 refund when reversing a clear', () => {
        // Pre-populate storage (simulates storage before transaction)
        (evm.storage as MockStorage).prePopulate(frame.address, 5n, 100n);
        evm.accessStorageSlot(frame.address, 5n);

        // Clear (gives 4,800 refund)
        frame.pushStack(0n);
        frame.pushStack(5n);
        sstore(frame);
        expect(evm.gas_refund).toBe(4800n);

        // Reverse clear (subtracts 4,800 refund)
        frame.pushStack(200n);
        frame.pushStack(5n);
        sstore(frame);
        expect(evm.gas_refund).toBe(0n);
      });

      it('should refund 19,900 when restoring to original 0', () => {
        // Original: 0, change to 100, then restore to 0
        evm.accessStorageSlot(frame.address, 5n); // Warm

        // Set 0 → 100 (no refund)
        frame.pushStack(100n);
        frame.pushStack(5n);
        sstore(frame);
        expect(evm.gas_refund).toBe(0n);

        // Restore 100 → 0 (refund 19,900)
        frame.pushStack(0n);
        frame.pushStack(5n);
        sstore(frame);
        expect(evm.gas_refund).toBe(19900n); // 20,000 - 100
      });

      it('should refund 2,800 when restoring to original non-zero', () => {
        // Pre-populate storage to 100 (simulates storage before transaction)
        (evm.storage as MockStorage).prePopulate(frame.address, 5n, 100n);
        evm.accessStorageSlot(frame.address, 5n); // Warm

        // Change 100 → 200 (no refund)
        frame.pushStack(200n);
        frame.pushStack(5n);
        sstore(frame);
        expect(evm.gas_refund).toBe(0n);

        // Restore 200 → 100 (refund 2,800)
        frame.pushStack(100n);
        frame.pushStack(5n);
        sstore(frame);
        expect(evm.gas_refund).toBe(2800n); // 5,000 - 2,100 - 100
      });

      it('should handle complex refund scenario (clear + reverse + restore)', () => {
        // Original: 100 (pre-populate to simulate storage before transaction)
        (evm.storage as MockStorage).prePopulate(frame.address, 5n, 100n);
        evm.accessStorageSlot(frame.address, 5n);

        // 100 → 0 (clear, +4,800 refund)
        frame.pushStack(0n);
        frame.pushStack(5n);
        sstore(frame);
        expect(evm.gas_refund).toBe(4800n);

        // 0 → 200 (reverse clear, -4,800 refund)
        frame.pushStack(200n);
        frame.pushStack(5n);
        sstore(frame);
        expect(evm.gas_refund).toBe(0n);

        // 200 → 100 (restore to original, +2,800 refund)
        frame.pushStack(100n);
        frame.pushStack(5n);
        sstore(frame);
        expect(evm.gas_refund).toBe(2800n);
      });
    });

    describe('Pre-Istanbul refunds', () => {
      beforeEach(() => {
        evm.hardfork = Hardfork.CONSTANTINOPLE;
      });

      it('should refund 15,000 when clearing storage', () => {
        (evm.storage as MockStorage).prePopulate(frame.address, 5n, 100n);

        frame.pushStack(0n); // clear
        frame.pushStack(5n);
        sstore(frame);

        expect(evm.gas_refund).toBe(15000n);
      });

      it('should not refund for non-clearing operations', () => {
        (evm.storage as MockStorage).prePopulate(frame.address, 5n, 100n);

        frame.pushStack(200n); // change but not clear
        frame.pushStack(5n);
        sstore(frame);

        expect(evm.gas_refund).toBe(0n);
      });

      it('should charge 20,000 for 0 → non-zero', () => {
        frame.pushStack(100n);
        frame.pushStack(5n);
        const gas_before = frame.gas_remaining;

        sstore(frame);

        const gas_used = gas_before - frame.gas_remaining;
        expect(gas_used).toBe(GasConstants.SstoreSetGas); // 20,000
      });

      it('should charge 5,000 for other changes', () => {
        (evm.storage as MockStorage).prePopulate(frame.address, 5n, 100n);

        frame.pushStack(200n);
        frame.pushStack(5n);
        const gas_before = frame.gas_remaining;

        sstore(frame);

        const gas_used = gas_before - frame.gas_remaining;
        expect(gas_used).toBe(GasConstants.SstoreResetGas); // 5,000
      });
    });
  });

  describe('TLOAD (0x5c)', () => {
    beforeEach(() => {
      frame.reset();
      evm.reset();
      evm.hardfork = Hardfork.CANCUN;
    });

    it('should load value from transient storage', () => {
      evm.storage.setTransient(frame.address, 5n, 42n);
      frame.pushStack(5n); // slot

      tload(frame);

      expect(frame.popStack()).toBe(42n);
      expect(frame.pc).toBe(1);
    });

    it('should return 0 for empty transient slot', () => {
      frame.pushStack(10n); // slot (not set)

      tload(frame);

      expect(frame.popStack()).toBe(0n);
    });

    it('should charge 100 gas (always warm)', () => {
      frame.pushStack(5n);
      const gas_before = frame.gas_remaining;

      tload(frame);

      const gas_used = gas_before - frame.gas_remaining;
      expect(gas_used).toBe(GasConstants.TLoadGas); // 100
    });

    it('should throw InvalidOpcode pre-Cancun', () => {
      evm.hardfork = Hardfork.SHANGHAI;
      frame.pushStack(5n);

      expect(() => tload(frame)).toThrow(EvmError);
      expect(() => tload(frame)).toThrow(CallError.InvalidOpcode);
    });

    it('should be independent of persistent storage', () => {
      // Set persistent storage (use prePopulate)
      (evm.storage as MockStorage).prePopulate(frame.address, 5n, 100n);
      // Set transient storage to different value
      evm.storage.setTransient(frame.address, 5n, 42n);

      frame.pushStack(5n);
      tload(frame);

      expect(frame.popStack()).toBe(42n); // Gets transient, not persistent
    });
  });

  describe('TSTORE (0x5d)', () => {
    beforeEach(() => {
      frame.reset();
      evm.reset();
      evm.hardfork = Hardfork.CANCUN;
    });

    it('should store value in transient storage', () => {
      frame.pushStack(100n); // value
      frame.pushStack(5n);   // slot

      tstore(frame);

      expect(evm.storage.getTransient(frame.address, 5n)).toBe(100n);
      expect(frame.pc).toBe(1);
    });

    it('should throw in static call context', () => {
      frame.is_static = true;
      frame.pushStack(100n);
      frame.pushStack(5n);

      expect(() => tstore(frame)).toThrow(EvmError);
      expect(() => tstore(frame)).toThrow(CallError.StaticCallViolation);
    });

    it('should charge 100 gas (always warm)', () => {
      frame.pushStack(100n);
      frame.pushStack(5n);
      const gas_before = frame.gas_remaining;

      tstore(frame);

      const gas_used = gas_before - frame.gas_remaining;
      expect(gas_used).toBe(GasConstants.TStoreGas); // 100
    });

    it('should throw InvalidOpcode pre-Cancun', () => {
      evm.hardfork = Hardfork.SHANGHAI;
      frame.pushStack(100n);
      frame.pushStack(5n);

      expect(() => tstore(frame)).toThrow(EvmError);
      expect(() => tstore(frame)).toThrow(CallError.InvalidOpcode);
    });

    it('should be independent of persistent storage', () => {
      // Set persistent storage (use prePopulate)
      (evm.storage as MockStorage).prePopulate(frame.address, 5n, 100n);
      // Set transient storage to different value
      frame.pushStack(42n);
      frame.pushStack(5n);
      tstore(frame);

      expect(evm.storage.get(frame.address, 5n)).toBe(100n); // Persistent unchanged
      expect(evm.storage.getTransient(frame.address, 5n)).toBe(42n); // Transient set
    });

    it('should delete transient slot when setting to 0', () => {
      // Set transient storage
      evm.storage.setTransient(frame.address, 5n, 100n);

      // Clear transient storage
      frame.pushStack(0n);
      frame.pushStack(5n);
      tstore(frame);

      expect(evm.storage.getTransient(frame.address, 5n)).toBe(0n);
    });

    it('should not affect gas refunds', () => {
      frame.pushStack(100n);
      frame.pushStack(5n);
      tstore(frame);

      expect(evm.gas_refund).toBe(0n); // Transient storage never gives refunds
    });

    it('should overwrite previous transient value', () => {
      evm.storage.setTransient(frame.address, 5n, 100n);

      frame.pushStack(200n);
      frame.pushStack(5n);
      tstore(frame);

      expect(evm.storage.getTransient(frame.address, 5n)).toBe(200n);
    });
  });

  describe('Integration: Persistent vs Transient Storage', () => {
    beforeEach(() => {
      frame.reset();
      evm.reset();
      evm.hardfork = Hardfork.CANCUN;
    });

    it('should maintain separate namespaces for same slot', () => {
      const slot = 5n;

      // Set persistent storage
      frame.pushStack(100n);
      frame.pushStack(slot);
      sstore(frame);

      // Set transient storage (same slot)
      frame.pushStack(200n);
      frame.pushStack(slot);
      tstore(frame);

      // Load persistent
      frame.pushStack(slot);
      sload(frame);
      expect(frame.popStack()).toBe(100n);

      // Load transient
      frame.pushStack(slot);
      tload(frame);
      expect(frame.popStack()).toBe(200n);
    });

    it('should not affect each other when clearing', () => {
      const slot = 5n;

      // Set both (use prePopulate for persistent to avoid tracking as original)
      (evm.storage as MockStorage).prePopulate(frame.address, slot, 100n);
      evm.storage.setTransient(frame.address, slot, 200n);

      // Clear transient
      frame.pushStack(0n);
      frame.pushStack(slot);
      tstore(frame);

      // Persistent should be unchanged
      expect(evm.storage.get(frame.address, slot)).toBe(100n);
      expect(evm.storage.getTransient(frame.address, slot)).toBe(0n);
    });

    it('should handle transaction boundary correctly (transient clears)', () => {
      const slot = 5n;

      // Set both (use prePopulate for initial persistent storage)
      (evm.storage as MockStorage).prePopulate(frame.address, slot, 100n);

      frame.pushStack(200n);
      frame.pushStack(slot);
      tstore(frame);

      // Simulate transaction end (clear transient)
      (evm.storage as MockStorage).clearTransient();

      // Persistent persists, transient cleared
      expect(evm.storage.get(frame.address, slot)).toBe(100n);
      expect(evm.storage.getTransient(frame.address, slot)).toBe(0n);
    });
  });

  describe('Edge Cases', () => {
    beforeEach(() => {
      frame.reset();
      evm.reset();
      evm.hardfork = Hardfork.CANCUN;
    });

    it('should handle max u256 slot numbers', () => {
      const maxSlot = 2n ** 256n - 1n;

      frame.pushStack(42n);
      frame.pushStack(maxSlot);
      sstore(frame);

      frame.pushStack(maxSlot);
      sload(frame);

      expect(frame.popStack()).toBe(42n);
    });

    it('should handle max u256 values', () => {
      const maxValue = 2n ** 256n - 1n;

      frame.pushStack(maxValue);
      frame.pushStack(5n);
      sstore(frame);

      frame.pushStack(5n);
      sload(frame);

      expect(frame.popStack()).toBe(maxValue);
    });

    it('should handle multiple slots in same transaction', () => {
      // Write multiple slots
      for (let i = 0n; i < 5n; i++) {
        frame.pushStack(i * 10n);
        frame.pushStack(i);
        sstore(frame);
      }

      // Read them back
      for (let i = 0n; i < 5n; i++) {
        frame.pushStack(i);
        sload(frame);
        expect(frame.popStack()).toBe(i * 10n);
      }
    });

    it('should track warm/cold correctly across multiple accesses', () => {
      const slot = 5n;

      // First access (cold)
      frame.pushStack(slot);
      const gas1 = frame.gas_remaining;
      sload(frame);
      expect(gas1 - frame.gas_remaining).toBe(2100n); // Cold

      // Second access (warm)
      frame.pushStack(slot);
      const gas2 = frame.gas_remaining;
      sload(frame);
      expect(gas2 - frame.gas_remaining).toBe(100n); // Warm

      // Third access (still warm)
      frame.pushStack(slot);
      const gas3 = frame.gas_remaining;
      sload(frame);
      expect(gas3 - frame.gas_remaining).toBe(100n); // Warm
    });
  });
});
