import * as Context from "effect/Context";
import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import { Bytes, Hex } from "voltaire-effect/primitives";
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

export interface ReadOnlyDbOptions {
  readonly createInMemWriteStore?: boolean;
}

export interface ReadOnlyDbService extends DbService {
  readonly clearTempChanges: () => Effect.Effect<void, DbError>;
}

export class ReadOnlyDb extends Context.Tag("ReadOnlyDb")<
  ReadOnlyDb,
  ReadOnlyDbService
>() {}

type OverlayStore = Map<string, BytesType>;

type DbReader = Pick<
  DbService,
  "get" | "getMany" | "getAll" | "getAllKeys" | "getAllValues" | "has"
>;

const readOnlyWriteError = () =>
  new DbError({ message: "ReadOnlyDb does not support writes" });

const mergeUnsupportedError = () =>
  new DbError({ message: "ReadOnlyDb does not support merge" });

const encodeKey = (key: BytesType): Effect.Effect<string, DbError> =>
  Effect.try({
    try: () => Hex.fromBytes(key),
    catch: (cause) => new DbError({ message: "Invalid DB key", cause }),
  });

const decodeKey = (keyHex: string): BytesType =>
  Hex.toBytes(keyHex) as BytesType;

const compareBytes = (left: BytesType, right: BytesType): number => {
  const leftBytes = left as Uint8Array;
  const rightBytes = right as Uint8Array;

  if (leftBytes === rightBytes) {
    return 0;
  }

  if (leftBytes.length === 0) {
    return rightBytes.length === 0 ? 0 : 1;
  }

  for (let index = 0; index < leftBytes.length; index += 1) {
    if (rightBytes.length <= index) {
      return -1;
    }

    const result = leftBytes[index]! - rightBytes[index]!;
    if (result !== 0) {
      return result < 0 ? -1 : 1;
    }
  }

  return rightBytes.length > leftBytes.length ? 1 : 0;
};

const cloneBytes = (value: BytesType): BytesType =>
  (value as Uint8Array).slice() as BytesType;

const cloneBytesEffect = (
  value: BytesType,
): Effect.Effect<BytesType, DbError> =>
  Bytes.isBytes(value)
    ? Effect.succeed(cloneBytes(value))
    : Effect.fail(new DbError({ message: "Invalid DB value" }));

const cloneOverlayStore = (store: OverlayStore): OverlayStore => {
  const snapshot = new Map<string, BytesType>();
  for (const [keyHex, value] of store.entries()) {
    snapshot.set(keyHex, cloneBytes(value));
  }
  return snapshot;
};

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
      const merged = new Map<string, BytesType>();

      for (const entry of baseEntries) {
        const keyHex = yield* encodeKey(entry.key);
        merged.set(keyHex, entry.value);
      }

      for (const [keyHex, value] of overlay.entries()) {
        merged.set(keyHex, value);
      }

      const entries: Array<DbEntry> = [];
      for (const [keyHex, value] of merged.entries()) {
        entries.push({ key: decodeKey(keyHex), value: cloneBytes(value) });
      }

      if (ordered) {
        entries.sort((left, right) => compareBytes(left.key, right.key));
      }

      return entries;
    });

  const getAllKeys = (ordered?: boolean) =>
    pipe(
      getAll(ordered),
      Effect.map((entries) => entries.map((entry) => entry.key)),
    );

  const getAllValues = (ordered?: boolean) =>
    pipe(
      getAll(ordered),
      Effect.map((entries) => entries.map((entry) => entry.value)),
    );

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
      overlay
        ? Effect.gen(function* () {
            const keyHex = yield* encodeKey(key);
            const stored = yield* cloneBytesEffect(value);
            overlay.set(keyHex, stored);
          })
        : Effect.fail(readOnlyWriteError());

    const remove = (key: BytesType) =>
      overlay
        ? Effect.gen(function* () {
            const keyHex = yield* encodeKey(key);
            overlay.delete(keyHex);
          })
        : Effect.fail(readOnlyWriteError());

    const merge = (_key: BytesType, _value: BytesType, _flags?: WriteFlags) =>
      overlay
        ? Effect.fail(mergeUnsupportedError())
        : Effect.fail(readOnlyWriteError());

    const writeBatch = (ops: ReadonlyArray<DbWriteOp>) =>
      overlay
        ? Effect.gen(function* () {
            if (ops.length === 0) {
              return;
            }

            for (const op of ops) {
              switch (op._tag) {
                case "put": {
                  const keyHex = yield* encodeKey(op.key);
                  const stored = yield* cloneBytesEffect(op.value);
                  overlay.set(keyHex, stored);
                  break;
                }
                case "del": {
                  const keyHex = yield* encodeKey(op.key);
                  overlay.delete(keyHex);
                  break;
                }
                case "merge": {
                  return yield* Effect.fail(mergeUnsupportedError());
                }
              }
            }
          })
        : Effect.fail(readOnlyWriteError());

    const startWriteBatch = () =>
      overlay
        ? Effect.acquireRelease(
            Effect.sync(() => {
              const putBatch = (
                key: BytesType,
                value: BytesType,
                _flags?: WriteFlags,
              ) =>
                Effect.gen(function* () {
                  const keyHex = yield* encodeKey(key);
                  const stored = yield* cloneBytesEffect(value);
                  overlay.set(keyHex, stored);
                });

              const mergeBatch = (
                _key: BytesType,
                _value: BytesType,
                _flags?: WriteFlags,
              ) => Effect.fail(mergeUnsupportedError());

              const removeBatch = (key: BytesType) =>
                Effect.gen(function* () {
                  const keyHex = yield* encodeKey(key);
                  overlay.delete(keyHex);
                });

              const clearBatch = () =>
                Effect.sync(() => {
                  // no-op for write-through batch
                });

              return {
                put: putBatch,
                merge: mergeBatch,
                remove: removeBatch,
                clear: clearBatch,
              } satisfies WriteBatch;
            }),
            () =>
              Effect.sync(() => {
                // no-op for batch release
              }),
          )
        : Effect.acquireRelease(Effect.fail(readOnlyWriteError()), () =>
            Effect.sync(() => {
              // no-op for batch release
            }),
          );

    const createSnapshot = () =>
      overlay
        ? Effect.gen(function* () {
            const baseSnapshot = yield* base.createSnapshot();
            const overlaySnapshot = cloneOverlayStore(overlay);
            return makeReadOnlyReader(baseSnapshot, overlaySnapshot);
          })
        : base.createSnapshot();

    const flush = (_onlyWal?: boolean) =>
      Effect.sync(() => {
        // no-op for read-only wrapper
      });

    const clear = () => Effect.fail(readOnlyWriteError());

    const compact = () =>
      Effect.sync(() => {
        // no-op for read-only wrapper
      });

    const gatherMetric = () => base.gatherMetric();

    const clearTempChanges = () =>
      overlay
        ? Effect.sync(() => overlay.clear())
        : Effect.sync(() => {
            // no-op when overlay is disabled
          });

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

export const ReadOnlyDbLive = (
  options: ReadOnlyDbOptions = {},
): Layer.Layer<ReadOnlyDb, DbError, Db> =>
  Layer.scoped(ReadOnlyDb, makeReadOnlyDb(options));

export const ReadOnlyDbTest = (
  options: ReadOnlyDbOptions = {},
): Layer.Layer<ReadOnlyDb, DbError, Db> =>
  Layer.scoped(ReadOnlyDb, makeReadOnlyDb(options));
