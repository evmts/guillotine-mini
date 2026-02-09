import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Exit from "effect/Exit";
import * as Option from "effect/Option";
import * as Scope from "effect/Scope";
import { Bytes, Hex } from "voltaire-effect/primitives";
import { DbMemoryTest, get, put, startWriteBatch } from "./Db";
import type { BytesType } from "./Db";

const toBytes = (hex: string): BytesType => Hex.toBytes(hex) as BytesType;

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
      const stored = Option.getOrThrow(result);
      assert.isTrue(Bytes.equals(stored, value));
    }).pipe(Effect.provide(DbMemoryTest())),
  );

  it.effect("commits when scope closes explicitly", () =>
    Effect.gen(function* () {
      const key = toBytes("0x14");
      const value = toBytes("0xbbbb");
      const scope = yield* Scope.make();
      const batch = yield* startWriteBatch().pipe(
        Effect.provideService(Scope.Scope, scope),
      );

      yield* batch.put(key, value);
      const interim = yield* get(key);
      assert.isTrue(Option.isNone(interim));

      yield* Scope.close(scope, Exit.succeed(undefined));

      const result = yield* get(key);
      const stored = Option.getOrThrow(result);
      assert.isTrue(Bytes.equals(stored, value));
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

  it.effect("clear resets pending writes but keeps later ones", () =>
    Effect.gen(function* () {
      const clearedKey = toBytes("0x15");
      const clearedValue = toBytes("0x9999");
      const committedKey = toBytes("0x16");
      const committedValue = toBytes("0x7777");

      yield* Effect.scoped(
        Effect.gen(function* () {
          const batch = yield* startWriteBatch();
          yield* batch.put(clearedKey, clearedValue);
          yield* batch.clear();
          yield* batch.put(committedKey, committedValue);
        }),
      );

      const clearedResult = yield* get(clearedKey);
      assert.isTrue(Option.isNone(clearedResult));

      const committedResult = yield* get(committedKey);
      const stored = Option.getOrThrow(committedResult);
      assert.isTrue(Bytes.equals(stored, committedValue));
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
