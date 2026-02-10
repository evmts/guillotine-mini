import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import { Bytes, Hex } from "voltaire-effect/primitives";
import {
  RlpxMaxSnappyUncompressedLength,
  RlpxSnappyLengthExceededError,
  RlpxSnappyLengthHeaderError,
  RlpxSnappyLengthValidatorLive,
  validateRlpxSnappyUncompressedLength,
} from "./RlpxSnappyLengthValidator";

type BytesType = ReturnType<typeof Bytes.random>;

const toBytes = (value: string): BytesType => Hex.toBytes(value) as BytesType;

const provideValidator = <A, E, R>(effect: Effect.Effect<A, E, R>) =>
  effect.pipe(Effect.provide(RlpxSnappyLengthValidatorLive));

describe("RlpxSnappyLengthValidator", () => {
  it.effect("reads Snappy uncompressed length from payload header", () =>
    provideValidator(
      Effect.gen(function* () {
        const length = yield* validateRlpxSnappyUncompressedLength(
          toBytes("0xac02ff"),
        );

        assert.strictEqual(length, 300);
      }),
    ),
  );

  it.effect("accepts payload length exactly at the RLPx 16 MiB limit", () =>
    provideValidator(
      Effect.gen(function* () {
        const length = yield* validateRlpxSnappyUncompressedLength(
          toBytes("0x80808008"),
        );

        assert.strictEqual(length, RlpxMaxSnappyUncompressedLength);
      }),
    ),
  );

  it.effect("rejects payload length above the RLPx 16 MiB limit", () =>
    provideValidator(
      Effect.gen(function* () {
        const outcome = yield* validateRlpxSnappyUncompressedLength(
          toBytes("0x81808008"),
        ).pipe(Effect.either);

        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          const error = outcome.left;
          if (error instanceof RlpxSnappyLengthExceededError) {
            assert.strictEqual(error.actualLength, 16_777_217);
            assert.strictEqual(
              error.maxLength,
              RlpxMaxSnappyUncompressedLength,
            );
          } else {
            assert.fail(`Expected RlpxSnappyLengthExceededError, got ${error}`);
          }
        }
      }),
    ),
  );

  it.effect("rejects empty payloads with a typed header error", () =>
    provideValidator(
      Effect.gen(function* () {
        const outcome = yield* validateRlpxSnappyUncompressedLength(
          toBytes("0x"),
        ).pipe(Effect.either);

        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          const error = outcome.left;
          if (error instanceof RlpxSnappyLengthHeaderError) {
            assert.strictEqual(error.reason, "EmptyPayload");
          } else {
            assert.fail(`Expected RlpxSnappyLengthHeaderError, got ${error}`);
          }
        }
      }),
    ),
  );

  it.effect("rejects truncated Snappy length headers", () =>
    provideValidator(
      Effect.gen(function* () {
        const outcome = yield* validateRlpxSnappyUncompressedLength(
          toBytes("0x80"),
        ).pipe(Effect.either);

        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          const error = outcome.left;
          if (error instanceof RlpxSnappyLengthHeaderError) {
            assert.strictEqual(error.reason, "TruncatedLength");
          } else {
            assert.fail(`Expected RlpxSnappyLengthHeaderError, got ${error}`);
          }
        }
      }),
    ),
  );

  it.effect("rejects overflowing Snappy length headers", () =>
    provideValidator(
      Effect.gen(function* () {
        const outcome = yield* validateRlpxSnappyUncompressedLength(
          toBytes("0x808080808001"),
        ).pipe(Effect.either);

        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          const error = outcome.left;
          if (error instanceof RlpxSnappyLengthHeaderError) {
            assert.strictEqual(error.reason, "LengthOverflow");
          } else {
            assert.fail(`Expected RlpxSnappyLengthHeaderError, got ${error}`);
          }
        }
      }),
    ),
  );
});
