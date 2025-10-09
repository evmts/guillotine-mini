import { describe, it, expect } from "bun:test";
import { readFileSync } from "fs";
import { join } from "path";
import { createEvm as createEvmFromModule } from "../src/evm.js";
import type { StateInterface, StateChanges } from "../src/types.js";

async function createEvm(options: any) {
  const wasmPath = join(import.meta.dir, "../wasm/guillotine_mini.wasm");
  console.log(`[Debug] Loading WASM from: ${wasmPath}`);
  const wasmBytes = readFileSync(wasmPath);
  console.log(`[Debug] WASM size: ${wasmBytes.length} bytes`);
  const wasmModule = new WebAssembly.Module(wasmBytes);
  return createEvmFromModule(wasmModule, options);
}

describe("Simple Async Test", () => {
  it("should execute without crashing", async () => {
    let getStorageCalled = false;
    let commitCalled = false;

    const mockState: StateInterface = {
      async getStorage(address, slot) {
        console.log(`getStorage(${address}, ${slot})`);
        getStorageCalled = true;
        return "0x0000000000000000000000000000000000000000000000000000000000000042";
      },
      async getBalance() {
        return 0n;
      },
      async getCode() {
        return "0x";
      },
      async getNonce() {
        return 0n;
      },
      async commitChanges(changes) {
        console.log("commitChanges called:", changes);
        commitCalled = true;
      },
    };

    const evm = await createEvm({
      hardfork: "CANCUN",
      stateInterface: mockState,
    });

    // Simplest possible bytecode: STOP (0x00)
    await evm.setBytecode("0x00");

    await evm.setExecutionContext({
      gas: 100000n,
      caller: "0x1111111111111111111111111111111111111111",
      address: "0x2222222222222222222222222222222222222222",
      value: 0n,
      calldata: "0x",
    });

    await evm.setBlockchainContext({
      chainId: 1n,
      blockNumber: 1n,
      blockTimestamp: 1n,
      blockDifficulty: 0n,
      blockPrevrandao: 0n,
      blockCoinbase: "0x0000000000000000000000000000000000000000",
      blockGasLimit: 30000000n,
      blockBaseFee: 1n,
      blobBaseFee: 1n,
    });

    const result = await evm.execute();
    console.log("Result:", result);

    expect(result.success).toBe(true);

    await evm.destroy();
  });
});
