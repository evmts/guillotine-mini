/**
 * Tests for control flow opcode handlers
 *
 * Covers:
 * - STOP: Halts execution
 * - JUMP: Unconditional jump to JUMPDEST
 * - JUMPI: Conditional jump if condition != 0
 * - JUMPDEST: Jump destination marker (no-op)
 * - PC: Returns current program counter
 * - RETURN: Returns output data and halts
 * - REVERT: Returns output data and reverts
 */

import { describe, expect, it, beforeEach } from 'bun:test';
import {
  stop,
  jump,
  jumpi,
  jumpdest,
  pc,
  ret,
  revert,
  type Frame,
} from './handlers_control_flow';
import { Bytecode } from '../bytecode';
import { CallError, EvmError } from '../errors';

/**
 * Mock Frame implementation for testing
 */
class MockFrame implements Frame {
  pc = 0;
  stopped = false;
  reverted = false;
  bytecode: Bytecode;
  output: Uint8Array = new Uint8Array(0);
  memory_size = 0;
  gas_left = 1000000n;
  private stack: bigint[] = [];
  private memory: Uint8Array = new Uint8Array(1024);
  private hardfork = 'Cancun';

  constructor(code: Uint8Array = new Uint8Array(0)) {
    this.bytecode = new Bytecode(code);
  }

  consumeGas(amount: bigint): void {
    if (this.gas_left < amount) {
      throw new EvmError(CallError.OutOfGas);
    }
    this.gas_left -= amount;
  }

  popStack(): bigint {
    const value = this.stack.pop();
    if (value === undefined) {
      throw new EvmError(CallError.StackUnderflow);
    }
    return value;
  }

  pushStack(value: bigint): void {
    if (this.stack.length >= 1024) {
      throw new EvmError(CallError.StackOverflow);
    }
    this.stack.push(value);
  }

  readMemory(address: number): number {
    if (address >= this.memory.length) {
      return 0;
    }
    return this.memory[address];
  }

  writeMemory(address: number, value: number): void {
    if (address >= this.memory.length) {
      // Expand memory
      const newSize = Math.max(this.memory.length * 2, address + 1);
      const newMemory = new Uint8Array(newSize);
      newMemory.set(this.memory);
      this.memory = newMemory;
    }
    this.memory[address] = value;
  }

  memoryExpansionCost(endBytes: bigint): bigint {
    const newSizeWords = (endBytes + 31n) / 32n;
    const oldSizeWords = BigInt(this.memory_size) / 32n;

    if (newSizeWords <= oldSizeWords) {
      return 0n;
    }

    const newCost = newSizeWords * 3n + (newSizeWords * newSizeWords) / 512n;
    const oldCost = oldSizeWords * 3n + (oldSizeWords * oldSizeWords) / 512n;

    return newCost - oldCost;
  }

  getEvm(): { hardfork: { isBefore: (fork: string) => boolean } } {
    const hardforks = [
      'Frontier',
      'Homestead',
      'Tangerine',
      'Spurious',
      'Byzantium',
      'Constantinople',
      'Istanbul',
      'Berlin',
      'London',
      'Merge',
      'Shanghai',
      'Cancun',
      'Prague',
    ];
    const currentIdx = hardforks.indexOf(this.hardfork);

    return {
      hardfork: {
        isBefore: (fork: string) => {
          const forkIdx = hardforks.indexOf(fork);
          return currentIdx < forkIdx;
        },
      },
    };
  }

  setHardfork(fork: string): void {
    this.hardfork = fork;
  }

  getStackSize(): number {
    return this.stack.length;
  }

  peekStack(depth: number = 0): bigint {
    const idx = this.stack.length - 1 - depth;
    if (idx < 0) {
      throw new EvmError(CallError.StackUnderflow);
    }
    return this.stack[idx];
  }
}

describe('Control Flow Handlers', () => {
  describe('STOP (0x00)', () => {
    it('should halt execution', () => {
      const frame = new MockFrame();
      stop(frame);
      expect(frame.stopped).toBe(true);
    });

    it('should not consume gas', () => {
      const frame = new MockFrame();
      const gasBeforeStop = frame.gas_left;
      stop(frame);
      expect(frame.gas_left).toBe(gasBeforeStop);
    });
  });

  describe('JUMP (0x56)', () => {
    it('should jump to valid JUMPDEST', () => {
      // Bytecode: JUMPDEST at PC=4
      const code = new Uint8Array([0x60, 0x04, 0x56, 0xfe, 0x5b, 0x00]);
      const frame = new MockFrame(code);

      // Push destination (PC=4, which is JUMPDEST)
      frame.pushStack(4n);

      jump(frame);

      expect(frame.pc).toBe(4);
    });

    it('should throw on invalid jump destination', () => {
      // Bytecode with no valid JUMPDEST at PC=3
      const code = new Uint8Array([0x60, 0x03, 0x56, 0xfe]);
      const frame = new MockFrame(code);

      // Push destination (PC=3, which is INVALID, not JUMPDEST)
      frame.pushStack(3n);

      expect(() => jump(frame)).toThrow(EvmError);
    });

    it('should throw on jump destination beyond bytecode', () => {
      const code = new Uint8Array([0x60, 0x10, 0x56]);
      const frame = new MockFrame(code);

      frame.pushStack(100n); // Jump to PC=100 (beyond code length)

      expect(() => jump(frame)).toThrow(EvmError);
    });

    it('should throw on stack underflow', () => {
      const frame = new MockFrame();
      expect(() => jump(frame)).toThrow(EvmError);
      expect(() => jump(frame)).toThrow(CallError.StackUnderflow);
    });

    it('should consume GasMidStep (8 gas)', () => {
      const code = new Uint8Array([0x60, 0x04, 0x56, 0xfe, 0x5b, 0x00]);
      const frame = new MockFrame(code);
      const gasBeforeJump = frame.gas_left;

      frame.pushStack(4n);
      jump(frame);

      expect(frame.gas_left).toBe(gasBeforeJump - 8n);
    });

    it('should throw on overflow destination', () => {
      const frame = new MockFrame();
      frame.pushStack(0x100000000n); // Larger than u32

      expect(() => jump(frame)).toThrow(EvmError);
    });
  });

  describe('JUMPI (0x57)', () => {
    it('should jump when condition is non-zero', () => {
      // Bytecode: JUMPDEST at PC=2
      const code = new Uint8Array([0x00, 0x00, 0x5b, 0x00]); // STOP, STOP, JUMPDEST, STOP
      const frame = new MockFrame(code);
      frame.pc = 0; // Start at beginning

      // Push in reverse order: condition first (bottom), dest second (top)
      frame.pushStack(1n); // condition (non-zero = true) - pushed first
      frame.pushStack(2n); // destination (JUMPDEST at PC=2) - pushed second (popped first)

      jumpi(frame);

      expect(frame.pc).toBe(2); // Should jump to PC=2
    });

    it('should not jump when condition is zero', () => {
      const code = new Uint8Array([0x60, 0x04, 0x57, 0xfe, 0x5b]); // PUSH1 4, JUMPI, INVALID, JUMPDEST
      const frame = new MockFrame(code);
      frame.pc = 2; // Start at JUMPI

      frame.pushStack(0n); // condition (zero = false) - pushed first
      frame.pushStack(4n); // destination (JUMPDEST at PC=4) - pushed second (popped first)

      jumpi(frame);

      expect(frame.pc).toBe(3); // PC incremented by 1 from 2 to 3
    });

    it('should throw on invalid jump destination when condition is true', () => {
      const code = new Uint8Array([0x60, 0x05, 0x60, 0x01, 0x57, 0xfe]);
      const frame = new MockFrame(code);

      frame.pushStack(1n); // condition (true)
      frame.pushStack(5n); // destination (INVALID, not JUMPDEST)

      expect(() => jumpi(frame)).toThrow(EvmError);
    });

    it('should not validate destination when condition is false', () => {
      const code = new Uint8Array([0x60, 0x05, 0x60, 0x00, 0x57, 0xfe]);
      const frame = new MockFrame(code);
      frame.pc = 4; // Start at JUMPI (PC=4)

      frame.pushStack(0n); // condition (false)
      frame.pushStack(999n); // Invalid destination

      // Should NOT throw because condition is false
      jumpi(frame);
      expect(frame.pc).toBe(5); // Incremented from 4 to 5
    });

    it('should consume GasSlowStep (10 gas)', () => {
      const code = new Uint8Array([0x60, 0x04, 0x57, 0xfe, 0x5b]); // PUSH1 4, JUMPI, INVALID, JUMPDEST
      const frame = new MockFrame(code);
      frame.pc = 2; // Start at JUMPI
      const gasBeforeJumpi = frame.gas_left;

      frame.pushStack(0n); // condition (false)
      frame.pushStack(100n); // Invalid destination (won't jump)

      jumpi(frame);

      expect(frame.gas_left).toBe(gasBeforeJumpi - 10n);
    });

    it('should treat any non-zero value as true', () => {
      const code = new Uint8Array([0x00, 0x00, 0x5b]); // STOP, STOP, JUMPDEST at PC=2
      const frame = new MockFrame(code);
      frame.pc = 0; // Start at beginning

      frame.pushStack(0xdeadbeefn); // Any non-zero (condition)
      frame.pushStack(2n); // destination (JUMPDEST at PC=2)

      jumpi(frame);

      expect(frame.pc).toBe(2);
    });
  });

  describe('JUMPDEST (0x5b)', () => {
    it('should increment PC', () => {
      const frame = new MockFrame();
      frame.pc = 10;

      jumpdest(frame);

      expect(frame.pc).toBe(11);
    });

    it('should consume JumpdestGas (1 gas)', () => {
      const frame = new MockFrame();
      const gasBeforeJumpdest = frame.gas_left;

      jumpdest(frame);

      expect(frame.gas_left).toBe(gasBeforeJumpdest - 1n);
    });

    it('should be identified during bytecode analysis', () => {
      // JUMPDEST at PC=0
      const code1 = new Uint8Array([0x5b]);
      const bytecode1 = new Bytecode(code1);
      expect(bytecode1.isValidJumpDest(0)).toBe(true);

      // JUMPDEST at PC=2 (after PUSH1)
      const code2 = new Uint8Array([0x60, 0x00, 0x5b]);
      const bytecode2 = new Bytecode(code2);
      expect(bytecode2.isValidJumpDest(2)).toBe(true);

      // NOT a JUMPDEST (inside PUSH data)
      const code3 = new Uint8Array([0x60, 0x5b]); // PUSH1 0x5b (PUSH data, not instruction)
      const bytecode3 = new Bytecode(code3);
      expect(bytecode3.isValidJumpDest(1)).toBe(false);
    });
  });

  describe('PC (0x58)', () => {
    it('should push current PC to stack', () => {
      const frame = new MockFrame();
      frame.pc = 42;

      pc(frame);

      expect(frame.getStackSize()).toBe(1);
      expect(frame.peekStack()).toBe(42n);
    });

    it('should increment PC', () => {
      const frame = new MockFrame();
      frame.pc = 10;

      pc(frame);

      expect(frame.pc).toBe(11);
    });

    it('should consume GasQuickStep (2 gas)', () => {
      const frame = new MockFrame();
      const gasBeforePc = frame.gas_left;

      pc(frame);

      expect(frame.gas_left).toBe(gasBeforePc - 2n);
    });

    it('should push zero when PC is zero', () => {
      const frame = new MockFrame();
      frame.pc = 0;

      pc(frame);

      expect(frame.peekStack()).toBe(0n);
    });
  });

  describe('RETURN (0xf3)', () => {
    it('should halt execution', () => {
      const frame = new MockFrame();
      frame.pushStack(0n); // offset
      frame.pushStack(0n); // length

      ret(frame);

      expect(frame.stopped).toBe(true);
    });

    it('should return empty output when length is zero', () => {
      const frame = new MockFrame();
      frame.pushStack(0n); // offset
      frame.pushStack(0n); // length

      ret(frame);

      expect(frame.output.length).toBe(0);
      expect(frame.stopped).toBe(true);
    });

    it('should copy memory to output', () => {
      const frame = new MockFrame();

      // Write some data to memory
      frame.writeMemory(0, 0xde);
      frame.writeMemory(1, 0xad);
      frame.writeMemory(2, 0xbe);
      frame.writeMemory(3, 0xef);

      // Stack is LIFO: last pushed is first popped
      frame.pushStack(4n); // length (popped second)
      frame.pushStack(0n); // offset (popped first)

      ret(frame);

      expect(frame.output.length).toBe(4);
      expect(frame.output[0]).toBe(0xde);
      expect(frame.output[1]).toBe(0xad);
      expect(frame.output[2]).toBe(0xbe);
      expect(frame.output[3]).toBe(0xef);
      expect(frame.stopped).toBe(true);
    });

    it('should charge for memory expansion', () => {
      const frame = new MockFrame();
      frame.memory_size = 0; // Start with no memory allocated
      const gasBeforeReturn = frame.gas_left;

      frame.pushStack(100n); // length (will expand memory)
      frame.pushStack(0n); // offset

      ret(frame);

      // Should have consumed gas for memory expansion
      expect(frame.gas_left).toBeLessThan(gasBeforeReturn);
    });

    it('should throw on offset overflow', () => {
      const frame = new MockFrame();
      frame.pushStack(10n); // length
      frame.pushStack(0x100000000n); // offset > u32::MAX

      expect(() => ret(frame)).toThrow(EvmError);
    });

    it('should throw on length overflow', () => {
      const frame = new MockFrame();
      frame.pushStack(0x100000000n); // length > u32::MAX
      frame.pushStack(0n); // offset

      expect(() => ret(frame)).toThrow(EvmError);
    });

    it('should throw on offset + length overflow', () => {
      const frame = new MockFrame();
      frame.pushStack(0x20n); // length causes overflow
      frame.pushStack(0xFFFFFFF0n); // offset close to u32::MAX

      expect(() => ret(frame)).toThrow(EvmError);
    });
  });

  describe('REVERT (0xfd)', () => {
    it('should halt execution with revert flag', () => {
      const frame = new MockFrame();
      frame.pushStack(0n); // offset
      frame.pushStack(0n); // length

      revert(frame);

      expect(frame.reverted).toBe(true);
      expect(frame.stopped).toBe(false); // REVERT sets reverted, not stopped
    });

    it('should throw before Byzantium hardfork', () => {
      const frame = new MockFrame();
      frame.setHardfork('Homestead'); // Before Byzantium

      // Push offset and length to avoid stack underflow
      frame.pushStack(0n); // length (popped second)
      frame.pushStack(0n); // offset (popped first)

      // Should throw InvalidOpcode because REVERT doesn't exist before Byzantium
      expect(() => revert(frame)).toThrow(EvmError);
      try {
        revert(frame);
      } catch (e) {
        expect((e as EvmError).errorType).toBe(CallError.InvalidOpcode);
      }
    });

    it('should work from Byzantium onwards', () => {
      const frame = new MockFrame();
      frame.setHardfork('Byzantium');

      frame.pushStack(0n);
      frame.pushStack(0n);

      expect(() => revert(frame)).not.toThrow();
      expect(frame.reverted).toBe(true);
    });

    it('should copy memory to output', () => {
      const frame = new MockFrame();

      // Write some data to memory
      frame.writeMemory(10, 0xaa);
      frame.writeMemory(11, 0xbb);
      frame.writeMemory(12, 0xcc);

      frame.pushStack(3n); // length (popped second)
      frame.pushStack(10n); // offset (popped first)

      revert(frame);

      expect(frame.output.length).toBe(3);
      expect(frame.output[0]).toBe(0xaa);
      expect(frame.output[1]).toBe(0xbb);
      expect(frame.output[2]).toBe(0xcc);
      expect(frame.reverted).toBe(true);
    });

    it('should return empty output when length is zero', () => {
      const frame = new MockFrame();
      frame.pushStack(0n); // length (popped second)
      frame.pushStack(0n); // offset (popped first)

      revert(frame);

      expect(frame.output.length).toBe(0);
      expect(frame.reverted).toBe(true);
    });

    it('should charge for memory expansion', () => {
      const frame = new MockFrame();
      frame.memory_size = 0; // Start with no memory allocated
      const gasBeforeRevert = frame.gas_left;

      frame.pushStack(100n); // length (will expand memory)
      frame.pushStack(0n); // offset

      revert(frame);

      expect(frame.gas_left).toBeLessThan(gasBeforeRevert);
    });
  });

  describe('Jump destination validation', () => {
    it('should validate JUMPDEST not inside PUSH data', () => {
      // PUSH2 0x5b00 (0x5b is data, not JUMPDEST)
      const code = new Uint8Array([0x61, 0x5b, 0x00, 0x5b]); // PUSH2 0x5b00, JUMPDEST
      const bytecode = new Bytecode(code);

      expect(bytecode.isValidJumpDest(1)).toBe(false); // Inside PUSH data
      expect(bytecode.isValidJumpDest(2)).toBe(false); // Inside PUSH data
      expect(bytecode.isValidJumpDest(3)).toBe(true); // Actual JUMPDEST
    });

    it('should handle multiple JUMPDESTs', () => {
      // JUMPDEST PUSH1 0x03 JUMPDEST
      const code = new Uint8Array([0x5b, 0x60, 0x03, 0x5b]);
      const bytecode = new Bytecode(code);

      expect(bytecode.isValidJumpDest(0)).toBe(true);
      expect(bytecode.isValidJumpDest(3)).toBe(true);
      expect(bytecode.isValidJumpDest(1)).toBe(false);
      expect(bytecode.isValidJumpDest(2)).toBe(false);
    });
  });
});
