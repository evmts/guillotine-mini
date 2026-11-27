import { describe, expect, test } from "bun:test";
import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";
import { handleEvmWorkerRequest } from "../cloudflare/evm-worker.ts";
import * as sdk from "./index.ts";

function findWasmDir(): string | null {
  const candidates = [
    process.env.GUILLOTINE_WASM_DIR,
    resolve(import.meta.dir, "../zig-out/bin"),
    "/home/lane/gm-v02/zig-out/bin",
  ].filter((x): x is string => typeof x === "string" && x.length > 0);
  for (const dir of candidates) {
    if (existsSync(resolve(dir, "guillotine_mini_core.wasm"))) return dir;
  }
  return null;
}

describe("@tevm/guillotine-mini public barrel exports & edge worker", () => {
  test("exports version, factory, codecs, WASI shim, precompiles, and fork helpers", () => {
    expect(sdk.SDK_VERSION).toBe("0.2.0");
    expect(typeof sdk.createEvm).toBe("function");
    expect(typeof sdk.GuillotineEvm).toBe("function");
    expect(typeof sdk.createWasiShim).toBe("function");
    expect(typeof sdk.createPrecompileImports).toBe("function");
    expect(typeof sdk.instantiatePrecompile).toBe("function");
    expect(typeof sdk.createJsonRpcProvider).toBe("function");
    expect(typeof sdk.createCachedStateProvider).toBe("function");
    expect(typeof sdk.driveAsyncExecution).toBe("function");
    expect(typeof sdk.WasmMemoryBridge).toBe("function");
    expect(typeof sdk.decodeRevertBytes).toBe("function");
    expect(sdk.PRECOMPILE_ADDRESSES).toContain(0x100);
  });

  test("Cloudflare Edge EVM Worker handles health, clientVersion, and real WASM JSON-RPC methods", async () => {
    const health = await handleEvmWorkerRequest(new Request("https://edge.mini.tevm.sh/health"), {});
    expect(health.status).toBe(200);
    const healthJson = (await health.json()) as { status: string; methods: string[] };
    expect(healthJson.status).toBe("ok");
    expect(healthJson.methods).toContain("eth_call");

    const verRes = await handleEvmWorkerRequest(
      new Request("https://edge.mini.tevm.sh/", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ jsonrpc: "2.0", id: 1, method: "web3_clientVersion", params: [] }),
      }),
      {},
    );
    const verJson = (await verRes.json()) as { result: string };
    expect(verJson.result).toBe("guillotine-mini/0.2.0/wasm32-wasi");

    const dir = findWasmDir();
    if (!dir) return;

    const coreWasm = new Uint8Array(readFileSync(resolve(dir, "guillotine_mini_core.wasm")));
    const idPrecompile = new Uint8Array(readFileSync(resolve(dir, "precompile-04.wasm")));
    const batchReq = new Request("https://edge.mini.tevm.sh/", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify([
        {
          jsonrpc: "2.0",
          id: 10,
          method: "eth_call",
          params: [{ to: "0x0000000000000000000000000000000000000004", data: "0xdeadbeef" }, "latest"],
        },
        {
          jsonrpc: "2.0",
          id: 11,
          method: "eth_estimateGas",
          params: [{ bytecode: "0x602a60005260206000f3" }, "latest"],
        },
        {
          jsonrpc: "2.0",
          id: 12,
          method: "eth_createAccessList",
          params: [{ bytecode: "0x6001545000" }, "latest"],
        },
        {
          jsonrpc: "2.0",
          id: 13,
          method: "debug_traceCall",
          params: [{ bytecode: "0x602a60005260206000f3" }, "latest", { tracer: "callTracer" }],
        },
      ]),
    });

    const batchRes = await handleEvmWorkerRequest(batchReq, { HARDFORK: "osaka" }, {
      wasm: coreWasm,
      precompiles: [idPrecompile],
    });
    expect(batchRes.status).toBe(200);
    const results = (await batchRes.json()) as Array<{ id: number; result?: unknown; error?: unknown }>;
    expect(results[0]?.result).toBe("0xdeadbeef");
    expect(results[1]?.result).toBe("0x521a"); // 21000 + 18 = 21018 = 0x521a
    expect((results[2]?.result as { accessList: unknown[] }).accessList.length).toBeGreaterThanOrEqual(1);
    expect((results[3]?.result as { type: string }).type).toBe("CALL");
  });
});
