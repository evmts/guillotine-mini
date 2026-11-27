#!/usr/bin/env node
/**
 * Reproducible Node / Bun WASM benchmark for `@tevm/guillotine-mini`.
 *
 * Measures:
 * - Raw & gzipped (level 9) sizes of `guillotine_mini_core.wasm`,
 *   `guillotine_mini.wasm`, and modular precompile reactors
 * - Cold instantiation latency (WebAssembly.instantiate + _initialize + evm_create)
 * - Warm simple arithmetic call (PUSH + ADD + MSTORE + RETURN)
 * - Warm 500-iteration arithmetic loop (~3,500 EVM opcodes)
 * - Osaka EIP-7939 `CLZ` opcode execution
 * - Osaka EIP-7951 `P256VERIFY` (0x0100) precompile verification (valid sig)
 *
 * Usage:
 *   node bench/wasm-compare.mjs [path/to/wasm-bin-dir]
 *   bun  bench/wasm-compare.mjs [path/to/wasm-bin-dir]
 */

import { createHash, generateKeyPairSync, sign } from "node:crypto";
import { existsSync, mkdirSync, writeFileSync } from "node:fs";
import { readFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { gzipSync } from "node:zlib";

const __dirname = dirname(fileURLToPath(import.meta.url));

function resolveWasmDir() {
  const candidates = [
    process.argv[2],
    process.env.GUILLOTINE_WASM_DIR,
    resolve(__dirname, "../zig-out/bin"),
    "/home/lane/gm-v02/zig-out/bin",
  ].filter(Boolean);
  for (const dir of candidates) {
    if (existsSync(resolve(dir, "guillotine_mini.wasm"))) return dir;
  }
  throw new Error(
    `Could not find guillotine_mini.wasm in: ${candidates.join(", ")}. Run "zig build wasm wasm-modular" first.`,
  );
}

function createWasiShim() {
  let memory = null;
  const view = () => new DataView(memory.buffer);
  const bytes = () => new Uint8Array(memory.buffer);
  const writeIovs = (fd, iovs, len, nwritten) => {
    if (fd !== 1 && fd !== 2) return 8;
    const dv = view();
    let total = 0;
    for (let i = 0; i < len >>> 0; i++) total += dv.getUint32((iovs >>> 0) + i * 8 + 4, true);
    dv.setUint32(nwritten >>> 0, total, true);
    return 0;
  };
  const wasiImport = {
    args_sizes_get: (a, b) => { view().setUint32(a >>> 0, 0, true); view().setUint32(b >>> 0, 0, true); return 0; },
    args_get: () => 0,
    environ_sizes_get: (a, b) => { view().setUint32(a >>> 0, 0, true); view().setUint32(b >>> 0, 0, true); return 0; },
    environ_get: () => 0,
    clock_res_get: (_id, out) => { view().setBigUint64(out >>> 0, 1_000_000n, true); return 0; },
    clock_time_get: (_id, _p, out) => { view().setBigUint64(out >>> 0, BigInt(Date.now()) * 1_000_000n, true); return 0; },
    fd_close: (fd) => (fd >= 0 && fd <= 2 ? 0 : 8),
    fd_fdstat_get: (fd, p) => { if (fd < 0 || fd > 2) return 8; bytes().fill(0, p >>> 0, (p >>> 0) + 24); view().setUint8(p >>> 0, 2); return 0; },
    fd_fdstat_set_flags: (fd) => (fd >= 0 && fd <= 2 ? 0 : 8),
    fd_filestat_get: (fd, p) => { if (fd < 0 || fd > 2) return 8; bytes().fill(0, p >>> 0, (p >>> 0) + 64); view().setUint8((p >>> 0) + 16, 2); return 0; },
    fd_prestat_get: () => 8,
    fd_prestat_dir_name: () => 8,
    fd_read: (fd, _i, _l, n) => { if (fd !== 0) return 8; view().setUint32(n >>> 0, 0, true); return 0; },
    fd_pread: (fd, _i, _l, _o, n) => { if (fd !== 0) return 8; view().setUint32(n >>> 0, 0, true); return 0; },
    fd_write: writeIovs,
    fd_pwrite: (fd, iovs, len, _off, n) => writeIovs(fd, iovs, len, n),
    fd_seek: (fd, _o, _w, out) => { if (fd < 0 || fd > 2) return 8; view().setBigUint64(out >>> 0, 0n, true); return 0; },
    fd_sync: (fd) => (fd >= 0 && fd <= 2 ? 0 : 8),
    path_open: () => 52,
    poll_oneoff: () => 52,
    proc_exit: (c) => { throw new Error(`proc_exit(${c})`); },
    random_get: (ptr, len) => { globalThis.crypto.getRandomValues(bytes().subarray(ptr >>> 0, (ptr >>> 0) + (len >>> 0))); return 0; },
    sched_yield: () => 0,
  };
  return {
    wasiImport,
    initialize(instance) {
      memory = instance.exports.memory;
      if (typeof instance.exports._initialize === "function") instance.exports._initialize();
    },
  };
}

function createPrecompileImports(getMem, instances) {
  const map = new Map();
  for (const inst of instances) map.set(inst.exports.address() >>> 0, inst.exports);
  return {
    run(addr, fork, input, len, gas, gasUsed) {
      const api = map.get(addr >>> 0);
      if (!api) throw new Error(`Missing precompile 0x${addr.toString(16)}`);
      const ptr = api.prepare(len >>> 0) >>> 0;
      if (len && ptr) {
        new Uint8Array(api.memory.buffer, ptr, len >>> 0).set(new Uint8Array(getMem().buffer, input >>> 0, len >>> 0));
      }
      const size = api.execute(fork >>> 0, gas);
      if (size >= 0) new DataView(getMem().buffer).setBigUint64(gasUsed >>> 0, api.gas_used(), true);
      return size;
    },
    copy_output(addr, dest, len) {
      const api = map.get(addr >>> 0);
      new Uint8Array(getMem().buffer, dest >>> 0, len >>> 0).set(
        new Uint8Array(api.memory.buffer, api.output_ptr() >>> 0, len >>> 0),
      );
    },
  };
}

function buildValidP256Input() {
  const { privateKey, publicKey } = generateKeyPairSync("ec", { namedCurve: "prime256v1" });
  const message = Buffer.from("guillotine-mini v0.2.0 P256VERIFY benchmark vector");
  const digest = createHash("sha256").update(message).digest();
  const sig = sign("sha256", message, { key: privateKey, dsaEncoding: "ieee-p1363" });
  const jwk = publicKey.export({ format: "jwk" });
  const qx = Buffer.from(jwk.x, "base64url");
  const qy = Buffer.from(jwk.y, "base64url");
  return Uint8Array.from(Buffer.concat([digest, sig.subarray(0, 32), sig.subarray(32, 64), qx, qy]));
}

async function instantiateEvm(mod, precompileModules = []) {
  const precompiles = await Promise.all(
    precompileModules.map(async (pm) => {
      const wasi = createWasiShim();
      const inst = await WebAssembly.instantiate(pm, { wasi_snapshot_preview1: wasi.wasiImport });
      wasi.initialize(inst);
      return inst;
    }),
  );
  const wasi = createWasiShim();
  let ref = null;
  const instance = await WebAssembly.instantiate(mod, {
    wasi_snapshot_preview1: wasi.wasiImport,
    env: { js_opcode_callback: () => 0, js_precompile_callback: () => 0 },
    precompiles: createPrecompileImports(() => ref.exports.memory, precompiles),
  });
  ref = instance;
  wasi.initialize(instance);
  const api = instance.exports;
  const allocs = [];
  const alloc = (val) => {
    const data = typeof val === "number" ? new Uint8Array(val) : val;
    const ptr = api.evm_alloc(data.length) >>> 0;
    new Uint8Array(api.memory.buffer, ptr, data.length).set(data);
    allocs.push([ptr, data.length]);
    return ptr;
  };
  const fork = new TextEncoder().encode("osaka");
  const handle = api.evm_create(alloc(fork), fork.length, 0) >>> 0;
  const target = new Uint8Array(20);
  target[18] = 2; // 0x0200
  const targetPtr = alloc(target);
  const zeroPtr = alloc(32);
  const callerPtr = alloc(20);
  api.evm_set_blockchain_context(handle, zeroPtr, 1n, 1_720_000_000n, zeroPtr, zeroPtr, callerPtr, 30_000_000n, zeroPtr, zeroPtr);
  return {
    api,
    handle,
    alloc,
    targetPtr,
    zeroPtr,
    callerPtr,
    close() {
      api.evm_destroy(handle);
      for (const [p, n] of allocs.reverse()) api.evm_free(p, n);
    },
  };
}

function stats(samplesNs) {
  const sorted = [...samplesNs].sort((a, b) => a - b);
  const sum = sorted.reduce((acc, v) => acc + v, 0);
  const pick = (p) => sorted[Math.min(sorted.length - 1, Math.floor(sorted.length * p))];
  return {
    runs: sorted.length,
    mean_ns: Math.round(sum / sorted.length),
    median_ns: pick(0.5),
    p95_ns: pick(0.95),
    min_ns: sorted[0],
  };
}

function measureSync(warmup, iters, fn) {
  for (let i = 0; i < warmup; i++) fn();
  const samples = new Array(iters);
  for (let i = 0; i < iters; i++) {
    const t0 = process.hrtime.bigint();
    fn();
    samples[i] = Number(process.hrtime.bigint() - t0);
  }
  return stats(samples);
}

const fmtUs = (ns) => `${(ns / 1_000).toFixed(2)} µs`;
const fmtMs = (ns) => `${(ns / 1_000_000).toFixed(3)} ms`;
const fmtKb = (b) => `${(b / 1024).toFixed(1)} KiB`;

const wasmDir = resolveWasmDir();
const fullBytes = await readFile(resolve(wasmDir, "guillotine_mini.wasm"));
const corePath = resolve(wasmDir, "guillotine_mini_core.wasm");
const coreBytes = existsSync(corePath) ? await readFile(corePath) : null;
const p256Path = resolve(wasmDir, "precompile-100.wasm");
const p256Bytes = existsSync(p256Path) ? await readFile(p256Path) : null;

const fullGzip = gzipSync(fullBytes, { level: 9 }).length;
const coreGzip = coreBytes ? gzipSync(coreBytes, { level: 9 }).length : null;
const p256Gzip = p256Bytes ? gzipSync(p256Bytes, { level: 9 }).length : null;

const fullMod = await WebAssembly.compile(fullBytes);
const coreMod = coreBytes ? await WebAssembly.compile(coreBytes) : null;
const p256Mod = p256Bytes ? await WebAssembly.compile(p256Bytes) : null;

const coldFullSamples = [];
for (let i = 0; i < 25; i++) {
  const t0 = process.hrtime.bigint();
  const f = await instantiateEvm(fullMod);
  f.close();
  coldFullSamples.push(Number(process.hrtime.bigint() - t0));
}
const coldFull = stats(coldFullSamples);

let coldCore = null;
if (coreMod) {
  const samples = [];
  for (let i = 0; i < 25; i++) {
    const t0 = process.hrtime.bigint();
    const f = await instantiateEvm(coreMod);
    f.close();
    samples.push(Number(process.hrtime.bigint() - t0));
  }
  coldCore = stats(samples);
}

const evm = await instantiateEvm(fullMod);
let simpleCall;
let loop500;
let osakaClz;
let p256Full;
let p256Modular = null;

try {
  // 1. Warm simple arithmetic call (20 + 22 = 42, return 32B)
  const simpleCode = Buffer.from("601460160160005260206000f3", "hex");
  const outPtr = evm.alloc(32);
  evm.api.evm_set_bytecode(evm.handle, evm.alloc(simpleCode), simpleCode.length);
  evm.api.evm_set_execution_context(evm.handle, 1_000_000n, evm.callerPtr, evm.targetPtr, evm.zeroPtr, evm.zeroPtr, 0);
  simpleCall = measureSync(50, 2000, () => {
    if (evm.api.evm_execute(evm.handle) !== 1) throw new Error("simple call failed");
    evm.api.evm_get_output(evm.handle, outPtr, 32);
  });

  // 2. Warm 500-iter arithmetic loop (~3.5K opcodes)
  const loopCode = Buffer.from("6101f45b600190038060035700", "hex");
  evm.api.evm_set_bytecode(evm.handle, evm.alloc(loopCode), loopCode.length);
  evm.api.evm_set_execution_context(evm.handle, 10_000_000n, evm.callerPtr, evm.targetPtr, evm.zeroPtr, evm.zeroPtr, 0);
  loop500 = measureSync(20, 200, () => {
    if (evm.api.evm_execute(evm.handle) !== 1) throw new Error("loop failed");
  });

  // 3. Osaka EIP-7939 CLZ (32x CLZ + return 32B)
  const clzCode = Buffer.from(`6001${"1e".repeat(32)}60005260206000f3`, "hex");
  evm.api.evm_set_bytecode(evm.handle, evm.alloc(clzCode), clzCode.length);
  evm.api.evm_set_execution_context(evm.handle, 1_000_000n, evm.callerPtr, evm.targetPtr, evm.zeroPtr, evm.zeroPtr, 0);
  osakaClz = measureSync(50, 1000, () => {
    if (evm.api.evm_execute(evm.handle) !== 1) throw new Error("CLZ failed");
    evm.api.evm_get_output(evm.handle, outPtr, 32);
  });

  // 4. Osaka EIP-7951 P256VERIFY (0x0100) with real valid secp256r1 signature
  const p256Input = buildValidP256Input();
  const p256Addr = new Uint8Array(20);
  p256Addr[18] = 1; // 0x0100
  const p256AddrPtr = evm.alloc(p256Addr);
  const p256InPtr = evm.alloc(p256Input);
  evm.api.evm_set_bytecode(evm.handle, 0, 0);
  evm.api.evm_set_execution_context(evm.handle, 100_000n, evm.callerPtr, p256AddrPtr, evm.zeroPtr, p256InPtr, p256Input.length);
  if (evm.api.evm_execute(evm.handle) !== 1 || evm.api.evm_get_output_len(evm.handle) !== 32) {
    throw new Error("P256VERIFY sanity check failed");
  }
  p256Full = measureSync(10, 200, () => {
    if (evm.api.evm_execute(evm.handle) !== 1) throw new Error("P256VERIFY failed");
    evm.api.evm_get_output(evm.handle, outPtr, 32);
  });

  if (coreMod && p256Mod) {
    const modEvm = await instantiateEvm(coreMod, [p256Mod]);
    try {
      const mOut = modEvm.alloc(32);
      const mAddr = modEvm.alloc(p256Addr);
      const mIn = modEvm.alloc(p256Input);
      modEvm.api.evm_set_bytecode(modEvm.handle, 0, 0);
      modEvm.api.evm_set_execution_context(modEvm.handle, 100_000n, modEvm.callerPtr, mAddr, modEvm.zeroPtr, mIn, p256Input.length);
      if (modEvm.api.evm_execute(modEvm.handle) !== 1 || modEvm.api.evm_get_output_len(modEvm.handle) !== 32) {
        throw new Error("Modular P256VERIFY sanity check failed");
      }
      p256Modular = measureSync(10, 200, () => {
        if (modEvm.api.evm_execute(modEvm.handle) !== 1) throw new Error("Modular P256VERIFY failed");
        modEvm.api.evm_get_output(modEvm.handle, mOut, 32);
      });
    } finally {
      modEvm.close();
    }
  }
} finally {
  evm.close();
}

const report = {
  runtime: typeof Bun !== "undefined" ? `bun ${Bun.version}` : `node ${process.version}`,
  wasmDir,
  sizes: {
    guillotine_mini_core_wasm: coreBytes ? { raw_bytes: coreBytes.length, gzip_bytes: coreGzip } : null,
    guillotine_mini_wasm: { raw_bytes: fullBytes.length, gzip_bytes: fullGzip },
    precompile_100_wasm: p256Bytes ? { raw_bytes: p256Bytes.length, gzip_bytes: p256Gzip } : null,
  },
  benchmarks: {
    cold_instantiate_full: coldFull,
    cold_instantiate_core: coldCore,
    warm_simple_call: simpleCall,
    warm_loop_500: loop500,
    osaka_clz_32x: osakaClz,
    osaka_p256verify_monolithic: p256Full,
    osaka_p256verify_modular: p256Modular,
  },
};

console.log("\n=== Guillotine Mini v0.2.0 WASM Benchmark ===");
console.log(`Runtime: ${report.runtime}`);
console.log("\nBundle Sizes:");
if (coreBytes) {
  console.log(`  guillotine_mini_core.wasm : ${coreBytes.length} B (${fmtKb(coreBytes.length)}) | gzip: ${coreGzip} B (${fmtKb(coreGzip)})`);
}
console.log(`  guillotine_mini.wasm      : ${fullBytes.length} B (${fmtKb(fullBytes.length)}) | gzip: ${fullGzip} B (${fmtKb(fullGzip)})`);
if (p256Bytes) {
  console.log(`  precompile-100.wasm       : ${p256Bytes.length} B (${fmtKb(p256Bytes.length)}) | gzip: ${p256Gzip} B (${fmtKb(p256Gzip)})`);
}
console.log("\nExecution Latency (median / p95):");
console.log(`  Cold instantiate (full)   : ${fmtMs(coldFull.median_ns)} / ${fmtMs(coldFull.p95_ns)}`);
if (coldCore) console.log(`  Cold instantiate (core)   : ${fmtMs(coldCore.median_ns)} / ${fmtMs(coldCore.p95_ns)}`);
console.log(`  Warm simple call (42)     : ${fmtUs(simpleCall.median_ns)} / ${fmtUs(simpleCall.p95_ns)}`);
console.log(`  Warm 500-iter loop        : ${fmtUs(loop500.median_ns)} / ${fmtUs(loop500.p95_ns)}`);
console.log(`  Osaka CLZ (32x)           : ${fmtUs(osakaClz.median_ns)} / ${fmtUs(osakaClz.p95_ns)}`);
console.log(`  Osaka P256VERIFY (full)   : ${fmtUs(p256Full.median_ns)} / ${fmtUs(p256Full.p95_ns)}`);
if (p256Modular) {
  console.log(`  Osaka P256VERIFY (modular): ${fmtUs(p256Modular.median_ns)} / ${fmtUs(p256Modular.p95_ns)}`);
}
console.log("");

const outPath = process.env.BENCH_JSON_OUT;
if (outPath) {
  const dir = dirname(outPath);
  if (dir && dir !== ".") mkdirSync(dir, { recursive: true });
  writeFileSync(outPath, `${JSON.stringify(report, null, 2)}\n`, "utf8");
}
