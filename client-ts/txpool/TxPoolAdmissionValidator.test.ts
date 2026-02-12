import { secp256k1 } from "@noble/curves/secp256k1.js";
import { assert, describe, it } from "@effect/vitest";
import * as Either from "effect/Either";
import * as Effect from "effect/Effect";
import * as Schema from "effect/Schema";
import { Address, Hex, Transaction } from "voltaire-effect/primitives";
import {
  BlobsSupportMode,
  TxPoolBlobFeeCapTooLowError,
  TxPoolBlobSupportDisabledError,
  type TxPoolConfig,
  TxPoolConfigDefaults,
  TxPoolGasLimitExceededError,
} from "./TxPool";
import {
  TxPoolAdmissionValidatorLive,
  validateTxPoolAdmission,
} from "./TxPoolAdmissionValidator";

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

const DefaultAdmissionConfig = {
  ...TxPoolConfigDefaults,
  minBlobTxPriorityFee: 0n,
} satisfies TxPoolConfig;

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

const makeSignedEip1559Tx = (
  nonce: bigint,
  gasLimit = 100_000n,
): Transaction.EIP1559 =>
  signDynamicFeeTx(
    Schema.validateSync(Eip1559Schema)({
      type: Transaction.Type.EIP1559,
      chainId: 1n,
      nonce,
      maxPriorityFeePerGas: 1n,
      maxFeePerGas: 2n,
      gasLimit,
      to: encodeAddress(Address.zero()),
      value: 0n,
      data: new Uint8Array(0),
      accessList: [],
      yParity: 0,
      r: new Uint8Array(32),
      s: new Uint8Array(32),
    }),
  );

const makeSignedEip4844Tx = (
  nonce: bigint,
  maxFeePerBlobGas = 3n,
): Transaction.EIP4844 =>
  signDynamicFeeTx(
    Schema.validateSync(Eip4844Schema)({
      type: Transaction.Type.EIP4844,
      chainId: 1n,
      nonce,
      maxPriorityFeePerGas: 1n,
      maxFeePerGas: 2n,
      gasLimit: 120_000n,
      to: encodeAddress(Address.zero()),
      value: 0n,
      data: new Uint8Array(0),
      accessList: [],
      maxFeePerBlobGas,
      blobVersionedHashes: [makeBlobHash(1)],
      yParity: 0,
      r: new Uint8Array(32),
      s: new Uint8Array(32),
    }),
  );

describe("TxPoolAdmissionValidator", () => {
  it.effect("accepts signed EIP-1559 transactions", () =>
    Effect.gen(function* () {
      const tx = makeSignedEip1559Tx(0n);

      const validated = yield* validateTxPoolAdmission(tx);
      assert.strictEqual(validated.isBlob, false);
      assert.strictEqual(validated.size > 0, true);
      assert.strictEqual(validated.tx, tx);
      assert.deepStrictEqual(validated.hash, Transaction.hash(tx));
      assert.deepStrictEqual(validated.sender, Transaction.getSender(tx));
    }).pipe(
      Effect.provide(TxPoolAdmissionValidatorLive(DefaultAdmissionConfig)),
    ),
  );

  it.effect("rejects blob transactions when blob support is disabled", () =>
    Effect.gen(function* () {
      const tx = makeSignedEip4844Tx(0n);
      const outcome = yield* Effect.either(validateTxPoolAdmission(tx));

      assert.isTrue(Either.isLeft(outcome));
      if (Either.isLeft(outcome)) {
        assert.isTrue(outcome.left instanceof TxPoolBlobSupportDisabledError);
      }
    }).pipe(
      Effect.provide(
        TxPoolAdmissionValidatorLive({
          ...DefaultAdmissionConfig,
          blobsSupport: BlobsSupportMode.Disabled,
        }),
      ),
    ),
  );

  it.effect(
    "applies effective gas limit as min(configured gas limit, current head gas limit)",
    () =>
      Effect.gen(function* () {
        const tx = makeSignedEip1559Tx(0n, 70_000n);
        const outcome = yield* Effect.either(validateTxPoolAdmission(tx));

        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(outcome.left instanceof TxPoolGasLimitExceededError);
          if (outcome.left instanceof TxPoolGasLimitExceededError) {
            assert.strictEqual(outcome.left.configuredLimit, 55_000n);
          }
        }
      }).pipe(
        Effect.provide(
          TxPoolAdmissionValidatorLive(
            {
              ...DefaultAdmissionConfig,
              gasLimit: 60_000,
            },
            {
              blockGasLimit: 55_000n,
              currentFeePerBlobGas: 1n,
            },
          ),
        ),
      ),
  );

  it.effect("rejects blob transactions below current blob base fee", () =>
    Effect.gen(function* () {
      const tx = makeSignedEip4844Tx(0n, 9n);
      const outcome = yield* Effect.either(validateTxPoolAdmission(tx));

      assert.isTrue(Either.isLeft(outcome));
      if (Either.isLeft(outcome)) {
        assert.isTrue(outcome.left instanceof TxPoolBlobFeeCapTooLowError);
      }
    }).pipe(
      Effect.provide(
        TxPoolAdmissionValidatorLive(DefaultAdmissionConfig, {
          blockGasLimit: null,
          currentFeePerBlobGas: 10n,
        }),
      ),
    ),
  );
});
