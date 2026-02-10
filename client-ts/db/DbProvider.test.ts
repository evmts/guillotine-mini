import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import {
  DbProviderMemoryTest,
  badBlocksDb,
  blockInfosDb,
  blockNumbersDb,
  blobTransactionsDb,
  blocksDb,
  bloomDb,
  codeDb,
  discoveryNodesDb,
  discoveryV5NodesDb,
  getDb,
  getColumnDb,
  headersDb,
  metadataDb,
  peersDb,
  receiptsDb,
  stateDb,
  storageDb,
} from "./DbProvider";
import { BlobTxsColumns, DbNames, ReceiptsColumns } from "./DbTypes";
import { toBytes } from "./testUtils";

describe("DbProvider", () => {
  it.effect("getDb resolves named DBs", () =>
    Effect.gen(function* () {
      const db = yield* getDb(DbNames.state);
      assert.strictEqual(db.name, DbNames.state);
    }).pipe(Effect.provide(DbProviderMemoryTest)),
  );

  const accessors = [
    ["storageDb", DbNames.storage, storageDb],
    ["stateDb", DbNames.state, stateDb],
    ["codeDb", DbNames.code, codeDb],
    ["blocksDb", DbNames.blocks, blocksDb],
    ["headersDb", DbNames.headers, headersDb],
    ["blockNumbersDb", DbNames.blockNumbers, blockNumbersDb],
    ["blockInfosDb", DbNames.blockInfos, blockInfosDb],
    ["badBlocksDb", DbNames.badBlocks, badBlocksDb],
    ["bloomDb", DbNames.bloom, bloomDb],
    ["metadataDb", DbNames.metadata, metadataDb],
    ["discoveryNodesDb", DbNames.discoveryNodes, discoveryNodesDb],
    ["discoveryV5NodesDb", DbNames.discoveryV5Nodes, discoveryV5NodesDb],
    ["peersDb", DbNames.peers, peersDb],
  ] as const;

  for (const [label, name, accessor] of accessors) {
    it.effect(`${label} resolves ${name}`, () =>
      Effect.gen(function* () {
        const db = yield* accessor();
        assert.strictEqual(db.name, name);
      }).pipe(Effect.provide(DbProviderMemoryTest)),
    );
  }

  it.effect("receiptsDb resolves receipts columns", () =>
    Effect.gen(function* () {
      const columnDb = yield* receiptsDb();
      assert.strictEqual(columnDb.name, DbNames.receipts);
      assert.deepStrictEqual(columnDb.columns, Object.values(ReceiptsColumns));
    }).pipe(Effect.provide(DbProviderMemoryTest)),
  );

  it.effect("blobTransactionsDb resolves blob transaction columns", () =>
    Effect.gen(function* () {
      const columnDb = yield* blobTransactionsDb();
      assert.strictEqual(columnDb.name, DbNames.blobTransactions);
      assert.deepStrictEqual(columnDb.columns, Object.values(BlobTxsColumns));
    }).pipe(Effect.provide(DbProviderMemoryTest)),
  );

  it.effect("getColumnDb resolves named column DBs", () =>
    Effect.gen(function* () {
      const receipts = yield* getColumnDb(DbNames.receipts);
      assert.strictEqual(receipts.name, DbNames.receipts);
      assert.deepStrictEqual(receipts.columns, Object.values(ReceiptsColumns));
    }).pipe(Effect.provide(DbProviderMemoryTest)),
  );

  it.effect("named DBs are isolated", () =>
    Effect.gen(function* () {
      const state = yield* stateDb();
      const code = yield* codeDb();
      const key = toBytes("0x01");
      const value = toBytes("0xdeadbeef");

      yield* state.put(key, value);

      const stateResult = yield* state.get(key);
      const codeResult = yield* code.get(key);

      assert.isTrue(Option.isSome(stateResult));
      assert.isTrue(Option.isNone(codeResult));
    }).pipe(Effect.provide(DbProviderMemoryTest)),
  );

  it.effect("receipt columns are isolated", () =>
    Effect.gen(function* () {
      const receipts = yield* receiptsDb();
      const defaultDb = receipts.getColumnDb(ReceiptsColumns.default);
      const transactionsDb = receipts.getColumnDb(ReceiptsColumns.transactions);
      const key = toBytes("0x02");
      const value = toBytes("0x1234");

      yield* defaultDb.put(key, value);

      const defaultResult = yield* defaultDb.get(key);
      const txResult = yield* transactionsDb.get(key);

      assert.isTrue(Option.isSome(defaultResult));
      assert.isTrue(Option.isNone(txResult));
    }).pipe(Effect.provide(DbProviderMemoryTest)),
  );

  it.effect("blob transaction columns are isolated", () =>
    Effect.gen(function* () {
      const blobTxs = yield* blobTransactionsDb();
      const fullDb = blobTxs.getColumnDb(BlobTxsColumns.fullBlobTxs);
      const lightDb = blobTxs.getColumnDb(BlobTxsColumns.lightBlobTxs);
      const key = toBytes("0x03");
      const value = toBytes("0xbeef");

      yield* fullDb.put(key, value);

      const fullResult = yield* fullDb.get(key);
      const lightResult = yield* lightDb.get(key);

      assert.isTrue(Option.isSome(fullResult));
      assert.isTrue(Option.isNone(lightResult));
    }).pipe(Effect.provide(DbProviderMemoryTest)),
  );
});
