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
});
