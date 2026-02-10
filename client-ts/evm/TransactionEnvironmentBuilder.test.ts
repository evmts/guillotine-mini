import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Either from "effect/Either";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";
import {
  Address,
  GasPrice,
  Hex,
  Transaction,
} from "voltaire-effect/primitives";
import { AccessListBuilderTest } from "./AccessListBuilder";
import { IntrinsicGasCalculatorTest } from "./IntrinsicGasCalculator";
import {
  TransactionEnvironmentBuilderTest,
  buildTransactionEnvironment,
  InsufficientTransactionGasError,
} from "./TransactionEnvironmentBuilder";
import type { TransientStorageService } from "../state/TransientStorage";

const LegacySchema = Transaction.LegacySchema as unknown as Schema.Schema<
  Transaction.Legacy,
  unknown
>;
const Eip4844Schema = Transaction.EIP4844Schema as unknown as Schema.Schema<
  Transaction.EIP4844,
  unknown
>;
const GasPriceSchema = GasPrice.BigInt as unknown as Schema.Schema<
  GasPrice.GasPriceType,
  bigint
>;

const EMPTY_SIGNATURE = {
  r: new Uint8Array(32),
  s: new Uint8Array(32),
};

const makeAddress = (lastByte: number): Address.AddressType => {
  const addr = Address.zero();
  addr[addr.length - 1] = lastByte;
  return addr;
};

const encodeAddress = (address: Address.AddressType): string =>
  Hex.fromBytes(address);

const makeLegacyTx = (
  gasLimit: bigint,
  data: Uint8Array = new Uint8Array(0),
): Transaction.Legacy =>
  Schema.decodeSync(LegacySchema)({
    type: Transaction.Type.Legacy,
    nonce: 0n,
    gasPrice: 1n,
    gasLimit,
    to: encodeAddress(Address.zero()),
    value: 0n,
    data,
    v: 27n,
    r: EMPTY_SIGNATURE.r,
    s: EMPTY_SIGNATURE.s,
  });

const makeBlobHash = (versionByte: number): Uint8Array => {
  const hash = new Uint8Array(32);
  hash[0] = versionByte;
  return hash;
};

const makeEip4844Tx = (
  gasLimit: bigint,
  blobVersionedHashes: Uint8Array[],
): Transaction.EIP4844 =>
  Schema.decodeSync(Eip4844Schema)({
    type: Transaction.Type.EIP4844,
    chainId: 1n,
    nonce: 0n,
    maxPriorityFeePerGas: 1n,
    maxFeePerGas: 2n,
    gasLimit,
    to: encodeAddress(Address.zero()),
    value: 0n,
    data: new Uint8Array(0),
    accessList: [],
    maxFeePerBlobGas: 1n,
    blobVersionedHashes,
    yParity: 0,
    r: EMPTY_SIGNATURE.r,
    s: EMPTY_SIGNATURE.s,
  });

type StorageSlotType = Parameters<TransientStorageService["get"]>[1];
type StorageValueType = Parameters<TransientStorageService["set"]>[2];

const makeSlot = (lastByte: number): StorageSlotType => {
  const value = new Uint8Array(32);
  value[value.length - 1] = lastByte;
  return value as StorageSlotType;
};

const makeStorageValue = (byte: number): StorageValueType => {
  const value = new Uint8Array(32);
  value.fill(byte);
  return value as StorageValueType;
};

const ZERO_STORAGE_VALUE = makeStorageValue(0);

const BaseLayer = Layer.merge(
  AccessListBuilderTest,
  IntrinsicGasCalculatorTest,
);
const TestLayer = TransactionEnvironmentBuilderTest.pipe(
  Layer.provide(BaseLayer),
);

const provideBuilder = <A, E, R>(effect: Effect.Effect<A, E, R>) =>
  effect.pipe(Effect.provide(TestLayer));

describe("TransactionEnvironmentBuilder", () => {
  it.effect("builds environment and clears transient storage", () =>
    provideBuilder(
      Effect.gen(function* () {
        const origin = makeAddress(0x01);
        const coinbase = makeAddress(0xaa);
        const tx = makeLegacyTx(50_000n);
        const gasPrice = Schema.decodeSync(GasPriceSchema)(1n);
        const slot = makeSlot(0x02);
        const stored = makeStorageValue(0x11);

        const env = yield* buildTransactionEnvironment({
          tx,
          origin,
          coinbase,
          gasPrice,
        });

        yield* env.transientStorage.set(origin, slot, stored);

        const refreshed = yield* buildTransactionEnvironment({
          tx,
          origin,
          coinbase,
          gasPrice,
        });

        assert.strictEqual(refreshed.gas, 29_000n);
        assert.strictEqual(refreshed.accessListAddresses.length, 1);
        const first = refreshed.accessListAddresses[0];
        if (!first) {
          throw new Error("missing coinbase address");
        }
        assert.isTrue(Address.equals(first, coinbase));
        assert.strictEqual(refreshed.blobVersionedHashes.length, 0);

        const cleared = yield* refreshed.transientStorage.get(origin, slot);
        assert.strictEqual(
          Hex.fromBytes(cleared),
          Hex.fromBytes(ZERO_STORAGE_VALUE),
        );
      }),
    ),
  );

  it.effect("fails when gas limit below calldata floor", () =>
    provideBuilder(
      Effect.gen(function* () {
        const origin = makeAddress(0x02);
        const coinbase = makeAddress(0xbb);
        const data = new Uint8Array([0x01]);
        const tx = makeLegacyTx(21_030n, data);
        const gasPrice = Schema.decodeSync(GasPriceSchema)(1n);

        const outcome = yield* Effect.either(
          buildTransactionEnvironment({ tx, origin, coinbase, gasPrice }),
        );

        assert.isTrue(Either.isLeft(outcome));
        if (Either.isLeft(outcome)) {
          assert.isTrue(
            outcome.left instanceof InsufficientTransactionGasError,
          );
        }
      }),
    ),
  );

  it.effect("uses intrinsic gas for available gas", () =>
    provideBuilder(
      Effect.gen(function* () {
        const origin = makeAddress(0x03);
        const coinbase = makeAddress(0xcc);
        const data = new Uint8Array([0x01]);
        const tx = makeLegacyTx(21_100n, data);
        const gasPrice = Schema.decodeSync(GasPriceSchema)(1n);

        const env = yield* buildTransactionEnvironment({
          tx,
          origin,
          coinbase,
          gasPrice,
        });

        assert.strictEqual(env.gas, 84n);
      }),
    ),
  );

  it.effect("includes blob versioned hashes", () =>
    provideBuilder(
      Effect.gen(function* () {
        const origin = makeAddress(0x04);
        const coinbase = makeAddress(0xdd);
        const hashes = [makeBlobHash(0x01), makeBlobHash(0x02)];
        const tx = makeEip4844Tx(50_000n, hashes);
        const gasPrice = Schema.decodeSync(GasPriceSchema)(1n);

        const env = yield* buildTransactionEnvironment({
          tx,
          origin,
          coinbase,
          gasPrice,
        });

        assert.strictEqual(env.blobVersionedHashes.length, hashes.length);
        const hashHexes = env.blobVersionedHashes.map(Hex.fromBytes);
        assert.isTrue(hashHexes.includes(Hex.fromBytes(hashes[0]!)));
        assert.isTrue(hashHexes.includes(Hex.fromBytes(hashes[1]!)));
      }),
    ),
  );
});
