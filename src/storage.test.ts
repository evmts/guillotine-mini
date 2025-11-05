/**
 * Tests for Storage module
 *
 * Validates persistent storage, transient storage (EIP-1153),
 * original value tracking, and async data fetching.
 */

import { describe, it, expect, beforeEach } from 'vitest';
import { Storage, StorageInjector } from './storage.js';
import { Address, HostInterface, addressFromHex } from './host.js';
import { CallError, EvmError } from './errors.js';

describe('Storage', () => {
  let storage: Storage;

  beforeEach(() => {
    storage = new Storage();
  });

  describe('initialization', () => {
    it('should create empty storage', () => {
      expect(storage).toBeDefined();
      // Storage should start empty (verified by get returning 0n)
      const addr = createAddress(0xab);
      expect(storage.get(addr, 123n)).toBe(0n);
    });
  });

  describe('persistent storage', () => {
    it('should return 0n for empty slot', () => {
      const addr = createAddress(0xab);
      const value = storage.get(addr, 123n);
      expect(value).toBe(0n);
    });

    it('should set and get storage value', () => {
      const addr = createAddress(0xab);
      const slot = 42n;
      const value = 0x1234567890abcdefn;

      // Set value
      storage.set(addr, slot, value);

      // Get value back
      const retrieved = storage.get(addr, slot);
      expect(retrieved).toBe(value);

      // Verify original storage was tracked
      const original = storage.getOriginal(addr, slot);
      expect(original).toBe(0n);
    });

    it('should delete slot when set to zero', () => {
      const addr = createAddress(0xab);
      const slot = 42n;

      // Set non-zero value
      storage.set(addr, slot, 999n);
      expect(storage.get(addr, slot)).toBe(999n);

      // Set to zero (should delete)
      storage.set(addr, slot, 0n);
      expect(storage.get(addr, slot)).toBe(0n);
    });

    it('should handle multiple addresses with same slot', () => {
      const addr1 = createAddress(0xaa);
      const addr2 = createAddress(0xbb);
      const slot = 1n;

      // Set different values for same slot on different addresses
      storage.set(addr1, slot, 111n);
      storage.set(addr2, slot, 222n);

      // Verify they're independent
      expect(storage.get(addr1, slot)).toBe(111n);
      expect(storage.get(addr2, slot)).toBe(222n);
    });

    it('should handle large u256 values', () => {
      const addr = createAddress(0xcc);
      const slot = 1n;
      const maxU256 = (1n << 256n) - 1n;

      storage.set(addr, slot, maxU256);
      expect(storage.get(addr, slot)).toBe(maxU256);
    });
  });

  describe('original storage tracking', () => {
    it('should return current value for unmodified slots', () => {
      const addr = createAddress(0xab);
      const slot = 42n;

      // Set initial value
      storage.set(addr, slot, 100n);

      // First write tracks original as 0n
      const original = storage.getOriginal(addr, slot);
      expect(original).toBe(0n);

      // Modify again
      storage.set(addr, slot, 200n);

      // Original should still be 0n (first value before transaction)
      expect(storage.getOriginal(addr, slot)).toBe(0n);
    });

    it('should preserve original value across multiple writes', () => {
      const addr = createAddress(0xdd);
      const slot = 5n;

      // First write (original = 0n)
      storage.set(addr, slot, 100n);
      expect(storage.getOriginal(addr, slot)).toBe(0n);

      // Second write
      storage.set(addr, slot, 200n);
      expect(storage.getOriginal(addr, slot)).toBe(0n);

      // Third write
      storage.set(addr, slot, 300n);
      expect(storage.getOriginal(addr, slot)).toBe(0n);

      // Current value should be last write
      expect(storage.get(addr, slot)).toBe(300n);
    });
  });

  describe('transient storage (EIP-1153)', () => {
    it('should get empty transient slot as 0n', () => {
      const addr = createAddress(0xcd);
      const slot = 789n;
      expect(storage.getTransient(addr, slot)).toBe(0n);
    });

    it('should set and get transient value', () => {
      const addr = createAddress(0xcd);
      const slot = 789n;
      const value = 0xdeadbeefn;

      // Set transient value
      storage.setTransient(addr, slot, value);

      // Get transient value back
      expect(storage.getTransient(addr, slot)).toBe(value);

      // Verify it doesn't affect persistent storage
      expect(storage.get(addr, slot)).toBe(0n);
    });

    it('should delete transient slot when set to zero', () => {
      const addr = createAddress(0xef);
      const slot = 100n;

      // Set transient value
      storage.setTransient(addr, slot, 12345n);
      expect(storage.getTransient(addr, slot)).toBe(12345n);

      // Set to zero (should delete)
      storage.setTransient(addr, slot, 0n);
      expect(storage.getTransient(addr, slot)).toBe(0n);
    });

    it('should clear all transient storage', () => {
      const addr1 = createAddress(0x11);
      const addr2 = createAddress(0x22);

      // Set multiple transient values
      storage.setTransient(addr1, 1n, 100n);
      storage.setTransient(addr1, 2n, 200n);
      storage.setTransient(addr2, 1n, 300n);

      // Verify they exist
      expect(storage.getTransient(addr1, 1n)).toBe(100n);
      expect(storage.getTransient(addr1, 2n)).toBe(200n);
      expect(storage.getTransient(addr2, 1n)).toBe(300n);

      // Clear transient storage
      storage.clearTransient();

      // Verify all are gone
      expect(storage.getTransient(addr1, 1n)).toBe(0n);
      expect(storage.getTransient(addr1, 2n)).toBe(0n);
      expect(storage.getTransient(addr2, 1n)).toBe(0n);
    });

    it('should not affect persistent storage when clearing transient', () => {
      const addr = createAddress(0x33);
      const slot = 1n;

      // Set both persistent and transient
      storage.set(addr, slot, 111n);
      storage.setTransient(addr, slot, 222n);

      expect(storage.get(addr, slot)).toBe(111n);
      expect(storage.getTransient(addr, slot)).toBe(222n);

      // Clear transient
      storage.clearTransient();

      // Persistent should remain
      expect(storage.get(addr, slot)).toBe(111n);
      expect(storage.getTransient(addr, slot)).toBe(0n);
    });
  });

  describe('host interface integration', () => {
    it('should delegate to host.getStorage', () => {
      const mockHost: HostInterface = {
        getBalance: () => 0n,
        setBalance: () => {},
        getCode: () => new Uint8Array(),
        setCode: () => {},
        getStorage: (addr, slot) => 42n,
        setStorage: () => {},
        getNonce: () => 0n,
        setNonce: () => {},
      };

      const storageWithHost = new Storage(mockHost);
      const addr = createAddress(0x44);

      expect(storageWithHost.get(addr, 1n)).toBe(42n);
    });

    it('should delegate to host.setStorage', () => {
      let storedValue = 0n;
      const mockHost: HostInterface = {
        getBalance: () => 0n,
        setBalance: () => {},
        getCode: () => new Uint8Array(),
        setCode: () => {},
        getStorage: () => storedValue,
        setStorage: (addr, slot, value) => {
          storedValue = value;
        },
        getNonce: () => 0n,
        setNonce: () => {},
      };

      const storageWithHost = new Storage(mockHost);
      const addr = createAddress(0x55);

      storageWithHost.set(addr, 1n, 123n);
      expect(storedValue).toBe(123n);
    });
  });

  describe('storage injector integration', () => {
    it('should throw NeedAsyncData on cache miss', () => {
      const mockInjector: StorageInjector = {
        storageCache: new Map(),
        markStorageDirty: () => {},
        clearCache: () => {},
      };

      const storageWithInjector = new Storage(null, mockInjector);
      const addr = createAddress(0x66);

      expect(() => storageWithInjector.get(addr, 1n)).toThrow(EvmError);
      expect(() => storageWithInjector.get(addr, 1n)).toThrow(
        expect.objectContaining({ errorType: CallError.NeedAsyncData })
      );
    });

    it('should return cached value on cache hit', () => {
      const addr = createAddress(0x77);
      const slot = 5n;
      const cachedValue = 999n;

      // Create cache key (same format as Storage.makeKey)
      const cacheKey = `${Array.from(addr)
        .map(b => b.toString(16).padStart(2, '0'))
        .join('')}:${slot.toString()}`;

      const mockInjector: StorageInjector = {
        storageCache: new Map([[cacheKey, cachedValue]]),
        markStorageDirty: () => {},
        clearCache: () => {},
      };

      const storageWithInjector = new Storage(null, mockInjector);

      expect(storageWithInjector.get(addr, slot)).toBe(cachedValue);
    });

    it('should mark storage dirty on set', () => {
      let markedDirty = false;
      const mockInjector: StorageInjector = {
        storageCache: new Map(),
        markStorageDirty: () => {
          markedDirty = true;
        },
        clearCache: () => {},
      };

      const storageWithInjector = new Storage(null, mockInjector);
      const addr = createAddress(0x88);

      storageWithInjector.set(addr, 1n, 100n);
      expect(markedDirty).toBe(true);
    });

    it('should put value in cache', () => {
      const addr = createAddress(0x99);
      const slot = 7n;
      const value = 555n;

      const mockInjector: StorageInjector = {
        storageCache: new Map(),
        markStorageDirty: () => {},
        clearCache: () => {},
      };

      const storageWithInjector = new Storage(null, mockInjector);

      storageWithInjector.putInCache(addr, slot, value);

      // Should be in cache
      const cacheKey = `${Array.from(addr)
        .map(b => b.toString(16).padStart(2, '0'))
        .join('')}:${slot.toString()}`;
      expect(mockInjector.storageCache.get(cacheKey)).toBe(value);

      // Should also be retrievable via get
      expect(storageWithInjector.get(addr, slot)).toBe(value);
    });

    it('should clear injector cache', () => {
      let cacheCleared = false;
      const mockInjector: StorageInjector = {
        storageCache: new Map(),
        markStorageDirty: () => {},
        clearCache: () => {
          cacheCleared = true;
        },
      };

      const storageWithInjector = new Storage(null, mockInjector);
      storageWithInjector.clearInjectorCache();

      expect(cacheCleared).toBe(true);
    });
  });

  describe('async data request', () => {
    it('should start with no async request', () => {
      expect(storage.getAsyncRequest()).toEqual({ type: 'none' });
    });

    it('should set async request on cache miss', () => {
      const addr = createAddress(0xaa);
      const slot = 10n;

      const mockInjector: StorageInjector = {
        storageCache: new Map(),
        markStorageDirty: () => {},
        clearCache: () => {},
      };

      const storageWithInjector = new Storage(null, mockInjector);

      try {
        storageWithInjector.get(addr, slot);
      } catch (e) {
        // Expected to throw
      }

      const request = storageWithInjector.getAsyncRequest();
      expect(request.type).toBe('storage');
      if (request.type === 'storage') {
        expect(request.slot).toBe(slot);
      }
    });

    it('should clear async request', () => {
      const addr = createAddress(0xbb);
      const mockInjector: StorageInjector = {
        storageCache: new Map(),
        markStorageDirty: () => {},
        clearCache: () => {},
      };

      const storageWithInjector = new Storage(null, mockInjector);

      try {
        storageWithInjector.get(addr, 1n);
      } catch (e) {
        // Expected to throw
      }

      expect(storageWithInjector.getAsyncRequest().type).toBe('storage');

      storageWithInjector.clearAsyncRequest();
      expect(storageWithInjector.getAsyncRequest()).toEqual({ type: 'none' });
    });
  });

  describe('edge cases', () => {
    it('should handle slot 0', () => {
      const addr = createAddress(0xcc);
      storage.set(addr, 0n, 123n);
      expect(storage.get(addr, 0n)).toBe(123n);
    });

    it('should handle very large slot numbers', () => {
      const addr = createAddress(0xdd);
      const slot = (1n << 255n) - 1n; // Near max u256
      storage.set(addr, slot, 456n);
      expect(storage.get(addr, slot)).toBe(456n);
    });

    it('should handle zero address', () => {
      const addr = new Uint8Array(20); // All zeros
      storage.set(addr, 1n, 789n);
      expect(storage.get(addr, 1n)).toBe(789n);
    });

    it('should handle max address', () => {
      const addr = new Uint8Array(20).fill(0xff);
      storage.set(addr, 1n, 321n);
      expect(storage.get(addr, 1n)).toBe(321n);
    });
  });
});

/**
 * Helper to create test address with repeated byte
 */
function createAddress(byte: number): Address {
  const addr = new Uint8Array(20);
  addr.fill(byte);
  return addr;
}
