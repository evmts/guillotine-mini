/**
 * Shared utilities for EVM instruction handlers
 *
 * This module provides common utilities used across instruction handlers:
 * - Memory expansion cost calculation (matching Zig/Python reference)
 * - Gas cost helpers
 * - Two's complement conversions for signed operations
 * - Bigint wrapping utilities (wrap256, signExtend, etc.)
 * - Byte array conversions
 *
 * All utilities are pure functions matching exact formulas from the Zig
 * implementation and Python execution-specs reference.
 */

// ================================ CONSTANTS ================================

/** Mask for 256-bit values (2^256 - 1) */
export const MASK_256 = (1n << 256n) - 1n;

/** Sign bit mask for 256-bit values (2^255) */
export const SIGN_BIT_256 = 1n << 255n;

/** Maximum signed 256-bit value (2^255 - 1) */
export const MAX_SIGNED_256 = SIGN_BIT_256 - 1n;

/** Minimum signed 256-bit value (-2^255 as unsigned) */
export const MIN_SIGNED_256 = SIGN_BIT_256;

/** Gas cost per memory word (3 gas) */
export const MEMORY_GAS = 3n;

/** Quadratic coefficient divisor for memory expansion (512) */
export const QUAD_COEFF_DIV = 512n;

/** Maximum reasonable memory size (16MB = 0x1000000 bytes) to prevent overflow */
export const MAX_MEMORY = 0x1000000n;

// ============================== MEMORY UTILS ===============================

/**
 * Calculate word count from byte count
 * Words are 32 bytes each, rounded up
 *
 * Formula: (bytes + 31) / 32
 *
 * @param bytes - Number of bytes
 * @returns Number of 32-byte words needed
 *
 * @example
 * wordCount(0n) // 0n
 * wordCount(1n) // 1n
 * wordCount(32n) // 1n
 * wordCount(33n) // 2n
 */
export function wordCount(bytes: bigint): bigint {
  return (bytes + 31n) / 32n;
}

/**
 * Calculate word-aligned memory size for EVM compliance
 * Memory size is always a multiple of 32 bytes
 *
 * @param bytes - Number of bytes
 * @returns Word-aligned size in bytes
 *
 * @example
 * wordAlignedSize(0n) // 0n
 * wordAlignedSize(1n) // 32n
 * wordAlignedSize(32n) // 32n
 * wordAlignedSize(33n) // 64n
 */
export function wordAlignedSize(bytes: bigint): bigint {
  const words = wordCount(bytes);
  return words * 32n;
}

/**
 * Calculate memory expansion cost
 *
 * The total memory cost for n words is: 3n + n²/512
 * This function returns the ADDITIONAL cost to expand from current size to new size.
 *
 * Formula (from src/frame.zig:238-269):
 * - current_words = wordCount(current_size)
 * - new_words = wordCount(end_bytes)
 * - current_cost = 3 * current_words + current_words² / 512
 * - new_cost = 3 * new_words + new_words² / 512
 * - expansion_cost = new_cost - current_cost
 *
 * Returns max bigint value if overflow would occur (will trigger OutOfGas)
 *
 * @param currentSize - Current memory size in bytes
 * @param endBytes - New memory size needed in bytes
 * @returns Gas cost for expansion (0 if no expansion needed)
 *
 * @example
 * memoryExpansionCost(0n, 32n) // 3n (first word)
 * memoryExpansionCost(32n, 32n) // 0n (no expansion)
 * memoryExpansionCost(32n, 64n) // 3n (second word, minimal quadratic)
 */
export function memoryExpansionCost(
  currentSize: bigint,
  endBytes: bigint
): bigint {
  // No expansion needed
  if (endBytes <= currentSize) return 0n;

  // Cap memory size to prevent overflow
  // At 16MB (~500k words), gas cost would be ~125 billion
  if (endBytes > MAX_MEMORY) return BigInt(Number.MAX_SAFE_INTEGER);

  const currentWords = wordCount(currentSize);
  const newWords = wordCount(endBytes);

  // Calculate cost for each size with overflow protection
  try {
    // Current cost: 3 * current_words + current_words² / 512
    const currentWordsSquared = currentWords * currentWords;
    const currentLinear = MEMORY_GAS * currentWords;
    const currentQuadratic = currentWordsSquared / QUAD_COEFF_DIV;
    const currentCost = currentLinear + currentQuadratic;

    // New cost: 3 * new_words + new_words² / 512
    const newWordsSquared = newWords * newWords;
    const newLinear = MEMORY_GAS * newWords;
    const newQuadratic = newWordsSquared / QUAD_COEFF_DIV;
    const newCost = newLinear + newQuadratic;

    // Return additional cost
    const expansionCost = newCost - currentCost;
    return expansionCost < 0n ? 0n : expansionCost;
  } catch {
    // Overflow occurred, return large value to trigger OutOfGas
    return BigInt(Number.MAX_SAFE_INTEGER);
  }
}

/**
 * Calculate copy operation gas cost
 * Copy operations (CALLDATACOPY, CODECOPY, EXTCODECOPY, RETURNDATACOPY, MCOPY)
 * cost 3 gas per word copied
 *
 * @param sizeBytes - Number of bytes to copy
 * @returns Gas cost for copy operation
 *
 * @example
 * copyGasCost(0n) // 0n
 * copyGasCost(1n) // 3n
 * copyGasCost(32n) // 3n
 * copyGasCost(33n) // 6n
 */
export function copyGasCost(sizeBytes: bigint): bigint {
  const words = wordCount(sizeBytes);
  return MEMORY_GAS * words;
}

// ============================ TWO'S COMPLEMENT =============================

/**
 * Check if a 256-bit value is negative (sign bit set)
 *
 * @param value - 256-bit value
 * @returns true if sign bit is set
 *
 * @example
 * isNegative256(0n) // false
 * isNegative256(SIGN_BIT_256) // true
 * isNegative256(MASK_256) // true (all bits set = -1)
 */
export function isNegative256(value: bigint): boolean {
  return (value & SIGN_BIT_256) !== 0n;
}

/**
 * Convert unsigned 256-bit to signed (two's complement)
 *
 * If sign bit is set, treats value as negative:
 * signed = value - 2^256
 *
 * @param value - Unsigned 256-bit value
 * @returns Signed bigint representation
 *
 * @example
 * toSigned256(0n) // 0n
 * toSigned256(1n) // 1n
 * toSigned256(MASK_256) // -1n
 * toSigned256(MIN_SIGNED_256) // -170141183460469231731687303715884105728n (-2^255)
 */
export function toSigned256(value: bigint): bigint {
  if (isNegative256(value)) {
    // Two's complement: -(2^256 - value)
    return value - (1n << 256n);
  }
  return value;
}

/**
 * Convert signed to unsigned 256-bit (two's complement)
 *
 * If value is negative:
 * unsigned = 2^256 + value (masked to 256 bits)
 *
 * @param value - Signed bigint
 * @returns Unsigned 256-bit value
 *
 * @example
 * toUnsigned256(0n) // 0n
 * toUnsigned256(1n) // 1n
 * toUnsigned256(-1n) // MASK_256 (all bits set)
 * toUnsigned256(-2n ** 255n) // MIN_SIGNED_256
 */
export function toUnsigned256(value: bigint): bigint {
  if (value < 0n) {
    // Two's complement: 2^256 + value
    return mask256((1n << 256n) + value);
  }
  return mask256(value);
}

// ============================== BIGINT UTILS ===============================

/**
 * Mask a bigint to 256 bits (wrapping operation)
 *
 * Equivalent to Zig's wrapping operators (+%, *%, -%)
 *
 * @param value - Value to mask
 * @returns Value masked to 256 bits
 *
 * @example
 * mask256(0n) // 0n
 * mask256(MASK_256) // MASK_256
 * mask256(MASK_256 + 1n) // 0n (wraps around)
 * mask256(MASK_256 + 2n) // 1n (wraps around)
 */
export function mask256(value: bigint): bigint {
  return value & MASK_256;
}

/**
 * Sign extend a value to 256 bits
 *
 * Used by SIGNEXTEND opcode (0x0b)
 *
 * @param byteNum - Byte position to extend from (0-31)
 * @param value - Value to sign extend
 * @returns Sign-extended value
 *
 * @example
 * signExtend256(0n, 0x7fn) // 0x7fn (positive, no extension)
 * signExtend256(0n, 0x80n) // MASK_256 - 0x7fn (negative, extended)
 * signExtend256(1n, 0x7fffn) // 0x7fffn (positive)
 * signExtend256(1n, 0x8000n) // all bits set from bit 15 up
 */
export function signExtend256(byteNum: bigint, value: bigint): bigint {
  // If byte number is >= 31, no extension needed (already 256 bits)
  if (byteNum >= 31n) return value;

  // Calculate bit position of sign bit
  const bitPos = 8n * byteNum + 7n;
  const signBit = 1n << bitPos;

  // Test if sign bit is set
  if ((value & signBit) !== 0n) {
    // Sign bit is set, extend with 1s
    const mask = (1n << (bitPos + 1n)) - 1n;
    return value | (MASK_256 ^ mask);
  } else {
    // Sign bit is clear, mask off upper bits
    const mask = (1n << (bitPos + 1n)) - 1n;
    return value & mask;
  }
}

/**
 * Extract byte from 256-bit word
 *
 * Used by BYTE opcode (0x1a)
 *
 * @param i - Byte index (0-31, 0 is most significant)
 * @param x - 256-bit value
 * @returns Extracted byte (0-255)
 *
 * @example
 * byte256(0n, 0xff00n << 240n) // 0xffn (MSB)
 * byte256(31n, 0xffn) // 0xffn (LSB)
 * byte256(32n, 0xffffffffn) // 0n (out of range)
 */
export function byte256(i: bigint, x: bigint): bigint {
  // If index >= 32, return 0
  if (i >= 32n) return 0n;

  // Extract byte at index i (counting from MSB)
  // byte 0 is at bits 248-255, byte 31 is at bits 0-7
  const bitOffset = 8n * (31n - i);
  return (x >> bitOffset) & 0xffn;
}

// =========================== BITWISE OPERATIONS ============================

/**
 * Arithmetic right shift (sign-extending)
 *
 * Used by SAR opcode (0x1d)
 *
 * @param value - 256-bit value
 * @param shift - Shift amount
 * @returns Right-shifted value with sign extension
 *
 * @example
 * sar256(0xffn, 4n) // 0x0fn (logical shift, no sign extension needed)
 * sar256(MIN_SIGNED_256, 1n) // 0xc000...0n (sign-extended with 1s)
 * sar256(MIN_SIGNED_256, 256n) // MASK_256 (all 1s)
 */
export function sar256(value: bigint, shift: bigint): bigint {
  // For shifts >= 256, result is all 1s (if negative) or all 0s (if positive)
  if (shift >= 256n) {
    return isNegative256(value) ? MASK_256 : 0n;
  }

  // Convert to signed, shift, convert back to unsigned
  const signed = toSigned256(value);
  const shifted = signed >> shift;
  return toUnsigned256(shifted);
}

/**
 * Logical right shift (zero-fill)
 *
 * Used by SHR opcode (0x1c)
 *
 * @param value - 256-bit value
 * @param shift - Shift amount
 * @returns Right-shifted value with zero fill
 *
 * @example
 * shr256(0xffn, 4n) // 0x0fn
 * shr256(MASK_256, 1n) // MAX_SIGNED_256
 * shr256(0xffffn, 256n) // 0n
 */
export function shr256(value: bigint, shift: bigint): bigint {
  // For shifts >= 256, result is always 0
  if (shift >= 256n) return 0n;

  return mask256(value >> shift);
}

/**
 * Left shift
 *
 * Used by SHL opcode (0x1b)
 *
 * @param value - 256-bit value
 * @param shift - Shift amount
 * @returns Left-shifted value masked to 256 bits
 *
 * @example
 * shl256(1n, 0n) // 1n
 * shl256(1n, 8n) // 256n
 * shl256(1n, 255n) // MIN_SIGNED_256
 * shl256(1n, 256n) // 0n (shifted out)
 */
export function shl256(value: bigint, shift: bigint): bigint {
  // For shifts >= 256, result is always 0
  if (shift >= 256n) return 0n;

  return mask256(value << shift);
}

// ============================ BYTE CONVERSIONS =============================

/**
 * Convert bigint to 32-byte array (big-endian)
 *
 * @param value - 256-bit value
 * @returns 32-byte Uint8Array
 *
 * @example
 * toBytes32(0n) // [0, 0, ..., 0] (32 zeros)
 * toBytes32(0xffn) // [0, 0, ..., 0, 0xff] (255 in last byte)
 * toBytes32(0xff00n) // [0, 0, ..., 0xff, 0x00]
 */
export function toBytes32(value: bigint): Uint8Array {
  const bytes = new Uint8Array(32);
  let v = mask256(value);

  // Fill from least significant byte (index 31) to most significant (index 0)
  for (let i = 31; i >= 0; i--) {
    bytes[i] = Number(v & 0xffn);
    v = v >> 8n;
  }

  return bytes;
}

/**
 * Convert 32-byte array to bigint (big-endian)
 *
 * @param bytes - 32-byte Uint8Array (or slice of larger array)
 * @returns 256-bit bigint
 *
 * @example
 * fromBytes32(new Uint8Array(32)) // 0n
 * fromBytes32(new Uint8Array([...zeros(31), 0xff])) // 0xffn
 */
export function fromBytes32(bytes: Uint8Array): bigint {
  if (bytes.length !== 32) {
    throw new Error(`Expected 32 bytes, got ${bytes.length}`);
  }

  let result = 0n;
  for (let i = 0; i < 32; i++) {
    result = (result << 8n) | BigInt(bytes[i]);
  }

  return result;
}

/**
 * Convert arbitrary byte array to bigint (big-endian)
 * Useful for calldata and returndata parsing
 *
 * @param bytes - Byte array
 * @returns Bigint representation
 *
 * @example
 * fromBytes(new Uint8Array([0xff])) // 0xffn
 * fromBytes(new Uint8Array([0xff, 0x00])) // 0xff00n
 */
export function fromBytes(bytes: Uint8Array): bigint {
  let result = 0n;
  for (let i = 0; i < bytes.length; i++) {
    result = (result << 8n) | BigInt(bytes[i]);
  }
  return result;
}

/**
 * Convert bigint to byte array of specified length (big-endian)
 * Truncates if value doesn't fit
 *
 * @param value - Bigint value
 * @param length - Desired byte length
 * @returns Byte array of specified length
 *
 * @example
 * toBytes(0xffffn, 2) // [0xff, 0xff]
 * toBytes(0xffffn, 4) // [0x00, 0x00, 0xff, 0xff]
 * toBytes(0xffffffn, 2) // [0xff, 0xff] (truncated)
 */
export function toBytes(value: bigint, length: number): Uint8Array {
  const bytes = new Uint8Array(length);
  let v = value;

  // Fill from least significant byte to most significant
  for (let i = length - 1; i >= 0; i--) {
    bytes[i] = Number(v & 0xffn);
    v = v >> 8n;
  }

  return bytes;
}

// ============================= SAFE MATH UTILS =============================

/**
 * Safe u32 addition with overflow check
 * Used for memory offset calculations
 *
 * @param a - First operand
 * @param b - Second operand
 * @returns Sum if no overflow
 * @throws Error if overflow occurs
 *
 * @example
 * addU32(1, 2) // 3
 * addU32(0xffffffff, 1) // throws Error
 */
export function addU32(a: number, b: number): number {
  // Check for negative inputs first
  if (a < 0 || b < 0) {
    throw new Error('OutOfBounds');
  }
  const result = a + b;
  if (result > 0xffffffff) {
    throw new Error('OutOfBounds');
  }
  return result;
}

/**
 * Safe u64 addition with overflow check
 *
 * @param a - First operand
 * @param b - Second operand
 * @returns Sum if no overflow
 * @throws Error if overflow occurs
 */
export function addU64(a: bigint, b: bigint): bigint {
  // Check for negative inputs first
  if (a < 0n || b < 0n) {
    throw new Error('OutOfBounds');
  }
  const result = a + b;
  const MAX_U64 = (1n << 64n) - 1n;
  if (result > MAX_U64) {
    throw new Error('OutOfBounds');
  }
  return result;
}

/**
 * Check if bigint fits in u64 range
 *
 * @param value - Value to check
 * @returns true if value fits in u64
 */
export function fitsU64(value: bigint): boolean {
  const MAX_U64 = (1n << 64n) - 1n;
  return value >= 0n && value <= MAX_U64;
}

/**
 * Check if bigint fits in u256 range
 *
 * @param value - Value to check
 * @returns true if value fits in u256
 */
export function fitsU256(value: bigint): boolean {
  return value >= 0n && value <= MASK_256;
}
