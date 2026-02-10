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

/** Blob transaction support modes (Nethermind BlobsSupportMode parity). */
export const BlobsSupportMode = {
  Disabled: "Disabled",
  InMemory: "InMemory",
  Storage: "Storage",
  StorageWithReorgs: "StorageWithReorgs",
} as const;

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

export type TxPoolValidationError =
  | InvalidTxPoolTransactionError
  | TxPoolTransactionEncodingError
  | TxPoolSenderRecoveryError
  | TxPoolGasLimitExceededError
  | TxPoolMaxTxSizeExceededError
  | TxPoolMaxBlobTxSizeExceededError
  | TxPoolBlobSupportDisabledError
  | TxPoolPriorityFeeTooLowError;

export type TxPoolAddError =
  | TxPoolValidationError
  | TxPoolFullError
  | TxPoolSenderLimitExceededError
  | TxPoolBlobSenderLimitExceededError;

/** Transaction pool service interface. */
export interface TxPoolService {
  readonly getPendingCount: () => Effect.Effect<number, never>;
  readonly getPendingBlobCount: () => Effect.Effect<number, never>;
  readonly getPendingTransactions: () => Effect.Effect<
    ReadonlyArray<Transaction.Any>,
    never
  >;
  readonly getPendingTransactionsBySender: (
    sender: Address.AddressType,
  ) => Effect.Effect<ReadonlyArray<Transaction.Any>, never>;
  readonly validateTransaction: (
    tx: Transaction.Any,
  ) => Effect.Effect<ValidatedTransaction, TxPoolValidationError>;
  readonly addTransaction: (
    tx: Transaction.Any,
  ) => Effect.Effect<TxPoolAddResult, TxPoolAddError>;
  readonly removeTransaction: (
    hash: Hash.HashType,
  ) => Effect.Effect<boolean, never>;
  readonly supportsBlobs: () => Effect.Effect<boolean, never>;
  readonly acceptTxWhenNotSynced: () => Effect.Effect<boolean, never>;
}

/** Context tag for the transaction pool. */
export class TxPool extends Context.Tag("TxPool")<TxPool, TxPoolService>() {}

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

const makeTxPool = (config: TxPoolConfigInput) =>
  Effect.gen(function* () {
    const validatedConfig = yield* decodeConfig(config);
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

    const validateTransaction = (tx: Transaction.Any) =>
      Effect.gen(function* () {
        const parsed = yield* decodeTransaction(tx);
        const isBlob = Transaction.isEIP4844(parsed);

        if (
          isBlob &&
          validatedConfig.blobsSupport === BlobsSupportMode.Disabled
        ) {
          return yield* Effect.fail(
            new TxPoolBlobSupportDisabledError({
              message: "Blob transactions are disabled",
            }),
          );
        }

        if (
          isBlob &&
          parsed.maxPriorityFeePerGas < validatedConfig.minBlobTxPriorityFee
        ) {
          return yield* Effect.fail(
            new TxPoolPriorityFeeTooLowError({
              minPriorityFeePerGas: validatedConfig.minBlobTxPriorityFee,
              maxPriorityFeePerGas: parsed.maxPriorityFeePerGas,
            }),
          );
        }

        if (validatedConfig.gasLimit !== null) {
          const gasLimit = BigInt(validatedConfig.gasLimit);
          if (parsed.gasLimit > gasLimit) {
            return yield* Effect.fail(
              new TxPoolGasLimitExceededError({
                gasLimit: parsed.gasLimit,
                configuredLimit: gasLimit,
              }),
            );
          }
        }

        const encoded = yield* encodeTransaction(parsed);
        const size = encoded.length;

        if (isBlob && validatedConfig.maxBlobTxSize !== null) {
          if (size > validatedConfig.maxBlobTxSize) {
            return yield* Effect.fail(
              new TxPoolMaxBlobTxSizeExceededError({
                size,
                maxSize: validatedConfig.maxBlobTxSize,
              }),
            );
          }
        }

        if (!isBlob && validatedConfig.maxTxSize !== null) {
          if (size > validatedConfig.maxTxSize) {
            return yield* Effect.fail(
              new TxPoolMaxTxSizeExceededError({
                size,
                maxSize: validatedConfig.maxTxSize,
              }),
            );
          }
        }

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

        const outcome = yield* Ref.modify(stateRef, (state) => {
          if (state.transactions.has(hashKey)) {
            return [
              { _tag: "AlreadyKnown", hash: validated.hash } as TxPoolAddResult,
              state,
            ];
          }

          if (
            validatedConfig.size > 0 &&
            state.transactions.size >= validatedConfig.size
          ) {
            return [
              {
                _tag: "Rejected",
                error: new TxPoolFullError({
                  size: state.transactions.size,
                  maxSize: validatedConfig.size,
                }),
              },
              state,
            ];
          }

          if (!validated.isBlob && validatedConfig.maxPendingTxsPerSender > 0) {
            const pending = state.senderIndex.get(senderKey)?.size ?? 0;
            if (pending >= validatedConfig.maxPendingTxsPerSender) {
              return [
                {
                  _tag: "Rejected",
                  error: new TxPoolSenderLimitExceededError({
                    sender: validated.sender,
                    pending,
                    maxPending: validatedConfig.maxPendingTxsPerSender,
                  }),
                },
                state,
              ];
            }
          }

          if (
            validated.isBlob &&
            validatedConfig.maxPendingBlobTxsPerSender > 0
          ) {
            const pending = state.blobSenderIndex.get(senderKey)?.size ?? 0;
            if (pending >= validatedConfig.maxPendingBlobTxsPerSender) {
              return [
                {
                  _tag: "Rejected",
                  error: new TxPoolBlobSenderLimitExceededError({
                    sender: validated.sender,
                    pending,
                    maxPending: validatedConfig.maxPendingBlobTxsPerSender,
                  }),
                },
                state,
              ];
            }
          }

          const nextState = addTransactionToState(
            state,
            validated,
            hashKey,
            senderKey,
          );

          return [
            {
              _tag: "Added",
              hash: validated.hash,
              isBlob: validated.isBlob,
            } as TxPoolAddResult,
            nextState,
          ];
        });

        if (outcome._tag === "Rejected") {
          return yield* Effect.fail(outcome.error);
        }

        return outcome as TxPoolAddResult;
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
): Layer.Layer<TxPool, InvalidTxPoolConfigError> =>
  Layer.effect(TxPool, makeTxPool(config));

/** Deterministic txpool layer for tests. */
export const TxPoolTest = (
  config: TxPoolConfigInput = TxPoolConfigDefaults,
): Layer.Layer<TxPool, InvalidTxPoolConfigError> => TxPoolLive(config);

/** Retrieve the total pending transaction count. */
export const getPendingCount = () =>
  Effect.gen(function* () {
    const pool = yield* TxPool;
    return yield* pool.getPendingCount();
  });

/** Retrieve the total pending blob transaction count. */
export const getPendingBlobCount = () =>
  Effect.gen(function* () {
    const pool = yield* TxPool;
    return yield* pool.getPendingBlobCount();
  });

/** Retrieve pending transactions. */
export const getPendingTransactions = () =>
  Effect.gen(function* () {
    const pool = yield* TxPool;
    return yield* pool.getPendingTransactions();
  });

/** Retrieve pending transactions for a sender. */
export const getPendingTransactionsBySender = (sender: Address.AddressType) =>
  Effect.gen(function* () {
    const pool = yield* TxPool;
    return yield* pool.getPendingTransactionsBySender(sender);
  });

/** Validate a transaction against txpool rules. */
export const validateTransaction = (tx: Transaction.Any) =>
  Effect.gen(function* () {
    const pool = yield* TxPool;
    return yield* pool.validateTransaction(tx);
  });

/** Add a transaction to the pool. */
export const addTransaction = (tx: Transaction.Any) =>
  Effect.gen(function* () {
    const pool = yield* TxPool;
    return yield* pool.addTransaction(tx);
  });

/** Remove a transaction from the pool by hash. */
export const removeTransaction = (hash: Hash.HashType) =>
  Effect.gen(function* () {
    const pool = yield* TxPool;
    return yield* pool.removeTransaction(hash);
  });

/** Check whether blob transactions are supported by configuration. */
export const supportsBlobs = () =>
  Effect.gen(function* () {
    const pool = yield* TxPool;
    return yield* pool.supportsBlobs();
  });

/** Check whether txs are accepted when the node is not synced. */
export const acceptTxWhenNotSynced = () =>
  Effect.gen(function* () {
    const pool = yield* TxPool;
    return yield* pool.acceptTxWhenNotSynced();
  });
