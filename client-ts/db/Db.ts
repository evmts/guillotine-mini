import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import * as Scope from "effect/Scope";
import * as Schema from "effect/Schema";
import { Hex } from "voltaire-effect/primitives";
import type { BytesType } from "./DbTypes";
import {
  DbConfigSchema,
  DbNames,
  type DbConfig,
  type DbMetric,
  type DbName,
  type ReadFlags,
  type WriteFlags,
} from "./DbTypes";

export * from "./DbTypes";

/** Error raised by DB operations. */
export class DbError extends Data.TaggedError("DbError")<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** DB key/value pair entry. */
export interface DbEntry {
  readonly key: BytesType;
  readonly value: BytesType;
}

/** Read-only snapshot view of a DB. */
export interface DbSnapshot {
  readonly get: (
    key: BytesType,
    flags?: ReadFlags,
  ) => Effect.Effect<Option.Option<BytesType>, DbError>;
  readonly getAll: (
    ordered?: boolean,
  ) => Effect.Effect<ReadonlyArray<DbEntry>, DbError>;
  readonly getAllKeys: (
    ordered?: boolean,
  ) => Effect.Effect<ReadonlyArray<BytesType>, DbError>;
  readonly getAllValues: (
    ordered?: boolean,
  ) => Effect.Effect<ReadonlyArray<BytesType>, DbError>;
  readonly has: (key: BytesType) => Effect.Effect<boolean, DbError>;
}

/** Single write operation for batched commits. */
export type DbWriteOp =
  | {
      readonly _tag: "put";
      readonly key: BytesType;
      readonly value: BytesType;
      readonly flags?: WriteFlags;
    }
  | {
      readonly _tag: "del";
      readonly key: BytesType;
    }
  | {
      readonly _tag: "merge";
      readonly key: BytesType;
      readonly value: BytesType;
      readonly flags?: WriteFlags;
    };

/** Batched write operations. */
export interface WriteBatch {
  readonly put: (
    key: BytesType,
    value: BytesType,
    flags?: WriteFlags,
  ) => Effect.Effect<void, DbError>;
  readonly merge: (
    key: BytesType,
    value: BytesType,
    flags?: WriteFlags,
  ) => Effect.Effect<void, DbError>;
  readonly remove: (key: BytesType) => Effect.Effect<void, DbError>;
  readonly clear: () => Effect.Effect<void, DbError>;
}

/** Key-value DB abstraction. */
export interface DbService {
  readonly name: DbName;
  readonly get: (
    key: BytesType,
    flags?: ReadFlags,
  ) => Effect.Effect<Option.Option<BytesType>, DbError>;
  readonly getAll: (
    ordered?: boolean,
  ) => Effect.Effect<ReadonlyArray<DbEntry>, DbError>;
  readonly getAllKeys: (
    ordered?: boolean,
  ) => Effect.Effect<ReadonlyArray<BytesType>, DbError>;
  readonly getAllValues: (
    ordered?: boolean,
  ) => Effect.Effect<ReadonlyArray<BytesType>, DbError>;
  readonly put: (
    key: BytesType,
    value: BytesType,
    flags?: WriteFlags,
  ) => Effect.Effect<void, DbError>;
  readonly merge: (
    key: BytesType,
    value: BytesType,
    flags?: WriteFlags,
  ) => Effect.Effect<void, DbError>;
  readonly remove: (key: BytesType) => Effect.Effect<void, DbError>;
  readonly has: (key: BytesType) => Effect.Effect<boolean, DbError>;
  readonly createSnapshot: () => Effect.Effect<
    DbSnapshot,
    DbError,
    Scope.Scope
  >;
  readonly flush: (onlyWal?: boolean) => Effect.Effect<void, DbError>;
  readonly clear: () => Effect.Effect<void, DbError>;
  readonly compact: () => Effect.Effect<void, DbError>;
  readonly gatherMetric: () => Effect.Effect<DbMetric, DbError>;
  readonly writeBatch: (
    ops: ReadonlyArray<DbWriteOp>,
  ) => Effect.Effect<void, DbError>;
  readonly startWriteBatch: () => Effect.Effect<
    WriteBatch,
    DbError,
    Scope.Scope
  >;
}

/** Context tag for the DB service. */
export class Db extends Context.Tag("Db")<Db, DbService>() {}

const validateConfig = (config: DbConfig): Effect.Effect<DbConfig, DbError> =>
  Effect.try({
    try: () => Schema.decodeSync(DbConfigSchema)(config),
    catch: (cause) => new DbError({ message: "Invalid DbConfig", cause }),
  });

const encodeKey = (key: BytesType): Effect.Effect<string, DbError> =>
  Effect.try({
    try: () => Hex.fromBytes(key),
    catch: (cause) => new DbError({ message: "Invalid DB key", cause }),
  });

const decodeKey = (keyHex: string): BytesType =>
  Hex.toBytes(keyHex) as BytesType;

const cloneBytes = (value: BytesType): BytesType =>
  Hex.toBytes(Hex.fromBytes(value)) as BytesType;

const mergeUnsupportedError = () =>
  new DbError({ message: "Merge is not supported by the memory DB" });

const failMergeUnsupported = () => Effect.fail(mergeUnsupportedError());

const listEntries = (
  store: Map<string, BytesType>,
  ordered = false,
): ReadonlyArray<DbEntry> => {
  const entries = Array.from(store.entries());
  if (ordered) {
    entries.sort(([left], [right]) =>
      left < right ? -1 : left > right ? 1 : 0,
    );
  }
  return entries.map(([keyHex, value]) => ({
    key: decodeKey(keyHex),
    value: cloneBytes(value),
  }));
};

const makeReader = (store: Map<string, BytesType>): DbSnapshot => {
  const getEntries = (ordered = false) => listEntries(store, ordered);

  const getAll = (ordered?: boolean) =>
    Effect.sync(() => getEntries(Boolean(ordered)));

  const getAllKeys = (ordered?: boolean) =>
    Effect.sync(() => getEntries(Boolean(ordered)).map((entry) => entry.key));

  const getAllValues = (ordered?: boolean) =>
    Effect.sync(() => getEntries(Boolean(ordered)).map((entry) => entry.value));

  const get = (key: BytesType, _flags?: ReadFlags) =>
    Effect.gen(function* () {
      const keyHex = yield* encodeKey(key);
      const value = store.get(keyHex);
      return pipe(Option.fromNullable(value), Option.map(cloneBytes));
    });

  const has = (key: BytesType) =>
    Effect.gen(function* () {
      const keyHex = yield* encodeKey(key);
      return store.has(keyHex);
    });

  return {
    get,
    getAll,
    getAllKeys,
    getAllValues,
    has,
  };
};

type PreparedWriteOp =
  | {
      readonly _tag: "put";
      readonly keyHex: string;
      readonly value: BytesType;
    }
  | {
      readonly _tag: "del";
      readonly keyHex: string;
    };

const makeMemoryDb = (config: DbConfig) =>
  Effect.gen(function* () {
    const validated = yield* validateConfig(config);
    const store = yield* Effect.acquireRelease(
      Effect.sync(() => new Map<string, BytesType>()),
      (map) => Effect.sync(() => map.clear()),
    );

    const { get, getAll, getAllKeys, getAllValues, has } = makeReader(store);

    const put = (key: BytesType, value: BytesType, _flags?: WriteFlags) =>
      Effect.gen(function* () {
        const keyHex = yield* encodeKey(key);
        store.set(keyHex, cloneBytes(value));
      });

    const merge = (_key: BytesType, _value: BytesType, _flags?: WriteFlags) =>
      failMergeUnsupported();

    const remove = (key: BytesType) =>
      Effect.gen(function* () {
        const keyHex = yield* encodeKey(key);
        store.delete(keyHex);
      });

    const createSnapshot = () =>
      pipe(
        Effect.acquireRelease(
          Effect.sync(() => {
            const snapshotStore = new Map<string, BytesType>();
            for (const [keyHex, value] of store.entries()) {
              snapshotStore.set(keyHex, cloneBytes(value));
            }
            return snapshotStore;
          }),
          (snapshotStore) => Effect.sync(() => snapshotStore.clear()),
        ),
        Effect.map((snapshotStore) => {
          return makeReader(snapshotStore);
        }),
      );

    const flush = (_onlyWal?: boolean) =>
      Effect.sync(() => {
        // no-op for in-memory DB
      });

    const clear = () =>
      Effect.sync(() => {
        store.clear();
      });

    const compact = () =>
      Effect.sync(() => {
        // no-op for in-memory DB
      });

    const gatherMetric = () =>
      Effect.sync(
        (): DbMetric => ({
          size: store.size,
          cacheSize: 0,
          indexSize: 0,
          memtableSize: 0,
          totalReads: 0,
          totalWrites: 0,
        }),
      );

    const writeBatch = (ops: ReadonlyArray<DbWriteOp>) =>
      Effect.gen(function* () {
        if (ops.length === 0) {
          return;
        }

        const prepared: Array<PreparedWriteOp> = [];

        for (const op of ops) {
          switch (op._tag) {
            case "put": {
              const keyHex = yield* encodeKey(op.key);
              prepared.push({
                _tag: "put",
                keyHex,
                value: cloneBytes(op.value),
              });
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

        for (const op of prepared) {
          if (op._tag === "put") {
            store.set(op.keyHex, op.value);
          } else {
            store.delete(op.keyHex);
          }
        }
      });

    const startWriteBatch = () =>
      Effect.acquireRelease(
        Effect.sync(() => {
          const put = (key: BytesType, value: BytesType, _flags?: WriteFlags) =>
            Effect.gen(function* () {
              const keyHex = yield* encodeKey(key);
              store.set(keyHex, cloneBytes(value));
            });

          const merge = (
            _key: BytesType,
            _value: BytesType,
            _flags?: WriteFlags,
          ) => failMergeUnsupported();

          const remove = (key: BytesType) =>
            Effect.gen(function* () {
              const keyHex = yield* encodeKey(key);
              store.delete(keyHex);
            });

          const clear = () =>
            Effect.sync(() => {
              // no-op for write-through batch
            });

          return {
            put,
            merge,
            remove,
            clear,
          } satisfies WriteBatch;
        }),
        () =>
          Effect.sync(() => {
            // no-op for in-memory batch disposal
          }),
      );

    return {
      name: validated.name,
      get,
      getAll,
      getAllKeys,
      getAllValues,
      put,
      merge,
      remove,
      has,
      createSnapshot,
      flush,
      clear,
      compact,
      gatherMetric,
      writeBatch,
      startWriteBatch,
    } satisfies DbService;
  });

/** In-memory production DB layer. */
export const DbMemoryLive = (config: DbConfig): Layer.Layer<Db, DbError> =>
  Layer.scoped(Db, makeMemoryDb(config));

/** In-memory deterministic DB layer for tests. */
export const DbMemoryTest = (
  config: DbConfig = { name: DbNames.state },
): Layer.Layer<Db, DbError> => Layer.scoped(Db, makeMemoryDb(config));

/** Retrieve a value by key. */
export const get = (key: BytesType, flags?: ReadFlags) =>
  Effect.gen(function* () {
    const db = yield* Db;
    return yield* db.get(key, flags);
  });

/** Return all entries. */
export const getAll = (ordered?: boolean) =>
  Effect.gen(function* () {
    const db = yield* Db;
    return yield* db.getAll(ordered);
  });

/** Return all keys. */
export const getAllKeys = (ordered?: boolean) =>
  Effect.gen(function* () {
    const db = yield* Db;
    return yield* db.getAllKeys(ordered);
  });

/** Return all values. */
export const getAllValues = (ordered?: boolean) =>
  Effect.gen(function* () {
    const db = yield* Db;
    return yield* db.getAllValues(ordered);
  });

/** Store a value by key. */
export const put = (key: BytesType, value: BytesType, flags?: WriteFlags) =>
  Effect.gen(function* () {
    const db = yield* Db;
    yield* db.put(key, value, flags);
  });

/** Merge a value by key. */
export const merge = (key: BytesType, value: BytesType, flags?: WriteFlags) =>
  Effect.gen(function* () {
    const db = yield* Db;
    yield* db.merge(key, value, flags);
  });

/** Remove a value by key. */
export const remove = (key: BytesType) =>
  Effect.gen(function* () {
    const db = yield* Db;
    yield* db.remove(key);
  });

/** Check whether a key exists. */
export const has = (key: BytesType) =>
  Effect.gen(function* () {
    const db = yield* Db;
    return yield* db.has(key);
  });

/** Create a read-only snapshot of the DB. */
export const createSnapshot = () =>
  Effect.gen(function* () {
    const db = yield* Db;
    return yield* db.createSnapshot();
  });

/** Flush underlying storage buffers. */
export const flush = (onlyWal?: boolean) =>
  Effect.gen(function* () {
    const db = yield* Db;
    yield* db.flush(onlyWal);
  });

/** Clear all data from the database. */
export const clear = () =>
  Effect.gen(function* () {
    const db = yield* Db;
    yield* db.clear();
  });

/** Compact underlying storage. */
export const compact = () =>
  Effect.gen(function* () {
    const db = yield* Db;
    yield* db.compact();
  });

/** Gather DB metrics. */
export const gatherMetric = () =>
  Effect.gen(function* () {
    const db = yield* Db;
    return yield* db.gatherMetric();
  });

/** Apply a batch of write operations. */
export const writeBatch = (ops: ReadonlyArray<DbWriteOp>) =>
  Effect.gen(function* () {
    const db = yield* Db;
    yield* db.writeBatch(ops);
  });

/** Start a write batch scope. */
export const startWriteBatch = () =>
  Effect.gen(function* () {
    const db = yield* Db;
    return yield* db.startWriteBatch();
  });
