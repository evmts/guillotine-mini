import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import {
  EngineCapabilitiesLive,
  InvalidEngineCapabilityMethodError,
  ParisEngineCapabilities,
  exchangeCapabilities,
} from "./EngineCapabilities";

const provideCapabilities =
  (supportedExecutionMethods: ReadonlyArray<string>) =>
  <A, E, R>(effect: Effect.Effect<A, E, R>) =>
    effect.pipe(
      Effect.provide(EngineCapabilitiesLive(supportedExecutionMethods)),
    );

describe("EngineCapabilities", () => {
  it.effect("returns configured methods for a valid capabilities request", () =>
    provideCapabilities(ParisEngineCapabilities)(
      Effect.gen(function* () {
        const result = yield* exchangeCapabilities([
          "engine_newPayloadV1",
          "engine_forkchoiceUpdatedV1",
        ]);

        assert.deepStrictEqual(result, [...ParisEngineCapabilities]);
      }),
    ),
  );

  it.effect("rejects non-engine methods in request list", () =>
    provideCapabilities(ParisEngineCapabilities)(
      Effect.gen(function* () {
        const outcome = yield* exchangeCapabilities([
          "eth_getBlockByNumberV1",
        ]).pipe(Effect.either);

        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          const error = outcome.left;
          assert.strictEqual(error._tag, "InvalidEngineCapabilityMethodError");
          assert.strictEqual(error.source, "request");
          assert.strictEqual(error.method, "eth_getBlockByNumberV1");
          assert.strictEqual(error.reason, "NonEngineNamespace");
        }
      }),
    ),
  );

  it.effect("rejects unversioned engine methods in request list", () =>
    provideCapabilities(ParisEngineCapabilities)(
      Effect.gen(function* () {
        const outcome = yield* exchangeCapabilities(["engine_newPayload"]).pipe(
          Effect.either,
        );

        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          const error = outcome.left;
          assert.strictEqual(error._tag, "InvalidEngineCapabilityMethodError");
          assert.strictEqual(error.source, "request");
          assert.strictEqual(error.method, "engine_newPayload");
          assert.strictEqual(error.reason, "MissingVersionSuffix");
        }
      }),
    ),
  );

  it.effect(
    "rejects engine_exchangeCapabilities in request list per spec",
    () =>
      provideCapabilities(ParisEngineCapabilities)(
        Effect.gen(function* () {
          const outcome = yield* exchangeCapabilities([
            "engine_exchangeCapabilities",
          ]).pipe(Effect.either);

          assert.isTrue(Either.isLeft(outcome));
          if (Either.isLeft(outcome)) {
            const error = outcome.left;
            assert.strictEqual(
              error._tag,
              "InvalidEngineCapabilityMethodError",
            );
            assert.strictEqual(error.source, "request");
            assert.strictEqual(error.method, "engine_exchangeCapabilities");
            assert.strictEqual(error.reason, "ExchangeCapabilitiesNotAllowed");
          }
        }),
      ),
  );

  it.effect("rejects invalid configured response capabilities", () =>
    Effect.gen(function* () {
      const outcome = yield* exchangeCapabilities(["engine_newPayloadV1"]).pipe(
        Effect.provide(EngineCapabilitiesLive(["engine_exchangeCapabilities"])),
        Effect.either,
      );

      assert.isTrue(Either.isLeft(outcome));
      if (Either.isLeft(outcome)) {
        const error = outcome.left;
        assert.isTrue(error instanceof InvalidEngineCapabilityMethodError);
        assert.strictEqual(error.source, "response");
        assert.strictEqual(error.method, "engine_exchangeCapabilities");
        assert.strictEqual(error.reason, "ExchangeCapabilitiesNotAllowed");
      }
    }),
  );
});
