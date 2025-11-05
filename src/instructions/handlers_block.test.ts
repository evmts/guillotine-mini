/**
 * Tests for block context opcode handlers
 * Port of handlers_block.zig tests to TypeScript
 */

import { describe, it, expect, beforeEach } from 'vitest';
import {
  blockhash,
  coinbase,
  timestamp,
  number,
  difficulty,
  gaslimit,
  chainid,
  selfbalance,
  basefee,
  blobhash,
  blobbasefee,
  Hardfork,
  type BlockContext,
  type EvmInterface,
  type FrameInterface,
} from './handlers_block';
import { CallError, EvmError } from '../errors';

/**
 * Mock Frame implementation for testing
 */
class MockFrame implements FrameInterface {
  pc = 0;
  address: Uint8Array;
  private stack: bigint[] = [];
  private gasUsed = 0n;
  private evmInstance: EvmInterface;

  constructor(evm: EvmInterface, address?: Uint8Array) {
    this.evmInstance = evm;
    this.address = address || new Uint8Array(20);
  }

  consumeGas(amount: bigint): void {
    this.gasUsed += amount;
  }

  popStack(): bigint {
    const value = this.stack.pop();
    if (value === undefined) {
      throw new EvmError(CallError.StackUnderflow);
    }
    return value;
  }

  pushStack(value: bigint): void {
    this.stack.push(value);
  }

  getEvm(): EvmInterface {
    return this.evmInstance;
  }

  // Test helpers
  getStack(): bigint[] {
    return [...this.stack];
  }

  getGasUsed(): bigint {
    return this.gasUsed;
  }

  resetGas(): void {
    this.gasUsed = 0n;
  }
}

/**
 * Mock EVM implementation for testing
 */
class MockEvm implements EvmInterface {
  block_context: BlockContext;
  hardfork: Hardfork;
  blob_versioned_hashes: Uint8Array[] = [];
  private balances: Map<string, bigint> = new Map();

  constructor(hardfork: Hardfork = Hardfork.CANCUN) {
    this.hardfork = hardfork;
    this.block_context = {
      block_number: 1000n,
      block_timestamp: 1700000000n,
      block_coinbase: new Uint8Array(20).fill(0xAB),
      block_difficulty: 15000000000000000n,
      block_prevrandao: 0x123456789ABCDEF0n,
      block_gas_limit: 30000000n,
      block_base_fee: 10n ** 9n, // 1 gwei
      chain_id: 1n, // mainnet
      block_hashes: [],
      blob_base_fee: 1n, // 1 wei
    };
  }

  get_balance(address: Uint8Array): bigint {
    const key = Array.from(address).join(',');
    return this.balances.get(key) || 0n;
  }

  set_balance(address: Uint8Array, balance: bigint): void {
    const key = Array.from(address).join(',');
    this.balances.set(key, balance);
  }
}

/**
 * Helper to create a 32-byte hash from a number
 */
function hashFromNumber(n: number): Uint8Array {
  const hash = new Uint8Array(32);
  hash[31] = n & 0xff;
  hash[30] = (n >> 8) & 0xff;
  return hash;
}

describe('Block Handlers', () => {
  let evm: MockEvm;
  let frame: MockFrame;

  beforeEach(() => {
    evm = new MockEvm();
    frame = new MockFrame(evm);
  });

  describe('BLOCKHASH (0x40)', () => {
    beforeEach(() => {
      // Set up block hashes for recent blocks
      // Current block: 1000
      // The algorithm: index = current - requested, actual_index = len - index
      // For block 997: index = 3, actual_index = 0
      // For block 998: index = 2, actual_index = 1
      // For block 999: index = 1, actual_index = 2
      // So block_hashes[0] should be hash(997), [1] = hash(998), [2] = hash(999)
      evm.block_context.block_number = 1000n;
      evm.block_context.block_hashes = [
        hashFromNumber(997), // Oldest in our range
        hashFromNumber(998),
        hashFromNumber(999), // Most recent
      ];
    });

    it('should return hash for recent block (within 256 blocks)', () => {
      // Request block 997 (3 blocks ago)
      // index = 1000 - 997 = 3
      // actual_index = 3 - 3 = 0
      // block_hashes[0] = hash(997)
      frame.pushStack(997n);
      blockhash(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);

      // hashFromNumber(997) = 0x000...03e5 (997 in hex is 0x3e5)
      const expected = 0x3e5n; // 997 in hex
      expect(result[0]).toBe(expected);
    });

    it('should return zero for current block', () => {
      // Cannot get hash of current block (not yet complete)
      frame.pushStack(1000n);
      blockhash(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      expect(result[0]).toBe(0n);
    });

    it('should return zero for future block', () => {
      frame.pushStack(1001n);
      blockhash(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      expect(result[0]).toBe(0n);
    });

    it('should return zero for block more than 256 blocks old', () => {
      // Request block 743 (257 blocks ago)
      frame.pushStack(743n);
      blockhash(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      expect(result[0]).toBe(0n);
    });

    it('should return hash for block exactly 256 blocks ago', () => {
      evm.block_context.block_number = 1000n;
      // Fill with 256 hashes: oldest (744) first, newest (999) last
      // block_hashes[0] = hash(744), block_hashes[1] = hash(745), ..., block_hashes[255] = hash(999)
      evm.block_context.block_hashes = Array.from({ length: 256 }, (_, i) =>
        hashFromNumber(744 + i)
      );

      // Request block 744 (256 blocks ago)
      // index = 1000 - 744 = 256
      // actual_index = 256 - 256 = 0
      // block_hashes[0] = hash(744)
      frame.pushStack(744n);
      blockhash(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      // Should get hash for block 744 from block_hashes[0]
      const expected = 0x2e8n; // 744 in hex
      expect(result[0]).toBe(expected);
    });

    it('should consume correct gas (20 gas)', () => {
      frame.pushStack(999n);
      blockhash(frame);
      expect(frame.getGasUsed()).toBe(20n);
    });

    it('should increment program counter', () => {
      frame.pushStack(999n);
      expect(frame.pc).toBe(0);
      blockhash(frame);
      expect(frame.pc).toBe(1);
    });
  });

  describe('COINBASE (0x41)', () => {
    it('should return block coinbase address', () => {
      // Set coinbase to 0xABAB...AB (20 bytes)
      const coinbase_addr = new Uint8Array(20).fill(0xAB);
      evm.block_context.block_coinbase = coinbase_addr;

      coinbase(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);

      // Convert expected address to u256
      let expected = 0n;
      for (const byte of coinbase_addr) {
        expected = (expected << 8n) | BigInt(byte);
      }
      expect(result[0]).toBe(expected);
    });

    it('should consume correct gas (2 gas)', () => {
      coinbase(frame);
      expect(frame.getGasUsed()).toBe(2n);
    });

    it('should increment program counter', () => {
      expect(frame.pc).toBe(0);
      coinbase(frame);
      expect(frame.pc).toBe(1);
    });
  });

  describe('TIMESTAMP (0x42)', () => {
    it('should return block timestamp', () => {
      evm.block_context.block_timestamp = 1700000000n;

      timestamp(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      expect(result[0]).toBe(1700000000n);
    });

    it('should consume correct gas (2 gas)', () => {
      timestamp(frame);
      expect(frame.getGasUsed()).toBe(2n);
    });

    it('should increment program counter', () => {
      expect(frame.pc).toBe(0);
      timestamp(frame);
      expect(frame.pc).toBe(1);
    });
  });

  describe('NUMBER (0x43)', () => {
    it('should return block number', () => {
      evm.block_context.block_number = 12345678n;

      number(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      expect(result[0]).toBe(12345678n);
    });

    it('should consume correct gas (2 gas)', () => {
      number(frame);
      expect(frame.getGasUsed()).toBe(2n);
    });

    it('should increment program counter', () => {
      expect(frame.pc).toBe(0);
      number(frame);
      expect(frame.pc).toBe(1);
    });
  });

  describe('DIFFICULTY (0x44)', () => {
    it('should return difficulty before Merge', () => {
      evm.hardfork = Hardfork.LONDON;
      evm.block_context.block_difficulty = 15000000000000000n;

      difficulty(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      expect(result[0]).toBe(15000000000000000n);
    });

    it('should return prevrandao after Merge', () => {
      evm.hardfork = Hardfork.MERGE;
      evm.block_context.block_prevrandao = 0x123456789ABCDEF0n;

      difficulty(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      expect(result[0]).toBe(0x123456789ABCDEF0n);
    });

    it('should return prevrandao in Shanghai (post-Merge)', () => {
      evm.hardfork = Hardfork.SHANGHAI;
      evm.block_context.block_prevrandao = 0xFEDCBA9876543210n;

      difficulty(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      expect(result[0]).toBe(0xFEDCBA9876543210n);
    });

    it('should consume correct gas (2 gas)', () => {
      difficulty(frame);
      expect(frame.getGasUsed()).toBe(2n);
    });

    it('should increment program counter', () => {
      expect(frame.pc).toBe(0);
      difficulty(frame);
      expect(frame.pc).toBe(1);
    });
  });

  describe('GASLIMIT (0x45)', () => {
    it('should return block gas limit', () => {
      evm.block_context.block_gas_limit = 30000000n;

      gaslimit(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      expect(result[0]).toBe(30000000n);
    });

    it('should consume correct gas (2 gas)', () => {
      gaslimit(frame);
      expect(frame.getGasUsed()).toBe(2n);
    });

    it('should increment program counter', () => {
      expect(frame.pc).toBe(0);
      gaslimit(frame);
      expect(frame.pc).toBe(1);
    });
  });

  describe('CHAINID (0x46) - EIP-1344', () => {
    it('should return chain ID for Istanbul+', () => {
      evm.hardfork = Hardfork.ISTANBUL;
      evm.block_context.chain_id = 1n;

      chainid(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      expect(result[0]).toBe(1n);
    });

    it('should work with different chain IDs', () => {
      evm.hardfork = Hardfork.CANCUN;
      evm.block_context.chain_id = 5n; // Goerli

      chainid(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      expect(result[0]).toBe(5n);
    });

    it('should throw InvalidOpcode before Istanbul', () => {
      evm.hardfork = Hardfork.CONSTANTINOPLE;

      expect(() => chainid(frame)).toThrow(EvmError);
      expect(() => chainid(frame)).toThrow('CHAINID not available before Istanbul');
    });

    it('should consume correct gas (2 gas)', () => {
      evm.hardfork = Hardfork.ISTANBUL;
      chainid(frame);
      expect(frame.getGasUsed()).toBe(2n);
    });

    it('should increment program counter', () => {
      evm.hardfork = Hardfork.ISTANBUL;
      expect(frame.pc).toBe(0);
      chainid(frame);
      expect(frame.pc).toBe(1);
    });
  });

  describe('SELFBALANCE (0x47) - EIP-1884', () => {
    it('should return balance of executing contract', () => {
      evm.hardfork = Hardfork.ISTANBUL;
      const contract_addr = new Uint8Array(20).fill(0x42);
      frame.address = contract_addr;
      evm.set_balance(contract_addr, 1000000000000000000n); // 1 ETH

      selfbalance(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      expect(result[0]).toBe(1000000000000000000n);
    });

    it('should return zero for contract with no balance', () => {
      evm.hardfork = Hardfork.ISTANBUL;
      const contract_addr = new Uint8Array(20).fill(0x99);
      frame.address = contract_addr;

      selfbalance(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      expect(result[0]).toBe(0n);
    });

    it('should throw InvalidOpcode before Istanbul', () => {
      evm.hardfork = Hardfork.CONSTANTINOPLE;

      expect(() => selfbalance(frame)).toThrow(EvmError);
      expect(() => selfbalance(frame)).toThrow('SELFBALANCE not available before Istanbul');
    });

    it('should consume correct gas (5 gas)', () => {
      evm.hardfork = Hardfork.ISTANBUL;
      selfbalance(frame);
      expect(frame.getGasUsed()).toBe(5n);
    });

    it('should increment program counter', () => {
      evm.hardfork = Hardfork.ISTANBUL;
      expect(frame.pc).toBe(0);
      selfbalance(frame);
      expect(frame.pc).toBe(1);
    });
  });

  describe('BASEFEE (0x48) - EIP-3198', () => {
    it('should return base fee for London+', () => {
      evm.hardfork = Hardfork.LONDON;
      evm.block_context.block_base_fee = 1000000000n; // 1 gwei

      basefee(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      expect(result[0]).toBe(1000000000n);
    });

    it('should work with different base fees', () => {
      evm.hardfork = Hardfork.CANCUN;
      evm.block_context.block_base_fee = 50000000000n; // 50 gwei

      basefee(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      expect(result[0]).toBe(50000000000n);
    });

    it('should throw InvalidOpcode before London', () => {
      evm.hardfork = Hardfork.BERLIN;

      expect(() => basefee(frame)).toThrow(EvmError);
      expect(() => basefee(frame)).toThrow('BASEFEE not available before London');
    });

    it('should consume correct gas (2 gas)', () => {
      evm.hardfork = Hardfork.LONDON;
      basefee(frame);
      expect(frame.getGasUsed()).toBe(2n);
    });

    it('should increment program counter', () => {
      evm.hardfork = Hardfork.LONDON;
      expect(frame.pc).toBe(0);
      basefee(frame);
      expect(frame.pc).toBe(1);
    });
  });

  describe('BLOBHASH (0x49) - EIP-4844', () => {
    beforeEach(() => {
      evm.hardfork = Hardfork.CANCUN;
      // Set up blob versioned hashes
      evm.blob_versioned_hashes = [
        hashFromNumber(0x01), // Index 0
        hashFromNumber(0x02), // Index 1
        hashFromNumber(0x03), // Index 2
      ];
    });

    it('should return blob hash at valid index', () => {
      frame.pushStack(0n); // Request index 0
      blobhash(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      expect(result[0]).toBe(0x01n);
    });

    it('should return blob hash at different valid index', () => {
      frame.pushStack(2n); // Request index 2
      blobhash(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      expect(result[0]).toBe(0x03n);
    });

    it('should return zero for out of bounds index', () => {
      frame.pushStack(10n); // Beyond array bounds
      blobhash(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      expect(result[0]).toBe(0n);
    });

    it('should return zero for very large index', () => {
      frame.pushStack(BigInt(Number.MAX_SAFE_INTEGER) + 1n);
      blobhash(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      expect(result[0]).toBe(0n);
    });

    it('should return zero when no blob hashes exist', () => {
      evm.blob_versioned_hashes = [];
      frame.pushStack(0n);
      blobhash(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      expect(result[0]).toBe(0n);
    });

    it('should throw InvalidOpcode before Cancun', () => {
      evm.hardfork = Hardfork.SHANGHAI;
      frame.pushStack(0n);

      expect(() => blobhash(frame)).toThrow(EvmError);
      expect(() => blobhash(frame)).toThrow('BLOBHASH not available before Cancun');
    });

    it('should consume correct gas (3 gas)', () => {
      frame.pushStack(0n);
      blobhash(frame);
      expect(frame.getGasUsed()).toBe(3n);
    });

    it('should increment program counter', () => {
      frame.pushStack(0n);
      expect(frame.pc).toBe(0);
      blobhash(frame);
      expect(frame.pc).toBe(1);
    });
  });

  describe('BLOBBASEFEE (0x4a) - EIP-7516', () => {
    it('should return blob base fee for Cancun+', () => {
      evm.hardfork = Hardfork.CANCUN;
      evm.block_context.blob_base_fee = 1000000000n; // 1 gwei

      blobbasefee(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      expect(result[0]).toBe(1000000000n);
    });

    it('should work with different blob base fees', () => {
      evm.hardfork = Hardfork.CANCUN;
      evm.block_context.blob_base_fee = 5000000000n; // 5 gwei

      blobbasefee(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      expect(result[0]).toBe(5000000000n);
    });

    it('should work with very small blob base fee', () => {
      evm.hardfork = Hardfork.CANCUN;
      evm.block_context.blob_base_fee = 1n; // 1 wei

      blobbasefee(frame);

      const result = frame.getStack();
      expect(result).toHaveLength(1);
      expect(result[0]).toBe(1n);
    });

    it('should throw InvalidOpcode before Cancun', () => {
      evm.hardfork = Hardfork.SHANGHAI;

      expect(() => blobbasefee(frame)).toThrow(EvmError);
      expect(() => blobbasefee(frame)).toThrow('BLOBBASEFEE not available before Cancun');
    });

    it('should consume correct gas (2 gas)', () => {
      evm.hardfork = Hardfork.CANCUN;
      blobbasefee(frame);
      expect(frame.getGasUsed()).toBe(2n);
    });

    it('should increment program counter', () => {
      evm.hardfork = Hardfork.CANCUN;
      expect(frame.pc).toBe(0);
      blobbasefee(frame);
      expect(frame.pc).toBe(1);
    });
  });

  describe('Gas costs summary', () => {
    beforeEach(() => {
      evm.hardfork = Hardfork.CANCUN;
    });

    it('should have correct relative gas costs', () => {
      frame.resetGas();
      frame.pushStack(999n);
      blockhash(frame);
      const blockhash_gas = frame.getGasUsed();

      frame.resetGas();
      coinbase(frame);
      const coinbase_gas = frame.getGasUsed();

      frame.resetGas();
      selfbalance(frame);
      const selfbalance_gas = frame.getGasUsed();

      frame.resetGas();
      frame.pushStack(0n);
      blobhash(frame);
      const blobhash_gas = frame.getGasUsed();

      // Verify gas cost relationships
      expect(blockhash_gas).toBe(20n); // Most expensive (accesses historical data)
      expect(selfbalance_gas).toBe(5n); // Mid-tier (accesses account state)
      expect(blobhash_gas).toBe(3n);    // Cheapest blob operation
      expect(coinbase_gas).toBe(2n);    // Cheapest (reads from block context)
    });
  });
});
