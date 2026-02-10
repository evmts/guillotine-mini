import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Exit from "effect/Exit";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";
import {
  Balance,
  BaseFeePerGas,
  Blob,
  GasPrice,
  Transaction,
} from "voltaire-effect/primitives";
import {
  beginTransaction,
  commitTransaction,
  rollbackTransaction,
  type TransactionBoundary,
  type TransactionBoundaryError,
} from "../state/TransactionBoundary";

/** Effective gas price breakdown for transaction execution. */
export type EffectiveGasPrice = {
  readonly effectiveGasPrice: GasPrice.GasPriceType;
  readonly priorityFeePerGas: GasPrice.GasPriceType;
};

/** Max gas fee and blob fee breakdown for transaction validation. */
export type MaxGasFeeCheck = {
  readonly maxGasFee: Balance.BalanceType;
  readonly blobGasFee: Balance.BalanceType;
  readonly blobGasUsed: bigint;
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
const BalanceSchema = Balance.BigInt as unknown as Schema.Schema<
  Balance.BalanceType,
  bigint
>;
const toBigInt = (value: bigint | number): bigint =>
  typeof value === "bigint" ? value : BigInt(value);
const BLOB_GAS_PER_BLOB = toBigInt(Blob.GAS_PER_BLOB);

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

/** Error raised when sender balance is invalid. */
export class InvalidBalanceError extends Data.TaggedError(
  "InvalidBalanceError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Error raised when sender balance cannot cover max fees + value. */
export class InsufficientSenderBalanceError extends Data.TaggedError(
  "InsufficientSenderBalanceError",
)<{
  readonly balance: bigint;
  readonly requiredBalance: bigint;
}> {}

/** Error raised when max fee per blob gas is insufficient. */
export class InsufficientMaxFeePerBlobGasError extends Data.TaggedError(
  "InsufficientMaxFeePerBlobGasError",
)<{
  readonly maxFeePerBlobGas: bigint;
  readonly blobGasPrice: bigint;
}> {}

/** Error raised when blob transaction has no blob hashes. */
export class NoBlobDataError extends Data.TaggedError("NoBlobDataError")<{
  readonly message: string;
}> {}

/** Error raised when a blob versioned hash is invalid. */
export class InvalidBlobVersionedHashError extends Data.TaggedError(
  "InvalidBlobVersionedHashError",
)<{
  readonly index: number;
}> {}

/** Error raised when transaction type forbids contract creation. */
export class TransactionTypeContractCreationError extends Data.TaggedError(
  "TransactionTypeContractCreationError",
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

/** Union of max fee and balance validation errors. */
export type MaxGasFeeCheckError =
  | TransactionFeeError
  | InvalidBalanceError
  | InsufficientSenderBalanceError
  | InsufficientMaxFeePerBlobGasError
  | NoBlobDataError
  | InvalidBlobVersionedHashError
  | TransactionTypeContractCreationError;

const runWithinBoundary = <A, E, R>(
  effect: Effect.Effect<A, E, R>,
): Effect.Effect<A, E | TransactionBoundaryError, R | TransactionBoundary> =>
  Effect.gen(function* () {
    yield* beginTransaction();
    const exit = yield* Effect.exit(effect);

    if (Exit.isSuccess(exit)) {
      yield* commitTransaction();
      return exit.value;
    }

    yield* rollbackTransaction();
    return yield* Effect.failCause(exit.cause);
  });

/** Transaction processor service interface (fee calculations). */
export interface TransactionProcessorService {
  readonly calculateEffectiveGasPrice: (
    tx: Transaction.Any,
    baseFeePerGas: bigint,
  ) => Effect.Effect<EffectiveGasPrice, TransactionFeeError>;
  readonly checkMaxGasFeeAndBalance: (
    tx: Transaction.Any,
    baseFeePerGas: bigint,
    blobGasPrice: bigint,
    senderBalance: bigint,
  ) => Effect.Effect<MaxGasFeeCheck, MaxGasFeeCheckError>;
  readonly runInTransactionBoundary: <A, E, R>(
    effect: Effect.Effect<A, E, R>,
  ) => Effect.Effect<A, E | TransactionBoundaryError, R | TransactionBoundary>;
  readonly runInCallFrameBoundary: <A, E, R>(
    effect: Effect.Effect<A, E, R>,
  ) => Effect.Effect<A, E | TransactionBoundaryError, R | TransactionBoundary>;
}

/** Context tag for transaction processor service. */
export class TransactionProcessor extends Context.Tag("TransactionProcessor")<
  TransactionProcessor,
  TransactionProcessorService
>() {}

const withTransactionProcessor = <A, E, R>(
  f: (service: TransactionProcessorService) => Effect.Effect<A, E, R>,
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

const decodeTransaction = (tx: Transaction.Any) =>
  Schema.validate(TransactionSchema)(tx).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidTransactionError({
          message: "Invalid transaction",
          cause,
        }),
    ),
  );

const parseTransactionAndBaseFee = (
  tx: Transaction.Any,
  baseFeePerGas: bigint,
) =>
  Effect.gen(function* () {
    const parsedTx = yield* decodeTransaction(tx);
    const baseFee = yield* decodeBaseFee(baseFeePerGas);
    return { parsedTx, baseFee };
  });

const ensureLegacyGasPrice = (
  tx: Transaction.Legacy | Transaction.EIP2930,
  baseFeePerGas: bigint,
) =>
  tx.gasPrice < baseFeePerGas
    ? Effect.fail(
        new GasPriceBelowBaseFeeError({
          gasPrice: tx.gasPrice,
          baseFeePerGas,
        }),
      )
    : Effect.succeed(tx);

const ensureDynamicFeeBounds = (
  tx: Transaction.EIP1559 | Transaction.EIP4844 | Transaction.EIP7702,
  baseFeePerGas: bigint,
) =>
  Effect.gen(function* () {
    if (tx.maxFeePerGas < tx.maxPriorityFeePerGas) {
      return yield* Effect.fail(
        new PriorityFeeGreaterThanMaxFeeError({
          maxFeePerGas: tx.maxFeePerGas,
          maxPriorityFeePerGas: tx.maxPriorityFeePerGas,
        }),
      );
    }

    if (tx.maxFeePerGas < baseFeePerGas) {
      return yield* Effect.fail(
        new InsufficientMaxFeePerGasError({
          maxFeePerGas: tx.maxFeePerGas,
          baseFeePerGas,
        }),
      );
    }

    return tx;
  });

const decodeBalance = (value: bigint, label: string) =>
  Schema.decode(BalanceSchema)(value).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidBalanceError({
          message: `Invalid ${label} balance`,
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
      const { parsedTx, baseFee } = yield* parseTransactionAndBaseFee(
        tx,
        baseFeePerGas,
      );
      const txType = parsedTx.type;

      if (Transaction.isLegacy(parsedTx) || Transaction.isEIP2930(parsedTx)) {
        const validatedTx = yield* ensureLegacyGasPrice(parsedTx, baseFee);
        const effectiveGasPrice = yield* decodeGasPrice(
          validatedTx.gasPrice,
          "effective",
        );
        const priorityFeePerGas = yield* decodeGasPrice(
          validatedTx.gasPrice - baseFee,
          "priority",
        );

        return { effectiveGasPrice, priorityFeePerGas };
      }

      if (
        Transaction.isEIP1559(parsedTx) ||
        Transaction.isEIP4844(parsedTx) ||
        Transaction.isEIP7702(parsedTx)
      ) {
        const validatedTx = yield* ensureDynamicFeeBounds(parsedTx, baseFee);
        const maxPriorityFee = validatedTx.maxPriorityFeePerGas;
        const maxPayablePriorityFee = validatedTx.maxFeePerGas - baseFee;
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

  const checkMaxGasFeeAndBalance = (
    tx: Transaction.Any,
    baseFeePerGas: bigint,
    blobGasPrice: bigint,
    senderBalance: bigint,
  ) =>
    Effect.gen(function* () {
      const { parsedTx, baseFee } = yield* parseTransactionAndBaseFee(
        tx,
        baseFeePerGas,
      );
      const txType = parsedTx.type;

      let maxGasFeeValue: bigint;

      if (Transaction.isLegacy(parsedTx) || Transaction.isEIP2930(parsedTx)) {
        const validatedTx = yield* ensureLegacyGasPrice(parsedTx, baseFee);
        maxGasFeeValue = validatedTx.gasLimit * validatedTx.gasPrice;
      } else if (
        Transaction.isEIP1559(parsedTx) ||
        Transaction.isEIP4844(parsedTx) ||
        Transaction.isEIP7702(parsedTx)
      ) {
        const validatedTx = yield* ensureDynamicFeeBounds(parsedTx, baseFee);
        maxGasFeeValue = validatedTx.gasLimit * validatedTx.maxFeePerGas;
      } else {
        return yield* Effect.fail(
          new UnsupportedTransactionTypeError({ type: txType }),
        );
      }

      let blobGasUsed = 0n;
      let blobGasFeeValue = 0n;

      if (Transaction.isEIP4844(parsedTx)) {
        if (parsedTx.to == null) {
          return yield* Effect.fail(
            new TransactionTypeContractCreationError({ type: parsedTx.type }),
          );
        }

        if (parsedTx.blobVersionedHashes.length === 0) {
          return yield* Effect.fail(
            new NoBlobDataError({ message: "no blob data in transaction" }),
          );
        }

        for (const [
          index,
          blobHash,
        ] of parsedTx.blobVersionedHashes.entries()) {
          if (!Blob.isValidVersion(blobHash as unknown as Blob.VersionedHash)) {
            return yield* Effect.fail(
              new InvalidBlobVersionedHashError({ index }),
            );
          }
        }

        const normalizedBlobGasPrice = yield* decodeGasPrice(
          blobGasPrice,
          "blob",
        );

        if (parsedTx.maxFeePerBlobGas < normalizedBlobGasPrice) {
          return yield* Effect.fail(
            new InsufficientMaxFeePerBlobGasError({
              maxFeePerBlobGas: parsedTx.maxFeePerBlobGas,
              blobGasPrice: normalizedBlobGasPrice,
            }),
          );
        }

        blobGasUsed =
          BigInt(parsedTx.blobVersionedHashes.length) * BLOB_GAS_PER_BLOB;
        blobGasFeeValue = blobGasUsed * parsedTx.maxFeePerBlobGas;
        maxGasFeeValue += blobGasFeeValue;
      }

      const maxGasFee = yield* decodeBalance(maxGasFeeValue, "max gas fee");
      const blobGasFee = yield* decodeBalance(blobGasFeeValue, "blob gas fee");
      const balance = yield* decodeBalance(senderBalance, "sender");
      const requiredBalanceValue = maxGasFeeValue + parsedTx.value;
      const requiredBalance = yield* decodeBalance(
        requiredBalanceValue,
        "required",
      );

      if (balance < requiredBalance) {
        return yield* Effect.fail(
          new InsufficientSenderBalanceError({
            balance,
            requiredBalance,
          }),
        );
      }

      return { maxGasFee, blobGasFee, blobGasUsed };
    });

  const runInTransactionBoundary = <A, E, R>(effect: Effect.Effect<A, E, R>) =>
    runWithinBoundary(effect);

  const runInCallFrameBoundary = <A, E, R>(effect: Effect.Effect<A, E, R>) =>
    runWithinBoundary(effect);

  return {
    calculateEffectiveGasPrice,
    checkMaxGasFeeAndBalance,
    runInTransactionBoundary,
    runInCallFrameBoundary,
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

/** Check max gas fee, blob fee constraints, and sender balance. */
export const checkMaxGasFeeAndBalance = (
  tx: Transaction.Any,
  baseFeePerGas: bigint,
  blobGasPrice: bigint,
  senderBalance: bigint,
) =>
  withTransactionProcessor((service) =>
    service.checkMaxGasFeeAndBalance(
      tx,
      baseFeePerGas,
      blobGasPrice,
      senderBalance,
    ),
  );

/** Execute a transaction-scoped effect with begin/commit/rollback semantics. */
export const runInTransactionBoundary = <A, E, R>(
  effect: Effect.Effect<A, E, R>,
) =>
  withTransactionProcessor((service) =>
    service.runInTransactionBoundary(effect),
  );

/** Execute a call-frame effect with begin/commit/rollback semantics. */
export const runInCallFrameBoundary = <A, E, R>(
  effect: Effect.Effect<A, E, R>,
) =>
  withTransactionProcessor((service) => service.runInCallFrameBoundary(effect));
