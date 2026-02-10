import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import { Bytes } from "voltaire-effect/primitives";
import { Db, DbMemoryTest } from "./Db";
import { ReadOnlyDb, ReadOnlyDbLive } from "./ReadOnlyDb";
import { toBytes } from "./testUtils";

describe("ReadOnlyDb", () => {
  it.effect("reads through to the base db and overlays writes", () =>
    Effect.gen(function* () {
      const base = yield* Db;
      const readOnly = yield* ReadOnlyDb;

      const key = toBytes("0x41");
      const baseValue = toBytes("0xaaaa");
      const overlayValue = toBytes("0xbbbb");

      yield* base.put(key, baseValue);

      const readThrough = yield* readOnly.get(key);
      assert.isTrue(Bytes.equals(Option.getOrThrow(readThrough), baseValue));

      yield* readOnly.put(key, overlayValue);

      const overlayRead = yield* readOnly.get(key);
      assert.isTrue(Bytes.equals(Option.getOrThrow(overlayRead), overlayValue));

      const baseRead = yield* base.get(key);
      assert.isTrue(Bytes.equals(Option.getOrThrow(baseRead), baseValue));
    }).pipe(
      Effect.provide(
        Layer.provideMerge(DbMemoryTest())(
          ReadOnlyDbLive({ createInMemWriteStore: true }),
        ),
      ),
    ),
  );

  it.effect("blocks writes when overlay is disabled", () =>
    Effect.gen(function* () {
      const readOnly = yield* ReadOnlyDb;
      const key = toBytes("0x42");
      const value = toBytes("0xdead");

      const error = yield* Effect.flip(readOnly.put(key, value));
      assert.strictEqual(error._tag, "DbError");
    }).pipe(
      Effect.provide(Layer.provideMerge(DbMemoryTest())(ReadOnlyDbLive())),
    ),
  );
});
