import { Bytes, Hash, Hex } from "voltaire-effect/primitives";
import type { BytesType, HashType } from "../Node";

/**
 * Build helpers that coerce byte input into voltaire Bytes with a custom error.
 */
export const makeBytesHelpers = (onError: (message: string) => Error) => {
  const isBytesType = (value: Uint8Array): value is BytesType =>
    Bytes.isBytes(value);

  const bytesFromUint8Array = (value: Uint8Array): BytesType => {
    if (!isBytesType(value)) {
      throw onError("Invalid bytes input");
    }
    return value;
  };

  const bytesFromHex = (hex: string): BytesType =>
    bytesFromUint8Array(Hex.toBytes(hex));

  return { bytesFromUint8Array, bytesFromHex };
};

/**
 * Build helpers that coerce hex input into voltaire hashes with a custom error.
 */
export const makeHashHelpers = (onError: (message: string) => Error) => {
  const hashFromHex = (hex: string): HashType => {
    const bytes = Hex.toBytes(hex);
    if (!Hash.isHash(bytes)) {
      throw onError("Invalid hash input");
    }
    return bytes;
  };

  return { hashFromHex };
};

/**
 * Compare two hashes synchronously.
 *
 * voltaire-effect's `Hash.equals` returns an `Effect<boolean>`. An Effect is an
 * object, so using it as a condition is always true.
 */
export const hashEquals = (left: HashType, right: HashType): boolean => {
  if (left.length !== right.length) return false;
  for (let index = 0; index < left.length; index += 1) {
    if (left[index] !== right[index]) return false;
  }
  return true;
};
