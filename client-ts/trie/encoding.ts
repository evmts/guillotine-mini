import { Bytes } from "@tevm/voltaire/Bytes";
import type { BytesType } from "@tevm/voltaire/Bytes";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Schema from "effect/Schema";

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

export const NibbleListSchema: Schema.Schema<Uint8Array, Uint8Array> =
  Schema.Uint8ArrayFromSelf.pipe(
    Schema.filter(isNibbleList, {
      message: () => "Nibble list must contain values between 0x0 and 0xf",
    }),
  );

export type NibbleList = BytesType;

const validateNibbleList = (
  nibbles: BytesType,
): Effect.Effect<NibbleList, NibbleEncodingError> =>
  Effect.try({
    try: () => Schema.decodeSync(NibbleListSchema)(nibbles) as BytesType,
    catch: (cause) =>
      new NibbleEncodingError({
        message: "Invalid nibble list",
        cause,
      }),
  });

export const bytesToNibbleList = (
  bytes: BytesType,
): Effect.Effect<NibbleList> =>
  Effect.sync(() => {
    const nibbles = new Uint8Array(bytes.length * 2);
    for (let i = 0; i < bytes.length; i += 1) {
      const byte = bytes[i]!;
      nibbles[i * 2] = (byte & 0xf0) >> 4;
      nibbles[i * 2 + 1] = byte & 0x0f;
    }
    return Bytes.from(nibbles);
  });

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
      return Bytes.from(compact);
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
    return Bytes.from(compact);
  });
