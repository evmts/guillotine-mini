import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import { Bytes } from "voltaire-effect/primitives";
import type { IteratorOptions } from "./DbAdapter";
import {
  DbMemoryTest,
  put as dbPut,
  seek as dbSeek,
  next as dbNext,
  range as dbRange,
} from "./Db";
import { ReadOnlyDb, ReadOnlyDbTest } from "./ReadOnlyDb";
import { toBytes } from "./testUtils";
import { expectSome } from "./DbUtils";

describe("IteratorOptions uniform acceptance", () => {
  const roLayer = Layer.provideMerge(DbMemoryTest())(ReadOnlyDbTest());

  it.effect("Db.* accept IteratorOptions typed opts", () =>
    Effect.gen(function* () {
      const prefix = toBytes("0xdead");
      const k1 = toBytes("0xdead01");
      const k2 = toBytes("0xdeadff");
      const other = toBytes("0xbeef");

      // IteratorOptions should be accepted by Db wrappers
      const opts: IteratorOptions = { prefix };

      yield* dbPut(k1, toBytes("0x01"));
      yield* dbPut(k2, toBytes("0x02"));
      yield* dbPut(other, toBytes("0x03"));

      const s = yield* dbSeek(toBytes("0x0000"), opts);
      const e = expectSome(s);
      assert.isTrue(Bytes.equals(e.key as any, k1));

      const n = yield* dbNext(k1, opts);
      const en = expectSome(n);
      assert.isTrue(Bytes.equals(en.key as any, k2));

      const entries = yield* dbRange(opts);
      assert.strictEqual(entries.length, 2);
      assert.isTrue(Bytes.equals(entries[0]!.key, k1 as any));
      assert.isTrue(Bytes.equals(entries[1]!.key, k2 as any));
    }).pipe(Effect.provide(DbMemoryTest())),
  );

  it.effect("ReadOnlyDb.* accept IteratorOptions typed opts", () =>
    Effect.gen(function* () {
      const prefix = toBytes("0xabcd");
      const k1 = toBytes("0xabcd01");
      const k2 = toBytes("0xabcdff");
      const other = toBytes("0xabef");

      const opts: IteratorOptions = { prefix };

      // write through the read-only overlay if enabled (disabled here), so write to base via Db API
      // Base is provided by DbMemoryTest() in the layered provider below
      yield* dbPut(k1, toBytes("0x11"));
      yield* dbPut(k2, toBytes("0x22"));
      yield* dbPut(other, toBytes("0x33"));

      const ro = yield* ReadOnlyDb;

      const s = yield* ro.seek(prefix, opts);
      const e = expectSome(s);
      // seek at prefix should return the prefix key itself if present; here only k1/k2 exist
      assert.isTrue(Bytes.equals(e.key as any, k1));

      const n = yield* ro.next(k1, opts);
      const en = expectSome(n);
      assert.isTrue(Bytes.equals(en.key as any, k2));

      const entries = yield* ro.range(opts);
      assert.strictEqual(entries.length, 2);
      assert.isTrue(Bytes.equals(entries[0]!.key, k1 as any));
      assert.isTrue(Bytes.equals(entries[1]!.key, k2 as any));
    }).pipe(Effect.provide(roLayer)),
  );
});
