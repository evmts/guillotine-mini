import {
  BaseFeePerGas,
  EffectiveGasPrice,
  GasPrice,
  MaxFeePerGas,
  MaxPriorityFeePerGas,
} from "voltaire-effect/primitives";

type CompareResult = -1 | 0 | 1;

const compareDescending = (left: bigint, right: bigint): CompareResult => {
  if (left > right) {
    return -1;
  }
  if (left < right) {
    return 1;
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
    if (maxFeeComparison !== 0) {
      return maxFeeComparison;
    }
  }

  return compareDescending(xGasPrice, yGasPrice);
};
