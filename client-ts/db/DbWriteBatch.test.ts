import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import { Bytes } from "voltaire-effect/primitives";
import { DbMemoryTest, get, writeBatch } from "./Db";
import type { DbWriteOp } from "./Db";
import { toBytes } from "./testUtils";

describe("Db writeBatch", () => {
  it.effect("applies put and delete operations in order", () =>
    Effect.gen(function* () {
      const key = toBytes("0x21");
      const value = toBytes("0xabcd");

      const ops: ReadonlyArray<DbWriteOp> = [
        { _tag: "put", key, value },
        { _tag: "del", key },
      ];

      yield* writeBatch(ops);

      const result = yield* get(key);
      assert.isTrue(Option.isNone(result));
    }).pipe(Effect.provide(DbMemoryTest())),
  );

  it.effect("last write wins for repeated puts", () =>
    Effect.gen(function* () {
      const key = toBytes("0x22");
      const first = toBytes("0x01");
      const second = toBytes("0x02");

      const ops: ReadonlyArray<DbWriteOp> = [
        { _tag: "put", key, value: first },
        { _tag: "put", key, value: second },
      ];

      yield* writeBatch(ops);

      const result = yield* get(key);
      const stored = Option.getOrThrow(result);
      assert.isTrue(Bytes.equals(stored, second));
    }).pipe(Effect.provide(DbMemoryTest())),
  );
});
