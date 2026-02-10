import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import type * as Schema from "effect/Schema";
import {
  Address,
  Hex,
  Storage,
  StorageValue,
} from "voltaire-effect/primitives";
import { bytes32Equals } from "./internal/bytes";
import {
  cloneStorageValue,
  isZeroStorageValue,
  zeroBytes32,
} from "./internal/storage";

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

/** Snapshot identifier for transient storage journaling. */
export type TransientStorageSnapshot = number;

/** Sentinel snapshot value when no transient storage snapshots exist. */
export const EMPTY_SNAPSHOT: TransientStorageSnapshot = -1;

type SnapshotEntry = {
  readonly id: TransientStorageSnapshot;
  readonly journalLength: number;
};

/** Error raised when a snapshot is not tracked by transient storage. */
export class UnknownTransientSnapshotError extends Data.TaggedError(
  "UnknownTransientSnapshotError",
)<{
  readonly snapshot: TransientStorageSnapshot;
  readonly depth: number;
}> {}

/** Service interface for EIP-1153 transient storage. */
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

/** Factory interface for transaction-scoped transient storage. */
export interface TransientStorageFactoryService {
  readonly make: () => Effect.Effect<TransientStorageService>;
}

/** Context tag for transient storage. */
export class TransientStorage extends Context.Tag("TransientStorage")<
  TransientStorage,
  TransientStorageService
>() {}

/** Context tag for transient storage factories. */
export class TransientStorageFactory extends Context.Tag(
  "TransientStorageFactory",
)<TransientStorageFactory, TransientStorageFactoryService>() {}

const withTransientStorage = <A, E>(
  f: (storage: TransientStorageService) => Effect.Effect<A, E>,
) => Effect.flatMap(TransientStorage, f);

const addressKey = (address: Address.AddressType): AddressKey =>
  Hex.fromBytes(address);

const storageSlotKey = (slot: StorageSlotType): StorageKey =>
  Hex.fromBytes(slot);

const ZERO_STORAGE_VALUE = zeroBytes32() as StorageValueType;

const makeTransientStorage = Effect.sync(() => {
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
      if (snapshotStack.length === 0) {
        journal.length = 0;
      }
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

/** Production transient storage layer. */
export const TransientStorageLive: Layer.Layer<TransientStorage> = Layer.effect(
  TransientStorage,
  makeTransientStorage,
);

/** Deterministic transient storage layer for tests. */
export const TransientStorageTest: Layer.Layer<TransientStorage> =
  TransientStorageLive;

/** Production transient storage factory layer. */
export const TransientStorageFactoryLive: Layer.Layer<TransientStorageFactory> =
  Layer.succeed(TransientStorageFactory, {
    make: () => makeTransientStorage,
  } satisfies TransientStorageFactoryService);

/** Deterministic transient storage factory layer for tests. */
export const TransientStorageFactoryTest: Layer.Layer<TransientStorageFactory> =
  TransientStorageFactoryLive;

/** Read a transient storage slot (zero if unset). */
export const getTransientStorage = (
  address: Address.AddressType,
  slot: StorageSlotType,
) => withTransientStorage((storage) => storage.get(address, slot));

/** Set a transient storage slot (zero clears the slot). */
export const setTransientStorage = (
  address: Address.AddressType,
  slot: StorageSlotType,
  value: StorageValueType,
) => withTransientStorage((storage) => storage.set(address, slot, value));

/** Capture a transient storage snapshot. */
export const takeSnapshot = () =>
  withTransientStorage((storage) => storage.takeSnapshot());

/** Restore transient storage to a snapshot. */
export const restoreSnapshot = (snapshot: TransientStorageSnapshot) =>
  withTransientStorage((storage) => storage.restoreSnapshot(snapshot));

/** Commit transient storage changes since a snapshot. */
export const commitSnapshot = (snapshot: TransientStorageSnapshot) =>
  withTransientStorage((storage) => storage.commitSnapshot(snapshot));

/** Clear all transient storage and snapshot history. */
export const clear = () => withTransientStorage((storage) => storage.clear());
