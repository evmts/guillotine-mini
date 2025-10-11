/**
 * Complete example: Using Guillotine EVM with async state interface
 * Demonstrates reading from Ethereum mainnet via RPC
 */

import { createEvm } from "../src/index.js";
import type { StateInterface, StateChanges, Address, U256 } from "../src/types.js";

/**
 * Example StateInterface implementation using ethers.js
 * In practice, you might use any RPC provider, database, or custom backend
 */
class EthersStateProvider implements StateInterface {
  private provider: any; // Would be ethers.JsonRpcProvider in real usage

  constructor(rpcUrl: string) {
    // In real usage: this.provider = new ethers.JsonRpcProvider(rpcUrl);
    // For this example, we'll use a mock
    console.log(`[State] Connected to RPC: ${rpcUrl}`);
  }

  async getStorage(address: Address, slot: U256): Promise<U256> {
    console.log(`[RPC] getStorage(${address}, ${slot})`);

    // In real usage: return await this.provider.getStorage(address, slot);

    // Mock: return zero for now
    const value = "0x0000000000000000000000000000000000000000000000000000000000000000";
    console.log(`[RPC] => ${value}`);
    return value;
  }

  async getBalance(address: Address): Promise<bigint> {
    console.log(`[RPC] getBalance(${address})`);

    // In real usage: return await this.provider.getBalance(address);

    const balance = 1000000000000000000n; // 1 ETH
    console.log(`[RPC] => ${balance}`);
    return balance;
  }

  async getCode(address: Address): Promise<string> {
    console.log(`[RPC] getCode(${address})`);

    // In real usage: return await this.provider.getCode(address);

    const code = "0x";
    console.log(`[RPC] => ${code}`);
    return code;
  }

  async getNonce(address: Address): Promise<bigint> {
    console.log(`[RPC] getNonce(${address})`);

    // In real usage: return BigInt(await this.provider.getTransactionCount(address));

    const nonce = 5n;
    console.log(`[RPC] => ${nonce}`);
    return nonce;
  }

  async commitChanges(changes: StateChanges): Promise<void> {
    console.log("[Commit] Received state changes:");
    console.log(`  Storage: ${changes.storage.length} changes`);
    console.log(`  Balances: ${changes.balances.length} changes`);
    console.log(`  Nonces: ${changes.nonces.length} changes`);
    console.log(`  Codes: ${changes.codes.length} changes`);
    console.log(`  Self-destructs: ${changes.selfDestructs.length} accounts`);

    // Log all storage changes
    for (const change of changes.storage) {
      console.log(`  SSTORE: ${change.address}[${change.slot}]`);
      console.log(`    ${change.originalValue} => ${change.newValue}`);
    }

    // In real usage: batch write to database or send to RPC
    console.log("[Commit] Changes would be written to database/state backend");
  }
}

/**
 * Example: Execute a simple storage read/write contract
 */
async function main() {
  console.log("=== Guillotine EVM with Async State Interface ===\n");

  // Create state provider
  const stateProvider = new EthersStateProvider("https://eth.llamarpc.com");

  // Create EVM with async state interface
  const evm = await createEvm({
    hardfork: "CANCUN",
    stateInterface: stateProvider,
    logLevel: "info",
  });

  console.log("[EVM] Created with async state interface\n");

  // Example contract: Simple storage counter
  // Solidity equivalent:
  //   uint256 counter;
  //   function increment() {
  //     counter = counter + 1;
  //   }

  const contractAddress = "0x1234567890123456789012345678901234567890";

  // Bytecode: PUSH1 0x00, SLOAD, PUSH1 0x01, ADD, PUSH1 0x00, SSTORE, STOP
  // Load slot 0, add 1, store back to slot 0
  const bytecode = "0x6000546001016000550000";

  await evm.setBytecode(bytecode);

  await evm.setExecutionContext({
    gas: 100000n,
    caller: "0x0000000000000000000000000000000000000001",
    address: contractAddress,
    value: 0n,
    calldata: "0x",
  });

  await evm.setBlockchainContext({
    chainId: 1n,
    blockNumber: 19000000n,
    blockTimestamp: 1234567890n,
    blockDifficulty: 0n,
    blockPrevrandao: 0n,
    blockCoinbase: "0x0000000000000000000000000000000000000000",
    blockGasLimit: 30000000n,
    blockBaseFee: 10000000000n,
    blobBaseFee: 1n,
  });

  console.log("[Execute] Starting transaction...\n");

  const result = await evm.execute();

  console.log("\n[Execute] Result:");
  console.log(`  Success: ${result.success}`);
  console.log(`  Gas Used: ${result.gasUsed}`);
  console.log(`  Gas Remaining: ${result.gasRemaining}`);
  console.log(`  Output: ${result.output}`);

  await evm.destroy();

  console.log("\n[EVM] Destroyed");
  console.log("\n=== Execution Flow ===");
  console.log("1. SLOAD hits -> cache miss -> async getStorage() call");
  console.log("2. RPC returns value -> cached -> execution continues");
  console.log("3. ADD performed");
  console.log("4. SSTORE marks slot dirty");
  console.log("5. Transaction ends -> dumpChanges() -> commitChanges() call");
  console.log("6. State changes committed to backend");
  console.log("7. Execution complete");
}

// Run the example
main().catch((err) => {
  console.error("Error:", err);
  process.exit(1);
});
