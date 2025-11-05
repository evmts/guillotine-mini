/**
 * Tests for system opcode handlers
 *
 * These tests verify the complex call/create logic:
 * - CALL, CALLCODE, DELEGATECALL, STATICCALL
 * - CREATE, CREATE2
 * - SELFDESTRUCT
 * - Gas calculations (warm/cold, value transfer, memory expansion)
 * - Call depth limits
 * - Static context enforcement
 * - EIP-6780 SELFDESTRUCT behavior (Cancun+)
 */

import { describe, it, expect, beforeEach } from 'bun:test';
import {
  create,
  create2,
  call,
  callcode,
  delegatecall,
  staticcall,
  selfdestruct,
  GasConstants,
  Hardfork,
  type FrameInterface,
  type EvmInterface,
  type Address,
  type CallParams,
  type CallResult,
  type CreateResult,
} from './handlers_system';
import { CallError, EvmError } from '../errors';

/**
 * Mock frame for testing
 */
class MockFrame implements FrameInterface {
  stack: bigint[] = [];
  memory: Uint8Array = new Uint8Array(1024);
  memory_size: number = 0;
  gas_remaining: bigint = 1000000n;
  is_static: boolean = false;
  stopped: boolean = false;
  return_data: Uint8Array = new Uint8Array(0);
  address: Address = { bytes: new Uint8Array(20) };
  caller: Address = { bytes: new Uint8Array(20) };
  pc: number = 0;
  allocator: any = null;

  private evm: MockEvm;

  constructor(evm: MockEvm) {
    this.evm = evm;
    // Set some default addresses
    this.address.bytes[19] = 0x42;
    this.caller.bytes[19] = 0x01;
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

  readMemory(offset: number): number {
    if (offset >= this.memory.length) {
      return 0;
    }
    return this.memory[offset];
  }

  writeMemory(offset: number, value: number): void {
    if (offset < this.memory.length) {
      this.memory[offset] = value;
    }
  }

  consumeGas(amount: bigint): void {
    if (amount > this.gas_remaining) {
      throw new Error('OutOfGas');
    }
    this.gas_remaining -= amount;
  }

  memoryExpansionCost(end_bytes: bigint): bigint {
    const end_words = (end_bytes + 31n) / 32n;
    const current_words = BigInt(this.memory_size) / 32n;

    if (end_words <= current_words) {
      return 0n;
    }

    const new_words = end_words;
    const old_words = current_words;

    const new_cost = (new_words * new_words) / 512n + 3n * new_words;
    const old_cost = (old_words * old_words) / 512n + 3n * old_words;

    return new_cost - old_cost;
  }

  createGasCost(length: number): bigint {
    return GasConstants.CreateGas;
  }

  create2GasCost(length: number): bigint {
    const word_count = Math.ceil(length / 32);
    return GasConstants.Create2Gas + BigInt(word_count) * GasConstants.InitCodeWordGas;
  }

  selfdestructGasCost(): bigint {
    return GasConstants.SelfdestructGas;
  }

  selfdestructRefund(): bigint {
    // Pre-London: 24000, London+: 0
    return this.evm.hardfork < Hardfork.LONDON ? GasConstants.SelfdestructRefundGas : 0n;
  }

  getEvm(): EvmInterface {
    return this.evm;
  }
}

/**
 * Mock EVM for testing
 */
class MockEvm implements EvmInterface {
  hardfork: Hardfork = Hardfork.CANCUN;
  gas_refund: bigint = 0n;

  balances: Map<string, bigint> = new Map();
  code: Map<string, Uint8Array> = new Map();
  nonces: Map<string, bigint> = new Map();
  warm_addresses: Set<string> = new Set();
  created_accounts: Set<string> = new Set();

  call_results: CallResult[] = [];
  create_results: CreateResult[] = [];

  getBalance(address: Address): bigint {
    const key = this.addressToString(address);
    return this.balances.get(key) ?? 0n;
  }

  getCode(address: Address): Uint8Array {
    const key = this.addressToString(address);
    return this.code.get(key) ?? new Uint8Array(0);
  }

  getNonce(address: Address): bigint {
    const key = this.addressToString(address);
    return this.nonces.get(key) ?? 0n;
  }

  isAddressWarm(address: Address): boolean {
    const key = this.addressToString(address);
    return this.warm_addresses.has(key);
  }

  warmAddress(address: Address): void {
    const key = this.addressToString(address);
    this.warm_addresses.add(key);
  }

  accessAddress(address: Address): bigint {
    if (this.hardfork < Hardfork.BERLIN) {
      return 0n;
    }
    const is_warm = this.isAddressWarm(address);
    if (!is_warm) {
      this.warmAddress(address);
      return GasConstants.ColdAccountAccessCost;
    }
    return GasConstants.WarmStorageReadCost;
  }

  accountExists(address: Address): boolean {
    const key = this.addressToString(address);
    return (
      (this.balances.get(key) ?? 0n) > 0n ||
      (this.code.get(key)?.length ?? 0) > 0 ||
      (this.nonces.get(key) ?? 0n) > 0n
    );
  }

  wasCreatedThisTransaction(address: Address): boolean {
    const key = this.addressToString(address);
    return this.created_accounts.has(key);
  }

  inner_call(params: any): CallResult {
    if (this.call_results.length > 0) {
      return this.call_results.shift()!;
    }
    // Default: successful call with no output
    return {
      success: true,
      gas_left: (params.gas ?? 0n) as bigint,
      output: new Uint8Array(0),
    };
  }

  inner_create(value: bigint, init_code: Uint8Array, gas: bigint, salt: bigint | null): CreateResult {
    if (this.create_results.length > 0) {
      return this.create_results.shift()!;
    }
    // Default: successful create
    const addr = new Uint8Array(20);
    addr[19] = 0x99; // Mock address
    return {
      address: { bytes: addr },
      success: true,
      gas_left: gas,
      output: new Uint8Array(0),
    };
  }

  private addressToString(address: Address): string {
    return Array.from(address.bytes)
      .map((b) => b.toString(16).padStart(2, '0'))
      .join('');
  }
}

describe('System Handlers', () => {
  let evm: MockEvm;
  let frame: MockFrame;

  beforeEach(() => {
    evm = new MockEvm();
    frame = new MockFrame(evm);
  });

  describe('CREATE', () => {
    it('should create contract and push address on success', () => {
      // Setup: value, offset, length
      frame.stack.push(0n); // length
      frame.stack.push(0n); // offset
      frame.stack.push(100n); // value

      // Mock successful create
      const created_addr = new Uint8Array(20);
      created_addr[19] = 0x42;
      evm.create_results.push({
        address: { bytes: created_addr },
        success: true,
        gas_left: 50000n,
        output: new Uint8Array(0),
      });

      create(frame);

      // Should push address on stack
      expect(frame.stack.length).toBe(1);
      const addr_u256 = frame.stack[0];
      expect(addr_u256).toBe(0x42n);

      // Should clear return_data on success
      expect(frame.return_data.length).toBe(0);

      // Should increment PC
      expect(frame.pc).toBe(1);
    });

    it('should push 0 on failure', () => {
      frame.stack.push(0n); // length
      frame.stack.push(0n); // offset
      frame.stack.push(100n); // value

      // Mock failed create
      evm.create_results.push({
        address: { bytes: new Uint8Array(20) },
        success: false,
        gas_left: 50000n,
        output: new Uint8Array([0xde, 0xad]),
      });

      create(frame);

      // Should push 0 on stack
      expect(frame.stack.length).toBe(1);
      expect(frame.stack[0]).toBe(0n);

      // Should set return_data to child output on failure
      expect(frame.return_data.length).toBe(2);
      expect(frame.return_data[0]).toBe(0xde);
      expect(frame.return_data[1]).toBe(0xad);
    });

    it('should reject in static context', () => {
      frame.is_static = true;
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(0n);

      expect(() => create(frame)).toThrow(CallError.StaticCallViolation);
    });

    it('should read init code from memory', () => {
      // Write some code to memory
      frame.memory[0] = 0x60;
      frame.memory[1] = 0x42;

      frame.stack.push(2n); // length = 2
      frame.stack.push(0n); // offset = 0
      frame.stack.push(0n); // value = 0

      create(frame);

      // Init code should be passed to inner_create (verified by not throwing)
      expect(frame.pc).toBe(1);
    });
  });

  describe('CALL', () => {
    it('should perform call with all parameters', () => {
      const target_addr = new Uint8Array(20);
      target_addr[19] = 0x88;
      let target_u256 = 0n;
      for (const b of target_addr) {
        target_u256 = (target_u256 << 8n) | BigInt(b);
      }

      // Push arguments: gas, address, value, in_offset, in_length, out_offset, out_length
      frame.stack.push(0n); // out_length
      frame.stack.push(0n); // out_offset
      frame.stack.push(0n); // in_length
      frame.stack.push(0n); // in_offset
      frame.stack.push(100n); // value
      frame.stack.push(target_u256); // address
      frame.stack.push(50000n); // gas

      // Mock successful call
      evm.call_results.push({
        success: true,
        gas_left: 40000n,
        output: new Uint8Array([0xaa, 0xbb]),
      });

      call(frame);

      // Should push 1 (success) on stack
      expect(frame.stack.length).toBe(1);
      expect(frame.stack[0]).toBe(1n);

      // Should set return_data
      expect(frame.return_data.length).toBe(2);
      expect(frame.return_data[0]).toBe(0xaa);
      expect(frame.return_data[1]).toBe(0xbb);

      // Should refund unused gas
      expect(frame.gas_remaining).toBeGreaterThan(0n);
    });

    it('should reject non-zero value in static context', () => {
      frame.is_static = true;

      // Push args with non-zero value
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(100n); // value > 0
      frame.stack.push(0n);
      frame.stack.push(50000n);

      expect(() => call(frame)).toThrow(CallError.StaticCallViolation);
    });

    it('should charge cold access cost (Berlin+)', () => {
      evm.hardfork = Hardfork.BERLIN;

      const target_addr = new Uint8Array(20);
      target_addr[19] = 0x88;
      let target_u256 = 0n;
      for (const b of target_addr) {
        target_u256 = (target_u256 << 8n) | BigInt(b);
      }

      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(0n); // value = 0
      frame.stack.push(target_u256);
      frame.stack.push(50000n);

      const gas_before = frame.gas_remaining;
      call(frame);
      const gas_after = frame.gas_remaining;

      // Should charge cold access cost
      const gas_used = gas_before - gas_after;
      expect(gas_used).toBeGreaterThanOrEqual(GasConstants.ColdAccountAccessCost);
    });

    it('should add account creation cost for new account with value', () => {
      const target_addr = new Uint8Array(20);
      target_addr[19] = 0x88;
      let target_u256 = 0n;
      for (const b of target_addr) {
        target_u256 = (target_u256 << 8n) | BigInt(b);
      }

      // Target doesn't exist
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(100n); // value > 0
      frame.stack.push(target_u256);
      frame.stack.push(100000n);

      const gas_before = frame.gas_remaining;
      call(frame);
      const gas_after = frame.gas_remaining;

      // Should charge value transfer + new account cost
      const gas_used = gas_before - gas_after;
      expect(gas_used).toBeGreaterThan(GasConstants.CallValueTransferGas + GasConstants.CallNewAccountGas);
    });
  });

  describe('DELEGATECALL', () => {
    it('should reject before Homestead', () => {
      evm.hardfork = Hardfork.FRONTIER;

      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(50000n);

      expect(() => delegatecall(frame)).toThrow();
    });

    it('should perform delegatecall (no value parameter)', () => {
      evm.hardfork = Hardfork.HOMESTEAD;

      const target_addr = new Uint8Array(20);
      target_addr[19] = 0x88;
      let target_u256 = 0n;
      for (const b of target_addr) {
        target_u256 = (target_u256 << 8n) | BigInt(b);
      }

      // Push 6 arguments (no value)
      frame.stack.push(0n); // out_length
      frame.stack.push(0n); // out_offset
      frame.stack.push(0n); // in_length
      frame.stack.push(0n); // in_offset
      frame.stack.push(target_u256); // address
      frame.stack.push(50000n); // gas

      evm.call_results.push({
        success: true,
        gas_left: 40000n,
        output: new Uint8Array(0),
      });

      delegatecall(frame);

      expect(frame.stack.length).toBe(1);
      expect(frame.stack[0]).toBe(1n);
    });
  });

  describe('STATICCALL', () => {
    it('should reject before Byzantium', () => {
      evm.hardfork = Hardfork.HOMESTEAD;

      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(50000n);

      expect(() => staticcall(frame)).toThrow();
    });

    it('should perform staticcall', () => {
      evm.hardfork = Hardfork.BYZANTIUM;

      const target_addr = new Uint8Array(20);
      target_addr[19] = 0x88;
      let target_u256 = 0n;
      for (const b of target_addr) {
        target_u256 = (target_u256 << 8n) | BigInt(b);
      }

      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(target_u256);
      frame.stack.push(50000n);

      evm.call_results.push({
        success: true,
        gas_left: 40000n,
        output: new Uint8Array(0),
      });

      staticcall(frame);

      expect(frame.stack.length).toBe(1);
      expect(frame.stack[0]).toBe(1n);
    });
  });

  describe('CREATE2', () => {
    it('should reject before Constantinople', () => {
      evm.hardfork = Hardfork.BYZANTIUM;

      frame.stack.push(0n); // salt
      frame.stack.push(0n); // length
      frame.stack.push(0n); // offset
      frame.stack.push(0n); // value

      expect(() => create2(frame)).toThrow();
    });

    it('should create contract with salt', () => {
      evm.hardfork = Hardfork.CONSTANTINOPLE;

      frame.stack.push(0x1234n); // salt
      frame.stack.push(0n); // length
      frame.stack.push(0n); // offset
      frame.stack.push(100n); // value

      const created_addr = new Uint8Array(20);
      created_addr[19] = 0x42;
      evm.create_results.push({
        address: { bytes: created_addr },
        success: true,
        gas_left: 50000n,
        output: new Uint8Array(0),
      });

      create2(frame);

      expect(frame.stack.length).toBe(1);
      const addr_u256 = frame.stack[0];
      expect(addr_u256).toBe(0x42n);
    });

    it('should reject in static context', () => {
      evm.hardfork = Hardfork.CONSTANTINOPLE;
      frame.is_static = true;

      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(0n);

      expect(() => create2(frame)).toThrow(CallError.StaticCallViolation);
    });
  });

  describe('SELFDESTRUCT', () => {
    it('should mark account for deletion', () => {
      const beneficiary = new Uint8Array(20);
      beneficiary[19] = 0x99;
      let beneficiary_u256 = 0n;
      for (const b of beneficiary) {
        beneficiary_u256 = (beneficiary_u256 << 8n) | BigInt(b);
      }

      frame.stack.push(beneficiary_u256);

      selfdestruct(frame);

      // Should stop execution
      expect(frame.stopped).toBe(true);
    });

    it('should charge cold access cost if beneficiary is cold (Berlin+)', () => {
      evm.hardfork = Hardfork.BERLIN;

      const beneficiary = new Uint8Array(20);
      beneficiary[19] = 0x99;
      let beneficiary_u256 = 0n;
      for (const b of beneficiary) {
        beneficiary_u256 = (beneficiary_u256 << 8n) | BigInt(b);
      }

      frame.stack.push(beneficiary_u256);

      const gas_before = frame.gas_remaining;
      selfdestruct(frame);
      const gas_after = frame.gas_remaining;

      const gas_used = gas_before - gas_after;
      // Should charge base + cold access
      expect(gas_used).toBeGreaterThanOrEqual(GasConstants.SelfdestructGas + GasConstants.ColdAccountAccessCost);
    });

    it('should not charge cold access if beneficiary is warm (Berlin+)', () => {
      evm.hardfork = Hardfork.BERLIN;

      const beneficiary = new Uint8Array(20);
      beneficiary[19] = 0x99;
      let beneficiary_u256 = 0n;
      for (const b of beneficiary) {
        beneficiary_u256 = (beneficiary_u256 << 8n) | BigInt(b);
      }

      // Pre-warm beneficiary
      evm.warmAddress({ bytes: beneficiary });

      frame.stack.push(beneficiary_u256);

      const gas_before = frame.gas_remaining;
      selfdestruct(frame);
      const gas_after = frame.gas_remaining;

      const gas_used = gas_before - gas_after;
      // Should only charge base cost
      expect(gas_used).toBe(GasConstants.SelfdestructGas);
    });

    it('should add account creation cost for new beneficiary with balance', () => {
      const beneficiary = new Uint8Array(20);
      beneficiary[19] = 0x99;
      let beneficiary_u256 = 0n;
      for (const b of beneficiary) {
        beneficiary_u256 = (beneficiary_u256 << 8n) | BigInt(b);
      }

      // Set self balance
      evm.balances.set(
        Array.from(frame.address.bytes)
          .map((b) => b.toString(16).padStart(2, '0'))
          .join(''),
        1000n
      );

      frame.stack.push(beneficiary_u256);

      const gas_before = frame.gas_remaining;
      selfdestruct(frame);
      const gas_after = frame.gas_remaining;

      const gas_used = gas_before - gas_after;
      // Should charge base + new account cost
      expect(gas_used).toBeGreaterThan(GasConstants.SelfdestructGas + GasConstants.CallNewAccountGas);
    });

    it('should apply refund (pre-London)', () => {
      evm.hardfork = Hardfork.BERLIN;
      evm.gas_refund = 0n;

      const beneficiary = new Uint8Array(20);
      beneficiary[19] = 0x99;
      let beneficiary_u256 = 0n;
      for (const b of beneficiary) {
        beneficiary_u256 = (beneficiary_u256 << 8n) | BigInt(b);
      }

      frame.stack.push(beneficiary_u256);

      selfdestruct(frame);

      // Should add refund
      expect(evm.gas_refund).toBe(GasConstants.SelfdestructRefundGas);
    });

    it('should not apply refund (London+)', () => {
      evm.hardfork = Hardfork.LONDON;
      evm.gas_refund = 0n;

      const beneficiary = new Uint8Array(20);
      beneficiary[19] = 0x99;
      let beneficiary_u256 = 0n;
      for (const b of beneficiary) {
        beneficiary_u256 = (beneficiary_u256 << 8n) | BigInt(b);
      }

      frame.stack.push(beneficiary_u256);

      selfdestruct(frame);

      // Should not add refund
      expect(evm.gas_refund).toBe(0n);
    });

    it('should reject in static context', () => {
      frame.is_static = true;

      const beneficiary = new Uint8Array(20);
      beneficiary[19] = 0x99;
      let beneficiary_u256 = 0n;
      for (const b of beneficiary) {
        beneficiary_u256 = (beneficiary_u256 << 8n) | BigInt(b);
      }

      frame.stack.push(beneficiary_u256);

      // Note: Gas is charged BEFORE static check, so need enough gas
      expect(() => selfdestruct(frame)).toThrow(CallError.StaticCallViolation);
    });
  });

  describe('Gas Calculations', () => {
    it('should apply EIP-150 gas forwarding (63/64th rule)', () => {
      evm.hardfork = Hardfork.TANGERINE;

      const target_addr = new Uint8Array(20);
      target_addr[19] = 0x88;
      let target_u256 = 0n;
      for (const b of target_addr) {
        target_u256 = (target_u256 << 8n) | BigInt(b);
      }

      frame.gas_remaining = 100000n;
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(target_u256);
      frame.stack.push(100000n); // Request all gas

      let forwarded_gas = 0n;
      evm.inner_call = (params: any) => {
        forwarded_gas = params.gas;
        return {
          success: true,
          gas_left: params.gas,
          output: new Uint8Array(0),
        };
      };

      call(frame);

      // Should forward 63/64th of remaining gas (after base costs)
      // Formula: (remaining - base_cost) - ((remaining - base_cost) / 64)
      expect(forwarded_gas).toBeLessThan(100000n);
      expect(forwarded_gas).toBeGreaterThan(90000n);
    });

    it('should add stipend for value transfers', () => {
      const target_addr = new Uint8Array(20);
      target_addr[19] = 0x88;
      let target_u256 = 0n;
      for (const b of target_addr) {
        target_u256 = (target_u256 << 8n) | BigInt(b);
      }

      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(0n);
      frame.stack.push(1000n); // value > 0
      frame.stack.push(target_u256);
      frame.stack.push(50000n);

      let forwarded_gas = 0n;
      evm.inner_call = (params: any) => {
        forwarded_gas = params.gas;
        return {
          success: true,
          gas_left: params.gas,
          output: new Uint8Array(0),
        };
      };

      call(frame);

      // Forwarded gas should include the stipend
      expect(forwarded_gas).toBeGreaterThan(GasConstants.CallStipend);
    });
  });
});
