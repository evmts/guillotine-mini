import * as Effect from "effect/Effect";
import { Bytes } from "voltaire-effect/primitives";
import { DbMemoryTest, get, put, writeBatch } from "./Db";
import type { BytesType, DbWriteOp } from "./Db";

interface BenchResult {
  readonly label: string;
  readonly operations: number;
  readonly durationMs: number;
  readonly opsPerSecond: number;
}

const makeData = (count: number, size: number) => {
  const keys = new Array<BytesType>(count);
  const values = new Array<BytesType>(count);

  for (let i = 0; i < count; i += 1) {
    keys[i] = Bytes.random(32) as BytesType;
    values[i] = Bytes.random(size) as BytesType;
  }

  return { keys, values } as const;
};

const measure = <E, R>(
  label: string,
  operations: number,
  effect: Effect.Effect<void, E, R>,
): Effect.Effect<BenchResult, E, R> =>
  Effect.gen(function* () {
    const start = performance.now();
    yield* effect;
    const durationMs = performance.now() - start;
    const opsPerSecond = operations / (durationMs / 1000);

    return {
      label,
      operations,
      durationMs,
      opsPerSecond,
    } satisfies BenchResult;
  });

const logResults = (title: string, results: ReadonlyArray<BenchResult>) =>
  Effect.sync(() => {
    console.log(`\n${title}`);
    for (const result of results) {
      console.log(
        `${result.label}: ${result.operations.toLocaleString()} ops in ${result.durationMs.toFixed(
          2,
        )} ms (${result.opsPerSecond.toFixed(0)} ops/s)`,
      );
    }
  });

const runPutGetBench = (count: number, valueSize: number) =>
  Effect.scoped(
    Effect.gen(function* () {
      const { keys, values } = makeData(count, valueSize);

      const putResult = yield* measure(
        "db.put",
        count,
        Effect.gen(function* () {
          for (let i = 0; i < count; i += 1) {
            const key = keys[i]!;
            const value = values[i]!;
            yield* put(key, value);
          }
        }),
      );

      const getResult = yield* measure(
        "db.get",
        count,
        Effect.gen(function* () {
          for (let i = 0; i < count; i += 1) {
            const key = keys[i]!;
            yield* get(key);
          }
        }),
      );

      yield* logResults("In-memory DB put/get", [putResult, getResult]);
    }).pipe(Effect.provide(DbMemoryTest())),
  );

const runWriteBatchBench = (count: number, valueSize: number) =>
  Effect.scoped(
    Effect.gen(function* () {
      const { keys, values } = makeData(count, valueSize);
      const ops: Array<DbWriteOp> = [];
      for (let i = 0; i < count; i += 1) {
        ops.push({
          _tag: "put",
          key: keys[i]!,
          value: values[i]!,
        });
      }

      const batchResult = yield* measure(
        "db.writeBatch(put)",
        count,
        writeBatch(ops),
      );

      yield* logResults("In-memory DB batch", [batchResult]);
    }).pipe(Effect.provide(DbMemoryTest())),
  );

const program = Effect.gen(function* () {
  const count = 100_000;
  const valueSize = 32;

  yield* runPutGetBench(count, valueSize);
  yield* runWriteBatchBench(count, valueSize);
});

Effect.runPromise(program).catch((error) => {
  console.error("Benchmark failed:", error);
  process.exitCode = 1;
});
