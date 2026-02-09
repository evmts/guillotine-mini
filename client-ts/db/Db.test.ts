import { assert, describe, it } from "@effect/vitest";
import { Effect, Option, Schema } from "effect";
import * as Bytes from "voltaire-effect/primitives/Bytes";
import { DbMemoryTest, get, has, put, remove } from "./Db";

const toBytes = (hex: string) => Schema.decodeSync(Bytes.Hex)(hex);

describe("Db", () => {
  it.effect("put/get round-trips bytes", () =>
    Effect.gen(function* () {
      const key = toBytes("0x01");
      const value = toBytes("0xdeadbeef");

      yield* put(key, value);
      const result = yield* get(key);

      assert.isTrue(Option.isSome(result));
      assert.isTrue(Bytes.equals(result.value, value));
    }).pipe(Effect.provide(DbMemoryTest())),
  );

  it.effect("get returns none for missing keys", () =>
    Effect.gen(function* () {
      const key = toBytes("0x02");
      const result = yield* get(key);
      assert.isTrue(Option.isNone(result));
    }).pipe(Effect.provide(DbMemoryTest())),
  );

  it.effect("has reflects put/remove", () =>
    Effect.gen(function* () {
      const key = toBytes("0x03");
      const value = toBytes("0x01");

      assert.isFalse(yield* has(key));
      yield* put(key, value);
      assert.isTrue(yield* has(key));
      yield* remove(key);
      assert.isFalse(yield* has(key));
    }).pipe(Effect.provide(DbMemoryTest())),
  );

  it.effect("remove deletes stored values", () =>
    Effect.gen(function* () {
      const key = toBytes("0x04");
      const value = toBytes("0x1234");

      yield* put(key, value);
      yield* remove(key);
      const result = yield* get(key);
      assert.isTrue(Option.isNone(result));
    }).pipe(Effect.provide(DbMemoryTest())),
  );
});
