/**
 * Tests for Storage Injector with LRU Cache
 */

import { describe, test, expect, beforeEach } from 'bun:test';
import {
  StorageInjector,
  LruCache,
  type StorageKey,
  type EvmLike,
} from './storage-injector';

// ============================================================================
// LRU Cache Tests
// ============================================================================

describe('LruCache', () => {
  test('init creates empty cache', () => {
    const cache = new LruCache<number, number>(10, (k) => k.toString());

    expect(cache.getSize()).toBe(0);
    expect(cache.hits).toBe(0);
    expect(cache.misses).toBe(0);
  });

  test('put and get', () => {
    const cache = new LruCache<number, number>(10, (k) => k.toString());

    cache.put(1, 100);

    expect(cache.get(1)).toBe(100);
    expect(cache.getSize()).toBe(1);
  });

  test('cache miss', () => {
    const cache = new LruCache<number, number>(10, (k) => k.toString());

    expect(cache.get(99)).toBeUndefined();
  });

  test('update existing entry', () => {
    const cache = new LruCache<number, number>(10, (k) => k.toString());

    cache.put(1, 100);
    cache.put(1, 200);

    expect(cache.get(1)).toBe(200);
    expect(cache.getSize()).toBe(1);
  });

  test('eviction at capacity', () => {
    const cache = new LruCache<number, number>(2, (k) => k.toString());

    cache.put(1, 100);
    cache.put(2, 200);
    expect(cache.getSize()).toBe(2);

    // Adding third item should evict first (LRU)
    cache.put(3, 300);

    expect(cache.get(1)).toBeUndefined(); // Evicted
    expect(cache.get(2)).toBe(200);
    expect(cache.get(3)).toBe(300);
    expect(cache.getSize()).toBe(2);
  });

  test('access updates LRU order', () => {
    const cache = new LruCache<number, number>(2, (k) => k.toString());

    cache.put(1, 100);
    cache.put(2, 200);

    // Access 1 to make it most recent
    cache.get(1);

    // Adding third item should evict 2 (least recent)
    cache.put(3, 300);

    expect(cache.get(1)).toBe(100); // Still present
    expect(cache.get(2)).toBeUndefined(); // Evicted
    expect(cache.get(3)).toBe(300);
  });

  test('clear removes all entries', () => {
    const cache = new LruCache<number, number>(10, (k) => k.toString());

    cache.put(1, 100);
    cache.put(2, 200);

    cache.clear();

    expect(cache.getSize()).toBe(0);
    expect(cache.get(1)).toBeUndefined();
    expect(cache.get(2)).toBeUndefined();
  });

  test('hit/miss tracking', () => {
    const cache = new LruCache<number, number>(10, (k) => k.toString());

    cache.put(1, 100);

    cache.get(1); // Hit
    cache.get(1); // Hit
    cache.get(2); // Miss
    cache.get(3); // Miss

    expect(cache.hits).toBe(2);
    expect(cache.misses).toBe(2);
  });

  test('complex key serialization', () => {
    interface ComplexKey {
      address: string;
      slot: bigint;
    }

    const cache = new LruCache<ComplexKey, bigint>(
      10,
      (k) => `${k.address}:${k.slot}`
    );

    cache.put({ address: '0xabc', slot: 42n }, 100n);

    expect(cache.get({ address: '0xabc', slot: 42n })).toBe(100n);
    expect(cache.get({ address: '0xabc', slot: 43n })).toBeUndefined();
  });
});

// ============================================================================
// Storage Injector Tests
// ============================================================================

describe('StorageInjector', () => {
  let injector: StorageInjector;

  beforeEach(() => {
    injector = new StorageInjector();
  });

  describe('initialization', () => {
    test('creates empty injector', () => {
      const stats = injector.getCacheStats();

      expect(stats.storage.size).toBe(0);
      expect(stats.balance.size).toBe(0);
      expect(stats.code.size).toBe(0);
      expect(stats.nonce.size).toBe(0);
    });
  });

  describe('storage cache', () => {
    test('cacheStorage and getStorageFromCache', () => {
      const address = '0x1234567890123456789012345678901234567890';
      const slot = 42n;
      const value = 100n;

      injector.cacheStorage(address, slot, value);

      expect(injector.getStorageFromCache(address, slot)).toBe(value);
    });

    test('cache miss returns undefined', () => {
      const address = '0x1234567890123456789012345678901234567890';

      expect(injector.getStorageFromCache(address, 99n)).toBeUndefined();
    });

    test('markStorageDirty tracks modification', () => {
      const address = '0x1234567890123456789012345678901234567890';
      const slot = 42n;

      injector.markStorageDirty(address, slot);

      // Verify by checking dumpChanges includes it
      const mockEvm: EvmLike = {
        storage: new Map(),
        original_storage: new Map(),
        balances: new Map(),
        nonces: new Map(),
        code: new Map(),
      };

      mockEvm.storage!.set(`${address.toLowerCase()}:${slot.toString(16)}`, 100n);
      mockEvm.original_storage!.set(`${address.toLowerCase()}:${slot.toString(16)}`, 0n);

      const changes = injector.dumpChanges(mockEvm);
      expect(changes.storage.length).toBe(1);
      expect(changes.storage[0].address).toBe(address.toLowerCase());
    });

    test('multiple marks for same slot (idempotent)', () => {
      const address = '0x1234567890123456789012345678901234567890';
      const slot = 42n;

      injector.markStorageDirty(address, slot);
      injector.markStorageDirty(address, slot);
      injector.markStorageDirty(address, slot);

      const mockEvm: EvmLike = {
        storage: new Map(),
        original_storage: new Map(),
        balances: new Map(),
        nonces: new Map(),
        code: new Map(),
      };

      mockEvm.storage!.set(`${address.toLowerCase()}:${slot.toString(16)}`, 100n);
      mockEvm.original_storage!.set(`${address.toLowerCase()}:${slot.toString(16)}`, 0n);

      const changes = injector.dumpChanges(mockEvm);
      // Should only have one entry
      expect(changes.storage.length).toBe(1);
    });
  });

  describe('balance cache', () => {
    test('cacheBalance and getBalanceFromCache', () => {
      const address = '0x1234567890123456789012345678901234567890';
      const balance = 1000n;

      injector.cacheBalance(address, balance);

      expect(injector.getBalanceFromCache(address)).toBe(balance);
    });

    test('markBalanceDirty tracks modification', () => {
      const address = '0x1234567890123456789012345678901234567890';

      injector.markBalanceDirty(address);

      const mockEvm: EvmLike = {
        storage: new Map(),
        balances: new Map([[address, 1000n]]),
        nonces: new Map(),
        code: new Map(),
      };

      const changes = injector.dumpChanges(mockEvm);
      expect(changes.balances.length).toBe(1);
      expect(changes.balances[0].address).toBe(address.toLowerCase());
      expect(changes.balances[0].balance).toBe('0x3e8');
    });
  });

  describe('code cache', () => {
    test('cacheCode and getCodeFromCache', () => {
      const address = '0x1234567890123456789012345678901234567890';
      const code = new Uint8Array([0x60, 0x80, 0x60, 0x40]);

      injector.cacheCode(address, code);

      const cached = injector.getCodeFromCache(address);
      expect(cached).toEqual(code);
      expect(cached).not.toBe(code); // Should be a copy
    });

    test('markCodeDirty tracks modification', () => {
      const address = '0x1234567890123456789012345678901234567890';
      const code = new Uint8Array([0x60, 0x80]);

      injector.markCodeDirty(address);

      const mockEvm: EvmLike = {
        storage: new Map(),
        balances: new Map(),
        nonces: new Map(),
        code: new Map([[address, code]]),
      };

      const changes = injector.dumpChanges(mockEvm);
      expect(changes.codes.length).toBe(1);
      expect(changes.codes[0].address).toBe(address.toLowerCase());
      expect(changes.codes[0].code).toBe('0x6080');
    });
  });

  describe('nonce cache', () => {
    test('cacheNonce and getNonceFromCache', () => {
      const address = '0x1234567890123456789012345678901234567890';
      const nonce = 5n;

      injector.cacheNonce(address, nonce);

      expect(injector.getNonceFromCache(address)).toBe(nonce);
    });

    test('markNonceDirty tracks modification', () => {
      const address = '0x1234567890123456789012345678901234567890';

      injector.markNonceDirty(address);

      const mockEvm: EvmLike = {
        storage: new Map(),
        balances: new Map(),
        nonces: new Map([[address, 5n]]),
        code: new Map(),
      };

      const changes = injector.dumpChanges(mockEvm);
      expect(changes.nonces.length).toBe(1);
      expect(changes.nonces[0].address).toBe(address.toLowerCase());
      expect(changes.nonces[0].nonce).toBe('0x5');
    });
  });

  describe('clearCache', () => {
    test('clears all caches and dirty sets', () => {
      const address = '0x1234567890123456789012345678901234567890';

      // Add data to all caches
      injector.cacheStorage(address, 42n, 100n);
      injector.cacheBalance(address, 1000n);
      injector.cacheCode(address, new Uint8Array([0x60]));
      injector.cacheNonce(address, 5n);

      // Mark all dirty
      injector.markStorageDirty(address, 42n);
      injector.markBalanceDirty(address);
      injector.markCodeDirty(address);
      injector.markNonceDirty(address);

      // Clear
      injector.clearCache();

      // Verify all cleared
      const stats = injector.getCacheStats();
      expect(stats.storage.size).toBe(0);
      expect(stats.balance.size).toBe(0);
      expect(stats.code.size).toBe(0);
      expect(stats.nonce.size).toBe(0);

      // Verify dirty sets cleared
      const mockEvm: EvmLike = {
        storage: new Map(),
        balances: new Map(),
        nonces: new Map(),
        code: new Map(),
      };

      const changes = injector.dumpChanges(mockEvm);
      expect(changes.storage.length).toBe(0);
      expect(changes.balances.length).toBe(0);
      expect(changes.codes.length).toBe(0);
      expect(changes.nonces.length).toBe(0);
    });
  });

  describe('getCacheStats', () => {
    test('returns cache statistics', () => {
      const address = '0x1234567890123456789012345678901234567890';

      // Add some data
      injector.cacheStorage(address, 1n, 100n);
      injector.cacheStorage(address, 2n, 200n);
      injector.cacheBalance(address, 1000n);

      // Trigger hits/misses
      injector.getStorageFromCache(address, 1n); // Hit
      injector.getStorageFromCache(address, 99n); // Miss
      injector.getBalanceFromCache(address); // Hit

      const stats = injector.getCacheStats();

      expect(stats.storage.size).toBe(2);
      expect(stats.storage.hits).toBe(1);
      expect(stats.storage.misses).toBe(1);

      expect(stats.balance.size).toBe(1);
      expect(stats.balance.hits).toBe(1);
      expect(stats.balance.misses).toBe(0);
    });
  });

  describe('dumpChanges', () => {
    test('empty dirty sets returns empty arrays', () => {
      const mockEvm: EvmLike = {
        storage: new Map(),
        original_storage: new Map(),
        balances: new Map(),
        nonces: new Map(),
        code: new Map(),
      };

      const changes = injector.dumpChanges(mockEvm);

      expect(changes.storage).toEqual([]);
      expect(changes.balances).toEqual([]);
      expect(changes.nonces).toEqual([]);
      expect(changes.codes).toEqual([]);
      expect(changes.selfDestructs).toEqual([]);
    });

    test('dumps storage change with original and new values', () => {
      const address = '0x1234567890123456789012345678901234567890';
      const slot = 42n;

      injector.markStorageDirty(address, slot);

      const mockEvm: EvmLike = {
        storage: new Map([[`${address.toLowerCase()}:2a`, 100n]]),
        original_storage: new Map([[`${address.toLowerCase()}:2a`, 0n]]),
        balances: new Map(),
        nonces: new Map(),
        code: new Map(),
      };

      const changes = injector.dumpChanges(mockEvm);

      expect(changes.storage.length).toBe(1);
      expect(changes.storage[0]).toEqual({
        address: address.toLowerCase(),
        slot: '0x2a',
        originalValue: '0x0',
        newValue: '0x64',
      });
    });

    test('dumps multiple state changes', () => {
      const address1 = '0x1111111111111111111111111111111111111111';
      const address2 = '0x2222222222222222222222222222222222222222';

      injector.markStorageDirty(address1, 1n);
      injector.markBalanceDirty(address1);
      injector.markNonceDirty(address2);
      injector.markCodeDirty(address2);

      const mockEvm: EvmLike = {
        storage: new Map([[`${address1.toLowerCase()}:1`, 100n]]),
        original_storage: new Map([[`${address1.toLowerCase()}:1`, 0n]]),
        balances: new Map([[address1, 1000n]]),
        nonces: new Map([[address2, 5n]]),
        code: new Map([[address2, new Uint8Array([0x60, 0x80])]]),
      };

      const changes = injector.dumpChanges(mockEvm);

      expect(changes.storage.length).toBe(1);
      expect(changes.balances.length).toBe(1);
      expect(changes.nonces.length).toBe(1);
      expect(changes.codes.length).toBe(1);
    });

    test('dumps self-destructs if tracked', () => {
      const address = '0x1234567890123456789012345678901234567890';

      const mockEvm: EvmLike = {
        storage: new Map(),
        balances: new Map(),
        nonces: new Map(),
        code: new Map(),
        selfdestructed_accounts: new Set([address]),
      };

      const changes = injector.dumpChanges(mockEvm);

      expect(changes.selfDestructs.length).toBe(1);
      expect(changes.selfDestructs[0]).toBe(address.toLowerCase());
    });

    test('handles addresses without 0x prefix', () => {
      const address = '1234567890123456789012345678901234567890';

      injector.markBalanceDirty(address);

      const mockEvm: EvmLike = {
        storage: new Map(),
        balances: new Map([[address, 1000n]]),
        nonces: new Map(),
        code: new Map(),
      };

      const changes = injector.dumpChanges(mockEvm);

      expect(changes.balances[0].address).toMatch(/^0x/);
    });
  });

  describe('dumpChangesJson', () => {
    test('returns valid JSON string', () => {
      const address = '0x1234567890123456789012345678901234567890';

      injector.markBalanceDirty(address);

      const mockEvm: EvmLike = {
        storage: new Map(),
        balances: new Map([[address, 1000n]]),
        nonces: new Map(),
        code: new Map(),
      };

      const json = injector.dumpChangesJson(mockEvm);

      // Should be valid JSON
      expect(() => JSON.parse(json)).not.toThrow();

      const parsed = JSON.parse(json);
      expect(parsed.balances).toHaveLength(1);
    });
  });

  describe('address normalization', () => {
    test('normalizes addresses to lowercase', () => {
      const address = '0xABCDEF1234567890123456789012345678901234';

      injector.markBalanceDirty(address);

      const mockEvm: EvmLike = {
        storage: new Map(),
        balances: new Map([[address.toLowerCase(), 1000n]]),
        nonces: new Map(),
        code: new Map(),
      };

      const changes = injector.dumpChanges(mockEvm);

      expect(changes.balances[0].address).toBe(address.toLowerCase());
    });

    test('handles mixed case addresses in storage keys', () => {
      const address = '0xABCDEF1234567890123456789012345678901234';
      const slot = 42n;

      injector.markStorageDirty(address, slot);

      const mockEvm: EvmLike = {
        storage: new Map([[`${address.toLowerCase()}:2a`, 100n]]),
        original_storage: new Map([[`${address.toLowerCase()}:2a`, 0n]]),
        balances: new Map(),
        nonces: new Map(),
        code: new Map(),
      };

      const changes = injector.dumpChanges(mockEvm);

      expect(changes.storage[0].address).toBe(address.toLowerCase());
    });
  });

  describe('integration scenarios', () => {
    test('typical transaction flow', () => {
      const sender = '0x1111111111111111111111111111111111111111';
      const recipient = '0x2222222222222222222222222222222222222222';

      // Sender: decrease balance, increment nonce
      injector.markBalanceDirty(sender);
      injector.markNonceDirty(sender);

      // Recipient: increase balance
      injector.markBalanceDirty(recipient);

      // Simulate EVM state
      const mockEvm: EvmLike = {
        storage: new Map(),
        balances: new Map([
          [sender, 900n], // Sent 100
          [recipient, 100n],
        ]),
        nonces: new Map([[sender, 1n]]),
        code: new Map(),
      };

      const changes = injector.dumpChanges(mockEvm);

      expect(changes.balances.length).toBe(2);
      expect(changes.nonces.length).toBe(1);
      expect(changes.storage.length).toBe(0);
      expect(changes.codes.length).toBe(0);
    });

    test('contract deployment flow', () => {
      const deployer = '0x1111111111111111111111111111111111111111';
      const contract = '0x2222222222222222222222222222222222222222';
      const code = new Uint8Array([0x60, 0x80, 0x60, 0x40, 0x52]);

      // Deployer: decrease balance, increment nonce
      injector.markBalanceDirty(deployer);
      injector.markNonceDirty(deployer);

      // Contract: set initial code and nonce
      injector.markCodeDirty(contract);
      injector.markNonceDirty(contract);

      const mockEvm: EvmLike = {
        storage: new Map(),
        balances: new Map([[deployer, 900n]]),
        nonces: new Map([
          [deployer, 2n],
          [contract, 1n],
        ]),
        code: new Map([[contract, code]]),
      };

      const changes = injector.dumpChanges(mockEvm);

      expect(changes.balances.length).toBe(1);
      expect(changes.nonces.length).toBe(2);
      expect(changes.codes.length).toBe(1);
      expect(changes.codes[0].code).toBe('0x6080604052');
    });

    test('storage writes during execution', () => {
      const contract = '0x1234567890123456789012345678901234567890';

      // Write to multiple storage slots
      injector.markStorageDirty(contract, 0n);
      injector.markStorageDirty(contract, 1n);
      injector.markStorageDirty(contract, 2n);

      const mockEvm: EvmLike = {
        storage: new Map([
          [`${contract.toLowerCase()}:0`, 100n],
          [`${contract.toLowerCase()}:1`, 200n],
          [`${contract.toLowerCase()}:2`, 300n],
        ]),
        original_storage: new Map([
          [`${contract.toLowerCase()}:0`, 0n],
          [`${contract.toLowerCase()}:1`, 0n],
          [`${contract.toLowerCase()}:2`, 0n],
        ]),
        balances: new Map(),
        nonces: new Map(),
        code: new Map(),
      };

      const changes = injector.dumpChanges(mockEvm);

      expect(changes.storage.length).toBe(3);
      expect(changes.storage[0].newValue).toBe('0x64'); // 100
      expect(changes.storage[1].newValue).toBe('0xc8'); // 200
      expect(changes.storage[2].newValue).toBe('0x12c'); // 300
    });

    test('cache survives across multiple lookups', () => {
      const address = '0x1234567890123456789012345678901234567890';
      const slot = 42n;
      const value = 100n;

      // Cache value
      injector.cacheStorage(address, slot, value);

      // Multiple reads should all hit cache
      expect(injector.getStorageFromCache(address, slot)).toBe(value);
      expect(injector.getStorageFromCache(address, slot)).toBe(value);
      expect(injector.getStorageFromCache(address, slot)).toBe(value);

      const stats = injector.getCacheStats();
      expect(stats.storage.hits).toBe(3);
      expect(stats.storage.misses).toBe(0);
    });

    test('clearCache prepares for next transaction', () => {
      const address = '0x1234567890123456789012345678901234567890';

      // Transaction 1: Make changes
      injector.cacheStorage(address, 1n, 100n);
      injector.markStorageDirty(address, 1n);
      injector.markBalanceDirty(address);

      // Clear for transaction 2
      injector.clearCache();

      // Transaction 2 starts fresh
      const mockEvm: EvmLike = {
        storage: new Map(),
        balances: new Map(),
        nonces: new Map(),
        code: new Map(),
      };

      const changes = injector.dumpChanges(mockEvm);

      // Should be empty
      expect(changes.storage.length).toBe(0);
      expect(changes.balances.length).toBe(0);

      // Cache should be empty
      expect(injector.getStorageFromCache(address, 1n)).toBeUndefined();
    });
  });
});
