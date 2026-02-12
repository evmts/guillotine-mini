import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";
import {
  Address,
  GasPrice,
  Hex,
  Transaction,
} from "voltaire-effect/primitives";
import {
  TransactionEnvironmentBuilderTest,
  buildTransactionEnvironment,
} from "./TransactionEnvironmentBuilder";
import { AccessListBuilderTest } from "./AccessListBuilder";
import { IntrinsicGasCalculatorTest } from "./IntrinsicGasCalculator";
import { EvmExecutorTest, executeCall } from "./EvmExecutor";

const LegacySchema = Transaction.LegacySchema as unknown as Schema.Schema<
  Transaction.Legacy,
  unknown
>;
const GasPriceSchema = GasPrice.BigInt as unknown as Schema.Schema<
  GasPrice.GasPriceType,
  bigint
>;

const makeAddress = (lastByte: number): Address.AddressType => {
  const addr = Address.zero();
  addr[addr.length - 1] = lastByte;
  return addr;
};

const encodeAddress = (address: Address.AddressType): string =>
  Hex.fromBytes(address);

const makeLegacyTx = (gasLimit: bigint): Transaction.Legacy =>
  Schema.decodeSync(LegacySchema)({
    type: Transaction.Type.Legacy,
    nonce: 0n,
    gasPrice: 1n,
    gasLimit,
    to: encodeAddress(Address.zero()),
    value: 0n,
    data: new Uint8Array(0),
    v: 27n,
    r: new Uint8Array(32),
    s: new Uint8Array(32),
  });

const EnvBuilderLayer = TransactionEnvironmentBuilderTest.pipe(
  Layer.provide(AccessListBuilderTest),
  Layer.provide(IntrinsicGasCalculatorTest),
);

const TestLayer = Layer.mergeAll(EvmExecutorTest, EnvBuilderLayer);

const provide = <A, E, R>(eff: Effect.Effect<A, E, R>) =>
  eff.pipe(Effect.provide(TestLayer));

describe("EvmExecutor", () => {
  it.effect("executes a call and returns EVM output shape", () =>
    provide(
      Effect.gen(function* () {
        const origin = makeAddress(0x01);
        const coinbase = makeAddress(0xaa);
        const tx = makeLegacyTx(50_000n);
        const gasPrice = Schema.decodeSync(GasPriceSchema)(1n);

        const env = yield* buildTransactionEnvironment({
          tx,
          origin,
          coinbase,
          gasPrice,
        });

        const output = yield* executeCall(env, {
          to: coinbase,
          input: new Uint8Array(0),
          value: 0n,
          isStatic: false,
        });

        assert.strictEqual(typeof output.gasLeft, "bigint");
        assert.strictEqual(output.refundCounter, 0n);
        assert.strictEqual(Array.isArray(output.logs), true);
        assert.strictEqual(Array.isArray(output.accountsToDelete), true);
      }),
    ),
  );
});
