import * as Context from "effect/Context";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import * as Schema from "effect/Schema";
import {
  BlockHash,
  BlockHeader,
  BlockNumber,
  Hex,
} from "voltaire-effect/primitives";
import { MissingBlockhashError } from "./BlockhashErrors";
import {
  BlockTree,
  type BlockTreeError,
  BlockTreeMemoryTest,
} from "./BlockTree";

/** Block header type used by the cache. */
export type BlockHeaderType = BlockHeader.BlockHeaderType;
/** Block hash type cached for lookups. */
export type BlockHashType = BlockHash.BlockHashType;
/** Block number type used for depth calculations. */
export type BlockNumberType = BlockNumber.BlockNumberType;

const BlockNumberSchema = BlockNumber.BigInt as unknown as Schema.Schema<
  BlockNumberType,
  bigint
>;
const MAX_BLOCKHASH_DEPTH = 256n;
const CACHE_LIMIT = 32;

/** Union of blockhash cache errors. */
export type BlockhashCacheError = BlockTreeError | MissingBlockhashError;

/** Blockhash cache service interface. */
export interface BlockhashCacheService {
  readonly getHash: (
    currentHeader: BlockHeaderType,
    depth: number,
  ) => Effect.Effect<Option.Option<BlockHashType>, BlockhashCacheError>;
  readonly prefetch: (
    currentHeader: BlockHeaderType,
  ) => Effect.Effect<ReadonlyArray<BlockHashType>, BlockhashCacheError>;
}

/** Context tag for the blockhash cache service. */
export class BlockhashCache extends Context.Tag("BlockhashCache")<
  BlockhashCache,
  BlockhashCacheService
>() {}

const toBigInt = (value: BlockNumberType) =>
  Schema.encodeSync(BlockNumberSchema)(value);

const hashKey = (hash: BlockHashType): string => Hex.fromBytes(hash);

const makeBlockhashCache = Effect.gen(function* () {
  const blockTree = yield* BlockTree;
  const state = yield* Effect.acquireRelease(
    Effect.sync(() => new Map<string, ReadonlyArray<BlockHashType>>()),
    (cache) =>
      Effect.sync(() => {
        cache.clear();
      }),
  );

  const saveCache = (
    hash: BlockHashType,
    hashes: ReadonlyArray<BlockHashType>,
  ) =>
    Effect.sync(() => {
      const key = hashKey(hash);
      if (state.has(key)) {
        state.delete(key);
      }
      state.set(key, hashes);
      if (state.size > CACHE_LIMIT) {
        const oldest = state.keys().next().value as string | undefined;
        if (oldest) {
          state.delete(oldest);
        }
      }
    });

  const loadHashes = (currentHeader: BlockHeaderType) =>
    Effect.gen(function* () {
      const currentNumber = toBigInt(currentHeader.number);
      if (currentNumber <= 0n) {
        return [] as ReadonlyArray<BlockHashType>;
      }

      const cacheHit = state.get(hashKey(currentHeader.parentHash));
      if (cacheHit) {
        return cacheHit;
      }

      const maxDepth =
        currentNumber < MAX_BLOCKHASH_DEPTH
          ? currentNumber
          : MAX_BLOCKHASH_DEPTH;
      const maxDepthNumber = Number(maxDepth);
      const hashes: Array<BlockHashType> = [];
      let currentHash = currentHeader.parentHash;
      let cursorNumber = currentNumber - 1n;

      while (true) {
        hashes.push(currentHash);

        if (hashes.length >= maxDepthNumber || cursorNumber === 0n) {
          break;
        }

        const block = yield* blockTree.getBlock(currentHash);
        if (Option.isNone(block)) {
          return yield* Effect.fail(
            new MissingBlockhashError({
              missingHash: currentHash,
              missingNumber: cursorNumber,
            }),
          );
        }

        const ancestor = Option.getOrThrow(block);
        const ancestorNumber = toBigInt(ancestor.header.number);
        if (ancestorNumber !== cursorNumber) {
          return yield* Effect.fail(
            new MissingBlockhashError({
              missingHash: currentHash,
              missingNumber: cursorNumber,
            }),
          );
        }

        currentHash = ancestor.header.parentHash;
        cursorNumber -= 1n;
      }

      yield* saveCache(currentHeader.parentHash, hashes);
      return hashes;
    });

  const getHash = (currentHeader: BlockHeaderType, depth: number) =>
    Effect.gen(function* () {
      if (depth <= 0 || BigInt(depth) > MAX_BLOCKHASH_DEPTH) {
        return Option.none();
      }

      if (depth === 1) {
        return Option.some(currentHeader.parentHash);
      }

      const hashes = yield* loadHashes(currentHeader);
      const index = depth - 1;
      if (index >= hashes.length) {
        return Option.none();
      }

      return Option.some(hashes[index]!);
    });

  const prefetch = (currentHeader: BlockHeaderType) =>
    Effect.gen(function* () {
      const hashes = yield* loadHashes(currentHeader);
      return hashes;
    });

  return {
    getHash,
    prefetch,
  } satisfies BlockhashCacheService;
});

/** Production blockhash cache layer. */
export const BlockhashCacheLive: Layer.Layer<
  BlockhashCache,
  BlockhashCacheError,
  BlockTree
> = Layer.scoped(BlockhashCache, makeBlockhashCache);

/** Deterministic blockhash cache layer for tests. */
export const BlockhashCacheTest =
  Layer.provideMerge(BlockTreeMemoryTest)(BlockhashCacheLive);

const withBlockhashCache = <A, E>(
  f: (service: BlockhashCacheService) => Effect.Effect<A, E>,
) => Effect.flatMap(BlockhashCache, f);

/** Retrieve a cached block hash at a given depth. */
export const getHash = (currentHeader: BlockHeaderType, depth: number) =>
  withBlockhashCache((cache) => cache.getHash(currentHeader, depth));

/** Prefetch and cache hashes for the last 256 blocks. */
export const prefetch = (currentHeader: BlockHeaderType) =>
  withBlockhashCache((cache) => cache.prefetch(currentHeader));
