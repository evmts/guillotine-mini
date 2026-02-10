import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import * as Schema from "effect/Schema";
import { Block, BlockHash, BlockNumber, Hex } from "voltaire-effect/primitives";
import {
  BlockStore,
  type BlockStoreError,
  BlockStoreMemoryLive,
  BlockStoreMemoryTest,
  InvalidBlockHashError,
} from "./BlockStore";

/** Block type handled by the block tree. */
export type BlockType = Block.BlockType;
/** Hash type for identifying blocks. */
export type BlockHashType = BlockHash.BlockHashType;
/** Block number type used for canonical indexing. */
export type BlockNumberType = BlockNumber.BlockNumberType;

type BlockHashKey = string;
type BlockNumberKey = bigint;

type BlockTreeState = {
  readonly canonicalChain: Map<BlockNumberKey, BlockHashType>;
  readonly orphans: Set<BlockHashKey>;
  readonly orphansByParent: Map<BlockHashKey, Set<BlockHashKey>>;
};

const BlockHashSchema = BlockHash.Bytes as unknown as Schema.Schema<
  BlockHashType,
  Uint8Array
>;
const BlockNumberSchema = BlockNumber.BigInt as unknown as Schema.Schema<
  BlockNumberType,
  bigint
>;

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

/** Union of block tree errors. */
export type BlockTreeError =
  | BlockStoreError
  | InvalidBlockNumberError
  | BlockNotFoundError
  | CannotSetOrphanAsHeadError;

/** Block tree service interface (canonical chain + orphan tracking). */
export interface BlockTreeService {
  readonly getBlock: (
    hash: BlockHashType,
  ) => Effect.Effect<Option.Option<BlockType>, BlockTreeError>;
  readonly getBlockByNumber: (
    number: BlockNumberType,
  ) => Effect.Effect<Option.Option<BlockType>, BlockTreeError>;
  readonly getCanonicalHash: (
    number: BlockNumberType,
  ) => Effect.Effect<Option.Option<BlockHashType>, BlockTreeError>;
  readonly hasBlock: (
    hash: BlockHashType,
  ) => Effect.Effect<boolean, BlockTreeError>;
  readonly isOrphan: (
    hash: BlockHashType,
  ) => Effect.Effect<boolean, BlockTreeError>;
  readonly putBlock: (block: BlockType) => Effect.Effect<void, BlockTreeError>;
  readonly setCanonicalHead: (
    hash: BlockHashType,
  ) => Effect.Effect<void, BlockTreeError>;
  readonly getHeadBlockNumber: () => Effect.Effect<
    Option.Option<BlockNumberType>
  >;
  readonly blockCount: () => Effect.Effect<number>;
  readonly orphanCount: () => Effect.Effect<number>;
  readonly canonicalChainLength: () => Effect.Effect<number>;
}

/** Context tag for the block tree service. */
export class BlockTree extends Context.Tag("BlockTree")<
  BlockTree,
  BlockTreeService
>() {}

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

const makeBlockTree = Effect.gen(function* () {
  const store = yield* BlockStore;
  const state = yield* Effect.acquireRelease(
    Effect.sync(
      () =>
        ({
          canonicalChain: new Map<BlockNumberKey, BlockHashType>(),
          orphans: new Set<BlockHashKey>(),
          orphansByParent: new Map<BlockHashKey, Set<BlockHashKey>>(),
        }) satisfies BlockTreeState,
    ),
    (tree) =>
      Effect.sync(() => {
        tree.canonicalChain.clear();
        tree.orphans.clear();
        tree.orphansByParent.clear();
      }),
  );

  const resolveOrphans = (parentHash: BlockHashType) =>
    Effect.sync(() => {
      const queue: Array<BlockHashKey> = [blockHashKey(parentHash)];

      for (let index = 0; index < queue.length; index += 1) {
        const parentKey = queue[index]!;
        const children = state.orphansByParent.get(parentKey);
        if (!children) {
          continue;
        }

        state.orphansByParent.delete(parentKey);
        for (const orphanKey of children) {
          state.orphans.delete(orphanKey);
          queue.push(orphanKey);
        }
      }
    });

  const getBlock = (hash: BlockHashType) => store.getBlock(hash);

  const getBlockByNumber = (number: BlockNumberType) =>
    Effect.gen(function* () {
      const validated = yield* decodeBlockNumber(number);
      const canonical = state.canonicalChain.get(blockNumberKey(validated));
      if (!canonical) {
        return Option.none();
      }
      return yield* store.getBlock(canonical);
    });

  const getCanonicalHash = (number: BlockNumberType) =>
    Effect.gen(function* () {
      const validated = yield* decodeBlockNumber(number);
      return Option.fromNullable(
        state.canonicalChain.get(blockNumberKey(validated)),
      );
    });

  const hasBlock = (hash: BlockHashType) => store.hasBlock(hash);

  const isOrphan = (hash: BlockHashType) =>
    Effect.gen(function* () {
      const validated = yield* decodeBlockHash(hash);
      return state.orphans.has(blockHashKey(validated));
    });

  const putBlock = (block: BlockType) =>
    Effect.gen(function* () {
      const exists = yield* store.hasBlock(block.hash);
      if (exists) {
        return;
      }

      const blockNumber = yield* decodeBlockNumber(block.header.number);
      const blockKey = blockHashKey(block.hash);
      const parentKey = blockHashKey(block.header.parentHash);
      const isGenesis = blockNumberKey(blockNumber) === 0n;
      const hasParent = yield* store.hasBlock(block.header.parentHash);

      if (!isGenesis && !hasParent) {
        state.orphans.add(blockKey);
        const children = state.orphansByParent.get(parentKey) ?? new Set();
        children.add(blockKey);
        state.orphansByParent.set(parentKey, children);
      }

      yield* store.putBlock(block);

      if (!state.orphans.has(blockKey)) {
        yield* resolveOrphans(block.hash);
      }
    });

  const buildCanonicalEntries = (head: BlockType) =>
    Effect.gen(function* () {
      const entries: Array<{
        readonly numberKey: BlockNumberKey;
        readonly hash: BlockHashType;
      }> = [];
      let currentBlock = head;
      let currentNumber = blockNumberKey(currentBlock.header.number);

      while (true) {
        entries.push({
          numberKey: currentNumber,
          hash: currentBlock.hash,
        });

        if (currentNumber === 0n) {
          break;
        }

        const parentBlock = yield* store.getBlock(
          currentBlock.header.parentHash,
        );
        if (Option.isNone(parentBlock)) {
          return yield* Effect.fail(
            new BlockNotFoundError({ hash: currentBlock.header.parentHash }),
          );
        }

        currentBlock = Option.getOrThrow(parentBlock);
        currentNumber -= 1n;
      }

      return entries;
    });

  const setCanonicalHead = (hash: BlockHashType) =>
    Effect.gen(function* () {
      const validated = yield* decodeBlockHash(hash);
      const headKey = blockHashKey(validated);
      const headBlock = yield* store.getBlock(validated);

      if (Option.isNone(headBlock)) {
        return yield* Effect.fail(new BlockNotFoundError({ hash: validated }));
      }

      if (state.orphans.has(headKey)) {
        return yield* Effect.fail(
          new CannotSetOrphanAsHeadError({ hash: validated }),
        );
      }

      const entries = yield* buildCanonicalEntries(
        Option.getOrThrow(headBlock),
      );

      state.canonicalChain.clear();
      for (const entry of entries) {
        state.canonicalChain.set(entry.numberKey, entry.hash);
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

  const blockCount = () => store.blockCount();

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
  } satisfies BlockTreeService;
});

/** In-memory production block tree layer. */
export const BlockTreeMemoryLive: Layer.Layer<BlockTree, BlockTreeError> =
  Layer.provide(Layer.scoped(BlockTree, makeBlockTree), BlockStoreMemoryLive);

/** In-memory deterministic block tree layer for tests. */
export const BlockTreeMemoryTest: Layer.Layer<BlockTree, BlockTreeError> =
  Layer.provide(Layer.scoped(BlockTree, makeBlockTree), BlockStoreMemoryTest);

const withBlockTree = <A, E, R>(
  f: (service: BlockTreeService) => Effect.Effect<A, E, R>,
) => Effect.flatMap(BlockTree, f);

/** Retrieve a block by hash. */
export const getBlock = (hash: BlockHashType) =>
  withBlockTree((tree) => tree.getBlock(hash));

/** Retrieve a canonical block by number. */
export const getBlockByNumber = (number: BlockNumberType) =>
  withBlockTree((tree) => tree.getBlockByNumber(number));

/** Retrieve the canonical hash for a block number. */
export const getCanonicalHash = (number: BlockNumberType) =>
  withBlockTree((tree) => tree.getCanonicalHash(number));

/** Check whether a block exists by hash. */
export const hasBlock = (hash: BlockHashType) =>
  withBlockTree((tree) => tree.hasBlock(hash));

/** Check whether a block is currently orphaned. */
export const isOrphan = (hash: BlockHashType) =>
  withBlockTree((tree) => tree.isOrphan(hash));

/** Put a block into local storage. */
export const putBlock = (block: BlockType) =>
  withBlockTree((tree) => tree.putBlock(block));

/** Set the canonical head hash. */
export const setCanonicalHead = (hash: BlockHashType) =>
  withBlockTree((tree) => tree.setCanonicalHead(hash));

/** Get the highest canonical block number. */
export const getHeadBlockNumber = () =>
  withBlockTree((tree) => tree.getHeadBlockNumber());

/** Get the total count of stored blocks. */
export const blockCount = () => withBlockTree((tree) => tree.blockCount());

/** Get the total count of orphaned blocks. */
export const orphanCount = () => withBlockTree((tree) => tree.orphanCount());

/** Get the length of the canonical chain. */
export const canonicalChainLength = () =>
  withBlockTree((tree) => tree.canonicalChainLength());
