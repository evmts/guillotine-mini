import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";
import {
  Address,
  Hex,
  Storage,
  StorageValue,
} from "voltaire-effect/primitives";
import { bytes32Equals, cloneBytes32 } from "./internal/bytes";

type AddressKey = Parameters<typeof Hex.equals>[0];
type StorageKey = Parameters<typeof Hex.equals>[0];
type StorageSlotType = Schema.Schema.Type<typeof Storage.StorageSlotSchema>;
type StorageValueType = Schema.Schema.Type<
  typeof StorageValue.StorageValueSchema
>;

type TransientStorageJournalEntry = {
  readonly addressKey: AddressKey;
  readonly slotKey: StorageKey;
  readonly previous: StorageValueType;
};

export type TransientStorageSnapshot = number;

export const EMPTY_SNAPSHOT: TransientStorageSnapshot = -1;

type SnapshotEntry = {
  readonly id: TransientStorageSnapshot;
  readonly journalLength: number;
};

export class UnknownTransientSnapshotError extends Data.TaggedError(
  "UnknownTransientSnapshotError",
)<{
  readonly snapshot: TransientStorageSnapshot;
  readonly depth: number;
}> {}

export interface TransientStorageService {
  readonly get: (
    address: Address.AddressType,
    slot: StorageSlotType,
  ) => Effect.Effect<StorageValueType>;
  readonly set: (
    address: Address.AddressType,
    slot: StorageSlotType,
    value: StorageValueType,
  ) => Effect.Effect<void>;
  readonly takeSnapshot: () => Effect.Effect<TransientStorageSnapshot>;
  readonly restoreSnapshot: (
    snapshot: TransientStorageSnapshot,
  ) => Effect.Effect<void, UnknownTransientSnapshotError>;
  readonly commitSnapshot: (
    snapshot: TransientStorageSnapshot,
  ) => Effect.Effect<void, UnknownTransientSnapshotError>;
  readonly clear: () => Effect.Effect<void>;
}

export class TransientStorage extends Context.Tag("TransientStorage")<
  TransientStorage,
  TransientStorageService
>() {}

const withTransientStorage = <A, E>(
  f: (storage: TransientStorageService) => Effect.Effect<A, E>,
) => Effect.flatMap(TransientStorage, f);

const addressKey = (address: Address.AddressType): AddressKey =>
  Hex.fromBytes(address);

const storageSlotKey = (slot: StorageSlotType): StorageKey =>
  Hex.fromBytes(slot);

const ZERO_STORAGE_VALUE = new Uint8Array(32) as StorageValueType;

const cloneStorageValue = (value: StorageValueType): StorageValueType =>
  cloneBytes32(value) as StorageValueType;

const isZeroStorageValue = (value: Uint8Array): boolean =>
  bytes32Equals(value, ZERO_STORAGE_VALUE);

const makeTransientStorage = Effect.gen(function* () {
  const storage = new Map<AddressKey, Map<StorageKey, StorageValueType>>();
  const journal: Array<TransientStorageJournalEntry> = [];
  const snapshotStack: Array<SnapshotEntry> = [];
  let nextSnapshotId: TransientStorageSnapshot = 0;

  const get = (address: Address.AddressType, slot: StorageSlotType) =>
    Effect.sync(() => {
      const key = addressKey(address);
      const slotKey = storageSlotKey(slot);
      const slots = storage.get(key);
      if (!slots) {
        return cloneStorageValue(ZERO_STORAGE_VALUE);
      }
      const value = slots.get(slotKey);
      return value
        ? cloneStorageValue(value)
        : cloneStorageValue(ZERO_STORAGE_VALUE);
    });

  const set = (
    address: Address.AddressType,
    slot: StorageSlotType,
    value: StorageValueType,
  ) =>
    Effect.sync(() => {
      const key = addressKey(address);
      const slotKey = storageSlotKey(slot);
      const slots = storage.get(key);
      const previous = slots?.get(slotKey) ?? ZERO_STORAGE_VALUE;

      if (bytes32Equals(previous, value)) {
        return;
      }

      journal.push({
        addressKey: key,
        slotKey,
        previous: cloneStorageValue(previous),
      });

      if (isZeroStorageValue(value)) {
        if (!slots) {
          return;
        }
        slots.delete(slotKey);
        if (slots.size === 0) {
          storage.delete(key);
        }
        return;
      }

      const next = cloneStorageValue(value);
      if (slots) {
        slots.set(slotKey, next);
        return;
      }

      const nextSlots = new Map<StorageKey, StorageValueType>();
      nextSlots.set(slotKey, next);
      storage.set(key, nextSlots);
    });

  const takeSnapshot = () =>
    Effect.sync(() => {
      const snapshot = nextSnapshotId;
      nextSnapshotId += 1;
      snapshotStack.push({ id: snapshot, journalLength: journal.length });
      return snapshot;
    });

  const lookupSnapshot = (snapshot: TransientStorageSnapshot) =>
    Effect.gen(function* () {
      for (let i = snapshotStack.length - 1; i >= 0; i -= 1) {
        const entry = snapshotStack[i];
        if (entry && entry.id === snapshot) {
          return { index: i, entry };
        }
      }
      return yield* Effect.fail(
        new UnknownTransientSnapshotError({
          snapshot,
          depth: snapshotStack.length,
        }),
      );
    });

  const revertEntry = (entry: TransientStorageJournalEntry) => {
    if (isZeroStorageValue(entry.previous)) {
      const slots = storage.get(entry.addressKey);
      if (!slots) {
        return;
      }
      slots.delete(entry.slotKey);
      if (slots.size === 0) {
        storage.delete(entry.addressKey);
      }
      return;
    }

    const slots =
      storage.get(entry.addressKey) ?? new Map<StorageKey, StorageValueType>();
    slots.set(entry.slotKey, cloneStorageValue(entry.previous));
    if (!storage.has(entry.addressKey)) {
      storage.set(entry.addressKey, slots);
    }
  };

  const dropSnapshots = (index: number) => {
    snapshotStack.splice(index);
  };

  const restoreSnapshot = (snapshot: TransientStorageSnapshot) =>
    Effect.gen(function* () {
      const { index, entry } = yield* lookupSnapshot(snapshot);
      const targetLength = entry.journalLength;
      for (let i = journal.length - 1; i >= targetLength; i -= 1) {
        const entry = journal[i];
        if (entry) {
          revertEntry(entry);
        }
      }
      journal.length = targetLength;
      dropSnapshots(index);
    });

  const commitSnapshot = (snapshot: TransientStorageSnapshot) =>
    Effect.gen(function* () {
      const { index } = yield* lookupSnapshot(snapshot);
      dropSnapshots(index);
    });

  const clear = () =>
    Effect.sync(() => {
      storage.clear();
      journal.length = 0;
      snapshotStack.length = 0;
    });

  return {
    get,
    set,
    takeSnapshot,
    restoreSnapshot,
    commitSnapshot,
    clear,
  } satisfies TransientStorageService;
});

export const TransientStorageLive: Layer.Layer<TransientStorage> = Layer.effect(
  TransientStorage,
  makeTransientStorage,
);

export const TransientStorageTest: Layer.Layer<TransientStorage> =
  TransientStorageLive;

export const getTransientStorage = (
  address: Address.AddressType,
  slot: StorageSlotType,
) => withTransientStorage((storage) => storage.get(address, slot));

export const setTransientStorage = (
  address: Address.AddressType,
  slot: StorageSlotType,
  value: StorageValueType,
) => withTransientStorage((storage) => storage.set(address, slot, value));

export const takeSnapshot = () =>
  withTransientStorage((storage) => storage.takeSnapshot());

export const restoreSnapshot = (snapshot: TransientStorageSnapshot) =>
  withTransientStorage((storage) => storage.restoreSnapshot(snapshot));

export const commitSnapshot = (snapshot: TransientStorageSnapshot) =>
  withTransientStorage((storage) => storage.commitSnapshot(snapshot));

export const clear = () => withTransientStorage((storage) => storage.clear());
