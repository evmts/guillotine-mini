import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import { Bytes } from "voltaire-effect/primitives";
import { DbMemoryTest, DbNullTest, getMany, put } from "./Db";
import { toBytes } from "./testUtils";

describe("Db getMany", () => {
  it.effect("returns values in input order with none for missing keys", () =>
    Effect.gen(function* () {
      const keyA = toBytes("0x10");
      const keyB = toBytes("0x11");
      const keyC = toBytes("0x12");
      const valueA = toBytes("0xaa");
      const valueC = toBytes("0xcc");

      yield* put(keyA, valueA);
      yield* put(keyC, valueC);

      const entries = yield* getMany([keyA, keyB, keyC]);
      assert.strictEqual(entries.length, 3);
      const first = entries[0]!;
      const second = entries[1]!;
      const third = entries[2]!;
      assert.isTrue(Bytes.equals(first.key, keyA));
      assert.isTrue(Option.isSome(first.value));
      assert.isTrue(Bytes.equals(Option.getOrThrow(first.value), valueA));
      assert.isTrue(Bytes.equals(second.key, keyB));
      assert.isTrue(Option.isNone(second.value));
      assert.isTrue(Bytes.equals(third.key, keyC));
      assert.isTrue(Option.isSome(third.value));
      assert.isTrue(Bytes.equals(Option.getOrThrow(third.value), valueC));
    }).pipe(Effect.provide(DbMemoryTest())),
  );

  it.effect("returns none for all keys in NullDb", () =>
    Effect.gen(function* () {
      const keyA = toBytes("0x20");
      const keyB = toBytes("0x21");

      const entries = yield* getMany([keyA, keyB]);
      assert.strictEqual(entries.length, 2);
      const first = entries[0]!;
      const second = entries[1]!;
      assert.isTrue(Bytes.equals(first.key, keyA));
      assert.isTrue(Option.isNone(first.value));
      assert.isTrue(Bytes.equals(second.key, keyB));
      assert.isTrue(Option.isNone(second.value));
    }).pipe(Effect.provide(DbNullTest())),
  );
});
