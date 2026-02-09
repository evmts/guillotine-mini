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
import { EMPTY_ACCOUNT, type AccountStateType } from "./Account";
import {
  ChangeTag,
  type JournalEntry,
  type JournalService,
  type JournalSnapshot,
  InvalidSnapshotError,
  Journal,
  JournalTest,
} from "./Journal";
import { bytes32Equals, cloneBytes32 } from "./internal/bytes";

/** Hex-encoded key for account map storage. */
type AccountKey = Parameters<typeof Hex.equals>[0];
/** Hex-encoded key for storage slot map storage. */
type StorageKey = Parameters<typeof Hex.equals>[0];
/** Canonical storage slot type. */
type StorageSlotType = Schema.Schema.Type<typeof Storage.StorageSlotSchema>;
/** Canonical storage value type. */
type StorageValueType = Schema.Schema.Type<
  typeof StorageValue.StorageValueSchema
>;
/** Journal key format for world state changes. */
type WorldStateJournalKey = string;
/** Journal value union for world state changes. */
type WorldStateJournalValue = AccountStateType | StorageValueType;

/** Snapshot identifier for world state journaling. */
export type WorldStateSnapshot = JournalSnapshot;

/** Error raised when a snapshot is not tracked by this world state. */
export class UnknownSnapshotError extends Data.TaggedError(
  "UnknownSnapshotError",
)<{
  readonly snapshot: WorldStateSnapshot;
  readonly depth: number;
}> {}

/** Error raised when writing storage for a missing account. */
export class MissingAccountError extends Data.TaggedError(
  "MissingAccountError",
)<{
  readonly address: Address.AddressType;
}> {}

/** World state service interface (accounts + storage + snapshots). */
export interface WorldStateService {
  readonly getAccountOptional: (
    address: Address.AddressType,
  ) => Effect.Effect<AccountStateType | null>;
  readonly getAccount: (
    address: Address.AddressType,
  ) => Effect.Effect<AccountStateType>;
  readonly setAccount: (
    address: Address.AddressType,
    account: AccountStateType | null,
  ) => Effect.Effect<void>;
  readonly destroyAccount: (
    address: Address.AddressType,
  ) => Effect.Effect<void>;
  readonly markAccountCreated: (
    address: Address.AddressType,
  ) => Effect.Effect<void>;
  readonly wasAccountCreated: (
    address: Address.AddressType,
  ) => Effect.Effect<boolean>;
  readonly getStorage: (
    address: Address.AddressType,
    slot: StorageSlotType,
  ) => Effect.Effect<StorageValueType>;
  readonly setStorage: (
    address: Address.AddressType,
    slot: StorageSlotType,
    value: StorageValueType,
  ) => Effect.Effect<void, MissingAccountError>;
  readonly takeSnapshot: () => Effect.Effect<WorldStateSnapshot>;
  readonly restoreSnapshot: (
    snapshot: WorldStateSnapshot,
  ) => Effect.Effect<void, InvalidSnapshotError | UnknownSnapshotError>;
  readonly commitSnapshot: (
    snapshot: WorldStateSnapshot,
  ) => Effect.Effect<void, InvalidSnapshotError | UnknownSnapshotError>;
  readonly clear: () => Effect.Effect<void>;
}

/** Context tag for the world state service. */
export class WorldState extends Context.Tag("WorldState")<
  WorldState,
  WorldStateService
>() {}

const withWorldState = <A, E>(
  f: (state: WorldStateService) => Effect.Effect<A, E>,
) => Effect.flatMap(WorldState, f);

const addressKey = (address: Address.AddressType): AccountKey =>
  Hex.fromBytes(address);

const storageSlotKey = (slot: StorageSlotType): StorageKey =>
  Hex.fromBytes(slot);

const accountJournalPrefix = "account:";
const storageJournalPrefix = "storage:";

const accountJournalKey = (key: AccountKey): WorldStateJournalKey =>
  `${accountJournalPrefix}${key}`;

const storageJournalKey = (
  key: AccountKey,
  slotKey: StorageKey,
): WorldStateJournalKey => `${storageJournalPrefix}${key}:${slotKey}`;

const parseStorageJournalKey = (
  key: WorldStateJournalKey,
): { readonly accountKey: AccountKey; readonly slotKey: StorageKey } | null => {
  if (!key.startsWith(storageJournalPrefix)) {
    return null;
  }
  const rest = key.slice(storageJournalPrefix.length);
  const separator = rest.indexOf(":");
  if (separator < 0) {
    return null;
  }
  return {
    accountKey: rest.slice(0, separator) as AccountKey,
    slotKey: rest.slice(separator + 1) as StorageKey,
  };
};

const cloneAccount = (account: AccountStateType): AccountStateType => ({
  ...account,
  codeHash: cloneBytes32(account.codeHash) as AccountStateType["codeHash"],
  storageRoot: cloneBytes32(
    account.storageRoot,
  ) as AccountStateType["storageRoot"],
});

const ZERO_STORAGE_VALUE = new Uint8Array(32) as StorageValueType;

const cloneStorageValue = (value: StorageValueType): StorageValueType =>
  cloneBytes32(value) as StorageValueType;

const isZeroStorageValue = (value: Uint8Array): boolean =>
  bytes32Equals(value, ZERO_STORAGE_VALUE);

const accountsEqual = (
  left: AccountStateType,
  right: AccountStateType,
): boolean =>
  left.nonce === right.nonce &&
  left.balance === right.balance &&
  bytes32Equals(left.codeHash, right.codeHash) &&
  bytes32Equals(left.storageRoot, right.storageRoot);

const makeWorldState = Effect.gen(function* () {
  const journal = (yield* Journal) as JournalService<
    WorldStateJournalKey,
    WorldStateJournalValue
  >;
  const accounts = new Map<AccountKey, AccountStateType>();
  const storage = new Map<AccountKey, Map<StorageKey, StorageValueType>>();
  const createdAccounts = new Set<AccountKey>();
  const snapshotStack: Array<WorldStateSnapshot> = [];

  const clearCreatedIfNoSnapshots = () => {
    if (snapshotStack.length === 0) {
      createdAccounts.clear();
    }
  };

  const getAccountOptional = (address: Address.AddressType) =>
    Effect.sync(() => {
      const account = accounts.get(addressKey(address));
      return account ? cloneAccount(account) : null;
    });

  const getAccount = (address: Address.AddressType) =>
    Effect.map(getAccountOptional(address), (account) =>
      account ? account : EMPTY_ACCOUNT,
    );

  const markAccountCreated = (address: Address.AddressType) =>
    Effect.sync(() => {
      if (snapshotStack.length === 0) {
        return;
      }
      createdAccounts.add(addressKey(address));
    });

  const wasAccountCreated = (address: Address.AddressType) =>
    Effect.sync(() => createdAccounts.has(addressKey(address)));

  const getStorage = (address: Address.AddressType, slot: StorageSlotType) =>
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

  const clearStorageForKey = (key: AccountKey) =>
    Effect.gen(function* () {
      const slots = storage.get(key);
      if (!slots) {
        return;
      }
      for (const [slotKey, value] of slots) {
        yield* journal.append({
          key: storageJournalKey(key, slotKey),
          value: cloneStorageValue(value),
          tag: ChangeTag.Delete,
        });
      }
      storage.delete(key);
    });

  const setStorage = (
    address: Address.AddressType,
    slot: StorageSlotType,
    value: StorageValueType,
  ) =>
    Effect.gen(function* () {
      const key = addressKey(address);
      if (!accounts.has(key)) {
        return yield* Effect.fail(new MissingAccountError({ address }));
      }
      const slotKey = storageSlotKey(slot);
      const slots = storage.get(key);
      const previous = slots?.get(slotKey) ?? null;

      if (isZeroStorageValue(value)) {
        if (previous === null) {
          return;
        }
        yield* journal.append({
          key: storageJournalKey(key, slotKey),
          value: cloneStorageValue(previous),
          tag: ChangeTag.Delete,
        });
        slots?.delete(slotKey);
        if (slots && slots.size === 0) {
          storage.delete(key);
        }
        return;
      }

      const next = cloneStorageValue(value);

      if (previous === null) {
        yield* journal.append({
          key: storageJournalKey(key, slotKey),
          value: null,
          tag: ChangeTag.Create,
        });
        const nextSlots = slots ?? new Map<StorageKey, StorageValueType>();
        nextSlots.set(slotKey, next);
        if (!slots) {
          storage.set(key, nextSlots);
        }
        return;
      }

      if (bytes32Equals(previous, next)) {
        return;
      }

      yield* journal.append({
        key: storageJournalKey(key, slotKey),
        value: cloneStorageValue(previous),
        tag: ChangeTag.Update,
      });
      const nextSlots = slots ?? new Map<StorageKey, StorageValueType>();
      nextSlots.set(slotKey, next);
      if (!slots) {
        storage.set(key, nextSlots);
      }
    });

  const setAccount = (
    address: Address.AddressType,
    account: AccountStateType | null,
  ) =>
    Effect.gen(function* () {
      const key = addressKey(address);
      const previous = accounts.get(key) ?? null;

      if (account === null) {
        if (previous === null) {
          return;
        }
        yield* journal.append({
          key: accountJournalKey(key),
          value: cloneAccount(previous),
          tag: ChangeTag.Delete,
        });
        accounts.delete(key);
        return;
      }

      const next = cloneAccount(account);

      if (previous === null) {
        yield* journal.append({
          key: accountJournalKey(key),
          value: null,
          tag: ChangeTag.Create,
        });
        accounts.set(key, next);
        yield* markAccountCreated(address);
        return;
      }

      if (accountsEqual(previous, next)) {
        return;
      }

      yield* journal.append({
        key: accountJournalKey(key),
        value: cloneAccount(previous),
        tag: ChangeTag.Update,
      });
      accounts.set(key, next);
    });

  const destroyAccount = (address: Address.AddressType) =>
    Effect.gen(function* () {
      const key = addressKey(address);
      yield* clearStorageForKey(key);
      yield* setAccount(address, null);
    });

  const takeSnapshot = () =>
    Effect.gen(function* () {
      const snapshot = yield* journal.takeSnapshot();
      if (snapshotStack.length === 0) {
        createdAccounts.clear();
      }
      snapshotStack.push(snapshot);
      return snapshot;
    });

  const applyRevert = (
    entry: JournalEntry<WorldStateJournalKey, WorldStateJournalValue>,
  ) =>
    Effect.sync(() => {
      if (entry.key.startsWith(accountJournalPrefix)) {
        const key = entry.key.slice(accountJournalPrefix.length) as AccountKey;
        if (entry.value === null) {
          accounts.delete(key);
        } else {
          accounts.set(key, cloneAccount(entry.value as AccountStateType));
        }
        return;
      }

      const parsed = parseStorageJournalKey(entry.key);
      if (!parsed) {
        return;
      }

      if (entry.value === null) {
        const slots = storage.get(parsed.accountKey);
        if (!slots) {
          return;
        }
        slots.delete(parsed.slotKey);
        if (slots.size === 0) {
          storage.delete(parsed.accountKey);
        }
        return;
      }

      const slots =
        storage.get(parsed.accountKey) ??
        new Map<StorageKey, StorageValueType>();
      slots.set(
        parsed.slotKey,
        cloneStorageValue(entry.value as StorageValueType),
      );
      if (!storage.has(parsed.accountKey)) {
        storage.set(parsed.accountKey, slots);
      }
    });

  const lookupSnapshotIndex = (snapshot: WorldStateSnapshot) =>
    Effect.gen(function* () {
      const index = snapshotStack.lastIndexOf(snapshot);
      if (index < 0) {
        return yield* Effect.fail(
          new UnknownSnapshotError({
            snapshot,
            depth: snapshotStack.length,
          }),
        );
      }
      return index;
    });

  const dropSnapshotsFromRestore = (index: number) => {
    snapshotStack.splice(index);
    clearCreatedIfNoSnapshots();
  };

  const dropSnapshotsFromCommit = (index: number) => {
    snapshotStack.splice(index);
    clearCreatedIfNoSnapshots();
  };

  const restoreSnapshot = (snapshot: WorldStateSnapshot) =>
    Effect.gen(function* () {
      const index = yield* lookupSnapshotIndex(snapshot);
      yield* journal.restore(snapshot, applyRevert);
      dropSnapshotsFromRestore(index);
    });

  const commitSnapshot = (snapshot: WorldStateSnapshot) =>
    Effect.gen(function* () {
      const index = yield* lookupSnapshotIndex(snapshot);
      yield* journal.commit(snapshot);
      dropSnapshotsFromCommit(index);
    });

  const clear = () =>
    Effect.gen(function* () {
      accounts.clear();
      storage.clear();
      createdAccounts.clear();
      snapshotStack.length = 0;
      yield* journal.clear();
    });

  return {
    getAccountOptional,
    getAccount,
    setAccount,
    destroyAccount,
    markAccountCreated,
    wasAccountCreated,
    getStorage,
    setStorage,
    takeSnapshot,
    restoreSnapshot,
    commitSnapshot,
    clear,
  } satisfies WorldStateService;
});

/** Production world state layer. */
export const WorldStateLive: Layer.Layer<WorldState, never, Journal> =
  Layer.effect(WorldState, makeWorldState);

/** Deterministic world state layer for tests. */
export const WorldStateTest: Layer.Layer<WorldState> = WorldStateLive.pipe(
  Layer.provide(JournalTest<WorldStateJournalKey, WorldStateJournalValue>()),
);

/** Read an optional account (None if not present). */
export const getAccountOptional = (address: Address.AddressType) =>
  withWorldState((state) => state.getAccountOptional(address));

/** Read an account (EMPTY_ACCOUNT if absent). */
export const getAccount = (address: Address.AddressType) =>
  withWorldState((state) => state.getAccount(address));

/** Set or delete an account. */
export const setAccount = (
  address: Address.AddressType,
  account: AccountStateType | null,
) => withWorldState((state) => state.setAccount(address, account));

/** Remove an account and its data from state. */
export const destroyAccount = (address: Address.AddressType) =>
  withWorldState((state) => state.destroyAccount(address));

/** Mark an account as created in the current transaction. */
export const markAccountCreated = (address: Address.AddressType) =>
  withWorldState((state) => state.markAccountCreated(address));

/** Check if an account was created in the current transaction. */
export const wasAccountCreated = (address: Address.AddressType) =>
  withWorldState((state) => state.wasAccountCreated(address));

/** Read a storage slot value (zero if unset). */
export const getStorage = (
  address: Address.AddressType,
  slot: StorageSlotType,
) => withWorldState((state) => state.getStorage(address, slot));

/** Set a storage slot value (zero clears the slot). */
export const setStorage = (
  address: Address.AddressType,
  slot: StorageSlotType,
  value: StorageValueType,
) => withWorldState((state) => state.setStorage(address, slot, value));

/** Capture a world state snapshot for later restore/commit. */
export const takeSnapshot = () =>
  withWorldState((state) => state.takeSnapshot());

/** Restore the world state to a prior snapshot. */
export const restoreSnapshot = (snapshot: WorldStateSnapshot) =>
  withWorldState((state) => state.restoreSnapshot(snapshot));

/** Commit changes since a snapshot and discard the snapshot. */
export const commitSnapshot = (snapshot: WorldStateSnapshot) =>
  withWorldState((state) => state.commitSnapshot(snapshot));

/** Clear all in-memory state and journal entries. */
export const clear = () => withWorldState((state) => state.clear());
