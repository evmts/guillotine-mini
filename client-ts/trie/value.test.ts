import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import { AccountState, Bytes, Rlp } from "voltaire-effect/primitives";
import { coerceEffect } from "./internal/effect";
import { makeBytesHelpers } from "./internal/primitives";
import { encodeAccount, TrieValueEncodingError } from "./value";

const { bytesFromHex, bytesFromUint8Array } = makeBytesHelpers(
  (message) => new Error(message),
);

const EmptyBytes = bytesFromHex("0x");

const encodeRlp = (data: Parameters<typeof Rlp.encode>[0]) =>
  coerceEffect<Uint8Array, unknown>(Rlp.encode(data));

const emptyAccount: AccountState.AccountStateType = {
  nonce: 0n,
  balance: 0n,
  codeHash: AccountState.EMPTY_CODE_HASH,
  storageRoot: AccountState.EMPTY_STORAGE_ROOT,
  __tag: "AccountState",
};

describe("trie account value encoding", () => {
  it.effect("encodes empty accounts with minimal integer bytes", () =>
    Effect.gen(function* () {
      const encoded = yield* encodeAccount(emptyAccount);
      const expected = yield* encodeRlp([
        EmptyBytes,
        EmptyBytes,
        emptyAccount.storageRoot,
        emptyAccount.codeHash,
      ]);

      assert.isTrue(Bytes.equals(encoded, bytesFromUint8Array(expected)));
    }),
  );

  it.effect("encodes non-zero balances without padding", () =>
    Effect.gen(function* () {
      const account: AccountState.AccountStateType = {
        ...emptyAccount,
        nonce: 1n,
        balance: 0xabcn,
      };
      const encoded = yield* encodeAccount(account);
      const expected = yield* encodeRlp([
        bytesFromHex("0x01"),
        bytesFromHex("0x0abc"),
        account.storageRoot,
        account.codeHash,
      ]);

      assert.isTrue(Bytes.equals(encoded, bytesFromUint8Array(expected)));
    }),
  );

  it.effect("fails on negative account fields", () =>
    Effect.gen(function* () {
      const account: AccountState.AccountStateType = {
        ...emptyAccount,
        nonce: -1n,
      };
      const result = yield* Effect.either(encodeAccount(account));

      assert.isTrue(Either.isLeft(result));
      if (Either.isLeft(result)) {
        assert.isTrue(result.left instanceof TrieValueEncodingError);
      }
    }),
  );
});
