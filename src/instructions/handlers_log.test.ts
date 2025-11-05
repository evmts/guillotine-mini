import { describe, expect, test, beforeEach } from 'bun:test';
import {
  log0,
  log1,
  log2,
  log3,
  log4,
  logGasCost,
  wordCount,
  wordAlignedSize,
  GasConstants,
  type FrameInterface,
  type EvmInterface,
  type Address,
  type Log,
} from './handlers_log';
import { CallError, EvmError } from '../errors';

/**
 * Mock EVM implementation for testing
 */
class MockEvm implements EvmInterface {
  logs: Log[] = [];

  reset(): void {
    this.logs = [];
  }
}

/**
 * Mock Frame implementation for testing
 */
class MockFrame implements FrameInterface {
  stack: bigint[] = [];
  memory: Map<number, number> = new Map();
  memory_size: number = 0;
  pc: number = 0;
  gas_remaining: bigint = 1000000n;
  is_static: boolean = false;
  address: Address = new Uint8Array(20).fill(0x42); // Mock address
  evm: MockEvm = new MockEvm();

  consumeGas(amount: bigint): void {
    if (amount > this.gas_remaining) {
      throw new EvmError(CallError.OutOfGas);
    }
    this.gas_remaining -= amount;
  }

  popStack(): bigint {
    if (this.stack.length === 0) {
      throw new EvmError(CallError.StackUnderflow);
    }
    return this.stack.pop()!;
  }

  pushStack(value: bigint): void {
    if (this.stack.length >= 1024) {
      throw new EvmError(CallError.StackOverflow);
    }
    this.stack.push(value);
  }

  readMemory(offset: number): number {
    return this.memory.get(offset) ?? 0;
  }

  writeMemory(offset: number, value: number): void {
    this.memory.set(offset, value & 0xff);
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

  getEvm(): EvmInterface {
    return this.evm;
  }

  reset(): void {
    this.stack = [];
    this.memory = new Map();
    this.memory_size = 0;
    this.pc = 0;
    this.gas_remaining = 1000000n;
    this.is_static = false;
    this.evm.reset();
  }
}

describe('Gas calculation helpers', () => {
  test('logGasCost calculates correctly for LOG0', () => {
    expect(logGasCost(0, 0)).toBe(375n);
    expect(logGasCost(0, 32)).toBe(375n + 8n * 32n);
  });

  test('logGasCost calculates correctly for LOG1', () => {
    expect(logGasCost(1, 0)).toBe(375n + 375n);
    expect(logGasCost(1, 32)).toBe(375n + 375n + 8n * 32n);
  });

  test('logGasCost calculates correctly for LOG4', () => {
    expect(logGasCost(4, 0)).toBe(375n + 4n * 375n);
    expect(logGasCost(4, 100)).toBe(375n + 4n * 375n + 8n * 100n);
  });

  test('wordCount rounds up correctly', () => {
    expect(wordCount(0n)).toBe(0n);
    expect(wordCount(1n)).toBe(1n);
    expect(wordCount(31n)).toBe(1n);
    expect(wordCount(32n)).toBe(1n);
    expect(wordCount(33n)).toBe(2n);
    expect(wordCount(64n)).toBe(2n);
  });

  test('wordAlignedSize aligns to 32-byte boundaries', () => {
    expect(wordAlignedSize(0n)).toBe(0);
    expect(wordAlignedSize(1n)).toBe(32);
    expect(wordAlignedSize(31n)).toBe(32);
    expect(wordAlignedSize(32n)).toBe(32);
    expect(wordAlignedSize(33n)).toBe(64);
    expect(wordAlignedSize(64n)).toBe(64);
    expect(wordAlignedSize(65n)).toBe(96);
  });
});

describe('LOG0', () => {
  let frame: MockFrame;

  beforeEach(() => {
    frame = new MockFrame();
  });

  test('emits log with no topics and no data', () => {
    frame.pushStack(0n); // length
    frame.pushStack(0n); // offset

    log0(frame);

    expect(frame.pc).toBe(1);
    expect(frame.evm.logs.length).toBe(1);
    expect(frame.evm.logs[0].topics.length).toBe(0);
    expect(frame.evm.logs[0].data.length).toBe(0);
    expect(frame.evm.logs[0].address).toEqual(frame.address);
  });

  test('emits log with data from memory', () => {
    // Write test data to memory
    const testData = new Uint8Array([0x01, 0x02, 0x03, 0x04]);
    for (let i = 0; i < testData.length; i++) {
      frame.writeMemory(i, testData[i]);
    }

    frame.pushStack(BigInt(testData.length)); // length
    frame.pushStack(0n); // offset

    log0(frame);

    expect(frame.evm.logs.length).toBe(1);
    expect(frame.evm.logs[0].data).toEqual(testData);
    expect(frame.evm.logs[0].topics.length).toBe(0);
  });

  test('charges correct gas for zero-length data', () => {
    const initialGas = frame.gas_remaining;
    frame.pushStack(0n); // length
    frame.pushStack(0n); // offset

    log0(frame);

    const expectedGas = GasConstants.LogGas;
    expect(frame.gas_remaining).toBe(initialGas - expectedGas);
  });

  test('charges correct gas for data', () => {
    const initialGas = frame.gas_remaining;
    const dataSize = 32;

    frame.pushStack(BigInt(dataSize)); // length
    frame.pushStack(0n); // offset

    log0(frame);

    const expectedGas = GasConstants.LogGas + GasConstants.LogDataGas * BigInt(dataSize);
    // Memory expansion: 0 -> 32 bytes = 1 word
    const memExpansion = 3n; // 3 * 1 + 1²/512 = 3
    expect(frame.gas_remaining).toBe(initialGas - expectedGas - memExpansion);
  });

  test('throws StaticCallViolation in static context', () => {
    frame.is_static = true;
    frame.pushStack(0n); // length
    frame.pushStack(0n); // offset

    try {
      log0(frame);
      expect(true).toBe(false); // Should not reach here
    } catch (e) {
      expect(e).toBeInstanceOf(EvmError);
      expect((e as EvmError).errorType).toBe(CallError.StaticCallViolation);
    }
  });

  test('throws OutOfGas when insufficient gas', () => {
    frame.gas_remaining = 100n; // Less than LOG base cost (375)
    frame.pushStack(0n); // length
    frame.pushStack(0n); // offset

    try {
      log0(frame);
      expect(true).toBe(false); // Should not reach here
    } catch (e) {
      expect(e).toBeInstanceOf(EvmError);
      expect((e as EvmError).errorType).toBe(CallError.OutOfGas);
    }
  });

  test('expands memory correctly', () => {
    expect(frame.memory_size).toBe(0);

    frame.pushStack(64n); // length
    frame.pushStack(0n); // offset

    log0(frame);

    expect(frame.memory_size).toBe(64); // Word-aligned to 64 bytes (2 words)
  });
});

describe('LOG1', () => {
  let frame: MockFrame;

  beforeEach(() => {
    frame = new MockFrame();
  });

  test('emits log with 1 topic', () => {
    const topic = 0x1234567890abcdefn;

    frame.pushStack(topic); // topic0
    frame.pushStack(0n); // length
    frame.pushStack(0n); // offset

    log1(frame);

    expect(frame.evm.logs.length).toBe(1);
    expect(frame.evm.logs[0].topics.length).toBe(1);
    expect(frame.evm.logs[0].topics[0]).toBe(topic);
    expect(frame.evm.logs[0].data.length).toBe(0);
  });

  test('charges correct gas for 1 topic', () => {
    const initialGas = frame.gas_remaining;

    frame.pushStack(0xffffffffffffffffn); // topic0
    frame.pushStack(0n); // length
    frame.pushStack(0n); // offset

    log1(frame);

    const expectedGas = GasConstants.LogGas + GasConstants.LogTopicGas;
    expect(frame.gas_remaining).toBe(initialGas - expectedGas);
  });

  test('emits log with topic and data', () => {
    const topic = 0xabcdefn;
    const testData = new Uint8Array([0xde, 0xad, 0xbe, 0xef]);

    for (let i = 0; i < testData.length; i++) {
      frame.writeMemory(i, testData[i]);
    }

    frame.pushStack(topic); // topic0
    frame.pushStack(BigInt(testData.length)); // length
    frame.pushStack(0n); // offset

    log1(frame);

    expect(frame.evm.logs[0].topics[0]).toBe(topic);
    expect(frame.evm.logs[0].data).toEqual(testData);
  });
});

describe('LOG2', () => {
  let frame: MockFrame;

  beforeEach(() => {
    frame = new MockFrame();
  });

  test('emits log with 2 topics', () => {
    const topic0 = 0x1111111111111111n;
    const topic1 = 0x2222222222222222n;

    frame.pushStack(topic1); // topic1 (popped second)
    frame.pushStack(topic0); // topic0 (popped first)
    frame.pushStack(0n); // length
    frame.pushStack(0n); // offset

    log2(frame);

    expect(frame.evm.logs[0].topics.length).toBe(2);
    expect(frame.evm.logs[0].topics[0]).toBe(topic0);
    expect(frame.evm.logs[0].topics[1]).toBe(topic1);
  });

  test('charges correct gas for 2 topics', () => {
    const initialGas = frame.gas_remaining;

    frame.pushStack(0n); // topic1
    frame.pushStack(0n); // topic0
    frame.pushStack(0n); // length
    frame.pushStack(0n); // offset

    log2(frame);

    const expectedGas = GasConstants.LogGas + 2n * GasConstants.LogTopicGas;
    expect(frame.gas_remaining).toBe(initialGas - expectedGas);
  });
});

describe('LOG3', () => {
  let frame: MockFrame;

  beforeEach(() => {
    frame = new MockFrame();
  });

  test('emits log with 3 topics', () => {
    const topic0 = 0x1111n;
    const topic1 = 0x2222n;
    const topic2 = 0x3333n;

    frame.pushStack(topic2); // topic2
    frame.pushStack(topic1); // topic1
    frame.pushStack(topic0); // topic0
    frame.pushStack(0n); // length
    frame.pushStack(0n); // offset

    log3(frame);

    expect(frame.evm.logs[0].topics.length).toBe(3);
    expect(frame.evm.logs[0].topics[0]).toBe(topic0);
    expect(frame.evm.logs[0].topics[1]).toBe(topic1);
    expect(frame.evm.logs[0].topics[2]).toBe(topic2);
  });

  test('charges correct gas for 3 topics', () => {
    const initialGas = frame.gas_remaining;

    frame.pushStack(0n); // topic2
    frame.pushStack(0n); // topic1
    frame.pushStack(0n); // topic0
    frame.pushStack(0n); // length
    frame.pushStack(0n); // offset

    log3(frame);

    const expectedGas = GasConstants.LogGas + 3n * GasConstants.LogTopicGas;
    expect(frame.gas_remaining).toBe(initialGas - expectedGas);
  });
});

describe('LOG4', () => {
  let frame: MockFrame;

  beforeEach(() => {
    frame = new MockFrame();
  });

  test('emits log with 4 topics', () => {
    const topic0 = 0x1111n;
    const topic1 = 0x2222n;
    const topic2 = 0x3333n;
    const topic3 = 0x4444n;

    frame.pushStack(topic3); // topic3
    frame.pushStack(topic2); // topic2
    frame.pushStack(topic1); // topic1
    frame.pushStack(topic0); // topic0
    frame.pushStack(0n); // length
    frame.pushStack(0n); // offset

    log4(frame);

    expect(frame.evm.logs[0].topics.length).toBe(4);
    expect(frame.evm.logs[0].topics[0]).toBe(topic0);
    expect(frame.evm.logs[0].topics[1]).toBe(topic1);
    expect(frame.evm.logs[0].topics[2]).toBe(topic2);
    expect(frame.evm.logs[0].topics[3]).toBe(topic3);
  });

  test('charges correct gas for 4 topics', () => {
    const initialGas = frame.gas_remaining;

    frame.pushStack(0n); // topic3
    frame.pushStack(0n); // topic2
    frame.pushStack(0n); // topic1
    frame.pushStack(0n); // topic0
    frame.pushStack(0n); // length
    frame.pushStack(0n); // offset

    log4(frame);

    const expectedGas = GasConstants.LogGas + 4n * GasConstants.LogTopicGas;
    expect(frame.gas_remaining).toBe(initialGas - expectedGas);
  });

  test('emits log with max topics and large data', () => {
    const topics = [0x1111n, 0x2222n, 0x3333n, 0x4444n];
    const dataSize = 256;

    // Write test data
    for (let i = 0; i < dataSize; i++) {
      frame.writeMemory(i, i % 256);
    }

    // Push topics in reverse order
    for (let i = topics.length - 1; i >= 0; i--) {
      frame.pushStack(topics[i]);
    }
    frame.pushStack(BigInt(dataSize)); // length
    frame.pushStack(0n); // offset

    log4(frame);

    expect(frame.evm.logs[0].topics.length).toBe(4);
    expect(frame.evm.logs[0].data.length).toBe(dataSize);
    for (let i = 0; i < topics.length; i++) {
      expect(frame.evm.logs[0].topics[i]).toBe(topics[i]);
    }
  });
});

describe('LOG memory edge cases', () => {
  let frame: MockFrame;

  beforeEach(() => {
    frame = new MockFrame();
  });

  test('reads from uninitialized memory (returns zeros)', () => {
    frame.pushStack(32n); // length
    frame.pushStack(0n); // offset

    log0(frame);

    expect(frame.evm.logs[0].data.length).toBe(32);
    expect(frame.evm.logs[0].data.every(b => b === 0)).toBe(true);
  });

  test('handles memory offset correctly', () => {
    const offset = 64;
    const testData = new Uint8Array([0xff, 0xee, 0xdd, 0xcc]);

    // Write data at offset
    for (let i = 0; i < testData.length; i++) {
      frame.writeMemory(offset + i, testData[i]);
    }

    frame.pushStack(BigInt(testData.length)); // length
    frame.pushStack(BigInt(offset)); // offset

    log0(frame);

    expect(frame.evm.logs[0].data).toEqual(testData);
  });

  test('throws OutOfBounds when offset exceeds u32', () => {
    frame.pushStack(0n); // length
    frame.pushStack(0x100000000n); // offset > u32::MAX

    try {
      log0(frame);
      expect(true).toBe(false); // Should not reach here
    } catch (e) {
      expect(e).toBeInstanceOf(EvmError);
      expect((e as EvmError).errorType).toBe(CallError.OutOfBounds);
    }
  });

  test('throws OutOfBounds when length exceeds u32', () => {
    frame.pushStack(0x100000000n); // length > u32::MAX
    frame.pushStack(0n); // offset

    try {
      log0(frame);
      expect(true).toBe(false); // Should not reach here
    } catch (e) {
      expect(e).toBeInstanceOf(EvmError);
      expect((e as EvmError).errorType).toBe(CallError.OutOfBounds);
    }
  });
});

describe('LOG multiple emissions', () => {
  let frame: MockFrame;

  beforeEach(() => {
    frame = new MockFrame();
  });

  test('accumulates multiple logs', () => {
    // Emit LOG0
    frame.pushStack(0n);
    frame.pushStack(0n);
    log0(frame);

    // Emit LOG1
    frame.pc = 0;
    frame.pushStack(0xaaaaaaaan);
    frame.pushStack(0n);
    frame.pushStack(0n);
    log1(frame);

    // Emit LOG2
    frame.pc = 0;
    frame.pushStack(0xbbbbbbbn);
    frame.pushStack(0xcccccccn);
    frame.pushStack(0n);
    frame.pushStack(0n);
    log2(frame);

    expect(frame.evm.logs.length).toBe(3);
    expect(frame.evm.logs[0].topics.length).toBe(0);
    expect(frame.evm.logs[1].topics.length).toBe(1);
    expect(frame.evm.logs[2].topics.length).toBe(2);
  });

  test('each log has correct address', () => {
    frame.pushStack(0n);
    frame.pushStack(0n);
    log0(frame);

    frame.pc = 0;
    frame.pushStack(0n);
    frame.pushStack(0n);
    frame.pushStack(0n);
    log1(frame);

    expect(frame.evm.logs[0].address).toEqual(frame.address);
    expect(frame.evm.logs[1].address).toEqual(frame.address);
  });
});

describe('LOG gas metering edge cases', () => {
  let frame: MockFrame;

  beforeEach(() => {
    frame = new MockFrame();
  });

  test('charges gas before memory expansion', () => {
    // Set gas just enough for LOG cost but not memory expansion
    const dataSize = 32;
    const logCost = GasConstants.LogGas + GasConstants.LogDataGas * BigInt(dataSize);
    const memExpansion = 3n; // 1 word expansion
    const totalCost = logCost + memExpansion;

    frame.gas_remaining = totalCost;
    frame.pushStack(BigInt(dataSize));
    frame.pushStack(0n);

    // Should succeed with exact gas
    log0(frame);
    expect(frame.gas_remaining).toBe(0n);
  });

  test('throws OutOfGas during memory expansion', () => {
    // Start with 0 memory
    expect(frame.memory_size).toBe(0);

    const dataSize = 256; // Use larger size for clearer memory expansion cost
    const logCost = GasConstants.LogGas + GasConstants.LogDataGas * BigInt(dataSize);

    // Calculate expected memory expansion cost for 256 bytes (8 words)
    // Cost = 3 * 8 + 8²/512 = 24 + 0.125 = 24 (integer division)
    const memCost = frame.memoryExpansionCost(BigInt(dataSize));

    // Set gas to only cover LOG cost, not memory expansion
    frame.gas_remaining = logCost;

    // Stack is LIFO, so push in reverse order: length, then offset
    frame.pushStack(BigInt(dataSize)); // length (will be popped second)
    frame.pushStack(0n); // offset (will be popped first)

    try {
      log0(frame);
      expect(true).toBe(false); // Should not reach here
    } catch (e) {
      expect(e).toBeInstanceOf(EvmError);
      expect((e as EvmError).errorType).toBe(CallError.OutOfGas);
    }
  });
});
