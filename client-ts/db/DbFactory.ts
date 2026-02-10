import * as Context from "effect/Context";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Scope from "effect/Scope";
import {
  Db,
  DbMemoryLive,
  DbRocksStubLive,
  type DbConfig,
  type DbError,
  type DbService,
} from "./Db";

/** Factory service for constructing DB backends from config. */
export interface DbFactoryService {
  readonly createDb: (
    config: DbConfig,
  ) => Effect.Effect<DbService, DbError, Scope.Scope>;
}

/** Context tag for DB factory implementations. */
export class DbFactory extends Context.Tag("DbFactory")<
  DbFactory,
  DbFactoryService
>() {}

const buildDb = (layer: Layer.Layer<Db, DbError>) =>
  Layer.build(layer).pipe(Effect.map((context) => Context.get(context, Db)));

const memoryDbFactory = {
  createDb: (config: DbConfig) => buildDb(DbMemoryLive(config)),
} satisfies DbFactoryService;

const rocksStubDbFactory = {
  createDb: (config: DbConfig) => buildDb(DbRocksStubLive(config)),
} satisfies DbFactoryService;

/** Memory-backed DB factory layer. */
export const DbFactoryMemoryLive: Layer.Layer<DbFactory> = Layer.succeed(
  DbFactory,
  memoryDbFactory,
);

/** Memory-backed DB factory layer for tests. */
export const DbFactoryMemoryTest: Layer.Layer<DbFactory> = DbFactoryMemoryLive;

/** RocksDB-stub-backed DB factory layer. */
export const DbFactoryRocksStubLive: Layer.Layer<DbFactory> = Layer.succeed(
  DbFactory,
  rocksStubDbFactory,
);

/** RocksDB-stub-backed DB factory layer for tests. */
export const DbFactoryRocksStubTest: Layer.Layer<DbFactory> =
  DbFactoryRocksStubLive;

const withDbFactory = <A, E, R>(
  f: (factory: DbFactoryService) => Effect.Effect<A, E, R>,
): Effect.Effect<A, E, R | DbFactory> => Effect.flatMap(DbFactory, f);

/** Create a DB from the configured factory. */
export const createDb = (config: DbConfig) =>
  withDbFactory((factory) => factory.createDb(config));
