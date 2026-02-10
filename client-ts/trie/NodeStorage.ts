import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import { Bytes, Hash } from "voltaire-effect/primitives";
import { Db, type DbService } from "../db/Db";
import type { DbError } from "../db/DbError";
import type { BytesType } from "./Node";

/** Error raised when trie node storage operations fail. */
export class TrieNodeStorageError extends Data.TaggedError(
  "TrieNodeStorageError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Trie node persistence interface. */
export interface TrieNodeStorageService {
  readonly get: (
    nodeHash: Hash.HashType,
  ) => Effect.Effect<Option.Option<BytesType>, TrieNodeStorageError>;
  readonly set: (
    nodeHash: Hash.HashType,
    encodedNode: BytesType,
  ) => Effect.Effect<void, TrieNodeStorageError>;
  readonly has: (
    nodeHash: Hash.HashType,
  ) => Effect.Effect<boolean, TrieNodeStorageError>;
  readonly remove: (
    nodeHash: Hash.HashType,
  ) => Effect.Effect<void, TrieNodeStorageError>;
}

/** Context tag for trie node persistence. */
export class TrieNodeStorage extends Context.Tag("TrieNodeStorage")<
  TrieNodeStorage,
  TrieNodeStorageService
>() {}

const invalidNodeHashError = (cause?: unknown) =>
  new TrieNodeStorageError({
    message: "Invalid trie node hash",
    cause,
  });

const invalidNodeDataError = (cause?: unknown) =>
  new TrieNodeStorageError({
    message: "Invalid trie node data",
    cause,
  });

const wrapDbGetError = (cause: DbError) =>
  new TrieNodeStorageError({
    message: "Failed to load trie node from DB",
    cause,
  });

const wrapDbSetError = (cause: DbError) =>
  new TrieNodeStorageError({
    message: "Failed to persist trie node to DB",
    cause,
  });

const wrapDbHasError = (cause: DbError) =>
  new TrieNodeStorageError({
    message: "Failed to check trie node presence in DB",
    cause,
  });

const wrapDbRemoveError = (cause: DbError) =>
  new TrieNodeStorageError({
    message: "Failed to remove trie node from DB",
    cause,
  });

const validateNodeHash = (
  nodeHash: Hash.HashType,
): Effect.Effect<Hash.HashType, TrieNodeStorageError> =>
  Hash.isHash(nodeHash)
    ? Effect.succeed(nodeHash)
    : Effect.fail(invalidNodeHashError());

const validateNodeData = (
  encodedNode: BytesType,
): Effect.Effect<BytesType, TrieNodeStorageError> =>
  Bytes.isBytes(encodedNode)
    ? Effect.succeed(encodedNode)
    : Effect.fail(invalidNodeDataError());

const cloneBytes = (value: BytesType): BytesType => Bytes.concat(value);

const makeTrieNodeStorage = (db: DbService) =>
  ({
    get: (nodeHash: Hash.HashType) =>
      Effect.gen(function* () {
        const validatedHash = yield* validateNodeHash(nodeHash);
        return yield* pipe(
          db.get(validatedHash),
          Effect.mapError(wrapDbGetError),
        );
      }),
    set: (nodeHash: Hash.HashType, encodedNode: BytesType) =>
      Effect.gen(function* () {
        const validatedHash = yield* validateNodeHash(nodeHash);
        const validatedNodeData = yield* validateNodeData(encodedNode);
        yield* pipe(
          db.put(validatedHash, cloneBytes(validatedNodeData)),
          Effect.mapError(wrapDbSetError),
        );
      }),
    has: (nodeHash: Hash.HashType) =>
      Effect.gen(function* () {
        const validatedHash = yield* validateNodeHash(nodeHash);
        return yield* pipe(
          db.has(validatedHash),
          Effect.mapError(wrapDbHasError),
        );
      }),
    remove: (nodeHash: Hash.HashType) =>
      Effect.gen(function* () {
        const validatedHash = yield* validateNodeHash(nodeHash);
        yield* pipe(
          db.remove(validatedHash),
          Effect.mapError(wrapDbRemoveError),
        );
      }),
  }) satisfies TrieNodeStorageService;

const TrieNodeStorageLayer = Layer.effect(
  TrieNodeStorage,
  Effect.gen(function* () {
    const db = yield* Db;
    return makeTrieNodeStorage(db);
  }),
);

/** Production trie node storage layer backed by DB. */
export const TrieNodeStorageLive: Layer.Layer<TrieNodeStorage, never, Db> =
  TrieNodeStorageLayer;

/** Deterministic trie node storage layer for tests. */
export const TrieNodeStorageTest: Layer.Layer<TrieNodeStorage, never, Db> =
  TrieNodeStorageLayer;

/** Load an encoded trie node by hash. */
export const getNode = (nodeHash: Hash.HashType) =>
  Effect.gen(function* () {
    const storage = yield* TrieNodeStorage;
    return yield* storage.get(nodeHash);
  });

/** Persist an encoded trie node by hash. */
export const setNode = (nodeHash: Hash.HashType, encodedNode: BytesType) =>
  Effect.gen(function* () {
    const storage = yield* TrieNodeStorage;
    yield* storage.set(nodeHash, encodedNode);
  });

/** Persist an encoded trie node and return its hash reference. */
export const persistEncodedNode = (encodedNode: BytesType) =>
  Effect.gen(function* () {
    const validatedNodeData = yield* validateNodeData(encodedNode);
    const nodeHash = yield* Hash.keccak256(validatedNodeData);
    yield* setNode(nodeHash, validatedNodeData);
    return nodeHash;
  });

/** Check if an encoded trie node exists by hash. */
export const hasNode = (nodeHash: Hash.HashType) =>
  Effect.gen(function* () {
    const storage = yield* TrieNodeStorage;
    return yield* storage.has(nodeHash);
  });

/** Remove an encoded trie node by hash. */
export const removeNode = (nodeHash: Hash.HashType) =>
  Effect.gen(function* () {
    const storage = yield* TrieNodeStorage;
    yield* storage.remove(nodeHash);
  });
