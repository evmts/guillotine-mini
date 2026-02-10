import * as Data from "effect/Data";
import {
  BaseFeePerGas,
  EffectiveGasPrice,
  GasPrice,
  MaxFeePerGas,
  MaxPriorityFeePerGas,
  Transaction,
} from "voltaire-effect/primitives";

type CompareResult = -1 | 0 | 1;
type FeeTuple = Readonly<{
  gasPrice: GasPrice.GasPriceType;
  maxFeePerGas: MaxFeePerGas.MaxFeePerGasType;
  maxPriorityFeePerGas: MaxPriorityFeePerGas.MaxPriorityFeePerGasType;
}>;
type ReplacementFeeTuple = Readonly<{
  gasPrice: bigint;
  maxFeePerGas: bigint;
  maxPriorityFeePerGas: bigint;
  supports1559: boolean;
}>;
type BlobReplacementFeeTuple = Readonly<{
  maxFeePerGas: bigint;
  maxPriorityFeePerGas: bigint;
  maxFeePerBlobGas: bigint;
  blobCount: number;
}>;

/** Error raised when the transaction type is not supported by the sorter. */
export class TxPoolSorterUnsupportedTransactionTypeError extends Data.TaggedError(
  "TxPoolSorterUnsupportedTransactionTypeError",
)<{
  readonly type: Transaction.Any["type"];
}> {}

const ZeroGasPrice = 0n as GasPrice.GasPriceType;
const ZeroMaxFeePerGas = 0n as MaxFeePerGas.MaxFeePerGasType;
const ZeroMaxPriorityFeePerGas =
  0n as MaxPriorityFeePerGas.MaxPriorityFeePerGasType;

const compareDescending = (left: bigint, right: bigint): CompareResult => {
  if (left > right) {
    return -1;
  }
  if (left < right) {
    return 1;
  }
  return 0;
};

const compareThresholdAgainstCandidate = (
  threshold: bigint,
  candidate: bigint,
): CompareResult => {
  if (threshold > candidate) {
    return 1;
  }
  if (threshold < candidate) {
    return -1;
  }
  return 0;
};

const isLegacyFeeFields = (
  maxFeePerGas: MaxFeePerGas.MaxFeePerGasType,
  maxPriorityFeePerGas: MaxPriorityFeePerGas.MaxPriorityFeePerGasType,
): boolean => maxFeePerGas === 0n && maxPriorityFeePerGas === 0n;

const resolveMaxFee = (
  gasPrice: GasPrice.GasPriceType,
  maxFeePerGas: MaxFeePerGas.MaxFeePerGasType,
  isLegacy: boolean,
): MaxFeePerGas.MaxFeePerGasType =>
  isLegacy
    ? (gasPrice as unknown as MaxFeePerGas.MaxFeePerGasType)
    : maxFeePerGas;

const resolveMaxPriority = (
  gasPrice: GasPrice.GasPriceType,
  maxPriorityFeePerGas: MaxPriorityFeePerGas.MaxPriorityFeePerGasType,
  isLegacy: boolean,
): MaxPriorityFeePerGas.MaxPriorityFeePerGasType =>
  isLegacy
    ? (gasPrice as unknown as MaxPriorityFeePerGas.MaxPriorityFeePerGasType)
    : maxPriorityFeePerGas;

const isDynamicFeeTransaction = (
  tx: Transaction.Any,
): tx is Transaction.EIP1559 | Transaction.EIP4844 | Transaction.EIP7702 =>
  Transaction.isEIP1559(tx) ||
  Transaction.isEIP4844(tx) ||
  Transaction.isEIP7702(tx);

const feeTupleFromTransaction = (tx: Transaction.Any): FeeTuple => {
  if (Transaction.isLegacy(tx) || Transaction.isEIP2930(tx)) {
    return {
      gasPrice: tx.gasPrice as GasPrice.GasPriceType,
      maxFeePerGas: ZeroMaxFeePerGas,
      maxPriorityFeePerGas: ZeroMaxPriorityFeePerGas,
    };
  }

  if (isDynamicFeeTransaction(tx)) {
    return {
      gasPrice: tx.maxPriorityFeePerGas as GasPrice.GasPriceType,
      maxFeePerGas: tx.maxFeePerGas as MaxFeePerGas.MaxFeePerGasType,
      maxPriorityFeePerGas:
        tx.maxPriorityFeePerGas as MaxPriorityFeePerGas.MaxPriorityFeePerGasType,
    };
  }

  throw new TxPoolSorterUnsupportedTransactionTypeError({ type: tx.type });
};

const replacementFeeTupleFromTransaction = (
  tx: Transaction.Any,
): ReplacementFeeTuple => {
  if (Transaction.isLegacy(tx) || Transaction.isEIP2930(tx)) {
    return {
      gasPrice: tx.gasPrice,
      maxFeePerGas: tx.gasPrice,
      maxPriorityFeePerGas: tx.gasPrice,
      supports1559: false,
    };
  }

  if (isDynamicFeeTransaction(tx)) {
    return {
      gasPrice: tx.maxPriorityFeePerGas,
      maxFeePerGas: tx.maxFeePerGas,
      maxPriorityFeePerGas: tx.maxPriorityFeePerGas,
      supports1559: true,
    };
  }

  throw new TxPoolSorterUnsupportedTransactionTypeError({ type: tx.type });
};

const blobReplacementFeeTupleFromTransaction = (
  tx: Transaction.EIP4844,
): BlobReplacementFeeTuple => ({
  maxFeePerGas: tx.maxFeePerGas,
  maxPriorityFeePerGas: tx.maxPriorityFeePerGas,
  maxFeePerBlobGas: tx.maxFeePerBlobGas,
  blobCount: tx.blobVersionedHashes.length,
});

/**
 * Compare two fee tuples by priority (descending).
 *
 * Returns:
 * - `-1` when `x` has higher priority (should sort before `y`)
 * - `0` when equal
 * - `1` when `y` has higher priority
 *
 * When EIP-1559 is enabled, this compares the effective gas price
 * `min(max_fee, base_fee + max_priority)` with a max fee tie-breaker.
 * Legacy txs with zeroed EIP-1559 fields are treated as
 * `max_fee = max_priority = gas_price`. Otherwise it compares
 * legacy `gas_price` (descending).
 */
export const compareFeeMarketPriority = (
  xGasPrice: GasPrice.GasPriceType,
  xMaxFeePerGas: MaxFeePerGas.MaxFeePerGasType,
  xMaxPriorityFeePerGas: MaxPriorityFeePerGas.MaxPriorityFeePerGasType,
  yGasPrice: GasPrice.GasPriceType,
  yMaxFeePerGas: MaxFeePerGas.MaxFeePerGasType,
  yMaxPriorityFeePerGas: MaxPriorityFeePerGas.MaxPriorityFeePerGasType,
  baseFeePerGas: BaseFeePerGas.BaseFeePerGasType,
  isEip1559Enabled: boolean,
): CompareResult => {
  if (isEip1559Enabled) {
    const xIsLegacy = isLegacyFeeFields(xMaxFeePerGas, xMaxPriorityFeePerGas);
    const yIsLegacy = isLegacyFeeFields(yMaxFeePerGas, yMaxPriorityFeePerGas);

    const xResolvedMaxFee = resolveMaxFee(xGasPrice, xMaxFeePerGas, xIsLegacy);
    const yResolvedMaxFee = resolveMaxFee(yGasPrice, yMaxFeePerGas, yIsLegacy);

    const xResolvedPriority = resolveMaxPriority(
      xGasPrice,
      xMaxPriorityFeePerGas,
      xIsLegacy,
    );
    const yResolvedPriority = resolveMaxPriority(
      yGasPrice,
      yMaxPriorityFeePerGas,
      yIsLegacy,
    );

    const xEffective = EffectiveGasPrice.calculate(
      baseFeePerGas,
      xResolvedPriority,
      xResolvedMaxFee,
    );
    const yEffective = EffectiveGasPrice.calculate(
      baseFeePerGas,
      yResolvedPriority,
      yResolvedMaxFee,
    );

    const effectiveComparison = compareDescending(xEffective, yEffective);
    if (effectiveComparison !== 0) {
      return effectiveComparison;
    }

    const maxFeeComparison = compareDescending(
      xResolvedMaxFee,
      yResolvedMaxFee,
    );
    return maxFeeComparison;
  }

  return compareDescending(xGasPrice, yGasPrice);
};

/** Compare two transactions by fee-market priority. */
export const compareTransactionFeeMarketPriority = (
  x: Transaction.Any,
  y: Transaction.Any,
  baseFeePerGas: BaseFeePerGas.BaseFeePerGasType,
  isEip1559Enabled: boolean,
): CompareResult => {
  const xTuple = feeTupleFromTransaction(x);
  const yTuple = feeTupleFromTransaction(y);

  return compareFeeMarketPriority(
    xTuple.gasPrice,
    xTuple.maxFeePerGas,
    xTuple.maxPriorityFeePerGas,
    yTuple.gasPrice,
    yTuple.maxFeePerGas,
    yTuple.maxPriorityFeePerGas,
    baseFeePerGas,
    isEip1559Enabled,
  );
};

/**
 * Compare a newcomer transaction against an existing transaction for replacement.
 *
 * Returns:
 * - `-1` when the new transaction should replace the old transaction
 * - `0` when undecided
 * - `1` when the existing transaction should be kept
 *
 * This mirrors Nethermind's `CompareReplacedTxByFee` fee bump policy:
 * - Legacy replacement requires a 10% `gasPrice` bump.
 * - 1559-style replacement requires a 10% bump on both `maxFeePerGas`
 *   and `maxPriorityFeePerGas`.
 */
export const compareReplacedTransactionByFee = (
  newTx: Transaction.Any,
  oldTx: Transaction.Any,
): CompareResult => {
  if (newTx === oldTx) {
    return 0;
  }

  const newcomer = replacementFeeTupleFromTransaction(newTx);
  const existing = replacementFeeTupleFromTransaction(oldTx);

  if (existing.maxFeePerGas === 0n) {
    return -1;
  }

  if (!newcomer.supports1559 && !existing.supports1559) {
    const bumpGasPrice = existing.gasPrice / 10n;
    const comparison = compareThresholdAgainstCandidate(
      existing.gasPrice + bumpGasPrice,
      newcomer.gasPrice,
    );
    if (comparison !== 0) {
      return comparison;
    }

    return bumpGasPrice > 0n ? -1 : 1;
  }

  const bumpMaxFeePerGas = existing.maxFeePerGas / 10n;
  if (existing.maxFeePerGas + bumpMaxFeePerGas > newcomer.maxFeePerGas) {
    return 1;
  }

  const bumpMaxPriorityFeePerGas = existing.maxPriorityFeePerGas / 10n;
  const priorityComparison = compareThresholdAgainstCandidate(
    existing.maxPriorityFeePerGas + bumpMaxPriorityFeePerGas,
    newcomer.maxPriorityFeePerGas,
  );
  if (priorityComparison !== 0) {
    return priorityComparison;
  }

  return bumpMaxFeePerGas > 0n && bumpMaxPriorityFeePerGas > 0n ? -1 : 1;
};

/**
 * Compare a newcomer blob transaction against an existing blob transaction.
 *
 * This mirrors Nethermind's `CompareReplacedBlobTx` rules:
 * - New blob tx cannot have fewer blobs than the existing tx.
 * - New blob tx must provide at least 2x bumps for `maxFeePerGas`,
 *   `maxPriorityFeePerGas`, and `maxFeePerBlobGas`.
 */
export const compareReplacedBlobTransactionByFee = (
  newTx: Transaction.EIP4844,
  oldTx: Transaction.EIP4844,
): CompareResult => {
  if (newTx === oldTx) {
    return 0;
  }

  const newcomer = blobReplacementFeeTupleFromTransaction(newTx);
  const existing = blobReplacementFeeTupleFromTransaction(oldTx);

  if (existing.blobCount > newcomer.blobCount) {
    return 1;
  }

  if (existing.maxFeePerGas * 2n > newcomer.maxFeePerGas) {
    return 1;
  }
  if (existing.maxPriorityFeePerGas * 2n > newcomer.maxPriorityFeePerGas) {
    return 1;
  }
  if (existing.maxFeePerBlobGas * 2n > newcomer.maxFeePerBlobGas) {
    return 1;
  }

  return -1;
};
