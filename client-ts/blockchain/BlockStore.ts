import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import * as Schema from "effect/Schema";
import { Block, BlockHash, BlockNumber, Hex } from "voltaire-effect/primitives";

/** Block type handled by the block store. */
export type BlockType = Block.BlockType;
/** Hash type for identifying blocks. */
export type BlockHashType = BlockHash.BlockHashType;
/** Block number type used for canonical indexing. */
export type BlockNumberType = BlockNumber.BlockNumberType;

type BlockHashKey = string;
type BlockNumberKey = bigint;

const BlockSchema = Block.Schema as unknown as Schema.Schema<
  BlockType,
  unknown
>;
const BlockHashSchema = BlockHash.Bytes as unknown as Schema.Schema<
  BlockHashType,
  Uint8Array
>;
const BlockNumberSchema = BlockNumber.BigInt as unknown as Schema.Schema<
  BlockNumberType,
  bigint
>;

/** Error raised when a block fails validation. */
export class InvalidBlockError extends Data.TaggedError("InvalidBlockError")<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Error raised when a block hash is invalid. */
export class InvalidBlockHashError extends Data.TaggedError(
  "InvalidBlockHashError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Error raised when a block number is invalid. */
export class InvalidBlockNumberError extends Data.TaggedError(
  "InvalidBlockNumberError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Error raised when setting canonical head with a missing block. */
export class BlockNotFoundError extends Data.TaggedError("BlockNotFoundError")<{
  readonly hash: BlockHashType;
}> {}

/** Error raised when attempting to set an orphan block as canonical head. */
export class CannotSetOrphanAsHeadError extends Data.TaggedError(
  "CannotSetOrphanAsHeadError",
)<{
  readonly hash: BlockHashType;
}> {}

/** Union of block store errors. */
export type BlockStoreError =
  | InvalidBlockError
  | InvalidBlockHashError
  | InvalidBlockNumberError
  | BlockNotFoundError
  | CannotSetOrphanAsHeadError;

/** Block store service interface (local block storage + canonical chain). */
export interface BlockStoreService {
  readonly getBlock: (
    hash: BlockHashType,
  ) => Effect.Effect<Option.Option<BlockType>, BlockStoreError>;
  readonly getBlockByNumber: (
    number: BlockNumberType,
  ) => Effect.Effect<Option.Option<BlockType>, BlockStoreError>;
  readonly getCanonicalHash: (
    number: BlockNumberType,
  ) => Effect.Effect<Option.Option<BlockHashType>, BlockStoreError>;
  readonly hasBlock: (
    hash: BlockHashType,
  ) => Effect.Effect<boolean, BlockStoreError>;
  readonly isOrphan: (
    hash: BlockHashType,
  ) => Effect.Effect<boolean, BlockStoreError>;
  readonly putBlock: (block: BlockType) => Effect.Effect<void, BlockStoreError>;
  readonly setCanonicalHead: (
    hash: BlockHashType,
  ) => Effect.Effect<void, BlockStoreError>;
  readonly getHeadBlockNumber: () => Effect.Effect<
    Option.Option<BlockNumberType>
  >;
  readonly blockCount: () => Effect.Effect<number>;
  readonly orphanCount: () => Effect.Effect<number>;
  readonly canonicalChainLength: () => Effect.Effect<number>;
}

/** Context tag for the block store service. */
export class BlockStore extends Context.Tag("BlockStore")<
  BlockStore,
  BlockStoreService
>() {}

const decodeBlock = (block: BlockType) =>
  Schema.decode(BlockSchema)(block).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidBlockError({
          message: "Invalid block",
          cause,
        }),
    ),
  );

const decodeBlockHash = (hash: BlockHashType) =>
  Schema.decode(BlockHashSchema)(hash).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidBlockHashError({
          message: "Invalid block hash",
          cause,
        }),
    ),
  );

const decodeBlockNumber = (number: BlockNumberType) =>
  Schema.decode(BlockNumberSchema)(number).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidBlockNumberError({
          message: "Invalid block number",
          cause,
        }),
    ),
  );

const blockHashKey = (hash: BlockHashType): BlockHashKey => Hex.fromBytes(hash);

const blockNumberKey = (number: BlockNumberType): BlockNumberKey =>
  number as bigint;

const makeBlockStore = Effect.gen(function* () {
  const state = yield* Effect.acquireRelease(
    Effect.sync(() => ({
      blocks: new Map<BlockHashKey, BlockType>(),
      canonicalChain: new Map<BlockNumberKey, BlockHashType>(),
      orphans: new Set<BlockHashKey>(),
    })),
    (store) =>
      Effect.sync(() => {
        store.blocks.clear();
        store.canonicalChain.clear();
        store.orphans.clear();
      }),
  );

  const resolveOrphans = (parentHash: BlockHashType) =>
    Effect.sync(() => {
      const queue: Array<BlockHashKey> = [blockHashKey(parentHash)];

      for (let index = 0; index < queue.length; index += 1) {
        const parentKey = queue[index];
        const resolved: Array<BlockHashKey> = [];

        for (const orphanKey of state.orphans) {
          const orphanBlock = state.blocks.get(orphanKey);
          if (!orphanBlock) {
            continue;
          }
          const orphanParentKey = blockHashKey(orphanBlock.header.parentHash);
          if (orphanParentKey === parentKey) {
            resolved.push(orphanKey);
            queue.push(blockHashKey(orphanBlock.hash));
          }
        }

        for (const orphanKey of resolved) {
          state.orphans.delete(orphanKey);
        }
      }
    });

  const getBlock = (hash: BlockHashType) =>
    Effect.gen(function* () {
      const validated = yield* decodeBlockHash(hash);
      return Option.fromNullable(state.blocks.get(blockHashKey(validated)));
    });

  const getBlockByNumber = (number: BlockNumberType) =>
    Effect.gen(function* () {
      const validated = yield* decodeBlockNumber(number);
      const canonical = state.canonicalChain.get(blockNumberKey(validated));
      return pipe(
        Option.fromNullable(canonical),
        Option.flatMap((hash) =>
          Option.fromNullable(state.blocks.get(blockHashKey(hash))),
        ),
      );
    });

  const getCanonicalHash = (number: BlockNumberType) =>
    Effect.gen(function* () {
      const validated = yield* decodeBlockNumber(number);
      return Option.fromNullable(
        state.canonicalChain.get(blockNumberKey(validated)),
      );
    });

  const hasBlock = (hash: BlockHashType) =>
    Effect.gen(function* () {
      const validated = yield* decodeBlockHash(hash);
      return state.blocks.has(blockHashKey(validated));
    });

  const isOrphan = (hash: BlockHashType) =>
    Effect.gen(function* () {
      const validated = yield* decodeBlockHash(hash);
      return state.orphans.has(blockHashKey(validated));
    });

  const putBlock = (block: BlockType) =>
    Effect.gen(function* () {
      const validated = yield* decodeBlock(block);
      const blockHash = validated.hash;
      const blockKey = blockHashKey(blockHash);

      if (state.blocks.has(blockKey)) {
        return;
      }

      const blockNumber = yield* decodeBlockNumber(validated.header.number);
      const parentKey = blockHashKey(validated.header.parentHash);
      const isGenesis = blockNumberKey(blockNumber) === 0n;
      const hasParent = state.blocks.has(parentKey);

      if (!isGenesis && !hasParent) {
        state.orphans.add(blockKey);
      }

      state.blocks.set(blockKey, validated);

      if (!state.orphans.has(blockKey)) {
        yield* resolveOrphans(blockHash);
      }
    });

  const setCanonicalHead = (hash: BlockHashType) =>
    Effect.gen(function* () {
      const validated = yield* decodeBlockHash(hash);
      const headKey = blockHashKey(validated);
      const headBlock = state.blocks.get(headKey);

      if (!headBlock) {
        return yield* Effect.fail(new BlockNotFoundError({ hash: validated }));
      }

      if (state.orphans.has(headKey)) {
        return yield* Effect.fail(
          new CannotSetOrphanAsHeadError({ hash: validated }),
        );
      }

      let currentHash = validated;
      let currentNumber = blockNumberKey(headBlock.header.number);

      for (const number of state.canonicalChain.keys()) {
        if (number > currentNumber) {
          state.canonicalChain.delete(number);
        }
      }

      while (true) {
        state.canonicalChain.set(currentNumber, currentHash);

        if (currentNumber === 0n) {
          break;
        }

        const currentBlock = state.blocks.get(blockHashKey(currentHash));
        if (!currentBlock) {
          break;
        }

        currentHash = currentBlock.header.parentHash;
        currentNumber -= 1n;
      }
    });

  const getHeadBlockNumber = () =>
    Effect.sync(() => {
      let max: BlockNumberKey | null = null;

      for (const number of state.canonicalChain.keys()) {
        if (max === null || number > max) {
          max = number;
        }
      }

      return pipe(
        Option.fromNullable(max),
        Option.map((value) => value as BlockNumberType),
      );
    });

  const blockCount = () => Effect.sync(() => state.blocks.size);

  const orphanCount = () => Effect.sync(() => state.orphans.size);

  const canonicalChainLength = () =>
    Effect.sync(() => state.canonicalChain.size);

  return {
    getBlock,
    getBlockByNumber,
    getCanonicalHash,
    hasBlock,
    isOrphan,
    putBlock,
    setCanonicalHead,
    getHeadBlockNumber,
    blockCount,
    orphanCount,
    canonicalChainLength,
  } satisfies BlockStoreService;
});

/** In-memory production block store layer. */
export const BlockStoreMemoryLive: Layer.Layer<BlockStore, BlockStoreError> =
  Layer.scoped(BlockStore, makeBlockStore);

/** In-memory deterministic block store layer for tests. */
export const BlockStoreMemoryTest: Layer.Layer<BlockStore, BlockStoreError> =
  Layer.scoped(BlockStore, makeBlockStore);

const withBlockStore = <A, E, R>(
  f: (service: BlockStoreService) => Effect.Effect<A, E, R>,
) => Effect.flatMap(BlockStore, f);

/** Retrieve a block by hash. */
export const getBlock = (hash: BlockHashType) =>
  withBlockStore((store) => store.getBlock(hash));

/** Retrieve a canonical block by number. */
export const getBlockByNumber = (number: BlockNumberType) =>
  withBlockStore((store) => store.getBlockByNumber(number));

/** Retrieve the canonical hash for a block number. */
export const getCanonicalHash = (number: BlockNumberType) =>
  withBlockStore((store) => store.getCanonicalHash(number));

/** Check whether a block exists by hash. */
export const hasBlock = (hash: BlockHashType) =>
  withBlockStore((store) => store.hasBlock(hash));

/** Check whether a block is currently orphaned. */
export const isOrphan = (hash: BlockHashType) =>
  withBlockStore((store) => store.isOrphan(hash));

/** Put a block into local storage. */
export const putBlock = (block: BlockType) =>
  withBlockStore((store) => store.putBlock(block));

/** Set the canonical head hash. */
export const setCanonicalHead = (hash: BlockHashType) =>
  withBlockStore((store) => store.setCanonicalHead(hash));

/** Get the highest canonical block number. */
export const getHeadBlockNumber = () =>
  withBlockStore((store) => store.getHeadBlockNumber());

/** Get the total count of stored blocks. */
export const blockCount = () => withBlockStore((store) => store.blockCount());

/** Get the total count of orphaned blocks. */
export const orphanCount = () => withBlockStore((store) => store.orphanCount());

/** Get the length of the canonical chain. */
export const canonicalChainLength = () =>
  withBlockStore((store) => store.canonicalChainLength());
