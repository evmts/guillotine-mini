import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";
import { Gas, Transaction } from "voltaire-effect/primitives";
import { requiresAccessListSupport } from "./internal/accessListSupport";
import {
  ReleaseSpec,
  ReleaseSpecPrague,
  type ReleaseSpecService,
} from "./ReleaseSpec";

/** Intrinsic gas result including calldata floor (when enabled). */
export type IntrinsicGas = {
  readonly intrinsicGas: Gas.GasType;
  readonly calldataFloorGas: Gas.GasType;
};

const TransactionSchema = Transaction.Schema as unknown as Schema.Schema<
  Transaction.Any,
  unknown
>;
const GasBigIntSchema = Gas.BigInt as unknown as Schema.Schema<
  Gas.GasType,
  bigint
>;

/** Error raised when the transaction fails intrinsic-gas validation. */
export class InvalidTransactionError extends Data.TaggedError(
  "InvalidTransactionError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Error raised when required hardfork features are unavailable. */
export class UnsupportedIntrinsicGasFeatureError extends Data.TaggedError(
  "UnsupportedIntrinsicGasFeatureError",
)<{
  readonly feature: string;
  readonly hardfork: ReleaseSpecService["hardfork"];
}> {}

/** Error raised when computed gas values violate schema constraints. */
export class InvalidGasError extends Data.TaggedError("InvalidGasError")<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Union of intrinsic gas calculation errors. */
export type IntrinsicGasError =
  | InvalidTransactionError
  | UnsupportedIntrinsicGasFeatureError
  | InvalidGasError;

/** Intrinsic gas calculator service interface. */
export interface IntrinsicGasCalculatorService {
  readonly calculateIntrinsicGas: (
    tx: Transaction.Any,
  ) => Effect.Effect<IntrinsicGas, IntrinsicGasError>;
}

/** Context tag for the intrinsic gas calculator service. */
export class IntrinsicGasCalculator extends Context.Tag(
  "IntrinsicGasCalculator",
)<IntrinsicGasCalculator, IntrinsicGasCalculatorService>() {}

const TX_BASE_COST = 21_000n;
const FLOOR_CALLDATA_COST = 10n;
const STANDARD_CALLDATA_TOKEN_COST = 4n;
const TX_CREATE_COST = 32_000n;
const TX_ACCESS_LIST_ADDRESS_COST = 2_400n;
const TX_ACCESS_LIST_STORAGE_KEY_COST = 1_900n;
const PER_EMPTY_ACCOUNT_COST = 25_000n;
const INIT_CODE_WORD_COST = 2n;
const CALLDATA_NONZERO_MULTIPLIER_EIP2028 = 4n;
const CALLDATA_NONZERO_MULTIPLIER_LEGACY = 17n;

const decodeGas = (
  value: bigint,
  label: string,
): Effect.Effect<Gas.GasType, InvalidGasError> =>
  Schema.decode(GasBigIntSchema)(value).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidGasError({
          message: `Invalid ${label} gas value`,
          cause,
        }),
    ),
  );

const countZeroBytes = (data: Uint8Array): number => {
  let zeros = 0;
  for (let i = 0; i < data.length; i += 1) {
    if (data[i] === 0) {
      zeros += 1;
    }
  }
  return zeros;
};

const tokensInCalldata = (
  data: Uint8Array,
  nonZeroMultiplier: bigint,
): bigint => {
  const zeroBytes = BigInt(countZeroBytes(data));
  const nonZeroBytes = BigInt(data.length) - zeroBytes;
  return zeroBytes + nonZeroBytes * nonZeroMultiplier;
};

const ceilDiv = (value: bigint, divisor: bigint): bigint =>
  (value + divisor - 1n) / divisor;

const initCodeCost = (length: number): bigint => {
  if (length === 0) {
    return 0n;
  }
  const words = ceilDiv(BigInt(length), 32n);
  return words * INIT_CODE_WORD_COST;
};

const accessListCost = (
  tx: Transaction.Any,
  isEip2930Enabled: boolean,
): bigint => {
  if (!isEip2930Enabled) {
    return 0n;
  }
  switch (tx.type) {
    case Transaction.Type.EIP2930:
    case Transaction.Type.EIP1559:
    case Transaction.Type.EIP4844:
    case Transaction.Type.EIP7702: {
      let total = 0n;
      for (const entry of tx.accessList) {
        total += TX_ACCESS_LIST_ADDRESS_COST;
        total +=
          BigInt(entry.storageKeys.length) * TX_ACCESS_LIST_STORAGE_KEY_COST;
      }
      return total;
    }
    default:
      return 0n;
  }
};

const authorizationCost = (
  tx: Transaction.Any,
  isEip7702Enabled: boolean,
): bigint =>
  isEip7702Enabled && tx.type === Transaction.Type.EIP7702
    ? BigInt(tx.authorizationList.length) * PER_EMPTY_ACCOUNT_COST
    : 0n;

const validateTransaction = (
  tx: Transaction.Any,
): Effect.Effect<Transaction.Any, InvalidTransactionError> =>
  Schema.validate(TransactionSchema)(tx).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidTransactionError({
          message: "Invalid transaction shape for intrinsic gas calculation",
          cause,
        }),
    ),
    Effect.flatMap((validated) =>
      Effect.gen(function* () {
        if (!(validated.data instanceof Uint8Array)) {
          return yield* Effect.fail(
            new InvalidTransactionError({
              message:
                "Invalid transaction shape for intrinsic gas calculation",
            }),
          );
        }
        if (typeof validated.gasLimit !== "bigint") {
          return yield* Effect.fail(
            new InvalidTransactionError({
              message:
                "Invalid transaction shape for intrinsic gas calculation",
            }),
          );
        }

        if (
          Transaction.isEIP2930(validated) ||
          Transaction.isEIP1559(validated) ||
          Transaction.isEIP4844(validated) ||
          Transaction.isEIP7702(validated)
        ) {
          if (!Array.isArray(validated.accessList)) {
            return yield* Effect.fail(
              new InvalidTransactionError({
                message:
                  "Invalid transaction shape for intrinsic gas calculation",
              }),
            );
          }
        }

        if (
          Transaction.isEIP7702(validated) &&
          !Array.isArray(validated.authorizationList)
        ) {
          return yield* Effect.fail(
            new InvalidTransactionError({
              message:
                "Invalid transaction shape for intrinsic gas calculation",
            }),
          );
        }

        return validated;
      }),
    ),
  );

const ensureAccessListSupport = (
  tx: Transaction.Any,
  spec: ReleaseSpecService,
): Effect.Effect<void, UnsupportedIntrinsicGasFeatureError> =>
  requiresAccessListSupport(tx) && !spec.isEip2930Enabled
    ? Effect.fail(
        new UnsupportedIntrinsicGasFeatureError({
          feature: "EIP-2930 access lists",
          hardfork: spec.hardfork,
        }),
      )
    : Effect.succeed(undefined);

const ensureAuthorizationSupport = (
  tx: Transaction.Any,
  spec: ReleaseSpecService,
): Effect.Effect<void, UnsupportedIntrinsicGasFeatureError> =>
  tx.type === Transaction.Type.EIP7702 && !spec.isEip7702Enabled
    ? Effect.fail(
        new UnsupportedIntrinsicGasFeatureError({
          feature: "EIP-7702 authorization lists",
          hardfork: spec.hardfork,
        }),
      )
    : Effect.succeed(undefined);

type IntrinsicGasValue = {
  readonly intrinsicGas: bigint;
  readonly calldataFloorGas: bigint;
};

const calculateIntrinsicGasValue = (
  tx: Transaction.Any,
  spec: ReleaseSpecService,
): IntrinsicGasValue => {
  const nonZeroMultiplier = spec.isEip2028Enabled
    ? CALLDATA_NONZERO_MULTIPLIER_EIP2028
    : CALLDATA_NONZERO_MULTIPLIER_LEGACY;
  const tokens = tokensInCalldata(tx.data, nonZeroMultiplier);
  const calldataFloorGas = spec.isEip7623Enabled
    ? TX_BASE_COST + tokens * FLOOR_CALLDATA_COST
    : 0n;
  const dataCost = tokens * STANDARD_CALLDATA_TOKEN_COST;
  const createCost = Transaction.isContractCreation(tx)
    ? TX_CREATE_COST +
      (spec.isEip3860Enabled ? initCodeCost(tx.data.length) : 0n)
    : 0n;
  const intrinsicGas =
    TX_BASE_COST +
    dataCost +
    createCost +
    accessListCost(tx, spec.isEip2930Enabled) +
    authorizationCost(tx, spec.isEip7702Enabled);

  return { intrinsicGas, calldataFloorGas };
};

const makeIntrinsicGasCalculator = Effect.gen(function* () {
  const spec = yield* ReleaseSpec;
  return {
    calculateIntrinsicGas: (tx: Transaction.Any) =>
      Effect.gen(function* () {
        const validated = yield* validateTransaction(tx);
        yield* ensureAccessListSupport(validated, spec);
        yield* ensureAuthorizationSupport(validated, spec);
        const gasValue = calculateIntrinsicGasValue(validated, spec);
        const intrinsicGas = yield* decodeGas(
          gasValue.intrinsicGas,
          "intrinsic",
        );
        const calldataFloorGas = yield* decodeGas(
          gasValue.calldataFloorGas,
          "calldata floor",
        );
        return { intrinsicGas, calldataFloorGas };
      }),
  } satisfies IntrinsicGasCalculatorService;
});

/** Production intrinsic gas calculator layer. */
export const IntrinsicGasCalculatorLive: Layer.Layer<
  IntrinsicGasCalculator,
  never,
  ReleaseSpec
> = Layer.effect(IntrinsicGasCalculator, makeIntrinsicGasCalculator);

/** Deterministic intrinsic gas calculator layer for tests. */
export const IntrinsicGasCalculatorTest: Layer.Layer<IntrinsicGasCalculator> =
  IntrinsicGasCalculatorLive.pipe(Layer.provide(ReleaseSpecPrague));

/** Calculate intrinsic gas for a transaction via the service. */
export const calculateIntrinsicGas = (tx: Transaction.Any) =>
  Effect.gen(function* () {
    const calculator = yield* IntrinsicGasCalculator;
    return yield* calculator.calculateIntrinsicGas(tx);
  });
