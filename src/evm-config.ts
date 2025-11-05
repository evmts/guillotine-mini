/**
 * EVM Configuration and Overrides
 *
 * Provides type-safe configuration for customizing EVM behavior:
 * - Gas limits and resource constraints
 * - Custom opcode handlers
 * - Custom precompile implementations
 * - Hardfork selection
 * - System contract toggles
 *
 * Ported from: src/evm_config.zig
 */

import type { Address } from './host';

/**
 * Hardfork enum defining Ethereum protocol versions
 * Each hardfork introduces new opcodes, gas rules, and EIPs
 */
export enum Hardfork {
  FRONTIER = 'FRONTIER',
  HOMESTEAD = 'HOMESTEAD',
  TANGERINE = 'TANGERINE',
  SPURIOUS = 'SPURIOUS',
  BYZANTIUM = 'BYZANTIUM',
  CONSTANTINOPLE = 'CONSTANTINOPLE',
  ISTANBUL = 'ISTANBUL',
  BERLIN = 'BERLIN',
  LONDON = 'LONDON',
  MERGE = 'MERGE',
  SHANGHAI = 'SHANGHAI',
  CANCUN = 'CANCUN',
  PRAGUE = 'PRAGUE',
}

/**
 * Default hardfork for new EVM instances
 */
export const DEFAULT_HARDFORK = Hardfork.CANCUN;

/**
 * Precompile execution output
 */
export interface PrecompileOutput {
  /** Output data from precompile execution */
  output: Uint8Array;
  /** Gas consumed during execution */
  gas_used: bigint;
  /** Whether execution succeeded */
  success: boolean;
}

/**
 * Custom precompile implementation with optional context
 *
 * Allows injecting custom precompile behavior at specific addresses.
 * Useful for:
 * - Testing custom cryptographic operations
 * - Network-specific precompiles (L2s)
 * - FFI-based native implementations
 */
export interface PrecompileOverride {
  /** Address where this precompile is registered */
  address: Address;

  /**
   * Execute the precompile with given input
   * @param input - Input data
   * @param gas_limit - Maximum gas available
   * @returns Execution result with output, gas used, and success status
   * @throws On allocation or execution errors
   */
  execute: (input: Uint8Array, gas_limit: bigint) => PrecompileOutput | Promise<PrecompileOutput>;

  /** Optional context for stateful precompiles (e.g., FFI pointers) */
  context?: unknown;
}

/**
 * Custom opcode handler override
 *
 * Allows replacing default opcode behavior.
 * Handler signature: (frame: Frame) => void
 *
 * NOTE: TypeScript cannot enforce exact handler signatures at compile time
 * without circular dependencies. Handlers must match Frame's opcode interface.
 */
export interface OpcodeOverride {
  /** Opcode to override (0x00-0xFF) */
  opcode: number;

  /**
   * Handler function that implements opcode logic
   * Should match signature: (frame: Frame) => void
   * Frame will provide stack, memory, pc, gas access
   */
  handler: Function;
}

/**
 * EVM configuration options
 *
 * Defines resource limits, hardfork version, and custom behavior overrides.
 * All fields have sensible defaults matching Ethereum mainnet.
 */
export interface EvmConfig {
  /**
   * Active hardfork for this EVM instance
   * Determines available opcodes and gas costs
   * @default CANCUN
   */
  hardfork: Hardfork;

  /**
   * Maximum stack depth (items)
   * @default 1024
   */
  stack_size: number;

  /**
   * Maximum contract bytecode size in bytes
   * @default 24576 (24 KB, EIP-170)
   */
  max_bytecode_size: number;

  /**
   * Maximum init code size for contract creation
   * @default 49152 (48 KB, EIP-3860)
   */
  max_initcode_size: number;

  /**
   * Block gas limit
   * @default 30000000 (30M)
   */
  block_gas_limit: bigint;

  /**
   * Initial memory capacity for memory allocation optimization
   * @default 4096 (4 KB)
   */
  memory_initial_capacity: number;

  /**
   * Maximum memory size limit
   * @default 0xFFFFFF (~16.7 MB)
   */
  memory_limit: bigint;

  /**
   * Maximum call depth for nested calls
   * @default 1024
   */
  max_call_depth: number;

  /**
   * Custom opcode handlers
   * Overrides default opcode implementations
   * @default []
   */
  opcode_overrides: OpcodeOverride[];

  /**
   * Custom precompile implementations
   * Adds or replaces precompiles at specific addresses
   * @default []
   */
  precompile_overrides: PrecompileOverride[];

  /**
   * Loop quota for infinite loop protection
   * - null = disabled (production)
   * - number = maximum iterations before throwing
   * @default 1000000 in debug, null in production
   */
  loop_quota: number | null;

  /**
   * Enable EIP-4788 beacon block root contract updates
   * @default true
   */
  enable_beacon_roots: boolean;

  /**
   * Enable EIP-2935 historical block hash contract updates
   * @default true
   */
  enable_historical_block_hashes: boolean;

  /**
   * Enable validator deposit contract processing
   * @default true
   */
  enable_validator_deposits: boolean;

  /**
   * Enable validator withdrawal processing
   * @default true
   */
  enable_validator_withdrawals: boolean;
}

/**
 * Default EVM configuration matching Ethereum mainnet
 */
export const DEFAULT_CONFIG: EvmConfig = {
  hardfork: DEFAULT_HARDFORK,
  stack_size: 1024,
  max_bytecode_size: 24576,
  max_initcode_size: 49152,
  block_gas_limit: 30_000_000n,
  memory_initial_capacity: 4096,
  memory_limit: 0xFFFFFFn,
  max_call_depth: 1024,
  opcode_overrides: [],
  precompile_overrides: [],
  loop_quota: process.env.NODE_ENV === 'production' ? null : 1_000_000,
  enable_beacon_roots: true,
  enable_historical_block_hashes: true,
  enable_validator_deposits: true,
  enable_validator_withdrawals: true,
};

/**
 * Create an EVM configuration with overrides
 *
 * @param overrides - Partial configuration to override defaults
 * @returns Complete EvmConfig with defaults applied
 *
 * @example
 * ```typescript
 * const config = createConfig({
 *   hardfork: Hardfork.BERLIN,
 *   block_gas_limit: 15_000_000n,
 *   loop_quota: 500_000,
 * });
 * ```
 */
export function createConfig(overrides: Partial<EvmConfig> = {}): EvmConfig {
  return {
    ...DEFAULT_CONFIG,
    ...overrides,
  };
}

/**
 * Parse hardfork from string (case-insensitive)
 *
 * @param hardforkStr - Hardfork name as string
 * @returns Hardfork enum value
 * @throws Error if hardfork name is invalid
 *
 * @example
 * ```typescript
 * const fork = parseHardfork('cancun'); // Hardfork.CANCUN
 * const fork2 = parseHardfork('BERLIN'); // Hardfork.BERLIN
 * ```
 */
export function parseHardfork(hardforkStr: string): Hardfork {
  const normalized = hardforkStr.toUpperCase();
  if (!(normalized in Hardfork)) {
    throw new Error(`Unknown hardfork: ${hardforkStr}`);
  }
  return Hardfork[normalized as keyof typeof Hardfork];
}

/**
 * Check if a hardfork is at least a given version
 *
 * @param current - Current hardfork
 * @param minimum - Minimum required hardfork
 * @returns true if current >= minimum
 *
 * @example
 * ```typescript
 * isAtLeast(Hardfork.CANCUN, Hardfork.BERLIN) // true
 * isAtLeast(Hardfork.BERLIN, Hardfork.CANCUN) // false
 * ```
 */
export function isAtLeast(current: Hardfork, minimum: Hardfork): boolean {
  const order = Object.values(Hardfork);
  return order.indexOf(current) >= order.indexOf(minimum);
}

/**
 * Check if a hardfork is before a given version
 *
 * @param current - Current hardfork
 * @param target - Target hardfork
 * @returns true if current < target
 *
 * @example
 * ```typescript
 * isBefore(Hardfork.BERLIN, Hardfork.CANCUN) // true
 * isBefore(Hardfork.CANCUN, Hardfork.BERLIN) // false
 * ```
 */
export function isBefore(current: Hardfork, target: Hardfork): boolean {
  const order = Object.values(Hardfork);
  return order.indexOf(current) < order.indexOf(target);
}

/**
 * Factory for creating network-specific configurations
 */
export const ConfigPresets = {
  /**
   * Ethereum mainnet (latest hardfork)
   */
  mainnet(): EvmConfig {
    return createConfig({
      hardfork: DEFAULT_HARDFORK,
      block_gas_limit: 30_000_000n,
    });
  },

  /**
   * Optimistic Ethereum (L2 with custom gas limits)
   */
  optimism(): EvmConfig {
    return createConfig({
      hardfork: Hardfork.CANCUN,
      block_gas_limit: 15_000_000n,
    });
  },

  /**
   * Arbitrum (L2 with custom precompiles)
   */
  arbitrum(): EvmConfig {
    return createConfig({
      hardfork: Hardfork.CANCUN,
      block_gas_limit: 32_000_000n,
    });
  },

  /**
   * Polygon (sidechain with different gas economics)
   */
  polygon(): EvmConfig {
    return createConfig({
      hardfork: Hardfork.CANCUN,
      block_gas_limit: 30_000_000n,
    });
  },

  /**
   * Testing configuration with all safety checks
   */
  testing(): EvmConfig {
    return createConfig({
      hardfork: DEFAULT_HARDFORK,
      loop_quota: 1_000_000,
      block_gas_limit: 30_000_000n,
      enable_beacon_roots: false,
      enable_historical_block_hashes: false,
    });
  },

  /**
   * Development configuration with relaxed limits
   */
  development(): EvmConfig {
    return createConfig({
      hardfork: DEFAULT_HARDFORK,
      block_gas_limit: 100_000_000n,
      loop_quota: 10_000_000,
      max_call_depth: 2048,
    });
  },
};
