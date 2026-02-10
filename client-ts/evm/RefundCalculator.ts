import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";
import { Gas } from "voltaire-effect/primitives";
import { ReleaseSpec, ReleaseSpecPrague } from "./ReleaseSpec";

const GasBigIntSchema = Gas.BigInt as unknown as Schema.Schema<
  Gas.GasType,
  bigint
>;

/** Error raised when gas values cannot be decoded. */
export class InvalidGasError extends Data.TaggedError("InvalidGasError")<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Union of refund calculation errors. */
export type RefundCalculatorError = InvalidGasError;

/** Refund calculator service interface. */
export interface RefundCalculatorService {
  readonly calculateClaimableRefund: (
    spentGas: bigint,
    totalRefund: bigint,
  ) => Effect.Effect<Gas.GasType, RefundCalculatorError>;
}

/** Context tag for the refund calculator service. */
export class RefundCalculator extends Context.Tag("RefundCalculator")<
  RefundCalculator,
  RefundCalculatorService
>() {}

const decodeGas = (value: bigint, label: string) =>
  Schema.decode(GasBigIntSchema)(value).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidGasError({
          message: `Invalid ${label} gas value`,
          cause,
        }),
    ),
  );

const makeRefundCalculator = Effect.gen(function* () {
  const spec = yield* ReleaseSpec;
  const maxRefundQuotient = spec.isEip3529Enabled ? 5n : 2n;

  const calculateClaimableRefund = (spentGas: bigint, totalRefund: bigint) =>
    Effect.gen(function* () {
      const spent = yield* decodeGas(spentGas, "spent");
      const refund = yield* decodeGas(totalRefund, "refund");
      const spentValue: bigint = spent;
      const refundValue: bigint = refund;
      const maxRefund = spentValue / maxRefundQuotient;
      const claimable = refundValue < maxRefund ? refundValue : maxRefund;
      return yield* decodeGas(claimable, "claimable refund");
    });

  return { calculateClaimableRefund } satisfies RefundCalculatorService;
});

/** Production refund calculator layer. */
export const RefundCalculatorLive: Layer.Layer<
  RefundCalculator,
  never,
  ReleaseSpec
> = Layer.effect(RefundCalculator, makeRefundCalculator);

/** Deterministic refund calculator layer for tests. */
export const RefundCalculatorTest: Layer.Layer<RefundCalculator> =
  RefundCalculatorLive.pipe(Layer.provide(ReleaseSpecPrague));

const withRefundCalculator = <A, E>(
  f: (service: RefundCalculatorService) => Effect.Effect<A, E>,
) => Effect.flatMap(RefundCalculator, f);

/** Calculate claimable gas refund based on fork rules. */
export const calculateClaimableRefund = (
  spentGas: bigint,
  totalRefund: bigint,
) =>
  withRefundCalculator((service) =>
    service.calculateClaimableRefund(spentGas, totalRefund),
  );
