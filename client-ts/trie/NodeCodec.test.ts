import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import { Bytes, Hex, Rlp } from "voltaire-effect/primitives";
import type { BytesType, EncodedNode } from "./Node";
import { nibbleListToCompact } from "./encoding";
import {
  TrieNodeCodecError,
  TrieNodeCodecTest,
  decodeTrieNode,
} from "./NodeCodec";
import { coerceEffect } from "./internal/effect";

// Helpers
const bytesFromHex = (hex: string): BytesType => Hex.toBytes(hex) as BytesType;
const toBytes = (value: Uint8Array): BytesType => Bytes.concat(value);

const encodeRlp = (data: Parameters<typeof Rlp.encode>[0]) =>
  coerceEffect<Uint8Array, unknown>(Rlp.encode(data));

describe("TrieNodeCodec", () => {
  it.effect("decodes a leaf node", () =>
    Effect.gen(function* () {
      const nibbleList = toBytes(new Uint8Array([0x01, 0x02]));
      const compact = yield* nibbleListToCompact(nibbleList, true);
      const rlpList = {
        type: "list",
        value: [
          { type: "bytes", value: compact },
          { type: "bytes", value: bytesFromHex("0xdeadbeef") },
        ],
      } as const;
      const encoded = yield* encodeRlp(rlpList);
      const node = yield* decodeTrieNode(toBytes(encoded));

      assert.strictEqual(node._tag, "leaf");
      if (node._tag !== "leaf") return;
      const recompact = yield* nibbleListToCompact(node.restOfKey, true);
      assert.strictEqual(Hex.fromBytes(recompact), Hex.fromBytes(compact));
      assert.strictEqual(Hex.fromBytes(node.value), "0xdeadbeef");
    }).pipe(Effect.provide(TrieNodeCodecTest)),
  );

  it.effect("decodes an extension with raw leaf child", () =>
    Effect.gen(function* () {
      const extNibbles = toBytes(new Uint8Array([0x00, 0x01]));
      const leafNibbles = toBytes(new Uint8Array([0x02, 0x03]));
      const extCompact = yield* nibbleListToCompact(extNibbles, false);
      const leafCompact = yield* nibbleListToCompact(leafNibbles, true);
      const rawLeaf = {
        type: "list",
        value: [
          { type: "bytes", value: leafCompact },
          { type: "bytes", value: bytesFromHex("0xabab") },
        ],
      } as const;
      const rlpList = {
        type: "list",
        value: [{ type: "bytes", value: extCompact }, rawLeaf],
      } as const;
      const encoded = yield* encodeRlp(rlpList);
      const node = yield* decodeTrieNode(toBytes(encoded));

      assert.strictEqual(node._tag, "extension");
      if (node._tag !== "extension") return;
      const recompact = yield* nibbleListToCompact(node.keySegment, false);
      assert.strictEqual(Hex.fromBytes(recompact), Hex.fromBytes(extCompact));
      assert.strictEqual(node.subnode._tag, "raw");
    }).pipe(Effect.provide(TrieNodeCodecTest)),
  );

  it.effect("decodes a branch node with one raw leaf child and value", () =>
    Effect.gen(function* () {
      const leafNibbles = toBytes(new Uint8Array([0x0f]));
      const leafCompact = yield* nibbleListToCompact(leafNibbles, true);
      const rawLeaf = {
        _tag: "raw",
        value: {
          type: "list",
          value: [
            { type: "bytes", value: leafCompact },
            { type: "bytes", value: bytesFromHex("0xbeef") },
          ],
        },
      } as const satisfies EncodedNode;

      const children: Array<{ type: string; value: any }> = [];
      for (let i = 0; i < 16; i += 1) {
        if (i === 5) {
          children.push(rawLeaf.value);
        } else {
          children.push({ type: "bytes", value: bytesFromHex("0x") });
        }
      }
      const rlpList = {
        type: "list",
        value: [...children, { type: "bytes", value: bytesFromHex("0x01") }],
      } as const;

      const encoded = yield* encodeRlp(rlpList);
      const node = yield* decodeTrieNode(toBytes(encoded));

      assert.strictEqual(node._tag, "branch");
      if (node._tag !== "branch") return;
      assert.strictEqual(node.subnodes.length, 16);
      assert.strictEqual(node.subnodes[5]!._tag, "raw");
      assert.strictEqual(Hex.fromBytes(node.value), "0x01");
    }).pipe(Effect.provide(TrieNodeCodecTest)),
  );

  it.effect("rejects invalid top-level items", () =>
    Effect.gen(function* () {
      const encoded = yield* encodeRlp(bytesFromHex("0x01"));
      const result = yield* decodeTrieNode(toBytes(encoded)).pipe(
        Effect.either,
      );
      assert.strictEqual(result._tag, "Left");
      if (result._tag === "Left") {
        assert.strictEqual(result.left instanceof TrieNodeCodecError, true);
      }
    }).pipe(Effect.provide(TrieNodeCodecTest)),
  );
});
