import * as Cause from "effect/Cause";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import * as Layer from "effect/Layer";
import { Address } from "voltaire-effect/primitives";
import { EMPTY_ACCOUNT, type AccountStateType } from "../state/Account";
import {
  clear as clearWorldState,
  setAccount,
  setStorage,
} from "../state/State";
import { TransactionBoundaryTest } from "../state/TransactionBoundary";
import {
  clear as clearTransientState,
  setTransientStorage,
} from "../state/TransientStorage";
import {
  runInCallFrameBoundary,
  runInTransactionBoundary,
  TransactionProcessorTest,
} from "./TransactionProcessor";

type BenchResult = {
  readonly label: string;
  readonly count: number;
  readonly ms: number;
  readonly opsPerSec: number;
  readonly msPerOp: number;
};

type StorageSlotType = Parameters<typeof setStorage>[1];
type StorageValueType = Parameters<typeof setStorage>[2];

type BenchEntry = {
  readonly address: Address.AddressType;
  readonly slot: StorageSlotType;
  readonly account: AccountStateType;
  readonly outerValue: StorageValueType;
  readonly innerValue: StorageValueType;
};

class BoundaryRollbackError extends Data.TaggedError("BoundaryRollbackError")<{
  readonly phase: "transaction" | "call-frame";
}> {}

const TransactionProcessorBenchLayer = Layer.mergeAll(
  TransactionProcessorTest,
  TransactionBoundaryTest,
);

const makeAccount = (nonce: bigint): AccountStateType => ({
  ...EMPTY_ACCOUNT,
  nonce,
});

const makeAddress = (value: number): Address.AddressType => {
  const bytes = Address.zero();
  let remaining = value;
  for (let i = bytes.length - 1; i >= 0 && remaining > 0; i -= 1) {
    bytes[i] = remaining & 0xff;
    remaining = Math.floor(remaining / 256);
  }
  return bytes;
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

const makeDataset = (count: number) => {
  const entries: BenchEntry[] = [];
  for (let i = 0; i < count; i += 1) {
    entries.push({
      address: makeAddress(i + 1),
      slot: makeSlot(i + 1),
      account: makeAccount(BigInt(i + 1)),
      outerValue: makeStorageValue(i + 31),
      innerValue: makeStorageValue(i + 127),
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

const clearState = () =>
  Effect.gen(function* () {
    yield* clearWorldState();
    yield* clearTransientState();
  });

const benchTxCommit = (entries: ReadonlyArray<BenchEntry>) =>
  Effect.gen(function* () {
    for (const entry of entries) {
      yield* runInTransactionBoundary(
        Effect.gen(function* () {
          yield* setAccount(entry.address, entry.account);
          yield* setStorage(entry.address, entry.slot, entry.outerValue);
          yield* setTransientStorage(
            entry.address,
            entry.slot,
            entry.outerValue,
          );
        }),
      );
    }
  });

const benchTxRollback = (entries: ReadonlyArray<BenchEntry>) =>
  Effect.gen(function* () {
    for (const entry of entries) {
      yield* Effect.either(
        runInTransactionBoundary(
          Effect.gen(function* () {
            yield* setAccount(entry.address, entry.account);
            yield* setStorage(entry.address, entry.slot, entry.outerValue);
            yield* setTransientStorage(
              entry.address,
              entry.slot,
              entry.outerValue,
            );
            return yield* Effect.fail(
              new BoundaryRollbackError({ phase: "transaction" }),
            );
          }),
        ),
      );
    }
  });

const benchNestedCallFrameCommit = (entries: ReadonlyArray<BenchEntry>) =>
  Effect.gen(function* () {
    for (const entry of entries) {
      yield* runInTransactionBoundary(
        Effect.gen(function* () {
          yield* setAccount(entry.address, entry.account);
          yield* runInCallFrameBoundary(
            Effect.gen(function* () {
              yield* setStorage(entry.address, entry.slot, entry.innerValue);
              yield* setTransientStorage(
                entry.address,
                entry.slot,
                entry.innerValue,
              );
            }),
          );
        }),
      );
    }
  });

const benchNestedCallFrameRollback = (entries: ReadonlyArray<BenchEntry>) =>
  Effect.gen(function* () {
    for (const entry of entries) {
      yield* runInTransactionBoundary(
        Effect.gen(function* () {
          yield* setAccount(entry.address, entry.account);
          yield* setStorage(entry.address, entry.slot, entry.outerValue);
          yield* setTransientStorage(
            entry.address,
            entry.slot,
            entry.outerValue,
          );

          yield* Effect.either(
            runInCallFrameBoundary(
              Effect.gen(function* () {
                yield* setStorage(entry.address, entry.slot, entry.innerValue);
                yield* setTransientStorage(
                  entry.address,
                  entry.slot,
                  entry.innerValue,
                );
                return yield* Effect.fail(
                  new BoundaryRollbackError({ phase: "call-frame" }),
                );
              }),
            ),
          );
        }),
      );
    }
  });

const runBenchmarks = (count: number) =>
  Effect.gen(function* () {
    const entries = makeDataset(count);
    const results: BenchResult[] = [];

    yield* clearState();
    results.push(
      yield* measure("tx-boundary-commit", count, benchTxCommit(entries)),
    );

    yield* clearState();
    results.push(
      yield* measure("tx-boundary-rollback", count, benchTxRollback(entries)),
    );

    const nestedBoundaryOps = count * 2;
    yield* clearState();
    results.push(
      yield* measure(
        "nested-call-frame-commit",
        nestedBoundaryOps,
        benchNestedCallFrameCommit(entries),
      ),
    );

    yield* clearState();
    results.push(
      yield* measure(
        "nested-call-frame-rollback",
        nestedBoundaryOps,
        benchNestedCallFrameRollback(entries),
      ),
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
  const count = parseCount(process.env.TX_BOUNDARY_BENCH_COUNT, 20_000);
  const results = yield* runBenchmarks(count);

  yield* Effect.sync(() => {
    console.log("TransactionProcessor boundary benchmark");
    console.log(`Iterations: ${count}`);
    console.table(formatResults(results));
  });
});

pipe(
  main,
  Effect.provide(TransactionProcessorBenchLayer),
  Effect.tapErrorCause((cause) =>
    Effect.sync(() => {
      console.error("Benchmark failed");
      console.error(Cause.pretty(cause));
    }),
  ),
  Effect.runPromise,
);
