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
