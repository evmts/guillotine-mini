import { describe, it, expect, beforeEach } from 'bun:test';
import { lt, gt, slt, sgt, eq, iszero, type Frame } from './handlers_comparison';

/**
 * Mock Frame implementation for testing comparison handlers
 */
class MockFrame implements Frame {
  stack: bigint[] = [];
  gasUsed = 0n;
  pc = 0;

  consumeGas(amount: bigint): void {
    this.gasUsed += amount;
  }

  popStack(): bigint {
    const value = this.stack.pop();
    if (value === undefined) {
      throw new Error('Stack underflow');
    }
    return value;
  }

  pushStack(value: bigint): void {
    this.stack.push(value);
  }

  reset(): void {
    this.stack = [];
    this.gasUsed = 0n;
    this.pc = 0;
  }
}

describe('Comparison Handlers', () => {
  let frame: MockFrame;

  beforeEach(() => {
    frame = new MockFrame();
  });

  describe('lt - Less Than (Unsigned)', () => {
    it('should return 1 when a < b', () => {
      // Stack: push 10, push 5 -> pop a=5, pop b=10 -> 5 < 10 = true
      frame.stack = [10n, 5n];
      lt(frame);
      expect(frame.stack).toEqual([1n]);
      expect(frame.gasUsed).toBe(3n);
      expect(frame.pc).toBe(1);
    });

    it('should return 0 when a > b', () => {
      // Stack: push 5, push 10 -> pop a=10, pop b=5 -> 10 < 5 = false
      frame.stack = [5n, 10n];
      lt(frame);
      expect(frame.stack).toEqual([0n]);
      expect(frame.gasUsed).toBe(3n);
      expect(frame.pc).toBe(1);
    });

    it('should return 0 when a == b', () => {
      // Stack: push 5, push 5 -> pop a=5, pop b=5 -> 5 < 5 = false
      frame.stack = [5n, 5n];
      lt(frame);
      expect(frame.stack).toEqual([0n]);
      expect(frame.gasUsed).toBe(3n);
      expect(frame.pc).toBe(1);
    });

    it('should handle zero', () => {
      // Stack: push 1, push 0 -> pop a=0, pop b=1 -> 0 < 1 = true
      frame.stack = [1n, 0n];
      lt(frame);
      expect(frame.stack).toEqual([1n]);
    });

    it('should handle maximum u256 value', () => {
      const max = (1n << 256n) - 1n;
      // Stack: push max, push max-1 -> pop a=max-1, pop b=max -> max-1 < max = true
      frame.stack = [max, max - 1n];
      lt(frame);
      expect(frame.stack).toEqual([1n]);
    });

    it('should treat all values as unsigned', () => {
      // 0x8000...0000 (sign bit set) is treated as large positive
      const largeValue = 1n << 255n;
      // Stack: push largeValue, push 1 -> pop a=1, pop b=largeValue -> 1 < 2^255 = true
      frame.stack = [largeValue, 1n];
      lt(frame);
      expect(frame.stack).toEqual([1n]); // 1 < 2^255 (unsigned)
    });
  });

  describe('gt - Greater Than (Unsigned)', () => {
    it('should return 1 when a > b', () => {
      // Stack: push 5, push 10 -> pop a=10, pop b=5 -> 10 > 5 = true
      frame.stack = [5n, 10n];
      gt(frame);
      expect(frame.stack).toEqual([1n]);
      expect(frame.gasUsed).toBe(3n);
      expect(frame.pc).toBe(1);
    });

    it('should return 0 when a < b', () => {
      // Stack: push 10, push 5 -> pop a=5, pop b=10 -> 5 > 10 = false
      frame.stack = [10n, 5n];
      gt(frame);
      expect(frame.stack).toEqual([0n]);
      expect(frame.gasUsed).toBe(3n);
      expect(frame.pc).toBe(1);
    });

    it('should return 0 when a == b', () => {
      // Stack: push 5, push 5 -> pop a=5, pop b=5 -> 5 > 5 = false
      frame.stack = [5n, 5n];
      gt(frame);
      expect(frame.stack).toEqual([0n]);
      expect(frame.gasUsed).toBe(3n);
      expect(frame.pc).toBe(1);
    });

    it('should handle zero', () => {
      // Stack: push 0, push 1 -> pop a=1, pop b=0 -> 1 > 0 = true
      frame.stack = [0n, 1n];
      gt(frame);
      expect(frame.stack).toEqual([1n]);
    });

    it('should handle maximum u256 value', () => {
      const max = (1n << 256n) - 1n;
      // Stack: push max-1, push max -> pop a=max, pop b=max-1 -> max > max-1 = true
      frame.stack = [max - 1n, max];
      gt(frame);
      expect(frame.stack).toEqual([1n]);
    });

    it('should treat all values as unsigned', () => {
      // 0x8000...0000 (sign bit set) is treated as large positive
      const largeValue = 1n << 255n;
      // Stack: push 1, push largeValue -> pop a=largeValue, pop b=1 -> 2^255 > 1 = true
      frame.stack = [1n, largeValue];
      gt(frame);
      expect(frame.stack).toEqual([1n]); // 2^255 > 1 (unsigned)
    });
  });

  describe('slt - Signed Less Than', () => {
    it('should return 1 when signed(a) < signed(b) - both positive', () => {
      // Stack: push 10, push 5 -> pop a=5, pop b=10 -> signed(5) < signed(10) = true
      frame.stack = [10n, 5n];
      slt(frame);
      expect(frame.stack).toEqual([1n]);
      expect(frame.gasUsed).toBe(3n);
      expect(frame.pc).toBe(1);
    });

    it('should return 0 when signed(a) > signed(b) - both positive', () => {
      // Stack: push 5, push 10 -> pop a=10, pop b=5 -> signed(10) < signed(5) = false
      frame.stack = [5n, 10n];
      slt(frame);
      expect(frame.stack).toEqual([0n]);
    });

    it('should return 0 when a == b', () => {
      // Stack: push 5, push 5 -> pop a=5, pop b=5 -> signed(5) < signed(5) = false
      frame.stack = [5n, 5n];
      slt(frame);
      expect(frame.stack).toEqual([0n]);
    });

    it('should handle negative < positive', () => {
      // 0xFFFF...FFFF = -1 in two's complement
      const negOne = (1n << 256n) - 1n;
      // Stack: push 1, push negOne -> pop a=negOne(-1), pop b=1 -> -1 < 1 = true
      frame.stack = [1n, negOne];
      slt(frame);
      expect(frame.stack).toEqual([1n]); // -1 < 1
    });

    it('should handle positive > negative', () => {
      const negOne = (1n << 256n) - 1n;
      // Stack: push negOne, push 1 -> pop a=1, pop b=negOne(-1) -> 1 < -1 = false
      frame.stack = [negOne, 1n];
      slt(frame);
      expect(frame.stack).toEqual([0n]); // 1 is not < -1
    });

    it('should handle both negative values', () => {
      // -5 < -2
      const neg2 = (1n << 256n) - 2n; // 0xFFFF...FFFE = -2
      const neg5 = (1n << 256n) - 5n; // 0xFFFF...FFFB = -5
      // Stack: push neg2, push neg5 -> pop a=neg5(-5), pop b=neg2(-2) -> -5 < -2 = true
      frame.stack = [neg2, neg5];
      slt(frame);
      expect(frame.stack).toEqual([1n]); // -5 < -2
    });

    it('should handle minimum signed value (most negative)', () => {
      const minSigned = 1n << 255n; // 0x8000...0000 = -2^255
      // Stack: push 0, push minSigned -> pop a=minSigned(-2^255), pop b=0 -> -2^255 < 0 = true
      frame.stack = [0n, minSigned];
      slt(frame);
      expect(frame.stack).toEqual([1n]); // -2^255 < 0
    });

    it('should handle maximum signed value (most positive)', () => {
      const maxSigned = (1n << 255n) - 1n; // 0x7FFF...FFFF = 2^255-1
      // Stack: push maxSigned, push 0 -> pop a=0, pop b=maxSigned(2^255-1) -> 0 < 2^255-1 = true
      frame.stack = [maxSigned, 0n];
      slt(frame);
      expect(frame.stack).toEqual([1n]); // 0 < 2^255-1
    });

    it('should handle sign bit boundary', () => {
      // 2^255-1 (max positive) vs 2^255 (min negative)
      const maxPos = (1n << 255n) - 1n;
      const minNeg = 1n << 255n;
      // Stack: push maxPos, push minNeg -> pop a=minNeg(-2^255), pop b=maxPos(2^255-1) -> -2^255 < 2^255-1 = true
      frame.stack = [maxPos, minNeg];
      slt(frame);
      expect(frame.stack).toEqual([1n]); // -2^255 < 2^255-1
    });
  });

  describe('sgt - Signed Greater Than', () => {
    it('should return 1 when signed(a) > signed(b) - both positive', () => {
      // Stack: push 5, push 10 -> pop a=10, pop b=5 -> signed(10) > signed(5) = true
      frame.stack = [5n, 10n];
      sgt(frame);
      expect(frame.stack).toEqual([1n]);
      expect(frame.gasUsed).toBe(3n);
      expect(frame.pc).toBe(1);
    });

    it('should return 0 when signed(a) < signed(b) - both positive', () => {
      // Stack: push 10, push 5 -> pop a=5, pop b=10 -> signed(5) > signed(10) = false
      frame.stack = [10n, 5n];
      sgt(frame);
      expect(frame.stack).toEqual([0n]);
    });

    it('should return 0 when a == b', () => {
      // Stack: push 5, push 5 -> pop a=5, pop b=5 -> signed(5) > signed(5) = false
      frame.stack = [5n, 5n];
      sgt(frame);
      expect(frame.stack).toEqual([0n]);
    });

    it('should handle positive > negative', () => {
      const negOne = (1n << 256n) - 1n;
      // Stack: push negOne, push 1 -> pop a=1, pop b=negOne(-1) -> 1 > -1 = true
      frame.stack = [negOne, 1n];
      sgt(frame);
      expect(frame.stack).toEqual([1n]); // 1 > -1
    });

    it('should handle negative < positive', () => {
      const negOne = (1n << 256n) - 1n;
      // Stack: push 1, push negOne -> pop a=negOne(-1), pop b=1 -> -1 > 1 = false
      frame.stack = [1n, negOne];
      sgt(frame);
      expect(frame.stack).toEqual([0n]); // -1 is not > 1
    });

    it('should handle both negative values', () => {
      // -2 > -5
      const neg2 = (1n << 256n) - 2n;
      const neg5 = (1n << 256n) - 5n;
      // Stack: push neg5, push neg2 -> pop a=neg2(-2), pop b=neg5(-5) -> -2 > -5 = true
      frame.stack = [neg5, neg2];
      sgt(frame);
      expect(frame.stack).toEqual([1n]); // -2 > -5
    });

    it('should handle minimum signed value (most negative)', () => {
      const minSigned = 1n << 255n; // -2^255
      // Stack: push minSigned, push 0 -> pop a=0, pop b=minSigned(-2^255) -> 0 > -2^255 = true
      frame.stack = [minSigned, 0n];
      sgt(frame);
      expect(frame.stack).toEqual([1n]); // 0 > -2^255
    });

    it('should handle maximum signed value (most positive)', () => {
      const maxSigned = (1n << 255n) - 1n; // 2^255-1
      // Stack: push 0, push maxSigned -> pop a=maxSigned(2^255-1), pop b=0 -> 2^255-1 > 0 = true
      frame.stack = [0n, maxSigned];
      sgt(frame);
      expect(frame.stack).toEqual([1n]); // 2^255-1 > 0
    });

    it('should handle sign bit boundary', () => {
      // 2^255-1 (max positive) vs 2^255 (min negative)
      const maxPos = (1n << 255n) - 1n;
      const minNeg = 1n << 255n;
      // Stack: push minNeg, push maxPos -> pop a=maxPos(2^255-1), pop b=minNeg(-2^255) -> 2^255-1 > -2^255 = true
      frame.stack = [minNeg, maxPos];
      sgt(frame);
      expect(frame.stack).toEqual([1n]); // 2^255-1 > -2^255
    });
  });

  describe('eq - Equality', () => {
    it('should return 1 when values are equal', () => {
      frame.stack = [42n, 42n]; // [a=42, b=42]
      eq(frame);
      expect(frame.stack).toEqual([1n]);
      expect(frame.gasUsed).toBe(3n);
      expect(frame.pc).toBe(1);
    });

    it('should return 0 when values are not equal', () => {
      frame.stack = [42n, 43n]; // [a=42, b=43]
      eq(frame);
      expect(frame.stack).toEqual([0n]);
    });

    it('should handle zero equality', () => {
      frame.stack = [0n, 0n]; // [a=0, b=0]
      eq(frame);
      expect(frame.stack).toEqual([1n]);
    });

    it('should handle zero inequality', () => {
      frame.stack = [0n, 1n]; // [a=0, b=1]
      eq(frame);
      expect(frame.stack).toEqual([0n]);
    });

    it('should handle maximum u256 value', () => {
      const max = (1n << 256n) - 1n;
      frame.stack = [max, max]; // [a=max, b=max]
      eq(frame);
      expect(frame.stack).toEqual([1n]);
    });

    it('should be symmetric (order does not matter)', () => {
      // Test a == b
      frame.reset();
      frame.stack = [42n, 100n];
      eq(frame);
      const result1 = frame.stack[0];

      // Test b == a
      frame.reset();
      frame.stack = [100n, 42n];
      eq(frame);
      const result2 = frame.stack[0];

      expect(result1).toBe(result2);
      expect(result1).toBe(0n);
    });

    it('should handle very large numbers', () => {
      const large1 = (1n << 255n) + 12345n;
      const large2 = (1n << 255n) + 12345n;
      frame.stack = [large1, large2];
      eq(frame);
      expect(frame.stack).toEqual([1n]);
    });
  });

  describe('iszero - Check if Zero', () => {
    it('should return 1 when value is zero', () => {
      frame.stack = [0n]; // [a=0]
      iszero(frame);
      expect(frame.stack).toEqual([1n]);
      expect(frame.gasUsed).toBe(3n);
      expect(frame.pc).toBe(1);
    });

    it('should return 0 when value is non-zero positive', () => {
      frame.stack = [1n]; // [a=1]
      iszero(frame);
      expect(frame.stack).toEqual([0n]);
    });

    it('should return 0 for any non-zero value', () => {
      frame.stack = [42n]; // [a=42]
      iszero(frame);
      expect(frame.stack).toEqual([0n]);
    });

    it('should return 0 for maximum u256 value', () => {
      const max = (1n << 256n) - 1n;
      frame.stack = [max]; // [a=max]
      iszero(frame);
      expect(frame.stack).toEqual([0n]);
    });

    it('should return 0 for negative values (as unsigned)', () => {
      // In two's complement, this would be -1, but treated as unsigned
      const maxU256 = (1n << 256n) - 1n;
      frame.stack = [maxU256];
      iszero(frame);
      expect(frame.stack).toEqual([0n]); // Non-zero as unsigned
    });

    it('should work as logical NOT', () => {
      // iszero(0) = 1 (NOT 0 = 1)
      frame.reset();
      frame.stack = [0n];
      iszero(frame);
      expect(frame.stack).toEqual([1n]);

      // iszero(1) = 0 (NOT 1 = 0)
      frame.reset();
      frame.stack = [1n];
      iszero(frame);
      expect(frame.stack).toEqual([0n]);

      // iszero(any non-zero) = 0
      frame.reset();
      frame.stack = [123456789n];
      iszero(frame);
      expect(frame.stack).toEqual([0n]);
    });
  });

  describe('Gas Consumption', () => {
    it('all comparison operations should consume 3 gas', () => {
      const operations = [
        { fn: lt, args: [10n, 5n] }, // Will compare 5 < 10
        { fn: gt, args: [5n, 10n] }, // Will compare 10 > 5
        { fn: slt, args: [10n, 5n] }, // Will compare signed(5) < signed(10)
        { fn: sgt, args: [5n, 10n] }, // Will compare signed(10) > signed(5)
        { fn: eq, args: [42n, 42n] }, // Will compare 42 == 42
      ];

      operations.forEach(({ fn, args }) => {
        frame.reset();
        frame.stack = [...args];
        fn(frame);
        expect(frame.gasUsed).toBe(3n);
      });
    });

    it('iszero should consume 3 gas', () => {
      frame.stack = [0n];
      iszero(frame);
      expect(frame.gasUsed).toBe(3n);
    });
  });

  describe('Program Counter', () => {
    it('all operations should increment PC by 1', () => {
      const operations = [
        { fn: lt, args: [10n, 5n] },
        { fn: gt, args: [5n, 10n] },
        { fn: slt, args: [10n, 5n] },
        { fn: sgt, args: [5n, 10n] },
        { fn: eq, args: [42n, 42n] },
        { fn: iszero, args: [0n] },
      ];

      operations.forEach(({ fn, args }) => {
        frame.reset();
        frame.stack = [...args];
        expect(frame.pc).toBe(0);
        fn(frame);
        expect(frame.pc).toBe(1);
      });
    });

    it('should increment PC from any starting position', () => {
      frame.pc = 100;
      frame.stack = [10n, 5n]; // Will compare 5 < 10
      lt(frame);
      expect(frame.pc).toBe(101);
    });
  });

  describe('Edge Cases', () => {
    it('should handle comparisons with maximum u256 values', () => {
      const max = (1n << 256n) - 1n;

      // max < max should be false
      frame.reset();
      frame.stack = [max, max]; // pop a=max, pop b=max -> max < max = false
      lt(frame);
      expect(frame.stack).toEqual([0n]);

      // max > max should be false
      frame.reset();
      frame.stack = [max, max]; // pop a=max, pop b=max -> max > max = false
      gt(frame);
      expect(frame.stack).toEqual([0n]);

      // max == max should be true
      frame.reset();
      frame.stack = [max, max]; // pop a=max, pop b=max -> max == max = true
      eq(frame);
      expect(frame.stack).toEqual([1n]);
    });

    it('should handle signed comparisons at boundaries', () => {
      const maxPos = (1n << 255n) - 1n; // 0x7FFF...FFFF = 2^255-1
      const minNeg = 1n << 255n; // 0x8000...0000 = -2^255

      // minNeg < maxPos (signed)
      frame.reset();
      frame.stack = [maxPos, minNeg]; // pop a=minNeg(-2^255), pop b=maxPos(2^255-1) -> -2^255 < 2^255-1 = true
      slt(frame);
      expect(frame.stack).toEqual([1n]);

      // maxPos > minNeg (signed)
      frame.reset();
      frame.stack = [minNeg, maxPos]; // pop a=maxPos(2^255-1), pop b=minNeg(-2^255) -> 2^255-1 > -2^255 = true
      sgt(frame);
      expect(frame.stack).toEqual([1n]);
    });

    it('should treat unsigned large values correctly', () => {
      // In unsigned comparison, 0x8000...0000 is very large
      const signBit = 1n << 255n;

      // signBit > 1 (unsigned)
      frame.reset();
      frame.stack = [1n, signBit]; // pop a=signBit(2^255), pop b=1 -> 2^255 > 1 = true
      gt(frame);
      expect(frame.stack).toEqual([1n]);

      // 1 < signBit (unsigned)
      frame.reset();
      frame.stack = [signBit, 1n]; // pop a=1, pop b=signBit(2^255) -> 1 < 2^255 = true
      lt(frame);
      expect(frame.stack).toEqual([1n]);
    });

    it('should handle double negation with iszero', () => {
      // iszero(iszero(0)) = iszero(1) = 0
      frame.stack = [0n];
      iszero(frame);
      iszero(frame);
      expect(frame.stack).toEqual([0n]);

      // iszero(iszero(42)) = iszero(0) = 1
      frame.reset();
      frame.stack = [42n];
      iszero(frame);
      iszero(frame);
      expect(frame.stack).toEqual([1n]);
    });
  });

  describe('Stack Underflow', () => {
    it('should throw on empty stack for binary operations', () => {
      const binaryOps = [lt, gt, slt, sgt, eq];

      binaryOps.forEach((fn) => {
        frame.reset();
        frame.stack = []; // Empty stack
        expect(() => fn(frame)).toThrow('Stack underflow');

        frame.reset();
        frame.stack = [42n]; // Only one value
        expect(() => fn(frame)).toThrow('Stack underflow');
      });
    });

    it('should throw on empty stack for unary operations', () => {
      frame.stack = [];
      expect(() => iszero(frame)).toThrow('Stack underflow');
    });
  });
});
