import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import { Bytes } from "voltaire-effect/primitives";
import { DbMemoryTest, next, put, range, seek } from "./Db";
import { toBytes } from "./testUtils";
import { expectNone, expectSome } from "./DbUtils";

describe("Db iterator prefix semantics", () => {
  it.effect("seek respects prefix and >= lower bound", () =>
    Effect.gen(function* () {
      const prefix = toBytes("0x1000");
      const k1 = toBytes("0x100001");
      const k2 = toBytes("0x1000ff");
      const k3 = toBytes("0x10ff"); // outside prefix

      yield* put(k1, toBytes("0xaa"));
      yield* put(k2, toBytes("0xbb"));
      yield* put(prefix, toBytes("0xdd"));
      yield* put(k3, toBytes("0xcc"));

      // Start well below prefix: should return first entry within prefix (k1)
      const s0 = yield* seek(toBytes("0x0000"), { prefix });
      const e0 = expectSome(s0, "seek below prefix should find k1");
      assert.isTrue(Bytes.equals(e0.key, k1));

      // Start exactly at the prefix key: should return the prefix key if present
      // Nethermind ordering: 0x100001 < 0x1000, so seek(0x1000) lands on 0x1000
      const s1 = yield* seek(prefix, { prefix });
      const e1 = expectSome(s1, "seek at prefix should find prefix");
      assert.isTrue(Bytes.equals(e1.key, prefix));

      // Start inside the prefix range but between entries
      const s2 = yield* seek(toBytes("0x100002"), { prefix });
      const e2 = expectSome(s2, "seek inside prefix should find k2");
      // With Nethermind ordering, k2 is the first >= 0x100002 within prefix
      assert.isTrue(Bytes.equals(e2.key, k2));

      // Start above the highest entry in the prefix: expect none
      const s3 = yield* seek(toBytes("0x100100"), { prefix });
      expectNone(s3, "seek above prefix should yield none");
    }).pipe(Effect.provide(DbMemoryTest())),
  );

  it.effect("next respects prefix and strict > bound", () =>
    Effect.gen(function* () {
      const prefix = toBytes("0x2000");
      const k1 = toBytes("0x200001");
      const k2 = toBytes("0x2000ff");

      yield* put(k1, toBytes("0x11"));
      yield* put(prefix, toBytes("0x22"));
      yield* put(k2, toBytes("0x33"));

      // Next from below prefix returns first inside prefix
      const n0 = yield* next(toBytes("0x1fff"), { prefix });
      const e0 = expectSome(n0, "next from below should find k1");
      assert.isTrue(Bytes.equals(e0.key, k1));

      // Strictly greater: next from k1 within prefix should be k2
      const n1 = yield* next(k1, { prefix });
      const e1 = expectSome(n1, "next from k1 should find k2");
      assert.isTrue(Bytes.equals(e1.key, k2));

      // Next from k2 should be the prefix key (ordering: k1 < k2 < prefix)
      const n2 = yield* next(k2, { prefix });
      const e2 = expectSome(n2, "next from k2 should find prefix");
      assert.isTrue(Bytes.equals(e2.key, prefix));

      // Next from the last key in prefix returns none
      const n3 = yield* next(prefix, { prefix });
      expectNone(n3, "next from prefix should be none");
    }).pipe(Effect.provide(DbMemoryTest())),
  );

  it.effect("range with prefix returns ordered subset or empty", () =>
    Effect.gen(function* () {
      const prefix = toBytes("0x3000");
      const k1 = toBytes("0x300001");
      const k2 = toBytes("0x3000ff");
      const other = toBytes("0x30ff");

      yield* put(k2, toBytes("0xaa"));
      yield* put(other, toBytes("0xbb"));
      yield* put(prefix, toBytes("0xcc"));
      yield* put(k1, toBytes("0xdd"));

      // Ordered according to Nethermind byte ordering: k1 < k2 < prefix
      const entries = yield* range({ prefix });
      assert.strictEqual(entries.length, 3);
      assert.isTrue(Bytes.equals(entries[0]!.key, k1));
      assert.isTrue(Bytes.equals(entries[1]!.key, k2));
      assert.isTrue(Bytes.equals(entries[2]!.key, prefix));

      // Different prefix yields empty result
      const none = yield* range({ prefix: toBytes("0x31") });
      assert.strictEqual(none.length, 0);
    }).pipe(Effect.provide(DbMemoryTest())),
  );
});
