import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import {
  EMPTY_ACCOUNT,
  hasCodeOrNonce,
  isAccountAlive,
  isContract,
  isEmpty,
  isTotallyEmpty,
  type AccountStateType,
} from "./Account";

const customBytes32 = (byte: number): AccountStateType["codeHash"] => {
  const value = new Uint8Array(32);
  value.fill(byte);
  return value as AccountStateType["codeHash"];
};

const makeAccount = (
  overrides: Partial<Omit<AccountStateType, "__tag">> = {},
): AccountStateType => ({
  ...EMPTY_ACCOUNT,
  ...overrides,
});

describe("Account helpers", () => {
  it.effect("treats EMPTY_ACCOUNT as empty, totally empty, and not alive", () =>
    Effect.gen(function* () {
      assert.isTrue(isEmpty(EMPTY_ACCOUNT));
      assert.isTrue(isTotallyEmpty(EMPTY_ACCOUNT));
      assert.isFalse(isAccountAlive(EMPTY_ACCOUNT));
      assert.isFalse(hasCodeOrNonce(EMPTY_ACCOUNT));
    }),
  );

  it.effect("detects non-empty accounts as alive", () =>
    Effect.gen(function* () {
      const account = makeAccount({ nonce: 1n });
      assert.isTrue(isAccountAlive(account));
    }),
  );

  it.effect("treats storage root as irrelevant for emptiness", () =>
    Effect.gen(function* () {
      const account = makeAccount({ storageRoot: customBytes32(0xab) });
      assert.isTrue(isEmpty(account));
      assert.isFalse(isTotallyEmpty(account));
    }),
  );

  it.effect("detects code hash for hasCodeOrNonce", () =>
    Effect.gen(function* () {
      const account = makeAccount({ codeHash: customBytes32(0xcd) });
      assert.isTrue(hasCodeOrNonce(account));
    }),
  );

  it.effect("detects contracts by code hash", () =>
    Effect.gen(function* () {
      assert.isFalse(isContract(EMPTY_ACCOUNT));
      const account = makeAccount({ codeHash: customBytes32(0xaa) });
      assert.isTrue(isContract(account));
    }),
  );

  it.effect("ignores balance-only for hasCodeOrNonce", () =>
    Effect.gen(function* () {
      const account = makeAccount({ balance: 1_000_000n });
      assert.isFalse(hasCodeOrNonce(account));
      assert.isFalse(isEmpty(account));
    }),
  );
});
