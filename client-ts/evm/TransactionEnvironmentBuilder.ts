import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";
import {
  Address,
  Gas,
  GasPrice,
  Hash,
  Transaction,
  TransactionIndex,
} from "voltaire-effect/primitives";
import {
  AccessListBuilder,
  type AccessListBuilderError,
  type AccessListStorageKey,
} from "./AccessListBuilder";
import {
  IntrinsicGasCalculator,
  type IntrinsicGasError,
} from "./IntrinsicGasCalculator";
import {
  TransientStorage,
  TransientStorageTest,
  type TransientStorageService,
} from "../state/TransientStorage";

const GasBigIntSchema = Gas.BigInt as unknown as Schema.Schema<
  Gas.GasType,
  bigint
>;

/** Transaction environment assembled for EVM execution. */
export type TransactionEnvironment = {
  readonly origin: Address.AddressType;
  readonly gasPrice: GasPrice.GasPriceType;
  readonly gas: Gas.GasType;
  readonly accessListAddresses: ReadonlyArray<Address.AddressType>;
  readonly accessListStorageKeys: ReadonlyArray<AccessListStorageKey>;
  readonly transientStorage: TransientStorageService;
  readonly blobVersionedHashes: ReadonlyArray<Transaction.VersionedHash>;
  readonly indexInBlock: TransactionIndex.TransactionIndexType | null;
  readonly txHash: Hash.HashType | null;
};

/** Inputs needed to build a transaction environment. */
export type TransactionEnvironmentInput = {
  readonly tx: Transaction.Any;
  readonly origin: Address.AddressType;
  readonly coinbase: Address.AddressType;
  readonly gasPrice: GasPrice.GasPriceType;
  readonly indexInBlock?: TransactionIndex.TransactionIndexType | null;
  readonly txHash?: Hash.HashType | null;
};

/** Error raised when available gas cannot be decoded. */
export class InvalidTransactionGasError extends Data.TaggedError(
  "InvalidTransactionGasError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Error raised when transaction gas limit is below intrinsic requirements. */
export class InsufficientTransactionGasError extends Data.TaggedError(
  "InsufficientTransactionGasError",
)<{
  readonly gasLimit: bigint;
  readonly intrinsicGas: Gas.GasType;
  readonly calldataFloorGas: Gas.GasType;
}> {}

/** Union of transaction environment builder errors. */
export type TransactionEnvironmentBuilderError =
  | AccessListBuilderError
  | IntrinsicGasError
  | InvalidTransactionGasError
  | InsufficientTransactionGasError;

/** Transaction environment builder service interface. */
export interface TransactionEnvironmentBuilderService {
  readonly buildTransactionEnvironment: (
    input: TransactionEnvironmentInput,
  ) => Effect.Effect<
    TransactionEnvironment,
    TransactionEnvironmentBuilderError
  >;
}

/** Context tag for the transaction environment builder service. */
export class TransactionEnvironmentBuilder extends Context.Tag(
  "TransactionEnvironmentBuilder",
)<TransactionEnvironmentBuilder, TransactionEnvironmentBuilderService>() {}

const decodeGas = (value: bigint, label: string) =>
  Schema.decode(GasBigIntSchema)(value).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidTransactionGasError({
          message: `Invalid ${label} gas value`,
          cause,
        }),
    ),
  );

const ensureSufficientGas = (
  gasLimit: bigint,
  intrinsicGas: Gas.GasType,
  calldataFloorGas: Gas.GasType,
): Effect.Effect<void, InsufficientTransactionGasError> => {
  const intrinsicValue: bigint = intrinsicGas;
  const floorValue: bigint = calldataFloorGas;
  const required = intrinsicValue > floorValue ? intrinsicValue : floorValue;
  if (gasLimit < required) {
    return Effect.fail(
      new InsufficientTransactionGasError({
        gasLimit,
        intrinsicGas,
        calldataFloorGas,
      }),
    );
  }
  return Effect.succeed(undefined);
};

const EMPTY_BLOB_HASHES: ReadonlyArray<Transaction.VersionedHash> = [];

const makeTransactionEnvironmentBuilder = Effect.gen(function* () {
  const accessListBuilder = yield* AccessListBuilder;
  const intrinsicGasCalculator = yield* IntrinsicGasCalculator;
  const transientStorage = yield* TransientStorage;

  const buildTransactionEnvironment = (input: TransactionEnvironmentInput) =>
    Effect.gen(function* () {
      const {
        tx,
        origin,
        coinbase,
        gasPrice,
        indexInBlock = null,
        txHash = null,
      } = input;
      const { intrinsicGas, calldataFloorGas } =
        yield* intrinsicGasCalculator.calculateIntrinsicGas(tx);
      const accessList = yield* accessListBuilder.buildAccessList(tx, coinbase);

      yield* ensureSufficientGas(tx.gasLimit, intrinsicGas, calldataFloorGas);

      const gasValue = tx.gasLimit - (intrinsicGas as bigint);
      const gas = yield* decodeGas(gasValue, "available");

      yield* transientStorage.clear();

      const blobVersionedHashes = Transaction.isEIP4844(tx)
        ? tx.blobVersionedHashes
        : EMPTY_BLOB_HASHES;

      return {
        origin,
        gasPrice,
        gas,
        accessListAddresses: accessList.addresses,
        accessListStorageKeys: accessList.storageKeys,
        transientStorage,
        blobVersionedHashes,
        indexInBlock,
        txHash,
      } satisfies TransactionEnvironment;
    });

  return {
    buildTransactionEnvironment,
  } satisfies TransactionEnvironmentBuilderService;
});

/** Production transaction environment builder layer. */
export const TransactionEnvironmentBuilderLive: Layer.Layer<
  TransactionEnvironmentBuilder,
  never,
  AccessListBuilder | IntrinsicGasCalculator | TransientStorage
> = Layer.effect(
  TransactionEnvironmentBuilder,
  makeTransactionEnvironmentBuilder,
);

/** Deterministic transaction environment builder layer for tests. */
export const TransactionEnvironmentBuilderTest: Layer.Layer<
  TransactionEnvironmentBuilder,
  never,
  AccessListBuilder | IntrinsicGasCalculator
> = TransactionEnvironmentBuilderLive.pipe(Layer.provide(TransientStorageTest));

/** Build a transaction environment via the service. */
export const buildTransactionEnvironment = (
  input: TransactionEnvironmentInput,
) =>
  Effect.gen(function* () {
    const builder = yield* TransactionEnvironmentBuilder;
    return yield* builder.buildTransactionEnvironment(input);
  });
