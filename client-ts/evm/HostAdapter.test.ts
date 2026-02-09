import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import { Address, Hex, RuntimeCode } from "voltaire-effect/primitives";
import {
  HostAdapterTest,
  getBalance,
  getCode,
  getNonce,
  getStorage,
  setBalance,
  setCode,
  setNonce,
  setStorage,
} from "./HostAdapter";

const provideHost = <A, E, R>(effect: Effect.Effect<A, E, R>) =>
  effect.pipe(Effect.provide(HostAdapterTest));

const makeAddress = (lastByte: number): Address.AddressType => {
  const addr = Address.zero();
  addr[addr.length - 1] = lastByte;
  return addr;
};

type StorageSlotType = Parameters<typeof getStorage>[1];
type StorageValueType = Parameters<typeof setStorage>[2];

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

const storageValueHex = (value: Uint8Array) => Hex.fromBytes(value);
const ZERO_STORAGE_VALUE = makeStorageValue(0);

const EMPTY_CODE = new Uint8Array(0) as RuntimeCode.RuntimeCodeType;
const SAMPLE_CODE = new Uint8Array([
  0x60, 0x00, 0x60, 0x00,
]) as RuntimeCode.RuntimeCodeType;

const codeHex = (code: Uint8Array) => Hex.fromBytes(code);

describe("HostAdapter", () => {
  it.effect("returns zero balance for missing accounts", () =>
    provideHost(
      Effect.gen(function* () {
        const balance = yield* getBalance(Address.zero());
        assert.strictEqual(balance, 0n);
      }),
    ),
  );

  it.effect("sets and reads balance", () =>
    provideHost(
      Effect.gen(function* () {
        const addr = makeAddress(1);
        yield* setBalance(addr, 42n);
        const balance = yield* getBalance(addr);
        assert.strictEqual(balance, 42n);
      }),
    ),
  );

  it.effect("returns zero nonce for missing accounts", () =>
    provideHost(
      Effect.gen(function* () {
        const nonce = yield* getNonce(Address.zero());
        assert.strictEqual(nonce, 0n);
      }),
    ),
  );

  it.effect("sets and reads nonce", () =>
    provideHost(
      Effect.gen(function* () {
        const addr = makeAddress(2);
        yield* setNonce(addr, 7n);
        const nonce = yield* getNonce(addr);
        assert.strictEqual(nonce, 7n);
      }),
    ),
  );

  it.effect("returns zero for missing storage slots", () =>
    provideHost(
      Effect.gen(function* () {
        const addr = makeAddress(3);
        const slot = makeSlot(9);
        const value = yield* getStorage(addr, slot);
        assert.strictEqual(
          storageValueHex(value),
          storageValueHex(ZERO_STORAGE_VALUE),
        );
      }),
    ),
  );

  it.effect("sets and reads storage slots", () =>
    provideHost(
      Effect.gen(function* () {
        const addr = makeAddress(4);
        const slot = makeSlot(5);
        const value = makeStorageValue(7);
        yield* setBalance(addr, 1n);
        yield* setStorage(addr, slot, value);
        const stored = yield* getStorage(addr, slot);
        assert.strictEqual(storageValueHex(stored), storageValueHex(value));
      }),
    ),
  );

  it.effect("returns empty code for missing contracts", () =>
    provideHost(
      Effect.gen(function* () {
        const code = yield* getCode(Address.zero());
        assert.strictEqual(codeHex(code), codeHex(EMPTY_CODE));
      }),
    ),
  );

  it.effect("sets and reads contract code", () =>
    provideHost(
      Effect.gen(function* () {
        const addr = makeAddress(5);
        yield* setCode(addr, SAMPLE_CODE);
        const code = yield* getCode(addr);
        assert.strictEqual(codeHex(code), codeHex(SAMPLE_CODE));
      }),
    ),
  );
});
