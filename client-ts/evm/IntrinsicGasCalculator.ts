import * as Context from "effect/Context";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import { Gas, Transaction } from "voltaire-effect/primitives";
import {
  ReleaseSpec,
  ReleaseSpecPrague,
  type ReleaseSpecService,
} from "./ReleaseSpec";

export type IntrinsicGas = {
  readonly intrinsicGas: Gas.GasType;
  readonly calldataFloorGas: Gas.GasType;
};

export interface IntrinsicGasCalculatorService {
  readonly calculateIntrinsicGas: (
    tx: Transaction.Any,
  ) => Effect.Effect<IntrinsicGas>;
}

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

const toGas = (value: bigint): Gas.GasType => value as Gas.GasType;

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

const calculateIntrinsicGasValue = (
  tx: Transaction.Any,
  spec: ReleaseSpecService,
): IntrinsicGas => {
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

  return {
    intrinsicGas: toGas(intrinsicGas),
    calldataFloorGas: toGas(calldataFloorGas),
  };
};

const makeIntrinsicGasCalculator = Effect.gen(function* () {
  const spec = yield* ReleaseSpec;
  return {
    calculateIntrinsicGas: (tx: Transaction.Any) =>
      Effect.sync(() => calculateIntrinsicGasValue(tx, spec)),
  } satisfies IntrinsicGasCalculatorService;
});

export const IntrinsicGasCalculatorLive: Layer.Layer<
  IntrinsicGasCalculator,
  never,
  ReleaseSpec
> = Layer.effect(IntrinsicGasCalculator, makeIntrinsicGasCalculator);

export const IntrinsicGasCalculatorTest: Layer.Layer<IntrinsicGasCalculator> =
  IntrinsicGasCalculatorLive.pipe(Layer.provide(ReleaseSpecPrague));

export const calculateIntrinsicGas = (tx: Transaction.Any) =>
  Effect.gen(function* () {
    const calculator = yield* IntrinsicGasCalculator;
    return yield* calculator.calculateIntrinsicGas(tx);
  });
