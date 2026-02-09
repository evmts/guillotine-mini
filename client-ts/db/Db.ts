import * as Context from "effect/Context"
import * as Data from "effect/Data"
import * as Effect from "effect/Effect"
import { pipe } from "effect/Function"
import * as Layer from "effect/Layer"
import * as Option from "effect/Option"
import * as Schema from "effect/Schema"
import * as Bytes from "voltaire-effect/primitives/Bytes"

/** Configuration for a DB layer. */
export interface DbConfig {
  readonly name: string
}

/** Schema for validating DB configuration at boundaries. */
export const DbConfigSchema = Schema.Struct({
  name: Schema.NonEmptyString
})

/** Error raised by DB operations. */
export class DbError extends Data.TaggedError("DbError")<{
  readonly message: string
  readonly cause?: unknown
}> {}

/** Key-value DB abstraction. */
export interface DbService {
  readonly name: string
  readonly get: (
    key: Bytes.BytesType
  ) => Effect.Effect<Option.Option<Bytes.BytesType>, DbError>
  readonly put: (
    key: Bytes.BytesType,
    value: Bytes.BytesType
  ) => Effect.Effect<void, DbError>
  readonly remove: (key: Bytes.BytesType) => Effect.Effect<void, DbError>
  readonly has: (key: Bytes.BytesType) => Effect.Effect<boolean, DbError>
}

/** Context tag for the DB service. */
export class Db extends Context.Tag("Db")<Db, DbService>() {}

const validateConfig = (config: DbConfig): Effect.Effect<DbConfig, DbError> =>
  Effect.try({
    try: () => Schema.decodeSync(DbConfigSchema)(config),
    catch: (cause) => new DbError({ message: "Invalid DbConfig", cause })
  })

const encodeKey = (key: Bytes.BytesType): Effect.Effect<string, DbError> =>
  Effect.try({
    try: () => Schema.encodeSync(Bytes.Hex)(key),
    catch: (cause) => new DbError({ message: "Invalid DB key", cause })
  })

const cloneBytes = (value: Bytes.BytesType): Bytes.BytesType => value.slice()

const makeMemoryDb = (config: DbConfig) =>
  Effect.gen(function* () {
    const validated = yield* validateConfig(config)
    const store = yield* Effect.acquireRelease(
      Effect.sync(() => new Map<string, Bytes.BytesType>()),
      (map) => Effect.sync(() => map.clear())
    )

    const get = (key: Bytes.BytesType) =>
      Effect.gen(function* () {
        const keyHex = yield* encodeKey(key)
        const value = store.get(keyHex)
        return pipe(Option.fromNullable(value), Option.map(cloneBytes))
      })

    const put = (key: Bytes.BytesType, value: Bytes.BytesType) =>
      Effect.gen(function* () {
        const keyHex = yield* encodeKey(key)
        store.set(keyHex, cloneBytes(value))
      })

    const remove = (key: Bytes.BytesType) =>
      Effect.gen(function* () {
        const keyHex = yield* encodeKey(key)
        store.delete(keyHex)
      })

    const has = (key: Bytes.BytesType) =>
      Effect.gen(function* () {
        const keyHex = yield* encodeKey(key)
        return store.has(keyHex)
      })

    return {
      name: validated.name,
      get,
      put,
      remove,
      has
    } satisfies DbService
  })

/** In-memory production DB layer. */
export const DbMemoryLive = (config: DbConfig): Layer.Layer<Db, DbError> =>
  Layer.scoped(Db, makeMemoryDb(config))

/** In-memory deterministic DB layer for tests. */
export const DbMemoryTest = (
  config: DbConfig = { name: "test" }
): Layer.Layer<Db, DbError> => Layer.scoped(Db, makeMemoryDb(config))

/** Retrieve a value by key. */
export const get = (key: Bytes.BytesType) =>
  Effect.gen(function* () {
    const db = yield* Db
    return yield* db.get(key)
  })

/** Store a value by key. */
export const put = (key: Bytes.BytesType, value: Bytes.BytesType) =>
  Effect.gen(function* () {
    const db = yield* Db
    yield* db.put(key, value)
  })

/** Remove a value by key. */
export const remove = (key: Bytes.BytesType) =>
  Effect.gen(function* () {
    const db = yield* Db
    yield* db.remove(key)
  })

/** Check whether a key exists. */
export const has = (key: Bytes.BytesType) =>
  Effect.gen(function* () {
    const db = yield* Db
    return yield* db.has(key)
  })
