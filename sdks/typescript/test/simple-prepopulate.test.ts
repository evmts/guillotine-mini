import { describe, it, expect } from "bun:test";
import { readFileSync } from "fs";
import { join } from "path";
import { createEvm as createEvmFromModule } from "../src/evm.js";

async function createEvm(options: any) {
  const wasmPath = join(import.meta.dir, "../wasm/guillotine_mini.wasm");
  const wasmBytes = readFileSync(wasmPath);
  const wasmModule = new WebAssembly.Module(wasmBytes);
  return createEvmFromModule(wasmModule, options);
}

describe("Simple pre-populate approach", () => {
  it("should work by pre-populating storage", async () => {
    const evm = await createEvm({
      hardfork: "CANCUN",
    });

    const testAddress = "0x1234567890123456789012345678901234567890";

    // Pre-populate storage BEFORE execution
    await evm.setStorage(
      testAddress,
      "0x0000000000000000000000000000000000000000000000000000000000000000",
      "0x000000000000000000000000000000000000000000000000000000000000002a" // 42
    );

    // Bytecode: PUSH1 0x00, SLOAD, PUSH1 0x00, MSTORE, PUSH1 0x20, PUSH1 0x00, RETURN
    await evm.setBytecode("0x60005460005260206000f3");

    await evm.setExecutionContext({
      gas: 100000n,
      caller: testAddress,
      address: testAddress,
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
    // Should return the value we stored (42)
    expect(result.output).toBe("0x000000000000000000000000000000000000000000000000000000000000002a");

    await evm.destroy();
  });
});
