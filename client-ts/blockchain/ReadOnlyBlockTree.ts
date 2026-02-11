import * as Context from "effect/Context";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import {
  BLOCK_TREE_INSTANCE_ID,
  BlockTree,
  type BlockHashType,
  type BlockNumberType,
  type BlockTreeError,
  BlockTreeMemoryTest,
  type BlockType,
} from "./BlockTree";

/** Read-only block tree service interface. */
export interface ReadOnlyBlockTreeService {
  readonly [BLOCK_TREE_INSTANCE_ID]: symbol;
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
  readonly getHeadBlockNumber: () => Effect.Effect<
    Option.Option<BlockNumberType>
  >;
  readonly blockCount: () => Effect.Effect<number>;
  readonly orphanCount: () => Effect.Effect<number>;
  readonly canonicalChainLength: () => Effect.Effect<number>;
}

/** Context tag for the read-only block tree service. */
export class ReadOnlyBlockTree extends Context.Tag("ReadOnlyBlockTree")<
  ReadOnlyBlockTree,
  ReadOnlyBlockTreeService
>() {}

const makeReadOnlyBlockTree = Effect.gen(function* () {
  const blockTree = yield* BlockTree;

  return {
    [BLOCK_TREE_INSTANCE_ID]: blockTree[BLOCK_TREE_INSTANCE_ID],
    getBlock: (hash) => blockTree.getBlock(hash),
    getBlockByNumber: (number) => blockTree.getBlockByNumber(number),
    getCanonicalHash: (number) => blockTree.getCanonicalHash(number),
    hasBlock: (hash) => blockTree.hasBlock(hash),
    isOrphan: (hash) => blockTree.isOrphan(hash),
    getHeadBlockNumber: () => blockTree.getHeadBlockNumber(),
    blockCount: () => blockTree.blockCount(),
    orphanCount: () => blockTree.orphanCount(),
    canonicalChainLength: () => blockTree.canonicalChainLength(),
  } satisfies ReadOnlyBlockTreeService;
});

/** Read-only block tree layer. */
export const ReadOnlyBlockTreeLive: Layer.Layer<
  ReadOnlyBlockTree,
  never,
  BlockTree
> = Layer.effect(ReadOnlyBlockTree, makeReadOnlyBlockTree);

/** Deterministic read-only block tree layer for tests. */
export const ReadOnlyBlockTreeTest: Layer.Layer<
  ReadOnlyBlockTree | BlockTree,
  BlockTreeError
> = Layer.provideMerge(BlockTreeMemoryTest)(ReadOnlyBlockTreeLive);

const withReadOnlyBlockTree = <A, E, R>(
  f: (service: ReadOnlyBlockTreeService) => Effect.Effect<A, E, R>,
) => Effect.flatMap(ReadOnlyBlockTree, f);

/** Retrieve a block by hash from the read-only view. */
export const getBlock = (hash: BlockHashType) =>
  withReadOnlyBlockTree((service) => service.getBlock(hash));

/** Retrieve a canonical block by number from the read-only view. */
export const getBlockByNumber = (number: BlockNumberType) =>
  withReadOnlyBlockTree((service) => service.getBlockByNumber(number));

/** Retrieve a canonical hash by number from the read-only view. */
export const getCanonicalHash = (number: BlockNumberType) =>
  withReadOnlyBlockTree((service) => service.getCanonicalHash(number));

/** Check block existence from the read-only view. */
export const hasBlock = (hash: BlockHashType) =>
  withReadOnlyBlockTree((service) => service.hasBlock(hash));

/** Check orphan status from the read-only view. */
export const isOrphan = (hash: BlockHashType) =>
  withReadOnlyBlockTree((service) => service.isOrphan(hash));

/** Retrieve current canonical head number from the read-only view. */
export const getHeadBlockNumber = () =>
  withReadOnlyBlockTree((service) => service.getHeadBlockNumber());

/** Retrieve total block count from the read-only view. */
export const blockCount = () =>
  withReadOnlyBlockTree((service) => service.blockCount());

/** Retrieve orphan count from the read-only view. */
export const orphanCount = () =>
  withReadOnlyBlockTree((service) => service.orphanCount());

/** Retrieve canonical chain length from the read-only view. */
export const canonicalChainLength = () =>
  withReadOnlyBlockTree((service) => service.canonicalChainLength());
