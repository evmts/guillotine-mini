import { readFile } from "node:fs/promises";
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname } from "node:path";
import { WASI } from "node:wasi";

const wasmPath = process.argv[2] ?? new URL("../zig-out/bin/guillotine_mini.wasm", import.meta.url);
const bytes = await readFile(wasmPath);
const module = await WebAssembly.compile(bytes);

const results = [];

function formatNs(ns) {
  if (ns < 1_000) return `${Math.round(ns)} ns`;
  if (ns < 1_000_000) return `${(ns / 1_000).toFixed(1)} us`;
  if (ns < 1_000_000_000) return `${(ns / 1_000_000).toFixed(2)} ms`;
  return `${(ns / 1_000_000_000).toFixed(3)} s`;
}

function formatOps(opsPerSec) {
  if (opsPerSec >= 1_000_000) return `${(opsPerSec / 1_000_000).toFixed(2)} M ops/s`;
  if (opsPerSec >= 1_000) return `${(opsPerSec / 1_000).toFixed(1)} K ops/s`;
  return `${opsPerSec.toFixed(0)} ops/s`;
}

function record(name, ops, elapsedNs) {
  const perOpNs = ops > 0 ? Math.floor(elapsedNs / ops) : 0;
  const opsPerSec = elapsedNs > 0 ? ops / (elapsedNs / 1e9) : 0;
  console.log(
    `  ${name.padEnd(55)} ${String(ops).padStart(10)} ops  total=${formatNs(elapsedNs).padEnd(10)}  per-op=${formatNs(perOpNs).padEnd(10)}  ${formatOps(opsPerSec)}`,
  );
  results.push({ name, ops, elapsed_ns: elapsedNs, per_op_ns: perOpNs, ops_per_sec: opsPerSec });
}

async function createFixture() {
  const wasi = new WASI({ version: "preview1" });
  const instance = await WebAssembly.instantiate(module, {
    wasi_snapshot_preview1: wasi.wasiImport,
    env: { js_opcode_callback: () => 0, js_precompile_callback: () => 0 },
  });
  wasi.initialize(instance);
  const api = instance.exports;
  const allocations = [];
  function alloc(value) {
    const data = typeof value === "number" ? new Uint8Array(value) : value;
    const ptr = api.evm_alloc(data.length);
    new Uint8Array(api.memory.buffer, ptr, data.length).set(data);
    allocations.push([ptr, data.length]);
    return ptr;
  }
  const fork = new TextEncoder().encode("osaka");
  const handle = api.evm_create(alloc(fork), fork.length, 0);
  const addressBytes = new Uint8Array(20);
  addressBytes[18] = 1;
  const address = alloc(addressBytes);
  const zero = alloc(32);
  const caller = alloc(20);
  api.evm_set_blockchain_context(handle, zero, 1n, 1_720_000_000n, zero, zero, caller, 30_000_000n, zero, zero);
  return {
    api,
    handle,
    alloc,
    caller,
    address,
    zero,
    close() {
      api.evm_destroy(handle);
      for (const [ptr, len] of allocations.reverse()) api.evm_free(ptr, len);
    },
  };
}

console.log("");
console.log("=".repeat(104));
console.log("  Benchmark Suite: wasm/wasi-reactor");
console.log("=".repeat(104));

// 1. Instantiation
{
  const iters = 20;
  const start = process.hrtime.bigint();
  for (let i = 0; i < iters; i += 1) {
    const f = await createFixture();
    f.close();
  }
  record("WASM instantiate + evm_create + evm_destroy", iters, Number(process.hrtime.bigint() - start));
}

// 2. Simple arithmetic execution
{
  const f = await createFixture();
  try {
    const code = Buffer.from("601460160160005260206000f3", "hex");
    const codePtr = f.alloc(code);
    const outPtr = f.alloc(32);
    f.api.evm_set_bytecode(f.handle, codePtr, code.length);
    f.api.evm_set_execution_context(f.handle, 1_000_000n, f.caller, f.address, f.zero, f.zero, 0);

    // Warmup
    for (let i = 0; i < 10; i += 1) f.api.evm_execute(f.handle);

    const iters = 500;
    let sink = 0n;
    const start = process.hrtime.bigint();
    for (let i = 0; i < iters; i += 1) {
      f.api.evm_execute(f.handle);
      f.api.evm_get_output(f.handle, outPtr, 32);
      sink += f.api.evm_get_gas_used(f.handle);
    }
    if (sink === 0n) throw new Error("unexpected zero gas");
    record("WASM evm_execute arithmetic + return 32B", iters, Number(process.hrtime.bigint() - start));

    // Tight loop (500 iterations in EVM bytecode)
    const loopCode = Buffer.from("6101f45b600190038060035700", "hex");
    const loopPtr = f.alloc(loopCode);
    f.api.evm_set_bytecode(f.handle, loopPtr, loopCode.length);
    f.api.evm_set_execution_context(f.handle, 10_000_000n, f.caller, f.address, f.zero, f.zero, 0);
    f.api.evm_execute(f.handle);

    const loopIters = 100;
    const t2 = process.hrtime.bigint();
    for (let i = 0; i < loopIters; i += 1) {
      f.api.evm_execute(f.handle);
      sink += f.api.evm_get_gas_used(f.handle);
    }
    record("WASM tight loop (500 EVM iters / ~3.5K opcodes)", loopIters, Number(process.hrtime.bigint() - t2));
  } finally {
    f.close();
  }
}

console.log("=".repeat(104));
console.log("");

const outPath = process.env.BENCH_JSON_OUT;
if (outPath && outPath.length > 0) {
  const dir = dirname(outPath);
  if (dir && dir !== ".") mkdirSync(dir, { recursive: true });
  writeFileSync(outPath, `${JSON.stringify({ suite: "wasm/wasi-reactor", benchmarks: results }, null, 2)}\n`, "utf8");
}
