/**
 * `@tevm/guillotine-mini` — Universal zero-dependency TypeScript/WASM SDK
 * for the Guillotine Mini Ethereum Virtual Machine.
 */

export const SDK_VERSION = "0.2.0";

export {
  ASYNC_CONTINUE,
  ASYNC_OUTPUT,
  ASYNC_REQUEST,
  WasmMemoryBridge,
  bytesToBigInt,
  bytesToHex,
  decodeRevertBytes,
  decodeUtf8,
  encodeU64Be,
  encodeUtf8,
  hexToBytes,
  toAddressBytes,
  toBytes,
  toWordBytes,
  type BytesInput,
  type DecodedRevert,
  type EvmLog,
  type EvmWasmExports,
  type Hex,
  type StorageChange,
} from "./abi.ts";

export {
  WASI_ERRNO,
  WasiExitError,
  createWasiShim,
  type WasiShim,
  type WasiShimOptions,
} from "./wasi-shim.ts";

export {
  PRECOMPILE_ADDRESSES,
  createPrecompileImports,
  instantiatePrecompile,
  instantiatePrecompiles,
  precompileFileName,
  type PrecompileAddress,
  type PrecompileExports,
  type PrecompileHostImports,
  type PrecompileModuleInput,
} from "./precompiles.ts";

export {
  createCachedStateProvider,
  createJsonRpcProvider,
  driveAsyncExecution,
  normalizeBlockTag,
  type AsyncExecutionOutcome,
  type CachedStateProvider,
  type DriveAsyncOptions,
  type JsonRpcProviderOptions,
  type RpcBlockHeader,
  type RpcBlockTag,
  type StateProvider,
} from "./fork.ts";

export {
  GuillotineEvm,
  createEvm,
  type AccessListEntry,
  type BlockContextOptions,
  type CallOptions,
  type CallResult,
  type CallTraceOptions,
  type CallTraceResult,
  type CreateAccessListResult,
  type CreateEvmOptions,
  type Eip3155TraceResult,
  type FlamegraphResult,
  type HardforkName,
  type TraceOptions,
  type WasmSource,
} from "./evm.ts";
