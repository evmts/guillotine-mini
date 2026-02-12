import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import type { Address, Balance, Bytes } from "voltaire-effect/primitives";
import { Hash, Receipt } from "voltaire-effect/primitives";
import type { TransactionEnvironment } from "./TransactionEnvironmentBuilder";
import type { EvmTransactionExecutionOutput } from "./TransactionProcessor";

/** Parameters for executing a top-level EVM message (call or create). */
export type EvmCallParams = {
  readonly to: Address.AddressType | null;
  readonly input: Bytes.BytesType;
  readonly value: Balance.BalanceType;
  readonly isStatic: boolean;
};

/** Error raised when EVM execution fails. */
export class EvmExecutionError extends Data.TaggedError("EvmExecutionError")<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Service interface for executing a single EVM message. */
export interface EvmExecutorService {
  readonly executeCall: (
    env: TransactionEnvironment,
    params: EvmCallParams,
  ) => Effect.Effect<EvmTransactionExecutionOutput, EvmExecutionError>;
}

/** Context tag for the EVM executor. */
export class EvmExecutor extends Context.Tag("EvmExecutor")<
  EvmExecutor,
  EvmExecutorService
>() {}

const makeEvmExecutorLive = Effect.succeed({
  executeCall: () =>
    Effect.fail(
      new EvmExecutionError({ message: "EvmExecutorLive not implemented" }),
    ),
} satisfies EvmExecutorService);

/** Production EVM executor (placeholder – real integration added in later pass). */
export const EvmExecutorLive: Layer.Layer<EvmExecutor> = Layer.effect(
  EvmExecutor,
  makeEvmExecutorLive,
);

const makeEvmExecutorTest = Effect.succeed({
  executeCall: (
    env: TransactionEnvironment,
    params: EvmCallParams,
  ): Effect.Effect<EvmTransactionExecutionOutput, EvmExecutionError> =>
    Effect.sync(() => ({
      gasLeft: env.gas as unknown as bigint,
      refundCounter: 0n,
      logs: [
        {
          address: (params.to ?? env.origin) as Address.AddressType,
          topics: [] as ReadonlyArray<Hash.HashType>,
          data: new Uint8Array(0),
          blockNumber: 0n,
          transactionHash: Hash.ZERO,
          transactionIndex: 0,
          blockHash: Hash.ZERO,
          logIndex: 0,
          removed: false,
        } satisfies Receipt.LogType,
      ],
      accountsToDelete: [],
    })),
} satisfies EvmExecutorService);

/** Deterministic EVM executor for tests. */
export const EvmExecutorTest: Layer.Layer<EvmExecutor> = Layer.effect(
  EvmExecutor,
  makeEvmExecutorTest,
);

const withEvmExecutor = <A, E>(
  f: (svc: EvmExecutorService) => Effect.Effect<A, E>,
) => Effect.flatMap(EvmExecutor, f);

/** Execute a top-level EVM message with the provided environment and params. */
export const executeCall = (
  env: TransactionEnvironment,
  params: EvmCallParams,
) => withEvmExecutor((svc) => svc.executeCall(env, params));
