/**
 * Universal modular precompile host for `guillotine_mini_core.wasm`.
 *
 * Uses `createWasiShim()` instead of `node:wasi`, so separately loadable
 * precompile WASM reactors work identically in browsers, Cloudflare Workers,
 * Deno, Bun, and Node 22+.
 */

import { createWasiShim, type WasiShimOptions } from "./wasi-shim.ts";

export const PRECOMPILE_ADDRESSES = [
  0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09,
  0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x100,
] as const;

export type PrecompileAddress = (typeof PRECOMPILE_ADDRESSES)[number];

export interface PrecompileExports {
  readonly memory: WebAssembly.Memory;
  readonly _initialize?: () => void;
  address(): number;
  prepare(len: number): number;
  execute(fork: number, gas: bigint): number;
  output_ptr(): number;
  gas_used(): bigint;
}

export type PrecompileModuleInput =
  | WebAssembly.Instance
  | WebAssembly.Module
  | ArrayBuffer
  | ArrayBufferView
  | Response;

export interface PrecompileHostImports {
  readonly [key: string]: WebAssembly.ImportValue;
  run(address: number, fork: number, inputPtr: number, len: number, gas: bigint, gasUsedPtr: number): number;
  copy_output(address: number, destPtr: number, len: number): void;
}

export function precompileFileName(address: number): string {
  const hex = address.toString(16).padStart(2, "0");
  return `precompile-${hex}.wasm`;
}

function asPrecompileExports(instance: WebAssembly.Instance): PrecompileExports {
  const exp = instance.exports;
  if (
    !(exp.memory instanceof WebAssembly.Memory) ||
    typeof exp.address !== "function" ||
    typeof exp.prepare !== "function" ||
    typeof exp.execute !== "function" ||
    typeof exp.output_ptr !== "function" ||
    typeof exp.gas_used !== "function"
  ) {
    throw new Error("Invalid modular precompile WASM exports");
  }
  return exp as unknown as PrecompileExports;
}

export type WasmSource = WebAssembly.Module | ArrayBuffer | ArrayBufferView | Response | URL | string;

export async function compileWasmModule(source: WasmSource): Promise<WebAssembly.Module> {
  if (source instanceof WebAssembly.Module) return source;
  if (source instanceof ArrayBuffer) return WebAssembly.compile(source);
  if (ArrayBuffer.isView(source)) {
    return WebAssembly.compile(new Uint8Array(source.buffer, source.byteOffset, source.byteLength).slice());
  }
  const res = source instanceof Response ? source : await fetch(source);
  if (!res.ok) throw new Error(`Failed to fetch WASM (${res.status} ${res.statusText})`);
  return WebAssembly.compile(await res.arrayBuffer());
}

/**
 * Instantiate and initialize a modular precompile WASI reactor using the
 * universal WASI shim.
 */
export async function instantiatePrecompile(
  source: PrecompileModuleInput,
  wasiOptions?: WasiShimOptions,
): Promise<WebAssembly.Instance> {
  if (source instanceof WebAssembly.Instance) return source;
  const mod = await compileWasmModule(source);
  const wasi = createWasiShim(wasiOptions);
  const instance = await WebAssembly.instantiate(mod, {
    wasi_snapshot_preview1: wasi.wasiImport,
  });
  wasi.initialize(instance);
  asPrecompileExports(instance);
  return instance;
}

export async function instantiatePrecompiles(
  sources: ReadonlyArray<PrecompileModuleInput>,
  wasiOptions?: WasiShimOptions,
): Promise<WebAssembly.Instance[]> {
  return Promise.all(sources.map((src) => instantiatePrecompile(src, wasiOptions)));
}

/**
 * Build the `precompiles` WASM import namespace expected by
 * `guillotine_mini_core.wasm` (`src/precompiles/wasm_host.zig`).
 */
export function createPrecompileImports(
  getCoreMemory: () => WebAssembly.Memory,
  instances: ReadonlyArray<WebAssembly.Instance> = [],
): PrecompileHostImports {
  const modules = new Map<number, PrecompileExports>();
  for (const instance of instances) {
    const api = asPrecompileExports(instance);
    const addr = api.address() >>> 0;
    if (modules.has(addr)) {
      throw new Error(`Duplicate WASM precompile 0x${addr.toString(16)}`);
    }
    modules.set(addr, api);
  }

  return {
    run(
      address: number,
      fork: number,
      inputPtr: number,
      len: number,
      gas: bigint,
      gasUsedPtr: number,
    ): number {
      const addr = address >>> 0;
      const api = modules.get(addr);
      if (!api) {
        throw new Error(`Missing WASM precompile 0x${addr.toString(16)}`);
      }
      const byteLen = len >>> 0;
      const ptr = api.prepare(byteLen) >>> 0;
      if (byteLen > 0 && ptr !== 0) {
        new Uint8Array(api.memory.buffer, ptr, byteLen).set(
          new Uint8Array(getCoreMemory().buffer, inputPtr >>> 0, byteLen),
        );
      }
      const size = api.execute(fork >>> 0, gas);
      if (size >= 0) {
        new DataView(getCoreMemory().buffer).setBigUint64(gasUsedPtr >>> 0, api.gas_used(), true);
      }
      return size;
    },

    copy_output(address: number, destPtr: number, len: number): void {
      const addr = address >>> 0;
      const api = modules.get(addr);
      if (!api) {
        throw new Error(`Missing WASM precompile 0x${addr.toString(16)}`);
      }
      const byteLen = len >>> 0;
      if (byteLen === 0) return;
      new Uint8Array(getCoreMemory().buffer, destPtr >>> 0, byteLen).set(
        new Uint8Array(api.memory.buffer, api.output_ptr() >>> 0, byteLen),
      );
    },
  };
}
