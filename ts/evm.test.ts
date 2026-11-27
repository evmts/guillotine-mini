import { describe, expect, test } from "bun:test";
import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";
import { WasmMemoryBridge, encodeUtf8, hexToBytes, toWordBytes, type EvmWasmExports, type Hex } from "./abi.ts";
import { GuillotineEvm, createEvm } from "./evm.ts";
import type { StateProvider } from "./fork.ts";

function findWasmDir(): string | null {
  const candidates = [
    process.env.GUILLOTINE_WASM_DIR,
    resolve(import.meta.dir, "../zig-out/bin"),
    "/home/lane/gm-v02/zig-out/bin",
  ].filter((x): x is string => typeof x === "string" && x.length > 0);
  for (const dir of candidates) {
    if (existsSync(resolve(dir, "guillotine_mini.wasm"))) return dir;
  }
  return null;
}

describe("GuillotineEvm SDK", () => {
  test("mock handle exercises Symbol.dispose, flamegraph export handling, and revert decode", async () => {
    const memory = new WebAssembly.Memory({ initial: 1 });
    let bump = 512;
    let destroyed = false;
    const svgText = encodeUtf8("<svg><g>ROOT</g></svg>");
    const foldedText = encodeUtf8("ROOT;ADD 3\n");
    const mockExports = {
      memory,
      evm_alloc: (len: number) => {
        const p = bump;
        bump += (len + 15) & ~15;
        return p;
      },
      evm_free: () => {},
      evm_destroy: () => {
        destroyed = true;
      },
      evm_set_blockchain_context: () => 1,
      evm_set_bytecode: () => 1,
      evm_set_execution_context: () => 1,
      evm_execute: () => 1,
      evm_is_success: () => 1,
      evm_get_output_len: () => 0,
      evm_get_output: () => 0,
      evm_get_gas_used: () => 21n,
      evm_get_gas_remaining: () => 999_979n,
      evm_get_gas_refund: () => 0n,
      evm_get_log_count: () => 0,
      evm_get_storage_change_count: () => 0,
      evm_enable_flamegraph: () => 1,
      evm_get_flamegraph_svg_len: () => svgText.length,
      evm_get_flamegraph_svg: (_h: number, p: number, n: number) => {
        new Uint8Array(memory.buffer, p, svgText.length).set(svgText.subarray(0, n));
        return svgText.length;
      },
      evm_get_flamegraph_folded_len: () => foldedText.length,
      evm_get_flamegraph_folded: (_h: number, p: number, n: number) => {
        new Uint8Array(memory.buffer, p, foldedText.length).set(foldedText.subarray(0, n));
        return foldedText.length;
      },
    } as unknown as EvmWasmExports;

    const evm = new GuillotineEvm(new WasmMemoryBridge(mockExports), 1, null, "latest");
    const fg = await evm.flamegraphSvg({ bytecode: "0x00" });
    expect(fg.svg).toBe("<svg><g>ROOT</g></svg>");
    expect(fg.folded).toBe("ROOT;ADD 3\n");

    const decoded = evm.decodeRevert("0x4e487b710000000000000000000000000000000000000000000000000000000000000012");
    expect(decoded?.kind).toBe("panic");
    expect(decoded?.panicCode).toBe(0x12);

    evm[Symbol.dispose]();
    expect(destroyed).toBe(true);
    expect(() => evm.callSync({ bytecode: "0x00" })).toThrow(/disposed/);
  });

  test("executes real monolithic guillotine_mini.wasm (arithmetic, Osaka CLZ, state, trace, callTrace, accessList, revert)", async () => {
    const dir = findWasmDir();
    if (!dir) return;

    const wasmBytes = new Uint8Array(readFileSync(resolve(dir, "guillotine_mini.wasm")));
    const evm = await createEvm({ wasm: wasmBytes, hardfork: "osaka" });
    try {
      // 1. Arithmetic return 42
      const r1 = await evm.call({ bytecode: "0x602a60005260206000f3" });
      expect(r1.success).toBe(true);
      expect(r1.outputHex).toBe(`0x${"00".repeat(31)}2a`);
      expect(r1.gasUsed).toBe(18n);

      // 2. Osaka EIP-7939 CLZ(1) = 255
      const r2 = await evm.call({ bytecode: "0x60011e60005260206000f3" });
      expect(r2.success).toBe(true);
      expect(r2.output[31]).toBe(255);

      // 3. State setters, storage changes, and logs
      const target: Hex = "0x0000000000000000000000000000000000000200";
      evm.setBalance(target, 1234n);
      evm.setNonce(target, 3n);
      evm.setStorage(target, 0n, 99n);
      expect(evm.getStorage(target, 0n)).toBe(99n);
      const r3 = await evm.call({ to: target, bytecode: "0x602a600055602a600052600760206000a100" });
      expect(r3.success).toBe(true);
      expect(evm.getStorage(target, 0n)).toBe(42n);
      expect(r3.logs.length).toBe(1);
      expect(r3.logs[0]?.topics[0]).toBe(`0x${"00".repeat(31)}07`);
      expect(r3.storageChanges.length).toBe(1);

      // 4. EIP-3155 trace
      const tr = await evm.trace({ bytecode: "0x600160020160005260206000f3" }, { enableMemory: true });
      expect(tr.result.success).toBe(true);
      expect(tr.steps.length).toBeGreaterThanOrEqual(6);
      expect(tr.summary?.pass).toBe(true);

      // 5. Call trace & EIP-2930 access list on nested CALL
      const callee: Hex = "0x0000000000000000000000000000000000000202";
      evm.setCode(callee, "0x600154505f5fa000"); // SLOAD(1), POP, LOG0, STOP
      const parentCode = "0x5f5f5f5f5f61020261fffff15000";
      const ct = await evm.callTrace({ bytecode: parentCode }, { withLog: true });
      expect(ct.result.success).toBe(true);
      expect(ct.callFrame?.type).toBe("CALL");

      const al = await evm.createAccessList({ bytecode: parentCode });
      expect(al.result.success).toBe(true);
      expect(al.accessList.some((e) => e.address.toLowerCase() === callee)).toBe(true);

      // 6. Revert decoding (Error("boom"))
      const errMsg = encodeUtf8("boom");
      const errData = new Uint8Array(100);
      errData.set(hexToBytes("0x08c379a0"), 0);
      errData.set(toWordBytes(32n), 4);
      errData.set(toWordBytes(BigInt(errMsg.length)), 36);
      errData.set(errMsg, 68);
      // CALLDATACOPY(0, 0, CALLDATASIZE); REVERT(0, CALLDATASIZE)
      const revRes = await evm.call({ bytecode: "0x365f5f37365ffd", data: errData });
      expect(revRes.success).toBe(false);
      const dec = evm.decodeRevert();
      expect(dec?.kind).toBe("error");
      expect(dec?.reason).toBe("boom");
    } finally {
      evm.dispose();
    }
  });

  test("executes real WASM with lazy async StateProvider injection", async () => {
    const dir = findWasmDir();
    if (!dir) return;

    const wasmBytes = new Uint8Array(readFileSync(resolve(dir, "guillotine_mini.wasm")));
    const storageReads: string[] = [];
    const provider: StateProvider = {
      async getStorageAt(addr, slot) {
        storageReads.push(`${addr}:${slot}`);
        return `0x${"00".repeat(31)}2a`;
      },
      async getBalance() {
        return 1000n;
      },
      async getCode() {
        return new Uint8Array(0);
      },
      async getTransactionCount() {
        return 0n;
      },
    };

    const evm = await createEvm({ wasm: wasmBytes, hardfork: "osaka", stateProvider: provider });
    try {
      // SLOAD(0), MSTORE(0), RETURN(0, 32)
      const res = await evm.call({ bytecode: "0x5f545f5260205ff3" });
      expect(res.success).toBe(true);
      expect(res.output[31]).toBe(42);
      expect(storageReads.length).toBe(1);
    } finally {
      evm.dispose();
    }
  });

  test("executes real modular guillotine_mini_core.wasm + modular precompiles via universal wasi-shim", async () => {
    const dir = findWasmDir();
    if (!dir || !existsSync(resolve(dir, "guillotine_mini_core.wasm"))) return;

    const coreBytes = new Uint8Array(readFileSync(resolve(dir, "guillotine_mini_core.wasm")));
    const precompileBytes = ["precompile-02.wasm", "precompile-04.wasm", "precompile-100.wasm"].map(
      (name) => new Uint8Array(readFileSync(resolve(dir, name))),
    );
    const evm = await createEvm({
      wasm: coreBytes,
      hardfork: "osaka",
      precompiles: precompileBytes,
    });
    try {
      // Direct call to SHA-256 precompile (0x02) with empty input
      const sha = await evm.call({ to: "0x0000000000000000000000000000000000000002", data: "0x" });
      expect(sha.success).toBe(true);
      expect(sha.outputHex).toBe("0xe3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855");

      // Direct call to IDENTITY precompile (0x04)
      const id = await evm.call({ to: "0x0000000000000000000000000000000000000004", data: "0xdeadbeef" });
      expect(id.success).toBe(true);
      expect(id.outputHex).toBe("0xdeadbeef");

      // Direct call to Osaka P256VERIFY precompile (0x0100) with invalid length -> succeeds with 0B & 6900 gas
      const p256 = await evm.call({ to: "0x0000000000000000000000000000000000000100", data: "0x1234" });
      expect(p256.success).toBe(true);
      expect(p256.output.length).toBe(0);
      expect(p256.gasUsed).toBe(6900n);
    } finally {
      evm.dispose();
    }
  });
});
