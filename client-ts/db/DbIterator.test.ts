import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import { Bytes, Hex } from "voltaire-effect/primitives";
import { DbMemoryTest, next, put, range, seek } from "./Db";
import { toBytes } from "./testUtils";

describe("Db iterator API", () => {
  it.effect("seek returns first >= key with ordering", () =>
    Effect.gen(function* () {
      const a = toBytes("0x01");
      const b = toBytes("0x0100");
      const c = toBytes("0x02");

      yield* put(a, toBytes("0xaa"));
      yield* put(b, toBytes("0xbb"));
      yield* put(c, toBytes("0xcc"));

      // Nethermind ordering: 0x0100 < 0x01 < 0x02
      const s1 = yield* seek(toBytes("0x00"));
      const e1 = Option.getOrThrow(s1);
      assert.isTrue(Bytes.equals(e1.key, b));

      const s2 = yield* seek(toBytes("0x01"));
      const e2 = Option.getOrThrow(s2);
      assert.isTrue(Bytes.equals(e2.key, a));

      const s3 = yield* seek(toBytes("0x0200"));
      const e3 = Option.getOrThrow(s3);
      assert.isTrue(Bytes.equals(e3.key, c));
    }).pipe(Effect.provide(DbMemoryTest())),
  );

  it.effect("next returns strictly greater entries", () =>
    Effect.gen(function* () {
      const a = toBytes("0x01");
      const b = toBytes("0x0100");
      const c = toBytes("0x02");

      yield* put(a, toBytes("0xaa"));
      yield* put(b, toBytes("0xbb"));
      yield* put(c, toBytes("0xcc"));

      const n1 = yield* next(b);
      const e1 = Option.getOrThrow(n1);
      assert.isTrue(Bytes.equals(e1.key, a));

      const n2 = yield* next(a);
      const e2 = Option.getOrThrow(n2);
      assert.isTrue(Bytes.equals(e2.key, c));

      const n3 = yield* next(c);
      assert.isTrue(Option.isNone(n3));
    }).pipe(Effect.provide(DbMemoryTest())),
  );

  it.effect("range supports optional prefix filtering", () =>
    Effect.gen(function* () {
      const p = Hex.toBytes("0x1000");
      const k1 = Hex.toBytes("0x100001");
      const k2 = Hex.toBytes("0x1000ffff");
      const k3 = Hex.toBytes("0x10ff");

      yield* put(k1 as any, toBytes("0xaa"));
      yield* put(k2 as any, toBytes("0xbb"));
      yield* put(k3 as any, toBytes("0xcc"));

      const entries = yield* range({ prefix: p as any });
      assert.strictEqual(entries.length, 2);
      assert.isTrue(Bytes.equals(entries[0]!.key, k1 as any));
      assert.isTrue(Bytes.equals(entries[1]!.key, k2 as any));
    }).pipe(Effect.provide(DbMemoryTest())),
  );
});
