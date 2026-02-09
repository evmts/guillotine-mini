import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import * as Scope from "effect/Scope";
import * as Schema from "effect/Schema";
import { Bytes, Hex } from "voltaire-effect/primitives";

export type BytesType = ReturnType<typeof Bytes.random>;

export const DbNames = {
  storage: "storage",
  state: "state",
  code: "code",
  blocks: "blocks",
  headers: "headers",
  blockNumbers: "blockNumbers",
  receipts: "receipts",
  blockInfos: "blockInfos",
  badBlocks: "badBlocks",
  bloom: "bloom",
  metadata: "metadata",
  blobTransactions: "blobTransactions",
  discoveryNodes: "discoveryNodes",
  discoveryV5Nodes: "discoveryV5Nodes",
  peers: "peers",
} as const;

export const DbNameSchema = Schema.Union(
  Schema.Literal(DbNames.storage),
  Schema.Literal(DbNames.state),
  Schema.Literal(DbNames.code),
  Schema.Literal(DbNames.blocks),
  Schema.Literal(DbNames.headers),
  Schema.Literal(DbNames.blockNumbers),
  Schema.Literal(DbNames.receipts),
  Schema.Literal(DbNames.blockInfos),
  Schema.Literal(DbNames.badBlocks),
  Schema.Literal(DbNames.bloom),
  Schema.Literal(DbNames.metadata),
  Schema.Literal(DbNames.blobTransactions),
  Schema.Literal(DbNames.discoveryNodes),
  Schema.Literal(DbNames.discoveryV5Nodes),
  Schema.Literal(DbNames.peers),
);

export type DbName = Schema.Schema.Type<typeof DbNameSchema>;

/** Configuration for a DB layer. */
export interface DbConfig {
  readonly name: DbName;
}

/** Schema for validating DB configuration at boundaries. */
export const DbConfigSchema = Schema.Struct({
  name: DbNameSchema,
});

/** Error raised by DB operations. */
export class DbError extends Data.TaggedError("DbError")<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Batched write operations. */
export interface WriteBatch {
  readonly put: (
    key: BytesType,
    value: BytesType,
  ) => Effect.Effect<void, DbError>;
  readonly remove: (key: BytesType) => Effect.Effect<void, DbError>;
  readonly clear: () => Effect.Effect<void, DbError>;
}

/** Key-value DB abstraction. */
export interface DbService {
  readonly name: string;
  readonly get: (
    key: BytesType,
  ) => Effect.Effect<Option.Option<BytesType>, DbError>;
  readonly put: (
    key: BytesType,
    value: BytesType,
  ) => Effect.Effect<void, DbError>;
  readonly remove: (key: BytesType) => Effect.Effect<void, DbError>;
  readonly has: (key: BytesType) => Effect.Effect<boolean, DbError>;
  readonly startWriteBatch: () => Effect.Effect<
    WriteBatch,
    DbError,
    Scope.Scope
  >;
}

/** Context tag for the DB service. */
export class Db extends Context.Tag("Db")<Db, DbService>() {}

const validateConfig = (config: DbConfig): Effect.Effect<DbConfig, DbError> =>
  Effect.try({
    try: () => Schema.decodeSync(DbConfigSchema)(config),
    catch: (cause) => new DbError({ message: "Invalid DbConfig", cause }),
  });

const encodeKey = (key: BytesType): Effect.Effect<string, DbError> =>
  Effect.try({
    try: () => Hex.fromBytes(key),
    catch: (cause) => new DbError({ message: "Invalid DB key", cause }),
  });

const cloneBytes = (value: BytesType): BytesType => value.slice() as BytesType;

const makeMemoryDb = (config: DbConfig) =>
  Effect.gen(function* () {
    const validated = yield* validateConfig(config);
    const store = yield* Effect.acquireRelease(
      Effect.sync(() => new Map<string, BytesType>()),
      (map) => Effect.sync(() => map.clear()),
    );

    const get = (key: BytesType) =>
      Effect.gen(function* () {
        const keyHex = yield* encodeKey(key);
        const value = store.get(keyHex);
        return pipe(Option.fromNullable(value), Option.map(cloneBytes));
      });

    const put = (key: BytesType, value: BytesType) =>
      Effect.gen(function* () {
        const keyHex = yield* encodeKey(key);
        store.set(keyHex, cloneBytes(value));
      });

    const remove = (key: BytesType) =>
      Effect.gen(function* () {
        const keyHex = yield* encodeKey(key);
        store.delete(keyHex);
      });

    const has = (key: BytesType) =>
      Effect.gen(function* () {
        const keyHex = yield* encodeKey(key);
        return store.has(keyHex);
      });

    const startWriteBatch = () =>
      pipe(
        Effect.acquireRelease(
          Effect.sync(() => new Map<string, BytesType | null>()),
          (pending) =>
            Effect.sync(() => {
              for (const [keyHex, value] of pending.entries()) {
                if (value === null) {
                  store.delete(keyHex);
                } else {
                  store.set(keyHex, cloneBytes(value));
                }
              }
              pending.clear();
            }),
        ),
        Effect.map((pending) => {
          const put = (key: BytesType, value: BytesType) =>
            Effect.gen(function* () {
              const keyHex = yield* encodeKey(key);
              pending.set(keyHex, cloneBytes(value));
            });

          const remove = (key: BytesType) =>
            Effect.gen(function* () {
              const keyHex = yield* encodeKey(key);
              pending.set(keyHex, null);
            });

          const clear = () =>
            Effect.try({
              try: () => pending.clear(),
              catch: (cause) =>
                new DbError({ message: "Failed to clear write batch", cause }),
            });

          return {
            put,
            remove,
            clear,
          } satisfies WriteBatch;
        }),
      );

    return {
      name: validated.name,
      get,
      put,
      remove,
      has,
      startWriteBatch,
    } satisfies DbService;
  });

/** In-memory production DB layer. */
export const DbMemoryLive = (config: DbConfig): Layer.Layer<Db, DbError> =>
  Layer.scoped(Db, makeMemoryDb(config));

/** In-memory deterministic DB layer for tests. */
export const DbMemoryTest = (
  config: DbConfig = { name: DbNames.state },
): Layer.Layer<Db, DbError> => Layer.scoped(Db, makeMemoryDb(config));

/** Retrieve a value by key. */
export const get = (key: BytesType) =>
  Effect.gen(function* () {
    const db = yield* Db;
    return yield* db.get(key);
  });

/** Store a value by key. */
export const put = (key: BytesType, value: BytesType) =>
  Effect.gen(function* () {
    const db = yield* Db;
    yield* db.put(key, value);
  });

/** Remove a value by key. */
export const remove = (key: BytesType) =>
  Effect.gen(function* () {
    const db = yield* Db;
    yield* db.remove(key);
  });

/** Check whether a key exists. */
export const has = (key: BytesType) =>
  Effect.gen(function* () {
    const db = yield* Db;
    return yield* db.has(key);
  });

/** Start a write batch scope. */
export const startWriteBatch = () =>
  Effect.gen(function* () {
    const db = yield* Db;
    return yield* db.startWriteBatch();
  });
