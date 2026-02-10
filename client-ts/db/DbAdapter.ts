import * as Context from "effect/Context";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import * as Scope from "effect/Scope";
import type { DbError } from "./DbError";
import type {
  BytesType,
  DbMetric,
  DbName,
  ReadFlags,
  WriteFlags,
} from "./DbTypes";

/** DB key/value pair entry. */
export interface DbEntry {
  readonly key: BytesType;
  readonly value: BytesType;
}

/** DB key/value pair result for multi-get operations. */
export interface DbGetEntry {
  readonly key: BytesType;
  readonly value: Option.Option<BytesType>;
}

/** Read-only key/value view used for DB snapshots. */
export interface DbSnapshot {
  readonly get: (
    key: BytesType,
    flags?: ReadFlags,
  ) => Effect.Effect<Option.Option<BytesType>, DbError>;
  readonly getMany: (
    keys: ReadonlyArray<BytesType>,
  ) => Effect.Effect<ReadonlyArray<DbGetEntry>, DbError>;
  readonly getAll: (
    ordered?: boolean,
  ) => Effect.Effect<ReadonlyArray<DbEntry>, DbError>;
  readonly getAllKeys: (
    ordered?: boolean,
  ) => Effect.Effect<ReadonlyArray<BytesType>, DbError>;
  readonly getAllValues: (
    ordered?: boolean,
  ) => Effect.Effect<ReadonlyArray<BytesType>, DbError>;
  readonly has: (key: BytesType) => Effect.Effect<boolean, DbError>;
}

/** Single write operation for batched commits. */
export type DbWriteOp =
  | {
      readonly _tag: "put";
      readonly key: BytesType;
      readonly value: BytesType;
      readonly flags?: WriteFlags;
    }
  | {
      readonly _tag: "del";
      readonly key: BytesType;
    }
  | {
      readonly _tag: "merge";
      readonly key: BytesType;
      readonly value: BytesType;
      readonly flags?: WriteFlags;
    };

/** IWriteBatch-compatible write operations. */
export interface WriteBatch {
  readonly put: (
    key: BytesType,
    value: BytesType,
    flags?: WriteFlags,
  ) => Effect.Effect<void, DbError>;
  readonly merge: (
    key: BytesType,
    value: BytesType,
    flags?: WriteFlags,
  ) => Effect.Effect<void, DbError>;
  readonly remove: (key: BytesType) => Effect.Effect<void, DbError>;
  readonly clear: () => Effect.Effect<void, DbError>;
}

/** IDbMeta-compatible DB maintenance and metrics surface. */
export interface DbMetaService {
  readonly flush: (onlyWal?: boolean) => Effect.Effect<void, DbError>;
  readonly clear: () => Effect.Effect<void, DbError>;
  readonly compact: () => Effect.Effect<void, DbError>;
  readonly gatherMetric: () => Effect.Effect<DbMetric, DbError>;
}

/** IDb-compatible key/value DB abstraction. */
export interface DbService extends DbMetaService {
  readonly name: DbName;
  readonly get: (
    key: BytesType,
    flags?: ReadFlags,
  ) => Effect.Effect<Option.Option<BytesType>, DbError>;
  readonly getMany: (
    keys: ReadonlyArray<BytesType>,
  ) => Effect.Effect<ReadonlyArray<DbGetEntry>, DbError>;
  readonly getAll: (
    ordered?: boolean,
  ) => Effect.Effect<ReadonlyArray<DbEntry>, DbError>;
  readonly getAllKeys: (
    ordered?: boolean,
  ) => Effect.Effect<ReadonlyArray<BytesType>, DbError>;
  readonly getAllValues: (
    ordered?: boolean,
  ) => Effect.Effect<ReadonlyArray<BytesType>, DbError>;
  readonly put: (
    key: BytesType,
    value: BytesType,
    flags?: WriteFlags,
  ) => Effect.Effect<void, DbError>;
  readonly merge: (
    key: BytesType,
    value: BytesType,
    flags?: WriteFlags,
  ) => Effect.Effect<void, DbError>;
  readonly remove: (key: BytesType) => Effect.Effect<void, DbError>;
  readonly has: (key: BytesType) => Effect.Effect<boolean, DbError>;
  readonly createSnapshot: () => Effect.Effect<
    DbSnapshot,
    DbError,
    Scope.Scope
  >;
  readonly writeBatch: (
    ops: ReadonlyArray<DbWriteOp>,
  ) => Effect.Effect<void, DbError>;
  readonly startWriteBatch: () => Effect.Effect<
    WriteBatch,
    DbError,
    Scope.Scope
  >;
}

/** Context tag for the DB adapter service. */
export class Db extends Context.Tag("Db")<Db, DbService>() {}
