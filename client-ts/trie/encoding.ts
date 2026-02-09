import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Schema from "effect/Schema";
import type { BytesType } from "./Node";

/** Error raised when nibble encoding/decoding fails. */
export class NibbleEncodingError extends Data.TaggedError(
  "NibbleEncodingError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

const isNibbleList = (nibbles: Uint8Array): boolean => {
  for (const nibble of nibbles) {
    if (nibble > 0x0f) {
      return false;
    }
  }
  return true;
};

/** Schema for validating nibble lists (values 0x0 through 0xf). */
export const NibbleListSchema: Schema.Schema<Uint8Array, Uint8Array> =
  Schema.Uint8ArrayFromSelf.pipe(
    Schema.filter(isNibbleList, {
      message: () => "Nibble list must contain values between 0x0 and 0xf",
    }),
  );

/** Nibble list type used by trie paths. */
export type NibbleList = BytesType;

/** Decoded hex-prefix path with leaf flag. */
export interface HexPrefixDecoded {
  readonly nibbles: NibbleList;
  readonly isLeaf: boolean;
}

const EmptyNibbles = new Uint8Array(0) as NibbleList;
const SingleNibbleCache = Array.from(
  { length: 16 },
  (_, nibble) => new Uint8Array([nibble]) as NibbleList,
);
const DoubleNibbleCache = Array.from(
  { length: 256 },
  (_, value) =>
    new Uint8Array([(value >> 4) & 0x0f, value & 0x0f]) as NibbleList,
);
const TripleNibbleCache = Array.from(
  { length: 4096 },
  (_, value) =>
    new Uint8Array([
      (value >> 8) & 0x0f,
      (value >> 4) & 0x0f,
      value & 0x0f,
    ]) as NibbleList,
);

const validateNibbleList = (
  nibbles: BytesType,
): Effect.Effect<NibbleList, NibbleEncodingError> =>
  Schema.decode(NibbleListSchema)(nibbles).pipe(
    Effect.map((validated) => validated as NibbleList),
    Effect.mapError(
      (cause) =>
        new NibbleEncodingError({
          message: "Invalid nibble list",
          cause,
        }),
    ),
  );

/** Convert a byte array into a nibble list (two nibbles per byte). */
export const bytesToNibbleList = (
  bytes: BytesType,
): Effect.Effect<NibbleList> =>
  Effect.sync(() => {
    if (bytes.length === 0) {
      return EmptyNibbles;
    }
    if (bytes.length === 1) {
      return DoubleNibbleCache[bytes[0]!]!;
    }
    const nibbles = new Uint8Array(bytes.length * 2);
    for (let i = 0; i < bytes.length; i += 1) {
      const byte = bytes[i]!;
      nibbles[i * 2] = (byte & 0xf0) >> 4;
      nibbles[i * 2 + 1] = byte & 0x0f;
    }
    return nibbles as NibbleList;
  });

/** Decode a hex-prefix compact-encoded path into nibbles and leaf flag. */
export const compactToNibbleList = (
  compact: BytesType,
): Effect.Effect<HexPrefixDecoded, NibbleEncodingError> =>
  Effect.gen(function* () {
    if (compact.length === 0) {
      return yield* Effect.fail(
        new NibbleEncodingError({ message: "Compact path cannot be empty" }),
      );
    }

    const first = compact[0]!;
    const isEven = (first & 0x10) === 0;
    const isLeaf = (first & 0x20) !== 0;
    const nibbleCount = compact.length * 2 - (isEven ? 2 : 1);

    switch (nibbleCount) {
      case 0:
        return { nibbles: EmptyNibbles, isLeaf };
      case 1:
        return { nibbles: SingleNibbleCache[first & 0x0f]!, isLeaf };
      case 2: {
        const second = compact[1];
        if (second === undefined) {
          return yield* Effect.fail(
            new NibbleEncodingError({ message: "Compact path is truncated" }),
          );
        }
        return { nibbles: DoubleNibbleCache[second]!, isLeaf };
      }
      case 3: {
        const second = compact[1];
        if (second === undefined) {
          return yield* Effect.fail(
            new NibbleEncodingError({ message: "Compact path is truncated" }),
          );
        }
        const index = ((first & 0x0f) << 8) | second;
        return { nibbles: TripleNibbleCache[index]!, isLeaf };
      }
      default:
        break;
    }

    const nibbles = new Uint8Array(nibbleCount);
    let offset = 0;
    if (!isEven) {
      nibbles[offset] = first & 0x0f;
      offset += 1;
    }
    for (let i = 1; i < compact.length; i += 1) {
      const byte = compact[i]!;
      nibbles[offset] = (byte & 0xf0) >> 4;
      offset += 1;
      if (offset < nibbleCount) {
        nibbles[offset] = byte & 0x0f;
        offset += 1;
      }
    }

    return { nibbles: nibbles as NibbleList, isLeaf };
  });

/** Encode a nibble list into a hex-prefix compact path. */
export const nibbleListToCompact = (
  nibbles: BytesType,
  isLeaf: boolean,
): Effect.Effect<BytesType, NibbleEncodingError> =>
  Effect.gen(function* () {
    const validated = yield* validateNibbleList(nibbles);
    const isEven = validated.length % 2 === 0;
    const compact = new Uint8Array(1 + Math.floor(validated.length / 2));

    if (isEven) {
      compact[0] = isLeaf ? 0x20 : 0x00;
      for (let i = 0; i < validated.length; i += 2) {
        const high = validated[i];
        const low = validated[i + 1];
        if (high === undefined || low === undefined) {
          return yield* Effect.fail(
            new NibbleEncodingError({
              message: "Invalid even-length nibble list",
            }),
          );
        }
        compact[1 + i / 2] = (high << 4) | low;
      }
      return compact as BytesType;
    }

    const first = validated[0];
    if (first === undefined) {
      return yield* Effect.fail(
        new NibbleEncodingError({
          message: "Invalid odd-length nibble list",
        }),
      );
    }
    compact[0] = (isLeaf ? 0x30 : 0x10) | first;
    for (let i = 1; i < validated.length; i += 2) {
      const high = validated[i];
      const low = validated[i + 1];
      if (high === undefined || low === undefined) {
        return yield* Effect.fail(
          new NibbleEncodingError({
            message: "Invalid odd-length nibble list",
          }),
        );
      }
      compact[1 + (i - 1) / 2] = (high << 4) | low;
    }
    return compact as BytesType;
  });
