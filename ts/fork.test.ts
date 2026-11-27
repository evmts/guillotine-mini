import { describe, expect, test } from "bun:test";
import {
  ASYNC_CONTINUE,
  ASYNC_OUTPUT,
  ASYNC_REQUEST,
  WasmMemoryBridge,
  bytesToBigInt,
  bytesToHex,
  encodeUtf8,
  hexToBytes,
  type EvmWasmExports,
  type Hex,
} from "./abi.ts";
import {
  createCachedStateProvider,
  createJsonRpcProvider,
  driveAsyncExecution,
  normalizeBlockTag,
  type StateProvider,
} from "./fork.ts";

describe("fork JSON-RPC provider and async state injection", () => {
  test("normalizeBlockTag converts bigint and preserves tags", () => {
    expect(normalizeBlockTag()).toBe("latest");
    expect(normalizeBlockTag("finalized")).toBe("finalized");
    expect(normalizeBlockTag(21_000_000n)).toBe("0x1406f40");
    expect(normalizeBlockTag("0x10")).toBe("0x10");
  });

  test("createJsonRpcProvider dispatches JSON-RPC 2.0 requests and caches via createCachedStateProvider", async () => {
    const calls: string[] = [];
    const mockFetch: typeof globalThis.fetch = (async (_url, init) => {
      const body = JSON.parse(String(init?.body ?? "{}")) as { id: number; method: string };
      calls.push(body.method);
      const responses: Record<string, unknown> = {
        eth_getStorageAt: `0x${"00".repeat(31)}2a`,
        eth_getBalance: "0xde0b6b3a7640000",
        eth_getCode: "0x60016000f3",
        eth_getTransactionCount: "0x7",
        eth_getBlockByNumber: {
          number: "0x10",
          timestamp: "0x66800000",
          gasLimit: "0x1c9c380",
          baseFeePerGas: "0x3b9aca00",
          miner: `0x${"11".repeat(20)}`,
          mixHash: `0x${"22".repeat(32)}`,
        },
      };
      return new Response(JSON.stringify({ jsonrpc: "2.0", id: body.id, result: responses[body.method] }), {
        status: 200,
        headers: { "content-type": "application/json" },
      });
    }) as typeof globalThis.fetch;

    const raw = createJsonRpcProvider("https://rpc.example", { fetch: mockFetch });
    const cached = createCachedStateProvider(raw);
    const addr: Hex = `0x${"aa".repeat(20)}`;
    const slot: Hex = `0x${"00".repeat(32)}`;

    expect(await cached.getStorageAt(addr, slot, "latest")).toBe(`0x${"00".repeat(31)}2a`);
    expect(await cached.getStorageAt(addr, slot, "latest")).toBe(`0x${"00".repeat(31)}2a`);
    expect(await cached.getBalance(addr, "latest")).toBe(10n ** 18n);
    expect(await cached.getBalance(addr, "latest")).toBe(10n ** 18n);
    expect(bytesToHex(await cached.getCode(addr, "latest"))).toBe("0x60016000f3");
    expect(await cached.getTransactionCount(addr, "latest")).toBe(7n);
    const hdr = await cached.getBlockByNumber!("latest");
    expect(hdr?.number).toBe(16n);
    expect(calls.length).toBe(5);

    cached.clearCache();
    expect(await cached.getBalance(addr, "latest")).toBe(10n ** 18n);
    expect(calls.length).toBe(6);
  });

  test("driveAsyncExecution services storage, balance, code, nonce, and overflow state changes", async () => {
    const memory = new WebAssembly.Memory({ initial: 4 });
    let bump = 1024;
    const targetAddr = hexToBytes(`0x${"00".repeat(18)}0200`);
    const slotZero = new Uint8Array(32);
    slotZero[31] = 1;
    const bigJson = encodeUtf8(`{"storage":[${Array.from({ length: 1200 }, (_, i) => `{"slot":"0x${i}"}`).join(",")}]}`);
    expect(bigJson.length).toBeGreaterThan(ASYNC_REQUEST.INLINE_CAPACITY);

    const sequence = [
      ASYNC_OUTPUT.NEED_STORAGE,
      ASYNC_OUTPUT.NEED_BALANCE,
      ASYNC_OUTPUT.NEED_CODE,
      ASYNC_OUTPUT.NEED_NONCE,
      ASYNC_OUTPUT.READY_TO_COMMIT,
      ASYNC_OUTPUT.RESULT,
    ];
    let stepIdx = 0;
    const seenTypes: number[] = [];

    function writeReq(reqPtr: number, kind: number): void {
      const mem = new Uint8Array(memory.buffer);
      mem.fill(0, reqPtr, reqPtr + ASYNC_REQUEST.STRUCT_SIZE);
      mem[reqPtr + ASYNC_REQUEST.OUTPUT_TYPE_OFFSET] = kind;
      mem.set(targetAddr, reqPtr + ASYNC_REQUEST.ADDRESS_OFFSET);
      mem.set(slotZero, reqPtr + ASYNC_REQUEST.SLOT_OFFSET);
      if (kind === ASYNC_OUTPUT.READY_TO_COMMIT) {
        new DataView(memory.buffer).setUint32(reqPtr + ASYNC_REQUEST.JSON_LEN_OFFSET, bigJson.length, true);
      }
    }

    const mockExports = {
      memory,
      evm_alloc(len: number): number {
        const ptr = bump;
        bump += (len + 15) & ~15;
        while (bump > memory.buffer.byteLength) memory.grow(1);
        return ptr;
      },
      evm_free(): void {},
      evm_call_ffi(_h: number, reqPtr: number): number {
        writeReq(reqPtr, sequence[stepIdx++] ?? ASYNC_OUTPUT.RESULT);
        return 1;
      },
      evm_continue_ffi(_h: number, kind: number, dataPtr: number, dataLen: number, reqPtr: number): number {
        seenTypes.push(kind);
        const payload = new Uint8Array(memory.buffer, dataPtr, dataLen);
        if (kind === ASYNC_CONTINUE.STORAGE) expect(payload.length).toBe(84);
        if (kind === ASYNC_CONTINUE.BALANCE) expect(payload.length).toBe(52);
        if (kind === ASYNC_CONTINUE.CODE) expect(payload.length).toBe(23);
        if (kind === ASYNC_CONTINUE.NONCE) expect(bytesToBigInt(payload.subarray(20, 28))).toBe(9n);
        writeReq(reqPtr, sequence[stepIdx++] ?? ASYNC_OUTPUT.RESULT);
        return 1;
      },
      evm_get_state_changes_len(): number {
        return bigJson.length;
      },
      evm_get_state_changes(_h: number, ptr: number, len: number): number {
        if (len >= bigJson.length) new Uint8Array(memory.buffer, ptr, bigJson.length).set(bigJson);
        return bigJson.length;
      },
    } as unknown as EvmWasmExports;

    const provider: StateProvider = {
      getStorageAt: async () => `0x${"00".repeat(31)}05`,
      getBalance: async () => 500n,
      getCode: async () => hexToBytes("0x600100"),
      getTransactionCount: async () => 9n,
    };

    const bridge = new WasmMemoryBridge(mockExports);
    let committed = "";
    const outcome = await driveAsyncExecution(bridge, 1, provider, {
      onStateChanges: (json) => {
        committed = json;
      },
    });

    expect(outcome.completed).toBe(true);
    expect(outcome.requestsServed).toBe(4);
    expect(outcome.storageFetches).toBe(1);
    expect(outcome.balanceFetches).toBe(1);
    expect(outcome.codeFetches).toBe(1);
    expect(outcome.nonceFetches).toBe(1);
    expect(outcome.stateChangesJson?.length).toBe(bigJson.length);
    expect(committed.length).toBe(bigJson.length);
    expect(seenTypes).toEqual([
      ASYNC_CONTINUE.STORAGE,
      ASYNC_CONTINUE.BALANCE,
      ASYNC_CONTINUE.CODE,
      ASYNC_CONTINUE.NONCE,
      ASYNC_CONTINUE.AFTER_COMMIT,
    ]);
  });
});
