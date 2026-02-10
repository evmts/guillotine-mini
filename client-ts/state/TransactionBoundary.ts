import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import type { InvalidSnapshotError } from "./Journal";
import {
  type UnknownSnapshotError,
  WorldState,
  WorldStateTest,
  type WorldStateSnapshot,
} from "./State";
import {
  TransientStorage,
  TransientStorageTest,
  type TransientStorageSnapshot,
  type UnknownTransientSnapshotError,
} from "./TransientStorage";

type TransactionSnapshot = {
  readonly worldStateSnapshot: WorldStateSnapshot;
  readonly transientStorageSnapshot: TransientStorageSnapshot;
};

/** Error raised when committing or rolling back without an active transaction. */
export class NoActiveTransactionError extends Data.TaggedError(
  "NoActiveTransactionError",
)<{
  readonly depth: number;
}> {}

/** Union of transaction boundary errors. */
export type TransactionBoundaryError =
  | NoActiveTransactionError
  | InvalidSnapshotError
  | UnknownSnapshotError
  | UnknownTransientSnapshotError;

/** Service interface for transaction boundary semantics. */
export interface TransactionBoundaryService {
  readonly beginTransaction: () => Effect.Effect<void>;
  readonly commitTransaction: () => Effect.Effect<
    void,
    TransactionBoundaryError
  >;
  readonly rollbackTransaction: () => Effect.Effect<
    void,
    TransactionBoundaryError
  >;
  readonly depth: () => Effect.Effect<number>;
}

/** Context tag for transaction boundary orchestration. */
export class TransactionBoundary extends Context.Tag("TransactionBoundary")<
  TransactionBoundary,
  TransactionBoundaryService
>() {}

const withTransactionBoundary = <A, E, R>(
  f: (service: TransactionBoundaryService) => Effect.Effect<A, E, R>,
) => Effect.flatMap(TransactionBoundary, f);

const makeTransactionBoundary: Effect.Effect<
  TransactionBoundaryService,
  never,
  WorldState | TransientStorage
> = Effect.gen(function* () {
  const worldState = yield* WorldState;
  const transientStorage = yield* TransientStorage;
  const stack: Array<TransactionSnapshot> = [];

  const requireActiveTransaction = (): Effect.Effect<
    TransactionSnapshot,
    NoActiveTransactionError
  > =>
    Effect.gen(function* () {
      const snapshot = stack[stack.length - 1];
      if (!snapshot) {
        return yield* Effect.fail(
          new NoActiveTransactionError({ depth: stack.length }),
        );
      }
      return snapshot;
    });

  const beginTransaction = (): Effect.Effect<void> =>
    Effect.gen(function* () {
      const worldStateSnapshot = yield* worldState.takeSnapshot();
      const transientStorageSnapshot = yield* transientStorage.takeSnapshot();
      stack.push({ worldStateSnapshot, transientStorageSnapshot });
    });

  const commitTransaction = (): Effect.Effect<void, TransactionBoundaryError> =>
    Effect.gen(function* () {
      const snapshot = yield* requireActiveTransaction();
      yield* worldState.commitSnapshot(snapshot.worldStateSnapshot);
      yield* transientStorage.commitSnapshot(snapshot.transientStorageSnapshot);
      stack.pop();
    });

  const rollbackTransaction = (): Effect.Effect<
    void,
    TransactionBoundaryError
  > =>
    Effect.gen(function* () {
      const snapshot = yield* requireActiveTransaction();
      yield* worldState.restoreSnapshot(snapshot.worldStateSnapshot);
      yield* transientStorage.restoreSnapshot(
        snapshot.transientStorageSnapshot,
      );
      stack.pop();
    });

  const depth = () => Effect.sync(() => stack.length);

  return {
    beginTransaction,
    commitTransaction,
    rollbackTransaction,
    depth,
  } satisfies TransactionBoundaryService;
});

/** Production transaction boundary layer. */
export const TransactionBoundaryLive: Layer.Layer<
  TransactionBoundary,
  never,
  WorldState | TransientStorage
> = Layer.effect(TransactionBoundary, makeTransactionBoundary);

const TransactionBoundaryTestDependencies = Layer.mergeAll(
  WorldStateTest,
  TransientStorageTest,
);

/** Deterministic transaction boundary layer for tests. */
export const TransactionBoundaryTest: Layer.Layer<
  TransactionBoundary | WorldState | TransientStorage
> = Layer.merge(
  TransactionBoundaryTestDependencies,
  TransactionBoundaryLive.pipe(
    Layer.provide(TransactionBoundaryTestDependencies),
  ),
);

/** Begin a nested transaction boundary. */
export const beginTransaction = () =>
  withTransactionBoundary((service) => service.beginTransaction());

/** Commit the latest transaction boundary. */
export const commitTransaction = () =>
  withTransactionBoundary((service) => service.commitTransaction());

/** Roll back the latest transaction boundary. */
export const rollbackTransaction = () =>
  withTransactionBoundary((service) => service.rollbackTransaction());

/** Return the active transaction depth. */
export const transactionDepth = () =>
  withTransactionBoundary((service) => service.depth());
