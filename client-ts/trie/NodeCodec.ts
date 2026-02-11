import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import { Bytes, Rlp } from "voltaire-effect/primitives";
import type {
  BytesType,
  EncodedNode,
  NibbleList,
  RlpType,
  TrieNode,
} from "./Node";
import { NibbleEncodingError, compactToNibbleList } from "./encoding";
import { coerceEffect } from "./internal/effect";
import { makeBytesHelpers } from "./internal/primitives";

/** Error raised when decoding a trie node from RLP fails. */
export class TrieNodeCodecError extends Data.TaggedError("TrieNodeCodecError")<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

const { bytesFromUint8Array } = makeBytesHelpers(
  (message) => new TrieNodeCodecError({ message }),
);

const wrapNibbleError = (cause: NibbleEncodingError) =>
  new TrieNodeCodecError({
    message: "Failed to decode hex-prefix compact path",
    cause,
  });

const wrapRlpDecodeError = (cause: unknown) =>
  new TrieNodeCodecError({ message: "Failed to RLP-decode trie node", cause });

const invalidTopLevelError = (cause?: unknown) =>
  new TrieNodeCodecError({ message: "Invalid top-level trie node", cause });

const invalidBranchArityError = (length: number) =>
  new TrieNodeCodecError({
    message: `Branch node must contain 16 children + value, received ${length}`,
  });

const invalidRlpItemError = (message: string) =>
  new TrieNodeCodecError({ message });

const toBytes = (value: Uint8Array): BytesType => bytesFromUint8Array(value);

const decodeRlp = (encoded: BytesType) =>
  coerceEffect<{ data: RlpType; remainder: Uint8Array }, unknown>(
    Rlp.decode(encoded),
  ).pipe(Effect.mapError(wrapRlpDecodeError));

/** Decode an encoded node reference (hash/raw/empty) from an RLP item. */
const decodeEncodedNodeRef = (
  item: RlpType,
): Effect.Effect<EncodedNode, TrieNodeCodecError> =>
  Effect.gen(function* () {
    if (item.type === "bytes") {
      const value = item.value;
      if (value.length === 0) {
        return { _tag: "empty" } as const satisfies EncodedNode;
      }
      if (value.length === 32) {
        return {
          _tag: "hash",
          value: toBytes(value),
        } as const satisfies EncodedNode;
      }
      return yield* Effect.fail(
        invalidRlpItemError(
          `Invalid child reference byte length ${value.length} (expected 0 or 32)`,
        ),
      );
    }

    if (item.type === "list") {
      return { _tag: "raw", value: item } as const satisfies EncodedNode;
    }

    return yield* Effect.fail(invalidRlpItemError("Unsupported RLP item type"));
  });

/** Decode a trie node (leaf/extension/branch) from its RLP-encoded bytes. */
const decodeTrieNodeImpl = (
  encoded: BytesType,
): Effect.Effect<TrieNode, TrieNodeCodecError> =>
  Effect.gen(function* () {
    const { data, remainder } = yield* decodeRlp(encoded);
    if (remainder.length !== 0) {
      return yield* Effect.fail(
        invalidTopLevelError(new Error("Unexpected RLP remainder")),
      );
    }

    if (data.type !== "list") {
      return yield* Effect.fail(
        invalidTopLevelError(new Error("Top-level trie node must be a list")),
      );
    }

    const items = data.value;
    if (items.length === 2) {
      const [compact, second] = items;
      if (compact.type !== "bytes") {
        return yield* Effect.fail(
          invalidRlpItemError(
            "Compact path for leaf/extension must be byte string",
          ),
        );
      }

      const decoded = yield* compactToNibbleList(toBytes(compact.value)).pipe(
        Effect.mapError(wrapNibbleError),
      );

      if (decoded.isLeaf) {
        if (second.type !== "bytes") {
          return yield* Effect.fail(
            invalidRlpItemError("Leaf value must be byte string"),
          );
        }
        return {
          _tag: "leaf",
          restOfKey: toBytes(decoded.nibbles),
          value: toBytes(second.value),
        } as const;
      }

      const subnode = yield* decodeEncodedNodeRef(second);
      return {
        _tag: "extension",
        keySegment: toBytes(decoded.nibbles),
        subnode,
      } as const;
    }

    if (items.length === 17) {
      const subnodes: Array<EncodedNode> = [];
      for (let i = 0; i < 16; i += 1) {
        const child = items[i];
        if (child === undefined) {
          return yield* Effect.fail(invalidBranchArityError(items.length));
        }
        subnodes.push(yield* decodeEncodedNodeRef(child));
      }
      const valueItem = items[16];
      if (valueItem === undefined || valueItem.type !== "bytes") {
        return yield* Effect.fail(
          invalidRlpItemError("Branch value must be byte string"),
        );
      }
      return {
        _tag: "branch",
        subnodes,
        value: toBytes(valueItem.value),
      } as const;
    }

    return yield* Effect.fail(invalidBranchArityError(items.length));
  });

/** Trie node codec service interface. */
export interface TrieNodeCodecService {
  readonly decode: (
    encoded: BytesType,
  ) => Effect.Effect<TrieNode, TrieNodeCodecError>;
}

/** Context tag for trie node codec. */
export class TrieNodeCodec extends Context.Tag("TrieNodeCodec")<
  TrieNodeCodec,
  TrieNodeCodecService
>() {}

const TrieNodeCodecLayer: Layer.Layer<TrieNodeCodec> = Layer.succeed(
  TrieNodeCodec,
  { decode: decodeTrieNodeImpl } satisfies TrieNodeCodecService,
);

/** Production trie node codec layer. */
export const TrieNodeCodecLive: Layer.Layer<TrieNodeCodec> = TrieNodeCodecLayer;

/** Deterministic trie node codec layer for tests. */
export const TrieNodeCodecTest: Layer.Layer<TrieNodeCodec> = TrieNodeCodecLayer;

/** Decode a trie node from RLP bytes. */
export const decodeTrieNode = (encoded: BytesType) =>
  Effect.gen(function* () {
    const codec = yield* TrieNodeCodec;
    return yield* codec.decode(encoded);
  });
