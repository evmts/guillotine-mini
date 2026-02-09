import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";
import { Hex } from "voltaire-effect/primitives";
import type { BytesType, EncodedNode, NibbleList, TrieNode } from "./Node";
import { BranchChildrenCount } from "./Node";
import { NibbleListSchema } from "./encoding";
import type { TrieHashError } from "./hash";
import { TrieHash } from "./hash";
import { makeBytesHelpers } from "./internal/primitives";

/** Map of nibble-encoded keys to raw values. */
export type NibbleKeyMap = ReadonlyMap<NibbleList, BytesType>;

/** Error raised when patricialization fails. */
export class PatricializeError extends Data.TaggedError("PatricializeError")<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

const { bytesFromHex, bytesFromUint8Array } = makeBytesHelpers(
  (message) => new PatricializeError({ message }),
);

const EmptyBytes = bytesFromHex("0x");

/** Compute the shared prefix length for two nibble lists. */
export const commonPrefixLength = (a: Uint8Array, b: Uint8Array): number => {
  const limit = Math.min(a.length, b.length);
  for (let i = 0; i < limit; i += 1) {
    if (a[i] !== b[i]) {
      return i;
    }
  }
  return limit;
};

const invalidLevelError = (level: number) =>
  new PatricializeError({
    message: `Trie level must be a non-negative integer, received ${level}`,
  });

const invalidKeyLengthError = (keyLength: number, level: number) =>
  new PatricializeError({
    message: `Trie key length ${keyLength} is shorter than level ${level}`,
  });

const invalidNibbleError = (nibble: number) =>
  new PatricializeError({
    message: `Invalid nibble value ${nibble}`,
  });

const missingBranchError = (index: number) =>
  new PatricializeError({
    message: `Missing branch at index ${index}`,
  });

const wrapHashError = (cause: TrieHashError) =>
  new PatricializeError({
    message: "Failed to encode internal trie node",
    cause,
  });

const validateLevel = (
  level: number,
): Effect.Effect<number, PatricializeError> =>
  Number.isInteger(level) && level >= 0
    ? Effect.succeed(level)
    : Effect.fail(invalidLevelError(level));

const validateNibbleList = (
  nibbles: NibbleList,
): Effect.Effect<NibbleList, PatricializeError> =>
  Schema.decode(NibbleListSchema)(nibbles).pipe(
    Effect.map((validated) => bytesFromUint8Array(validated)),
    Effect.mapError(
      (cause) =>
        new PatricializeError({
          message: "Invalid nibble list",
          cause,
        }),
    ),
  );

const normalizeKeyMap = (
  obj: NibbleKeyMap,
): Effect.Effect<Map<NibbleList, BytesType>, PatricializeError> =>
  Effect.gen(function* () {
    const deduped = new Map<string, { key: NibbleList; value: BytesType }>();
    for (const [key, value] of obj) {
      const validated = yield* validateNibbleList(key);
      deduped.set(Hex.fromBytes(validated), { key: validated, value });
    }

    const normalized = new Map<NibbleList, BytesType>();
    for (const { key, value } of deduped.values()) {
      normalized.set(key, value);
    }
    return normalized;
  });

const patricializeImpl = (
  obj: NibbleKeyMap,
  level: number,
  encodeInternalNode: (
    node: TrieNode | null | undefined,
  ) => Effect.Effect<EncodedNode, TrieHashError>,
): Effect.Effect<TrieNode | null, PatricializeError> =>
  Effect.gen(function* () {
    if (obj.size === 0) {
      return null;
    }

    const first = obj.entries().next();
    if (first.done) {
      return null;
    }

    const [arbitraryKey, arbitraryValue] = first.value;
    if (arbitraryKey.length < level) {
      return yield* Effect.fail(
        invalidKeyLengthError(arbitraryKey.length, level),
      );
    }

    if (obj.size === 1) {
      return {
        _tag: "leaf",
        restOfKey: bytesFromUint8Array(arbitraryKey.subarray(level)),
        value: arbitraryValue,
      };
    }

    const substring = arbitraryKey.subarray(level);
    let prefixLength = substring.length;
    for (const [key] of obj) {
      if (key.length < level) {
        return yield* Effect.fail(invalidKeyLengthError(key.length, level));
      }
      const candidate = commonPrefixLength(substring, key.subarray(level));
      if (candidate < prefixLength) {
        prefixLength = candidate;
      }
      if (prefixLength === 0) {
        break;
      }
    }

    const encodeSubnode = (node: TrieNode | null) =>
      pipe(encodeInternalNode(node), Effect.mapError(wrapHashError));

    if (prefixLength > 0) {
      const prefix = bytesFromUint8Array(
        arbitraryKey.subarray(level, level + prefixLength),
      );
      const subnode = yield* pipe(
        patricializeImpl(obj, level + prefixLength, encodeInternalNode),
        Effect.flatMap(encodeSubnode),
      );
      return {
        _tag: "extension",
        keySegment: prefix,
        subnode,
      };
    }

    const branches: Array<Map<NibbleList, BytesType>> = Array.from(
      { length: BranchChildrenCount },
      () => new Map<NibbleList, BytesType>(),
    );
    let value = EmptyBytes;
    for (const [key, entryValue] of obj) {
      if (key.length < level) {
        return yield* Effect.fail(invalidKeyLengthError(key.length, level));
      }
      if (key.length === level) {
        value = entryValue;
        continue;
      }
      const nibble = key[level];
      if (nibble === undefined || nibble > 0x0f) {
        return yield* Effect.fail(invalidNibbleError(nibble ?? -1));
      }
      const branch = branches[nibble];
      if (branch === undefined) {
        return yield* Effect.fail(missingBranchError(nibble));
      }
      branch.set(key, entryValue);
    }

    const subnodes: EncodedNode[] = [];
    for (let i = 0; i < BranchChildrenCount; i += 1) {
      const branch = branches[i];
      if (branch === undefined) {
        return yield* Effect.fail(missingBranchError(i));
      }
      const encoded = yield* pipe(
        patricializeImpl(branch, level + 1, encodeInternalNode),
        Effect.flatMap(encodeSubnode),
      );
      subnodes.push(encoded);
    }

    return {
      _tag: "branch",
      subnodes,
      value,
    };
  });

const makePatricialize = (
  encodeInternalNode: (
    node: TrieNode | null | undefined,
  ) => Effect.Effect<EncodedNode, TrieHashError>,
) => ({
  patricialize: (obj: NibbleKeyMap, level: number) =>
    Effect.gen(function* () {
      yield* validateLevel(level);
      const normalized = yield* normalizeKeyMap(obj);
      return yield* patricializeImpl(normalized, level, encodeInternalNode);
    }),
});

/** Trie patricialization service interface. */
export interface TriePatricializeService {
  readonly patricialize: (
    obj: NibbleKeyMap,
    level: number,
  ) => Effect.Effect<TrieNode | null, PatricializeError>;
}

/** Context tag for trie patricialization. */
export class TriePatricialize extends Context.Tag("TriePatricialize")<
  TriePatricialize,
  TriePatricializeService
>() {}

const TriePatricializeLayer = Layer.effect(
  TriePatricialize,
  Effect.gen(function* () {
    const hasher = yield* TrieHash;
    return makePatricialize(hasher.encodeInternalNode);
  }),
);

/** Production trie patricialize layer. */
export const TriePatricializeLive = TriePatricializeLayer;

/** Deterministic trie patricialize layer for tests. */
export const TriePatricializeTest = TriePatricializeLayer;

/** Build a trie node from a nibble-key map. */
export const patricialize = (obj: NibbleKeyMap, level: number) =>
  Effect.gen(function* () {
    const builder = yield* TriePatricialize;
    return yield* builder.patricialize(obj, level);
  });
