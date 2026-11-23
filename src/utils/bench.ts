import { TsBenchSuite } from "../../scripts/bench-ts-utils.ts";
import {
  addMod256,
  subMod256,
  mulMod256,
  divMod256,
  sdivMod256,
  modMod256,
  smodMod256,
  slt,
  sgt,
  toSigned,
  toUnsigned,
} from "./bigint.ts";
import { shl256, shr256, sar256, byte256, mask256 } from "./bigint-bitwise.ts";
import {
  calculateMemoryExpansionCost,
  expandMemory,
  readMemory,
  writeMemory,
  copyMemory,
} from "./memory.ts";

const suite = new TsBenchSuite("ts/src-utils");

const a = 0x123456789abcdef0fedcba9876543210112233445566778899aabbccddeeff01n;
const b = 0x00000000000000010000000000000007000000000000000d0000000000000013n;
const N = 200_000;

suite.section("BigInt 256-bit Arithmetic (src/utils/bigint.ts)");
let sink = 0n;
suite.bench("addMod256", N, () => {
  for (let i = 0; i < N; i += 1) sink ^= addMod256(a + BigInt(i), b);
});
suite.bench("subMod256", N, () => {
  for (let i = 0; i < N; i += 1) sink ^= subMod256(a + BigInt(i), b);
});
suite.bench("mulMod256", N, () => {
  for (let i = 0; i < N; i += 1) sink ^= mulMod256(a + BigInt(i), b);
});
suite.bench("divMod256 / modMod256", N, () => {
  for (let i = 0; i < N; i += 1) {
    sink ^= divMod256(a + BigInt(i), b) ^ modMod256(a + BigInt(i), b);
  }
});
suite.bench("sdivMod256 / smodMod256", N, () => {
  for (let i = 0; i < N; i += 1) {
    sink ^= sdivMod256(a + BigInt(i), b) ^ smodMod256(a + BigInt(i), b);
  }
});
suite.bench("toSigned + toUnsigned + slt + sgt", N, () => {
  for (let i = 0; i < N; i += 1) {
    const s = toSigned(a + BigInt(i));
    sink ^= toUnsigned(s) ^ (slt(a, b) ? 1n : 0n) ^ (sgt(a, b) ? 2n : 0n);
  }
});

suite.section("BigInt 256-bit Bitwise (src/utils/bigint-bitwise.ts)");
suite.bench("shl256 + shr256 + sar256", N, () => {
  for (let i = 0; i < N; i += 1) {
    const sh = BigInt(i & 255);
    sink ^= shl256(a, sh) ^ shr256(a, sh) ^ sar256(a, sh);
  }
});
suite.bench("byte256 + mask256", N, () => {
  for (let i = 0; i < N; i += 1) {
    sink ^= byte256(BigInt(i & 31), a) ^ mask256(a + BigInt(i));
  }
});

suite.section("EVM Memory Helpers (src/utils/memory.ts)");
const memN = 50_000;
let numSink = 0;
suite.bench("calculateMemoryExpansionCost", memN, () => {
  for (let i = 0; i < memN; i += 1) {
    numSink += calculateMemoryExpansionCost(1024, 1024 + ((i & 63) * 32));
  }
});
let mem = expandMemory(new Uint8Array(0), 4096);
const word = new Uint8Array(32).fill(0xab);
suite.bench("writeMemory + readMemory (32B word)", memN, () => {
  for (let i = 0; i < memN; i += 1) {
    const off = (i & 63) * 32;
    mem = writeMemory(mem, off, word);
    const slice = readMemory(mem, off, 32);
    numSink += slice[0]!;
  }
});
suite.bench("copyMemory (1KB copy)", 10_000, () => {
  for (let i = 0; i < 10_000; i += 1) {
    mem = copyMemory(mem, 1024, 0, 1024);
    numSink += mem[1024]!;
  }
});

if (sink === 12345678901234567890n && numSink === -1) console.log("");
suite.finish();
