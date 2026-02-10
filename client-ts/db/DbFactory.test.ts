import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import { Bytes } from "voltaire-effect/primitives";
import {
  DbFactoryMemoryTest,
  DbFactoryRocksStubTest,
  createDb,
  createColumnsDb,
} from "./DbFactory";
import { BlobTxsColumns, DbNames, ReceiptsColumns } from "./DbTypes";
import { toBytes } from "./testUtils";

describe("DbFactory", () => {
  it.effect("memory factory creates a functional DB", () =>
    Effect.scoped(
      Effect.gen(function* () {
        const db = yield* createDb({ name: DbNames.state });
        const key = toBytes("0x01");
        const value = toBytes("0xabcd");

        yield* db.put(key, value);
        const result = yield* db.get(key);

        assert.strictEqual(db.name, DbNames.state);
        assert.strictEqual(Option.isSome(result), true);
        assert.strictEqual(
          Bytes.equals(Option.getOrThrow(result), value),
          true,
        );
      }),
    ).pipe(Effect.provide(DbFactoryMemoryTest)),
  );

  it.effect("rocksdb stub factory creates a stub DB", () =>
    Effect.scoped(
      Effect.gen(function* () {
        const db = yield* createDb({ name: DbNames.state });
        const key = toBytes("0x02");

        assert.strictEqual(db.name, DbNames.state);
        const error = yield* Effect.flip(db.get(key));
        assert.strictEqual(error._tag, "DbError");
        assert.strictEqual(
          error.message.includes("does not implement get"),
          true,
        );
      }),
    ).pipe(Effect.provide(DbFactoryRocksStubTest)),
  );

  it.effect("memory factory creates receipts column DBs", () =>
    Effect.scoped(
      Effect.gen(function* () {
        const receipts = yield* createColumnsDb({ name: DbNames.receipts });
        const key = toBytes("0x03");
        const value = toBytes("0xbeef");
        const defaultDb = receipts.getColumnDb(ReceiptsColumns.default);
        const transactionsDb = receipts.getColumnDb(
          ReceiptsColumns.transactions,
        );

        assert.strictEqual(receipts.name, DbNames.receipts);
        assert.deepStrictEqual(
          receipts.columns,
          Object.values(ReceiptsColumns),
        );

        yield* defaultDb.put(key, value);

        const defaultResult = yield* defaultDb.get(key);
        const transactionsResult = yield* transactionsDb.get(key);

        assert.strictEqual(Option.isSome(defaultResult), true);
        assert.strictEqual(
          Bytes.equals(Option.getOrThrow(defaultResult), value),
          true,
        );
        assert.strictEqual(Option.isNone(transactionsResult), true);
      }),
    ).pipe(Effect.provide(DbFactoryMemoryTest)),
  );

  it.effect("rocksdb stub factory creates blob transaction column DBs", () =>
    Effect.scoped(
      Effect.gen(function* () {
        const blobTxs = yield* createColumnsDb({
          name: DbNames.blobTransactions,
        });
        const key = toBytes("0x04");
        const fullDb = blobTxs.getColumnDb(BlobTxsColumns.fullBlobTxs);

        assert.strictEqual(blobTxs.name, DbNames.blobTransactions);
        assert.deepStrictEqual(blobTxs.columns, Object.values(BlobTxsColumns));

        const error = yield* Effect.flip(fullDb.get(key));
        assert.strictEqual(error._tag, "DbError");
        assert.strictEqual(
          error.message.includes("does not implement get"),
          true,
        );
      }),
    ).pipe(Effect.provide(DbFactoryRocksStubTest)),
  );
});
