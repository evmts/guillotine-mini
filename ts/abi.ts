/**
 * Typed WASM linear-memory ABI bridge, result readers, and Ethereum codecs.
 * Creates fresh `Uint8Array` / `DataView` views on every access so `memory.grow()`
 * never detaches cached views.
 */

export type Hex = `0x${string}`;
export type BytesInput = Hex | Uint8Array;

export const ASYNC_REQUEST = {
  OUTPUT_TYPE_OFFSET: 0, ADDRESS_OFFSET: 1, SLOT_OFFSET: 21,
  JSON_LEN_OFFSET: 56, JSON_DATA_OFFSET: 60, INLINE_CAPACITY: 16_384, STRUCT_SIZE: 60 + 16_384,
} as const;

export const ASYNC_OUTPUT = {
  RESULT: 0, NEED_STORAGE: 1, NEED_BALANCE: 2, NEED_CODE: 3, NEED_NONCE: 4, READY_TO_COMMIT: 5, ERROR: 255,
} as const;

export const ASYNC_CONTINUE = { STORAGE: 1, BALANCE: 2, CODE: 3, NONCE: 4, AFTER_COMMIT: 5 } as const;

export interface EvmLog {
  readonly address: Hex;
  readonly topics: ReadonlyArray<Hex>;
  readonly data: Hex;
}

export interface StorageChange {
  readonly address: Hex;
  readonly slot: Hex;
  readonly value: Hex;
}

export interface DecodedRevert {
  readonly kind: "error" | "panic" | "custom" | "empty" | "raw";
  readonly selector?: Hex;
  readonly reason?: string;
  readonly panicCode?: number;
  readonly raw: Hex;
}

export interface EvmWasmExports {
  readonly memory: WebAssembly.Memory;
  readonly _initialize?: () => void;
  evm_alloc(len: number): number;
  evm_free(ptr: number, len: number): void;
  evm_create(hardforkPtr: number, hardforkLen: number, logLevel: number): number;
  evm_destroy(handle: number): void;
  evm_set_js_opcode_callbacks_enabled(enabled: number): void;
  evm_set_bytecode(handle: number, ptr: number, len: number): number;
  evm_set_execution_context(h: number, gas: bigint, caller: number, addr: number, val: number, data: number, len: number): number;
  evm_set_origin(handle: number, originPtr: number): number;
  evm_set_gas_price(handle: number, gasPricePtr: number): number;
  evm_set_blockchain_context(
    h: number, chainId: number, num: bigint, ts: bigint, diff: number, randao: number, coin: number, gasLim: bigint, baseFee: number, blobFee: number,
  ): number;
  evm_set_access_list_addresses(handle: number, ptr: number, count: number): number;
  evm_set_access_list_storage_keys(handle: number, addrPtr: number, slotPtr: number, count: number): number;
  evm_set_blob_hashes(handle: number, ptr: number, count: number): number;
  evm_execute(handle: number): number;
  evm_get_gas_remaining(handle: number): bigint;
  evm_get_gas_used(handle: number): bigint;
  evm_is_success(handle: number): number;
  evm_get_output_len(handle: number): number;
  evm_get_output(handle: number, bufPtr: number, bufLen: number): number;
  evm_set_storage(handle: number, addrPtr: number, slotPtr: number, valPtr: number): number;
  evm_get_storage(handle: number, addrPtr: number, slotPtr: number, valOutPtr: number): number;
  evm_set_balance(handle: number, addrPtr: number, balPtr: number): number;
  evm_set_code(handle: number, addrPtr: number, codePtr: number, codeLen: number): number;
  evm_set_nonce(handle: number, addrPtr: number, nonce: bigint): number;
  evm_enable_storage_injector(handle: number): number;
  evm_call_ffi(handle: number, reqOutPtr: number): number;
  evm_continue_ffi(handle: number, kind: number, dataPtr: number, dataLen: number, reqOutPtr: number): number;
  evm_get_state_changes_len(handle: number): number;
  evm_get_state_changes(handle: number, bufPtr: number, bufLen: number): number;
  evm_get_log_count(handle: number): number;
  evm_get_log(h: number, idx: number, addr: number, tc: number, topics: number, dLen: number, data: number, maxLen: number): number;
  evm_get_gas_refund(handle: number): bigint;
  evm_get_storage_change_count(handle: number): number;
  evm_get_storage_change(handle: number, idx: number, addrOut: number, slotOut: number, valOut: number): number;
  evm_enable_tracing(handle: number, mem: number, noStack: number, noStorage: number, retData: number): void;
  evm_disable_tracing(handle: number): void;
  evm_get_trace_json_len(handle: number): number;
  evm_get_trace_json(handle: number, bufPtr: number, bufLen: number): number;
  evm_enable_call_tracer(handle: number, onlyTop: number, withLog: number): void;
  evm_get_call_trace_json_len(handle: number): number;
  evm_get_call_trace_json(handle: number, bufPtr: number, bufLen: number): number;
  evm_enable_access_list_tracker(handle: number): void;
  evm_get_access_list_json_len(handle: number): number;
  evm_get_access_list_json(handle: number, bufPtr: number, bufLen: number): number;
  evm_enable_flamegraph?: (handle: number, compactAddresses: number) => number;
  evm_get_flamegraph_svg_len?: (handle: number) => number;
  evm_get_flamegraph_svg?: (handle: number, bufPtr: number, bufLen: number) => number;
  evm_get_flamegraph_folded_len?: (handle: number) => number;
  evm_get_flamegraph_folded?: (handle: number, bufPtr: number, bufLen: number) => number;
  evm_decode_revert_json_len?: (handle: number) => number;
  evm_decode_revert_json?: (handle: number, bufPtr: number, bufLen: number) => number;
}

const HEX_CHARS = "0123456789abcdef";
const textEncoder = new TextEncoder();
const textDecoder = new TextDecoder();

export const encodeUtf8 = (text: string): Uint8Array => textEncoder.encode(text);
export const decodeUtf8 = (bytes: Uint8Array): string => textDecoder.decode(bytes);

export function hexToBytes(hex: string): Uint8Array {
  const clean = hex.startsWith("0x") || hex.startsWith("0X") ? hex.slice(2) : hex;
  if (clean.length === 0) return new Uint8Array(0);
  const padded = clean.length % 2 === 1 ? `0${clean}` : clean;
  const out = new Uint8Array(padded.length / 2);
  for (let i = 0; i < out.length; i++) {
    const byte = Number.parseInt(padded.slice(i * 2, i * 2 + 2), 16);
    if (Number.isNaN(byte)) throw new Error(`Invalid hex string: ${hex}`);
    out[i] = byte;
  }
  return out;
}

export function bytesToHex(bytes: Uint8Array): Hex {
  let out = "0x";
  for (let i = 0; i < bytes.length; i++) {
    const b = bytes[i] ?? 0;
    out += HEX_CHARS.charAt(b >> 4) + HEX_CHARS.charAt(b & 0x0f);
  }
  return out as Hex;
}

export function toBytes(input: BytesInput | undefined): Uint8Array {
  if (input === undefined) return new Uint8Array(0);
  return typeof input === "string" ? hexToBytes(input) : input;
}

export function toAddressBytes(input: BytesInput): Uint8Array {
  const raw = toBytes(input);
  if (raw.length > 20) throw new Error(`Address exceeds 20 bytes: ${raw.length}`);
  if (raw.length === 20) return raw;
  const out = new Uint8Array(20);
  out.set(raw, 20 - raw.length);
  return out;
}

export function toWordBytes(input: bigint | number | BytesInput): Uint8Array {
  const out = new Uint8Array(32);
  if (typeof input === "bigint" || typeof input === "number") {
    let v = typeof input === "number" ? BigInt(input) : input;
    if (v < 0n) throw new Error(`Unsigned 256-bit word cannot be negative: ${v}`);
    for (let i = 31; i >= 0 && v > 0n; i--) {
      out[i] = Number(v & 0xffn);
      v >>= 8n;
    }
    if (v > 0n) throw new Error("Value overflows 256-bit word");
    return out;
  }
  const raw = toBytes(input);
  if (raw.length > 32) throw new Error(`Word exceeds 32 bytes: ${raw.length}`);
  out.set(raw, 32 - raw.length);
  return out;
}

export function bytesToBigInt(bytes: Uint8Array): bigint {
  let value = 0n;
  for (let i = 0; i < bytes.length; i++) value = (value << 8n) | BigInt(bytes[i] ?? 0);
  return value;
}

export function encodeU64Be(value: bigint | number): Uint8Array {
  let v = typeof value === "number" ? BigInt(value) : value;
  if (v < 0n || v > 0xffff_ffff_ffff_ffffn) throw new Error(`Nonce out of u64 range: ${v}`);
  const out = new Uint8Array(8);
  for (let i = 7; i >= 0; i--) {
    out[i] = Number(v & 0xffn);
    v >>= 8n;
  }
  return out;
}

export function decodeRevertBytes(output: Uint8Array): DecodedRevert {
  const raw = bytesToHex(output);
  if (output.length === 0) return { kind: "empty", raw };
  if (output.length < 4) return { kind: "raw", raw };
  const selector = bytesToHex(output.subarray(0, 4));
  if (selector === "0x08c379a0" && output.length >= 68) {
    const lenPos = 4 + Number(bytesToBigInt(output.subarray(4, 36)));
    if (lenPos + 32 <= output.length) {
      const strLen = Number(bytesToBigInt(output.subarray(lenPos, lenPos + 32)));
      if (lenPos + 32 + strLen <= output.length) {
        return { kind: "error", selector, reason: decodeUtf8(output.subarray(lenPos + 32, lenPos + 32 + strLen)), raw };
      }
    }
  }
  if (selector === "0x4e487b71" && output.length >= 36) {
    return { kind: "panic", selector, panicCode: Number(bytesToBigInt(output.subarray(4, 36))), raw };
  }
  return { kind: "custom", selector, raw };
}

export class WasmMemoryBridge {
  readonly exports: EvmWasmExports;

  constructor(exports: EvmWasmExports) {
    this.exports = exports;
  }

  view(): DataView {
    return new DataView(this.exports.memory.buffer);
  }

  bytes(): Uint8Array {
    return new Uint8Array(this.exports.memory.buffer);
  }

  alloc(len: number): number {
    if (len === 0) return 0;
    const ptr = this.exports.evm_alloc(len) >>> 0;
    if (ptr === 0) throw new Error(`WASM evm_alloc(${len}) returned null`);
    return ptr;
  }

  free(ptr: number, len: number): void {
    if (ptr !== 0 && len > 0) this.exports.evm_free(ptr, len);
  }

  writeBytes(data: Uint8Array): number {
    if (data.length === 0) return 0;
    const ptr = this.alloc(data.length);
    this.bytes().set(data, ptr);
    return ptr;
  }

  readBytes(ptr: number, len: number): Uint8Array {
    return len === 0 ? new Uint8Array(0) : this.bytes().slice(ptr >>> 0, (ptr >>> 0) + len);
  }

  withBytes<T>(data: Uint8Array, fn: (ptr: number, len: number) => T): T {
    const ptr = this.writeBytes(data);
    try { return fn(ptr, data.length); } finally { this.free(ptr, data.length); }
  }

  withAlloc<T>(len: number, fn: (ptr: number) => T): T {
    const ptr = this.alloc(len);
    if (len > 0) this.bytes().fill(0, ptr, ptr + len);
    try { return fn(ptr); } finally { this.free(ptr, len); }
  }

  readBytesGetter(handle: number, getLen: (h: number) => number, getBuf: (h: number, p: number, n: number) => number): Uint8Array {
    const len = getLen(handle) >>> 0;
    if (len === 0) return new Uint8Array(0);
    return this.withAlloc(len, (ptr) => this.readBytes(ptr, Math.min(getBuf(handle, ptr, len) >>> 0, len)));
  }

  readTextGetter(handle: number, getLen: (h: number) => number, getBuf: (h: number, p: number, n: number) => number): string {
    const raw = this.readBytesGetter(handle, getLen, getBuf);
    return raw.length === 0 ? "" : decodeUtf8(raw);
  }

  readLogs(handle: number): EvmLog[] {
    const api = this.exports;
    const count = api.evm_get_log_count(handle) >>> 0;
    const out: EvmLog[] = [];
    for (let i = 0; i < count; i++) {
      this.withAlloc(156, (meta) => {
        if (api.evm_get_log(handle, i, meta, meta + 20, meta + 24, meta + 152, 0, 0) === 0) return;
        const dv = this.view();
        const tCount = dv.getUint32(meta + 20, true);
        const dLen = dv.getUint32(meta + 152, true);
        const topics: Hex[] = [];
        for (let t = 0; t < tCount; t++) topics.push(bytesToHex(this.readBytes(meta + 24 + t * 32, 32)));
        const data = dLen === 0 ? new Uint8Array(0) : this.withAlloc(dLen, (dp) => {
          api.evm_get_log(handle, i, meta, meta + 20, meta + 24, meta + 152, dp, dLen);
          return this.readBytes(dp, dLen);
        });
        out.push({ address: bytesToHex(this.readBytes(meta, 20)), topics, data: bytesToHex(data) });
      });
    }
    return out;
  }

  readStorageChanges(handle: number): StorageChange[] {
    const api = this.exports;
    const count = api.evm_get_storage_change_count(handle) >>> 0;
    const out: StorageChange[] = [];
    for (let i = 0; i < count; i++) {
      this.withAlloc(84, (ptr) => {
        if (api.evm_get_storage_change(handle, i, ptr, ptr + 20, ptr + 52) === 0) return;
        out.push({
          address: bytesToHex(this.readBytes(ptr, 20)),
          slot: bytesToHex(this.readBytes(ptr + 20, 32)),
          value: bytesToHex(this.readBytes(ptr + 52, 32)),
        });
      });
    }
    return out;
  }
}
