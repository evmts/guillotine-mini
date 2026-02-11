import * as Cause from "effect/Cause";
import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import { Hex } from "voltaire-effect/primitives";
import { DbMemoryTest, clear, put, seek, range, type BytesType } from "./Db";

type BenchResult = {
  readonly label: string;
  readonly count: number;
  readonly ms: number;
  readonly opsPerSec: number;
  readonly msPerOp: number;
};

const makeBytes = (hex: string): BytesType => Hex.toBytes(hex) as BytesType;

const keyOf = (prefix: number, idx: number): BytesType =>
  // 2 bytes prefix + 2 bytes idx = 4 bytes key
  makeBytes(
    `0x${prefix.toString(16).padStart(4, "0")}${idx
      .toString(16)
      .padStart(4, "0")}`,
  );

const valueOf = (n: number): BytesType =>
  // Use small values; DB copies on write so avoid huge buffers here
  makeBytes(`0x${n.toString(16).padStart(2, "0")}`);

const populate = (prefixes: number, perPrefix: number) =>
  Effect.gen(function* () {
    for (let p = 0; p < prefixes; p += 1) {
      for (let i = 0; i < perPrefix; i += 1) {
        const k = keyOf(p, i);
        yield* put(k, valueOf((p + i) & 0xff));
      }
    }
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
      msPerOp: safeMs / Math.max(count, 1),
    } satisfies BenchResult;
  });

const benchSeekExact = (prefixes: number, perPrefix: number) =>
  Effect.gen(function* () {
    for (let p = 0; p < prefixes; p += 1) {
      for (let i = 0; i < perPrefix; i += 1) {
        const k = keyOf(p, i);
        yield* seek(k);
      }
    }
  });

const benchSeekPrefix = (prefixes: number, perPrefix: number) =>
  Effect.gen(function* () {
    for (let p = 0; p < prefixes; p += 1) {
      const prefix = keyOf(p, 0).slice(0, 2) as BytesType; // first 2 bytes
      yield* seek(prefix, { prefix });
    }
  });

const benchRangeAll = () => range();

const benchRangePrefix = (prefixes: number) =>
  Effect.gen(function* () {
    for (let p = 0; p < prefixes; p += 1) {
      const prefix = keyOf(p, 0).slice(0, 2) as BytesType;
      const _ = yield* range({ prefix });
      void _;
    }
  });

const run = (prefixes: number, perPrefix: number) =>
  Effect.gen(function* () {
    const total = prefixes * perPrefix;
    yield* clear();
    yield* populate(prefixes, perPrefix);

    const results: BenchResult[] = [];

    results.push(
      yield* measure("seek(exact)", total, benchSeekExact(prefixes, perPrefix)),
    );

    results.push(
      yield* measure(
        "seek(prefix)",
        prefixes,
        benchSeekPrefix(prefixes, perPrefix),
      ),
    );

    results.push(yield* measure("range(all)", 1, benchRangeAll()));

    results.push(
      yield* measure("range(prefix)", prefixes, benchRangePrefix(prefixes)),
    );

    return results;
  });

const format = (results: ReadonlyArray<BenchResult>) =>
  results.map((r) => ({
    label: r.label,
    count: r.count,
    ms: r.ms,
    msPerOp: Number(r.msPerOp.toFixed(6)),
    opsPerSec: Math.round(r.opsPerSec),
  }));

const main = Effect.gen(function* () {
  const prefixes = 256; // 2-byte prefix space
  const perPrefix = 200; // total 51,200 keys
  const results = yield* run(prefixes, perPrefix);

  yield* Effect.sync(() => {
    console.log("Db iterator benchmark (in-memory)");
    console.log(`Prefixes: ${prefixes}, PerPrefix: ${perPrefix}`);
    console.table(format(results));
  });
});

pipe(
  main,
  Effect.provide(DbMemoryTest()),
  Effect.tapErrorCause((cause) =>
    Effect.sync(() => {
      console.error("Iterator benchmark failed");
      console.error(Cause.pretty(cause));
    }),
  ),
  Effect.runPromise,
);
