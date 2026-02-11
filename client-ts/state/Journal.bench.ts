import * as Cause from "effect/Cause";
import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import { Address } from "voltaire-effect/primitives";
import { EMPTY_ACCOUNT, type AccountStateType } from "./Account";
import {
  ChangeTag,
  EMPTY_SNAPSHOT,
  JournalLive,
  append,
  clear,
  commit,
  restore,
  takeSnapshot,
  type ChangeTagType,
  type JournalEntry,
} from "./Journal";

type BenchResult = {
  readonly label: string;
  readonly count: number;
  readonly ms: number;
  readonly opsPerSec: number;
  readonly msPerOp: number;
};

const makeAccount = (nonce: bigint): AccountStateType => ({
  ...EMPTY_ACCOUNT,
  nonce,
});

const makeAddress = (value: number): Address.AddressType => {
  const addr = Address.zero();
  let remaining = value;
  for (let i = addr.length - 1; i >= 0 && remaining > 0; i -= 1) {
    addr[i] = remaining & 0xff;
    remaining = Math.floor(remaining / 256);
  }
  return addr;
};

const entryTags: ReadonlyArray<ChangeTagType> = [
  ChangeTag.Create,
  ChangeTag.Update,
  ChangeTag.JustCache,
  ChangeTag.Delete,
  ChangeTag.Touch,
];

const makeEntry = (
  index: number,
): JournalEntry<Address.AddressType, AccountStateType> => {
  const tag = entryTags[index % entryTags.length] ?? ChangeTag.Update;
  const value = tag === ChangeTag.Delete ? null : makeAccount(BigInt(index));
  return {
    key: makeAddress(index),
    value,
    tag,
  };
};

const makeDataset = (count: number) => {
  const entries: JournalEntry<Address.AddressType, AccountStateType>[] = [];
  for (let i = 0; i < count; i += 1) {
    entries.push(makeEntry(i));
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

const benchAppend = (
  entries: ReadonlyArray<JournalEntry<Address.AddressType, AccountStateType>>,
) =>
  Effect.gen(function* () {
    for (const entry of entries) {
      yield* append(entry);
    }
  });

const benchRestore = (
  entries: ReadonlyArray<JournalEntry<Address.AddressType, AccountStateType>>,
) =>
  Effect.gen(function* () {
    yield* clear();
    for (const entry of entries) {
      yield* append(entry);
    }
    yield* restore<Address.AddressType, AccountStateType>(EMPTY_SNAPSHOT);
  });

const benchCommit = (
  entries: ReadonlyArray<JournalEntry<Address.AddressType, AccountStateType>>,
) =>
  Effect.gen(function* () {
    yield* clear();
    const baseCount = Math.floor(entries.length / 2);
    for (let i = 0; i < baseCount; i += 1) {
      const entry = entries[i];
      if (entry) {
        yield* append(entry);
      }
    }
    const snapshot = yield* takeSnapshot();
    for (let i = baseCount; i < entries.length; i += 1) {
      const entry = entries[i];
      if (entry) {
        yield* append(entry);
      }
    }
    yield* commit<Address.AddressType, AccountStateType>(snapshot);
  });

const runBenchmarks = (count: number) =>
  Effect.gen(function* () {
    const entries = makeDataset(count);
    const results: BenchResult[] = [];

    yield* clear();
    results.push(yield* measure("append", count, benchAppend(entries)));

    results.push(yield* measure("restore", count, benchRestore(entries)));

    const baseCount = Math.floor(count / 2);
    const commitCount = count - baseCount;
    results.push(yield* measure("commit", commitCount, benchCommit(entries)));

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
  const count = parseCount(process.env.JOURNAL_BENCH_COUNT, 100_000);
  const results = yield* runBenchmarks(count);

  yield* Effect.sync(() => {
    console.log("Journal benchmark (append + snapshot/restore)");
    console.log(`Entries: ${count}`);
    console.table(formatResults(results));
  });
});

pipe(
  main,
  Effect.provide(JournalLive),
  Effect.tapErrorCause((cause) =>
    Effect.sync(() => {
      console.error("Benchmark failed");
      console.error(Cause.pretty(cause));
    }),
  ),
  Effect.runPromise,
);
