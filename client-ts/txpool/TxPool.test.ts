import { secp256k1 } from "@noble/curves/secp256k1.js";
import { assert, describe, it } from "@effect/vitest";
import * as Either from "effect/Either";
import * as Effect from "effect/Effect";
import * as Schema from "effect/Schema";
import { Address, Hash, Hex, Transaction } from "voltaire-effect/primitives";
import {
  BlobsSupportMode,
  TxPoolBlobFeeCapTooLowError,
  InvalidTxPoolConfigError,
  TxPoolBlobSupportDisabledError,
  TxPoolConfigDefaults,
  TxPoolFullError,
  TxPoolLive,
  TxPoolPriorityFeeTooLowError,
  TxPoolReplacementNotAllowedError,
  TxPoolSenderLimitExceededError,
  TxPoolTest,
  acceptTxWhenNotSynced,
  addTransaction,
  getPendingBlobCount,
  getPendingCount,
  getPendingTransactions,
  getPendingTransactionsBySender,
  removeTransaction,
  supportsBlobs,
  validateTransaction,
} from "./TxPool";

const Eip1559Schema = Transaction.EIP1559Schema as unknown as Schema.Schema<
  Transaction.EIP1559,
  unknown
>;
const Eip4844Schema = Transaction.EIP4844Schema as unknown as Schema.Schema<
  Transaction.EIP4844,
  unknown
>;

const PRIVATE_KEY = new Uint8Array(32);
PRIVATE_KEY[31] = 1;

const encodeAddress = (address: Address.AddressType): string =>
  Hex.fromBytes(address);

const makeBlobHash = (versionByte: number): Uint8Array => {
  const hash = new Uint8Array(32);
  hash[0] = versionByte;
  return hash;
};

const signDynamicFeeTx = <T extends Transaction.EIP1559 | Transaction.EIP4844>(
  tx: T,
): T => {
  const signingHash = Transaction.getSigningHash(tx);
  const signature = secp256k1.sign(signingHash, PRIVATE_KEY, {
    prehash: false,
    format: "recovered",
  });
  const recovery = signature[0] ?? 0;
  const r = signature.slice(1, 33);
  const s = signature.slice(33, 65);
  return { ...tx, yParity: recovery & 1, r, s } as T;
};

const makeEip1559Tx = (
  nonce: bigint,
  maxPriorityFeePerGas = 1n,
  maxFeePerGas = 2n,
  gasLimit = 100_000n,
): Transaction.EIP1559 =>
  Schema.validateSync(Eip1559Schema)({
    type: Transaction.Type.EIP1559,
    chainId: 1n,
    nonce,
    maxPriorityFeePerGas,
    maxFeePerGas,
    gasLimit,
    to: encodeAddress(Address.zero()),
    value: 0n,
    data: new Uint8Array(0),
    accessList: [],
    yParity: 0,
    r: new Uint8Array(32),
    s: new Uint8Array(32),
  });

const makeEip4844Tx = (
  nonce: bigint,
  maxPriorityFeePerGas = 1n,
  maxFeePerGas = 2n,
  maxFeePerBlobGas = 3n,
  blobVersionedHashes: Uint8Array[] = [makeBlobHash(1)],
): Transaction.EIP4844 =>
  Schema.validateSync(Eip4844Schema)({
    type: Transaction.Type.EIP4844,
    chainId: 1n,
    nonce,
    maxPriorityFeePerGas,
    maxFeePerGas,
    gasLimit: 120_000n,
    to: encodeAddress(Address.zero()),
    value: 0n,
    data: new Uint8Array(0),
    accessList: [],
    maxFeePerBlobGas,
    blobVersionedHashes,
    yParity: 0,
    r: new Uint8Array(32),
    s: new Uint8Array(32),
  });

const makeSignedEip1559Tx = (
  nonce: bigint,
  maxPriorityFeePerGas = 1n,
  maxFeePerGas = 2n,
  gasLimit = 100_000n,
): Transaction.EIP1559 =>
  signDynamicFeeTx(
    makeEip1559Tx(nonce, maxPriorityFeePerGas, maxFeePerGas, gasLimit),
  );

const makeSignedEip4844Tx = (
  nonce: bigint,
  maxPriorityFeePerGas = 1n,
  maxFeePerGas = 2n,
  maxFeePerBlobGas = 3n,
  blobVersionedHashes: Uint8Array[] = [makeBlobHash(1)],
): Transaction.EIP4844 =>
  signDynamicFeeTx(
    makeEip4844Tx(
      nonce,
      maxPriorityFeePerGas,
      maxFeePerGas,
      maxFeePerBlobGas,
      blobVersionedHashes,
    ),
  );

describe("TxPool", () => {
  it.effect("returns pending transaction count", () =>
    Effect.gen(function* () {
      const count = yield* getPendingCount();
      assert.strictEqual(count, 0);
    }).pipe(Effect.provide(TxPoolLive(TxPoolConfigDefaults))),
  );

  it.effect("returns pending blob transaction count", () =>
    Effect.gen(function* () {
      const count = yield* getPendingBlobCount();
      assert.strictEqual(count, 0);
    }).pipe(Effect.provide(TxPoolLive(TxPoolConfigDefaults))),
  );

  it.effect("uses TxPoolTest defaults", () =>
    Effect.gen(function* () {
      const count = yield* getPendingCount();
      assert.strictEqual(count, 0);
    }).pipe(Effect.provide(TxPoolTest())),
  );

  it.effect("adds pending transactions and indexes by sender", () =>
    Effect.gen(function* () {
      const tx = makeSignedEip1559Tx(0n);
      const result = yield* addTransaction(tx);
      assert.strictEqual(result._tag, "Added");

      const count = yield* getPendingCount();
      assert.strictEqual(count, 1);

      const pending = yield* getPendingTransactions();
      assert.strictEqual(pending.length, 1);

      const sender = Transaction.getSender(tx);
      const bySender = yield* getPendingTransactionsBySender(sender);
      assert.strictEqual(bySender.length, 1);
    }).pipe(Effect.provide(TxPoolLive(TxPoolConfigDefaults))),
  );

  it.effect(
    "rejects same-sender same-nonce replacements without required fee bump",
    () =>
      Effect.gen(function* () {
        const existing = makeSignedEip1559Tx(0n, 1n, 2n);
        const incoming = makeSignedEip1559Tx(0n, 1n, 2n, 100_001n);

        const added = yield* addTransaction(existing);
        assert.strictEqual(added._tag, "Added");

        const outcome = yield* Effect.either(addTransaction(incoming));
        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(
            outcome.left instanceof TxPoolReplacementNotAllowedError,
          );
        }

        const pending = yield* getPendingTransactions();
        assert.strictEqual(pending.length, 1);
        assert.strictEqual(
          Hash.toHex(Transaction.hash(pending[0]!)),
          Hash.toHex(Transaction.hash(existing)),
        );
      }).pipe(Effect.provide(TxPoolLive(TxPoolConfigDefaults))),
  );

  it.effect(
    "replaces same-sender same-nonce transaction when fee bump is sufficient",
    () =>
      Effect.gen(function* () {
        const existing = makeSignedEip1559Tx(0n, 1n, 2n);
        const replacement = makeSignedEip1559Tx(0n, 2n, 3n);

        const first = yield* addTransaction(existing);
        assert.strictEqual(first._tag, "Added");

        const second = yield* addTransaction(replacement);
        assert.strictEqual(second._tag, "Added");

        const count = yield* getPendingCount();
        assert.strictEqual(count, 1);

        const sender = Transaction.getSender(replacement);
        const bySender = yield* getPendingTransactionsBySender(sender);
        assert.strictEqual(bySender.length, 1);
        assert.strictEqual(
          Hash.toHex(Transaction.hash(bySender[0]!)),
          Hash.toHex(Transaction.hash(replacement)),
        );
      }).pipe(Effect.provide(TxPoolLive(TxPoolConfigDefaults))),
  );

  it.effect(
    "allows valid same-nonce replacement when pool size and sender limit are saturated",
    () =>
      Effect.gen(function* () {
        const existing = makeSignedEip1559Tx(0n, 1n, 2n);
        const replacement = makeSignedEip1559Tx(0n, 2n, 3n);

        const first = yield* addTransaction(existing);
        assert.strictEqual(first._tag, "Added");

        const second = yield* addTransaction(replacement);
        assert.strictEqual(second._tag, "Added");

        const count = yield* getPendingCount();
        assert.strictEqual(count, 1);
      }).pipe(
        Effect.provide(
          TxPoolLive({
            ...TxPoolConfigDefaults,
            size: 1,
            maxPendingTxsPerSender: 1,
          }),
        ),
      ),
  );

  it.effect("adds blob transactions and updates blob count", () =>
    Effect.gen(function* () {
      const blobTx = makeSignedEip4844Tx(0n);
      const result = yield* addTransaction(blobTx);
      assert.strictEqual(result._tag, "Added");

      const blobCount = yield* getPendingBlobCount();
      assert.strictEqual(blobCount, 1);
    }).pipe(Effect.provide(TxPoolLive(TxPoolConfigDefaults))),
  );

  it.effect("applies blob replacement fee rules for maxFeePerBlobGas", () =>
    Effect.gen(function* () {
      const existing = makeSignedEip4844Tx(0n, 10n, 10n, 10n);
      const underpricedBlobFee = makeSignedEip4844Tx(0n, 20n, 20n, 19n);

      const first = yield* addTransaction(existing);
      assert.strictEqual(first._tag, "Added");

      const second = yield* Effect.either(addTransaction(underpricedBlobFee));
      assert.isTrue(Either.isLeft(second));
      if (Either.isLeft(second)) {
        assert.isTrue(second.left instanceof TxPoolReplacementNotAllowedError);
      }
    }).pipe(Effect.provide(TxPoolLive(TxPoolConfigDefaults))),
  );

  it.effect("rejects blob replacement with fewer blobs", () =>
    Effect.gen(function* () {
      const existing = makeSignedEip4844Tx(0n, 10n, 10n, 10n, [
        makeBlobHash(1),
        makeBlobHash(2),
      ]);
      const fewerBlobsReplacement = makeSignedEip4844Tx(0n, 20n, 20n, 20n, [
        makeBlobHash(1),
      ]);

      const first = yield* addTransaction(existing);
      assert.strictEqual(first._tag, "Added");

      const second = yield* Effect.either(
        addTransaction(fewerBlobsReplacement),
      );
      assert.isTrue(Either.isLeft(second));
      if (Either.isLeft(second)) {
        assert.isTrue(second.left instanceof TxPoolReplacementNotAllowedError);
      }
    }).pipe(Effect.provide(TxPoolLive(TxPoolConfigDefaults))),
  );

  it.effect("validates transactions and recovers sender", () =>
    Effect.gen(function* () {
      const tx = makeSignedEip1559Tx(0n);
      const validated = yield* validateTransaction(tx);
      assert.isFalse(validated.isBlob);
      const expectedSender = Transaction.getSender(tx);
      assert.isTrue(Address.equals(validated.sender, expectedSender));
    }).pipe(Effect.provide(TxPoolLive(TxPoolConfigDefaults))),
  );

  it.effect("removes transactions by hash", () =>
    Effect.gen(function* () {
      const tx = makeSignedEip1559Tx(0n);
      const result = yield* addTransaction(tx);
      assert.strictEqual(result._tag, "Added");

      const removed = yield* removeTransaction(result.hash);
      assert.isTrue(removed);

      const count = yield* getPendingCount();
      assert.strictEqual(count, 0);
    }).pipe(Effect.provide(TxPoolLive(TxPoolConfigDefaults))),
  );

  it.effect("enforces pool size limits", () =>
    Effect.gen(function* () {
      const tx1 = makeSignedEip1559Tx(0n);
      const tx2 = makeSignedEip1559Tx(1n);

      yield* addTransaction(tx1);
      const outcome = yield* Effect.either(addTransaction(tx2));

      assert.isTrue(Either.isLeft(outcome));
      if (Either.isLeft(outcome)) {
        assert.isTrue(outcome.left instanceof TxPoolFullError);
      }
    }).pipe(
      Effect.provide(
        TxPoolLive({
          ...TxPoolConfigDefaults,
          size: 1,
        }),
      ),
    ),
  );

  it.effect("enforces per-sender pending limits", () =>
    Effect.gen(function* () {
      const tx1 = makeSignedEip1559Tx(0n);
      const tx2 = makeSignedEip1559Tx(1n);

      yield* addTransaction(tx1);
      const outcome = yield* Effect.either(addTransaction(tx2));

      assert.isTrue(Either.isLeft(outcome));
      if (Either.isLeft(outcome)) {
        assert.isTrue(outcome.left instanceof TxPoolSenderLimitExceededError);
      }
    }).pipe(
      Effect.provide(
        TxPoolLive({
          ...TxPoolConfigDefaults,
          maxPendingTxsPerSender: 1,
        }),
      ),
    ),
  );

  it.effect("rejects blob transactions when blobs are disabled", () =>
    Effect.gen(function* () {
      const blobTx = makeSignedEip4844Tx(0n);
      const outcome = yield* Effect.either(addTransaction(blobTx));
      assert.isTrue(Either.isLeft(outcome));
      if (Either.isLeft(outcome)) {
        assert.isTrue(outcome.left instanceof TxPoolBlobSupportDisabledError);
      }
    }).pipe(
      Effect.provide(
        TxPoolLive({
          ...TxPoolConfigDefaults,
          blobsSupport: BlobsSupportMode.Disabled,
        }),
      ),
    ),
  );

  it.effect("rejects blob transactions with low priority fee", () =>
    Effect.gen(function* () {
      const blobTx = makeSignedEip4844Tx(0n, 1n);
      const outcome = yield* Effect.either(addTransaction(blobTx));
      assert.isTrue(Either.isLeft(outcome));
      if (Either.isLeft(outcome)) {
        assert.isTrue(outcome.left instanceof TxPoolPriorityFeeTooLowError);
      }
    }).pipe(
      Effect.provide(
        TxPoolLive({
          ...TxPoolConfigDefaults,
          minBlobTxPriorityFee: 5n,
        }),
      ),
    ),
  );

  it.effect(
    "rejects blob transactions below current blob base fee when required",
    () =>
      Effect.gen(function* () {
        const blobTx = makeSignedEip4844Tx(0n, 1n, 2n, 9n);
        const outcome = yield* Effect.either(addTransaction(blobTx));
        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof TxPoolBlobFeeCapTooLowError);
        }
      }).pipe(
        Effect.provide(
          TxPoolLive(TxPoolConfigDefaults, {
            blockGasLimit: null,
            currentFeePerBlobGas: 10n,
          }),
        ),
      ),
  );

  it.effect(
    "allows blob transactions below current blob base fee when disabled",
    () =>
      Effect.gen(function* () {
        const blobTx = makeSignedEip4844Tx(0n, 1n, 2n, 9n);
        const result = yield* addTransaction(blobTx);
        assert.strictEqual(result._tag, "Added");
      }).pipe(
        Effect.provide(
          TxPoolLive(
            {
              ...TxPoolConfigDefaults,
              currentBlobBaseFeeRequired: false,
            },
            {
              blockGasLimit: null,
              currentFeePerBlobGas: 10n,
            },
          ),
        ),
      ),
  );

  it.effect("derives blob support from configuration", () =>
    Effect.gen(function* () {
      const enabled = yield* supportsBlobs();
      assert.isTrue(enabled);
    }).pipe(Effect.provide(TxPoolLive(TxPoolConfigDefaults))),
  );

  it.effect("returns false when blob support is disabled", () =>
    Effect.gen(function* () {
      const enabled = yield* supportsBlobs();
      assert.isFalse(enabled);
    }).pipe(
      Effect.provide(
        TxPoolLive({
          ...TxPoolConfigDefaults,
          blobsSupport: BlobsSupportMode.Disabled,
        }),
      ),
    ),
  );

  it.effect("derives accept-tx-when-not-synced from configuration", () =>
    Effect.gen(function* () {
      const allowed = yield* acceptTxWhenNotSynced();
      assert.isFalse(allowed);
    }).pipe(Effect.provide(TxPoolLive(TxPoolConfigDefaults))),
  );

  it.effect("returns true when accept-tx-when-not-synced is enabled", () =>
    Effect.gen(function* () {
      const allowed = yield* acceptTxWhenNotSynced();
      assert.isTrue(allowed);
    }).pipe(
      Effect.provide(
        TxPoolLive({
          ...TxPoolConfigDefaults,
          acceptTxWhenNotSynced: true,
        }),
      ),
    ),
  );

  it.effect("fails when configuration is invalid", () =>
    Effect.gen(function* () {
      const outcome = yield* Effect.either(
        getPendingCount().pipe(
          Effect.provide(TxPoolLive({ ...TxPoolConfigDefaults, size: -1 })),
        ),
      );
      assert.isTrue(Either.isLeft(outcome));
      if (Either.isLeft(outcome)) {
        assert.isTrue(outcome.left instanceof InvalidTxPoolConfigError);
      }
    }),
  );
});
