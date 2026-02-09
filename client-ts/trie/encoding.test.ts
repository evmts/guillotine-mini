import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import { Bytes, Hex } from "voltaire-effect/primitives";
import {
  bytesToNibbleList,
  nibbleListToCompact,
  NibbleEncodingError,
} from "./encoding";

type BytesType = ReturnType<typeof Bytes.random>;

const toBytes = (hex: string): BytesType => Hex.toBytes(hex) as BytesType;

describe("trie encoding", () => {
  it.effect("bytesToNibbleList converts bytes into nibbles", () =>
    Effect.gen(function* () {
      const bytes = toBytes("0x12ab");
      const result = yield* bytesToNibbleList(bytes);
      assert.deepEqual(Array.from(result), [0x1, 0x2, 0xa, 0xb]);
    }),
  );

  it.effect("nibbleListToCompact encodes even extension paths", () =>
    Effect.gen(function* () {
      const nibbles = new Uint8Array([0x1, 0x2, 0x3, 0x4]) as BytesType;
      const result = yield* nibbleListToCompact(nibbles, false);
      assert.isTrue(Bytes.equals(result, toBytes("0x001234")));
    }),
  );

  it.effect("nibbleListToCompact encodes odd leaf paths", () =>
    Effect.gen(function* () {
      const nibbles = new Uint8Array([0x1, 0x2, 0x3]) as BytesType;
      const result = yield* nibbleListToCompact(nibbles, true);
      assert.isTrue(Bytes.equals(result, toBytes("0x3123")));
    }),
  );

  it.effect("nibbleListToCompact encodes even leaf paths", () =>
    Effect.gen(function* () {
      const nibbles = new Uint8Array([0x1, 0x2, 0x3, 0x4]) as BytesType;
      const result = yield* nibbleListToCompact(nibbles, true);
      assert.isTrue(Bytes.equals(result, toBytes("0x201234")));
    }),
  );

  it.effect("nibbleListToCompact encodes odd extension paths", () =>
    Effect.gen(function* () {
      const nibbles = new Uint8Array([0x1]) as BytesType;
      const result = yield* nibbleListToCompact(nibbles, false);
      assert.isTrue(Bytes.equals(result, toBytes("0x11")));
    }),
  );

  it.effect("nibbleListToCompact encodes empty leaf paths", () =>
    Effect.gen(function* () {
      const nibbles = new Uint8Array([]) as BytesType;
      const result = yield* nibbleListToCompact(nibbles, true);
      assert.isTrue(Bytes.equals(result, toBytes("0x20")));
    }),
  );

  it.effect("nibbleListToCompact rejects invalid nibbles", () =>
    Effect.gen(function* () {
      const nibbles = new Uint8Array([0x10]) as BytesType;
      const result = yield* Effect.either(nibbleListToCompact(nibbles, false));
      assert.isTrue(Either.isLeft(result));
      if (Either.isLeft(result)) {
        assert.isTrue(result.left instanceof NibbleEncodingError);
      }
    }),
  );
});
