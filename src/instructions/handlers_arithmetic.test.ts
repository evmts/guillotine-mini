/**
 * Tests for arithmetic opcode handlers
 *
 * Verifies all arithmetic operations match EVM spec behavior including:
 * - Overflow/underflow wrapping
 * - Signed arithmetic edge cases
 * - Division by zero handling
 * - Gas consumption
 */

import { describe, it, expect, beforeEach } from "bun:test";
import {
  add,
  mul,
  sub,
  div,
  sdiv,
  mod,
  smod,
  addmod,
  mulmod,
  exp,
  signextend,
  type Frame,
} from "./handlers_arithmetic";

// u256 constants
const MAX_U256 = (1n << 256n) - 1n;
const MIN_SIGNED = 1n << 255n;
const MAX_SIGNED = MIN_SIGNED - 1n;

/**
 * Mock frame for testing
 */
class MockFrame implements Frame {
  pc: number = 0;
  gasUsed: bigint = 0n;
  stack: bigint[] = [];

  consumeGas(amount: bigint): void {
    this.gasUsed += amount;
  }

  popStack(): bigint {
    const val = this.stack.pop();
    if (val === undefined) {
      throw new Error("Stack underflow");
    }
    return val;
  }

  pushStack(value: bigint): void {
    this.stack.push(value);
  }

  reset(): void {
    this.pc = 0;
    this.gasUsed = 0n;
    this.stack = [];
  }
}

describe("Arithmetic Handlers", () => {
  let frame: MockFrame;

  beforeEach(() => {
    frame = new MockFrame();
  });

  describe("ADD (0x01)", () => {
    it("should add two small numbers", () => {
      frame.stack = [5n, 3n];
      add(frame);
      expect(frame.stack).toEqual([8n]);
      expect(frame.gasUsed).toBe(3n);
      expect(frame.pc).toBe(1);
    });

    it("should wrap on overflow", () => {
      frame.stack = [MAX_U256, 1n];
      add(frame);
      expect(frame.stack).toEqual([0n]);
    });

    it("should handle max + max overflow", () => {
      frame.stack = [MAX_U256, MAX_U256];
      add(frame);
      expect(frame.stack).toEqual([MAX_U256 - 1n]);
    });
  });

  describe("MUL (0x02)", () => {
    it("should multiply two numbers", () => {
      frame.stack = [6n, 7n];
      mul(frame);
      expect(frame.stack).toEqual([42n]);
      expect(frame.gasUsed).toBe(5n);
      expect(frame.pc).toBe(1);
    });

    it("should wrap on overflow", () => {
      frame.stack = [MAX_U256, 2n];
      mul(frame);
      expect(frame.stack).toEqual([MAX_U256 - 1n]);
    });

    it("should handle multiplication by zero", () => {
      frame.stack = [0n, 12345n];
      mul(frame);
      expect(frame.stack).toEqual([0n]);
    });
  });

  describe("SUB (0x03)", () => {
    it("should subtract two numbers", () => {
      // Stack [a, b] means b - a
      frame.stack = [3n, 10n]; // 10 - 3 = 7
      sub(frame);
      expect(frame.stack).toEqual([7n]);
      expect(frame.gasUsed).toBe(3n);
      expect(frame.pc).toBe(1);
    });

    it("should wrap on underflow", () => {
      // 1 - 0 = 1, but we want 0 - 1 which wraps
      frame.stack = [1n, 0n];
      sub(frame);
      expect(frame.stack).toEqual([MAX_U256]);
    });

    it("should handle subtracting from zero", () => {
      // 0 - 100 wraps
      frame.stack = [100n, 0n];
      sub(frame);
      expect(frame.stack).toEqual([MAX_U256 - 99n]);
    });
  });

  describe("DIV (0x04)", () => {
    it("should divide two numbers", () => {
      // Stack [a, b] means b / a
      frame.stack = [3n, 10n]; // 10 / 3 = 3
      div(frame);
      expect(frame.stack).toEqual([3n]);
      expect(frame.gasUsed).toBe(5n);
      expect(frame.pc).toBe(1);
    });

    it("should return 0 for division by zero", () => {
      // 10 / 0 = 0
      frame.stack = [0n, 10n];
      div(frame);
      expect(frame.stack).toEqual([0n]);
    });

    it("should handle exact division", () => {
      // 100 / 10 = 10
      frame.stack = [10n, 100n];
      div(frame);
      expect(frame.stack).toEqual([10n]);
    });
  });

  describe("SDIV (0x05)", () => {
    it("should divide positive numbers", () => {
      // 10 / 3 = 3
      frame.stack = [3n, 10n];
      sdiv(frame);
      expect(frame.stack).toEqual([3n]);
      expect(frame.gasUsed).toBe(5n);
      expect(frame.pc).toBe(1);
    });

    it("should handle negative dividend", () => {
      // -10 / 3 = -3
      const negTen = MAX_U256 - 9n;
      frame.stack = [3n, negTen];
      sdiv(frame);
      const result = frame.stack[0];
      expect(result).toBe(MAX_U256 - 2n); // -3 in u256
    });

    it("should handle negative divisor", () => {
      // 10 / -3 = -3
      const negThree = MAX_U256 - 2n;
      frame.stack = [negThree, 10n];
      sdiv(frame);
      expect(frame.stack[0]).toBe(MAX_U256 - 2n); // -3
    });

    it("should handle MIN_SIGNED / -1 overflow case", () => {
      // -2^255 / -1 should return -2^255 (not overflow)
      frame.stack = [MAX_U256, MIN_SIGNED];
      sdiv(frame);
      expect(frame.stack).toEqual([MIN_SIGNED]);
    });

    it("should return 0 for division by zero", () => {
      // 10 / 0 = 0
      frame.stack = [0n, 10n];
      sdiv(frame);
      expect(frame.stack).toEqual([0n]);
    });
  });

  describe("MOD (0x06)", () => {
    it("should compute modulo", () => {
      // 10 % 3 = 1
      frame.stack = [3n, 10n];
      mod(frame);
      expect(frame.stack).toEqual([1n]);
      expect(frame.gasUsed).toBe(5n);
      expect(frame.pc).toBe(1);
    });

    it("should return 0 for mod by zero", () => {
      // 10 % 0 = 0
      frame.stack = [0n, 10n];
      mod(frame);
      expect(frame.stack).toEqual([0n]);
    });

    it("should handle exact modulo", () => {
      // 15 % 5 = 0
      frame.stack = [5n, 15n];
      mod(frame);
      expect(frame.stack).toEqual([0n]);
    });
  });

  describe("SMOD (0x07)", () => {
    it("should compute signed modulo", () => {
      // 10 % 3 = 1
      frame.stack = [3n, 10n];
      smod(frame);
      expect(frame.stack).toEqual([1n]);
      expect(frame.gasUsed).toBe(5n);
      expect(frame.pc).toBe(1);
    });

    it("should handle negative dividend", () => {
      // -10 % 3 = -1
      const negTen = MAX_U256 - 9n;
      frame.stack = [3n, negTen];
      smod(frame);
      expect(frame.stack[0]).toBe(MAX_U256); // -1 in u256
    });

    it("should handle MIN_SIGNED % -1 special case", () => {
      // -2^255 % -1 = 0
      frame.stack = [MAX_U256, MIN_SIGNED];
      smod(frame);
      expect(frame.stack).toEqual([0n]);
    });

    it("should return 0 for mod by zero", () => {
      // 10 % 0 = 0
      frame.stack = [0n, 10n];
      smod(frame);
      expect(frame.stack).toEqual([0n]);
    });
  });

  describe("ADDMOD (0x08)", () => {
    it("should compute (a + b) % n", () => {
      // Stack [a, b, n] computes (n + b) % a
      frame.stack = [4n, 3n, 5n]; // (5 + 3) % 4 = 0
      addmod(frame);
      expect(frame.stack).toEqual([0n]);
      expect(frame.gasUsed).toBe(8n);
      expect(frame.pc).toBe(1);
    });

    it("should handle overflow without wrapping", () => {
      // (MAX_U256 + MAX_U256) % 100 = should use u512 intermediate
      frame.stack = [100n, MAX_U256, MAX_U256];
      addmod(frame);
      // (2^256 - 1 + 2^256 - 1) % 100 = (2*2^256 - 2) % 100
      // BigInt calculation: (MAX_U256 + MAX_U256) % 100n = 70n
      expect(frame.stack[0]).toBe(70n);
    });

    it("should return 0 for mod by zero", () => {
      // n=0 case
      frame.stack = [0n, 3n, 5n];
      addmod(frame);
      expect(frame.stack).toEqual([0n]);
    });
  });

  describe("MULMOD (0x09)", () => {
    it("should compute (a * b) % n", () => {
      // Stack [a, b, n] computes (n * b) % a
      frame.stack = [7n, 3n, 5n]; // (5 * 3) % 7 = 1
      mulmod(frame);
      expect(frame.stack).toEqual([1n]);
      expect(frame.gasUsed).toBe(8n);
      expect(frame.pc).toBe(1);
    });

    it("should handle overflow without wrapping", () => {
      // (MAX_U256 * 2) % 100 should use u512 intermediate
      frame.stack = [100n, 2n, MAX_U256];
      mulmod(frame);
      // (2^256 - 1) * 2 % 100 = (2*2^256 - 2) % 100
      // BigInt calculation: (MAX_U256 * 2n) % 100n = 70n
      expect(frame.stack[0]).toBe(70n);
    });

    it("should return 0 for mod by zero", () => {
      // n=0 case
      frame.stack = [0n, 3n, 5n];
      mulmod(frame);
      expect(frame.stack).toEqual([0n]);
    });
  });

  describe("EXP (0x0a)", () => {
    it("should compute power", () => {
      // Stack [base, exp] computes exp ^ base
      frame.stack = [3n, 2n]; // 2^3 = 8
      exp(frame);
      expect(frame.stack).toEqual([8n]);
      expect(frame.gasUsed).toBe(10n + 50n); // base + 1 byte
      expect(frame.pc).toBe(1);
    });

    it("should handle zero exponent", () => {
      // 0^123 = 0, but need to check zig semantics
      // Actually stack [exp, base], so [0, 123] means 123^0 = 1
      frame.stack = [0n, 123n];
      exp(frame);
      expect(frame.stack).toEqual([1n]);
      expect(frame.gasUsed).toBe(10n); // No byte cost for 0
    });

    it("should handle large exponent with correct gas", () => {
      // 2^256
      frame.stack = [256n, 2n];
      exp(frame);
      // 256 = 0x100 = 2 bytes
      expect(frame.gasUsed).toBe(10n + 100n); // base + 2 * 50
    });

    it("should wrap on overflow", () => {
      // 2^256 wraps to 0 in u256
      frame.stack = [256n, 2n];
      exp(frame);
      expect(frame.stack[0]).toBe(0n);
    });

    it("should handle base 0", () => {
      // 0^5 = 0
      frame.stack = [5n, 0n];
      exp(frame);
      expect(frame.stack).toEqual([0n]);
    });

    it("should handle base 1", () => {
      // 1^1000 = 1
      frame.stack = [1000n, 1n];
      exp(frame);
      expect(frame.stack).toEqual([1n]);
    });
  });

  describe("SIGNEXTEND (0x0b)", () => {
    it("should sign extend a positive byte", () => {
      // Stack [byte_index, value]
      frame.stack = [0x7Fn, 0n]; // value 127, byte 0
      signextend(frame);
      expect(frame.stack).toEqual([0x7Fn]);
      expect(frame.gasUsed).toBe(5n);
      expect(frame.pc).toBe(1);
    });

    it("should sign extend a negative byte", () => {
      // Stack [value, byte_index]
      frame.stack = [0xFFn, 0n]; // value 255 (-1 as i8), byte 0
      signextend(frame);
      expect(frame.stack[0]).toBe(MAX_U256); // Extended to all 1s
    });

    it("should handle byte index 1", () => {
      // Sign bit at bit 15 (byte 1, bit 7)
      frame.stack = [0x7FFFn, 1n]; // Positive 16-bit value, byte 1
      signextend(frame);
      expect(frame.stack[0]).toBe(0x7FFFn);
    });

    it("should sign extend negative 16-bit value", () => {
      // Stack [value, byte_index]
      frame.stack = [0x8000n, 1n]; // Negative 16-bit value, byte 1
      signextend(frame);
      // Should extend sign bit from bit 15
      const expected = MAX_U256 - 0x7FFFn;
      expect(frame.stack[0]).toBe(expected);
    });

    it("should not extend if byte_index >= 31", () => {
      const value = 0x123456789ABCDEFn;
      frame.stack = [value, 31n];
      signextend(frame);
      expect(frame.stack).toEqual([value]);
    });

    it("should not extend if byte_index > 31", () => {
      const value = 0x123456789ABCDEFn;
      frame.stack = [value, 100n];
      signextend(frame);
      expect(frame.stack).toEqual([value]);
    });
  });

  describe("Gas consumption", () => {
    it("should use correct gas for fastest operations", () => {
      frame.stack = [5n, 3n];
      add(frame);
      expect(frame.gasUsed).toBe(3n);

      frame.reset();
      frame.stack = [10n, 3n];
      sub(frame);
      expect(frame.gasUsed).toBe(3n);
    });

    it("should use correct gas for fast operations", () => {
      frame.stack = [6n, 7n];
      mul(frame);
      expect(frame.gasUsed).toBe(5n);

      frame.reset();
      frame.stack = [10n, 3n];
      div(frame);
      expect(frame.gasUsed).toBe(5n);

      frame.reset();
      frame.stack = [10n, 3n];
      sdiv(frame);
      expect(frame.gasUsed).toBe(5n);

      frame.reset();
      frame.stack = [10n, 3n];
      mod(frame);
      expect(frame.gasUsed).toBe(5n);

      frame.reset();
      frame.stack = [10n, 3n];
      smod(frame);
      expect(frame.gasUsed).toBe(5n);

      frame.reset();
      frame.stack = [0n, 0x7Fn];
      signextend(frame);
      expect(frame.gasUsed).toBe(5n);
    });

    it("should use correct gas for mid operations", () => {
      frame.stack = [5n, 3n, 4n];
      addmod(frame);
      expect(frame.gasUsed).toBe(8n);

      frame.reset();
      frame.stack = [5n, 3n, 7n];
      mulmod(frame);
      expect(frame.gasUsed).toBe(8n);
    });

    it("should calculate dynamic gas for EXP", () => {
      // Stack [exponent, base], gas based on exponent byte length
      // 0 bytes (exponent = 0)
      frame.stack = [0n, 2n];
      exp(frame);
      expect(frame.gasUsed).toBe(10n);

      // 1 byte (exponent 1-255)
      frame.reset();
      frame.stack = [255n, 2n];
      exp(frame);
      expect(frame.gasUsed).toBe(10n + 50n);

      // 2 bytes (exponent 256-65535)
      frame.reset();
      frame.stack = [256n, 2n];
      exp(frame);
      expect(frame.gasUsed).toBe(10n + 100n);

      // 3 bytes
      frame.reset();
      frame.stack = [65536n, 2n];
      exp(frame);
      expect(frame.gasUsed).toBe(10n + 150n);
    });
  });

  describe("Edge cases", () => {
    it("should handle all operations with MAX_U256", () => {
      // These should all complete without errors
      frame.stack = [MAX_U256, MAX_U256];
      add(frame);

      frame.reset();
      frame.stack = [MAX_U256, MAX_U256];
      mul(frame);

      frame.reset();
      frame.stack = [MAX_U256, MAX_U256];
      sub(frame);

      frame.reset();
      frame.stack = [MAX_U256, MAX_U256];
      div(frame);

      frame.reset();
      frame.stack = [MAX_U256, MAX_U256, MAX_U256];
      addmod(frame);
    });

    it("should handle pc increment correctly", () => {
      frame.pc = 42;
      frame.stack = [5n, 3n];
      add(frame);
      expect(frame.pc).toBe(43);
    });

    it("should maintain stack order", () => {
      // Stack starts as [bottom, ..., top]
      // For SUB: top - second where top is last element
      // Stack [a, b] → b - a
      frame.stack = [3n, 10n]; // 10 - 3 = 7
      sub(frame);
      expect(frame.stack[0]).toBe(7n);
    });
  });
});
