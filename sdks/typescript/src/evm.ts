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
  StateInterface,
  StateChanges,
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
    evm_create: (hardforkName: number, hardforkLen: number, logLevel: number) => number;
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
    // Async protocol FFI functions
    evm_call_ffi: (handle: number, requestOut: number) => number;
    evm_continue_ffi: (
      handle: number,
      continueType: number,
      dataPtr: number,
      dataLen: number,
      requestOut: number,
    ) => number;
    evm_get_state_changes: (
      handle: number,
      buffer: number,
      bufferLen: number,
    ) => number;
    evm_enable_storage_injector: (handle: number) => number;
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
  private stateInterface?: StateInterface;

  constructor(wasmModule: WebAssembly.Module, options?: EvmOptions) {
    this.stateInterface = options?.stateInterface;
    this.readyPromise = this.initialize(wasmModule, options);
  }

  private async initialize(wasmModule: WebAssembly.Module, options?: EvmOptions): Promise<void> {
    // Store custom handlers for callbacks
    const opcodeOverrides = options?.opcodeOverrides || [];
    const precompileOverrides = options?.precompileOverrides || [];

    // Store references to prevent garbage collection
    opcodeOverrides.forEach(o => this.opcodeHandlers.set(o.opcode, o.handler));
    precompileOverrides.forEach(o => {
      // Convert address hex string to bytes for storage key
      const addressBytes = addressToBytes(o.address);
      const key = Array.from(addressBytes).join(',');
      this.precompileHandlers.set(key, o.execute);
    });

    // Map log level string to numeric value
    const logLevelMap: Record<string, number> = {
      'none': 0,
      'error': 1,
      'warn': 2,
      'info': 3,
      'debug': 4,
    };
    const logLevel = logLevelMap[options?.logLevel || 'none'];

    // Create WASM imports with callback functions
    const imports = {
      wasi_snapshot_preview1: {
        fd_write: () => 0,
        fd_close: () => 0,
        fd_seek: () => 0,
        fd_read: () => 0,
        fd_pwrite: () => 0,
        fd_pread: () => 0,
        fd_fdstat_get: () => 0,
        fd_filestat_get: () => 0,
        fd_prestat_get: () => 0,
        fd_prestat_dir_name: () => 0,
        path_open: () => 0,
        proc_exit: () => {},
        environ_sizes_get: () => 0,
        environ_get: () => 0,
        clock_time_get: () => 0,
        random_get: () => 0,
      },
      env: {
        // BLS12-381 curve operations (stubs for now - not called in basic tests)
        bls12_381_pairing: () => 0,
        bls12_381_g1_add: () => 0,
        bls12_381_g1_mul: () => 0,
        bls12_381_g1_multiexp: () => 0,
        bls12_381_g2_add: () => 0,
        bls12_381_g2_mul: () => 0,
        bls12_381_g2_multiexp: () => 0,
        bls12_381_map_fp_to_g1: () => 0,
        bls12_381_map_fp2_to_g2: () => 0,
        // BN254 curve operations (alt_bn128)
        bn254_ecpairing: () => 0,
        bn254_ecadd: () => 0,
        bn254_ecmul: () => 0,

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
            const inputBytes = memory.slice(inputPtr, inputPtr + inputLen);

            // Find matching precompile handler
            const addrKey = Array.from(address).join(',');
            const handler = this.precompileHandlers.get(addrKey);
            if (!handler) return 0; // No custom handler for this address

            // Convert input bytes to hex string for handler
            const inputHex = bytesToHex(inputBytes);

            // Execute handler (note: must be synchronous)
            const resultPromise = handler(inputHex, gasLimit);

            // Check if handler returned a Promise (async)
            if (resultPromise instanceof Promise) {
              console.error('Async precompile handlers are not supported in callback pattern');
              return 0;
            }

            // Handler is synchronous
            const result = resultPromise as any;

            // Convert output hex string to bytes and write to WASM memory
            if (result.output && result.output.length > 0) {
              const outputBytes = hexToBytes(result.output);

              // Allocate memory for output (simplified - in production use proper allocator)
              const outputPtr = memory.length - outputBytes.length;
              memory.set(outputBytes, outputPtr);

              // Write output pointer and length
              const view = new DataView(memory.buffer);
              view.setUint32(outputLenPtr, outputBytes.length, true);
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

    // Create EVM instance with hardfork and log level
    const hardfork = options?.hardfork || '';
    const hardforkBytes = new TextEncoder().encode(hardfork);
    const hardforkPtr = hardforkBytes.length > 0 ? this.allocateAndCopy(hardforkBytes) : 0;

    this.handle = this.wasm.exports.evm_create(hardforkPtr, hardforkBytes.length, logLevel);
    if (this.handle === 0) {
      throw new Error("Failed to create EVM instance");
    }

    // Enable storage injector if state interface is provided
    if (options?.stateInterface) {
      const result = this.wasm.exports.evm_enable_storage_injector(this.handle);
      if (result === 0) {
        throw new Error("Failed to enable storage injector");
      }
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

    const bytecodeBytes = hexToBytes(bytecode);
    const ptr = this.allocateAndCopy(bytecodeBytes);
    const result = this.wasm.exports.evm_set_bytecode(
      this.handle,
      ptr,
      bytecodeBytes.length,
    );
    if (result === 0) {
      throw new Error("Failed to set bytecode");
    }
  }

  async setExecutionContext(ctx: ExecutionContext): Promise<void> {
    await this.ready();
    if (!this.wasm) throw new Error("WASM not initialized");

    const callerBytes = addressToBytes(ctx.caller);
    const addressBytes = addressToBytes(ctx.address);
    const valueBytes = bigintToU256(ctx.value);
    const calldataBytes = hexToBytes(ctx.calldata);

    console.log(`[Debug] setExecutionContext: address=${ctx.address}, addressBytes=${Array.from(addressBytes)}`);

    const callerPtr = this.allocateAndCopy(callerBytes);
    const addressPtr = this.allocateAndCopy(addressBytes);
    const valuePtr = this.allocateAndCopy(valueBytes);
    const calldataPtr = calldataBytes.length > 0 ? this.allocateAndCopy(calldataBytes) : 0;

    const result = this.wasm.exports.evm_set_execution_context(
      this.handle,
      ctx.gas,
      callerPtr,
      addressPtr,
      valuePtr,
      calldataPtr,
      calldataBytes.length,
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

    const coinbaseBytes = addressToBytes(ctx.blockCoinbase);
    const coinbasePtr = this.allocateAndCopy(coinbaseBytes);

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

    // Extract unique addresses and convert to bytes
    const addresses: Uint8Array[] = [];
    for (const entry of accessList) {
      addresses.push(addressToBytes(entry.address));
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

    // Extract storage keys with addresses and convert to bytes
    const storageKeys: Array<{ address: Uint8Array; slot: Uint8Array }> = [];
    for (const entry of accessList) {
      for (const slot of entry.storageKeys) {
        storageKeys.push({
          address: addressToBytes(entry.address),
          slot: hexToBytes(slot)
        });
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

    // Convert hex strings to bytes and pack into single buffer (32 bytes each)
    const packedHashes = new Uint8Array(hashes.length * 32);
    for (let i = 0; i < hashes.length; i++) {
      const hashBytes = hexToBytes(hashes[i]);
      if (hashBytes.length !== 32) {
        throw new Error(`Blob hash ${i} must be 32 bytes`);
      }
      packedHashes.set(hashBytes, i * 32);
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

  /**
   * Execute with yield handling for async state interface
   * INTERNAL: Handles all the yield/continue logic
   */
  private async executeWithYieldHandling(): Promise<ExecutionResult> {
    if (!this.wasm) throw new Error("WASM not initialized");
    if (!this.stateInterface) {
      throw new Error("StateInterface required for async execution");
    }

    // Output types
    const OutputType = {
      Result: 0,
      NeedStorage: 1,
      NeedBalance: 2,
      NeedCode: 3,
      NeedNonce: 4,
      ReadyToCommit: 5,
      Error: 255,
    };

    // Continue types
    const ContinueType = {
      Storage: 1,
      Balance: 2,
      Code: 3,
      Nonce: 4,
      AfterCommit: 5,
    };

    // Allocate request buffer in WASM memory
    let memory = this.getMemory();
    const requestPtr = memory.length - 256; // Reserve 256 bytes at end of memory

    // Start execution
    console.log(`[Debug] Calling evm_call_ffi with handle=${this.handle}, requestPtr=${requestPtr}`);
    const startResult = this.wasm.exports.evm_call_ffi(this.handle, requestPtr);
    console.log(`[Debug] evm_call_ffi returned: ${startResult}`);
    if (!startResult) {
      throw new Error("Failed to start async execution");
    }

    // Read from memory (need to refresh since it may have grown)
    memory = this.getMemory();
    let outputType = memory[requestPtr];

    const reqAddr1 = memory[requestPtr + 1];
    const reqAddr2 = memory[requestPtr + 2];
    console.log(`[Debug] Initial outputType: ${outputType}, requestPtr: ${requestPtr}, address[0:2]=${reqAddr1.toString(16)}${reqAddr2.toString(16)}`);

    // Yield loop - handle async requests until done
    while (outputType !== OutputType.Result) {
      console.log(`[Debug] Handling outputType: ${outputType}`);
      if (outputType === OutputType.NeedStorage) {
        // Request data is in WASM memory at requestPtr
        memory = this.getMemory();
        console.log(`[Debug] Request buffer bytes:`, Array.from(memory.slice(requestPtr, requestPtr + 25)));
        const address = bytesToHex(memory.slice(requestPtr + 1, requestPtr + 21));
        const slot = bytesToHex(memory.slice(requestPtr + 21, requestPtr + 53));

        console.log(`[Debug] NeedStorage: address=${address}, slot=${slot}`);
        const value = await this.stateInterface.getStorage(address, slot);

        // Pack continue data: address(20) + slot(32) + value(32) = 84 bytes
        const continueData = new Uint8Array(84);
        continueData.set(memory.slice(requestPtr + 1, requestPtr + 21), 0); // address
        continueData.set(memory.slice(requestPtr + 21, requestPtr + 53), 20); // slot
        continueData.set(hexToBytes(value), 52); // value

        const continuePtr = this.allocateAndCopy(continueData);
        const continueResult = this.wasm.exports.evm_continue_ffi(
          this.handle,
          ContinueType.Storage,
          continuePtr,
          84,
          requestPtr,
        );

        if (!continueResult) {
          throw new Error("Failed to continue after storage");
        }

        // Refresh memory and outputType
        memory = this.getMemory();
        outputType = memory[requestPtr];
      } else if (outputType === OutputType.NeedBalance) {
        memory = this.getMemory();
        const address = bytesToHex(memory.slice(requestPtr + 1, requestPtr + 21));
        const balance = await this.stateInterface.getBalance(address);

        // Pack continue data: address(20) + balance(32) = 52 bytes
        const continueData = new Uint8Array(52);
        continueData.set(memory.slice(requestPtr + 1, requestPtr + 21), 0); // address
        continueData.set(hexToBytes(bigintToU256(balance)), 20); // balance

        const continuePtr = this.allocateAndCopy(continueData);
        const continueResult = this.wasm.exports.evm_continue_ffi(
          this.handle,
          ContinueType.Balance,
          continuePtr,
          52,
          requestPtr,
        );

        if (!continueResult) {
          throw new Error("Failed to continue after balance");
        }

        memory = this.getMemory();
        outputType = memory[requestPtr];
      } else if (outputType === OutputType.ReadyToCommit) {
        // Read JSON directly from AsyncRequest struct
        // Layout: output_type(1) + address(20) + slot(32) + json_len(4) + padding(3) + json_data
        // (struct is packed with alignment)
        memory = this.getMemory();
        const jsonLenOffset = requestPtr + 1 + 20 + 32;
        // Skip padding - find the '{' character
        let jsonDataOffset = jsonLenOffset + 4;
        while (jsonDataOffset < requestPtr + 1000 && memory[jsonDataOffset] !== 0x7B) { // 0x7B = '{'
          jsonDataOffset++;
        }

        const jsonLen = new DataView(memory.buffer, memory.byteOffset + jsonLenOffset, 4).getUint32(0, false);

        const changesJson = new TextDecoder().decode(
          memory.slice(jsonDataOffset, jsonDataOffset + jsonLen),
        );

        console.log(`[Debug] ReadyToCommit: json_len=${jsonLen}, JSON=${changesJson}`);

        if (jsonLen === 0 || !changesJson) {
          // No changes - continue without committing
          console.log("[Debug] No state changes to commit");
          const continueResult = this.wasm.exports.evm_continue_ffi(
            this.handle,
            ContinueType.AfterCommit,
            0,
            0,
            requestPtr,
          );

          if (!continueResult) {
            throw new Error("Failed to continue after empty commit");
          }

          memory = this.getMemory();
          outputType = memory[requestPtr];
          continue;
        }

        const changes: StateChanges = JSON.parse(changesJson);

        // Commit changes
        await this.stateInterface.commitChanges(changes);

        // Continue after commit
        const continueResult = this.wasm.exports.evm_continue_ffi(
          this.handle,
          ContinueType.AfterCommit,
          0,
          0,
          requestPtr,
        );

        if (!continueResult) {
          throw new Error("Failed to continue after commit");
        }

        memory = this.getMemory();
        outputType = memory[requestPtr];
      } else if (outputType === OutputType.Error) {
        throw new Error("EVM execution error during async execution");
      } else {
        throw new Error(`Unknown output type: ${outputType}`);
      }
    }

    // Done - return result
    const success = this.wasm.exports.evm_is_success(this.handle) !== 0;
    const gasRemaining = this.wasm.exports.evm_get_gas_remaining(this.handle);
    const gasUsed = this.wasm.exports.evm_get_gas_used(this.handle);

    // Get output
    const outputLen = this.wasm.exports.evm_get_output_len(this.handle);
    const outputBytes = new Uint8Array(outputLen);
    if (outputLen > 0) {
      const outputPtr = this.allocateAndCopy(new Uint8Array(outputLen));
      this.wasm.exports.evm_get_output(this.handle, outputPtr, outputLen);
      outputBytes.set(memory.slice(outputPtr, outputPtr + outputLen));
    }

    return {
      success,
      gasRemaining,
      gasUsed,
      output: bytesToHex(outputBytes),
    };
  }

  async execute(): Promise<ExecutionResult> {
    await this.ready();
    if (!this.wasm) throw new Error("WASM not initialized");

    // If stateInterface is provided, use async protocol
    if (this.stateInterface) {
      return this.executeWithYieldHandling();
    }

    // Otherwise, use regular sync execution
    const result = this.wasm.exports.evm_execute(this.handle);
    const success = this.wasm.exports.evm_is_success(this.handle) !== 0;
    const gasRemaining = this.wasm.exports.evm_get_gas_remaining(this.handle);
    const gasUsed = this.wasm.exports.evm_get_gas_used(this.handle);

    // Get output
    const outputLen = this.wasm.exports.evm_get_output_len(this.handle);
    const outputBytes = new Uint8Array(outputLen);
    if (outputLen > 0) {
      const outputPtr = this.allocateAndCopy(new Uint8Array(outputLen));
      this.wasm.exports.evm_get_output(this.handle, outputPtr, outputLen);
      outputBytes.set(this.getMemory().slice(outputPtr, outputPtr + outputLen));
    }

    return {
      success,
      gasRemaining,
      gasUsed,
      output: bytesToHex(outputBytes),
    };
  }

  async setStorage(address: Address, slot: U256, value: U256): Promise<void> {
    await this.ready();
    if (!this.wasm) throw new Error("WASM not initialized");

    const addressBytes = addressToBytes(address);
    const slotBytes = hexToBytes(slot);
    const valueBytes = hexToBytes(value);

    const addressPtr = this.allocateAndCopy(addressBytes);
    const slotPtr = this.allocateAndCopy(slotBytes);
    const valuePtr = this.allocateAndCopy(valueBytes);

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

    const addressBytes = addressToBytes(address);
    const slotBytes = hexToBytes(slot);
    const valueBytes = new Uint8Array(32);

    const addressPtr = this.allocateAndCopy(addressBytes);
    const slotPtr = this.allocateAndCopy(slotBytes);
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

    const storageBytes = this.getMemory().slice(valuePtr, valuePtr + 32);
    return bytesToHex(storageBytes);
  }

  async setBalance(address: Address, balance: bigint): Promise<void> {
    await this.ready();
    if (!this.wasm) throw new Error("WASM not initialized");

    const addressBytes = addressToBytes(address);
    const balanceBytes = bigintToU256(balance);

    const addressPtr = this.allocateAndCopy(addressBytes);
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

    const addressBytes = addressToBytes(address);
    const codeBytes = hexToBytes(code);

    const addressPtr = this.allocateAndCopy(addressBytes);
    const codePtr = codeBytes.length > 0 ? this.allocateAndCopy(codeBytes) : 0;

    const result = this.wasm.exports.evm_set_code(
      this.handle,
      addressPtr,
      codePtr,
      codeBytes.length,
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
