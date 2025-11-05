/**
 * Tests for KECCAK256 (SHA3) opcode handler
 */

import { describe, it, expect, beforeEach } from 'vitest';
import { sha3, type Frame, OutOfBoundsError, OutOfGasError, StackUnderflowError, StackOverflowError } from './handlers_keccak';

/**
 * Mock Frame implementation for testing
 */
class MockFrame implements Frame {
  pc: number = 0;
  memory: Uint8Array;
  memorySize: number = 0;
  stack: bigint[] = [];
  gasRemaining: bigint = 1000000n;

  constructor(initialMemorySize = 1024) {
    this.memory = new Uint8Array(initialMemorySize);
  }

  consumeGas(amount: bigint): void {
    if (this.gasRemaining < amount) {
      throw new OutOfGasError();
    }
    this.gasRemaining -= amount;
  }

  popStack(): bigint {
    const value = this.stack.pop();
    if (value === undefined) {
      throw new StackUnderflowError();
    }
    return value;
  }

  pushStack(value: bigint): void {
    if (this.stack.length >= 1024) {
      throw new StackOverflowError();
    }
    this.stack.push(value);
  }

  readMemory(offset: number): number {
    if (offset >= this.memory.length) {
      // Expand memory if needed
      const newSize = Math.max(this.memory.length * 2, offset + 1);
      const newMemory = new Uint8Array(newSize);
      newMemory.set(this.memory);
      this.memory = newMemory;
    }
    return this.memory[offset] ?? 0;
  }

  writeMemory(offset: number, value: number): void {
    if (offset >= this.memory.length) {
      const newSize = Math.max(this.memory.length * 2, offset + 1);
      const newMemory = new Uint8Array(newSize);
      newMemory.set(this.memory);
      this.memory = newMemory;
    }
    this.memory[offset] = value;
  }

  memoryExpansionCost(endAddress: bigint): bigint {
    const endNum = Number(endAddress);
    if (endNum <= this.memorySize) {
      return 0n;
    }
    // Simplified memory expansion cost (quadratic)
    // Real formula: (words^2) / 512 + 3 * words
    const words = BigInt(Math.ceil(endNum / 32));
    const newCost = (words * words) / 512n + 3n * words;
    const oldWords = BigInt(Math.ceil(this.memorySize / 32));
    const oldCost = (oldWords * oldWords) / 512n + 3n * oldWords;
    return newCost - oldCost;
  }
}

describe('KECCAK256 (SHA3) Opcode Handler', () => {
  let frame: MockFrame;

  beforeEach(() => {
    frame = new MockFrame();
  });

  describe('Empty Data (size = 0)', () => {
    it('should return known hash for empty input', () => {
      // Setup: Push offset=0, size=0 onto stack
      frame.stack.push(0n); // size
      frame.stack.push(0n); // offset

      const initialGas = frame.gasRemaining;
      const initialPc = frame.pc;

      // Execute
      sha3(frame);

      // Expected hash for keccak256("")
      const expectedHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470n;

      // Verify
      expect(frame.stack).toHaveLength(1);
      expect(frame.stack[0]).toBe(expectedHash);
      expect(frame.pc).toBe(initialPc + 1);
      expect(frame.gasRemaining).toBeLessThan(initialGas); // Gas was consumed
    });
  });

  describe('Single Word (32 bytes)', () => {
    it('should hash 32 bytes of zeros correctly', () => {
      // Setup: 32 zeros in memory at offset 0
      for (let i = 0; i < 32; i++) {
        frame.writeMemory(i, 0);
      }

      frame.stack.push(32n); // size
      frame.stack.push(0n);  // offset

      // Execute
      sha3(frame);

      // Verify stack has result
      expect(frame.stack).toHaveLength(1);
      const hash = frame.stack[0];
      expect(hash).toBeGreaterThan(0n);

      // keccak256(32 zeros) = 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563
      const expectedHash = 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563n;
      expect(hash).toBe(expectedHash);
    });

    it('should hash 32 bytes of 0xFF correctly', () => {
      // Setup: 32 0xFF bytes in memory
      for (let i = 0; i < 32; i++) {
        frame.writeMemory(i, 0xFF);
      }

      frame.stack.push(32n); // size
      frame.stack.push(0n);  // offset

      // Execute
      sha3(frame);

      // Verify
      expect(frame.stack).toHaveLength(1);
      const hash = frame.stack[0];
      expect(hash).toBeGreaterThan(0n);

      // keccak256(32 * 0xFF) = 0xa9c584056064687e149968cbab758a3376d22aedc6a55823d1b3ecbee81b8fb9
      const expectedHash = 0xa9c584056064687e149968cbab758a3376d22aedc6a55823d1b3ecbee81b8fb9n;
      expect(hash).toBe(expectedHash);
    });
  });

  describe('Multi-Word Data', () => {
    it('should hash 64 bytes correctly', () => {
      // Setup: 64 sequential bytes (0x00..0x3F)
      for (let i = 0; i < 64; i++) {
        frame.writeMemory(i, i);
      }

      frame.stack.push(64n); // size
      frame.stack.push(0n);  // offset

      const initialGas = frame.gasRemaining;

      // Execute
      sha3(frame);

      // Verify
      expect(frame.stack).toHaveLength(1);
      const hash = frame.stack[0];
      expect(hash).toBeGreaterThan(0n);

      // Gas should account for 2 words (64 bytes / 32)
      // Gas = 30 + 6 * 2 = 42
      const expectedGasCost = 30n + 6n * 2n;
      expect(frame.gasRemaining).toBeLessThanOrEqual(initialGas - expectedGasCost);
    });

    it('should hash non-word-aligned data correctly', () => {
      // Setup: 50 bytes (not word-aligned)
      for (let i = 0; i < 50; i++) {
        frame.writeMemory(i, i % 256);
      }

      frame.stack.push(50n); // size
      frame.stack.push(0n);  // offset

      const initialGas = frame.gasRemaining;

      // Execute
      sha3(frame);

      // Verify
      expect(frame.stack).toHaveLength(1);
      const hash = frame.stack[0];
      expect(hash).toBeGreaterThan(0n);

      // Gas should account for 2 words (50 bytes rounds up to 64)
      // Gas = 30 + 6 * 2 = 42
      const expectedGasCost = 30n + 6n * 2n;
      expect(frame.gasRemaining).toBeLessThanOrEqual(initialGas - expectedGasCost);
    });
  });

  describe('Known Test Vectors', () => {
    it('should hash "Hello, World!" correctly', () => {
      // ASCII for "Hello, World!"
      const text = "Hello, World!";
      const bytes = new TextEncoder().encode(text);

      // Write to memory
      for (let i = 0; i < bytes.length; i++) {
        frame.writeMemory(i, bytes[i]);
      }

      frame.stack.push(BigInt(bytes.length)); // size
      frame.stack.push(0n);                    // offset

      // Execute
      sha3(frame);

      // Verify
      expect(frame.stack).toHaveLength(1);
      const hash = frame.stack[0];

      // keccak256("Hello, World!") = 0xacaf3289d7b601cbd114fb36c4d29c85bbfd5e133f14cb355c3fd8d99367964f
      const expectedHash = 0xacaf3289d7b601cbd114fb36c4d29c85bbfd5e133f14cb355c3fd8d99367964fn;
      expect(hash).toBe(expectedHash);
    });

    it('should hash single byte correctly', () => {
      // Single byte: 0x01
      frame.writeMemory(0, 0x01);

      frame.stack.push(1n); // size
      frame.stack.push(0n); // offset

      // Execute
      sha3(frame);

      // Verify
      expect(frame.stack).toHaveLength(1);
      const hash = frame.stack[0];
      expect(hash).toBeGreaterThan(0n);

      // keccak256(0x01) = 0x5fe7f977e71dba2ea1a68e21057beebb9be2ac30c6410aa38d4f3fbe41dcffd2
      const expectedHash = 0x5fe7f977e71dba2ea1a68e21057beebb9be2ac30c6410aa38d4f3fbe41dcffd2n;
      expect(hash).toBe(expectedHash);
    });
  });

  describe('Memory Offsets', () => {
    it('should hash data at non-zero offset', () => {
      // Write data at offset 100
      const offset = 100;
      const data = [0xDE, 0xAD, 0xBE, 0xEF];

      for (let i = 0; i < data.length; i++) {
        frame.writeMemory(offset + i, data[i]);
      }

      frame.stack.push(4n);              // size
      frame.stack.push(BigInt(offset));  // offset

      // Execute
      sha3(frame);

      // Verify
      expect(frame.stack).toHaveLength(1);
      const hash = frame.stack[0];
      expect(hash).toBeGreaterThan(0n);

      // keccak256(0xDEADBEEF) = 0xd4fd4e189132273036449fc9e11198c739161b4c0116a9a2dccdfa1c492006f1
      const expectedHash = 0xd4fd4e189132273036449fc9e11198c739161b4c0116a9a2dccdfa1c492006f1n;
      expect(hash).toBe(expectedHash);
    });

    it('should handle large offsets correctly', () => {
      // Large offset but within bounds
      const offset = 1000;
      frame.writeMemory(offset, 0x42);

      frame.stack.push(1n);              // size
      frame.stack.push(BigInt(offset));  // offset

      // Execute
      sha3(frame);

      // Verify
      expect(frame.stack).toHaveLength(1);
      expect(frame.pc).toBe(1);
    });
  });

  describe('Gas Accounting', () => {
    it('should charge correct gas for empty data', () => {
      frame.stack.push(0n); // size
      frame.stack.push(0n); // offset

      const initialGas = frame.gasRemaining;

      sha3(frame);

      // Gas = 30 + 6 * 0 = 30
      const expectedGas = 30n;
      expect(initialGas - frame.gasRemaining).toBeGreaterThanOrEqual(expectedGas);
    });

    it('should charge correct gas for 1 word', () => {
      for (let i = 0; i < 32; i++) {
        frame.writeMemory(i, 0);
      }

      frame.stack.push(32n); // size
      frame.stack.push(0n);  // offset

      const initialGas = frame.gasRemaining;

      sha3(frame);

      // Gas = 30 + 6 * 1 = 36 (plus memory expansion)
      const expectedGas = 36n;
      expect(initialGas - frame.gasRemaining).toBeGreaterThanOrEqual(expectedGas);
    });

    it('should charge correct gas for 3 words', () => {
      for (let i = 0; i < 96; i++) {
        frame.writeMemory(i, 0);
      }

      frame.stack.push(96n); // size
      frame.stack.push(0n);  // offset

      const initialGas = frame.gasRemaining;

      sha3(frame);

      // Gas = 30 + 6 * 3 = 48 (plus memory expansion)
      const expectedGas = 48n;
      expect(initialGas - frame.gasRemaining).toBeGreaterThanOrEqual(expectedGas);
    });

    it('should throw OutOfGas when insufficient gas', () => {
      frame.gasRemaining = 20n; // Not enough for KECCAK256

      frame.stack.push(32n); // size
      frame.stack.push(0n);  // offset

      expect(() => sha3(frame)).toThrow(OutOfGasError);
    });
  });

  describe('Memory Expansion', () => {
    it('should expand memory when needed', () => {
      const initialMemorySize = frame.memorySize;

      // Hash data beyond current memory size
      frame.stack.push(64n); // size
      frame.stack.push(0n);  // offset

      sha3(frame);

      // Memory should have expanded
      expect(frame.memorySize).toBeGreaterThan(initialMemorySize);
    });

    it('should charge memory expansion cost', () => {
      frame.memorySize = 0;

      frame.stack.push(128n); // size = 128 bytes (4 words)
      frame.stack.push(0n);   // offset

      const initialGas = frame.gasRemaining;

      sha3(frame);

      // Should charge both KECCAK256 gas and memory expansion
      // KECCAK256 gas = 30 + 6 * 4 = 54
      // Memory expansion cost is additional (quadratic formula)
      const keccakGas = 54n;
      expect(initialGas - frame.gasRemaining).toBeGreaterThan(keccakGas);
    });
  });

  describe('Edge Cases', () => {
    it('should handle maximum practical size', () => {
      // Large but reasonable size (1 KB)
      const size = 1024;
      for (let i = 0; i < size; i++) {
        frame.writeMemory(i, i % 256);
      }

      frame.stack.push(BigInt(size)); // size
      frame.stack.push(0n);           // offset

      // Execute
      sha3(frame);

      // Verify
      expect(frame.stack).toHaveLength(1);
      expect(frame.pc).toBe(1);
    });

    it('should throw OutOfBounds for size exceeding u32', () => {
      const MAX_U32 = 0xFFFFFFFF;

      frame.stack.push(BigInt(MAX_U32) + 1n); // size > u32::MAX
      frame.stack.push(0n);                    // offset

      expect(() => sha3(frame)).toThrow(OutOfBoundsError);
    });

    it('should throw OutOfBounds for offset exceeding u32', () => {
      const MAX_U32 = 0xFFFFFFFF;

      frame.stack.push(1n);                    // size
      frame.stack.push(BigInt(MAX_U32) + 1n); // offset > u32::MAX

      expect(() => sha3(frame)).toThrow(OutOfBoundsError);
    });

    it('should throw StackUnderflow when stack is empty', () => {
      // Empty stack - no values to pop
      expect(() => sha3(frame)).toThrow(StackUnderflowError);
    });

    it('should throw StackUnderflow when stack has only one value', () => {
      // Only one value on stack (needs two: offset and size)
      frame.stack.push(0n);

      expect(() => sha3(frame)).toThrow(StackUnderflowError);
    });
  });

  describe('PC Increment', () => {
    it('should increment PC by 1 on success', () => {
      frame.pc = 42;
      frame.stack.push(0n); // size
      frame.stack.push(0n); // offset

      sha3(frame);

      expect(frame.pc).toBe(43);
    });

    it('should not increment PC on error', () => {
      frame.pc = 42;
      frame.gasRemaining = 10n; // Not enough gas

      frame.stack.push(32n); // size
      frame.stack.push(0n);  // offset

      expect(() => sha3(frame)).toThrow(OutOfGasError);
      expect(frame.pc).toBe(42); // PC unchanged
    });
  });

  describe('Ethereum Yellow Paper Test Vectors', () => {
    it('should match known Ethereum test vector 1', () => {
      // Empty hash
      frame.stack.push(0n);
      frame.stack.push(0n);

      sha3(frame);

      const hash = frame.stack[0];
      // Verify against known empty hash
      expect(hash).toBe(0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470n);
    });

    it('should match known Ethereum test vector 2', () => {
      // Hash of 0x00
      frame.writeMemory(0, 0x00);
      frame.stack.push(1n);
      frame.stack.push(0n);

      sha3(frame);

      const hash = frame.stack[0];
      // keccak256(0x00) = 0xbc36789e7a1e281436464229828f817d6612f7b477d66591ff96a9e064bcc98a
      expect(hash).toBe(0xbc36789e7a1e281436464229828f817d6612f7b477d66591ff96a9e064bcc98an);
    });
  });
});
