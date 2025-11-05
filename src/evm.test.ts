/**
 * EVM Integration Tests
 *
 * Comprehensive end-to-end tests for the EVM implementation covering:
 * - Basic execution (arithmetic, stack, memory, storage)
 * - Nested calls (CALL, DELEGATECALL, STATICCALL)
 * - Contract creation (CREATE, CREATE2)
 * - Gas metering and out-of-gas handling
 * - Hardfork-specific features
 * - Precompiles
 * - Edge cases and error conditions
 */

import { describe, it, expect, beforeEach } from 'bun:test';
import type { HostInterface, Address } from './host.js';
import { addressFromHex, addressToHex } from './host.js';
import type { CallResult } from './call-result.js';
import { Hardfork } from './evm-config.js';
import {
  STOP, ADD, MUL, SUB, DIV, PUSH1, PUSH2, PUSH32, POP,
  DUP1, DUP2, SWAP1, SWAP2, MLOAD, MSTORE, MSTORE8,
  SLOAD, SSTORE, JUMP, JUMPI, JUMPDEST, RETURN, REVERT,
  CALL, DELEGATECALL, STATICCALL, CREATE, CREATE2,
  TLOAD, TSTORE, MCOPY, PUSH0, SELFDESTRUCT,
  LOG0, LOG1, LOG2, LOG3, LOG4,
} from './opcode.js';

/**
 * Mock host implementation for testing
 */
class TestHost implements HostInterface {
  private balances = new Map<string, bigint>();
  private codes = new Map<string, Uint8Array>();
  private storage = new Map<string, Map<string, bigint>>();
  private nonces = new Map<string, bigint>();

  private addressKey(address: Address): string {
    return addressToHex(address);
  }

  getBalance(address: Address): bigint {
    return this.balances.get(this.addressKey(address)) ?? 0n;
  }

  setBalance(address: Address, balance: bigint): void {
    this.balances.set(this.addressKey(address), balance);
  }

  getCode(address: Address): Uint8Array {
    return this.codes.get(this.addressKey(address)) ?? new Uint8Array(0);
  }

  setCode(address: Address, code: Uint8Array): void {
    this.codes.set(this.addressKey(address), code);
  }

  getStorage(address: Address, slot: bigint): bigint {
    const addrKey = this.addressKey(address);
    const slotMap = this.storage.get(addrKey);
    if (!slotMap) return 0n;
    return slotMap.get(slot.toString(16)) ?? 0n;
  }

  setStorage(address: Address, slot: bigint, value: bigint): void {
    const addrKey = this.addressKey(address);
    let slotMap = this.storage.get(addrKey);
    if (!slotMap) {
      slotMap = new Map();
      this.storage.set(addrKey, slotMap);
    }
    slotMap.set(slot.toString(16), value);
  }

  getNonce(address: Address): bigint {
    return this.nonces.get(this.addressKey(address)) ?? 0n;
  }

  setNonce(address: Address, nonce: bigint): void {
    this.nonces.set(this.addressKey(address), nonce);
  }

  clear(): void {
    this.balances.clear();
    this.codes.clear();
    this.storage.clear();
    this.nonces.clear();
  }
}

/**
 * Helper to build bytecode from opcodes
 */
function bytecode(...ops: (number | number[])[]): Uint8Array {
  const bytes: number[] = [];
  for (const op of ops) {
    if (Array.isArray(op)) {
      bytes.push(...op);
    } else {
      bytes.push(op);
    }
  }
  return new Uint8Array(bytes);
}

/**
 * Helper to encode a u256 value as 32 bytes (big-endian)
 */
function encodeU256(value: bigint): number[] {
  const bytes: number[] = [];
  let v = value;
  for (let i = 0; i < 32; i++) {
    bytes.unshift(Number(v & 0xFFn));
    v >>= 8n;
  }
  return bytes;
}

/**
 * Helper to decode a u256 value from bytes (big-endian)
 */
function decodeU256(bytes: Uint8Array, offset = 0): bigint {
  let value = 0n;
  for (let i = 0; i < 32 && offset + i < bytes.length; i++) {
    value = (value << 8n) | BigInt(bytes[offset + i]);
  }
  return value;
}

/**
 * Placeholder EVM interface (to be implemented)
 * Tests assume an EVM class with this interface will exist
 */
interface IEvm {
  execute(
    bytecode: Uint8Array,
    options?: {
      gas?: bigint;
      caller?: Address;
      address?: Address;
      value?: bigint;
      input?: Uint8Array;
      hardfork?: Hardfork;
    }
  ): CallResult;
}

/**
 * Stub EVM implementation for testing structure
 * NOTE: This is a placeholder - real implementation needed
 */
class StubEvm implements IEvm {
  constructor(private host: HostInterface) {}

  execute(
    bytecode: Uint8Array,
    options?: {
      gas?: bigint;
      caller?: Address;
      address?: Address;
      value?: bigint;
      input?: Uint8Array;
      hardfork?: Hardfork;
    }
  ): CallResult {
    // Stub implementation - real EVM needed
    throw new Error('EVM implementation not yet available');
  }
}

// Skip all tests until EVM implementation is available
const testOrSkip = describe.skip;

testOrSkip('EVM Integration Tests', () => {
  let host: TestHost;
  let evm: IEvm;
  let testAddr: Address;

  beforeEach(() => {
    host = new TestHost();
    evm = new StubEvm(host);
    testAddr = addressFromHex('0x1000000000000000000000000000000000000001');
  });

  describe('1. Basic Execution', () => {
    it('should execute simple ADD operation', () => {
      // PUSH1 5, PUSH1 3, ADD, PUSH1 0, MSTORE, PUSH1 32, PUSH1 0, RETURN
      const code = bytecode(
        PUSH1, 0x05,
        PUSH1, 0x03,
        ADD,
        PUSH1, 0x00,
        MSTORE,
        PUSH1, 0x20,
        PUSH1, 0x00,
        RETURN
      );

      const result = evm.execute(code, { gas: 100000n });

      expect(result.success).toBe(true);
      expect(result.output.length).toBe(32);
      expect(decodeU256(result.output)).toBe(8n); // 5 + 3
    });

    it('should execute MUL operation', () => {
      // PUSH1 7, PUSH1 6, MUL, PUSH1 0, MSTORE, PUSH1 32, PUSH1 0, RETURN
      const code = bytecode(
        PUSH1, 0x07,
        PUSH1, 0x06,
        MUL,
        PUSH1, 0x00,
        MSTORE,
        PUSH1, 0x20,
        PUSH1, 0x00,
        RETURN
      );

      const result = evm.execute(code, { gas: 100000n });

      expect(result.success).toBe(true);
      expect(decodeU256(result.output)).toBe(42n); // 7 * 6
    });

    it('should execute SUB operation', () => {
      // PUSH1 10, PUSH1 3, SUB, PUSH1 0, MSTORE, PUSH1 32, PUSH1 0, RETURN
      const code = bytecode(
        PUSH1, 0x0A,
        PUSH1, 0x03,
        SUB,
        PUSH1, 0x00,
        MSTORE,
        PUSH1, 0x20,
        PUSH1, 0x00,
        RETURN
      );

      const result = evm.execute(code, { gas: 100000n });

      expect(result.success).toBe(true);
      expect(decodeU256(result.output)).toBe(7n); // 10 - 3
    });

    it('should execute DIV operation', () => {
      // PUSH1 5, PUSH1 20, DIV, PUSH1 0, MSTORE, PUSH1 32, PUSH1 0, RETURN
      const code = bytecode(
        PUSH1, 0x05,
        PUSH1, 0x14,
        DIV,
        PUSH1, 0x00,
        MSTORE,
        PUSH1, 0x20,
        PUSH1, 0x00,
        RETURN
      );

      const result = evm.execute(code, { gas: 100000n });

      expect(result.success).toBe(true);
      expect(decodeU256(result.output)).toBe(4n); // 20 / 5
    });

    it('should handle stack operations (DUP, SWAP)', () => {
      // PUSH1 1, PUSH1 2, PUSH1 3, SWAP2, POP, POP, PUSH1 0, MSTORE, PUSH1 32, PUSH1 0, RETURN
      // Stack: [1, 2, 3] -> [3, 2, 1] (after SWAP2) -> [3] (after 2 POPs)
      const code = bytecode(
        PUSH1, 0x01,
        PUSH1, 0x02,
        PUSH1, 0x03,
        SWAP2,
        POP,
        POP,
        PUSH1, 0x00,
        MSTORE,
        PUSH1, 0x20,
        PUSH1, 0x00,
        RETURN
      );

      const result = evm.execute(code, { gas: 100000n });

      expect(result.success).toBe(true);
      expect(decodeU256(result.output)).toBe(3n);
    });

    it('should handle memory operations (MLOAD, MSTORE)', () => {
      // PUSH1 0x42, PUSH1 0x20, MSTORE, PUSH1 0x20, MLOAD, PUSH1 0, MSTORE, PUSH1 32, PUSH1 0, RETURN
      const code = bytecode(
        PUSH1, 0x42,
        PUSH1, 0x20,
        MSTORE,
        PUSH1, 0x20,
        MLOAD,
        PUSH1, 0x00,
        MSTORE,
        PUSH1, 0x20,
        PUSH1, 0x00,
        RETURN
      );

      const result = evm.execute(code, { gas: 100000n });

      expect(result.success).toBe(true);
      expect(decodeU256(result.output)).toBe(0x42n);
    });

    it('should handle MSTORE8 operation', () => {
      // PUSH1 0xFF, PUSH1 0, MSTORE8, PUSH1 1, PUSH1 0, RETURN
      const code = bytecode(
        PUSH1, 0xFF,
        PUSH1, 0x00,
        MSTORE8,
        PUSH1, 0x01,
        PUSH1, 0x00,
        RETURN
      );

      const result = evm.execute(code, { gas: 100000n });

      expect(result.success).toBe(true);
      expect(result.output.length).toBe(1);
      expect(result.output[0]).toBe(0xFF);
    });

    it('should handle storage operations (SLOAD, SSTORE)', () => {
      // PUSH1 0x42, PUSH1 0, SSTORE, PUSH1 0, SLOAD, PUSH1 0, MSTORE, PUSH1 32, PUSH1 0, RETURN
      const code = bytecode(
        PUSH1, 0x42,
        PUSH1, 0x00,
        SSTORE,
        PUSH1, 0x00,
        SLOAD,
        PUSH1, 0x00,
        MSTORE,
        PUSH1, 0x20,
        PUSH1, 0x00,
        RETURN
      );

      const result = evm.execute(code, { gas: 100000n, address: testAddr });

      expect(result.success).toBe(true);
      expect(decodeU256(result.output)).toBe(0x42n);
      expect(host.getStorage(testAddr, 0n)).toBe(0x42n);
    });

    it('should handle control flow (JUMP, JUMPI)', () => {
      // PUSH1 8, JUMP, INVALID, JUMPDEST, PUSH1 0x42, PUSH1 0, MSTORE, PUSH1 32, PUSH1 0, RETURN
      const code = bytecode(
        PUSH1, 0x08,
        JUMP,
        0xFE, // INVALID (should be skipped)
        JUMPDEST,
        PUSH1, 0x42,
        PUSH1, 0x00,
        MSTORE,
        PUSH1, 0x20,
        PUSH1, 0x00,
        RETURN
      );

      const result = evm.execute(code, { gas: 100000n });

      expect(result.success).toBe(true);
      expect(decodeU256(result.output)).toBe(0x42n);
    });

    it('should handle conditional jump (JUMPI)', () => {
      // PUSH1 1, PUSH1 10, JUMPI, PUSH1 0xFF, PUSH1 0, MSTORE, JUMP to end, JUMPDEST, PUSH1 0x42, PUSH1 0, MSTORE, ...
      const code = bytecode(
        PUSH1, 0x01, // condition (true)
        PUSH1, 0x0C, // jump target
        JUMPI,
        PUSH1, 0xFF, // skipped
        PUSH1, 0x00,
        MSTORE,
        PUSH1, 0x14,
        JUMP,
        JUMPDEST,
        PUSH1, 0x42,
        PUSH1, 0x00,
        MSTORE,
        JUMPDEST,
        PUSH1, 0x20,
        PUSH1, 0x00,
        RETURN
      );

      const result = evm.execute(code, { gas: 100000n });

      expect(result.success).toBe(true);
      expect(decodeU256(result.output)).toBe(0x42n);
    });
  });

  describe('2. Nested Calls', () => {
    it('should execute CALL with value transfer', () => {
      const callerAddr = addressFromHex('0x1000000000000000000000000000000000000001');
      const calleeAddr = addressFromHex('0x2000000000000000000000000000000000000002');

      // Set up balances
      host.setBalance(callerAddr, 1000000n);

      // Callee code: return the value received
      // CALLVALUE, PUSH1 0, MSTORE, PUSH1 32, PUSH1 0, RETURN
      const calleeCode = bytecode(
        0x34, // CALLVALUE
        PUSH1, 0x00,
        MSTORE,
        PUSH1, 0x20,
        PUSH1, 0x00,
        RETURN
      );
      host.setCode(calleeAddr, calleeCode);

      // Caller code: CALL with value 100
      // PUSH1 0, PUSH1 0, PUSH1 32, PUSH1 0, PUSH1 100, PUSH20 <callee>, PUSH2 10000, CALL, ...
      const callerCode = bytecode(
        PUSH1, 0x00, // retSize
        PUSH1, 0x00, // retOffset
        PUSH1, 0x00, // argSize
        PUSH1, 0x00, // argOffset
        PUSH1, 0x64, // value (100)
        ...[0x73, ...Array.from(calleeAddr)], // PUSH20 callee address
        PUSH2, 0x27, 0x10, // gas (10000)
        0xF1, // CALL
        PUSH1, 0x20,
        PUSH1, 0x00,
        RETURN
      );

      const result = evm.execute(callerCode, {
        gas: 100000n,
        address: callerAddr,
      });

      expect(result.success).toBe(true);
      expect(decodeU256(result.output)).toBe(100n); // Value received by callee
      expect(host.getBalance(calleeAddr)).toBe(100n);
      expect(host.getBalance(callerAddr)).toBeLessThan(1000000n - 100n);
    });

    it('should execute DELEGATECALL preserving context', () => {
      const callerAddr = addressFromHex('0x1000000000000000000000000000000000000001');
      const calleeAddr = addressFromHex('0x2000000000000000000000000000000000000002');

      // Callee code: SSTORE slot 0 with value 0x42
      // PUSH1 0x42, PUSH1 0, SSTORE, STOP
      const calleeCode = bytecode(
        PUSH1, 0x42,
        PUSH1, 0x00,
        SSTORE,
        STOP
      );
      host.setCode(calleeAddr, calleeCode);

      // Caller code: DELEGATECALL to callee
      const callerCode = bytecode(
        PUSH1, 0x00, // retSize
        PUSH1, 0x00, // retOffset
        PUSH1, 0x00, // argSize
        PUSH1, 0x00, // argOffset
        ...[0x73, ...Array.from(calleeAddr)], // PUSH20 callee address
        PUSH2, 0x27, 0x10, // gas (10000)
        0xF4, // DELEGATECALL
        STOP
      );

      const result = evm.execute(callerCode, {
        gas: 100000n,
        address: callerAddr,
      });

      expect(result.success).toBe(true);
      // Storage should be modified in caller's context
      expect(host.getStorage(callerAddr, 0n)).toBe(0x42n);
      // Callee's storage should be unchanged
      expect(host.getStorage(calleeAddr, 0n)).toBe(0n);
    });

    it('should execute STATICCALL with read-only restriction', () => {
      const callerAddr = addressFromHex('0x1000000000000000000000000000000000000001');
      const calleeAddr = addressFromHex('0x2000000000000000000000000000000000000002');

      // Callee code: Try to SSTORE (should fail in static context)
      // PUSH1 0x42, PUSH1 0, SSTORE, STOP
      const calleeCode = bytecode(
        PUSH1, 0x42,
        PUSH1, 0x00,
        SSTORE,
        STOP
      );
      host.setCode(calleeAddr, calleeCode);

      // Caller code: STATICCALL to callee
      const callerCode = bytecode(
        PUSH1, 0x00, // retSize
        PUSH1, 0x00, // retOffset
        PUSH1, 0x00, // argSize
        PUSH1, 0x00, // argOffset
        ...[0x73, ...Array.from(calleeAddr)], // PUSH20 callee address
        PUSH2, 0x27, 0x10, // gas (10000)
        0xFA, // STATICCALL
        PUSH1, 0x20,
        PUSH1, 0x00,
        RETURN
      );

      const result = evm.execute(callerCode, {
        gas: 100000n,
        address: callerAddr,
      });

      // Call should fail due to write in static context
      expect(result.success).toBe(false);
    });

    it('should enforce call depth limit (1024)', () => {
      // Create recursive CALL contract
      const addr = addressFromHex('0x1000000000000000000000000000000000000001');

      // Code that calls itself
      const code = bytecode(
        PUSH1, 0x00, // retSize
        PUSH1, 0x00, // retOffset
        PUSH1, 0x00, // argSize
        PUSH1, 0x00, // argOffset
        PUSH1, 0x00, // value
        ...[0x73, ...Array.from(addr)], // PUSH20 self address
        PUSH2, 0x27, 0x10, // gas (10000)
        0xF1, // CALL
        STOP
      );
      host.setCode(addr, code);

      const result = evm.execute(code, {
        gas: 10000000n,
        address: addr,
      });

      // Should fail due to call depth limit
      expect(result.success).toBe(false);
    });

    it('should handle revert in nested call', () => {
      const callerAddr = addressFromHex('0x1000000000000000000000000000000000000001');
      const calleeAddr = addressFromHex('0x2000000000000000000000000000000000000002');

      // Callee code: REVERT with data
      // PUSH1 0x42, PUSH1 0, MSTORE, PUSH1 32, PUSH1 0, REVERT
      const calleeCode = bytecode(
        PUSH1, 0x42,
        PUSH1, 0x00,
        MSTORE,
        PUSH1, 0x20,
        PUSH1, 0x00,
        REVERT
      );
      host.setCode(calleeAddr, calleeCode);

      // Caller code: CALL to callee, return CALL result
      const callerCode = bytecode(
        PUSH1, 0x20, // retSize
        PUSH1, 0x00, // retOffset
        PUSH1, 0x00, // argSize
        PUSH1, 0x00, // argOffset
        PUSH1, 0x00, // value
        ...[0x73, ...Array.from(calleeAddr)], // PUSH20 callee address
        PUSH2, 0x27, 0x10, // gas (10000)
        0xF1, // CALL
        PUSH1, 0x00,
        MSTORE,
        PUSH1, 0x20,
        PUSH1, 0x00,
        RETURN
      );

      const result = evm.execute(callerCode, {
        gas: 100000n,
        address: callerAddr,
      });

      expect(result.success).toBe(true);
      // CALL should return 0 (failure) on stack
      expect(decodeU256(result.output)).toBe(0n);
    });
  });

  describe('3. Contract Creation', () => {
    it('should execute CREATE with init code', () => {
      const addr = addressFromHex('0x1000000000000000000000000000000000000001');

      // Init code: return runtime code
      // Runtime code: PUSH1 0x42, PUSH1 0, MSTORE, PUSH1 32, PUSH1 0, RETURN
      const runtimeCode = bytecode(
        PUSH1, 0x42,
        PUSH1, 0x00,
        MSTORE,
        PUSH1, 0x20,
        PUSH1, 0x00,
        RETURN
      );

      // Init code: PUSH runtime code to memory, return it
      const initCode = bytecode(
        ...encodeU256(BigInt(runtimeCode.length)).map((b, i) =>
          i === 0 ? [PUSH1, b] : [b]
        ).flat(),
        PUSH1, 0x00,
        MSTORE,
        // Copy runtime code to memory
        ...runtimeCode.flatMap((byte, i) =>
          [PUSH1, byte, PUSH1, 0x20 + i, MSTORE8]
        ),
        PUSH1, runtimeCode.length,
        PUSH1, 0x20,
        RETURN
      );

      // Creator code: CREATE contract
      const creatorCode = bytecode(
        ...encodeU256(BigInt(initCode.length)).map((b, i) =>
          i === 0 ? [PUSH1, b] : [b]
        ).flat(),
        PUSH1, 0x00,
        MSTORE,
        // Copy init code to memory
        ...initCode.flatMap((byte, i) =>
          [PUSH1, byte, PUSH1, 0x20 + i, MSTORE8]
        ),
        PUSH1, initCode.length,
        PUSH1, 0x20,
        PUSH1, 0x00, // value
        CREATE,
        STOP
      );

      const result = evm.execute(creatorCode, {
        gas: 1000000n,
        address: addr,
      });

      expect(result.success).toBe(true);
      expect(result.created_address).toBeDefined();
    });

    it('should execute CREATE2 with salt', () => {
      const addr = addressFromHex('0x1000000000000000000000000000000000000001');

      // Simple init code that returns empty runtime code
      const initCode = bytecode(
        PUSH1, 0x00,
        PUSH1, 0x00,
        RETURN
      );

      // Creator code: CREATE2 with salt
      const creatorCode = bytecode(
        PUSH1, 0x42, // salt
        PUSH1, initCode.length,
        PUSH1, 0x00,
        PUSH1, 0x00, // value
        CREATE2,
        STOP
      );

      const result = evm.execute(creatorCode, {
        gas: 1000000n,
        address: addr,
      });

      expect(result.success).toBe(true);
      expect(result.created_address).toBeDefined();
    });

    it('should enforce init code size limit (EIP-3860)', () => {
      const addr = addressFromHex('0x1000000000000000000000000000000000000001');

      // Create init code that exceeds MAX_INITCODE_SIZE (49152 bytes)
      const tooLargeInitCode = new Uint8Array(50000);

      // Creator code: CREATE with too large init code
      const creatorCode = bytecode(
        PUSH2, 0xC3, 0x50, // size (50000)
        PUSH1, 0x00,
        PUSH1, 0x00, // value
        CREATE,
        STOP
      );

      const result = evm.execute(creatorCode, {
        gas: 1000000n,
        address: addr,
        hardfork: Hardfork.SHANGHAI, // EIP-3860 active
      });

      expect(result.success).toBe(false);
    });

    it('should enforce contract code size limit (EIP-170)', () => {
      const addr = addressFromHex('0x1000000000000000000000000000000000000001');

      // Init code that returns code exceeding MAX_CODE_SIZE (24576 bytes)
      const tooLargeRuntimeCode = new Uint8Array(25000);

      // Init code returns too large runtime code
      const initCode = bytecode(
        PUSH2, 0x61, 0xA8, // size (25000)
        PUSH1, 0x00,
        RETURN
      );

      const result = evm.execute(initCode, {
        gas: 1000000n,
        address: addr,
      });

      expect(result.success).toBe(false);
    });

    it('should detect address collision (EIP-684)', () => {
      const addr = addressFromHex('0x1000000000000000000000000000000000000001');
      const existingAddr = addressFromHex('0x2000000000000000000000000000000000000002');

      // Set up existing contract at address
      host.setCode(existingAddr, bytecode(PUSH1, 0x42));
      host.setNonce(existingAddr, 1n);

      // Try to CREATE at same address (simplified - actual address calculation differs)
      const initCode = bytecode(
        PUSH1, 0x00,
        PUSH1, 0x00,
        RETURN
      );

      // This test assumes CREATE would collide - actual behavior depends on address calculation
      const result = evm.execute(initCode, {
        gas: 1000000n,
        address: addr,
      });

      // If collision detected, CREATE should fail
      // Actual test needs real address calculation
    });
  });

  describe('4. Gas Metering', () => {
    it('should handle out of gas', () => {
      // Simple code that uses more than available gas
      const code = bytecode(
        PUSH1, 0x42,
        PUSH1, 0x00,
        MSTORE,
        PUSH1, 0x20,
        PUSH1, 0x00,
        RETURN
      );

      const result = evm.execute(code, { gas: 10n }); // Very low gas

      expect(result.success).toBe(false);
      expect(result.gas_left).toBe(0n);
    });

    it('should calculate SSTORE gas refunds correctly', () => {
      const addr = addressFromHex('0x1000000000000000000000000000000000000001');

      // Set storage slot 0 to 0x42
      host.setStorage(addr, 0n, 0x42n);

      // Clear storage slot (should get refund)
      // PUSH1 0, PUSH1 0, SSTORE, STOP
      const code = bytecode(
        PUSH1, 0x00,
        PUSH1, 0x00,
        SSTORE,
        STOP
      );

      const result = evm.execute(code, {
        gas: 100000n,
        address: addr,
      });

      expect(result.success).toBe(true);
      expect(result.refund_counter).toBeGreaterThan(0n); // Should have refund
    });

    it('should charge memory expansion costs', () => {
      // Expand memory significantly
      // PUSH2 0x1000, PUSH1 0, MSTORE
      const code = bytecode(
        PUSH2, 0x10, 0x00,
        PUSH1, 0x00,
        MSTORE,
        STOP
      );

      const lowGasResult = evm.execute(code, { gas: 100n });
      const highGasResult = evm.execute(code, { gas: 100000n });

      expect(lowGasResult.success).toBe(false); // Out of gas
      expect(highGasResult.success).toBe(true);
    });

    it('should provide call stipend for value transfer', () => {
      const callerAddr = addressFromHex('0x1000000000000000000000000000000000000001');
      const calleeAddr = addressFromHex('0x2000000000000000000000000000000000000002');

      host.setBalance(callerAddr, 1000000n);

      // Callee code: STOP (minimal gas usage)
      const calleeCode = bytecode(STOP);
      host.setCode(calleeAddr, calleeCode);

      // Caller code: CALL with value but minimal gas
      const callerCode = bytecode(
        PUSH1, 0x00, // retSize
        PUSH1, 0x00, // retOffset
        PUSH1, 0x00, // argSize
        PUSH1, 0x00, // argOffset
        PUSH1, 0x64, // value (100)
        ...[0x73, ...Array.from(calleeAddr)], // PUSH20 callee
        PUSH1, 0x00, // gas (0 - but stipend of 2300 should be provided)
        CALL,
        STOP
      );

      const result = evm.execute(callerCode, {
        gas: 100000n,
        address: callerAddr,
      });

      // Should succeed with stipend
      expect(result.success).toBe(true);
    });
  });

  describe('5. Hardfork Features', () => {
    it('should support PUSH0 (Shanghai+)', () => {
      // PUSH0, PUSH1 0, MSTORE, PUSH1 32, PUSH1 0, RETURN
      const code = bytecode(
        PUSH0,
        PUSH1, 0x00,
        MSTORE,
        PUSH1, 0x20,
        PUSH1, 0x00,
        RETURN
      );

      const resultShanghai = evm.execute(code, {
        gas: 100000n,
        hardfork: Hardfork.SHANGHAI,
      });

      expect(resultShanghai.success).toBe(true);
      expect(decodeU256(resultShanghai.output)).toBe(0n);

      // Should fail pre-Shanghai
      const resultBerlin = evm.execute(code, {
        gas: 100000n,
        hardfork: Hardfork.BERLIN,
      });

      expect(resultBerlin.success).toBe(false); // Invalid opcode
    });

    it('should support TLOAD/TSTORE (Cancun+)', () => {
      // PUSH1 0x42, PUSH1 0, TSTORE, PUSH1 0, TLOAD, PUSH1 0, MSTORE, PUSH1 32, PUSH1 0, RETURN
      const code = bytecode(
        PUSH1, 0x42,
        PUSH1, 0x00,
        TSTORE,
        PUSH1, 0x00,
        TLOAD,
        PUSH1, 0x00,
        MSTORE,
        PUSH1, 0x20,
        PUSH1, 0x00,
        RETURN
      );

      const resultCancun = evm.execute(code, {
        gas: 100000n,
        hardfork: Hardfork.CANCUN,
      });

      expect(resultCancun.success).toBe(true);
      expect(decodeU256(resultCancun.output)).toBe(0x42n);

      // Should fail pre-Cancun
      const resultShanghai = evm.execute(code, {
        gas: 100000n,
        hardfork: Hardfork.SHANGHAI,
      });

      expect(resultShanghai.success).toBe(false); // Invalid opcode
    });

    it('should support MCOPY (Cancun+)', () => {
      // PUSH1 0x42, PUSH1 0, MSTORE, PUSH1 32, PUSH1 32, PUSH1 0, MCOPY, PUSH1 32, PUSH1 32, RETURN
      const code = bytecode(
        PUSH1, 0x42,
        PUSH1, 0x00,
        MSTORE,
        PUSH1, 0x20, // size
        PUSH1, 0x20, // src
        PUSH1, 0x00, // dst
        MCOPY,
        PUSH1, 0x20,
        PUSH1, 0x20,
        RETURN
      );

      const resultCancun = evm.execute(code, {
        gas: 100000n,
        hardfork: Hardfork.CANCUN,
      });

      expect(resultCancun.success).toBe(true);
      expect(decodeU256(resultCancun.output)).toBe(0x42n);
    });

    it('should enforce EIP-2929 warm/cold access (Berlin+)', () => {
      const addr = addressFromHex('0x1000000000000000000000000000000000000001');

      // SLOAD twice from same slot - second should be cheaper (warm)
      // PUSH1 0, SLOAD, POP, PUSH1 0, SLOAD, STOP
      const code = bytecode(
        PUSH1, 0x00,
        SLOAD,
        POP,
        PUSH1, 0x00,
        SLOAD,
        STOP
      );

      const resultBerlin = evm.execute(code, {
        gas: 100000n,
        address: addr,
        hardfork: Hardfork.BERLIN,
      });

      const resultIstanbul = evm.execute(code, {
        gas: 100000n,
        address: addr,
        hardfork: Hardfork.ISTANBUL,
      });

      expect(resultBerlin.success).toBe(true);
      expect(resultIstanbul.success).toBe(true);
      // Berlin should use less gas due to warm access
      expect(resultBerlin.gas_left).toBeGreaterThan(resultIstanbul.gas_left);
    });

    it('should enforce EIP-6780 SELFDESTRUCT (Cancun+)', () => {
      const addr = addressFromHex('0x1000000000000000000000000000000000000001');
      const beneficiary = addressFromHex('0x2000000000000000000000000000000000000002');

      host.setBalance(addr, 1000n);

      // SELFDESTRUCT
      const code = bytecode(
        ...[0x73, ...Array.from(beneficiary)], // PUSH20 beneficiary
        SELFDESTRUCT
      );

      const resultCancun = evm.execute(code, {
        gas: 100000n,
        address: addr,
        hardfork: Hardfork.CANCUN,
      });

      // Post-Cancun: SELFDESTRUCT only works in same transaction as creation
      // Should succeed but not actually destroy (unless created in same tx)
      expect(resultCancun.success).toBe(true);
      // Balance transfer should still happen
      expect(host.getBalance(beneficiary)).toBe(1000n);
    });
  });

  describe('6. Precompiles', () => {
    it('should execute ECRECOVER precompile', () => {
      // Address 0x01 - ECRECOVER
      const ecrecoverAddr = addressFromHex('0x0000000000000000000000000000000000000001');

      // Prepare call to ECRECOVER
      // Input: hash (32 bytes) + v (32 bytes) + r (32 bytes) + s (32 bytes)
      const callerCode = bytecode(
        PUSH1, 0x20, // retSize
        PUSH1, 0x00, // retOffset
        PUSH1, 0x80, // argSize (128 bytes)
        PUSH1, 0x00, // argOffset
        PUSH1, 0x00, // value
        ...[0x73, ...Array.from(ecrecoverAddr)],
        PUSH2, 0x27, 0x10, // gas
        CALL,
        PUSH1, 0x20,
        PUSH1, 0x00,
        RETURN
      );

      // Note: Need valid signature data for real test
      const result = evm.execute(callerCode, { gas: 100000n });

      // Should execute (result depends on input data)
      expect(result.gas_left).toBeLessThan(100000n); // Some gas used
    });

    it('should execute SHA256 precompile', () => {
      const sha256Addr = addressFromHex('0x0000000000000000000000000000000000000002');

      // Call SHA256 with empty input
      const callerCode = bytecode(
        PUSH1, 0x20, // retSize
        PUSH1, 0x00, // retOffset
        PUSH1, 0x00, // argSize
        PUSH1, 0x00, // argOffset
        PUSH1, 0x00, // value
        ...[0x73, ...Array.from(sha256Addr)],
        PUSH2, 0x27, 0x10,
        CALL,
        PUSH1, 0x20,
        PUSH1, 0x00,
        RETURN
      );

      const result = evm.execute(callerCode, { gas: 100000n });

      expect(result.success).toBe(true);
      expect(result.output.length).toBe(32);
    });

    it('should execute RIPEMD160 precompile', () => {
      const ripemd160Addr = addressFromHex('0x0000000000000000000000000000000000000003');

      const callerCode = bytecode(
        PUSH1, 0x20, // retSize
        PUSH1, 0x00, // retOffset
        PUSH1, 0x00, // argSize
        PUSH1, 0x00, // argOffset
        PUSH1, 0x00, // value
        ...[0x73, ...Array.from(ripemd160Addr)],
        PUSH2, 0x27, 0x10,
        CALL,
        PUSH1, 0x20,
        PUSH1, 0x00,
        RETURN
      );

      const result = evm.execute(callerCode, { gas: 100000n });

      expect(result.success).toBe(true);
    });

    it('should execute IDENTITY precompile', () => {
      const identityAddr = addressFromHex('0x0000000000000000000000000000000000000004');

      // Copy data through IDENTITY
      const callerCode = bytecode(
        // Store test data
        PUSH1, 0x42,
        PUSH1, 0x00,
        MSTORE,
        // Call IDENTITY
        PUSH1, 0x20, // retSize
        PUSH1, 0x20, // retOffset
        PUSH1, 0x20, // argSize
        PUSH1, 0x00, // argOffset
        PUSH1, 0x00, // value
        ...[0x73, ...Array.from(identityAddr)],
        PUSH2, 0x27, 0x10,
        CALL,
        PUSH1, 0x20,
        PUSH1, 0x20,
        RETURN
      );

      const result = evm.execute(callerCode, { gas: 100000n });

      expect(result.success).toBe(true);
      expect(decodeU256(result.output)).toBe(0x42n);
    });
  });

  describe('7. Edge Cases', () => {
    it('should handle empty bytecode', () => {
      const code = new Uint8Array(0);

      const result = evm.execute(code, { gas: 100000n });

      expect(result.success).toBe(true);
      expect(result.output.length).toBe(0);
      expect(result.gas_left).toBe(100000n); // No gas used
    });

    it('should handle zero value transfer', () => {
      const callerAddr = addressFromHex('0x1000000000000000000000000000000000000001');
      const calleeAddr = addressFromHex('0x2000000000000000000000000000000000000002');

      const calleeCode = bytecode(STOP);
      host.setCode(calleeAddr, calleeCode);

      const callerCode = bytecode(
        PUSH1, 0x00, // retSize
        PUSH1, 0x00, // retOffset
        PUSH1, 0x00, // argSize
        PUSH1, 0x00, // argOffset
        PUSH1, 0x00, // value (0)
        ...[0x73, ...Array.from(calleeAddr)],
        PUSH2, 0x27, 0x10,
        CALL,
        STOP
      );

      const result = evm.execute(callerCode, {
        gas: 100000n,
        address: callerAddr,
      });

      expect(result.success).toBe(true);
    });

    it('should detect invalid jump destination', () => {
      // Jump to non-JUMPDEST location
      const code = bytecode(
        PUSH1, 0x05,
        JUMP,
        STOP, // Position 5 (not JUMPDEST)
      );

      const result = evm.execute(code, { gas: 100000n });

      expect(result.success).toBe(false);
    });

    it('should handle stack underflow', () => {
      // Try to ADD without enough stack items
      const code = bytecode(
        PUSH1, 0x01,
        ADD, // Only 1 item on stack, need 2
      );

      const result = evm.execute(code, { gas: 100000n });

      expect(result.success).toBe(false);
    });

    it('should handle stack overflow', () => {
      // Push more than 1024 items
      const ops: number[] = [];
      for (let i = 0; i < 1025; i++) {
        ops.push(PUSH1, 0x01);
      }
      const code = bytecode(...ops);

      const result = evm.execute(code, { gas: 10000000n });

      expect(result.success).toBe(false);
    });

    it('should handle REVERT with data', () => {
      // PUSH1 0x42, PUSH1 0, MSTORE, PUSH1 32, PUSH1 0, REVERT
      const code = bytecode(
        PUSH1, 0x42,
        PUSH1, 0x00,
        MSTORE,
        PUSH1, 0x20,
        PUSH1, 0x00,
        REVERT
      );

      const result = evm.execute(code, { gas: 100000n });

      expect(result.success).toBe(false);
      expect(result.output.length).toBe(32);
      expect(decodeU256(result.output)).toBe(0x42n);
      // Gas should not be fully consumed on REVERT
      expect(result.gas_left).toBeGreaterThan(0n);
    });

    it('should handle LOG operations', () => {
      const addr = addressFromHex('0x1000000000000000000000000000000000000001');

      // LOG1 with 1 topic
      const code = bytecode(
        PUSH1, 0x42, // data
        PUSH1, 0x00,
        MSTORE,
        PUSH1, 0x01, // topic
        PUSH1, 0x20, // size
        PUSH1, 0x00, // offset
        LOG1,
        STOP
      );

      const result = evm.execute(code, {
        gas: 100000n,
        address: addr,
      });

      expect(result.success).toBe(true);
      expect(result.logs.length).toBe(1);
      expect(result.logs[0].topics.length).toBe(1);
      expect(result.logs[0].topics[0]).toBe(1n);
    });

    it('should reject LOG in static context', () => {
      // Try to LOG in STATICCALL
      const callerAddr = addressFromHex('0x1000000000000000000000000000000000000001');
      const calleeAddr = addressFromHex('0x2000000000000000000000000000000000000002');

      const calleeCode = bytecode(
        PUSH1, 0x42,
        PUSH1, 0x00,
        MSTORE,
        PUSH1, 0x01,
        PUSH1, 0x20,
        PUSH1, 0x00,
        LOG1,
        STOP
      );
      host.setCode(calleeAddr, calleeCode);

      const callerCode = bytecode(
        PUSH1, 0x00,
        PUSH1, 0x00,
        PUSH1, 0x00,
        PUSH1, 0x00,
        ...[0x73, ...Array.from(calleeAddr)],
        PUSH2, 0x27, 0x10,
        STATICCALL,
        STOP
      );

      const result = evm.execute(callerCode, {
        gas: 100000n,
        address: callerAddr,
      });

      expect(result.success).toBe(false);
    });

    it('should handle division by zero', () => {
      // PUSH1 0, PUSH1 10, DIV (10 / 0)
      const code = bytecode(
        PUSH1, 0x00,
        PUSH1, 0x0A,
        DIV,
        PUSH1, 0x00,
        MSTORE,
        PUSH1, 0x20,
        PUSH1, 0x00,
        RETURN
      );

      const result = evm.execute(code, { gas: 100000n });

      expect(result.success).toBe(true);
      // DIV by 0 returns 0 (doesn't fail)
      expect(decodeU256(result.output)).toBe(0n);
    });

    it('should handle insufficient balance for value transfer', () => {
      const callerAddr = addressFromHex('0x1000000000000000000000000000000000000001');
      const calleeAddr = addressFromHex('0x2000000000000000000000000000000000000002');

      host.setBalance(callerAddr, 50n); // Not enough

      const calleeCode = bytecode(STOP);
      host.setCode(calleeAddr, calleeCode);

      const callerCode = bytecode(
        PUSH1, 0x00,
        PUSH1, 0x00,
        PUSH1, 0x00,
        PUSH1, 0x00,
        PUSH1, 0x64, // Try to send 100
        ...[0x73, ...Array.from(calleeAddr)],
        PUSH2, 0x27, 0x10,
        CALL,
        STOP
      );

      const result = evm.execute(callerCode, {
        gas: 100000n,
        address: callerAddr,
      });

      // CALL should return 0 (failure) but execution continues
      expect(result.success).toBe(true);
    });
  });
});
