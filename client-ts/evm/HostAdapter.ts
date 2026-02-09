import * as Context from "effect/Context";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";
import {
  Address,
  Hash,
  Hex,
  RuntimeCode,
  Storage,
  StorageValue,
} from "voltaire-effect/primitives";
import { EMPTY_CODE_HASH, type AccountStateType } from "../state/Account";
import { WorldState, WorldStateTest } from "../state/State";
import { coerceEffect } from "../trie/internal/effect";

/** Hex-encoded key for account map storage. */
type AccountKey = Parameters<typeof Hex.equals>[0];
/** Canonical storage slot type. */
type StorageSlotType = Schema.Schema.Type<typeof Storage.StorageSlotSchema>;
/** Canonical storage value type. */
type StorageValueType = Schema.Schema.Type<
  typeof StorageValue.StorageValueSchema
>;

const addressKey = (address: Address.AddressType): AccountKey =>
  Hex.fromBytes(address);

const EMPTY_CODE = new Uint8Array(0) as RuntimeCode.RuntimeCodeType;

const keccak256 = (data: Uint8Array) =>
  coerceEffect<Hash.HashType, never>(Hash.keccak256(data));

const codeHashFor = (code: RuntimeCode.RuntimeCodeType) =>
  code.length === 0
    ? Effect.succeed(EMPTY_CODE_HASH)
    : keccak256(code).pipe(
        Effect.map((hash) => hash as unknown as AccountStateType["codeHash"]),
      );

/** Host adapter interface for EVM access to world state. */
export interface HostAdapterService {
  readonly getBalance: (
    address: Address.AddressType,
  ) => Effect.Effect<AccountStateType["balance"]>;
  readonly setBalance: (
    address: Address.AddressType,
    balance: AccountStateType["balance"],
  ) => Effect.Effect<void>;
  readonly getNonce: (
    address: Address.AddressType,
  ) => Effect.Effect<AccountStateType["nonce"]>;
  readonly setNonce: (
    address: Address.AddressType,
    nonce: AccountStateType["nonce"],
  ) => Effect.Effect<void>;
  readonly getCode: (
    address: Address.AddressType,
  ) => Effect.Effect<RuntimeCode.RuntimeCodeType>;
  readonly setCode: (
    address: Address.AddressType,
    code: RuntimeCode.RuntimeCodeType,
  ) => Effect.Effect<void>;
  readonly getStorage: (
    address: Address.AddressType,
    slot: StorageSlotType,
  ) => Effect.Effect<StorageValueType>;
  readonly setStorage: (
    address: Address.AddressType,
    slot: StorageSlotType,
    value: StorageValueType,
  ) => Effect.Effect<void>;
}

/** Context tag for the host adapter service. */
export class HostAdapter extends Context.Tag("HostAdapter")<
  HostAdapter,
  HostAdapterService
>() {}

const makeHostAdapter = Effect.gen(function* () {
  const worldState = yield* WorldState;
  const codes = new Map<AccountKey, RuntimeCode.RuntimeCodeType>();

  const getBalance = (address: Address.AddressType) =>
    Effect.map(worldState.getAccount(address), (account) => account.balance);

  const setBalance = (
    address: Address.AddressType,
    balance: AccountStateType["balance"],
  ) =>
    Effect.gen(function* () {
      const account = yield* worldState.getAccount(address);
      yield* worldState.setAccount(address, { ...account, balance });
    });

  const getNonce = (address: Address.AddressType) =>
    Effect.map(worldState.getAccount(address), (account) => account.nonce);

  const setNonce = (
    address: Address.AddressType,
    nonce: AccountStateType["nonce"],
  ) =>
    Effect.gen(function* () {
      const account = yield* worldState.getAccount(address);
      yield* worldState.setAccount(address, { ...account, nonce });
    });

  const getCode = (address: Address.AddressType) =>
    Effect.sync(() => codes.get(addressKey(address)) ?? EMPTY_CODE);

  const setCode = (
    address: Address.AddressType,
    code: RuntimeCode.RuntimeCodeType,
  ) =>
    Effect.gen(function* () {
      const key = addressKey(address);
      if (code.length === 0) {
        codes.delete(key);
      } else {
        codes.set(key, code);
      }
      const account = yield* worldState.getAccount(address);
      const codeHash = yield* codeHashFor(code);
      yield* worldState.setAccount(address, { ...account, codeHash });
    });

  const getStorage = (address: Address.AddressType, slot: StorageSlotType) =>
    worldState.getStorage(address, slot);

  const setStorage = (
    address: Address.AddressType,
    slot: StorageSlotType,
    value: StorageValueType,
  ) => worldState.setStorage(address, slot, value);

  return {
    getBalance,
    setBalance,
    getNonce,
    setNonce,
    getCode,
    setCode,
    getStorage,
    setStorage,
  } satisfies HostAdapterService;
});

/** Production host adapter layer. */
export const HostAdapterLive: Layer.Layer<HostAdapter, never, WorldState> =
  Layer.effect(HostAdapter, makeHostAdapter);

/** Deterministic host adapter layer for tests. */
export const HostAdapterTest: Layer.Layer<HostAdapter> = HostAdapterLive.pipe(
  Layer.provide(WorldStateTest),
);

/** Read account balance from the host adapter. */
export const getBalance = (address: Address.AddressType) =>
  Effect.gen(function* () {
    const host = yield* HostAdapter;
    return yield* host.getBalance(address);
  });

/** Set account balance via the host adapter. */
export const setBalance = (
  address: Address.AddressType,
  balance: AccountStateType["balance"],
) =>
  Effect.gen(function* () {
    const host = yield* HostAdapter;
    return yield* host.setBalance(address, balance);
  });

/** Read account nonce from the host adapter. */
export const getNonce = (address: Address.AddressType) =>
  Effect.gen(function* () {
    const host = yield* HostAdapter;
    return yield* host.getNonce(address);
  });

/** Set account nonce via the host adapter. */
export const setNonce = (
  address: Address.AddressType,
  nonce: AccountStateType["nonce"],
) =>
  Effect.gen(function* () {
    const host = yield* HostAdapter;
    return yield* host.setNonce(address, nonce);
  });

/** Read contract code via the host adapter. */
export const getCode = (address: Address.AddressType) =>
  Effect.gen(function* () {
    const host = yield* HostAdapter;
    return yield* host.getCode(address);
  });

/** Store contract code via the host adapter. */
export const setCode = (
  address: Address.AddressType,
  code: RuntimeCode.RuntimeCodeType,
) =>
  Effect.gen(function* () {
    const host = yield* HostAdapter;
    return yield* host.setCode(address, code);
  });

/** Read storage slot value via the host adapter. */
export const getStorage = (
  address: Address.AddressType,
  slot: StorageSlotType,
) =>
  Effect.gen(function* () {
    const host = yield* HostAdapter;
    return yield* host.getStorage(address, slot);
  });

/** Write storage slot value via the host adapter. */
export const setStorage = (
  address: Address.AddressType,
  slot: StorageSlotType,
  value: StorageValueType,
) =>
  Effect.gen(function* () {
    const host = yield* HostAdapter;
    return yield* host.setStorage(address, slot, value);
  });
