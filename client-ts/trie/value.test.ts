import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import * as Schema from "effect/Schema";
import {
  AccountState,
  Address,
  Bytes,
  Hash,
  Hex,
  Receipt,
  Rlp,
  Transaction,
  Uint,
} from "voltaire-effect/primitives";
import { coerceEffect } from "./internal/effect";
import { makeBytesHelpers } from "./internal/primitives";
import {
  encodeAccount,
  encodeTrieValue,
  TrieValueEncodingError,
} from "./value";

const { bytesFromHex, bytesFromUint8Array } = makeBytesHelpers(
  (message) => new Error(message),
);

const EmptyBytes = bytesFromHex("0x");

const encodeRlp = (data: Parameters<typeof Rlp.encode>[0]) =>
  coerceEffect<Uint8Array, unknown>(Rlp.encode(data));

const toU256 = (value: bigint) =>
  coerceEffect<Parameters<typeof Uint.toBigInt>[0], Error>(
    Uint.fromBigInt(value),
  );

const TransactionSerializedSchema =
  Transaction.Serialized as unknown as Schema.Schema<
    Transaction.Any,
    Uint8Array
  >;
const LegacySchema = Transaction.LegacySchema as unknown as Schema.Schema<
  Transaction.Legacy,
  unknown
>;

const EMPTY_SIGNATURE = {
  r: new Uint8Array(32),
  s: new Uint8Array(32),
};

const makeLegacyTx = (): Transaction.Legacy =>
  Schema.validateSync(LegacySchema)({
    type: Transaction.Type.Legacy,
    nonce: 0n,
    gasPrice: 1n,
    gasLimit: 21_000n,
    to: Hex.fromBytes(Address.zero()),
    value: 0n,
    data: new Uint8Array(0),
    v: 27n,
    r: EMPTY_SIGNATURE.r,
    s: EMPTY_SIGNATURE.s,
  });

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

describe("trie value encoding", () => {
  it.effect("passes through raw bytes", () =>
    Effect.gen(function* () {
      const value = bytesFromHex("0x1234");
      const encoded = yield* encodeTrieValue(value);
      assert.isTrue(Bytes.equals(encoded, value));
    }),
  );

  it.effect("encodes U256 values as RLP", () =>
    Effect.gen(function* () {
      const value = yield* toU256(128n);
      const encoded = yield* encodeTrieValue(value);
      const expected = yield* encodeRlp(bytesFromHex("0x80"));

      assert.isTrue(Bytes.equals(encoded, bytesFromUint8Array(expected)));
    }),
  );

  it.effect("encodes transactions using serialized RLP bytes", () =>
    Effect.gen(function* () {
      const tx = makeLegacyTx();
      const expected = Schema.encodeSync(TransactionSerializedSchema)(tx);
      const encoded = yield* encodeTrieValue(tx);

      assert.isTrue(Bytes.equals(encoded, bytesFromUint8Array(expected)));
    }),
  );

  it.effect("encodes receipts as RLP lists", () =>
    Effect.gen(function* () {
      const receipt: Receipt.ReceiptType = {
        transactionHash: Hash.ZERO,
        blockNumber: 0n,
        blockHash: Hash.ZERO,
        transactionIndex: 0,
        from: Address.zero(),
        to: Address.zero(),
        cumulativeGasUsed: 1n,
        gasUsed: 1n,
        effectiveGasPrice: 0n,
        contractAddress: null,
        logs: [
          {
            address: Address.zero(),
            topics: [Hash.ZERO],
            data: new Uint8Array([0x01]),
            blockNumber: 0n,
            transactionHash: Hash.ZERO,
            transactionIndex: 0,
            blockHash: Hash.ZERO,
            logIndex: 0,
            removed: false,
          },
        ],
        logsBloom: new Uint8Array(256),
        root: Hash.ZERO,
        type: "legacy",
      };

      const root = receipt.root ?? Hash.ZERO;
      const expected = yield* encodeRlp([
        root,
        bytesFromHex("0x01"),
        receipt.logsBloom,
        receipt.logs.map((log) => [
          log.address,
          Array.from(log.topics),
          log.data,
        ]),
      ]);
      const encoded = yield* encodeTrieValue(receipt);

      assert.isTrue(Bytes.equals(encoded, bytesFromUint8Array(expected)));
    }),
  );
});
