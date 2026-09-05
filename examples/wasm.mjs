import { readFile } from 'node:fs/promises'
import { WASI } from 'node:wasi'

const bytes = await readFile(process.argv[2] ?? new URL('../zig-out/bin/guillotine_mini.wasm', import.meta.url))
const wasi = new WASI({ version: 'preview1' })
const { instance } = await WebAssembly.instantiate(bytes, {
  wasi_snapshot_preview1: wasi.wasiImport,
  // Returning zero selects the built-in opcode/precompile implementation.
  env: { js_opcode_callback: () => 0, js_precompile_callback: () => 0 },
})
wasi.initialize(instance)
const api = instance.exports
const buffers = []
function alloc(bytes) {
  const ptr = api.evm_alloc(bytes.length)
  if (!ptr) throw new Error('WASM buffer allocation failed')
  // Allocations may grow memory: always obtain a fresh view after allocating.
  new Uint8Array(api.memory.buffer, ptr, bytes.length).set(bytes)
  buffers.push([ptr, bytes.length])
  return ptr
}

let handle = 0
try {
  const fork = new TextEncoder().encode('prague')
  handle = api.evm_create(alloc(fork), fork.length, 0)
  if (!handle) throw new Error('EVM initialization failed')
  const addressBytes = new Uint8Array(20)
  addressBytes[18] = 1 // Execute at address 0x100, outside the precompile range.
  const address = alloc(addressBytes)
  const zero = alloc(new Uint8Array(32))
  // PUSH1 42; PUSH1 0; MSTORE; PUSH1 32; PUSH1 0; RETURN.
  const code = Uint8Array.from([0x60, 0x2a, 0x60, 0x00, 0x52, 0x60, 0x20, 0x60, 0x00, 0xf3])
  if (!api.evm_set_bytecode(handle, alloc(code), code.length)) throw new Error('Setting bytecode failed')
  if (!api.evm_set_execution_context(handle, 100000n, address, address, zero, zero, 0)) throw new Error('Setting context failed')
  if (!api.evm_execute(handle)) throw new Error('EVM execution failed')
  const output = alloc(new Uint8Array(32))
  const length = api.evm_get_output(handle, output, 32)
  console.log(`Output: 0x${Buffer.from(api.memory.buffer, output, length).toString('hex')}`)
  console.log(`Gas used: ${api.evm_get_gas_used(handle)}`)
} finally {
  api.evm_destroy(handle)
  for (const [ptr, len] of buffers.reverse()) api.evm_free(ptr, len)
}
