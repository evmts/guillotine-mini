import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import { Address, Hex } from "voltaire-effect/primitives";
import {
  TransientStorageTest,
  UnknownTransientSnapshotError,
  clear,
  commitSnapshot,
  getTransientStorage,
  restoreSnapshot,
  setTransientStorage,
  takeSnapshot,
} from "./TransientStorage";

const makeAddress = (lastByte: number): Address.AddressType => {
  const addr = Address.zero();
  addr[addr.length - 1] = lastByte;
  return addr;
};

type StorageSlotType = Parameters<typeof getTransientStorage>[1];
type StorageValueType = Parameters<typeof setTransientStorage>[2];

const makeSlot = (lastByte: number): StorageSlotType => {
  const value = new Uint8Array(32);
  value[value.length - 1] = lastByte;
  return value as StorageSlotType;
};

const makeStorageValue = (byte: number): StorageValueType => {
  const value = new Uint8Array(32);
  value.fill(byte);
  return value as StorageValueType;
};

const storageValueHex = (value: Uint8Array) => Hex.fromBytes(value);
const ZERO_STORAGE_VALUE = makeStorageValue(0);

const provideTransientStorage = <A, E, R>(effect: Effect.Effect<A, E, R>) =>
  effect.pipe(Effect.provide(TransientStorageTest));

describe("TransientStorage", () => {
  it.effect("returns zero for missing transient storage", () =>
    provideTransientStorage(
      Effect.gen(function* () {
        const addr = makeAddress(1);
        const slot = makeSlot(2);
        const value = yield* getTransientStorage(addr, slot);
        assert.strictEqual(
          storageValueHex(value),
          storageValueHex(ZERO_STORAGE_VALUE),
        );
      }),
    ),
  );

  it.effect("sets and gets transient storage", () =>
    provideTransientStorage(
      Effect.gen(function* () {
        const addr = makeAddress(2);
        const slot = makeSlot(3);
        const stored = makeStorageValue(9);

        yield* setTransientStorage(addr, slot, stored);
        const value = yield* getTransientStorage(addr, slot);
        assert.strictEqual(storageValueHex(value), storageValueHex(stored));
      }),
    ),
  );

  it.effect("clears transient storage when set to zero", () =>
    provideTransientStorage(
      Effect.gen(function* () {
        const addr = makeAddress(3);
        const slot = makeSlot(4);
        const stored = makeStorageValue(7);

        yield* setTransientStorage(addr, slot, stored);
        yield* setTransientStorage(addr, slot, ZERO_STORAGE_VALUE);

        const value = yield* getTransientStorage(addr, slot);
        assert.strictEqual(
          storageValueHex(value),
          storageValueHex(ZERO_STORAGE_VALUE),
        );
      }),
    ),
  );

  it.effect("restores snapshot changes", () =>
    provideTransientStorage(
      Effect.gen(function* () {
        const addr = makeAddress(4);
        const slot = makeSlot(5);
        const first = makeStorageValue(1);
        const second = makeStorageValue(2);

        yield* setTransientStorage(addr, slot, first);
        const snapshot = yield* takeSnapshot();
        yield* setTransientStorage(addr, slot, second);

        yield* restoreSnapshot(snapshot);
        const value = yield* getTransientStorage(addr, slot);
        assert.strictEqual(storageValueHex(value), storageValueHex(first));
      }),
    ),
  );

  it.effect("commits snapshot changes", () =>
    provideTransientStorage(
      Effect.gen(function* () {
        const addr = makeAddress(5);
        const slot = makeSlot(6);
        const first = makeStorageValue(3);
        const second = makeStorageValue(4);

        yield* setTransientStorage(addr, slot, first);
        const snapshot = yield* takeSnapshot();
        yield* setTransientStorage(addr, slot, second);

        yield* commitSnapshot(snapshot);
        const value = yield* getTransientStorage(addr, slot);
        assert.strictEqual(storageValueHex(value), storageValueHex(second));
      }),
    ),
  );

  it.effect("keeps outer snapshots after inner commit", () =>
    provideTransientStorage(
      Effect.gen(function* () {
        const addr = makeAddress(6);
        const slot = makeSlot(7);
        const initial = makeStorageValue(5);
        const outerValue = makeStorageValue(6);
        const innerValue = makeStorageValue(7);

        yield* setTransientStorage(addr, slot, initial);
        const outer = yield* takeSnapshot();
        yield* setTransientStorage(addr, slot, outerValue);

        const inner = yield* takeSnapshot();
        yield* setTransientStorage(addr, slot, innerValue);
        yield* commitSnapshot(inner);

        yield* restoreSnapshot(outer);
        const value = yield* getTransientStorage(addr, slot);
        assert.strictEqual(storageValueHex(value), storageValueHex(initial));
      }),
    ),
  );

  it.effect("clear drops transient storage and snapshots", () =>
    provideTransientStorage(
      Effect.gen(function* () {
        const addr = makeAddress(7);
        const slot = makeSlot(8);
        const stored = makeStorageValue(8);

        const snapshot = yield* takeSnapshot();
        yield* setTransientStorage(addr, slot, stored);
        yield* clear();

        const value = yield* getTransientStorage(addr, slot);
        assert.strictEqual(
          storageValueHex(value),
          storageValueHex(ZERO_STORAGE_VALUE),
        );

        const outcome = yield* Effect.either(restoreSnapshot(snapshot));
        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof UnknownTransientSnapshotError);
        }
      }),
    ),
  );

  it.effect("fails for unknown snapshots", () =>
    provideTransientStorage(
      Effect.gen(function* () {
        const outcome = yield* Effect.either(restoreSnapshot(5));
        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof UnknownTransientSnapshotError);
        }
      }),
    ),
  );
});
