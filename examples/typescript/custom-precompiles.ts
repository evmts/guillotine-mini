/**
 * Example 4: Custom Precompiles
 *
 * Demonstrates extending the EVM with custom precompiled contracts:
 * - Registering custom precompile handlers via JavaScript callbacks
 * - Calling precompiles from bytecode
 * - Handling gas metering for custom operations
 * - Building domain-specific EVM extensions
 *
 * This pattern enables:
 * - Layer 2 solutions with custom opcodes
 * - Rollups with specialized cryptography
 * - Private chains with custom functionality
 * - Testing and development environments
 */

import { loadWasm } from './basic-usage.ts';

// Helper functions
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
 * Custom Precompile Registry
 * Maps addresses to handler functions
 */
interface PrecompileHandler {
  (input: Uint8Array, gasLimit: bigint): {
    success: boolean;
    output: Uint8Array;
    gasUsed: bigint;
  };
}

class PrecompileRegistry {
  private handlers = new Map<string, PrecompileHandler>();

  register(address: string, handler: PrecompileHandler): void {
    this.handlers.set(address.toLowerCase(), handler);
    console.log(`✅ Registered custom precompile at ${address}`);
  }

  handle(address: Uint8Array, input: Uint8Array, gasLimit: bigint): {
    success: boolean;
    output: Uint8Array;
    gasUsed: bigint;
  } | null {
    const addrHex = addressToHex(address).toLowerCase();
    const handler = this.handlers.get(addrHex);

    if (!handler) {
      return null; // Not handled by custom precompiles
    }

    console.log(`\n🔧 Custom precompile invoked: ${addrHex}`);
    console.log(`   Input: ${bytesToHex(input)}`);
    console.log(`   Gas limit: ${gasLimit}`);

    const result = handler(input, gasLimit);

    console.log(`   Output: ${bytesToHex(result.output)}`);
    console.log(`   Gas used: ${result.gasUsed}`);
    console.log(`   Success: ${result.success}`);

    return result;
  }
}

/**
 * Load WASM with custom precompile callback
 */
function loadWasmWithPrecompiles(registry: PrecompileRegistry) {
  return loadWasm((memory, alloc, addressPtr, inputPtr, inputLength, gasLimit, outputLengthPtr, outputPtrPtr, gasUsedPtr) => {
    try {
      const address = new Uint8Array(memory.buffer, addressPtr, 20).slice();
      const input = new Uint8Array(memory.buffer, inputPtr, inputLength).slice();
      const result = registry.handle(address, input, gasLimit);
      if (!result?.success) return 0;

      // The EVM copies the callback result before returning to the caller.
      const outputPtr = alloc(result.output);
      const metadata = new DataView(memory.buffer);
      metadata.setUint32(outputLengthPtr, result.output.length, true);
      metadata.setUint32(outputPtrPtr, outputPtr, true);
      metadata.setBigUint64(gasUsedPtr, result.gasUsed, true);
      return 1;
    } catch (error) {
      console.error('Error in precompile callback:', error);
      return 0;
    }
  });
}

/**
 * Example 1: Simple Custom Precompile (String Reverser)
 *
 * Address: 0x0000000000000000000000000000000000001000
 * Input: UTF-8 string bytes
 * Output: Reversed UTF-8 string bytes
 * Gas: 100 + 10 per byte
 */
async function example1_stringReverser() {
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('Example 1: Custom Precompile - String Reverser');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  const registry = new PrecompileRegistry();

  // Register string reverser at address 0x1000
  registry.register('0x0000000000000000000000000000000000001000', (input, gasLimit) => {
    const gasCost = 100n + BigInt(input.length) * 10n;

    if (gasCost > gasLimit) {
      return {
        success: false,
        output: new Uint8Array(0),
        gasUsed: gasLimit, // Consume all gas on failure
      };
    }

    // Reverse the bytes
    const output = new Uint8Array(input.length);
    for (let i = 0; i < input.length; i++) {
      output[i] = input[input.length - 1 - i];
    }

    return {
      success: true,
      output,
      gasUsed: gasCost,
    };
  });

  const { api: wasm, alloc, release, createEvm, readOutput } = await loadWasmWithPrecompiles(registry);

  const evmHandle = createEvm('Cancun');

  try {
    // Store "Hello World!" in memory and call precompile
    const inputText = "Hello World!";
    const inputBytes = new TextEncoder().encode(inputText);

    // Bytecode:
    // 1. Store input in memory
    // 2. CALL precompile at 0x1000
    // 3. Return output
    const bytecode = new Uint8Array([
      // Store "Hello World!" in memory at offset 0
      // PUSH32 "Hello World!" (padded)
      0x7f, ...Array.from(inputBytes), ...new Array(32 - inputBytes.length).fill(0),
      0x60, 0x00,       // PUSH1 0 (offset)
      0x52,             // MSTORE

      // CALL(gas, to, value, argsOffset, argsSize, retOffset, retSize)
      0x60, 0x20,       // PUSH1 32 (retSize - max output)
      0x60, 0x20,       // PUSH1 32 (retOffset)
      0x60, 0x0c,       // PUSH1 12 (argsSize - "Hello World!" length)
      0x60, 0x00,       // PUSH1 0 (argsOffset)
      0x60, 0x00,       // PUSH1 0 (value)
      0x61, 0x10, 0x00, // PUSH2 0x1000 (precompile address)
      0x61, 0xff, 0xff, // PUSH2 65535 (gas for call)
      0xf1,             // CALL

      // Return the output (32 bytes from offset 32)
      0x60, 0x20,       // PUSH1 32 (length)
      0x60, 0x20,       // PUSH1 32 (offset)
      0xf3              // RETURN
    ]);

    console.log(`Input: "${inputText}"`);
    console.log(`Expected output: "${inputText.split('').reverse().join('')}"\n`);

    wasm.evm_set_bytecode(evmHandle, alloc(bytecode), bytecode.length);

    const gas = 1000000n;
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
    console.log('🚀 Executing bytecode...\n');
    const success = wasm.evm_execute(evmHandle);

    console.log('\n✅ Execution:', success ? 'SUCCESS' : 'FAILED');

    const gasUsed = wasm.evm_get_gas_used(evmHandle);
    console.log(`⛽ Gas used: ${gasUsed}\n`);

    // Get output
    const outputBuffer = readOutput(evmHandle);
    if (outputBuffer.length > 0) {

      // Decode as string (remove padding)
      let text = '';
      for (let i = 0; i < outputBuffer.length; i++) {
        if (outputBuffer[i] === 0) break; // Stop at null terminator/padding
        text += String.fromCharCode(outputBuffer[i]);
      }

      console.log('📤 Output (raw):', bytesToHex(outputBuffer));
      console.log(`📤 Output (string): "${text}"`);
      console.log(`✅ Match: ${text === inputText.split('').reverse().join('')}`);
    }

    console.log('');

  } finally {
    wasm.evm_destroy(evmHandle);
    release();
  }
}

/**
 * Example 2: Mathematical Precompile (Fibonacci)
 *
 * Address: 0x0000000000000000000000000000000000002000
 * Input: 32-byte u256 (n)
 * Output: 32-byte u256 (fibonacci(n))
 * Gas: 50 + 20 * n
 */
async function example2_fibonacci() {
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('Example 2: Custom Precompile - Fibonacci Calculator');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  const registry = new PrecompileRegistry();

  // Register fibonacci calculator at address 0x2000
  registry.register('0x0000000000000000000000000000000000002000', (input, gasLimit) => {
    if (input.length < 32) {
      return {
        success: false,
        output: new Uint8Array(0),
        gasUsed: 0n,
      };
    }

    const n = bytesToU256(input.slice(0, 32));

    // Gas cost: 50 base + 20 per iteration
    const gasCost = 50n + 20n * n;

    if (gasCost > gasLimit) {
      return {
        success: false,
        output: new Uint8Array(0),
        gasUsed: gasLimit,
      };
    }

    // Limit n to prevent overflow (fibonacci grows exponentially)
    if (n > 93n) {
      return {
        success: false,
        output: new Uint8Array(0),
        gasUsed: gasCost,
      };
    }

    // Calculate fibonacci
    let a = 0n;
    let b = 1n;
    for (let i = 0n; i < n; i++) {
      [a, b] = [b, a + b];
    }

    const result = a;
    const output = u256ToBytes(result);

    return {
      success: true,
      output,
      gasUsed: gasCost,
    };
  });

  const { api: wasm, alloc, release, createEvm, readOutput } = await loadWasmWithPrecompiles(registry);

  const evmHandle = createEvm('Cancun');

  try {
    const n = 10n;
    console.log(`Computing fibonacci(${n})...\n`);

    // Bytecode: Call fibonacci precompile with n=10
    const bytecode = new Uint8Array([
      // PUSH32 n (input)
      0x7f, ...Array.from(u256ToBytes(n)),

      // Store n in memory
      0x60, 0x00,       // PUSH1 0 (offset)
      0x52,             // MSTORE

      // CALL(gas, to, value, argsOffset, argsSize, retOffset, retSize)
      0x60, 0x20,       // PUSH1 32 (retSize)
      0x60, 0x20,       // PUSH1 32 (retOffset)
      0x60, 0x20,       // PUSH1 32 (argsSize)
      0x60, 0x00,       // PUSH1 0 (argsOffset)
      0x60, 0x00,       // PUSH1 0 (value)
      0x61, 0x20, 0x00, // PUSH2 0x2000 (precompile address)
      0x62, 0x0f, 0xff, 0xff, // PUSH3 65535 (gas)
      0xf1,             // CALL

      // Return result
      0x60, 0x20,       // PUSH1 32
      0x60, 0x20,       // PUSH1 32
      0xf3              // RETURN
    ]);

    wasm.evm_set_bytecode(evmHandle, alloc(bytecode), bytecode.length);

    const gas = 1000000n;
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
    console.log('🚀 Executing bytecode...\n');
    const success = wasm.evm_execute(evmHandle);

    console.log('\n✅ Execution:', success ? 'SUCCESS' : 'FAILED');

    const gasUsed = wasm.evm_get_gas_used(evmHandle);
    console.log(`⛽ Gas used: ${gasUsed}\n`);

    // Get output
    const outputBuffer = readOutput(evmHandle);
    if (outputBuffer.length > 0) {

      const result = bytesToU256(outputBuffer);
      console.log(`📤 fibonacci(${n}) = ${result}`);

      // Verify (fibonacci(10) = 55)
      const expected = 55n;
      console.log(`✅ Expected: ${expected}, Got: ${result}, Match: ${result === expected}`);
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
  console.log('║     Guillotine Mini - Custom Precompile Examples         ║');
  console.log('╚═══════════════════════════════════════════════════════════╝\n');

  try {
    await example1_stringReverser();
    await example2_fibonacci();

    console.log('✅ All custom precompile examples completed successfully!');
  } catch (error) {
    console.error('❌ Error running examples:', error);
    process.exit(1);
  }
}

main();
