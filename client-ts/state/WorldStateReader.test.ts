import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import { Address, Hex, RuntimeCode } from "voltaire-effect/primitives";
import { type AccountStateType, EMPTY_ACCOUNT } from "./Account";
import {
  WorldState,
  WorldStateTest,
  destroyAccount,
  getAccountOptional as wsGetAccountOptional,
  getCode as wsGetCode,
  getStorage as wsGetStorage,
  setAccount,
  setCode,
  setStorage,
} from "./State";
import {
  WorldStateReader,
  WorldStateReaderFromWorldState,
} from "./WorldStateReader";

type StorageSlotType = Parameters<typeof wsGetStorage>[1];
type StorageValueType = Parameters<typeof setStorage>[2];

const provideEnv = <A, E>(
  eff: Effect.Effect<A, E, WorldState | WorldStateReader>,
) =>
  eff.pipe(
    Effect.provide(
      Layer.provideMerge(WorldStateTest)(WorldStateReaderFromWorldState),
    ),
  );

const makeAddress = (lastByte: number): Address.AddressType => {
  const addr = Address.zero();
  addr[addr.length - 1] = lastByte;
  return addr;
};

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

describe("WorldStateReader", () => {
  it.effect("returns null for missing accounts", () =>
    provideEnv(
      Effect.gen(function* () {
        const reader = yield* WorldStateReader;
        const account = yield* reader.getAccountOptional(Address.zero());
        assert.isNull(account);
      }),
    ),
  );

  it.effect("hasAccount reflects presence in world state via adapter", () =>
    provideEnv(
      Effect.gen(function* () {
        const reader = yield* WorldStateReader;
        const addr = makeAddress(0xee);
        assert.isFalse(yield* reader.hasAccount(addr));
        yield* setAccount(addr, {
          ...EMPTY_ACCOUNT,
          nonce: 1n,
        } satisfies AccountStateType);
        assert.isTrue(yield* reader.hasAccount(addr));
        yield* destroyAccount(addr);
        assert.isFalse(yield* reader.hasAccount(addr));
      }),
    ),
  );

  it.effect("reads code through adapter (empty and set)", () =>
    provideEnv(
      Effect.gen(function* () {
        const reader = yield* WorldStateReader;
        const addr = makeAddress(0xab);
        const empty = yield* reader.getCode(addr);
        assert.strictEqual(codeHex(empty), codeHex(EMPTY_CODE));

        yield* setCode(addr, SAMPLE_CODE);
        const stored = yield* reader.getCode(addr);
        assert.strictEqual(codeHex(stored), codeHex(SAMPLE_CODE));
      }),
    ),
  );

  it.effect("reads storage through adapter (zero and set)", () =>
    provideEnv(
      Effect.gen(function* () {
        const reader = yield* WorldStateReader;
        const addr = makeAddress(0xcd);
        const slot = makeSlot(1);
        const value = makeStorageValue(7);

        const zero = yield* reader.getStorage(addr, slot);
        assert.strictEqual(
          storageValueHex(zero),
          storageValueHex(ZERO_STORAGE_VALUE),
        );

        yield* setAccount(addr, EMPTY_ACCOUNT);
        yield* setStorage(addr, slot, value);
        const stored = yield* reader.getStorage(addr, slot);
        assert.strictEqual(storageValueHex(stored), storageValueHex(value));
      }),
    ),
  );
});
