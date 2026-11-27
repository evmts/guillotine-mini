/**
 * Async JSON-RPC state-injection loop for `evm_call_ffi` / `evm_continue_ffi`.
 * Drives lazy storage, balance, code, and nonce fetching against any Ethereum
 * JSON-RPC endpoint (or mock provider) with per-block caching.
 */

import {
  ASYNC_CONTINUE,
  ASYNC_OUTPUT,
  ASYNC_REQUEST,
  bytesToHex,
  decodeUtf8,
  encodeU64Be,
  hexToBytes,
  toWordBytes,
  type Hex,
  type WasmMemoryBridge,
} from "./abi.ts";

export type RpcBlockTag = "latest" | "pending" | "safe" | "finalized" | "earliest" | Hex | bigint;

export interface RpcBlockHeader {
  readonly number: bigint;
  readonly timestamp: bigint;
  readonly gasLimit: bigint;
  readonly baseFeePerGas: bigint;
  readonly coinbase: Hex;
  readonly prevRandao: Hex;
}

export interface StateProvider {
  getStorageAt(address: Hex, slot: Hex, blockTag: string): Promise<Hex>;
  getBalance(address: Hex, blockTag: string): Promise<bigint>;
  getCode(address: Hex, blockTag: string): Promise<Uint8Array>;
  getTransactionCount(address: Hex, blockTag: string): Promise<bigint>;
  getBlockByNumber?(blockTag: string): Promise<RpcBlockHeader | null>;
}

export interface CachedStateProvider extends StateProvider {
  clearCache(): void;
}

export interface JsonRpcProviderOptions {
  readonly fetch?: typeof globalThis.fetch;
  readonly headers?: Record<string, string>;
}

export interface DriveAsyncOptions {
  readonly blockTag?: RpcBlockTag;
  readonly maxSteps?: number;
  readonly onStateChanges?: (stateChangesJson: string) => void | Promise<void>;
}

export interface AsyncExecutionOutcome {
  readonly completed: boolean;
  readonly stateChangesJson: string | null;
  readonly requestsServed: number;
  readonly storageFetches: number;
  readonly balanceFetches: number;
  readonly codeFetches: number;
  readonly nonceFetches: number;
}

interface JsonRpcResponse {
  readonly result?: unknown;
  readonly error?: { readonly code: number; readonly message: string };
}

interface RawRpcBlock {
  readonly number?: string;
  readonly timestamp?: string;
  readonly gasLimit?: string;
  readonly baseFeePerGas?: string;
  readonly miner?: string;
  readonly mixHash?: string;
  readonly difficulty?: string;
}

export function normalizeBlockTag(blockTag: RpcBlockTag = "latest"): string {
  return typeof blockTag === "bigint" ? `0x${blockTag.toString(16)}` : blockTag;
}

function parseRpcQuantity(value: unknown, method: string): bigint {
  if (typeof value !== "string") throw new Error(`RPC ${method} returned non-string quantity`);
  return value === "0x" || value === "" ? 0n : BigInt(value);
}

export function createJsonRpcProvider(rpcUrl: string, options: JsonRpcProviderOptions = {}): StateProvider {
  const fetchFn = options.fetch ?? globalThis.fetch;
  if (typeof fetchFn !== "function") throw new Error("globalThis.fetch is unavailable; supply options.fetch");
  let nextId = 1;

  async function rpc(method: string, params: ReadonlyArray<unknown>): Promise<unknown> {
    const res = await fetchFn(rpcUrl, {
      method: "POST",
      headers: { "content-type": "application/json", ...options.headers },
      body: JSON.stringify({ jsonrpc: "2.0", id: nextId++, method, params }),
    });
    if (!res.ok) throw new Error(`RPC ${method} HTTP ${res.status} ${res.statusText}`);
    const payload = (await res.json()) as JsonRpcResponse;
    if (payload.error) throw new Error(`RPC ${method} error ${payload.error.code}: ${payload.error.message}`);
    return payload.result;
  }

  return {
    async getStorageAt(address: Hex, slot: Hex, blockTag: string): Promise<Hex> {
      const result = await rpc("eth_getStorageAt", [address, slot, blockTag]);
      if (typeof result !== "string") throw new Error("eth_getStorageAt returned invalid payload");
      return result as Hex;
    },
    async getBalance(address: Hex, blockTag: string): Promise<bigint> {
      return parseRpcQuantity(await rpc("eth_getBalance", [address, blockTag]), "eth_getBalance");
    },
    async getCode(address: Hex, blockTag: string): Promise<Uint8Array> {
      const result = await rpc("eth_getCode", [address, blockTag]);
      if (typeof result !== "string") throw new Error("eth_getCode returned invalid payload");
      return hexToBytes(result);
    },
    async getTransactionCount(address: Hex, blockTag: string): Promise<bigint> {
      return parseRpcQuantity(await rpc("eth_getTransactionCount", [address, blockTag]), "eth_getTransactionCount");
    },
    async getBlockByNumber(blockTag: string): Promise<RpcBlockHeader | null> {
      const raw = (await rpc("eth_getBlockByNumber", [blockTag, false])) as RawRpcBlock | null;
      if (!raw) return null;
      return {
        number: parseRpcQuantity(raw.number ?? "0x0", "eth_getBlockByNumber.number"),
        timestamp: parseRpcQuantity(raw.timestamp ?? "0x0", "eth_getBlockByNumber.timestamp"),
        gasLimit: parseRpcQuantity(raw.gasLimit ?? "0x1c9c380", "eth_getBlockByNumber.gasLimit"),
        baseFeePerGas: parseRpcQuantity(raw.baseFeePerGas ?? "0x0", "eth_getBlockByNumber.baseFeePerGas"),
        coinbase: (raw.miner ?? "0x0000000000000000000000000000000000000000") as Hex,
        prevRandao: (raw.mixHash ?? raw.difficulty ?? `0x${"00".repeat(32)}`) as Hex,
      };
    },
  };
}

async function cached<T>(map: Map<string, T>, key: string, load: () => Promise<T>): Promise<T> {
  if (map.has(key)) return map.get(key) as T;
  const value = await load();
  map.set(key, value);
  return value;
}

export function createCachedStateProvider(inner: StateProvider): CachedStateProvider {
  const storage = new Map<string, Hex>();
  const balances = new Map<string, bigint>();
  const codes = new Map<string, Uint8Array>();
  const nonces = new Map<string, bigint>();
  const blocks = new Map<string, RpcBlockHeader | null>();

  return {
    clearCache(): void {
      storage.clear();
      balances.clear();
      codes.clear();
      nonces.clear();
      blocks.clear();
    },
    getStorageAt: (addr, slot, tag) =>
      cached(storage, `${tag}:${addr.toLowerCase()}:${slot.toLowerCase()}`, () => inner.getStorageAt(addr, slot, tag)),
    getBalance: (addr, tag) =>
      cached(balances, `${tag}:${addr.toLowerCase()}`, () => inner.getBalance(addr, tag)),
    getCode: (addr, tag) =>
      cached(codes, `${tag}:${addr.toLowerCase()}`, () => inner.getCode(addr, tag)),
    getTransactionCount: (addr, tag) =>
      cached(nonces, `${tag}:${addr.toLowerCase()}`, () => inner.getTransactionCount(addr, tag)),
    getBlockByNumber: (tag) =>
      inner.getBlockByNumber ? cached(blocks, tag, () => inner.getBlockByNumber!(tag)) : Promise.resolve(null),
  };
}

function concatBytes(parts: ReadonlyArray<Uint8Array>): Uint8Array {
  let total = 0;
  for (const part of parts) total += part.length;
  const out = new Uint8Array(total);
  let offset = 0;
  for (const part of parts) {
    out.set(part, offset);
    offset += part.length;
  }
  return out;
}

function readStateChangesJson(bridge: WasmMemoryBridge, handle: number, reqPtr: number): string {
  const jsonLen = bridge.view().getUint32(reqPtr + ASYNC_REQUEST.JSON_LEN_OFFSET, true);
  if (jsonLen === 0) return "";
  if (jsonLen <= ASYNC_REQUEST.INLINE_CAPACITY) {
    return decodeUtf8(bridge.readBytes(reqPtr + ASYNC_REQUEST.JSON_DATA_OFFSET, jsonLen));
  }
  return bridge.readTextGetter(
    handle,
    (h) => bridge.exports.evm_get_state_changes_len(h),
    (h, p, n) => bridge.exports.evm_get_state_changes(h, p, n),
  );
}

export async function driveAsyncExecution(
  bridge: WasmMemoryBridge,
  handle: number,
  provider: StateProvider,
  options: DriveAsyncOptions = {},
): Promise<AsyncExecutionOutcome> {
  const blockTag = normalizeBlockTag(options.blockTag);
  const maxSteps = options.maxSteps ?? 4096;
  const api = bridge.exports;
  let requestsServed = 0;
  let storageFetches = 0;
  let balanceFetches = 0;
  let codeFetches = 0;
  let nonceFetches = 0;
  let stateChangesJson: string | null = null;

  const reqPtr = bridge.alloc(ASYNC_REQUEST.STRUCT_SIZE);
  try {
    bridge.bytes().fill(0, reqPtr, reqPtr + ASYNC_REQUEST.STRUCT_SIZE);
    if (api.evm_call_ffi(handle, reqPtr) === 0) throw new Error("evm_call_ffi failed to start async execution");

    for (let step = 0; step < maxSteps; step++) {
      const outputType = bridge.bytes()[reqPtr + ASYNC_REQUEST.OUTPUT_TYPE_OFFSET] ?? ASYNC_OUTPUT.ERROR;
      if (outputType === ASYNC_OUTPUT.RESULT) {
        return { completed: true, stateChangesJson, requestsServed, storageFetches, balanceFetches, codeFetches, nonceFetches };
      }
      if (outputType === ASYNC_OUTPUT.ERROR) throw new Error("Async EVM execution returned host error (output_type=255)");

      const addrBytes = bridge.readBytes(reqPtr + ASYNC_REQUEST.ADDRESS_OFFSET, 20);
      const addrHex = bytesToHex(addrBytes);
      let ok = 0;

      if (outputType === ASYNC_OUTPUT.NEED_STORAGE) {
        const slotBytes = bridge.readBytes(reqPtr + ASYNC_REQUEST.SLOT_OFFSET, 32);
        const valHex = await provider.getStorageAt(addrHex, bytesToHex(slotBytes), blockTag);
        const payload = concatBytes([addrBytes, slotBytes, toWordBytes(valHex)]);
        ok = bridge.withBytes(payload, (p, n) => api.evm_continue_ffi(handle, ASYNC_CONTINUE.STORAGE, p, n, reqPtr));
        storageFetches++;
        requestsServed++;
      } else if (outputType === ASYNC_OUTPUT.NEED_BALANCE) {
        const payload = concatBytes([addrBytes, toWordBytes(await provider.getBalance(addrHex, blockTag))]);
        ok = bridge.withBytes(payload, (p, n) => api.evm_continue_ffi(handle, ASYNC_CONTINUE.BALANCE, p, n, reqPtr));
        balanceFetches++;
        requestsServed++;
      } else if (outputType === ASYNC_OUTPUT.NEED_CODE) {
        const payload = concatBytes([addrBytes, await provider.getCode(addrHex, blockTag)]);
        ok = bridge.withBytes(payload, (p, n) => api.evm_continue_ffi(handle, ASYNC_CONTINUE.CODE, p, n, reqPtr));
        codeFetches++;
        requestsServed++;
      } else if (outputType === ASYNC_OUTPUT.NEED_NONCE) {
        const payload = concatBytes([addrBytes, encodeU64Be(await provider.getTransactionCount(addrHex, blockTag))]);
        ok = bridge.withBytes(payload, (p, n) => api.evm_continue_ffi(handle, ASYNC_CONTINUE.NONCE, p, n, reqPtr));
        nonceFetches++;
        requestsServed++;
      } else if (outputType === ASYNC_OUTPUT.READY_TO_COMMIT) {
        stateChangesJson = readStateChangesJson(bridge, handle, reqPtr);
        if (options.onStateChanges) await options.onStateChanges(stateChangesJson);
        ok = api.evm_continue_ffi(handle, ASYNC_CONTINUE.AFTER_COMMIT, 0, 0, reqPtr);
      } else {
        throw new Error(`Unknown async output_type=${outputType}`);
      }
      if (ok === 0) throw new Error(`evm_continue_ffi rejected continuation for output_type=${outputType}`);
    }
    throw new Error(`Async execution exceeded maxSteps (${maxSteps})`);
  } finally {
    bridge.free(reqPtr, ASYNC_REQUEST.STRUCT_SIZE);
  }
}
