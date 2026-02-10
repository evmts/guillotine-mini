import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import { Bytes } from "voltaire-effect/primitives";

type BytesType = ReturnType<typeof Bytes.random>;

/** Maximum accepted Snappy uncompressed payload size for RLPx messages (16 MiB). */
export const RlpxMaxSnappyUncompressedLength = 1024 * 1024 * 16;

/** Failure reasons when decoding Snappy's uncompressed length header. */
export type RlpxSnappyLengthHeaderReason =
  | "EmptyPayload"
  | "TruncatedLength"
  | "LengthOverflow";

/** Error raised when Snappy length header parsing fails. */
export class RlpxSnappyLengthHeaderError extends Data.TaggedError(
  "RlpxSnappyLengthHeaderError",
)<{
  readonly reason: RlpxSnappyLengthHeaderReason;
}> {}

/** Error raised when a Snappy payload exceeds the RLPx 16 MiB uncompressed limit. */
export class RlpxSnappyLengthExceededError extends Data.TaggedError(
  "RlpxSnappyLengthExceededError",
)<{
  readonly actualLength: number;
  readonly maxLength: number;
}> {}

/** Errors emitted while decoding or bounds-checking Snappy uncompressed length. */
export type RlpxSnappyLengthValidationError =
  | RlpxSnappyLengthHeaderError
  | RlpxSnappyLengthExceededError;

/** Service contract for decoding and validating RLPx Snappy payload sizes. */
export interface RlpxSnappyLengthValidatorService {
  readonly validateUncompressedLength: (
    compressedPayload: BytesType,
  ) => Effect.Effect<number, RlpxSnappyLengthValidationError>;
}

/** Context tag for the RLPx Snappy length validator. */
export class RlpxSnappyLengthValidator extends Context.Tag(
  "RlpxSnappyLengthValidator",
)<RlpxSnappyLengthValidator, RlpxSnappyLengthValidatorService>() {}

const failLengthHeader = (
  reason: RlpxSnappyLengthHeaderReason,
): Effect.Effect<never, RlpxSnappyLengthHeaderError> =>
  Effect.fail(new RlpxSnappyLengthHeaderError({ reason }));

const decodeSnappyLengthHeader = (
  compressedPayload: BytesType,
): Effect.Effect<number, RlpxSnappyLengthHeaderError> =>
  Effect.gen(function* () {
    const bytes = compressedPayload as Uint8Array;

    if (bytes.length === 0) {
      return yield* failLengthHeader("EmptyPayload");
    }

    let length = 0;
    let shift = 0;

    for (let index = 0; index < bytes.length; index += 1) {
      const current = bytes[index]!;
      const value = current & 0x7f;
      const hasContinuation = (current & 0x80) !== 0;

      if (shift === 28 && (value > 0x0f || hasContinuation)) {
        return yield* failLengthHeader("LengthOverflow");
      }

      const increment = value * 2 ** shift;
      const next = length + increment;

      if (!Number.isSafeInteger(next)) {
        return yield* failLengthHeader("LengthOverflow");
      }

      length = next;

      if (!hasContinuation) {
        return length;
      }

      shift += 7;
    }

    return yield* failLengthHeader("TruncatedLength");
  });

const makeRlpxSnappyLengthValidator =
  Effect.succeed<RlpxSnappyLengthValidatorService>({
    validateUncompressedLength: (compressedPayload) =>
      Effect.gen(function* () {
        const uncompressedLength =
          yield* decodeSnappyLengthHeader(compressedPayload);

        if (uncompressedLength > RlpxMaxSnappyUncompressedLength) {
          return yield* Effect.fail(
            new RlpxSnappyLengthExceededError({
              actualLength: uncompressedLength,
              maxLength: RlpxMaxSnappyUncompressedLength,
            }),
          );
        }

        return uncompressedLength;
      }),
  } satisfies RlpxSnappyLengthValidatorService);

/** Live RLPx Snappy length validator layer. */
export const RlpxSnappyLengthValidatorLive: Layer.Layer<RlpxSnappyLengthValidator> =
  Layer.effect(RlpxSnappyLengthValidator, makeRlpxSnappyLengthValidator);

/** Test RLPx Snappy length validator layer. */
export const RlpxSnappyLengthValidatorTest: Layer.Layer<RlpxSnappyLengthValidator> =
  RlpxSnappyLengthValidatorLive;

/** Validate Snappy uncompressed length header against RLPx limits. */
export const validateRlpxSnappyUncompressedLength = (
  compressedPayload: BytesType,
) =>
  Effect.gen(function* () {
    const validator = yield* RlpxSnappyLengthValidator;
    return yield* validator.validateUncompressedLength(compressedPayload);
  });
