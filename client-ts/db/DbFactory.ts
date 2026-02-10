import * as Context from "effect/Context";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Scope from "effect/Scope";
import * as Path from "node:path";
import {
  Db,
  DbMemoryLive,
  DbRocksStubLive,
  type DbConfig,
  type DbError,
  type DbService,
} from "./Db";
import {
  BlobTxsColumns,
  DbNames,
  ReceiptsColumns,
  type BlobTxsColumn,
  type ColumnDbName,
  type ReceiptsColumn,
} from "./DbTypes";

/** Columnar DB service group for a named DB. */
export interface ColumnsDbService<Column extends string> {
  readonly name: ColumnDbName;
  readonly columns: ReadonlyArray<Column>;
  readonly getColumnDb: (column: Column) => DbService;
}

/** Typed map of supported column DB services by name. */
export type ColumnDbServices = {
  readonly [DbNames.receipts]: ColumnsDbService<ReceiptsColumn>;
  readonly [DbNames.blobTransactions]: ColumnsDbService<BlobTxsColumn>;
};

const receiptsColumns = Object.values(
  ReceiptsColumns,
) as ReadonlyArray<ReceiptsColumn>;
const blobTxsColumns = Object.values(
  BlobTxsColumns,
) as ReadonlyArray<BlobTxsColumn>;
const columnSpecs: Record<ColumnDbName, ReadonlyArray<string>> = {
  [DbNames.receipts]: receiptsColumns,
  [DbNames.blobTransactions]: blobTxsColumns,
};

/** Factory service for constructing DB backends from config. */
export interface DbFactoryService {
  readonly createDb: (
    config: DbConfig,
  ) => Effect.Effect<DbService, DbError, Scope.Scope>;
  readonly getFullDbPath: (config: DbConfig) => string;
  readonly createColumnsDb: <Name extends ColumnDbName>(config: {
    readonly name: Name;
  }) => Effect.Effect<ColumnDbServices[Name], DbError, Scope.Scope>;
}

/** Context tag for DB factory implementations. */
export class DbFactory extends Context.Tag("DbFactory")<
  DbFactory,
  DbFactoryService
>() {}

const buildDb = (layer: Layer.Layer<Db, DbError>) =>
  Layer.build(layer).pipe(Effect.map((context) => Context.get(context, Db)));

const buildDbRecord = <Key extends string>(
  keys: ReadonlyArray<Key>,
  build: (key: Key) => Effect.Effect<DbService, DbError, Scope.Scope>,
) =>
  Effect.gen(function* () {
    const entries: Array<readonly [Key, DbService]> = [];

    for (const key of keys) {
      const db = yield* build(key);
      entries.push([key, db]);
    }

    return Object.fromEntries(entries) as Record<Key, DbService>;
  });

const buildColumnsDb = <Name extends ColumnDbName>(
  config: { readonly name: Name },
  buildDbByName: (name: Name) => Effect.Effect<DbService, DbError, Scope.Scope>,
): Effect.Effect<ColumnDbServices[Name], DbError, Scope.Scope> =>
  Effect.gen(function* () {
    const columns = columnSpecs[config.name];
    const columnDbs = yield* buildDbRecord(columns, () =>
      buildDbByName(config.name),
    );

    return {
      name: config.name,
      columns,
      getColumnDb: (column: (typeof columns)[number]) => columnDbs[column],
    } as ColumnDbServices[Name];
  });

const isExplicitlyRelativePath = (value: string) =>
  value.startsWith("./") ||
  value.startsWith("../") ||
  value.startsWith(".\\") ||
  value.startsWith("..\\");

const resolveDbPath = (config: DbConfig): string => {
  const dbPath = config.path ?? config.name;
  const basePath = config.basePath;

  if (basePath === undefined || basePath.length === 0) {
    return dbPath;
  }

  if (Path.isAbsolute(dbPath) || isExplicitlyRelativePath(dbPath)) {
    return dbPath;
  }

  if (Path.isAbsolute(basePath) || isExplicitlyRelativePath(basePath)) {
    return Path.join(basePath, dbPath);
  }

  return Path.join(process.cwd(), basePath, dbPath);
};

const memoryDbFactory = {
  createDb: (config: DbConfig) => buildDb(DbMemoryLive(config)),
  getFullDbPath: (config: DbConfig) => resolveDbPath(config),
  createColumnsDb: <Name extends ColumnDbName>(config: {
    readonly name: Name;
  }) => buildColumnsDb(config, (name) => buildDb(DbMemoryLive({ name }))),
} satisfies DbFactoryService;

const rocksStubDbFactory = {
  createDb: (config: DbConfig) => buildDb(DbRocksStubLive(config)),
  getFullDbPath: (config: DbConfig) => resolveDbPath(config),
  createColumnsDb: <Name extends ColumnDbName>(config: {
    readonly name: Name;
  }) => buildColumnsDb(config, (name) => buildDb(DbRocksStubLive({ name }))),
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

/** Resolve the full filesystem path for a DB config. */
export const getFullDbPath = (config: DbConfig) =>
  withDbFactory((factory) => Effect.succeed(factory.getFullDbPath(config)));

/** Create a column DB from the configured factory. */
export const createColumnsDb = <Name extends ColumnDbName>(config: {
  readonly name: Name;
}) => withDbFactory((factory) => factory.createColumnsDb(config));
