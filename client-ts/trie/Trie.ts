import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import { Bytes, Hex } from "voltaire-effect/primitives";
import type { BytesType, HashType } from "./Node";
import { TrieRoot, type TrieRootError, type TrieRootEntry } from "./root";

/** Error raised when trie operations fail. */
export class TrieError extends Data.TaggedError("TrieError")<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Configuration for an in-memory trie. */
export interface TrieConfig {
  /** When true, hash keys with keccak256 before nibble expansion. */
  readonly secured?: boolean;
  /** Default value omitted from the trie (e.g. 0 for storage, null for accounts). */
  readonly defaultValue?: BytesType;
}

/** In-memory trie service interface. */
export interface TrieService {
  readonly get: (key: BytesType) => Effect.Effect<BytesType, TrieError>;
  readonly put: (
    key: BytesType,
    value: BytesType,
  ) => Effect.Effect<void, TrieError>;
  readonly remove: (key: BytesType) => Effect.Effect<void, TrieError>;
  readonly root: () => Effect.Effect<HashType, TrieRootError>;
}

/** Context tag for the trie service. */
export class Trie extends Context.Tag("Trie")<Trie, TrieService>() {}

type TrieEntry = {
  readonly key: BytesType;
  readonly value: BytesType;
};

const cloneBytes = (value: BytesType): BytesType =>
  (value as Uint8Array).slice() as BytesType;

const EmptyBytes = Hex.toBytes("0x") as BytesType;

const invalidKeyError = (cause?: unknown) =>
  new TrieError({
    message: "Invalid trie key",
    cause,
  });

const invalidValueError = (cause?: unknown) =>
  new TrieError({
    message: "Invalid trie value",
    cause,
  });

const invalidDefaultError = (cause?: unknown) =>
  new TrieError({
    message: "Invalid trie default value",
    cause,
  });

const encodeKey = (key: BytesType): Effect.Effect<string, TrieError> =>
  Bytes.isBytes(key)
    ? Effect.try({
        try: () => Hex.fromBytes(key),
        catch: (cause) => invalidKeyError(cause),
      })
    : Effect.fail(invalidKeyError());

const validateValue = (
  value: BytesType,
): Effect.Effect<BytesType, TrieError> =>
  Bytes.isBytes(value)
    ? Effect.succeed(value)
    : Effect.fail(invalidValueError());

const makeTrie = (config?: TrieConfig) =>
  Effect.gen(function* () {
    const trieRoot = yield* TrieRoot;
    const secured = config?.secured ?? false;
    const configuredDefault = config?.defaultValue;
    const store = yield* Effect.acquireRelease(
      Effect.sync(() => new Map<string, TrieEntry>()),
      (map) =>
        Effect.sync(() => {
          map.clear();
        }),
    );

    const resolveDefault = () =>
      configuredDefault === undefined
        ? Effect.succeed(EmptyBytes)
        : Bytes.isBytes(configuredDefault)
          ? Effect.succeed(configuredDefault)
          : Effect.fail(invalidDefaultError());

    const get = (key: BytesType) =>
      Effect.gen(function* () {
        const keyHex = yield* encodeKey(key);
        const entry = store.get(keyHex);
        if (entry) {
          return cloneBytes(entry.value);
        }
        const defaultValue = yield* resolveDefault();
        return cloneBytes(defaultValue);
      });

    const put = (key: BytesType, value: BytesType) =>
      Effect.gen(function* () {
        const keyHex = yield* encodeKey(key);
        const validatedValue = yield* validateValue(value);
        const defaultValue = yield* resolveDefault();
        if (Bytes.equals(validatedValue, defaultValue)) {
          store.delete(keyHex);
          return;
        }
        store.set(keyHex, {
          key: cloneBytes(key),
          value: cloneBytes(validatedValue),
        });
      });

    const remove = (key: BytesType) =>
      Effect.gen(function* () {
        const keyHex = yield* encodeKey(key);
        store.delete(keyHex);
      });

    const root = () =>
      Effect.gen(function* () {
        const entries: Array<TrieRootEntry> = [];
        for (const entry of store.values()) {
          entries.push({
            key: cloneBytes(entry.key),
            value: cloneBytes(entry.value),
          });
        }
        return yield* trieRoot.root(entries, { secured });
      });

    return { get, put, remove, root } satisfies TrieService;
  });

/** In-memory production trie layer. */
export const TrieMemoryLive = (
  config: TrieConfig = {},
): Layer.Layer<Trie, TrieError, TrieRoot> =>
  Layer.scoped(Trie, makeTrie(config));

/** Deterministic in-memory trie layer for tests. */
export const TrieMemoryTest = (
  config: TrieConfig = {},
): Layer.Layer<Trie, TrieError, TrieRoot> => TrieMemoryLive(config);

/** Retrieve a value by key. */
export const get = (key: BytesType) =>
  Effect.gen(function* () {
    const trie = yield* Trie;
    return yield* trie.get(key);
  });

/** Store a value by key (default values delete the key). */
export const put = (key: BytesType, value: BytesType) =>
  Effect.gen(function* () {
    const trie = yield* Trie;
    yield* trie.put(key, value);
  });

/** Remove a value by key. */
export const remove = (key: BytesType) =>
  Effect.gen(function* () {
    const trie = yield* Trie;
    yield* trie.remove(key);
  });

/** Compute the trie root hash for current entries. */
export const root = () =>
  Effect.gen(function* () {
    const trie = yield* Trie;
    return yield* trie.root();
  });
