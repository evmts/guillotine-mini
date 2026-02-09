import * as Context from "effect/Context";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import { Db, DbMemoryLive } from "./Db";
import type { DbError, DbService } from "./Db";
import { DbNames, type DbName } from "./DbTypes";

export interface DbProviderService {
  readonly getDb: (name: DbName) => DbService;
}

export class DbProvider extends Context.Tag("DbProvider")<
  DbProvider,
  DbProviderService
>() {}

const dbNames = Object.values(DbNames) as ReadonlyArray<DbName>;

const buildMemoryDb = (name: DbName) =>
  Layer.build(DbMemoryLive({ name })).pipe(
    Effect.map((context) => Context.get(context, Db)),
  );

const makeMemoryProvider = Effect.gen(function* () {
  const entries: Array<readonly [DbName, DbService]> = [];

  for (const name of dbNames) {
    const db = yield* buildMemoryDb(name);
    entries.push([name, db]);
  }

  const dbs = Object.fromEntries(entries) as Record<DbName, DbService>;

  return {
    getDb: (name: DbName) => dbs[name],
  } satisfies DbProviderService;
});

export const DbProviderMemoryLive: Layer.Layer<DbProvider, DbError> =
  Layer.scoped(DbProvider, makeMemoryProvider);

export const DbProviderMemoryTest: Layer.Layer<DbProvider, DbError> =
  Layer.scoped(DbProvider, makeMemoryProvider);

const withProvider = <A, E, R>(
  f: (provider: DbProviderService) => Effect.Effect<A, E, R>,
) => Effect.flatMap(DbProvider, f);

export const getDb = (name: DbName) =>
  withProvider((provider) => Effect.succeed(provider.getDb(name)));

export const storageDb = () => getDb(DbNames.storage);
export const stateDb = () => getDb(DbNames.state);
export const codeDb = () => getDb(DbNames.code);
export const blocksDb = () => getDb(DbNames.blocks);
export const headersDb = () => getDb(DbNames.headers);
export const blockNumbersDb = () => getDb(DbNames.blockNumbers);
export const receiptsDb = () => getDb(DbNames.receipts);
export const blockInfosDb = () => getDb(DbNames.blockInfos);
export const badBlocksDb = () => getDb(DbNames.badBlocks);
export const bloomDb = () => getDb(DbNames.bloom);
export const metadataDb = () => getDb(DbNames.metadata);
export const blobTransactionsDb = () => getDb(DbNames.blobTransactions);
export const discoveryNodesDb = () => getDb(DbNames.discoveryNodes);
export const discoveryV5NodesDb = () => getDb(DbNames.discoveryV5Nodes);
export const peersDb = () => getDb(DbNames.peers);
