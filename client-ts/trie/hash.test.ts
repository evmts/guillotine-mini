import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import * as VoltaireHash from "@tevm/voltaire/Hash";
import * as VoltaireRlp from "@tevm/voltaire/Rlp";
import { Bytes, Hex } from "voltaire-effect/primitives";
import type { BranchNode, BytesType, LeafNode } from "./Node";
import { encodeInternalNode, TrieHashError, TrieHashTest } from "./hash";
import { nibbleListToCompact } from "./encoding";

const toBytes = (hex: string): BytesType => Hex.toBytes(hex) as BytesType;
const asBytes = (value: Uint8Array): BytesType => value as BytesType;
const encodeRlp = (data: VoltaireRlp.Encodable) =>
  Effect.sync(() => VoltaireRlp.encode(data));
const keccak256 = (data: Uint8Array) =>
  Effect.sync(() => VoltaireHash.keccak256(data));

describe("trie hashing", () => {
  it.effect("encodeInternalNode returns empty for null nodes", () =>
    Effect.gen(function* () {
      const result = yield* encodeInternalNode(null);
      assert.strictEqual(result._tag, "empty");
    }).pipe(Effect.provide(TrieHashTest)),
  );

  it.effect("encodeInternalNode inlines small leaf nodes", () =>
    Effect.gen(function* () {
      const restOfKey = new Uint8Array([0x1, 0x2, 0x3]) as BytesType;
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
      assert.isTrue(Bytes.equals(asBytes(encoded), asBytes(expected)));
    }).pipe(Effect.provide(TrieHashTest)),
  );

  it.effect("encodeInternalNode hashes large leaf nodes", () =>
    Effect.gen(function* () {
      const restOfKey = new Uint8Array(0) as BytesType;
      const value = new Uint8Array(64).fill(0xab) as BytesType;
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
      assert.isTrue(VoltaireHash.equals(result.value, expected));
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
