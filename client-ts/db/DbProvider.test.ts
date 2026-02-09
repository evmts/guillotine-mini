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
  headersDb,
  metadataDb,
  peersDb,
  receiptsDb,
  stateDb,
  storageDb,
} from "./DbProvider";
import { DbNames } from "./DbTypes";
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
    ["receiptsDb", DbNames.receipts, receiptsDb],
    ["blockInfosDb", DbNames.blockInfos, blockInfosDb],
    ["badBlocksDb", DbNames.badBlocks, badBlocksDb],
    ["bloomDb", DbNames.bloom, bloomDb],
    ["metadataDb", DbNames.metadata, metadataDb],
    ["blobTransactionsDb", DbNames.blobTransactions, blobTransactionsDb],
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
});
