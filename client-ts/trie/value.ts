import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Schema from "effect/Schema";
import {
  AccountState,
  Bytes,
  Receipt,
  Rlp,
  Transaction,
  Uint,
} from "voltaire-effect/primitives";
import { coerceEffect } from "./internal/effect";
import type { BytesType } from "./Node";
import { encodeRlp as encodeRlpGeneric } from "./internal/rlp";
import { makeBytesHelpers } from "./internal/primitives";

/** Error raised when encoding trie values fails. */
export class TrieValueEncodingError extends Data.TaggedError(
  "TrieValueEncodingError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

const { bytesFromHex, bytesFromUint8Array } = makeBytesHelpers(
  (message) => new TrieValueEncodingError({ message }),
);

type U256Type = Parameters<typeof Uint.toBigInt>[0];

/** Trie value types that require encoding for storage. */
export type TrieValue =
  | BytesType
  | AccountState.AccountStateType
  | Transaction.Any
  | Receipt.ReceiptType
  | U256Type;

const EmptyBytes = bytesFromHex("0x");

const negativeIntegerError = (label: string, value: bigint) =>
  new TrieValueEncodingError({
    message: `${label} must be non-negative, received ${value}`,
  });

const wrapHexError = (cause: unknown) =>
  new TrieValueEncodingError({
    message: "Failed to encode integer bytes",
    cause,
  });

const wrapRlpError = (cause: unknown) =>
  new TrieValueEncodingError({
    message: "Failed to RLP-encode trie value",
    cause,
  });

const wrapBytesError = (cause: unknown) =>
  new TrieValueEncodingError({
    message: "Invalid encoded trie bytes",
    cause,
  });

const wrapTransactionError = (cause: unknown) =>
  new TrieValueEncodingError({
    message: "Failed to encode transaction",
    cause,
  });

const wrapUnsupportedError = (value: unknown) =>
  new TrieValueEncodingError({
    message: `Unsupported trie value ${typeof value}`,
    cause: value,
  });

const bytesFromHexEffect = (hex: string) =>
  Effect.try({
    try: () => bytesFromHex(hex),
    catch: (cause) => wrapHexError(cause),
  });

const bigintToMinimalBytes = (
  value: bigint,
  label: string,
): Effect.Effect<BytesType, TrieValueEncodingError> =>
  Effect.gen(function* () {
    if (value < 0n) {
      return yield* Effect.fail(negativeIntegerError(label, value));
    }
    if (value === 0n) {
      return EmptyBytes;
    }

    const hex = value.toString(16);
    const evenHex = hex.length % 2 === 0 ? hex : `0${hex}`;
    return yield* bytesFromHexEffect(`0x${evenHex}`);
  });

const encodeRlp = (data: Parameters<typeof Rlp.encode>[0]) =>
  encodeRlpGeneric(data).pipe(Effect.mapError(wrapRlpError));

const toBytes = (
  value: Uint8Array,
): Effect.Effect<BytesType, TrieValueEncodingError> =>
  Effect.try({
    try: () => bytesFromUint8Array(value),
    catch: (cause) => wrapBytesError(cause),
  });

const TransactionSerializedSchema =
  Transaction.Serialized as unknown as Schema.Schema<
    Transaction.Any,
    Uint8Array
  >;

const isTransaction = (value: unknown): value is Transaction.Any =>
  Transaction.isLegacy(value as Transaction.Any) ||
  Transaction.isEIP2930(value as Transaction.Any) ||
  Transaction.isEIP1559(value as Transaction.Any) ||
  Transaction.isEIP4844(value as Transaction.Any) ||
  Transaction.isEIP7702(value as Transaction.Any);

const isReceipt = Schema.is(
  Receipt.Schema as unknown as Schema.Schema<Receipt.ReceiptType, unknown>,
);

const isAccountState = Schema.is(
  AccountState.AccountStateSchema as unknown as Schema.Schema<
    AccountState.AccountStateType,
    unknown
  >,
);

const receiptTypePrefix: Record<Receipt.ReceiptType["type"], number | null> = {
  legacy: null,
  eip2930: 1,
  eip1559: 2,
  eip4844: 3,
  eip7702: 4,
};

const encodeTransaction = (tx: Transaction.Any) =>
  Effect.try({
    try: () => Schema.encodeSync(TransactionSerializedSchema)(tx),
    catch: (cause) => wrapTransactionError(cause),
  }).pipe(Effect.flatMap(toBytes));

const encodeReceipt = (receipt: Receipt.ReceiptType) =>
  Effect.gen(function* () {
    const rootOrStatus =
      receipt.root !== undefined
        ? receipt.root
        : receipt.status !== undefined
          ? yield* bigintToMinimalBytes(
              BigInt(receipt.status),
              "Receipt status",
            )
          : yield* Effect.fail(
              new TrieValueEncodingError({
                message: "Receipt must include status or state root",
              }),
            );

    const cumulativeGas = yield* bigintToMinimalBytes(
      receipt.cumulativeGasUsed,
      "Receipt cumulative gas used",
    );
    const bloom = yield* toBytes(receipt.logsBloom);
    const logs = receipt.logs.map((log) => [
      log.address,
      Array.from(log.topics),
      log.data,
    ]);

    const encoded = yield* encodeRlp([
      rootOrStatus,
      cumulativeGas,
      bloom,
      logs,
    ]);

    const prefix = receiptTypePrefix[receipt.type];
    if (prefix === null) {
      return yield* toBytes(encoded);
    }

    const prefixed = new Uint8Array(encoded.length + 1);
    prefixed[0] = prefix;
    prefixed.set(encoded, 1);
    return yield* toBytes(prefixed);
  });

const encodeU256 = (value: U256Type) =>
  Effect.gen(function* () {
    const bigInt = yield* coerceEffect<bigint, never>(Uint.toBigInt(value));
    const minimal = yield* bigintToMinimalBytes(bigInt, "U256");
    const encoded = yield* encodeRlp(minimal);
    return yield* toBytes(encoded);
  });

/** Encode an account state into its RLP trie value. */
export const encodeAccount = (
  account: AccountState.AccountStateType,
): Effect.Effect<BytesType, TrieValueEncodingError> =>
  Effect.gen(function* () {
    const nonceBytes = yield* bigintToMinimalBytes(
      account.nonce,
      "Account nonce",
    );
    const balanceBytes = yield* bigintToMinimalBytes(
      account.balance,
      "Account balance",
    );
    const encoded = yield* encodeRlp([
      nonceBytes,
      balanceBytes,
      account.storageRoot,
      account.codeHash,
    ]);
    return yield* toBytes(encoded);
  });

/** Encode a trie value for storage (bytes passthrough, RLP for others). */
export const encodeTrieValue = (
  value: TrieValue,
): Effect.Effect<BytesType, TrieValueEncodingError> =>
  Effect.gen(function* () {
    if (Bytes.isBytes(value)) {
      return yield* toBytes(value as Uint8Array);
    }
    if (isAccountState(value)) {
      return yield* encodeAccount(value);
    }
    if (isTransaction(value)) {
      return yield* encodeTransaction(value);
    }
    if (isReceipt(value)) {
      return yield* encodeReceipt(value);
    }
    if (Uint.isUint256(value)) {
      return yield* encodeU256(value);
    }
    return yield* Effect.fail(wrapUnsupportedError(value));
  });
