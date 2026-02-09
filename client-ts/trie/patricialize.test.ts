import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import * as Layer from "effect/Layer";
import { Bytes } from "voltaire-effect/primitives";
import type { BytesType } from "./Node";
import { TrieHashTest } from "./hash";
import { makeBytesHelpers } from "./internal/primitives";
import {
  PatricializeError,
  TriePatricializeTest,
  commonPrefixLength,
  patricialize,
} from "./patricialize";

const { bytesFromHex, bytesFromUint8Array } = makeBytesHelpers(
  (message) => new Error(message),
);
const toBytes = (hex: string): BytesType => bytesFromHex(hex);
const nibbles = (...values: number[]): BytesType =>
  bytesFromUint8Array(new Uint8Array(values));

const TestLayer = TriePatricializeTest.pipe(Layer.provide(TrieHashTest));

describe("trie patricialize", () => {
  it.effect("commonPrefixLength returns the shared prefix length", () =>
    Effect.gen(function* () {
      const a = nibbles(0x1, 0x2, 0x3);
      const b = nibbles(0x1, 0x2, 0x4);
      const c = nibbles(0x1, 0x2);

      assert.strictEqual(commonPrefixLength(a, b), 2);
      assert.strictEqual(commonPrefixLength(a, c), 2);
      assert.strictEqual(commonPrefixLength(c, a), 2);
      assert.strictEqual(commonPrefixLength(nibbles(), a), 0);
    }),
  );

  it.effect("patricialize returns null for empty maps", () =>
    Effect.gen(function* () {
      const result = yield* patricialize(new Map(), 0);
      assert.isNull(result);
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("patricialize builds leaf nodes for single keys", () =>
    Effect.gen(function* () {
      const key = nibbles(0xa, 0xb);
      const value = toBytes("0xdeadbeef");
      const input = new Map<BytesType, BytesType>([[key, value]]);

      const node = yield* patricialize(input, 0);
      assert.strictEqual(node?._tag, "leaf");
      if (node?._tag !== "leaf") {
        return;
      }

      assert.isTrue(Bytes.equals(node.restOfKey, key));
      assert.isTrue(Bytes.equals(node.value, value));
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("patricialize builds extension nodes for shared prefixes", () =>
    Effect.gen(function* () {
      const keyA = nibbles(0x1, 0x2, 0x3);
      const keyB = nibbles(0x1, 0x2, 0x4);
      const input = new Map<BytesType, BytesType>([
        [keyA, toBytes("0x01")],
        [keyB, toBytes("0x02")],
      ]);

      const node = yield* patricialize(input, 0);
      assert.strictEqual(node?._tag, "extension");
      if (node?._tag !== "extension") {
        return;
      }

      assert.isTrue(Bytes.equals(node.keySegment, nibbles(0x1, 0x2)));
      assert.notStrictEqual(node.subnode._tag, "empty");
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("patricialize builds branch nodes for diverging keys", () =>
    Effect.gen(function* () {
      const emptyKey = nibbles();
      const keyA = nibbles(0x1);
      const keyB = nibbles(0x2);
      const input = new Map<BytesType, BytesType>([
        [emptyKey, toBytes("0xaa")],
        [keyA, toBytes("0x01")],
        [keyB, toBytes("0x02")],
      ]);

      const node = yield* patricialize(input, 0);
      assert.strictEqual(node?._tag, "branch");
      if (node?._tag !== "branch") {
        return;
      }

      assert.strictEqual(node.subnodes.length, 16);
      assert.isTrue(Bytes.equals(node.value, toBytes("0xaa")));
      assert.notStrictEqual(node.subnodes[1]?._tag, "empty");
      assert.notStrictEqual(node.subnodes[2]?._tag, "empty");
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("patricialize rejects invalid nibble values", () =>
    Effect.gen(function* () {
      const key = nibbles(0x10);
      const input = new Map<BytesType, BytesType>([[key, toBytes("0x01")]]);

      const result = yield* Effect.either(patricialize(input, 0));
      assert.isTrue(Either.isLeft(result));
      if (Either.isLeft(result)) {
        assert.isTrue(result.left instanceof PatricializeError);
      }
    }).pipe(Effect.provide(TestLayer)),
  );
});
