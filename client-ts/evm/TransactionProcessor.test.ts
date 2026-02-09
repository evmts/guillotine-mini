import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import * as Schema from "effect/Schema";
import { Address, Transaction } from "voltaire-effect/primitives";
import {
  calculateEffectiveGasPrice,
  GasPriceBelowBaseFeeError,
  InsufficientMaxFeePerGasError,
  PriorityFeeGreaterThanMaxFeeError,
  TransactionProcessorTest,
} from "./TransactionProcessor";

const provideProcessor = <A, E, R>(effect: Effect.Effect<A, E, R>) =>
  effect.pipe(Effect.provide(TransactionProcessorTest));

const LegacySchema = Transaction.LegacySchema as unknown as Schema.Schema<
  Transaction.Legacy,
  unknown
>;
const Eip1559Schema = Transaction.EIP1559Schema as unknown as Schema.Schema<
  Transaction.EIP1559,
  unknown
>;

const EMPTY_SIGNATURE = {
  r: new Uint8Array(32),
  s: new Uint8Array(32),
};

const makeLegacyTx = (gasPrice: bigint): Transaction.Legacy =>
  Schema.decodeSync(LegacySchema)({
    type: Transaction.Type.Legacy,
    nonce: 0n,
    gasPrice,
    gasLimit: 100_000n,
    to: Address.zero(),
    value: 0n,
    data: new Uint8Array(0),
    v: 27n,
    r: EMPTY_SIGNATURE.r,
    s: EMPTY_SIGNATURE.s,
  });

const makeEip1559Tx = (
  maxFeePerGas: bigint,
  maxPriorityFeePerGas: bigint,
): Transaction.EIP1559 =>
  Schema.decodeSync(Eip1559Schema)({
    type: Transaction.Type.EIP1559,
    chainId: 1n,
    nonce: 0n,
    maxPriorityFeePerGas,
    maxFeePerGas,
    gasLimit: 100_000n,
    to: Address.zero(),
    value: 0n,
    data: new Uint8Array(0),
    accessList: [],
    yParity: 0,
    r: EMPTY_SIGNATURE.r,
    s: EMPTY_SIGNATURE.s,
  });

describe("TransactionProcessor.calculateEffectiveGasPrice", () => {
  it.effect("returns effective gas price for legacy tx", () =>
    provideProcessor(
      Effect.gen(function* () {
        const tx = makeLegacyTx(30n);
        const result = yield* calculateEffectiveGasPrice(tx, 10n);
        assert.strictEqual(result.effectiveGasPrice, 30n);
        assert.strictEqual(result.priorityFeePerGas, 20n);
      }),
    ),
  );

  it.effect("fails when legacy gas price is below base fee", () =>
    provideProcessor(
      Effect.gen(function* () {
        const tx = makeLegacyTx(5n);
        const outcome = yield* Effect.either(
          calculateEffectiveGasPrice(tx, 10n),
        );
        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof GasPriceBelowBaseFeeError);
        }
      }),
    ),
  );

  it.effect("fails when max priority fee exceeds max fee", () =>
    provideProcessor(
      Effect.gen(function* () {
        const tx = makeEip1559Tx(10n, 15n);
        const outcome = yield* Effect.either(
          calculateEffectiveGasPrice(tx, 1n),
        );
        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(
            outcome.left instanceof PriorityFeeGreaterThanMaxFeeError,
          );
        }
      }),
    ),
  );

  it.effect("fails when max fee is below base fee", () =>
    provideProcessor(
      Effect.gen(function* () {
        const tx = makeEip1559Tx(5n, 1n);
        const outcome = yield* Effect.either(
          calculateEffectiveGasPrice(tx, 10n),
        );
        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof InsufficientMaxFeePerGasError);
        }
      }),
    ),
  );

  it.effect("returns effective gas price for EIP-1559", () =>
    provideProcessor(
      Effect.gen(function* () {
        const tx = makeEip1559Tx(50n, 5n);
        const result = yield* calculateEffectiveGasPrice(tx, 30n);
        assert.strictEqual(result.priorityFeePerGas, 5n);
        assert.strictEqual(result.effectiveGasPrice, 35n);
      }),
    ),
  );
});
