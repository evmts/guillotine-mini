import * as Cause from "effect/Cause";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import * as Layer from "effect/Layer";
import { Hash, Rlp } from "voltaire-effect/primitives";
import type { BytesType, EncodedNode, HashType, NibbleList } from "./Node";
import { bytesToNibbleList } from "./encoding";
import { encodeInternalNode, TrieHashError, TrieHashLive } from "./hash";
import { coerceEffect } from "./internal/effect";
import { makeBytesHelpers, makeHashHelpers } from "./internal/primitives";
import {
  PatricializeError,
  patricialize,
  TriePatricializeLive,
} from "./patricialize";

type BenchResult = {
  readonly label: string;
  readonly count: number;
  readonly ms: number;
  readonly opsPerSec: number;
  readonly msPerOp: number;
};

type BenchEntry = {
  readonly key: BytesType;
  readonly value: BytesType;
};

class TrieBenchError extends Data.TaggedError("TrieBenchError")<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

const { bytesFromHex } = makeBytesHelpers(
  (message) => new TrieBenchError({ message }),
);
const { hashFromHex } = makeHashHelpers(
  (message) => new TrieBenchError({ message }),
);
const encodeRlp = (data: Parameters<typeof Rlp.encode>[0]) =>
  coerceEffect<Uint8Array, unknown>(Rlp.encode(data));
const keccak256 = (data: Uint8Array) =>
  coerceEffect<HashType, never>(Hash.keccak256(data));
const EmptyTrieRoot = hashFromHex(
  "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
);

const makeBytes = (value: number, byteLength = 32): BytesType =>
  bytesFromHex(`0x${value.toString(16).padStart(byteLength * 2, "0")}`);

const makeDataset = (count: number) => {
  const entries: BenchEntry[] = [];
  for (let i = 0; i < count; i += 1) {
    entries.push({ key: makeBytes(i), value: makeBytes(i + count) });
  }
  return entries;
};

const buildNibbleMap = (entries: ReadonlyArray<BenchEntry>) =>
  Effect.gen(function* () {
    const map = new Map<NibbleList, BytesType>();
    for (const entry of entries) {
      const nibbleKey = yield* bytesToNibbleList(entry.key);
      map.set(nibbleKey, entry.value);
    }
    return map;
  });

const encodedNodeToRoot = (
  encoded: EncodedNode,
): Effect.Effect<HashType, TrieBenchError> => {
  switch (encoded._tag) {
    case "hash":
      return Effect.succeed(encoded.value);
    case "raw":
      return encodeRlp(encoded.value).pipe(
        Effect.flatMap((encodedNode) => keccak256(encodedNode)),
        Effect.mapError(
          (cause) =>
            new TrieBenchError({
              message: "Failed to encode root node",
              cause,
            }),
        ),
      );
    case "empty":
      return Effect.succeed(EmptyTrieRoot);
  }
};

const computeRoot = (entries: ReadonlyArray<BenchEntry>) =>
  Effect.gen(function* () {
    const nibbleMap = yield* buildNibbleMap(entries);
    const node = yield* patricialize(nibbleMap, 0);
    const encoded = yield* encodeInternalNode(node);
    return yield* encodedNodeToRoot(encoded);
  });

const benchInsert = (entries: ReadonlyArray<BenchEntry>) =>
  Effect.asVoid(computeRoot(entries));

const measure = <R, E>(
  label: string,
  count: number,
  effect: Effect.Effect<void, E, R>,
): Effect.Effect<BenchResult, E, R> =>
  Effect.gen(function* () {
    const start = Date.now();
    yield* effect;
    const ms = Date.now() - start;
    const safeMs = ms === 0 ? 1 : ms;
    return {
      label,
      count,
      ms,
      opsPerSec: (count / safeMs) * 1000,
      msPerOp: safeMs / count,
    } satisfies BenchResult;
  });

const runBenchmarks = (count: number) =>
  Effect.gen(function* () {
    const entries = makeDataset(count);
    const results: BenchResult[] = [];

    results.push(yield* measure("insert+root", count, benchInsert(entries)));
    return results;
  });

const formatResults = (results: ReadonlyArray<BenchResult>) =>
  results.map((result) => ({
    label: result.label,
    count: result.count,
    ms: result.ms,
    msPerOp: Number(result.msPerOp.toFixed(6)),
    opsPerSec: Math.round(result.opsPerSec),
  }));

const parseCount = (value: string | undefined, fallback: number) => {
  if (value === undefined) {
    return fallback;
  }
  const parsed = Number(value);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return fallback;
  }
  return Math.floor(parsed);
};

const main = Effect.gen(function* () {
  const count = parseCount(process.env.TRIE_BENCH_COUNT, 10_000);
  const results = yield* runBenchmarks(count);

  yield* Effect.sync(() => {
    console.log("Trie benchmark (patricialize + root)");
    console.log(`Entries: ${count}`);
    console.table(formatResults(results));
  });
});

const TrieBenchLayer = Layer.merge(
  TrieHashLive,
  TriePatricializeLive.pipe(Layer.provide(TrieHashLive)),
);

pipe(
  main,
  Effect.provide(TrieBenchLayer),
  Effect.tapErrorCause((cause) =>
    Effect.sync(() => {
      console.error("Benchmark failed");
      console.error(Cause.pretty(cause));
    }),
  ),
  Effect.runPromise,
);
