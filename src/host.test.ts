/**
 * Tests for HostInterface implementation
 */

import { describe, it, expect, beforeEach } from 'bun:test';
import {
  type HostInterface,
  type Address,
  addressFromHex,
  addressToHex,
  addressEquals,
} from './host';

/**
 * Mock implementation of HostInterface for testing
 */
class MockHost implements HostInterface {
  private balances = new Map<string, bigint>();
  private codes = new Map<string, Uint8Array>();
  private storage = new Map<string, Map<string, bigint>>();
  private nonces = new Map<string, bigint>();

  private addressKey(address: Address): string {
    return addressToHex(address);
  }

  private storageKey(address: Address, slot: bigint): string {
    return `${this.addressKey(address)}:${slot.toString(16)}`;
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

  // Test helpers
  clear(): void {
    this.balances.clear();
    this.codes.clear();
    this.storage.clear();
    this.nonces.clear();
  }
}

describe('HostInterface', () => {
  let host: MockHost;
  let testAddress: Address;

  beforeEach(() => {
    host = new MockHost();
    testAddress = addressFromHex('0x1234567890123456789012345678901234567890');
  });

  describe('Balance operations', () => {
    it('should return 0 for unset balance', () => {
      expect(host.getBalance(testAddress)).toBe(0n);
    });

    it('should set and get balance', () => {
      const balance = 1000000000000000000n; // 1 ETH in wei
      host.setBalance(testAddress, balance);
      expect(host.getBalance(testAddress)).toBe(balance);
    });

    it('should handle large u256 balances', () => {
      const maxU256 = 2n ** 256n - 1n;
      host.setBalance(testAddress, maxU256);
      expect(host.getBalance(testAddress)).toBe(maxU256);
    });

    it('should update existing balance', () => {
      host.setBalance(testAddress, 100n);
      host.setBalance(testAddress, 200n);
      expect(host.getBalance(testAddress)).toBe(200n);
    });
  });

  describe('Code operations', () => {
    it('should return empty array for unset code', () => {
      const code = host.getCode(testAddress);
      expect(code.length).toBe(0);
    });

    it('should set and get code', () => {
      const bytecode = new Uint8Array([0x60, 0x80, 0x60, 0x40]); // PUSH1 0x80 PUSH1 0x40
      host.setCode(testAddress, bytecode);
      const retrieved = host.getCode(testAddress);
      expect(retrieved.length).toBe(bytecode.length);
      for (let i = 0; i < bytecode.length; i++) {
        expect(retrieved[i]).toBe(bytecode[i]);
      }
    });

    it('should handle empty code', () => {
      const emptyCode = new Uint8Array(0);
      host.setCode(testAddress, emptyCode);
      expect(host.getCode(testAddress).length).toBe(0);
    });

    it('should replace existing code', () => {
      host.setCode(testAddress, new Uint8Array([0x60, 0x01]));
      host.setCode(testAddress, new Uint8Array([0x60, 0x02]));
      const code = host.getCode(testAddress);
      expect(code.length).toBe(2);
      expect(code[0]).toBe(0x60);
      expect(code[1]).toBe(0x02);
    });
  });

  describe('Storage operations', () => {
    it('should return 0 for unset storage slot', () => {
      expect(host.getStorage(testAddress, 0n)).toBe(0n);
      expect(host.getStorage(testAddress, 123n)).toBe(0n);
    });

    it('should set and get storage slot', () => {
      const slot = 42n;
      const value = 12345n;
      host.setStorage(testAddress, slot, value);
      expect(host.getStorage(testAddress, slot)).toBe(value);
    });

    it('should handle multiple slots independently', () => {
      host.setStorage(testAddress, 0n, 100n);
      host.setStorage(testAddress, 1n, 200n);
      host.setStorage(testAddress, 2n, 300n);
      expect(host.getStorage(testAddress, 0n)).toBe(100n);
      expect(host.getStorage(testAddress, 1n)).toBe(200n);
      expect(host.getStorage(testAddress, 2n)).toBe(300n);
    });

    it('should handle large u256 slot keys and values', () => {
      const largeSlot = 2n ** 255n;
      const largeValue = 2n ** 256n - 1n;
      host.setStorage(testAddress, largeSlot, largeValue);
      expect(host.getStorage(testAddress, largeSlot)).toBe(largeValue);
    });

    it('should update existing storage slot', () => {
      host.setStorage(testAddress, 0n, 100n);
      host.setStorage(testAddress, 0n, 200n);
      expect(host.getStorage(testAddress, 0n)).toBe(200n);
    });
  });

  describe('Nonce operations', () => {
    it('should return 0 for unset nonce', () => {
      expect(host.getNonce(testAddress)).toBe(0n);
    });

    it('should set and get nonce', () => {
      const nonce = 42n;
      host.setNonce(testAddress, nonce);
      expect(host.getNonce(testAddress)).toBe(nonce);
    });

    it('should handle u64 max nonce', () => {
      const maxU64 = 2n ** 64n - 1n;
      host.setNonce(testAddress, maxU64);
      expect(host.getNonce(testAddress)).toBe(maxU64);
    });

    it('should increment nonce', () => {
      host.setNonce(testAddress, 0n);
      host.setNonce(testAddress, 1n);
      host.setNonce(testAddress, 2n);
      expect(host.getNonce(testAddress)).toBe(2n);
    });
  });

  describe('Multiple accounts', () => {
    it('should isolate state between different addresses', () => {
      const addr1 = addressFromHex('0x1111111111111111111111111111111111111111');
      const addr2 = addressFromHex('0x2222222222222222222222222222222222222222');

      host.setBalance(addr1, 100n);
      host.setBalance(addr2, 200n);
      host.setNonce(addr1, 1n);
      host.setNonce(addr2, 2n);
      host.setStorage(addr1, 0n, 1000n);
      host.setStorage(addr2, 0n, 2000n);

      expect(host.getBalance(addr1)).toBe(100n);
      expect(host.getBalance(addr2)).toBe(200n);
      expect(host.getNonce(addr1)).toBe(1n);
      expect(host.getNonce(addr2)).toBe(2n);
      expect(host.getStorage(addr1, 0n)).toBe(1000n);
      expect(host.getStorage(addr2, 0n)).toBe(2000n);
    });
  });
});

describe('Address helpers', () => {
  describe('addressFromHex', () => {
    it('should parse hex string with 0x prefix', () => {
      const addr = addressFromHex('0x1234567890123456789012345678901234567890');
      expect(addr.length).toBe(20);
      expect(addr[0]).toBe(0x12);
      expect(addr[1]).toBe(0x34);
    });

    it('should parse hex string without 0x prefix', () => {
      const addr = addressFromHex('1234567890123456789012345678901234567890');
      expect(addr.length).toBe(20);
      expect(addr[0]).toBe(0x12);
    });

    it('should throw on invalid length', () => {
      expect(() => addressFromHex('0x1234')).toThrow('Invalid address length');
      expect(() => addressFromHex('0x' + '12'.repeat(21))).toThrow('Invalid address length');
    });
  });

  describe('addressToHex', () => {
    it('should convert address to hex string with 0x prefix', () => {
      const addr = new Uint8Array(20);
      addr[0] = 0x12;
      addr[1] = 0x34;
      const hex = addressToHex(addr);
      expect(hex).toMatch(/^0x[0-9a-f]{40}$/);
      expect(hex.slice(0, 6)).toBe('0x1234');
    });

    it('should pad single digit bytes with leading zero', () => {
      const addr = new Uint8Array(20);
      addr[0] = 0x01;
      const hex = addressToHex(addr);
      expect(hex.slice(0, 4)).toBe('0x01');
    });
  });

  describe('addressEquals', () => {
    it('should return true for equal addresses', () => {
      const addr1 = addressFromHex('0x1234567890123456789012345678901234567890');
      const addr2 = addressFromHex('0x1234567890123456789012345678901234567890');
      expect(addressEquals(addr1, addr2)).toBe(true);
    });

    it('should return false for different addresses', () => {
      const addr1 = addressFromHex('0x1234567890123456789012345678901234567890');
      const addr2 = addressFromHex('0x0000000000000000000000000000000000000000');
      expect(addressEquals(addr1, addr2)).toBe(false);
    });

    it('should return false for invalid length arrays', () => {
      const addr1 = new Uint8Array(20);
      const addr2 = new Uint8Array(19);
      expect(addressEquals(addr1, addr2)).toBe(false);
    });
  });

  describe('Round-trip conversion', () => {
    it('should preserve address through hex conversion', () => {
      const original = '0xabcdef1234567890123456789012345678901234';
      const addr = addressFromHex(original);
      const converted = addressToHex(addr);
      expect(converted.toLowerCase()).toBe(original.toLowerCase());
    });
  });
});
