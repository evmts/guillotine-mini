import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Schema from "effect/Schema";
import {
  Address,
  BaseFeePerGas,
  GasPrice,
  Hex,
  MaxFeePerGas,
  MaxPriorityFeePerGas,
  Transaction,
} from "voltaire-effect/primitives";
import {
  compareFeeMarketPriority,
  compareTransactionFeeMarketPriority,
  TxPoolSorterUnsupportedTransactionTypeError,
} from "./TxPoolSorter";

const decodeBaseFee = (value: number) =>
  Schema.decodeSync(BaseFeePerGas.Gwei)(value);
const decodeGasPrice = (value: number) =>
  Schema.decodeSync(GasPrice.Gwei)(value);
const decodeMaxFee = (value: number) =>
  Schema.decodeSync(MaxFeePerGas.Gwei)(value);
const decodeMaxPriority = (value: number) =>
  Schema.decodeSync(MaxPriorityFeePerGas.Gwei)(value);
const decodeBaseFeeWei = (value: bigint) =>
  Schema.decodeSync(BaseFeePerGas.BigInt)(value);

const LegacySchema = Transaction.LegacySchema as unknown as Schema.Schema<
  Transaction.Legacy,
  unknown
>;
const Eip2930Schema = Transaction.EIP2930Schema as unknown as Schema.Schema<
  Transaction.EIP2930,
  unknown
>;
const Eip1559Schema = Transaction.EIP1559Schema as unknown as Schema.Schema<
  Transaction.EIP1559,
  unknown
>;
const encodeAddress = (address: Address.AddressType): string =>
  Hex.fromBytes(address);
const defaultTo = encodeAddress(Address.zero());

const makeLegacyTx = (gasPrice: bigint): Transaction.Legacy =>
  Schema.validateSync(LegacySchema)({
    type: Transaction.Type.Legacy,
    nonce: 0n,
    gasPrice,
    gasLimit: 21_000n,
    to: defaultTo,
    value: 0n,
    data: new Uint8Array(0),
    v: 27n,
    r: new Uint8Array(32),
    s: new Uint8Array(32),
  });

const makeEip2930Tx = (gasPrice: bigint): Transaction.EIP2930 =>
  Schema.validateSync(Eip2930Schema)({
    type: Transaction.Type.EIP2930,
    chainId: 1n,
    nonce: 0n,
    gasPrice,
    gasLimit: 21_000n,
    to: defaultTo,
    value: 0n,
    data: new Uint8Array(0),
    accessList: [],
    yParity: 0,
    r: new Uint8Array(32),
    s: new Uint8Array(32),
  });

const makeEip1559Tx = (
  maxFeePerGas: bigint,
  maxPriorityFeePerGas: bigint,
): Transaction.EIP1559 =>
  Schema.validateSync(Eip1559Schema)({
    type: Transaction.Type.EIP1559,
    chainId: 1n,
    nonce: 0n,
    maxPriorityFeePerGas,
    maxFeePerGas,
    gasLimit: 21_000n,
    to: defaultTo,
    value: 0n,
    data: new Uint8Array(0),
    accessList: [],
    yParity: 0,
    r: new Uint8Array(32),
    s: new Uint8Array(32),
  });

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

describe("TxPoolSorter.compareTransactionFeeMarketPriority", () => {
  it.effect("compares legacy gas price against EIP-1559 effective fee", () =>
    Effect.sync(() => {
      const baseFee = decodeBaseFeeWei(10n);
      const legacyTx = makeLegacyTx(50n);
      const eip1559Tx = makeEip1559Tx(20n, 5n);

      const result = compareTransactionFeeMarketPriority(
        legacyTx,
        eip1559Tx,
        baseFee,
        true,
      );

      assert.strictEqual(result, -1);
    }),
  );

  it.effect("uses max fee as tie-breaker for EIP-1559 transactions", () =>
    Effect.sync(() => {
      const baseFee = decodeBaseFeeWei(10n);
      const lowerMaxFee = makeEip1559Tx(20n, 5n);
      const higherMaxFee = makeEip1559Tx(25n, 5n);

      const result = compareTransactionFeeMarketPriority(
        lowerMaxFee,
        higherMaxFee,
        baseFee,
        true,
      );

      assert.strictEqual(result, 1);
    }),
  );

  it.effect(
    "falls back to legacy gas price ordering when EIP-1559 disabled",
    () =>
      Effect.sync(() => {
        const baseFee = decodeBaseFeeWei(0n);
        const eip2930Tx = makeEip2930Tx(5n);
        const legacyTx = makeLegacyTx(10n);

        const result = compareTransactionFeeMarketPriority(
          eip2930Tx,
          legacyTx,
          baseFee,
          false,
        );

        assert.strictEqual(result, 1);
      }),
  );

  it.effect("throws on unsupported transaction types", () =>
    Effect.sync(() => {
      const baseFee = decodeBaseFeeWei(0n);
      const unknownTx = { type: 99 } as unknown as Transaction.Any;

      assert.throws(
        () =>
          compareTransactionFeeMarketPriority(
            unknownTx,
            unknownTx,
            baseFee,
            true,
          ),
        TxPoolSorterUnsupportedTransactionTypeError,
      );
    }),
  );
});
