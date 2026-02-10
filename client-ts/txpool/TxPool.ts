import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Ref from "effect/Ref";
import * as Schema from "effect/Schema";
import {
  Address,
  Hash,
  MaxPriorityFeePerGas,
  Transaction,
} from "voltaire-effect/primitives";
import {
  compareReplacedBlobTransactionByFee,
  compareReplacedTransactionByFee,
} from "./TxPoolSorter";

/** Blob transaction support modes (Nethermind BlobsSupportMode parity). */
export const BlobsSupportMode = {
  Disabled: "Disabled",
  InMemory: "InMemory",
  Storage: "Storage",
  StorageWithReorgs: "StorageWithReorgs",
} as const;

/** Supported blob transaction handling modes. */
export type BlobsSupportMode =
  (typeof BlobsSupportMode)[keyof typeof BlobsSupportMode];

export const BlobsSupportModeSchema = Schema.Union(
  Schema.Literal(BlobsSupportMode.Disabled),
  Schema.Literal(BlobsSupportMode.InMemory),
  Schema.Literal(BlobsSupportMode.Storage),
  Schema.Literal(BlobsSupportMode.StorageWithReorgs),
);

const NonNegativeIntSchema = Schema.NonNegativeInt;
const NullableNonNegativeIntSchema = Schema.NullOr(NonNegativeIntSchema);
const MinBlobTxPriorityFeeInputSchema = Schema.Union(
  Schema.BigIntFromSelf,
  Schema.Number,
  Schema.String,
);
type MinBlobTxPriorityFeeInput = Schema.Schema.Encoded<
  typeof MinBlobTxPriorityFeeInputSchema
>;

/** Runtime chain-head values used by txpool admission filters. */
export type TxPoolHeadInfoConfig = {
  readonly blockGasLimit: bigint | null;
  readonly currentFeePerBlobGas: bigint;
};

/** Default chain-head values used when no live head provider is wired. */
export const TxPoolHeadInfoDefaults: TxPoolHeadInfoConfig = {
  blockGasLimit: null,
  currentFeePerBlobGas: 1n,
};

/** Schema for validating txpool configuration at boundaries. */
export const TxPoolConfigInputSchema = Schema.Struct({
  peerNotificationThreshold: NonNegativeIntSchema,
  minBaseFeeThreshold: NonNegativeIntSchema,
  size: NonNegativeIntSchema,
  blobsSupport: BlobsSupportModeSchema,
  persistentBlobStorageSize: NonNegativeIntSchema,
  blobCacheSize: NonNegativeIntSchema,
  inMemoryBlobPoolSize: NonNegativeIntSchema,
  maxPendingTxsPerSender: NonNegativeIntSchema,
  maxPendingBlobTxsPerSender: NonNegativeIntSchema,
  hashCacheSize: NonNegativeIntSchema,
  gasLimit: NullableNonNegativeIntSchema,
  maxTxSize: NullableNonNegativeIntSchema,
  maxBlobTxSize: NullableNonNegativeIntSchema,
  proofsTranslationEnabled: Schema.Boolean,
  reportMinutes: NullableNonNegativeIntSchema,
  acceptTxWhenNotSynced: Schema.Boolean,
  persistentBroadcastEnabled: Schema.Boolean,
  currentBlobBaseFeeRequired: Schema.Boolean,
  minBlobTxPriorityFee: MinBlobTxPriorityFeeInputSchema,
});

/** Schema for validated txpool configuration. */
export const TxPoolConfigSchema = Schema.Struct({
  peerNotificationThreshold: NonNegativeIntSchema,
  minBaseFeeThreshold: NonNegativeIntSchema,
  size: NonNegativeIntSchema,
  blobsSupport: BlobsSupportModeSchema,
  persistentBlobStorageSize: NonNegativeIntSchema,
  blobCacheSize: NonNegativeIntSchema,
  inMemoryBlobPoolSize: NonNegativeIntSchema,
  maxPendingTxsPerSender: NonNegativeIntSchema,
  maxPendingBlobTxsPerSender: NonNegativeIntSchema,
  hashCacheSize: NonNegativeIntSchema,
  gasLimit: NullableNonNegativeIntSchema,
  maxTxSize: NullableNonNegativeIntSchema,
  maxBlobTxSize: NullableNonNegativeIntSchema,
  proofsTranslationEnabled: Schema.Boolean,
  reportMinutes: NullableNonNegativeIntSchema,
  acceptTxWhenNotSynced: Schema.Boolean,
  persistentBroadcastEnabled: Schema.Boolean,
  currentBlobBaseFeeRequired: Schema.Boolean,
  minBlobTxPriorityFee: MaxPriorityFeePerGas.BigInt,
});

/** Configuration for the transaction pool. */
export type TxPoolConfig = Schema.Schema.Type<typeof TxPoolConfigSchema>;
/** Input configuration for the txpool prior to decoding. */
export type TxPoolConfigInput = Schema.Schema.Encoded<
  typeof TxPoolConfigInputSchema
>;

/** Default txpool configuration derived from Nethermind defaults. */
export const TxPoolConfigDefaults: TxPoolConfigInput = {
  peerNotificationThreshold: 5,
  minBaseFeeThreshold: 70,
  size: 2048,
  blobsSupport: BlobsSupportMode.StorageWithReorgs,
  persistentBlobStorageSize: 16 * 1024,
  blobCacheSize: 256,
  inMemoryBlobPoolSize: 512,
  maxPendingTxsPerSender: 0,
  maxPendingBlobTxsPerSender: 16,
  hashCacheSize: 512 * 1024,
  gasLimit: null,
  maxTxSize: 128 * 1024,
  maxBlobTxSize: 1024 * 1024,
  proofsTranslationEnabled: false,
  reportMinutes: null,
  acceptTxWhenNotSynced: false,
  persistentBroadcastEnabled: true,
  currentBlobBaseFeeRequired: true,
  minBlobTxPriorityFee: 0n,
};

/** Error raised when txpool configuration is invalid. */
export class InvalidTxPoolConfigError extends Data.TaggedError(
  "InvalidTxPoolConfigError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

const TransactionSchema = Transaction.Schema as unknown as Schema.Schema<
  Transaction.Any,
  unknown
>;
const TransactionSerializedSchema =
  Transaction.Serialized as unknown as Schema.Schema<
    Transaction.Any,
    Uint8Array
  >;

/** Result when attempting to add a transaction to the pool. */
export type TxPoolAddResult =
  | {
      readonly _tag: "Added";
      readonly hash: Hash.HashType;
      readonly isBlob: boolean;
    }
  | {
      readonly _tag: "AlreadyKnown";
      readonly hash: Hash.HashType;
    };

type ValidatedTransaction = {
  readonly tx: Transaction.Any;
  readonly hash: Hash.HashType;
  readonly sender: Address.AddressType;
  readonly isBlob: boolean;
  readonly size: number;
};

/** Error raised when a transaction fails schema validation. */
export class InvalidTxPoolTransactionError extends Data.TaggedError(
  "InvalidTxPoolTransactionError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Error raised when transaction serialization fails. */
export class TxPoolTransactionEncodingError extends Data.TaggedError(
  "TxPoolTransactionEncodingError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Error raised when sender recovery fails. */
export class TxPoolSenderRecoveryError extends Data.TaggedError(
  "TxPoolSenderRecoveryError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Error raised when a transaction exceeds the configured gas limit. */
export class TxPoolGasLimitExceededError extends Data.TaggedError(
  "TxPoolGasLimitExceededError",
)<{
  readonly gasLimit: bigint;
  readonly configuredLimit: bigint;
}> {}

/** Error raised when a transaction exceeds the configured size limit. */
export class TxPoolMaxTxSizeExceededError extends Data.TaggedError(
  "TxPoolMaxTxSizeExceededError",
)<{
  readonly size: number;
  readonly maxSize: number;
}> {}

/** Error raised when a blob transaction exceeds the configured size limit. */
export class TxPoolMaxBlobTxSizeExceededError extends Data.TaggedError(
  "TxPoolMaxBlobTxSizeExceededError",
)<{
  readonly size: number;
  readonly maxSize: number;
}> {}

/** Error raised when blob transactions are disabled. */
export class TxPoolBlobSupportDisabledError extends Data.TaggedError(
  "TxPoolBlobSupportDisabledError",
)<{
  readonly message: string;
}> {}

/** Error raised when blob transaction priority fee is too low. */
export class TxPoolPriorityFeeTooLowError extends Data.TaggedError(
  "TxPoolPriorityFeeTooLowError",
)<{
  readonly minPriorityFeePerGas: bigint;
  readonly maxPriorityFeePerGas: bigint;
}> {}

/** Error raised when blob fee cap is below current blob base fee. */
export class TxPoolBlobFeeCapTooLowError extends Data.TaggedError(
  "TxPoolBlobFeeCapTooLowError",
)<{
  readonly currentFeePerBlobGas: bigint;
  readonly maxFeePerBlobGas: bigint;
}> {}

/** Error raised when the pool has reached its capacity. */
export class TxPoolFullError extends Data.TaggedError("TxPoolFullError")<{
  readonly size: number;
  readonly maxSize: number;
}> {}

/** Error raised when a sender exceeds the pending transaction limit. */
export class TxPoolSenderLimitExceededError extends Data.TaggedError(
  "TxPoolSenderLimitExceededError",
)<{
  readonly sender: Address.AddressType;
  readonly pending: number;
  readonly maxPending: number;
}> {}

/** Error raised when a sender exceeds the pending blob transaction limit. */
export class TxPoolBlobSenderLimitExceededError extends Data.TaggedError(
  "TxPoolBlobSenderLimitExceededError",
)<{
  readonly sender: Address.AddressType;
  readonly pending: number;
  readonly maxPending: number;
}> {}

/** Error raised when a same-sender same-nonce replacement does not satisfy fee bump rules. */
export class TxPoolReplacementNotAllowedError extends Data.TaggedError(
  "TxPoolReplacementNotAllowedError",
)<{
  readonly incomingHash: Hash.HashType;
  readonly existingHash: Hash.HashType;
}> {}

/** Validation failures for txpool admission. */
export type TxPoolValidationError =
  | InvalidTxPoolTransactionError
  | TxPoolTransactionEncodingError
  | TxPoolSenderRecoveryError
  | TxPoolGasLimitExceededError
  | TxPoolMaxTxSizeExceededError
  | TxPoolMaxBlobTxSizeExceededError
  | TxPoolBlobSupportDisabledError
  | TxPoolPriorityFeeTooLowError
  | TxPoolBlobFeeCapTooLowError;

/** Errors returned when adding a transaction to the pool. */
export type TxPoolAddError =
  | TxPoolValidationError
  | TxPoolFullError
  | TxPoolSenderLimitExceededError
  | TxPoolBlobSenderLimitExceededError
  | TxPoolReplacementNotAllowedError;

type TxPoolAddOutcome =
  | TxPoolAddResult
  | {
      readonly _tag: "Rejected";
      readonly error: TxPoolAddError;
    };

/** Transaction pool service interface. */
export interface TxPoolService {
  /** Retrieve the total pending transaction count. */
  readonly getPendingCount: () => Effect.Effect<number, never>;
  /** Retrieve the total pending blob transaction count. */
  readonly getPendingBlobCount: () => Effect.Effect<number, never>;
  /** Retrieve all pending transactions. */
  readonly getPendingTransactions: () => Effect.Effect<
    ReadonlyArray<Transaction.Any>,
    never
  >;
  /** Retrieve pending transactions for a sender. */
  readonly getPendingTransactionsBySender: (
    sender: Address.AddressType,
  ) => Effect.Effect<ReadonlyArray<Transaction.Any>, never>;
  /** Validate a transaction against txpool rules. */
  readonly validateTransaction: (
    tx: Transaction.Any,
  ) => Effect.Effect<ValidatedTransaction, TxPoolValidationError>;
  /** Add a transaction to the pool. */
  readonly addTransaction: (
    tx: Transaction.Any,
  ) => Effect.Effect<TxPoolAddResult, TxPoolAddError>;
  /** Remove a transaction by hash. */
  readonly removeTransaction: (
    hash: Hash.HashType,
  ) => Effect.Effect<boolean, never>;
  /** Check whether blob transactions are supported. */
  readonly supportsBlobs: () => Effect.Effect<boolean, never>;
  /** Check whether txs are accepted when the node is not synced. */
  readonly acceptTxWhenNotSynced: () => Effect.Effect<boolean, never>;
}

/** Context tag for the transaction pool. */
export class TxPool extends Context.Tag("TxPool")<TxPool, TxPoolService>() {}

/** Runtime chain-head info used by txpool filters. */
export interface TxPoolHeadInfoService {
  readonly getBlockGasLimit: () => Effect.Effect<bigint | null, never>;
  readonly getCurrentFeePerBlobGas: () => Effect.Effect<bigint, never>;
}

/** Context tag for txpool chain-head info. */
export class TxPoolHeadInfo extends Context.Tag("TxPoolHeadInfo")<
  TxPoolHeadInfo,
  TxPoolHeadInfoService
>() {}

const withTxPool = <A, E>(f: (pool: TxPoolService) => Effect.Effect<A, E>) =>
  Effect.flatMap(TxPool, f);

const parseMinBlobTxPriorityFee = (value: MinBlobTxPriorityFeeInput) =>
  Effect.try({
    try: () => {
      if (typeof value === "bigint") {
        return Schema.decodeSync(MaxPriorityFeePerGas.BigInt)(value);
      }

      if (typeof value === "number") {
        if (!Number.isFinite(value) || !Number.isInteger(value)) {
          throw new Error("minBlobTxPriorityFee must be an integer");
        }
        return Schema.decodeSync(MaxPriorityFeePerGas.BigInt)(BigInt(value));
      }

      const normalized = value.trim();
      if (normalized.length === 0) {
        throw new Error("minBlobTxPriorityFee cannot be empty");
      }

      return Schema.decodeSync(MaxPriorityFeePerGas.BigInt)(BigInt(normalized));
    },
    catch: (cause) =>
      new InvalidTxPoolConfigError({
        message: "Invalid minBlobTxPriorityFee",
        cause,
      }),
  });

const decodeConfig = (config: TxPoolConfigInput) =>
  Schema.decode(TxPoolConfigInputSchema)(config).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidTxPoolConfigError({
          message: "Invalid txpool configuration",
          cause,
        }),
    ),
    Effect.flatMap((decoded) =>
      parseMinBlobTxPriorityFee(decoded.minBlobTxPriorityFee).pipe(
        Effect.map((minBlobTxPriorityFee) => {
          const normalized = {
            ...decoded,
            minBlobTxPriorityFee,
          } satisfies TxPoolConfig;
          return normalized;
        }),
      ),
    ),
  );

type TxPoolState = {
  readonly transactions: Map<string, Transaction.Any>;
  readonly blobTransactions: Map<string, Transaction.EIP4844>;
  readonly senderIndex: Map<string, Set<string>>;
  readonly blobSenderIndex: Map<string, Set<string>>;
  readonly senderByHash: Map<string, string>;
};

const emptyState: TxPoolState = {
  transactions: new Map(),
  blobTransactions: new Map(),
  senderIndex: new Map(),
  blobSenderIndex: new Map(),
  senderByHash: new Map(),
};

const addToIndex = (
  index: Map<string, Set<string>>,
  senderKey: string,
  hashKey: string,
) => {
  const next = new Map(index);
  const set = new Set(next.get(senderKey) ?? []);
  set.add(hashKey);
  next.set(senderKey, set);
  return next;
};

const removeFromIndex = (
  index: Map<string, Set<string>>,
  senderKey: string,
  hashKey: string,
) => {
  const next = new Map(index);
  const set = next.get(senderKey);
  if (!set) {
    return next;
  }
  const updated = new Set(set);
  updated.delete(hashKey);
  if (updated.size === 0) {
    next.delete(senderKey);
  } else {
    next.set(senderKey, updated);
  }
  return next;
};

const addTransactionToState = (
  state: TxPoolState,
  validated: ValidatedTransaction,
  hashKey: string,
  senderKey: string,
): TxPoolState => {
  const transactions = new Map(state.transactions);
  transactions.set(hashKey, validated.tx);

  const blobTransactions = new Map(state.blobTransactions);
  if (validated.isBlob) {
    blobTransactions.set(hashKey, validated.tx as Transaction.EIP4844);
  }

  const senderIndex = addToIndex(state.senderIndex, senderKey, hashKey);
  const blobSenderIndex = validated.isBlob
    ? addToIndex(state.blobSenderIndex, senderKey, hashKey)
    : state.blobSenderIndex;

  const senderByHash = new Map(state.senderByHash);
  senderByHash.set(hashKey, senderKey);

  return {
    transactions,
    blobTransactions,
    senderIndex,
    blobSenderIndex,
    senderByHash,
  };
};

const removeTransactionFromState = (
  state: TxPoolState,
  hashKey: string,
): { readonly removed: boolean; readonly next: TxPoolState } => {
  const existing = state.transactions.get(hashKey);
  if (!existing) {
    return { removed: false, next: state };
  }

  const transactions = new Map(state.transactions);
  transactions.delete(hashKey);

  const blobTransactions = new Map(state.blobTransactions);
  const isBlob = blobTransactions.delete(hashKey);

  const senderByHash = new Map(state.senderByHash);
  const senderKey = senderByHash.get(hashKey);
  senderByHash.delete(hashKey);

  const senderIndex =
    senderKey !== undefined
      ? removeFromIndex(state.senderIndex, senderKey, hashKey)
      : state.senderIndex;
  const blobSenderIndex =
    senderKey !== undefined && isBlob
      ? removeFromIndex(state.blobSenderIndex, senderKey, hashKey)
      : state.blobSenderIndex;

  return {
    removed: true,
    next: {
      transactions,
      blobTransactions,
      senderIndex,
      blobSenderIndex,
      senderByHash,
    },
  };
};

const findCompetingTransactionBySenderAndNonce = (
  state: TxPoolState,
  senderKey: string,
  nonce: bigint,
): { readonly hashKey: string; readonly tx: Transaction.Any } | undefined => {
  const hashes = state.senderIndex.get(senderKey);
  if (!hashes) {
    return undefined;
  }

  for (const hashKey of hashes) {
    const tx = state.transactions.get(hashKey);
    if (tx && tx.nonce === nonce) {
      return { hashKey, tx };
    }
  }

  return undefined;
};

const makeTxPoolHeadInfo = (
  config: TxPoolHeadInfoConfig = TxPoolHeadInfoDefaults,
): TxPoolHeadInfoService =>
  ({
    getBlockGasLimit: () => Effect.succeed(config.blockGasLimit),
    getCurrentFeePerBlobGas: () => Effect.succeed(config.currentFeePerBlobGas),
  }) satisfies TxPoolHeadInfoService;

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

const runIncomingTxFilters = <Ctx>(
  filters: ReadonlyArray<IncomingTxFilter<Ctx>>,
  input: Ctx,
) => Effect.forEach(filters, (filter) => filter(input), { discard: true });

const makeTxPool = (config: TxPoolConfigInput) =>
  Effect.gen(function* () {
    const validatedConfig = yield* decodeConfig(config);
    const headInfo = yield* TxPoolHeadInfo;
    const stateRef = yield* Ref.make(emptyState);

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
      if (
        isBlob &&
        validatedConfig.blobsSupport === BlobsSupportMode.Disabled
      ) {
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
      if (
        isBlob &&
        parsed.maxPriorityFeePerGas < validatedConfig.minBlobTxPriorityFee
      ) {
        return Effect.fail(
          new TxPoolPriorityFeeTooLowError({
            minPriorityFeePerGas: validatedConfig.minBlobTxPriorityFee,
            maxPriorityFeePerGas: parsed.maxPriorityFeePerGas,
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
      if (
        isBlob &&
        validatedConfig.currentBlobBaseFeeRequired &&
        parsed.maxFeePerBlobGas < currentFeePerBlobGas
      ) {
        return Effect.fail(
          new TxPoolBlobFeeCapTooLowError({
            currentFeePerBlobGas,
            maxFeePerBlobGas: parsed.maxFeePerBlobGas,
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
      if (isBlob && validatedConfig.maxBlobTxSize !== null) {
        if (size > validatedConfig.maxBlobTxSize) {
          return Effect.fail(
            new TxPoolMaxBlobTxSizeExceededError({
              size,
              maxSize: validatedConfig.maxBlobTxSize,
            }),
          );
        }
      }

      if (!isBlob && validatedConfig.maxTxSize !== null) {
        if (size > validatedConfig.maxTxSize) {
          return Effect.fail(
            new TxPoolMaxTxSizeExceededError({
              size,
              maxSize: validatedConfig.maxTxSize,
            }),
          );
        }
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

    const validateTransaction = (tx: Transaction.Any) =>
      Effect.gen(function* () {
        const parsed = yield* decodeTransaction(tx);
        const isBlob = Transaction.isEIP4844(parsed);
        const currentBlockGasLimit = yield* headInfo.getBlockGasLimit();
        const currentFeePerBlobGas = yield* headInfo.getCurrentFeePerBlobGas();
        const configuredGasLimit =
          validatedConfig.gasLimit === null
            ? null
            : BigInt(validatedConfig.gasLimit);
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
        } satisfies ValidatedTransaction;
      });

    const getPendingCount = () =>
      Ref.get(stateRef).pipe(Effect.map((state) => state.transactions.size));
    const getPendingBlobCount = () =>
      Ref.get(stateRef).pipe(
        Effect.map((state) => state.blobTransactions.size),
      );
    const getPendingTransactions = () =>
      Ref.get(stateRef).pipe(
        Effect.map((state) => Array.from(state.transactions.values())),
      );
    const getPendingTransactionsBySender = (sender: Address.AddressType) =>
      Ref.get(stateRef).pipe(
        Effect.map((state) => {
          const senderKey = Address.toHex(sender);
          const hashes = state.senderIndex.get(senderKey);
          if (!hashes) {
            return [];
          }
          const transactions: Transaction.Any[] = [];
          for (const hashKey of hashes) {
            const tx = state.transactions.get(hashKey);
            if (tx) {
              transactions.push(tx);
            }
          }
          return transactions;
        }),
      );

    const addTransaction = (tx: Transaction.Any) =>
      Effect.gen(function* () {
        const validated = yield* validateTransaction(tx);
        const hashKey = Hash.toHex(validated.hash);
        const senderKey = Address.toHex(validated.sender);

        const outcome = yield* Ref.modify(
          stateRef,
          (state): [TxPoolAddOutcome, TxPoolState] => {
            if (state.transactions.has(hashKey)) {
              return [{ _tag: "AlreadyKnown", hash: validated.hash }, state];
            }

            const competing = findCompetingTransactionBySenderAndNonce(
              state,
              senderKey,
              validated.tx.nonce,
            );
            const stateAfterReplacement =
              competing === undefined
                ? state
                : removeTransactionFromState(state, competing.hashKey).next;

            if (competing !== undefined) {
              const comparison =
                Transaction.isEIP4844(validated.tx) &&
                Transaction.isEIP4844(competing.tx)
                  ? compareReplacedBlobTransactionByFee(
                      validated.tx,
                      competing.tx,
                    )
                  : compareReplacedTransactionByFee(validated.tx, competing.tx);
              if (comparison !== -1) {
                return [
                  {
                    _tag: "Rejected",
                    error: new TxPoolReplacementNotAllowedError({
                      incomingHash: validated.hash,
                      existingHash: Transaction.hash(competing.tx),
                    }),
                  },
                  state,
                ];
              }
            }

            if (
              validatedConfig.size > 0 &&
              stateAfterReplacement.transactions.size >= validatedConfig.size
            ) {
              return [
                {
                  _tag: "Rejected",
                  error: new TxPoolFullError({
                    size: stateAfterReplacement.transactions.size,
                    maxSize: validatedConfig.size,
                  }),
                },
                state,
              ];
            }

            const pendingLimit = validated.isBlob
              ? validatedConfig.maxPendingBlobTxsPerSender
              : validatedConfig.maxPendingTxsPerSender;
            if (pendingLimit > 0) {
              const pending = validated.isBlob
                ? (stateAfterReplacement.blobSenderIndex.get(senderKey)?.size ??
                  0)
                : (stateAfterReplacement.senderIndex.get(senderKey)?.size ?? 0);
              if (pending >= pendingLimit) {
                return [
                  {
                    _tag: "Rejected",
                    error: validated.isBlob
                      ? new TxPoolBlobSenderLimitExceededError({
                          sender: validated.sender,
                          pending,
                          maxPending: pendingLimit,
                        })
                      : new TxPoolSenderLimitExceededError({
                          sender: validated.sender,
                          pending,
                          maxPending: pendingLimit,
                        }),
                  },
                  state,
                ];
              }
            }

            const nextState = addTransactionToState(
              stateAfterReplacement,
              validated,
              hashKey,
              senderKey,
            );

            return [
              {
                _tag: "Added",
                hash: validated.hash,
                isBlob: validated.isBlob,
              },
              nextState,
            ];
          },
        );

        if (outcome._tag === "Rejected") {
          return yield* Effect.fail(outcome.error);
        }

        return outcome;
      });

    const removeTransaction = (hash: Hash.HashType) =>
      Ref.modify(stateRef, (state) => {
        const hashKey = Hash.toHex(hash);
        const result = removeTransactionFromState(state, hashKey);
        return [result.removed, result.next];
      });

    const supportsBlobs = () =>
      Effect.succeed(
        validatedConfig.blobsSupport !== BlobsSupportMode.Disabled,
      );
    const acceptTxWhenNotSynced = () =>
      Effect.succeed(validatedConfig.acceptTxWhenNotSynced);

    return {
      getPendingCount,
      getPendingBlobCount,
      getPendingTransactions,
      getPendingTransactionsBySender,
      validateTransaction,
      addTransaction,
      removeTransaction,
      supportsBlobs,
      acceptTxWhenNotSynced,
    } satisfies TxPoolService;
  });

/** Production txpool layer. */
export const TxPoolLive = (
  config: TxPoolConfigInput,
  headInfoConfig: TxPoolHeadInfoConfig = TxPoolHeadInfoDefaults,
): Layer.Layer<TxPool, InvalidTxPoolConfigError> =>
  Layer.effect(TxPool, makeTxPool(config)).pipe(
    Layer.provide(TxPoolHeadInfoLive(headInfoConfig)),
  );

/** Deterministic txpool layer for tests. */
export const TxPoolTest = (
  config: TxPoolConfigInput = TxPoolConfigDefaults,
  headInfoConfig: TxPoolHeadInfoConfig = TxPoolHeadInfoDefaults,
): Layer.Layer<TxPool, InvalidTxPoolConfigError> =>
  TxPoolLive(config, headInfoConfig);

/** Layer providing txpool chain-head admission inputs. */
export const TxPoolHeadInfoLive = (
  config: TxPoolHeadInfoConfig = TxPoolHeadInfoDefaults,
): Layer.Layer<TxPoolHeadInfo> =>
  Layer.succeed(TxPoolHeadInfo, makeTxPoolHeadInfo(config));

/** Retrieve the total pending transaction count. */
export const getPendingCount = () =>
  withTxPool((pool) => pool.getPendingCount());

/** Retrieve the total pending blob transaction count. */
export const getPendingBlobCount = () =>
  withTxPool((pool) => pool.getPendingBlobCount());

/** Retrieve pending transactions. */
export const getPendingTransactions = () =>
  withTxPool((pool) => pool.getPendingTransactions());

/** Retrieve pending transactions for a sender. */
export const getPendingTransactionsBySender = (sender: Address.AddressType) =>
  withTxPool((pool) => pool.getPendingTransactionsBySender(sender));

/** Validate a transaction against txpool rules. */
export const validateTransaction = (tx: Transaction.Any) =>
  withTxPool((pool) => pool.validateTransaction(tx));

/** Add a transaction to the pool. */
export const addTransaction = (tx: Transaction.Any) =>
  withTxPool((pool) => pool.addTransaction(tx));

/** Remove a transaction from the pool by hash. */
export const removeTransaction = (hash: Hash.HashType) =>
  withTxPool((pool) => pool.removeTransaction(hash));

/** Check whether blob transactions are supported by configuration. */
export const supportsBlobs = () => withTxPool((pool) => pool.supportsBlobs());

/** Check whether txs are accepted when the node is not synced. */
export const acceptTxWhenNotSynced = () =>
  withTxPool((pool) => pool.acceptTxWhenNotSynced());
