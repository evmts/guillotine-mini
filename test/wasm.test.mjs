import assert from 'node:assert/strict'
import { createHash } from 'node:crypto'
import { readFile } from 'node:fs/promises'
import { test } from 'node:test'
import { WASI } from 'node:wasi'

const bytes = await readFile(process.argv[2] ?? new URL('../zig-out/bin/guillotine_mini.wasm', import.meta.url))
const module = await WebAssembly.compile(bytes)

async function fixture(js_opcode_callback = () => 0) {
  const wasi = new WASI({ version: 'preview1' })
  const instance = await WebAssembly.instantiate(module, {
    wasi_snapshot_preview1: wasi.wasiImport,
    env: { js_opcode_callback, js_precompile_callback: () => 0 },
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
  function configure(code, { input = new Uint8Array(), gas = 1_000_000n } = {}) {
    if (code != null) {
      const bytecode = typeof code === 'string' ? Buffer.from(code, 'hex') : code
      assert.equal(api.evm_set_bytecode(handle, alloc(bytecode), bytecode.length), 1)
    }
    const inputPtr = input.length ? alloc(input) : zero
    assert.equal(api.evm_set_execution_context(handle, gas, caller, address, zero, inputPtr, input.length), 1)
  }
  function execute(code, options) {
    configure(code, options)
    const success = api.evm_execute(handle) === 1
    const length = api.evm_get_output_len(handle)
    const outputPtr = length ? alloc(length) : zero
    assert.equal(api.evm_get_output(handle, outputPtr, length), length)
    const output = Buffer.from(new Uint8Array(api.memory.buffer, outputPtr, length))
    return { success, output, gasUsed: api.evm_get_gas_used(handle) }
  }
  function readJsonText(kind) {
    const length = api[`evm_get_${kind}_len`](handle)
    assert.ok(length > 0)
    const ptr = alloc(length)
    assert.equal(api[`evm_get_${kind}`](handle, ptr, length), length)
    return Buffer.from(new Uint8Array(api.memory.buffer, ptr, length)).toString('utf8')
  }
  function close() {
    api.evm_destroy(handle)
    for (const [ptr, len] of allocations.reverse()) api.evm_free(ptr, len)
  }
  return { api, alloc, handle, address, zero, configure, execute, readJsonText, close }
}

test('WASI reactor contains crypto implementations and exports its complete C API', () => {
  const exports = new Set(WebAssembly.Module.exports(module).map(({ name }) => name))
  assert.deepEqual(new Set([...exports].filter(name => name.startsWith('evm_'))), new Set([
    'evm_alloc', 'evm_free', 'evm_create', 'evm_destroy', 'evm_set_bytecode', 'evm_set_execution_context',
    'evm_set_blockchain_context', 'evm_execute', 'evm_get_gas_remaining', 'evm_get_gas_used', 'evm_is_success',
    'evm_get_output_len', 'evm_get_output', 'evm_set_storage', 'evm_get_storage', 'evm_set_balance', 'evm_set_code',
    'evm_set_access_list_addresses', 'evm_set_access_list_storage_keys', 'evm_set_blob_hashes', 'evm_set_nonce',
    'evm_call_ffi', 'evm_continue_ffi', 'evm_get_state_changes', 'evm_get_state_changes_len',
    'evm_enable_storage_injector', 'evm_get_log_count', 'evm_get_log', 'evm_get_gas_refund',
    'evm_get_storage_change_count', 'evm_get_storage_change', 'evm_set_js_opcode_callbacks_enabled',
    'evm_enable_tracing', 'evm_disable_tracing', 'evm_get_trace_json_len', 'evm_get_trace_json',
    'evm_enable_call_tracer', 'evm_get_call_trace_json_len', 'evm_get_call_trace_json',
    'evm_enable_access_list_tracker', 'evm_get_access_list_json_len', 'evm_get_access_list_json',
  ]))
  assert.ok(exports.has('memory') && exports.has('_initialize'))
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

test('uses storage, balance, nonce, and code set before the first execution', async () => {
  const f = await fixture()
  try {
    const value = f.alloc(Buffer.from('00'.repeat(31) + '2a', 'hex'))
    assert.equal(f.api.evm_set_storage(f.handle, f.address, f.zero, value), 1)
    assert.equal(f.api.evm_set_balance(f.handle, f.address, value), 1)
    const nonceAccount = f.alloc(Buffer.from('00'.repeat(18) + '0201', 'hex'))
    assert.equal(f.api.evm_set_nonce(f.handle, nonceAccount, 1n), 1)

    // SLOAD(0), SELFBALANCE, EXTCODEHASH(nonceAccount), return three words.
    const code = Buffer.from('5f545f52476020526102013f60405260605ff3', 'hex')
    const codePtr = f.alloc(code)
    assert.equal(f.api.evm_set_code(f.handle, f.address, codePtr, code.length), 1)
    new Uint8Array(f.api.memory.buffer, codePtr, code.length).fill(0)
    for (let i = 0; i < 2; i++) {
      const result = f.execute(null)
      assert.equal(result.success, true)
      assert.equal(result.output.toString('hex'), ('00'.repeat(31) + '2a').repeat(2)
        + 'c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470')
    }
  } finally { f.close() }
})

test('invokes the JavaScript opcode callback only while enabled', async () => {
  const seen = []
  const f = await fixture(opcode => { seen.push(opcode); return 0 })
  try {
    f.execute('5f5000')
    assert.deepEqual(seen, [])
    f.api.evm_set_js_opcode_callbacks_enabled(1)
    assert.equal(f.execute('5f5000').success, true)
    assert.deepEqual(seen, [0x5f, 0x50, 0x00])
    f.api.evm_set_js_opcode_callbacks_enabled(0)
    f.execute('5f5000')
    assert.equal(seen.length, 3)
  } finally { f.close() }
})

test('pulls EIP-3155 opcode JSONL with capture options and a transaction summary', async () => {
  const f = await fixture()
  try {
    assert.equal(f.api.evm_get_trace_json_len(f.handle), 0)
    f.api.evm_enable_tracing(f.handle, 1, 1, 0, 1)
    const value = '00'.repeat(31) + '2a'
    assert.equal(f.api.evm_set_storage(f.handle, f.address, f.zero, f.alloc(Buffer.from(value, 'hex'))), 1)
    const result = f.execute('5f545f5260205ff3')
    assert.equal(result.success, true)
    const lines = f.readJsonText('trace_json').trim().split('\n').map(line => JSON.parse(line))
    const summary = lines.pop()
    assert.deepEqual(lines.map(step => step.op), [0x5f, 0x54, 0x5f, 0x52, 0x60, 0x5f, 0xf3])
    assert.deepEqual(lines[3].stack, [])
    assert.equal(lines[4].memory, '0x' + value)
    assert.equal(lines[4].storage['0x0'], '0x2a')
    assert.equal(lines[4].returnData, '0x')
    assert.equal(summary.output, '0x' + value)
    assert.equal(BigInt(summary.gasUsed), result.gasUsed)
    f.api.evm_disable_tracing(f.handle)
    f.execute('00')
    assert.equal(f.api.evm_get_trace_json_len(f.handle), 0)
  } finally { f.close() }
})

test('collects a Geth call trace and EIP-2930 access list in the same execution', async () => {
  const f = await fixture()
  try {
    f.api.evm_enable_call_tracer(f.handle, 0, 1)
    f.api.evm_enable_access_list_tracker(f.handle)
    const calleeBytes = Buffer.from('00'.repeat(18) + '0200', 'hex')
    const callee = '0x' + calleeBytes.toString('hex')
    const code = Buffer.from('600154505f5fa000', 'hex') // SLOAD(1), POP, LOG0, STOP.
    assert.equal(f.api.evm_set_code(f.handle, f.alloc(calleeBytes), f.alloc(code), code.length), 1)
    const parentCode = '5f5f5f5f5f61020061fffff15000'
    assert.equal(f.execute(parentCode).success, true)
    const calls = JSON.parse(f.readJsonText('call_trace_json'))
    assert.equal(calls.type, 'CALL')
    assert.equal(calls.calls.length, 1)
    assert.equal(calls.calls[0].type, 'CALL')
    assert.equal(calls.calls[0].to, callee)
    assert.equal(calls.calls[0].logs[0].address, callee)
    assert.deepEqual(JSON.parse(f.readJsonText('access_list_json')), [
      { address: callee, storageKeys: ['0x' + '00'.repeat(31) + '01'] },
    ])

    f.api.evm_enable_call_tracer(f.handle, 1, 0)
    assert.equal(f.execute(parentCode).success, true)
    assert.equal(JSON.parse(f.readJsonText('call_trace_json')).calls, undefined)
    assert.equal(f.execute('00').success, true)
    assert.deepEqual(JSON.parse(f.readJsonText('access_list_json')), [])
  } finally { f.close() }
})

test('retrieves the full async state dump beyond the inline buffer', async () => {
  const f = await fixture()
  try {
    const slots = 180
    const slot = f.alloc(32)
    const value = f.alloc(Buffer.from('00'.repeat(31) + '01', 'hex'))
    let code = ''
    for (let i = 0; i < slots; i++) {
      new Uint8Array(f.api.memory.buffer, slot, 32)[31] = i
      assert.equal(f.api.evm_set_storage(f.handle, f.address, slot, value), 1)
      code += `600260${i.toString(16).padStart(2, '0')}55`
    }
    assert.equal(f.api.evm_enable_storage_injector(f.handle), 1)
    f.api.evm_enable_tracing(f.handle, 0, 1, 1, 0)
    f.api.evm_enable_call_tracer(f.handle, 0, 0)
    f.api.evm_enable_access_list_tracker(f.handle)
    f.configure(code + '00')
    const request = f.alloc(60 + 16384)
    assert.equal(f.api.evm_call_ffi(f.handle, request), 1)
    assert.equal(new Uint8Array(f.api.memory.buffer, request, 1)[0], 5)
    assert.ok(f.api.evm_get_state_changes_len(f.handle) > 16384)
    const fullDump = f.readJsonText('state_changes')
    const prefix = f.alloc(16)
    assert.equal(f.api.evm_get_state_changes(f.handle, prefix, 16), 16)
    assert.equal(Buffer.from(new Uint8Array(f.api.memory.buffer, prefix, 16)).toString(), fullDump.slice(0, 16))
    const { storage } = JSON.parse(fullDump)
    assert.equal(storage.length, slots)
    assert.equal(storage[0].originalValue, '0x1')
    assert.equal(storage[0].newValue, '0x2')

    assert.equal(f.api.evm_continue_ffi(f.handle, 5, f.zero, 0, request), 1)
    assert.equal(new Uint8Array(f.api.memory.buffer, request, 1)[0], 0)
    assert.equal(f.api.evm_get_state_changes_len(f.handle), 0)
    assert.equal(JSON.parse(f.readJsonText('call_trace_json')).type, 'CALL')
    assert.equal(JSON.parse(f.readJsonText('access_list_json'))[0].storageKeys.length, slots)
    assert.equal(f.readJsonText('trace_json').trim().split('\n').length, slots * 3 + 2)
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
