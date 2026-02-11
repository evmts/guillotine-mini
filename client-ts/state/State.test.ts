import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import { Address, Hex, RuntimeCode } from "voltaire-effect/primitives";
import {
  EMPTY_ACCOUNT,
  isTotallyEmpty,
  type AccountStateType,
} from "./Account";
import {
  WorldStateTest,
  accountExistsAndIsEmpty,
  MissingAccountError,
  UnknownSnapshotError,
  clear,
  commitSnapshot,
  destroyAccount,
  destroyTouchedEmptyAccounts,
  getAccount,
  getAccountOptional,
  getCode,
  getStorage,
  getStorageOriginal,
  markAccountCreated,
  restoreSnapshot,
  setAccount,
  setCode,
  setStorage,
  takeSnapshot,
  wasAccountCreated,
} from "./State";

const makeAccount = (
  overrides: Partial<Omit<AccountStateType, "__tag">> = {},
): AccountStateType => ({
  ...EMPTY_ACCOUNT,
  ...overrides,
});

const makeAddress = (lastByte: number): Address.AddressType => {
  const addr = Address.zero();
  addr[addr.length - 1] = lastByte;
  return addr;
};

type StorageSlotType = Parameters<typeof getStorage>[1];
type StorageValueType = Parameters<typeof setStorage>[2];

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

const EMPTY_CODE = new Uint8Array(0) as RuntimeCode.RuntimeCodeType;
const SAMPLE_CODE = new Uint8Array([
  0x60, 0x00, 0x60, 0x00,
]) as RuntimeCode.RuntimeCodeType;

const codeHex = (code: Uint8Array) => Hex.fromBytes(code);

const provideWorldState = <A, E, R>(effect: Effect.Effect<A, E, R>) =>
  effect.pipe(Effect.provide(WorldStateTest));

describe("WorldState", () => {
  it.effect("returns null for missing accounts", () =>
    provideWorldState(
      Effect.gen(function* () {
        const account = yield* getAccountOptional(Address.zero());
        assert.isNull(account);
      }),
    ),
  );

  it.effect("returns EMPTY_ACCOUNT for missing accounts", () =>
    provideWorldState(
      Effect.gen(function* () {
        const account = yield* getAccount(Address.zero());
        assert.isTrue(isTotallyEmpty(account));
      }),
    ),
  );

  it.effect("accountExistsAndIsEmpty is false for missing accounts", () =>
    provideWorldState(
      Effect.gen(function* () {
        const existsAndIsEmpty = yield* accountExistsAndIsEmpty(Address.zero());
        assert.isFalse(existsAndIsEmpty);
      }),
    ),
  );

  it.effect("accountExistsAndIsEmpty matches EIP-161 emptiness semantics", () =>
    provideWorldState(
      Effect.gen(function* () {
        const empty = makeAddress(0xa1);
        const nonEmpty = makeAddress(0xa2);
        const nonEmptyStorageRoot = new Uint8Array(32);
        nonEmptyStorageRoot[nonEmptyStorageRoot.length - 1] = 0x01;

        yield* setAccount(
          empty,
          makeAccount({
            storageRoot: nonEmptyStorageRoot as AccountStateType["storageRoot"],
          }),
        );
        yield* setAccount(nonEmpty, makeAccount({ nonce: 1n }));

        assert.isTrue(yield* accountExistsAndIsEmpty(empty));
        assert.isFalse(yield* accountExistsAndIsEmpty(nonEmpty));
      }),
    ),
  );

  it.effect("sets, updates, and deletes accounts", () =>
    provideWorldState(
      Effect.gen(function* () {
        const addr = makeAddress(1);
        yield* setAccount(addr, makeAccount({ nonce: 1n }));

        const created = yield* getAccountOptional(addr);
        assert.isNotNull(created);
        assert.strictEqual(created?.nonce, 1n);

        yield* setAccount(addr, makeAccount({ nonce: 2n }));
        const updated = yield* getAccountOptional(addr);
        assert.strictEqual(updated?.nonce, 2n);

        yield* destroyAccount(addr);
        const deleted = yield* getAccountOptional(addr);
        assert.isNull(deleted);
      }),
    ),
  );

  it.effect(
    "destroyTouchedEmptyAccounts deletes only touched empty accounts",
    () =>
      provideWorldState(
        Effect.gen(function* () {
          const touchedEmpty = makeAddress(0xb1);
          const touchedNonEmpty = makeAddress(0xb2);
          const untouchedEmpty = makeAddress(0xb3);
          const missingTouched = makeAddress(0xb4);

          yield* setAccount(touchedEmpty, makeAccount());
          yield* setAccount(touchedNonEmpty, makeAccount({ nonce: 1n }));
          yield* setAccount(untouchedEmpty, makeAccount());

          yield* destroyTouchedEmptyAccounts([
            touchedEmpty,
            touchedNonEmpty,
            missingTouched,
          ]);

          const deleted = yield* getAccountOptional(touchedEmpty);
          assert.isNull(deleted);

          const preservedNonEmpty = yield* getAccountOptional(touchedNonEmpty);
          assert.isNotNull(preservedNonEmpty);
          assert.strictEqual(preservedNonEmpty?.nonce, 1n);

          const untouched = yield* getAccountOptional(untouchedEmpty);
          assert.isNotNull(untouched);
        }),
      ),
  );

  it.effect("returns empty code for missing accounts", () =>
    provideWorldState(
      Effect.gen(function* () {
        const code = yield* getCode(Address.zero());
        assert.strictEqual(codeHex(code), codeHex(EMPTY_CODE));
      }),
    ),
  );

  it.effect("sets and clears contract code", () =>
    provideWorldState(
      Effect.gen(function* () {
        const addr = makeAddress(8);
        yield* setCode(addr, SAMPLE_CODE);
        const stored = yield* getCode(addr);
        assert.strictEqual(codeHex(stored), codeHex(SAMPLE_CODE));

        yield* setCode(addr, EMPTY_CODE);
        const cleared = yield* getCode(addr);
        assert.strictEqual(codeHex(cleared), codeHex(EMPTY_CODE));
      }),
    ),
  );

  it.effect("restores code changes on snapshot rollback", () =>
    provideWorldState(
      Effect.gen(function* () {
        const addr = makeAddress(16);
        yield* setCode(addr, SAMPLE_CODE);
        const snapshot = yield* takeSnapshot();
        yield* setCode(addr, EMPTY_CODE);

        yield* restoreSnapshot(snapshot);
        const restored = yield* getCode(addr);
        assert.strictEqual(codeHex(restored), codeHex(SAMPLE_CODE));
      }),
    ),
  );

  it.effect("returns zero for missing storage slots", () =>
    provideWorldState(
      Effect.gen(function* () {
        const addr = makeAddress(10);
        const slot = makeSlot(0);
        const value = yield* getStorage(addr, slot);
        assert.strictEqual(
          storageValueHex(value),
          storageValueHex(ZERO_STORAGE_VALUE),
        );
      }),
    ),
  );

  it.effect("sets, updates, and clears storage slots", () =>
    provideWorldState(
      Effect.gen(function* () {
        const addr = makeAddress(11);
        const slot = makeSlot(1);
        const valueA = makeStorageValue(5);
        const valueB = makeStorageValue(9);

        yield* setAccount(addr, makeAccount({ nonce: 1n }));
        yield* setStorage(addr, slot, valueA);
        const created = yield* getStorage(addr, slot);
        assert.strictEqual(storageValueHex(created), storageValueHex(valueA));

        yield* setStorage(addr, slot, valueB);
        const updated = yield* getStorage(addr, slot);
        assert.strictEqual(storageValueHex(updated), storageValueHex(valueB));

        yield* setStorage(addr, slot, ZERO_STORAGE_VALUE);
        const cleared = yield* getStorage(addr, slot);
        assert.strictEqual(
          storageValueHex(cleared),
          storageValueHex(ZERO_STORAGE_VALUE),
        );
      }),
    ),
  );

  it.effect("restores storage snapshot changes", () =>
    provideWorldState(
      Effect.gen(function* () {
        const addr = makeAddress(12);
        const slot = makeSlot(2);
        const valueA = makeStorageValue(3);
        const valueB = makeStorageValue(7);

        yield* setAccount(addr, makeAccount({ nonce: 1n }));
        yield* setStorage(addr, slot, valueA);
        const snapshot = yield* takeSnapshot();
        yield* setStorage(addr, slot, valueB);

        yield* restoreSnapshot(snapshot);
        const reverted = yield* getStorage(addr, slot);
        assert.strictEqual(storageValueHex(reverted), storageValueHex(valueA));
      }),
    ),
  );

  it.effect("commits storage snapshot changes", () =>
    provideWorldState(
      Effect.gen(function* () {
        const addr = makeAddress(13);
        const slot = makeSlot(3);
        const valueA = makeStorageValue(6);
        const valueB = makeStorageValue(8);

        yield* setAccount(addr, makeAccount({ nonce: 1n }));
        yield* setStorage(addr, slot, valueA);
        const snapshot = yield* takeSnapshot();
        yield* setStorage(addr, slot, valueB);

        yield* commitSnapshot(snapshot);
        const committed = yield* getStorage(addr, slot);
        assert.strictEqual(storageValueHex(committed), storageValueHex(valueB));
      }),
    ),
  );

  it.effect("tracks original storage values within a transaction", () =>
    provideWorldState(
      Effect.gen(function* () {
        const addr = makeAddress(14);
        const slot = makeSlot(4);
        const valueA = makeStorageValue(1);
        const valueB = makeStorageValue(2);

        yield* setAccount(addr, makeAccount({ nonce: 1n }));
        yield* setStorage(addr, slot, valueA);

        const snapshot = yield* takeSnapshot();
        const original = yield* getStorageOriginal(addr, slot);
        assert.strictEqual(storageValueHex(original), storageValueHex(valueA));

        yield* setStorage(addr, slot, valueB);
        const stillOriginal = yield* getStorageOriginal(addr, slot);
        assert.strictEqual(
          storageValueHex(stillOriginal),
          storageValueHex(valueA),
        );

        yield* commitSnapshot(snapshot);
      }),
    ),
  );

  it.effect("returns zero original storage for created accounts", () =>
    provideWorldState(
      Effect.gen(function* () {
        const addr = makeAddress(15);
        const slot = makeSlot(5);
        const value = makeStorageValue(9);

        const snapshot = yield* takeSnapshot();
        yield* markAccountCreated(addr);
        yield* setAccount(addr, makeAccount({ nonce: 1n }));
        yield* setStorage(addr, slot, value);

        const original = yield* getStorageOriginal(addr, slot);
        assert.strictEqual(
          storageValueHex(original),
          storageValueHex(ZERO_STORAGE_VALUE),
        );

        yield* commitSnapshot(snapshot);
      }),
    ),
  );

  it.effect("restores snapshot changes", () =>
    provideWorldState(
      Effect.gen(function* () {
        const addr = makeAddress(2);
        yield* setAccount(addr, makeAccount({ nonce: 1n }));

        const snapshot = yield* takeSnapshot();
        yield* setAccount(addr, makeAccount({ nonce: 3n }));

        yield* restoreSnapshot(snapshot);
        const reverted = yield* getAccountOptional(addr);
        assert.strictEqual(reverted?.nonce, 1n);
      }),
    ),
  );

  it.effect("commits snapshot changes", () =>
    provideWorldState(
      Effect.gen(function* () {
        const addr = makeAddress(3);
        yield* setAccount(addr, makeAccount({ nonce: 4n }));

        const snapshot = yield* takeSnapshot();
        yield* setAccount(addr, makeAccount({ nonce: 5n }));

        yield* commitSnapshot(snapshot);
        const committed = yield* getAccountOptional(addr);
        assert.strictEqual(committed?.nonce, 5n);
      }),
    ),
  );

  it.effect("tracks created accounts within transaction snapshots", () =>
    provideWorldState(
      Effect.gen(function* () {
        const addr = makeAddress(4);
        const outer = yield* takeSnapshot();
        yield* markAccountCreated(addr);
        yield* setAccount(addr, makeAccount({ nonce: 1n }));

        assert.isTrue(yield* wasAccountCreated(addr));

        const inner = yield* takeSnapshot();
        yield* setAccount(addr, makeAccount({ nonce: 9n }));
        yield* restoreSnapshot(inner);

        assert.isTrue(yield* wasAccountCreated(addr));
        const reverted = yield* getAccountOptional(addr);
        assert.strictEqual(reverted?.nonce, 1n);

        yield* commitSnapshot(outer);
        assert.isFalse(yield* wasAccountCreated(addr));
      }),
    ),
  );

  it.effect("allows explicit markAccountCreated within snapshot", () =>
    provideWorldState(
      Effect.gen(function* () {
        const addr = makeAddress(5);
        const snapshot = yield* takeSnapshot();

        yield* markAccountCreated(addr);
        assert.isTrue(yield* wasAccountCreated(addr));

        yield* commitSnapshot(snapshot);
        assert.isFalse(yield* wasAccountCreated(addr));
      }),
    ),
  );

  it.effect("fails to set storage for missing accounts", () =>
    provideWorldState(
      Effect.gen(function* () {
        const addr = makeAddress(6);
        const slot = makeSlot(4);
        const value = makeStorageValue(1);
        const outcome = yield* Effect.either(setStorage(addr, slot, value));
        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof MissingAccountError);
        }
      }),
    ),
  );

  it.effect("preserves created accounts after snapshot restore", () =>
    provideWorldState(
      Effect.gen(function* () {
        const addr = makeAddress(7);
        const outer = yield* takeSnapshot();
        const inner = yield* takeSnapshot();

        yield* markAccountCreated(addr);
        yield* setAccount(addr, makeAccount({ nonce: 1n }));
        assert.isTrue(yield* wasAccountCreated(addr));

        yield* restoreSnapshot(inner);
        assert.isTrue(yield* wasAccountCreated(addr));
        const reverted = yield* getAccountOptional(addr);
        assert.isNull(reverted);

        yield* restoreSnapshot(outer);
        assert.isFalse(yield* wasAccountCreated(addr));
      }),
    ),
  );

  it.effect("fails for unknown snapshots", () =>
    provideWorldState(
      Effect.gen(function* () {
        const outcome = yield* Effect.either(restoreSnapshot(5));
        assert.isTrue(Either.isLeft(outcome));

        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof UnknownSnapshotError);
        }
      }),
    ),
  );

  it.effect("clear resets tracked state", () =>
    provideWorldState(
      Effect.gen(function* () {
        const addr = makeAddress(9);
        const slot = makeSlot(9);
        const value = makeStorageValue(7);

        const snapshot = yield* takeSnapshot();
        yield* markAccountCreated(addr);
        yield* setAccount(addr, makeAccount({ nonce: 1n }));
        yield* setStorage(addr, slot, value);

        yield* clear();

        const account = yield* getAccountOptional(addr);
        assert.isNull(account);

        const stored = yield* getStorage(addr, slot);
        assert.strictEqual(
          storageValueHex(stored),
          storageValueHex(ZERO_STORAGE_VALUE),
        );

        assert.isFalse(yield* wasAccountCreated(addr));

        const restored = yield* Effect.either(restoreSnapshot(snapshot));
        assert.isTrue(Either.isLeft(restored));
        if (Either.isLeft(restored)) {
          assert.isTrue(restored.left instanceof UnknownSnapshotError);
        }
      }),
    ),
  );
});
