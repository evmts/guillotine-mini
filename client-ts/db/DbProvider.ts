import * as Context from "effect/Context";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import {
  type ColumnDbServices,
  DbFactory,
  DbFactoryMemoryLive,
  DbFactoryRocksStubLive,
} from "./DbFactory";
import type { DbError, DbService } from "./Db";
import {
  DbNames,
  StandardDbNames,
  type ColumnDbName,
  type DbName,
  type StandardDbName,
} from "./DbTypes";

/** DB provider service for resolving standard and column databases. */
export interface DbProviderService {
  readonly getDb: (name: StandardDbName) => DbService;
  readonly getColumnDb: <Name extends ColumnDbName>(
    name: Name,
  ) => ColumnDbServices[Name];
}

/** Context tag for the DB provider. */
export class DbProvider extends Context.Tag("DbProvider")<
  DbProvider,
  DbProviderService
>() {}

const dbNames = Object.values(StandardDbNames) as ReadonlyArray<StandardDbName>;

const buildDbRecord = <Key extends string, R>(
  keys: ReadonlyArray<Key>,
  build: (key: Key) => Effect.Effect<DbService, DbError, R>,
) =>
  Effect.gen(function* () {
    const entries: Array<readonly [Key, DbService]> = [];

    for (const key of keys) {
      const db = yield* build(key);
      entries.push([key, db]);
    }

    return Object.fromEntries(entries) as Record<Key, DbService>;
  });

const makeDbProvider = Effect.gen(function* () {
  const dbFactory = yield* DbFactory;
  const buildDb = (name: DbName) => dbFactory.createDb({ name });

  const dbs = yield* buildDbRecord(dbNames, buildDb);
  const receiptsDb = yield* dbFactory.createColumnsDb({
    name: DbNames.receipts,
  });
  const blobTransactionsDb = yield* dbFactory.createColumnsDb({
    name: DbNames.blobTransactions,
  });
  const columnDbs: ColumnDbServices = {
    receipts: receiptsDb,
    blobTransactions: blobTransactionsDb,
  };

  return {
    getDb: (name: StandardDbName) => dbs[name],
    getColumnDb: <Name extends ColumnDbName>(name: Name) => columnDbs[name],
  } satisfies DbProviderService;
});

/** Backend-agnostic provider layer. */
export const DbProviderLive: Layer.Layer<DbProvider, DbError, DbFactory> =
  Layer.scoped(DbProvider, makeDbProvider);

/** In-memory provider layer for production. */
export const DbProviderMemoryLive: Layer.Layer<DbProvider, DbError> =
  DbProviderLive.pipe(Layer.provide(DbFactoryMemoryLive));

/** In-memory provider layer for tests. */
export const DbProviderMemoryTest: Layer.Layer<DbProvider, DbError> =
  DbProviderMemoryLive;

/** RocksDB-stub-backed provider layer for production. */
export const DbProviderRocksStubLive: Layer.Layer<DbProvider, DbError> =
  DbProviderLive.pipe(Layer.provide(DbFactoryRocksStubLive));

/** RocksDB-stub-backed provider layer for tests. */
export const DbProviderRocksStubTest: Layer.Layer<DbProvider, DbError> =
  DbProviderRocksStubLive;

const withProvider = <A, E, R>(
  f: (provider: DbProviderService) => Effect.Effect<A, E, R>,
) => Effect.flatMap(DbProvider, f);

/** Resolve a standard key/value DB by name. */
export const getDb = (name: StandardDbName) =>
  withProvider((provider) => Effect.succeed(provider.getDb(name)));

/** Resolve a column DB by name. */
export const getColumnDb = <Name extends ColumnDbName>(name: Name) =>
  withProvider((provider) => Effect.succeed(provider.getColumnDb(name)));

/** Resolve the storage DB instance. */
export const storageDb = () => getDb(DbNames.storage);
/** Resolve the state DB instance. */
export const stateDb = () => getDb(DbNames.state);
/** Resolve the code DB instance. */
export const codeDb = () => getDb(DbNames.code);
/** Resolve the blocks DB instance. */
export const blocksDb = () => getDb(DbNames.blocks);
/** Resolve the headers DB instance. */
export const headersDb = () => getDb(DbNames.headers);
/** Resolve the block numbers DB instance. */
export const blockNumbersDb = () => getDb(DbNames.blockNumbers);
/** Resolve the block infos DB instance. */
export const blockInfosDb = () => getDb(DbNames.blockInfos);
/** Resolve the bad blocks DB instance. */
export const badBlocksDb = () => getDb(DbNames.badBlocks);
/** Resolve the bloom DB instance. */
export const bloomDb = () => getDb(DbNames.bloom);
/** Resolve the metadata DB instance. */
export const metadataDb = () => getDb(DbNames.metadata);
/** Resolve the receipts column DB instance. */
export const receiptsDb = () => getColumnDb(DbNames.receipts);
/** Resolve the blob transactions column DB instance. */
export const blobTransactionsDb = () => getColumnDb(DbNames.blobTransactions);
/** Resolve the discovery nodes DB instance. */
export const discoveryNodesDb = () => getDb(DbNames.discoveryNodes);
/** Resolve the discovery v5 nodes DB instance. */
export const discoveryV5NodesDb = () => getDb(DbNames.discoveryV5Nodes);
/** Resolve the peers DB instance. */
export const peersDb = () => getDb(DbNames.peers);
