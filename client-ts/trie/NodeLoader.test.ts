import { describe, it, expect } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import { Bytes, Hash, Hex, Rlp } from "voltaire-effect/primitives";
import type { BytesType, EncodedNode, TrieNode } from "./Node";
import { nibbleListToCompact } from "./encoding";
import { TrieNodeCodecTest } from "./NodeCodec";
import { DbMemoryTest, DbNames, DbRocksStubTest } from "../db/Db";
import {
  TrieNodeStorageKeyScheme,
  TrieNodeStorageTest,
  setNodeStorageScheme,
  setNodeWithContext,
} from "./NodeStorage";
import { ReadFlags } from "../db/Db";
import { EMPTY_TRIE_ROOT } from "./root";
import {
  TrieNodeLoaderError,
  TrieNodeLoaderTest,
  loadTrieNode,
} from "./NodeLoader";
import { coerceEffect } from "./internal/effect";

// Helpers
const toBytes = (u8: Uint8Array): BytesType => Bytes.concat(u8);
const bytesFromHex = (hex: string): BytesType => Hex.toBytes(hex) as BytesType;

const encodeRlp = (data: Parameters<typeof Rlp.encode>[0]) =>
  coerceEffect<Uint8Array, unknown>(Rlp.encode(data));

const hashFromHex = (hex: string): Hash.HashType => {
  const value = Hex.toBytes(hex);
  if (!Hash.isHash(value)) throw new Error("Invalid hash fixture");
  return value;
};

const StorageLayer = TrieNodeStorageTest.pipe(
  Layer.provide(DbMemoryTest({ name: DbNames.state })),
);
const BaseDeps = Layer.mergeAll(TrieNodeCodecTest, StorageLayer);
const LoaderProvided = TrieNodeLoaderTest.pipe(Layer.provide(BaseDeps));
const TestLayer = Layer.mergeAll(BaseDeps, LoaderProvided);

const RocksStorageLayer = TrieNodeStorageTest.pipe(
  Layer.provide(DbRocksStubTest({ name: DbNames.state })),
);
const RocksBaseDeps = Layer.mergeAll(TrieNodeCodecTest, RocksStorageLayer);
const RocksLoaderProvided = TrieNodeLoaderTest.pipe(
  Layer.provide(RocksBaseDeps),
);
const RocksLayer = Layer.mergeAll(RocksBaseDeps, RocksLoaderProvided);

describe("TrieNodeLoader", () => {
  it.effect("returns null for empty reference", () =>
    Effect.gen(function* () {
      const result = yield* loadTrieNode(
        null,
        { bytes: EMPTY_TRIE_ROOT, length: 0 },
        { _tag: "empty" },
      );
      expect(result).toBeNull();
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("decodes inline raw leaf", () =>
    Effect.gen(function* () {
      const nibbles = toBytes(new Uint8Array([0x0a]));
      const compact = yield* nibbleListToCompact(nibbles, true);
      const rawLeaf = {
        type: "list",
        value: [
          { type: "bytes", value: compact },
          { type: "bytes", value: bytesFromHex("0xdead") },
        ],
      } as const;

      const node = yield* loadTrieNode(
        null,
        { bytes: EMPTY_TRIE_ROOT, length: 0 },
        { _tag: "raw", value: rawLeaf },
      );
      expect(node?._tag).toBe("leaf");
      if (node?._tag !== "leaf") return;
      const recompact = yield* nibbleListToCompact(node.restOfKey, true);
      expect(Hex.fromBytes(recompact)).toBe(Hex.fromBytes(compact));
      expect(Hex.fromBytes(node.value)).toBe("0xdead");
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("loads hashed node via half-path scheme", () =>
    Effect.gen(function* () {
      const address = hashFromHex(`0x${"11".repeat(32)}`);
      const path = { bytes: hashFromHex(`0x${"22".repeat(32)}`), length: 6 };
      const leafNibbles = toBytes(new Uint8Array([0x01, 0x02]));
      const compact = yield* nibbleListToCompact(leafNibbles, true);
      const rlpList = {
        type: "list",
        value: [
          { type: "bytes", value: compact },
          { type: "bytes", value: bytesFromHex("0xaaaa") },
        ],
      } as const;
      const encoded = yield* encodeRlp(rlpList);
      const nodeHash = yield* Hash.keccak256(encoded);

      // Default scheme is HalfPath; store under that scheme
      yield* setNodeWithContext(address, path, nodeHash, toBytes(encoded));

      const loaded = yield* loadTrieNode(address, path, {
        _tag: "hash",
        value: nodeHash,
      });
      expect(loaded?._tag).toBe("leaf");
      if (loaded?._tag !== "leaf") return;
      const round = yield* nibbleListToCompact(loaded.restOfKey, true);
      expect(Hex.fromBytes(round)).toBe(Hex.fromBytes(compact));
      expect(Hex.fromBytes(loaded.value)).toBe("0xaaaa");
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("reads hash-keyed entry via fallback from half-path scheme", () =>
    Effect.gen(function* () {
      const address = hashFromHex(`0x${"33".repeat(32)}`);
      const path = { bytes: hashFromHex(`0x${"44".repeat(32)}`), length: 3 };
      const nibbles = toBytes(new Uint8Array([0x0f]));
      const compact = yield* nibbleListToCompact(nibbles, true);
      const rlpList = {
        type: "list",
        value: [
          { type: "bytes", value: compact },
          { type: "bytes", value: bytesFromHex("0xbb") },
        ],
      } as const;
      const encoded = yield* encodeRlp(rlpList);
      const nodeHash = yield* Hash.keccak256(encoded);

      // Store under hash scheme first
      yield* setNodeStorageScheme(TrieNodeStorageKeyScheme.Hash);
      yield* setNodeWithContext(address, path, nodeHash, toBytes(encoded));

      // Switch to half-path scheme; loader should still find it via fallback
      yield* setNodeStorageScheme(TrieNodeStorageKeyScheme.HalfPath);
      const loaded = yield* loadTrieNode(address, path, {
        _tag: "hash",
        value: nodeHash,
      });
      expect(loaded?._tag).toBe("leaf");
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("returns null when hashed node is missing", () =>
    Effect.gen(function* () {
      const address = hashFromHex(`0x${"55".repeat(32)}`);
      const path = { bytes: hashFromHex(`0x${"66".repeat(32)}`), length: 2 };
      const nodeHash = hashFromHex(`0x${"77".repeat(32)}`);
      const result = yield* loadTrieNode(address, path, {
        _tag: "hash",
        value: nodeHash,
      });
      expect(result).toBeNull();
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("short-circuits to null for EMPTY_TRIE_ROOT hash ref", () =>
    Effect.gen(function* () {
      const address = hashFromHex(`0x${"88".repeat(32)}`);
      const path = { bytes: hashFromHex(`0x${"99".repeat(32)}`), length: 8 };
      const result = yield* loadTrieNode(address, path, {
        _tag: "hash",
        value: EMPTY_TRIE_ROOT,
      });
      expect(result).toBeNull();
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("wraps storage errors from DB", () =>
    Effect.gen(function* () {
      const address = hashFromHex(`0x${"aa".repeat(32)}`);
      const path = { bytes: hashFromHex(`0x${"bb".repeat(32)}`), length: 4 };
      const nodeHash = hashFromHex(`0x${"cc".repeat(32)}`);

      const result = yield* Effect.either(
        loadTrieNode(address, path, { _tag: "hash", value: nodeHash }),
      );
      expect(result._tag).toBe("Left");
      if (result._tag === "Left") {
        expect(result.left instanceof TrieNodeLoaderError).toBe(true);
      }
    }).pipe(Effect.provide(RocksLayer)),
  );

  it.effect("wraps codec errors when decoding invalid bytes", () =>
    Effect.gen(function* () {
      const address = hashFromHex(`0x${"dd".repeat(32)}`);
      const path = { bytes: hashFromHex(`0x${"ee".repeat(32)}`), length: 1 };
      const invalidEncoded = bytesFromHex("0x01"); // RLP bytes, not a list → invalid top-level
      const nodeHash = yield* Hash.keccak256(invalidEncoded);

      // Store under hash scheme
      yield* setNodeStorageScheme(TrieNodeStorageKeyScheme.Hash);
      yield* setNodeWithContext(address, path, nodeHash, invalidEncoded);

      const result = yield* Effect.either(
        loadTrieNode(address, path, { _tag: "hash", value: nodeHash }),
      );
      expect(result._tag).toBe("Left");
      if (result._tag === "Left") {
        expect(result.left instanceof TrieNodeLoaderError).toBe(true);
      }
    }).pipe(Effect.provide(TestLayer)),
  );
});
