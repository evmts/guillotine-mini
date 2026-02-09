import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import * as Layer from "effect/Layer";
import { Hash, Rlp } from "voltaire-effect/primitives";
import type {
  BytesType,
  EncodedNode,
  HashType,
  NibbleList,
  TrieNode,
} from "./Node";
import { bytesToNibbleList } from "./encoding";
import { TrieHash, type TrieHashError } from "./hash";
import { TriePatricialize, type PatricializeError } from "./patricialize";
import { coerceEffect } from "./internal/effect";
import { makeBytesHelpers, makeHashHelpers } from "./internal/primitives";

/** Error raised when computing trie roots. */
export class TrieRootError extends Data.TaggedError("TrieRootError")<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Trie root input entry. */
export interface TrieRootEntry {
  readonly key: BytesType;
  readonly value: BytesType;
}

/** Trie root configuration options. */
export interface TrieRootOptions {
  /** When true, hash keys with keccak256 before nibble expansion. */
  readonly secured?: boolean;
}

/** Trie root computation service interface. */
export interface TrieRootService {
  readonly root: (
    entries: ReadonlyArray<TrieRootEntry>,
    options?: TrieRootOptions,
  ) => Effect.Effect<HashType, TrieRootError>;
}

const { bytesFromUint8Array } = makeBytesHelpers(
  (message) => new TrieRootError({ message }),
);
const { hashFromHex } = makeHashHelpers(
  (message) => new TrieRootError({ message }),
);

/** Keccak-256 hash of the empty trie root (keccak256(rlp.encode(b""))). */
export const EMPTY_TRIE_ROOT: HashType = hashFromHex(
  "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
);

const wrapTrieHashError = (cause: TrieHashError) =>
  new TrieRootError({
    message: "Failed to encode trie node",
    cause,
  });

const wrapPatricializeError = (cause: PatricializeError) =>
  new TrieRootError({
    message: "Failed to patricialize trie",
    cause,
  });

const wrapRlpError = (cause: unknown) =>
  new TrieRootError({
    message: "Failed to RLP-encode trie root",
    cause,
  });

const wrapBytesError = (cause: unknown) =>
  new TrieRootError({
    message: "Invalid trie bytes input",
    cause,
  });

const encodeRlp = (data: Parameters<typeof Rlp.encode>[0]) =>
  coerceEffect<Uint8Array, unknown>(Rlp.encode(data)).pipe(
    Effect.mapError(wrapRlpError),
  );

const keccak256 = (data: Uint8Array) =>
  coerceEffect<HashType, never>(Hash.keccak256(data));

const toBytes = (value: Uint8Array): Effect.Effect<BytesType, TrieRootError> =>
  Effect.try({
    try: () => bytesFromUint8Array(value),
    catch: (cause) => wrapBytesError(cause),
  });

const encodedNodeToRoot = (
  encoded: EncodedNode,
): Effect.Effect<HashType, TrieRootError> =>
  Effect.gen(function* () {
    switch (encoded._tag) {
      case "hash":
        return encoded.value;
      case "raw": {
        const encodedBytes = yield* encodeRlp(encoded.value);
        return yield* keccak256(encodedBytes);
      }
      case "empty":
        return EMPTY_TRIE_ROOT;
    }
  });

const buildNibbleMap = (
  entries: ReadonlyArray<TrieRootEntry>,
  secured: boolean,
): Effect.Effect<Map<NibbleList, BytesType>, TrieRootError> =>
  Effect.gen(function* () {
    const map = new Map<NibbleList, BytesType>();
    for (const entry of entries) {
      const keyBytes = secured
        ? yield* pipe(keccak256(entry.key), Effect.flatMap(toBytes))
        : entry.key;
      const nibbleKey = yield* bytesToNibbleList(keyBytes);
      map.set(nibbleKey, entry.value);
    }
    return map;
  });

const makeTrieRoot = (
  patricialize: (
    obj: ReadonlyMap<NibbleList, BytesType>,
    level: number,
  ) => Effect.Effect<TrieNode | null, PatricializeError>,
  encodeInternalNode: (
    node: TrieNode | null | undefined,
  ) => Effect.Effect<EncodedNode, TrieHashError>,
) =>
  ({
    root: (entries: ReadonlyArray<TrieRootEntry>, options?: TrieRootOptions) =>
      Effect.gen(function* () {
        const secured = options?.secured ?? false;
        const nibbleMap = yield* buildNibbleMap(entries, secured);
        const node = yield* pipe(
          patricialize(nibbleMap, 0),
          Effect.mapError(wrapPatricializeError),
        );
        const encoded = yield* pipe(
          encodeInternalNode(node),
          Effect.mapError(wrapTrieHashError),
        );
        return yield* encodedNodeToRoot(encoded);
      }),
  }) satisfies TrieRootService;

/** Context tag for trie root computation. */
export class TrieRoot extends Context.Tag("TrieRoot")<
  TrieRoot,
  TrieRootService
>() {}

const TrieRootLayer = Layer.effect(
  TrieRoot,
  Effect.gen(function* () {
    const hasher = yield* TrieHash;
    const builder = yield* TriePatricialize;
    return makeTrieRoot(builder.patricialize, hasher.encodeInternalNode);
  }),
);

/** Production trie root layer. */
export const TrieRootLive: Layer.Layer<
  TrieRoot,
  never,
  TrieHash | TriePatricialize
> = TrieRootLayer;

/** Deterministic trie root layer for tests. */
export const TrieRootTest: Layer.Layer<
  TrieRoot,
  never,
  TrieHash | TriePatricialize
> = TrieRootLayer;

/** Compute the MPT root hash for a set of entries. */
export const trieRoot = (
  entries: ReadonlyArray<TrieRootEntry>,
  options?: TrieRootOptions,
) =>
  Effect.gen(function* () {
    const service = yield* TrieRoot;
    return yield* service.root(entries, options);
  });
