import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import * as Ref from "effect/Ref";
import * as Schema from "effect/Schema";
import {
  BlockHash,
  BlockHeader,
  BlockNumber,
  Hex,
} from "voltaire-effect/primitives";
import { ReleaseSpec } from "../evm/ReleaseSpec";
import {
  BlockhashCache,
  type BlockhashCacheError,
  BlockhashCacheTest,
} from "./BlockhashCache";
import {
  BlockhashStore,
  type BlockhashStoreError,
  BlockhashStoreLive,
} from "./BlockhashStore";
import { WorldStateTest } from "../state/State";

/** Block header type used by the blockhash provider. */
export type BlockHeaderType = BlockHeader.BlockHeaderType;
/** Block hash type returned by the provider. */
export type BlockHashType = BlockHash.BlockHashType;
/** Block number type used for hash lookups. */
export type BlockNumberType = BlockNumber.BlockNumberType;

const BlockNumberSchema = BlockNumber.BigInt as unknown as Schema.Schema<
  BlockNumberType,
  bigint
>;
const MAX_BLOCKHASH_DEPTH = 256n;

/** Error raised when a block number is invalid. */
export class InvalidBlockhashNumberError extends Data.TaggedError(
  "InvalidBlockhashNumberError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Union of blockhash provider errors. */
export type BlockhashProviderError =
  | BlockhashCacheError
  | BlockhashStoreError
  | InvalidBlockhashNumberError;

/** Blockhash provider service interface. */
export interface BlockhashProviderService {
  readonly getBlockhash: (
    currentHeader: BlockHeaderType,
    number: BlockNumberType,
  ) => Effect.Effect<Option.Option<BlockHashType>, BlockhashProviderError>;
  readonly getLast256BlockHashes: (
    currentHeader: BlockHeaderType,
  ) => Effect.Effect<ReadonlyArray<BlockHashType>, BlockhashProviderError>;
  readonly prefetch: (
    currentHeader: BlockHeaderType,
  ) => Effect.Effect<void, BlockhashProviderError>;
}

/** Context tag for the blockhash provider service. */
export class BlockhashProvider extends Context.Tag("BlockhashProvider")<
  BlockhashProvider,
  BlockhashProviderService
>() {}

const decodeBlockNumber = (number: BlockNumberType, label: string) =>
  Schema.decode(BlockNumberSchema)(number).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidBlockhashNumberError({
          message: `Invalid ${label} block number`,
          cause,
        }),
    ),
  );

const toBigInt = (number: BlockNumberType) =>
  Schema.encodeSync(BlockNumberSchema)(number);

type PrefetchState = {
  readonly key: string;
  readonly hashes: ReadonlyArray<BlockHashType>;
};

const hashKey = (hash: BlockHashType): string => Hex.fromBytes(hash);

const makeBlockhashProvider = Effect.gen(function* () {
  const cache = yield* BlockhashCache;
  const store = yield* BlockhashStore;
  const spec = yield* ReleaseSpec;
  const prefetched = yield* Ref.make<Option.Option<PrefetchState>>(
    Option.none(),
  );

  const readPrefetched = (currentHeader: BlockHeaderType) =>
    Effect.gen(function* () {
      const state = yield* Ref.get(prefetched);
      if (Option.isNone(state)) {
        return Option.none<ReadonlyArray<BlockHashType>>();
      }

      const cached = Option.getOrThrow(state);
      if (cached.key !== hashKey(currentHeader.parentHash)) {
        return Option.none<ReadonlyArray<BlockHashType>>();
      }

      return Option.some(cached.hashes);
    });

  const prefetch = (currentHeader: BlockHeaderType) =>
    Effect.gen(function* () {
      const hashes = yield* cache.prefetch(currentHeader);
      yield* Ref.set(
        prefetched,
        Option.some({
          key: hashKey(currentHeader.parentHash),
          hashes,
        }),
      );
    });

  const getBlockhash = (
    currentHeader: BlockHeaderType,
    number: BlockNumberType,
  ) =>
    Effect.gen(function* () {
      const currentNumberType = yield* decodeBlockNumber(
        currentHeader.number,
        "current",
      );
      const requestedNumberType = yield* decodeBlockNumber(number, "requested");

      const currentNumber = toBigInt(currentNumberType);
      const requestedNumber = toBigInt(requestedNumberType);

      if (requestedNumber >= currentNumber) {
        return Option.none();
      }

      const depth = currentNumber - requestedNumber;
      if (depth > MAX_BLOCKHASH_DEPTH) {
        return Option.none();
      }

      if (spec.isBlockHashInStateAvailable) {
        return yield* store.getBlockhashFromState(
          currentHeader,
          requestedNumberType,
        );
      }

      if (depth === 1n) {
        return Option.some(currentHeader.parentHash);
      }

      const cached = yield* readPrefetched(currentHeader);
      if (Option.isSome(cached)) {
        const hashes = Option.getOrThrow(cached);
        const index = Number(depth - 1n);
        if (index < hashes.length) {
          return Option.some(hashes[index]!);
        }
      }

      return yield* cache.getHash(currentHeader, Number(depth));
    });

  const getLast256BlockHashes = (currentHeader: BlockHeaderType) =>
    Effect.gen(function* () {
      const currentNumberType = yield* decodeBlockNumber(
        currentHeader.number,
        "current",
      );
      const currentNumber = toBigInt(currentNumberType);

      if (currentNumber <= 0n) {
        return [];
      }

      const cached = yield* readPrefetched(currentHeader);
      const hashes = Option.isSome(cached)
        ? Option.getOrThrow(cached)
        : yield* cache.prefetch(currentHeader);

      return [...hashes].reverse();
    });

  return {
    getBlockhash,
    getLast256BlockHashes,
    prefetch,
  } satisfies BlockhashProviderService;
});

/** Production blockhash provider layer. */
export const BlockhashProviderLive: Layer.Layer<
  BlockhashProvider,
  BlockhashProviderError,
  BlockhashCache | BlockhashStore | ReleaseSpec
> = Layer.effect(BlockhashProvider, makeBlockhashProvider);

/** Deterministic blockhash provider layer for tests. */
export const BlockhashProviderTest = Layer.provideMerge(BlockhashCacheTest)(
  BlockhashProviderLive.pipe(
    Layer.provideMerge(BlockhashStoreLive.pipe(Layer.provide(WorldStateTest))),
  ),
);

const withBlockhashProvider = <A, E>(
  f: (service: BlockhashProviderService) => Effect.Effect<A, E>,
) => Effect.flatMap(BlockhashProvider, f);

/** Retrieve a recent block hash for BLOCKHASH semantics. */
export const getBlockhash = (
  currentHeader: BlockHeaderType,
  number: BlockNumberType,
) =>
  withBlockhashProvider((service) =>
    service.getBlockhash(currentHeader, number),
  );

/** Retrieve ordered block hashes for the last 256 blocks. */
export const getLast256BlockHashes = (currentHeader: BlockHeaderType) =>
  withBlockhashProvider((service) =>
    service.getLast256BlockHashes(currentHeader),
  );

/** Prefetch block hashes for the last 256 blocks. */
export const prefetch = (currentHeader: BlockHeaderType) =>
  withBlockhashProvider((service) => service.prefetch(currentHeader));

export { MissingBlockhashError } from "./BlockhashErrors";
