/**
 * Test Utilities
 *
 * Helper functions for parsing test fixtures and converting between formats.
 */

/**
 * Convert hex string to Uint8Array
 *
 * @param hex - Hex string (with or without 0x prefix)
 * @returns Byte array
 */
export function hexToBytes(hex: string): Uint8Array {
  // Handle empty string
  if (!hex || hex === '0x' || hex === '') {
    return new Uint8Array(0);
  }

  // Remove 0x prefix if present
  const cleaned = hex.startsWith('0x') ? hex.slice(2) : hex;

  // Ensure even length (pad with leading 0 if needed)
  const padded = cleaned.length % 2 === 0 ? cleaned : '0' + cleaned;

  // Convert to bytes
  const bytes = new Uint8Array(padded.length / 2);
  for (let i = 0; i < padded.length; i += 2) {
    bytes[i / 2] = parseInt(padded.slice(i, i + 2), 16);
  }

  return bytes;
}

/**
 * Convert Uint8Array to hex string
 *
 * @param bytes - Byte array
 * @param prefix - Whether to add 0x prefix (default: true)
 * @returns Hex string
 */
export function bytesToHex(bytes: Uint8Array, prefix: boolean = true): string {
  const hex = Array.from(bytes)
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
  return prefix ? `0x${hex}` : hex;
}

/**
 * Convert hex string to bigint
 *
 * @param hex - Hex string (with or without 0x prefix)
 * @returns BigInt value
 */
export function hexToBigInt(hex: string | number): bigint {
  // Handle number input
  if (typeof hex === 'number') {
    return BigInt(hex);
  }

  // Handle empty/zero
  if (!hex || hex === '0x' || hex === '' || hex === '0x0') {
    return 0n;
  }

  // Remove 0x prefix if present
  const cleaned = hex.startsWith('0x') ? hex.slice(2) : hex;

  // Convert to bigint
  return BigInt(`0x${cleaned}`);
}

/**
 * Convert bigint to hex string
 *
 * @param value - BigInt value
 * @param prefix - Whether to add 0x prefix (default: true)
 * @param padTo - Optional padding length (in bytes)
 * @returns Hex string
 */
export function bigIntToHex(value: bigint, prefix: boolean = true, padTo?: number): string {
  let hex = value.toString(16);

  // Pad to specified length if provided
  if (padTo) {
    hex = hex.padStart(padTo * 2, '0');
  }

  return prefix ? `0x${hex}` : hex;
}

/**
 * Compare two byte arrays for equality
 *
 * @param a - First byte array
 * @param b - Second byte array
 * @returns true if equal
 */
export function bytesEqual(a: Uint8Array, b: Uint8Array): boolean {
  if (a.length !== b.length) {
    return false;
  }
  for (let i = 0; i < a.length; i++) {
    if (a[i] !== b[i]) {
      return false;
    }
  }
  return true;
}

/**
 * Check if a hex string matches a filter pattern
 *
 * @param testName - Test name to match
 * @param filter - Filter pattern (substring match)
 * @returns true if matches
 */
export function matchesFilter(testName: string, filter: string): boolean {
  if (!filter) {
    return true;
  }
  return testName.toLowerCase().includes(filter.toLowerCase());
}

/**
 * Parse address from various formats
 *
 * @param addr - Address in string or Uint8Array format
 * @returns 20-byte address
 */
export function parseAddress(addr: string | Uint8Array): Uint8Array {
  if (addr instanceof Uint8Array) {
    if (addr.length === 20) {
      return addr;
    }
    throw new Error(`Invalid address length: ${addr.length}`);
  }

  const bytes = hexToBytes(addr);
  if (bytes.length === 20) {
    return bytes;
  }

  // If too short, pad with leading zeros
  if (bytes.length < 20) {
    const padded = new Uint8Array(20);
    padded.set(bytes, 20 - bytes.length);
    return padded;
  }

  // If too long, take last 20 bytes
  return bytes.slice(-20);
}

/**
 * Format gas amount for display
 *
 * @param gas - Gas amount
 * @returns Formatted string
 */
export function formatGas(gas: bigint): string {
  return gas.toLocaleString();
}

/**
 * Format address for display
 *
 * @param addr - Address bytes
 * @returns Formatted hex string
 */
export function formatAddress(addr: Uint8Array): string {
  return bytesToHex(addr, true);
}
