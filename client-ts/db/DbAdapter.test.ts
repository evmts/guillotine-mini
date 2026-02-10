import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import {
  type DbService,
  type DbSnapshot,
  type WriteBatch,
  type BytesType,
  DbNames,
  ReadFlags,
  WriteFlags,
} from "./Db";

const makeSnapshot = (): DbSnapshot => ({
  get: (_key, _flags) => Effect.succeed(Option.none()),
  getMany: (keys) =>
    Effect.succeed(keys.map((key) => ({ key, value: Option.none() }))),
  getAll: (_ordered) => Effect.succeed([]),
  getAllKeys: (_ordered) => Effect.succeed([]),
  getAllValues: (_ordered) => Effect.succeed([]),
  has: (_key) => Effect.succeed(false),
});

const makeWriteBatch = (): WriteBatch => ({
  put: (_key, _value, _flags) => Effect.void,
  merge: (_key, _value, _flags) => Effect.void,
  remove: (_key) => Effect.void,
  clear: () => Effect.void,
});

const makeDbService = (): DbService =>
  ({
    name: DbNames.state,
    get: (_key, _flags = ReadFlags.None) => Effect.succeed(Option.none()),
    getMany: (keys) =>
      Effect.succeed(keys.map((key) => ({ key, value: Option.none() }))),
    getAll: (_ordered) => Effect.succeed([]),
    getAllKeys: (_ordered) => Effect.succeed([]),
    getAllValues: (_ordered) => Effect.succeed([]),
    put: (_key, _value, _flags = WriteFlags.None) => Effect.void,
    merge: (_key, _value, _flags = WriteFlags.None) => Effect.void,
    remove: (_key) => Effect.void,
    has: (_key) => Effect.succeed(false),
    createSnapshot: () =>
      Effect.acquireRelease(Effect.sync(makeSnapshot), () =>
        Effect.sync(() => {
          // no-op release for test snapshot
        }),
      ),
    flush: (_onlyWal) => Effect.void,
    clear: () => Effect.void,
    compact: () => Effect.void,
    gatherMetric: () =>
      Effect.succeed({
        size: 0,
        cacheSize: 0,
        indexSize: 0,
        memtableSize: 0,
        totalReads: 0,
        totalWrites: 0,
      }),
    writeBatch: (_ops) => Effect.void,
    startWriteBatch: () =>
      Effect.acquireRelease(Effect.sync(makeWriteBatch), () =>
        Effect.sync(() => {
          // no-op release for test batch
        }),
      ),
  }) satisfies DbService;

describe("DbAdapter", () => {
  it.effect("keeps IDb + IDbMeta boundary methods available", () =>
    Effect.gen(function* () {
      const service = makeDbService();
      const key = "0x01" as BytesType;
      const value = "0x02" as BytesType;

      const read = yield* service.get(key);
      assert.isTrue(Option.isNone(read));
      assert.isFalse(yield* service.has(key));

      yield* service.put(key, value);
      yield* service.merge(key, value);
      yield* service.remove(key);

      yield* service.flush();
      yield* service.clear();
      yield* service.compact();

      const metric = yield* service.gatherMetric();
      assert.deepStrictEqual(metric, {
        size: 0,
        cacheSize: 0,
        indexSize: 0,
        memtableSize: 0,
        totalReads: 0,
        totalWrites: 0,
      });
    }),
  );

  it.effect("exposes scoped snapshot and write-batch boundaries", () =>
    Effect.gen(function* () {
      const service = makeDbService();
      const key = "0x03" as BytesType;

      const snapshot = yield* Effect.scoped(service.createSnapshot());
      assert.isFalse(yield* snapshot.has(key));

      const batch = yield* Effect.scoped(service.startWriteBatch());
      yield* batch.put(key, "0x04" as BytesType);
      yield* batch.clear();
    }),
  );
});
