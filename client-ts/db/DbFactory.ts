import * as Context from "effect/Context";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Scope from "effect/Scope";
import * as Schema from "effect/Schema";
import * as Path from "node:path";
import {
  Db,
  DbMemoryLive,
  DbRocksStubLive,
  type DbConfig,
  type DbService,
} from "./Db";
import { DbError } from "./DbError";
import {
  BlobTxsColumns,
  ColumnDbNameSchema,
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

const receiptsColumns = [
  ReceiptsColumns.Default,
  ReceiptsColumns.Transactions,
  ReceiptsColumns.Blocks,
] as const satisfies ReadonlyArray<ReceiptsColumn>;

const blobTxsColumns = [
  BlobTxsColumns.FullBlobTxs,
  BlobTxsColumns.LightBlobTxs,
  BlobTxsColumns.ProcessedTxs,
] as const satisfies ReadonlyArray<BlobTxsColumn>;

type CreateColumnsDb = {
  (config: {
    readonly name: typeof DbNames.receipts;
  }): Effect.Effect<
    ColumnDbServices[typeof DbNames.receipts],
    DbError,
    Scope.Scope
  >;
  (config: {
    readonly name: typeof DbNames.blobTransactions;
  }): Effect.Effect<
    ColumnDbServices[typeof DbNames.blobTransactions],
    DbError,
    Scope.Scope
  >;
};

/** Factory service for constructing DB backends from config. */
export interface DbFactoryService {
  readonly createDb: (
    config: DbConfig,
  ) => Effect.Effect<DbService, DbError, Scope.Scope>;
  readonly getFullDbPath: (config: DbConfig) => string;
  readonly createColumnsDb: CreateColumnsDb;
}

/** Context tag for DB factory implementations. */
export class DbFactory extends Context.Tag("DbFactory")<
  DbFactory,
  DbFactoryService
>() {}

const buildDb = (layer: Layer.Layer<Db, DbError>) =>
  Layer.build(layer).pipe(Effect.map((context) => Context.get(context, Db)));

const validateColumnDbName = (
  name: unknown,
): Effect.Effect<ColumnDbName, DbError> =>
  Effect.try({
    try: () => Schema.decodeUnknownSync(ColumnDbNameSchema)(name),
    catch: (cause) =>
      new DbError({
        message: `Invalid column DB name: ${String(name)}`,
        cause,
      }),
  });

const buildReceiptsColumnsDb = (
  buildDbByName: (
    name: typeof DbNames.receipts,
  ) => Effect.Effect<DbService, DbError, Scope.Scope>,
): Effect.Effect<
  ColumnDbServices[typeof DbNames.receipts],
  DbError,
  Scope.Scope
> =>
  Effect.gen(function* () {
    const defaultDb = yield* buildDbByName(DbNames.receipts);
    const transactionsDb = yield* buildDbByName(DbNames.receipts);
    const blocksDb = yield* buildDbByName(DbNames.receipts);

    return {
      name: DbNames.receipts,
      columns: receiptsColumns,
      getColumnDb: (column: ReceiptsColumn) => {
        switch (column) {
          case ReceiptsColumns.Default:
            return defaultDb;
          case ReceiptsColumns.Transactions:
            return transactionsDb;
          case ReceiptsColumns.Blocks:
            return blocksDb;
        }
      },
    } satisfies ColumnDbServices[typeof DbNames.receipts];
  });

const buildBlobTxsColumnsDb = (
  buildDbByName: (
    name: typeof DbNames.blobTransactions,
  ) => Effect.Effect<DbService, DbError, Scope.Scope>,
): Effect.Effect<
  ColumnDbServices[typeof DbNames.blobTransactions],
  DbError,
  Scope.Scope
> =>
  Effect.gen(function* () {
    const fullBlobTxsDb = yield* buildDbByName(DbNames.blobTransactions);
    const lightBlobTxsDb = yield* buildDbByName(DbNames.blobTransactions);
    const processedTxsDb = yield* buildDbByName(DbNames.blobTransactions);

    return {
      name: DbNames.blobTransactions,
      columns: blobTxsColumns,
      getColumnDb: (column: BlobTxsColumn) => {
        switch (column) {
          case BlobTxsColumns.FullBlobTxs:
            return fullBlobTxsDb;
          case BlobTxsColumns.LightBlobTxs:
            return lightBlobTxsDb;
          case BlobTxsColumns.ProcessedTxs:
            return processedTxsDb;
        }
      },
    } satisfies ColumnDbServices[typeof DbNames.blobTransactions];
  });

const makeCreateColumnsDb = (
  buildDbByName: (
    name: ColumnDbName,
  ) => Effect.Effect<DbService, DbError, Scope.Scope>,
): CreateColumnsDb => {
  function createColumnsDb(config: {
    readonly name: typeof DbNames.receipts;
  }): Effect.Effect<
    ColumnDbServices[typeof DbNames.receipts],
    DbError,
    Scope.Scope
  >;
  function createColumnsDb(config: {
    readonly name: typeof DbNames.blobTransactions;
  }): Effect.Effect<
    ColumnDbServices[typeof DbNames.blobTransactions],
    DbError,
    Scope.Scope
  >;
  function createColumnsDb(config: { readonly name: ColumnDbName }) {
    return Effect.gen(function* () {
      const validatedName = yield* validateColumnDbName(config.name);

      if (validatedName === DbNames.receipts) {
        return yield* buildReceiptsColumnsDb(buildDbByName);
      }

      return yield* buildBlobTxsColumnsDb(buildDbByName);
    });
  }

  return createColumnsDb;
};

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
  createColumnsDb: makeCreateColumnsDb((name) =>
    buildDb(DbMemoryLive({ name })),
  ),
} satisfies DbFactoryService;

const rocksStubDbFactory = {
  createDb: (config: DbConfig) => buildDb(DbRocksStubLive(config)),
  getFullDbPath: (config: DbConfig) => resolveDbPath(config),
  createColumnsDb: makeCreateColumnsDb((name) =>
    buildDb(DbRocksStubLive({ name })),
  ),
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
export function createColumnsDb(config: {
  readonly name: typeof DbNames.receipts;
}): Effect.Effect<
  ColumnDbServices[typeof DbNames.receipts],
  DbError,
  Scope.Scope | DbFactory
>;
export function createColumnsDb(config: {
  readonly name: typeof DbNames.blobTransactions;
}): Effect.Effect<
  ColumnDbServices[typeof DbNames.blobTransactions],
  DbError,
  Scope.Scope | DbFactory
>;
export function createColumnsDb(config: { readonly name: ColumnDbName }) {
  if (config.name === DbNames.receipts) {
    return withDbFactory((factory) =>
      factory.createColumnsDb({ name: DbNames.receipts }),
    );
  }

  return withDbFactory((factory) =>
    factory.createColumnsDb({ name: DbNames.blobTransactions }),
  );
}
