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

describe("Sync mode test", () => {
  it("should execute STOP without async", async () => {
    const evm = await createEvm({
      hardfork: "CANCUN",
    });

    await evm.setBytecode("0x00"); // STOP

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
