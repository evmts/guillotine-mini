import { describe, expect, test } from 'bun:test';
import { pop, push, dup, swap, Hardfork, FrameInterface, GAS_QUICKSTEP, GAS_FASTESTSTEP } from './handlers_stack';
import { CallError, EvmError } from '../errors';
import { Bytecode } from '../bytecode';

/**
 * Mock Frame implementation for testing stack operations
 */
class MockFrame implements FrameInterface {
  stack: bigint[] = [];
  pc = 0;
  gasRemaining = 1000000n;
  bytecode: Bytecode;
  hardfork: Hardfork;

  constructor(
    code: Uint8Array = new Uint8Array([]),
    hardfork: Hardfork = Hardfork.CANCUN
  ) {
    this.bytecode = new Bytecode(code);
    this.hardfork = hardfork;
  }

  consumeGas(amount: bigint): void {
    if (this.gasRemaining < amount) {
      throw new EvmError(CallError.OutOfGas);
    }
    this.gasRemaining -= amount;
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

  readImmediate(size: number): bigint | null {
    return this.bytecode.readImmediate(this.pc, size);
  }
}

describe('Stack Handlers', () => {
  describe('POP (0x50)', () => {
    test('removes top item from stack', () => {
      const frame = new MockFrame();
      frame.stack = [1n, 2n, 3n];
      frame.pc = 0;

      pop(frame);

      expect(frame.stack).toEqual([1n, 2n]);
      expect(frame.pc).toBe(1);
      expect(frame.gasRemaining).toBe(1000000n - BigInt(GAS_QUICKSTEP));
    });

    test('throws StackUnderflow on empty stack', () => {
      const frame = new MockFrame();
      frame.stack = [];

      expect(() => pop(frame)).toThrow(EvmError);
      expect(() => pop(frame)).toThrow('StackUnderflow');
    });

    test('charges correct gas (2 gas)', () => {
      const frame = new MockFrame();
      frame.stack = [42n];
      const initialGas = frame.gasRemaining;

      pop(frame);

      expect(frame.gasRemaining).toBe(initialGas - BigInt(GAS_QUICKSTEP));
    });

    test('throws OutOfGas when insufficient gas', () => {
      const frame = new MockFrame();
      frame.stack = [1n];
      frame.gasRemaining = 1n;

      expect(() => pop(frame)).toThrow(EvmError);
      expect(() => pop(frame)).toThrow('OutOfGas');
    });
  });

  describe('PUSH0 (0x5f)', () => {
    test('pushes zero onto stack (Shanghai+)', () => {
      const frame = new MockFrame(new Uint8Array([]), Hardfork.SHANGHAI);
      frame.pc = 0;

      push(frame, 0x5f);

      expect(frame.stack).toEqual([0n]);
      expect(frame.pc).toBe(1);
      expect(frame.gasRemaining).toBe(1000000n - BigInt(GAS_QUICKSTEP));
    });

    test('throws InvalidOpcode before Shanghai', () => {
      const frame = new MockFrame(new Uint8Array([]), Hardfork.LONDON);

      expect(() => push(frame, 0x5f)).toThrow(EvmError);
      expect(() => push(frame, 0x5f)).toThrow('PUSH0 requires Shanghai hardfork');
    });

    test('charges correct gas (2 gas)', () => {
      const frame = new MockFrame(new Uint8Array([]), Hardfork.SHANGHAI);
      const initialGas = frame.gasRemaining;

      push(frame, 0x5f);

      expect(frame.gasRemaining).toBe(initialGas - BigInt(GAS_QUICKSTEP));
    });
  });

  describe('PUSH1-PUSH32 (0x60-0x7f)', () => {
    test('PUSH1 pushes 1 byte', () => {
      const code = new Uint8Array([0x60, 0xff]); // PUSH1 0xff
      const frame = new MockFrame(code);
      frame.pc = 0;

      push(frame, 0x60);

      expect(frame.stack).toEqual([0xffn]);
      expect(frame.pc).toBe(2); // Opcode + 1 byte
      expect(frame.gasRemaining).toBe(1000000n - BigInt(GAS_FASTESTSTEP));
    });

    test('PUSH2 pushes 2 bytes', () => {
      const code = new Uint8Array([0x61, 0x12, 0x34]); // PUSH2 0x1234
      const frame = new MockFrame(code);
      frame.pc = 0;

      push(frame, 0x61);

      expect(frame.stack).toEqual([0x1234n]);
      expect(frame.pc).toBe(3); // Opcode + 2 bytes
    });

    test('PUSH32 pushes 32 bytes', () => {
      const code = new Uint8Array(33);
      code[0] = 0x7f; // PUSH32
      for (let i = 1; i <= 32; i++) {
        code[i] = i;
      }
      const frame = new MockFrame(code);
      frame.pc = 0;

      push(frame, 0x7f);

      // Calculate expected value: big-endian 32 bytes
      let expected = 0n;
      for (let i = 1; i <= 32; i++) {
        expected = (expected << 8n) | BigInt(i);
      }
      expect(frame.stack).toEqual([expected]);
      expect(frame.pc).toBe(33); // Opcode + 32 bytes
    });

    test('PUSH with all zeros', () => {
      const code = new Uint8Array([0x62, 0x00, 0x00, 0x00]); // PUSH3 0x000000
      const frame = new MockFrame(code);

      push(frame, 0x62);

      expect(frame.stack).toEqual([0n]);
    });

    test('throws InvalidPush when bytecode truncated', () => {
      const code = new Uint8Array([0x61, 0x12]); // PUSH2 but only 1 byte
      const frame = new MockFrame(code);

      expect(() => push(frame, 0x61)).toThrow(EvmError);
      expect(() => push(frame, 0x61)).toThrow('PUSH2 has insufficient bytecode');
    });

    test('throws InvalidPush when no data bytes', () => {
      const code = new Uint8Array([0x60]); // PUSH1 but no data
      const frame = new MockFrame(code);

      expect(() => push(frame, 0x60)).toThrow(EvmError);
      expect(() => push(frame, 0x60)).toThrow('PUSH1 has insufficient bytecode');
    });

    test('charges correct gas (3 gas)', () => {
      const code = new Uint8Array([0x60, 0x42]); // PUSH1 0x42
      const frame = new MockFrame(code);
      const initialGas = frame.gasRemaining;

      push(frame, 0x60);

      expect(frame.gasRemaining).toBe(initialGas - BigInt(GAS_FASTESTSTEP));
    });

    test('all PUSH1-PUSH32 opcodes work correctly', () => {
      for (let pushSize = 1; pushSize <= 32; pushSize++) {
        const opcode = 0x60 + pushSize - 1; // PUSH1 = 0x60, PUSH32 = 0x7f
        const code = new Uint8Array(1 + pushSize);
        code[0] = opcode;
        // Fill with sequential bytes
        for (let i = 1; i <= pushSize; i++) {
          code[i] = i % 256;
        }

        const frame = new MockFrame(code);
        push(frame, opcode);

        // Calculate expected value
        let expected = 0n;
        for (let i = 1; i <= pushSize; i++) {
          expected = (expected << 8n) | BigInt(i % 256);
        }

        expect(frame.stack).toEqual([expected]);
        expect(frame.pc).toBe(1 + pushSize);
      }
    });
  });

  describe('DUP1-DUP16 (0x80-0x8f)', () => {
    test('DUP1 duplicates top item', () => {
      const frame = new MockFrame();
      frame.stack = [1n, 2n, 3n];
      frame.pc = 0;

      dup(frame, 0x80);

      expect(frame.stack).toEqual([1n, 2n, 3n, 3n]);
      expect(frame.pc).toBe(1);
      expect(frame.gasRemaining).toBe(1000000n - BigInt(GAS_FASTESTSTEP));
    });

    test('DUP2 duplicates second item', () => {
      const frame = new MockFrame();
      frame.stack = [1n, 2n, 3n];

      dup(frame, 0x81);

      expect(frame.stack).toEqual([1n, 2n, 3n, 2n]);
    });

    test('DUP16 duplicates 16th item', () => {
      const frame = new MockFrame();
      // Create stack with 16 items
      for (let i = 1; i <= 16; i++) {
        frame.stack.push(BigInt(i));
      }

      dup(frame, 0x8f); // DUP16

      expect(frame.stack.length).toBe(17);
      expect(frame.stack[16]).toBe(1n); // Duplicates bottom item
    });

    test('throws StackUnderflow when insufficient items', () => {
      const frame = new MockFrame();
      frame.stack = [1n];

      // DUP2 requires 2 items
      expect(() => dup(frame, 0x81)).toThrow(EvmError);
      expect(() => dup(frame, 0x81)).toThrow('DUP2 requires 2 items on stack, found 1');
    });

    test('throws StackUnderflow on empty stack', () => {
      const frame = new MockFrame();
      frame.stack = [];

      expect(() => dup(frame, 0x80)).toThrow(EvmError);
      expect(() => dup(frame, 0x80)).toThrow('DUP1 requires 1 items on stack, found 0');
    });

    test('charges correct gas (3 gas)', () => {
      const frame = new MockFrame();
      frame.stack = [42n];
      const initialGas = frame.gasRemaining;

      dup(frame, 0x80);

      expect(frame.gasRemaining).toBe(initialGas - BigInt(GAS_FASTESTSTEP));
    });

    test('all DUP1-DUP16 opcodes work correctly', () => {
      for (let dupN = 1; dupN <= 16; dupN++) {
        const opcode = 0x80 + dupN - 1; // DUP1 = 0x80, DUP16 = 0x8f
        const frame = new MockFrame();

        // Create stack with enough items
        for (let i = 1; i <= 16; i++) {
          frame.stack.push(BigInt(i));
        }

        dup(frame, opcode);

        // Should duplicate the nth item from top
        expect(frame.stack.length).toBe(17);
        expect(frame.stack[16]).toBe(BigInt(16 - dupN + 1));
      }
    });
  });

  describe('SWAP1-SWAP16 (0x90-0x9f)', () => {
    test('SWAP1 swaps top with second', () => {
      const frame = new MockFrame();
      frame.stack = [1n, 2n, 3n];
      frame.pc = 0;

      swap(frame, 0x90);

      expect(frame.stack).toEqual([1n, 3n, 2n]);
      expect(frame.pc).toBe(1);
      expect(frame.gasRemaining).toBe(1000000n - BigInt(GAS_FASTESTSTEP));
    });

    test('SWAP2 swaps top with third', () => {
      const frame = new MockFrame();
      frame.stack = [1n, 2n, 3n, 4n];

      swap(frame, 0x91);

      expect(frame.stack).toEqual([1n, 4n, 3n, 2n]);
    });

    test('SWAP16 swaps top with 17th', () => {
      const frame = new MockFrame();
      // Create stack with 17 items
      for (let i = 1; i <= 17; i++) {
        frame.stack.push(BigInt(i));
      }

      swap(frame, 0x9f); // SWAP16

      expect(frame.stack.length).toBe(17);
      expect(frame.stack[0]).toBe(17n); // Bottom swapped with top
      expect(frame.stack[16]).toBe(1n); // Top swapped with bottom
    });

    test('throws StackUnderflow when insufficient items', () => {
      const frame = new MockFrame();
      frame.stack = [1n];

      // SWAP1 requires 2 items
      expect(() => swap(frame, 0x90)).toThrow(EvmError);
      expect(() => swap(frame, 0x90)).toThrow('SWAP1 requires 2 items on stack, found 1');
    });

    test('throws StackUnderflow on empty stack', () => {
      const frame = new MockFrame();
      frame.stack = [];

      expect(() => swap(frame, 0x90)).toThrow(EvmError);
      expect(() => swap(frame, 0x90)).toThrow('SWAP1 requires 2 items on stack, found 0');
    });

    test('charges correct gas (3 gas)', () => {
      const frame = new MockFrame();
      frame.stack = [1n, 2n];
      const initialGas = frame.gasRemaining;

      swap(frame, 0x90);

      expect(frame.gasRemaining).toBe(initialGas - BigInt(GAS_FASTESTSTEP));
    });

    test('all SWAP1-SWAP16 opcodes work correctly', () => {
      for (let swapN = 1; swapN <= 16; swapN++) {
        const opcode = 0x90 + swapN - 1; // SWAP1 = 0x90, SWAP16 = 0x9f
        const frame = new MockFrame();

        // Create stack with 17 items (need n+1 items for SWAPn)
        for (let i = 1; i <= 17; i++) {
          frame.stack.push(BigInt(i));
        }

        const topBefore = frame.stack[16];
        const swapIdxBefore = frame.stack[16 - swapN];

        swap(frame, opcode);

        // Should swap top with (n+1)th from top
        expect(frame.stack.length).toBe(17);
        expect(frame.stack[16]).toBe(swapIdxBefore);
        expect(frame.stack[16 - swapN]).toBe(topBefore);
      }
    });
  });

  describe('Edge cases', () => {
    test('PUSH operations work at end of bytecode', () => {
      const code = new Uint8Array([0x60, 0x42]); // PUSH1 0x42 at end
      const frame = new MockFrame(code);

      push(frame, 0x60);

      expect(frame.stack).toEqual([0x42n]);
    });

    test('stack operations work with max u256 values', () => {
      const frame = new MockFrame();
      const maxU256 = (1n << 256n) - 1n;
      frame.stack = [maxU256];

      dup(frame, 0x80); // DUP1

      expect(frame.stack).toEqual([maxU256, maxU256]);
    });

    test('multiple stack operations in sequence', () => {
      const code = new Uint8Array([0x60, 0x01, 0x60, 0x02]); // PUSH1 1, PUSH1 2
      const frame = new MockFrame(code);

      push(frame, 0x60); // Push 1
      push(frame, 0x60); // Push 2
      dup(frame, 0x81); // DUP2 (duplicate 1)
      swap(frame, 0x91); // SWAP2 (swap with 2)
      pop(frame); // Remove top

      expect(frame.stack).toEqual([1n, 2n]);
    });

    test('DUP and SWAP preserve stack integrity', () => {
      const frame = new MockFrame();
      frame.stack = [10n, 20n, 30n, 40n, 50n];

      dup(frame, 0x82); // DUP3: duplicate 30
      expect(frame.stack).toEqual([10n, 20n, 30n, 40n, 50n, 30n]);

      swap(frame, 0x91); // SWAP2: swap 30 with 40
      expect(frame.stack).toEqual([10n, 20n, 30n, 30n, 50n, 40n]);
    });

    test('gas consumption accumulates correctly', () => {
      const frame = new MockFrame(new Uint8Array([0x60, 0x42]));
      const initialGas = frame.gasRemaining;

      push(frame, 0x60); // 3 gas
      dup(frame, 0x80); // 3 gas
      swap(frame, 0x90); // 3 gas
      pop(frame); // 2 gas

      const totalGasUsed = BigInt(GAS_FASTESTSTEP + GAS_FASTESTSTEP + GAS_FASTESTSTEP + GAS_QUICKSTEP);
      expect(frame.gasRemaining).toBe(initialGas - totalGasUsed);
    });

    test('PUSH0 multiple times builds stack', () => {
      const frame = new MockFrame(new Uint8Array([]), Hardfork.SHANGHAI);

      for (let i = 0; i < 5; i++) {
        push(frame, 0x5f);
      }

      expect(frame.stack).toEqual([0n, 0n, 0n, 0n, 0n]);
    });

    test('DUP on single item stack works', () => {
      const frame = new MockFrame();
      frame.stack = [999n];

      dup(frame, 0x80); // DUP1

      expect(frame.stack).toEqual([999n, 999n]);
    });

    test('SWAP on exactly 2 items works', () => {
      const frame = new MockFrame();
      frame.stack = [111n, 222n];

      swap(frame, 0x90); // SWAP1

      expect(frame.stack).toEqual([222n, 111n]);
    });
  });

  describe('Gas edge cases', () => {
    test('operations fail when exact gas needed', () => {
      const frame = new MockFrame();
      frame.stack = [1n];
      frame.gasRemaining = BigInt(GAS_QUICKSTEP - 1);

      expect(() => pop(frame)).toThrow(EvmError);
      expect(() => pop(frame)).toThrow('OutOfGas');
    });

    test('operations succeed with exact gas', () => {
      const frame = new MockFrame();
      frame.stack = [1n];
      frame.gasRemaining = BigInt(GAS_QUICKSTEP);

      pop(frame);

      expect(frame.gasRemaining).toBe(0n);
      expect(frame.stack).toEqual([]);
    });
  });

  describe('Hardfork compatibility', () => {
    test('PUSH0 works on Shanghai', () => {
      const frame = new MockFrame(new Uint8Array([]), Hardfork.SHANGHAI);
      push(frame, 0x5f);
      expect(frame.stack).toEqual([0n]);
    });

    test('PUSH0 works on Cancun (post-Shanghai)', () => {
      const frame = new MockFrame(new Uint8Array([]), Hardfork.CANCUN);
      push(frame, 0x5f);
      expect(frame.stack).toEqual([0n]);
    });

    test('PUSH0 fails on London (pre-Shanghai)', () => {
      const frame = new MockFrame(new Uint8Array([]), Hardfork.LONDON);
      expect(() => push(frame, 0x5f)).toThrow(EvmError);
    });

    test('PUSH1-PUSH32 work on all hardforks', () => {
      const hardforks = [
        Hardfork.FRONTIER,
        Hardfork.HOMESTEAD,
        Hardfork.BERLIN,
        Hardfork.LONDON,
        Hardfork.SHANGHAI,
        Hardfork.CANCUN,
      ];

      for (const hardfork of hardforks) {
        const code = new Uint8Array([0x60, 0x42]);
        const frame = new MockFrame(code, hardfork);
        push(frame, 0x60);
        expect(frame.stack).toEqual([0x42n]);
      }
    });
  });
});
