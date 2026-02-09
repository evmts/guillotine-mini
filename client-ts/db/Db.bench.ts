import * as Cause from "effect/Cause";
import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import { Hex } from "voltaire-effect/primitives";
import {
  clear,
  DbMemoryTest,
  get,
  put,
  startWriteBatch,
  writeBatch,
  type BytesType,
  type DbWriteOp,
} from "./Db";

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

const makeBytes = (value: number, byteLength = 32): BytesType =>
  Hex.toBytes(
    `0x${value.toString(16).padStart(byteLength * 2, "0")}`,
  ) as BytesType;

const makeDataset = (count: number) => {
  const entries: BenchEntry[] = [];
  for (let i = 0; i < count; i += 1) {
    entries.push({ key: makeBytes(i), value: makeBytes(i + count) });
  }
  return entries;
};

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

const benchPut = (entries: ReadonlyArray<BenchEntry>) =>
  Effect.gen(function* () {
    for (const entry of entries) {
      yield* put(entry.key, entry.value);
    }
  });

const benchGet = (keys: ReadonlyArray<BytesType>) =>
  Effect.gen(function* () {
    for (const key of keys) {
      yield* get(key);
    }
  });

const benchWriteBatch = (ops: ReadonlyArray<DbWriteOp>) => writeBatch(ops);

const benchScopedBatch = (entries: ReadonlyArray<BenchEntry>) =>
  Effect.scoped(
    Effect.gen(function* () {
      const batch = yield* startWriteBatch();
      for (const entry of entries) {
        yield* batch.put(entry.key, entry.value);
      }
    }),
  );

const runBenchmarks = (count: number) =>
  Effect.gen(function* () {
    const entries = makeDataset(count);
    const keys = entries.map((entry) => entry.key);
    const ops: DbWriteOp[] = entries.map((entry) => ({
      _tag: "put",
      key: entry.key,
      value: entry.value,
    }));

    const results: BenchResult[] = [];

    yield* clear();
    results.push(yield* measure("put", count, benchPut(entries)));

    results.push(yield* measure("get", count, benchGet(keys)));

    yield* clear();
    results.push(yield* measure("writeBatch", count, benchWriteBatch(ops)));

    yield* clear();
    results.push(
      yield* measure("scopedWriteBatch", count, benchScopedBatch(entries)),
    );

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

const main = Effect.gen(function* () {
  const count = 50_000;
  const results = yield* runBenchmarks(count);

  yield* Effect.sync(() => {
    console.log("Db benchmark (in-memory)");
    console.log(`Entries: ${count}`);
    console.table(formatResults(results));
  });
});

pipe(
  main,
  Effect.provide(DbMemoryTest()),
  Effect.tapErrorCause((cause) =>
    Effect.sync(() => {
      console.error("Benchmark failed");
      console.error(Cause.pretty(cause));
    }),
  ),
  Effect.runPromise,
);
