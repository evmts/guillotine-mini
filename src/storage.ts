/**
 * Storage management for the EVM
 *
 * Handles persistent storage, transient storage (EIP-1153), and original storage tracking
 * for gas calculations (EIP-2200, EIP-2929).
 *
 * Architecture:
 * - Persistent storage: Main storage state, modified by SSTORE
 * - Transient storage: EIP-1153, cleared at transaction boundaries
 * - Original storage: Snapshot at transaction start, used for SSTORE refunds
 *
 * @module storage
 */

import { Address, HostInterface } from './host';
import { CallError, EvmError } from './errors';

/**
 * Storage key combining address and slot
 * Used as Map key for storage lookups
 */
export interface StorageKey {
  /** Contract address (20 bytes) */
  address: Address;
  /** Storage slot (u256) */
  slot: bigint;
}

/**
 * Async data request types
 * Used for async storage fetching in storage injector mode
 */
export type AsyncDataRequest =
  | { type: 'none' }
  | { type: 'storage'; address: Address; slot: bigint };

/**
 * Storage injector interface for async data fetching
 * Allows external systems to provide storage values on demand
 */
export interface StorageInjector {
  /** Cache of previously fetched storage values */
  storageCache: Map<string, bigint>;

  /** Mark a storage slot as modified (dirty) */
  markStorageDirty(address: Address, slot: bigint): void;

  /** Clear the storage cache */
  clearCache(): void;
}

/**
 * Storage manager - handles all storage operations for the EVM
 *
 * Responsibilities:
 * - Persistent storage (SLOAD/SSTORE)
 * - Transient storage (TLOAD/TSTORE, EIP-1153)
 * - Original value tracking for gas refunds
 * - Optional async data fetching via storage injector
 * - Optional external state backend via host interface
 */
export class Storage {
  /** Persistent storage (current transaction state) */
  private storage: Map<string, bigint> = new Map();

  /** Original storage values (snapshot at transaction start) */
  private originalStorage: Map<string, bigint> = new Map();

  /** Transient storage (EIP-1153, cleared at transaction boundaries) */
  private transient: Map<string, bigint> = new Map();

  /** Host interface (optional, for external state backends) */
  private host: HostInterface | null = null;

  /** Storage injector for async data fetching */
  private storageInjector: StorageInjector | null = null;

  /** Async data request state */
  private asyncDataRequest: AsyncDataRequest = { type: 'none' };

  /**
   * Initialize storage manager
   *
   * @param host - Optional host interface for external state backend
   * @param injector - Optional storage injector for async data fetching
   */
  constructor(host?: HostInterface | null, injector?: StorageInjector | null) {
    this.host = host ?? null;
    this.storageInjector = injector ?? null;
  }

  /**
   * Clear injector cache (call at transaction start)
   *
   * Clears the storage injector's cache of previously fetched values.
   * Should be called at the beginning of each new transaction to ensure
   * fresh data is fetched from the async source.
   */
  clearInjectorCache(): void {
    if (this.storageInjector) {
      this.storageInjector.clearCache();
    }
  }

  /**
   * Get storage value
   *
   * Retrieves the current value from a contract's persistent storage slot.
   *
   * Behavior depends on configuration:
   * - With storage injector: Checks cache first, throws NeedAsyncData if miss
   * - With host interface: Delegates to host.getStorage()
   * - Without host: Uses internal Map, returns 0n for empty slots
   *
   * @param address - Contract address
   * @param slot - Storage slot (u256)
   * @returns Current storage value (0n if slot is empty)
   * @throws {EvmError} NeedAsyncData when using injector and value not in cache
   */
  get(address: Address, slot: bigint): bigint {
    const key = this.makeKey(address, slot);

    // If using storage injector, check cache first
    if (this.storageInjector) {
      const cacheKey = this.makeCacheKey(address, slot);
      const cached = this.storageInjector.storageCache.get(cacheKey);
      if (cached !== undefined) {
        return cached; // Cache hit
      }

      // Cache miss - yield to fetch from async source
      this.asyncDataRequest = {
        type: 'storage',
        address,
        slot,
      };
      throw new EvmError(CallError.NeedAsyncData);
    }

    // No injector - use host or internal Map
    if (this.host) {
      return this.host.getStorage(address, slot);
    }
    return this.storage.get(key) ?? 0n;
  }

  /**
   * Set storage value
   *
   * Sets a contract's persistent storage slot to a new value. Automatically tracks
   * the original value (before transaction modifications) for SSTORE gas calculations.
   *
   * EVM semantics: Setting a slot to 0 deletes it (per EVM specification).
   *
   * @param address - Contract address
   * @param slot - Storage slot (u256)
   * @param value - New value to set (0n = delete slot)
   */
  set(address: Address, slot: bigint, value: bigint): void {
    const key = this.makeKey(address, slot);

    // Track original value on first write in transaction
    if (!this.originalStorage.has(key)) {
      const current = this.host
        ? this.host.getStorage(address, slot)
        : this.storage.get(key) ?? 0n;
      this.originalStorage.set(key, current);
    }

    // Mark dirty if using injector
    if (this.storageInjector) {
      this.storageInjector.markStorageDirty(address, slot);
    }

    if (this.host) {
      this.host.setStorage(address, slot, value);
      return;
    }

    // EVM spec: storage slots with value 0 should be deleted, not stored
    if (value === 0n) {
      this.storage.delete(key);
    } else {
      this.storage.set(key, value);
    }
  }

  /**
   * Get original storage value (before transaction modifications)
   *
   * Returns the storage value as it existed at the start of the transaction,
   * before any SSTORE modifications. Used for SSTORE gas calculation (EIP-2200, EIP-2929).
   *
   * @param address - Contract address
   * @param slot - Storage slot (u256)
   * @returns Original storage value (0n if slot was empty at transaction start)
   */
  getOriginal(address: Address, slot: bigint): bigint {
    const key = this.makeKey(address, slot);

    // If we have tracked the original, return it
    const original = this.originalStorage.get(key);
    if (original !== undefined) {
      return original;
    }

    // Otherwise return current value (unchanged in this transaction)
    // Use host if available
    if (this.host) {
      return this.host.getStorage(address, slot);
    }
    return this.storage.get(key) ?? 0n;
  }

  /**
   * Get transient storage value (EIP-1153)
   *
   * Retrieves a value from transient storage (Cancun+ hardfork, EIP-1153).
   * Transient storage is cleared at transaction boundaries and is cheaper than persistent storage.
   *
   * @param address - Contract address
   * @param slot - Transient storage slot (u256)
   * @returns Current transient value (0n if slot is empty)
   */
  getTransient(address: Address, slot: bigint): bigint {
    const key = this.makeKey(address, slot);
    return this.transient.get(key) ?? 0n;
  }

  /**
   * Set transient storage value (EIP-1153)
   *
   * Sets a transient storage slot (Cancun+ hardfork, EIP-1153). Setting to 0 deletes the slot.
   * Transient storage is cleared automatically at transaction boundaries.
   *
   * @param address - Contract address
   * @param slot - Transient storage slot (u256)
   * @param value - New value (0n = delete slot)
   */
  setTransient(address: Address, slot: bigint, value: bigint): void {
    const key = this.makeKey(address, slot);
    if (value === 0n) {
      this.transient.delete(key);
    } else {
      this.transient.set(key, value);
    }
  }

  /**
   * Put storage value directly in cache (for async continuation)
   *
   * Stores a fetched value directly into the storage injector's cache without
   * triggering original_storage tracking. Used when resuming from async data fetch.
   *
   * @param address - Contract address
   * @param slot - Storage slot (u256)
   * @param value - Fetched value to cache
   */
  putInCache(address: Address, slot: bigint, value: bigint): void {
    const key = this.makeKey(address, slot);
    const cacheKey = this.makeCacheKey(address, slot);

    // Store value in both cache and storage
    if (this.storageInjector) {
      this.storageInjector.storageCache.set(cacheKey, value);
    }

    // Also put in internal storage so get() can find it
    this.storage.set(key, value);
  }

  /**
   * Clear transient storage (called at transaction boundaries)
   *
   * Clears all transient storage (EIP-1153). Must be called at the end of each transaction.
   * Transient storage does NOT persist across transaction boundaries.
   */
  clearTransient(): void {
    this.transient.clear();
  }

  /**
   * Clear async data request
   *
   * Resets the async data request state to 'none'. Called after successfully
   * handling a NeedAsyncData error and resuming execution.
   */
  clearAsyncRequest(): void {
    this.asyncDataRequest = { type: 'none' };
  }

  /**
   * Get the current async data request
   *
   * @returns Current async data request state
   */
  getAsyncRequest(): AsyncDataRequest {
    return this.asyncDataRequest;
  }

  /**
   * Clear all storage for a specific address
   *
   * Removes all storage slots and original storage entries for a given address.
   * Used when selfdestructing an account (EIP-6780).
   *
   * @param address - Contract address to clear storage for
   */
  clearStorageForAddress(address: Address): void {
    // Convert address to hex prefix for matching keys
    const addrHex = Array.from(address)
      .map(b => b.toString(16).padStart(2, '0'))
      .join('');
    const prefix = `${addrHex}:`;

    // Remove from storage map
    const storageKeysToRemove: string[] = [];
    for (const key of this.storage.keys()) {
      if (key.startsWith(prefix)) {
        storageKeysToRemove.push(key);
      }
    }
    for (const key of storageKeysToRemove) {
      this.storage.delete(key);
    }

    // Remove from original storage map
    const originalKeysToRemove: string[] = [];
    for (const key of this.originalStorage.keys()) {
      if (key.startsWith(prefix)) {
        originalKeysToRemove.push(key);
      }
    }
    for (const key of originalKeysToRemove) {
      this.originalStorage.delete(key);
    }
  }

  /**
   * Make storage key from address and slot
   *
   * Creates a unique string key for the storage Map by combining
   * the address bytes and slot value.
   *
   * @param address - Contract address
   * @param slot - Storage slot
   * @returns String key for Map lookup
   */
  private makeKey(address: Address, slot: bigint): string {
    // Convert address to hex string
    const addrHex = Array.from(address)
      .map(b => b.toString(16).padStart(2, '0'))
      .join('');
    // Combine with slot as decimal string
    return `${addrHex}:${slot.toString()}`;
  }

  /**
   * Make cache key for storage injector
   *
   * Creates a cache key for the storage injector's cache Map.
   * Same format as makeKey for consistency.
   *
   * @param address - Contract address
   * @param slot - Storage slot
   * @returns String key for cache lookup
   */
  private makeCacheKey(address: Address, slot: bigint): string {
    return this.makeKey(address, slot);
  }
}
