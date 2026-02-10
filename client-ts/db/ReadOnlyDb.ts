import * as Context from "effect/Context";
import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import {
  Db,
  DbError,
  type DbEntry,
  type DbGetEntry,
  type DbService,
  type DbSnapshot,
  type DbWriteOp,
  type BytesType,
  type ReadFlags,
  type WriteBatch,
  type WriteFlags,
} from "./Db";
import {
  cloneBytes,
  cloneBytesEffect,
  compareBytes,
  decodeKey,
  encodeKey,
} from "./DbUtils";

/** Options for the read-only DB wrapper. */
export interface ReadOnlyDbOptions {
  readonly createInMemWriteStore?: boolean;
}

/** Read-only DB service with optional in-memory write overlay. */
export interface ReadOnlyDbService extends DbService {
  readonly clearTempChanges: () => Effect.Effect<void, DbError>;
}

/** Context tag for the read-only DB service. */
export class ReadOnlyDb extends Context.Tag("ReadOnlyDb")<
  ReadOnlyDb,
  ReadOnlyDbService
>() {}

type OverlayStore = Map<string, BytesType>;
type PreparedOverlayWriteOp =
  | {
      readonly _tag: "put";
      readonly keyHex: string;
      readonly value: BytesType;
    }
  | {
      readonly _tag: "del";
      readonly keyHex: string;
    };

type DbReader = Pick<
  DbService,
  "get" | "getMany" | "getAll" | "getAllKeys" | "getAllValues" | "has"
>;

const readOnlyWriteError = () =>
  new DbError({ message: "ReadOnlyDb does not support writes" });

const mergeUnsupportedError = () =>
  new DbError({ message: "ReadOnlyDb does not support merge" });

const failReadOnlyWrite = () => Effect.fail(readOnlyWriteError());

const failMergeUnsupported = () => Effect.fail(mergeUnsupportedError());

const cloneOverlayStore = (store: OverlayStore): OverlayStore => {
  const snapshot = new Map<string, BytesType>();
  for (const [keyHex, value] of store.entries()) {
    snapshot.set(keyHex, cloneBytes(value));
  }
  return snapshot;
};

const putOverlayValue = (
  overlay: OverlayStore,
  key: BytesType,
  value: BytesType,
) =>
  Effect.gen(function* () {
    const keyHex = yield* encodeKey(key);
    const stored = yield* cloneBytesEffect(value);
    overlay.set(keyHex, stored);
  });

const removeOverlayValue = (overlay: OverlayStore, key: BytesType) =>
  Effect.gen(function* () {
    const keyHex = yield* encodeKey(key);
    overlay.delete(keyHex);
  });

const prepareOverlayWriteOps = (ops: ReadonlyArray<DbWriteOp>) =>
  Effect.gen(function* () {
    const prepared: Array<PreparedOverlayWriteOp> = [];

    for (const op of ops) {
      switch (op._tag) {
        case "put": {
          const keyHex = yield* encodeKey(op.key);
          const value = yield* cloneBytesEffect(op.value);
          prepared.push({ _tag: "put", keyHex, value });
          break;
        }
        case "del": {
          const keyHex = yield* encodeKey(op.key);
          prepared.push({ _tag: "del", keyHex });
          break;
        }
        case "merge": {
          return yield* failMergeUnsupported();
        }
      }
    }

    return prepared;
  });

const applyPreparedOverlayWriteOps = (
  overlay: OverlayStore,
  ops: ReadonlyArray<PreparedOverlayWriteOp>,
) =>
  Effect.sync(() => {
    for (const op of ops) {
      if (op._tag === "put") {
        overlay.set(op.keyHex, op.value);
      } else {
        overlay.delete(op.keyHex);
      }
    }
  });

const makeReadOnlyReader = (
  base: DbReader,
  overlay?: OverlayStore,
): DbSnapshot => {
  if (!overlay) {
    return {
      get: base.get,
      getMany: base.getMany,
      getAll: base.getAll,
      getAllKeys: base.getAllKeys,
      getAllValues: base.getAllValues,
      has: base.has,
    } satisfies DbSnapshot;
  }

  const getOverlayValue = (keyHex: string) =>
    overlay.has(keyHex) ? overlay.get(keyHex) : undefined;

  const get = (key: BytesType, flags?: ReadFlags) =>
    Effect.gen(function* () {
      const keyHex = yield* encodeKey(key);
      const overlayValue = getOverlayValue(keyHex);
      if (overlayValue !== undefined) {
        return Option.some(cloneBytes(overlayValue));
      }
      return yield* base.get(key, flags);
    });

  const getMany = (keys: ReadonlyArray<BytesType>) =>
    Effect.gen(function* () {
      const baseEntries = yield* base.getMany(keys);
      const results: Array<DbGetEntry> = [];

      for (const entry of baseEntries) {
        const keyHex = yield* encodeKey(entry.key);
        const overlayValue = getOverlayValue(keyHex);
        if (overlayValue === undefined) {
          results.push(entry);
          continue;
        }

        results.push({
          key: entry.key,
          value: Option.some(cloneBytes(overlayValue)),
        });
      }

      return results;
    });

  const getAll = (ordered?: boolean) =>
    Effect.gen(function* () {
      const baseEntries = yield* base.getAll(false);
      const entries: Array<DbEntry> = [];

      for (const entry of baseEntries) {
        const keyHex = yield* encodeKey(entry.key);
        if (overlay.has(keyHex)) {
          continue;
        }
        entries.push({
          key: cloneBytes(entry.key),
          value: cloneBytes(entry.value),
        });
      }

      for (const [keyHex, value] of overlay.entries()) {
        entries.push({ key: decodeKey(keyHex), value: cloneBytes(value) });
      }

      if (ordered) {
        entries.sort((left, right) => compareBytes(left.key, right.key));
      }

      return entries;
    });

  const getAllKeys = (ordered?: boolean) =>
    ordered
      ? pipe(
          getAll(true),
          Effect.map((entries) => entries.map((entry) => entry.key)),
        )
      : Effect.gen(function* () {
          const baseKeys = yield* base.getAllKeys(false);
          const keys: Array<BytesType> = [];

          for (const key of baseKeys) {
            const keyHex = yield* encodeKey(key);
            if (overlay.has(keyHex)) {
              continue;
            }
            keys.push(cloneBytes(key));
          }

          for (const keyHex of overlay.keys()) {
            keys.push(decodeKey(keyHex));
          }

          return keys;
        });

  const getAllValues = (ordered?: boolean) =>
    ordered
      ? pipe(
          getAll(true),
          Effect.map((entries) => entries.map((entry) => entry.value)),
        )
      : Effect.gen(function* () {
          const baseEntries = yield* base.getAll(false);
          const values: Array<BytesType> = [];

          for (const entry of baseEntries) {
            const keyHex = yield* encodeKey(entry.key);
            if (overlay.has(keyHex)) {
              continue;
            }
            values.push(cloneBytes(entry.value));
          }

          for (const value of overlay.values()) {
            values.push(cloneBytes(value));
          }

          return values;
        });

  const has = (key: BytesType) =>
    Effect.gen(function* () {
      const keyHex = yield* encodeKey(key);
      const overlayValue = getOverlayValue(keyHex);
      if (overlayValue !== undefined) {
        return true;
      }
      return yield* base.has(key);
    });

  return {
    get,
    getMany,
    getAll,
    getAllKeys,
    getAllValues,
    has,
  } satisfies DbSnapshot;
};

const makeReadOnlyDb = (options: ReadOnlyDbOptions = {}) =>
  Effect.gen(function* () {
    const base = yield* Db;
    const overlay = options.createInMemWriteStore
      ? yield* Effect.acquireRelease(
          Effect.sync(() => new Map<string, BytesType>()),
          (store) => Effect.sync(() => store.clear()),
        )
      : undefined;

    const reader = makeReadOnlyReader(base, overlay);

    const put = (key: BytesType, value: BytesType, _flags?: WriteFlags) =>
      overlay ? putOverlayValue(overlay, key, value) : failReadOnlyWrite();

    const remove = (key: BytesType) =>
      overlay ? removeOverlayValue(overlay, key) : failReadOnlyWrite();

    const merge = (_key: BytesType, _value: BytesType, _flags?: WriteFlags) =>
      overlay ? failMergeUnsupported() : failReadOnlyWrite();

    const writeBatch = (ops: ReadonlyArray<DbWriteOp>) =>
      overlay
        ? Effect.gen(function* () {
            if (ops.length === 0) {
              return;
            }

            const prepared = yield* prepareOverlayWriteOps(ops);
            yield* applyPreparedOverlayWriteOps(overlay, prepared);
          })
        : failReadOnlyWrite();

    const startWriteBatch = () =>
      overlay
        ? Effect.acquireRelease(
            Effect.sync(() => {
              const putBatch = (
                key: BytesType,
                value: BytesType,
                _flags?: WriteFlags,
              ) => putOverlayValue(overlay, key, value);

              const mergeBatch = (
                _key: BytesType,
                _value: BytesType,
                _flags?: WriteFlags,
              ) => failMergeUnsupported();

              const removeBatch = (key: BytesType) =>
                removeOverlayValue(overlay, key);

              const clearBatch = () => Effect.void;

              return {
                put: putBatch,
                merge: mergeBatch,
                remove: removeBatch,
                clear: clearBatch,
              } satisfies WriteBatch;
            }),
            () => Effect.void,
          )
        : Effect.acquireRelease(failReadOnlyWrite(), () => Effect.void);

    const createSnapshot = () =>
      overlay
        ? Effect.gen(function* () {
            const baseSnapshot = yield* base.createSnapshot();
            const overlaySnapshot = cloneOverlayStore(overlay);
            return makeReadOnlyReader(baseSnapshot, overlaySnapshot);
          })
        : base.createSnapshot();

    const flush = (_onlyWal?: boolean) => Effect.void;

    const clear = () => failReadOnlyWrite();

    const compact = () => Effect.void;

    const gatherMetric = () => base.gatherMetric();

    const clearTempChanges = () =>
      overlay ? Effect.sync(() => overlay.clear()) : Effect.void;

    return {
      name: base.name,
      get: reader.get,
      getMany: reader.getMany,
      getAll: reader.getAll,
      getAllKeys: reader.getAllKeys,
      getAllValues: reader.getAllValues,
      put,
      merge,
      remove,
      has: reader.has,
      createSnapshot,
      flush,
      clear,
      compact,
      gatherMetric,
      writeBatch,
      startWriteBatch,
      clearTempChanges,
    } satisfies ReadOnlyDbService;
  });

/** Read-only DB layer for production. */
export const ReadOnlyDbLive = (
  options: ReadOnlyDbOptions = {},
): Layer.Layer<ReadOnlyDb, DbError, Db> =>
  Layer.scoped(ReadOnlyDb, makeReadOnlyDb(options));

/** Read-only DB layer for tests. */
export const ReadOnlyDbTest = (
  options: ReadOnlyDbOptions = {},
): Layer.Layer<ReadOnlyDb, DbError, Db> =>
  Layer.scoped(ReadOnlyDb, makeReadOnlyDb(options));

const withReadOnlyDb = <A, E, R>(
  f: (db: ReadOnlyDbService) => Effect.Effect<A, E, R>,
): Effect.Effect<A, E, R | ReadOnlyDb> => Effect.flatMap(ReadOnlyDb, f);

/** Retrieve a value by key from the read-only DB. */
export const get = (key: BytesType, flags?: ReadFlags) =>
  withReadOnlyDb((db) => db.get(key, flags));

/** Retrieve values for multiple keys from the read-only DB. */
export const getMany = (keys: ReadonlyArray<BytesType>) =>
  withReadOnlyDb((db) => db.getMany(keys));

/** Return all entries from the read-only DB. */
export const getAll = (ordered?: boolean) =>
  withReadOnlyDb((db) => db.getAll(ordered));

/** Return all keys from the read-only DB. */
export const getAllKeys = (ordered?: boolean) =>
  withReadOnlyDb((db) => db.getAllKeys(ordered));

/** Return all values from the read-only DB. */
export const getAllValues = (ordered?: boolean) =>
  withReadOnlyDb((db) => db.getAllValues(ordered));

/** Write a value to the read-only DB overlay if enabled. */
export const put = (key: BytesType, value: BytesType, flags?: WriteFlags) =>
  withReadOnlyDb((db) => db.put(key, value, flags));

/** Merge a value into the read-only DB overlay if enabled. */
export const merge = (key: BytesType, value: BytesType, flags?: WriteFlags) =>
  withReadOnlyDb((db) => db.merge(key, value, flags));

/** Remove a value from the read-only DB overlay if enabled. */
export const remove = (key: BytesType) =>
  withReadOnlyDb((db) => db.remove(key));

/** Check whether a key exists in the read-only DB view. */
export const has = (key: BytesType) => withReadOnlyDb((db) => db.has(key));

/** Create a read-only snapshot. */
export const createSnapshot = () => withReadOnlyDb((db) => db.createSnapshot());

/** Flush underlying storage buffers. */
export const flush = (onlyWal?: boolean) =>
  withReadOnlyDb((db) => db.flush(onlyWal));

/** Clear all data from the read-only DB. */
export const clear = () => withReadOnlyDb((db) => db.clear());

/** Compact underlying storage. */
export const compact = () => withReadOnlyDb((db) => db.compact());

/** Gather DB metrics from the wrapped DB. */
export const gatherMetric = () => withReadOnlyDb((db) => db.gatherMetric());

/** Apply a batch of write operations to the overlay if enabled. */
export const writeBatch = (ops: ReadonlyArray<DbWriteOp>) =>
  withReadOnlyDb((db) => db.writeBatch(ops));

/** Start a write batch scope. */
export const startWriteBatch = () =>
  withReadOnlyDb((db) => db.startWriteBatch());

/** Clear in-memory overlay state when enabled. */
export const clearTempChanges = () =>
  withReadOnlyDb((db) => db.clearTempChanges());
