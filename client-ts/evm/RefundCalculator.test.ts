import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import * as Layer from "effect/Layer";
import { Hardfork } from "voltaire-effect/primitives";
import {
  calculateClaimableRefund,
  InvalidGasError,
  RefundCalculatorLive,
  RefundCalculatorTest,
} from "./RefundCalculator";
import { ReleaseSpecLive } from "./ReleaseSpec";

const provideCalculator =
  (hardfork: Hardfork.HardforkType) =>
  <A, E, R>(effect: Effect.Effect<A, E, R>) =>
    effect.pipe(
      Effect.provide(
        RefundCalculatorLive.pipe(Layer.provide(ReleaseSpecLive(hardfork))),
      ),
    );

const providePrague = <A, E, R>(effect: Effect.Effect<A, E, R>) =>
  effect.pipe(Effect.provide(RefundCalculatorTest));

describe("RefundCalculator", () => {
  it.effect("caps refunds at half of spent gas before London", () =>
    provideCalculator(Hardfork.BERLIN)(
      Effect.gen(function* () {
        const refund = yield* calculateClaimableRefund(100n, 80n);
        assert.strictEqual(refund, 50n);
      }),
    ),
  );

  it.effect("caps refunds at one-fifth of spent gas in London+", () =>
    providePrague(
      Effect.gen(function* () {
        const refund = yield* calculateClaimableRefund(100n, 80n);
        assert.strictEqual(refund, 20n);
      }),
    ),
  );

  it.effect("returns total refund when below cap", () =>
    providePrague(
      Effect.gen(function* () {
        const refund = yield* calculateClaimableRefund(100n, 10n);
        assert.strictEqual(refund, 10n);
      }),
    ),
  );

  it.effect("fails when gas values are invalid", () =>
    providePrague(
      Effect.gen(function* () {
        const outcome = yield* Effect.either(calculateClaimableRefund(-1n, 0n));
        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof InvalidGasError);
        }
      }),
    ),
  );
});
