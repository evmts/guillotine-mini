import assert from 'node:assert/strict'
import { createHash, generateKeyPairSync, sign } from 'node:crypto'
import { readFile } from 'node:fs/promises'
import { test } from 'node:test'
import { WASI } from 'node:wasi'

const bytes = await readFile(process.argv[2] ?? new URL('../zig-out/bin/guillotine_mini.wasm', import.meta.url))
const module = await WebAssembly.compile(bytes)

async function fixture(hardfork = 'prague') {
  const wasi = new WASI({ version: 'preview1' })
  // Tests replace these to run host code inside execution.
  const hooks = { opcode: () => 0, precompile: () => 0 }
  const instance = await WebAssembly.instantiate(module, {
    wasi_snapshot_preview1: wasi.wasiImport,
    env: {
      js_opcode_callback: (...args) => hooks.opcode(...args),
      js_precompile_callback: (...args) => hooks.precompile(...args),
    },
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
  const fork = new TextEncoder().encode(hardfork)
  const handle = api.evm_create(alloc(fork), fork.length, 0)
  assert.ok(handle, 'EVM initialization succeeds')
  const addressBytes = new Uint8Array(20)
  addressBytes[18] = 2 // 0x0200 is not a precompile on any fork (0x0100 is P256VERIFY on Osaka).
  const address = alloc(addressBytes)
  const zero = alloc(32)
  const caller = alloc(20)
  api.evm_set_blockchain_context(handle, zero, 1n, 1_720_000_000n, zero, zero, caller, 30_000_000n, zero, zero)
  function setCall(code, { input = new Uint8Array(), gas = 1_000_000n, to = address } = {}) {
    const bytecode = typeof code === 'string' ? Buffer.from(code, 'hex') : code
    assert.equal(api.evm_set_bytecode(handle, bytecode.length ? alloc(bytecode) : zero, bytecode.length), 1)
    const inputPtr = input.length ? alloc(input) : zero
    assert.equal(api.evm_set_execution_context(handle, gas, caller, to, zero, inputPtr, input.length), 1)
  }
  function execute(code, options) {
    setCall(code, options)
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
  return { api, alloc, handle, address, caller, zero, hooks, setCall, execute, close }
}

// Leak check for linear memory. The allocator returns whole pages only when every slot
// in them is free, so memory can step up a page or two long after warm-up without any
// leak (measured: flat for 3,000 cycles once past the step). A real leak grows with
// every iteration, so run enough iterations that the smallest leak of interest
// dwarfs the slack, then bound the growth.
const WASM_PAGE = 65536
function assertNoLeak(api, warmUp, measured, { slackPages = 4, leakBytesIfBroken }) {
  assert.ok(leakBytesIfBroken >= 8 * slackPages * WASM_PAGE, 'measured phase must be able to expose a leak')
  warmUp()
  const before = api.memory.buffer.byteLength
  measured()
  const grown = api.memory.buffer.byteLength - before
  assert.ok(grown <= slackPages * WASM_PAGE, `linear memory grew by ${grown} bytes`)
}

test('WASI reactor contains crypto implementations and exports its complete C API', () => {
  const exports = new Set(WebAssembly.Module.exports(module).map(({ name }) => name))
  for (const name of ['memory', '_initialize', 'evm_alloc', 'evm_free', 'evm_create', 'evm_destroy', 'evm_execute',
    'evm_set_nonce', 'evm_get_log_count', 'evm_get_log', 'evm_get_gas_refund', 'evm_get_storage_change_count',
    'evm_get_storage_change', 'evm_call_ffi', 'evm_continue_ffi', 'evm_get_state_changes', 'evm_get_state_changes_len']) assert.ok(exports.has(name), name)
  assert.equal(exports.has('_start'), false)
  assert.equal(exports.has('main'), false)
  assert.deepEqual(WebAssembly.Module.imports(module).filter(({ module }) => module !== 'wasi_snapshot_preview1')
    .map(({ module, name }) => `${module}.${name}`).sort(), ['env.js_opcode_callback', 'env.js_precompile_callback'])
})

// Must match wasm_lib.root_module.export_symbol_names in build.zig.
const C_API = ['evm_alloc', 'evm_free', 'evm_create', 'evm_destroy', 'evm_set_bytecode', 'evm_set_execution_context',
  'evm_set_blockchain_context', 'evm_execute', 'evm_get_gas_remaining', 'evm_get_gas_used', 'evm_is_success',
  'evm_get_output_len', 'evm_get_output', 'evm_set_storage', 'evm_get_storage', 'evm_set_balance', 'evm_set_code',
  'evm_set_access_list_addresses', 'evm_set_access_list_storage_keys', 'evm_set_blob_hashes', 'evm_call_ffi',
  'evm_continue_ffi', 'evm_get_state_changes', 'evm_get_state_changes_len', 'evm_set_origin', 'evm_set_gas_price',
  'evm_enable_storage_injector', 'evm_set_nonce', 'evm_get_log_count', 'evm_get_log', 'evm_get_gas_refund',
  'evm_get_storage_change_count', 'evm_get_storage_change']

test('WASI reactor exports exactly the 33 C API functions listed in build.zig', () => {
  const exported = WebAssembly.Module.exports(module).filter(({ kind }) => kind === 'function').map(({ name }) => name)
  assert.equal(C_API.length, 33)
  assert.deepEqual(exported.filter((name) => name.startsWith('evm_')).sort(), [...C_API].sort())
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
  const pushAddress = address <= 0xff ? `60${address.toString(16).padStart(2, '0')}` : `61${address.toString(16).padStart(4, '0')}`
  return `36600060003760${outputLength.toString(16).padStart(2, '0')}6000366000${pushAddress}5afa60${outputLength.toString(16).padStart(2, '0')}5260${(outputLength + 32).toString(16).padStart(2, '0')}6000f3`
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
    // Each cycle() copies ~1.3 MiB (100 handles x bytecode, calldata, lists, hashes).
    // 1,000 measured handles; leaking one 4 KiB copy per handle would add ~4 MiB.
    assertNoLeak(f.api, cycle, () => { for (let round = 0; round < 10; round++) cycle() },
      { leakBytesIfBroken: 10 * 100 * 4096 })
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

// CALLDATACOPY input to mem[0..]; STATICCALL 0x0100 writing return data at 0xa0;
// return [return_word(32) || success(32) || returndatasize(32)].
function p256StaticCall(gasPushHex = '5a') {
  return `366000600037602060a0366000610100${gasPushHex}fa60c0523d60e052606060a0f3`
}

function generateP256Input() {
  const { privateKey, publicKey } = generateKeyPairSync('ec', { namedCurve: 'prime256v1' })
  const message = Buffer.from('guillotine-mini osaka eip-7951 wasm test')
  const signature = sign('sha256', message, { key: privateKey, dsaEncoding: 'ieee-p1363' })
  const { x, y } = publicKey.export({ format: 'jwk' })
  return Buffer.concat([
    createHash('sha256').update(message).digest(),
    signature,
    Buffer.from(x, 'base64url'),
    Buffer.from(y, 'base64url'),
  ])
}

test('Osaka EIP-7951 P256VERIFY executes via direct, async, and nested STATICCALL in WASI', async () => {
  const one = Buffer.from('00'.repeat(31) + '01', 'hex')
  const freshInput = generateP256Input()
  const P256_N = 0xffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551n
  const sHigh = Buffer.from((P256_N - BigInt('0x' + freshInput.subarray(64, 96).toString('hex'))).toString(16).padStart(64, '0'), 'hex')
  const highSInput = Buffer.concat([freshInput.subarray(0, 64), sHigh, freshInput.subarray(96, 160)])

  // EEST test_modular_comparison: recovered point x > n (x mod n == r).
  const eestHighX = Buffer.from([
    'bb5a52f42f9c9261ed4361f59422a1e30036e7c32b270c8807a419feca605023',
    '000000000000000000000000000000004319055358e8617b0c46353d039cdaab',
    'ffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc63254e',
    '0ad99500288d466940031d72a9f5445a4d43784640855bf0a69874d2de5fe103',
    'c5011e6ef2c42dcd50d5d3d29f99ae6eba2c80c9244f4c5422f0979ff0c3ba5e',
  ].join(''), 'hex')

  // EIP-7951 zero-hash vector: h == 0, Q = G, r = s = G.x.
  const gx = '6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296'
  const gy = '4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5'
  const zeroHashInput = Buffer.from('00'.repeat(32) + gx.repeat(3) + gy, 'hex')

  const osaka = await fixture('osaka')
  const prague = await fixture('prague')
  try {
    const p256Addr = osaka.alloc(Buffer.from('00'.repeat(18) + '0100', 'hex'))

    // Direct evm_execute to 0x0100 with empty bytecode
    assert.deepEqual(osaka.execute('', { input: eestHighX, to: p256Addr, gas: 6900n }), { success: true, output: one, gasUsed: 6900n })
    assert.deepEqual(osaka.execute('', { input: zeroHashInput, to: p256Addr, gas: 6900n }), { success: true, output: one, gasUsed: 6900n })
    assert.deepEqual(osaka.execute('', { input: eestHighX, to: p256Addr, gas: 6899n }), { success: false, output: Buffer.alloc(0), gasUsed: 6899n })

    // Nested STATICCALL: valid OpenSSL, high-s, invalid sig, short input, OutOfGas vs exact 6900
    const valid = osaka.execute(p256StaticCall(), { input: freshInput })
    assert.equal(valid.success, true)
    assert.deepEqual(valid.output.subarray(0, 32), one)
    assert.equal(valid.output[63], 1)
    assert.equal(valid.output[95], 32)

    const highS = osaka.execute(p256StaticCall(), { input: highSInput })
    assert.equal(highS.success, true)
    assert.deepEqual(highS.output.subarray(0, 32), one)
    assert.equal(highS.output[63], 1)
    assert.equal(highS.output[95], 32)

    const tampered = Buffer.from(freshInput)
    tampered[0] ^= 1
    const invalid = osaka.execute(p256StaticCall(), { input: tampered })
    assert.equal(invalid.success, true)
    assert.equal(invalid.output[63], 1)
    assert.equal(invalid.output[95], 0)
    assert.equal(invalid.gasUsed, valid.gasUsed)

    const shortRes = osaka.execute(p256StaticCall(), { input: freshInput.subarray(0, 159) })
    assert.equal(shortRes.output[63], 1)
    assert.equal(shortRes.output[95], 0)

    const oog = osaka.execute(p256StaticCall('611af3'), { input: freshInput })
    assert.equal(oog.output[63], 0, '6899 gas fails STATICCALL')
    assert.equal(oog.output[95], 0)

    const exact = osaka.execute(p256StaticCall('611af4'), { input: freshInput })
    assert.equal(exact.output[63], 1, '6900 gas succeeds')
    assert.deepEqual(exact.output.subarray(0, 32), one)

    // Pre-Osaka (Prague): 0x0100 is an empty account (cold 2600 vs Osaka warm 100 + 6900)
    const before = prague.execute(p256StaticCall(), { input: freshInput })
    assert.equal(before.success, true)
    assert.equal(before.output[63], 1)
    assert.equal(before.output[95], 0)
    assert.equal(valid.gasUsed - before.gasUsed, 6900n + 100n - 2600n)

    // Direct async evm_call_ffi to 0x0100 with storage injector preserves result across ready_to_commit
    assert.equal(osaka.api.evm_enable_storage_injector(osaka.handle), 1)
    osaka.setCall('', { input: zeroHashInput, to: p256Addr, gas: 7000n })
    const request = osaka.alloc(60 + 16384)
    assert.equal(osaka.api.evm_call_ffi(osaka.handle, request), 1)
    assert.equal(new Uint8Array(osaka.api.memory.buffer)[request], 5)
    assert.equal(osaka.api.evm_continue_ffi(osaka.handle, 5, osaka.zero, 0, request), 1)
    assert.equal(new Uint8Array(osaka.api.memory.buffer)[request], 0)
    assert.equal(osaka.api.evm_get_gas_remaining(osaka.handle), 100n)
    const outPtr = osaka.alloc(32)
    assert.equal(osaka.api.evm_get_output(osaka.handle, outPtr, 32), 32)
    assert.deepEqual(Buffer.from(new Uint8Array(osaka.api.memory.buffer, outPtr, 32)), one)
  } finally { osaka.close(); prague.close() }
})

// CREATE `count` contracts whose init code is CALLER SELFDESTRUCT; each adds an entry
// to "selfDestructs" without triggering async storage reads.
const selfDestructLoop = (count) =>
  '6133ff600052' + '61' + count.toString(16).padStart(4, '0') + '5b6002601e6000f050600190038060095700'

test('async WASI ready_to_commit handles inline fast-path, >20 KiB overflow, and replacement without truncation', async () => {
  const REQUEST = { size: 60 + 16384, jsonLen: 56, jsonData: 60, inlineCapacity: 16384 }
  const f = await fixture('osaka')
  try {
    const { api, handle } = f
    const bytesAt = (ptr, len) => new Uint8Array(api.memory.buffer, ptr, len)
    const tag = (req) => bytesAt(req, 1)[0]
    const readLen = (req) => new DataView(api.memory.buffer).getUint32(req + REQUEST.jsonLen, true)

    // Salvage #854: reading storage and state-changes length before any call is safe and defined
    const slot = f.alloc(32)
    const val = f.alloc(new Uint8Array(32).fill(0xff))
    assert.equal(api.evm_get_storage(handle, f.address, slot, val), 1)
    assert.ok(bytesAt(val, 32).every((b) => b === 0))
    assert.equal(api.evm_get_state_changes_len(handle), 0)
    assert.equal(api.evm_get_state_changes(handle, 0, 0), 0)

    assert.equal(api.evm_enable_storage_injector(handle), 1)
    assert.equal(api.evm_enable_storage_injector(handle), 1, 'idempotent enable')
    const request = f.alloc(new Uint8Array(REQUEST.size).fill(0xa5))

    // 1. Overflow path: 500 self-destructed contracts -> >22 KiB (> 16384 inline cap)
    const accounts = 500
    f.setCall(selfDestructLoop(accounts), { gas: 30_000_000n })
    assert.equal(api.evm_call_ffi(handle, request), 1)
    assert.equal(tag(request), 5, 'ready_to_commit')

    const largeLen = readLen(request)
    assert.ok(largeLen > 20 * 1024 && largeLen > REQUEST.inlineCapacity, `expected >20 KiB, got ${largeLen}`)
    assert.ok(bytesAt(request + REQUEST.jsonData, REQUEST.inlineCapacity).every((b) => b === 0), 'json_data zeroed on overflow')
    assert.equal(api.evm_get_state_changes_len(handle), largeLen)
    assert.equal(api.evm_get_state_changes(handle, 0, 0), largeLen)

    // Undersized buffer must remain untouched (no truncated prefix)
    const smallBuf = f.alloc(new Uint8Array(REQUEST.inlineCapacity).fill(0x55))
    assert.equal(api.evm_get_state_changes(handle, smallBuf, REQUEST.inlineCapacity), largeLen)
    assert.ok(bytesAt(smallBuf, REQUEST.inlineCapacity).every((b) => b === 0x55))

    // Exact-sized buffer receives complete, valid JSON with sentinel byte past end untouched
    const fullBuf = f.alloc(new Uint8Array(largeLen + 1).fill(0xcc))
    assert.equal(api.evm_get_state_changes(handle, fullBuf, largeLen), largeLen)
    assert.equal(bytesAt(fullBuf + largeLen, 1)[0], 0xcc)
    const parsedLarge = JSON.parse(new TextDecoder().decode(bytesAt(fullBuf, largeLen)))
    assert.equal(parsedLarge.selfDestructs.length, accounts)
    assert.equal(new Set(parsedLarge.selfDestructs).size, accounts)

    assert.equal(api.evm_continue_ffi(handle, 5, f.zero, 0, request), 1)
    assert.equal(tag(request), 0)
    assert.equal(api.evm_is_success(handle), 1)

    // 2. Subsequent small call replaces the dump and delivers complete JSON inline
    bytesAt(request + REQUEST.jsonData, REQUEST.inlineCapacity).fill(0xee)
    f.setCall(selfDestructLoop(3), { gas: 1_000_000n })
    assert.equal(api.evm_call_ffi(handle, request), 1)
    assert.equal(tag(request), 5)
    const smallLen = readLen(request)
    assert.ok(smallLen > 0 && smallLen <= REQUEST.inlineCapacity)
    assert.equal(api.evm_get_state_changes_len(handle), smallLen)
    assert.ok(bytesAt(request + REQUEST.jsonData + smallLen, REQUEST.inlineCapacity - smallLen).every((b) => b === 0))
    const inlineJson = new TextDecoder().decode(bytesAt(request + REQUEST.jsonData, smallLen))
    assert.equal(JSON.parse(inlineJson).selfDestructs.length, 3)

    assert.equal(api.evm_get_state_changes(handle, fullBuf, largeLen), smallLen)
    assert.equal(new TextDecoder().decode(bytesAt(fullBuf, smallLen)), inlineJson)

    assert.equal(api.evm_continue_ffi(handle, 5, f.zero, 0, request), 1)
    assert.equal(tag(request), 0)
    assert.equal(api.evm_is_success(handle), 1)
  } finally { f.close() }
})

// ---- Round 1 fixes: C ABI input validation, async state machine, ownership ----

const REQUEST = { size: 60 + 16384, address: 1, slot: 21, jsonLen: 56, jsonData: 60 }
// SSTORE(0, 7) with its operands pushed twice. A handler that probes the slot before
// popping leaves the spare pair on the stack; one that pops before yielding consumes
// it on resume. The stored value is the same either way.
const STORE_SLOT0_7 = '600760006007600055'
const RETURN_SLOT0 = '60005460005260206000f3'

function asyncHelpers(f) {
  const { api } = f
  const bytesAt = (ptr, len) => new Uint8Array(api.memory.buffer, ptr, len)
  const request = f.alloc(new Uint8Array(REQUEST.size).fill(0xa5))
  const tag = () => bytesAt(request, 1)[0]
  const json = () => {
    const len = new DataView(api.memory.buffer).getUint32(request + REQUEST.jsonLen, true)
    return JSON.parse(new TextDecoder().decode(bytesAt(request + REQUEST.jsonData, len)))
  }
  // address(20) + slot(32) + value(32)
  function storageReply(slot, value) {
    const reply = new Uint8Array(84)
    reply[18] = 2
    reply[51] = slot
    reply[83] = value
    return f.alloc(reply)
  }
  function output() {
    const length = api.evm_get_output_len(f.handle)
    const ptr = f.alloc(Math.max(length, 1))
    assert.equal(api.evm_get_output(f.handle, ptr, length), length)
    return Buffer.from(bytesAt(ptr, length))
  }
  return { bytesAt, request, tag, json, storageReply, output }
}

test('exports the origin and gas price setters', () => {
  const exports = new Set(WebAssembly.Module.exports(module).map(({ name }) => name))
  for (const name of ['evm_set_origin', 'evm_set_gas_price', 'evm_enable_storage_injector', 'evm_set_code',
    'evm_set_balance', 'evm_set_storage', 'evm_get_storage', 'evm_set_blob_hashes']) assert.ok(exports.has(name), name)
})

test('invalid C ABI inputs return an error instead of trapping', async () => {
  const f = await fixture('osaka')
  try {
    const { api, handle } = f
    const h = asyncHelpers(f)
    const name = f.alloc(new TextEncoder().encode('osaka'))
    const bogus = f.alloc(new TextEncoder().encode('pragueee'))

    // Out-of-range log levels, unknown forks, and a null name with a length.
    for (const level of [5, 6, 99, 255]) assert.equal(api.evm_create(name, 5, level), 0, `log level ${level}`)
    assert.equal(api.evm_create(bogus, 8, 0), 0)
    assert.equal(api.evm_create(0, 5, 0), 0)
    for (const level of [0, 1, 2, 3, 4]) {
      const created = api.evm_create(0, 0, level)
      assert.ok(created, `log level ${level}`)
      api.evm_destroy(created)
    }

    // Negative gas is rejected and the previous context keeps running.
    f.setCall('602a60005260206000f3', { gas: 100_000n })
    assert.equal(api.evm_set_execution_context(handle, -1n, f.caller, f.address, f.zero, f.zero, 0), 0)
    assert.equal(api.evm_set_execution_context(handle, -(2n ** 63n), f.caller, f.address, f.zero, f.zero, 0), 0)
    assert.equal(api.evm_execute(handle), 1)
    assert.equal(api.evm_get_gas_used(handle), 18n)

    // Null handle.
    api.evm_destroy(0)
    assert.equal(api.evm_set_bytecode(0, f.zero, 1), 0)
    assert.equal(api.evm_set_execution_context(0, 1n, f.caller, f.address, f.zero, f.zero, 0), 0)
    assert.equal(api.evm_execute(0), 0)
    assert.equal(api.evm_call_ffi(0, h.request), 0)
    assert.equal(api.evm_continue_ffi(0, 5, 0, 0, h.request), 0)
    assert.equal(api.evm_get_output(0, f.zero, 32), 0)
    assert.equal(api.evm_set_code(0, f.address, f.zero, 1), 0)
    assert.equal(api.evm_set_origin(0, f.address), 0)
    assert.equal(api.evm_set_gas_price(0, f.zero), 0)
    assert.equal(api.evm_enable_storage_injector(0), 0)
    assert.equal(api.evm_get_storage_change(0, 0, f.zero, f.zero, f.zero), 0)

    // Null data pointers with a non-zero length.
    assert.equal(api.evm_set_bytecode(handle, 0, 4), 0)
    assert.equal(api.evm_set_execution_context(handle, 1n, 0, f.address, f.zero, f.zero, 0), 0)
    assert.equal(api.evm_set_execution_context(handle, 1n, f.caller, 0, f.zero, f.zero, 0), 0)
    assert.equal(api.evm_set_execution_context(handle, 1n, f.caller, f.address, 0, f.zero, 0), 0)
    assert.equal(api.evm_set_execution_context(handle, 1n, f.caller, f.address, f.zero, 0, 8), 0)
    assert.equal(api.evm_set_access_list_addresses(handle, 0, 2), 0)
    assert.equal(api.evm_set_access_list_storage_keys(handle, 0, f.zero, 1), 0)
    assert.equal(api.evm_set_access_list_storage_keys(handle, f.address, 0, 1), 0)
    assert.equal(api.evm_set_blob_hashes(handle, 0, 1), 0)
    assert.equal(api.evm_set_storage(handle, 0, f.zero, f.zero), 0)
    assert.equal(api.evm_get_storage(handle, f.address, f.zero, 0), 0)
    assert.equal(api.evm_set_balance(handle, f.address, 0), 0)
    assert.equal(api.evm_set_code(handle, f.address, 0, 4), 0)
    assert.equal(api.evm_set_nonce(handle, 0, 1n), 0)
    assert.equal(api.evm_set_origin(handle, 0), 0)
    assert.equal(api.evm_set_gas_price(handle, 0), 0)
    assert.equal(api.evm_call_ffi(handle, 0), 0)
    assert.equal(api.evm_continue_ffi(handle, 5, 0, 0, 0), 0)
    assert.equal(api.evm_get_output(handle, 0, 32), 0)
    assert.equal(api.evm_get_log(handle, 0, 0, 0, 0, 0, 0, 0), 0)
    api.evm_set_blockchain_context(handle, 0, 1n, 1n, 0, 0, 0, 1n, 0, 0)

    // Malformed continuations report tag 255.
    for (const [type, ptr, len] of [[1, 0, 84], [1, f.zero, 32], [2, f.zero, 20], [4, f.zero, 27], [9, 0, 0], [5, 0, 0]]) {
      h.bytesAt(h.request, 1)[0] = 0
      assert.equal(api.evm_continue_ffi(handle, type, ptr, len, h.request), 0, `continue type ${type}`)
      assert.equal(h.tag(), 255)
    }

    // Null with zero length is an empty input, and the handle still works.
    assert.equal(api.evm_set_bytecode(handle, 0, 0), 1)
    assert.equal(api.evm_set_execution_context(handle, 21_000n, f.caller, f.address, f.zero, 0, 0), 1)
    assert.equal(api.evm_set_code(handle, f.address, 0, 0), 1)
    assert.equal(api.evm_execute(handle), 1, 'calling an account without code succeeds')
    assert.equal(api.evm_get_output_len(handle), 0)
    assert.deepEqual(f.execute('602a60005260206000f3').output[31], 42)
  } finally { f.close() }
})

test('async SSTORE commits the written value, and SLOAD after SSTORE reads it', async () => {
  const f = await fixture('osaka')
  try {
    const { api, handle } = f
    const h = asyncHelpers(f)
    assert.equal(api.evm_enable_storage_injector(handle), 1)

    f.setCall(STORE_SLOT0_7 + RETURN_SLOT0, { gas: 100_000n })
    assert.equal(api.evm_call_ffi(handle, h.request), 1)
    assert.equal(h.tag(), 1, 'need_storage')
    assert.equal(h.bytesAt(h.request + REQUEST.address, 20)[18], 2)
    assert.ok(h.bytesAt(h.request + REQUEST.slot, 32).every((b) => b === 0))

    // Replies that do not answer the outstanding request are rejected and change nothing.
    assert.equal(api.evm_continue_ffi(handle, 1, h.storageReply(1, 9), 84, h.request), 0)
    assert.equal(h.tag(), 255)
    assert.equal(api.evm_continue_ffi(handle, 2, h.storageReply(0, 9), 52, h.request), 0)
    assert.equal(h.tag(), 255)
    assert.equal(api.evm_continue_ffi(handle, 5, 0, 0, h.request), 0)
    assert.equal(h.tag(), 255)

    // The host holds slot 0 = 5.
    assert.equal(api.evm_continue_ffi(handle, 1, h.storageReply(0, 5), 84, h.request), 1)
    assert.equal(h.tag(), 5, 'ready_to_commit')
    const changes = h.json()
    assert.deepEqual(changes.storage, [{
      address: '0x' + '00'.repeat(18) + '0200', slot: '0x0', originalValue: '0x5', newValue: '0x7',
    }])
    assert.deepEqual(changes.selfDestructs, [])

    assert.equal(api.evm_continue_ffi(handle, 5, 0, 0, h.request), 1)
    assert.equal(h.tag(), 0)
    assert.equal(api.evm_is_success(handle), 1)
    assert.equal(h.output().toString('hex'), '00'.repeat(31) + '07', 'SLOAD returns the value written by SSTORE')

    // The acknowledgement is consumed once.
    assert.equal(api.evm_continue_ffi(handle, 5, 0, 0, h.request), 0)
    assert.equal(h.tag(), 255)
  } finally { f.close() }
})

test('reverted and halted async transactions never emit ready_to_commit', async () => {
  const f = await fixture('osaka')
  try {
    const { api, handle } = f
    const h = asyncHelpers(f)
    assert.equal(api.evm_enable_storage_injector(handle), 1)

    // SSTORE(0, 7); MSTORE(0, 0xdeadbeef); REVERT(28, 4)
    f.setCall(STORE_SLOT0_7 + '63deadbeef6000526004601cfd', { gas: 100_000n })
    assert.equal(api.evm_call_ffi(handle, h.request), 1)
    assert.equal(h.tag(), 1)
    assert.equal(api.evm_continue_ffi(handle, 1, h.storageReply(0, 5), 84, h.request), 1)
    assert.equal(h.tag(), 0, 'a revert is a final result, not ready_to_commit')
    assert.equal(api.evm_is_success(handle), 0)
    assert.equal(h.output().toString('hex'), 'deadbeef')
    assert.ok(api.evm_get_gas_remaining(handle) > 0n)
    assert.equal(api.evm_get_state_changes_len(handle), 0, 'no change set exists for a reverted transaction')
    assert.equal(api.evm_continue_ffi(handle, 5, 0, 0, h.request), 0, 'nothing to acknowledge')
    assert.equal(h.tag(), 255)

    // A successful transaction first, then INVALID: the halt reports its own failed
    // result (tag 0), never tag 255 with the earlier output.
    f.setCall('602a60005260206000f3', { gas: 100_000n })
    assert.equal(api.evm_call_ffi(handle, h.request), 1)
    assert.equal(h.tag(), 5)
    assert.equal(api.evm_continue_ffi(handle, 5, 0, 0, h.request), 1)
    assert.equal(api.evm_is_success(handle), 1)
    assert.equal(h.output()[31], 42)

    f.setCall('fe', { gas: 5_000n })
    assert.equal(api.evm_call_ffi(handle, h.request), 1)
    assert.equal(h.tag(), 0)
    assert.equal(api.evm_is_success(handle), 0)
    assert.equal(api.evm_get_output_len(handle), 0)
    assert.equal(api.evm_get_gas_remaining(handle), 0n)
    assert.equal(api.evm_get_gas_used(handle), 5_000n)
    assert.equal(api.evm_get_state_changes_len(handle), 0)
    assert.equal(api.evm_continue_ffi(handle, 5, 0, 0, h.request), 0)

    // Out of gas takes the same path.
    f.setCall('602a60005260206000f3', { gas: 2n })
    assert.equal(api.evm_call_ffi(handle, h.request), 1)
    assert.equal(h.tag(), 0)
    assert.equal(api.evm_is_success(handle), 0)
  } finally { f.close() }
})

test('async execution without a storage injector returns the real result and logs', async () => {
  const f = await fixture('osaka')
  try {
    const { api, handle } = f
    const h = asyncHelpers(f)

    // A continuation on a fresh handle is a protocol error.
    assert.equal(api.evm_continue_ffi(handle, 5, 0, 0, h.request), 0)
    assert.equal(h.tag(), 255)

    // MSTORE(0, 42); LOG0(0, 32); RETURN(0, 32)
    f.setCall('602a60005260206000a060206000f3', { gas: 100_000n })
    assert.equal(api.evm_call_ffi(handle, h.request), 1)
    assert.equal(h.tag(), 0)
    assert.equal(api.evm_is_success(handle), 1)
    assert.equal(h.output().toString('hex'), '00'.repeat(31) + '2a')
    assert.equal(api.evm_get_log_count(handle), 1)
    const used = api.evm_get_gas_used(handle)
    assert.ok(used > 0n && used < 100_000n)
    assert.equal(api.evm_get_gas_remaining(handle), 100_000n - used)

    // Setting up the next call does not change the finished call's gas report.
    f.setCall('00', { gas: 7n })
    assert.equal(api.evm_get_gas_used(handle), used)
  } finally { f.close() }
})

test('repeated evm_set_code and evm_set_bytecode do not leak', async () => {
  const f = await fixture('osaka')
  try {
    const { api, handle } = f
    const code = f.alloc(new Uint8Array(8192).fill(0x5b))
    const other = f.alloc(new Uint8Array(20).fill(0x77))
    function cycle() {
      for (let i = 0; i < 400; i++) {
        assert.equal(api.evm_set_code(handle, f.address, code, 8192), 1)
        assert.equal(api.evm_set_code(handle, other, code, 4096 + (i % 7)), 1)
        assert.equal(api.evm_set_bytecode(handle, code, 2048), 1)
        if (i % 50 === 0) assert.equal(api.evm_set_code(handle, other, 0, 0), 1)
      }
    }
    // 2,000 measured replacements of >= 4 KiB each.
    assertNoLeak(api, cycle, () => { for (let round = 0; round < 5; round++) cycle() },
      { leakBytesIfBroken: 5 * 400 * 4096 })

    // Handles that own code and an injector release everything on destroy. 4,000
    // measured lifecycles expose any leak of 525 bytes or more per handle, which
    // covers the injector, each code copy, and the context itself.
    function lifecycle(count) {
      for (let i = 0; i < count; i++) {
        const created = api.evm_create(0, 0, 0)
        assert.ok(created)
        assert.equal(api.evm_enable_storage_injector(created), 1)
        assert.equal(api.evm_set_code(created, f.address, code, 8192), 1)
        assert.equal(api.evm_set_code(created, other, code, 8192), 1)
        api.evm_destroy(created)
      }
    }
    assertNoLeak(api, () => lifecycle(200), () => lifecycle(4000), { leakBytesIfBroken: 4000 * 525 })
  } finally { f.close() }
})

test('origin, gas price and blob hashes are set per handle and cleared correctly', async () => {
  const f = await fixture('osaka')
  try {
    const { api, handle } = f
    const h = asyncHelpers(f)

    // MSTORE(0, ORIGIN); MSTORE(32, GASPRICE); RETURN(0, 64)
    const context = '32600052' + '3a602052' + '60406000f3'
    assert.equal(f.execute(context).output.toString('hex'), '00'.repeat(64))
    const origin = f.alloc(new Uint8Array(20).fill(0xab))
    const price = new Uint8Array(32)
    price[30] = 0x12
    price[31] = 0x34
    assert.equal(api.evm_set_origin(handle, origin), 1)
    assert.equal(api.evm_set_gas_price(handle, f.alloc(price)), 1)
    const expected = '00'.repeat(12) + 'ab'.repeat(20) + '00'.repeat(30) + '1234'
    assert.equal(f.execute(context).output.toString('hex'), expected)
    f.setCall(context)
    assert.equal(api.evm_call_ffi(handle, h.request), 1)
    assert.equal(h.tag(), 0)
    assert.equal(h.output().toString('hex'), expected, 'async entry point sees the same context')

    // MSTORE(0, BLOBHASH(0)); MSTORE(32, BLOBHASH(1)); RETURN(0, 64)
    const blobs = '600049600052' + '600149602052' + '60406000f3'
    const two = new Uint8Array(64).fill(0xaa)
    two[0] = 1
    two[32] = 1
    two.fill(0xbb, 33)
    assert.equal(api.evm_set_blob_hashes(handle, f.alloc(two), 2), 1)
    assert.equal(f.execute(blobs).output.toString('hex'), Buffer.from(two).toString('hex'))
    f.setCall(blobs)
    assert.equal(api.evm_call_ffi(handle, h.request), 1)
    assert.equal(h.output().toString('hex'), Buffer.from(two).toString('hex'), 'async entry point receives blob hashes')

    // A shorter list hides the old second hash; an empty list clears all of them.
    assert.equal(api.evm_set_blob_hashes(handle, f.alloc(two), 1), 1)
    assert.equal(f.execute(blobs).output.toString('hex'), Buffer.from(two.subarray(0, 32)).toString('hex') + '00'.repeat(32))
    assert.equal(api.evm_set_blob_hashes(handle, 0, 0), 1)
    assert.equal(f.execute(blobs).output.toString('hex'), '00'.repeat(64))
    f.setCall(blobs)
    assert.equal(api.evm_call_ffi(handle, h.request), 1)
    assert.equal(h.output().toString('hex'), '00'.repeat(64))
  } finally { f.close() }
})

test('access list storage keys warm their slot and transfer buffers are 16-byte aligned', async () => {
  const f = await fixture('osaka')
  try {
    const { api, handle } = f
    // SLOAD(1): 2100 cold, 100 warm, plus 3 for the PUSH1.
    assert.equal(f.execute('60015400').gasUsed, 2103n)
    const slotOne = new Uint8Array(32)
    slotOne[31] = 1
    // The key's address is not passed to evm_set_access_list_addresses.
    assert.equal(api.evm_set_access_list_storage_keys(handle, f.address, f.alloc(slotOne), 1), 1)
    assert.equal(f.execute('60015400').gasUsed, 103n)
    assert.equal(api.evm_set_access_list_storage_keys(handle, 0, 0, 0), 1)
    assert.equal(f.execute('60015400').gasUsed, 2103n)

    for (const size of [1, 7, 60, REQUEST.size]) assert.equal(f.alloc(size) % 16, 0, `evm_alloc(${size}) alignment`)
  } finally { f.close() }
})

// MSTORE(0, n); RETURN(0, 32)
const returnByte = (n) => `60${n.toString(16).padStart(2, '0')}60005260206000f3`

test('interleaved evm_execute and evm_call_ffi keep evm_set_code and cancel the suspended call', async () => {
  const f = await fixture('osaka')
  try {
    const { api, handle } = f
    const h = asyncHelpers(f)
    const installed = Buffer.from(returnByte(0x2a), 'hex')
    assert.equal(api.evm_set_code(handle, f.address, f.alloc(installed), installed.length), 1)

    // Installed code wins over evm_set_bytecode on both entry points, repeatedly.
    for (let round = 0; round < 2; round++) {
      f.setCall(returnByte(7), { gas: 100_000n })
      assert.equal(api.evm_execute(handle), 1)
      assert.equal(h.output()[31], 0x2a, 'evm_execute runs the installed code')
      assert.equal(api.evm_call_ffi(handle, h.request), 1)
      assert.equal(h.tag(), 0)
      assert.equal(h.output()[31], 0x2a, 'evm_call_ffi runs the installed code')
    }

    // Suspend an async SLOAD at a code-less address, then run a sync call.
    assert.equal(api.evm_enable_storage_injector(handle), 1)
    const other = f.alloc(new Uint8Array(20).fill(0x33))
    f.setCall(RETURN_SLOT0, { gas: 100_000n, to: other })
    assert.equal(api.evm_call_ffi(handle, h.request), 1)
    assert.equal(h.tag(), 1, 'need_storage')
    f.setCall(returnByte(7), { gas: 100_000n })
    assert.equal(api.evm_execute(handle), 1)
    assert.equal(h.output()[31], 0x2a)

    // The suspended call was cancelled: its reply is rejected and the sync result stays readable.
    const reply = new Uint8Array(84).fill(0x33, 0, 20)
    reply[83] = 5
    assert.equal(api.evm_continue_ffi(handle, 1, f.alloc(reply), 84, h.request), 0)
    assert.equal(h.tag(), 255)
    assert.equal(api.evm_continue_ffi(handle, 5, 0, 0, h.request), 0)
    assert.equal(h.tag(), 255)

    // The installed code survived the whole sequence.
    assert.equal(api.evm_execute(handle), 1)
    assert.equal(h.output()[31], 0x2a)
  } finally { f.close() }
})

test('a host callback cannot re-enter, mutate or destroy the executing handle', async () => {
  const f = await fixture('osaka')
  try {
    const { api, handle } = f
    const h = asyncHelpers(f)
    const code = f.alloc(Buffer.from('fe', 'hex'))
    const storageOut = f.alloc(32)
    const attempts = []
    f.hooks.opcode = () => {
      if (attempts.length > 0) return 0
      attempts.push({
        execute: api.evm_execute(handle),
        callFfi: api.evm_call_ffi(handle, h.request),
        callTag: h.tag(),
        continueFfi: api.evm_continue_ffi(handle, 5, 0, 0, h.request),
        setBytecode: api.evm_set_bytecode(handle, code, 1),
        setContext: api.evm_set_execution_context(handle, 1n, f.caller, f.address, f.zero, 0, 0),
        setCode: api.evm_set_code(handle, f.address, code, 1),
        setStorage: api.evm_set_storage(handle, f.address, f.zero, f.zero),
        setBalance: api.evm_set_balance(handle, f.address, f.zero),
        setNonce: api.evm_set_nonce(handle, f.address, 1n),
        setBlobs: api.evm_set_blob_hashes(handle, 0, 0),
        injector: api.evm_enable_storage_injector(handle),
        readStorage: api.evm_get_storage(handle, f.address, f.zero, storageOut),
      })
      return 0
    }
    f.setCall(returnByte(0x2a), { gas: 100_000n })
    assert.equal(api.evm_execute(handle), 1)
    f.hooks.opcode = () => 0
    assert.equal(h.output()[31], 0x2a, 'the outer call completes with its own code')
    assert.deepEqual(attempts, [{
      execute: 0, callFfi: 0, callTag: 255, continueFfi: 0, setBytecode: 0, setContext: 0, setCode: 0,
      setStorage: 0, setBalance: 0, setNonce: 0, setBlobs: 0, injector: 0, readStorage: 1,
    }])
    assert.equal(api.evm_get_gas_used(handle) > 0n, true)

    // Nothing was replaced: the same call runs the same code again.
    assert.equal(api.evm_execute(handle), 1)
    assert.equal(h.output()[31], 0x2a)

    // Destroy from inside a callback is deferred to the end of the call, on both entry points.
    const created = []
    function destroyDuringCall(start) {
      const doomed = api.evm_create(0, 0, 0)
      assert.ok(doomed)
      created.push(doomed)
      const bytecode = Buffer.from(returnByte(1), 'hex')
      assert.equal(api.evm_set_bytecode(doomed, f.alloc(bytecode), bytecode.length), 1)
      assert.equal(api.evm_set_execution_context(doomed, 100_000n, f.caller, f.address, f.zero, 0, 0), 1)
      let calls = 0
      f.hooks.opcode = () => { if (calls++ === 0) api.evm_destroy(doomed); return 0 }
      const ok = start(doomed)
      f.hooks.opcode = () => 0
      assert.ok(calls > 1, 'execution continued after the deferred destroy')
      return ok
    }
    assert.equal(destroyDuringCall((doomed) => api.evm_execute(doomed)), 0)
    assert.equal(destroyDuringCall((doomed) => api.evm_call_ffi(doomed, h.request)), 0)
    // The surviving handle still works and fresh handles reuse the freed memory.
    assert.equal(api.evm_execute(handle), 1)
    assert.equal(h.output()[31], 0x2a)
  } finally { f.close() }
})

// R2-02: AsyncExecutor owns a root checkpoint so a reverted async transaction rolls back SSTOREs.
test('a reverted async transaction leaves storage, refunds and change lists clean', async () => {
  const f = await fixture('osaka')
  try {
    const { api, handle } = f
    const h = asyncHelpers(f)
    assert.equal(api.evm_enable_storage_injector(handle), 1)
    const storageOut = f.alloc(32)
    const readSlot0 = () => {
      assert.equal(api.evm_get_storage(handle, f.address, f.zero, storageOut), 1)
      return h.bytesAt(storageOut, 32)[31]
    }

    // SSTORE(0, 7); SSTORE(0, 0) for a refund; then REVERT(0, 0).
    f.setCall(STORE_SLOT0_7 + '600060006000600055' + '60006000fd', { gas: 100_000n })
    assert.equal(api.evm_call_ffi(handle, h.request), 1)
    assert.equal(h.tag(), 1)
    assert.equal(api.evm_continue_ffi(handle, 1, h.storageReply(0, 5), 84, h.request), 1)
    assert.equal(h.tag(), 0)
    assert.equal(api.evm_is_success(handle), 0)

    assert.notEqual(readSlot0(), 7, 'the reverted write is not visible')
    assert.notEqual(readSlot0(), 0, 'the reverted clear is not visible')
    assert.equal(api.evm_get_gas_refund(handle), 0n)
    assert.equal(api.evm_get_state_changes_len(handle), 0)

    // A later successful transaction sees the host value, not the reverted one.
    f.setCall(RETURN_SLOT0, { gas: 100_000n })
    assert.equal(api.evm_call_ffi(handle, h.request), 1)
    if (h.tag() === 1) assert.equal(api.evm_continue_ffi(handle, 1, h.storageReply(0, 5), 84, h.request), 1)
    assert.equal(h.tag(), 5)
    assert.deepEqual(h.json().storage, [])
    assert.equal(api.evm_continue_ffi(handle, 5, 0, 0, h.request), 1)
    assert.equal(h.output()[31], 5)
  } finally { f.close() }
})
