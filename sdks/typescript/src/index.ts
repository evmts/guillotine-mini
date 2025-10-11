import { createEvm as createEvmImpl } from './evm.js';
import { wasmModule } from './wasm.js';

export type {
  Evm,
  ExecutionContext,
  BlockchainContext,
  ExecutionResult,
  Address,
  U256,
  Bytes,
  Hardfork,
  AccessListEntry,
  EvmOptions,
  LogLevel,
} from './types.js';
export {
  hexToBytes,
  bytesToHex,
  bigintToU256,
  u256ToBigint,
  addressToBytes,
  bytesToAddress,
} from './utils.js';

/**
 * Create a new EVM instance with the bundled WASM module.
 *
 * @param options - Optional configuration (hardfork, etc.)
 * @returns EVM instance
 *
 * Works in both Node.js and browser environments.
 */
export async function createEvm(options?: import('./types.js').EvmOptions) {
  const module = await wasmModule();
  return createEvmImpl(module, options);
}
