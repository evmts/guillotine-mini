/**
 * Simple example showing how to use the Guillotine Mini EVM SDK
 */
import { createEvm } from '../src/index.js';

async function main() {
  console.log('Creating EVM instance with Cancun hardfork...');
  const evm = await createEvm({ hardfork: 'CANCUN' });
  console.log('✓ EVM ready');

  // Simple program: PUSH1 1 PUSH1 1 ADD (returns 2)
  await evm.setBytecode('0x6001600101');
  console.log('✓ Bytecode set');

  // Set execution context
  await evm.setExecutionContext({
    gas: 100000n,
    caller: '0x1234567890123456789012345678901234567890',
    address: '0x0000000000000000000000000000000000000001',
    value: 0n,
    calldata: '0x',
  });
  console.log('✓ Execution context set');

  // Set blockchain context (all fields required)
  await evm.setBlockchainContext({
    chainId: 1n,
    blockNumber: 1000000n,
    blockTimestamp: BigInt(Date.now() / 1000),
    blockDifficulty: 0n,  // Use 0 for PoS
    blockPrevrandao: 0n,
    blockCoinbase: '0x0000000000000000000000000000000000000000',
    blockGasLimit: 30000000n,
    blockBaseFee: 10n ** 9n,  // 1 gwei
    blobBaseFee: 1n,
  });
  console.log('✓ Blockchain context set');

  // Execute
  console.log('\nExecuting bytecode...');
  const result = await evm.execute();

  console.log('\nResult:');
  console.log('  Success:', result.success);
  console.log('  Gas used:', result.gasUsed);
  console.log('  Gas remaining:', result.gasRemaining);
  console.log('  Output:', result.output);

  // Clean up
  await evm.destroy();
  console.log('\n✓ EVM destroyed');
}

main().catch(console.error);
