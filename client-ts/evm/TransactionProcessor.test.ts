import { assert, describe, it } from "@effect/vitest";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";
import { Address, Blob, Hex, Transaction } from "voltaire-effect/primitives";
import {
  BlockBlobGasLimitExceededError,
  BlockGasLimitExceededError,
  buyGasAndIncrementNonce,
  calculateEffectiveGasPrice,
  checkInclusionAvailabilityAndSenderCode,
  checkMaxGasFeeAndBalance,
  EmptyAuthorizationListError,
  GasPriceBelowBaseFeeError,
  InsufficientMaxFeePerBlobGasError,
  InsufficientMaxFeePerGasError,
  InsufficientSenderBalanceError,
  InvalidBlobVersionedHashError,
  InvalidSenderAccountCodeError,
  NoBlobDataError,
  processTransaction,
  PriorityFeeGreaterThanMaxFeeError,
  runInCallFrameBoundary,
  runInTransactionBoundary,
  TransactionNonceTooHighError,
  TransactionNonceTooLowError,
  TransactionTypeContractCreationError,
  TransactionProcessorTest,
} from "./TransactionProcessor";
import { EMPTY_ACCOUNT, type AccountStateType } from "../state/Account";
import {
  getAccountOptional,
  getStorage,
  setAccount,
  setCode,
  setStorage,
  WorldStateTest,
} from "../state/State";
import {
  getTransientStorage,
  setTransientStorage,
  TransientStorageTest,
} from "../state/TransientStorage";
import {
  NoActiveTransactionError,
  transactionDepth,
  TransactionBoundaryTest,
} from "../state/TransactionBoundary";

const provideProcessor = <A, E, R>(effect: Effect.Effect<A, E, R>) =>
  effect.pipe(Effect.provide(TransactionProcessorTest));

const TransactionProcessorExecutionTest = Layer.mergeAll(
  TransactionProcessorTest,
  TransactionBoundaryTest,
  WorldStateTest,
  TransientStorageTest,
);

const provideExecutionProcessor = <A, E, R>(effect: Effect.Effect<A, E, R>) =>
  effect.pipe(Effect.provide(TransactionProcessorExecutionTest));

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
const Eip7702Schema = Transaction.EIP7702Schema as unknown as Schema.Schema<
  Transaction.EIP7702,
  unknown
>;

const EMPTY_SIGNATURE = {
  r: new Uint8Array(32),
  s: new Uint8Array(32),
};

const encodeAddress = (address: Address.AddressType): string =>
  Hex.fromBytes(address);

const makeAddress = (lastByte: number): Address.AddressType => {
  const address = Address.zero();
  address[address.length - 1] = lastByte;
  return address;
};

const makeSlot = (lastByte: number) => {
  const slot = new Uint8Array(32);
  slot[slot.length - 1] = lastByte;
  return slot as Parameters<typeof setStorage>[1];
};

const makeStorageValue = (byte: number) => {
  const value = new Uint8Array(32);
  value.fill(byte);
  return value as Parameters<typeof setStorage>[2];
};

const makeDelegationCode = (delegatedTo: Address.AddressType) => {
  const code = new Uint8Array(23);
  code[0] = 0xef;
  code[1] = 0x01;
  code[2] = 0x00;
  code.set(delegatedTo, 3);
  return code as Parameters<typeof setCode>[1];
};

const makeNonDelegationCode = () =>
  new Uint8Array([0x60, 0x00, 0x56]) as Parameters<typeof setCode>[1];

const makeAccount = (
  overrides: Partial<Omit<AccountStateType, "__tag">> = {},
): AccountStateType => ({
  ...EMPTY_ACCOUNT,
  ...overrides,
});

const storageValueHex = (value: Uint8Array) => Hex.fromBytes(value);
const ZERO_STORAGE_VALUE = makeStorageValue(0);

class ExecutionFailedError extends Data.TaggedError("ExecutionFailedError")<{
  readonly scope: "transaction" | "call-frame";
}> {}

const makeLegacyTx = (gasPrice: bigint): Transaction.Legacy =>
  Schema.validateSync(LegacySchema)({
    type: Transaction.Type.Legacy,
    nonce: 0n,
    gasPrice,
    gasLimit: 100_000n,
    to: encodeAddress(Address.zero()),
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
    to: encodeAddress(Address.zero()),
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
  to: Address.AddressType | null = Address.zero(),
): Transaction.EIP4844 =>
  Schema.validateSync(Eip4844Schema)({
    type: Transaction.Type.EIP4844,
    chainId: 1n,
    nonce: 0n,
    maxPriorityFeePerGas,
    maxFeePerGas,
    gasLimit: 100_000n,
    to: to === null ? null : encodeAddress(to),
    value: 0n,
    data: new Uint8Array(0),
    accessList: [],
    maxFeePerBlobGas,
    blobVersionedHashes,
    yParity: 0,
    r: EMPTY_SIGNATURE.r,
    s: EMPTY_SIGNATURE.s,
  });

const makeEip7702Tx = (
  maxFeePerGas: bigint,
  maxPriorityFeePerGas: bigint,
  authorizationList: Transaction.EIP7702["authorizationList"],
  to: Address.AddressType | null = Address.zero(),
): Transaction.EIP7702 =>
  Schema.validateSync(Eip7702Schema)({
    type: Transaction.Type.EIP7702,
    chainId: 1n,
    nonce: 0n,
    maxPriorityFeePerGas,
    maxFeePerGas,
    gasLimit: 100_000n,
    to: to === null ? null : encodeAddress(to),
    value: 0n,
    data: new Uint8Array(0),
    accessList: [],
    authorizationList: authorizationList.map((authorization) => ({
      ...authorization,
      address: encodeAddress(authorization.address),
    })),
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

  it.effect("fails when set-code transaction creates a contract", () =>
    provideProcessor(
      Effect.gen(function* () {
        const tx = makeEip7702Tx(
          10n,
          1n,
          [
            {
              chainId: 1n,
              address: Address.zero(),
              nonce: 0n,
              yParity: 0,
              r: EMPTY_SIGNATURE.r,
              s: EMPTY_SIGNATURE.s,
            },
          ],
          null,
        );
        const outcome = yield* Effect.either(
          checkMaxGasFeeAndBalance(tx, 1n, 0n, 10_000_000n),
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

  it.effect("fails when set-code authorization list is empty", () =>
    provideProcessor(
      Effect.gen(function* () {
        const tx = makeEip7702Tx(10n, 1n, []);
        const outcome = yield* Effect.either(
          checkMaxGasFeeAndBalance(tx, 1n, 0n, 10_000_000n),
        );
        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof EmptyAuthorizationListError);
        }
      }),
    ),
  );
});

describe("TransactionProcessor.buyGasAndIncrementNonce", () => {
  it.effect("precharges effective gas fee and increments sender nonce", () =>
    provideExecutionProcessor(
      Effect.gen(function* () {
        const sender = makeAddress(0xb1);
        const tx = makeEip1559Tx(10n, 1n);
        yield* setAccount(
          sender,
          makeAccount({
            nonce: tx.nonce,
            balance: 2_000_000n,
          }),
        );

        const result = yield* buyGasAndIncrementNonce(tx, sender, 5n, 0n);
        assert.strictEqual(result.maxGasFee, tx.gasLimit * tx.maxFeePerGas);
        assert.strictEqual(result.effectiveGasPrice, 6n);
        assert.strictEqual(result.senderBalanceAfterGasBuy, 1_400_000n);
        assert.strictEqual(result.senderNonceAfterIncrement, tx.nonce + 1n);

        const account = yield* getAccountOptional(sender);
        assert.strictEqual(account?.balance, 1_400_000n);
        assert.strictEqual(account?.nonce, tx.nonce + 1n);
      }),
    ),
  );

  it.effect("precharges current blob fee instead of max blob reservation", () =>
    provideExecutionProcessor(
      Effect.gen(function* () {
        const sender = makeAddress(0xb6);
        const blobHash = makeBlobHash(0x01);
        const tx = makeEip4844Tx(10n, 1n, 5n, [blobHash]);
        const gasPerBlob = toBigInt(Blob.GAS_PER_BLOB);
        yield* setAccount(
          sender,
          makeAccount({
            nonce: tx.nonce,
            balance: 2_000_000n,
          }),
        );

        const result = yield* buyGasAndIncrementNonce(tx, sender, 5n, 2n);
        const expectedBlobGasUsed = gasPerBlob;
        const expectedGasPrecharge =
          tx.gasLimit * 6n + expectedBlobGasUsed * 2n;
        const expectedBalance = 2_000_000n - expectedGasPrecharge;

        assert.strictEqual(
          result.maxGasFee,
          tx.gasLimit * tx.maxFeePerGas + 5n * gasPerBlob,
        );
        assert.strictEqual(result.blobGasUsed, expectedBlobGasUsed);
        assert.strictEqual(result.senderBalanceAfterGasBuy, expectedBalance);
        const account = yield* getAccountOptional(sender);
        assert.strictEqual(account?.balance, expectedBalance);
      }),
    ),
  );

  it.effect("fails when transaction nonce is lower than sender nonce", () =>
    provideExecutionProcessor(
      Effect.gen(function* () {
        const sender = makeAddress(0xb2);
        const tx = makeEip1559Tx(10n, 1n);
        yield* setAccount(
          sender,
          makeAccount({
            nonce: tx.nonce + 1n,
            balance: 2_000_000n,
          }),
        );

        const outcome = yield* Effect.either(
          buyGasAndIncrementNonce(tx, sender, 5n, 0n),
        );
        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof TransactionNonceTooLowError);
        }
      }),
    ),
  );

  it.effect("fails when transaction nonce is higher than sender nonce", () =>
    provideExecutionProcessor(
      Effect.gen(function* () {
        const sender = makeAddress(0xb3);
        const tx: Transaction.EIP1559 = {
          ...makeEip1559Tx(10n, 1n),
          nonce: 1n,
        };
        yield* setAccount(
          sender,
          makeAccount({
            nonce: 0n,
            balance: 2_000_000n,
          }),
        );

        const outcome = yield* Effect.either(
          buyGasAndIncrementNonce(tx, sender, 5n, 0n),
        );
        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof TransactionNonceTooHighError);
        }
      }),
    ),
  );
});

describe("TransactionProcessor.processTransaction", () => {
  const maxBlobGasPerBlock = 1_179_648n;

  it.effect("orchestrates inclusion checks then gas purchase in one call", () =>
    provideExecutionProcessor(
      Effect.gen(function* () {
        const sender = makeAddress(0xb7);
        const tx = makeEip1559Tx(10n, 1n);
        yield* setAccount(
          sender,
          makeAccount({
            nonce: tx.nonce,
            balance: 2_000_000n,
          }),
        );

        const result = yield* processTransaction(
          tx,
          sender,
          5n,
          0n,
          130_000n,
          10_000n,
          maxBlobGasPerBlock,
          0n,
        );

        assert.strictEqual(result.effectiveGasPrice, 6n);
        assert.strictEqual(result.senderNonceAfterIncrement, tx.nonce + 1n);
        assert.strictEqual(result.txBlobGasUsed, 0n);
        assert.strictEqual(result.senderHasDelegationCode, false);
      }),
    ),
  );

  it.effect("enforces inclusion validation before nonce mutation", () =>
    provideExecutionProcessor(
      Effect.gen(function* () {
        const sender = makeAddress(0xb8);
        const tx = makeLegacyTx(10n);
        yield* setAccount(
          sender,
          makeAccount({
            nonce: tx.nonce + 1n,
            balance: 2_000_000n,
          }),
        );

        const outcome = yield* Effect.either(
          processTransaction(
            tx,
            sender,
            5n,
            0n,
            90_000n,
            0n,
            maxBlobGasPerBlock,
            0n,
          ),
        );
        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof BlockGasLimitExceededError);
        }

        const account = yield* getAccountOptional(sender);
        assert.strictEqual(account?.nonce, tx.nonce + 1n);
      }),
    ),
  );
});

describe("TransactionProcessor.checkInclusionAvailabilityAndSenderCode", () => {
  const maxBlobGasPerBlock = 1_179_648n;

  it.effect("returns inclusion check result for EOA sender", () =>
    provideExecutionProcessor(
      Effect.gen(function* () {
        const sender = makeAddress(0xc1);
        const tx = makeLegacyTx(10n);

        const result = yield* checkInclusionAvailabilityAndSenderCode(
          tx,
          sender,
          130_000n,
          25_000n,
          maxBlobGasPerBlock,
          0n,
        );

        assert.strictEqual(result.txBlobGasUsed, 0n);
        assert.strictEqual(result.senderHasDelegationCode, false);
      }),
    ),
  );

  it.effect("accepts delegated sender code and computes blob gas used", () =>
    provideExecutionProcessor(
      Effect.gen(function* () {
        const sender = makeAddress(0xc2);
        yield* setCode(sender, makeDelegationCode(makeAddress(0xd1)));
        const blobHash = makeBlobHash(0x01);
        const tx = makeEip4844Tx(10n, 1n, 2n, [blobHash, blobHash]);

        const result = yield* checkInclusionAvailabilityAndSenderCode(
          tx,
          sender,
          130_000n,
          10_000n,
          maxBlobGasPerBlock,
          800_000n,
        );

        assert.strictEqual(
          result.txBlobGasUsed,
          toBigInt(Blob.GAS_PER_BLOB) * 2n,
        );
        assert.strictEqual(result.senderHasDelegationCode, true);
      }),
    ),
  );

  it.effect("fails when tx gas limit exceeds available block gas", () =>
    provideExecutionProcessor(
      Effect.gen(function* () {
        const sender = makeAddress(0xc3);
        const tx = makeLegacyTx(10n);

        const outcome = yield* Effect.either(
          checkInclusionAvailabilityAndSenderCode(
            tx,
            sender,
            90_000n,
            0n,
            maxBlobGasPerBlock,
            0n,
          ),
        );

        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof BlockGasLimitExceededError);
        }
      }),
    ),
  );

  it.effect("fails when tx blob gas exceeds available block blob gas", () =>
    provideExecutionProcessor(
      Effect.gen(function* () {
        const sender = makeAddress(0xc4);
        const blobHash = makeBlobHash(0x01);
        const tx = makeEip4844Tx(10n, 1n, 2n, [blobHash, blobHash]);

        const outcome = yield* Effect.either(
          checkInclusionAvailabilityAndSenderCode(
            tx,
            sender,
            130_000n,
            0n,
            300_000n,
            100_000n,
          ),
        );

        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof BlockBlobGasLimitExceededError);
        }
      }),
    ),
  );

  it.effect("fails when sender has non-delegation code", () =>
    provideExecutionProcessor(
      Effect.gen(function* () {
        const sender = makeAddress(0xc5);
        yield* setCode(sender, makeNonDelegationCode());
        const tx = makeLegacyTx(10n);

        const outcome = yield* Effect.either(
          checkInclusionAvailabilityAndSenderCode(
            tx,
            sender,
            130_000n,
            0n,
            maxBlobGasPerBlock,
            0n,
          ),
        );

        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof InvalidSenderAccountCodeError);
        }
      }),
    ),
  );
});

describe("TransactionProcessor execution boundaries", () => {
  it.effect("runInCallFrameBoundary requires an active transaction scope", () =>
    provideExecutionProcessor(
      Effect.gen(function* () {
        const outcome = yield* Effect.either(
          runInCallFrameBoundary(Effect.succeed("ok")),
        );

        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof NoActiveTransactionError);
        }
      }),
    ),
  );

  it.effect(
    "runInTransactionBoundary commits world and transient changes",
    () =>
      provideExecutionProcessor(
        Effect.gen(function* () {
          const address = makeAddress(0xa1);
          const slot = makeSlot(0xa1);
          const value = makeStorageValue(0x11);

          yield* setAccount(address, makeAccount({ nonce: 1n }));
          assert.strictEqual(yield* transactionDepth(), 0);

          const result = yield* runInTransactionBoundary(
            Effect.gen(function* () {
              assert.strictEqual(yield* transactionDepth(), 1);
              yield* setAccount(address, makeAccount({ nonce: 2n }));
              yield* setStorage(address, slot, value);
              yield* setTransientStorage(address, slot, value);
              return "ok";
            }),
          );

          assert.strictEqual(result, "ok");
          assert.strictEqual(yield* transactionDepth(), 0);

          const account = yield* getAccountOptional(address);
          assert.strictEqual(account?.nonce, 2n);
          assert.strictEqual(
            storageValueHex(yield* getStorage(address, slot)),
            storageValueHex(value),
          );
          assert.strictEqual(
            storageValueHex(yield* getTransientStorage(address, slot)),
            storageValueHex(value),
          );
        }),
      ),
  );

  it.effect("runInTransactionBoundary rolls back on failure", () =>
    provideExecutionProcessor(
      Effect.gen(function* () {
        const address = makeAddress(0xa2);
        const slot = makeSlot(0xa2);
        const value = makeStorageValue(0x22);

        yield* setAccount(address, makeAccount({ nonce: 3n }));
        const outcome = yield* Effect.either(
          runInTransactionBoundary(
            Effect.gen(function* () {
              yield* setAccount(address, makeAccount({ nonce: 4n }));
              yield* setStorage(address, slot, value);
              yield* setTransientStorage(address, slot, value);
              return yield* Effect.fail(
                new ExecutionFailedError({ scope: "transaction" }),
              );
            }),
          ),
        );

        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof ExecutionFailedError);
        }
        assert.strictEqual(yield* transactionDepth(), 0);

        const account = yield* getAccountOptional(address);
        assert.strictEqual(account?.nonce, 3n);
        assert.strictEqual(
          storageValueHex(yield* getStorage(address, slot)),
          storageValueHex(ZERO_STORAGE_VALUE),
        );
        assert.strictEqual(
          storageValueHex(yield* getTransientStorage(address, slot)),
          storageValueHex(ZERO_STORAGE_VALUE),
        );
      }),
    ),
  );

  it.effect("runInCallFrameBoundary commits nested call-frame changes", () =>
    provideExecutionProcessor(
      Effect.gen(function* () {
        const address = makeAddress(0xa3);
        const slot = makeSlot(0xa3);
        const value = makeStorageValue(0x33);

        yield* setAccount(address, makeAccount({ nonce: 5n }));
        yield* runInTransactionBoundary(
          Effect.gen(function* () {
            assert.strictEqual(yield* transactionDepth(), 1);
            yield* runInCallFrameBoundary(
              Effect.gen(function* () {
                assert.strictEqual(yield* transactionDepth(), 2);
                yield* setAccount(address, makeAccount({ nonce: 6n }));
                yield* setStorage(address, slot, value);
                yield* setTransientStorage(address, slot, value);
              }),
            );
            assert.strictEqual(yield* transactionDepth(), 1);
          }),
        );

        assert.strictEqual(yield* transactionDepth(), 0);
        const account = yield* getAccountOptional(address);
        assert.strictEqual(account?.nonce, 6n);
        assert.strictEqual(
          storageValueHex(yield* getStorage(address, slot)),
          storageValueHex(value),
        );
        assert.strictEqual(
          storageValueHex(yield* getTransientStorage(address, slot)),
          storageValueHex(value),
        );
      }),
    ),
  );

  it.effect("runInCallFrameBoundary rolls back failed inner call frame", () =>
    provideExecutionProcessor(
      Effect.gen(function* () {
        const address = makeAddress(0xa4);
        const slot = makeSlot(0xa4);
        const outerValue = makeStorageValue(0x44);
        const innerValue = makeStorageValue(0x45);

        yield* setAccount(address, makeAccount({ nonce: 7n }));
        yield* runInTransactionBoundary(
          Effect.gen(function* () {
            assert.strictEqual(yield* transactionDepth(), 1);
            yield* setAccount(address, makeAccount({ nonce: 8n }));
            yield* setStorage(address, slot, outerValue);
            yield* setTransientStorage(address, slot, outerValue);

            const callResult = yield* Effect.either(
              runInCallFrameBoundary(
                Effect.gen(function* () {
                  assert.strictEqual(yield* transactionDepth(), 2);
                  yield* setAccount(address, makeAccount({ nonce: 9n }));
                  yield* setStorage(address, slot, innerValue);
                  yield* setTransientStorage(address, slot, innerValue);
                  return yield* Effect.fail(
                    new ExecutionFailedError({ scope: "call-frame" }),
                  );
                }),
              ),
            );

            assert.isTrue(Either.isLeft(callResult));
            if (Either.isLeft(callResult)) {
              assert.isTrue(callResult.left instanceof ExecutionFailedError);
            }

            assert.strictEqual(yield* transactionDepth(), 1);
            const innerRolledBackAccount = yield* getAccountOptional(address);
            assert.strictEqual(innerRolledBackAccount?.nonce, 8n);
            assert.strictEqual(
              storageValueHex(yield* getStorage(address, slot)),
              storageValueHex(outerValue),
            );
            assert.strictEqual(
              storageValueHex(yield* getTransientStorage(address, slot)),
              storageValueHex(outerValue),
            );
          }),
        );

        assert.strictEqual(yield* transactionDepth(), 0);
        const account = yield* getAccountOptional(address);
        assert.strictEqual(account?.nonce, 8n);
        assert.strictEqual(
          storageValueHex(yield* getStorage(address, slot)),
          storageValueHex(outerValue),
        );
        assert.strictEqual(
          storageValueHex(yield* getTransientStorage(address, slot)),
          storageValueHex(outerValue),
        );
      }),
    ),
  );
});
