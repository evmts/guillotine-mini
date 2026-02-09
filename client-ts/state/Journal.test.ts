import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import { Address } from "voltaire-effect/primitives";
import { EMPTY_ACCOUNT, type AccountStateType } from "./Account";
import {
  ChangeTag,
  EMPTY_SNAPSHOT,
  InvalidSnapshotError,
  JournalTest,
  append,
  clear,
  commit,
  entries,
  restore,
  takeSnapshot,
  type JournalEntry,
} from "./Journal";

const makeAccount = (
  overrides: Partial<Omit<AccountStateType, "__tag">> = {},
): AccountStateType => ({
  ...EMPTY_ACCOUNT,
  ...overrides,
});

const makeEntry = (
  key: Address.AddressType,
  value: AccountStateType | null,
  tag: (typeof ChangeTag)[keyof typeof ChangeTag],
): JournalEntry<Address.AddressType, AccountStateType> => ({
  key,
  value,
  tag,
});

const provideJournal = <A, E, R>(effect: Effect.Effect<A, E, R>) =>
  effect.pipe(
    Effect.provide(JournalTest<Address.AddressType, AccountStateType>()),
  );

describe("Journal", () => {
  it.effect("appends entries and returns sequential indices", () =>
    provideJournal(
      Effect.gen(function* () {
        const addrA = Address.zero();
        const addrB = Address.zero();

        const idxA = yield* append(
          makeEntry(addrA, makeAccount({ nonce: 1n }), ChangeTag.Create),
        );
        const idxB = yield* append(
          makeEntry(addrB, makeAccount({ nonce: 2n }), ChangeTag.Update),
        );

        assert.strictEqual(idxA, 0);
        assert.strictEqual(idxB, 1);

        const all = yield* entries<Address.AddressType, AccountStateType>();
        assert.strictEqual(all.length, 2);
      }),
    ),
  );

  it.effect("takeSnapshot returns sentinel for empty journal", () =>
    provideJournal(
      Effect.gen(function* () {
        const emptySnapshot = yield* takeSnapshot();
        assert.strictEqual(emptySnapshot, EMPTY_SNAPSHOT);

        const addr = Address.zero();
        yield* append(
          makeEntry(addr, makeAccount({ nonce: 3n }), ChangeTag.Create),
        );

        const snapshot = yield* takeSnapshot();
        assert.strictEqual(snapshot, 0);
      }),
    ),
  );

  it.effect("restore truncates and preserves just-cache entries", () =>
    provideJournal(
      Effect.gen(function* () {
        const address = Address.zero();

        yield* append(
          makeEntry(address, makeAccount({ nonce: 1n }), ChangeTag.Create),
        );
        const snapshot = yield* takeSnapshot();
        yield* append(
          makeEntry(address, makeAccount({ nonce: 2n }), ChangeTag.Update),
        );
        yield* append(makeEntry(address, makeAccount(), ChangeTag.JustCache));
        yield* append(makeEntry(address, null, ChangeTag.Delete));

        const reverted: Array<(typeof ChangeTag)[keyof typeof ChangeTag]> = [];
        const onRevert = (
          entry: JournalEntry<Address.AddressType, AccountStateType>,
        ) =>
          Effect.sync(() => {
            reverted.push(entry.tag);
          });

        yield* restore(snapshot, onRevert);

        const all = yield* entries<Address.AddressType, AccountStateType>();
        assert.strictEqual(all.length, 2);

        const first = all[0];
        const second = all[1];
        if (!first || !second) {
          throw new Error("Expected two entries after restore");
        }

        assert.strictEqual(first.tag, ChangeTag.Create);
        assert.strictEqual(second.tag, ChangeTag.JustCache);

        assert.strictEqual(reverted.length, 2);
        const firstReverted = reverted[0];
        const secondReverted = reverted[1];
        if (!firstReverted || !secondReverted) {
          throw new Error("Expected two reverted entries");
        }
        assert.strictEqual(firstReverted, ChangeTag.Delete);
        assert.strictEqual(secondReverted, ChangeTag.Update);
      }),
    ),
  );

  it.effect("restore fails for invalid snapshots", () =>
    provideJournal(
      Effect.gen(function* () {
        const addr = Address.zero();
        yield* append(
          makeEntry(addr, makeAccount({ nonce: 1n }), ChangeTag.Create),
        );

        const outcome = yield* Effect.either(restore(5));
        assert.isTrue(Either.isLeft(outcome));

        if (Either.isLeft(outcome)) {
          const error = outcome.left;
          assert.isTrue(error instanceof InvalidSnapshotError);
        }
      }),
    ),
  );

  it.effect("commit invokes callback and truncates entries", () =>
    provideJournal(
      Effect.gen(function* () {
        const addrA = Address.zero();
        const addrB = Address.zero();
        const addrC = Address.zero();

        yield* append(
          makeEntry(addrA, makeAccount({ nonce: 1n }), ChangeTag.Create),
        );
        const snapshot = yield* takeSnapshot();
        yield* append(
          makeEntry(addrB, makeAccount({ nonce: 2n }), ChangeTag.Update),
        );
        yield* append(
          makeEntry(addrC, makeAccount({ nonce: 3n }), ChangeTag.Update),
        );

        const committed: bigint[] = [];
        const onCommit = (
          entry: JournalEntry<Address.AddressType, AccountStateType>,
        ) =>
          Effect.sync(() => {
            if (!entry.value) {
              throw new Error("Expected committed entry to have a value");
            }
            committed.push(entry.value.nonce);
          });

        yield* commit(snapshot, onCommit);

        const all = yield* entries<Address.AddressType, AccountStateType>();
        assert.strictEqual(all.length, 1);
        assert.strictEqual(committed.length, 2);
        const firstCommitted = committed[0];
        const secondCommitted = committed[1];
        if (!firstCommitted || !secondCommitted) {
          throw new Error("Expected two committed entries");
        }
        assert.strictEqual(firstCommitted, 2n);
        assert.strictEqual(secondCommitted, 3n);
      }),
    ),
  );

  it.effect("clear drops all entries", () =>
    provideJournal(
      Effect.gen(function* () {
        const addr = Address.zero();
        yield* append(makeEntry(addr, makeAccount(), ChangeTag.JustCache));
        yield* clear();

        const all = yield* entries<Address.AddressType, AccountStateType>();
        assert.strictEqual(all.length, 0);
      }),
    ),
  );
});
