/**
 * Example 3: EIP-3155 Execution Tracing
 *
 * Demonstrates execution introspection and debugging:
 * - Inspecting storage changes
 * - Reading event logs (LOG0-LOG4)
 * - Analyzing gas refunds
 * - Building execution traces
 * - Debugging contract execution
 *
 * This pattern is essential for:
 * - Debuggers and development tools
 * - Transaction analysis
 * - Gas optimization
 * - Security auditing
 */

import { loadWasm } from './basic-usage.ts';

function hexToAddress(hex: string): Uint8Array {
  const clean = hex.startsWith('0x') ? hex.slice(2) : hex;
  const padded = clean.padStart(40, '0');
  const bytes = new Uint8Array(20);
  for (let i = 0; i < 20; i++) {
    bytes[i] = parseInt(padded.slice(i * 2, i * 2 + 2), 16);
  }
  return bytes;
}

function u256ToBytes(value: bigint): Uint8Array {
  const bytes = new Uint8Array(32);
  let v = value;
  for (let i = 31; i >= 0; i--) {
    bytes[i] = Number(v & 0xFFn);
    v >>= 8n;
  }
  return bytes;
}

function bytesToU256(bytes: Uint8Array): bigint {
  let value = 0n;
  for (let i = 0; i < 32; i++) {
    value = (value << 8n) | BigInt(bytes[i]);
  }
  return value;
}

function addressToHex(address: Uint8Array): string {
  return '0x' + Array.from(address).map(b => b.toString(16).padStart(2, '0')).join('');
}

function bytesToHex(bytes: Uint8Array): string {
  return '0x' + Array.from(bytes).map(b => b.toString(16).padStart(2, '0')).join('');
}

/**
 * Example 1: Inspecting Storage Changes
 *
 * Track which storage slots were modified during execution
 */
async function example1_storageChanges() {
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('Example 1: Inspecting Storage Changes');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  const { api: wasm, alloc, read, release, createEvm } = await loadWasm();

  const evmHandle = createEvm('Cancun');

  try {
    // Bytecode: Write to multiple storage slots
    const bytecode = new Uint8Array([
      // Store 100 at slot 0
      0x60, 0x64,       // PUSH1 100
      0x60, 0x00,       // PUSH1 0 (slot)
      0x55,             // SSTORE

      // Store 200 at slot 1
      0x60, 0xc8,       // PUSH1 200
      0x60, 0x01,       // PUSH1 1 (slot)
      0x55,             // SSTORE

      // Store 300 at slot 5
      0x61, 0x01, 0x2c, // PUSH2 300
      0x60, 0x05,       // PUSH1 5 (slot)
      0x55,             // SSTORE

      0x00              // STOP
    ]);

    console.log('Bytecode: Write to storage slots 0, 1, and 5\n');

    wasm.evm_set_bytecode(evmHandle, alloc(bytecode), bytecode.length);

    const gas = 100000n;
    const caller = hexToAddress('0x1000000000000000000000000000000000000001');
    const address = hexToAddress('0x2000000000000000000000000000000000000002');
    const value = u256ToBytes(0n);
    const calldata = new Uint8Array(0);

    wasm.evm_set_execution_context(
      evmHandle,
      gas,
      alloc(caller),
      alloc(address),
      alloc(value),
      alloc(calldata),
      calldata.length
    );

    const chainId = u256ToBytes(1n);
    const blockNumber = 100n;
    const blockTimestamp = 1700000000n;
    const blockDifficulty = u256ToBytes(0n);
    const blockPrevrandao = u256ToBytes(0n);
    const blockCoinbase = hexToAddress('0x0000000000000000000000000000000000000000');
    const blockGasLimit = 30000000n;
    const blockBaseFee = u256ToBytes(1000000000n);
    const blobBaseFee = u256ToBytes(1n);

    wasm.evm_set_blockchain_context(
      evmHandle,
      alloc(chainId),
      blockNumber,
      blockTimestamp,
      alloc(blockDifficulty),
      alloc(blockPrevrandao),
      alloc(blockCoinbase),
      blockGasLimit,
      alloc(blockBaseFee),
      alloc(blobBaseFee)
    );

    // Execute
    const success = wasm.evm_execute(evmHandle);

    console.log('✅ Execution:', success ? 'SUCCESS' : 'FAILED');

    const gasUsed = wasm.evm_get_gas_used(evmHandle);
    const gasRemaining = wasm.evm_get_gas_remaining(evmHandle);
    const gasRefund = wasm.evm_get_gas_refund(evmHandle);

    console.log(`⛽ Gas used: ${gasUsed}`);
    console.log(`⛽ Gas remaining: ${gasRemaining}`);
    console.log(`💰 Gas refund: ${gasRefund}\n`);

    // Inspect storage changes
    const storageChangeCount = wasm.evm_get_storage_change_count(evmHandle);
    console.log(`📦 Storage Changes (${storageChangeCount} slots modified):\n`);

    const addressOut = alloc(20);
    const slotOut = alloc(32);
    const valueOut = alloc(32);
    for (let i = 0; i < storageChangeCount; i++) {

      const ok = wasm.evm_get_storage_change(evmHandle, i, addressOut, slotOut, valueOut);
      if (ok) {
        const slot = bytesToU256(read(slotOut, 32));
        const value = bytesToU256(read(valueOut, 32));
        console.log(`  Slot ${slot}: ${value}`);
      }
    }

    console.log('');

  } finally {
    wasm.evm_destroy(evmHandle);
    release();
  }
}

/**
 * Example 2: Event Log Analysis
 *
 * Track and analyze LOG0-LOG4 events
 */
async function example2_eventLogs() {
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('Example 2: Event Log Analysis');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  const { api: wasm, alloc, read, release, createEvm } = await loadWasm();

  const evmHandle = createEvm('Cancun');

  try {
    // Bytecode: Emit multiple LOG events
    // LOG1: topic1 = 0xAAAA..., data = "Hello"
    // LOG2: topic1 = 0xBBBB..., topic2 = 0xCCCC..., data = "World"
    const bytecode = new Uint8Array([
      // Prepare data in memory: "Hello" at offset 0
      0x7f, ...[0x48, 0x65, 0x6c, 0x6c, 0x6f, ...new Array(27).fill(0)], // PUSH32 "Hello" (padded)
      0x60, 0x00,       // PUSH1 0 (offset)
      0x52,             // MSTORE

      // LOG1: 1 topic, 5 bytes of data
      0x7f, ...new Array(31).fill(0xaa), 0xaa, // PUSH32 topic1 (0xAAAA...)
      0x60, 0x05,       // PUSH1 5 (data length)
      0x60, 0x00,       // PUSH1 0 (data offset)
      0xa1,             // LOG1

      // Prepare data in memory: "World" at offset 32
      0x7f, ...[0x57, 0x6f, 0x72, 0x6c, 0x64, ...new Array(27).fill(0)], // PUSH32 "World" (padded)
      0x60, 0x20,       // PUSH1 32 (offset)
      0x52,             // MSTORE

      // LOG2: 2 topics, 5 bytes of data
      0x7f, ...new Array(31).fill(0xcc), 0xcc, // PUSH32 topic2 (0xCCCC...)
      0x7f, ...new Array(31).fill(0xbb), 0xbb, // PUSH32 topic1 (0xBBBB...)
      0x60, 0x05,       // PUSH1 5 (data length)
      0x60, 0x20,       // PUSH1 32 (data offset)
      0xa2,             // LOG2

      0x00              // STOP
    ]);

    console.log('Bytecode: Emit LOG1 and LOG2 events\n');

    wasm.evm_set_bytecode(evmHandle, alloc(bytecode), bytecode.length);

    const gas = 100000n;
    const caller = hexToAddress('0x1000000000000000000000000000000000000001');
    const address = hexToAddress('0x2000000000000000000000000000000000000002');
    const value = u256ToBytes(0n);
    const calldata = new Uint8Array(0);

    wasm.evm_set_execution_context(
      evmHandle,
      gas,
      alloc(caller),
      alloc(address),
      alloc(value),
      alloc(calldata),
      calldata.length
    );

    const chainId = u256ToBytes(1n);
    const blockNumber = 100n;
    const blockTimestamp = 1700000000n;
    const blockDifficulty = u256ToBytes(0n);
    const blockPrevrandao = u256ToBytes(0n);
    const blockCoinbase = hexToAddress('0x0000000000000000000000000000000000000000');
    const blockGasLimit = 30000000n;
    const blockBaseFee = u256ToBytes(1000000000n);
    const blobBaseFee = u256ToBytes(1n);

    wasm.evm_set_blockchain_context(
      evmHandle,
      alloc(chainId),
      blockNumber,
      blockTimestamp,
      alloc(blockDifficulty),
      alloc(blockPrevrandao),
      alloc(blockCoinbase),
      blockGasLimit,
      alloc(blockBaseFee),
      alloc(blobBaseFee)
    );

    // Execute
    const success = wasm.evm_execute(evmHandle);

    console.log('✅ Execution:', success ? 'SUCCESS' : 'FAILED');

    const gasUsed = wasm.evm_get_gas_used(evmHandle);
    console.log(`⛽ Gas used: ${gasUsed}\n`);

    // Inspect logs
    const logCount = wasm.evm_get_log_count(evmHandle);
    console.log(`📝 Event Logs (${logCount} emitted):\n`);

    const addressOut = alloc(20);
    const topicsCountOut = alloc(4);
    const topicsOut = alloc(4 * 32);
    const dataLenOut = alloc(4);
    const dataCapacity = 1024;
    const dataOut = alloc(dataCapacity);
    for (let i = 0; i < logCount; i++) {

      const ok = wasm.evm_get_log(
        evmHandle,
        i,
        addressOut,
        topicsCountOut,
        topicsOut,
        dataLenOut,
        dataOut,
        dataCapacity
      );

      if (ok) {
        const metadata = new DataView(wasm.memory.buffer);
        const topicsCount = metadata.getUint32(topicsCountOut, true);
        console.log(`  Log ${i}:`);
        console.log(`    Address: ${addressToHex(read(addressOut, 20))}`);
        console.log(`    Topics (${topicsCount}):`);

        for (let j = 0; j < topicsCount; j++) {
          const topicBytes = read(topicsOut + j * 32, 32);
          const topic = bytesToU256(topicBytes);
          console.log(`      [${j}] ${topic.toString(16).padStart(64, '0')}`);
        }

        const dataLen = metadata.getUint32(dataLenOut, true);
        const data = read(dataOut, Math.min(dataLen, dataCapacity));
        console.log(`    Data (${dataLen} bytes): ${bytesToHex(data)}`);

        // Try to decode as ASCII
        const ascii = Array.from(data)
          .map(b => (b >= 32 && b <= 126 ? String.fromCharCode(b) : '.'))
          .join('');
        console.log(`    Data (ASCII): "${ascii}"`);
        console.log('');
      }
    }

  } finally {
    wasm.evm_destroy(evmHandle);
    release();
  }
}

/**
 * Example 3: Gas Refund Analysis
 *
 * Track gas refunds from SSTORE operations
 */
async function example3_gasRefundAnalysis() {
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('Example 3: Gas Refund Analysis (SSTORE Refunds)');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  const { api: wasm, alloc, read, release, createEvm } = await loadWasm();

  const evmHandle = createEvm('Cancun');

  try {
    // Pre-set storage to generate refunds
    const address = hexToAddress('0x2000000000000000000000000000000000000002');
    wasm.evm_set_storage(
      evmHandle,
      alloc(address),
      alloc(u256ToBytes(0n)),
      alloc(u256ToBytes(100n))
    );

    // Bytecode: Clear storage slot 0 (triggers refund)
    const bytecode = new Uint8Array([
      0x60, 0x00,       // PUSH1 0 (new value)
      0x60, 0x00,       // PUSH1 0 (slot)
      0x55,             // SSTORE (clear slot 0: 100 -> 0, triggers refund)
      0x00              // STOP
    ]);

    console.log('Bytecode: Clear storage slot 0 (100 -> 0)\n');
    console.log('Note: Clearing storage (nonzero -> zero) triggers gas refund\n');

    wasm.evm_set_bytecode(evmHandle, alloc(bytecode), bytecode.length);

    const gas = 100000n;
    const caller = hexToAddress('0x1000000000000000000000000000000000000001');
    const value = u256ToBytes(0n);
    const calldata = new Uint8Array(0);

    wasm.evm_set_execution_context(
      evmHandle,
      gas,
      alloc(caller),
      alloc(address),
      alloc(value),
      alloc(calldata),
      calldata.length
    );

    const chainId = u256ToBytes(1n);
    const blockNumber = 100n;
    const blockTimestamp = 1700000000n;
    const blockDifficulty = u256ToBytes(0n);
    const blockPrevrandao = u256ToBytes(0n);
    const blockCoinbase = hexToAddress('0x0000000000000000000000000000000000000000');
    const blockGasLimit = 30000000n;
    const blockBaseFee = u256ToBytes(1000000000n);
    const blobBaseFee = u256ToBytes(1n);

    wasm.evm_set_blockchain_context(
      evmHandle,
      alloc(chainId),
      blockNumber,
      blockTimestamp,
      alloc(blockDifficulty),
      alloc(blockPrevrandao),
      alloc(blockCoinbase),
      blockGasLimit,
      alloc(blockBaseFee),
      alloc(blobBaseFee)
    );

    // Execute
    const success = wasm.evm_execute(evmHandle);

    console.log('✅ Execution:', success ? 'SUCCESS' : 'FAILED\n');

    const gasUsed = wasm.evm_get_gas_used(evmHandle);
    const gasRemaining = wasm.evm_get_gas_remaining(evmHandle);
    const gasRefund = wasm.evm_get_gas_refund(evmHandle);

    console.log(`⛽ Gas Metrics:`);
    console.log(`   Initial gas: ${gas}`);
    console.log(`   Gas used: ${gasUsed}`);
    console.log(`   Gas remaining: ${gasRemaining}`);
    console.log(`   Gas refund: ${gasRefund}`);
    console.log(`\n💡 Note: Refund is capped at 1/5 of gas used (EIP-3529, London+)`);
    console.log(`   Max refundable: ${Number(gasUsed) / 5}`);
    console.log(`   Actual refund: ${gasRefund}\n`);

    // Check storage changes
    const storageChangeCount = wasm.evm_get_storage_change_count(evmHandle);
    console.log(`📦 Storage Changes:`);

    const addressOut = alloc(20);
    const slotOut = alloc(32);
    const valueOut = alloc(32);
    for (let i = 0; i < storageChangeCount; i++) {

      const ok = wasm.evm_get_storage_change(evmHandle, i, addressOut, slotOut, valueOut);
      if (ok) {
        const slot = bytesToU256(read(slotOut, 32));
        const value = bytesToU256(read(valueOut, 32));
        console.log(`   Slot ${slot}: 100 -> ${value} (cleared)`);
      }
    }

    console.log('');

  } finally {
    wasm.evm_destroy(evmHandle);
    release();
  }
}

/**
 * Run all examples
 */
async function main() {
  console.log('╔═══════════════════════════════════════════════════════════╗');
  console.log('║      Guillotine Mini - Execution Tracing Examples        ║');
  console.log('╚═══════════════════════════════════════════════════════════╝\n');

  try {
    await example1_storageChanges();
    await example2_eventLogs();
    await example3_gasRefundAnalysis();

    console.log('✅ All tracing examples completed successfully!');
  } catch (error) {
    console.error('❌ Error running examples:', error);
    process.exit(1);
  }
}

main();
