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
import {
  TransactionEnvironmentBuilderTest,
  buildTransactionEnvironment,
} from "./TransactionEnvironmentBuilder";
import { AccessListBuilderTest } from "./AccessListBuilder";
import { IntrinsicGasCalculatorTest } from "./IntrinsicGasCalculator";
import {
  TransactionProcessorTest,
  executeEvmCall,
  runInTransactionBoundary,
} from "./TransactionProcessor";
import {
  EvmExecutorLive,
  EvmExecutorTest,
  EvmExecutionError,
} from "./EvmExecutor";
import { TransactionBoundaryTest } from "../state/TransactionBoundary";

const LegacySchema = Transaction.LegacySchema as unknown as Schema.Schema<
  Transaction.Legacy,
  unknown
>;
const GasPriceSchema = GasPrice.BigInt as unknown as Schema.Schema<
  GasPrice.GasPriceType,
  bigint
>;

const makeAddress = (lastByte: number): Address.AddressType => {
  const a = Address.zero();
  a[a.length - 1] = lastByte;
  return a;
};

const encode = (addr: Address.AddressType): string => Hex.fromBytes(addr);

const makeLegacyTx = (gasLimit: bigint): Transaction.Legacy =>
  Schema.decodeSync(LegacySchema)({
    type: Transaction.Type.Legacy,
    nonce: 0n,
    gasPrice: 1n,
    gasLimit,
    to: encode(Address.zero()),
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

const BaseTestLayer = Layer.mergeAll(
  TransactionProcessorTest,
  TransactionBoundaryTest,
  EnvBuilderLayer,
);

const provide = <A, E, R>(eff: Effect.Effect<A, E, R>) =>
  eff.pipe(Effect.provide(BaseTestLayer), Effect.provide(EvmExecutorTest));

describe("TransactionProcessor.executeEvmCall", () => {
  it.effect("delegates to EvmExecutor within call-frame boundary", () =>
    provide(
      Effect.gen(function* () {
        const origin = makeAddress(0x01);
        const coinbase = makeAddress(0xaa);
        const to = makeAddress(0xbb);
        const gasPrice = Schema.decodeSync(GasPriceSchema)(1n);
        const tx = makeLegacyTx(50_000n);

        const env = yield* buildTransactionEnvironment({
          tx,
          origin,
          coinbase,
          gasPrice,
        });

        const output = yield* runInTransactionBoundary(
          executeEvmCall(env, {
            to,
            input: new Uint8Array(0),
            value: 0n,
            isStatic: false,
          }),
        );

        assert.strictEqual(typeof output.gasLeft, "bigint");
        assert.strictEqual(output.refundCounter, 0n);
        assert.ok(Array.isArray(output.logs));
        assert.ok(Array.isArray(output.accountsToDelete));
        // EvmExecutorTest echoes `to` when provided
        assert.strictEqual(
          Hex.fromBytes(output.logs[0]!.address),
          Hex.fromBytes(to),
        );
      }),
    ),
  );

  it.effect("fails without an active transaction boundary", () =>
    provide(
      Effect.gen(function* () {
        const origin = makeAddress(0x02);
        const coinbase = makeAddress(0xab);
        const gasPrice = Schema.decodeSync(GasPriceSchema)(1n);
        const tx = makeLegacyTx(30_000n);
        const env = yield* buildTransactionEnvironment({
          tx,
          origin,
          coinbase,
          gasPrice,
        });

        const result = yield* Effect.either(
          executeEvmCall(env, {
            to: coinbase,
            input: new Uint8Array(0),
            value: 0n,
            isStatic: true,
          }),
        );

        assert.isTrue(Either.isLeft(result));
      }),
    ),
  );

  it.effect("propagates EvmExecutionError from executor", () =>
    // Use EvmExecutorLive which currently always fails to simulate error propagation
    Effect.gen(function* () {
      const origin = makeAddress(0x03);
      const coinbase = makeAddress(0xac);
      const gasPrice = Schema.decodeSync(GasPriceSchema)(1n);
      const tx = makeLegacyTx(40_000n);

      const env = yield* buildTransactionEnvironment({
        tx,
        origin,
        coinbase,
        gasPrice,
      }).pipe(Effect.provide(BaseTestLayer));

      const eff = runInTransactionBoundary(
        executeEvmCall(env, {
          to: coinbase,
          input: new Uint8Array(0),
          value: 0n,
          isStatic: false,
        }),
      );

      const ErrorLayer = Layer.mergeAll(BaseTestLayer, EvmExecutorLive);
      const result = yield* Effect.either(eff.pipe(Effect.provide(ErrorLayer)));
      assert.isTrue(Either.isLeft(result));
      if (Either.isLeft(result)) {
        assert.isTrue(result.left instanceof EvmExecutionError);
      }
    }),
  );
});
