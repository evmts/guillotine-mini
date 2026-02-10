import assert from "node:assert/strict";
import { describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import {
  RlpxCapabilityMessageIdStart,
  RlpxHelloCapabilityNegotiator,
  RlpxHelloCapabilityNegotiatorLive,
  type RlpxHelloCapability,
  type RlpxHelloCapabilityDescriptor,
  RlpxHelloCapabilityValidationError,
  RlpxHelloMessageIdAllocationError,
  negotiateRlpxHelloCapabilities,
} from "./RlpxHelloCapabilityNegotiator";

const runWithNegotiator = <A, E>(
  effect: Effect.Effect<A, E, RlpxHelloCapabilityNegotiator>,
): A =>
  Effect.runSync(
    effect.pipe(Effect.provide(RlpxHelloCapabilityNegotiatorLive)),
  );

const negotiate = (
  localCapabilities: ReadonlyArray<RlpxHelloCapabilityDescriptor>,
  remoteCapabilities: ReadonlyArray<RlpxHelloCapability>,
) => negotiateRlpxHelloCapabilities(localCapabilities, remoteCapabilities);

const negotiateEither = (
  localCapabilities: ReadonlyArray<RlpxHelloCapabilityDescriptor>,
  remoteCapabilities: ReadonlyArray<RlpxHelloCapability>,
) => negotiate(localCapabilities, remoteCapabilities).pipe(Effect.either);

const expectLeft = <A, E>(result: Either.Either<A, E>): E => {
  assert.strictEqual(Either.isLeft(result), true);

  if (Either.isLeft(result)) {
    return result.left;
  }

  assert.fail(`Expected Left result, got ${JSON.stringify(result)}`);
};

interface ValidationErrorExpectation {
  readonly reason:
    | "CapabilityNameEmpty"
    | "CapabilityNameTooLong"
    | "CapabilityNameNonAscii"
    | "CapabilityNameNonPrintableAscii"
    | "InvalidVersion"
    | "InvalidMessageIdSpaceSize"
    | "DuplicateCapabilityWithDifferentMessageSpace";
  readonly source?: "local" | "remote";
  readonly capabilityName?: string;
  readonly capabilityVersion?: number;
}

const expectValidationError = (
  error: unknown,
  expected: ValidationErrorExpectation,
): RlpxHelloCapabilityValidationError => {
  assert.strictEqual(error instanceof RlpxHelloCapabilityValidationError, true);

  if (!(error instanceof RlpxHelloCapabilityValidationError)) {
    assert.fail(`Expected RlpxHelloCapabilityValidationError, got ${error}`);
  }

  assert.strictEqual(error.reason, expected.reason);

  if (expected.source !== undefined) {
    assert.strictEqual(error.source, expected.source);
  }

  if (expected.capabilityName !== undefined) {
    assert.strictEqual(error.capabilityName, expected.capabilityName);
  }

  if (expected.capabilityVersion !== undefined) {
    assert.strictEqual(error.capabilityVersion, expected.capabilityVersion);
  }

  return error;
};

describe("RlpxHelloCapabilityNegotiator", () => {
  it("negotiates shared capabilities with highest version, alphabetic ordering, and 0x10-based offsets", () => {
    const result = runWithNegotiator(
      negotiate(
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
      ),
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
    assert.strictEqual(result.nextMessageId, RlpxCapabilityMessageIdStart + 25);
  });

  it("treats capability names as case-sensitive during matching and sorting", () => {
    const result = runWithNegotiator(
      negotiate(
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
      ),
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
  });

  it("returns empty negotiation output when no capabilities are shared", () => {
    const result = runWithNegotiator(
      negotiate(
        [{ name: "eth", version: 68, messageIdSpaceSize: 17 }],
        [{ name: "snap", version: 1 }],
      ),
    );

    assert.deepStrictEqual(result.negotiatedCapabilities, []);
    assert.strictEqual(result.nextMessageId, RlpxCapabilityMessageIdStart);
  });

  it("rejects local duplicate definitions with conflicting message-ID space", () => {
    const result = runWithNegotiator(
      negotiateEither(
        [
          { name: "eth", version: 68, messageIdSpaceSize: 17 },
          { name: "eth", version: 68, messageIdSpaceSize: 18 },
        ],
        [{ name: "eth", version: 68 }],
      ),
    );

    expectValidationError(expectLeft(result), {
      reason: "DuplicateCapabilityWithDifferentMessageSpace",
      source: "local",
      capabilityName: "eth",
      capabilityVersion: 68,
    });
  });

  it("rejects capability names longer than 8 ASCII characters", () => {
    const result = runWithNegotiator(
      negotiateEither(
        [{ name: "toolonggg", version: 1, messageIdSpaceSize: 1 }],
        [{ name: "toolonggg", version: 1 }],
      ),
    );

    expectValidationError(expectLeft(result), {
      reason: "CapabilityNameTooLong",
      source: "local",
    });
  });

  it("rejects empty local capability names", () => {
    const result = runWithNegotiator(
      negotiateEither(
        [{ name: "", version: 1, messageIdSpaceSize: 1 }],
        [{ name: "", version: 1 }],
      ),
    );

    expectValidationError(expectLeft(result), {
      reason: "CapabilityNameEmpty",
      source: "local",
      capabilityName: "",
      capabilityVersion: 1,
    });
  });

  it("rejects empty remote capability names", () => {
    const result = runWithNegotiator(
      negotiateEither(
        [{ name: "eth", version: 68, messageIdSpaceSize: 17 }],
        [{ name: "", version: 68 }],
      ),
    );

    expectValidationError(expectLeft(result), {
      reason: "CapabilityNameEmpty",
      source: "remote",
      capabilityName: "",
      capabilityVersion: 68,
    });
  });

  it("rejects non-ASCII capability names in remote Hello entries", () => {
    const result = runWithNegotiator(
      negotiateEither(
        [{ name: "eth", version: 68, messageIdSpaceSize: 17 }],
        [{ name: "éth", version: 68 }],
      ),
    );

    expectValidationError(expectLeft(result), {
      reason: "CapabilityNameNonAscii",
      source: "remote",
    });
  });

  it("rejects local capability names containing non-printable ASCII", () => {
    const result = runWithNegotiator(
      negotiateEither(
        [{ name: "et\u0001h", version: 68, messageIdSpaceSize: 17 }],
        [{ name: "et\u0001h", version: 68 }],
      ),
    );

    expectValidationError(expectLeft(result), {
      reason: "CapabilityNameNonPrintableAscii",
      source: "local",
      capabilityName: "et\u0001h",
      capabilityVersion: 68,
    });
  });

  it("rejects remote capability names containing non-printable ASCII", () => {
    const result = runWithNegotiator(
      negotiateEither(
        [{ name: "eth", version: 68, messageIdSpaceSize: 17 }],
        [{ name: "et\u0007h", version: 68 }],
      ),
    );

    expectValidationError(expectLeft(result), {
      reason: "CapabilityNameNonPrintableAscii",
      source: "remote",
      capabilityName: "et\u0007h",
      capabilityVersion: 68,
    });
  });

  it("rejects non-positive local message-ID space sizes", () => {
    const result = runWithNegotiator(
      negotiateEither(
        [{ name: "eth", version: 68, messageIdSpaceSize: 0 }],
        [{ name: "eth", version: 68 }],
      ),
    );

    expectValidationError(expectLeft(result), {
      reason: "InvalidMessageIdSpaceSize",
      source: "local",
    });
  });

  it("rejects non-integer local capability versions", () => {
    const result = runWithNegotiator(
      negotiateEither(
        [{ name: "eth", version: 1.5, messageIdSpaceSize: 17 }],
        [{ name: "eth", version: 1.5 }],
      ),
    );

    expectValidationError(expectLeft(result), {
      reason: "InvalidVersion",
      source: "local",
      capabilityName: "eth",
      capabilityVersion: 1.5,
    });
  });

  it("rejects negative local capability versions", () => {
    const result = runWithNegotiator(
      negotiateEither(
        [{ name: "eth", version: -1, messageIdSpaceSize: 17 }],
        [{ name: "eth", version: -1 }],
      ),
    );

    expectValidationError(expectLeft(result), {
      reason: "InvalidVersion",
      source: "local",
      capabilityName: "eth",
      capabilityVersion: -1,
    });
  });

  it("rejects non-integer remote capability versions", () => {
    const result = runWithNegotiator(
      negotiateEither(
        [{ name: "eth", version: 68, messageIdSpaceSize: 17 }],
        [{ name: "eth", version: 68.25 }],
      ),
    );

    expectValidationError(expectLeft(result), {
      reason: "InvalidVersion",
      source: "remote",
      capabilityName: "eth",
      capabilityVersion: 68.25,
    });
  });

  it("rejects negative remote capability versions", () => {
    const result = runWithNegotiator(
      negotiateEither(
        [{ name: "eth", version: 68, messageIdSpaceSize: 17 }],
        [{ name: "eth", version: -68 }],
      ),
    );

    expectValidationError(expectLeft(result), {
      reason: "InvalidVersion",
      source: "remote",
      capabilityName: "eth",
      capabilityVersion: -68,
    });
  });

  it("rejects allocations that would overflow message-ID numeric bounds", () => {
    const result = runWithNegotiator(
      negotiateEither(
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
      ),
    );

    const error = expectLeft(result);

    assert.strictEqual(
      error instanceof RlpxHelloMessageIdAllocationError,
      true,
    );
    if (error instanceof RlpxHelloMessageIdAllocationError) {
      assert.strictEqual(error.capabilityName, "b");
      assert.strictEqual(error.capabilityVersion, 1);
    }
  });
});
