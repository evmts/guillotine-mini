/**
 * Test Host Implementation
 *
 * In-memory state backend for EVM testing, implementing the HostInterface.
 * Provides storage for balances, nonces, code, storage, and logs.
 *
 * Port of test/specs/test_host.zig
 */

import type { HostInterface, Address } from '../../src/host';
import type { Log } from '../../src/call-result';

/**
 * TestHost: In-memory EVM state backend for testing
 *
 * Implements HostInterface with simple Map-based storage.
 * All state is stored in memory and cleared between tests.
 */
export class TestHost implements HostInterface {
  private balances: Map<string, bigint> = new Map();
  private nonces: Map<string, bigint> = new Map();
  private code: Map<string, Uint8Array> = new Map();
  private storage: Map<string, Map<string, bigint>> = new Map();
  private logs: Log[] = [];

  /**
   * Convert address to string key for Map storage
   */
  private addressKey(address: Address): string {
    return Array.from(address)
      .map((b) => b.toString(16).padStart(2, '0'))
      .join('');
  }

  /**
   * Convert slot (bigint) to string key
   */
  private slotKey(slot: bigint): string {
    return slot.toString(16).padStart(64, '0');
  }

  /**
   * Get balance for an address
   */
  getBalance(address: Address): bigint {
    const key = this.addressKey(address);
    return this.balances.get(key) ?? 0n;
  }

  /**
   * Set balance for an address
   */
  setBalance(address: Address, balance: bigint): void {
    const key = this.addressKey(address);
    if (balance === 0n) {
      this.balances.delete(key);
    } else {
      this.balances.set(key, balance);
    }
  }

  /**
   * Get nonce for an address
   */
  getNonce(address: Address): bigint {
    const key = this.addressKey(address);
    return this.nonces.get(key) ?? 0n;
  }

  /**
   * Set nonce for an address
   */
  setNonce(address: Address, nonce: number | bigint): void {
    const key = this.addressKey(address);
    const nonceValue = typeof nonce === 'number' ? BigInt(nonce) : nonce;
    if (nonceValue === 0n) {
      this.nonces.delete(key);
    } else {
      this.nonces.set(key, nonceValue);
    }
  }

  /**
   * Get code for an address
   */
  getCode(address: Address): Uint8Array {
    const key = this.addressKey(address);
    return this.code.get(key) ?? new Uint8Array(0);
  }

  /**
   * Set code for an address
   */
  setCode(address: Address, code: Uint8Array): void {
    const key = this.addressKey(address);
    if (code.length === 0) {
      this.code.delete(key);
    } else {
      // Store a copy to avoid external modifications
      this.code.set(key, new Uint8Array(code));
    }
  }

  /**
   * Get storage value for an address and slot
   */
  getStorage(address: Address, slot: bigint): bigint {
    const addrKey = this.addressKey(address);
    const slotMap = this.storage.get(addrKey);
    if (!slotMap) {
      return 0n;
    }
    const slotKey = this.slotKey(slot);
    return slotMap.get(slotKey) ?? 0n;
  }

  /**
   * Set storage value for an address and slot
   */
  setStorage(address: Address, slot: bigint, value: bigint): void {
    const addrKey = this.addressKey(address);
    let slotMap = this.storage.get(addrKey);

    if (!slotMap) {
      if (value === 0n) {
        // No need to create a map for a zero value
        return;
      }
      slotMap = new Map();
      this.storage.set(addrKey, slotMap);
    }

    const slotKey = this.slotKey(slot);
    if (value === 0n) {
      slotMap.delete(slotKey);
      // Clean up empty maps
      if (slotMap.size === 0) {
        this.storage.delete(addrKey);
      }
    } else {
      slotMap.set(slotKey, value);
    }
  }

  /**
   * Add a log entry
   */
  addLog(log: Log): void {
    this.logs.push({
      address: new Uint8Array(log.address),
      topics: [...log.topics],
      data: new Uint8Array(log.data),
    });
  }

  /**
   * Get all logs
   */
  getLogs(): Log[] {
    return this.logs;
  }

  /**
   * Clear all logs
   */
  clearLogs(): void {
    this.logs = [];
  }

  /**
   * Clear all state (for test cleanup)
   */
  clear(): void {
    this.balances.clear();
    this.nonces.clear();
    this.code.clear();
    this.storage.clear();
    this.logs = [];
  }

  /**
   * Get all accounts with balances (for debugging/testing)
   */
  getAllAccounts(): Array<{ address: string; balance: bigint }> {
    const accounts: Array<{ address: string; balance: bigint }> = [];
    for (const [addrKey, balance] of this.balances.entries()) {
      accounts.push({ address: `0x${addrKey}`, balance });
    }
    return accounts;
  }

  /**
   * Get all storage for an address (for debugging/testing)
   */
  getAllStorage(address: Address): Array<{ slot: bigint; value: bigint }> {
    const addrKey = this.addressKey(address);
    const slotMap = this.storage.get(addrKey);
    if (!slotMap) {
      return [];
    }

    const entries: Array<{ slot: bigint; value: bigint }> = [];
    for (const [slotKey, value] of slotMap.entries()) {
      entries.push({ slot: BigInt(`0x${slotKey}`), value });
    }
    return entries;
  }
}
