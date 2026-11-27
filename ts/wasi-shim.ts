/**
 * Minimal pure-JavaScript WASI Preview 1 reactor shim.
 *
 * Works with zero Node.js dependencies across browsers (Chrome, Safari, Firefox),
 * Cloudflare Workers, Deno, Bun, and Node 22+.
 */

export const WASI_ERRNO = {
  SUCCESS: 0,
  BADF: 8,
  INVAL: 28,
  NOSYS: 52,
  SPIPE: 70,
} as const;

const WASI_FILETYPE_CHARACTER_DEVICE = 2;
const CRYPTO_CHUNK_LIMIT = 65_536;

export class WasiExitError extends Error {
  readonly code: number;

  constructor(code: number) {
    super(`WASI proc_exit(${code})`);
    this.name = "WasiExitError";
    this.code = code;
  }
}

export interface WasiShimOptions {
  /** Receive raw bytes written to stdout (fd 1). */
  onStdout?: (chunk: Uint8Array) => void;
  /** Receive raw bytes written to stderr (fd 2). */
  onStderr?: (chunk: Uint8Array) => void;
  /** Custom CSPRNG implementation; defaults to `crypto.getRandomValues`. */
  randomBytes?: (target: Uint8Array) => void;
  /** Custom monotonic/realtime clock in nanoseconds. */
  nowNs?: () => bigint;
}

export interface WasiShim {
  readonly wasiImport: Record<string, WebAssembly.ImportValue>;
  setMemory(memory: WebAssembly.Memory): void;
  initialize(instance: WebAssembly.Instance): void;
}

function defaultRandomBytes(target: Uint8Array): void {
  const webCrypto = globalThis.crypto;
  if (webCrypto && typeof webCrypto.getRandomValues === "function") {
    for (let offset = 0; offset < target.length; offset += CRYPTO_CHUNK_LIMIT) {
      const len = Math.min(CRYPTO_CHUNK_LIMIT, target.length - offset);
      if (target.buffer instanceof ArrayBuffer) {
        webCrypto.getRandomValues(new Uint8Array(target.buffer, target.byteOffset + offset, len));
      } else {
        const tmp = new Uint8Array(len);
        webCrypto.getRandomValues(tmp);
        target.set(tmp, offset);
      }
    }
    return;
  }
  for (let i = 0; i < target.length; i++) {
    target[i] = Math.floor(Math.random() * 256) & 0xff;
  }
}

/**
 * Create a WASI Preview 1 import namespace (`wasi_snapshot_preview1`) for
 * instantiating Zig WASI reactor modules in any JavaScript runtime.
 */
export function createWasiShim(options: WasiShimOptions = {}): WasiShim {
  let memory: WebAssembly.Memory | null = null;
  const fillRandom = options.randomBytes ?? defaultRandomBytes;
  const nowNs = options.nowNs ?? (() => BigInt(Date.now()) * 1_000_000n);

  function view(): DataView {
    if (!memory) throw new Error("WASI shim memory is not initialized");
    return new DataView(memory.buffer);
  }

  function bytes(): Uint8Array {
    if (!memory) throw new Error("WASI shim memory is not initialized");
    return new Uint8Array(memory.buffer);
  }

  function writeIovs(fd: number, iovsPtr: number, iovsLen: number, nwrittenPtr: number): number {
    if (fd !== 1 && fd !== 2) return WASI_ERRNO.BADF;
    const dv = view();
    const mem = bytes();
    const sink = fd === 1 ? options.onStdout : options.onStderr;
    let total = 0;
    const base = iovsPtr >>> 0;
    const count = iovsLen >>> 0;
    for (let i = 0; i < count; i++) {
      const ptr = dv.getUint32(base + i * 8, true);
      const len = dv.getUint32(base + i * 8 + 4, true);
      if (len > 0) {
        if (sink) sink(mem.slice(ptr, ptr + len));
        total += len;
      }
    }
    dv.setUint32(nwrittenPtr >>> 0, total, true);
    return WASI_ERRNO.SUCCESS;
  }

  function readZero(fd: number, nreadPtr: number): number {
    if (fd !== 0) return WASI_ERRNO.BADF;
    view().setUint32(nreadPtr >>> 0, 0, true);
    return WASI_ERRNO.SUCCESS;
  }

  const wasiImport: Record<string, WebAssembly.ImportValue> = {
    args_sizes_get(argcPtr: number, argvBufSizePtr: number): number {
      const dv = view();
      dv.setUint32(argcPtr >>> 0, 0, true);
      dv.setUint32(argvBufSizePtr >>> 0, 0, true);
      return WASI_ERRNO.SUCCESS;
    },
    args_get(): number {
      return WASI_ERRNO.SUCCESS;
    },
    environ_sizes_get(countPtr: number, bufSizePtr: number): number {
      const dv = view();
      dv.setUint32(countPtr >>> 0, 0, true);
      dv.setUint32(bufSizePtr >>> 0, 0, true);
      return WASI_ERRNO.SUCCESS;
    },
    environ_get(): number {
      return WASI_ERRNO.SUCCESS;
    },
    clock_res_get(_clockId: number, resPtr: number): number {
      view().setBigUint64(resPtr >>> 0, 1_000_000n, true);
      return WASI_ERRNO.SUCCESS;
    },
    clock_time_get(_clockId: number, _precision: bigint, timePtr: number): number {
      view().setBigUint64(timePtr >>> 0, nowNs(), true);
      return WASI_ERRNO.SUCCESS;
    },
    fd_close(fd: number): number {
      return fd >= 0 && fd <= 2 ? WASI_ERRNO.SUCCESS : WASI_ERRNO.BADF;
    },
    fd_fdstat_get(fd: number, bufPtr: number): number {
      if (fd < 0 || fd > 2) return WASI_ERRNO.BADF;
      const off = bufPtr >>> 0;
      bytes().fill(0, off, off + 24);
      view().setUint8(off, WASI_FILETYPE_CHARACTER_DEVICE);
      return WASI_ERRNO.SUCCESS;
    },
    fd_fdstat_set_flags(fd: number): number {
      return fd >= 0 && fd <= 2 ? WASI_ERRNO.SUCCESS : WASI_ERRNO.BADF;
    },
    fd_filestat_get(fd: number, bufPtr: number): number {
      if (fd < 0 || fd > 2) return WASI_ERRNO.BADF;
      const off = bufPtr >>> 0;
      bytes().fill(0, off, off + 64);
      view().setUint8(off + 16, WASI_FILETYPE_CHARACTER_DEVICE);
      return WASI_ERRNO.SUCCESS;
    },
    fd_prestat_get(): number {
      return WASI_ERRNO.BADF;
    },
    fd_prestat_dir_name(): number {
      return WASI_ERRNO.BADF;
    },
    fd_read(fd: number, _iovsPtr: number, _iovsLen: number, nreadPtr: number): number {
      return readZero(fd, nreadPtr);
    },
    fd_pread(fd: number, _iovsPtr: number, _iovsLen: number, _offset: bigint, nreadPtr: number): number {
      return readZero(fd, nreadPtr);
    },
    fd_write(fd: number, iovsPtr: number, iovsLen: number, nwrittenPtr: number): number {
      return writeIovs(fd, iovsPtr, iovsLen, nwrittenPtr);
    },
    fd_pwrite(fd: number, iovsPtr: number, iovsLen: number, _offset: bigint, nwrittenPtr: number): number {
      return writeIovs(fd, iovsPtr, iovsLen, nwrittenPtr);
    },
    fd_seek(fd: number, _offset: bigint, _whence: number, newOffsetPtr: number): number {
      if (fd < 0 || fd > 2) return WASI_ERRNO.BADF;
      view().setBigUint64(newOffsetPtr >>> 0, 0n, true);
      return WASI_ERRNO.SUCCESS;
    },
    fd_sync(fd: number): number {
      return fd >= 0 && fd <= 2 ? WASI_ERRNO.SUCCESS : WASI_ERRNO.BADF;
    },
    path_open(): number {
      return WASI_ERRNO.NOSYS;
    },
    poll_oneoff(): number {
      return WASI_ERRNO.NOSYS;
    },
    proc_exit(code: number): never {
      throw new WasiExitError(code >>> 0);
    },
    random_get(bufPtr: number, bufLen: number): number {
      const start = bufPtr >>> 0;
      const len = bufLen >>> 0;
      if (len > 0) fillRandom(bytes().subarray(start, start + len));
      return WASI_ERRNO.SUCCESS;
    },
    sched_yield(): number {
      return WASI_ERRNO.SUCCESS;
    },
  };

  return {
    wasiImport,
    setMemory(mem: WebAssembly.Memory): void {
      memory = mem;
    },
    initialize(instance: WebAssembly.Instance): void {
      const exportedMem = instance.exports.memory;
      if (exportedMem instanceof WebAssembly.Memory) {
        memory = exportedMem;
      }
      const initFn = instance.exports._initialize;
      if (typeof initFn === "function") {
        (initFn as () => void)();
      }
    },
  };
}
