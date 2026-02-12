import * as Context from "effect/Context";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import { Address, RuntimeCode } from "voltaire-effect/primitives";
import type { AccountStateType } from "./Account";
import { WorldState, WorldStateTest } from "./State";
import type {
  StorageSlotType,
  StorageValueType,
} from "./StorageTypes";

// Storage types are centralized in `StorageTypes.ts` to prevent drift.

/**
 * Read-only view of the world state, mirroring Nethermind's IStateReader boundary.
 * Exposes only pure reads used by EVM and RPC: account (optional), code, storage, and presence check.
 */
export interface WorldStateReaderService {
  /** Read account data, returning null when the account is absent. */
  readonly getAccountOptional: (
    address: Address.AddressType,
  ) => Effect.Effect<AccountStateType | null>;
  /** True if an account exists (regardless of emptiness). */
  readonly hasAccount: (address: Address.AddressType) => Effect.Effect<boolean>;
  /** Read contract runtime code, returning empty code when unset. */
  readonly getCode: (
    address: Address.AddressType,
  ) => Effect.Effect<RuntimeCode.RuntimeCodeType>;
  /** Read storage value, returning zero for missing slots. */
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

const withWorldStateReader = <A, E>(
  f: (reader: WorldStateReaderService) => Effect.Effect<A, E>,
) => Effect.flatMap(WorldStateReader, f);

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

/** Read an optional account through the world-state reader boundary. */
export const getAccountOptional = (address: Address.AddressType) =>
  withWorldStateReader((reader) => reader.getAccountOptional(address));

/** Check account existence through the world-state reader boundary. */
export const hasAccount = (address: Address.AddressType) =>
  withWorldStateReader((reader) => reader.hasAccount(address));

/** Read runtime code through the world-state reader boundary. */
export const getCode = (address: Address.AddressType) =>
  withWorldStateReader((reader) => reader.getCode(address));

/** Read storage through the world-state reader boundary. */
export const getStorage = (
  address: Address.AddressType,
  slot: StorageSlotType,
) => withWorldStateReader((reader) => reader.getStorage(address, slot));
