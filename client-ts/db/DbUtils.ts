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
