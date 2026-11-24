/**
 * Async Execution with External Storage Backend
 *
 * After building the WASM reactor, run with Node.js 24 or newer:
 *   node examples/typescript/async-execution.ts
 *
 * Demonstrates the async execution protocol for integrating with external state:
 * - Starting async execution with evm_call_ffi
 * - Handling storage and balance requests
 * - Resuming execution with evm_continue_ffi
 * - Processing state change commits
 * - Building a complete async execution loop
 *
 * This pattern is essential for integrating the EVM with:
 * - Database backends (PostgreSQL, LevelDB)
 * - Remote state providers (RPC nodes)
 * - Layer 2 solutions
 * - State channels
 */

import { readFileSync } from 'node:fs';
import { WASI } from 'node:wasi';

type WasmExports = WebAssembly.Exports & {
  memory: WebAssembly.Memory;
  evm_alloc(length: number): number;
  evm_free(pointer: number, length: number): void;
  evm_create(hardfork: number, length: number, logLevel: number): number;
  evm_destroy(handle: number): void;
  evm_enable_storage_injector(handle: number): number;
  evm_set_bytecode(handle: number, code: number, length: number): number;
  evm_set_execution_context(
    handle: number, gas: bigint, caller: number, address: number, value: number, calldata: number, length: number
  ): number;
  evm_set_blockchain_context(
    handle: number, chainId: number, blockNumber: bigint, timestamp: bigint, difficulty: number,
    prevrandao: number, coinbase: number, gasLimit: bigint, baseFee: number, blobBaseFee: number
  ): void;
  evm_call_ffi(handle: number, request: number): number;
  evm_continue_ffi(handle: number, type: number, data: number, length: number, request: number): number;
  evm_get_state_changes_len(handle: number): number;
  evm_get_state_changes(handle: number, buffer: number, length: number): number;
  evm_is_success(handle: number): number;
  evm_get_output_len(handle: number): number;
  evm_get_output(handle: number, buffer: number, length: number): number;
  evm_get_gas_used(handle: number): bigint;
};

async function loadWasm(): Promise<WasmExports> {
  const bytes = readFileSync(new URL('../../zig-out/bin/guillotine_mini.wasm', import.meta.url));
  const wasi = new WASI({ version: 'preview1' });
  const { instance } = await WebAssembly.instantiate(bytes, {
    wasi_snapshot_preview1: wasi.wasiImport,
    env: {
      js_opcode_callback: () => 0,
      js_precompile_callback: () => 0,
    },
  });
  wasi.initialize(instance);
  return instance.exports as WasmExports;
}

const RequestType = {
  RESULT: 0,
  NEED_STORAGE: 1,
  NEED_BALANCE: 2,
  READY_TO_COMMIT: 5,
  ERROR: 255,
} as const;

// wasm32 layout of AsyncRequest in src/root_c.zig. Three padding bytes follow slot.
const JSON_LENGTH_OFFSET = 56;
const JSON_DATA_OFFSET = 60;
const JSON_INLINE_CAPACITY = 16384;
const REQUEST_SIZE = JSON_DATA_OFFSET + JSON_INLINE_CAPACITY;

function allocate(wasm: WasmExports, length: number): number {
  const pointer = wasm.evm_alloc(length);
  if (!pointer) throw new Error('WASM buffer allocation failed');
  return pointer;
}

function readStateChanges(wasm: WasmExports, handle: number, request: number): string {
  const length = new DataView(wasm.memory.buffer).getUint32(request + JSON_LENGTH_OFFSET, true);
  const decoder = new TextDecoder();
  if (length <= JSON_INLINE_CAPACITY) {
    return decoder.decode(new Uint8Array(wasm.memory.buffer, request + JSON_DATA_OFFSET, length));
  }

  const fullLength = wasm.evm_get_state_changes_len(handle);
  if (fullLength !== length) throw new Error('Inconsistent state changes length');
  const buffer = allocate(wasm, fullLength);
  try {
    const copiedLength = wasm.evm_get_state_changes(handle, buffer, fullLength);
    if (copiedLength !== fullLength) throw new Error('State changes length changed before copying');
    return decoder.decode(new Uint8Array(wasm.memory.buffer, buffer, fullLength));
  } finally {
    wasm.evm_free(buffer, fullLength);
  }
}

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
  for (const byte of bytes) {
    value = (value << 8n) | BigInt(byte);
  }
  return value;
}

function addressToHex(address: Uint8Array): string {
  return '0x' + Array.from(address).map(b => b.toString(16).padStart(2, '0')).join('');
}

/**
 * Mock external state backend
 * In production, this would query a database or RPC node
 */
class ExternalStateBackend {
  private storage = new Map<string, Map<string, bigint>>();

  private requestCount = 0;

  async getStorage(address: Uint8Array, slot: bigint): Promise<bigint> {
    this.requestCount++;
    console.log(`  📡 [Request ${this.requestCount}] Storage read: ${addressToHex(address)} slot ${slot}`);

    // Simulate async database query
    await this.simulateLatency();

    const addrKey = addressToHex(address);
    const slotMap = this.storage.get(addrKey);
    if (!slotMap) {
      console.log(`     ↳ Value: 0 (uninitialized)`);
      return 0n;
    }
    const value = slotMap.get(slot.toString(16)) ?? 0n;
    console.log(`     ↳ Value: ${value}`);
    return value;
  }

  async getBalance(address: Uint8Array): Promise<bigint> {
    this.requestCount++;
    console.log(`  📡 [Request ${this.requestCount}] Balance read: ${addressToHex(address)}`);

    await this.simulateLatency();

    console.log('     ↳ Balance: 0 wei');
    return 0n;
  }

  async commitStateChanges(changesJson: string): Promise<void> {
    console.log(`\n  💾 Committing state changes...`);
    console.log(`     JSON payload: ${changesJson.substring(0, 100)}${changesJson.length > 100 ? '...' : ''}`);

    await this.simulateLatency();

    // A real backend would persist the decoded changes before returning.
    JSON.parse(changesJson);
    console.log('     ✅ State changes committed');
  }

  // Pre-populate state for testing
  setStorage(address: Uint8Array, slot: bigint, value: bigint): void {
    const addrKey = addressToHex(address);
    let slotMap = this.storage.get(addrKey);
    if (!slotMap) {
      slotMap = new Map();
      this.storage.set(addrKey, slotMap);
    }
    slotMap.set(slot.toString(16), value);
  }

  private async simulateLatency(): Promise<void> {
    // Simulate 10-50ms database/network latency
    const delay = Math.random() * 40 + 10;
    await new Promise(resolve => setTimeout(resolve, delay));
  }
}

async function executeAsync(
  wasm: WasmExports, handle: number, request: number, backend: ExternalStateBackend
): Promise<number> {
  let ok = wasm.evm_call_ffi(handle, request);
  for (let iteration = 1; iteration <= 100; iteration++) {
    const memory = new Uint8Array(wasm.memory.buffer, request, REQUEST_SIZE);
    const type = memory[0];
    if (!ok || type === RequestType.ERROR) throw new Error('Async execution failed');

    switch (type) {
      case RequestType.RESULT:
        return iteration;
      case RequestType.NEED_STORAGE: {
        const address = memory.slice(1, 21);
        const slot = memory.slice(21, 53);
        const value = await backend.getStorage(address, bytesToU256(slot));
        const response = new Uint8Array(84);
        response.set(address, 0);
        response.set(slot, 20);
        response.set(u256ToBytes(value), 52);
        ok = resume(type, response);
        break;
      }
      case RequestType.NEED_BALANCE: {
        const address = memory.slice(1, 21);
        const balance = await backend.getBalance(address);
        const response = new Uint8Array(52);
        response.set(address, 0);
        response.set(u256ToBytes(balance), 20);
        ok = resume(type, response);
        break;
      }
      case RequestType.READY_TO_COMMIT:
        await backend.commitStateChanges(readStateChanges(wasm, handle, request));
        ok = wasm.evm_continue_ffi(handle, type, request, 0, request);
        break;
      default:
        throw new Error(`Unknown async request type: ${type}`);
    }
  }
  throw new Error('Async execution exceeded 100 iterations');

  function resume(type: number, bytes: Uint8Array): number {
    const response = allocate(wasm, bytes.length);
    try {
      new Uint8Array(wasm.memory.buffer, response, bytes.length).set(bytes);
      return wasm.evm_continue_ffi(handle, type, response, bytes.length, request);
    } finally {
      wasm.evm_free(response, bytes.length);
    }
  }
}

async function runExample(title: string, bytecode: Uint8Array, slots: bigint[], expected: bigint) {
  console.log(`\n${title}`);
  const wasm = await loadWasm();
  const backend = new ExternalStateBackend();
  const contract = hexToAddress('0x2000000000000000000000000000000000000002');
  slots.forEach((value, index) => backend.setStorage(contract, BigInt(index), value));

  const buffers: [number, number][] = [];
  function transfer(data: Uint8Array | number): number {
    const length = typeof data === 'number' ? data : data.length;
    const pointer = allocate(wasm, length);
    buffers.push([pointer, length]);
    if (typeof data !== 'number') {
      new Uint8Array(wasm.memory.buffer, pointer, length).set(data);
    }
    return pointer;
  }

  let handle = 0;
  try {
    const fork = new TextEncoder().encode('cancun');
    handle = wasm.evm_create(transfer(fork), fork.length, 0);
    if (!handle) throw new Error('Failed to create EVM instance');
    if (!wasm.evm_enable_storage_injector(handle)) throw new Error('Failed to enable storage injector');
    if (!wasm.evm_set_bytecode(handle, transfer(bytecode), bytecode.length)) {
      throw new Error('Failed to set bytecode');
    }

    const caller = transfer(hexToAddress('0x1000000000000000000000000000000000000001'));
    const address = transfer(contract);
    const zero = transfer(u256ToBytes(0n));
    if (!wasm.evm_set_execution_context(handle, 100000n, caller, address, zero, zero, 0)) {
      throw new Error('Failed to set execution context');
    }

    const one = transfer(u256ToBytes(1n));
    const coinbase = transfer(hexToAddress('0x0'));
    const baseFee = transfer(u256ToBytes(1000000000n));
    wasm.evm_set_blockchain_context(handle, one, 100n, 1700000000n, zero, zero, coinbase, 30000000n, baseFee, one);

    const iterations = await executeAsync(wasm, handle, transfer(REQUEST_SIZE), backend);
    if (!wasm.evm_is_success(handle)) throw new Error('EVM execution did not succeed');
    const outputLength = wasm.evm_get_output_len(handle);
    if (outputLength !== 32) throw new Error(`Expected 32 output bytes, got ${outputLength}`);
    const output = transfer(outputLength);
    if (wasm.evm_get_output(handle, output, outputLength) !== outputLength) {
      throw new Error('Failed to read EVM output');
    }

    const result = bytesToU256(new Uint8Array(wasm.memory.buffer, output, outputLength));
    if (result !== expected) throw new Error(`Expected ${expected}, got ${result}`);
    console.log(`Output: ${result}`);
    console.log(`Gas used: ${wasm.evm_get_gas_used(handle)}`);
    console.log(`Async iterations: ${iterations}`);
  } finally {
    if (handle) wasm.evm_destroy(handle);
    for (const [pointer, length] of buffers.reverse()) wasm.evm_free(pointer, length);
  }
}

async function main() {
  await runExample('Example 1: Async storage load', new Uint8Array([
    0x60, 0x00, 0x54, // Load slot 0.
    0x60, 0x00, 0x52, // Store the value in memory.
    0x60, 0x20, 0x60, 0x00, 0xf3, // Return 32 bytes.
  ]), [42n], 42n);

  await runExample('Example 2: Multiple async storage requests', new Uint8Array([
    0x60, 0x00, 0x54, // Load slot 0.
    0x60, 0x01, 0x54, 0x01, // Add slot 1.
    0x60, 0x02, 0x54, 0x01, // Add slot 2.
    0x60, 0x00, 0x52, // Store the sum in memory.
    0x60, 0x20, 0x60, 0x00, 0xf3, // Return 32 bytes.
  ]), [10n, 20n, 30n], 60n);

  console.log('\nAll async examples completed successfully.');
}

main().catch((error) => {
  console.error('Error running async examples:', error);
  process.exitCode = 1;
});
