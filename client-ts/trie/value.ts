import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import { AccountState, Rlp } from "voltaire-effect/primitives";
import type { BytesType } from "./Node";
import { coerceEffect } from "./internal/effect";
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

const EmptyBytes = bytesFromHex("0x");

const negativeIntegerError = (value: bigint) =>
  new TrieValueEncodingError({
    message: `Account integer must be non-negative, received ${value}`,
  });

const wrapHexError = (cause: unknown) =>
  new TrieValueEncodingError({
    message: "Failed to encode account integer",
    cause,
  });

const wrapRlpError = (cause: unknown) =>
  new TrieValueEncodingError({
    message: "Failed to RLP-encode account state",
    cause,
  });

const wrapBytesError = (cause: unknown) =>
  new TrieValueEncodingError({
    message: "Invalid encoded account bytes",
    cause,
  });

const bytesFromHexEffect = (hex: string) =>
  Effect.try({
    try: () => bytesFromHex(hex),
    catch: (cause) => wrapHexError(cause),
  });

const bigintToMinimalBytes = (
  value: bigint,
): Effect.Effect<BytesType, TrieValueEncodingError> =>
  Effect.gen(function* () {
    if (value < 0n) {
      return yield* Effect.fail(negativeIntegerError(value));
    }
    if (value === 0n) {
      return EmptyBytes;
    }

    const hex = value.toString(16);
    const evenHex = hex.length % 2 === 0 ? hex : `0${hex}`;
    return yield* bytesFromHexEffect(`0x${evenHex}`);
  });

const encodeRlp = (data: Parameters<typeof Rlp.encode>[0]) =>
  coerceEffect<Uint8Array, unknown>(Rlp.encode(data)).pipe(
    Effect.mapError(wrapRlpError),
  );

const toBytes = (
  value: Uint8Array,
): Effect.Effect<BytesType, TrieValueEncodingError> =>
  Effect.try({
    try: () => bytesFromUint8Array(value),
    catch: (cause) => wrapBytesError(cause),
  });

/** Encode an account state into its RLP trie value. */
export const encodeAccount = (
  account: AccountState.AccountStateType,
): Effect.Effect<BytesType, TrieValueEncodingError> =>
  Effect.gen(function* () {
    const nonceBytes = yield* bigintToMinimalBytes(account.nonce);
    const balanceBytes = yield* bigintToMinimalBytes(account.balance);
    const encoded = yield* encodeRlp([
      nonceBytes,
      balanceBytes,
      account.storageRoot,
      account.codeHash,
    ]);
    return yield* toBytes(encoded);
  });
