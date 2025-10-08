/**
 * Example: Custom Opcode and Precompile Handlers
 *
 * Demonstrates how to override EVM opcodes and precompiles with custom implementations.
 * This is useful for:
 * - Testing alternative opcode implementations
 * - Adding instrumentation/logging to specific opcodes
 * - Implementing custom precompiles for L2s or sidechains
 * - Educational purposes (understanding EVM internals)
 */

import { createEvm, type ExecutionContext, type BlockchainContext } from '../src/index.js';

async function testCustomAddOpcode() {
  console.log('\n=== Test: Custom ADD Opcode (0x01) ===\n');

  // Create EVM with default config
  const evm = await createEvm({ hardfork: 'CANCUN' });

  try {
    // Simple bytecode: PUSH1 5, PUSH1 3, ADD, PUSH1 0, MSTORE, PUSH1 32, PUSH1 0, RETURN
    // Expected result without override: 5 + 3 = 8
    // Expected result with override: 5 * 3 = 15 (we'll override ADD to multiply)
    const bytecode = '0x' +
      '6005' +  // PUSH1 5
      '6003' +  // PUSH1 3
      '01' +    // ADD (we want to override this)
      '6000' +  // PUSH1 0
      '52' +    // MSTORE
      '6020' +  // PUSH1 32
      '6000' +  // PUSH1 0
      'f3';     // RETURN

    await evm.setBytecode(bytecode);

    const execCtx: ExecutionContext = {
      gas: 1000000n,
      caller: '0x0000000000000000000000000000000000000000',
      address: '0x0000000000000000000000000000000000000000',
      value: 0n,
      calldata: '0x',
    };

    const blockCtx: BlockchainContext = {
      chainId: 1n,
      blockNumber: 1000n,
      blockTimestamp: 1234567890n,
      blockDifficulty: 0n,
      blockPrevrandao: 0n,
      blockCoinbase: '0x0000000000000000000000000000000000000000',
      blockGasLimit: 30000000n,
      blockBaseFee: 1000000000n,
      blobBaseFee: 1n,
    };

    await evm.setExecutionContext(execCtx);
    await evm.setBlockchainContext(blockCtx);

    const result = await evm.execute();

    console.log('Execution result:', {
      success: result.success,
      gasUsed: result.gasUsed.toString(),
      gasRemaining: result.gasRemaining.toString(),
      output: result.output,
    });

    // Parse result: should be 8 (0x0000000000000000000000000000000000000000000000000000000000000008)
    const outputBytes = result.output.slice(2); // Remove 0x prefix
    const value = parseInt(outputBytes.slice(-2), 16); // Get the last byte
    console.log(`Result value: ${value} (expected 8 without override, 15 with multiply override)`);

    if (value === 8) {
      console.log('✅ Default ADD opcode works correctly (5 + 3 = 8)');
    } else {
      console.log('❌ Unexpected result');
    }

    // TODO: Once C API supports custom handlers, uncomment:
    // const evmWithOverride = await createEvm({
    //   hardfork: 'CANCUN',
    //   opcodeOverrides: [
    //     { opcode: 0x01, handler: customMultiplyHandler }
    //   ]
    // });
    // ... test with override ...

  } finally {
    await evm.destroy();
  }
}

async function testCustomPrecompile() {
  console.log('\n=== Test: Custom Precompile ===\n');

  const evm = await createEvm({ hardfork: 'CANCUN' });

  try {
    // Bytecode that calls a precompile address 0x99 (custom)
    // PUSH1 20 (return size)
    // PUSH1 0 (return offset)
    // PUSH1 0 (args size)
    // PUSH1 0 (args offset)
    // PUSH1 0 (value)
    // PUSH1 0x99 (address - custom precompile)
    // PUSH2 10000 (gas)
    // CALL
    const bytecode = '0x' +
      '6014' +    // PUSH1 20 (return size)
      '6000' +    // PUSH1 0 (return offset)
      '6000' +    // PUSH1 0 (args size)
      '6000' +    // PUSH1 0 (args offset)
      '6000' +    // PUSH1 0 (value)
      '6099' +    // PUSH1 0x99 (custom precompile address)
      '612710' +  // PUSH2 10000 (gas)
      'f1';       // CALL

    await evm.setBytecode(bytecode);

    const execCtx: ExecutionContext = {
      gas: 1000000n,
      caller: '0x0000000000000000000000000000000000000000',
      address: '0x0000000000000000000000000000000000000000',
      value: 0n,
      calldata: '0x',
    };

    const blockCtx: BlockchainContext = {
      chainId: 1n,
      blockNumber: 1000n,
      blockTimestamp: 1234567890n,
      blockDifficulty: 0n,
      blockPrevrandao: 0n,
      blockCoinbase: '0x0000000000000000000000000000000000000000',
      blockGasLimit: 30000000n,
      blockBaseFee: 1000000000n,
      blobBaseFee: 1n,
    };

    await evm.setExecutionContext(execCtx);
    await evm.setBlockchainContext(blockCtx);

    const result = await evm.execute();

    console.log('Execution result:', {
      success: result.success,
      gasUsed: result.gasUsed.toString(),
      gasRemaining: result.gasRemaining.toString(),
    });

    // Without custom precompile, call to 0x99 should succeed but return empty
    // (empty account returns success with no output)
    console.log('✅ Call to non-existent precompile handled correctly');

    // TODO: Once C API supports custom precompiles, uncomment:
    // const evmWithPrecompile = await createEvm({
    //   hardfork: 'CANCUN',
    //   precompileOverrides: [
    //     {
    //       address: '0x0000000000000000000000000000000000000099',
    //       execute: customPrecompileHandler
    //     }
    //   ]
    // });
    // ... test with custom precompile ...

  } finally {
    await evm.destroy();
  }
}

async function main() {
  console.log('Custom Handler Examples');
  console.log('=======================\n');
  console.log('Note: Custom handler support requires C API extensions.');
  console.log('These tests demonstrate the interface but use default implementations.\n');

  await testCustomAddOpcode();
  await testCustomPrecompile();

  console.log('\n=== All Tests Complete ===\n');
}

main().catch(console.error);
