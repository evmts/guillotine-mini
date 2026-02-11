import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import { Hash } from "voltaire-effect/primitives";
import type { EncodedNode, TrieNode } from "./Node";
import type { BytesType } from "./Node";
import type { TrieNodePath } from "./NodeStorage";
import { TrieNodeStorage, type TrieNodeStorageError } from "./NodeStorage";
import { ReadFlags } from "../db/Db";
import { TrieNodeCodec, TrieNodeCodecError } from "./NodeCodec";
import { encodeRlp as encodeRlpGeneric } from "./internal/rlp";
import { coerceEffect } from "./internal/effect";
import { EMPTY_TRIE_ROOT } from "./root";

/** Error raised when loading trie nodes via storage + codec fails. */
export class TrieNodeLoaderError extends Data.TaggedError(
  "TrieNodeLoaderError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

const wrapStorageError = (cause: TrieNodeStorageError) =>
  new TrieNodeLoaderError({
    message: "Failed to load encoded trie node from storage",
    cause,
  });

const wrapCodecError = (cause: TrieNodeCodecError) =>
  new TrieNodeLoaderError({
    message: "Failed to decode loaded trie node",
    cause,
  });

const wrapRlpEncodeError = (cause: unknown) =>
  new TrieNodeLoaderError({
    message: "Failed to RLP-encode inline node",
    cause,
  });

import { makeBytesHelpers } from "./internal/primitives";

const { bytesFromUint8Array } = makeBytesHelpers(
  (message) => new TrieNodeLoaderError({ message }),
);

const isEmptyTrieRoot = (hash: Hash.HashType) =>
  Hash.equals(hash, EMPTY_TRIE_ROOT);

const encodeRlp = (
  data: Parameters<typeof import("voltaire-effect/primitives").Rlp.encode>[0],
) =>
  encodeRlpGeneric(data).pipe(
    Effect.map((u8) => bytesFromUint8Array(u8)),
    Effect.mapError(wrapRlpEncodeError),
  );

const decodeBytes = (codec: typeof TrieNodeCodec.Type, encoded: BytesType) =>
  coerceEffect<TrieNode, TrieNodeCodecError>(codec.decode(encoded)).pipe(
    Effect.mapError(wrapCodecError),
  );

/** Trie node loader service interface. */
export interface TrieNodeLoaderService {
  /**
   * Resolve an encoded node reference into a concrete trie node or null.
   * - `raw` → decode inline RLP
   * - `hash` → fetch encoded bytes from storage (supports hash/half-path schemes) and decode
   * - `empty` → null
   */
  readonly load: (
    addressHash: Hash.HashType | null,
    path: TrieNodePath,
    ref: EncodedNode,
    readFlags?: ReadFlags,
  ) => Effect.Effect<TrieNode | null, TrieNodeLoaderError>;
}

/** Context tag for trie node loading. */
export class TrieNodeLoader extends Context.Tag("TrieNodeLoader")<
  TrieNodeLoader,
  TrieNodeLoaderService
>() {}

const makeTrieNodeLoader = (
  storage: typeof TrieNodeStorage.Type,
  codec: typeof TrieNodeCodec.Type,
) =>
  ({
    load: (
      addressHash: Hash.HashType | null,
      path: TrieNodePath,
      ref: EncodedNode,
      readFlags: ReadFlags = ReadFlags.None,
    ) =>
      Effect.gen(function* () {
        switch (ref._tag) {
          case "empty":
            return null;
          case "raw": {
            if (ref.encoded !== undefined) {
              return yield* decodeBytes(codec, ref.encoded);
            }
            const encoded = yield* encodeRlp(ref.value);
            return yield* decodeBytes(codec, encoded);
          }
          case "hash": {
            if (isEmptyTrieRoot(ref.value)) {
              return null;
            }

            const loaded = yield* storage
              .get(addressHash, path, ref.value, readFlags)
              .pipe(Effect.mapError(wrapStorageError));

            if (Option.isNone(loaded)) {
              return null;
            }

            return yield* decodeBytes(codec, loaded.value);
          }
        }
      }),
  }) satisfies TrieNodeLoaderService;

const TrieNodeLoaderLayer = Layer.effect(
  TrieNodeLoader,
  Effect.gen(function* () {
    const storage = yield* TrieNodeStorage;
    const codec = yield* TrieNodeCodec;
    return makeTrieNodeLoader(storage, codec);
  }),
);

/** Production trie node loader layer. */
export const TrieNodeLoaderLive: Layer.Layer<
  TrieNodeLoader,
  never,
  TrieNodeStorage | TrieNodeCodec
> = TrieNodeLoaderLayer;

/** Deterministic trie node loader layer for tests. */
export const TrieNodeLoaderTest: Layer.Layer<
  TrieNodeLoader,
  never,
  TrieNodeStorage | TrieNodeCodec
> = TrieNodeLoaderLayer;

/** Resolve an encoded node reference into a concrete trie node or null. */
export const loadTrieNode = (
  addressHash: Hash.HashType | null,
  path: TrieNodePath,
  ref: EncodedNode,
  readFlags?: ReadFlags,
) =>
  Effect.gen(function* () {
    const loader = yield* TrieNodeLoader;
    return yield* loader.load(addressHash, path, ref, readFlags);
  });
