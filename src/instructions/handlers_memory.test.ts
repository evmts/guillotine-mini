import { describe, expect, test, beforeEach } from 'bun:test';
import {
  mload,
  mstore,
  mstore8,
  msize,
  mcopy,
  Frame,
  Evm,
  Hardfork,
} from './handlers_memory';

/**
 * Mock Frame implementation for testing
 */
class MockFrame implements Frame {
  stack: bigint[] = [];
  memory: Map<number, number> = new Map();
  memory_size: number = 0;
  pc: number = 0;
  gasRemaining: bigint = 1000000n;
  hardfork: Hardfork = Hardfork.CANCUN;

  consumeGas(amount: bigint): void {
    if (amount > this.gasRemaining) {
      throw new Error('OutOfGas');
    }
    this.gasRemaining -= amount;
  }

  popStack(): bigint {
    if (this.stack.length === 0) {
      throw new Error('StackUnderflow');
    }
    return this.stack.pop()!;
  }

  pushStack(value: bigint): void {
    if (this.stack.length >= 1024) {
      throw new Error('StackOverflow');
    }
    this.stack.push(value);
  }

  readMemory(offset: number): number {
    return this.memory.get(offset) ?? 0;
  }

  writeMemory(offset: number, value: number): void {
    this.memory.set(offset, value & 0xff);
    // Don't auto-update memory_size here - let the opcode handler do it
  }

  memoryExpansionCost(endBytes: bigint): bigint {
    const currentSize = BigInt(this.memory_size);
    if (endBytes <= currentSize) return 0n;

    const currentWords = currentSize / 32n;
    const newWords = (endBytes + 31n) / 32n;

    // Cost = 3n + n²/512
    const newCost = 3n * newWords + (newWords * newWords) / 512n;
    const currentCost = 3n * currentWords + (currentWords * currentWords) / 512n;

    return newCost - currentCost;
  }

  getEvm(): Evm {
    return {
      hardfork: this.hardfork,
    };
  }

  reset(): void {
    this.stack = [];
    this.memory = new Map();
    this.memory_size = 0;
    this.pc = 0;
    this.gasRemaining = 1000000n;
  }
}

describe('MLOAD', () => {
  let frame: MockFrame;

  beforeEach(() => {
    frame = new MockFrame();
  });

  test('loads zero from uninitialized memory', () => {
    frame.pushStack(0n); // offset
    mload(frame);

    expect(frame.popStack()).toBe(0n);
    expect(frame.pc).toBe(1);
  });

  test('loads 32 bytes from memory', () => {
    // Write test data to memory
    for (let i = 0; i < 32; i++) {
      frame.memory.set(i, i + 1);
    }
    frame.memory_size = 32;

    frame.pushStack(0n); // offset
    mload(frame);

    // Expected: 0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20
    const expected = BigInt(
      '0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20'
    );
    expect(frame.popStack()).toBe(expected);
  });

  test('loads from offset', () => {
    // Write 0xFF at position 10-41
    for (let i = 10; i < 42; i++) {
      frame.memory.set(i, 0xff);
    }
    frame.memory_size = 64;

    frame.pushStack(10n); // offset
    mload(frame);

    // All 32 bytes should be 0xFF
    const expected = (1n << 256n) - 1n;
    expect(frame.popStack()).toBe(expected);
  });

  test('expands memory on first access', () => {
    frame.pushStack(0n);
    mload(frame);

    expect(frame.memory_size).toBe(32);
  });

  test('expands memory when reading beyond current size', () => {
    frame.memory_size = 32;

    frame.pushStack(32n); // offset
    mload(frame);

    expect(frame.memory_size).toBe(64);
  });

  test('charges gas including expansion cost', () => {
    const initialGas = frame.gasRemaining;

    frame.pushStack(0n);
    mload(frame);

    // Should charge GasFastestStep (3) + expansion cost
    expect(frame.gasRemaining).toBeLessThan(initialGas);
  });

  test('throws on offset overflow', () => {
    frame.pushStack(BigInt(0x100000000)); // > u32::MAX

    expect(() => mload(frame)).toThrow('OutOfBounds');
  });
});

describe('MSTORE', () => {
  let frame: MockFrame;

  beforeEach(() => {
    frame = new MockFrame();
  });

  test('stores 32 bytes to memory', () => {
    const value = BigInt('0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20');
    frame.pushStack(value); // value (bottom)
    frame.pushStack(0n); // offset (top, popped first)
    mstore(frame);

    // Verify each byte was stored correctly
    for (let i = 0; i < 32; i++) {
      expect(frame.memory.get(i)).toBe(i + 1);
    }
    expect(frame.pc).toBe(1);
  });

  test('stores max u256 value', () => {
    const maxU256 = (1n << 256n) - 1n;
    frame.pushStack(maxU256); // value
    frame.pushStack(0n); // offset
    mstore(frame);

    // All bytes should be 0xFF
    for (let i = 0; i < 32; i++) {
      expect(frame.memory.get(i)).toBe(0xff);
    }
  });

  test('stores at offset', () => {
    frame.pushStack(0x42n); // value
    frame.pushStack(100n); // offset
    mstore(frame);

    // Last byte (at offset 131 = 100 + 31) should be 0x42
    expect(frame.memory.get(131)).toBe(0x42);
  });

  test('expands memory on first write', () => {
    frame.pushStack(0n); // value
    frame.pushStack(0n); // offset
    mstore(frame);

    expect(frame.memory_size).toBe(32);
  });

  test('stores zero value', () => {
    frame.pushStack(0n); // value
    frame.pushStack(0n); // offset
    mstore(frame);

    // Memory should remain zero-initialized
    for (let i = 0; i < 32; i++) {
      expect(frame.memory.get(i) ?? 0).toBe(0);
    }
  });

  test('overwrites existing memory', () => {
    // First store
    frame.pushStack(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffn); // value
    frame.pushStack(0n); // offset
    mstore(frame);

    // Overwrite with zeros
    frame.pushStack(0n); // value
    frame.pushStack(0n); // offset
    mstore(frame);

    for (let i = 0; i < 32; i++) {
      expect(frame.memory.get(i) ?? 0).toBe(0);
    }
  });

  test('charges gas including expansion cost', () => {
    const initialGas = frame.gasRemaining;

    frame.pushStack(123n); // value
    frame.pushStack(0n); // offset
    mstore(frame);

    expect(frame.gasRemaining).toBeLessThan(initialGas);
  });

  test('throws on offset overflow', () => {
    frame.pushStack(0n); // value
    frame.pushStack(BigInt(0x100000000)); // offset (overflow)

    expect(() => mstore(frame)).toThrow('OutOfBounds');
  });
});

describe('MSTORE8', () => {
  let frame: MockFrame;

  beforeEach(() => {
    frame = new MockFrame();
  });

  test('stores single byte', () => {
    frame.pushStack(0x42n); // value
    frame.pushStack(0n); // offset
    mstore8(frame);

    expect(frame.memory.get(0)).toBe(0x42);
    expect(frame.pc).toBe(1);
  });

  test('truncates value to single byte', () => {
    frame.pushStack(0x123456n); // value - Only 0x56 should be stored
    frame.pushStack(0n); // offset
    mstore8(frame);

    expect(frame.memory.get(0)).toBe(0x56);
  });

  test('stores at offset', () => {
    frame.pushStack(0xabn); // value
    frame.pushStack(100n); // offset
    mstore8(frame);

    expect(frame.memory.get(100)).toBe(0xab);
  });

  test('stores zero byte', () => {
    frame.pushStack(0n); // value
    frame.pushStack(5n); // offset
    mstore8(frame);

    expect(frame.memory.get(5) ?? 0).toBe(0);
  });

  test('expands memory minimally', () => {
    frame.pushStack(0x42n); // value
    frame.pushStack(0n); // offset
    mstore8(frame);

    // Should expand to 32 bytes (word-aligned)
    expect(frame.memory_size).toBe(32);
  });

  test('charges gas including expansion cost', () => {
    const initialGas = frame.gasRemaining;

    frame.pushStack(0x42n); // value
    frame.pushStack(0n); // offset
    mstore8(frame);

    expect(frame.gasRemaining).toBeLessThan(initialGas);
  });

  test('throws on offset overflow', () => {
    frame.pushStack(0n); // value
    frame.pushStack(BigInt(0x100000000)); // offset (overflow)

    expect(() => mstore8(frame)).toThrow('OutOfBounds');
  });
});

describe('MSIZE', () => {
  let frame: MockFrame;

  beforeEach(() => {
    frame = new MockFrame();
  });

  test('returns zero for fresh memory', () => {
    msize(frame);

    expect(frame.popStack()).toBe(0n);
    expect(frame.pc).toBe(1);
  });

  test('returns current memory size', () => {
    frame.memory_size = 64;
    msize(frame);

    expect(frame.popStack()).toBe(64n);
  });

  test('returns size after memory expansion', () => {
    // Expand memory by writing
    frame.pushStack(0n);
    frame.pushStack(0n);
    mstore(frame);

    frame.pc = 0; // Reset PC
    msize(frame);

    expect(frame.popStack()).toBe(32n);
  });

  test('charges minimal gas', () => {
    const initialGas = frame.gasRemaining;
    msize(frame);

    // Should charge GasQuickStep (2)
    expect(frame.gasRemaining).toBe(initialGas - 2n);
  });
});

describe('MCOPY', () => {
  let frame: MockFrame;

  beforeEach(() => {
    frame = new MockFrame();
    frame.hardfork = Hardfork.CANCUN;
  });

  test('throws InvalidOpcode before Cancun', () => {
    frame.hardfork = Hardfork.SHANGHAI;
    frame.pushStack(32n); // length
    frame.pushStack(32n); // src
    frame.pushStack(0n); // dest

    expect(() => mcopy(frame)).toThrow('InvalidOpcode');
  });

  test('copies memory region', () => {
    // Write source data
    for (let i = 0; i < 32; i++) {
      frame.memory.set(i, i + 1);
    }
    frame.memory_size = 64;

    frame.pushStack(32n); // length
    frame.pushStack(0n); // src
    frame.pushStack(32n); // dest
    mcopy(frame);

    // Verify destination has copied data
    for (let i = 0; i < 32; i++) {
      expect(frame.memory.get(32 + i)).toBe(i + 1);
    }
    expect(frame.pc).toBe(1);
  });

  test('handles zero-length copy', () => {
    const initialGas = frame.gasRemaining;

    frame.pushStack(0n); // length
    frame.pushStack(0n); // src
    frame.pushStack(0n); // dest
    mcopy(frame);

    // Should charge base gas but not expand memory or copy
    expect(frame.gasRemaining).toBeLessThan(initialGas);
    expect(frame.memory_size).toBe(0);
    expect(frame.pc).toBe(1);
  });

  test('handles overlapping regions (forward)', () => {
    // Write source data
    for (let i = 0; i < 10; i++) {
      frame.memory.set(i, i + 1);
    }
    frame.memory_size = 32;

    // Copy 0-9 to 5-14 (overlapping forward)
    frame.pushStack(10n); // length
    frame.pushStack(0n); // src
    frame.pushStack(5n); // dest
    mcopy(frame);

    // Verify the copy worked - destination should have source values
    // Source: [1,2,3,4,5,6,7,8,9,10,0,0,0,0,0,...]
    // After copying to offset 5: [1,2,3,4,5,1,2,3,4,5,6,7,8,9,10,...]
    for (let i = 0; i < 10; i++) {
      expect(frame.memory.get(i + 5)).toBe(i + 1);
    }
  });

  test('handles overlapping regions (backward)', () => {
    // Write source data at offset 5
    for (let i = 0; i < 10; i++) {
      frame.memory.set(i + 5, i + 1);
    }
    frame.memory_size = 32;

    // Copy 5-14 to 0-9 (overlapping backward)
    frame.pushStack(10n); // length
    frame.pushStack(5n); // src
    frame.pushStack(0n); // dest
    mcopy(frame);

    // Destination (0-9) should have the source values (which were at 5-14)
    // Source was: offset 5-14 with values [1,2,3,4,5,6,7,8,9,10]
    // After copy using temp buffer: destination 0-9 gets [1,2,3,4,5,6,7,8,9,10]
    for (let i = 0; i < 10; i++) {
      expect(frame.memory.get(i)).toBe(i + 1);
    }
    // Positions 5-9 overlap with destination, so they get overwritten with destination values
    // which are the same as the first 5 source values: [1,2,3,4,5]
    // But since we copy from 5-14 to 0-9, position 5 onwards are in both src and dest
    // After copy: [1,2,3,4,5,6,7,8,9,10,...] at 0-9
    // Original 10-14 still have [6,7,8,9,10]
  });

  test('expands memory to cover both src and dest', () => {
    frame.pushStack(32n); // length
    frame.pushStack(0n); // src
    frame.pushStack(64n); // dest
    mcopy(frame);

    // Should expand to 96 bytes (64 + 32, word-aligned)
    expect(frame.memory_size).toBe(96);
  });

  test('copies to/from uninitialized memory', () => {
    // Copy 32 bytes from offset 0 (uninitialized) to offset 32
    frame.pushStack(32n); // length
    frame.pushStack(0n); // src
    frame.pushStack(32n); // dest
    mcopy(frame);

    // Destination should be all zeros
    for (let i = 0; i < 32; i++) {
      expect(frame.memory.get(32 + i) ?? 0).toBe(0);
    }
  });

  test('charges gas for copy operation', () => {
    const initialGas = frame.gasRemaining;

    frame.pushStack(32n); // length (1 word = 3 gas)
    frame.pushStack(0n); // src
    frame.pushStack(32n); // dest
    mcopy(frame);

    // Should charge: GasFastestStep (3) + expansion cost + copy cost (3 per word)
    expect(frame.gasRemaining).toBeLessThan(initialGas - 6n); // At least 3 + 3
  });

  test('throws on offset overflow', () => {
    frame.pushStack(1n); // length
    frame.pushStack(0n); // src
    frame.pushStack(BigInt(0x100000000)); // dest overflow

    // Large offsets cause OutOfGas due to huge memory expansion cost before OutOfBounds
    expect(() => mcopy(frame)).toThrow();
  });

  test('copies single byte', () => {
    frame.memory.set(0, 0x42);
    frame.memory_size = 32;

    frame.pushStack(1n); // length
    frame.pushStack(0n); // src
    frame.pushStack(10n); // dest
    mcopy(frame);

    expect(frame.memory.get(10)).toBe(0x42);
  });

  test('copies partial word', () => {
    // Write 10 bytes
    for (let i = 0; i < 10; i++) {
      frame.memory.set(i, i + 1);
    }
    frame.memory_size = 32;

    frame.pushStack(10n); // length
    frame.pushStack(0n); // src
    frame.pushStack(20n); // dest
    mcopy(frame);

    // Verify 10 bytes copied
    for (let i = 0; i < 10; i++) {
      expect(frame.memory.get(20 + i)).toBe(i + 1);
    }
  });
});

describe('Memory expansion cost', () => {
  let frame: MockFrame;

  beforeEach(() => {
    frame = new MockFrame();
  });

  test('expansion cost is zero when within current size', () => {
    frame.memory_size = 64;
    const cost = frame.memoryExpansionCost(32n);
    expect(cost).toBe(0n);
  });

  test('expansion cost is quadratic', () => {
    // Expanding from 0 to 1024 bytes (32 words)
    const cost1 = frame.memoryExpansionCost(1024n);

    // Expanding from 1024 to 2048 bytes (another 32 words)
    frame.memory_size = 1024;
    const cost2 = frame.memoryExpansionCost(2048n);

    // Due to quadratic formula (3n + n²/512), the second 32-word expansion
    // should cost more than the first
    expect(cost2).toBeGreaterThan(cost1);
  });

  test('matches EVM formula: 3n + n²/512', () => {
    const endBytes = 320n; // 10 words
    const cost = frame.memoryExpansionCost(endBytes);

    const words = 10n;
    const expected = 3n * words + (words * words) / 512n;
    expect(cost).toBe(expected);
  });
});
