import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Exit from "effect/Exit";
import * as Option from "effect/Option";
import * as Scope from "effect/Scope";
import { Bytes } from "voltaire-effect/primitives";
import { DbMemoryTest, get, put, startWriteBatch } from "./Db";
import { toBytes } from "./testUtils";

describe("Db WriteBatch", () => {
  it.effect("writes through within scoped batch", () =>
    Effect.gen(function* () {
      const key = toBytes("0x10");
      const value = toBytes("0xaaaa");

      yield* Effect.scoped(
        Effect.gen(function* () {
          const batch = yield* startWriteBatch();
          yield* batch.put(key, value);
          const interim = yield* get(key);
          const stored = Option.getOrThrow(interim);
          assert.isTrue(Bytes.equals(stored, value));
        }),
      );

      const result = yield* get(key);
      const stored = Option.getOrThrow(result);
      assert.isTrue(Bytes.equals(stored, value));
    }).pipe(Effect.provide(DbMemoryTest())),
  );

  it.effect("writes through with explicit scope", () =>
    Effect.gen(function* () {
      const key = toBytes("0x14");
      const value = toBytes("0xbbbb");
      const scope = yield* Scope.make();
      const batch = yield* startWriteBatch().pipe(
        Effect.provideService(Scope.Scope, scope),
      );

      yield* batch.put(key, value);
      const interim = yield* get(key);
      const stored = Option.getOrThrow(interim);
      assert.isTrue(Bytes.equals(stored, value));

      yield* Scope.close(scope, Exit.succeed(undefined));

      const result = yield* get(key);
      const storedAfter = Option.getOrThrow(result);
      assert.isTrue(Bytes.equals(storedAfter, value));
    }).pipe(Effect.provide(DbMemoryTest())),
  );

  it.effect("removes keys immediately", () =>
    Effect.gen(function* () {
      const key = toBytes("0x11");
      const value = toBytes("0xbeef");

      yield* put(key, value);
      yield* Effect.scoped(
        Effect.gen(function* () {
          const batch = yield* startWriteBatch();
          yield* batch.remove(key);
          const interim = yield* get(key);
          assert.isTrue(Option.isNone(interim));
        }),
      );

      const result = yield* get(key);
      assert.isTrue(Option.isNone(result));
    }).pipe(Effect.provide(DbMemoryTest())),
  );

  it.effect("clear is a no-op for write-through batches", () =>
    Effect.gen(function* () {
      const key = toBytes("0x12");
      const value = toBytes("0x1234");

      yield* Effect.scoped(
        Effect.gen(function* () {
          const batch = yield* startWriteBatch();
          yield* batch.put(key, value);
          yield* batch.clear();
          const interim = yield* get(key);
          const stored = Option.getOrThrow(interim);
          assert.isTrue(Bytes.equals(stored, value));
        }),
      );

      const result = yield* get(key);
      const stored = Option.getOrThrow(result);
      assert.isTrue(Bytes.equals(stored, value));
    }).pipe(Effect.provide(DbMemoryTest())),
  );

  it.effect("clear does not drop prior or later writes", () =>
    Effect.gen(function* () {
      const firstKey = toBytes("0x15");
      const firstValue = toBytes("0x9999");
      const secondKey = toBytes("0x16");
      const secondValue = toBytes("0x7777");

      yield* Effect.scoped(
        Effect.gen(function* () {
          const batch = yield* startWriteBatch();
          yield* batch.put(firstKey, firstValue);
          yield* batch.clear();
          yield* batch.put(secondKey, secondValue);

          const firstInterim = yield* get(firstKey);
          const firstStored = Option.getOrThrow(firstInterim);
          assert.isTrue(Bytes.equals(firstStored, firstValue));

          const secondInterim = yield* get(secondKey);
          const secondStored = Option.getOrThrow(secondInterim);
          assert.isTrue(Bytes.equals(secondStored, secondValue));
        }),
      );

      const firstResult = yield* get(firstKey);
      const firstStored = Option.getOrThrow(firstResult);
      assert.isTrue(Bytes.equals(firstStored, firstValue));

      const secondResult = yield* get(secondKey);
      const secondStored = Option.getOrThrow(secondResult);
      assert.isTrue(Bytes.equals(secondStored, secondValue));
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
      const stored = Option.getOrThrow(result);
      assert.isTrue(Bytes.equals(stored, second));
    }).pipe(Effect.provide(DbMemoryTest())),
  );
});
