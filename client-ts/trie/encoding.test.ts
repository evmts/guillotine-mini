import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import { Bytes, Hex } from "voltaire-effect/primitives";
import {
  bytesToNibbleList,
  compactToNibbleList,
  nibbleListToCompact,
  NibbleEncodingError,
} from "./encoding";

type BytesType = ReturnType<typeof Bytes.random>;

const isBytesType = (value: Uint8Array): value is BytesType =>
  Bytes.isBytes(value);
const bytesFromUint8Array = (value: Uint8Array): BytesType => {
  if (!isBytesType(value)) {
    throw new Error("Invalid bytes input");
  }
  return value;
};
const bytesFromHex = (hex: string): BytesType =>
  bytesFromUint8Array(Hex.toBytes(hex));
const toBytes = (hex: string): BytesType => bytesFromHex(hex);

describe("trie encoding", () => {
  it.effect("bytesToNibbleList converts bytes into nibbles", () =>
    Effect.gen(function* () {
      const bytes = toBytes("0x12ab");
      const result = yield* bytesToNibbleList(bytes);
      assert.deepEqual(Array.from(result), [0x1, 0x2, 0xa, 0xb]);
    }),
  );

  it.effect("bytesToNibbleList handles empty input", () =>
    Effect.gen(function* () {
      const bytes = bytesFromUint8Array(new Uint8Array(0));
      const result = yield* bytesToNibbleList(bytes);
      assert.deepEqual(Array.from(result), []);
    }),
  );

  it.effect("nibbleListToCompact encodes even extension paths", () =>
    Effect.gen(function* () {
      const nibbles = bytesFromUint8Array(new Uint8Array([0x1, 0x2, 0x3, 0x4]));
      const result = yield* nibbleListToCompact(nibbles, false);
      assert.isTrue(Bytes.equals(result, toBytes("0x001234")));
    }),
  );

  it.effect("nibbleListToCompact encodes odd leaf paths", () =>
    Effect.gen(function* () {
      const nibbles = bytesFromUint8Array(new Uint8Array([0x1, 0x2, 0x3]));
      const result = yield* nibbleListToCompact(nibbles, true);
      assert.isTrue(Bytes.equals(result, toBytes("0x3123")));
    }),
  );

  it.effect("nibbleListToCompact encodes even leaf paths", () =>
    Effect.gen(function* () {
      const nibbles = bytesFromUint8Array(new Uint8Array([0x1, 0x2, 0x3, 0x4]));
      const result = yield* nibbleListToCompact(nibbles, true);
      assert.isTrue(Bytes.equals(result, toBytes("0x201234")));
    }),
  );

  it.effect("nibbleListToCompact encodes odd extension paths", () =>
    Effect.gen(function* () {
      const nibbles = bytesFromUint8Array(new Uint8Array([0x1]));
      const result = yield* nibbleListToCompact(nibbles, false);
      assert.isTrue(Bytes.equals(result, toBytes("0x11")));
    }),
  );

  it.effect("nibbleListToCompact encodes empty extension paths", () =>
    Effect.gen(function* () {
      const nibbles = bytesFromUint8Array(new Uint8Array(0));
      const result = yield* nibbleListToCompact(nibbles, false);
      assert.isTrue(Bytes.equals(result, toBytes("0x00")));
    }),
  );

  it.effect("nibbleListToCompact encodes empty leaf paths", () =>
    Effect.gen(function* () {
      const nibbles = bytesFromUint8Array(new Uint8Array(0));
      const result = yield* nibbleListToCompact(nibbles, true);
      assert.isTrue(Bytes.equals(result, toBytes("0x20")));
    }),
  );

  it.effect("nibbleListToCompact rejects invalid nibbles", () =>
    Effect.gen(function* () {
      const nibbles = bytesFromUint8Array(new Uint8Array([0x10]));
      const result = yield* Effect.either(nibbleListToCompact(nibbles, false));
      assert.isTrue(Either.isLeft(result));
      if (Either.isLeft(result)) {
        assert.isTrue(result.left instanceof NibbleEncodingError);
      }
    }),
  );

  it.effect("compactToNibbleList rejects invalid flag bits", () =>
    Effect.gen(function* () {
      const compact = bytesFromUint8Array(new Uint8Array([0x80]));
      const result = yield* Effect.either(compactToNibbleList(compact));
      assert.isTrue(Either.isLeft(result));
      if (Either.isLeft(result)) {
        assert.isTrue(result.left instanceof NibbleEncodingError);
      }
    }),
  );
});
