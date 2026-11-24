// Supply this namespace when instantiating the modular EVM. Each precompile
// instance has its own linear memory and can be initialized by the host's WASI.
export function precompileImports(coreMemory, instances = []) {
  const modules = new Map()
  for (const { exports: api } of instances) {
    const address = api.address()
    if (modules.has(address)) throw new Error(`Duplicate precompile 0x${address.toString(16)}`)
    modules.set(address, api)
  }
  return {
    run(address, fork, input, len, gas, gasUsed) {
      const api = modules.get(address)
      if (!api) throw new Error(`Missing WASM precompile 0x${address.toString(16)}`)
      const ptr = api.prepare(len)
      if (len && ptr) {
        new Uint8Array(api.memory.buffer, ptr >>> 0, len >>> 0)
          .set(new Uint8Array(coreMemory().buffer, input >>> 0, len >>> 0))
      }
      const size = api.execute(fork, gas)
      if (size >= 0) new DataView(coreMemory().buffer).setBigUint64(gasUsed >>> 0, api.gas_used(), true)
      return size
    },
    copy_output(address, dest, len) {
      const api = modules.get(address)
      new Uint8Array(coreMemory().buffer, dest >>> 0, len >>> 0)
        .set(new Uint8Array(api.memory.buffer, api.output_ptr() >>> 0, len >>> 0))
    },
  }
}
