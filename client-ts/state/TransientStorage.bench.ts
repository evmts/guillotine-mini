import * as Cause from "effect/Cause";
import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import { Address } from "voltaire-effect/primitives";
import {
  TransientStorageLive,
  clear,
  commitSnapshot,
  getTransientStorage,
  restoreSnapshot,
  setTransientStorage,
  takeSnapshot,
} from "./TransientStorage";

type BenchResult = {
  readonly label: string;
  readonly count: number;
  readonly ms: number;
  readonly opsPerSec: number;
  readonly msPerOp: number;
};

type StorageSlotType = Parameters<typeof setTransientStorage>[1];
type StorageValueType = Parameters<typeof setTransientStorage>[2];

type BenchEntry = {
  readonly address: Address.AddressType;
  readonly slot: StorageSlotType;
  readonly value: StorageValueType;
};

const makeAddress = (value: number): Address.AddressType => {
  const addr = Address.zero();
  let remaining = value;
  for (let i = addr.length - 1; i >= 0 && remaining > 0; i -= 1) {
    addr[i] = remaining & 0xff;
    remaining = Math.floor(remaining / 256);
  }
  return addr;
};

const makeSlot = (value: number): StorageSlotType => {
  const bytes = new Uint8Array(32);
  let remaining = value;
  for (let i = bytes.length - 1; i >= 0 && remaining > 0; i -= 1) {
    bytes[i] = remaining & 0xff;
    remaining = Math.floor(remaining / 256);
  }
  return bytes as StorageSlotType;
};

const makeStorageValue = (byte: number): StorageValueType => {
  const bytes = new Uint8Array(32);
  bytes.fill(byte & 0xff);
  return bytes as StorageValueType;
};

const makeDataset = (count: number, seed: number) => {
  const entries: BenchEntry[] = [];
  for (let i = 0; i < count; i += 1) {
    entries.push({
      address: makeAddress(i),
      slot: makeSlot(i),
      value: makeStorageValue(seed + i),
    });
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

const benchSet = (entries: ReadonlyArray<BenchEntry>) =>
  Effect.gen(function* () {
    for (const entry of entries) {
      yield* setTransientStorage(entry.address, entry.slot, entry.value);
    }
  });

const benchGet = (entries: ReadonlyArray<BenchEntry>) =>
  Effect.gen(function* () {
    for (const entry of entries) {
      yield* getTransientStorage(entry.address, entry.slot);
    }
  });

const benchSnapshotRestore = (updates: ReadonlyArray<BenchEntry>) =>
  Effect.gen(function* () {
    const snapshot = yield* takeSnapshot();
    yield* benchSet(updates);
    yield* restoreSnapshot(snapshot);
  });

const benchSnapshotCommit = (updates: ReadonlyArray<BenchEntry>) =>
  Effect.gen(function* () {
    const snapshot = yield* takeSnapshot();
    yield* benchSet(updates);
    yield* commitSnapshot(snapshot);
  });

const runBenchmarks = (count: number) =>
  Effect.gen(function* () {
    const base = makeDataset(count, 1);
    const updates = makeDataset(count, count + 5);
    const results: BenchResult[] = [];

    yield* clear();
    results.push(yield* measure("set", count, benchSet(base)));

    yield* clear();
    yield* benchSet(base);
    results.push(yield* measure("get", count, benchGet(base)));

    yield* clear();
    yield* benchSet(base);
    results.push(
      yield* measure("snapshot-restore", count, benchSnapshotRestore(updates)),
    );

    yield* clear();
    yield* benchSet(base);
    results.push(
      yield* measure("snapshot-commit", count, benchSnapshotCommit(updates)),
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
  const count = parseCount(process.env.TRANSIENT_STORAGE_BENCH_COUNT, 100_000);
  const results = yield* runBenchmarks(count);

  yield* Effect.sync(() => {
    console.log("Transient storage benchmark (set/get + snapshot)");
    console.log(`Entries: ${count}`);
    console.table(formatResults(results));
  });
});

pipe(
  main,
  Effect.provide(TransientStorageLive),
  Effect.tapErrorCause((cause) =>
    Effect.sync(() => {
      console.error("Benchmark failed");
      console.error(Cause.pretty(cause));
    }),
  ),
  Effect.runPromise,
);
