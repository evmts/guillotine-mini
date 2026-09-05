import assert from 'node:assert/strict'
import { createHash } from 'node:crypto'
import { readFile } from 'node:fs/promises'
import { test } from 'node:test'
import { WASI } from 'node:wasi'

const bytes = await readFile(process.argv[2] ?? new URL('../zig-out/bin/guillotine_mini.wasm', import.meta.url))
const module = await WebAssembly.compile(bytes)

async function fixture() {
  const wasi = new WASI({ version: 'preview1' })
  const instance = await WebAssembly.instantiate(module, {
    wasi_snapshot_preview1: wasi.wasiImport,
    env: { js_opcode_callback: () => 0, js_precompile_callback: () => 0 },
  })
  wasi.initialize(instance)
  const api = instance.exports
  const allocations = []
  function alloc(value) {
    const data = typeof value === 'number' ? new Uint8Array(value) : value
    const ptr = api.evm_alloc(data.length)
    assert.ok(ptr, 'host transfer allocation succeeds')
    new Uint8Array(api.memory.buffer, ptr, data.length).set(data)
    allocations.push([ptr, data.length])
    return ptr
  }
  const fork = new TextEncoder().encode('prague')
  const handle = api.evm_create(alloc(fork), fork.length, 0)
  assert.ok(handle, 'EVM initialization succeeds')
  const addressBytes = new Uint8Array(20)
  addressBytes[18] = 1 // 0x100 is not a precompile.
  const address = alloc(addressBytes)
  const zero = alloc(32)
  const caller = alloc(20)
  api.evm_set_blockchain_context(handle, zero, 1n, 1_720_000_000n, zero, zero, caller, 30_000_000n, zero, zero)
  function execute(code, { input = new Uint8Array(), gas = 1_000_000n } = {}) {
    const bytecode = typeof code === 'string' ? Buffer.from(code, 'hex') : code
    assert.equal(api.evm_set_bytecode(handle, alloc(bytecode), bytecode.length), 1)
    const inputPtr = input.length ? alloc(input) : zero
    assert.equal(api.evm_set_execution_context(handle, gas, caller, address, zero, inputPtr, input.length), 1)
    const success = api.evm_execute(handle) === 1
    const length = api.evm_get_output_len(handle)
    const outputPtr = length ? alloc(length) : zero
    assert.equal(api.evm_get_output(handle, outputPtr, length), length)
    const output = Buffer.from(new Uint8Array(api.memory.buffer, outputPtr, length))
    return { success, output, gasUsed: api.evm_get_gas_used(handle) }
  }
  function close() {
    api.evm_destroy(handle)
    for (const [ptr, len] of allocations.reverse()) api.evm_free(ptr, len)
  }
  return { api, alloc, handle, address, zero, execute, close }
}

test('WASI reactor contains crypto implementations and exports its complete C API', () => {
  const exports = new Set(WebAssembly.Module.exports(module).map(({ name }) => name))
  for (const name of ['memory', '_initialize', 'evm_alloc', 'evm_free', 'evm_create', 'evm_destroy', 'evm_execute',
    'evm_set_nonce', 'evm_get_log_count', 'evm_get_log', 'evm_get_gas_refund', 'evm_get_storage_change_count',
    'evm_get_storage_change', 'evm_call_ffi', 'evm_continue_ffi', 'evm_get_state_changes']) assert.ok(exports.has(name), name)
  assert.equal(exports.has('_start'), false)
  assert.equal(exports.has('main'), false)
  assert.deepEqual(WebAssembly.Module.imports(module).filter(({ module }) => module !== 'wasi_snapshot_preview1')
    .map(({ module, name }) => `${module}.${name}`).sort(), ['env.js_opcode_callback', 'env.js_precompile_callback'])
})

test('executes arithmetic bytecode and returns output and gas', async () => {
  const f = await fixture()
  try {
    const result = f.execute('602a60005260206000f3')
    assert.equal(result.success, true)
    assert.equal(result.output.toString('hex'), '00'.repeat(31) + '2a')
    assert.equal(result.gasUsed, 18n)
    assert.equal(f.api.evm_is_success(f.handle), 1)
    assert.equal(f.api.evm_get_gas_remaining(f.handle), 1_000_000n - result.gasUsed)
  } finally { f.close() }
})

test('preserves revert data and reports out of gas', async () => {
  const f = await fixture()
  try {
    const result = f.execute('63deadbeef6000526004601cfd')
    assert.equal(result.success, false)
    assert.equal(result.output.toString('hex'), 'deadbeef')
    assert.equal(f.api.evm_is_success(f.handle), 0)
    const exhausted = f.execute('602a60005260206000f3', { gas: 2n })
    assert.equal(exhausted.success, false)
    assert.equal(exhausted.output.length, 0)
    assert.equal(exhausted.gasUsed, 2n)
  } finally { f.close() }
})

test('exposes storage writes and logs through the WASM C API', async () => {
  const f = await fixture()
  try {
    const result = f.execute('602a600055602a600052600760206000a100')
    assert.equal(result.success, true)
    const storage = f.alloc(32)
    assert.equal(f.api.evm_get_storage(f.handle, f.address, f.zero, storage), 1)
    assert.equal(new Uint8Array(f.api.memory.buffer, storage, 32)[31], 42)
    assert.equal(f.api.evm_get_storage_change_count(f.handle), 1)
    assert.equal(f.api.evm_get_log_count(f.handle), 1)
    const logAddress = f.alloc(20), topicCount = f.alloc(4), topics = f.alloc(128), dataLen = f.alloc(4), data = f.alloc(32)
    assert.equal(f.api.evm_get_log(f.handle, 0, logAddress, topicCount, topics, dataLen, data, 32), 1)
    assert.equal(new DataView(f.api.memory.buffer).getUint32(topicCount, true), 1)
    assert.equal(new Uint8Array(f.api.memory.buffer, topics, 32)[31], 7)
    assert.equal(new DataView(f.api.memory.buffer).getUint32(dataLen, true), 32)
    assert.equal(new Uint8Array(f.api.memory.buffer, data, 32)[31], 42)
  } finally { f.close() }
})

// CALLDATACOPY; STATICCALL a precompile; return its output and success flag.
function precompileCall(address, outputLength) {
  return `36600060003760${outputLength.toString(16).padStart(2, '0')}600036600060${address.toString(16).padStart(2, '0')}5afa60${outputLength.toString(16).padStart(2, '0')}5260${(outputLength + 32).toString(16).padStart(2, '0')}6000f3`
}

test('executes SHA256, BN254 pairing, and BLS12-381 precompiles inside WASM', async () => {
  const f = await fixture()
  try {
    const input = new TextEncoder().encode('abc')
    const sha = f.execute(precompileCall(2, 32), { input })
    assert.equal(sha.success, true)
    assert.equal(sha.output.subarray(0, 32).toString('hex'), createHash('sha256').update(input).digest('hex'))
    assert.equal(sha.output[63], 1)
    const pairing = f.execute(precompileCall(8, 32))
    assert.equal(pairing.success, true)
    assert.equal(pairing.output.toString('hex'), '00'.repeat(31) + '01' + '00'.repeat(31) + '01')
    // EIP-196 generator (1, 2), multiplied by one, must remain (1, 2).
    const multiplyInput = Buffer.from('00'.repeat(31) + '01' + '00'.repeat(31) + '02' + '00'.repeat(31) + '01', 'hex')
    const multiply = f.execute(precompileCall(7, 64), { input: multiplyInput })
    assert.equal(multiply.success, true)
    assert.equal(multiply.output.toString('hex'), multiplyInput.toString('hex'))
    const bls = f.execute(precompileCall(11, 128), { input: new Uint8Array(256) })
    assert.equal(bls.success, true)
    assert.equal(bls.output.toString('hex'), '00'.repeat(159) + '01')
  } finally { f.close() }
})

test('transfer buffers support memory growth and reuse', async () => {
  const f = await fixture()
  try {
    assert.equal(f.api.evm_alloc(0), 0)
    f.api.evm_free(0, 0)
    const before = f.api.memory.buffer.byteLength
    const size = before + 65_536
    const ptr = f.api.evm_alloc(size)
    assert.ok(ptr)
    assert.ok(f.api.memory.buffer.byteLength > before)
    new Uint8Array(f.api.memory.buffer, ptr, size).fill(0xab)
    f.api.evm_free(ptr, size)
    const after = f.api.memory.buffer.byteLength
    for (let i = 0; i < 10; i++) {
      const next = f.api.evm_alloc(size)
      assert.ok(next)
      f.api.evm_free(next, size)
    }
    assert.equal(f.api.memory.buffer.byteLength, after)
  } finally { f.close() }
})

test('destroy releases copied bytecode, calldata, access lists, and blob hashes', async () => {
  const f = await fixture()
  try {
    const buffer = f.alloc(4096)
    function cycle() {
      for (let i = 0; i < 100; i++) {
        const handle = f.api.evm_create(buffer, 0, 0)
        assert.ok(handle)
        assert.equal(f.api.evm_set_bytecode(handle, buffer, 4096), 1)
        assert.equal(f.api.evm_set_execution_context(handle, 100000n, f.address, f.address, f.zero, buffer, 4096), 1)
        // Replacing calldata with empty input must release the old allocation.
        assert.equal(f.api.evm_set_execution_context(handle, 100000n, f.address, f.address, f.zero, buffer, 0), 1)
        assert.equal(f.api.evm_set_execution_context(handle, 100000n, f.address, f.address, f.zero, buffer, 4096), 1)
        assert.equal(f.api.evm_set_access_list_addresses(handle, buffer, 32), 1)
        assert.equal(f.api.evm_set_access_list_storage_keys(handle, buffer, buffer, 16), 1)
        assert.equal(f.api.evm_set_blob_hashes(handle, buffer, 32), 1)
        f.api.evm_destroy(handle)
      }
    }
    cycle()
    const afterWarmup = f.api.memory.buffer.byteLength
    cycle()
    assert.equal(f.api.memory.buffer.byteLength, afterWarmup)
  } finally { f.close() }
})

test('failed replacement allocations leave an instance safe to destroy', async () => {
  const f = await fixture()
  try {
    const buffer = f.alloc(64)
    assert.equal(f.api.evm_set_access_list_addresses(f.handle, buffer, 1), 1)
    assert.equal(f.api.evm_set_access_list_addresses(f.handle, buffer, 0xffffffff), 0)
    assert.equal(f.api.evm_set_access_list_storage_keys(f.handle, buffer, buffer, 1), 1)
    assert.equal(f.api.evm_set_access_list_storage_keys(f.handle, buffer, buffer, 0xffffffff), 0)
    assert.equal(f.api.evm_set_blob_hashes(f.handle, buffer, 1), 1)
    assert.equal(f.api.evm_set_blob_hashes(f.handle, buffer, 0xffffffff), 0)
  } finally { f.close() }
})
