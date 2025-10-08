/**
 * Convert hex string to Uint8Array
 */
export function hexToBytes(hex: string): Uint8Array {
  const clean = hex.startsWith('0x') ? hex.slice(2) : hex;
  if (clean.length % 2 !== 0) {
    throw new Error('Invalid hex string length');
  }
  const bytes = new Uint8Array(clean.length / 2);
  for (let i = 0; i < bytes.length; i++) {
    bytes[i] = parseInt(clean.slice(i * 2, i * 2 + 2), 16);
  }
  return bytes;
}

/**
 * Convert Uint8Array to hex string
 */
export function bytesToHex(bytes: Uint8Array): string {
  return '0x' + Array.from(bytes)
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
}

/**
 * Convert bigint to 32-byte big-endian Uint8Array (u256)
 */
export function bigintToU256(value: bigint): Uint8Array {
  if (value < 0n) {
    throw new Error('Value must be non-negative');
  }
  if (value >= 2n ** 256n) {
    throw new Error('Value exceeds u256 max');
  }

  const bytes = new Uint8Array(32);
  let temp = value;
  for (let i = 31; i >= 0; i--) {
    bytes[i] = Number(temp & 0xFFn);
    temp >>= 8n;
  }
  return bytes;
}

/**
 * Convert 32-byte big-endian Uint8Array (u256) to bigint
 */
export function u256ToBigint(bytes: Uint8Array): bigint {
  if (bytes.length !== 32) {
    throw new Error('u256 must be 32 bytes');
  }
  let result = 0n;
  for (let i = 0; i < 32; i++) {
    result = (result << 8n) | BigInt(bytes[i]);
  }
  return result;
}

/**
 * Convert Ethereum address string to 20-byte Uint8Array
 */
export function addressToBytes(address: string): Uint8Array {
  const bytes = hexToBytes(address);
  if (bytes.length !== 20) {
    throw new Error('Address must be 20 bytes');
  }
  return bytes;
}

/**
 * Convert 20-byte Uint8Array to Ethereum address string
 */
export function bytesToAddress(bytes: Uint8Array): string {
  if (bytes.length !== 20) {
    throw new Error('Address must be 20 bytes');
  }
  return bytesToHex(bytes);
}

/**
 * Convert bigint to hex string (u256)
 */
export function bigintToHex(value: bigint): string {
  return bytesToHex(bigintToU256(value));
}

/**
 * Convert hex string (u256) to bigint
 */
export function hexToBigint(hex: string): bigint {
  return u256ToBigint(hexToBytes(hex));
}

/**
 * Pad hex string to specific byte length
 */
export function padHex(hex: string, byteLength: number): string {
  const clean = hex.startsWith('0x') ? hex.slice(2) : hex;
  const padded = clean.padStart(byteLength * 2, '0');
  return '0x' + padded;
}

/**
 * Validate hex string format
 */
export function isValidHex(hex: string): boolean {
  if (!hex.startsWith('0x')) return false;
  const clean = hex.slice(2);
  return /^[0-9a-fA-F]*$/.test(clean) && clean.length % 2 === 0;
}

/**
 * Validate Ethereum address format
 */
export function isValidAddress(address: string): boolean {
  if (!isValidHex(address)) return false;
  const clean = address.slice(2);
  return clean.length === 40; // 20 bytes = 40 hex chars
}
