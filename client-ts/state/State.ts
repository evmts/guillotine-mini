import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import { Address, Hex } from "voltaire-effect/primitives";
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

/** Hex-encoded key for account map storage. */
type AccountKey = Parameters<typeof Hex.equals>[0];

/** Snapshot identifier for world state journaling. */
export type WorldStateSnapshot = JournalSnapshot;

/** Error raised when a snapshot is not tracked by this world state. */
export class UnknownSnapshotError extends Data.TaggedError(
  "UnknownSnapshotError",
)<{
  readonly snapshot: WorldStateSnapshot;
  readonly depth: number;
}> {}

/** World state service interface (accounts + snapshots). */
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

const addressKey = (address: Address.AddressType): AccountKey =>
  Hex.fromBytes(address);

const cloneBytes32 = (value: Uint8Array): Uint8Array => value.slice();

const cloneAccount = (account: AccountStateType): AccountStateType => ({
  ...account,
  codeHash: cloneBytes32(account.codeHash) as AccountStateType["codeHash"],
  storageRoot: cloneBytes32(
    account.storageRoot,
  ) as AccountStateType["storageRoot"],
});

const bytes32Equals = (left: Uint8Array, right: Uint8Array): boolean => {
  if (left.length !== right.length) {
    return false;
  }
  for (let i = 0; i < left.length; i += 1) {
    if (left[i] !== right[i]) {
      return false;
    }
  }
  return true;
};

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
    AccountKey,
    AccountStateType
  >;
  const accounts = new Map<AccountKey, AccountStateType>();
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
          key,
          value: cloneAccount(previous),
          tag: ChangeTag.Delete,
        });
        accounts.delete(key);
        return;
      }

      const next = cloneAccount(account);

      if (previous === null) {
        yield* journal.append({
          key,
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
        key,
        value: cloneAccount(previous),
        tag: ChangeTag.Update,
      });
      accounts.set(key, next);
    });

  const destroyAccount = (address: Address.AddressType) =>
    setAccount(address, null);

  const takeSnapshot = () =>
    Effect.gen(function* () {
      const snapshot = yield* journal.takeSnapshot();
      if (snapshotStack.length === 0) {
        createdAccounts.clear();
      }
      snapshotStack.push(snapshot);
      return snapshot;
    });

  const applyRevert = (entry: JournalEntry<AccountKey, AccountStateType>) =>
    Effect.sync(() => {
      if (entry.value === null) {
        accounts.delete(entry.key);
      } else {
        accounts.set(entry.key, cloneAccount(entry.value));
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

  const dropSnapshotsFrom = (index: number) => {
    snapshotStack.splice(index);
    clearCreatedIfNoSnapshots();
  };

  const restoreSnapshot = (snapshot: WorldStateSnapshot) =>
    Effect.gen(function* () {
      const index = yield* lookupSnapshotIndex(snapshot);
      yield* journal.restore(snapshot, applyRevert);
      dropSnapshotsFrom(index);
    });

  const commitSnapshot = (snapshot: WorldStateSnapshot) =>
    Effect.gen(function* () {
      const index = yield* lookupSnapshotIndex(snapshot);
      yield* journal.commit(snapshot);
      dropSnapshotsFrom(index);
    });

  const clear = () =>
    Effect.gen(function* () {
      accounts.clear();
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
  Layer.provide(JournalTest<AccountKey, AccountStateType>()),
);

/** Read an optional account (None if not present). */
export const getAccountOptional = (address: Address.AddressType) =>
  Effect.gen(function* () {
    const state = yield* WorldState;
    return yield* state.getAccountOptional(address);
  });

/** Read an account (EMPTY_ACCOUNT if absent). */
export const getAccount = (address: Address.AddressType) =>
  Effect.gen(function* () {
    const state = yield* WorldState;
    return yield* state.getAccount(address);
  });

/** Set or delete an account. */
export const setAccount = (
  address: Address.AddressType,
  account: AccountStateType | null,
) =>
  Effect.gen(function* () {
    const state = yield* WorldState;
    return yield* state.setAccount(address, account);
  });

/** Remove an account and its data from state. */
export const destroyAccount = (address: Address.AddressType) =>
  Effect.gen(function* () {
    const state = yield* WorldState;
    return yield* state.destroyAccount(address);
  });

/** Mark an account as created in the current transaction. */
export const markAccountCreated = (address: Address.AddressType) =>
  Effect.gen(function* () {
    const state = yield* WorldState;
    return yield* state.markAccountCreated(address);
  });

/** Check if an account was created in the current transaction. */
export const wasAccountCreated = (address: Address.AddressType) =>
  Effect.gen(function* () {
    const state = yield* WorldState;
    return yield* state.wasAccountCreated(address);
  });

/** Capture a world state snapshot for later restore/commit. */
export const takeSnapshot = () =>
  Effect.gen(function* () {
    const state = yield* WorldState;
    return yield* state.takeSnapshot();
  });

/** Restore the world state to a prior snapshot. */
export const restoreSnapshot = (snapshot: WorldStateSnapshot) =>
  Effect.gen(function* () {
    const state = yield* WorldState;
    return yield* state.restoreSnapshot(snapshot);
  });

/** Commit changes since a snapshot and discard the snapshot. */
export const commitSnapshot = (snapshot: WorldStateSnapshot) =>
  Effect.gen(function* () {
    const state = yield* WorldState;
    return yield* state.commitSnapshot(snapshot);
  });

/** Clear all in-memory state and journal entries. */
export const clear = () =>
  Effect.gen(function* () {
    const state = yield* WorldState;
    return yield* state.clear();
  });
