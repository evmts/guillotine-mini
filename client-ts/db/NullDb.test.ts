import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import {
  DbNullTest,
  clear,
  compact,
  createSnapshot,
  flush,
  gatherMetric,
  get,
  getAll,
  getAllKeys,
  getAllValues,
  has,
  merge,
  put,
  remove,
  startWriteBatch,
  writeBatch,
} from "./Db";
import { toBytes } from "./testUtils";

describe("NullDb", () => {
  it.effect("returns empty reads and missing keys", () =>
    Effect.gen(function* () {
      const key = toBytes("0x01");

      const value = yield* get(key);
      assert.isTrue(Option.isNone(value));
      assert.isFalse(yield* has(key));
      assert.deepStrictEqual(yield* getAll(), []);
      assert.deepStrictEqual(yield* getAllKeys(), []);
      assert.deepStrictEqual(yield* getAllValues(), []);
    }).pipe(Effect.provide(DbNullTest())),
  );

  it.effect("creates empty snapshots", () =>
    Effect.gen(function* () {
      const key = toBytes("0x02");

      yield* Effect.scoped(
        Effect.gen(function* () {
          const snapshot = yield* createSnapshot();
          const value = yield* snapshot.get(key);
          assert.isTrue(Option.isNone(value));
          assert.isFalse(yield* snapshot.has(key));
        }),
      );
    }).pipe(Effect.provide(DbNullTest())),
  );

  it.effect("rejects write operations", () =>
    Effect.gen(function* () {
      const key = toBytes("0x03");
      const value = toBytes("0xdead");

      const putError = yield* Effect.flip(put(key, value));
      assert.strictEqual(putError._tag, "DbError");

      const mergeError = yield* Effect.flip(merge(key, value));
      assert.strictEqual(mergeError._tag, "DbError");

      const removeError = yield* Effect.flip(remove(key));
      assert.strictEqual(removeError._tag, "DbError");

      const batchError = yield* Effect.flip(
        writeBatch([{ _tag: "put", key, value }]),
      );
      assert.strictEqual(batchError._tag, "DbError");

      const startBatchError = yield* Effect.flip(
        Effect.scoped(startWriteBatch()),
      );
      assert.strictEqual(startBatchError._tag, "DbError");
    }).pipe(Effect.provide(DbNullTest())),
  );

  it.effect("no-ops maintenance operations", () =>
    Effect.gen(function* () {
      yield* flush();
      yield* clear();
      yield* compact();
      const metrics = yield* gatherMetric();
      assert.deepStrictEqual(metrics, {
        size: 0,
        cacheSize: 0,
        indexSize: 0,
        memtableSize: 0,
        totalReads: 0,
        totalWrites: 0,
      });
    }).pipe(Effect.provide(DbNullTest())),
  );
});
