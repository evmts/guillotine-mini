import assert from "node:assert/strict";
import { describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import {
  RlpxHelloCapabilityNegotiator,
  RlpxCapabilityMessageIdStart,
  RlpxHelloCapabilityNegotiatorLive,
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

describe("RlpxHelloCapabilityNegotiator", () => {
  it("negotiates shared capabilities with highest version, alphabetic ordering, and 0x10-based offsets", () => {
    const result = runWithNegotiator(
      negotiateRlpxHelloCapabilities(
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
      negotiateRlpxHelloCapabilities(
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
      negotiateRlpxHelloCapabilities(
        [{ name: "eth", version: 68, messageIdSpaceSize: 17 }],
        [{ name: "snap", version: 1 }],
      ),
    );

    assert.deepStrictEqual(result.negotiatedCapabilities, []);
    assert.strictEqual(result.nextMessageId, RlpxCapabilityMessageIdStart);
  });

  it("rejects local duplicate definitions with conflicting message-ID space", () => {
    const result = runWithNegotiator(
      negotiateRlpxHelloCapabilities(
        [
          { name: "eth", version: 68, messageIdSpaceSize: 17 },
          { name: "eth", version: 68, messageIdSpaceSize: 18 },
        ],
        [{ name: "eth", version: 68 }],
      ).pipe(Effect.either),
    );

    assert.strictEqual(Either.isLeft(result), true);
    if (!Either.isLeft(result)) {
      assert.fail(`Expected Left result, got ${JSON.stringify(result)}`);
    }

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
      assert.fail(`Expected RlpxHelloCapabilityValidationError, got ${error}`);
    }
  });

  it("rejects capability names longer than 8 ASCII characters", () => {
    const result = runWithNegotiator(
      negotiateRlpxHelloCapabilities(
        [{ name: "toolonggg", version: 1, messageIdSpaceSize: 1 }],
        [{ name: "toolonggg", version: 1 }],
      ).pipe(Effect.either),
    );

    assert.strictEqual(Either.isLeft(result), true);
    if (!Either.isLeft(result)) {
      assert.fail(`Expected Left result, got ${JSON.stringify(result)}`);
    }

    const error = result.left;
    if (error instanceof RlpxHelloCapabilityValidationError) {
      assert.strictEqual(error.reason, "CapabilityNameTooLong");
      assert.strictEqual(error.source, "local");
    } else {
      assert.fail(`Expected RlpxHelloCapabilityValidationError, got ${error}`);
    }
  });

  it("rejects empty local capability names", () => {
    const result = runWithNegotiator(
      negotiateRlpxHelloCapabilities(
        [{ name: "", version: 1, messageIdSpaceSize: 1 }],
        [{ name: "", version: 1 }],
      ).pipe(Effect.either),
    );

    assert.strictEqual(Either.isLeft(result), true);
    if (!Either.isLeft(result)) {
      assert.fail(`Expected Left result, got ${JSON.stringify(result)}`);
    }

    const error = result.left;
    if (error instanceof RlpxHelloCapabilityValidationError) {
      assert.strictEqual(error.reason, "CapabilityNameEmpty");
      assert.strictEqual(error.source, "local");
      assert.strictEqual(error.capabilityName, "");
      assert.strictEqual(error.capabilityVersion, 1);
    } else {
      assert.fail(`Expected RlpxHelloCapabilityValidationError, got ${error}`);
    }
  });

  it("rejects empty remote capability names", () => {
    const result = runWithNegotiator(
      negotiateRlpxHelloCapabilities(
        [{ name: "eth", version: 68, messageIdSpaceSize: 17 }],
        [{ name: "", version: 68 }],
      ).pipe(Effect.either),
    );

    assert.strictEqual(Either.isLeft(result), true);
    if (!Either.isLeft(result)) {
      assert.fail(`Expected Left result, got ${JSON.stringify(result)}`);
    }

    const error = result.left;
    if (error instanceof RlpxHelloCapabilityValidationError) {
      assert.strictEqual(error.reason, "CapabilityNameEmpty");
      assert.strictEqual(error.source, "remote");
      assert.strictEqual(error.capabilityName, "");
      assert.strictEqual(error.capabilityVersion, 68);
    } else {
      assert.fail(`Expected RlpxHelloCapabilityValidationError, got ${error}`);
    }
  });

  it("rejects non-ASCII capability names in remote Hello entries", () => {
    const result = runWithNegotiator(
      negotiateRlpxHelloCapabilities(
        [{ name: "eth", version: 68, messageIdSpaceSize: 17 }],
        [{ name: "éth", version: 68 }],
      ).pipe(Effect.either),
    );

    assert.strictEqual(Either.isLeft(result), true);
    if (!Either.isLeft(result)) {
      assert.fail(`Expected Left result, got ${JSON.stringify(result)}`);
    }

    const error = result.left;
    if (error instanceof RlpxHelloCapabilityValidationError) {
      assert.strictEqual(error.reason, "CapabilityNameNonAscii");
      assert.strictEqual(error.source, "remote");
    } else {
      assert.fail(`Expected RlpxHelloCapabilityValidationError, got ${error}`);
    }
  });

  it("rejects non-positive local message-ID space sizes", () => {
    const result = runWithNegotiator(
      negotiateRlpxHelloCapabilities(
        [{ name: "eth", version: 68, messageIdSpaceSize: 0 }],
        [{ name: "eth", version: 68 }],
      ).pipe(Effect.either),
    );

    assert.strictEqual(Either.isLeft(result), true);
    if (!Either.isLeft(result)) {
      assert.fail(`Expected Left result, got ${JSON.stringify(result)}`);
    }

    const error = result.left;
    if (error instanceof RlpxHelloCapabilityValidationError) {
      assert.strictEqual(error.reason, "InvalidMessageIdSpaceSize");
      assert.strictEqual(error.source, "local");
    } else {
      assert.fail(`Expected RlpxHelloCapabilityValidationError, got ${error}`);
    }
  });

  it("rejects non-integer local capability versions", () => {
    const result = runWithNegotiator(
      negotiateRlpxHelloCapabilities(
        [{ name: "eth", version: 1.5, messageIdSpaceSize: 17 }],
        [{ name: "eth", version: 1.5 }],
      ).pipe(Effect.either),
    );

    assert.strictEqual(Either.isLeft(result), true);
    if (!Either.isLeft(result)) {
      assert.fail(`Expected Left result, got ${JSON.stringify(result)}`);
    }

    const error = result.left;
    if (error instanceof RlpxHelloCapabilityValidationError) {
      assert.strictEqual(error.reason, "InvalidVersion");
      assert.strictEqual(error.source, "local");
      assert.strictEqual(error.capabilityName, "eth");
      assert.strictEqual(error.capabilityVersion, 1.5);
    } else {
      assert.fail(`Expected RlpxHelloCapabilityValidationError, got ${error}`);
    }
  });

  it("rejects negative local capability versions", () => {
    const result = runWithNegotiator(
      negotiateRlpxHelloCapabilities(
        [{ name: "eth", version: -1, messageIdSpaceSize: 17 }],
        [{ name: "eth", version: -1 }],
      ).pipe(Effect.either),
    );

    assert.strictEqual(Either.isLeft(result), true);
    if (!Either.isLeft(result)) {
      assert.fail(`Expected Left result, got ${JSON.stringify(result)}`);
    }

    const error = result.left;
    if (error instanceof RlpxHelloCapabilityValidationError) {
      assert.strictEqual(error.reason, "InvalidVersion");
      assert.strictEqual(error.source, "local");
      assert.strictEqual(error.capabilityName, "eth");
      assert.strictEqual(error.capabilityVersion, -1);
    } else {
      assert.fail(`Expected RlpxHelloCapabilityValidationError, got ${error}`);
    }
  });

  it("rejects non-integer remote capability versions", () => {
    const result = runWithNegotiator(
      negotiateRlpxHelloCapabilities(
        [{ name: "eth", version: 68, messageIdSpaceSize: 17 }],
        [{ name: "eth", version: 68.25 }],
      ).pipe(Effect.either),
    );

    assert.strictEqual(Either.isLeft(result), true);
    if (!Either.isLeft(result)) {
      assert.fail(`Expected Left result, got ${JSON.stringify(result)}`);
    }

    const error = result.left;
    if (error instanceof RlpxHelloCapabilityValidationError) {
      assert.strictEqual(error.reason, "InvalidVersion");
      assert.strictEqual(error.source, "remote");
      assert.strictEqual(error.capabilityName, "eth");
      assert.strictEqual(error.capabilityVersion, 68.25);
    } else {
      assert.fail(`Expected RlpxHelloCapabilityValidationError, got ${error}`);
    }
  });

  it("rejects negative remote capability versions", () => {
    const result = runWithNegotiator(
      negotiateRlpxHelloCapabilities(
        [{ name: "eth", version: 68, messageIdSpaceSize: 17 }],
        [{ name: "eth", version: -68 }],
      ).pipe(Effect.either),
    );

    assert.strictEqual(Either.isLeft(result), true);
    if (!Either.isLeft(result)) {
      assert.fail(`Expected Left result, got ${JSON.stringify(result)}`);
    }

    const error = result.left;
    if (error instanceof RlpxHelloCapabilityValidationError) {
      assert.strictEqual(error.reason, "InvalidVersion");
      assert.strictEqual(error.source, "remote");
      assert.strictEqual(error.capabilityName, "eth");
      assert.strictEqual(error.capabilityVersion, -68);
    } else {
      assert.fail(`Expected RlpxHelloCapabilityValidationError, got ${error}`);
    }
  });

  it("rejects allocations that would overflow message-ID numeric bounds", () => {
    const result = runWithNegotiator(
      negotiateRlpxHelloCapabilities(
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
      ).pipe(Effect.either),
    );

    assert.strictEqual(Either.isLeft(result), true);
    if (!Either.isLeft(result)) {
      assert.fail(`Expected Left result, got ${JSON.stringify(result)}`);
    }

    const error = result.left;
    assert.strictEqual(
      error instanceof RlpxHelloMessageIdAllocationError,
      true,
    );
    assert.strictEqual(error.capabilityName, "b");
    assert.strictEqual(error.capabilityVersion, 1);
  });
});
