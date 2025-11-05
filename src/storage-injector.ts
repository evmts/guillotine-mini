/**
 * Storage Injector with LRU Cache for Async State Interface
 *
 * Provides lazy-loading storage with caching and dirty tracking for external state backends.
 * Used for async storage retrieval and generating minimal state change diffs.
 */

/**
 * Simple LRU (Least Recently Used) Cache implementation
 * Uses a doubly-linked list for O(1) access/eviction
 */
export class LruCache<K, V> {
  private map: Map<string, Node<K, V>>;
  private head: Node<K, V> | null;
  private tail: Node<K, V> | null;
  private size: number;
  private readonly capacity: number;
  private readonly keySerializer: (key: K) => string;

  // Statistics
  public hits: number;
  public misses: number;

  constructor(capacity: number, keySerializer: (key: K) => string) {
    this.map = new Map();
    this.head = null;
    this.tail = null;
    this.size = 0;
    this.capacity = capacity;
    this.keySerializer = keySerializer;
    this.hits = 0;
    this.misses = 0;
  }

  /**
   * Get value from cache, moving it to front if found
   */
  public get(key: K): V | undefined {
    const keyStr = this.keySerializer(key);
    const node = this.map.get(keyStr);

    if (node) {
      this.hits++;
      this.moveToFront(node);
      return node.value;
    }

    this.misses++;
    return undefined;
  }

  /**
   * Put value in cache, evicting LRU if at capacity
   */
  public put(key: K, value: V): void {
    const keyStr = this.keySerializer(key);
    const existingNode = this.map.get(keyStr);

    // Update existing entry
    if (existingNode) {
      existingNode.value = value;
      this.moveToFront(existingNode);
      return;
    }

    // Evict LRU if at capacity
    if (this.size >= this.capacity) {
      this.evictLru();
    }

    // Create new node
    const newNode: Node<K, V> = {
      key,
      value,
      prev: null,
      next: this.head,
    };

    // Update head's prev pointer
    if (this.head) {
      this.head.prev = newNode;
    }

    // Update head
    this.head = newNode;

    // Update tail if first node
    if (this.tail === null) {
      this.tail = newNode;
    }

    // Add to map
    this.map.set(keyStr, newNode);
    this.size++;
  }

  /**
   * Clear all entries from cache
   */
  public clear(): void {
    this.map.clear();
    this.head = null;
    this.tail = null;
    this.size = 0;
  }

  /**
   * Get current cache size
   */
  public getSize(): number {
    return this.size;
  }

  /**
   * Move node to front of LRU list (most recently used)
   */
  private moveToFront(node: Node<K, V>): void {
    if (node === this.head) return; // Already at front

    // Remove from current position
    if (node.prev) {
      node.prev.next = node.next;
    }

    if (node.next) {
      node.next.prev = node.prev;
    } else {
      // This was the tail
      this.tail = node.prev;
    }

    // Move to front
    node.prev = null;
    node.next = this.head;

    if (this.head) {
      this.head.prev = node;
    }

    this.head = node;
  }

  /**
   * Evict least recently used entry
   */
  private evictLru(): void {
    if (!this.tail) return;

    // Remove from map
    const keyStr = this.keySerializer(this.tail.key);
    this.map.delete(keyStr);

    // Update tail
    if (this.tail.prev) {
      this.tail.prev.next = null;
      this.tail = this.tail.prev;
    } else {
      // This was the only node
      this.head = null;
      this.tail = null;
    }

    this.size--;
  }
}

/**
 * Doubly-linked list node for LRU cache
 */
interface Node<K, V> {
  key: K;
  value: V;
  prev: Node<K, V> | null;
  next: Node<K, V> | null;
}

/**
 * Storage key combining address and slot
 */
export interface StorageKey {
  address: string; // 0x-prefixed hex
  slot: bigint;
}

/**
 * Serializes storage key for use in Map/Set
 */
function serializeStorageKey(key: StorageKey): string {
  return `${key.address.toLowerCase()}:${key.slot.toString(16)}`;
}

/**
 * Serializes address for use in Map/Set
 */
function serializeAddress(address: string): string {
  return address.toLowerCase();
}

/**
 * State change record for JSON export
 */
export interface StateChanges {
  storage: StorageChange[];
  balances: BalanceChange[];
  nonces: NonceChange[];
  codes: CodeChange[];
  selfDestructs: string[];
}

export interface StorageChange {
  address: string;
  slot: string;
  originalValue: string;
  newValue: string;
}

export interface BalanceChange {
  address: string;
  balance: string;
}

export interface NonceChange {
  address: string;
  nonce: string;
}

export interface CodeChange {
  address: string;
  code: string;
}

/**
 * EVM-like interface for dumpChanges compatibility
 */
export interface EvmLike {
  storage?: Map<string, bigint> | Storage;
  balances?: Map<string, bigint>;
  nonces?: Map<string, bigint>;
  code?: Map<string, Uint8Array>;
  original_storage?: Map<string, bigint>;
  selfdestructed_accounts?: Set<string>;

  // Methods for real EVM
  getStorage?(address: string, slot: bigint): bigint;
  getOriginalStorage?(address: string, slot: bigint): bigint;
  getNonce?(address: string): bigint;
}

/**
 * Storage interface (for real EVM integration)
 */
export interface Storage {
  get(address: string, slot: bigint): bigint;
  getOriginal(address: string, slot: bigint): bigint;
}

/**
 * Storage Injector - manages LRU cache and dirty tracking for async storage
 *
 * Features:
 * - LRU caching for storage slots, balances, code, nonces
 * - Dirty tracking for state changes
 * - JSON export of state changes for external commits
 * - Cache-first lookup with async fallback support
 */
export class StorageInjector {
  // LRU caches (check before async request)
  private storageCache: LruCache<StorageKey, bigint>;
  private balanceCache: LruCache<string, bigint>;
  private codeCache: LruCache<string, Uint8Array>;
  private nonceCache: LruCache<string, bigint>;

  // Dirty tracking (for change dump)
  private dirtyStorage: Set<string>;
  private dirtyBalances: Set<string>;
  private dirtyNonces: Set<string>;
  private dirtyCodes: Set<string>;

  constructor() {
    // Initialize LRU caches with reasonable capacities
    this.storageCache = new LruCache<StorageKey, bigint>(1024, serializeStorageKey);
    this.balanceCache = new LruCache<string, bigint>(256, serializeAddress);
    this.codeCache = new LruCache<string, Uint8Array>(128, serializeAddress);
    this.nonceCache = new LruCache<string, bigint>(256, serializeAddress);

    // Initialize dirty tracking sets
    this.dirtyStorage = new Set();
    this.dirtyBalances = new Set();
    this.dirtyNonces = new Set();
    this.dirtyCodes = new Set();
  }

  // ==================== Cache Read Methods ====================

  /**
   * Get storage value from cache (returns undefined if not cached)
   */
  public getStorageFromCache(address: string, slot: bigint): bigint | undefined {
    return this.storageCache.get({ address, slot });
  }

  /**
   * Get balance from cache (returns undefined if not cached)
   */
  public getBalanceFromCache(address: string): bigint | undefined {
    return this.balanceCache.get(address);
  }

  /**
   * Get code from cache (returns undefined if not cached)
   */
  public getCodeFromCache(address: string): Uint8Array | undefined {
    return this.codeCache.get(address);
  }

  /**
   * Get nonce from cache (returns undefined if not cached)
   */
  public getNonceFromCache(address: string): bigint | undefined {
    return this.nonceCache.get(address);
  }

  // ==================== Cache Write Methods ====================

  /**
   * Cache storage value
   */
  public cacheStorage(address: string, slot: bigint, value: bigint): void {
    this.storageCache.put({ address, slot }, value);
  }

  /**
   * Cache balance
   */
  public cacheBalance(address: string, balance: bigint): void {
    this.balanceCache.put(address, balance);
  }

  /**
   * Cache code
   */
  public cacheCode(address: string, code: Uint8Array): void {
    // Create copy to avoid external mutations
    this.codeCache.put(address, new Uint8Array(code));
  }

  /**
   * Cache nonce
   */
  public cacheNonce(address: string, nonce: bigint): void {
    this.nonceCache.put(address, nonce);
  }

  // ==================== Dirty Tracking ====================

  /**
   * Mark storage slot as dirty (called by EVM on set_storage)
   */
  public markStorageDirty(address: string, slot: bigint): void {
    const key = serializeStorageKey({ address, slot });
    this.dirtyStorage.add(key);
  }

  /**
   * Mark balance as dirty
   */
  public markBalanceDirty(address: string): void {
    this.dirtyBalances.add(serializeAddress(address));
  }

  /**
   * Mark nonce as dirty
   */
  public markNonceDirty(address: string): void {
    this.dirtyNonces.add(serializeAddress(address));
  }

  /**
   * Mark code as dirty
   */
  public markCodeDirty(address: string): void {
    this.dirtyCodes.add(serializeAddress(address));
  }

  // ==================== Cache Management ====================

  /**
   * Clear cache and dirty sets (call at start of new transaction)
   */
  public clearCache(): void {
    this.storageCache.clear();
    this.balanceCache.clear();
    this.codeCache.clear();
    this.nonceCache.clear();
    this.dirtyStorage.clear();
    this.dirtyBalances.clear();
    this.dirtyNonces.clear();
    this.dirtyCodes.clear();
  }

  /**
   * Get cache statistics
   */
  public getCacheStats() {
    return {
      storage: {
        size: this.storageCache.getSize(),
        hits: this.storageCache.hits,
        misses: this.storageCache.misses,
      },
      balance: {
        size: this.balanceCache.getSize(),
        hits: this.balanceCache.hits,
        misses: this.balanceCache.misses,
      },
      code: {
        size: this.codeCache.getSize(),
        hits: this.codeCache.hits,
        misses: this.codeCache.misses,
      },
      nonce: {
        size: this.nonceCache.getSize(),
        hits: this.nonceCache.hits,
        misses: this.nonceCache.misses,
      },
    };
  }

  // ==================== State Change Export ====================

  /**
   * Dump all state changes as structured object for commit
   * Returns state changes that can be serialized to JSON
   */
  public dumpChanges(evm: EvmLike): StateChanges {
    const changes: StateChanges = {
      storage: [],
      balances: [],
      nonces: [],
      codes: [],
      selfDestructs: [],
    };

    // Dump storage changes
    for (const keyStr of this.dirtyStorage) {
      const [address, slotHex] = keyStr.split(':');
      const slot = BigInt('0x' + slotHex);

      // Get original and current values
      const original = this.getOriginalValue(evm, address, slot);
      const current = this.getCurrentValue(evm, address, slot);

      changes.storage.push({
        address: this.normalizeAddress(address),
        slot: '0x' + slot.toString(16),
        originalValue: '0x' + original.toString(16),
        newValue: '0x' + current.toString(16),
      });
    }

    // Dump balance changes
    for (const address of this.dirtyBalances) {
      const balance = this.getBalance(evm, address);

      changes.balances.push({
        address: this.normalizeAddress(address),
        balance: '0x' + balance.toString(16),
      });
    }

    // Dump nonce changes
    for (const address of this.dirtyNonces) {
      const nonce = this.getNonce(evm, address);

      changes.nonces.push({
        address: this.normalizeAddress(address),
        nonce: '0x' + nonce.toString(16),
      });
    }

    // Dump code changes
    for (const address of this.dirtyCodes) {
      const code = this.getCode(evm, address);

      changes.codes.push({
        address: this.normalizeAddress(address),
        code: '0x' + this.bytesToHex(code),
      });
    }

    // Dump self-destructs if tracked
    if (evm.selfdestructed_accounts) {
      for (const address of evm.selfdestructed_accounts) {
        changes.selfDestructs.push(this.normalizeAddress(address));
      }
    }

    return changes;
  }

  /**
   * Dump changes as JSON string
   */
  public dumpChangesJson(evm: EvmLike): string {
    return JSON.stringify(this.dumpChanges(evm));
  }

  // ==================== Helper Methods ====================

  /**
   * Get original storage value (before transaction)
   */
  private getOriginalValue(evm: EvmLike, address: string, slot: bigint): bigint {
    // Check if mock EVM (has original_storage map)
    if (evm.original_storage) {
      const key = serializeStorageKey({ address, slot });
      return evm.original_storage.get(key) ?? 0n;
    }

    // Real EVM with Storage struct
    if (evm.storage && typeof evm.storage === 'object' && 'getOriginal' in evm.storage) {
      return evm.storage.getOriginal(address, slot);
    }

    return 0n;
  }

  /**
   * Get current storage value
   */
  private getCurrentValue(evm: EvmLike, address: string, slot: bigint): bigint {
    // Check if mock EVM (has storage map)
    if (evm.storage instanceof Map) {
      const key = serializeStorageKey({ address, slot });
      return evm.storage.get(key) ?? 0n;
    }

    // Real EVM with Storage struct
    if (evm.storage && typeof evm.storage === 'object' && 'get' in evm.storage) {
      return evm.storage.get(address, slot);
    }

    // Try method-based access
    if (evm.getStorage) {
      return evm.getStorage(address, slot);
    }

    return 0n;
  }

  /**
   * Get balance from EVM
   */
  private getBalance(evm: EvmLike, address: string): bigint {
    if (evm.balances) {
      return evm.balances.get(address) ?? 0n;
    }
    return 0n;
  }

  /**
   * Get nonce from EVM
   */
  private getNonce(evm: EvmLike, address: string): bigint {
    // Check for map-based access
    if (evm.nonces) {
      return evm.nonces.get(address) ?? 0n;
    }

    // Check for method-based access
    if (evm.getNonce) {
      return evm.getNonce(address);
    }

    return 0n;
  }

  /**
   * Get code from EVM
   */
  private getCode(evm: EvmLike, address: string): Uint8Array {
    if (evm.code) {
      return evm.code.get(address) ?? new Uint8Array(0);
    }
    return new Uint8Array(0);
  }

  /**
   * Normalize address to 0x-prefixed checksummed format
   */
  private normalizeAddress(address: string): string {
    // Ensure 0x prefix
    if (!address.startsWith('0x')) {
      return '0x' + address;
    }
    return address.toLowerCase();
  }

  /**
   * Convert byte array to hex string (without 0x prefix)
   */
  private bytesToHex(bytes: Uint8Array): string {
    return Array.from(bytes)
      .map(b => b.toString(16).padStart(2, '0'))
      .join('');
  }
}
