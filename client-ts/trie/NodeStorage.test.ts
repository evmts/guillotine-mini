import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import { Bytes, Hash, Hex, Rlp } from "voltaire-effect/primitives";
import {
  Db,
  DbError,
  DbMemoryTest,
  DbNames,
  DbRocksStubTest,
  ReadFlags,
  type DbWriteOp,
  type DbService,
} from "../db/Db";
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
    assert.strictEqual(result.left instanceof TrieNodeStorageError, true);
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

const unsupportedMergeError = () =>
  new DbError({ message: "Merge is not supported by capture test DB" });

type CaptureReadCall = {
  readonly keyHex: string;
  readonly flags: number | undefined;
};

const makeCaptureNodeStorageLayer = () => {
  const store = new Map<string, BytesType>();
  const readCalls: Array<CaptureReadCall> = [];
  const writeKeys: Array<string> = [];

  const clone = (value: BytesType): BytesType => Bytes.concat(value);
  const encodeKey = (key: BytesType): string => Hex.fromBytes(key);
  const decodeKey = (hex: string): BytesType => bytesFromHex(`0x${hex}`);
  const putEntry = (key: BytesType, value: BytesType) =>
    Effect.sync(() => {
      const keyHex = encodeKey(key);
      store.set(keyHex, clone(value));
      writeKeys.push(keyHex);
    });
  const removeEntry = (key: BytesType) =>
    Effect.sync(() => {
      store.delete(encodeKey(key));
    });

  const db: DbService = {
    name: DbNames.state,
    get: (key: BytesType, flags?: number) =>
      Effect.sync(() => {
        const keyHex = encodeKey(key);
        readCalls.push({ keyHex, flags });
        const value = store.get(keyHex);
        return Option.fromNullable(value).pipe(Option.map(clone));
      }),
    getMany: (keys: ReadonlyArray<BytesType>) =>
      Effect.sync(() =>
        keys.map((key) => {
          const keyHex = encodeKey(key);
          readCalls.push({ keyHex, flags: undefined });
          return {
            key,
            value: Option.fromNullable(store.get(keyHex)).pipe(
              Option.map(clone),
            ),
          };
        }),
      ),
    getAll: (_ordered?: boolean) =>
      Effect.sync(() =>
        Array.from(store.entries()).map(([keyHex, value]) => ({
          key: decodeKey(keyHex),
          value: clone(value),
        })),
      ),
    getAllKeys: (_ordered?: boolean) =>
      Effect.sync(() => Array.from(store.keys(), decodeKey)),
    getAllValues: (_ordered?: boolean) =>
      Effect.sync(() => Array.from(store.values(), clone)),
    put: (key: BytesType, value: BytesType) => putEntry(key, value),
    merge: (_key: BytesType, _value: BytesType) =>
      Effect.fail(unsupportedMergeError()),
    remove: (key: BytesType) => removeEntry(key),
    has: (key: BytesType) => Effect.sync(() => store.has(encodeKey(key))),
    createSnapshot: () =>
      Effect.acquireRelease(
        Effect.sync(() => ({
          get: (key: BytesType) =>
            Effect.sync(() =>
              Option.fromNullable(store.get(encodeKey(key))).pipe(
                Option.map(clone),
              ),
            ),
          getMany: (keys: ReadonlyArray<BytesType>) =>
            Effect.sync(() =>
              keys.map((key) => ({
                key,
                value: Option.fromNullable(store.get(encodeKey(key))).pipe(
                  Option.map(clone),
                ),
              })),
            ),
          getAll: (_ordered?: boolean) =>
            Effect.sync(() =>
              Array.from(store.entries()).map(([keyHex, value]) => ({
                key: decodeKey(keyHex),
                value: clone(value),
              })),
            ),
          getAllKeys: (_ordered?: boolean) =>
            Effect.sync(() => Array.from(store.keys(), decodeKey)),
          getAllValues: (_ordered?: boolean) =>
            Effect.sync(() => Array.from(store.values(), clone)),
          has: (key: BytesType) => Effect.sync(() => store.has(encodeKey(key))),
        })),
        () => Effect.void,
      ),
    flush: (_onlyWal?: boolean) => Effect.void,
    clear: () =>
      Effect.sync(() => {
        store.clear();
      }),
    compact: () => Effect.void,
    gatherMetric: () =>
      Effect.succeed({
        size: store.size,
        cacheSize: 0,
        indexSize: 0,
        memtableSize: 0,
        totalReads: readCalls.length,
        totalWrites: writeKeys.length,
      }),
    writeBatch: (ops: ReadonlyArray<DbWriteOp>) =>
      Effect.forEach(ops, (op) => {
        switch (op._tag) {
          case "put": {
            return putEntry(op.key, op.value);
          }
          case "del": {
            return removeEntry(op.key);
          }
          case "merge":
            return Effect.fail(unsupportedMergeError());
          default:
            return Effect.void;
        }
      }).pipe(Effect.asVoid),
    startWriteBatch: () =>
      Effect.acquireRelease(
        Effect.succeed({
          put: (key: BytesType, value: BytesType) => putEntry(key, value),
          merge: (_key: BytesType, _value: BytesType) =>
            Effect.fail(unsupportedMergeError()),
          remove: (key: BytesType) => removeEntry(key),
          clear: () => Effect.void,
        }),
        () => Effect.void,
      ),
  };

  return {
    layer: TrieNodeStorageTest.pipe(Layer.provide(Layer.succeed(Db, db))),
    readCalls,
    writeKeys,
  } as const;
};

const pathPrefixByLength = {
  0: "0000000000000000",
  1: "2000000000000000",
  4: "2222000000000000",
  5: "2222200000000000",
  6: "2222220000000000",
  10: "2222222222000000",
  32: "2222222222222222",
} as const;

const boundaryPathLengths = [0, 1, 4, 5, 6, 10, 32] as const;

const buildExpectedHalfPathKeyHex = (
  hasAddress: boolean,
  pathLength: (typeof boundaryPathLengths)[number],
): string => {
  const prefix = hasAddress ? "02" : pathLength > 5 ? "01" : "00";
  const address = hasAddress ? "11".repeat(32) : "";
  const pathPrefix = pathPrefixByLength[pathLength];
  const lengthHex = pathLength.toString(16).padStart(2, "0");
  const nodeHash = "33".repeat(32);
  return `0x${prefix}${address}${pathPrefix}${lengthHex}${nodeHash}`;
};

const expectedReadAheadFlags = (
  hasAddress: boolean,
  pathLength: (typeof boundaryPathLengths)[number],
) =>
  hasAddress
    ? ReadFlags.combine(ReadFlags.HintReadAhead, ReadFlags.HintReadAhead3)
    : pathLength > 5
      ? ReadFlags.combine(ReadFlags.HintReadAhead, ReadFlags.HintReadAhead2)
      : ReadFlags.HintReadAhead;

const isPlainBunTestRunner =
  typeof Bun !== "undefined" && process.env.VITEST === undefined;

const describeTrieNodeStorage = isPlainBunTestRunner ? describe.skip : describe;

describeTrieNodeStorage("TrieNodeStorage", () => {
  it.effect("setNode and getNode round-trip encoded trie nodes", () =>
    Effect.gen(function* () {
      const nodeHash = hashFromHex(
        "0x1111111111111111111111111111111111111111111111111111111111111111",
      );
      const encodedNode = bytesFromHex("0xc58320646f67");

      yield* setNode(nodeHash, encodedNode);
      const loaded = yield* getNode(nodeHash);

      assert.strictEqual(Option.isSome(loaded), true);
      if (Option.isSome(loaded)) {
        assert.strictEqual(Bytes.equals(loaded.value, encodedNode), true);
      }
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect("getNode returns none when hash is missing", () =>
    Effect.gen(function* () {
      const nodeHash = hashFromHex(
        "0x2222222222222222222222222222222222222222222222222222222222222222",
      );
      const loaded = yield* getNode(nodeHash);
      assert.strictEqual(Option.isNone(loaded), true);
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

      assert.strictEqual(before, false);
      assert.strictEqual(after, true);
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

      assert.strictEqual(Option.isNone(loaded), true);
      assert.strictEqual(present, false);
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

      assert.strictEqual(Option.isSome(before), true);
      assert.strictEqual(beforePresent, true);
      assert.strictEqual(Option.isSome(after), true);
      assert.strictEqual(afterPresent, true);

      if (Option.isSome(before) && Option.isSome(after)) {
        assert.strictEqual(Bytes.equals(before.value, emptyNode), true);
        assert.strictEqual(Bytes.equals(after.value, emptyNode), true);
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

        assert.strictEqual(
          yield* Hash.equals(reference.value, expectedHash),
          true,
        );

        const loaded = yield* getNode(reference.value);
        assert.strictEqual(Option.isSome(loaded), true);
        if (Option.isSome(loaded)) {
          assert.strictEqual(Bytes.equals(loaded.value, encodedNode), true);
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
        assert.strictEqual(
          Bytes.equals(bytesFromUint8Array(reEncoded), encodedNode),
          true,
        );

        const persisted = yield* hasNode(expectedHash);
        assert.strictEqual(persisted, false);
      }).pipe(Effect.provide(TestLayer)),
  );

  it.effect(
    "persistEncodedNode hashes and stores nodes with encoded size exactly 32 bytes",
    () =>
      Effect.gen(function* () {
        const encodedNode = bytesFromHex(`0x${"ab".repeat(32)}`);
        const expectedHash = yield* Hash.keccak256(encodedNode);

        const reference = yield* persistEncodedNode(encodedNode);
        assert.strictEqual(reference._tag, "hash");
        if (reference._tag !== "hash") {
          assert.fail("Expected hash reference for 32-byte encoded node");
          return;
        }

        assert.strictEqual(
          yield* Hash.equals(reference.value, expectedHash),
          true,
        );

        const loaded = yield* getNode(reference.value);
        assert.strictEqual(Option.isSome(loaded), true);
        if (Option.isSome(loaded)) {
          assert.strictEqual(Bytes.equals(loaded.value, encodedNode), true);
        }
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
        assert.strictEqual(Option.isSome(loaded), true);
        if (Option.isSome(loaded)) {
          assert.strictEqual(Bytes.equals(loaded.value, original), true);
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

  it.effect(
    "startNodeWriteBatch supports set/remove/clear on the success path",
    () =>
      Effect.scoped(
        Effect.gen(function* () {
          const addressHash = hashFromHex(
            "0x1212121212121212121212121212121212121212121212121212121212121212",
          );
          const pathA: TrieNodePath = {
            bytes: hashFromHex(
              "0x3434343434343434343434343434343434343434343434343434343434343434",
            ),
            length: 5,
          };
          const pathB: TrieNodePath = {
            bytes: hashFromHex(
              "0x5656565656565656565656565656565656565656565656565656565656565656",
            ),
            length: 10,
          };
          const nodeHashA = hashFromHex(
            "0x7878787878787878787878787878787878787878787878787878787878787878",
          );
          const nodeHashB = hashFromHex(
            "0x9090909090909090909090909090909090909090909090909090909090909090",
          );
          const encodedA = bytesFromHex("0xc2200c");
          const encodedB = bytesFromHex("0xc2200d");

          yield* setNodeStorageScheme(TrieNodeStorageKeyScheme.HalfPath);

          const batch = yield* startNodeWriteBatch();
          yield* batch.set(addressHash, pathA, nodeHashA, encodedA);

          const loadedAfterSet = yield* getNodeWithContext(
            addressHash,
            pathA,
            nodeHashA,
          );
          assert.strictEqual(Option.isSome(loadedAfterSet), true);

          yield* batch.remove(addressHash, pathA, nodeHashA);
          const loadedAfterRemove = yield* getNodeWithContext(
            addressHash,
            pathA,
            nodeHashA,
          );
          assert.strictEqual(Option.isNone(loadedAfterRemove), true);

          yield* batch.set(addressHash, pathB, nodeHashB, encodedB);
          yield* batch.clear();

          const loadedAfterClear = yield* getNodeWithContext(
            addressHash,
            pathB,
            nodeHashB,
          );
          assert.strictEqual(Option.isSome(loadedAfterClear), true);
          if (Option.isSome(loadedAfterClear)) {
            assert.strictEqual(
              Bytes.equals(loadedAfterClear.value, encodedB),
              true,
            );
          }
        }).pipe(Effect.provide(TestLayer)),
      ),
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

      assert.strictEqual(Option.isSome(loaded), true);
      assert.strictEqual(exists, true);
      if (Option.isSome(loaded)) {
        assert.strictEqual(Bytes.equals(loaded.value, encodedNode), true);
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

      assert.strictEqual(Option.isSome(loaded), true);
      assert.strictEqual(exists, true);
      if (Option.isSome(loaded)) {
        assert.strictEqual(Bytes.equals(loaded.value, encodedNode), true);
      }
    }).pipe(Effect.provide(TestLayer)),
  );

  it.effect(
    "matches Nethermind half-path key encoding boundaries with and without address",
    () => {
      const harness = makeCaptureNodeStorageLayer();
      return Effect.gen(function* () {
        const addressHash = hashFromHex(`0x${"11".repeat(32)}`);
        const pathBytes = hashFromHex(`0x${"22".repeat(32)}`);
        const nodeHash = hashFromHex(`0x${"33".repeat(32)}`);
        const encodedNode = bytesFromHex("0xc2200b");

        yield* setNodeStorageScheme(TrieNodeStorageKeyScheme.HalfPath);

        for (const hasAddress of [false, true] as const) {
          for (const pathLength of boundaryPathLengths) {
            const path: TrieNodePath = { bytes: pathBytes, length: pathLength };
            const writeCountBefore = harness.writeKeys.length;

            yield* setNodeWithContext(
              hasAddress ? addressHash : null,
              path,
              nodeHash,
              encodedNode,
            );

            const observedKeyHex = harness.writeKeys[writeCountBefore];
            assert.strictEqual(typeof observedKeyHex, "string");
            assert.strictEqual(
              observedKeyHex,
              buildExpectedHalfPathKeyHex(hasAddress, pathLength),
            );
          }
        }
      }).pipe(Effect.provide(harness.layer));
    },
  );

  it.effect(
    "applies read-ahead flags at half-path boundary lengths for top-level and storage keys",
    () => {
      const harness = makeCaptureNodeStorageLayer();
      return Effect.gen(function* () {
        const addressHash = hashFromHex(`0x${"11".repeat(32)}`);
        const pathBytes = hashFromHex(`0x${"22".repeat(32)}`);
        const nodeHash = hashFromHex(`0x${"33".repeat(32)}`);

        yield* setNodeStorageScheme(TrieNodeStorageKeyScheme.HalfPath);

        for (const hasAddress of [false, true] as const) {
          for (const pathLength of boundaryPathLengths) {
            const path: TrieNodePath = { bytes: pathBytes, length: pathLength };
            const readCountBefore = harness.readCalls.length;

            const loaded = yield* getNodeWithContext(
              hasAddress ? addressHash : null,
              path,
              nodeHash,
              ReadFlags.HintReadAhead,
            );

            assert.strictEqual(Option.isNone(loaded), true);
            assert.strictEqual(
              harness.readCalls.length > readCountBefore,
              true,
            );

            const firstRead = harness.readCalls[readCountBefore];
            assert.strictEqual(firstRead === undefined, false);
            if (firstRead === undefined) {
              assert.fail("Expected a captured read call");
              return;
            }
            assert.strictEqual(
              firstRead.keyHex,
              buildExpectedHalfPathKeyHex(hasAddress, pathLength),
            );
            assert.strictEqual(
              firstRead.flags,
              expectedReadAheadFlags(hasAddress, pathLength),
            );
          }
        }
      }).pipe(Effect.provide(harness.layer));
    },
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
      assert.strictEqual(Option.isNone(loaded), true);
      assert.strictEqual(exists, false);
    }).pipe(Effect.provide(TestLayer)),
  );
});
