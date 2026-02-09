import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import { Bytes, Hash, Rlp } from "voltaire-effect/primitives";
import type { BranchNode, BytesType, HashType, LeafNode } from "./Node";
import { encodeInternalNode, TrieHashError, TrieHashTest } from "./hash";
import { nibbleListToCompact } from "./encoding";
import { makeBytesHelpers } from "./internal/primitives";

const { bytesFromHex, bytesFromUint8Array } = makeBytesHelpers(
  (message) => new Error(message),
);
const toBytes = (hex: string): BytesType => bytesFromHex(hex);
const coerceEffect = <A, E>(effect: unknown): Effect.Effect<A, E> =>
  effect as Effect.Effect<A, E>;
const encodeRlp = (data: Parameters<typeof Rlp.encode>[0]) =>
  coerceEffect<Uint8Array, unknown>(Rlp.encode(data));
const keccak256 = (data: Uint8Array) =>
  coerceEffect<HashType, never>(Hash.keccak256(data));
const hashEquals = (left: HashType, right: HashType) =>
  coerceEffect<boolean, never>(Hash.equals(left, right));

describe("trie hashing", () => {
  it.effect("encodeInternalNode returns empty for null nodes", () =>
    Effect.gen(function* () {
      const result = yield* encodeInternalNode(null);
      assert.strictEqual(result._tag, "empty");
    }).pipe(Effect.provide(TrieHashTest)),
  );

  it.effect("encodeInternalNode inlines small leaf nodes", () =>
    Effect.gen(function* () {
      const restOfKey = bytesFromUint8Array(new Uint8Array([0x1, 0x2, 0x3]));
      const value = toBytes("0x01");
      const node: LeafNode = { _tag: "leaf", restOfKey, value };

      const result = yield* encodeInternalNode(node);
      assert.strictEqual(result._tag, "raw");
      if (result._tag !== "raw") {
        return;
      }

      const compact = yield* nibbleListToCompact(restOfKey, true);
      const expected = yield* encodeRlp([compact, value]);
      const encoded = yield* encodeRlp(result.value);

      assert.isTrue(encoded.length < 32);
      assert.isTrue(
        Bytes.equals(
          bytesFromUint8Array(encoded),
          bytesFromUint8Array(expected),
        ),
      );
    }).pipe(Effect.provide(TrieHashTest)),
  );

  it.effect("encodeInternalNode hashes large leaf nodes", () =>
    Effect.gen(function* () {
      const restOfKey = bytesFromUint8Array(new Uint8Array(0));
      const value = bytesFromUint8Array(new Uint8Array(64).fill(0xab));
      const node: LeafNode = { _tag: "leaf", restOfKey, value };

      const result = yield* encodeInternalNode(node);
      assert.strictEqual(result._tag, "hash");
      if (result._tag !== "hash") {
        return;
      }

      const compact = yield* nibbleListToCompact(restOfKey, true);
      const encoded = yield* encodeRlp([compact, value]);
      const expected = yield* keccak256(encoded);

      assert.isTrue(encoded.length >= 32);
      assert.isTrue(yield* hashEquals(result.value, expected));
    }).pipe(Effect.provide(TrieHashTest)),
  );

  it.effect("encodeInternalNode rejects invalid branch lengths", () =>
    Effect.gen(function* () {
      const node: BranchNode = {
        _tag: "branch",
        subnodes: [],
        value: toBytes("0x"),
      };

      const result = yield* Effect.either(encodeInternalNode(node));
      assert.isTrue(Either.isLeft(result));
      if (Either.isLeft(result)) {
        assert.isTrue(result.left instanceof TrieHashError);
      }
    }).pipe(Effect.provide(TrieHashTest)),
  );
});
