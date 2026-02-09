import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import { Address } from "voltaire-effect/primitives";
import {
  EMPTY_ACCOUNT,
  isTotallyEmpty,
  type AccountStateType,
} from "./Account";
import {
  WorldStateTest,
  UnknownSnapshotError,
  commitSnapshot,
  destroyAccount,
  getAccount,
  getAccountOptional,
  markAccountCreated,
  restoreSnapshot,
  setAccount,
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
});
