import * as Context from "effect/Context";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import * as Schema from "effect/Schema";
import {
  BlockHash,
  BlockHeader,
  BlockNumber,
  Storage,
  StorageValue,
} from "voltaire-effect/primitives";
import { ReleaseSpec } from "../evm/ReleaseSpec";
import {
  type MissingAccountError,
  type WorldStateService,
  WorldState,
} from "../state/State";

/** Block header type used by the store. */
export type BlockHeaderType = BlockHeader.BlockHeaderType;
/** Block hash type stored in state. */
export type BlockHashType = BlockHash.BlockHashType;
/** Block number type for lookups. */
export type BlockNumberType = BlockNumber.BlockNumberType;

type StorageSlotType = Parameters<WorldStateService["setStorage"]>[1];
type StorageValueType = Parameters<WorldStateService["setStorage"]>[2];

const BlockHashSchema = BlockHash.Bytes as unknown as Schema.Schema<
  BlockHashType,
  Uint8Array
>;
const StorageSlotSchema = Storage.StorageSlotSchema as unknown as Schema.Schema<
  StorageSlotType,
  Uint8Array
>;
const StorageValueSchema =
  StorageValue.StorageValueSchema as unknown as Schema.Schema<
    StorageValueType,
    Uint8Array
  >;

/** Union of blockhash store errors. */
export type BlockhashStoreError = MissingAccountError;

/** Blockhash store service interface. */
export interface BlockhashStoreService {
  readonly applyBlockhashStateChanges: (
    header: BlockHeaderType,
  ) => Effect.Effect<void, BlockhashStoreError>;
  readonly getBlockhashFromState: (
    currentHeader: BlockHeaderType,
    number: BlockNumberType,
  ) => Effect.Effect<Option.Option<BlockHashType>, BlockhashStoreError>;
}

/** Context tag for the blockhash store service. */
export class BlockhashStore extends Context.Tag("BlockhashStore")<
  BlockhashStore,
  BlockhashStoreService
>() {}

const slotFromBigInt = (value: bigint): StorageSlotType => {
  const bytes = new Uint8Array(32);
  let remaining = value;
  for (let index = bytes.length - 1; index >= 0; index -= 1) {
    bytes[index] = Number(remaining & 0xffn);
    remaining >>= 8n;
  }
  return Schema.decodeSync(StorageSlotSchema)(bytes);
};

const toStorageValue = (hash: BlockHashType): StorageValueType =>
  Schema.decodeSync(StorageValueSchema)(hash as Uint8Array);

const toBlockHash = (value: StorageValueType): BlockHashType =>
  Schema.decodeSync(BlockHashSchema)(value as Uint8Array);

const isZeroValue = (value: StorageValueType): boolean => {
  const bytes = value as Uint8Array;
  for (let index = 0; index < bytes.length; index += 1) {
    if (bytes[index] !== 0) {
      return false;
    }
  }
  return true;
};

const makeBlockhashStore = Effect.gen(function* () {
  const worldState = yield* WorldState;
  const spec = yield* ReleaseSpec;

  const applyBlockhashStateChanges = (header: BlockHeaderType) =>
    Effect.gen(function* () {
      if (!spec.isEip2935Enabled) {
        return;
      }

      const currentNumber = header.number as bigint;
      if (currentNumber <= 0n) {
        return;
      }

      const address = spec.eip2935ContractAddress;
      const code = yield* worldState.getCode(address);
      if (code.length === 0) {
        return;
      }

      const account = yield* worldState.getAccountOptional(address);
      if (!account) {
        return;
      }

      const ringSize = spec.eip2935RingBufferSize;
      const index = (currentNumber - 1n) % ringSize;
      const slot = slotFromBigInt(index);
      const value = toStorageValue(header.parentHash);

      yield* worldState.setStorage(address, slot, value);
    });

  const getBlockhashFromState = (
    currentHeader: BlockHeaderType,
    number: BlockNumberType,
  ) =>
    Effect.gen(function* () {
      const currentNumber = currentHeader.number as bigint;
      const requestedNumber = number as bigint;
      const ringSize = spec.eip2935RingBufferSize;

      if (requestedNumber >= currentNumber) {
        return Option.none();
      }

      if (requestedNumber + ringSize < currentNumber) {
        return Option.none();
      }

      const address = spec.eip2935ContractAddress;
      const slot = slotFromBigInt(requestedNumber % ringSize);
      const value = yield* worldState.getStorage(address, slot);

      if (isZeroValue(value)) {
        return Option.none();
      }

      return Option.some(toBlockHash(value));
    });

  return {
    applyBlockhashStateChanges,
    getBlockhashFromState,
  } satisfies BlockhashStoreService;
});

/** Production blockhash store layer. */
export const BlockhashStoreLive: Layer.Layer<
  BlockhashStore,
  BlockhashStoreError,
  WorldState | ReleaseSpec
> = Layer.effect(BlockhashStore, makeBlockhashStore);

const withBlockhashStore = <A, E>(
  f: (service: BlockhashStoreService) => Effect.Effect<A, E>,
) => Effect.flatMap(BlockhashStore, f);

/** Apply EIP-2935 block hash state updates for a header. */
export const applyBlockhashStateChanges = (header: BlockHeaderType) =>
  withBlockhashStore((store) => store.applyBlockhashStateChanges(header));

/** Read a block hash from the EIP-2935 state ring buffer. */
export const getBlockhashFromState = (
  currentHeader: BlockHeaderType,
  number: BlockNumberType,
) =>
  withBlockhashStore((store) =>
    store.getBlockhashFromState(currentHeader, number),
  );
