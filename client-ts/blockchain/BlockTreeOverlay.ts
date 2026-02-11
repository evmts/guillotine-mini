import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import * as Schema from "effect/Schema";
import { BlockNumber, Hex } from "voltaire-effect/primitives";
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

const BlockNumberBigIntSchema = BlockNumber.BigInt as unknown as Schema.Schema<
  BlockNumberType,
  bigint
>;

const blockNumberToBigInt = (number: BlockNumberType) =>
  Schema.encodeSync(BlockNumberBigIntSchema)(number);

const blockNumberFromBigInt = (number: bigint): BlockNumberType =>
  Schema.decodeSync(BlockNumberBigIntSchema)(number);

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
  const trackedOverlayHashes = new Map<string, BlockHashType>();

  const rememberOverlayHash = (hash: BlockHashType) =>
    Effect.sync(() => {
      trackedOverlayHashes.set(Hex.fromBytes(hash), hash);
    });

  const materializeAncestryFromBase = (
    hash: BlockHashType,
    visited = new Set<string>(),
  ) =>
    Effect.gen(function* () {
      const hashHex = Hex.fromBytes(hash);
      if (visited.has(hashHex)) {
        return;
      }
      visited.add(hashHex);

      const presentInOverlay = yield* overlayTree.hasBlock(hash);
      if (presentInOverlay) {
        yield* rememberOverlayHash(hash);
        return;
      }

      const blockInBase = yield* baseTree.getBlock(hash);
      if (Option.isNone(blockInBase)) {
        return;
      }

      const block = Option.getOrThrow(blockInBase);
      if (blockNumberToBigInt(block.header.number) > 0n) {
        yield* materializeAncestryFromBase(block.header.parentHash, visited);
      }

      const stillMissing = !(yield* overlayTree.hasBlock(block.hash));
      if (stillMissing) {
        yield* overlayTree.putBlock(block);
      }
      yield* rememberOverlayHash(block.hash);
    });

  const readThroughOption = <A>(
    overlay: Effect.Effect<Option.Option<A>, BlockTreeError>,
    base: () => Effect.Effect<Option.Option<A>, BlockTreeError>,
    onOverlayHit: (value: A) => Effect.Effect<void, BlockTreeError> = () =>
      Effect.void,
  ) =>
    Effect.gen(function* () {
      const overlayValue = yield* overlay;
      if (Option.isSome(overlayValue)) {
        yield* onOverlayHit(Option.getOrThrow(overlayValue));
        return overlayValue;
      }
      return yield* base();
    });

  const getBlock = (hash: BlockHashType) =>
    readThroughOption(
      overlayTree.getBlock(hash),
      () => baseTree.getBlock(hash),
      (block) => rememberOverlayHash(block.hash),
    );

  const getBlockByNumber = (number: BlockNumberType) =>
    readThroughOption(
      overlayTree.getBlockByNumber(number),
      () => baseTree.getBlockByNumber(number),
      (block) => rememberOverlayHash(block.hash),
    );

  const getCanonicalHash = (number: BlockNumberType) =>
    readThroughOption(
      overlayTree.getCanonicalHash(number),
      () => baseTree.getCanonicalHash(number),
      (hash) => rememberOverlayHash(hash),
    );

  const hasBlock = (hash: BlockHashType) =>
    Effect.gen(function* () {
      const inOverlay = yield* overlayTree.hasBlock(hash);
      if (inOverlay) {
        yield* rememberOverlayHash(hash);
        return true;
      }
      return yield* baseTree.hasBlock(hash);
    });

  const isOrphan = (hash: BlockHashType) =>
    Effect.gen(function* () {
      const inOverlay = yield* overlayTree.hasBlock(hash);
      if (inOverlay) {
        yield* rememberOverlayHash(hash);
        return yield* overlayTree.isOrphan(hash);
      }
      return yield* baseTree.isOrphan(hash);
    });

  const putBlock = (block: BlockType) =>
    Effect.gen(function* () {
      if (blockNumberToBigInt(block.header.number) > 0n) {
        yield* materializeAncestryFromBase(block.header.parentHash);
      }
      yield* overlayTree.putBlock(block);
      yield* rememberOverlayHash(block.hash);
    });

  const setCanonicalHead = (hash: BlockHashType) =>
    Effect.gen(function* () {
      yield* materializeAncestryFromBase(hash);
      yield* overlayTree.setCanonicalHead(hash);
    });

  const getHeadBlockNumber = () =>
    readThroughOption(overlayTree.getHeadBlockNumber(), () =>
      baseTree.getHeadBlockNumber(),
    );

  const blockCount = () =>
    Effect.gen(function* () {
      const baseCount = yield* baseTree.blockCount();
      let overlayOnly = 0;

      for (const hash of trackedOverlayHashes.values()) {
        const existsInBase = yield* baseTree.hasBlock(hash);
        if (!existsInBase) {
          overlayOnly += 1;
        }
      }

      return baseCount + overlayOnly;
    });

  const orphanCount = () =>
    Effect.gen(function* () {
      const baseOrphanCount = yield* baseTree.orphanCount();
      let shadowedBaseOrphans = 0;
      let visibleOverlayOrphans = 0;

      for (const hash of trackedOverlayHashes.values()) {
        const existsInBase = yield* baseTree.hasBlock(hash);
        if (existsInBase && (yield* baseTree.isOrphan(hash))) {
          shadowedBaseOrphans += 1;
        }

        if (yield* overlayTree.isOrphan(hash)) {
          visibleOverlayOrphans += 1;
        }
      }

      const remainingBaseOrphans = Math.max(
        0,
        baseOrphanCount - shadowedBaseOrphans,
      );
      return remainingBaseOrphans + visibleOverlayOrphans;
    });

  const collectCanonicalHashes = (
    tree: Pick<
      ReadOnlyBlockTreeService,
      "getCanonicalHash" | "getHeadBlockNumber"
    >,
  ) =>
    Effect.gen(function* () {
      const hashes = new Map<string, BlockHashType>();
      const headNumber = yield* tree.getHeadBlockNumber();
      if (Option.isNone(headNumber)) {
        return hashes;
      }

      const head = blockNumberToBigInt(Option.getOrThrow(headNumber));
      for (let number = 0n; number <= head; number += 1n) {
        const maybeHash = yield* tree.getCanonicalHash(
          blockNumberFromBigInt(number),
        );
        if (Option.isSome(maybeHash)) {
          const hash = Option.getOrThrow(maybeHash);
          hashes.set(Hex.fromBytes(hash), hash);
        }
      }

      return hashes;
    });

  const canonicalChainLength = () =>
    Effect.gen(function* () {
      const [baseCanonicalHashes, overlayCanonicalHashes] = yield* Effect.all([
        collectCanonicalHashes(baseTree),
        collectCanonicalHashes(overlayTree),
      ]);

      for (const [key, hash] of overlayCanonicalHashes.entries()) {
        baseCanonicalHashes.set(key, hash);
      }

      return baseCanonicalHashes.size;
    });

  return {
    [BLOCK_TREE_INSTANCE_ID]: overlayTree[BLOCK_TREE_INSTANCE_ID],
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
