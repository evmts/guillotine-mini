import { describe, expect, test } from 'bun:test';
import {
  address,
  balance,
  origin,
  caller,
  callvalue,
  calldataload,
  calldatasize,
  calldatacopy,
  codesize,
  codecopy,
  gasprice,
  extcodesize,
  extcodecopy,
  returndatasize,
  returndatacopy,
  extcodehash,
  gas,
  type Frame,
  type Evm,
  type Bytecode,
  Hardfork,
} from './handlers_context';

/**
 * Mock Bytecode implementation
 */
class MockBytecode implements Bytecode {
  private code: Uint8Array;

  constructor(code: Uint8Array) {
    this.code = code;
  }

  get length(): number {
    return this.code.length;
  }

  getOpcode(pc: number): number | null {
    if (pc >= this.code.length) {
      return null;
    }
    return this.code[pc];
  }
}

/**
 * Mock EVM implementation
 */
class MockEvm implements Evm {
  hardfork: Hardfork = Hardfork.CANCUN;
  origin: Uint8Array = new Uint8Array(20);
  gas_price: bigint = 1000000000n; // 1 gwei

  private warm_addresses = new Set<string>();
  private balances = new Map<string, bigint>();
  private codes = new Map<string, Uint8Array>();

  constructor() {
    // Default origin address
    this.origin.fill(0);
    this.origin[19] = 0xAA;
  }

  accessAddress(address: Uint8Array): bigint {
    const key = Array.from(address).join(',');
    if (this.warm_addresses.has(key)) {
      return 100n; // Warm
    }
    this.warm_addresses.add(key);
    return 2600n; // Cold
  }

  get_balance(address: Uint8Array): bigint {
    const key = Array.from(address).join(',');
    return this.balances.get(key) ?? 0n;
  }

  set_balance(address: Uint8Array, balance: bigint): void {
    const key = Array.from(address).join(',');
    this.balances.set(key, balance);
  }

  get_code(address: Uint8Array): Uint8Array {
    const key = Array.from(address).join(',');
    return this.codes.get(key) ?? new Uint8Array(0);
  }

  set_code(address: Uint8Array, code: Uint8Array): void {
    const key = Array.from(address).join(',');
    this.codes.set(key, code);
  }
}

/**
 * Mock Frame implementation
 */
class MockFrame implements Frame {
  gas_remaining: bigint = 1000000n;
  pc: number = 0;
  address: Uint8Array;
  caller: Uint8Array;
  value: bigint;
  calldata: Uint8Array;
  bytecode: Bytecode;
  return_data: Uint8Array;
  memory_size: number = 0;

  private stack: bigint[] = [];
  private memory: number[] = [];
  private evm: Evm;

  constructor(evm: Evm, options: Partial<Frame> = {}) {
    this.evm = evm;
    this.address = options.address ?? new Uint8Array(20);
    this.caller = options.caller ?? new Uint8Array(20);
    this.value = options.value ?? 0n;
    this.calldata = options.calldata ?? new Uint8Array(0);
    this.bytecode = options.bytecode ?? new MockBytecode(new Uint8Array(0));
    this.return_data = options.return_data ?? new Uint8Array(0);
  }

  consumeGas(amount: bigint): void {
    if (amount > this.gas_remaining) {
      throw new Error('OutOfGas');
    }
    this.gas_remaining -= amount;
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

  writeMemory(offset: number, value: number): void {
    // Expand memory if needed
    while (this.memory.length <= offset) {
      this.memory.push(0);
    }
    this.memory[offset] = value & 0xFF;
  }

  readMemory(offset: number, length: number): Uint8Array {
    const result = new Uint8Array(length);
    for (let i = 0; i < length; i++) {
      result[i] = this.memory[offset + i] ?? 0;
    }
    return result;
  }

  memoryExpansionCost(size: bigint): bigint {
    const current_words = BigInt(Math.floor(this.memory_size / 32));
    const new_words = (size + 31n) / 32n;

    if (new_words <= current_words) {
      return 0n;
    }

    const current_cost = current_words * current_words / 512n + current_words * 3n;
    const new_cost = new_words * new_words / 512n + new_words * 3n;

    return new_cost - current_cost;
  }

  getEvm(): Evm {
    return this.evm;
  }

  getStack(): bigint[] {
    return [...this.stack];
  }
}

describe('Context Handlers', () => {
  describe('ADDRESS', () => {
    test('returns current contract address', () => {
      const evm = new MockEvm();
      const addr = new Uint8Array(20);
      addr[19] = 0x42;

      const frame = new MockFrame(evm, { address: addr });

      address(frame);

      expect(frame.pc).toBe(1);
      expect(frame.getStack()).toHaveLength(1);
      expect(frame.getStack()[0]).toBe(0x42n);
    });
  });

  describe('BALANCE', () => {
    test('returns account balance (Berlin+, cold access)', () => {
      const evm = new MockEvm();
      evm.hardfork = Hardfork.BERLIN;

      const addr = new Uint8Array(20);
      addr[19] = 0x99;
      evm.set_balance(addr, 1000n);

      const frame = new MockFrame(evm);
      frame.pushStack(0x99n); // Address on stack

      const gas_before = frame.gas_remaining;
      balance(frame);

      expect(frame.pc).toBe(1);
      expect(frame.getStack()).toHaveLength(1);
      expect(frame.getStack()[0]).toBe(1000n);
      expect(gas_before - frame.gas_remaining).toBe(2600n); // Cold access
    });

    test('returns account balance (Berlin+, warm access)', () => {
      const evm = new MockEvm();
      evm.hardfork = Hardfork.BERLIN;

      const addr = new Uint8Array(20);
      addr[19] = 0x99;
      evm.set_balance(addr, 1000n);

      // Mark as warm
      evm.accessAddress(addr);

      const frame = new MockFrame(evm);
      frame.pushStack(0x99n);

      const gas_before = frame.gas_remaining;
      balance(frame);

      expect(frame.getStack()[0]).toBe(1000n);
      expect(gas_before - frame.gas_remaining).toBe(100n); // Warm access
    });

    test('returns zero for non-existent account', () => {
      const evm = new MockEvm();
      const frame = new MockFrame(evm);
      frame.pushStack(0xDEADBEEFn);

      balance(frame);

      expect(frame.getStack()[0]).toBe(0n);
    });
  });

  describe('ORIGIN', () => {
    test('returns transaction origin address', () => {
      const evm = new MockEvm();
      evm.origin = new Uint8Array(20);
      evm.origin[19] = 0xAA;

      const frame = new MockFrame(evm);

      origin(frame);

      expect(frame.pc).toBe(1);
      expect(frame.getStack()).toHaveLength(1);
      expect(frame.getStack()[0]).toBe(0xAAn);
    });
  });

  describe('CALLER', () => {
    test('returns caller address', () => {
      const evm = new MockEvm();
      const caller_addr = new Uint8Array(20);
      caller_addr[19] = 0xBB;

      const frame = new MockFrame(evm, { caller: caller_addr });

      caller(frame);

      expect(frame.pc).toBe(1);
      expect(frame.getStack()).toHaveLength(1);
      expect(frame.getStack()[0]).toBe(0xBBn);
    });
  });

  describe('CALLVALUE', () => {
    test('returns call value', () => {
      const evm = new MockEvm();
      const frame = new MockFrame(evm, { value: 123456n });

      callvalue(frame);

      expect(frame.pc).toBe(1);
      expect(frame.getStack()).toHaveLength(1);
      expect(frame.getStack()[0]).toBe(123456n);
    });

    test('returns zero when no value sent', () => {
      const evm = new MockEvm();
      const frame = new MockFrame(evm, { value: 0n });

      callvalue(frame);

      expect(frame.getStack()[0]).toBe(0n);
    });
  });

  describe('CALLDATALOAD', () => {
    test('loads 32 bytes from calldata', () => {
      const evm = new MockEvm();
      const calldata = new Uint8Array(64);
      calldata.fill(0xFF);

      const frame = new MockFrame(evm, { calldata });
      frame.pushStack(0n); // Offset 0

      calldataload(frame);

      expect(frame.pc).toBe(1);
      expect(frame.getStack()).toHaveLength(1);

      // All 0xFF bytes = 2^256 - 1
      const expected = (1n << 256n) - 1n;
      expect(frame.getStack()[0]).toBe(expected);
    });

    test('pads with zeros when offset near end', () => {
      const evm = new MockEvm();
      const calldata = new Uint8Array(4);
      calldata[0] = 0x12;
      calldata[1] = 0x34;
      calldata[2] = 0x56;
      calldata[3] = 0x78;

      const frame = new MockFrame(evm, { calldata });
      frame.pushStack(0n); // Offset 0

      calldataload(frame);

      // 0x12345678 followed by 28 zero bytes
      expect(frame.getStack()[0]).toBe(0x1234567800000000000000000000000000000000000000000000000000000000n);
    });

    test('returns zero when offset beyond calldata', () => {
      const evm = new MockEvm();
      const calldata = new Uint8Array(4);

      const frame = new MockFrame(evm, { calldata });
      frame.pushStack(1000n); // Offset beyond calldata

      calldataload(frame);

      expect(frame.getStack()[0]).toBe(0n);
    });
  });

  describe('CALLDATASIZE', () => {
    test('returns calldata size', () => {
      const evm = new MockEvm();
      const calldata = new Uint8Array(128);

      const frame = new MockFrame(evm, { calldata });

      calldatasize(frame);

      expect(frame.pc).toBe(1);
      expect(frame.getStack()).toHaveLength(1);
      expect(frame.getStack()[0]).toBe(128n);
    });

    test('returns zero for empty calldata', () => {
      const evm = new MockEvm();
      const frame = new MockFrame(evm, { calldata: new Uint8Array(0) });

      calldatasize(frame);

      expect(frame.getStack()[0]).toBe(0n);
    });
  });

  describe('CALLDATACOPY', () => {
    test('copies calldata to memory', () => {
      const evm = new MockEvm();
      const calldata = new Uint8Array([0x11, 0x22, 0x33, 0x44]);

      const frame = new MockFrame(evm, { calldata });
      frame.pushStack(4n); // Length
      frame.pushStack(0n); // Offset
      frame.pushStack(0n); // Dest offset

      calldatacopy(frame);

      expect(frame.pc).toBe(1);
      const copied = frame.readMemory(0, 4);
      expect(Array.from(copied)).toEqual([0x11, 0x22, 0x33, 0x44]);
    });

    test('pads with zeros when reading beyond calldata', () => {
      const evm = new MockEvm();
      const calldata = new Uint8Array([0xAA, 0xBB]);

      const frame = new MockFrame(evm, { calldata });
      frame.pushStack(4n); // Length (more than calldata)
      frame.pushStack(0n); // Offset
      frame.pushStack(0n); // Dest offset

      calldatacopy(frame);

      const copied = frame.readMemory(0, 4);
      expect(Array.from(copied)).toEqual([0xAA, 0xBB, 0x00, 0x00]);
    });
  });

  describe('CODESIZE', () => {
    test('returns bytecode size', () => {
      const evm = new MockEvm();
      const code = new Uint8Array([0x60, 0x01, 0x60, 0x02, 0x01]); // PUSH1 1 PUSH1 2 ADD

      const frame = new MockFrame(evm, { bytecode: new MockBytecode(code) });

      codesize(frame);

      expect(frame.pc).toBe(1);
      expect(frame.getStack()).toHaveLength(1);
      expect(frame.getStack()[0]).toBe(5n);
    });
  });

  describe('CODECOPY', () => {
    test('copies bytecode to memory', () => {
      const evm = new MockEvm();
      const code = new Uint8Array([0x60, 0x01, 0x60, 0x02]);

      const frame = new MockFrame(evm, { bytecode: new MockBytecode(code) });
      frame.pushStack(4n); // Length
      frame.pushStack(0n); // Offset
      frame.pushStack(0n); // Dest offset

      codecopy(frame);

      expect(frame.pc).toBe(1);
      const copied = frame.readMemory(0, 4);
      expect(Array.from(copied)).toEqual([0x60, 0x01, 0x60, 0x02]);
    });

    test('pads with zeros when reading beyond code', () => {
      const evm = new MockEvm();
      const code = new Uint8Array([0xAA, 0xBB]);

      const frame = new MockFrame(evm, { bytecode: new MockBytecode(code) });
      frame.pushStack(4n); // Length
      frame.pushStack(0n); // Offset
      frame.pushStack(0n); // Dest offset

      codecopy(frame);

      const copied = frame.readMemory(0, 4);
      expect(Array.from(copied)).toEqual([0xAA, 0xBB, 0x00, 0x00]);
    });
  });

  describe('GASPRICE', () => {
    test('returns gas price', () => {
      const evm = new MockEvm();
      evm.gas_price = 20000000000n; // 20 gwei

      const frame = new MockFrame(evm);

      gasprice(frame);

      expect(frame.pc).toBe(1);
      expect(frame.getStack()).toHaveLength(1);
      expect(frame.getStack()[0]).toBe(20000000000n);
    });
  });

  describe('EXTCODESIZE', () => {
    test('returns external code size', () => {
      const evm = new MockEvm();
      const addr = new Uint8Array(20);
      addr[19] = 0x88;

      const code = new Uint8Array([0x60, 0x01, 0x60, 0x02, 0x01]);
      evm.set_code(addr, code);

      const frame = new MockFrame(evm);
      frame.pushStack(0x88n); // Address

      extcodesize(frame);

      expect(frame.pc).toBe(1);
      expect(frame.getStack()[0]).toBe(5n);
    });

    test('returns zero for account with no code', () => {
      const evm = new MockEvm();
      const frame = new MockFrame(evm);
      frame.pushStack(0x99n);

      extcodesize(frame);

      expect(frame.getStack()[0]).toBe(0n);
    });
  });

  describe('EXTCODECOPY', () => {
    test('copies external code to memory', () => {
      const evm = new MockEvm();
      const addr = new Uint8Array(20);
      addr[19] = 0x77;

      const code = new Uint8Array([0xAA, 0xBB, 0xCC, 0xDD]);
      evm.set_code(addr, code);

      const frame = new MockFrame(evm);
      frame.pushStack(4n); // Size
      frame.pushStack(0n); // Offset
      frame.pushStack(0n); // Dest offset
      frame.pushStack(0x77n); // Address

      extcodecopy(frame);

      expect(frame.pc).toBe(1);
      const copied = frame.readMemory(0, 4);
      expect(Array.from(copied)).toEqual([0xAA, 0xBB, 0xCC, 0xDD]);
    });
  });

  describe('RETURNDATASIZE', () => {
    test('returns return data size (Byzantium+)', () => {
      const evm = new MockEvm();
      evm.hardfork = Hardfork.BYZANTIUM;

      const return_data = new Uint8Array(64);
      const frame = new MockFrame(evm, { return_data });

      returndatasize(frame);

      expect(frame.pc).toBe(1);
      expect(frame.getStack()[0]).toBe(64n);
    });

    test('throws error before Byzantium', () => {
      const evm = new MockEvm();
      evm.hardfork = Hardfork.SPURIOUS_DRAGON;

      const frame = new MockFrame(evm);

      expect(() => returndatasize(frame)).toThrow('InvalidOpcode');
    });
  });

  describe('RETURNDATACOPY', () => {
    test('copies return data to memory (Byzantium+)', () => {
      const evm = new MockEvm();
      evm.hardfork = Hardfork.BYZANTIUM;

      const return_data = new Uint8Array([0x11, 0x22, 0x33, 0x44]);
      const frame = new MockFrame(evm, { return_data });

      frame.pushStack(4n); // Length
      frame.pushStack(0n); // Offset
      frame.pushStack(0n); // Dest offset

      returndatacopy(frame);

      expect(frame.pc).toBe(1);
      const copied = frame.readMemory(0, 4);
      expect(Array.from(copied)).toEqual([0x11, 0x22, 0x33, 0x44]);
    });

    test('throws error when reading beyond return data', () => {
      const evm = new MockEvm();
      evm.hardfork = Hardfork.BYZANTIUM;

      const return_data = new Uint8Array([0x11, 0x22]);
      const frame = new MockFrame(evm, { return_data });

      frame.pushStack(4n); // Length (more than return_data)
      frame.pushStack(0n); // Offset
      frame.pushStack(0n); // Dest offset

      expect(() => returndatacopy(frame)).toThrow('OutOfBounds');
    });

    test('throws error before Byzantium', () => {
      const evm = new MockEvm();
      evm.hardfork = Hardfork.SPURIOUS_DRAGON;

      const frame = new MockFrame(evm);
      frame.pushStack(0n);
      frame.pushStack(0n);
      frame.pushStack(0n);

      expect(() => returndatacopy(frame)).toThrow('InvalidOpcode');
    });
  });

  describe('EXTCODEHASH', () => {
    test('returns code hash (Constantinople+)', () => {
      const evm = new MockEvm();
      evm.hardfork = Hardfork.CONSTANTINOPLE;

      const addr = new Uint8Array(20);
      addr[19] = 0x66;

      const code = new Uint8Array([0x60, 0x01]);
      evm.set_code(addr, code);

      const frame = new MockFrame(evm);
      frame.pushStack(0x66n);

      extcodehash(frame);

      expect(frame.pc).toBe(1);
      expect(frame.getStack()).toHaveLength(1);
      // Should be non-zero hash
      expect(frame.getStack()[0]).not.toBe(0n);
    });

    test('returns zero for empty account', () => {
      const evm = new MockEvm();
      evm.hardfork = Hardfork.CONSTANTINOPLE;

      const frame = new MockFrame(evm);
      frame.pushStack(0x99n);

      extcodehash(frame);

      expect(frame.getStack()[0]).toBe(0n);
    });

    test('throws error before Constantinople', () => {
      const evm = new MockEvm();
      evm.hardfork = Hardfork.BYZANTIUM;

      const frame = new MockFrame(evm);
      frame.pushStack(0n);

      expect(() => extcodehash(frame)).toThrow('InvalidOpcode');
    });
  });

  describe('GAS', () => {
    test('returns remaining gas', () => {
      const evm = new MockEvm();
      const frame = new MockFrame(evm);
      frame.gas_remaining = 500000n;

      gas(frame);

      expect(frame.pc).toBe(1);
      expect(frame.getStack()).toHaveLength(1);
      // Gas remaining after consuming 2 gas (GasQuickStep)
      expect(frame.getStack()[0]).toBe(499998n);
    });
  });
});
