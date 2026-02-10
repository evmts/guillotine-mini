import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Ref from "effect/Ref";
import * as Schema from "effect/Schema";
import { MaxPriorityFeePerGas } from "voltaire-effect/primitives";

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

/** Schema for validating txpool configuration at boundaries. */
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
  typeof TxPoolConfigSchema
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

/** Transaction pool service interface. */
export interface TxPoolService {
  readonly getPendingCount: () => Effect.Effect<number, never>;
  readonly getPendingBlobCount: () => Effect.Effect<number, never>;
  readonly supportsBlobs: () => Effect.Effect<boolean, never>;
  readonly acceptTxWhenNotSynced: () => Effect.Effect<boolean, never>;
}

/** Context tag for the transaction pool. */
export class TxPool extends Context.Tag("TxPool")<TxPool, TxPoolService>() {}

const decodeConfig = (config: TxPoolConfigInput) =>
  Schema.decode(TxPoolConfigSchema)(config).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidTxPoolConfigError({
          message: "Invalid txpool configuration",
          cause,
        }),
    ),
  );

const makeTxPool = (config: TxPoolConfigInput) =>
  Effect.gen(function* () {
    const validatedConfig = yield* decodeConfig(config);
    const pendingRef = yield* Ref.make(0);
    const pendingBlobRef = yield* Ref.make(0);

    const getPendingCount = () => Ref.get(pendingRef);
    const getPendingBlobCount = () => Ref.get(pendingBlobRef);
    const supportsBlobs = () =>
      Effect.succeed(
        validatedConfig.blobsSupport !== BlobsSupportMode.Disabled,
      );
    const acceptTxWhenNotSynced = () =>
      Effect.succeed(validatedConfig.acceptTxWhenNotSynced);

    return {
      getPendingCount,
      getPendingBlobCount,
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
