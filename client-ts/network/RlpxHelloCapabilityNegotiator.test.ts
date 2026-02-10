import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import {
  RlpxCapabilityMessageIdStart,
  RlpxHelloCapabilityNegotiatorLive,
  RlpxHelloCapabilityValidationError,
  RlpxHelloMessageIdAllocationError,
  negotiateRlpxHelloCapabilities,
} from "./RlpxHelloCapabilityNegotiator";

const provideNegotiator = <A, E, R>(effect: Effect.Effect<A, E, R>) =>
  effect.pipe(Effect.provide(RlpxHelloCapabilityNegotiatorLive));

describe("RlpxHelloCapabilityNegotiator", () => {
  it.effect(
    "negotiates shared capabilities with highest version, alphabetic ordering, and 0x10-based offsets",
    () =>
      provideNegotiator(
        Effect.gen(function* () {
          const result = yield* negotiateRlpxHelloCapabilities(
            [
              { name: "snap", version: 1, messageIdSpaceSize: 8 },
              { name: "eth", version: 66, messageIdSpaceSize: 17 },
              { name: "eth", version: 68, messageIdSpaceSize: 17 },
              { name: "nodedata", version: 1, messageIdSpaceSize: 2 },
            ],
            [
              { name: "les", version: 2 },
              { name: "eth", version: 66 },
              { name: "eth", version: 68 },
              { name: "snap", version: 1 },
            ],
          );

          assert.deepStrictEqual(result.negotiatedCapabilities, [
            {
              name: "eth",
              version: 68,
              messageIdSpaceSize: 17,
              messageIdOffset: RlpxCapabilityMessageIdStart,
              messageIdRangeEnd: RlpxCapabilityMessageIdStart + 16,
            },
            {
              name: "snap",
              version: 1,
              messageIdSpaceSize: 8,
              messageIdOffset: RlpxCapabilityMessageIdStart + 17,
              messageIdRangeEnd: RlpxCapabilityMessageIdStart + 24,
            },
          ]);
          assert.strictEqual(
            result.nextMessageId,
            RlpxCapabilityMessageIdStart + 25,
          );
        }),
      ),
  );

  it.effect(
    "treats capability names as case-sensitive during matching and sorting",
    () =>
      provideNegotiator(
        Effect.gen(function* () {
          const result = yield* negotiateRlpxHelloCapabilities(
            [
              { name: "Aa", version: 1, messageIdSpaceSize: 1 },
              { name: "aa", version: 1, messageIdSpaceSize: 1 },
              { name: "aa", version: 2, messageIdSpaceSize: 2 },
            ],
            [
              { name: "aa", version: 1 },
              { name: "Aa", version: 1 },
              { name: "aa", version: 2 },
            ],
          );

          assert.deepStrictEqual(result.negotiatedCapabilities, [
            {
              name: "Aa",
              version: 1,
              messageIdSpaceSize: 1,
              messageIdOffset: RlpxCapabilityMessageIdStart,
              messageIdRangeEnd: RlpxCapabilityMessageIdStart,
            },
            {
              name: "aa",
              version: 2,
              messageIdSpaceSize: 2,
              messageIdOffset: RlpxCapabilityMessageIdStart + 1,
              messageIdRangeEnd: RlpxCapabilityMessageIdStart + 2,
            },
          ]);
        }),
      ),
  );

  it.effect(
    "returns empty negotiation output when no capabilities are shared",
    () =>
      provideNegotiator(
        Effect.gen(function* () {
          const result = yield* negotiateRlpxHelloCapabilities(
            [{ name: "eth", version: 68, messageIdSpaceSize: 17 }],
            [{ name: "snap", version: 1 }],
          );

          assert.deepStrictEqual(result.negotiatedCapabilities, []);
          assert.strictEqual(
            result.nextMessageId,
            RlpxCapabilityMessageIdStart,
          );
        }),
      ),
  );

  it.effect(
    "rejects local duplicate definitions with conflicting message-ID space",
    () =>
      provideNegotiator(
        Effect.gen(function* () {
          const result = yield* negotiateRlpxHelloCapabilities(
            [
              { name: "eth", version: 68, messageIdSpaceSize: 17 },
              { name: "eth", version: 68, messageIdSpaceSize: 18 },
            ],
            [{ name: "eth", version: 68 }],
          ).pipe(Effect.either);

          assert.isTrue(Either.isLeft(result));
          if (Either.isLeft(result)) {
            const error = result.left;
            if (error instanceof RlpxHelloCapabilityValidationError) {
              assert.strictEqual(
                error.reason,
                "DuplicateCapabilityWithDifferentMessageSpace",
              );
              assert.strictEqual(error.source, "local");
              assert.strictEqual(error.capabilityName, "eth");
              assert.strictEqual(error.capabilityVersion, 68);
            } else {
              assert.fail(
                `Expected RlpxHelloCapabilityValidationError, got ${error}`,
              );
            }
          }
        }),
      ),
  );

  it.effect("rejects capability names longer than 8 ASCII characters", () =>
    provideNegotiator(
      Effect.gen(function* () {
        const result = yield* negotiateRlpxHelloCapabilities(
          [{ name: "toolonggg", version: 1, messageIdSpaceSize: 1 }],
          [{ name: "toolonggg", version: 1 }],
        ).pipe(Effect.either);

        assert.isTrue(Either.isLeft(result));
        if (Either.isLeft(result)) {
          const error = result.left;
          if (error instanceof RlpxHelloCapabilityValidationError) {
            assert.strictEqual(error.reason, "CapabilityNameTooLong");
            assert.strictEqual(error.source, "local");
          } else {
            assert.fail(
              `Expected RlpxHelloCapabilityValidationError, got ${error}`,
            );
          }
        }
      }),
    ),
  );

  it.effect("rejects non-ASCII capability names in remote Hello entries", () =>
    provideNegotiator(
      Effect.gen(function* () {
        const result = yield* negotiateRlpxHelloCapabilities(
          [{ name: "eth", version: 68, messageIdSpaceSize: 17 }],
          [{ name: "éth", version: 68 }],
        ).pipe(Effect.either);

        assert.isTrue(Either.isLeft(result));
        if (Either.isLeft(result)) {
          const error = result.left;
          if (error instanceof RlpxHelloCapabilityValidationError) {
            assert.strictEqual(error.reason, "CapabilityNameNonAscii");
            assert.strictEqual(error.source, "remote");
          } else {
            assert.fail(
              `Expected RlpxHelloCapabilityValidationError, got ${error}`,
            );
          }
        }
      }),
    ),
  );

  it.effect("rejects non-positive local message-ID space sizes", () =>
    provideNegotiator(
      Effect.gen(function* () {
        const result = yield* negotiateRlpxHelloCapabilities(
          [{ name: "eth", version: 68, messageIdSpaceSize: 0 }],
          [{ name: "eth", version: 68 }],
        ).pipe(Effect.either);

        assert.isTrue(Either.isLeft(result));
        if (Either.isLeft(result)) {
          const error = result.left;
          if (error instanceof RlpxHelloCapabilityValidationError) {
            assert.strictEqual(error.reason, "InvalidMessageIdSpaceSize");
            assert.strictEqual(error.source, "local");
          } else {
            assert.fail(
              `Expected RlpxHelloCapabilityValidationError, got ${error}`,
            );
          }
        }
      }),
    ),
  );

  it.effect(
    "rejects allocations that would overflow message-ID numeric bounds",
    () =>
      provideNegotiator(
        Effect.gen(function* () {
          const result = yield* negotiateRlpxHelloCapabilities(
            [
              {
                name: "a",
                version: 1,
                messageIdSpaceSize:
                  Number.MAX_SAFE_INTEGER - RlpxCapabilityMessageIdStart,
              },
              { name: "b", version: 1, messageIdSpaceSize: 1 },
            ],
            [
              { name: "a", version: 1 },
              { name: "b", version: 1 },
            ],
          ).pipe(Effect.either);

          assert.isTrue(Either.isLeft(result));
          if (Either.isLeft(result)) {
            const error = result.left;
            assert.isTrue(error instanceof RlpxHelloMessageIdAllocationError);
            assert.strictEqual(error.capabilityName, "b");
            assert.strictEqual(error.capabilityVersion, 1);
          }
        }),
      ),
  );
});
