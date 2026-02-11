import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import { Db } from "./Db";
import {
  DbRocksStubTest,
  clear,
  compact,
  createSnapshot,
  flush,
  gatherMetric,
  get,
  getAll,
  getAllKeys,
  getAllValues,
  next,
  getMany,
  has,
  merge,
  range,
  put,
  remove,
  seek,
  startWriteBatch,
  writeBatch,
} from "./Db";
import type { DbError } from "./Db";
import { DbNames } from "./DbTypes";
import { toBytes } from "./testUtils";

describe("DbRocksStub", () => {
  it.effect("exposes configured db name", () =>
    Effect.gen(function* () {
      const db = yield* Db;
      assert.strictEqual(db.name, DbNames.state);
    }).pipe(Effect.provide(DbRocksStubTest())),
  );

  it.effect("fails all operations with DbError", () =>
    Effect.gen(function* () {
      const key = toBytes("0x01");
      const value = toBytes("0xdeadbeef");

      const expectUnsupported = <A, R>(
        effect: Effect.Effect<A, DbError, R>,
        operation: string,
      ) =>
        Effect.gen(function* () {
          const error = yield* Effect.flip(effect);
          assert.strictEqual(error._tag, "DbError");
          assert.isTrue(
            error.message.includes(`does not implement ${operation}`),
          );
        });

      yield* expectUnsupported(get(key), "get");
      yield* expectUnsupported(getMany([key]), "getMany");
      yield* expectUnsupported(getAll(), "getAll");
      yield* expectUnsupported(getAllKeys(), "getAllKeys");
      yield* expectUnsupported(getAllValues(), "getAllValues");
      yield* expectUnsupported(seek(key), "seek");
      yield* expectUnsupported(next(key), "next");
      yield* expectUnsupported(range(), "range");
      yield* expectUnsupported(put(key, value), "put");
      yield* expectUnsupported(merge(key, value), "merge");
      yield* expectUnsupported(remove(key), "remove");
      yield* expectUnsupported(has(key), "has");
      yield* expectUnsupported(
        Effect.scoped(createSnapshot()),
        "createSnapshot",
      );
      yield* expectUnsupported(flush(), "flush");
      yield* expectUnsupported(clear(), "clear");
      yield* expectUnsupported(compact(), "compact");
      yield* expectUnsupported(gatherMetric(), "gatherMetric");
      yield* expectUnsupported(
        writeBatch([{ _tag: "put", key, value }]),
        "writeBatch",
      );
      yield* expectUnsupported(
        Effect.scoped(startWriteBatch()),
        "startWriteBatch",
      );
    }).pipe(Effect.provide(DbRocksStubTest())),
  );
});
