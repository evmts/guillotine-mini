import * as Cause from "effect/Cause";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import * as Layer from "effect/Layer";
import { Bytes, Hash, Hex, Rlp } from "voltaire-effect/primitives";
import type { BytesType, EncodedNode, TrieNode } from "./Node";
import { nibbleListToCompact } from "./encoding";
import { TrieNodeCodecTest } from "./NodeCodec";
import { ReadFlags } from "../db/Db";
import { DbMemoryTest, DbNames } from "../db/Db";
import {
  TrieNodeStorageKeyScheme,
  TrieNodeStorageTest,
  setNode,
  setNodeStorageScheme,
} from "./NodeStorage";
import { TrieNodeLoaderTest, loadTrieNode } from "./NodeLoader";
import { coerceEffect } from "./internal/effect";

type BenchResult = {
  readonly label: string;
  readonly count: number;
  readonly ms: number;
  readonly opsPerSec: number;
  readonly msPerOp: number;
};

class TrieNodeLoaderBenchError extends Data.TaggedError(
  "TrieNodeLoaderBenchError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

const toBytes = (u8: Uint8Array): BytesType => Bytes.concat(u8);
const bytesFromHex = (hex: string): BytesType => Hex.toBytes(hex) as BytesType;

const encodeRlp = (data: Parameters<typeof Rlp.encode>[0]) =>
  coerceEffect<Uint8Array, unknown>(Rlp.encode(data));

const makeWord = (v: number): Uint8Array => {
  const out = new Uint8Array(32);
  out[28] = (v >>> 24) & 0xff;
  out[29] = (v >>> 16) & 0xff;
  out[30] = (v >>> 8) & 0xff;
  out[31] = v & 0xff;
  return out;
};

type Fixture = {
  readonly raw: EncodedNode & { readonly _tag: "raw" };
  readonly encoded: BytesType;
  readonly hash: BytesType;
};
