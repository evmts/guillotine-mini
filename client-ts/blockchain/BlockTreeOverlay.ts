import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import {
  BLOCK_TREE_INSTANCE_ID,
  BlockTree,
  type BlockHashType,
  type BlockNumberType,
  type BlockTreeError,
  type BlockTreeService,
  type BlockType,
} from "./BlockTree";
import {
  ReadOnlyBlockTree,
  type ReadOnlyBlockTreeService,
} from "./ReadOnlyBlockTree";

/** Block tree overlay service (read-through base + write overlay). */
export interface BlockTreeOverlayService extends BlockTreeService {}

/** Error raised when base and overlay trees share the same backing instance. */
export class BlockTreeOverlaySharedStateError extends Data.TaggedError(
  "BlockTreeOverlaySharedStateError",
)<{
  readonly message: string;
}> {}

/** Context tag for the block tree overlay service. */
export class BlockTreeOverlay extends Context.Tag("BlockTreeOverlay")<
  BlockTreeOverlay,
  BlockTreeOverlayService
>() {}

const makeBlockTreeOverlay = Effect.gen(function* () {
  const baseTree = yield* ReadOnlyBlockTree;
  const overlayTree = yield* BlockTree;

  if (
    baseTree[BLOCK_TREE_INSTANCE_ID] === overlayTree[BLOCK_TREE_INSTANCE_ID]
  ) {
    return yield* Effect.fail(
      new BlockTreeOverlaySharedStateError({
        message:
          "BlockTreeOverlay requires isolated base and overlay block tree instances",
      }),
    );
  }

  return makeBlockTreeOverlayService(baseTree, overlayTree);
});

/** Build a block tree overlay service from base + overlay trees. */
export const makeBlockTreeOverlayService = (
  baseTree: ReadOnlyBlockTreeService,
  overlayTree: BlockTreeService,
): BlockTreeOverlayService => {
  const readThroughOption = <A>(
    overlay: Effect.Effect<Option.Option<A>, BlockTreeError>,
    base: () => Effect.Effect<Option.Option<A>, BlockTreeError>,
  ) =>
    Effect.gen(function* () {
      const overlayValue = yield* overlay;
      if (Option.isSome(overlayValue)) {
        return overlayValue;
      }
      return yield* base();
    });

  const readThroughBoolean = (
    overlay: Effect.Effect<boolean, BlockTreeError>,
    base: () => Effect.Effect<boolean, BlockTreeError>,
  ) =>
    Effect.gen(function* () {
      const overlayValue = yield* overlay;
      if (overlayValue) {
        return true;
      }
      return yield* base();
    });

  const getBlock = (hash: BlockHashType) =>
    readThroughOption(overlayTree.getBlock(hash), () =>
      baseTree.getBlock(hash),
    );

  const getBlockByNumber = (number: BlockNumberType) =>
    readThroughOption(overlayTree.getBlockByNumber(number), () =>
      baseTree.getBlockByNumber(number),
    );

  const getCanonicalHash = (number: BlockNumberType) =>
    readThroughOption(overlayTree.getCanonicalHash(number), () =>
      baseTree.getCanonicalHash(number),
    );

  const hasBlock = (hash: BlockHashType) =>
    readThroughBoolean(overlayTree.hasBlock(hash), () =>
      baseTree.hasBlock(hash),
    );

  const isOrphan = (hash: BlockHashType) =>
    readThroughBoolean(overlayTree.isOrphan(hash), () =>
      baseTree.isOrphan(hash),
    );

  const putBlock = (block: BlockType) => overlayTree.putBlock(block);

  const setCanonicalHead = (hash: BlockHashType) =>
    overlayTree.setCanonicalHead(hash);

  const getHeadBlockNumber = () =>
    readThroughOption(overlayTree.getHeadBlockNumber(), () =>
      baseTree.getHeadBlockNumber(),
    );

  const blockCount = () =>
    Effect.gen(function* () {
      const [overlayCount, baseCount] = yield* Effect.all([
        overlayTree.blockCount(),
        baseTree.blockCount(),
      ]);
      return overlayCount + baseCount;
    });

  const orphanCount = () =>
    Effect.gen(function* () {
      const [overlayCount, baseCount] = yield* Effect.all([
        overlayTree.orphanCount(),
        baseTree.orphanCount(),
      ]);
      return overlayCount + baseCount;
    });

  const canonicalChainLength = () =>
    Effect.gen(function* () {
      const [overlayLength, baseLength] = yield* Effect.all([
        overlayTree.canonicalChainLength(),
        baseTree.canonicalChainLength(),
      ]);
      return Math.max(overlayLength, baseLength);
    });

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
  } satisfies BlockTreeOverlayService;
};

/** Block tree overlay layer. */
export const BlockTreeOverlayLive: Layer.Layer<
  BlockTreeOverlay,
  BlockTreeOverlaySharedStateError,
  ReadOnlyBlockTree | BlockTree
> = Layer.effect(BlockTreeOverlay, makeBlockTreeOverlay);
