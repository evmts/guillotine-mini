import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import { Bytes, Hex } from "voltaire-effect/primitives";
import type { BytesType, HashType } from "./Node";
import { TrieRoot, type TrieRootError } from "./root";

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

interface TrieStoreService {
  readonly get: (
    key: BytesType,
  ) => Effect.Effect<TrieEntry | undefined, TrieError>;
  readonly put: (entry: TrieEntry) => Effect.Effect<void, TrieError>;
  readonly remove: (key: BytesType) => Effect.Effect<void, TrieError>;
  readonly entries: () => Effect.Effect<ReadonlyArray<TrieEntry>, never>;
}

class TrieStore extends Context.Tag("TrieStore")<
  TrieStore,
  TrieStoreService
>() {}

const cloneBytes = (value: BytesType): BytesType => Bytes.concat(value);

const cloneEntry = (entry: TrieEntry): TrieEntry => ({
  key: cloneBytes(entry.key),
  value: cloneBytes(entry.value),
});

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

const makeTrieStore = () =>
  Effect.gen(function* () {
    const store = yield* Effect.acquireRelease(
      Effect.sync(() => new Map<string, TrieEntry>()),
      (map) =>
        Effect.sync(() => {
          map.clear();
        }),
    );

    const get = (key: BytesType) =>
      Effect.gen(function* () {
        const keyHex = yield* encodeKey(key);
        const entry = store.get(keyHex);
        return entry ? cloneEntry(entry) : undefined;
      });

    const put = (entry: TrieEntry) =>
      Effect.gen(function* () {
        const keyHex = yield* encodeKey(entry.key);
        store.set(keyHex, cloneEntry(entry));
      });

    const remove = (key: BytesType) =>
      Effect.gen(function* () {
        const keyHex = yield* encodeKey(key);
        store.delete(keyHex);
      });

    const entries = () =>
      Effect.sync(() => Array.from(store.values(), cloneEntry));

    return {
      get,
      put,
      remove,
      entries,
    } satisfies TrieStoreService;
  });

const TrieStoreMemoryLayer = Layer.scoped(TrieStore, makeTrieStore());

const makeTrie = (config?: TrieConfig) =>
  Effect.gen(function* () {
    const trieRoot = yield* TrieRoot;
    const trieStore = yield* TrieStore;
    const secured = config?.secured ?? false;
    const configuredDefault = config?.defaultValue;

    const resolveDefault = () =>
      configuredDefault === undefined
        ? Effect.succeed(EmptyBytes)
        : Bytes.isBytes(configuredDefault)
          ? Effect.succeed(configuredDefault)
          : Effect.fail(invalidDefaultError());

    const get = (key: BytesType) =>
      Effect.gen(function* () {
        const entry = yield* trieStore.get(key);
        if (entry) {
          return entry.value;
        }
        const defaultValue = yield* resolveDefault();
        return cloneBytes(defaultValue);
      });

    const put = (key: BytesType, value: BytesType) =>
      Effect.gen(function* () {
        const validatedValue = yield* validateValue(value);
        const defaultValue = yield* resolveDefault();
        if (Bytes.equals(validatedValue, defaultValue)) {
          yield* trieStore.remove(key);
          return;
        }
        yield* trieStore.put({ key, value: validatedValue });
      });

    const remove = (key: BytesType) =>
      Effect.gen(function* () {
        yield* trieStore.remove(key);
      });

    const root = () =>
      Effect.gen(function* () {
        const entries = yield* trieStore.entries();
        return yield* trieRoot.root(entries, { secured });
      });

    return { get, put, remove, root } satisfies TrieService;
  });

const TrieLayer = (config?: TrieConfig) => Layer.effect(Trie, makeTrie(config));

/** In-memory trie layer backed by a scoped store. */
export const TrieMemoryLive = (
  config: TrieConfig = {},
): Layer.Layer<Trie, never, TrieRoot> =>
  TrieLayer(config).pipe(Layer.provide(TrieStoreMemoryLayer));

/** Deterministic in-memory trie layer for tests. */
export const TrieMemoryTest = (
  config: TrieConfig = {},
): Layer.Layer<Trie, never, TrieRoot> => TrieMemoryLive(config);

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
