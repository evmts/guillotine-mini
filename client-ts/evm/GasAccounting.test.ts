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
  InvalidEffectiveGasPriceError,
  InvalidRefundAmountError,
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
          calldataFloorGas: 0n,
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
          calldataFloorGas: 0n,
        });
        assert.strictEqual(result.gasUsedAfterRefund, 64n);
        assert.strictEqual(result.senderRefundAmount, 72n);
      }),
    ),
  );

  it.effect("respects refund counter below the London cap", () =>
    providePrague(
      Effect.gen(function* () {
        const result = yield* calculateGasSettlement({
          gasLimit: 100n,
          gasLeft: 70n,
          refundCounter: 5n,
          effectiveGasPrice: 2n,
          calldataFloorGas: 0n,
        });
        assert.strictEqual(result.gasUsedAfterRefund, 25n);
        assert.strictEqual(result.senderRefundAmount, 150n);
      }),
    ),
  );

  it.effect("applies calldata floor gas after refund", () =>
    providePrague(
      Effect.gen(function* () {
        const result = yield* calculateGasSettlement({
          gasLimit: 100n,
          gasLeft: 20n,
          refundCounter: 50n,
          effectiveGasPrice: 2n,
          calldataFloorGas: 70n,
        });
        assert.strictEqual(result.gasUsedAfterRefund, 70n);
        assert.strictEqual(result.senderRefundAmount, 60n);
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
            calldataFloorGas: 0n,
          }),
        );
        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof InvalidGasAccountingError);
        }
      }),
    ),
  );

  it.effect("fails when gas left exceeds gas limit", () =>
    providePrague(
      Effect.gen(function* () {
        const outcome = yield* Effect.either(
          calculateGasSettlement({
            gasLimit: 50n,
            gasLeft: 60n,
            refundCounter: 0n,
            effectiveGasPrice: 1n,
            calldataFloorGas: 0n,
          }),
        );
        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof InvalidGasAccountingError);
        }
      }),
    ),
  );

  it.effect("fails when effective gas price is invalid", () =>
    providePrague(
      Effect.gen(function* () {
        const outcome = yield* Effect.either(
          calculateGasSettlement({
            gasLimit: 100n,
            gasLeft: 20n,
            refundCounter: 0n,
            effectiveGasPrice: -1n,
            calldataFloorGas: 0n,
          }),
        );
        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof InvalidEffectiveGasPriceError);
        }
      }),
    ),
  );

  it.effect("fails when sender refund amount overflows", () =>
    providePrague(
      Effect.gen(function* () {
        const maxUint256 = (1n << 256n) - 1n;
        const outcome = yield* Effect.either(
          calculateGasSettlement({
            gasLimit: 3n,
            gasLeft: 2n,
            refundCounter: 0n,
            effectiveGasPrice: maxUint256,
            calldataFloorGas: 0n,
          }),
        );
        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof InvalidRefundAmountError);
        }
      }),
    ),
  );
});
