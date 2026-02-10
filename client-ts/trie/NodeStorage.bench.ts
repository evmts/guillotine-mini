import * as Cause from "effect/Cause";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import { Rlp } from "voltaire-effect/primitives";
import { DbMemoryTest, DbNames, clear } from "../db/Db";
import type { BytesType } from "./Node";
import {
  getNode,
  persistEncodedNode,
  TrieNodeStorageTest,
} from "./NodeStorage";
import { coerceEffect } from "./internal/effect";

type BenchResult = {
  readonly label: string;
  readonly count: number;
  readonly ms: number;
  readonly opsPerSec: number;
  readonly msPerOp: number;
};

type MemoryResult = {
  readonly rounds: number;
  readonly startHeapBytes: number;
  readonly endHeapBytes: number;
  readonly deltaHeapBytes: number;
};

class TrieNodeStorageBenchError extends Data.TaggedError(
  "TrieNodeStorageBenchError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

const encodeRlp = (value: Parameters<typeof Rlp.encode>[0]) =>
  coerceEffect<Uint8Array, unknown>(Rlp.encode(value));

const makeWord = (value: number): Uint8Array => {
  const bytes = new Uint8Array(32);
  bytes[28] = (value >>> 24) & 0xff;
  bytes[29] = (value >>> 16) & 0xff;
  bytes[30] = (value >>> 8) & 0xff;
  bytes[31] = value & 0xff;
  return bytes;
};

const makeLargeDataset = (count: number) =>
  Effect.gen(function* () {
    const entries: BytesType[] = [];
    for (let i = 0; i < count; i += 1) {
      const encoded = yield* encodeRlp([makeWord(i), makeWord(i + count)]);
      entries.push(encoded as BytesType);
    }
    return entries;
  });

const makeInlineDataset = (count: number) =>
  Effect.gen(function* () {
    const entries: BytesType[] = [];
    for (let i = 0; i < count; i += 1) {
      const encoded = yield* encodeRlp([new Uint8Array([i & 0xff])]);
      entries.push(encoded as BytesType);
    }
    return entries;
  });

const runGc = () =>
  Effect.sync(() => {
    const runtime = globalThis as { gc?: () => void };
    if (typeof runtime.gc === "function") {
      runtime.gc();
    }
  });

const currentHeapUsedBytes = () =>
  Effect.sync(() => {
    if (
      typeof process === "undefined" ||
      typeof process.memoryUsage !== "function"
    ) {
      return 0;
    }
    return process.memoryUsage().heapUsed;
  });

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

const benchPersistHashed = (encodedNodes: ReadonlyArray<BytesType>) =>
  Effect.gen(function* () {
    for (const encodedNode of encodedNodes) {
      const reference = yield* persistEncodedNode(encodedNode);
      if (reference._tag !== "hash") {
        return yield* Effect.fail(
          new TrieNodeStorageBenchError({
            message: "Expected hash reference for large encoded node",
          }),
        );
      }
    }
  });

const benchPersistHashedRoundTrip = (encodedNodes: ReadonlyArray<BytesType>) =>
  Effect.gen(function* () {
    for (const encodedNode of encodedNodes) {
      const reference = yield* persistEncodedNode(encodedNode);
      if (reference._tag !== "hash") {
        return yield* Effect.fail(
          new TrieNodeStorageBenchError({
            message: "Expected hash reference for large encoded node",
          }),
        );
      }
      yield* getNode(reference.value);
    }
  });

const benchPersistInline = (encodedNodes: ReadonlyArray<BytesType>) =>
  Effect.gen(function* () {
    for (const encodedNode of encodedNodes) {
      const reference = yield* persistEncodedNode(encodedNode);
      if (reference._tag !== "raw") {
        return yield* Effect.fail(
          new TrieNodeStorageBenchError({
            message: "Expected inline raw reference for short encoded node",
          }),
        );
      }
    }
  });

const measureHeapStability = (
  encodedNodes: ReadonlyArray<BytesType>,
  rounds: number,
) =>
  Effect.gen(function* () {
    yield* runGc();
    const startHeapBytes = yield* currentHeapUsedBytes();

    for (let i = 0; i < rounds; i += 1) {
      yield* clear();
      yield* benchPersistHashed(encodedNodes);
    }

    yield* runGc();
    const endHeapBytes = yield* currentHeapUsedBytes();

    return {
      rounds,
      startHeapBytes,
      endHeapBytes,
      deltaHeapBytes: endHeapBytes - startHeapBytes,
    } satisfies MemoryResult;
  });

const runBenchmarks = (count: number, memoryRounds: number) =>
  Effect.gen(function* () {
    const largeEntries = yield* makeLargeDataset(count);
    const inlineEntries = yield* makeInlineDataset(count);
    const results: BenchResult[] = [];

    yield* clear();
    results.push(
      yield* measure("persist-hash", count, benchPersistHashed(largeEntries)),
    );

    yield* clear();
    results.push(
      yield* measure(
        "persist-hash+get",
        count,
        benchPersistHashedRoundTrip(largeEntries),
      ),
    );

    yield* clear();
    results.push(
      yield* measure(
        "persist-inline",
        count,
        benchPersistInline(inlineEntries),
      ),
    );

    const memory = yield* measureHeapStability(largeEntries, memoryRounds);

    return { results, memory } as const;
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
  const count = parseCount(process.env.NODE_STORAGE_BENCH_COUNT, 20_000);
  const memoryRounds = parseCount(process.env.NODE_STORAGE_BENCH_ROUNDS, 5);
  const { results, memory } = yield* runBenchmarks(count, memoryRounds);

  yield* Effect.sync(() => {
    console.log("Trie node storage benchmark (persistEncodedNode)");
    console.log(`Entries: ${count}`);
    console.log(`Heap rounds: ${memoryRounds}`);
    console.table(formatResults(results));
    console.log(
      "Heap delta (bytes):",
      memory.deltaHeapBytes,
      `(start=${memory.startHeapBytes}, end=${memory.endHeapBytes})`,
    );
  });
});

pipe(
  main,
  Effect.provide(TrieNodeStorageTest),
  Effect.provide(DbMemoryTest({ name: DbNames.state })),
  Effect.tapErrorCause((cause) =>
    Effect.sync(() => {
      console.error("Benchmark failed");
      console.error(Cause.pretty(cause));
    }),
  ),
  Effect.runPromise,
);
