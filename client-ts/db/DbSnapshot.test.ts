import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import { Bytes } from "voltaire-effect/primitives";
import { DbMemoryTest, createSnapshot, get, put } from "./Db";
import { toBytes } from "./testUtils";

describe("Db snapshots", () => {
  it.effect("exposes a stable view of data", () =>
    Effect.gen(function* () {
      const key = toBytes("0x30");
      const initial = toBytes("0xaaaa");
      const updated = toBytes("0xbbbb");

      yield* put(key, initial);

      yield* Effect.scoped(
        Effect.gen(function* () {
          const snapshot = yield* createSnapshot();

          yield* put(key, updated);

          const snapshotValue = yield* snapshot.get(key);
          const snapshotStored = Option.getOrThrow(snapshotValue);
          assert.isTrue(Bytes.equals(snapshotStored, initial));

          const liveValue = yield* get(key);
          const liveStored = Option.getOrThrow(liveValue);
          assert.isTrue(Bytes.equals(liveStored, updated));
        }),
      );
    }).pipe(Effect.provide(DbMemoryTest())),
  );

  it.effect("getMany returns snapshot values in order", () =>
    Effect.gen(function* () {
      const keyA = toBytes("0x31");
      const keyB = toBytes("0x32");
      const initial = toBytes("0xaaaa");
      const updated = toBytes("0xbbbb");
      const added = toBytes("0xcccc");

      yield* put(keyA, initial);

      yield* Effect.scoped(
        Effect.gen(function* () {
          const snapshot = yield* createSnapshot();

          yield* put(keyA, updated);
          yield* put(keyB, added);

          const entries = yield* snapshot.getMany([keyA, keyB]);
          assert.strictEqual(entries.length, 2);
          const first = entries[0]!;
          const second = entries[1]!;
          assert.isTrue(Bytes.equals(first.key, keyA));
          assert.isTrue(Option.isSome(first.value));
          assert.isTrue(Bytes.equals(Option.getOrThrow(first.value), initial));
          assert.isTrue(Bytes.equals(second.key, keyB));
          assert.isTrue(Option.isNone(second.value));
        }),
      );
    }).pipe(Effect.provide(DbMemoryTest())),
  );
});
