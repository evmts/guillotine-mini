import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import { Address, Hash, Hex, RuntimeCode } from "voltaire-effect/primitives";
import { TrieHashLive } from "../trie/hash";
import { encodeRlp } from "../trie/internal/rlp";
import { KeyNibblerLive } from "../trie/KeyNibbler";
import type { BytesType } from "../trie/Node";
import { TriePatricializeLive } from "../trie/patricialize";
import { TrieRoot, TrieRootLive, type TrieRootEntry } from "../trie/root";
import type { StorageSlotType, StorageValueType } from "./StorageTypes";
import {
  EMPTY_ACCOUNT,
  EMPTY_CODE_HASH,
  isEmpty,
  type AccountStateType,
} from "./Account";
import {
  ChangeTag,
  type JournalEntry,
  type JournalService,
  type JournalSnapshot,
  InvalidSnapshotError,
  Journal,
  JournalTest,
} from "./Journal";
import { bytes32Equals, cloneBytes32, bytesEquals } from "./internal/bytes";
import {
  cloneStorageValue,
  isZeroStorageValue,
  zeroBytes32,
} from "./internal/storage";
import { lookupSnapshotEntry } from "./internal/snapshot";

/** Hex-encoded key for account map storage. */
type AccountKey = Parameters<typeof Hex.equals>[0];
/** Hex-encoded key for storage slot map storage. */
type StorageKey = Parameters<typeof Hex.equals>[0];
/** Canonical runtime code type. */
type CodeValueType = RuntimeCode.RuntimeCodeType;
/** Journal key format for world state changes (structured to avoid brittle parsing). */
type WorldStateJournalKey =
  | { readonly kind: "account"; readonly key: AccountKey }
  | { readonly kind: "code"; readonly key: AccountKey }
  | {
      readonly kind: "storage";
      readonly accountKey: AccountKey;
      readonly slotKey: StorageKey;
    };
/** A null root marks local slot changes that have yet to be hashed. */
type StoredAccount = Omit<AccountStateType, "storageRoot"> & {
  readonly storageRoot: AccountStateType["storageRoot"] | null;
};
/** Journal value union for world state changes. */
type WorldStateJournalValue =
  | StoredAccount
  | StorageValueType
  | CodeValueType;
type OriginalStorageJournalEntry = {
  readonly accountKey: AccountKey;
  readonly slotKey: StorageKey;
};
type SnapshotEntry = {
  readonly id: WorldStateSnapshot;
  readonly journalSnapshot: JournalSnapshot;
  readonly originalStorageLength: number;
};

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

/** Error raised when marking an account as created without an active snapshot. */
export class NoActiveSnapshotError extends Data.TaggedError(
  "NoActiveSnapshotError",
)<{}> {}

/** World state service interface (accounts + storage + snapshots). */
export interface WorldStateService {
  readonly getAccountOptional: (
    address: Address.AddressType,
  ) => Effect.Effect<AccountStateType | null>;
  /** True if an account exists (regardless of emptiness). */
  readonly hasAccount: (address: Address.AddressType) => Effect.Effect<boolean>;
  readonly getAccount: (
    address: Address.AddressType,
  ) => Effect.Effect<AccountStateType>;
  readonly accountExistsAndIsEmpty: (
    address: Address.AddressType,
  ) => Effect.Effect<boolean>;
  readonly getCode: (
    address: Address.AddressType,
  ) => Effect.Effect<RuntimeCode.RuntimeCodeType>;
  readonly setAccount: (
    address: Address.AddressType,
    account: AccountStateType | null,
  ) => Effect.Effect<void>;
  readonly setCode: (
    address: Address.AddressType,
    code: RuntimeCode.RuntimeCodeType,
  ) => Effect.Effect<void>;
  readonly destroyAccount: (
    address: Address.AddressType,
  ) => Effect.Effect<void>;
  readonly destroyTouchedEmptyAccounts: (
    touchedAccounts: Iterable<Address.AddressType>,
  ) => Effect.Effect<void>;
  readonly markAccountCreated: (
    address: Address.AddressType,
  ) => Effect.Effect<void, NoActiveSnapshotError>;
  readonly wasAccountCreated: (
    address: Address.AddressType,
  ) => Effect.Effect<boolean>;
  readonly getStorage: (
    address: Address.AddressType,
    slot: StorageSlotType,
  ) => Effect.Effect<StorageValueType>;
  readonly getStorageOriginal: (
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

const accountJournalKey = (key: AccountKey): WorldStateJournalKey => ({
  kind: "account",
  key,
});

const codeJournalKey = (key: AccountKey): WorldStateJournalKey => ({
  kind: "code",
  key,
});

const storageJournalKey = (
  key: AccountKey,
  slotKey: StorageKey,
): WorldStateJournalKey => ({ kind: "storage", accountKey: key, slotKey });

const cloneAccount = (account: AccountStateType): AccountStateType => ({
  ...account,
  codeHash: cloneBytes32(account.codeHash) as AccountStateType["codeHash"],
  storageRoot: cloneBytes32(
    account.storageRoot,
  ) as AccountStateType["storageRoot"],
});

const ZERO_STORAGE_VALUE = zeroBytes32() as StorageValueType;
const EMPTY_CODE = new Uint8Array(0) as RuntimeCode.RuntimeCodeType;
const cloneRuntimeCode = (
  code: RuntimeCode.RuntimeCodeType,
): RuntimeCode.RuntimeCodeType =>
  (code.length === 0
    ? EMPTY_CODE
    : new Uint8Array(code)) as RuntimeCode.RuntimeCodeType;

const accountsEqual = (left: StoredAccount, right: StoredAccount): boolean =>
  left.nonce === right.nonce &&
  left.balance === right.balance &&
  bytes32Equals(left.codeHash, right.codeHash) &&
  (left.storageRoot === right.storageRoot ||
    (left.storageRoot !== null &&
      right.storageRoot !== null &&
      bytes32Equals(left.storageRoot, right.storageRoot)));

const makeWorldState = Effect.gen(function* () {
  const journal = (yield* Journal) as JournalService<
    WorldStateJournalKey,
    WorldStateJournalValue
  >;
  const trieRoot = yield* TrieRoot;
  const stateMutation = (yield* Effect.makeSemaphore(1)).withPermits(1);
  const accounts = new Map<AccountKey, StoredAccount>();
  const dirtyStorageRoots = new Set<AccountKey>();
  const codes = new Map<AccountKey, RuntimeCode.RuntimeCodeType>();
  const storage = new Map<AccountKey, Map<StorageKey, StorageValueType>>();
  const createdAccounts = new Set<AccountKey>();
  const originalStorage = new Map<
    AccountKey,
    Map<StorageKey, StorageValueType>
  >();
  const originalStorageJournal: Array<OriginalStorageJournalEntry> = [];
  const snapshotStack: Array<SnapshotEntry> = [];
  let nextSnapshotId: WorldStateSnapshot = 0;

  const clearTransactionTrackingIfNoSnapshots = () => {
    if (snapshotStack.length === 0) {
      createdAccounts.clear();
      originalStorage.clear();
      originalStorageJournal.length = 0;
    }
  };

  const recordOriginalStorageValue = (
    key: AccountKey,
    slotKey: StorageKey,
    value: StorageValueType,
  ) => {
    if (snapshotStack.length === 0) {
      return;
    }
    if (createdAccounts.has(key)) {
      return;
    }

    const slots = originalStorage.get(key);
    if (slots?.has(slotKey)) {
      return;
    }

    const nextSlots = slots ?? new Map<StorageKey, StorageValueType>();
    nextSlots.set(slotKey, cloneStorageValue(value));
    if (!slots) {
      originalStorage.set(key, nextSlots);
    }
    originalStorageJournal.push({ accountKey: key, slotKey });
  };

  const putAccount = (key: AccountKey, account: StoredAccount | null) => {
    if (account === null) {
      accounts.delete(key);
    } else {
      accounts.set(key, account);
    }
    if (account?.storageRoot === null) {
      dirtyStorageRoots.add(key);
    } else {
      dirtyStorageRoots.delete(key);
    }
  };

  const writeAccount = (key: AccountKey, account: StoredAccount) =>
    Effect.gen(function* () {
      const previous = accounts.get(key) ?? null;
      if (previous && accountsEqual(previous, account)) {
        return;
      }
      yield* journal.append({
        key: accountJournalKey(key),
        value: previous,
        tag: previous === null ? ChangeTag.Create : ChangeTag.Update,
      });
      putAccount(key, account);
    }).pipe(Effect.uninterruptible);

  const materializeStorageRoot = (
    key: AccountKey,
    account: StoredAccount,
  ): Effect.Effect<AccountStateType> =>
    Effect.gen(function* () {
      if (account.storageRoot !== null) {
        return { ...account, storageRoot: account.storageRoot };
      }

      const entries: TrieRootEntry[] = [];
      for (const [keyHex, slotValue] of storage.get(key) ?? []) {
        // Storage leaves hold RLP of the minimal big-endian integer.
        const firstNonZero = slotValue.findIndex((byte) => byte !== 0);
        const encoded = yield* encodeRlp(
          slotValue.subarray(firstNonZero),
        ).pipe(Effect.orDie);
        entries.push({
          key: Hex.toBytes(keyHex) as BytesType,
          value: encoded as BytesType,
        });
      }
      const storageRoot = yield* trieRoot
        .root(entries, { secured: true })
        .pipe(Effect.orDie);
      const next = {
        ...account,
        storageRoot: cloneBytes32(storageRoot) as AccountStateType["storageRoot"],
      };
      // Journal the cache update so restoring a snapshot can make it dirty again.
      if (snapshotStack.length > 0) {
        yield* writeAccount(key, next);
      } else {
        putAccount(key, next);
      }
      return next;
    });

  const getAccountOptional = (address: Address.AddressType) =>
    Effect.gen(function* () {
      const key = addressKey(address);
      const account = accounts.get(key);
      return account
        ? cloneAccount(yield* materializeStorageRoot(key, account))
        : null;
    }).pipe(stateMutation);

  const getAccount = (address: Address.AddressType) =>
    Effect.map(getAccountOptional(address), (account) =>
      account ? account : cloneAccount(EMPTY_ACCOUNT),
    );

  const hasAccount = (address: Address.AddressType) =>
    Effect.sync(() => accounts.has(addressKey(address)));

  const accountExistsAndIsEmpty = (address: Address.AddressType) =>
    Effect.sync(() => {
      const account = accounts.get(addressKey(address));
      return account !== undefined && isEmpty(account);
    });

  const getCode = (address: Address.AddressType) =>
    Effect.sync(() => {
      const code = codes.get(addressKey(address)) ?? EMPTY_CODE;
      return cloneRuntimeCode(code);
    });

  const markAccountCreated = (address: Address.AddressType) =>
    Effect.gen(function* () {
      if (snapshotStack.length === 0) {
        return yield* Effect.fail(new NoActiveSnapshotError());
      }
      return yield* Effect.sync(() => {
        createdAccounts.add(addressKey(address));
      });
    });

  const wasAccountCreated = (address: Address.AddressType) =>
    Effect.sync(() => createdAccounts.has(addressKey(address)));

  const getStorage = (address: Address.AddressType, slot: StorageSlotType) =>
    Effect.sync(() => {
      const key = addressKey(address);
      const slotKey = storageSlotKey(slot);
      // If the account does not exist, storage reads must return zero by spec.
      if (!accounts.has(key)) {
        recordOriginalStorageValue(key, slotKey, ZERO_STORAGE_VALUE);
        return cloneStorageValue(ZERO_STORAGE_VALUE);
      }
      const slots = storage.get(key);
      if (!slots) {
        recordOriginalStorageValue(key, slotKey, ZERO_STORAGE_VALUE);
        return cloneStorageValue(ZERO_STORAGE_VALUE);
      }
      const value = slots.get(slotKey);
      const nextValue = value ?? ZERO_STORAGE_VALUE;
      recordOriginalStorageValue(key, slotKey, nextValue);
      return value
        ? cloneStorageValue(value)
        : cloneStorageValue(ZERO_STORAGE_VALUE);
    });

  const getStorageOriginal = (
    address: Address.AddressType,
    slot: StorageSlotType,
  ) =>
    Effect.sync(() => {
      const key = addressKey(address);
      if (createdAccounts.has(key)) {
        return cloneStorageValue(ZERO_STORAGE_VALUE);
      }

      const slotKey = storageSlotKey(slot);
      const slots = originalStorage.get(key);
      if (slots?.has(slotKey)) {
        return cloneStorageValue(slots.get(slotKey)!);
      }

      const currentSlots = storage.get(key);
      const currentValue = currentSlots?.get(slotKey) ?? ZERO_STORAGE_VALUE;
      recordOriginalStorageValue(key, slotKey, currentValue);
      return cloneStorageValue(currentValue);
    });

  const setCode = (
    address: Address.AddressType,
    code: RuntimeCode.RuntimeCodeType,
  ) =>
    Effect.gen(function* () {
      const key = addressKey(address);
      const previous = codes.get(key) ?? null;

      // Compute desired code hash for the account (EMPTY for zero-length code)
      const computed = yield* code.length === 0
        ? Effect.succeed(EMPTY_CODE_HASH)
        : Hash.keccak256(code);
      const codeHash = cloneBytes32(computed) as AccountStateType["codeHash"];

      // Update code bytes with journaling semantics
      if (code.length === 0) {
        if (previous !== null) {
          yield* journal.append({
            key: codeJournalKey(key),
            value: cloneRuntimeCode(previous),
            tag: ChangeTag.Delete,
          });
          codes.delete(key);
        }
      } else {
        const next = cloneRuntimeCode(code);
        if (previous === null) {
          yield* journal.append({
            key: codeJournalKey(key),
            value: null,
            tag: ChangeTag.Create,
          });
          codes.set(key, next);
        } else if (!bytesEquals(previous, next)) {
          yield* journal.append({
            key: codeJournalKey(key),
            value: cloneRuntimeCode(previous),
            tag: ChangeTag.Update,
          });
          codes.set(key, next);
        }
      }

      // Keep AccountState.codeHash coherent with the stored code bytes.
      // Avoid materializing an empty account when setting empty code on a missing account.
      const priorAccount = accounts.get(key) ?? null;
      const shouldMaterialize =
        priorAccount !== null || !bytes32Equals(codeHash, EMPTY_CODE_HASH);
      if (shouldMaterialize) {
        const base = priorAccount ?? EMPTY_ACCOUNT;
        yield* writeAccount(key, { ...base, codeHash });
      }
    }).pipe(Effect.uninterruptible, stateMutation);

  const setStorage = (
    address: Address.AddressType,
    slot: StorageSlotType,
    value: StorageValueType,
  ) =>
    Effect.gen(function* () {
      const key = addressKey(address);
      const account = accounts.get(key);
      if (!account) {
        return yield* Effect.fail(new MissingAccountError({ address }));
      }

      const slotKey = storageSlotKey(slot);
      const slots = storage.get(key);
      const previous = slots?.get(slotKey);
      const deleting = isZeroStorageValue(value);
      recordOriginalStorageValue(key, slotKey, previous ?? ZERO_STORAGE_VALUE);
      if (previous ? bytes32Equals(previous, value) : deleting) {
        return;
      }

      yield* journal.append({
        key: storageJournalKey(key, slotKey),
        value: previous ? cloneStorageValue(previous) : null,
        tag: deleting
          ? ChangeTag.Delete
          : previous
            ? ChangeTag.Update
            : ChangeTag.Create,
      });
      if (deleting) {
        slots?.delete(slotKey);
        if (slots?.size === 0) {
          storage.delete(key);
        }
      } else {
        const nextSlots = slots ?? new Map<StorageKey, StorageValueType>();
        nextSlots.set(slotKey, cloneStorageValue(value));
        if (!slots) {
          storage.set(key, nextSlots);
        }
      }
      if (account.storageRoot !== null) {
        yield* writeAccount(key, { ...account, storageRoot: null });
      }
    }).pipe(Effect.uninterruptible, stateMutation);

  // Callers hold stateMutation across the account, code, and storage changes.
  const deleteAccount = (key: AccountKey) =>
    Effect.gen(function* () {
      for (const [slotKey, value] of storage.get(key) ?? []) {
        recordOriginalStorageValue(key, slotKey, value);
        yield* journal.append({
          key: storageJournalKey(key, slotKey),
          value: cloneStorageValue(value),
          tag: ChangeTag.Delete,
        });
      }
      const code = codes.get(key);
      if (code) {
        yield* journal.append({
          key: codeJournalKey(key),
          value: cloneRuntimeCode(code),
          tag: ChangeTag.Delete,
        });
      }
      const account = accounts.get(key);
      if (account) {
        yield* journal.append({
          key: accountJournalKey(key),
          value: account,
          tag: ChangeTag.Delete,
        });
      }

      storage.delete(key);
      codes.delete(key);
      putAccount(key, null);
    });

  const setAccount = (
    address: Address.AddressType,
    account: AccountStateType | null,
  ) =>
    Effect.suspend(() => {
      const key = addressKey(address);
      return account === null
        ? deleteAccount(key)
        : writeAccount(key, cloneAccount(account));
    }).pipe(Effect.uninterruptible, stateMutation);

  const destroyAccount = (address: Address.AddressType) =>
    setAccount(address, null);

  const destroyTouchedEmptyAccounts = (
    touchedAccounts: Iterable<Address.AddressType>,
  ) =>
    Effect.forEach(
      touchedAccounts,
      (address) =>
        Effect.gen(function* () {
          const key = addressKey(address);
          const account = accounts.get(key);
          if (account && isEmpty(account)) {
            yield* deleteAccount(key);
          }
        }),
      { discard: true },
    ).pipe(Effect.uninterruptible, stateMutation);

  const takeSnapshot = () =>
    Effect.gen(function* () {
      const journalSnapshot = yield* journal.takeSnapshot();
      if (snapshotStack.length === 0) {
        clearTransactionTrackingIfNoSnapshots();
      }
      const snapshot = nextSnapshotId;
      nextSnapshotId += 1;
      snapshotStack.push({
        id: snapshot,
        journalSnapshot,
        originalStorageLength: originalStorageJournal.length,
      });
      return snapshot;
    }).pipe(stateMutation);

  const applyRevert = (
    entry: JournalEntry<WorldStateJournalKey, WorldStateJournalValue>,
  ) =>
    Effect.sync(() => {
      const key = entry.key;
      if (typeof key === "object" && key) {
        if (key.kind === "account") {
          putAccount(key.key, entry.value as StoredAccount | null);
          return;
        }

        if (key.kind === "code") {
          const accKey = key.key;
          if (entry.value === null) {
            codes.delete(accKey);
          } else {
            codes.set(
              accKey,
              cloneRuntimeCode(entry.value as RuntimeCode.RuntimeCodeType),
            );
          }
          return;
        }

        if (key.kind === "storage") {
          if (entry.value === null) {
            const slots = storage.get(key.accountKey);
            if (!slots) {
              return;
            }
            slots.delete(key.slotKey);
            if (slots.size === 0) {
              storage.delete(key.accountKey);
            }
            return;
          }

          const slots =
            storage.get(key.accountKey) ??
            new Map<StorageKey, StorageValueType>();
          slots.set(
            key.slotKey,
            cloneStorageValue(entry.value as StorageValueType),
          );
          if (!storage.has(key.accountKey)) {
            storage.set(key.accountKey, slots);
          }
          return;
        }
      }
    });

  const lookupSnapshot = (snapshot: WorldStateSnapshot) =>
    lookupSnapshotEntry(
      snapshotStack,
      snapshot,
      (missingSnapshot, depth) =>
        new UnknownSnapshotError({
          snapshot: missingSnapshot,
          depth,
        }),
    );

  const dropSnapshotsFrom = (index: number) => {
    snapshotStack.splice(index);
    clearTransactionTrackingIfNoSnapshots();
  };

  const revertOriginalStorage = (targetLength: number) => {
    for (let i = originalStorageJournal.length - 1; i >= targetLength; i -= 1) {
      const entry = originalStorageJournal[i];
      if (!entry) {
        continue;
      }
      const slots = originalStorage.get(entry.accountKey);
      if (!slots) {
        continue;
      }
      slots.delete(entry.slotKey);
      if (slots.size === 0) {
        originalStorage.delete(entry.accountKey);
      }
    }
    originalStorageJournal.length = targetLength;
  };

  const restoreSnapshot = (snapshot: WorldStateSnapshot) =>
    Effect.gen(function* () {
      const { index, entry } = yield* lookupSnapshot(snapshot);
      yield* journal.restore(entry.journalSnapshot, applyRevert);
      revertOriginalStorage(entry.originalStorageLength);
      dropSnapshotsFrom(index);
    }).pipe(Effect.uninterruptible, stateMutation);

  const commitSnapshot = (snapshot: WorldStateSnapshot) =>
    Effect.gen(function* () {
      const { index, entry } = yield* lookupSnapshot(snapshot);
      // A parent rollback still needs the child slot and account entries.
      if (index === 0) {
        for (const key of dirtyStorageRoots) {
          yield* materializeStorageRoot(key, accounts.get(key)!);
        }
        yield* journal.commit(entry.journalSnapshot);
      }
      dropSnapshotsFrom(index);
    }).pipe(Effect.uninterruptible, stateMutation);

  const clear = () =>
    Effect.gen(function* () {
      accounts.clear();
      dirtyStorageRoots.clear();
      codes.clear();
      storage.clear();
      createdAccounts.clear();
      originalStorage.clear();
      originalStorageJournal.length = 0;
      snapshotStack.length = 0;
      yield* journal.clear();
    }).pipe(Effect.uninterruptible, stateMutation);

  return {
    getAccountOptional,
    hasAccount,
    getAccount,
    accountExistsAndIsEmpty,
    getCode,
    setAccount,
    setCode,
    destroyAccount,
    destroyTouchedEmptyAccounts,
    markAccountCreated,
    wasAccountCreated,
    getStorage,
    getStorageOriginal,
    setStorage,
    takeSnapshot,
    restoreSnapshot,
    commitSnapshot,
    clear,
  } satisfies WorldStateService;
});

const StorageTrieRootLive = TrieRootLive.pipe(
  Layer.provide(
    Layer.mergeAll(
      KeyNibblerLive,
      TrieHashLive,
      TriePatricializeLive.pipe(Layer.provide(TrieHashLive)),
    ),
  ),
);

/** Production world state layer. */
export const WorldStateLive: Layer.Layer<WorldState, never, Journal> =
  Layer.effect(WorldState, makeWorldState).pipe(
    Layer.provide(StorageTrieRootLive),
  );

/** Deterministic world state layer for tests. */
export const WorldStateTest: Layer.Layer<WorldState> = WorldStateLive.pipe(
  Layer.provide(JournalTest),
);

/** Read an optional account (None if not present). */
export const getAccountOptional = (address: Address.AddressType) =>
  withWorldState((state) => state.getAccountOptional(address));

/** Check if an account exists (present in world state). */
export const hasAccount = (address: Address.AddressType) =>
  withWorldState((state) => state.hasAccount(address));

/** Read an account (EMPTY_ACCOUNT if absent). */
export const getAccount = (address: Address.AddressType) =>
  withWorldState((state) => state.getAccount(address));

/** Check EIP-161 account existence+emptiness (non-existent is false). */
export const accountExistsAndIsEmpty = (address: Address.AddressType) =>
  withWorldState((state) => state.accountExistsAndIsEmpty(address));

/** Read contract code (empty if unset). */
export const getCode = (address: Address.AddressType) =>
  withWorldState((state) => state.getCode(address));

/** Set or delete an account. */
export const setAccount = (
  address: Address.AddressType,
  account: AccountStateType | null,
) => withWorldState((state) => state.setAccount(address, account));

/** Set contract code (empty clears). */
export const setCode = (
  address: Address.AddressType,
  code: RuntimeCode.RuntimeCodeType,
) => withWorldState((state) => state.setCode(address, code));

/** Remove an account and its data from state. */
export const destroyAccount = (address: Address.AddressType) =>
  withWorldState((state) => state.destroyAccount(address));

/** Destroy touched accounts that exist and are empty (EIP-161 semantics). */
export const destroyTouchedEmptyAccounts = (
  touchedAccounts: Iterable<Address.AddressType>,
) =>
  withWorldState((state) => state.destroyTouchedEmptyAccounts(touchedAccounts));

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

/** Read the original storage slot value for the current transaction. */
export const getStorageOriginal = (
  address: Address.AddressType,
  slot: StorageSlotType,
) => withWorldState((state) => state.getStorageOriginal(address, slot));

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
