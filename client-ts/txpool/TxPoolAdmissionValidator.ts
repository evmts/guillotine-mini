import * as Context from "effect/Context";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";
import { Address, Hash, Transaction } from "voltaire-effect/primitives";
import {
  BlobsSupportMode,
  InvalidTxPoolTransactionError,
  TxPoolBlobFeeCapTooLowError,
  TxPoolBlobSupportDisabledError,
  type TxPoolConfig,
  type TxPoolHeadInfoConfig,
  TxPoolHeadInfo,
  TxPoolHeadInfoDefaults,
  TxPoolHeadInfoLive,
  TxPoolGasLimitExceededError,
  TxPoolMaxBlobTxSizeExceededError,
  TxPoolMaxTxSizeExceededError,
  TxPoolPriorityFeeTooLowError,
  TxPoolSenderRecoveryError,
  TxPoolTransactionEncodingError,
  type TxPoolValidationError,
} from "./TxPool";

const TransactionSchema = Transaction.Schema as unknown as Schema.Schema<
  Transaction.Any,
  unknown
>;
const TransactionSerializedSchema =
  Transaction.Serialized as unknown as Schema.Schema<
    Transaction.Any,
    Uint8Array
  >;

/** Normalized transaction details produced by txpool admission validation. */
export type ValidatedTxPoolTransaction = {
  readonly tx: Transaction.Any;
  readonly hash: Hash.HashType;
  readonly sender: Address.AddressType;
  readonly isBlob: boolean;
  readonly size: number;
};

/** Service boundary for txpool admission validation. */
export interface TxPoolAdmissionValidatorService {
  readonly validate: (
    tx: Transaction.Any,
  ) => Effect.Effect<ValidatedTxPoolTransaction, TxPoolValidationError>;
}

/** Context tag for txpool admission validation. */
export class TxPoolAdmissionValidator extends Context.Tag(
  "TxPoolAdmissionValidator",
)<TxPoolAdmissionValidator, TxPoolAdmissionValidatorService>() {}

type TxPoolFilterInput = {
  readonly parsed: Transaction.Any;
  readonly isBlob: boolean;
  readonly currentFeePerBlobGas: bigint;
  readonly effectiveGasLimit: bigint | null;
};

type TxPoolPostHashFilterInput = TxPoolFilterInput & {
  readonly size: number;
};

type IncomingTxFilter<Ctx> = (
  input: Ctx,
) => Effect.Effect<void, TxPoolValidationError>;

const minDefinedBigInt = (
  left: bigint | null,
  right: bigint | null,
): bigint | null => {
  if (left === null) {
    return right;
  }
  if (right === null) {
    return left;
  }
  return left < right ? left : right;
};

const runIncomingTxFilters = <Ctx>(
  filters: ReadonlyArray<IncomingTxFilter<Ctx>>,
  input: Ctx,
) => Effect.forEach(filters, (filter) => filter(input), { discard: true });

const makeTxPoolAdmissionValidator = (config: TxPoolConfig) =>
  Effect.gen(function* () {
    const headInfo = yield* TxPoolHeadInfo;

    const encodeTransaction = (tx: Transaction.Any) =>
      Effect.try({
        try: () => Schema.encodeSync(TransactionSerializedSchema)(tx),
        catch: (cause) =>
          new TxPoolTransactionEncodingError({
            message: "Failed to encode transaction",
            cause,
          }),
      });

    const recoverSender = (tx: Transaction.Any) =>
      Effect.try({
        try: () => Transaction.getSender(tx),
        catch: (cause) =>
          new TxPoolSenderRecoveryError({
            message: "Failed to recover transaction sender",
            cause,
          }),
      });

    const decodeTransaction = (tx: Transaction.Any) =>
      Schema.validate(TransactionSchema)(tx).pipe(
        Effect.mapError(
          (cause) =>
            new InvalidTxPoolTransactionError({
              message: "Invalid transaction",
              cause,
            }),
        ),
      );

    const notSupportedTxFilter: IncomingTxFilter<TxPoolFilterInput> = ({
      isBlob,
    }) => {
      if (isBlob && config.blobsSupport === BlobsSupportMode.Disabled) {
        return Effect.fail(
          new TxPoolBlobSupportDisabledError({
            message: "Blob transactions are disabled",
          }),
        );
      }
      return Effect.void;
    };

    const priorityFeeTooLowFilter: IncomingTxFilter<TxPoolFilterInput> = ({
      isBlob,
      parsed,
    }) => {
      if (!isBlob) {
        return Effect.void;
      }

      const blobTx = parsed as Transaction.EIP4844;
      if (blobTx.maxPriorityFeePerGas < config.minBlobTxPriorityFee) {
        return Effect.fail(
          new TxPoolPriorityFeeTooLowError({
            minPriorityFeePerGas: config.minBlobTxPriorityFee,
            maxPriorityFeePerGas: blobTx.maxPriorityFeePerGas,
          }),
        );
      }
      return Effect.void;
    };

    const blobBaseFeeFilter: IncomingTxFilter<TxPoolFilterInput> = ({
      isBlob,
      parsed,
      currentFeePerBlobGas,
    }) => {
      if (!isBlob) {
        return Effect.void;
      }

      const blobTx = parsed as Transaction.EIP4844;
      if (
        config.currentBlobBaseFeeRequired &&
        blobTx.maxFeePerBlobGas < currentFeePerBlobGas
      ) {
        return Effect.fail(
          new TxPoolBlobFeeCapTooLowError({
            currentFeePerBlobGas,
            maxFeePerBlobGas: blobTx.maxFeePerBlobGas,
          }),
        );
      }
      return Effect.void;
    };

    const gasLimitTxFilter: IncomingTxFilter<TxPoolFilterInput> = ({
      parsed,
      effectiveGasLimit,
    }) => {
      if (effectiveGasLimit !== null && parsed.gasLimit > effectiveGasLimit) {
        return Effect.fail(
          new TxPoolGasLimitExceededError({
            gasLimit: parsed.gasLimit,
            configuredLimit: effectiveGasLimit,
          }),
        );
      }
      return Effect.void;
    };

    const sizeTxFilter: IncomingTxFilter<TxPoolPostHashFilterInput> = ({
      isBlob,
      size,
    }) => {
      if (
        isBlob &&
        config.maxBlobTxSize !== null &&
        size > config.maxBlobTxSize
      ) {
        return Effect.fail(
          new TxPoolMaxBlobTxSizeExceededError({
            size,
            maxSize: config.maxBlobTxSize,
          }),
        );
      }

      if (!isBlob && config.maxTxSize !== null && size > config.maxTxSize) {
        return Effect.fail(
          new TxPoolMaxTxSizeExceededError({
            size,
            maxSize: config.maxTxSize,
          }),
        );
      }

      return Effect.void;
    };

    const preHashFilters: ReadonlyArray<IncomingTxFilter<TxPoolFilterInput>> = [
      notSupportedTxFilter,
      priorityFeeTooLowFilter,
      blobBaseFeeFilter,
      gasLimitTxFilter,
    ];

    const postHashFilters: ReadonlyArray<
      IncomingTxFilter<TxPoolPostHashFilterInput>
    > = [sizeTxFilter];

    const validate = (tx: Transaction.Any) =>
      Effect.gen(function* () {
        const parsed = yield* decodeTransaction(tx);
        const isBlob = Transaction.isEIP4844(parsed);
        const currentBlockGasLimit = yield* headInfo.getBlockGasLimit();
        const currentFeePerBlobGas = yield* headInfo.getCurrentFeePerBlobGas();
        const configuredGasLimit =
          config.gasLimit === null ? null : BigInt(config.gasLimit);
        const effectiveGasLimit = minDefinedBigInt(
          currentBlockGasLimit,
          configuredGasLimit,
        );
        const filterInput = {
          parsed,
          isBlob,
          currentFeePerBlobGas,
          effectiveGasLimit,
        } satisfies TxPoolFilterInput;

        yield* runIncomingTxFilters(preHashFilters, filterInput);

        const encoded = yield* encodeTransaction(parsed);
        const size = encoded.length;
        yield* runIncomingTxFilters(postHashFilters, {
          ...filterInput,
          size,
        } satisfies TxPoolPostHashFilterInput);

        const sender = yield* recoverSender(parsed);
        const hash = Transaction.hash(parsed);

        return {
          tx: parsed,
          hash,
          sender,
          isBlob,
          size,
        } satisfies ValidatedTxPoolTransaction;
      });

    return {
      validate,
    } satisfies TxPoolAdmissionValidatorService;
  });

/** Live txpool admission validator layer. */
export const TxPoolAdmissionValidatorLive = (
  config: TxPoolConfig,
  headInfoConfig: TxPoolHeadInfoConfig = TxPoolHeadInfoDefaults,
): Layer.Layer<TxPoolAdmissionValidator> =>
  Layer.effect(
    TxPoolAdmissionValidator,
    makeTxPoolAdmissionValidator(config),
  ).pipe(Layer.provide(TxPoolHeadInfoLive(headInfoConfig)));

/** Deterministic txpool admission validator layer for tests. */
export const TxPoolAdmissionValidatorTest = (
  config: TxPoolConfig,
  headInfoConfig: TxPoolHeadInfoConfig = TxPoolHeadInfoDefaults,
): Layer.Layer<TxPoolAdmissionValidator> =>
  TxPoolAdmissionValidatorLive(config, headInfoConfig);

/** Validate transaction admission rules for txpool. */
export const validateTxPoolAdmission = (tx: Transaction.Any) =>
  Effect.flatMap(TxPoolAdmissionValidator, (service) => service.validate(tx));
