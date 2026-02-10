import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import { Bytes, Hash, Hex, Rlp } from "voltaire-effect/primitives";
import { DbMemoryTest, DbNames, DbRocksStubTest } from "../db/Db";
import type { BytesType } from "./Node";
import {
  compactNodeStorage,
  flushNodeStorage,
  getNode,
  getNodeStorageScheme,
  getNodeWithContext,
  hasNode,
  hasNodeWithContext,
  persistEncodedNode,
  removeNode,
  removeNodeWithContext,
  setNode,
  setNodeStorageScheme,
  setNodeWithContext,
  startNodeWriteBatch,
  TrieNodeStorageError,
  TrieNodeStorageKeyScheme,
  TrieNodeStorageTest,
  type TrieNodePath,
} from "./NodeStorage";
import { coerceEffect } from "./internal/effect";
import { makeBytesHelpers } from "./internal/primitives";
import { EMPTY_TRIE_ROOT } from "./root";

const { bytesFromHex, bytesFromUint8Array } = makeBytesHelpers(
  (message) => new Error(message),
);

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

const RocksLayer = TrieNodeStorageTest.pipe(
  Layer.provide(DbRocksStubTest({ name: DbNames.state })),
);

const extractTag = (cause: unknown): string | undefined => {
  if (typeof cause !== "object" || cause === null || !("_tag" in cause)) {
    return undefined;
  }

  const tag = (cause as { readonly _tag: unknown })._tag;
  return typeof tag === "string" ? tag : undefined;
};

const assertTrieNodeStorageError = (
  result: Either<TrieNodeStorageError, unknown>,
): TrieNodeStorageError => {
  if (result._tag === "Left") {
    assert.isTrue(result.left instanceof TrieNodeStorageError);
    return result.left;
  }

  assert.fail("Expected TrieNodeStorageError");
};

type Either<E, A> =
  | { readonly _tag: "Left"; readonly left: E }
  | { readonly _tag: "Right"; readonly right: A };

const expectDbWrappedError = <A, R>(
  effect: Effect.Effect<A, TrieNodeStorageError, R>,
) =>
  Effect.gen(function* () {
    const result = (yield* Effect.either(effect)) as Either<
      TrieNodeStorageError,
      A
    >;
    const error = assertTrieNodeStorageError(result);
    assert.strictEqual(extractTag(error.cause), "DbError");
  });

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

  it.effect("canonical empty trie root is always readable and present", () =>
    Effect.gen(function* () {
      const emptyNode = bytesFromHex("0x80");

      const before = yield* getNode(EMPTY_TRIE_ROOT);
      const beforePresent = yield* hasNode(EMPTY_TRIE_ROOT);

      yield* setNode(EMPTY_TRIE_ROOT, bytesFromHex("0xc2200f"));
      yield* removeNode(EMPTY_TRIE_ROOT);

      const after = yield* getNode(EMPTY_TRIE_ROOT);
      const afterPresent = yield* hasNode(EMPTY_TRIE_ROOT);

      assert.isTrue(Option.isSome(before));
      assert.isTrue(beforePresent);
      assert.isTrue(Option.isSome(after));
      assert.isTrue(afterPresent);

      if (Option.isSome(before) && Option.isSome(after)) {
        assert.isTrue(Bytes.equals(before.value, emptyNode));
        assert.isTrue(Bytes.equals(after.value, emptyNode));
      }
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("setNode rejects invalid hash input", () =>
    Effect.gen(function* () {
      const invalidHash = bytesFromHex("0x1234") as unknown as Hash.HashType;
      const encodedNode = bytesFromHex("0xc22001");

      const result = (yield* Effect.either(
        setNode(invalidHash, encodedNode),
      )) as Either<TrieNodeStorageError, void>;

      assertTrieNodeStorageError(result);
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("getNode rejects invalid hash input", () =>
    Effect.gen(function* () {
      const invalidHash = bytesFromHex("0x1234") as unknown as Hash.HashType;
      const result = (yield* Effect.either(getNode(invalidHash))) as Either<
        TrieNodeStorageError,
        Option.Option<BytesType>
      >;
      assertTrieNodeStorageError(result);
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("hasNode rejects invalid hash input", () =>
    Effect.gen(function* () {
      const invalidHash = bytesFromHex("0x1234") as unknown as Hash.HashType;
      const result = (yield* Effect.either(hasNode(invalidHash))) as Either<
        TrieNodeStorageError,
        boolean
      >;
      assertTrieNodeStorageError(result);
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("removeNode rejects invalid hash input", () =>
    Effect.gen(function* () {
      const invalidHash = bytesFromHex("0x1234") as unknown as Hash.HashType;
      const result = (yield* Effect.either(removeNode(invalidHash))) as Either<
        TrieNodeStorageError,
        void
      >;
      assertTrieNodeStorageError(result);
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect(
    "persistEncodedNode hashes and stores nodes with encoded size >= 32 bytes",
    () =>
      Effect.gen(function* () {
        const encodedNode = bytesFromHex(`0x${"11".repeat(40)}`);
        const expectedHash = yield* Hash.keccak256(encodedNode);

        const reference = yield* persistEncodedNode(encodedNode);

        assert.strictEqual(reference._tag, "hash");
        if (reference._tag !== "hash") {
          assert.fail("Expected hash reference for large encoded node");
          return;
        }

        assert.isTrue(yield* Hash.equals(reference.value, expectedHash));

        const loaded = yield* getNode(reference.value);
        assert.isTrue(Option.isSome(loaded));
        if (Option.isSome(loaded)) {
          assert.isTrue(Bytes.equals(loaded.value, encodedNode));
        }
      }).pipe(Effect.provide(TestLayer)),
  );

  it.effect(
    "persistEncodedNode returns inline raw reference for encoded nodes smaller than 32 bytes",
    () =>
      Effect.gen(function* () {
        const encodedNode = bytesFromHex("0xc2200a");
        const expectedHash = yield* Hash.keccak256(encodedNode);

        const reference = yield* persistEncodedNode(encodedNode);

        assert.strictEqual(reference._tag, "raw");
        if (reference._tag !== "raw") {
          assert.fail("Expected raw reference for short encoded node");
          return;
        }

        const reEncoded = yield* coerceEffect<Uint8Array, unknown>(
          Rlp.encode(reference.value),
        );
        assert.isTrue(
          Bytes.equals(bytesFromUint8Array(reEncoded), encodedNode),
        );

        const persisted = yield* hasNode(expectedHash);
        assert.isFalse(persisted);
      }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("persistEncodedNode rejects invalid encoded bytes input", () =>
    Effect.gen(function* () {
      const invalidNode = null as unknown as BytesType;
      const result = (yield* Effect.either(
        persistEncodedNode(invalidNode),
      )) as Either<TrieNodeStorageError, unknown>;
      assertTrieNodeStorageError(result);
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect(
    "setNode stores an immutable copy when caller mutates the original bytes",
    () =>
      Effect.gen(function* () {
        const nodeHash = hashFromHex(
          "0x5555555555555555555555555555555555555555555555555555555555555555",
        );
        const original = bytesFromHex("0xc22003");
        const mutable = bytesFromHex("0xc22003");

        yield* setNode(nodeHash, mutable);

        mutable[mutable.length - 1] = 0xff;

        const loaded = yield* getNode(nodeHash);
        assert.isTrue(Option.isSome(loaded));
        if (Option.isSome(loaded)) {
          assert.isTrue(Bytes.equals(loaded.value, original));
        }
      }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("wraps DbError causes across trie node DB operations", () =>
    Effect.gen(function* () {
      const nodeHash = hashFromHex(
        "0x6666666666666666666666666666666666666666666666666666666666666666",
      );
      const encodedNode = bytesFromHex("0xc22006");

      yield* expectDbWrappedError(getNode(nodeHash));
      yield* expectDbWrappedError(setNode(nodeHash, encodedNode));
      yield* expectDbWrappedError(hasNode(nodeHash));
      yield* expectDbWrappedError(removeNode(nodeHash));
      yield* expectDbWrappedError(flushNodeStorage());
      yield* expectDbWrappedError(compactNodeStorage());
      yield* Effect.scoped(
        expectDbWrappedError(startNodeWriteBatch().pipe(Effect.asVoid)),
      );
    }).pipe(Effect.provide(RocksLayer)),
  );

  it.effect("reads hash-keyed entries via half-path scheme fallback", () =>
    Effect.gen(function* () {
      const addressHash = hashFromHex(
        "0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
      );
      const path: TrieNodePath = {
        bytes: hashFromHex(
          "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        ),
        length: 3,
      };
      const nodeHash = hashFromHex(
        "0x7777777777777777777777777777777777777777777777777777777777777777",
      );
      const encodedNode = bytesFromHex("0xc22007");

      yield* setNodeStorageScheme(TrieNodeStorageKeyScheme.Hash);
      yield* setNodeWithContext(addressHash, path, nodeHash, encodedNode);

      yield* setNodeStorageScheme(TrieNodeStorageKeyScheme.HalfPath);
      const loaded = yield* getNodeWithContext(addressHash, path, nodeHash);
      const exists = yield* hasNodeWithContext(addressHash, path, nodeHash);

      assert.isTrue(Option.isSome(loaded));
      assert.isTrue(exists);
      if (Option.isSome(loaded)) {
        assert.isTrue(Bytes.equals(loaded.value, encodedNode));
      }
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("reads half-path keyed entries via hash scheme fallback", () =>
    Effect.gen(function* () {
      const addressHash = hashFromHex(
        "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
      );
      const path: TrieNodePath = {
        bytes: hashFromHex(
          "0xdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd",
        ),
        length: 10,
      };
      const nodeHash = hashFromHex(
        "0x8888888888888888888888888888888888888888888888888888888888888888",
      );
      const encodedNode = bytesFromHex("0xc22008");

      yield* setNodeStorageScheme(TrieNodeStorageKeyScheme.HalfPath);
      yield* setNodeWithContext(addressHash, path, nodeHash, encodedNode);

      yield* setNodeStorageScheme(TrieNodeStorageKeyScheme.Hash);
      const loaded = yield* getNodeWithContext(addressHash, path, nodeHash);
      const exists = yield* hasNodeWithContext(addressHash, path, nodeHash);

      assert.isTrue(Option.isSome(loaded));
      assert.isTrue(exists);
      if (Option.isSome(loaded)) {
        assert.isTrue(Bytes.equals(loaded.value, encodedNode));
      }
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect(
    "setNodeStorageScheme updates and getNodeStorageScheme reads it",
    () =>
      Effect.gen(function* () {
        yield* setNodeStorageScheme(TrieNodeStorageKeyScheme.Hash);
        const hashScheme = yield* getNodeStorageScheme();
        assert.strictEqual(hashScheme, TrieNodeStorageKeyScheme.Hash);

        yield* setNodeStorageScheme(TrieNodeStorageKeyScheme.HalfPath);
        const halfPathScheme = yield* getNodeStorageScheme();
        assert.strictEqual(halfPathScheme, TrieNodeStorageKeyScheme.HalfPath);
      }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("removeNodeWithContext removes contextual node entries", () =>
    Effect.gen(function* () {
      const addressHash = hashFromHex(
        "0xabababababababababababababababababababababababababababababababab",
      );
      const path: TrieNodePath = {
        bytes: hashFromHex(
          "0xcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd",
        ),
        length: 8,
      };
      const nodeHash = hashFromHex(
        "0x9999999999999999999999999999999999999999999999999999999999999999",
      );
      const encodedNode = bytesFromHex("0xc22009");

      yield* setNodeWithContext(addressHash, path, nodeHash, encodedNode);
      yield* removeNodeWithContext(addressHash, path, nodeHash);

      const loaded = yield* getNodeWithContext(addressHash, path, nodeHash);
      const exists = yield* hasNodeWithContext(addressHash, path, nodeHash);
      assert.isTrue(Option.isNone(loaded));
      assert.isFalse(exists);
    }).pipe(Effect.provide(TestLayer)),
  );
});
