import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Schema from "effect/Schema";
import {
  BaseFeePerGas,
  GasPrice,
  MaxFeePerGas,
  MaxPriorityFeePerGas,
} from "voltaire-effect/primitives";
import { compareFeeMarketPriority } from "./TxPoolSorter";

const decodeBaseFee = (value: number) =>
  Schema.decodeSync(BaseFeePerGas.Gwei)(value);
const decodeGasPrice = (value: number) =>
  Schema.decodeSync(GasPrice.Gwei)(value);
const decodeMaxFee = (value: number) =>
  Schema.decodeSync(MaxFeePerGas.Gwei)(value);
const decodeMaxPriority = (value: number) =>
  Schema.decodeSync(MaxPriorityFeePerGas.Gwei)(value);

describe("TxPoolSorter.compareFeeMarketPriority", () => {
  it.effect("compares effective gas price under EIP-1559", () =>
    Effect.sync(() => {
      const baseFee = decodeBaseFee(10);
      const xMaxFee = decodeMaxFee(30);
      const xMaxPriority = decodeMaxPriority(2);
      const yMaxFee = decodeMaxFee(20);
      const yMaxPriority = decodeMaxPriority(8);
      const xGasPrice = decodeGasPrice(0);
      const yGasPrice = decodeGasPrice(0);

      const result = compareFeeMarketPriority(
        xGasPrice,
        xMaxFee,
        xMaxPriority,
        yGasPrice,
        yMaxFee,
        yMaxPriority,
        baseFee,
        true,
      );

      assert.strictEqual(result, 1);
    }),
  );

  it.effect("treats zeroed EIP-1559 fields as legacy gas price", () =>
    Effect.sync(() => {
      const baseFee = decodeBaseFee(10);
      const xGasPrice = decodeGasPrice(50);
      const yGasPrice = decodeGasPrice(0);
      const xMaxFee = decodeMaxFee(0);
      const xMaxPriority = decodeMaxPriority(0);
      const yMaxFee = decodeMaxFee(40);
      const yMaxPriority = decodeMaxPriority(2);

      const result = compareFeeMarketPriority(
        xGasPrice,
        xMaxFee,
        xMaxPriority,
        yGasPrice,
        yMaxFee,
        yMaxPriority,
        baseFee,
        true,
      );

      assert.strictEqual(result, -1);
    }),
  );

  it.effect("uses max fee as tie-breaker on equal effective price", () =>
    Effect.sync(() => {
      const baseFee = decodeBaseFee(10);
      const xMaxFee = decodeMaxFee(20);
      const xMaxPriority = decodeMaxPriority(5);
      const yMaxFee = decodeMaxFee(25);
      const yMaxPriority = decodeMaxPriority(5);
      const xGasPrice = decodeGasPrice(0);
      const yGasPrice = decodeGasPrice(0);

      const result = compareFeeMarketPriority(
        xGasPrice,
        xMaxFee,
        xMaxPriority,
        yGasPrice,
        yMaxFee,
        yMaxPriority,
        baseFee,
        true,
      );

      assert.strictEqual(result, 1);
    }),
  );

  it.effect("caps priority by max fee minus base fee", () =>
    Effect.sync(() => {
      const baseFee = decodeBaseFee(25);
      const xMaxFee = decodeMaxFee(27);
      const xMaxPriority = decodeMaxPriority(5);
      const yMaxFee = decodeMaxFee(28);
      const yMaxPriority = decodeMaxPriority(1);
      const xGasPrice = decodeGasPrice(0);
      const yGasPrice = decodeGasPrice(0);

      const result = compareFeeMarketPriority(
        xGasPrice,
        xMaxFee,
        xMaxPriority,
        yGasPrice,
        yMaxFee,
        yMaxPriority,
        baseFee,
        true,
      );

      assert.strictEqual(result, -1);
    }),
  );

  it.effect("handles max fee below base fee", () =>
    Effect.sync(() => {
      const baseFee = decodeBaseFee(30);
      const xMaxFee = decodeMaxFee(25);
      const xMaxPriority = decodeMaxPriority(2);
      const yMaxFee = decodeMaxFee(28);
      const yMaxPriority = decodeMaxPriority(1);
      const xGasPrice = decodeGasPrice(0);
      const yGasPrice = decodeGasPrice(0);

      const result = compareFeeMarketPriority(
        xGasPrice,
        xMaxFee,
        xMaxPriority,
        yGasPrice,
        yMaxFee,
        yMaxPriority,
        baseFee,
        true,
      );

      assert.strictEqual(result, 1);
    }),
  );

  it.effect("falls back to legacy gas price ordering", () =>
    Effect.sync(() => {
      const baseFee = decodeBaseFee(0);
      const xGasPrice = decodeGasPrice(30);
      const yGasPrice = decodeGasPrice(20);
      const xMaxFee = decodeMaxFee(0);
      const xMaxPriority = decodeMaxPriority(0);
      const yMaxFee = decodeMaxFee(0);
      const yMaxPriority = decodeMaxPriority(0);

      const result = compareFeeMarketPriority(
        xGasPrice,
        xMaxFee,
        xMaxPriority,
        yGasPrice,
        yMaxFee,
        yMaxPriority,
        baseFee,
        false,
      );

      assert.strictEqual(result, -1);
    }),
  );

  it.effect("returns zero for equal fee tuples", () =>
    Effect.sync(() => {
      const baseFee = decodeBaseFee(10);
      const gasPrice = decodeGasPrice(20);
      const maxFee = decodeMaxFee(20);
      const maxPriority = decodeMaxPriority(5);

      const result = compareFeeMarketPriority(
        gasPrice,
        maxFee,
        maxPriority,
        gasPrice,
        maxFee,
        maxPriority,
        baseFee,
        true,
      );

      assert.strictEqual(result, 0);
    }),
  );
});
