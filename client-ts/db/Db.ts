import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import * as Schema from "effect/Schema";
import {
  Db,
  type DbEntry,
  type DbGetEntry,
  type DbService,
  type DbSnapshot,
  type IteratorOptions,
  type DbWriteOp,
  type WriteBatch,
} from "./DbAdapter";
import { DbError } from "./DbError";
import type { BytesType } from "./DbTypes";
import {
  DbConfigSchema,
  DbNames,
  type DbConfig,
  type DbMetric,
  type ReadFlags,
  type WriteFlags,
} from "./DbTypes";
import {
  cloneBytes,
  cloneBytesEffect,
  compareBytes,
  decodeKey,
  encodeKey,
  startsWithBytes,
} from "./DbUtils";

export * from "./DbTypes";
export * from "./DbAdapter";
export { DbError } from "./DbError";

const validateConfig = (config: DbConfig): Effect.Effect<DbConfig, DbError> =>
  Effect.try({
    try: () => Schema.decodeSync(DbConfigSchema)(config),
    catch: (cause) => new DbError({ message: "Invalid DbConfig", cause }),
  });

const mergeUnsupportedError = () =>
  new DbError({ message: "Merge is not supported by the memory DB" });

const failMergeUnsupported = () => Effect.fail(mergeUnsupportedError());

const nullDbWriteError = () =>
  new DbError({ message: "NullDb does not support writes" });

const failNullDbWrite = () => Effect.fail(nullDbWriteError());

const rocksDbUnsupportedError = (operation: string) =>
  new DbError({
    message: `RocksDb backend stub does not implement ${operation}`,
  });

const failRocksDbUnsupported = <A>(
  operation: string,
): Effect.Effect<A, DbError> =>
  Effect.fail(rocksDbUnsupportedError(operation)) as Effect.Effect<A, DbError>;

type StoreEntry = {
  readonly key: BytesType;
  readonly value: BytesType;
};

const collectEntries = (store: Map<string, BytesType>): Array<StoreEntry> => {
  const entries: Array<StoreEntry> = [];
  for (const [keyHex, value] of store.entries()) {
    entries.push({ key: decodeKey(keyHex), value });
  }
  return entries;
};

const orderEntries = (entries: Array<StoreEntry>): Array<StoreEntry> => {
  entries.sort((left, right) => compareBytes(left.key, right.key));
  return entries;
};

const listEntries = (
  store: Map<string, BytesType>,
  ordered = false,
  getOrdered?: () => ReadonlyArray<StoreEntry>,
  getUnordered?: () => ReadonlyArray<StoreEntry>,
): ReadonlyArray<DbEntry> => {
  const baseEntries = ordered
    ? (getOrdered?.() ?? orderEntries(collectEntries(store)))
    : (getUnordered?.() ?? collectEntries(store));
  return baseEntries.map(({ key, value }) => ({
    key,
    value: cloneBytes(value),
  }));
};

type EntryCache = {
  readonly getOrdered?: () => ReadonlyArray<StoreEntry>;
  readonly getUnordered?: () => ReadonlyArray<StoreEntry>;
};

const makeReader = (
  store: Map<string, BytesType>,
  trackRead?: (count: number) => void,
  cache?: EntryCache,
): DbSnapshot => {
  const noteRead = (count = 1) => {
    if (trackRead) {
      trackRead(count);
    }
  };

  const getAll = (ordered?: boolean) =>
    Effect.sync(() =>
      listEntries(
        store,
        Boolean(ordered),
        cache?.getOrdered,
        cache?.getUnordered,
      ),
    );

  const getAllKeys = (ordered?: boolean) =>
    Effect.sync(() => {
      const keys = Array.from(store.keys(), (keyHex) => decodeKey(keyHex));
      if (ordered) {
        const orderedEntries = cache?.getOrdered?.();
        if (orderedEntries) {
          return orderedEntries.map(({ key }) => key);
        }
        keys.sort(compareBytes);
      }
      return keys;
    });

  const getAllValues = (ordered?: boolean) =>
    Effect.sync(() => {
      if (!ordered) {
        const unordered = cache?.getUnordered?.();
        if (unordered) return unordered.map(({ value }) => cloneBytes(value));
        return Array.from(store.values(), (value) => cloneBytes(value));
      }
      const entries =
        cache?.getOrdered?.() ?? orderEntries(collectEntries(store));
      return entries.map(({ value }) => cloneBytes(value));
    });

  const withPrefix = (
    entries: ReadonlyArray<StoreEntry>,
    options?: { readonly prefix?: BytesType },
  ) =>
    options?.prefix
      ? entries.filter((e) => startsWithBytes(e.key, options.prefix!))
      : entries;

  const range = (options?: IteratorOptions) =>
    Effect.sync(() => {
      const ordered =
        cache?.getOrdered?.() ?? orderEntries(collectEntries(store));
      const entries = withPrefix(ordered, options);
      return entries.map(({ key, value }) => ({
        key,
        value: cloneBytes(value),
      }));
    });

  const seek = (key: BytesType, options?: IteratorOptions) =>
    Effect.sync(() => {
      const ordered =
        cache?.getOrdered?.() ?? orderEntries(collectEntries(store));
      const entries = withPrefix(ordered, options);

      if (options?.prefix) {
        const p = options.prefix;
        const inPrefix = startsWithBytes(key, p);

        if (!inPrefix) {
          // Outside the prefix window: below -> first; above -> none
          const rel = compareBytes(key, p);
          if (rel < 0) {
            const first = entries[0];
            return first
              ? Option.some<DbEntry>({
                  key: first.key,
                  value: cloneBytes(first.value),
                })
              : Option.none<DbEntry>();
          }
          return Option.none<DbEntry>();
        }

        // Inside the prefix window: find lower_bound within the filtered set
        for (const entry of entries) {
          const cmp = compareBytes(entry.key, key);
          if (cmp >= 0) {
            return Option.some<DbEntry>({
              key: entry.key,
              value: cloneBytes(entry.value),
            });
          }
        }

        // Edge case: seeking exactly at the prefix key but that key is absent.
        // Nethermind ordering places all extended keys (prefix+bytes) before
        // the bare prefix key, so lower_bound would be empty; return first.
        if (compareBytes(key, p) === 0) {
          const first = entries[0];
          return first
            ? Option.some<DbEntry>({
                key: first.key,
                value: cloneBytes(first.value),
              })
            : Option.none<DbEntry>();
        }

        return Option.none<DbEntry>();
      }

      for (const entry of entries) {
        const cmp = compareBytes(entry.key, key);
        if (cmp >= 0) {
          return Option.some<DbEntry>({
            key: entry.key,
            value: cloneBytes(entry.value),
          });
        }
      }
      return Option.none<DbEntry>();
    });

  const next = (key: BytesType, options?: IteratorOptions) =>
    Effect.sync(() => {
      const ordered =
        cache?.getOrdered?.() ?? orderEntries(collectEntries(store));
      const entries = withPrefix(ordered, options);
      for (const entry of entries) {
        const cmp = compareBytes(entry.key, key);
        if (cmp > 0) {
          return Option.some<DbEntry>({
            key: entry.key,
            value: cloneBytes(entry.value),
          });
        }
      }
      return Option.none<DbEntry>();
    });

  const get = (key: BytesType, _flags?: ReadFlags) =>
    Effect.gen(function* () {
      const keyHex = yield* encodeKey(key);
      noteRead();
      const value = store.get(keyHex);
      return pipe(Option.fromNullable(value), Option.map(cloneBytes));
    });

  const getMany = (keys: ReadonlyArray<BytesType>) =>
    Effect.gen(function* () {
      if (keys.length > 0) {
        noteRead(keys.length);
      }
      const entries: Array<DbGetEntry> = [];

      for (const key of keys) {
        const keyHex = yield* encodeKey(key);
        const value = store.get(keyHex);
        entries.push({
          key,
          value: pipe(Option.fromNullable(value), Option.map(cloneBytes)),
        });
      }

      return entries;
    });

  const has = (key: BytesType) =>
    Effect.gen(function* () {
      const keyHex = yield* encodeKey(key);
      noteRead();
      return store.has(keyHex);
    });

  return {
    get,
    getMany,
    getAll,
    getAllKeys,
    getAllValues,
    seek,
    next,
    range,
    has,
  };
};

const makeNullSnapshot = (): DbSnapshot => {
  const get = (_key: BytesType, _flags?: ReadFlags) =>
    Effect.succeed(Option.none());

  const getMany = (keys: ReadonlyArray<BytesType>) =>
    Effect.succeed(
      keys.map((key) => ({
        key,
        value: Option.none(),
      })),
    );

  const getAll = (_ordered?: boolean) =>
    Effect.succeed<ReadonlyArray<DbEntry>>([]);

  const getAllKeys = (_ordered?: boolean) =>
    Effect.succeed<ReadonlyArray<BytesType>>([]);

  const getAllValues = (_ordered?: boolean) =>
    Effect.succeed<ReadonlyArray<BytesType>>([]);

  const has = (_key: BytesType) => Effect.succeed(false);

  const range = (_options?: { readonly prefix?: BytesType }) =>
    Effect.succeed<ReadonlyArray<DbEntry>>([]);

  const seek = (_key: BytesType, _options?: { readonly prefix?: BytesType }) =>
    Effect.succeed(Option.none<DbEntry>());

  const next = (_key: BytesType, _options?: { readonly prefix?: BytesType }) =>
    Effect.succeed(Option.none<DbEntry>());

  return {
    get,
    getMany,
    getAll,
    getAllKeys,
    getAllValues,
    seek,
    next,
    range,
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
    let totalReads = 0;
    let totalWrites = 0;
    const trackRead = (count = 1) => {
      totalReads += count;
    };
    const trackWrite = (count = 1) => {
      totalWrites += count;
    };

    // Lightweight caches for ordered / unordered entry views
    let cacheOrdered: ReadonlyArray<StoreEntry> | null = null;
    let cacheUnordered: ReadonlyArray<StoreEntry> | null = null;
    const resetCache = () => {
      cacheOrdered = null;
      cacheUnordered = null;
    };
    const getUnordered = () => {
      if (cacheUnordered) return cacheUnordered;
      cacheUnordered = collectEntries(store);
      return cacheUnordered;
    };
    const getOrdered = () => {
      if (cacheOrdered) return cacheOrdered;
      cacheOrdered = orderEntries(getUnordered().slice());
      return cacheOrdered;
    };

    const {
      get,
      getMany,
      getAll,
      getAllKeys,
      getAllValues,
      seek,
      next,
      range,
      has,
    } = makeReader(store, trackRead, { getOrdered, getUnordered });

    const put = (key: BytesType, value: BytesType, _flags?: WriteFlags) =>
      Effect.gen(function* () {
        const keyHex = yield* encodeKey(key);
        const storedValue = yield* cloneBytesEffect(value);
        store.set(keyHex, storedValue);
        resetCache();
        trackWrite();
      });

    const merge = (_key: BytesType, _value: BytesType, _flags?: WriteFlags) =>
      failMergeUnsupported();

    const remove = (key: BytesType) =>
      Effect.gen(function* () {
        const keyHex = yield* encodeKey(key);
        store.delete(keyHex);
        resetCache();
        trackWrite();
      });

    const createSnapshot = () =>
      Effect.map(
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
        (snapshotStore) => {
          // Snapshot is immutable; cache once lazily per snapshot
          let snapOrdered: ReadonlyArray<StoreEntry> | null = null;
          let snapUnordered: ReadonlyArray<StoreEntry> | null = null;
          const getSnapUnordered = () => {
            if (snapUnordered) return snapUnordered;
            snapUnordered = collectEntries(snapshotStore);
            return snapUnordered;
          };
          const getSnapOrdered = () => {
            if (snapOrdered) return snapOrdered;
            snapOrdered = orderEntries(getSnapUnordered().slice());
            return snapOrdered;
          };
          return makeReader(snapshotStore, undefined, {
            getOrdered: getSnapOrdered,
            getUnordered: getSnapUnordered,
          });
        },
      );

    const flush = (_onlyWal?: boolean) =>
      Effect.sync(() => {
        // no-op for in-memory DB
      });

    const clear = () =>
      Effect.sync(() => {
        store.clear();
        resetCache();
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
          totalReads,
          totalWrites,
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
              const value = yield* cloneBytesEffect(op.value);
              prepared.push({
                _tag: "put",
                keyHex,
                value,
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
            trackWrite();
          } else {
            store.delete(op.keyHex);
            trackWrite();
          }
        }
        resetCache();
      });

    const startWriteBatch = () =>
      Effect.acquireRelease(
        Effect.sync(() => {
          const put = (key: BytesType, value: BytesType, _flags?: WriteFlags) =>
            Effect.gen(function* () {
              const keyHex = yield* encodeKey(key);
              const storedValue = yield* cloneBytesEffect(value);
              store.set(keyHex, storedValue);
              resetCache();
              trackWrite();
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
              resetCache();
              trackWrite();
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
      getMany,
      getAll,
      getAllKeys,
      getAllValues,
      seek,
      next,
      range,
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

const makeNullDb = (config: DbConfig) =>
  Effect.gen(function* () {
    const validated = yield* validateConfig(config);
    const snapshot = makeNullSnapshot();

    const put = (_key: BytesType, _value: BytesType, _flags?: WriteFlags) =>
      failNullDbWrite();

    const merge = (_key: BytesType, _value: BytesType, _flags?: WriteFlags) =>
      failNullDbWrite();

    const remove = (_key: BytesType) => failNullDbWrite();

    const createSnapshot = () =>
      Effect.acquireRelease(
        Effect.sync(() => makeNullSnapshot()),
        () =>
          Effect.sync(() => {
            // no-op for null snapshot release
          }),
      );

    const flush = (_onlyWal?: boolean) =>
      Effect.sync(() => {
        // no-op for null DB
      });

    const clear = () =>
      Effect.sync(() => {
        // no-op for null DB
      });

    const compact = () =>
      Effect.sync(() => {
        // no-op for null DB
      });

    const gatherMetric = () =>
      Effect.sync(
        (): DbMetric => ({
          size: 0,
          cacheSize: 0,
          indexSize: 0,
          memtableSize: 0,
          totalReads: 0,
          totalWrites: 0,
        }),
      );

    const writeBatch = (_ops: ReadonlyArray<DbWriteOp>) => failNullDbWrite();

    const startWriteBatch = () =>
      Effect.acquireRelease(Effect.fail(nullDbWriteError()), () =>
        Effect.sync(() => {
          // no-op for null DB batch disposal
        }),
      );

    return {
      name: validated.name,
      get: snapshot.get,
      getMany: snapshot.getMany,
      getAll: snapshot.getAll,
      getAllKeys: snapshot.getAllKeys,
      getAllValues: snapshot.getAllValues,
      seek: snapshot.seek,
      next: snapshot.next,
      range: snapshot.range,
      put,
      merge,
      remove,
      has: snapshot.has,
      createSnapshot,
      flush,
      clear,
      compact,
      gatherMetric,
      writeBatch,
      startWriteBatch,
    } satisfies DbService;
  });

const makeRocksDb = (config: DbConfig) =>
  Effect.gen(function* () {
    const validated = yield* validateConfig(config);

    const get = (_key: BytesType, _flags?: ReadFlags) =>
      failRocksDbUnsupported<Option.Option<BytesType>>("get");

    const getMany = (_keys: ReadonlyArray<BytesType>) =>
      failRocksDbUnsupported<ReadonlyArray<DbGetEntry>>("getMany");

    const getAll = (_ordered?: boolean) =>
      failRocksDbUnsupported<ReadonlyArray<DbEntry>>("getAll");

    const getAllKeys = (_ordered?: boolean) =>
      failRocksDbUnsupported<ReadonlyArray<BytesType>>("getAllKeys");

    const getAllValues = (_ordered?: boolean) =>
      failRocksDbUnsupported<ReadonlyArray<BytesType>>("getAllValues");

    const seek = (
      _key: BytesType,
      _options?: { readonly prefix?: BytesType },
    ) => failRocksDbUnsupported<Option.Option<DbEntry>>("seek");

    const next = (
      _key: BytesType,
      _options?: { readonly prefix?: BytesType },
    ) => failRocksDbUnsupported<Option.Option<DbEntry>>("next");

    const range = (_options?: { readonly prefix?: BytesType }) =>
      failRocksDbUnsupported<ReadonlyArray<DbEntry>>("range");

    const put = (_key: BytesType, _value: BytesType, _flags?: WriteFlags) =>
      failRocksDbUnsupported<void>("put");

    const merge = (_key: BytesType, _value: BytesType, _flags?: WriteFlags) =>
      failRocksDbUnsupported<void>("merge");

    const remove = (_key: BytesType) => failRocksDbUnsupported<void>("remove");

    const has = (_key: BytesType) => failRocksDbUnsupported<boolean>("has");

    const createSnapshot = () =>
      failRocksDbUnsupported<DbSnapshot>("createSnapshot");

    const flush = (_onlyWal?: boolean) => failRocksDbUnsupported<void>("flush");

    const clear = () => failRocksDbUnsupported<void>("clear");

    const compact = () => failRocksDbUnsupported<void>("compact");

    const gatherMetric = () => failRocksDbUnsupported<DbMetric>("gatherMetric");

    const writeBatch = (_ops: ReadonlyArray<DbWriteOp>) =>
      failRocksDbUnsupported<void>("writeBatch");

    const startWriteBatch = () =>
      failRocksDbUnsupported<WriteBatch>("startWriteBatch");

    return {
      name: validated.name,
      get,
      getMany,
      getAll,
      getAllKeys,
      getAllValues,
      seek,
      next,
      range,
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

/** Null object DB layer (read-only, writes fail). */
export const DbNullLive = (config: DbConfig): Layer.Layer<Db, DbError> =>
  Layer.scoped(Db, makeNullDb(config));

/** Null object DB layer for tests. */
export const DbNullTest = (
  config: DbConfig = { name: DbNames.state },
): Layer.Layer<Db, DbError> => Layer.scoped(Db, makeNullDb(config));

/** RocksDB backend stub layer (all operations fail). */
export const DbRocksStubLive = (config: DbConfig): Layer.Layer<Db, DbError> =>
  Layer.effect(Db, makeRocksDb(config));

/** RocksDB backend stub layer for tests (all operations fail). */
export const DbRocksStubTest = (
  config: DbConfig = { name: DbNames.state },
): Layer.Layer<Db, DbError> => Layer.effect(Db, makeRocksDb(config));

const withDb = <A, E, R>(
  f: (db: DbService) => Effect.Effect<A, E, R>,
): Effect.Effect<A, E, R | Db> => Effect.flatMap(Db, f);

/** Retrieve a value by key. */
export const get = (key: BytesType, flags?: ReadFlags) =>
  withDb((db) => db.get(key, flags));

/** Retrieve values for multiple keys. */
export const getMany = (keys: ReadonlyArray<BytesType>) =>
  withDb((db) => db.getMany(keys));

/** Return all entries. */
export const getAll = (ordered?: boolean) => withDb((db) => db.getAll(ordered));

/** Return all keys. */
export const getAllKeys = (ordered?: boolean) =>
  withDb((db) => db.getAllKeys(ordered));

/** Return all values. */
export const getAllValues = (ordered?: boolean) =>
  withDb((db) => db.getAllValues(ordered));

/** Seek to the first entry with key >= `key`, optionally restricted by `prefix`. */
export const seek = (
  key: BytesType,
  options?: { readonly prefix?: BytesType },
) => withDb((db) => db.seek(key, options));

/** Move to the next entry with key > `key`, optionally restricted by `prefix`. */
export const next = (
  key: BytesType,
  options?: { readonly prefix?: BytesType },
) => withDb((db) => db.next(key, options));

/** Return all entries, optionally restricted by a `prefix`. */
export const range = (options?: { readonly prefix?: BytesType }) =>
  withDb((db) => db.range(options));

/** Store a value by key. */
export const put = (key: BytesType, value: BytesType, flags?: WriteFlags) =>
  withDb((db) => db.put(key, value, flags));

/** Merge a value by key. */
export const merge = (key: BytesType, value: BytesType, flags?: WriteFlags) =>
  withDb((db) => db.merge(key, value, flags));

/** Remove a value by key. */
export const remove = (key: BytesType) => withDb((db) => db.remove(key));

/** Check whether a key exists. */
export const has = (key: BytesType) => withDb((db) => db.has(key));

/** Create a read-only snapshot of the DB. */
export const createSnapshot = () => withDb((db) => db.createSnapshot());

/** Flush underlying storage buffers. */
export const flush = (onlyWal?: boolean) => withDb((db) => db.flush(onlyWal));

/** Clear all data from the database. */
export const clear = () => withDb((db) => db.clear());

/** Compact underlying storage. */
export const compact = () => withDb((db) => db.compact());

/** Gather DB metrics. */
export const gatherMetric = () => withDb((db) => db.gatherMetric());

/** Apply a batch of write operations. */
export const writeBatch = (ops: ReadonlyArray<DbWriteOp>) =>
  withDb((db) => db.writeBatch(ops));

/** Start a write batch scope. */
export const startWriteBatch = () => withDb((db) => db.startWriteBatch());
