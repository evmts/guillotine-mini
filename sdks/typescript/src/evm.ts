import type {
  Evm,
  ExecutionContext,
  BlockchainContext,
  ExecutionResult,
  Address,
  U256,
  Bytes,
  EvmOptions,
  AccessListEntry,
  OpcodeHandler,
  PrecompileHandler,
} from "./types.js";
import {
  bigintToU256,
  hexToBytes,
  bytesToHex,
  addressToBytes,
  isValidAddress,
  isValidHex,
} from "./utils.js";

/**
 * WASM module interface
 */
interface WasmModule {
  instance: WebAssembly.Instance;
  exports: {
    memory: WebAssembly.Memory;
    evm_create: (hardforkName: number, hardforkLen: number) => number;
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
      chainId: number,
      blockNumber: bigint,
      blockTimestamp: bigint,
      blockDifficulty: number,
      blockPrevrandao: number,
      blockCoinbase: number,
      blockGasLimit: bigint,
      blockBaseFee: number,
      blobBaseFee: number,
    ) => void;
    evm_set_access_list_addresses: (
      handle: number,
      addresses: number,
      count: number,
    ) => number;
    evm_set_access_list_storage_keys: (
      handle: number,
      addresses: number,
      slots: number,
      count: number,
    ) => number;
    evm_set_blob_hashes: (
      handle: number,
      hashes: number,
      count: number,
    ) => number;
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
  // Store references to callback functions to prevent garbage collection
  private opcodeHandlers: Map<number, any> = new Map();
  private precompileHandlers: Map<string, any> = new Map();

  constructor(wasmModule: WebAssembly.Module, options?: EvmOptions) {
    this.readyPromise = this.initialize(wasmModule, options);
  }

  private async initialize(wasmModule: WebAssembly.Module, options?: EvmOptions): Promise<void> {
    // Store custom handlers for callbacks
    const opcodeOverrides = options?.opcodeOverrides || [];
    const precompileOverrides = options?.precompileOverrides || [];

    // Store references to prevent garbage collection
    opcodeOverrides.forEach(o => this.opcodeHandlers.set(o.opcode, o.handler));
    precompileOverrides.forEach(o => {
      const key = Array.from(o.address).join(',');
      this.precompileHandlers.set(key, o.execute);
    });

    // Create WASM imports with callback functions
    const imports = {
      env: {
        // Called BY WASM to execute custom opcode handlers
        js_opcode_callback: (opcode: number, framePtr: number): number => {
          const handler = this.opcodeHandlers.get(opcode);
          if (!handler) return 0; // No custom handler for this opcode

          try {
            const result = handler(framePtr);
            return result ? 1 : 0;
          } catch (e) {
            console.error(`Opcode 0x${opcode.toString(16)} handler error:`, e);
            return 0;
          }
        },

        // Called BY WASM to execute custom precompile handlers
        js_precompile_callback: (
          addressPtr: number,
          inputPtr: number,
          inputLen: number,
          gasLimit: bigint,
          outputLenPtr: number,
          outputPtrPtr: number,
          gasUsedPtr: number
        ): number => {
          if (!this.wasm) return 0;

          try {
            const memory = new Uint8Array(this.wasm.exports.memory.buffer);
            const address = memory.slice(addressPtr, addressPtr + 20);
            const input = memory.slice(inputPtr, inputPtr + inputLen);

            // Find matching precompile handler
            const addrKey = Array.from(address).join(',');
            const handler = this.precompileHandlers.get(addrKey);
            if (!handler) return 0; // No custom handler for this address

            // Execute handler (note: must be synchronous)
            const resultPromise = handler(input, gasLimit);

            // Check if handler returned a Promise (async)
            if (resultPromise instanceof Promise) {
              console.error('Async precompile handlers are not supported in callback pattern');
              return 0;
            }

            // Handler is synchronous
            const result = resultPromise as any;

            // Write output to WASM memory
            if (result.output && result.output.length > 0) {
              // Allocate memory for output (simplified - in production use proper allocator)
              const outputPtr = memory.length - result.output.length;
              memory.set(result.output, outputPtr);

              // Write output pointer and length
              const view = new DataView(memory.buffer);
              view.setUint32(outputLenPtr, result.output.length, true);
              view.setUint32(outputPtrPtr, outputPtr, true);
            } else {
              const view = new DataView(memory.buffer);
              view.setUint32(outputLenPtr, 0, true);
            }

            // Write gas used
            const view = new DataView(memory.buffer);
            view.setBigUint64(gasUsedPtr, result.gasUsed, true);

            return result.success ? 1 : 0;
          } catch (e) {
            console.error('Precompile handler error:', e);
            return 0;
          }
        },
      },
    };

    // Instantiate WASM module with callback imports
    const instance = await WebAssembly.instantiate(wasmModule, imports);

    this.wasm = {
      instance,
      exports: instance.exports as any,
    };

    // Create EVM instance with hardfork
    const hardfork = options?.hardfork || '';
    const hardforkBytes = new TextEncoder().encode(hardfork);
    const hardforkPtr = hardforkBytes.length > 0 ? this.allocateAndCopy(hardforkBytes) : 0;

    this.handle = this.wasm.exports.evm_create(hardforkPtr, hardforkBytes.length);
    if (this.handle === 0) {
      throw new Error("Failed to create EVM instance");
    }
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

    const chainIdBytes = bigintToU256(ctx.chainId);
    const chainIdPtr = this.allocateAndCopy(chainIdBytes);

    const blockDifficultyBytes = bigintToU256(ctx.blockDifficulty);
    const blockDifficultyPtr = this.allocateAndCopy(blockDifficultyBytes);

    const blockPrevrandaoBytes = bigintToU256(ctx.blockPrevrandao);
    const blockPrevrandaoPtr = this.allocateAndCopy(blockPrevrandaoBytes);

    const coinbasePtr = this.allocateAndCopy(ctx.blockCoinbase);

    const blockBaseFeeBytes = bigintToU256(ctx.blockBaseFee);
    const blockBaseFeePtr = this.allocateAndCopy(blockBaseFeeBytes);

    const blobBaseFeeBytes = bigintToU256(ctx.blobBaseFee);
    const blobBaseFeePtr = this.allocateAndCopy(blobBaseFeeBytes);

    this.wasm.exports.evm_set_blockchain_context(
      this.handle,
      chainIdPtr,
      ctx.blockNumber,
      ctx.blockTimestamp,
      blockDifficultyPtr,
      blockPrevrandaoPtr,
      coinbasePtr,
      ctx.blockGasLimit,
      blockBaseFeePtr,
      blobBaseFeePtr,
    );
  }

  async setAccessList(accessList: AccessListEntry[]): Promise<void> {
    await this.ready();
    if (!this.wasm) throw new Error("WASM not initialized");

    // Extract unique addresses
    const addresses: Uint8Array[] = [];
    for (const entry of accessList) {
      addresses.push(entry.address);
    }

    // Pack addresses into single buffer (20 bytes each)
    if (addresses.length > 0) {
      const packedAddresses = new Uint8Array(addresses.length * 20);
      for (let i = 0; i < addresses.length; i++) {
        packedAddresses.set(addresses[i], i * 20);
      }
      const addressesPtr = this.allocateAndCopy(packedAddresses);
      const result = this.wasm.exports.evm_set_access_list_addresses(
        this.handle,
        addressesPtr,
        addresses.length,
      );
      if (result === 0) {
        throw new Error("Failed to set access list addresses");
      }
    }

    // Extract storage keys with addresses
    const storageKeys: Array<{ address: Uint8Array; slot: U256 }> = [];
    for (const entry of accessList) {
      for (const slot of entry.storageKeys) {
        storageKeys.push({ address: entry.address, slot });
      }
    }

    // Pack storage keys (20 bytes address + 32 bytes slot each)
    if (storageKeys.length > 0) {
      const packedAddresses = new Uint8Array(storageKeys.length * 20);
      const packedSlots = new Uint8Array(storageKeys.length * 32);

      for (let i = 0; i < storageKeys.length; i++) {
        packedAddresses.set(storageKeys[i].address, i * 20);
        packedSlots.set(storageKeys[i].slot, i * 32);
      }

      const addressesPtr = this.allocateAndCopy(packedAddresses);
      const slotsPtr = this.allocateAndCopy(packedSlots);

      const result = this.wasm.exports.evm_set_access_list_storage_keys(
        this.handle,
        addressesPtr,
        slotsPtr,
        storageKeys.length,
      );
      if (result === 0) {
        throw new Error("Failed to set access list storage keys");
      }
    }
  }

  async setBlobHashes(hashes: Bytes[]): Promise<void> {
    await this.ready();
    if (!this.wasm) throw new Error("WASM not initialized");

    if (hashes.length === 0) {
      // Clear blob hashes
      this.wasm.exports.evm_set_blob_hashes(this.handle, 0, 0);
      return;
    }

    // Pack hashes into single buffer (32 bytes each)
    const packedHashes = new Uint8Array(hashes.length * 32);
    for (let i = 0; i < hashes.length; i++) {
      if (hashes[i].length !== 32) {
        throw new Error(`Blob hash ${i} must be 32 bytes`);
      }
      packedHashes.set(hashes[i], i * 32);
    }

    const hashesPtr = this.allocateAndCopy(packedHashes);
    const result = this.wasm.exports.evm_set_blob_hashes(
      this.handle,
      hashesPtr,
      hashes.length,
    );
    if (result === 0) {
      throw new Error("Failed to set blob hashes");
    }
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
      this.opcodeHandlers.clear();
      this.precompileHandlers.clear();
    }
  }
}

/**
 * Create a new EVM instance.
 * Returns synchronously, but all methods await WASM initialization.
 *
 * @param wasmModule - WebAssembly module to use. Import from the bundled WASM.
 * @param options - Optional configuration (hardfork, etc.)
 */
export function createEvm(wasmModule: WebAssembly.Module, options?: EvmOptions): Evm {
  return new EvmImpl(wasmModule, options);
}
