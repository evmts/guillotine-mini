import { describe, expect, test } from "bun:test";
import { WASI_ERRNO, WasiExitError, createWasiShim } from "./wasi-shim.ts";

describe("wasi-shim", () => {
  test("writes stdout and stderr via iovecs and handles memory growth", () => {
    const stdout: string[] = [];
    const stderr: string[] = [];
    const dec = new TextDecoder();
    const shim = createWasiShim({
      onStdout: (c) => stdout.push(dec.decode(c)),
      onStderr: (c) => stderr.push(dec.decode(c)),
    });
    const memory = new WebAssembly.Memory({ initial: 1 });
    shim.setMemory(memory);

    const enc = new TextEncoder();
    const msgA = enc.encode("hello ");
    const msgB = enc.encode("wasi!");
    const bytes = new Uint8Array(memory.buffer);
    bytes.set(msgA, 64);
    bytes.set(msgB, 128);

    const dv = new DataView(memory.buffer);
    // Two iovecs at offset 0: [ptr, len]
    dv.setUint32(0, 64, true);
    dv.setUint32(4, msgA.length, true);
    dv.setUint32(8, 128, true);
    dv.setUint32(12, msgB.length, true);

    const fdWrite = shim.wasiImport.fd_write as (fd: number, iovs: number, len: number, nwritten: number) => number;
    expect(fdWrite(1, 0, 2, 32)).toBe(WASI_ERRNO.SUCCESS);
    expect(dv.getUint32(32, true)).toBe(msgA.length + msgB.length);
    expect(stdout.join("")).toBe("hello wasi!");

    // Grow linear memory and verify fresh DataView / Uint8Array after detach
    memory.grow(1);
    const dv2 = new DataView(memory.buffer);
    expect(fdWrite(2, 0, 1, 32)).toBe(WASI_ERRNO.SUCCESS);
    expect(dv2.getUint32(32, true)).toBe(msgA.length);
    expect(stderr.join("")).toBe("hello ");

    // Unknown file descriptor returns BADF
    expect(fdWrite(99, 0, 1, 32)).toBe(WASI_ERRNO.BADF);
  });

  test("random_get fills large buffers across WebCrypto chunk boundaries", () => {
    const shim = createWasiShim();
    const memory = new WebAssembly.Memory({ initial: 3 });
    shim.setMemory(memory);

    const randomGet = shim.wasiImport.random_get as (ptr: number, len: number) => number;
    // Exceeds 65536-byte WebCrypto single-call cap
    expect(randomGet(16, 70_000)).toBe(WASI_ERRNO.SUCCESS);
    const slice = new Uint8Array(memory.buffer, 16, 70_000);
    const nonZero = slice.some((b) => b !== 0);
    expect(nonZero).toBe(true);
  });

  test("fd_filestat_get, fd_read, fd_seek, clocks, args, environ, and proc_exit", () => {
    const fixedNs = 1_720_000_000_000_000_000n;
    const shim = createWasiShim({ nowNs: () => fixedNs });
    const memory = new WebAssembly.Memory({ initial: 1 });
    shim.setMemory(memory);
    const dv = new DataView(memory.buffer);

    const fdFilestat = shim.wasiImport.fd_filestat_get as (fd: number, ptr: number) => number;
    expect(fdFilestat(1, 0)).toBe(WASI_ERRNO.SUCCESS);
    expect(dv.getUint8(16)).toBe(2); // CHARACTER_DEVICE
    expect(fdFilestat(7, 0)).toBe(WASI_ERRNO.BADF);

    const fdRead = shim.wasiImport.fd_read as (fd: number, iovs: number, len: number, nread: number) => number;
    expect(fdRead(0, 0, 0, 80)).toBe(WASI_ERRNO.SUCCESS);
    expect(dv.getUint32(80, true)).toBe(0);
    expect(fdRead(5, 0, 0, 80)).toBe(WASI_ERRNO.BADF);

    const fdSeek = shim.wasiImport.fd_seek as (fd: number, off: bigint, whence: number, out: number) => number;
    expect(fdSeek(1, 0n, 0, 88)).toBe(WASI_ERRNO.SUCCESS);
    expect(dv.getBigUint64(88, true)).toBe(0n);

    const clockTime = shim.wasiImport.clock_time_get as (id: number, prec: bigint, out: number) => number;
    expect(clockTime(0, 1n, 96)).toBe(WASI_ERRNO.SUCCESS);
    expect(dv.getBigUint64(96, true)).toBe(fixedNs);

    const argsSizes = shim.wasiImport.args_sizes_get as (argc: number, size: number) => number;
    expect(argsSizes(104, 108)).toBe(WASI_ERRNO.SUCCESS);
    expect(dv.getUint32(104, true)).toBe(0);
    expect(dv.getUint32(108, true)).toBe(0);

    const procExit = shim.wasiImport.proc_exit as (code: number) => never;
    expect(() => procExit(42)).toThrow(WasiExitError);
    try {
      procExit(7);
    } catch (err) {
      expect(err).toBeInstanceOf(WasiExitError);
      expect((err as WasiExitError).code).toBe(7);
    }
  });

  test("initialize binds exported memory and invokes _initialize", () => {
    let initialized = false;
    const memory = new WebAssembly.Memory({ initial: 1 });
    const fakeInstance = {
      exports: {
        memory,
        _initialize: () => {
          initialized = true;
        },
      },
    } as unknown as WebAssembly.Instance;

    const shim = createWasiShim();
    shim.initialize(fakeInstance);
    expect(initialized).toBe(true);
    const randomGet = shim.wasiImport.random_get as (ptr: number, len: number) => number;
    expect(randomGet(0, 8)).toBe(WASI_ERRNO.SUCCESS);
  });
});
