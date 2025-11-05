/**
 * EIP-2929 Warm/Cold Access Tracking
 *
 * This module manages the warm/cold access state for addresses and storage slots
 * according to EIP-2929. It's EVM-specific logic, not a primitive type.
 *
 * Key features:
 * - Track warm addresses (Set<Address>)
 * - Track warm storage slots (Set<StorageSlotKey>)
 * - Return gas cost on access (cold=2600/2100, warm=100)
 * - Pre-warm from EIP-2930 access lists
 * - Snapshot/restore for revert handling
 * - Transaction-scoped tracking (clear at transaction end)
 */

// Gas constants from EIP-2929 (Berlin+)
// These match the values in primitives/GasConstants
const WARM_STORAGE_READ_COST = 100;
const COLD_ACCOUNT_ACCESS_COST = 2600;
const COLD_SLOAD_COST = 2100;

/**
 * Snapshot of warm sets for nested call revert handling
 */
export interface AccessListSnapshot {
  addresses: Set<string>;
  slots: Set<string>;
}

/**
 * Manages warm/cold access state for EIP-2929
 *
 * EIP-2929 introduces warm/cold access costs for addresses and storage slots.
 * First access is cold (expensive), subsequent accesses are warm (cheap).
 * This state persists for the entire transaction but can be snapshotted/restored
 * for nested call reverts.
 */
export class AccessListManager {
  private warmAddresses: Set<string>;
  private warmStorageSlots: Set<string>;

  /**
   * Initialize empty access list manager
   */
  constructor() {
    this.warmAddresses = new Set();
    this.warmStorageSlots = new Set();
  }

  /**
   * Access an address and return gas cost (warm=100, cold=2600)
   * EIP-2929: First access is cold, subsequent accesses are warm
   *
   * @param address - The address to access
   * @returns Gas cost: 2600 for cold access, 100 for warm access
   */
  accessAddress(address: Uint8Array): number {
    const key = this.addressKey(address);
    const isWarm = this.warmAddresses.has(key);

    if (!isWarm) {
      this.warmAddresses.add(key);
      return COLD_ACCOUNT_ACCESS_COST;
    }

    return WARM_STORAGE_READ_COST;
  }

  /**
   * Access a storage slot and return gas cost (warm=100, cold=2100)
   * EIP-2929: First access is cold, subsequent accesses are warm
   *
   * @param address - The contract address
   * @param slot - The storage slot (u256)
   * @returns Gas cost: 2100 for cold access, 100 for warm access
   */
  accessStorageSlot(address: Uint8Array, slot: bigint): number {
    const key = this.storageSlotKey(address, slot);
    const isWarm = this.warmStorageSlots.has(key);

    if (!isWarm) {
      this.warmStorageSlots.add(key);
      return COLD_SLOAD_COST;
    }

    return WARM_STORAGE_READ_COST;
  }

  /**
   * Pre-warm multiple addresses (marks them as already accessed)
   *
   * @param addresses - Array of addresses to pre-warm
   */
  preWarmAddresses(addresses: Uint8Array[]): void {
    for (const address of addresses) {
      const key = this.addressKey(address);
      this.warmAddresses.add(key);
    }
  }

  /**
   * Pre-warm multiple storage slots (marks them as already accessed)
   *
   * @param slots - Array of {address, slot} pairs to pre-warm
   */
  preWarmStorageSlots(
    slots: Array<{ address: Uint8Array; slot: bigint }>
  ): void {
    for (const { address, slot } of slots) {
      const key = this.storageSlotKey(address, slot);
      this.warmStorageSlots.add(key);
    }
  }

  /**
   * Pre-warm from EIP-2930 access list
   *
   * @param accessList - EIP-2930 access list with addresses and storage keys
   */
  preWarmFromAccessList(
    accessList: Array<{ address: Uint8Array; storageKeys: Uint8Array[] }>
  ): void {
    for (const entry of accessList) {
      // Pre-warm address
      const addressKey = this.addressKey(entry.address);
      this.warmAddresses.add(addressKey);

      // Pre-warm storage keys (convert Hash to bigint)
      for (const keyHash of entry.storageKeys) {
        // Convert 32-byte hash to bigint (big-endian)
        const slot = this.hashToBigInt(keyHash);
        const slotKey = this.storageSlotKey(entry.address, slot);
        this.warmStorageSlots.add(slotKey);
      }
    }
  }

  /**
   * Check if address is warm
   *
   * @param address - The address to check
   * @returns True if address is warm (already accessed)
   */
  isAddressWarm(address: Uint8Array): boolean {
    const key = this.addressKey(address);
    return this.warmAddresses.has(key);
  }

  /**
   * Check if storage slot is warm
   *
   * @param address - The contract address
   * @param slot - The storage slot (u256)
   * @returns True if storage slot is warm (already accessed)
   */
  isStorageSlotWarm(address: Uint8Array, slot: bigint): boolean {
    const key = this.storageSlotKey(address, slot);
    return this.warmStorageSlots.has(key);
  }

  /**
   * Clear all warm sets (used at transaction boundaries)
   */
  clear(): void {
    this.warmAddresses.clear();
    this.warmStorageSlots.clear();
  }

  /**
   * Create snapshot for nested call revert handling
   *
   * @returns Snapshot of current warm sets
   */
  snapshot(): AccessListSnapshot {
    return {
      addresses: new Set(this.warmAddresses),
      slots: new Set(this.warmStorageSlots),
    };
  }

  /**
   * Restore from snapshot (for nested call reverts)
   *
   * @param snapshot - Snapshot to restore from
   */
  restore(snapshot: AccessListSnapshot): void {
    this.warmAddresses = new Set(snapshot.addresses);
    this.warmStorageSlots = new Set(snapshot.slots);
  }

  /**
   * Convert address to string key for Set storage
   * Uses hex representation for efficient comparison
   */
  private addressKey(address: Uint8Array): string {
    return Array.from(address)
      .map((b) => b.toString(16).padStart(2, "0"))
      .join("");
  }

  /**
   * Convert address + slot to string key for Set storage
   * Format: "address:slot" where both are hex strings
   */
  private storageSlotKey(address: Uint8Array, slot: bigint): string {
    const addressHex = this.addressKey(address);
    const slotHex = slot.toString(16).padStart(64, "0");
    return `${addressHex}:${slotHex}`;
  }

  /**
   * Convert 32-byte hash to bigint (big-endian)
   */
  private hashToBigInt(hash: Uint8Array): bigint {
    let result = 0n;
    for (const byte of hash) {
      result = (result << 8n) | BigInt(byte);
    }
    return result;
  }

  /**
   * Get count of warm addresses
   */
  get warmAddressCount(): number {
    return this.warmAddresses.size;
  }

  /**
   * Get count of warm storage slots
   */
  get warmStorageSlotCount(): number {
    return this.warmStorageSlots.size;
  }
}
