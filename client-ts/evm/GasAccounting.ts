import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";
import { Balance, Gas, GasPrice } from "voltaire-effect/primitives";
import {
  RefundCalculator,
  type RefundCalculatorError,
  RefundCalculatorTest,
} from "./RefundCalculator";

const GasBigIntSchema = Gas.BigInt as unknown as Schema.Schema<
  Gas.GasType,
  bigint
>;
const GasPriceSchema = GasPrice.BigInt as unknown as Schema.Schema<
  GasPrice.GasPriceType,
  bigint
>;
const BalanceSchema = Balance.BigInt as unknown as Schema.Schema<
  Balance.BalanceType,
  bigint
>;

/** Settlement gas accounting output. */
export type GasSettlement = {
  readonly gasUsedAfterRefund: Gas.GasType;
  readonly senderRefundAmount: Balance.BalanceType;
};

/** Inputs required to compute refund settlement amounts. */
export type GasAccountingInput = {
  readonly gasLimit: bigint;
  readonly gasLeft: bigint;
  readonly refundCounter: bigint;
  readonly effectiveGasPrice: bigint;
};

/** Error raised when gas inputs cannot be decoded. */
export class InvalidGasAccountingError extends Data.TaggedError(
  "InvalidGasAccountingError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Error raised when the effective gas price is invalid. */
export class InvalidEffectiveGasPriceError extends Data.TaggedError(
  "InvalidEffectiveGasPriceError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Error raised when the sender refund amount is invalid. */
export class InvalidRefundAmountError extends Data.TaggedError(
  "InvalidRefundAmountError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Union of gas accounting errors. */
export type GasAccountingError =
  | RefundCalculatorError
  | InvalidGasAccountingError
  | InvalidEffectiveGasPriceError
  | InvalidRefundAmountError;

/** Gas accounting service interface. */
export interface GasAccountingService {
  readonly calculateGasSettlement: (
    input: GasAccountingInput,
  ) => Effect.Effect<GasSettlement, GasAccountingError>;
}

/** Context tag for the gas accounting service. */
export class GasAccounting extends Context.Tag("GasAccounting")<
  GasAccounting,
  GasAccountingService
>() {}

const decodeGas = (value: bigint, label: string) =>
  Schema.decode(GasBigIntSchema)(value).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidGasAccountingError({
          message: `Invalid ${label} gas value`,
          cause,
        }),
    ),
  );

const decodeGasPrice = (value: bigint) =>
  Schema.decode(GasPriceSchema)(value).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidEffectiveGasPriceError({
          message: "Invalid effective gas price",
          cause,
        }),
    ),
  );

const decodeBalance = (value: bigint) =>
  Schema.decode(BalanceSchema)(value).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidRefundAmountError({
          message: "Invalid sender refund amount",
          cause,
        }),
    ),
  );

const makeGasAccounting = Effect.gen(function* () {
  const refundCalculator = yield* RefundCalculator;

  const calculateGasSettlement = (input: GasAccountingInput) =>
    Effect.gen(function* () {
      const gasLimit = yield* decodeGas(input.gasLimit, "limit");
      const gasLeft = yield* decodeGas(input.gasLeft, "left");
      const effectiveGasPrice = yield* decodeGasPrice(input.effectiveGasPrice);

      const gasLimitValue: bigint = gasLimit;
      const gasLeftValue: bigint = gasLeft;
      const gasUsedBeforeRefundValue = gasLimitValue - gasLeftValue;
      const gasUsedBeforeRefund = yield* decodeGas(
        gasUsedBeforeRefundValue,
        "used before refund",
      );

      const claimableRefund = yield* refundCalculator.calculateClaimableRefund(
        gasUsedBeforeRefund,
        input.refundCounter,
      );
      const gasUsedAfterRefundValue =
        (gasUsedBeforeRefund as bigint) - (claimableRefund as bigint);
      const gasUsedAfterRefund = yield* decodeGas(
        gasUsedAfterRefundValue,
        "used after refund",
      );

      const gasLeftAfterRefundValue =
        gasLimitValue - (gasUsedAfterRefund as bigint);
      yield* decodeGas(gasLeftAfterRefundValue, "left after refund");
      const refundAmountValue =
        gasLeftAfterRefundValue * (effectiveGasPrice as bigint);
      const senderRefundAmount = yield* decodeBalance(refundAmountValue);

      return {
        gasUsedAfterRefund,
        senderRefundAmount,
      } satisfies GasSettlement;
    });

  return { calculateGasSettlement } satisfies GasAccountingService;
});

/** Production gas accounting layer. */
export const GasAccountingLive: Layer.Layer<
  GasAccounting,
  never,
  RefundCalculator
> = Layer.effect(GasAccounting, makeGasAccounting);

/** Deterministic gas accounting layer for tests. */
export const GasAccountingTest: Layer.Layer<GasAccounting> =
  GasAccountingLive.pipe(Layer.provide(RefundCalculatorTest));

const withGasAccounting = <A, E>(
  f: (service: GasAccountingService) => Effect.Effect<A, E>,
) => Effect.flatMap(GasAccounting, f);

/** Compute gas used after refunds and sender refund amount. */
export const calculateGasSettlement = (input: GasAccountingInput) =>
  withGasAccounting((service) => service.calculateGasSettlement(input));
