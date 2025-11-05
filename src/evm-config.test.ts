/**
 * Tests for EVM configuration and overrides
 *
 * Tests cover:
 * - Default configuration values
 * - Custom configurations
 * - Hardfork parsing and comparison
 * - Opcode/precompile overrides
 * - Network-specific presets
 */

import { describe, it, expect } from 'vitest';
import {
  Hardfork,
  DEFAULT_HARDFORK,
  DEFAULT_CONFIG,
  createConfig,
  parseHardfork,
  isAtLeast,
  isBefore,
  ConfigPresets,
  type EvmConfig,
  type OpcodeOverride,
  type PrecompileOverride,
} from './evm-config';
import { addressFromHex } from './host';

describe('EvmConfig', () => {
  describe('default configuration', () => {
    it('should have correct default values', () => {
      const config = DEFAULT_CONFIG;

      expect(config.hardfork).toBe(Hardfork.CANCUN);
      expect(config.stack_size).toBe(1024);
      expect(config.max_bytecode_size).toBe(24576);
      expect(config.max_initcode_size).toBe(49152);
      expect(config.block_gas_limit).toBe(30_000_000n);
      expect(config.memory_initial_capacity).toBe(4096);
      expect(config.memory_limit).toBe(0xFFFFFFn);
      expect(config.max_call_depth).toBe(1024);
      expect(config.opcode_overrides).toEqual([]);
      expect(config.precompile_overrides).toEqual([]);
    });

    it('should set loop quota based on environment', () => {
      const config = DEFAULT_CONFIG;
      // In test environment, loop quota should be set
      if (process.env.NODE_ENV === 'production') {
        expect(config.loop_quota).toBeNull();
      } else {
        expect(config.loop_quota).toBe(1_000_000);
      }
    });

    it('should enable all system contracts by default', () => {
      const config = DEFAULT_CONFIG;

      expect(config.enable_beacon_roots).toBe(true);
      expect(config.enable_historical_block_hashes).toBe(true);
      expect(config.enable_validator_deposits).toBe(true);
      expect(config.enable_validator_withdrawals).toBe(true);
    });
  });

  describe('custom configuration', () => {
    it('should override specific fields', () => {
      const config = createConfig({
        hardfork: Hardfork.BERLIN,
        stack_size: 512,
        max_bytecode_size: 12288,
        max_call_depth: 512,
      });

      expect(config.hardfork).toBe(Hardfork.BERLIN);
      expect(config.stack_size).toBe(512);
      expect(config.max_bytecode_size).toBe(12288);
      expect(config.max_call_depth).toBe(512);
      // Other fields should have defaults
      expect(config.block_gas_limit).toBe(30_000_000n);
      expect(config.memory_limit).toBe(0xFFFFFFn);
    });

    it('should handle partial overrides', () => {
      const config = createConfig({
        block_gas_limit: 15_000_000n,
      });

      expect(config.block_gas_limit).toBe(15_000_000n);
      expect(config.hardfork).toBe(DEFAULT_HARDFORK);
      expect(config.stack_size).toBe(1024);
    });

    it('should allow disabling system contracts', () => {
      const config = createConfig({
        enable_beacon_roots: false,
        enable_historical_block_hashes: false,
        enable_validator_deposits: false,
        enable_validator_withdrawals: false,
      });

      expect(config.enable_beacon_roots).toBe(false);
      expect(config.enable_historical_block_hashes).toBe(false);
      expect(config.enable_validator_deposits).toBe(false);
      expect(config.enable_validator_withdrawals).toBe(false);
    });
  });

  describe('hardfork handling', () => {
    it('should support all hardfork variations', () => {
      const hardforks = [
        Hardfork.FRONTIER,
        Hardfork.HOMESTEAD,
        Hardfork.BYZANTIUM,
        Hardfork.BERLIN,
        Hardfork.LONDON,
        Hardfork.SHANGHAI,
        Hardfork.CANCUN,
        Hardfork.PRAGUE,
      ];

      for (const hardfork of hardforks) {
        const config = createConfig({ hardfork });
        expect(config.hardfork).toBe(hardfork);
        // Non-hardfork settings should remain default
        expect(config.stack_size).toBe(1024);
        expect(config.max_call_depth).toBe(1024);
      }
    });

    it('should parse hardfork from string (case-insensitive)', () => {
      expect(parseHardfork('CANCUN')).toBe(Hardfork.CANCUN);
      expect(parseHardfork('cancun')).toBe(Hardfork.CANCUN);
      expect(parseHardfork('Berlin')).toBe(Hardfork.BERLIN);
      expect(parseHardfork('SHANGHAI')).toBe(Hardfork.SHANGHAI);
    });

    it('should throw on invalid hardfork string', () => {
      expect(() => parseHardfork('INVALID')).toThrow('Unknown hardfork');
      expect(() => parseHardfork('DENCUN')).toThrow('Unknown hardfork');
    });
  });

  describe('hardfork comparison', () => {
    it('should correctly compare hardfork versions with isAtLeast', () => {
      // Same version
      expect(isAtLeast(Hardfork.CANCUN, Hardfork.CANCUN)).toBe(true);

      // Later >= Earlier
      expect(isAtLeast(Hardfork.CANCUN, Hardfork.BERLIN)).toBe(true);
      expect(isAtLeast(Hardfork.SHANGHAI, Hardfork.LONDON)).toBe(true);
      expect(isAtLeast(Hardfork.PRAGUE, Hardfork.CANCUN)).toBe(true);

      // Earlier < Later
      expect(isAtLeast(Hardfork.BERLIN, Hardfork.CANCUN)).toBe(false);
      expect(isAtLeast(Hardfork.LONDON, Hardfork.SHANGHAI)).toBe(false);
      expect(isAtLeast(Hardfork.FRONTIER, Hardfork.HOMESTEAD)).toBe(false);
    });

    it('should correctly compare hardfork versions with isBefore', () => {
      // Same version
      expect(isBefore(Hardfork.CANCUN, Hardfork.CANCUN)).toBe(false);

      // Earlier < Later
      expect(isBefore(Hardfork.BERLIN, Hardfork.CANCUN)).toBe(true);
      expect(isBefore(Hardfork.LONDON, Hardfork.SHANGHAI)).toBe(true);
      expect(isBefore(Hardfork.FRONTIER, Hardfork.HOMESTEAD)).toBe(true);

      // Later >= Earlier
      expect(isBefore(Hardfork.CANCUN, Hardfork.BERLIN)).toBe(false);
      expect(isBefore(Hardfork.SHANGHAI, Hardfork.LONDON)).toBe(false);
      expect(isBefore(Hardfork.PRAGUE, Hardfork.CANCUN)).toBe(false);
    });

    it('should handle full hardfork sequence', () => {
      const sequence = [
        Hardfork.FRONTIER,
        Hardfork.HOMESTEAD,
        Hardfork.TANGERINE,
        Hardfork.SPURIOUS,
        Hardfork.BYZANTIUM,
        Hardfork.CONSTANTINOPLE,
        Hardfork.ISTANBUL,
        Hardfork.BERLIN,
        Hardfork.LONDON,
        Hardfork.MERGE,
        Hardfork.SHANGHAI,
        Hardfork.CANCUN,
        Hardfork.PRAGUE,
      ];

      // Verify sequential ordering
      for (let i = 0; i < sequence.length - 1; i++) {
        expect(isBefore(sequence[i], sequence[i + 1])).toBe(true);
        expect(isAtLeast(sequence[i + 1], sequence[i])).toBe(true);
      }
    });
  });

  describe('opcode overrides', () => {
    it('should accept opcode overrides', () => {
      const dummyHandler = () => {
        /* custom ADD handler */
      };

      const config = createConfig({
        opcode_overrides: [
          {
            opcode: 0x01, // ADD
            handler: dummyHandler,
          },
        ],
      });

      expect(config.opcode_overrides).toHaveLength(1);
      expect(config.opcode_overrides[0].opcode).toBe(0x01);
      expect(config.opcode_overrides[0].handler).toBe(dummyHandler);
    });

    it('should accept multiple opcode overrides', () => {
      const handlers = {
        add: () => {},
        mul: () => {},
        sstore: () => {},
      };

      const config = createConfig({
        opcode_overrides: [
          { opcode: 0x01, handler: handlers.add },
          { opcode: 0x02, handler: handlers.mul },
          { opcode: 0x55, handler: handlers.sstore },
        ],
      });

      expect(config.opcode_overrides).toHaveLength(3);
      expect(config.opcode_overrides[0].opcode).toBe(0x01);
      expect(config.opcode_overrides[1].opcode).toBe(0x02);
      expect(config.opcode_overrides[2].opcode).toBe(0x55);
    });
  });

  describe('precompile overrides', () => {
    it('should accept precompile overrides', () => {
      const ecrecoverOverride: PrecompileOverride = {
        address: addressFromHex('0x0000000000000000000000000000000000000001'),
        execute: (input: Uint8Array, gas_limit: bigint) => {
          return {
            output: new Uint8Array(32),
            gas_used: 3000n,
            success: true,
          };
        },
      };

      const config = createConfig({
        precompile_overrides: [ecrecoverOverride],
      });

      expect(config.precompile_overrides).toHaveLength(1);
      expect(config.precompile_overrides[0].address).toEqual(ecrecoverOverride.address);
      expect(config.precompile_overrides[0].execute).toBe(ecrecoverOverride.execute);
    });

    it('should accept precompile with context', () => {
      const customContext = { state: 'custom' };
      const precompile: PrecompileOverride = {
        address: addressFromHex('0x00000000000000000000000000000000000000FF'),
        execute: (input: Uint8Array, gas_limit: bigint) => {
          return {
            output: new Uint8Array(0),
            gas_used: 1000n,
            success: true,
          };
        },
        context: customContext,
      };

      const config = createConfig({
        precompile_overrides: [precompile],
      });

      expect(config.precompile_overrides[0].context).toBe(customContext);
    });

    it('should handle multiple precompiles', () => {
      const precompiles: PrecompileOverride[] = [
        {
          address: addressFromHex('0x0000000000000000000000000000000000000001'),
          execute: () => ({ output: new Uint8Array(0), gas_used: 3000n, success: true }),
        },
        {
          address: addressFromHex('0x0000000000000000000000000000000000000002'),
          execute: () => ({ output: new Uint8Array(0), gas_used: 60n, success: true }),
        },
        {
          address: addressFromHex('0x0000000000000000000000000000000000000008'),
          execute: () => ({ output: new Uint8Array(0), gas_used: 30000n, success: true }),
        },
      ];

      const config = createConfig({
        precompile_overrides: precompiles,
      });

      expect(config.precompile_overrides).toHaveLength(3);
    });

    it('should support async precompiles', async () => {
      const asyncPrecompile: PrecompileOverride = {
        address: addressFromHex('0x0000000000000000000000000000000000000010'),
        execute: async (input: Uint8Array, gas_limit: bigint) => {
          await new Promise((resolve) => setTimeout(resolve, 1));
          return {
            output: new Uint8Array(32),
            gas_used: 5000n,
            success: true,
          };
        },
      };

      const config = createConfig({
        precompile_overrides: [asyncPrecompile],
      });

      const result = await config.precompile_overrides[0].execute(new Uint8Array(0), 10000n);
      expect(result.success).toBe(true);
      expect(result.gas_used).toBe(5000n);
      expect(result.output).toHaveLength(32);
    });
  });

  describe('loop quota', () => {
    it('should accept custom loop quota', () => {
      const config = createConfig({
        loop_quota: 1_000_000,
      });

      expect(config.loop_quota).toBe(1_000_000);
    });

    it('should accept null loop quota (disabled)', () => {
      const config = createConfig({
        loop_quota: null,
      });

      expect(config.loop_quota).toBeNull();
    });

    it('should accept different quota values', () => {
      const configs = [
        createConfig({ loop_quota: 100_000 }),
        createConfig({ loop_quota: 500_000 }),
        createConfig({ loop_quota: 10_000_000 }),
      ];

      expect(configs[0].loop_quota).toBe(100_000);
      expect(configs[1].loop_quota).toBe(500_000);
      expect(configs[2].loop_quota).toBe(10_000_000);
    });
  });

  describe('network presets', () => {
    it('should create mainnet config', () => {
      const config = ConfigPresets.mainnet();

      expect(config.hardfork).toBe(DEFAULT_HARDFORK);
      expect(config.block_gas_limit).toBe(30_000_000n);
      expect(config.enable_beacon_roots).toBe(true);
    });

    it('should create optimism config', () => {
      const config = ConfigPresets.optimism();

      expect(config.hardfork).toBe(Hardfork.CANCUN);
      expect(config.block_gas_limit).toBe(15_000_000n);
    });

    it('should create arbitrum config', () => {
      const config = ConfigPresets.arbitrum();

      expect(config.hardfork).toBe(Hardfork.CANCUN);
      expect(config.block_gas_limit).toBe(32_000_000n);
    });

    it('should create polygon config', () => {
      const config = ConfigPresets.polygon();

      expect(config.hardfork).toBe(Hardfork.CANCUN);
      expect(config.block_gas_limit).toBe(30_000_000n);
    });

    it('should create testing config', () => {
      const config = ConfigPresets.testing();

      expect(config.hardfork).toBe(DEFAULT_HARDFORK);
      expect(config.loop_quota).toBe(1_000_000);
      expect(config.enable_beacon_roots).toBe(false);
      expect(config.enable_historical_block_hashes).toBe(false);
    });

    it('should create development config', () => {
      const config = ConfigPresets.development();

      expect(config.hardfork).toBe(DEFAULT_HARDFORK);
      expect(config.block_gas_limit).toBe(100_000_000n);
      expect(config.loop_quota).toBe(10_000_000);
      expect(config.max_call_depth).toBe(2048);
    });

    it('should allow overriding preset configs', () => {
      const base = ConfigPresets.mainnet();
      const customized = createConfig({
        ...base,
        block_gas_limit: 50_000_000n,
        loop_quota: 2_000_000,
      });

      expect(customized.block_gas_limit).toBe(50_000_000n);
      expect(customized.loop_quota).toBe(2_000_000);
      expect(customized.hardfork).toBe(DEFAULT_HARDFORK);
    });
  });

  describe('resource limits', () => {
    it('should validate stack size', () => {
      const config = createConfig({ stack_size: 512 });
      expect(config.stack_size).toBe(512);
    });

    it('should validate bytecode size limits', () => {
      const config = createConfig({
        max_bytecode_size: 12288,
        max_initcode_size: 24576,
      });

      expect(config.max_bytecode_size).toBe(12288);
      expect(config.max_initcode_size).toBe(24576);
    });

    it('should validate memory limits', () => {
      const config = createConfig({
        memory_initial_capacity: 8192,
        memory_limit: 0x1FFFFFn,
      });

      expect(config.memory_initial_capacity).toBe(8192);
      expect(config.memory_limit).toBe(0x1FFFFFn);
    });

    it('should validate call depth', () => {
      const config = createConfig({ max_call_depth: 512 });
      expect(config.max_call_depth).toBe(512);
    });
  });

  describe('integration', () => {
    it('should support complete custom EVM configuration', () => {
      const customHandler = () => {
        /* custom logic */
      };
      const customPrecompile: PrecompileOverride = {
        address: addressFromHex('0x00000000000000000000000000000000DEADBEEF'),
        execute: () => ({ output: new Uint8Array(0), gas_used: 1n, success: true }),
        context: { custom: true },
      };

      const config = createConfig({
        hardfork: Hardfork.SHANGHAI,
        stack_size: 2048,
        max_bytecode_size: 48000,
        max_initcode_size: 96000,
        block_gas_limit: 50_000_000n,
        memory_initial_capacity: 8192,
        memory_limit: 0x2FFFFFn,
        max_call_depth: 2048,
        opcode_overrides: [{ opcode: 0x01, handler: customHandler }],
        precompile_overrides: [customPrecompile],
        loop_quota: 5_000_000,
        enable_beacon_roots: false,
        enable_historical_block_hashes: true,
        enable_validator_deposits: false,
        enable_validator_withdrawals: true,
      });

      expect(config.hardfork).toBe(Hardfork.SHANGHAI);
      expect(config.stack_size).toBe(2048);
      expect(config.block_gas_limit).toBe(50_000_000n);
      expect(config.opcode_overrides).toHaveLength(1);
      expect(config.precompile_overrides).toHaveLength(1);
      expect(config.enable_beacon_roots).toBe(false);
    });
  });
});
