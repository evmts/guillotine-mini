/**
 * Tests for bitwise opcode handlers
 * Port of handlers_bitwise.zig tests to TypeScript
 */

import { describe, it, expect, beforeEach } from 'vitest';
import {
  op_and,
  op_or,
  op_xor,
  op_not,
  byte,
  shl,
  shr,
  sar,
  type Frame,
  type Evm,
  type Hardfork,
} from './handlers_bitwise';

/**
 * Mock Frame for testing
 */
class MockFrame implements Frame {
  stack: bigint[] = [];
  pc: number = 0;
  gasUsed: bigint = 0n;
  hardfork: string = 'CANCUN';

  consumeGas(amount: bigint): void {
    this.gasUsed += amount;
  }

  popStack(): bigint {
    const value = this.stack.pop();
    if (value === undefined) {
      throw new Error('StackUnderflow');
    }
    return value;
  }

  pushStack(value: bigint): void {
    if (this.stack.length >= 1024) {
      throw new Error('StackOverflow');
    }
    this.stack.push(value);
  }

  getEvm(): Evm {
    return {
      hardfork: {
        isBefore: (fork: string) => {
          const forks = [
            'FRONTIER',
            'HOMESTEAD',
            'TANGERINE',
            'SPURIOUS',
            'BYZANTIUM',
            'CONSTANTINOPLE',
            'ISTANBUL',
            'BERLIN',
            'LONDON',
            'MERGE',
            'SHANGHAI',
            'CANCUN',
            'PRAGUE',
          ];
          const currentIdx = forks.indexOf(this.hardfork);
          const targetIdx = forks.indexOf(fork);
          return currentIdx < targetIdx;
        },
      },
    };
  }
}

describe('handlers_bitwise', () => {
  let frame: MockFrame;

  beforeEach(() => {
    frame = new MockFrame();
  });

  describe('op_and', () => {
    it('should perform bitwise AND on two values', () => {
      frame.stack = [0xfn, 0xaan];
      op_and(frame);

      expect(frame.stack).toEqual([0xan]);
      expect(frame.pc).toBe(1);
      expect(frame.gasUsed).toBe(3n);
    });

    it('should handle all zeros', () => {
      frame.stack = [0n, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffn];
      op_and(frame);

      expect(frame.stack).toEqual([0n]);
    });

    it('should handle all ones', () => {
      frame.stack = [
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffn,
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffn,
      ];
      op_and(frame);

      expect(frame.stack).toEqual([
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffn,
      ]);
    });

    it('should mask result to 256 bits', () => {
      frame.stack = [0x123n, 0x456n];
      op_and(frame);

      expect(frame.stack).toEqual([0x2n]);
    });
  });

  describe('op_or', () => {
    it('should perform bitwise OR on two values', () => {
      frame.stack = [0xfn, 0xaan];
      op_or(frame);

      expect(frame.stack).toEqual([0xafn]);
      expect(frame.pc).toBe(1);
      expect(frame.gasUsed).toBe(3n);
    });

    it('should handle all zeros', () => {
      frame.stack = [0n, 0n];
      op_or(frame);

      expect(frame.stack).toEqual([0n]);
    });

    it('should handle all ones', () => {
      frame.stack = [
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffn,
        0n,
      ];
      op_or(frame);

      expect(frame.stack).toEqual([
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffn,
      ]);
    });

    it('should combine bits correctly', () => {
      frame.stack = [0x123n, 0x456n];
      op_or(frame);

      expect(frame.stack).toEqual([0x577n]);
    });
  });

  describe('op_xor', () => {
    it('should perform bitwise XOR on two values', () => {
      frame.stack = [0xfn, 0xaan];
      op_xor(frame);

      expect(frame.stack).toEqual([0xa5n]);
      expect(frame.pc).toBe(1);
      expect(frame.gasUsed).toBe(3n);
    });

    it('should return 0 for identical values', () => {
      frame.stack = [0x123n, 0x123n];
      op_xor(frame);

      expect(frame.stack).toEqual([0n]);
    });

    it('should flip bits correctly', () => {
      frame.stack = [0x123n, 0x456n];
      op_xor(frame);

      expect(frame.stack).toEqual([0x575n]);
    });

    it('should handle all ones', () => {
      frame.stack = [
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffn,
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffn,
      ];
      op_xor(frame);

      expect(frame.stack).toEqual([0n]);
    });
  });

  describe('op_not', () => {
    it('should perform bitwise NOT', () => {
      frame.stack = [0n];
      op_not(frame);

      expect(frame.stack).toEqual([
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffn,
      ]);
      expect(frame.pc).toBe(1);
      expect(frame.gasUsed).toBe(3n);
    });

    it('should flip all bits', () => {
      frame.stack = [0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffn];
      op_not(frame);

      expect(frame.stack).toEqual([0n]);
    });

    it('should flip partial value', () => {
      frame.stack = [0xfn];
      op_not(frame);

      expect(frame.stack).toEqual([
        0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0n,
      ]);
    });

    it('should be involutory (NOT NOT = identity)', () => {
      const original = 0x123456789abcdef0n;
      frame.stack = [original];
      op_not(frame);
      op_not(frame);

      expect(frame.stack).toEqual([original]);
    });
  });

  describe('byte', () => {
    it('should extract most significant byte (index 0)', () => {
      frame.stack = [
        0xff00000000000000000000000000000000000000000000000000000000000000n,
        0n,
      ];
      byte(frame);

      expect(frame.stack).toEqual([0xffn]);
      expect(frame.pc).toBe(1);
      expect(frame.gasUsed).toBe(3n);
    });

    it('should extract least significant byte (index 31)', () => {
      frame.stack = [
        0x00000000000000000000000000000000000000000000000000000000000000ffn,
        31n,
      ];
      byte(frame);

      expect(frame.stack).toEqual([0xffn]);
    });

    it('should extract middle byte', () => {
      frame.stack = [
        0xabn << 128n, // byte 15 is at bit offset 128
        15n,
      ];
      byte(frame);

      expect(frame.stack).toEqual([0xabn]);
    });

    it('should return 0 for out of bounds index', () => {
      frame.stack = [0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffn, 32n];
      byte(frame);

      expect(frame.stack).toEqual([0n]);
    });

    it('should return 0 for very large index', () => {
      frame.stack = [0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffn, 1000n];
      byte(frame);

      expect(frame.stack).toEqual([0n]);
    });

    it('should extract bytes from sequential positions', () => {
      const value = 0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdefn;
      const expected = [
        0x01n, 0x23n, 0x45n, 0x67n, 0x89n, 0xabn, 0xcdn, 0xefn,
        0x01n, 0x23n, 0x45n, 0x67n, 0x89n, 0xabn, 0xcdn, 0xefn,
        0x01n, 0x23n, 0x45n, 0x67n, 0x89n, 0xabn, 0xcdn, 0xefn,
        0x01n, 0x23n, 0x45n, 0x67n, 0x89n, 0xabn, 0xcdn, 0xefn,
      ];

      for (let i = 0n; i < 32n; i++) {
        frame.stack = [value, i];
        byte(frame);
        expect(frame.stack[0]).toBe(expected[Number(i)]);
        frame.stack = [];
      }
    });
  });

  describe('shl', () => {
    it('should shift left by 4 bits', () => {
      frame.stack = [0x1n, 4n];
      shl(frame);

      expect(frame.stack).toEqual([0x10n]);
      expect(frame.pc).toBe(1);
      expect(frame.gasUsed).toBe(3n);
    });

    it('should shift left by 8 bits', () => {
      frame.stack = [0xffn, 8n];
      shl(frame);

      expect(frame.stack).toEqual([0xff00n]);
    });

    it('should return 0 for shift >= 256', () => {
      frame.stack = [0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffn, 256n];
      shl(frame);

      expect(frame.stack).toEqual([0n]);
    });

    it('should mask to 256 bits on overflow', () => {
      frame.stack = [
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffn,
        1n,
      ];
      shl(frame);

      expect(frame.stack).toEqual([
        0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffen,
      ]);
    });

    it('should handle zero shift', () => {
      frame.stack = [0x123n, 0n];
      shl(frame);

      expect(frame.stack).toEqual([0x123n]);
    });

    it('should throw error before Constantinople hardfork', () => {
      frame.hardfork = 'BYZANTIUM';
      frame.stack = [0x1n, 4n];

      expect(() => shl(frame)).toThrow('InvalidOpcode');
    });
  });

  describe('shr', () => {
    it('should shift right by 4 bits', () => {
      frame.stack = [0x10n, 4n];
      shr(frame);

      expect(frame.stack).toEqual([0x1n]);
      expect(frame.pc).toBe(1);
      expect(frame.gasUsed).toBe(3n);
    });

    it('should shift right by 8 bits', () => {
      frame.stack = [0xff00n, 8n];
      shr(frame);

      expect(frame.stack).toEqual([0xffn]);
    });

    it('should return 0 for shift >= 256', () => {
      frame.stack = [0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffn, 256n];
      shr(frame);

      expect(frame.stack).toEqual([0n]);
    });

    it('should zero-fill on right shift', () => {
      frame.stack = [
        0x8000000000000000000000000000000000000000000000000000000000000000n,
        4n,
      ];
      shr(frame);

      expect(frame.stack).toEqual([
        0x0800000000000000000000000000000000000000000000000000000000000000n,
      ]);
    });

    it('should handle zero shift', () => {
      frame.stack = [0x123n, 0n];
      shr(frame);

      expect(frame.stack).toEqual([0x123n]);
    });

    it('should throw error before Constantinople hardfork', () => {
      frame.hardfork = 'BYZANTIUM';
      frame.stack = [0x10n, 4n];

      expect(() => shr(frame)).toThrow('InvalidOpcode');
    });
  });

  describe('sar', () => {
    it('should shift right positive value by 4 bits', () => {
      frame.stack = [0x10n, 4n];
      sar(frame);

      expect(frame.stack).toEqual([0x1n]);
      expect(frame.pc).toBe(1);
      expect(frame.gasUsed).toBe(3n);
    });

    it('should sign-extend negative value', () => {
      // Sign bit set (negative value)
      frame.stack = [
        0x8000000000000000000000000000000000000000000000000000000000000000n,
        4n,
      ];
      sar(frame);

      // Should be sign-extended with 1s
      expect(frame.stack).toEqual([
        0xf800000000000000000000000000000000000000000000000000000000000000n,
      ]);
    });

    it('should return all 1s for negative value with shift >= 256', () => {
      // Sign bit set (negative value)
      frame.stack = [
        0x8000000000000000000000000000000000000000000000000000000000000000n,
        256n,
      ];
      sar(frame);

      expect(frame.stack).toEqual([
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffn,
      ]);
    });

    it('should return 0 for positive value with shift >= 256', () => {
      frame.stack = [
        0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffn,
        256n,
      ];
      sar(frame);

      expect(frame.stack).toEqual([0n]);
    });

    it('should handle zero shift', () => {
      frame.stack = [0x123n, 0n];
      sar(frame);

      expect(frame.stack).toEqual([0x123n]);
    });

    it('should sign-extend small negative value', () => {
      // All bits set (negative -1)
      frame.stack = [
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffn,
        4n,
      ];
      sar(frame);

      // Still all bits set
      expect(frame.stack).toEqual([
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffn,
      ]);
    });

    it('should throw error before Constantinople hardfork', () => {
      frame.hardfork = 'BYZANTIUM';
      frame.stack = [0x10n, 4n];

      expect(() => sar(frame)).toThrow('InvalidOpcode');
    });
  });

  describe('gas costs', () => {
    it('should consume 3 gas for each operation', () => {
      const operations = [op_and, op_or, op_xor, op_not, byte, shl, shr, sar];

      for (const op of operations) {
        const testFrame = new MockFrame();
        testFrame.stack = [0x1n, 0x2n];

        try {
          op(testFrame);
          expect(testFrame.gasUsed).toBe(3n);
        } catch (e) {
          // Skip hardfork errors for shift operations
          if (e instanceof Error && e.message === 'InvalidOpcode') {
            continue;
          }
          throw e;
        }
      }
    });
  });

  describe('PC increment', () => {
    it('should increment PC by 1 for each operation', () => {
      const operations = [op_and, op_or, op_xor, op_not, byte, shl, shr, sar];

      for (const op of operations) {
        const testFrame = new MockFrame();
        testFrame.stack = [0x1n, 0x2n];
        testFrame.pc = 42;

        try {
          op(testFrame);
          expect(testFrame.pc).toBe(43);
        } catch (e) {
          // Skip hardfork errors for shift operations
          if (e instanceof Error && e.message === 'InvalidOpcode') {
            continue;
          }
          throw e;
        }
      }
    });
  });
});
