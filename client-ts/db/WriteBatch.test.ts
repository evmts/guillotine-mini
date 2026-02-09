import { assert, describe, it } from "@effect/vitest";
import { Effect, Option, Schema } from "effect";
import * as Bytes from "voltaire-effect/primitives/Bytes";
import { DbMemoryTest, get, put, startWriteBatch } from "./Db";

const toBytes = (hex: string) => Schema.decodeSync(Bytes.Hex)(hex);

describe("Db WriteBatch", () => {
  it.effect("commits on scope close", () =>
    Effect.gen(function* () {
      const key = toBytes("0x10");
      const value = toBytes("0xaaaa");

      yield* Effect.scoped(
        Effect.gen(function* () {
          const batch = yield* startWriteBatch();
          yield* batch.put(key, value);
          const interim = yield* get(key);
          assert.isTrue(Option.isNone(interim));
        }),
      );

      const result = yield* get(key);
      assert.isTrue(Option.isSome(result));
      assert.isTrue(Bytes.equals(result.value, value));
    }).pipe(Effect.provide(DbMemoryTest())),
  );

  it.effect("removes keys on commit", () =>
    Effect.gen(function* () {
      const key = toBytes("0x11");
      const value = toBytes("0xbeef");

      yield* put(key, value);
      yield* Effect.scoped(
        Effect.gen(function* () {
          const batch = yield* startWriteBatch();
          yield* batch.remove(key);
        }),
      );

      const result = yield* get(key);
      assert.isTrue(Option.isNone(result));
    }).pipe(Effect.provide(DbMemoryTest())),
  );

  it.effect("clear discards pending writes", () =>
    Effect.gen(function* () {
      const key = toBytes("0x12");
      const value = toBytes("0x1234");

      yield* Effect.scoped(
        Effect.gen(function* () {
          const batch = yield* startWriteBatch();
          yield* batch.put(key, value);
          yield* batch.clear();
        }),
      );

      const result = yield* get(key);
      assert.isTrue(Option.isNone(result));
    }).pipe(Effect.provide(DbMemoryTest())),
  );

  it.effect("last write wins within batch", () =>
    Effect.gen(function* () {
      const key = toBytes("0x13");
      const first = toBytes("0x01");
      const second = toBytes("0x02");

      yield* Effect.scoped(
        Effect.gen(function* () {
          const batch = yield* startWriteBatch();
          yield* batch.put(key, first);
          yield* batch.put(key, second);
        }),
      );

      const result = yield* get(key);
      assert.isTrue(Option.isSome(result));
      assert.isTrue(Bytes.equals(result.value, second));
    }).pipe(Effect.provide(DbMemoryTest())),
  );
});
