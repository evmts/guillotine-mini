/**
 * Ergonomic universal TypeScript/WASM SDK for Guillotine Mini.
 * Zero Node.js dependencies; supports monolithic and modular WASM reactors.
 */
import {
  WasmMemoryBridge, bytesToBigInt, bytesToHex, decodeRevertBytes, encodeUtf8,
  toAddressBytes, toBytes, toWordBytes,
  type BytesInput, type DecodedRevert, type EvmLog, type EvmWasmExports, type Hex, type StorageChange,
} from "./abi.ts";
import {
  createCachedStateProvider, createJsonRpcProvider, driveAsyncExecution, normalizeBlockTag,
  type RpcBlockTag, type StateProvider,
} from "./fork.ts";
import {
  compileWasmModule, createPrecompileImports, instantiatePrecompiles,
  type PrecompileModuleInput, type WasmSource,
} from "./precompiles.ts";
import { createWasiShim, type WasiShimOptions } from "./wasi-shim.ts";

export type { WasmSource };
export type HardforkName =
  | "frontier" | "homestead" | "tangerine_whistle" | "spurious_dragon" | "byzantium" | "constantinople"
  | "petersburg" | "istanbul" | "berlin" | "london" | "merge" | "paris" | "shanghai"
  | "cancun" | "prague" | "osaka" | "amsterdam" | (string & {});

export interface BlockContextOptions {
  readonly chainId: bigint | number; readonly blockNumber: bigint | number; readonly timestamp: bigint | number;
  readonly difficulty: bigint | number; readonly prevRandao: bigint | number | BytesInput; readonly coinbase: BytesInput;
  readonly gasLimit: bigint | number; readonly baseFee: bigint | number; readonly blobBaseFee: bigint | number;
}
export interface AccessListEntry { readonly address: BytesInput; readonly storageKeys?: ReadonlyArray<BytesInput>; }
export interface CallOptions {
  readonly bytecode?: BytesInput; readonly to?: BytesInput; readonly caller?: BytesInput; readonly origin?: BytesInput;
  readonly value?: bigint | number; readonly data?: BytesInput; readonly gas?: bigint | number;
  readonly gasPrice?: bigint | number; readonly accessList?: ReadonlyArray<AccessListEntry>;
  readonly blobHashes?: ReadonlyArray<BytesInput>; readonly blockTag?: RpcBlockTag;
}
export interface CallResult {
  readonly success: boolean; readonly output: Uint8Array; readonly outputHex: Hex;
  readonly gasUsed: bigint; readonly gasRemaining: bigint; readonly gasRefund: bigint;
  readonly logs: ReadonlyArray<EvmLog>; readonly storageChanges: ReadonlyArray<StorageChange>;
  readonly stateChangesJson?: string | null;
}
export interface TraceOptions { readonly enableMemory?: boolean; readonly disableStack?: boolean; readonly disableStorage?: boolean; readonly enableReturnData?: boolean; }
export interface Eip3155TraceResult { readonly result: CallResult; readonly rawJsonl: string; readonly steps: ReadonlyArray<Record<string, unknown>>; readonly summary: Record<string, unknown> | null; }
export interface CallTraceOptions { readonly onlyTopCall?: boolean; readonly withLog?: boolean; }
export interface CallTraceResult { readonly result: CallResult; readonly callFrame: Record<string, unknown> | null; }
export interface CreateAccessListResult { readonly result: CallResult; readonly accessList: ReadonlyArray<{ readonly address: Hex; readonly storageKeys: ReadonlyArray<Hex> }>; }
export interface FlamegraphResult { readonly result: CallResult; readonly svg: string; readonly folded: string; }
export interface CreateEvmOptions {
  readonly wasm: WasmSource; readonly hardfork?: HardforkName; readonly logLevel?: 0 | 1 | 2 | 3 | 4;
  readonly precompiles?: ReadonlyArray<PrecompileModuleInput>; readonly rpcUrl?: string;
  readonly stateProvider?: StateProvider; readonly blockTag?: RpcBlockTag; readonly cacheRpc?: boolean;
  readonly blockContext?: Partial<BlockContextOptions>;
  readonly onOpcode?: (opcode: number, framePtr: number) => number;
  readonly onPrecompile?: (a: number, i: number, n: number, g: bigint, ol: number, op: number, gu: number) => number;
  readonly wasi?: WasiShimOptions;
}

const ZERO_ADDRESS: Hex = "0x0000000000000000000000000000000000000000";
const DEFAULT_TARGET: Hex = "0x0000000000000000000000000000000000000200";
const assertOk = (flag: number, op: string): void => { if (flag === 0) throw new Error(`${op} failed`); };

export class GuillotineEvm {
  readonly bridge: WasmMemoryBridge;
  private handle: number;
  private disposed = false;
  private provider: StateProvider | null;
  private defaultBlockTag: RpcBlockTag;
  private blockCtx: BlockContextOptions = {
    chainId: 1n, blockNumber: 1n, timestamp: 1_720_000_000n, difficulty: 0n,
    prevRandao: 0n, coinbase: ZERO_ADDRESS, gasLimit: 30_000_000n, baseFee: 0n, blobBaseFee: 0n,
  };

  constructor(bridge: WasmMemoryBridge, handle: number, provider: StateProvider | null, blockTag: RpcBlockTag, initialBlock?: Partial<BlockContextOptions>) {
    this.bridge = bridge;
    this.handle = handle;
    this.provider = provider;
    this.defaultBlockTag = blockTag;
    if (provider) assertOk(bridge.exports.evm_enable_storage_injector(handle), "evm_enable_storage_injector");
    this.setBlockContext(initialBlock ?? {});
  }

  private assertLive(): number {
    if (this.disposed || this.handle === 0) throw new Error("GuillotineEvm instance has been disposed");
    return this.handle;
  }

  setBalance(address: BytesInput, balance: bigint | number): void {
    const h = this.assertLive();
    this.bridge.withBytes(toAddressBytes(address), (a) =>
      this.bridge.withBytes(toWordBytes(balance), (b) => assertOk(this.bridge.exports.evm_set_balance(h, a, b), "evm_set_balance")));
  }
  setCode(address: BytesInput, code: BytesInput): void {
    const h = this.assertLive();
    this.bridge.withBytes(toAddressBytes(address), (a) =>
      this.bridge.withBytes(toBytes(code), (c, n) => assertOk(this.bridge.exports.evm_set_code(h, a, c, n), "evm_set_code")));
  }
  setStorage(address: BytesInput, slot: bigint | number | BytesInput, value: bigint | number | BytesInput): void {
    const h = this.assertLive();
    this.bridge.withBytes(toAddressBytes(address), (a) =>
      this.bridge.withBytes(toWordBytes(slot), (s) =>
        this.bridge.withBytes(toWordBytes(value), (v) => assertOk(this.bridge.exports.evm_set_storage(h, a, s, v), "evm_set_storage"))));
  }
  getStorage(address: BytesInput, slot: bigint | number | BytesInput): bigint {
    const h = this.assertLive();
    return this.bridge.withBytes(toAddressBytes(address), (a) =>
      this.bridge.withBytes(toWordBytes(slot), (s) =>
        this.bridge.withAlloc(32, (out) => {
          assertOk(this.bridge.exports.evm_get_storage(h, a, s, out), "evm_get_storage");
          return bytesToBigInt(this.bridge.readBytes(out, 32));
        })));
  }
  setNonce(address: BytesInput, nonce: bigint | number): void {
    const h = this.assertLive();
    this.bridge.withBytes(toAddressBytes(address), (a) => assertOk(this.bridge.exports.evm_set_nonce(h, a, BigInt(nonce)), "evm_set_nonce"));
  }
  setOrigin(origin: BytesInput): void {
    const h = this.assertLive();
    this.bridge.withBytes(toAddressBytes(origin), (p) => assertOk(this.bridge.exports.evm_set_origin(h, p), "evm_set_origin"));
  }
  setGasPrice(gasPrice: bigint | number): void {
    const h = this.assertLive();
    this.bridge.withBytes(toWordBytes(gasPrice), (p) => assertOk(this.bridge.exports.evm_set_gas_price(h, p), "evm_set_gas_price"));
  }
  setBlockContext(ctx: Partial<BlockContextOptions>): void {
    const h = this.assertLive();
    this.blockCtx = { ...this.blockCtx, ...ctx };
    const b = this.blockCtx;
    const buf = new Uint8Array(180);
    buf.set(toWordBytes(b.chainId), 0); buf.set(toWordBytes(b.difficulty), 32);
    buf.set(toWordBytes(b.prevRandao), 64); buf.set(toWordBytes(b.baseFee), 96);
    buf.set(toWordBytes(b.blobBaseFee), 128); buf.set(toAddressBytes(b.coinbase), 160);
    this.bridge.withBytes(buf, (p) => assertOk(
      this.bridge.exports.evm_set_blockchain_context(h, p, BigInt(b.blockNumber), BigInt(b.timestamp), p + 32, p + 64, p + 160, BigInt(b.gasLimit), p + 96, p + 128),
      "evm_set_blockchain_context",
    ));
  }
  setAccessList(entries: ReadonlyArray<AccessListEntry>): void {
    const h = this.assertLive();
    const api = this.bridge.exports;
    if (entries.length === 0) { api.evm_set_access_list_addresses(h, 0, 0); api.evm_set_access_list_storage_keys(h, 0, 0, 0); return; }
    const addrs = new Uint8Array(entries.length * 20);
    const pairs: Array<{ addr: Uint8Array; slot: Uint8Array }> = [];
    entries.forEach((e, i) => {
      const a = toAddressBytes(e.address);
      addrs.set(a, i * 20);
      for (const s of e.storageKeys ?? []) pairs.push({ addr: a, slot: toWordBytes(s) });
    });
    this.bridge.withBytes(addrs, (p) => assertOk(api.evm_set_access_list_addresses(h, p, entries.length), "evm_set_access_list_addresses"));
    if (pairs.length === 0) { api.evm_set_access_list_storage_keys(h, 0, 0, 0); return; }
    const kAddrs = new Uint8Array(pairs.length * 20);
    const kSlots = new Uint8Array(pairs.length * 32);
    pairs.forEach((kp, i) => { kAddrs.set(kp.addr, i * 20); kSlots.set(kp.slot, i * 32); });
    this.bridge.withBytes(kAddrs, (ap) => this.bridge.withBytes(kSlots, (sp) =>
      assertOk(api.evm_set_access_list_storage_keys(h, ap, sp, pairs.length), "evm_set_access_list_storage_keys")));
  }
  setBlobHashes(hashes: ReadonlyArray<BytesInput>): void {
    const h = this.assertLive();
    if (hashes.length === 0) { this.bridge.exports.evm_set_blob_hashes(h, 0, 0); return; }
    const packed = new Uint8Array(hashes.length * 32);
    hashes.forEach((hash, i) => packed.set(toWordBytes(hash), i * 32));
    this.bridge.withBytes(packed, (p) => assertOk(this.bridge.exports.evm_set_blob_hashes(h, p, hashes.length), "evm_set_blob_hashes"));
  }

  private configureCall(params: CallOptions): void {
    const h = this.assertLive();
    const api = this.bridge.exports;
    if (params.origin !== undefined) this.setOrigin(params.origin);
    if (params.gasPrice !== undefined) this.setGasPrice(params.gasPrice);
    if (params.accessList !== undefined) this.setAccessList(params.accessList);
    if (params.blobHashes !== undefined) this.setBlobHashes(params.blobHashes);
    if (params.bytecode !== undefined) this.bridge.withBytes(toBytes(params.bytecode), (p, n) => assertOk(api.evm_set_bytecode(h, p, n), "evm_set_bytecode"));
    else api.evm_set_bytecode(h, 0, 0);
    const fixed = new Uint8Array(72);
    fixed.set(toAddressBytes(params.caller ?? ZERO_ADDRESS), 0); fixed.set(toAddressBytes(params.to ?? DEFAULT_TARGET), 20); fixed.set(toWordBytes(params.value ?? 0n), 40);
    this.bridge.withBytes(fixed, (fp) => this.bridge.withBytes(toBytes(params.data), (dp, dn) =>
      assertOk(api.evm_set_execution_context(h, BigInt(params.gas ?? 1_000_000n), fp, fp + 20, fp + 40, dp, dn), "evm_set_execution_context")));
  }
  private readResult(stateChangesJson?: string | null): CallResult {
    const h = this.assertLive();
    const api = this.bridge.exports;
    const output = this.bridge.readBytesGetter(h, api.evm_get_output_len, api.evm_get_output);
    return {
      success: api.evm_is_success(h) !== 0, output, outputHex: bytesToHex(output),
      gasUsed: api.evm_get_gas_used(h), gasRemaining: api.evm_get_gas_remaining(h), gasRefund: api.evm_get_gas_refund(h),
      logs: this.bridge.readLogs(h), storageChanges: this.bridge.readStorageChanges(h),
      ...(stateChangesJson !== undefined ? { stateChangesJson } : {}),
    };
  }

  callSync(params: CallOptions): CallResult {
    const h = this.assertLive();
    this.configureCall(params);
    this.bridge.exports.evm_execute(h);
    return this.readResult();
  }
  async call(params: CallOptions): Promise<CallResult> {
    if (!this.provider) return this.callSync(params);
    const h = this.assertLive();
    const rawTag = params.blockTag ?? this.defaultBlockTag;
    const blockTag = normalizeBlockTag(rawTag);
    if (this.provider.getBlockByNumber) {
      const hdr = await this.provider.getBlockByNumber(blockTag);
      if (hdr) this.setBlockContext({ blockNumber: hdr.number, timestamp: hdr.timestamp, gasLimit: hdr.gasLimit, baseFee: hdr.baseFeePerGas, coinbase: hdr.coinbase, prevRandao: hdr.prevRandao });
    }
    this.configureCall(params);
    const outcome = await driveAsyncExecution(this.bridge, h, this.provider, { blockTag: rawTag });
    return this.readResult(outcome.stateChangesJson);
  }
  async trace(params: CallOptions, opts: TraceOptions = {}): Promise<Eip3155TraceResult> {
    const h = this.assertLive();
    const api = this.bridge.exports;
    api.evm_enable_tracing(h, opts.enableMemory ? 1 : 0, opts.disableStack ? 1 : 0, opts.disableStorage ? 1 : 0, opts.enableReturnData ? 1 : 0);
    try {
      const result = await this.call(params);
      const rawJsonl = this.bridge.readTextGetter(h, api.evm_get_trace_json_len, api.evm_get_trace_json);
      const parsed = rawJsonl.trim() ? rawJsonl.trim().split("\n").map((l) => JSON.parse(l) as Record<string, unknown>) : [];
      const summary = parsed.length > 0 && "pass" in (parsed[parsed.length - 1] ?? {}) ? parsed.pop() ?? null : null;
      return { result, rawJsonl, steps: parsed, summary };
    } finally { api.evm_disable_tracing(h); }
  }
  async callTrace(params: CallOptions, opts: CallTraceOptions = {}): Promise<CallTraceResult> {
    const h = this.assertLive();
    const api = this.bridge.exports;
    api.evm_enable_call_tracer(h, opts.onlyTopCall ? 1 : 0, opts.withLog ? 1 : 0);
    const result = await this.call(params);
    const raw = this.bridge.readTextGetter(h, api.evm_get_call_trace_json_len, api.evm_get_call_trace_json);
    return { result, callFrame: raw ? (JSON.parse(raw) as Record<string, unknown>) : null };
  }
  async createAccessList(params: CallOptions): Promise<CreateAccessListResult> {
    const h = this.assertLive();
    const api = this.bridge.exports;
    api.evm_enable_access_list_tracker(h);
    const result = await this.call(params);
    const raw = this.bridge.readTextGetter(h, api.evm_get_access_list_json_len, api.evm_get_access_list_json);
    const accessList = raw ? (JSON.parse(raw) as ReadonlyArray<{ readonly address: Hex; readonly storageKeys: ReadonlyArray<Hex> }>) : [];
    return { result, accessList };
  }
  async flamegraphSvg(params: CallOptions, opts: { readonly compactAddresses?: boolean } = {}): Promise<FlamegraphResult> {
    const h = this.assertLive();
    const api = this.bridge.exports;
    if (!api.evm_enable_flamegraph || !api.evm_get_flamegraph_svg_len || !api.evm_get_flamegraph_svg) {
      throw new Error("WASM binary does not export evm_enable_flamegraph / evm_get_flamegraph_svg");
    }
    api.evm_enable_flamegraph(h, opts.compactAddresses ? 1 : 0);
    const result = await this.call(params);
    const svg = this.bridge.readTextGetter(h, api.evm_get_flamegraph_svg_len, api.evm_get_flamegraph_svg);
    const folded = api.evm_get_flamegraph_folded_len && api.evm_get_flamegraph_folded
      ? this.bridge.readTextGetter(h, api.evm_get_flamegraph_folded_len, api.evm_get_flamegraph_folded) : "";
    return { result, svg, folded };
  }
  decodeRevert(output?: BytesInput): DecodedRevert | null {
    if (output !== undefined) return decodeRevertBytes(toBytes(output));
    const h = this.assertLive();
    const api = this.bridge.exports;
    if (api.evm_decode_revert_json_len && api.evm_decode_revert_json) {
      const rawJson = this.bridge.readTextGetter(h, api.evm_decode_revert_json_len, api.evm_decode_revert_json);
      if (rawJson) return JSON.parse(rawJson) as DecodedRevert;
    }
    const lastOutput = this.bridge.readBytesGetter(h, api.evm_get_output_len, api.evm_get_output);
    return lastOutput.length === 0 ? null : decodeRevertBytes(lastOutput);
  }
  dispose(): void {
    if (this.disposed) return;
    this.disposed = true;
    if (this.handle !== 0) { this.bridge.exports.evm_destroy(this.handle); this.handle = 0; }
  }
  [Symbol.dispose](): void { this.dispose(); }
}

export async function createEvm(options: CreateEvmOptions): Promise<GuillotineEvm> {
  const [mod, precompiles] = await Promise.all([
    compileWasmModule(options.wasm),
    options.precompiles ? instantiatePrecompiles(options.precompiles, options.wasi) : Promise.resolve([]),
  ]);
  const wasi = createWasiShim(options.wasi);
  let instanceRef: WebAssembly.Instance | null = null;
  const instance = await WebAssembly.instantiate(mod, {
    wasi_snapshot_preview1: wasi.wasiImport,
    env: { js_opcode_callback: options.onOpcode ?? (() => 0), js_precompile_callback: options.onPrecompile ?? (() => 0) },
    precompiles: createPrecompileImports(() => {
      const mem = instanceRef?.exports.memory;
      if (!(mem instanceof WebAssembly.Memory)) throw new Error("Core WASM memory unavailable");
      return mem;
    }, precompiles),
  });
  instanceRef = instance;
  wasi.initialize(instance);
  const bridge = new WasmMemoryBridge(instance.exports as unknown as EvmWasmExports);
  if (options.onOpcode) bridge.exports.evm_set_js_opcode_callbacks_enabled(1);
  const forkName = options.hardfork ?? "osaka";
  const handle = bridge.withBytes(encodeUtf8(forkName), (p, n) => bridge.exports.evm_create(p, n, options.logLevel ?? 0) >>> 0);
  if (handle === 0) throw new Error(`Failed to create Guillotine EVM for hardfork "${forkName}"`);
  let provider: StateProvider | null = options.stateProvider ?? (options.rpcUrl ? createJsonRpcProvider(options.rpcUrl) : null);
  if (provider && (options.cacheRpc ?? true)) provider = createCachedStateProvider(provider);
  return new GuillotineEvm(bridge, handle, provider, options.blockTag ?? "latest", options.blockContext);
}
