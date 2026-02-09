import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import { Address, Hash, Transaction } from "voltaire-effect/primitives";
import {
  IntrinsicGasCalculatorTest,
  calculateIntrinsicGas,
} from "./IntrinsicGasCalculator";

const provideCalculator = <A, E, R>(effect: Effect.Effect<A, E, R>) =>
  effect.pipe(Effect.provide(IntrinsicGasCalculatorTest));

const makeAddress = (lastByte: number): Address.AddressType => {
  const addr = Address.zero();
  addr[addr.length - 1] = lastByte;
  return addr;
};

const EMPTY_SIGNATURE = {
  r: new Uint8Array(32),
  s: new Uint8Array(32),
};

const makeLegacyTx = (
  data: Uint8Array,
  to: Address.AddressType | null,
): Transaction.Legacy => ({
  type: Transaction.Type.Legacy,
  nonce: 0n,
  gasPrice: 1n,
  gasLimit: 100_000n,
  to,
  value: 0n,
  data,
  v: 27n,
  r: EMPTY_SIGNATURE.r,
  s: EMPTY_SIGNATURE.s,
});

const makeAccessListTx = (
  accessList: Transaction.EIP2930["accessList"],
): Transaction.EIP2930 => ({
  type: Transaction.Type.EIP2930,
  chainId: 1n,
  nonce: 0n,
  gasPrice: 1n,
  gasLimit: 100_000n,
  to: Address.zero(),
  value: 0n,
  data: new Uint8Array(0),
  accessList,
  yParity: 0,
  r: EMPTY_SIGNATURE.r,
  s: EMPTY_SIGNATURE.s,
});

const makeSetCodeTx = (
  authorizationList: Transaction.EIP7702["authorizationList"],
): Transaction.EIP7702 => ({
  type: Transaction.Type.EIP7702,
  chainId: 1n,
  nonce: 0n,
  maxPriorityFeePerGas: 1n,
  maxFeePerGas: 2n,
  gasLimit: 100_000n,
  to: Address.zero(),
  value: 0n,
  data: new Uint8Array(0),
  accessList: [],
  authorizationList,
  yParity: 0,
  r: EMPTY_SIGNATURE.r,
  s: EMPTY_SIGNATURE.s,
});

describe("IntrinsicGasCalculator", () => {
  it.effect("calculates calldata costs and floor for legacy tx", () =>
    provideCalculator(
      Effect.gen(function* () {
        const data = new Uint8Array([0x00, 0x01, 0x00, 0x02]);
        const tx = makeLegacyTx(data, Address.zero());
        const result = yield* calculateIntrinsicGas(tx);
        assert.strictEqual(result.intrinsicGas, 21_040n);
        assert.strictEqual(result.calldataFloorGas, 21_100n);
      }),
    ),
  );

  it.effect("adds create and init code costs for contract creation", () =>
    provideCalculator(
      Effect.gen(function* () {
        const data = new Uint8Array(33);
        const tx = makeLegacyTx(data, null);
        const result = yield* calculateIntrinsicGas(tx);
        assert.strictEqual(result.intrinsicGas, 53_136n);
        assert.strictEqual(result.calldataFloorGas, 21_330n);
      }),
    ),
  );

  it.effect("charges access list costs for EIP-2930", () =>
    provideCalculator(
      Effect.gen(function* () {
        const accessList: Transaction.EIP2930["accessList"] = [
          {
            address: Address.zero(),
            storageKeys: [Hash.ZERO],
          },
          {
            address: makeAddress(1),
            storageKeys: [Hash.ZERO, Hash.ZERO],
          },
        ];
        const tx = makeAccessListTx(accessList);
        const result = yield* calculateIntrinsicGas(tx);
        assert.strictEqual(result.intrinsicGas, 31_500n);
        assert.strictEqual(result.calldataFloorGas, 21_000n);
      }),
    ),
  );

  it.effect("charges authorization costs for EIP-7702", () =>
    provideCalculator(
      Effect.gen(function* () {
        const authorizationList: Transaction.EIP7702["authorizationList"] = [
          {
            chainId: 1n,
            address: Address.zero(),
            nonce: 0n,
            yParity: 0,
            r: EMPTY_SIGNATURE.r,
            s: EMPTY_SIGNATURE.s,
          },
          {
            chainId: 1n,
            address: makeAddress(2),
            nonce: 1n,
            yParity: 1,
            r: EMPTY_SIGNATURE.r,
            s: EMPTY_SIGNATURE.s,
          },
        ];
        const tx = makeSetCodeTx(authorizationList);
        const result = yield* calculateIntrinsicGas(tx);
        assert.strictEqual(result.intrinsicGas, 71_000n);
        assert.strictEqual(result.calldataFloorGas, 21_000n);
      }),
    ),
  );
});
