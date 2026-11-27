import { describe, expect, test } from "bun:test";
import {
  WasmMemoryBridge,
  bytesToBigInt,
  bytesToHex,
  decodeRevertBytes,
  encodeU64Be,
  encodeUtf8,
  hexToBytes,
  toAddressBytes,
  toWordBytes,
  type EvmWasmExports,
} from "./abi.ts";

function makeMockExports(): { exports: EvmWasmExports; liveAllocs: Map<number, number> } {
  const memory = new WebAssembly.Memory({ initial: 1 });
  let bump = 1024;
  const liveAllocs = new Map<number, number>();
  let storedPayload = new Uint8Array(0);

  const exports = {
    memory,
    evm_alloc(len: number): number {
      if (len === 0) return 0;
      const ptr = bump;
      bump += (len + 15) & ~15;
      while (bump > memory.buffer.byteLength) memory.grow(1);
      liveAllocs.set(ptr, len);
      return ptr;
    },
    evm_free(ptr: number, len: number): void {
      const expected = liveAllocs.get(ptr);
      if (expected !== len) throw new Error(`Mismatched free(${ptr}, ${len}) vs ${expected}`);
      liveAllocs.delete(ptr);
    },
    evm_get_output_len(): number {
      return storedPayload.length;
    },
    evm_get_output(_h: number, ptr: number, len: number): number {
      const n = Math.min(len, storedPayload.length);
      new Uint8Array(memory.buffer, ptr, n).set(storedPayload.subarray(0, n));
      return n;
    },
  } as unknown as EvmWasmExports;

  storedPayload = encodeUtf8("guillotine-mini");
  return { exports, liveAllocs };
}

describe("abi codecs and WasmMemoryBridge", () => {
  test("hex, address, word, and u64 codecs roundtrip cleanly", () => {
    expect(bytesToHex(hexToBytes("0x0102ff"))).toBe("0x0102ff");
    expect(bytesToHex(hexToBytes("abc"))).toBe("0x0abc");
    expect(hexToBytes("0x")).toEqual(new Uint8Array(0));
    expect(() => hexToBytes("0xzz")).toThrow();

    const addr = toAddressBytes("0x0200");
    expect(addr.length).toBe(20);
    expect(addr[18]).toBe(2);
    expect(addr[19]).toBe(0);
    expect(() => toAddressBytes(`0x${"11".repeat(21)}`)).toThrow();

    const word = toWordBytes(0x1234n);
    expect(word.length).toBe(32);
    expect(bytesToBigInt(word)).toBe(0x1234n);
    expect(() => toWordBytes(-1n)).toThrow();
    expect(() => toWordBytes(1n << 256n)).toThrow();

    expect(bytesToHex(encodeU64Be(0x0102030405060708n))).toBe("0x0102030405060708");
    expect(() => encodeU64Be(-1n)).toThrow();
  });

  test("decodeRevertBytes decodes Error(string), Panic(uint256), custom, raw, and empty", () => {
    expect(decodeRevertBytes(new Uint8Array(0))).toEqual({ kind: "empty", raw: "0x" });
    expect(decodeRevertBytes(new Uint8Array([0xaa, 0xbb]))).toEqual({ kind: "raw", raw: "0xaabb" });

    // Error("insufficient balance")
    const msg = encodeUtf8("insufficient balance");
    const errBuf = new Uint8Array(4 + 32 + 32 + 32);
    errBuf.set(hexToBytes("0x08c379a0"), 0);
    errBuf.set(toWordBytes(32n), 4);
    errBuf.set(toWordBytes(BigInt(msg.length)), 36);
    errBuf.set(msg, 68);
    expect(decodeRevertBytes(errBuf)).toMatchObject({
      kind: "error",
      selector: "0x08c379a0",
      reason: "insufficient balance",
    });

    // Panic(0x11) = arithmetic overflow
    const panicBuf = new Uint8Array(36);
    panicBuf.set(hexToBytes("0x4e487b71"), 0);
    panicBuf.set(toWordBytes(0x11n), 4);
    expect(decodeRevertBytes(panicBuf)).toMatchObject({
      kind: "panic",
      selector: "0x4e487b71",
      panicCode: 0x11,
    });

    // Custom 4-byte error
    expect(decodeRevertBytes(hexToBytes("0xdeadbeef0102"))).toEqual({
      kind: "custom",
      selector: "0xdeadbeef",
      raw: "0xdeadbeef0102",
    });
  });

  test("WasmMemoryBridge auto-frees scoped buffers and survives memory.grow()", () => {
    const { exports, liveAllocs } = makeMockExports();
    const bridge = new WasmMemoryBridge(exports);

    // Trigger memory growth with >64KiB buffer and verify clean read/free
    const large = new Uint8Array(70_000);
    large[0] = 0xde;
    large[69_999] = 0xad;
    const echoed = bridge.withBytes(large, (ptr, len) => bridge.readBytes(ptr, len));
    expect(echoed[0]).toBe(0xde);
    expect(echoed[69_999]).toBe(0xad);
    expect(liveAllocs.size).toBe(0);

    const text = bridge.readTextGetter(1, exports.evm_get_output_len, exports.evm_get_output);
    expect(text).toBe("guillotine-mini");
    expect(liveAllocs.size).toBe(0);
  });
});
