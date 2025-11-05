/**
 * Host interface for EVM external state access
 *
 * NOTE: This module provides a minimal host interface for testing purposes.
 * The EVM's inner_call method now uses CallParams/CallResult directly and does not
 * go through this host interface - it handles nested calls internally.
 *
 * This interface is for external state backends (balances, storage, code, nonces).
 * NOT used for nested calls - EVM.inner_call handles those directly.
 */

/**
 * Ethereum address (20 bytes)
 * Represented as a Uint8Array of length 20
 */
export type Address = Uint8Array;

/**
 * Host interface for external state access
 *
 * Implementations should provide methods to access and modify:
 * - Account balances (u256 values)
 * - Account nonces (u64 values)
 * - Contract code (bytecode)
 * - Storage slots (u256 → u256 mapping)
 */
export interface HostInterface {
  /**
   * Get the balance of an account
   * @param address - Account address
   * @returns Balance as bigint (u256)
   */
  getBalance(address: Address): bigint;

  /**
   * Set the balance of an account
   * @param address - Account address
   * @param balance - New balance as bigint (u256)
   */
  setBalance(address: Address, balance: bigint): void;

  /**
   * Get the code (bytecode) of an account
   * @param address - Account address
   * @returns Contract bytecode as Uint8Array
   */
  getCode(address: Address): Uint8Array;

  /**
   * Set the code (bytecode) of an account
   * @param address - Account address
   * @param code - Contract bytecode as Uint8Array
   */
  setCode(address: Address, code: Uint8Array): void;

  /**
   * Get a storage slot value
   * @param address - Account address
   * @param slot - Storage slot as bigint (u256)
   * @returns Storage value as bigint (u256)
   */
  getStorage(address: Address, slot: bigint): bigint;

  /**
   * Set a storage slot value
   * @param address - Account address
   * @param slot - Storage slot as bigint (u256)
   * @param value - Storage value as bigint (u256)
   */
  setStorage(address: Address, slot: bigint, value: bigint): void;

  /**
   * Get the nonce of an account
   * @param address - Account address
   * @returns Nonce as bigint (u64)
   */
  getNonce(address: Address): bigint;

  /**
   * Set the nonce of an account
   * @param address - Account address
   * @param nonce - New nonce as bigint (u64)
   */
  setNonce(address: Address, nonce: bigint): void;
}

/**
 * Helper to create an Address from a hex string
 * @param hex - Hex string (with or without 0x prefix)
 * @returns Address as Uint8Array
 */
export function addressFromHex(hex: string): Address {
  const cleaned = hex.startsWith('0x') ? hex.slice(2) : hex;
  if (cleaned.length !== 40) {
    throw new Error(`Invalid address length: expected 40 hex chars, got ${cleaned.length}`);
  }
  const bytes = new Uint8Array(20);
  for (let i = 0; i < 20; i++) {
    bytes[i] = parseInt(cleaned.slice(i * 2, i * 2 + 2), 16);
  }
  return bytes;
}

/**
 * Helper to convert an Address to a hex string
 * @param address - Address as Uint8Array
 * @returns Hex string with 0x prefix
 */
export function addressToHex(address: Address): string {
  return '0x' + Array.from(address).map(b => b.toString(16).padStart(2, '0')).join('');
}

/**
 * Helper to compare two addresses for equality
 * @param a - First address
 * @param b - Second address
 * @returns true if addresses are equal
 */
export function addressEquals(a: Address, b: Address): boolean {
  if (a.length !== 20 || b.length !== 20) return false;
  for (let i = 0; i < 20; i++) {
    if (a[i] !== b[i]) return false;
  }
  return true;
}
