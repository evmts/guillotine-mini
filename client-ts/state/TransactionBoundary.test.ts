import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import { Address, Hex } from "voltaire-effect/primitives";
import { EMPTY_ACCOUNT, type AccountStateType } from "./Account";
import {
  getAccountOptional,
  setAccount,
  setStorage,
  getStorage,
  WorldState,
} from "./State";
import {
  getTransientStorage,
  setTransientStorage,
  TransientStorage,
} from "./TransientStorage";
import {
  NoActiveTransactionError,
  TransactionBoundary,
  TransactionBoundaryTest,
  beginTransaction,
  commitTransaction,
  rollbackTransaction,
  transactionDepth,
} from "./TransactionBoundary";

const makeAddress = (lastByte: number): Address.AddressType => {
  const address = Address.zero();
  address[address.length - 1] = lastByte;
  return address;
};

const makeSlot = (lastByte: number) => {
  const slot = new Uint8Array(32);
  slot[slot.length - 1] = lastByte;
  return slot as Parameters<typeof getStorage>[1];
};

const makeStorageValue = (byte: number) => {
  const value = new Uint8Array(32);
  value.fill(byte);
  return value as Parameters<typeof setStorage>[2];
};

const makeAccount = (
  overrides: Partial<Omit<AccountStateType, "__tag">> = {},
): AccountStateType => ({
  ...EMPTY_ACCOUNT,
  ...overrides,
});

const storageValueHex = (value: Uint8Array) => Hex.fromBytes(value);
const ZERO_STORAGE_VALUE = makeStorageValue(0);

const provideIntegration = <A, E>(
  effect: Effect.Effect<
    A,
    E,
    TransactionBoundary | WorldState | TransientStorage
  >,
) => effect.pipe(Effect.provide(TransactionBoundaryTest));

describe("TransactionBoundary", () => {
  it.effect("beginTransaction increases transaction depth", () =>
    provideIntegration(
      Effect.gen(function* () {
        assert.strictEqual(yield* transactionDepth(), 0);
        yield* beginTransaction();
        assert.strictEqual(yield* transactionDepth(), 1);
        yield* beginTransaction();
        assert.strictEqual(yield* transactionDepth(), 2);
      }),
    ),
  );

  it.effect("commitTransaction persists world and transient changes", () =>
    provideIntegration(
      Effect.gen(function* () {
        const address = makeAddress(1);
        const slot = makeSlot(1);
        const value = makeStorageValue(0xaa);

        yield* setAccount(address, makeAccount({ nonce: 1n }));
        yield* beginTransaction();
        yield* setAccount(address, makeAccount({ nonce: 2n }));
        yield* setStorage(address, slot, value);
        yield* setTransientStorage(address, slot, value);

        yield* commitTransaction();
        assert.strictEqual(yield* transactionDepth(), 0);

        const account = yield* getAccountOptional(address);
        assert.strictEqual(account?.nonce, 2n);

        const persistent = yield* getStorage(address, slot);
        assert.strictEqual(storageValueHex(persistent), storageValueHex(value));

        const transient = yield* getTransientStorage(address, slot);
        assert.strictEqual(storageValueHex(transient), storageValueHex(value));
      }),
    ),
  );

  it.effect("rollbackTransaction reverts world and transient changes", () =>
    provideIntegration(
      Effect.gen(function* () {
        const address = makeAddress(2);
        const slot = makeSlot(2);
        const value = makeStorageValue(0xbb);

        yield* setAccount(address, makeAccount({ nonce: 3n }));
        yield* beginTransaction();
        yield* setAccount(address, makeAccount({ nonce: 4n }));
        yield* setStorage(address, slot, value);
        yield* setTransientStorage(address, slot, value);

        yield* rollbackTransaction();
        assert.strictEqual(yield* transactionDepth(), 0);

        const account = yield* getAccountOptional(address);
        assert.strictEqual(account?.nonce, 3n);

        const persistent = yield* getStorage(address, slot);
        assert.strictEqual(
          storageValueHex(persistent),
          storageValueHex(ZERO_STORAGE_VALUE),
        );

        const transient = yield* getTransientStorage(address, slot);
        assert.strictEqual(
          storageValueHex(transient),
          storageValueHex(ZERO_STORAGE_VALUE),
        );
      }),
    ),
  );

  it.effect(
    "nested boundaries are committed and rolled back in LIFO order",
    () =>
      provideIntegration(
        Effect.gen(function* () {
          const address = makeAddress(3);
          const slot = makeSlot(3);
          const outerValue = makeStorageValue(0x0c);
          const innerValue = makeStorageValue(0x0d);

          yield* setAccount(address, makeAccount({ nonce: 10n }));

          yield* beginTransaction();
          yield* setAccount(address, makeAccount({ nonce: 11n }));
          yield* setStorage(address, slot, outerValue);
          yield* setTransientStorage(address, slot, outerValue);

          yield* beginTransaction();
          yield* setAccount(address, makeAccount({ nonce: 12n }));
          yield* setStorage(address, slot, innerValue);
          yield* setTransientStorage(address, slot, innerValue);

          yield* rollbackTransaction();
          assert.strictEqual(yield* transactionDepth(), 1);

          const afterInnerRollback = yield* getAccountOptional(address);
          assert.strictEqual(afterInnerRollback?.nonce, 11n);

          const persistentAfterInnerRollback = yield* getStorage(address, slot);
          assert.strictEqual(
            storageValueHex(persistentAfterInnerRollback),
            storageValueHex(outerValue),
          );

          const transientAfterInnerRollback = yield* getTransientStorage(
            address,
            slot,
          );
          assert.strictEqual(
            storageValueHex(transientAfterInnerRollback),
            storageValueHex(outerValue),
          );

          yield* commitTransaction();
          assert.strictEqual(yield* transactionDepth(), 0);

          const afterOuterCommit = yield* getAccountOptional(address);
          assert.strictEqual(afterOuterCommit?.nonce, 11n);
        }),
      ),
  );

  it.effect("commitTransaction fails when there is no active transaction", () =>
    provideIntegration(
      Effect.gen(function* () {
        const result = yield* Effect.either(commitTransaction());
        assert.isTrue(Either.isLeft(result));
        if (Either.isLeft(result)) {
          assert.isTrue(result.left instanceof NoActiveTransactionError);
        }
      }),
    ),
  );

  it.effect(
    "rollbackTransaction fails when there is no active transaction",
    () =>
      provideIntegration(
        Effect.gen(function* () {
          const result = yield* Effect.either(rollbackTransaction());
          assert.isTrue(Either.isLeft(result));
          if (Either.isLeft(result)) {
            assert.isTrue(result.left instanceof NoActiveTransactionError);
          }
        }),
      ),
  );
});
