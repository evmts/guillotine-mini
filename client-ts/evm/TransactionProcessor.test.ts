import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import * as Schema from "effect/Schema";
import { Address, Blob, Transaction } from "voltaire-effect/primitives";
import {
  calculateEffectiveGasPrice,
  checkMaxGasFeeAndBalance,
  GasPriceBelowBaseFeeError,
  InsufficientMaxFeePerBlobGasError,
  InsufficientMaxFeePerGasError,
  InsufficientSenderBalanceError,
  InvalidBlobVersionedHashError,
  NoBlobDataError,
  PriorityFeeGreaterThanMaxFeeError,
  TransactionTypeContractCreationError,
  TransactionProcessorTest,
} from "./TransactionProcessor";

const provideProcessor = <A, E, R>(effect: Effect.Effect<A, E, R>) =>
  effect.pipe(Effect.provide(TransactionProcessorTest));

const toBigInt = (value: bigint | number): bigint =>
  typeof value === "bigint" ? value : BigInt(value);

const LegacySchema = Transaction.LegacySchema as unknown as Schema.Schema<
  Transaction.Legacy,
  unknown
>;
const Eip1559Schema = Transaction.EIP1559Schema as unknown as Schema.Schema<
  Transaction.EIP1559,
  unknown
>;
const Eip4844Schema = Transaction.EIP4844Schema as unknown as Schema.Schema<
  Transaction.EIP4844,
  unknown
>;

const EMPTY_SIGNATURE = {
  r: new Uint8Array(32),
  s: new Uint8Array(32),
};

const makeLegacyTx = (gasPrice: bigint): Transaction.Legacy =>
  Schema.validateSync(LegacySchema)({
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
  Schema.validateSync(Eip1559Schema)({
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

const makeBlobHash = (versionByte: number): Uint8Array => {
  const hash = new Uint8Array(32);
  hash[0] = versionByte;
  return hash;
};

const makeEip4844Tx = (
  maxFeePerGas: bigint,
  maxPriorityFeePerGas: bigint,
  maxFeePerBlobGas: bigint,
  blobVersionedHashes: Uint8Array[],
  to: Transaction.EIP4844["to"] | null = Address.zero(),
): Transaction.EIP4844 =>
  Schema.validateSync(Eip4844Schema)({
    type: Transaction.Type.EIP4844,
    chainId: 1n,
    nonce: 0n,
    maxPriorityFeePerGas,
    maxFeePerGas,
    gasLimit: 100_000n,
    to,
    value: 0n,
    data: new Uint8Array(0),
    accessList: [],
    maxFeePerBlobGas,
    blobVersionedHashes,
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

describe("TransactionProcessor.checkMaxGasFeeAndBalance", () => {
  it.effect("returns max gas fee including blob fees for blob tx", () =>
    provideProcessor(
      Effect.gen(function* () {
        const blobHash = makeBlobHash(0x01);
        const tx = makeEip4844Tx(10n, 1n, 2n, [blobHash, blobHash]);
        const senderBalance = 10_000_000_000n;
        const result = yield* checkMaxGasFeeAndBalance(
          tx,
          1n,
          1n,
          senderBalance,
        );
        const gasPerBlob = toBigInt(Blob.GAS_PER_BLOB);
        const expectedBlobGasUsed = gasPerBlob * 2n;
        const expectedBlobGasFee = expectedBlobGasUsed * tx.maxFeePerBlobGas;
        const expectedMaxGasFee =
          tx.gasLimit * tx.maxFeePerGas + expectedBlobGasFee;

        assert.strictEqual(result.blobGasUsed, expectedBlobGasUsed);
        assert.strictEqual(result.blobGasFee, expectedBlobGasFee);
        assert.strictEqual(result.maxGasFee, expectedMaxGasFee);
      }),
    ),
  );

  it.effect("fails when sender balance is insufficient", () =>
    provideProcessor(
      Effect.gen(function* () {
        const tx = makeLegacyTx(10n);
        const outcome = yield* Effect.either(
          checkMaxGasFeeAndBalance(tx, 1n, 0n, 1n),
        );
        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof InsufficientSenderBalanceError);
        }
      }),
    ),
  );

  it.effect("fails when blob transaction has no blob hashes", () =>
    provideProcessor(
      Effect.gen(function* () {
        const tx = makeEip4844Tx(10n, 1n, 2n, []);
        const outcome = yield* Effect.either(
          checkMaxGasFeeAndBalance(tx, 1n, 1n, 10_000_000n),
        );
        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof NoBlobDataError);
        }
      }),
    ),
  );

  it.effect("fails when blob transaction creates a contract", () =>
    provideProcessor(
      Effect.gen(function* () {
        const blobHash = makeBlobHash(0x01);
        const tx = makeEip4844Tx(10n, 1n, 2n, [blobHash], null);
        const outcome = yield* Effect.either(
          checkMaxGasFeeAndBalance(tx, 1n, 1n, 10_000_000n),
        );
        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(
            outcome.left instanceof TransactionTypeContractCreationError,
          );
        }
      }),
    ),
  );

  it.effect("fails when blob versioned hash is invalid", () =>
    provideProcessor(
      Effect.gen(function* () {
        const invalidHash = makeBlobHash(0x02);
        const tx = makeEip4844Tx(10n, 1n, 2n, [invalidHash]);
        const outcome = yield* Effect.either(
          checkMaxGasFeeAndBalance(tx, 1n, 1n, 10_000_000n),
        );
        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof InvalidBlobVersionedHashError);
        }
      }),
    ),
  );

  it.effect("fails when max fee per blob gas is below blob gas price", () =>
    provideProcessor(
      Effect.gen(function* () {
        const blobHash = makeBlobHash(0x01);
        const tx = makeEip4844Tx(10n, 1n, 1n, [blobHash]);
        const outcome = yield* Effect.either(
          checkMaxGasFeeAndBalance(tx, 1n, 2n, 10_000_000n),
        );
        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(
            outcome.left instanceof InsufficientMaxFeePerBlobGasError,
          );
        }
      }),
    ),
  );
});
