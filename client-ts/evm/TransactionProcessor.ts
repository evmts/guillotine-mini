import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";
import {
  BaseFeePerGas,
  GasPrice,
  Transaction,
} from "voltaire-effect/primitives";

/** Effective gas price breakdown for transaction execution. */
export type EffectiveGasPrice = {
  readonly effectiveGasPrice: GasPrice.GasPriceType;
  readonly priorityFeePerGas: GasPrice.GasPriceType;
};

const TransactionSchema = Transaction.Schema as unknown as Schema.Schema<
  Transaction.Any,
  unknown
>;
const BaseFeeSchema = BaseFeePerGas.BigInt as unknown as Schema.Schema<
  BaseFeePerGas.BaseFeePerGasType,
  bigint
>;
const GasPriceSchema = GasPrice.BigInt as unknown as Schema.Schema<
  GasPrice.GasPriceType,
  bigint
>;

/** Error raised when transaction decoding fails. */
export class InvalidTransactionError extends Data.TaggedError(
  "InvalidTransactionError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Error raised when base fee per gas is invalid. */
export class InvalidBaseFeeError extends Data.TaggedError(
  "InvalidBaseFeeError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Error raised when a gas price calculation yields an invalid value. */
export class InvalidGasPriceError extends Data.TaggedError(
  "InvalidGasPriceError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Error raised when max priority fee is greater than max fee. */
export class PriorityFeeGreaterThanMaxFeeError extends Data.TaggedError(
  "PriorityFeeGreaterThanMaxFeeError",
)<{
  readonly maxFeePerGas: bigint;
  readonly maxPriorityFeePerGas: bigint;
}> {}

/** Error raised when max fee per gas is below base fee. */
export class InsufficientMaxFeePerGasError extends Data.TaggedError(
  "InsufficientMaxFeePerGasError",
)<{
  readonly maxFeePerGas: bigint;
  readonly baseFeePerGas: bigint;
}> {}

/** Error raised when legacy gas price is below base fee. */
export class GasPriceBelowBaseFeeError extends Data.TaggedError(
  "GasPriceBelowBaseFeeError",
)<{
  readonly gasPrice: bigint;
  readonly baseFeePerGas: bigint;
}> {}

/** Error raised when transaction type is unsupported. */
export class UnsupportedTransactionTypeError extends Data.TaggedError(
  "UnsupportedTransactionTypeError",
)<{
  readonly type: Transaction.Any["type"];
}> {}

/** Union of transaction fee calculation errors. */
export type TransactionFeeError =
  | InvalidTransactionError
  | InvalidBaseFeeError
  | InvalidGasPriceError
  | PriorityFeeGreaterThanMaxFeeError
  | InsufficientMaxFeePerGasError
  | GasPriceBelowBaseFeeError
  | UnsupportedTransactionTypeError;

/** Transaction processor service interface (fee calculations). */
export interface TransactionProcessorService {
  readonly calculateEffectiveGasPrice: (
    tx: Transaction.Any,
    baseFeePerGas: bigint,
  ) => Effect.Effect<EffectiveGasPrice, TransactionFeeError>;
}

/** Context tag for transaction processor service. */
export class TransactionProcessor extends Context.Tag("TransactionProcessor")<
  TransactionProcessor,
  TransactionProcessorService
>() {}

const withTransactionProcessor = <A, E>(
  f: (service: TransactionProcessorService) => Effect.Effect<A, E>,
) => Effect.flatMap(TransactionProcessor, f);

const decodeBaseFee = (value: bigint) =>
  Schema.decode(BaseFeeSchema)(value).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidBaseFeeError({
          message: "Invalid base fee per gas",
          cause,
        }),
    ),
  );

const decodeGasPrice = (value: bigint, label: string) =>
  Schema.decode(GasPriceSchema)(value).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidGasPriceError({
          message: `Invalid ${label} gas price`,
          cause,
        }),
    ),
  );

const makeTransactionProcessor = Effect.gen(function* () {
  const calculateEffectiveGasPrice = (
    tx: Transaction.Any,
    baseFeePerGas: bigint,
  ) =>
    Effect.gen(function* () {
      const parsedTx = yield* Schema.decode(TransactionSchema)(tx).pipe(
        Effect.mapError(
          (cause) =>
            new InvalidTransactionError({
              message: "Invalid transaction",
              cause,
            }),
        ),
      );
      const baseFee = yield* decodeBaseFee(baseFeePerGas);

      const txType = parsedTx.type;

      if (Transaction.isLegacy(parsedTx) || Transaction.isEIP2930(parsedTx)) {
        if (parsedTx.gasPrice < baseFee) {
          return yield* Effect.fail(
            new GasPriceBelowBaseFeeError({
              gasPrice: parsedTx.gasPrice,
              baseFeePerGas: baseFee,
            }),
          );
        }

        const effectiveGasPrice = yield* decodeGasPrice(
          parsedTx.gasPrice,
          "effective",
        );
        const priorityFeePerGas = yield* decodeGasPrice(
          parsedTx.gasPrice - baseFee,
          "priority",
        );

        return { effectiveGasPrice, priorityFeePerGas };
      }

      if (
        Transaction.isEIP1559(parsedTx) ||
        Transaction.isEIP4844(parsedTx) ||
        Transaction.isEIP7702(parsedTx)
      ) {
        if (parsedTx.maxFeePerGas < parsedTx.maxPriorityFeePerGas) {
          return yield* Effect.fail(
            new PriorityFeeGreaterThanMaxFeeError({
              maxFeePerGas: parsedTx.maxFeePerGas,
              maxPriorityFeePerGas: parsedTx.maxPriorityFeePerGas,
            }),
          );
        }

        if (parsedTx.maxFeePerGas < baseFee) {
          return yield* Effect.fail(
            new InsufficientMaxFeePerGasError({
              maxFeePerGas: parsedTx.maxFeePerGas,
              baseFeePerGas: baseFee,
            }),
          );
        }

        const maxPriorityFee = parsedTx.maxPriorityFeePerGas;
        const maxPayablePriorityFee = parsedTx.maxFeePerGas - baseFee;
        const priorityFeeValue =
          maxPriorityFee < maxPayablePriorityFee
            ? maxPriorityFee
            : maxPayablePriorityFee;
        const effectiveGasPriceValue = baseFee + priorityFeeValue;

        const effectiveGasPrice = yield* decodeGasPrice(
          effectiveGasPriceValue,
          "effective",
        );
        const priorityFeePerGas = yield* decodeGasPrice(
          priorityFeeValue,
          "priority",
        );

        return { effectiveGasPrice, priorityFeePerGas };
      }

      return yield* Effect.fail(
        new UnsupportedTransactionTypeError({ type: txType }),
      );
    });

  return {
    calculateEffectiveGasPrice,
  } satisfies TransactionProcessorService;
});

/** Production transaction processor layer. */
export const TransactionProcessorLive: Layer.Layer<TransactionProcessor> =
  Layer.effect(TransactionProcessor, makeTransactionProcessor);

/** Deterministic transaction processor layer for tests. */
export const TransactionProcessorTest = TransactionProcessorLive;

/** Calculate effective gas price and priority fee per gas. */
export const calculateEffectiveGasPrice = (
  tx: Transaction.Any,
  baseFeePerGas: bigint,
) =>
  withTransactionProcessor((service) =>
    service.calculateEffectiveGasPrice(tx, baseFeePerGas),
  );
