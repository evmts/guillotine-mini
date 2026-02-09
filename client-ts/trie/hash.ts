import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import * as Layer from "effect/Layer";
import * as VoltaireHash from "@tevm/voltaire/Hash";
import * as VoltaireRlp from "@tevm/voltaire/Rlp";
import type { EncodedNode, RlpType, TrieNode } from "./Node";
import { BranchChildrenCount } from "./Node";
import { NibbleEncodingError, nibbleListToCompact } from "./encoding";

type RlpItem = Uint8Array | RlpType;

const EmptyBytes = new Uint8Array(0);

/** Error raised when trie hashing fails. */
export class TrieHashError extends Data.TaggedError("TrieHashError")<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

const toRlpItem = (node: EncodedNode): RlpItem => {
  switch (node._tag) {
    case "hash":
      return node.value;
    case "raw":
      return node.value;
    case "empty":
      return EmptyBytes;
  }
};

const toBrandedRlp = (item: RlpItem): RlpType =>
  item instanceof Uint8Array ? { type: "bytes", value: item } : item;

const toRlpList = (items: ReadonlyArray<RlpItem>): RlpType => ({
  type: "list",
  value: items.map((item) => toBrandedRlp(item)),
});

const invalidBranchError = (length: number) =>
  new TrieHashError({
    message: `Branch node must contain ${BranchChildrenCount} subnodes, received ${length}`,
  });

const wrapNibbleError = (cause: NibbleEncodingError) =>
  new TrieHashError({
    message: "Failed to compact nibble list",
    cause,
  });

const wrapRlpError = (cause: unknown) =>
  new TrieHashError({
    message: "Failed to RLP-encode trie node",
    cause,
  });

const encodeRlp = (data: VoltaireRlp.Encodable) =>
  Effect.try({
    try: () => VoltaireRlp.encode(data),
    catch: (cause) => wrapRlpError(cause),
  });

const keccak256 = (data: Uint8Array) =>
  Effect.sync(() => VoltaireHash.keccak256(data));

const nodeToItems = (
  node: TrieNode,
): Effect.Effect<ReadonlyArray<RlpItem>, TrieHashError> => {
  switch (node._tag) {
    case "leaf":
      return pipe(
        nibbleListToCompact(node.restOfKey, true),
        Effect.mapError(wrapNibbleError),
        Effect.map(
          (compact) => [compact, node.value] as ReadonlyArray<RlpItem>,
        ),
      );
    case "extension":
      return pipe(
        nibbleListToCompact(node.keySegment, false),
        Effect.mapError(wrapNibbleError),
        Effect.map(
          (compact) =>
            [compact, toRlpItem(node.subnode)] as ReadonlyArray<RlpItem>,
        ),
      );
    case "branch": {
      if (node.subnodes.length !== BranchChildrenCount) {
        return Effect.fail(invalidBranchError(node.subnodes.length));
      }
      const children = node.subnodes.map((subnode) => toRlpItem(subnode));
      return Effect.succeed([
        ...children,
        node.value,
      ] as ReadonlyArray<RlpItem>);
    }
  }
};

const encodeInternalNodeImpl = (
  node: TrieNode | null | undefined,
): Effect.Effect<EncodedNode, TrieHashError> =>
  Effect.gen(function* () {
    if (node === null || node === undefined) {
      return { _tag: "empty" };
    }

    const items = yield* nodeToItems(node);
    const rlpList = toRlpList(items);
    const encoded = yield* encodeRlp(rlpList);

    if (encoded.length < 32) {
      return { _tag: "raw", value: rlpList };
    }

    const hashed = yield* keccak256(encoded);
    return {
      _tag: "hash",
      value: hashed,
    };
  });

/** Trie hashing service interface. */
export interface TrieHashService {
  readonly encodeInternalNode: (
    node: TrieNode | null | undefined,
  ) => Effect.Effect<EncodedNode, TrieHashError>;
}

/** Context tag for trie hashing. */
export class TrieHash extends Context.Tag("TrieHash")<
  TrieHash,
  TrieHashService
>() {}

const TrieHashLayer: Layer.Layer<TrieHash> = Layer.succeed(TrieHash, {
  encodeInternalNode: (node) => encodeInternalNodeImpl(node),
});

/** Production trie hashing layer. */
export const TrieHashLive: Layer.Layer<TrieHash> = TrieHashLayer;

/** Deterministic trie hashing layer for tests. */
export const TrieHashTest: Layer.Layer<TrieHash> = TrieHashLayer;

/** Encode an internal trie node reference (inline or hash). */
export const encodeInternalNode = (node: TrieNode | null | undefined) =>
  Effect.gen(function* () {
    const hasher = yield* TrieHash;
    return yield* hasher.encodeInternalNode(node);
  });
