import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import { Bytes } from "voltaire-effect/primitives";
import { Db, DbMemoryTest } from "./Db";
import {
  ReadOnlyDb,
  ReadOnlyDbLive,
  clear as clearReadOnly,
  clearTempChanges,
  compact,
  createSnapshot,
  flush,
  gatherMetric,
  get,
  getAll,
  getAllKeys,
  getAllValues,
  getMany,
  has,
  merge,
  put,
  remove,
  startWriteBatch,
  writeBatch,
} from "./ReadOnlyDb";
import { toBytes } from "./testUtils";

describe("ReadOnlyDb", () => {
  const withOverlay = Layer.provideMerge(DbMemoryTest())(
    ReadOnlyDbLive({ createInMemWriteStore: true }),
  );
  const withoutOverlay = Layer.provideMerge(DbMemoryTest())(ReadOnlyDbLive());

  it.effect("reads through to the base db and overlays writes", () =>
    Effect.gen(function* () {
      const base = yield* Db;
      const readOnly = yield* ReadOnlyDb;

      const key = toBytes("0x41");
      const baseValue = toBytes("0xaaaa");
      const overlayValue = toBytes("0xbbbb");

      yield* base.put(key, baseValue);

      const readThrough = yield* readOnly.get(key);
      assert.isTrue(Bytes.equals(Option.getOrThrow(readThrough), baseValue));

      yield* readOnly.put(key, overlayValue);

      const overlayRead = yield* readOnly.get(key);
      assert.isTrue(Bytes.equals(Option.getOrThrow(overlayRead), overlayValue));

      const baseRead = yield* base.get(key);
      assert.isTrue(Bytes.equals(Option.getOrThrow(baseRead), baseValue));
    }).pipe(Effect.provide(withOverlay)),
  );

  it.effect("getMany and has respect overlay writes", () =>
    Effect.gen(function* () {
      const base = yield* Db;
      const readOnly = yield* ReadOnlyDb;

      const keyA = toBytes("0x01");
      const keyB = toBytes("0x02");
      const keyC = toBytes("0x03");
      const baseA = toBytes("0xaaaa");
      const baseB = toBytes("0xbbbb");
      const overlayB = toBytes("0xcccc");

      yield* base.put(keyA, baseA);
      yield* base.put(keyB, baseB);
      yield* readOnly.put(keyB, overlayB);

      const results = yield* readOnly.getMany([keyA, keyB, keyC]);
      assert.isTrue(Bytes.equals(Option.getOrThrow(results[0]!.value), baseA));
      assert.isTrue(
        Bytes.equals(Option.getOrThrow(results[1]!.value), overlayB),
      );
      assert.isTrue(Option.isNone(results[2]!.value));

      assert.isTrue(yield* readOnly.has(keyA));
      assert.isTrue(yield* readOnly.has(keyB));
      assert.isFalse(yield* readOnly.has(keyC));
    }).pipe(Effect.provide(withOverlay)),
  );

  it.effect("getAll, keys, and values merge overlay writes", () =>
    Effect.gen(function* () {
      const base = yield* Db;
      const readOnly = yield* ReadOnlyDb;

      const key1 = toBytes("0x01");
      const key2 = toBytes("0x02");
      const key3 = toBytes("0x03");
      const base1 = toBytes("0x1111");
      const base2 = toBytes("0x2222");
      const overlay2 = toBytes("0x2223");
      const overlay3 = toBytes("0x3333");

      yield* base.put(key1, base1);
      yield* base.put(key2, base2);
      yield* readOnly.put(key2, overlay2);
      yield* readOnly.put(key3, overlay3);

      const all = yield* readOnly.getAll(true);
      assert.strictEqual(all.length, 3);
      assert.isTrue(Bytes.equals(all[0]!.key, key1));
      assert.isTrue(Bytes.equals(all[0]!.value, base1));
      assert.isTrue(Bytes.equals(all[1]!.key, key2));
      assert.isTrue(Bytes.equals(all[1]!.value, overlay2));
      assert.isTrue(Bytes.equals(all[2]!.key, key3));
      assert.isTrue(Bytes.equals(all[2]!.value, overlay3));

      const keys = yield* readOnly.getAllKeys();
      assert.isTrue(keys.some((key) => Bytes.equals(key, key1)));
      assert.isTrue(keys.some((key) => Bytes.equals(key, key2)));
      assert.isTrue(keys.some((key) => Bytes.equals(key, key3)));

      const orderedKeys = yield* readOnly.getAllKeys(true);
      assert.isTrue(Bytes.equals(orderedKeys[0]!, key1));
      assert.isTrue(Bytes.equals(orderedKeys[1]!, key2));
      assert.isTrue(Bytes.equals(orderedKeys[2]!, key3));

      const values = yield* readOnly.getAllValues();
      assert.isTrue(values.some((value) => Bytes.equals(value, base1)));
      assert.isTrue(values.some((value) => Bytes.equals(value, overlay2)));
      assert.isTrue(values.some((value) => Bytes.equals(value, overlay3)));
      assert.isFalse(values.some((value) => Bytes.equals(value, base2)));

      const orderedValues = yield* readOnly.getAllValues(true);
      assert.isTrue(Bytes.equals(orderedValues[0]!, base1));
      assert.isTrue(Bytes.equals(orderedValues[1]!, overlay2));
      assert.isTrue(Bytes.equals(orderedValues[2]!, overlay3));
    }).pipe(Effect.provide(withOverlay)),
  );

  it.effect("remove clears overlay entries without hiding base data", () =>
    Effect.gen(function* () {
      const base = yield* Db;
      const readOnly = yield* ReadOnlyDb;

      const key = toBytes("0x10");
      const baseValue = toBytes("0xaaaa");
      const overlayValue = toBytes("0xbbbb");

      yield* base.put(key, baseValue);
      yield* readOnly.put(key, overlayValue);
      yield* readOnly.remove(key);

      const result = yield* readOnly.get(key);
      assert.isTrue(Bytes.equals(Option.getOrThrow(result), baseValue));
    }).pipe(Effect.provide(withOverlay)),
  );

  it.effect("writeBatch is atomic when merge fails", () =>
    Effect.gen(function* () {
      const base = yield* Db;
      const readOnly = yield* ReadOnlyDb;

      const key = toBytes("0x20");
      const baseValue = toBytes("0xaaaa");
      const overlayValue = toBytes("0xbbbb");

      yield* base.put(key, baseValue);

      const error = yield* Effect.flip(
        readOnly.writeBatch([
          { _tag: "put", key, value: overlayValue },
          { _tag: "merge", key, value: toBytes("0x01") },
        ]),
      );
      assert.strictEqual(error._tag, "DbError");

      const result = yield* readOnly.get(key);
      assert.isTrue(Bytes.equals(Option.getOrThrow(result), baseValue));
    }).pipe(Effect.provide(withOverlay)),
  );

  it.effect("merge is rejected even with overlay enabled", () =>
    Effect.gen(function* () {
      const readOnly = yield* ReadOnlyDb;
      const key = toBytes("0x21");
      const value = toBytes("0xaaaa");

      const error = yield* Effect.flip(readOnly.merge(key, value));
      assert.strictEqual(error._tag, "DbError");
    }).pipe(Effect.provide(withOverlay)),
  );

  it.effect("startWriteBatch writes through and clear is a no-op", () =>
    Effect.gen(function* () {
      const base = yield* Db;
      const readOnly = yield* ReadOnlyDb;

      const key = toBytes("0x30");
      const baseValue = toBytes("0x0101");
      const overlayValue = toBytes("0x0202");

      yield* base.put(key, baseValue);

      yield* Effect.scoped(
        Effect.gen(function* () {
          const batch = yield* readOnly.startWriteBatch();
          yield* batch.put(key, overlayValue);

          const interim = yield* readOnly.get(key);
          assert.isTrue(Bytes.equals(Option.getOrThrow(interim), overlayValue));

          yield* batch.clear();

          yield* batch.remove(key);
          const afterRemove = yield* readOnly.get(key);
          assert.isTrue(
            Bytes.equals(Option.getOrThrow(afterRemove), baseValue),
          );
        }),
      );
    }).pipe(Effect.provide(withOverlay)),
  );

  it.effect(
    "createSnapshot isolates overlay changes and clearTempChanges",
    () =>
      Effect.gen(function* () {
        const base = yield* Db;
        const readOnly = yield* ReadOnlyDb;

        const key = toBytes("0x40");
        const baseValue = toBytes("0xaaaa");
        const overlayValue = toBytes("0xbbbb");

        yield* base.put(key, baseValue);
        yield* readOnly.put(key, overlayValue);

        yield* Effect.scoped(
          Effect.gen(function* () {
            const snapshot = yield* readOnly.createSnapshot();

            const snapValue = yield* snapshot.get(key);
            assert.isTrue(
              Bytes.equals(Option.getOrThrow(snapValue), overlayValue),
            );

            yield* readOnly.clearTempChanges();

            const afterClear = yield* readOnly.get(key);
            assert.isTrue(
              Bytes.equals(Option.getOrThrow(afterClear), baseValue),
            );

            const stillSnap = yield* snapshot.get(key);
            assert.isTrue(
              Bytes.equals(Option.getOrThrow(stillSnap), overlayValue),
            );
          }),
        );
      }).pipe(Effect.provide(withOverlay)),
  );

  it.effect("flush/compact are no-ops and clear is rejected", () =>
    Effect.gen(function* () {
      const base = yield* Db;
      const readOnly = yield* ReadOnlyDb;

      yield* base.put(toBytes("0x50"), toBytes("0xaaaa"));
      yield* readOnly.put(toBytes("0x51"), toBytes("0xbbbb"));

      yield* readOnly.flush();
      yield* readOnly.compact();

      const metrics = yield* readOnly.gatherMetric();
      assert.strictEqual(metrics.size, 1);

      const error = yield* Effect.flip(readOnly.clear());
      assert.strictEqual(error._tag, "DbError");
    }).pipe(Effect.provide(withOverlay)),
  );

  it.effect("blocks writes when overlay is disabled", () =>
    Effect.gen(function* () {
      const readOnly = yield* ReadOnlyDb;
      const key = toBytes("0x42");
      const value = toBytes("0xdead");

      const error = yield* Effect.flip(readOnly.put(key, value));
      assert.strictEqual(error._tag, "DbError");
      assert.strictEqual(
        (yield* Effect.flip(readOnly.remove(key)))._tag,
        "DbError",
      );
      assert.strictEqual(
        (yield* Effect.flip(readOnly.merge(key, value)))._tag,
        "DbError",
      );
      assert.strictEqual(
        (yield* Effect.flip(readOnly.writeBatch([{ _tag: "put", key, value }])))
          ._tag,
        "DbError",
      );
      assert.strictEqual(
        (yield* Effect.flip(Effect.scoped(readOnly.startWriteBatch())))._tag,
        "DbError",
      );
    }).pipe(Effect.provide(withoutOverlay)),
  );

  it.effect("convenience accessors delegate to ReadOnlyDb service", () =>
    Effect.gen(function* () {
      const base = yield* Db;
      const baseKey = toBytes("0x60");
      const baseValue = toBytes("0xaaaa");
      const overlayKey = toBytes("0x61");
      const overlayValue = toBytes("0xbbbb");
      const batchKey = toBytes("0x62");
      const batchValue = toBytes("0xcccc");
      const scopedKey = toBytes("0x63");
      const scopedValue = toBytes("0xdddd");

      yield* base.put(baseKey, baseValue);
      yield* put(overlayKey, overlayValue);

      const single = yield* get(overlayKey);
      assert.isTrue(Bytes.equals(Option.getOrThrow(single), overlayValue));

      const many = yield* getMany([baseKey, overlayKey]);
      assert.strictEqual(many.length, 2);
      assert.isTrue(Bytes.equals(Option.getOrThrow(many[0]!.value), baseValue));
      assert.isTrue(
        Bytes.equals(Option.getOrThrow(many[1]!.value), overlayValue),
      );

      const entries = yield* getAll();
      assert.strictEqual(entries.length, 2);
      const keys = yield* getAllKeys();
      assert.strictEqual(keys.length, 2);
      const values = yield* getAllValues();
      assert.strictEqual(values.length, 2);

      assert.isTrue(yield* has(baseKey));

      yield* writeBatch([{ _tag: "put", key: batchKey, value: batchValue }]);
      const batchStored = yield* get(batchKey);
      assert.isTrue(Bytes.equals(Option.getOrThrow(batchStored), batchValue));

      yield* Effect.scoped(
        Effect.gen(function* () {
          const batch = yield* startWriteBatch();
          yield* batch.put(scopedKey, scopedValue);
          yield* batch.clear();
        }),
      );
      const scopedStored = yield* get(scopedKey);
      assert.isTrue(Bytes.equals(Option.getOrThrow(scopedStored), scopedValue));

      yield* Effect.scoped(
        Effect.gen(function* () {
          const snapshot = yield* createSnapshot();
          const snapshotValue = yield* snapshot.get(overlayKey);
          assert.isTrue(
            Bytes.equals(Option.getOrThrow(snapshotValue), overlayValue),
          );
        }),
      );

      yield* flush();
      yield* compact();
      const metrics = yield* gatherMetric();
      assert.strictEqual(metrics.size, 1);

      const mergeError = yield* Effect.flip(merge(overlayKey, overlayValue));
      assert.strictEqual(mergeError._tag, "DbError");

      const clearError = yield* Effect.flip(clearReadOnly());
      assert.strictEqual(clearError._tag, "DbError");

      yield* remove(overlayKey);
      const removed = yield* get(overlayKey);
      assert.isTrue(Option.isNone(removed));

      yield* clearTempChanges();
      const afterClear = yield* get(baseKey);
      assert.isTrue(Bytes.equals(Option.getOrThrow(afterClear), baseValue));
    }).pipe(Effect.provide(withOverlay)),
  );
});
