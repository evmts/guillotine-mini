import type {
  Evm,
  ExecutionContext,
  BlockchainContext,
  ExecutionResult,
  Address,
  U256,
  Bytes,
} from "./types.js";
import { bigintToU256 } from "./utils.js";

/**
 * WASM module interface
 */
interface WasmModule {
  instance: WebAssembly.Instance;
  exports: {
    memory: WebAssembly.Memory;
    evm_create: () => number;
    evm_destroy: (handle: number) => void;
    evm_set_bytecode: (handle: number, bytecode: number, len: number) => number;
    evm_set_execution_context: (
      handle: number,
      gas: bigint,
      caller: number,
      address: number,
      value: number,
      calldata: number,
      calldataLen: number,
    ) => number;
    evm_set_blockchain_context: (
      handle: number,
      chainId: bigint,
      blockNumber: bigint,
      blockTimestamp: bigint,
      blockCoinbase: number,
      blockGasLimit: bigint,
    ) => void;
    evm_execute: (handle: number) => number;
    evm_get_gas_remaining: (handle: number) => bigint;
    evm_get_gas_used: (handle: number) => bigint;
    evm_is_success: (handle: number) => number;
    evm_get_output_len: (handle: number) => number;
    evm_get_output: (
      handle: number,
      buffer: number,
      bufferLen: number,
    ) => number;
    evm_set_storage: (
      handle: number,
      address: number,
      slot: number,
      value: number,
    ) => number;
    evm_get_storage: (
      handle: number,
      address: number,
      slot: number,
      value: number,
    ) => number;
    evm_set_balance: (
      handle: number,
      address: number,
      balance: number,
    ) => number;
    evm_set_code: (
      handle: number,
      address: number,
      code: number,
      codeLen: number,
    ) => number;
  };
}

/**
 * Implementation of Evm interface wrapping WASM
 */
class EvmImpl implements Evm {
  private readyPromise: Promise<void>;
  private wasm: WasmModule | null = null;
  private handle: number = 0;

  constructor(wasmPath: string) {
    this.readyPromise = this.initialize(wasmPath);
  }

  private async initialize(wasmPath: string): Promise<void> {
    // Load WASM module
    const wasmBuffer = await this.loadWasm(wasmPath);
    const wasmModule = await WebAssembly.instantiate(wasmBuffer, {
      env: {
        // Add any required imports here if needed
      },
    });

    this.wasm = {
      instance: wasmModule.instance,
      exports: wasmModule.instance.exports as any,
    };

    // Create EVM instance
    this.handle = this.wasm.exports.evm_create();
    if (this.handle === 0) {
      throw new Error("Failed to create EVM instance");
    }
  }

  private async loadWasm(wasmPath: string): Promise<ArrayBuffer> {
    // Node.js environment
    if (typeof process !== "undefined" && process.versions?.node) {
      const fs = await import("fs/promises");
      const buffer = await fs.readFile(wasmPath);
      return buffer.buffer.slice(
        buffer.byteOffset,
        buffer.byteOffset + buffer.byteLength,
      ) as ArrayBuffer;
    }

    // Browser environment
    if (typeof fetch !== "undefined") {
      const response = await fetch(wasmPath);
      return await response.arrayBuffer();
    }

    throw new Error("Unsupported environment for loading WASM");
  }

  async ready(): Promise<void> {
    await this.readyPromise;
  }

  private getMemory(): Uint8Array {
    if (!this.wasm) throw new Error("WASM not initialized");
    return new Uint8Array(this.wasm.exports.memory.buffer);
  }

  private allocateAndCopy(data: Uint8Array): number {
    const memory = this.getMemory();
    // Simple allocation strategy: find space at end of memory
    // In production, you'd use a proper allocator
    const ptr = memory.length - data.length;
    memory.set(data, ptr);
    return ptr;
  }

  async setBytecode(bytecode: Bytes): Promise<void> {
    await this.ready();
    if (!this.wasm) throw new Error("WASM not initialized");

    const ptr = this.allocateAndCopy(bytecode);
    const result = this.wasm.exports.evm_set_bytecode(
      this.handle,
      ptr,
      bytecode.length,
    );
    if (result === 0) {
      throw new Error("Failed to set bytecode");
    }
  }

  async setExecutionContext(ctx: ExecutionContext): Promise<void> {
    await this.ready();
    if (!this.wasm) throw new Error("WASM not initialized");

    const callerPtr = this.allocateAndCopy(ctx.caller);
    const addressPtr = this.allocateAndCopy(ctx.address);
    const valueBytes = bigintToU256(ctx.value);
    const valuePtr = this.allocateAndCopy(valueBytes);
    const calldataPtr =
      ctx.calldata.length > 0 ? this.allocateAndCopy(ctx.calldata) : 0;

    const result = this.wasm.exports.evm_set_execution_context(
      this.handle,
      ctx.gas,
      callerPtr,
      addressPtr,
      valuePtr,
      calldataPtr,
      ctx.calldata.length,
    );

    if (result === 0) {
      throw new Error("Failed to set execution context");
    }
  }

  async setBlockchainContext(ctx: BlockchainContext): Promise<void> {
    await this.ready();
    if (!this.wasm) throw new Error("WASM not initialized");

    const coinbasePtr = this.allocateAndCopy(ctx.blockCoinbase);

    this.wasm.exports.evm_set_blockchain_context(
      this.handle,
      ctx.chainId,
      ctx.blockNumber,
      ctx.blockTimestamp,
      coinbasePtr,
      ctx.blockGasLimit,
    );
  }

  async execute(): Promise<ExecutionResult> {
    await this.ready();
    if (!this.wasm) throw new Error("WASM not initialized");

    const result = this.wasm.exports.evm_execute(this.handle);
    const success = this.wasm.exports.evm_is_success(this.handle) !== 0;
    const gasRemaining = this.wasm.exports.evm_get_gas_remaining(this.handle);
    const gasUsed = this.wasm.exports.evm_get_gas_used(this.handle);

    // Get output
    const outputLen = this.wasm.exports.evm_get_output_len(this.handle);
    const output = new Uint8Array(outputLen);
    if (outputLen > 0) {
      const outputPtr = this.allocateAndCopy(new Uint8Array(outputLen));
      this.wasm.exports.evm_get_output(this.handle, outputPtr, outputLen);
      output.set(this.getMemory().slice(outputPtr, outputPtr + outputLen));
    }

    return {
      success,
      gasRemaining,
      gasUsed,
      output,
    };
  }

  async setStorage(address: Address, slot: U256, value: U256): Promise<void> {
    await this.ready();
    if (!this.wasm) throw new Error("WASM not initialized");

    const addressPtr = this.allocateAndCopy(address);
    const slotPtr = this.allocateAndCopy(slot);
    const valuePtr = this.allocateAndCopy(value);

    const result = this.wasm.exports.evm_set_storage(
      this.handle,
      addressPtr,
      slotPtr,
      valuePtr,
    );
    if (result === 0) {
      throw new Error("Failed to set storage");
    }
  }

  async getStorage(address: Address, slot: U256): Promise<U256> {
    await this.ready();
    if (!this.wasm) throw new Error("WASM not initialized");

    const addressPtr = this.allocateAndCopy(address);
    const slotPtr = this.allocateAndCopy(slot);
    const valueBytes = new Uint8Array(32);
    const valuePtr = this.allocateAndCopy(valueBytes);

    const result = this.wasm.exports.evm_get_storage(
      this.handle,
      addressPtr,
      slotPtr,
      valuePtr,
    );
    if (result === 0) {
      throw new Error("Failed to get storage");
    }

    return this.getMemory().slice(valuePtr, valuePtr + 32);
  }

  async setBalance(address: Address, balance: bigint): Promise<void> {
    await this.ready();
    if (!this.wasm) throw new Error("WASM not initialized");

    const addressPtr = this.allocateAndCopy(address);
    const balanceBytes = bigintToU256(balance);
    const balancePtr = this.allocateAndCopy(balanceBytes);

    const result = this.wasm.exports.evm_set_balance(
      this.handle,
      addressPtr,
      balancePtr,
    );
    if (result === 0) {
      throw new Error("Failed to set balance");
    }
  }

  async setCode(address: Address, code: Bytes): Promise<void> {
    await this.ready();
    if (!this.wasm) throw new Error("WASM not initialized");

    const addressPtr = this.allocateAndCopy(address);
    const codePtr = code.length > 0 ? this.allocateAndCopy(code) : 0;

    const result = this.wasm.exports.evm_set_code(
      this.handle,
      addressPtr,
      codePtr,
      code.length,
    );
    if (result === 0) {
      throw new Error("Failed to set code");
    }
  }

  async destroy(): Promise<void> {
    await this.ready();
    if (this.wasm && this.handle !== 0) {
      this.wasm.exports.evm_destroy(this.handle);
      this.handle = 0;
    }
  }
}

/**
 * Create a new EVM instance.
 * Returns synchronously, but all methods await WASM initialization.
 *
 * @param wasmPath - Path to the WASM file (e.g., './wasm/guillotine_mini.wasm')
 */
export function createEvm(wasmPath: string): Evm {
  return new EvmImpl(wasmPath);
}
