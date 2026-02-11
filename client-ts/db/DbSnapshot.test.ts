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
          const snapshotStored = Option.match(snapshotValue, {
            onNone: () =>
              assert.fail("expected snapshot to contain initial value"),
            onSome: (v) => v,
          });
          assert.isTrue(Bytes.equals(snapshotStored, initial));

          const liveValue = yield* get(key);
          const liveStored = Option.match(liveValue, {
            onNone: () =>
              assert.fail("expected live DB to contain updated value"),
            onSome: (v) => v,
          });
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
          const firstVal = Option.match(first.value, {
            onNone: () =>
              assert.fail("expected first value to be present in snapshot"),
            onSome: (v) => v,
          });
          assert.isTrue(Bytes.equals(firstVal, initial));
          assert.isTrue(Bytes.equals(second.key, keyB));
          assert.isTrue(Option.isNone(second.value));
        }),
      );
    }).pipe(Effect.provide(DbMemoryTest())),
  );

  it.effect(
    "snapshot iterator seek/next/range operate over snapshot view",
    () =>
      Effect.gen(function* () {
        const a = toBytes("0x01");
        const b = toBytes("0x0100");
        const c = toBytes("0x02");

        yield* put(a, toBytes("0xaa"));
        yield* put(b, toBytes("0xbb"));

        yield* Effect.scoped(
          Effect.gen(function* () {
            const snapshot = yield* createSnapshot();

            // mutate live DB after snapshot
            yield* put(c, toBytes("0xcc"));

            const s = yield* snapshot.seek(toBytes("0x00"));
            const e = Option.match(s, {
              onNone: () =>
                assert.fail("expected snapshot seek to find first key"),
              onSome: (v) => v,
            });
            assert.isTrue(Bytes.equals(e.key, b));

            const n = yield* snapshot.next(b);
            const e2 = Option.match(n, {
              onNone: () =>
                assert.fail("expected snapshot next to find second key"),
              onSome: (v) => v,
            });
            assert.isTrue(Bytes.equals(e2.key, a));

            const all = yield* snapshot.range();
            assert.strictEqual(all.length, 2);
          }),
        );
      }).pipe(Effect.provide(DbMemoryTest())),
  );
});
