/**
 * Integration tests for async state interface (storage injection)
 * Tests the complete flow from TypeScript StateInterface -> Zig async protocol -> WASM
 */

import { describe, it, expect, beforeAll } from "bun:test";
import { readFileSync } from "fs";
import { join } from "path";
import { createEvm as createEvmFromModule } from "../src/evm.js";
import type { StateInterface, StateChanges, Address, U256, EvmOptions } from "../src/types.js";

// Helper to create EVM with proper WASM loading for tests
async function createEvm(options?: EvmOptions) {
  const wasmPath = join(import.meta.dir, "../wasm/guillotine_mini.wasm");
  const wasmBytes = readFileSync(wasmPath);
  const wasmModule = new WebAssembly.Module(wasmBytes);
  return createEvmFromModule(wasmModule, options);
}

describe("Async State Interface Integration", () => {
  // Mock state provider with in-memory storage
  class MockStateProvider implements StateInterface {
    private storage: Map<string, string> = new Map();
    private balances: Map<string, bigint> = new Map();
    private codes: Map<string, string> = new Map();
    private nonces: Map<string, bigint> = new Map();

    // Track calls for verification
    public getStorageCalls: Array<{ address: Address; slot: U256 }> = [];
    public getBalanceCalls: Address[] = [];
    public commitChangesCalls: StateChanges[] = [];

    async getStorage(address: Address, slot: U256): Promise<U256> {
      this.getStorageCalls.push({ address, slot });
      const key = `${address}:${slot}`;
      const value = this.storage.get(key) || "0x0000000000000000000000000000000000000000000000000000000000000000";
      console.log(`[MockState] getStorage(${address}, ${slot}) => ${value}`);
      return value;
    }

    async getBalance(address: Address): Promise<bigint> {
      this.getBalanceCalls.push(address);
      const balance = this.balances.get(address) || 0n;
      console.log(`[MockState] getBalance(${address}) => ${balance}`);
      return balance;
    }

    async getCode(address: Address): Promise<string> {
      const code = this.codes.get(address) || "0x";
      console.log(`[MockState] getCode(${address}) => ${code}`);
      return code;
    }

    async getNonce(address: Address): Promise<bigint> {
      const nonce = this.nonces.get(address) || 0n;
      console.log(`[MockState] getNonce(${address}) => ${nonce}`);
      return nonce;
    }

    async commitChanges(changes: StateChanges): Promise<void> {
      console.log(`[MockState] commitChanges:`, {
        storage: changes.storage.length,
        balances: changes.balances.length,
        nonces: changes.nonces.length,
        codes: changes.codes.length,
        selfDestructs: changes.selfDestructs.length,
      });

      this.commitChangesCalls.push(changes);

      // Apply changes to mock state
      for (const change of changes.storage) {
        const key = `${change.address}:${change.slot}`;
        this.storage.set(key, change.newValue);
        console.log(`  SSTORE: ${change.address}[${change.slot}] = ${change.newValue}`);
      }
    }

    // Helper to preset storage values
    setStorage(address: Address, slot: U256, value: U256): void {
      const key = `${address}:${slot}`;
      this.storage.set(key, value);
    }

    // Helper to reset call tracking
    resetCallTracking(): void {
      this.getStorageCalls = [];
      this.getBalanceCalls = [];
      this.commitChangesCalls = [];
    }
  }

  it("should execute simple SLOAD with async state interface", async () => {
    const mockState = new MockStateProvider();

    // Preset storage value
    const testAddress = "0x1234567890123456789012345678901234567890";
    const testSlot = "0x0000000000000000000000000000000000000000000000000000000000000000";
    const testValue = "0x000000000000000000000000000000000000000000000000000000000000002a"; // 42 in hex

    mockState.setStorage(testAddress, testSlot, testValue);

    const evm = await createEvm({
      hardfork: "CANCUN",
      stateInterface: mockState,
      logLevel: "debug",
    });

    // Bytecode: PUSH1 0x00, SLOAD, PUSH1 0x00, MSTORE, PUSH1 0x20, PUSH1 0x00, RETURN
    // This loads slot 0, stores in memory at offset 0, returns 32 bytes
    const bytecode = "0x60005460005260206000f3";

    await evm.setBytecode(bytecode);
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

    // Verify execution succeeded
    expect(result.success).toBe(true);

    // Verify output is the value we loaded (42)
    expect(result.output).toBe(testValue);

    // Verify async calls were made
    expect(mockState.getStorageCalls.length).toBeGreaterThan(0);
    expect(mockState.getStorageCalls[0].slot).toBe(testSlot);

    // Verify no changes committed (read-only operation)
    expect(mockState.commitChangesCalls.length).toBe(0);

    await evm.destroy();
  });

  it("should track and commit SSTORE changes", async () => {
    const mockState = new MockStateProvider();

    const testAddress = "0x1234567890123456789012345678901234567890";
    const testSlot = "0x0000000000000000000000000000000000000000000000000000000000000000";
    const newValue = "0x0000000000000000000000000000000000000000000000000000000000000063"; // 99

    const evm = await createEvm({
      hardfork: "CANCUN",
      stateInterface: mockState,
    });

    // Bytecode: PUSH1 0x63 (99), PUSH1 0x00 (slot 0), SSTORE
    const bytecode = "0x606360005500";

    await evm.setBytecode(bytecode);
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

    // Verify execution succeeded
    expect(result.success).toBe(true);

    // Verify commitChanges was called
    expect(mockState.commitChangesCalls.length).toBe(1);

    const changes = mockState.commitChangesCalls[0];
    expect(changes.storage.length).toBe(1);
    expect(changes.storage[0].address).toBe(testAddress);
    expect(changes.storage[0].slot).toBe(testSlot);
    expect(changes.storage[0].newValue).toBe(newValue);

    await evm.destroy();
  });

  it("should handle multiple SLOAD/SSTORE in one transaction", async () => {
    const mockState = new MockStateProvider();

    const testAddress = "0x1234567890123456789012345678901234567890";

    // Preset some values
    mockState.setStorage(
      testAddress,
      "0x0000000000000000000000000000000000000000000000000000000000000000",
      "0x000000000000000000000000000000000000000000000000000000000000000a" // 10
    );
    mockState.setStorage(
      testAddress,
      "0x0000000000000000000000000000000000000000000000000000000000000001",
      "0x0000000000000000000000000000000000000000000000000000000000000014" // 20
    );

    const evm = await createEvm({
      hardfork: "CANCUN",
      stateInterface: mockState,
    });

    // Bytecode:
    // PUSH1 0x00, SLOAD (load slot 0 = 10)
    // PUSH1 0x01, SLOAD (load slot 1 = 20)
    // ADD (10 + 20 = 30)
    // PUSH1 0x02, SSTORE (store 30 in slot 2)
    // STOP
    const bytecode = "0x600054600154016002550000";

    await evm.setBytecode(bytecode);
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

    mockState.resetCallTracking();
    const result = await evm.execute();

    expect(result.success).toBe(true);

    // Should have called getStorage twice (for slots 0 and 1)
    expect(mockState.getStorageCalls.length).toBeGreaterThanOrEqual(2);

    // Should have committed one change (slot 2)
    expect(mockState.commitChangesCalls.length).toBe(1);
    const changes = mockState.commitChangesCalls[0];
    expect(changes.storage.length).toBe(1);
    expect(changes.storage[0].slot).toBe("0x0000000000000000000000000000000000000000000000000000000000000002");
    expect(changes.storage[0].newValue).toBe("0x000000000000000000000000000000000000000000000000000000000000001e"); // 30

    await evm.destroy();
  });

  it("should work without stateInterface (sync mode)", async () => {
    // Create EVM without state interface - should use sync execution
    const evm = await createEvm({
      hardfork: "CANCUN",
    });

    const testAddress = "0x1234567890123456789012345678901234567890";

    // Simple bytecode: PUSH1 0x42, PUSH1 0x00, RETURN (return 0x42)
    const bytecode = "0x604260005260016000f3";

    await evm.setBytecode(bytecode);
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

    expect(result.success).toBe(true);
    // Output should be 0x42 (1 byte, padded to 32 bytes in return data is handled by RETURN opcode)

    await evm.destroy();
  });

  it("should handle cache hits (no redundant async calls)", async () => {
    const mockState = new MockStateProvider();

    const testAddress = "0x1234567890123456789012345678901234567890";
    const testSlot = "0x0000000000000000000000000000000000000000000000000000000000000000";

    mockState.setStorage(testAddress, testSlot, "0x0000000000000000000000000000000000000000000000000000000000000042");

    const evm = await createEvm({
      hardfork: "CANCUN",
      stateInterface: mockState,
    });

    // Bytecode: SLOAD slot 0, SLOAD slot 0 again (should hit cache)
    // PUSH1 0x00, SLOAD, PUSH1 0x00, SLOAD, STOP
    const bytecode = "0x60005460005400";

    await evm.setBytecode(bytecode);
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

    mockState.resetCallTracking();
    const result = await evm.execute();

    expect(result.success).toBe(true);

    // Should only call getStorage once - second SLOAD should hit cache
    expect(mockState.getStorageCalls.length).toBe(1);

    await evm.destroy();
  });

  it("should include original and new values in state changes", async () => {
    const mockState = new MockStateProvider();

    const testAddress = "0x1234567890123456789012345678901234567890";
    const testSlot = "0x0000000000000000000000000000000000000000000000000000000000000000";
    const originalValue = "0x0000000000000000000000000000000000000000000000000000000000000010"; // 16
    const newValue = "0x0000000000000000000000000000000000000000000000000000000000000020"; // 32

    mockState.setStorage(testAddress, testSlot, originalValue);

    const evm = await createEvm({
      hardfork: "CANCUN",
      stateInterface: mockState,
    });

    // Bytecode: PUSH1 0x00, SLOAD (load original), PUSH1 0x20, PUSH1 0x00, SSTORE (store 32)
    const bytecode = "0x600054602060005500";

    await evm.setBytecode(bytecode);
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

    expect(result.success).toBe(true);
    expect(mockState.commitChangesCalls.length).toBe(1);

    const changes = mockState.commitChangesCalls[0];
    expect(changes.storage.length).toBe(1);
    expect(changes.storage[0].originalValue).toBe(originalValue);
    expect(changes.storage[0].newValue).toBe(newValue);

    await evm.destroy();
  });
});

describe("Async Protocol Edge Cases", () => {
  class FailingStateProvider implements StateInterface {
    async getStorage(_address: Address, _slot: U256): Promise<U256> {
      throw new Error("Simulated storage failure");
    }

    async getBalance(_address: Address): Promise<bigint> {
      throw new Error("Simulated balance failure");
    }

    async getCode(_address: Address): Promise<string> {
      throw new Error("Simulated code failure");
    }

    async getNonce(_address: Address): Promise<bigint> {
      throw new Error("Simulated nonce failure");
    }

    async commitChanges(_changes: StateChanges): Promise<void> {
      throw new Error("Simulated commit failure");
    }
  }

  it("should propagate errors from state interface", async () => {
    const failingState = new FailingStateProvider();

    const evm = await createEvm({
      hardfork: "CANCUN",
      stateInterface: failingState,
    });

    const testAddress = "0x1234567890123456789012345678901234567890";

    // Bytecode: PUSH1 0x00, SLOAD (will trigger async call that fails)
    const bytecode = "0x600054";

    await evm.setBytecode(bytecode);
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

    // Should throw error from state interface
    await expect(evm.execute()).rejects.toThrow("Simulated storage failure");

    await evm.destroy();
  });
});
