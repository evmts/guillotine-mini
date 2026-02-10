import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import { Bytes, Hash, Hex } from "voltaire-effect/primitives";
import { DbMemoryTest, DbNames } from "../db/Db";
import type { BytesType } from "./Node";
import {
  persistEncodedNode,
  TrieNodeStorageError,
  TrieNodeStorageTest,
  getNode,
  hasNode,
  removeNode,
  setNode,
} from "./NodeStorage";
import { makeBytesHelpers } from "./internal/primitives";

const { bytesFromHex } = makeBytesHelpers((message) => new Error(message));

const hashFromHex = (hex: string): Hash.HashType => {
  const value = Hex.toBytes(hex);
  if (!Hash.isHash(value)) {
    throw new Error("Invalid hash fixture");
  }
  return value;
};

const TestLayer = TrieNodeStorageTest.pipe(
  Layer.provide(DbMemoryTest({ name: DbNames.state })),
);

describe("TrieNodeStorage", () => {
  it.effect("setNode and getNode round-trip encoded trie nodes", () =>
    Effect.gen(function* () {
      const nodeHash = hashFromHex(
        "0x1111111111111111111111111111111111111111111111111111111111111111",
      );
      const encodedNode = bytesFromHex("0xc58320646f67");

      yield* setNode(nodeHash, encodedNode);
      const loaded = yield* getNode(nodeHash);

      assert.isTrue(Option.isSome(loaded));
      if (Option.isSome(loaded)) {
        assert.isTrue(Bytes.equals(loaded.value, encodedNode));
      }
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("getNode returns none when hash is missing", () =>
    Effect.gen(function* () {
      const nodeHash = hashFromHex(
        "0x2222222222222222222222222222222222222222222222222222222222222222",
      );
      const loaded = yield* getNode(nodeHash);
      assert.isTrue(Option.isNone(loaded));
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("hasNode reflects trie node presence", () =>
    Effect.gen(function* () {
      const nodeHash = hashFromHex(
        "0x3333333333333333333333333333333333333333333333333333333333333333",
      );
      const encodedNode = bytesFromHex("0xc22001");

      const before = yield* hasNode(nodeHash);
      yield* setNode(nodeHash, encodedNode);
      const after = yield* hasNode(nodeHash);

      assert.isFalse(before);
      assert.isTrue(after);
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("removeNode deletes previously stored trie nodes", () =>
    Effect.gen(function* () {
      const nodeHash = hashFromHex(
        "0x4444444444444444444444444444444444444444444444444444444444444444",
      );
      const encodedNode = bytesFromHex("0xc22002");

      yield* setNode(nodeHash, encodedNode);
      yield* removeNode(nodeHash);

      const loaded = yield* getNode(nodeHash);
      const present = yield* hasNode(nodeHash);

      assert.isTrue(Option.isNone(loaded));
      assert.isFalse(present);
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("setNode rejects invalid hash input", () =>
    Effect.gen(function* () {
      const invalidHash = bytesFromHex("0x1234") as unknown as Hash.HashType;
      const encodedNode = bytesFromHex("0xc22001");

      const result = yield* Effect.either(setNode(invalidHash, encodedNode));
      if (result._tag === "Left") {
        assert.isTrue(result.left instanceof TrieNodeStorageError);
        return;
      }
      assert.fail("Expected TrieNodeStorageError for invalid hash");
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect(
    "persistEncodedNode stores bytes keyed by keccak hash and returns that hash",
    () =>
      Effect.gen(function* () {
        const encodedNode = bytesFromHex("0xc2200a");
        const expectedHash = yield* Hash.keccak256(encodedNode);

        const storedHash = yield* persistEncodedNode(encodedNode);
        const loaded = yield* getNode(storedHash);

        assert.isTrue(yield* Hash.equals(storedHash, expectedHash));
        assert.isTrue(Option.isSome(loaded));
        if (Option.isSome(loaded)) {
          assert.isTrue(Bytes.equals(loaded.value, encodedNode));
        }
      }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("persistEncodedNode rejects invalid encoded bytes input", () =>
    Effect.gen(function* () {
      const invalidNode = null as unknown as BytesType;
      const result = yield* Effect.either(persistEncodedNode(invalidNode));
      if (result._tag === "Left") {
        assert.isTrue(result.left instanceof TrieNodeStorageError);
        return;
      }
      assert.fail("Expected TrieNodeStorageError for invalid encoded node");
    }).pipe(Effect.provide(TestLayer)),
  );
});
