import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import * as Path from "node:path";
import { Bytes } from "voltaire-effect/primitives";
import {
  DbFactoryMemoryTest,
  DbFactoryRocksStubTest,
  createDb,
  createColumnsDb,
  getFullDbPath,
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
        const defaultDb = receipts.getColumnDb(ReceiptsColumns.Default);
        const transactionsDb = receipts.getColumnDb(
          ReceiptsColumns.Transactions,
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
        const fullDb = blobTxs.getColumnDb(BlobTxsColumns.FullBlobTxs);

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

  it.effect(
    "fails with DbError for invalid column DB names at runtime boundary",
    () =>
      Effect.scoped(
        Effect.gen(function* () {
          const invalidConfig = {
            name: "not-a-column-db",
          } as unknown as { readonly name: typeof DbNames.receipts };

          const error = yield* Effect.flip(createColumnsDb(invalidConfig));
          assert.strictEqual(error._tag, "DbError");
          assert.strictEqual(
            error.message.includes("Invalid column DB name"),
            true,
          );
        }),
      ).pipe(Effect.provide(DbFactoryMemoryTest)),
  );

  it.effect("returns db name when path settings are omitted", () =>
    Effect.gen(function* () {
      const fullPath = yield* getFullDbPath({
        name: DbNames.state,
      });
      assert.strictEqual(fullPath, DbNames.state);
    }).pipe(Effect.provide(DbFactoryMemoryTest)),
  );

  it.effect("resolves full path from non-rooted base path", () =>
    Effect.gen(function* () {
      const fullPath = yield* getFullDbPath({
        name: DbNames.state,
        basePath: "db",
      });
      assert.strictEqual(fullPath, Path.join(process.cwd(), "db", "state"));
    }).pipe(Effect.provide(DbFactoryMemoryTest)),
  );

  it.effect("joins explicitly relative base path and custom db path", () =>
    Effect.gen(function* () {
      const fullPath = yield* getFullDbPath({
        name: DbNames.state,
        basePath: "./db",
        path: "state-data",
      });
      assert.strictEqual(fullPath, Path.join("./db", "state-data"));
    }).pipe(Effect.provide(DbFactoryMemoryTest)),
  );

  it.effect("keeps absolute db path unchanged when base path is provided", () =>
    Effect.gen(function* () {
      const absolutePath = Path.join(process.cwd(), "absolute-state");
      const fullPath = yield* getFullDbPath({
        name: DbNames.state,
        path: absolutePath,
        basePath: "db",
      });
      assert.strictEqual(fullPath, absolutePath);
    }).pipe(Effect.provide(DbFactoryMemoryTest)),
  );

  it.effect(
    "keeps explicitly relative db path unchanged when base path is provided",
    () =>
      Effect.gen(function* () {
        const explicitPath = "./state-relative";
        const fullPath = yield* getFullDbPath({
          name: DbNames.state,
          path: explicitPath,
          basePath: "db",
        });
        assert.strictEqual(fullPath, explicitPath);
      }).pipe(Effect.provide(DbFactoryRocksStubTest)),
  );
});
