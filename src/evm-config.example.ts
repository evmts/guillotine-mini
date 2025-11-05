/**
 * Example usage of EVM configuration system
 *
 * This file demonstrates common configuration patterns for customizing
 * EVM behavior through config objects, opcode overrides, and precompile injection.
 */

import {
  createConfig,
  ConfigPresets,
  Hardfork,
  isAtLeast,
  type EvmConfig,
  type OpcodeOverride,
  type PrecompileOverride,
} from './evm-config.js';
import { addressFromHex } from './host.js';

// =============================================================================
// Example 1: Basic Configuration
// =============================================================================

/**
 * Create a basic mainnet configuration
 */
function example1_basicConfig() {
  // Use preset
  const mainnetConfig = ConfigPresets.mainnet();
  console.log('Mainnet hardfork:', mainnetConfig.hardfork);
  console.log('Block gas limit:', mainnetConfig.block_gas_limit);

  // Custom configuration
  const customConfig = createConfig({
    hardfork: Hardfork.SHANGHAI,
    block_gas_limit: 20_000_000n,
    max_call_depth: 512,
  });
  console.log('Custom config:', customConfig);
}

// =============================================================================
// Example 2: Testing Configuration
// =============================================================================

/**
 * Create a configuration optimized for testing
 */
function example2_testingConfig() {
  const testConfig = ConfigPresets.testing();

  // Testing configs have:
  // - Loop quotas enabled for safety
  // - System contracts disabled for speed
  // - Standard resource limits
  console.log('Test loop quota:', testConfig.loop_quota); // 1_000_000
  console.log('Beacon roots enabled:', testConfig.enable_beacon_roots); // false

  return testConfig;
}

// =============================================================================
// Example 3: Custom Opcode Handler
// =============================================================================

/**
 * Override the ADD opcode with custom logic
 *
 * NOTE: Handler signature must match: (frame: Frame) => void
 * This example shows the structure; actual implementation would need Frame import
 */
function example3_opcodeOverride() {
  // Custom ADD that logs operations
  const customAddHandler = (frame: any) => {
    // Pop two values from stack
    const a = frame.popStack();
    const b = frame.popStack();

    // Custom logic: log operation
    console.log(`ADD: ${a} + ${b}`);

    // Compute result with overflow
    const result = (a + b) % (2n ** 256n);

    // Push result
    frame.pushStack(result);

    // Charge gas
    frame.chargeGas(3n); // Gverylow
  };

  const config = createConfig({
    opcode_overrides: [
      {
        opcode: 0x01, // ADD
        handler: customAddHandler,
      },
    ],
  });

  console.log('Opcode overrides:', config.opcode_overrides.length);
  return config;
}

// =============================================================================
// Example 4: Custom Precompile
// =============================================================================

/**
 * Add a custom precompile at address 0x0A
 */
function example4_customPrecompile() {
  // Custom precompile that reverses input bytes
  const reversePrecompile: PrecompileOverride = {
    address: addressFromHex('0x000000000000000000000000000000000000000A'),
    execute: (input: Uint8Array, gas_limit: bigint) => {
      // Gas cost: 15 base + 3 per byte
      const gas_used = 15n + BigInt(input.length) * 3n;

      if (gas_used > gas_limit) {
        return {
          output: new Uint8Array(0),
          gas_used: gas_limit,
          success: false,
        };
      }

      // Reverse the input
      const output = new Uint8Array(input.length);
      for (let i = 0; i < input.length; i++) {
        output[i] = input[input.length - 1 - i];
      }

      return {
        output,
        gas_used,
        success: true,
      };
    },
  };

  const config = createConfig({
    precompile_overrides: [reversePrecompile],
  });

  console.log('Precompile overrides:', config.precompile_overrides.length);
  return config;
}

// =============================================================================
// Example 5: Async Precompile (for FFI/external calls)
// =============================================================================

/**
 * Add an async precompile that fetches data from external source
 */
function example5_asyncPrecompile() {
  // Async precompile for signature verification service
  const externalSigVerify: PrecompileOverride = {
    address: addressFromHex('0x000000000000000000000000000000000000FFFF'),
    execute: async (input: Uint8Array, gas_limit: bigint) => {
      const gas_cost = 10000n;

      if (gas_cost > gas_limit) {
        return {
          output: new Uint8Array(0),
          gas_used: gas_limit,
          success: false,
        };
      }

      // Simulate external API call
      await new Promise((resolve) => setTimeout(resolve, 10));

      // Return verification result (1 = valid, 0 = invalid)
      const output = new Uint8Array(32);
      output[31] = 1; // Valid

      return {
        output,
        gas_used: gas_cost,
        success: true,
      };
    },
    context: { apiUrl: 'https://sig-verify.example.com' },
  };

  const config = createConfig({
    precompile_overrides: [externalSigVerify],
  });

  return config;
}

// =============================================================================
// Example 6: L2-Specific Configuration
// =============================================================================

/**
 * Configure EVM for an L2 with custom gas economics
 */
function example6_l2Config() {
  const l2Config = createConfig({
    hardfork: Hardfork.CANCUN,
    block_gas_limit: 15_000_000n, // Lower than mainnet
    max_call_depth: 256, // More restrictive
    // Disable system contracts not needed on L2
    enable_beacon_roots: false,
    enable_historical_block_hashes: false,
    enable_validator_deposits: false,
    enable_validator_withdrawals: false,
  });

  return l2Config;
}

// =============================================================================
// Example 7: Hardfork Feature Checks
// =============================================================================

/**
 * Use hardfork comparison for feature detection
 */
function example7_hardforkChecks() {
  const config = createConfig({
    hardfork: Hardfork.CANCUN,
  });

  // Check if EIP-1153 (transient storage) is available
  const hasTransientStorage = isAtLeast(config.hardfork, Hardfork.CANCUN);
  console.log('Transient storage available:', hasTransientStorage); // true

  // Check if PUSH0 is available
  const hasPush0 = isAtLeast(config.hardfork, Hardfork.SHANGHAI);
  console.log('PUSH0 available:', hasPush0); // true

  // Check if warm coinbase is available
  const hasWarmCoinbase = isAtLeast(config.hardfork, Hardfork.SHANGHAI);
  console.log('Warm coinbase available:', hasWarmCoinbase); // true
}

// =============================================================================
// Example 8: Production vs Development
// =============================================================================

/**
 * Different configs for different environments
 */
function example8_environmentConfigs() {
  // Production: strict, no debug features
  const prodConfig = createConfig({
    hardfork: Hardfork.CANCUN,
    loop_quota: null, // No quota check (performance)
    block_gas_limit: 30_000_000n,
  });

  // Development: relaxed, debug-friendly
  const devConfig = ConfigPresets.development();
  console.log('Dev loop quota:', devConfig.loop_quota); // 10_000_000
  console.log('Dev gas limit:', devConfig.block_gas_limit); // 100_000_000n

  return process.env.NODE_ENV === 'production' ? prodConfig : devConfig;
}

// =============================================================================
// Example 9: Complete Custom EVM
// =============================================================================

/**
 * Build a fully customized EVM with multiple overrides
 */
function example9_fullyCustomEVM() {
  // Custom opcodes
  const customOpcodes: OpcodeOverride[] = [
    {
      opcode: 0x01, // ADD
      handler: (frame: any) => {
        /* custom logic */
      },
    },
    {
      opcode: 0xFE, // INVALID
      handler: (frame: any) => {
        /* custom logic */
      },
    },
  ];

  // Custom precompiles
  const customPrecompiles: PrecompileOverride[] = [
    {
      address: addressFromHex('0x0000000000000000000000000000000000000001'),
      execute: (input, gas) => ({
        output: new Uint8Array(32),
        gas_used: 3000n,
        success: true,
      }),
    },
    {
      address: addressFromHex('0x00000000000000000000000000000000DEADBEEF'),
      execute: (input, gas) => ({
        output: new Uint8Array(0),
        gas_used: 1000n,
        success: true,
      }),
    },
  ];

  const customEVM = createConfig({
    hardfork: Hardfork.PRAGUE,
    stack_size: 2048,
    max_bytecode_size: 48000,
    block_gas_limit: 50_000_000n,
    opcode_overrides: customOpcodes,
    precompile_overrides: customPrecompiles,
    loop_quota: 5_000_000,
    enable_beacon_roots: true,
    enable_historical_block_hashes: true,
  });

  return customEVM;
}

// =============================================================================
// Run Examples
// =============================================================================

if (import.meta.main) {
  console.log('=== Example 1: Basic Configuration ===');
  example1_basicConfig();

  console.log('\n=== Example 2: Testing Configuration ===');
  example2_testingConfig();

  console.log('\n=== Example 7: Hardfork Checks ===');
  example7_hardforkChecks();

  console.log('\n=== Example 8: Environment Configs ===');
  example8_environmentConfigs();
}
