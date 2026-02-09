import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Ref from "effect/Ref";
import * as Schema from "effect/Schema";

/** Configuration for the transaction pool. */
export interface TxPoolConfig {
  readonly pendingCount: number;
  readonly pendingBlobCount: number;
}

const PendingCountSchema = Schema.NonNegativeInt;

/** Schema for validating txpool configuration at boundaries. */
export const TxPoolConfigSchema = Schema.Struct({
  pendingCount: PendingCountSchema,
  pendingBlobCount: PendingCountSchema,
});

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
}

/** Context tag for the transaction pool. */
export class TxPool extends Context.Tag("TxPool")<TxPool, TxPoolService>() {}

const decodeConfig = (config: TxPoolConfig) =>
  Schema.decode(TxPoolConfigSchema)(config).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidTxPoolConfigError({
          message: "Invalid txpool configuration",
          cause,
        }),
    ),
  );

const makeTxPool = (config: TxPoolConfig) =>
  Effect.gen(function* () {
    const validated = yield* decodeConfig(config);
    const pendingRef = yield* Ref.make(validated.pendingCount);
    const pendingBlobRef = yield* Ref.make(validated.pendingBlobCount);

    const getPendingCount = () => Ref.get(pendingRef);
    const getPendingBlobCount = () => Ref.get(pendingBlobRef);

    return { getPendingCount, getPendingBlobCount } satisfies TxPoolService;
  });

/** Production txpool layer. */
export const TxPoolLive = (
  config: TxPoolConfig,
): Layer.Layer<TxPool, InvalidTxPoolConfigError> =>
  Layer.effect(TxPool, makeTxPool(config));

/** Deterministic txpool layer for tests. */
export const TxPoolTest = (
  config: TxPoolConfig = { pendingCount: 0, pendingBlobCount: 0 },
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
