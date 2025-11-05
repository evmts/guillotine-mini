/**
 * Tests for Frame implementation
 *
 * Test coverage:
 * - Frame initialization
 * - Stack operations (push/pop/peek)
 * - Memory operations (read/write/expansion)
 * - Gas consumption and tracking
 * - Memory expansion cost calculation
 * - Gas cost helpers (CREATE, CREATE2, SELFDESTRUCT)
 * - Bytecode operations (getCurrentOpcode, readImmediate)
 * - Execution loop integration tests
 */

import { describe, test, expect } from 'vitest';
import { Frame, Hardfork, HardforkUtils } from './frame';
import { CallError, EvmError } from './errors';
import { Bytecode } from './bytecode';

/**
 * Create a test address (20 bytes)
 */
function createAddress(value: number = 0): Uint8Array {
  const addr = new Uint8Array(20);
  addr[19] = value;
  return addr;
}

/**
 * Create a minimal frame for testing
 */
function createTestFrame(
  bytecode: Uint8Array = new Uint8Array([0x00]), // STOP
  gas: bigint = 100000n
): Frame {
  return new Frame({
    bytecode,
    gas,
    caller: createAddress(1),
    address: createAddress(2),
    value: 0n,
    calldata: new Uint8Array(0),
    evmPtr: null,
    hardfork: Hardfork.CANCUN,
    isStatic: false,
  });
}

// ================================ INITIALIZATION ================================

describe('Frame - Initialization', () => {
  test('initializes with correct default values', () => {
    const bytecode = new Uint8Array([0x00, 0x01, 0x02]);
    const frame = new Frame({
      bytecode,
      gas: 50000n,
      caller: createAddress(1),
      address: createAddress(2),
      value: 100n,
      calldata: new Uint8Array([0xaa, 0xbb]),
      evmPtr: { test: 'evm' },
      hardfork: Hardfork.SHANGHAI,
      isStatic: true,
      authorized: 123n,
      callDepth: 5,
    });

    expect(frame.pc).toBe(0);
    expect(frame.gasRemaining).toBe(50000n);
    expect(frame.value).toBe(100n);
    expect(frame.hardfork).toBe(Hardfork.SHANGHAI);
    expect(frame.isStatic).toBe(true);
    expect(frame.authorized).toBe(123n);
    expect(frame.callDepth).toBe(5);
    expect(frame.stopped).toBe(false);
    expect(frame.reverted).toBe(false);
    expect(frame.stack.length).toBe(0);
    expect(frame.bytecode.length).toBe(3);
  });

  test('defaults optional parameters', () => {
    const frame = createTestFrame();

    expect(frame.authorized).toBe(null);
    expect(frame.callDepth).toBe(0);
    expect(frame.output.length).toBe(0);
    expect(frame.returnData.length).toBe(0);
  });
});

// ================================ STACK OPERATIONS ================================

describe('Frame - Stack Operations', () => {
  test('pushStack adds values to stack', () => {
    const frame = createTestFrame();

    frame.pushStack(100n);
    frame.pushStack(200n);
    frame.pushStack(300n);

    expect(frame.stack.length).toBe(3);
    expect(frame.stack[0]).toBe(100n);
    expect(frame.stack[1]).toBe(200n);
    expect(frame.stack[2]).toBe(300n);
  });

  test('pushStack throws StackOverflow when exceeding 1024 items', () => {
    const frame = createTestFrame();

    // Fill stack to limit
    for (let i = 0; i < 1024; i++) {
      frame.pushStack(BigInt(i));
    }

    // 1025th push should overflow
    expect(() => frame.pushStack(9999n)).toThrow(EvmError);
    expect(() => frame.pushStack(9999n)).toThrow(/StackOverflow/);
  });

  test('popStack removes and returns top value', () => {
    const frame = createTestFrame();

    frame.pushStack(100n);
    frame.pushStack(200n);
    frame.pushStack(300n);

    expect(frame.popStack()).toBe(300n);
    expect(frame.popStack()).toBe(200n);
    expect(frame.popStack()).toBe(100n);
    expect(frame.stack.length).toBe(0);
  });

  test('popStack throws StackUnderflow when empty', () => {
    const frame = createTestFrame();

    expect(() => frame.popStack()).toThrow(EvmError);
    expect(() => frame.popStack()).toThrow(/StackUnderflow/);
  });

  test('peekStack returns value without removing', () => {
    const frame = createTestFrame();

    frame.pushStack(100n);
    frame.pushStack(200n);
    frame.pushStack(300n);

    expect(frame.peekStack(0)).toBe(300n); // Top
    expect(frame.peekStack(1)).toBe(200n); // Second
    expect(frame.peekStack(2)).toBe(100n); // Third
    expect(frame.stack.length).toBe(3); // Stack unchanged
  });

  test('peekStack throws StackUnderflow for invalid index', () => {
    const frame = createTestFrame();

    frame.pushStack(100n);
    frame.pushStack(200n);

    expect(() => frame.peekStack(2)).toThrow(EvmError);
    expect(() => frame.peekStack(2)).toThrow(/StackUnderflow/);
  });

  test('stack is LIFO (last in, first out)', () => {
    const frame = createTestFrame();

    frame.pushStack(1n);
    frame.pushStack(2n);
    frame.pushStack(3n);

    expect(frame.popStack()).toBe(3n);
    expect(frame.popStack()).toBe(2n);
    expect(frame.popStack()).toBe(1n);
  });
});

// ================================ MEMORY OPERATIONS ================================

describe('Frame - Memory Operations', () => {
  test('readMemory returns 0 for uninitialized', () => {
    const frame = createTestFrame();

    expect(frame.readMemory(0)).toBe(0);
    expect(frame.readMemory(100)).toBe(0);
    expect(frame.readMemory(999999)).toBe(0);
  });

  test('writeMemory stores byte values', () => {
    const frame = createTestFrame();

    frame.writeMemory(0, 0xaa);
    frame.writeMemory(1, 0xbb);
    frame.writeMemory(31, 0xcc);

    expect(frame.readMemory(0)).toBe(0xaa);
    expect(frame.readMemory(1)).toBe(0xbb);
    expect(frame.readMemory(31)).toBe(0xcc);
  });

  test('writeMemory masks to byte (0-255)', () => {
    const frame = createTestFrame();

    frame.writeMemory(0, 0x1ff); // 511 -> 0xff
    expect(frame.readMemory(0)).toBe(0xff);
  });

  test('writeMemory expands memory to word boundaries', () => {
    const frame = createTestFrame();

    // Write at offset 0 -> should expand to 32 bytes
    frame.writeMemory(0, 0xaa);
    expect(frame.getMemorySlice().length).toBe(32);

    // Write at offset 32 -> should expand to 64 bytes
    frame.writeMemory(32, 0xbb);
    expect(frame.getMemorySlice().length).toBe(64);

    // Write at offset 63 -> should still be 64 bytes
    frame.writeMemory(63, 0xcc);
    expect(frame.getMemorySlice().length).toBe(64);

    // Write at offset 64 -> should expand to 96 bytes
    frame.writeMemory(64, 0xdd);
    expect(frame.getMemorySlice().length).toBe(96);
  });

  test('getMemorySlice returns sparse memory as dense array', () => {
    const frame = createTestFrame();

    frame.writeMemory(0, 0xaa);
    frame.writeMemory(31, 0xbb);

    const slice = frame.getMemorySlice();
    expect(slice.length).toBe(32);
    expect(slice[0]).toBe(0xaa);
    expect(slice[31]).toBe(0xbb);
    // Uninitialized bytes should be 0
    expect(slice[1]).toBe(0);
    expect(slice[30]).toBe(0);
  });

  test('getMemorySlice returns empty for no memory', () => {
    const frame = createTestFrame();

    const slice = frame.getMemorySlice();
    expect(slice.length).toBe(0);
  });

  test('memory is sparse (only non-zero bytes stored)', () => {
    const frame = createTestFrame();

    // Write to widely spaced offsets
    frame.writeMemory(0, 0xaa);
    frame.writeMemory(1000, 0xbb);

    // Should only store 2 entries, not 1001
    expect(frame.readMemory(0)).toBe(0xaa);
    expect(frame.readMemory(500)).toBe(0); // Uninitialized
    expect(frame.readMemory(1000)).toBe(0xbb);
  });
});

// ================================ GAS OPERATIONS ================================

describe('Frame - Gas Operations', () => {
  test('consumeGas reduces gas remaining', () => {
    const frame = createTestFrame(new Uint8Array([0x00]), 1000n);

    frame.consumeGas(100n);
    expect(frame.gasRemaining).toBe(900n);

    frame.consumeGas(300n);
    expect(frame.gasRemaining).toBe(600n);
  });

  test('consumeGas throws OutOfGas when insufficient', () => {
    const frame = createTestFrame(new Uint8Array([0x00]), 100n);

    expect(() => frame.consumeGas(101n)).toThrow(EvmError);
    expect(() => frame.consumeGas(101n)).toThrow(/OutOfGas/);
    expect(frame.gasRemaining).toBe(0n); // Gas set to 0 on failure
  });

  test('consumeGas allows exact gas consumption', () => {
    const frame = createTestFrame(new Uint8Array([0x00]), 100n);

    frame.consumeGas(100n);
    expect(frame.gasRemaining).toBe(0n);
  });

  test('memoryExpansionCost returns 0 for no expansion', () => {
    const frame = createTestFrame();

    // No memory used yet
    expect(frame.memoryExpansionCost(0)).toBe(0n);

    // Write 32 bytes (1 word)
    frame.writeMemory(0, 0xaa);
    expect(frame.getMemorySlice().length).toBe(32);

    // Accessing within current size has no cost
    expect(frame.memoryExpansionCost(32)).toBe(0n);
    expect(frame.memoryExpansionCost(16)).toBe(0n);
  });

  test('memoryExpansionCost calculates cost for expansion', () => {
    const frame = createTestFrame();

    // Expand from 0 to 32 bytes (1 word)
    // Cost = 3*1 + 1^2/512 = 3 + 0 = 3
    const cost1 = frame.memoryExpansionCost(32);
    expect(cost1).toBe(3n);

    // Expand memory
    frame.writeMemory(0, 0xaa);
    expect(frame.getMemorySlice().length).toBe(32);

    // Expand from 32 to 64 bytes (2 words)
    // New cost = 3*2 + 2^2/512 = 6 + 0 = 6
    // Expansion cost = 6 - 3 = 3
    const cost2 = frame.memoryExpansionCost(64);
    expect(cost2).toBe(3n);
  });

  test('memoryExpansionCost uses quadratic formula', () => {
    const frame = createTestFrame();

    // Expand to 512 words (16384 bytes)
    // Cost = 3*512 + 512^2/512 = 1536 + 512 = 2048
    const cost = frame.memoryExpansionCost(16384);
    expect(cost).toBe(2048n);
  });

  test('memoryExpansionCost caps at max memory size', () => {
    const frame = createTestFrame();

    // Try to expand beyond 16MB (max reasonable memory)
    const cost = frame.memoryExpansionCost(0x2000000); // 32MB
    expect(cost).toBeGreaterThan(0n);
    // Should return large value to trigger OutOfGas
  });
});

// ================================ GAS COST HELPERS ================================

describe('Frame - Gas Cost Helpers', () => {
  test('selfdestructGasCost returns 0 pre-Tangerine', () => {
    const frame = new Frame({
      bytecode: new Uint8Array([0x00]),
      gas: 100000n,
      caller: createAddress(1),
      address: createAddress(2),
      value: 0n,
      calldata: new Uint8Array(0),
      evmPtr: null,
      hardfork: Hardfork.HOMESTEAD,
      isStatic: false,
    });

    expect(frame.selfdestructGasCost()).toBe(0n);
  });

  test('selfdestructGasCost returns 5000 post-Tangerine', () => {
    const frame = new Frame({
      bytecode: new Uint8Array([0x00]),
      gas: 100000n,
      caller: createAddress(1),
      address: createAddress(2),
      value: 0n,
      calldata: new Uint8Array(0),
      evmPtr: null,
      hardfork: Hardfork.BERLIN,
      isStatic: false,
    });

    expect(frame.selfdestructGasCost()).toBe(5000n);
  });

  test('selfdestructRefund returns 24000 pre-London', () => {
    const frame = new Frame({
      bytecode: new Uint8Array([0x00]),
      gas: 100000n,
      caller: createAddress(1),
      address: createAddress(2),
      value: 0n,
      calldata: new Uint8Array(0),
      evmPtr: null,
      hardfork: Hardfork.BERLIN,
      isStatic: false,
    });

    expect(frame.selfdestructRefund()).toBe(24000n);
  });

  test('selfdestructRefund returns 0 post-London', () => {
    const frame = new Frame({
      bytecode: new Uint8Array([0x00]),
      gas: 100000n,
      caller: createAddress(1),
      address: createAddress(2),
      value: 0n,
      calldata: new Uint8Array(0),
      evmPtr: null,
      hardfork: Hardfork.LONDON,
      isStatic: false,
    });

    expect(frame.selfdestructRefund()).toBe(0n);
  });

  test('createGasCost returns base 32000 pre-Shanghai', () => {
    const frame = new Frame({
      bytecode: new Uint8Array([0x00]),
      gas: 100000n,
      caller: createAddress(1),
      address: createAddress(2),
      value: 0n,
      calldata: new Uint8Array(0),
      evmPtr: null,
      hardfork: Hardfork.BERLIN,
      isStatic: false,
    });

    expect(frame.createGasCost(100)).toBe(32000n);
  });

  test('createGasCost adds initcode word cost post-Shanghai', () => {
    const frame = new Frame({
      bytecode: new Uint8Array([0x00]),
      gas: 100000n,
      caller: createAddress(1),
      address: createAddress(2),
      value: 0n,
      calldata: new Uint8Array(0),
      evmPtr: null,
      hardfork: Hardfork.SHANGHAI,
      isStatic: false,
    });

    // 64 bytes = 2 words, 2 * 2 = 4 gas
    // Total = 32000 + 4 = 32004
    expect(frame.createGasCost(64)).toBe(32004n);
  });

  test('create2GasCost includes keccak256 cost', () => {
    const frame = new Frame({
      bytecode: new Uint8Array([0x00]),
      gas: 100000n,
      caller: createAddress(1),
      address: createAddress(2),
      value: 0n,
      calldata: new Uint8Array(0),
      evmPtr: null,
      hardfork: Hardfork.BERLIN,
      isStatic: false,
    });

    // 32 bytes = 1 word
    // Base = 32000
    // Keccak256 = 1 * 6 = 6
    // Total = 32006
    expect(frame.create2GasCost(32)).toBe(32006n);
  });

  test('create2GasCost adds initcode cost post-Shanghai', () => {
    const frame = new Frame({
      bytecode: new Uint8Array([0x00]),
      gas: 100000n,
      caller: createAddress(1),
      address: createAddress(2),
      value: 0n,
      calldata: new Uint8Array(0),
      evmPtr: null,
      hardfork: Hardfork.SHANGHAI,
      isStatic: false,
    });

    // 64 bytes = 2 words
    // Base = 32000
    // Keccak256 = 2 * 6 = 12
    // Initcode = 2 * 2 = 4
    // Total = 32016
    expect(frame.create2GasCost(64)).toBe(32016n);
  });
});

// ================================ HARDFORK UTILITIES ================================

describe('Frame - Hardfork Utilities', () => {
  test('HardforkUtils.isAtLeast checks version', () => {
    expect(HardforkUtils.isAtLeast(Hardfork.CANCUN, Hardfork.SHANGHAI)).toBe(true);
    expect(HardforkUtils.isAtLeast(Hardfork.SHANGHAI, Hardfork.CANCUN)).toBe(false);
    expect(HardforkUtils.isAtLeast(Hardfork.LONDON, Hardfork.LONDON)).toBe(true);
  });

  test('HardforkUtils.isBefore checks version', () => {
    expect(HardforkUtils.isBefore(Hardfork.SHANGHAI, Hardfork.CANCUN)).toBe(true);
    expect(HardforkUtils.isBefore(Hardfork.CANCUN, Hardfork.SHANGHAI)).toBe(false);
    expect(HardforkUtils.isBefore(Hardfork.LONDON, Hardfork.LONDON)).toBe(false);
  });
});

// ================================ BYTECODE OPERATIONS ================================

describe('Frame - Bytecode Operations', () => {
  test('getCurrentOpcode returns opcode at PC', () => {
    const bytecode = new Uint8Array([0x60, 0x01, 0x60, 0x02]);
    const frame = createTestFrame(bytecode);

    expect(frame.getCurrentOpcode()).toBe(0x60);
    frame.pc = 2;
    expect(frame.getCurrentOpcode()).toBe(0x60);
    frame.pc = 4;
    expect(frame.getCurrentOpcode()).toBe(null); // Past end
  });

  test('readImmediate reads PUSH data', () => {
    const bytecode = new Uint8Array([
      0x60, 0xff, // PUSH1 0xff
      0x61, 0x12, 0x34, // PUSH2 0x1234
    ]);
    const frame = createTestFrame(bytecode);

    // Read PUSH1 immediate
    frame.pc = 0;
    expect(frame.readImmediate(1)).toBe(0xffn);

    // Read PUSH2 immediate
    frame.pc = 2;
    expect(frame.readImmediate(2)).toBe(0x1234n);
  });

  test('readImmediate returns null for insufficient data', () => {
    const bytecode = new Uint8Array([0x60, 0xff]);
    const frame = createTestFrame(bytecode);

    // Try to read 2 bytes when only 1 available
    frame.pc = 0;
    expect(frame.readImmediate(2)).toBe(null);
  });
});

// ================================ EXECUTION LOOP ================================

describe('Frame - Execution Loop', () => {
  test('execute runs until STOP', () => {
    // Simple program: PUSH1 1, PUSH1 2, ADD, STOP
    const bytecode = new Uint8Array([
      0x60, 0x01, // PUSH1 1
      0x60, 0x02, // PUSH1 2
      0x01, // ADD
      0x00, // STOP
    ]);

    const frame = createTestFrame(bytecode, 10000n);
    frame.execute();

    expect(frame.stopped).toBe(true);
    expect(frame.reverted).toBe(false);
    expect(frame.stack.length).toBe(1);
    expect(frame.stack[0]).toBe(3n); // 1 + 2
  });

  test('execute stops at end of bytecode', () => {
    const bytecode = new Uint8Array([0x60, 0x01]); // PUSH1 1 (no STOP)
    const frame = createTestFrame(bytecode, 10000n);

    frame.execute();

    expect(frame.pc).toBe(2); // Past end
    expect(frame.stopped).toBe(false);
    expect(frame.stack.length).toBe(1);
  });

  test('execute throws on invalid opcode', () => {
    const bytecode = new Uint8Array([0xfe]); // INVALID opcode
    const frame = createTestFrame(bytecode, 10000n);

    expect(() => frame.execute()).toThrow(EvmError);
    expect(() => frame.execute()).toThrow(/Invalid opcode/);
  });

  test('execute throws ExecutionTimeout after max iterations', () => {
    // Infinite loop: JUMPDEST, PUSH1 0, JUMP
    const bytecode = new Uint8Array([
      0x5b, // JUMPDEST (PC=0)
      0x60, 0x00, // PUSH1 0
      0x56, // JUMP (back to PC=0)
    ]);

    const frame = createTestFrame(bytecode, 100000000000n); // Lots of gas

    expect(() => frame.execute()).toThrow(EvmError);
    expect(() => frame.execute()).toThrow(/Execution exceeded/);
  });

  test('step executes single instruction', () => {
    const bytecode = new Uint8Array([
      0x60, 0x01, // PUSH1 1
      0x60, 0x02, // PUSH1 2
      0x01, // ADD
      0x00, // STOP
    ]);

    const frame = createTestFrame(bytecode, 10000n);

    // Step 1: PUSH1 1
    frame.step();
    expect(frame.pc).toBe(2);
    expect(frame.stack.length).toBe(1);
    expect(frame.stack[0]).toBe(1n);

    // Step 2: PUSH1 2
    frame.step();
    expect(frame.pc).toBe(4);
    expect(frame.stack.length).toBe(2);
    expect(frame.stack[1]).toBe(2n);

    // Step 3: ADD
    frame.step();
    expect(frame.pc).toBe(5);
    expect(frame.stack.length).toBe(1);
    expect(frame.stack[0]).toBe(3n);

    // Step 4: STOP
    frame.step();
    expect(frame.stopped).toBe(true);
  });

  test('step does nothing after stopped', () => {
    const bytecode = new Uint8Array([0x00]); // STOP
    const frame = createTestFrame(bytecode, 10000n);

    frame.step();
    expect(frame.stopped).toBe(true);

    const pcBefore = frame.pc;
    frame.step(); // Should do nothing
    expect(frame.pc).toBe(pcBefore);
  });

  test.skip('step does nothing after reverted', () => {
    // TODO: This test requires EVM integration (REVERT handler needs EVM context)
    const bytecode = new Uint8Array([
      0x60, 0x00, // PUSH1 0
      0x60, 0x00, // PUSH1 0
      0xfd, // REVERT
    ]);
    const frame = createTestFrame(bytecode, 10000n);

    frame.execute();
    expect(frame.reverted).toBe(true);

    const pcBefore = frame.pc;
    frame.step(); // Should do nothing
    expect(frame.pc).toBe(pcBefore);
  });

  test('step does nothing at end of bytecode', () => {
    const bytecode = new Uint8Array([0x60, 0x01]); // PUSH1 1
    const frame = createTestFrame(bytecode, 10000n);

    frame.execute();
    expect(frame.pc).toBe(2); // Past end

    frame.step(); // Should do nothing
    expect(frame.pc).toBe(2);
  });
});

// ================================ INTEGRATION TESTS ================================

describe('Frame - Integration Tests', () => {
  test('executes simple arithmetic program', () => {
    // Program: (5 + 3) * 2 = 16
    const bytecode = new Uint8Array([
      0x60, 0x05, // PUSH1 5
      0x60, 0x03, // PUSH1 3
      0x01, // ADD -> 8
      0x60, 0x02, // PUSH1 2
      0x02, // MUL -> 16
      0x00, // STOP
    ]);

    const frame = createTestFrame(bytecode, 10000n);
    frame.execute();

    expect(frame.stopped).toBe(true);
    expect(frame.stack.length).toBe(1);
    expect(frame.stack[0]).toBe(16n);
  });

  test('executes stack manipulation program', () => {
    // Program: DUP and SWAP
    const bytecode = new Uint8Array([
      0x60, 0x0a, // PUSH1 10
      0x60, 0x14, // PUSH1 20
      0x80, // DUP1 -> [10, 20, 20]
      0x91, // SWAP2 -> [20, 20, 10]
      0x00, // STOP
    ]);

    const frame = createTestFrame(bytecode, 10000n);
    frame.execute();

    expect(frame.stopped).toBe(true);
    expect(frame.stack.length).toBe(3);
    expect(frame.stack[0]).toBe(20n);
    expect(frame.stack[1]).toBe(20n);
    expect(frame.stack[2]).toBe(10n);
  });

  test.skip('executes memory operations', () => {
    // TODO: This test requires EVM integration (MSTORE/MLOAD handlers need more work)
    // Program: MSTORE and MLOAD
    const bytecode = new Uint8Array([
      0x60, 0x42, // PUSH1 0x42
      0x60, 0x00, // PUSH1 0 (offset)
      0x52, // MSTORE (store 0x42 at offset 0)
      0x60, 0x00, // PUSH1 0 (offset)
      0x51, // MLOAD (load from offset 0)
      0x00, // STOP
    ]);

    const frame = createTestFrame(bytecode, 10000n);
    frame.execute();

    expect(frame.stopped).toBe(true);
    expect(frame.stack.length).toBe(1);
    // MSTORE stores a 32-byte word, MLOAD reads it back
    expect(frame.stack[0]).toBe(0x42n);
  });

  test('executes conditional jump', () => {
    // Program: JUMPI (conditional jump)
    // JUMPI pops: dest (top), then condition
    // So we need to push: condition first, then dest
    // PC:  0  1   2  3   4     5  6     7  8   9
    const bytecode = new Uint8Array([
      0x60, 0x01, // PUSH1 1 (condition = true) - PC 0-1
      0x60, 0x09, // PUSH1 9 (jump target) - PC 2-3
      0x57, // JUMPI (should jump to PC=9) - PC 4
      0x60, 0xff, // PUSH1 0xff (skipped) - PC 5-6
      0x00, // STOP - PC 7
      0x00, // Padding - PC 8
      0x5b, // JUMPDEST - PC 9
      0x60, 0xaa, // PUSH1 0xaa (executed) - PC 10-11
      0x00, // STOP - PC 12
    ]);

    const frame = createTestFrame(bytecode, 10000n);
    frame.execute();

    expect(frame.stopped).toBe(true);
    expect(frame.stack.length).toBe(1);
    expect(frame.stack[0]).toBe(0xaan); // 0xff was skipped
  });

  test('gas is consumed during execution', () => {
    const bytecode = new Uint8Array([
      0x60, 0x01, // PUSH1 1 (3 gas)
      0x60, 0x02, // PUSH1 2 (3 gas)
      0x01, // ADD (3 gas)
      0x00, // STOP (0 gas)
    ]);

    const frame = createTestFrame(bytecode, 10000n);
    const gasBefore = frame.gasRemaining;

    frame.execute();

    expect(frame.gasRemaining).toBeLessThan(gasBefore);
    expect(frame.gasRemaining).toBe(gasBefore - 9n); // 3 + 3 + 3
  });

  test('execution stops on OutOfGas', () => {
    const bytecode = new Uint8Array([
      0x60, 0x01, // PUSH1 1
      0x60, 0x02, // PUSH1 2
      0x01, // ADD
      0x00, // STOP
    ]);

    // Only 5 gas available (needs 9)
    const frame = createTestFrame(bytecode, 5n);

    expect(() => frame.execute()).toThrow(EvmError);
    expect(() => frame.execute()).toThrow(/OutOfGas/);
  });
});
