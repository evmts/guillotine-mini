import * as Context from "effect/Context";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";
import {
  Address,
  RuntimeCode,
  Storage,
  StorageValue,
} from "voltaire-effect/primitives";
import type { AccountStateType } from "./Account";
import { WorldState, WorldStateTest } from "./State";

/** Canonical storage slot type. */
type StorageSlotType = Schema.Schema.Type<typeof Storage.StorageSlotSchema>;
/** Canonical storage value type. */
type StorageValueType = Schema.Schema.Type<
  typeof StorageValue.StorageValueSchema
>;

/**
 * Read-only view of the world state, mirroring Nethermind's IStateReader boundary.
 * Exposes only pure reads used by EVM and RPC: account (optional), code, storage, and presence check.
 */
export interface WorldStateReaderService {
  readonly getAccountOptional: (
    address: Address.AddressType,
  ) => Effect.Effect<AccountStateType | null>;
  /** True if an account exists (regardless of emptiness). */
  readonly hasAccount: (address: Address.AddressType) => Effect.Effect<boolean>;
  readonly getCode: (
    address: Address.AddressType,
  ) => Effect.Effect<RuntimeCode.RuntimeCodeType>;
  readonly getStorage: (
    address: Address.AddressType,
    slot: StorageSlotType,
  ) => Effect.Effect<StorageValueType>;
}

/** Context tag for the read-only world state service. */
export class WorldStateReader extends Context.Tag("WorldStateReader")<
  WorldStateReader,
  WorldStateReaderService
>() {}

const makeWorldStateReader = Effect.gen(function* () {
  const worldState = yield* WorldState;

  const getAccountOptional = (address: Address.AddressType) =>
    worldState.getAccountOptional(address);

  const hasAccount = (address: Address.AddressType) =>
    worldState.hasAccount(address);

  const getCode = (address: Address.AddressType) => worldState.getCode(address);

  const getStorage = (address: Address.AddressType, slot: StorageSlotType) =>
    worldState.getStorage(address, slot);

  return {
    getAccountOptional,
    hasAccount,
    getCode,
    getStorage,
  } satisfies WorldStateReaderService;
});

/** Adapter Layer: provide WorldStateReader from an existing WorldState. */
export const WorldStateReaderFromWorldState: Layer.Layer<
  WorldStateReader,
  never,
  WorldState
> = Layer.effect(WorldStateReader, makeWorldStateReader);

/** Deterministic reader layer for tests (adapts the in-memory WorldStateTest). */
export const WorldStateReaderTest: Layer.Layer<WorldStateReader> =
  WorldStateReaderFromWorldState.pipe(Layer.provide(WorldStateTest));
