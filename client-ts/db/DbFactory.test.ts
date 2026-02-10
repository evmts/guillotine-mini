import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import { Bytes } from "voltaire-effect/primitives";
import {
  DbFactoryMemoryTest,
  DbFactoryRocksStubTest,
  createDb,
} from "./DbFactory";
import { DbNames } from "./DbTypes";
import { toBytes } from "./testUtils";

describe("DbFactory", () => {
  it.effect("memory factory creates a functional DB", () =>
    Effect.scoped(
      Effect.gen(function* () {
        const db = yield* createDb({ name: DbNames.state });
        const key = toBytes("0x01");
        const value = toBytes("0xabcd");

        yield* db.put(key, value);
        const result = yield* db.get(key);

        assert.strictEqual(db.name, DbNames.state);
        assert.isTrue(Option.isSome(result));
        assert.isTrue(Bytes.equals(Option.getOrThrow(result), value));
      }),
    ).pipe(Effect.provide(DbFactoryMemoryTest)),
  );

  it.effect("rocksdb stub factory creates a stub DB", () =>
    Effect.scoped(
      Effect.gen(function* () {
        const db = yield* createDb({ name: DbNames.state });
        const key = toBytes("0x02");

        assert.strictEqual(db.name, DbNames.state);
        const error = yield* Effect.flip(db.get(key));
        assert.strictEqual(error._tag, "DbError");
        assert.isTrue(error.message.includes("does not implement get"));
      }),
    ).pipe(Effect.provide(DbFactoryRocksStubTest)),
  );
});
