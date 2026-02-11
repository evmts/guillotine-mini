import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import {
  Db,
  type DbEntry,
  type DbGetEntry,
  type DbService,
  type DbSnapshot,
  type DbWriteOp,
  type WriteBatch,
} from "./DbAdapter";
import type { BytesType } from "./DbTypes";
import { toBytes } from "./testUtils";

type StoreEntry = {
  readonly key: BytesType;
  readonly value: BytesType;
};

type Hooks = {
  readonly onSnapshotRelease?: () => void;
  readonly onWriteBatchRelease?: () => void;
};

// Note: Always use voltaire-effect primitives for bytes construction.
// Tests must not instantiate raw Uint8Array directly.

const keyOf = (key: BytesType): string => String(key);

const orderEntries = (
  entries: ReadonlyArray<StoreEntry>,
): ReadonlyArray<StoreEntry> => {
  return [...entries].sort((left, right) =>
    keyOf(left.key).localeCompare(keyOf(right.key)),
  );
};

const makeSnapshot = (store: Map<string, StoreEntry>): DbSnapshot => {
  const get = (key: BytesType) => {
    const entry = store.get(keyOf(key));
    return Effect.succeed(Option.fromNullable(entry?.value));
  };

  const getMany = (keys: ReadonlyArray<BytesType>) =>
    Effect.succeed(
      keys.map(
        (key): DbGetEntry => ({
          key,
          value: Option.fromNullable(store.get(keyOf(key))?.value),
        }),
      ),
    );

  const getAll = (ordered = false) =>
    Effect.succeed<ReadonlyArray<DbEntry>>(
      (ordered ? orderEntries([...store.values()]) : [...store.values()]).map(
        ({ key, value }) => ({ key, value }),
      ),
    );

  const getAllKeys = (ordered = false) =>
    Effect.succeed(
      (ordered ? orderEntries([...store.values()]) : [...store.values()]).map(
        ({ key }) => key,
      ),
    );

  const getAllValues = (ordered = false) =>
    Effect.succeed(
      (ordered ? orderEntries([...store.values()]) : [...store.values()]).map(
        ({ value }) => value,
      ),
    );

  const has = (key: BytesType) => Effect.succeed(store.has(keyOf(key)));

  const sorted = () => orderEntries([...store.values()]);

  const seek = (key: BytesType) =>
    Effect.succeed(
      (() => {
        for (const { key: k, value } of sorted()) {
          if (String(k) >= String(key)) return Option.some({ key: k, value });
        }
        return Option.none();
      })(),
    );

  const next = (key: BytesType) =>
    Effect.succeed(
      (() => {
        for (const { key: k, value } of sorted()) {
          if (String(k) > String(key)) return Option.some({ key: k, value });
        }
        return Option.none();
      })(),
    );

  const range = () =>
    Effect.succeed<ReadonlyArray<DbEntry>>(
      sorted().map(({ key, value }) => ({
        key,
        value,
      })),
    );

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

const makeDbService = (hooks: Hooks = {}): DbService => {
  const store = new Map<string, StoreEntry>();
  let totalReads = 0;
  let totalWrites = 0;

  const snapshotView = () => makeSnapshot(store);

  const get = (key: BytesType) => {
    totalReads += 1;
    const entry = store.get(keyOf(key));
    return Effect.succeed(Option.fromNullable(entry?.value));
  };

  const getMany = (keys: ReadonlyArray<BytesType>) => {
    totalReads += keys.length;
    return Effect.succeed(
      keys.map(
        (key): DbGetEntry => ({
          key,
          value: Option.fromNullable(store.get(keyOf(key))?.value),
        }),
      ),
    );
  };

  const getAll = (ordered?: boolean) => snapshotView().getAll(ordered);
  const getAllKeys = (ordered?: boolean) => snapshotView().getAllKeys(ordered);
  const getAllValues = (ordered?: boolean) =>
    snapshotView().getAllValues(ordered);

  const put = (key: BytesType, value: BytesType) =>
    Effect.sync(() => {
      store.set(keyOf(key), { key, value });
      totalWrites += 1;
    });

  const merge = (key: BytesType, value: BytesType) => put(key, value);

  const remove = (key: BytesType) =>
    Effect.sync(() => {
      store.delete(keyOf(key));
      totalWrites += 1;
    });

  const has = (key: BytesType) => {
    totalReads += 1;
    return Effect.succeed(store.has(keyOf(key)));
  };

  const createSnapshot = () =>
    Effect.acquireRelease(
      Effect.sync(() => {
        const snapshotStore = new Map<string, StoreEntry>(
          [...store.entries()].map(([key, entry]) => [key, { ...entry }]),
        );
        return makeSnapshot(snapshotStore);
      }),
      () =>
        Effect.sync(() => {
          hooks.onSnapshotRelease?.();
        }),
    );

  const flush = (_onlyWal?: boolean) => Effect.void;
  const clear = () =>
    Effect.sync(() => {
      store.clear();
    });
  const compact = () => Effect.void;

  const gatherMetric = () =>
    Effect.succeed({
      size: store.size,
      cacheSize: 0,
      indexSize: 0,
      memtableSize: 0,
      totalReads,
      totalWrites,
    });

  const writeBatch = (ops: ReadonlyArray<DbWriteOp>) =>
    Effect.gen(function* () {
      for (const op of ops) {
        if (op._tag === "del") {
          yield* remove(op.key);
          continue;
        }
        yield* put(op.key, op.value);
      }
    });

  const startWriteBatch = () =>
    Effect.acquireRelease(
      Effect.sync(
        (): WriteBatch => ({
          put: (key: BytesType, value: BytesType) => put(key, value),
          merge: (key: BytesType, value: BytesType) => merge(key, value),
          remove: (key: BytesType) => remove(key),
          clear: () => Effect.void,
        }),
      ),
      () =>
        Effect.sync(() => {
          hooks.onWriteBatchRelease?.();
        }),
    );

  const seek = (key: BytesType) => snapshotView().seek(key);
  const next = (key: BytesType) => snapshotView().next(key);
  const range = () => snapshotView().range();

  return {
    name: "state",
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
};

const provideDb = (service: DbService) => Layer.succeed(Db, service);

describe("DbAdapter", () => {
  it.effect(
    "wires Db Context.Tag through Layer and exercises IDb + IDbMeta",
    () =>
      Effect.gen(function* () {
        const key = toBytes("0x01");
        const value = toBytes("0x02");

        const service = makeDbService();
        const program = Effect.gen(function* () {
          const db = yield* Db;

          assert.isFalse(yield* db.has(key));

          yield* db.put(key, value);
          assert.isTrue(yield* db.has(key));

          const read = yield* db.get(key);
          assert.isTrue(Option.isSome(read));
          assert.deepStrictEqual(Option.getOrNull(read), value);

          const many = yield* db.getMany([key, toBytes("0xff")]);
          assert.strictEqual(many.length, 2);
          assert.isTrue(Option.isSome(many[0]!.value));
          assert.isTrue(Option.isNone(many[1]!.value));

          const all = yield* db.getAll();
          assert.strictEqual(all.length, 1);
          assert.deepStrictEqual(all[0]!.value, value);

          yield* db.flush();
          yield* db.compact();

          const metric = yield* db.gatherMetric();
          assert.strictEqual(metric.size, 1);
          assert.strictEqual(metric.totalReads, 5);
          assert.strictEqual(metric.totalWrites, 1);

          yield* db.clear();
          assert.isFalse(yield* db.has(key));
        });

        yield* program.pipe(Effect.provide(provideDb(service)));
      }),
  );

  it.effect(
    "scopes snapshot and write-batch boundaries with release finalizers",
    () =>
      Effect.gen(function* () {
        let snapshotReleases = 0;
        let writeBatchReleases = 0;

        const key = toBytes("0x03");
        const value = toBytes("0x04");

        const service = makeDbService({
          onSnapshotRelease: () => {
            snapshotReleases += 1;
          },
          onWriteBatchRelease: () => {
            writeBatchReleases += 1;
          },
        });

        const layer = provideDb(service);

        const scopedProgram = Effect.scoped(
          Effect.gen(function* () {
            const db = yield* Db;

            const snapshot = yield* db.createSnapshot();
            assert.isFalse(yield* snapshot.has(key));

            const batch = yield* db.startWriteBatch();
            yield* batch.put(key, value);
            yield* batch.clear();
          }),
        );

        yield* scopedProgram.pipe(Effect.provide(layer));
        assert.strictEqual(snapshotReleases, 1);
        assert.strictEqual(writeBatchReleases, 1);

        const readProgram = Effect.gen(function* () {
          const db = yield* Db;
          const result = yield* db.get(key);
          return Option.getOrNull(result);
        });

        const stored = yield* readProgram.pipe(Effect.provide(layer));
        assert.deepStrictEqual(stored, value);
      }),
  );
});
