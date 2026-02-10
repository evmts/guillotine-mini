import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import * as Scope from "effect/Scope";
import { Bytes, Hash, Hex } from "voltaire-effect/primitives";
import {
  Db,
  ReadFlags,
  type DbService,
  type ReadFlags as DbReadFlags,
  type WriteBatch,
  type WriteFlags as DbWriteFlags,
} from "../db/Db";
import type { DbError } from "../db/DbError";
import type { EncodedNode } from "./Node";
import type { BytesType } from "./Node";
import { makeBytesHelpers, makeHashHelpers } from "./internal/primitives";
import { EMPTY_TRIE_ROOT } from "./root";

/** Error raised when trie node storage operations fail. */
export class TrieNodeStorageError extends Data.TaggedError(
  "TrieNodeStorageError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Key scheme used for trie node DB keys. */
export const TrieNodeStorageKeyScheme = {
  Hash: "hash",
  HalfPath: "halfPath",
  Current: "current",
} as const;

/** Trie node key scheme type. */
export type TrieNodeStorageKeyScheme =
  (typeof TrieNodeStorageKeyScheme)[keyof typeof TrieNodeStorageKeyScheme];

/** Tree path context used for half-path trie node keys. */
export interface TrieNodePath {
  readonly bytes: Hash.HashType;
  readonly length: number;
}

/** Batched trie node write operations. */
export interface TrieNodeStorageWriteBatch {
  readonly set: (
    addressHash: Hash.HashType | null,
    path: TrieNodePath,
    nodeHash: Hash.HashType,
    encodedNode: BytesType,
    writeFlags?: DbWriteFlags,
  ) => Effect.Effect<void, TrieNodeStorageError>;
  readonly remove: (
    addressHash: Hash.HashType | null,
    path: TrieNodePath,
    nodeHash: Hash.HashType,
  ) => Effect.Effect<void, TrieNodeStorageError>;
  readonly clear: () => Effect.Effect<void, TrieNodeStorageError>;
}

/** Trie node persistence interface. */
export interface TrieNodeStorageService {
  readonly getScheme: () => Effect.Effect<TrieNodeStorageKeyScheme>;
  readonly setScheme: (
    scheme: TrieNodeStorageKeyScheme,
  ) => Effect.Effect<void, TrieNodeStorageError>;
  readonly requirePath: boolean;
  readonly get: (
    addressHash: Hash.HashType | null,
    path: TrieNodePath,
    nodeHash: Hash.HashType,
    readFlags?: DbReadFlags,
  ) => Effect.Effect<Option.Option<BytesType>, TrieNodeStorageError>;
  readonly set: (
    addressHash: Hash.HashType | null,
    path: TrieNodePath,
    nodeHash: Hash.HashType,
    encodedNode: BytesType,
    writeFlags?: DbWriteFlags,
  ) => Effect.Effect<void, TrieNodeStorageError>;
  readonly keyExists: (
    addressHash: Hash.HashType | null,
    path: TrieNodePath,
    nodeHash: Hash.HashType,
  ) => Effect.Effect<boolean, TrieNodeStorageError>;
  readonly remove: (
    addressHash: Hash.HashType | null,
    path: TrieNodePath,
    nodeHash: Hash.HashType,
  ) => Effect.Effect<void, TrieNodeStorageError>;
  readonly startWriteBatch: () => Effect.Effect<
    TrieNodeStorageWriteBatch,
    TrieNodeStorageError,
    Scope.Scope
  >;
  readonly flush: (
    onlyWal?: boolean,
  ) => Effect.Effect<void, TrieNodeStorageError>;
  readonly compact: () => Effect.Effect<void, TrieNodeStorageError>;
}

/** Context tag for trie node persistence. */
export class TrieNodeStorage extends Context.Tag("TrieNodeStorage")<
  TrieNodeStorage,
  TrieNodeStorageService
>() {}

const StoragePathLength = 74;
const StateKeyLength = 42;
const HashKeyLength = 32;
const TopStateBoundary = 5;
const MaxPathLength = 64;

const invalidNodeHashError = (cause?: unknown) =>
  new TrieNodeStorageError({
    message: "Invalid trie node hash",
    cause,
  });

const invalidAddressHashError = (cause?: unknown) =>
  new TrieNodeStorageError({
    message: "Invalid trie address hash",
    cause,
  });

const invalidNodePathError = (cause?: unknown) =>
  new TrieNodeStorageError({
    message: "Invalid trie node path",
    cause,
  });

const invalidNodeDataError = (cause?: unknown) =>
  new TrieNodeStorageError({
    message: "Invalid trie node data",
    cause,
  });

const invalidKeySchemeError = (cause?: unknown) =>
  new TrieNodeStorageError({
    message: "Invalid trie node key scheme",
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

const wrapDbStartBatchError = (cause: DbError) =>
  new TrieNodeStorageError({
    message: "Failed to start trie node write batch",
    cause,
  });

const wrapDbWriteBatchError = (cause: DbError) =>
  new TrieNodeStorageError({
    message: "Failed to write trie node batch operation",
    cause,
  });

const wrapDbFlushError = (cause: DbError) =>
  new TrieNodeStorageError({
    message: "Failed to flush trie node storage",
    cause,
  });

const wrapDbCompactError = (cause: DbError) =>
  new TrieNodeStorageError({
    message: "Failed to compact trie node storage",
    cause,
  });

const validateNodeHash = (
  nodeHash: Hash.HashType,
): Effect.Effect<Hash.HashType, TrieNodeStorageError> =>
  Hash.isHash(nodeHash)
    ? Effect.succeed(nodeHash)
    : Effect.fail(invalidNodeHashError());

const validateAddressHash = (
  addressHash: Hash.HashType | null,
): Effect.Effect<Hash.HashType | null, TrieNodeStorageError> =>
  addressHash === null
    ? Effect.succeed(null)
    : Hash.isHash(addressHash)
      ? Effect.succeed(addressHash)
      : Effect.fail(invalidAddressHashError());

const validateNodePath = (
  path: TrieNodePath,
): Effect.Effect<TrieNodePath, TrieNodeStorageError> => {
  if (!Hash.isHash(path.bytes)) {
    return Effect.fail(invalidNodePathError());
  }

  if (
    !Number.isInteger(path.length) ||
    path.length < 0 ||
    path.length > MaxPathLength
  ) {
    return Effect.fail(invalidNodePathError());
  }

  return Effect.succeed(path);
};

const validateNodeData = (
  encodedNode: BytesType,
): Effect.Effect<BytesType, TrieNodeStorageError> =>
  Bytes.isBytes(encodedNode)
    ? Effect.succeed(encodedNode)
    : Effect.fail(invalidNodeDataError());

const validateKeyScheme = (
  scheme: TrieNodeStorageKeyScheme,
): Effect.Effect<TrieNodeStorageKeyScheme, TrieNodeStorageError> => {
  switch (scheme) {
    case TrieNodeStorageKeyScheme.Hash:
    case TrieNodeStorageKeyScheme.HalfPath:
    case TrieNodeStorageKeyScheme.Current:
      return Effect.succeed(scheme);
    default:
      return Effect.fail(invalidKeySchemeError());
  }
};

const cloneBytes = (value: BytesType): BytesType => Bytes.concat(value);
const { bytesFromHex, bytesFromUint8Array } = makeBytesHelpers(
  (message) => new TrieNodeStorageError({ message }),
);
const { hashFromHex } = makeHashHelpers(
  (message) => new TrieNodeStorageError({ message }),
);
const EmptyTrieNode = bytesFromHex("0x80");
const EmptyTrieRootHex = Hex.fromBytes(EMPTY_TRIE_ROOT);
const EmptyPathHash = hashFromHex(
  "0x0000000000000000000000000000000000000000000000000000000000000000",
);

/** Empty/default trie path context used by hash-only APIs. */
export const EmptyNodePath: TrieNodePath = {
  bytes: EmptyPathHash,
  length: 0,
};

const isEmptyTrieRoot = (nodeHash: Hash.HashType): boolean =>
  Hex.fromBytes(nodeHash) === EmptyTrieRootHex;

const normalizeScheme = (
  scheme: TrieNodeStorageKeyScheme,
): TrieNodeStorageKeyScheme =>
  scheme === TrieNodeStorageKeyScheme.Current
    ? TrieNodeStorageKeyScheme.HalfPath
    : scheme;

const getHashNodeStoragePath = (nodeHash: Hash.HashType): BytesType => nodeHash;

const getHalfPathNodeStoragePath = (
  addressHash: Hash.HashType | null,
  path: TrieNodePath,
  nodeHash: Hash.HashType,
): Effect.Effect<BytesType, TrieNodeStorageError> =>
  Effect.try({
    try: () => {
      if (addressHash === null) {
        const pathBytes = new Uint8Array(StateKeyLength);
        pathBytes[0] = path.length <= TopStateBoundary ? 0 : 1;
        pathBytes.set(path.bytes.subarray(0, 8), 1);
        pathBytes[9] = path.length;
        pathBytes.set(nodeHash, 10);
        return bytesFromUint8Array(pathBytes);
      }

      const pathBytes = new Uint8Array(StoragePathLength);
      pathBytes[0] = 2;
      pathBytes.set(addressHash, 1);
      pathBytes.set(path.bytes.subarray(0, 8), 33);
      pathBytes[41] = path.length;
      pathBytes.set(nodeHash, 42);
      return bytesFromUint8Array(pathBytes);
    },
    catch: (cause) => invalidNodePathError(cause),
  });

const adjustReadFlagsForHalfPath = (
  addressHash: Hash.HashType | null,
  path: TrieNodePath,
  readFlags: DbReadFlags,
): DbReadFlags => {
  if ((readFlags & ReadFlags.HintReadAhead) === 0) {
    return readFlags;
  }

  if (addressHash === null && path.length > TopStateBoundary) {
    return ReadFlags.combine(readFlags, ReadFlags.HintReadAhead2);
  }

  if (addressHash !== null) {
    return ReadFlags.combine(readFlags, ReadFlags.HintReadAhead3);
  }

  return readFlags;
};

const readWithFallback = (
  db: DbService,
  scheme: TrieNodeStorageKeyScheme,
  hashKey: BytesType,
  halfPathKey: BytesType,
  readFlags: DbReadFlags,
): Effect.Effect<Option.Option<BytesType>, TrieNodeStorageError> =>
  Effect.gen(function* () {
    const firstKey =
      scheme === TrieNodeStorageKeyScheme.HalfPath ? halfPathKey : hashKey;
    const secondKey =
      scheme === TrieNodeStorageKeyScheme.HalfPath ? hashKey : halfPathKey;

    const firstResult = yield* pipe(
      db.get(firstKey, readFlags),
      Effect.mapError(wrapDbGetError),
    );

    if (Option.isSome(firstResult)) {
      return firstResult;
    }

    return yield* pipe(
      db.get(secondKey, readFlags),
      Effect.mapError(wrapDbGetError),
    );
  });

const keyExistsWithFallback = (
  db: DbService,
  scheme: TrieNodeStorageKeyScheme,
  hashKey: BytesType,
  halfPathKey: BytesType,
): Effect.Effect<boolean, TrieNodeStorageError> =>
  Effect.gen(function* () {
    const firstKey =
      scheme === TrieNodeStorageKeyScheme.HalfPath ? halfPathKey : hashKey;
    const secondKey =
      scheme === TrieNodeStorageKeyScheme.HalfPath ? hashKey : halfPathKey;

    const firstExists = yield* pipe(
      db.has(firstKey),
      Effect.mapError(wrapDbHasError),
    );

    if (firstExists) {
      return true;
    }

    return yield* pipe(db.has(secondKey), Effect.mapError(wrapDbHasError));
  });

const makeWriteBatch = (
  batch: WriteBatch,
  resolveScheme: () => TrieNodeStorageKeyScheme,
): TrieNodeStorageWriteBatch =>
  ({
    set: (
      addressHash: Hash.HashType | null,
      path: TrieNodePath,
      nodeHash: Hash.HashType,
      encodedNode: BytesType,
      writeFlags?: DbWriteFlags,
    ) =>
      Effect.gen(function* () {
        const validatedAddressHash = yield* validateAddressHash(addressHash);
        const validatedPath = yield* validateNodePath(path);
        const validatedHash = yield* validateNodeHash(nodeHash);
        const validatedNodeData = yield* validateNodeData(encodedNode);

        if (isEmptyTrieRoot(validatedHash)) {
          return;
        }

        const scheme = resolveScheme();
        const key =
          scheme === TrieNodeStorageKeyScheme.HalfPath
            ? yield* getHalfPathNodeStoragePath(
                validatedAddressHash,
                validatedPath,
                validatedHash,
              )
            : getHashNodeStoragePath(validatedHash);

        yield* pipe(
          batch.put(key, cloneBytes(validatedNodeData), writeFlags),
          Effect.mapError(wrapDbWriteBatchError),
        );
      }),
    remove: (
      addressHash: Hash.HashType | null,
      path: TrieNodePath,
      nodeHash: Hash.HashType,
    ) =>
      Effect.gen(function* () {
        const validatedAddressHash = yield* validateAddressHash(addressHash);
        const validatedPath = yield* validateNodePath(path);
        const validatedHash = yield* validateNodeHash(nodeHash);

        if (isEmptyTrieRoot(validatedHash)) {
          return;
        }

        const scheme = resolveScheme();
        const key =
          scheme === TrieNodeStorageKeyScheme.HalfPath
            ? yield* getHalfPathNodeStoragePath(
                validatedAddressHash,
                validatedPath,
                validatedHash,
              )
            : getHashNodeStoragePath(validatedHash);

        yield* pipe(batch.remove(key), Effect.mapError(wrapDbWriteBatchError));
      }),
    clear: () => pipe(batch.clear(), Effect.mapError(wrapDbWriteBatchError)),
  }) satisfies TrieNodeStorageWriteBatch;

const makeTrieNodeStorage = (db: DbService) => {
  let scheme: TrieNodeStorageKeyScheme = TrieNodeStorageKeyScheme.HalfPath;

  const resolveScheme = () => normalizeScheme(scheme);

  return {
    getScheme: () => Effect.sync(() => scheme),
    setScheme: (nextScheme: TrieNodeStorageKeyScheme) =>
      Effect.gen(function* () {
        const validatedScheme = yield* validateKeyScheme(nextScheme);
        scheme = validatedScheme;
      }),
    requirePath: true,
    get: (
      addressHash: Hash.HashType | null,
      path: TrieNodePath,
      nodeHash: Hash.HashType,
      readFlags: DbReadFlags = ReadFlags.None,
    ) =>
      Effect.gen(function* () {
        const validatedAddressHash = yield* validateAddressHash(addressHash);
        const validatedPath = yield* validateNodePath(path);
        const validatedHash = yield* validateNodeHash(nodeHash);

        if (isEmptyTrieRoot(validatedHash)) {
          return Option.some(cloneBytes(EmptyTrieNode));
        }

        const effectiveScheme = resolveScheme();
        const hashKey = getHashNodeStoragePath(validatedHash);
        const halfPathKey = yield* getHalfPathNodeStoragePath(
          validatedAddressHash,
          validatedPath,
          validatedHash,
        );

        const adjustedReadFlags =
          effectiveScheme === TrieNodeStorageKeyScheme.HalfPath
            ? adjustReadFlagsForHalfPath(
                validatedAddressHash,
                validatedPath,
                readFlags,
              )
            : readFlags;

        return yield* readWithFallback(
          db,
          effectiveScheme,
          hashKey,
          halfPathKey,
          adjustedReadFlags,
        );
      }),
    set: (
      addressHash: Hash.HashType | null,
      path: TrieNodePath,
      nodeHash: Hash.HashType,
      encodedNode: BytesType,
      writeFlags?: DbWriteFlags,
    ) =>
      Effect.gen(function* () {
        const validatedAddressHash = yield* validateAddressHash(addressHash);
        const validatedPath = yield* validateNodePath(path);
        const validatedHash = yield* validateNodeHash(nodeHash);
        const validatedNodeData = yield* validateNodeData(encodedNode);

        if (isEmptyTrieRoot(validatedHash)) {
          return;
        }

        const effectiveScheme = resolveScheme();
        const key =
          effectiveScheme === TrieNodeStorageKeyScheme.HalfPath
            ? yield* getHalfPathNodeStoragePath(
                validatedAddressHash,
                validatedPath,
                validatedHash,
              )
            : getHashNodeStoragePath(validatedHash);

        yield* pipe(
          db.put(key, cloneBytes(validatedNodeData), writeFlags),
          Effect.mapError(wrapDbSetError),
        );
      }),
    keyExists: (
      addressHash: Hash.HashType | null,
      path: TrieNodePath,
      nodeHash: Hash.HashType,
    ) =>
      Effect.gen(function* () {
        const validatedAddressHash = yield* validateAddressHash(addressHash);
        const validatedPath = yield* validateNodePath(path);
        const validatedHash = yield* validateNodeHash(nodeHash);

        if (isEmptyTrieRoot(validatedHash)) {
          return true;
        }

        const effectiveScheme = resolveScheme();
        const hashKey = getHashNodeStoragePath(validatedHash);
        const halfPathKey = yield* getHalfPathNodeStoragePath(
          validatedAddressHash,
          validatedPath,
          validatedHash,
        );

        return yield* keyExistsWithFallback(
          db,
          effectiveScheme,
          hashKey,
          halfPathKey,
        );
      }),
    remove: (
      addressHash: Hash.HashType | null,
      path: TrieNodePath,
      nodeHash: Hash.HashType,
    ) =>
      Effect.gen(function* () {
        const validatedAddressHash = yield* validateAddressHash(addressHash);
        const validatedPath = yield* validateNodePath(path);
        const validatedHash = yield* validateNodeHash(nodeHash);

        if (isEmptyTrieRoot(validatedHash)) {
          return;
        }

        const effectiveScheme = resolveScheme();
        const key =
          effectiveScheme === TrieNodeStorageKeyScheme.HalfPath
            ? yield* getHalfPathNodeStoragePath(
                validatedAddressHash,
                validatedPath,
                validatedHash,
              )
            : getHashNodeStoragePath(validatedHash);

        yield* pipe(db.remove(key), Effect.mapError(wrapDbRemoveError));
      }),
    startWriteBatch: () =>
      Effect.gen(function* () {
        const batch = yield* pipe(
          db.startWriteBatch(),
          Effect.mapError(wrapDbStartBatchError),
        );

        return makeWriteBatch(batch, resolveScheme);
      }),
    flush: (onlyWal?: boolean) =>
      pipe(db.flush(onlyWal), Effect.mapError(wrapDbFlushError)),
    compact: () => pipe(db.compact(), Effect.mapError(wrapDbCompactError)),
  } satisfies TrieNodeStorageService;
};

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

/** Load an encoded trie node by hash-only context. */
export const getNode = (nodeHash: Hash.HashType, readFlags?: DbReadFlags) =>
  Effect.gen(function* () {
    const storage = yield* TrieNodeStorage;
    return yield* storage.get(null, EmptyNodePath, nodeHash, readFlags);
  });

/** Persist an encoded trie node by hash-only context. */
export const setNode = (
  nodeHash: Hash.HashType,
  encodedNode: BytesType,
  writeFlags?: DbWriteFlags,
) =>
  Effect.gen(function* () {
    const storage = yield* TrieNodeStorage;
    yield* storage.set(null, EmptyNodePath, nodeHash, encodedNode, writeFlags);
  });

/** Load an encoded trie node by full context (address hash + path + node hash). */
export const getNodeWithContext = (
  addressHash: Hash.HashType | null,
  path: TrieNodePath,
  nodeHash: Hash.HashType,
  readFlags?: DbReadFlags,
) =>
  Effect.gen(function* () {
    const storage = yield* TrieNodeStorage;
    return yield* storage.get(addressHash, path, nodeHash, readFlags);
  });

/** Persist an encoded trie node by full context (address hash + path + node hash). */
export const setNodeWithContext = (
  addressHash: Hash.HashType | null,
  path: TrieNodePath,
  nodeHash: Hash.HashType,
  encodedNode: BytesType,
  writeFlags?: DbWriteFlags,
) =>
  Effect.gen(function* () {
    const storage = yield* TrieNodeStorage;
    yield* storage.set(addressHash, path, nodeHash, encodedNode, writeFlags);
  });

/** Persist an encoded trie node and return its hash reference. */
export const persistEncodedNode = (encodedNode: BytesType) =>
  Effect.gen(function* () {
    const validatedNodeData = yield* validateNodeData(encodedNode);
    const nodeHash = yield* Hash.keccak256(validatedNodeData);
    yield* setNode(nodeHash, validatedNodeData);
    return nodeHash;
  });

/** Check if an encoded trie node exists by hash-only context. */
export const hasNode = (nodeHash: Hash.HashType) =>
  Effect.gen(function* () {
    const storage = yield* TrieNodeStorage;
    return yield* storage.keyExists(null, EmptyNodePath, nodeHash);
  });

/** Check if an encoded trie node exists by full context. */
export const hasNodeWithContext = (
  addressHash: Hash.HashType | null,
  path: TrieNodePath,
  nodeHash: Hash.HashType,
) =>
  Effect.gen(function* () {
    const storage = yield* TrieNodeStorage;
    return yield* storage.keyExists(addressHash, path, nodeHash);
  });

/** Remove an encoded trie node by hash-only context. */
export const removeNode = (nodeHash: Hash.HashType) =>
  Effect.gen(function* () {
    const storage = yield* TrieNodeStorage;
    yield* storage.remove(null, EmptyNodePath, nodeHash);
  });

/** Remove an encoded trie node by full context. */
export const removeNodeWithContext = (
  addressHash: Hash.HashType | null,
  path: TrieNodePath,
  nodeHash: Hash.HashType,
) =>
  Effect.gen(function* () {
    const storage = yield* TrieNodeStorage;
    yield* storage.remove(addressHash, path, nodeHash);
  });

/** Return the active trie node storage key scheme. */
export const getNodeStorageScheme = () =>
  Effect.gen(function* () {
    const storage = yield* TrieNodeStorage;
    return yield* storage.getScheme();
  });

/** Update the active trie node storage key scheme. */
export const setNodeStorageScheme = (scheme: TrieNodeStorageKeyScheme) =>
  Effect.gen(function* () {
    const storage = yield* TrieNodeStorage;
    yield* storage.setScheme(scheme);
  });

/** Start a trie node write batch. */
export const startNodeWriteBatch = () =>
  Effect.gen(function* () {
    const storage = yield* TrieNodeStorage;
    return yield* storage.startWriteBatch();
  });

/** Flush trie node storage. */
export const flushNodeStorage = (onlyWal?: boolean) =>
  Effect.gen(function* () {
    const storage = yield* TrieNodeStorage;
    yield* storage.flush(onlyWal);
  });

/** Compact trie node storage. */
export const compactNodeStorage = () =>
  Effect.gen(function* () {
    const storage = yield* TrieNodeStorage;
    yield* storage.compact();
  });
