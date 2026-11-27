import { describe, expect, test } from "bun:test";
import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";
import {
  PRECOMPILE_ADDRESSES,
  createPrecompileImports,
  instantiatePrecompiles,
  precompileFileName,
} from "./precompiles.ts";

function findWasmDir(): string | null {
  const candidates = [
    process.env.GUILLOTINE_WASM_DIR,
    resolve(import.meta.dir, "../zig-out/bin"),
    "/home/lane/gm-v02/zig-out/bin",
  ].filter((x): x is string => typeof x === "string" && x.length > 0);
  for (const dir of candidates) {
    if (existsSync(resolve(dir, "precompile-04.wasm"))) return dir;
  }
  return null;
}

function mockPrecompileInstance(addr: number, transform: (input: Uint8Array) => Uint8Array, gasCost: bigint): WebAssembly.Instance {
  const memory = new WebAssembly.Memory({ initial: 1 });
  let inLen = 0;
  let outBytes = new Uint8Array(0);
  return {
    exports: {
      memory,
      address: () => addr,
      prepare: (len: number) => {
        inLen = len;
        return len === 0 ? 0 : 128;
      },
      execute: (_fork: number, gas: bigint) => {
        if (gas < gasCost) return -1;
        const input = new Uint8Array(memory.buffer, 128, inLen).slice();
        outBytes = transform(input);
        new Uint8Array(memory.buffer, 4096, outBytes.length).set(outBytes);
        return outBytes.length;
      },
      output_ptr: () => 4096,
      gas_used: () => gasCost,
    },
  } as unknown as WebAssembly.Instance;
}

describe("precompiles modular host", () => {
  test("precompileFileName formats standard and Osaka 0x100 addresses", () => {
    expect(PRECOMPILE_ADDRESSES.length).toBe(18);
    expect(precompileFileName(0x01)).toBe("precompile-01.wasm");
    expect(precompileFileName(0x0a)).toBe("precompile-0a.wasm");
    expect(precompileFileName(0x100)).toBe("precompile-100.wasm");
  });

  test("createPrecompileImports dispatches, writes gas_used, copies output, and catches errors", () => {
    const coreMemory = new WebAssembly.Memory({ initial: 1 });
    const identity = mockPrecompileInstance(0x04, (bytes) => bytes, 18n);
    const imports = createPrecompileImports(() => coreMemory, [identity]);

    // Write input bytes at offset 64 in core memory, reserve gas_used u64 at offset 16
    const payload = new Uint8Array([1, 2, 3, 4, 5]);
    new Uint8Array(coreMemory.buffer, 64, payload.length).set(payload);
    const outLen = imports.run(0x04, 14, 64, payload.length, 1000n, 16);
    expect(outLen).toBe(payload.length);
    expect(new DataView(coreMemory.buffer).getBigUint64(16, true)).toBe(18n);

    imports.copy_output(0x04, 256, outLen);
    expect(new Uint8Array(coreMemory.buffer, 256, outLen)).toEqual(payload);

    // Out-of-gas returns negative error code without clobbering gas_used
    expect(imports.run(0x04, 14, 64, payload.length, 5n, 16)).toBe(-1);

    // Duplicate & missing precompiles throw descriptive errors
    expect(() => createPrecompileImports(() => coreMemory, [identity, identity])).toThrow(/Duplicate/);
    expect(() => imports.run(0x02, 14, 64, 0, 1000n, 16)).toThrow(/Missing/);
  });

  test("instantiates real precompile-02, precompile-04, and precompile-100 WASM reactors when present", async () => {
    const dir = findWasmDir();
    if (!dir) return;

    const files = ["precompile-02.wasm", "precompile-04.wasm", "precompile-100.wasm"];
    const buffers = files.map((f) => new Uint8Array(readFileSync(resolve(dir, f))));
    const instances = await instantiatePrecompiles(buffers);
    const coreMemory = new WebAssembly.Memory({ initial: 1 });
    const host = createPrecompileImports(() => coreMemory, instances);

    // Call real SHA-256 precompile (0x02) on empty input -> e3b0c442...
    const len = host.run(0x02, 14, 0, 0, 100_000n, 0);
    expect(len).toBe(32);
    expect(new DataView(coreMemory.buffer).getBigUint64(0, true)).toBe(60n);
    host.copy_output(0x02, 64, 32);
    const hash = new Uint8Array(coreMemory.buffer, 64, 32);
    expect(hash[0]).toBe(0xe3);
    expect(hash[1]).toBe(0xb0);
    expect(hash[31]).toBe(0x55);
  });
});
