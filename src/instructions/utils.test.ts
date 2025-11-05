/**
 * Test suite for instruction handler utilities
 *
 * Tests all utility functions to ensure they match Zig/Python reference implementation:
 * - Memory expansion cost calculation
 * - Two's complement conversions
 * - Bigint wrapping and masking
 * - Byte array conversions
 * - Safe math operations
 */

import { describe, test, expect } from 'bun:test';
import {
  // Constants
  MASK_256,
  SIGN_BIT_256,
  MAX_SIGNED_256,
  MIN_SIGNED_256,
  MEMORY_GAS,
  QUAD_COEFF_DIV,
  // Memory utils
  wordCount,
  wordAlignedSize,
  memoryExpansionCost,
  copyGasCost,
  // Two's complement
  isNegative256,
  toSigned256,
  toUnsigned256,
  // Bigint utils
  mask256,
  signExtend256,
  byte256,
  // Bitwise operations
  sar256,
  shr256,
  shl256,
  // Byte conversions
  toBytes32,
  fromBytes32,
  fromBytes,
  toBytes,
  // Safe math
  addU32,
  addU64,
  fitsU64,
  fitsU256,
} from './utils';

// ================================ CONSTANTS ================================

describe('Constants', () => {
  test('MASK_256 is 2^256 - 1', () => {
    expect(MASK_256).toBe((1n << 256n) - 1n);
  });

  test('SIGN_BIT_256 is 2^255', () => {
    expect(SIGN_BIT_256).toBe(1n << 255n);
  });

  test('MAX_SIGNED_256 is 2^255 - 1', () => {
    expect(MAX_SIGNED_256).toBe(SIGN_BIT_256 - 1n);
  });

  test('MIN_SIGNED_256 is 2^255', () => {
    expect(MIN_SIGNED_256).toBe(SIGN_BIT_256);
  });

  test('MEMORY_GAS is 3', () => {
    expect(MEMORY_GAS).toBe(3n);
  });

  test('QUAD_COEFF_DIV is 512', () => {
    expect(QUAD_COEFF_DIV).toBe(512n);
  });
});

// ============================== MEMORY UTILS ===============================

describe('Memory Utilities', () => {
  describe('wordCount', () => {
    test('0 bytes = 0 words', () => {
      expect(wordCount(0n)).toBe(0n);
    });

    test('1 byte = 1 word', () => {
      expect(wordCount(1n)).toBe(1n);
    });

    test('31 bytes = 1 word', () => {
      expect(wordCount(31n)).toBe(1n);
    });

    test('32 bytes = 1 word', () => {
      expect(wordCount(32n)).toBe(1n);
    });

    test('33 bytes = 2 words', () => {
      expect(wordCount(33n)).toBe(2n);
    });

    test('64 bytes = 2 words', () => {
      expect(wordCount(64n)).toBe(2n);
    });

    test('65 bytes = 3 words', () => {
      expect(wordCount(65n)).toBe(3n);
    });
  });

  describe('wordAlignedSize', () => {
    test('0 bytes = 0 aligned', () => {
      expect(wordAlignedSize(0n)).toBe(0n);
    });

    test('1 byte = 32 aligned', () => {
      expect(wordAlignedSize(1n)).toBe(32n);
    });

    test('31 bytes = 32 aligned', () => {
      expect(wordAlignedSize(31n)).toBe(32n);
    });

    test('32 bytes = 32 aligned', () => {
      expect(wordAlignedSize(32n)).toBe(32n);
    });

    test('33 bytes = 64 aligned', () => {
      expect(wordAlignedSize(33n)).toBe(64n);
    });

    test('64 bytes = 64 aligned', () => {
      expect(wordAlignedSize(64n)).toBe(64n);
    });

    test('65 bytes = 96 aligned', () => {
      expect(wordAlignedSize(65n)).toBe(96n);
    });
  });

  describe('memoryExpansionCost', () => {
    test('no expansion needed returns 0', () => {
      expect(memoryExpansionCost(32n, 32n)).toBe(0n);
      expect(memoryExpansionCost(64n, 32n)).toBe(0n);
      expect(memoryExpansionCost(64n, 64n)).toBe(0n);
    });

    test('first word costs 3 gas (linear only)', () => {
      // 0 -> 32 bytes (0 -> 1 word)
      // cost = (3 * 1 + 1²/512) - (3 * 0 + 0²/512)
      // cost = 3 + 0 = 3
      expect(memoryExpansionCost(0n, 32n)).toBe(3n);
    });

    test('second word costs 3 gas (minimal quadratic)', () => {
      // 32 -> 64 bytes (1 -> 2 words)
      // new_cost = 3 * 2 + 2²/512 = 6 + 4/512 = 6 + 0 = 6
      // old_cost = 3 * 1 + 1²/512 = 3 + 1/512 = 3 + 0 = 3
      // expansion = 6 - 3 = 3
      expect(memoryExpansionCost(32n, 64n)).toBe(3n);
    });

    test('expansion from 0 to 64 bytes', () => {
      // 0 -> 64 bytes (0 -> 2 words)
      // cost = 3 * 2 + 2²/512 = 6 + 4/512 = 6 + 0 = 6
      expect(memoryExpansionCost(0n, 64n)).toBe(6n);
    });

    test('quadratic cost becomes visible at larger sizes', () => {
      // 0 -> 1024 bytes (0 -> 32 words)
      // cost = 3 * 32 + 32²/512 = 96 + 1024/512 = 96 + 2 = 98
      expect(memoryExpansionCost(0n, 1024n)).toBe(98n);

      // 0 -> 2048 bytes (0 -> 64 words)
      // cost = 3 * 64 + 64²/512 = 192 + 4096/512 = 192 + 8 = 200
      expect(memoryExpansionCost(0n, 2048n)).toBe(200n);
    });

    test('expansion with non-zero current size', () => {
      // 1024 -> 2048 bytes (32 -> 64 words)
      // new_cost = 3 * 64 + 64²/512 = 192 + 8 = 200
      // old_cost = 3 * 32 + 32²/512 = 96 + 2 = 98
      // expansion = 200 - 98 = 102
      expect(memoryExpansionCost(1024n, 2048n)).toBe(102n);
    });

    test('expansion with unaligned sizes (rounds up)', () => {
      // 0 -> 33 bytes (0 -> 2 words, rounds up from 1.03125)
      // cost = 3 * 2 + 2²/512 = 6 + 0 = 6
      expect(memoryExpansionCost(0n, 33n)).toBe(6n);

      // 32 -> 65 bytes (1 -> 3 words)
      // new_cost = 3 * 3 + 3²/512 = 9 + 9/512 = 9 + 0 = 9
      // old_cost = 3 * 1 + 1²/512 = 3 + 0 = 3
      // expansion = 9 - 3 = 6
      expect(memoryExpansionCost(32n, 65n)).toBe(6n);
    });

    test('large memory size (near max reasonable)', () => {
      // 0 -> 1MB (0 -> 32768 words)
      // cost = 3 * 32768 + 32768²/512
      //      = 98304 + 1073741824/512
      //      = 98304 + 2097152
      //      = 2195456
      const oneMB = 1024n * 1024n;
      const expectedCost = 2195456n;
      expect(memoryExpansionCost(0n, oneMB)).toBe(expectedCost);
    });

    test('extremely large size returns max value', () => {
      const hugeSize = 1n << 60n; // Way over MAX_MEMORY
      const result = memoryExpansionCost(0n, hugeSize);
      expect(result).toBeGreaterThan(1000000000n); // Should be very large
    });
  });

  describe('copyGasCost', () => {
    test('0 bytes = 0 gas', () => {
      expect(copyGasCost(0n)).toBe(0n);
    });

    test('1 byte = 3 gas (1 word)', () => {
      expect(copyGasCost(1n)).toBe(3n);
    });

    test('32 bytes = 3 gas (1 word)', () => {
      expect(copyGasCost(32n)).toBe(3n);
    });

    test('33 bytes = 6 gas (2 words)', () => {
      expect(copyGasCost(33n)).toBe(6n);
    });

    test('64 bytes = 6 gas (2 words)', () => {
      expect(copyGasCost(64n)).toBe(6n);
    });

    test('65 bytes = 9 gas (3 words)', () => {
      expect(copyGasCost(65n)).toBe(9n);
    });
  });
});

// ============================ TWO'S COMPLEMENT =============================

describe("Two's Complement", () => {
  describe('isNegative256', () => {
    test('zero is not negative', () => {
      expect(isNegative256(0n)).toBe(false);
    });

    test('positive values are not negative', () => {
      expect(isNegative256(1n)).toBe(false);
      expect(isNegative256(127n)).toBe(false);
      expect(isNegative256(MAX_SIGNED_256)).toBe(false);
    });

    test('sign bit set is negative', () => {
      expect(isNegative256(SIGN_BIT_256)).toBe(true);
      expect(isNegative256(SIGN_BIT_256 + 1n)).toBe(true);
      expect(isNegative256(MASK_256)).toBe(true);
    });
  });

  describe('toSigned256', () => {
    test('zero remains zero', () => {
      expect(toSigned256(0n)).toBe(0n);
    });

    test('positive values remain unchanged', () => {
      expect(toSigned256(1n)).toBe(1n);
      expect(toSigned256(127n)).toBe(127n);
      expect(toSigned256(MAX_SIGNED_256)).toBe(MAX_SIGNED_256);
    });

    test('values with sign bit become negative', () => {
      // 2^255 = -2^255 in signed
      expect(toSigned256(MIN_SIGNED_256)).toBe(-(1n << 255n));

      // 2^256 - 1 (all bits set) = -1 in signed
      expect(toSigned256(MASK_256)).toBe(-1n);

      // 2^256 - 2 = -2 in signed
      expect(toSigned256(MASK_256 - 1n)).toBe(-2n);
    });
  });

  describe('toUnsigned256', () => {
    test('zero remains zero', () => {
      expect(toUnsigned256(0n)).toBe(0n);
    });

    test('positive values remain unchanged', () => {
      expect(toUnsigned256(1n)).toBe(1n);
      expect(toUnsigned256(127n)).toBe(127n);
      expect(toUnsigned256(MAX_SIGNED_256)).toBe(MAX_SIGNED_256);
    });

    test('negative values become large unsigned', () => {
      // -1 = 2^256 - 1 (all bits set)
      expect(toUnsigned256(-1n)).toBe(MASK_256);

      // -2 = 2^256 - 2
      expect(toUnsigned256(-2n)).toBe(MASK_256 - 1n);

      // -2^255 = 2^255 (sign bit only)
      expect(toUnsigned256(-(1n << 255n))).toBe(MIN_SIGNED_256);
    });
  });

  describe('round-trip conversions', () => {
    test('positive values round-trip correctly', () => {
      const values = [0n, 1n, 127n, 255n, MAX_SIGNED_256];
      for (const v of values) {
        expect(toUnsigned256(toSigned256(v))).toBe(v);
      }
    });

    test('negative values round-trip correctly', () => {
      const values = [MIN_SIGNED_256, MIN_SIGNED_256 + 1n, MASK_256];
      for (const v of values) {
        expect(toUnsigned256(toSigned256(v))).toBe(v);
      }
    });
  });
});

// ============================== BIGINT UTILS ===============================

describe('Bigint Utilities', () => {
  describe('mask256', () => {
    test('values within range unchanged', () => {
      expect(mask256(0n)).toBe(0n);
      expect(mask256(1n)).toBe(1n);
      expect(mask256(MASK_256)).toBe(MASK_256);
    });

    test('values over 256 bits wrap around', () => {
      expect(mask256(MASK_256 + 1n)).toBe(0n);
      expect(mask256(MASK_256 + 2n)).toBe(1n);
      expect(mask256((MASK_256 + 1n) * 2n)).toBe(0n);
    });

    test('simulates wrapping arithmetic', () => {
      // Simulates Zig's +% operator
      const a = MASK_256;
      const b = 2n;
      expect(mask256(a + b)).toBe(1n);
    });
  });

  describe('signExtend256', () => {
    test('extending from byte 0 (8 bits)', () => {
      // Positive: 0x7f (bit 7 clear)
      expect(signExtend256(0n, 0x7fn)).toBe(0x7fn);

      // Negative: 0x80 (bit 7 set) - extends with 1s
      expect(signExtend256(0n, 0x80n)).toBe(MASK_256 - 0x7fn);

      // 0xff should extend as -1
      expect(signExtend256(0n, 0xffn)).toBe(MASK_256);
    });

    test('extending from byte 1 (16 bits)', () => {
      // Positive: 0x7fff (bit 15 clear)
      expect(signExtend256(1n, 0x7fffn)).toBe(0x7fffn);

      // Negative: 0x8000 (bit 15 set)
      const extended = signExtend256(1n, 0x8000n);
      expect(extended).toBe(MASK_256 - 0x7fffn);
    });

    test('no extension needed for byte 31+', () => {
      expect(signExtend256(31n, 0x80n)).toBe(0x80n);
      expect(signExtend256(32n, 0x80n)).toBe(0x80n);
      expect(signExtend256(100n, 0x80n)).toBe(0x80n);
    });

    test('real-world SIGNEXTEND opcode cases', () => {
      // signextend(0, 0x7f) = 0x7f (positive stays positive)
      expect(signExtend256(0n, 0x7fn)).toBe(0x7fn);

      // signextend(0, 0xff) = -1 (all bits set)
      expect(signExtend256(0n, 0xffn)).toBe(MASK_256);

      // signextend(1, 0x7fff) = 0x7fff
      expect(signExtend256(1n, 0x7fffn)).toBe(0x7fffn);
    });
  });

  describe('byte256', () => {
    test('extract from single-byte value', () => {
      expect(byte256(31n, 0xffn)).toBe(0xffn); // LSB
      expect(byte256(30n, 0xffn)).toBe(0n);
      expect(byte256(0n, 0xffn)).toBe(0n); // MSB
    });

    test('extract from multi-byte value', () => {
      const value = 0xff00n;
      expect(byte256(30n, value)).toBe(0xffn);
      expect(byte256(31n, value)).toBe(0x00n);
    });

    test('extract MSB', () => {
      const value = 0xffn << 248n; // MSB = 0xff
      expect(byte256(0n, value)).toBe(0xffn);
    });

    test('out of range returns 0', () => {
      expect(byte256(32n, 0xffffffffn)).toBe(0n);
      expect(byte256(100n, 0xffffffffn)).toBe(0n);
    });

    test('real-world BYTE opcode cases', () => {
      // byte(31, 0xff) = 0xff (LSB)
      expect(byte256(31n, 0xffn)).toBe(0xffn);

      // byte(0, 0xff << 248) = 0xff (MSB)
      expect(byte256(0n, 0xffn << 248n)).toBe(0xffn);

      // byte(1, 0xff << 248) = 0x00 (second byte from left)
      expect(byte256(1n, 0xffn << 248n)).toBe(0x00n);
    });
  });
});

// =========================== BITWISE OPERATIONS ============================

describe('Bitwise Operations', () => {
  describe('sar256 (arithmetic right shift)', () => {
    test('positive values shift logically', () => {
      expect(sar256(0xffn, 4n)).toBe(0x0fn);
      expect(sar256(0x100n, 1n)).toBe(0x80n);
    });

    test('negative values extend with 1s', () => {
      // -1 (all bits set) shifted right stays -1
      expect(sar256(MASK_256, 1n)).toBe(MASK_256);
      expect(sar256(MASK_256, 8n)).toBe(MASK_256);

      // MIN_SIGNED_256 (0x8000...0) >> 1 = 0xc000...0
      const shifted = sar256(MIN_SIGNED_256, 1n);
      expect(shifted).toBeGreaterThan(MIN_SIGNED_256);
      expect(isNegative256(shifted)).toBe(true);
    });

    test('shift >= 256 returns all 0s or all 1s', () => {
      expect(sar256(0x123n, 256n)).toBe(0n); // positive -> 0
      expect(sar256(MIN_SIGNED_256, 256n)).toBe(MASK_256); // negative -> -1
    });
  });

  describe('shr256 (logical right shift)', () => {
    test('shifts with zero fill', () => {
      expect(shr256(0xffn, 4n)).toBe(0x0fn);
      expect(shr256(MASK_256, 1n)).toBe(MAX_SIGNED_256);
    });

    test('no sign extension for negative values', () => {
      // Unlike SAR, SHR always fills with 0s
      const result = shr256(MIN_SIGNED_256, 1n);
      expect(result).toBe(1n << 254n);
      expect(isNegative256(result)).toBe(false);
    });

    test('shift >= 256 returns 0', () => {
      expect(shr256(MASK_256, 256n)).toBe(0n);
      expect(shr256(0x123n, 300n)).toBe(0n);
    });
  });

  describe('shl256 (left shift)', () => {
    test('basic left shift', () => {
      expect(shl256(1n, 0n)).toBe(1n);
      expect(shl256(1n, 8n)).toBe(256n);
      expect(shl256(1n, 255n)).toBe(MIN_SIGNED_256);
    });

    test('shift wraps around', () => {
      // Shift beyond 256 bits wraps to 0
      expect(shl256(1n, 256n)).toBe(0n);
      expect(shl256(0xffn, 256n)).toBe(0n);
    });

    test('high bits are masked off', () => {
      expect(shl256(MASK_256, 1n)).toBe(mask256(MASK_256 << 1n));
    });
  });
});

// ============================ BYTE CONVERSIONS =============================

describe('Byte Conversions', () => {
  describe('toBytes32', () => {
    test('zero produces 32 zero bytes', () => {
      const bytes = toBytes32(0n);
      expect(bytes.length).toBe(32);
      expect(bytes.every((b) => b === 0)).toBe(true);
    });

    test('small values fill LSB', () => {
      const bytes = toBytes32(0xffn);
      expect(bytes.length).toBe(32);
      expect(bytes[31]).toBe(0xff); // LSB
      expect(bytes.slice(0, 31).every((b) => b === 0)).toBe(true);
    });

    test('multi-byte values', () => {
      const bytes = toBytes32(0xff00n);
      expect(bytes[30]).toBe(0xff);
      expect(bytes[31]).toBe(0x00);
    });

    test('max value fills all bytes', () => {
      const bytes = toBytes32(MASK_256);
      expect(bytes.every((b) => b === 0xff)).toBe(true);
    });
  });

  describe('fromBytes32', () => {
    test('32 zero bytes = 0', () => {
      const bytes = new Uint8Array(32);
      expect(fromBytes32(bytes)).toBe(0n);
    });

    test('LSB = 0xff', () => {
      const bytes = new Uint8Array(32);
      bytes[31] = 0xff;
      expect(fromBytes32(bytes)).toBe(0xffn);
    });

    test('MSB = 0xff', () => {
      const bytes = new Uint8Array(32);
      bytes[0] = 0xff;
      expect(fromBytes32(bytes)).toBe(0xffn << 248n);
    });

    test('all bytes = 0xff', () => {
      const bytes = new Uint8Array(32).fill(0xff);
      expect(fromBytes32(bytes)).toBe(MASK_256);
    });

    test('rejects non-32-byte arrays', () => {
      expect(() => fromBytes32(new Uint8Array(31))).toThrow();
      expect(() => fromBytes32(new Uint8Array(33))).toThrow();
    });
  });

  describe('round-trip conversions', () => {
    test('toBytes32/fromBytes32 round-trip', () => {
      const values = [0n, 1n, 0xffn, 0xff00n, MASK_256];
      for (const v of values) {
        expect(fromBytes32(toBytes32(v))).toBe(v);
      }
    });
  });

  describe('fromBytes', () => {
    test('empty array = 0', () => {
      expect(fromBytes(new Uint8Array(0))).toBe(0n);
    });

    test('single byte', () => {
      expect(fromBytes(new Uint8Array([0xff]))).toBe(0xffn);
    });

    test('multi-byte big-endian', () => {
      expect(fromBytes(new Uint8Array([0xff, 0x00]))).toBe(0xff00n);
      expect(fromBytes(new Uint8Array([0x01, 0x02, 0x03]))).toBe(0x010203n);
    });
  });

  describe('toBytes', () => {
    test('zero with various lengths', () => {
      expect(toBytes(0n, 1)).toEqual(new Uint8Array([0]));
      expect(toBytes(0n, 4)).toEqual(new Uint8Array([0, 0, 0, 0]));
    });

    test('value fills from LSB', () => {
      expect(toBytes(0xffn, 2)).toEqual(new Uint8Array([0x00, 0xff]));
      expect(toBytes(0xff00n, 2)).toEqual(new Uint8Array([0xff, 0x00]));
    });

    test('truncates if value too large', () => {
      expect(toBytes(0xffffffn, 2)).toEqual(new Uint8Array([0xff, 0xff]));
    });
  });
});

// ============================= SAFE MATH UTILS =============================

describe('Safe Math', () => {
  describe('addU32', () => {
    test('normal addition', () => {
      expect(addU32(1, 2)).toBe(3);
      expect(addU32(100, 200)).toBe(300);
    });

    test('max u32 value', () => {
      expect(addU32(0xffffffff, 0)).toBe(0xffffffff);
    });

    test('overflow throws', () => {
      expect(() => addU32(0xffffffff, 1)).toThrow('OutOfBounds');
      expect(() => addU32(0x80000000, 0x80000000)).toThrow('OutOfBounds');
    });

    test('negative inputs throw', () => {
      expect(() => addU32(-1, 5)).toThrow('OutOfBounds');
      expect(() => addU32(5, -1)).toThrow('OutOfBounds');
    });
  });

  describe('addU64', () => {
    test('normal addition', () => {
      expect(addU64(1n, 2n)).toBe(3n);
      expect(addU64(100n, 200n)).toBe(300n);
    });

    test('max u64 value', () => {
      const MAX_U64 = (1n << 64n) - 1n;
      expect(addU64(MAX_U64, 0n)).toBe(MAX_U64);
    });

    test('overflow throws', () => {
      const MAX_U64 = (1n << 64n) - 1n;
      expect(() => addU64(MAX_U64, 1n)).toThrow('OutOfBounds');
    });

    test('negative inputs throw', () => {
      expect(() => addU64(-1n, 5n)).toThrow('OutOfBounds');
      expect(() => addU64(5n, -1n)).toThrow('OutOfBounds');
    });
  });

  describe('fitsU64', () => {
    test('values within range', () => {
      expect(fitsU64(0n)).toBe(true);
      expect(fitsU64(1n)).toBe(true);
      expect(fitsU64((1n << 64n) - 1n)).toBe(true);
    });

    test('values outside range', () => {
      expect(fitsU64(-1n)).toBe(false);
      expect(fitsU64(1n << 64n)).toBe(false);
      expect(fitsU64(MASK_256)).toBe(false);
    });
  });

  describe('fitsU256', () => {
    test('values within range', () => {
      expect(fitsU256(0n)).toBe(true);
      expect(fitsU256(1n)).toBe(true);
      expect(fitsU256(MASK_256)).toBe(true);
    });

    test('values outside range', () => {
      expect(fitsU256(-1n)).toBe(false);
      expect(fitsU256(MASK_256 + 1n)).toBe(false);
    });
  });
});

// ======================= INTEGRATION TESTS =================================

describe('Integration Tests', () => {
  test('simulate SIGNEXTEND opcode', () => {
    // SIGNEXTEND(0, 0x7f) - positive byte stays positive
    const result1 = signExtend256(0n, 0x7fn);
    expect(result1).toBe(0x7fn);

    // SIGNEXTEND(0, 0x80) - negative byte extends
    const result2 = signExtend256(0n, 0x80n);
    expect(isNegative256(result2)).toBe(true);

    // SIGNEXTEND(0, 0xff) - should be all 1s (-1)
    const result3 = signExtend256(0n, 0xffn);
    expect(result3).toBe(MASK_256);
  });

  test('simulate SAR opcode with negative number', () => {
    // SAR(1, -1) should still be -1
    const negOne = toUnsigned256(-1n);
    const shifted = sar256(negOne, 1n);
    expect(shifted).toBe(negOne);
  });

  test('simulate memory expansion for MLOAD', () => {
    // MLOAD offset=0 on empty memory
    const cost1 = memoryExpansionCost(0n, 32n);
    expect(cost1).toBe(3n); // First word

    // MLOAD offset=32 (already have first word)
    const cost2 = memoryExpansionCost(32n, 64n);
    expect(cost2).toBe(3n); // Second word

    // MLOAD offset=64 from empty
    const cost3 = memoryExpansionCost(0n, 96n);
    expect(cost3).toBe(9n); // Three words
  });

  test('simulate CALLDATACOPY gas calculation', () => {
    // CALLDATACOPY: copy 64 bytes to memory[0]
    const copyGas = copyGasCost(64n);
    const expansionGas = memoryExpansionCost(0n, 64n);
    const totalGas = copyGas + expansionGas;

    // Copy: 2 words * 3 = 6 gas
    // Expansion: 0 -> 2 words = 6 gas
    // Total: 12 gas (plus base cost)
    expect(copyGas).toBe(6n);
    expect(expansionGas).toBe(6n);
    expect(totalGas).toBe(12n);
  });

  test('byte extraction matches expected EVM behavior', () => {
    // Extract each byte from a test value
    const value = 0x0123456789abcdefn;

    // MSB first (byte 0 = 0x01 for values with MSB)
    expect(byte256(24n, value)).toBe(0x01n);
    expect(byte256(25n, value)).toBe(0x23n);
    expect(byte256(26n, value)).toBe(0x45n);
    expect(byte256(27n, value)).toBe(0x67n);
    expect(byte256(28n, value)).toBe(0x89n);
    expect(byte256(29n, value)).toBe(0xabn);
    expect(byte256(30n, value)).toBe(0xcdn);
    expect(byte256(31n, value)).toBe(0xefn); // LSB
  });
});
