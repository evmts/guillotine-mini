import * as Effect from "effect/Effect";
import { Bytes, Hex } from "voltaire-effect/primitives";
import type { BytesType } from "./DbTypes";
import { DbError } from "./DbError";

/** Encode a DB key as a hex string suitable for map indexing. */
export const encodeKey = (key: BytesType): Effect.Effect<string, DbError> =>
  Effect.try({
    try: () => Hex.fromBytes(key),
    catch: (cause) => new DbError({ message: "Invalid DB key", cause }),
  });

/** Decode a hex-encoded DB key back into bytes. */
export const decodeKey = (keyHex: string): BytesType =>
  Hex.toBytes(keyHex) as BytesType;

/** Compare two byte arrays in lexicographic order. */
export const compareBytes = (left: BytesType, right: BytesType): number => {
  const leftBytes = left as Uint8Array;
  const rightBytes = right as Uint8Array;

  if (leftBytes === rightBytes) {
    return 0;
  }

  if (leftBytes.length === 0) {
    return rightBytes.length === 0 ? 0 : 1;
  }

  for (let index = 0; index < leftBytes.length; index += 1) {
    if (rightBytes.length <= index) {
      return -1;
    }

    const result = leftBytes[index]! - rightBytes[index]!;
    if (result !== 0) {
      return result < 0 ? -1 : 1;
    }
  }

  return rightBytes.length > leftBytes.length ? 1 : 0;
};

/** Clone a byte array value to avoid shared mutable buffers. */
export const cloneBytes = (value: BytesType): BytesType =>
  (value as Uint8Array).slice() as BytesType;

/** Clone a byte array value, failing if the input is not a byte array. */
export const cloneBytesEffect = (
  value: BytesType,
): Effect.Effect<BytesType, DbError> =>
  Bytes.isBytes(value)
    ? Effect.succeed(cloneBytes(value))
    : Effect.fail(new DbError({ message: "Invalid DB value" }));

/**
 * Return true if `key` starts with `prefix` using byte-wise comparison.
 *
 * This avoids Hex <-> Bytes conversions on hot paths and guarantees that
 * prefix filtering matches Nethermind's iterator expectations.
 */
export const startsWithBytes = (key: BytesType, prefix: BytesType): boolean => {
  const k = key as Uint8Array;
  const p = prefix as Uint8Array;
  if (p.length > k.length) return false;
  for (let i = 0; i < p.length; i++) {
    if (k[i] !== p[i]) return false;
  }
  return true;
};

/** Assert that an Option is Some and return the contained value for tests. */
export const expectSome = <A>(option: Option.Option<A>, message?: string): A => {
  if (Option.isSome(option)) return option.value;
  throw new Error(message ?? "Expected Some, got None");
};

/** Assert that an Option is None for tests. */
export const expectNone = <A>(option: Option.Option<A>, message?: string): void => {
  if (Option.isNone(option)) return;
  throw new Error(message ?? "Expected None, got Some");
};
