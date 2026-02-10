import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import * as Layer from "effect/Layer";
import { Hardfork } from "voltaire-effect/primitives";
import {
  calculateGasSettlement,
  GasAccountingLive,
  GasAccountingTest,
  InvalidGasAccountingError,
} from "./GasAccounting";
import { RefundCalculatorLive } from "./RefundCalculator";
import { ReleaseSpecLive } from "./ReleaseSpec";

const provideGasAccounting =
  (hardfork: Hardfork.HardforkType) =>
  <A, E, R>(effect: Effect.Effect<A, E, R>) =>
    effect.pipe(
      Effect.provide(
        GasAccountingLive.pipe(
          Layer.provide(
            RefundCalculatorLive.pipe(Layer.provide(ReleaseSpecLive(hardfork))),
          ),
        ),
      ),
    );

const providePrague = <A, E, R>(effect: Effect.Effect<A, E, R>) =>
  effect.pipe(Effect.provide(GasAccountingTest));

describe("GasAccounting", () => {
  it.effect("computes pre-London gas used after refund and sender refund", () =>
    provideGasAccounting(Hardfork.BERLIN)(
      Effect.gen(function* () {
        const result = yield* calculateGasSettlement({
          gasLimit: 100n,
          gasLeft: 20n,
          refundCounter: 50n,
          effectiveGasPrice: 2n,
        });
        assert.strictEqual(result.gasUsedAfterRefund, 40n);
        assert.strictEqual(result.senderRefundAmount, 120n);
      }),
    ),
  );

  it.effect("computes London+ gas used after refund and sender refund", () =>
    providePrague(
      Effect.gen(function* () {
        const result = yield* calculateGasSettlement({
          gasLimit: 100n,
          gasLeft: 20n,
          refundCounter: 50n,
          effectiveGasPrice: 2n,
        });
        assert.strictEqual(result.gasUsedAfterRefund, 64n);
        assert.strictEqual(result.senderRefundAmount, 72n);
      }),
    ),
  );

  it.effect("fails when gas inputs are invalid", () =>
    providePrague(
      Effect.gen(function* () {
        const outcome = yield* Effect.either(
          calculateGasSettlement({
            gasLimit: 100n,
            gasLeft: -1n,
            refundCounter: 0n,
            effectiveGasPrice: 1n,
          }),
        );
        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof InvalidGasAccountingError);
        }
      }),
    ),
  );
});
