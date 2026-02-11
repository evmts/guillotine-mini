import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import { Hex } from "voltaire-effect/primitives";
import {
  BLOCK_TREE_INSTANCE_ID,
  BlockTree,
  BlockTreeMemoryTest,
  type BlockTreeService,
  type BlockType,
} from "./BlockTree";
import {
  BlockTreeOverlay,
  BlockTreeOverlayLive,
  BlockTreeOverlaySharedStateError,
  type BlockTreeOverlayService,
  makeBlockTreeOverlayService,
} from "./BlockTreeOverlay";
import {
  ReadOnlyBlockTree,
  ReadOnlyBlockTreeLive,
  type ReadOnlyBlockTreeService,
} from "./ReadOnlyBlockTree";
import { blockHashFromByte, makeBlock } from "./testUtils";

const toReadOnly = (tree: BlockTreeService): ReadOnlyBlockTreeService => ({
  [BLOCK_TREE_INSTANCE_ID]: tree[BLOCK_TREE_INSTANCE_ID],
  getBlock: (hash) => tree.getBlock(hash),
  getBlockByNumber: (number) => tree.getBlockByNumber(number),
  getCanonicalHash: (number) => tree.getCanonicalHash(number),
  hasBlock: (hash) => tree.hasBlock(hash),
  isOrphan: (hash) => tree.isOrphan(hash),
  getHeadBlockNumber: () => tree.getHeadBlockNumber(),
  blockCount: () => tree.blockCount(),
  orphanCount: () => tree.orphanCount(),
  canonicalChainLength: () => tree.canonicalChainLength(),
});

const withIsolatedTrees = <A, E>(
  f: (
    baseTree: BlockTreeService,
    overlayTree: BlockTreeService,
    overlay: BlockTreeOverlayService,
  ) => Effect.Effect<A, E>,
) =>
  Effect.flatMap(BlockTree, (baseTree) =>
    Effect.flatMap(BlockTree, (overlayTree) =>
      f(
        baseTree,
        overlayTree,
        makeBlockTreeOverlayService(toReadOnly(baseTree), overlayTree),
      ),
    ).pipe(Effect.provide(Layer.fresh(BlockTreeMemoryTest))),
  ).pipe(Effect.provide(Layer.fresh(BlockTreeMemoryTest)));

const baseReadOnlyIsolated = ReadOnlyBlockTreeLive.pipe(
  Layer.provide(Layer.fresh(BlockTreeMemoryTest)),
);

const overlayDependenciesIsolated = Layer.provideMerge(baseReadOnlyIsolated)(
  Layer.fresh(BlockTreeMemoryTest),
);

const blockTreeOverlayIsolatedLive = Layer.provideMerge(
  overlayDependenciesIsolated,
)(BlockTreeOverlayLive);

const blockTreeOverlaySharedLive = BlockTreeOverlayLive.pipe(
  Layer.provide(Layer.provideMerge(BlockTreeMemoryTest)(ReadOnlyBlockTreeLive)),
);

const makeChain = (): {
  readonly genesis: BlockType;
  readonly block1: BlockType;
  readonly block2: BlockType;
  readonly side1: BlockType;
} => {
  const genesis = makeBlock({
    number: 0n,
    hash: blockHashFromByte(0x10),
    parentHash: blockHashFromByte(0x00),
  });
  const block1 = makeBlock({
    number: 1n,
    hash: blockHashFromByte(0x11),
    parentHash: genesis.hash,
  });
  const block2 = makeBlock({
    number: 2n,
    hash: blockHashFromByte(0x12),
    parentHash: block1.hash,
  });
  const side1 = makeBlock({
    number: 1n,
    hash: blockHashFromByte(0x21),
    parentHash: genesis.hash,
  });

  return { genesis, block1, block2, side1 };
};

describe("BlockTreeOverlay", () => {
  it.effect(
    "fails fast when base and overlay share the same live instance",
    () =>
      Effect.gen(function* () {
        const error = yield* Effect.flip(
          BlockTreeOverlay.pipe(Effect.provide(blockTreeOverlaySharedLive)),
        );

        assert.instanceOf(error, BlockTreeOverlaySharedStateError);
      }),
  );

  it.effect(
    "isolated live layer keeps base and overlay stores independent",
    () =>
      Effect.gen(function* () {
        const overlay = yield* BlockTreeOverlay;
        const base = yield* ReadOnlyBlockTree;
        const overlayTree = yield* BlockTree;
        const genesis = makeBlock({
          number: 0n,
          hash: blockHashFromByte(0x30),
          parentHash: blockHashFromByte(0x00),
        });

        yield* overlay.putBlock(genesis);

        assert.isTrue(yield* overlayTree.hasBlock(genesis.hash));
        assert.isFalse(yield* base.hasBlock(genesis.hash));
      }).pipe(Effect.provide(blockTreeOverlayIsolatedLive)),
  );

  it.effect(
    "putBlock imports parent ancestry from base before overlay writes",
    () =>
      withIsolatedTrees((baseTree, overlayTree, overlay) =>
        Effect.gen(function* () {
          const { genesis, block1, block2 } = makeChain();

          yield* baseTree.putBlock(genesis);
          yield* baseTree.putBlock(block1);
          yield* baseTree.setCanonicalHead(block1.hash);
          yield* overlay.putBlock(block2);

          assert.isTrue(yield* overlayTree.hasBlock(genesis.hash));
          assert.isTrue(yield* overlayTree.hasBlock(block1.hash));
          assert.isTrue(yield* overlayTree.hasBlock(block2.hash));
          assert.isFalse(yield* overlay.isOrphan(block2.hash));
        }),
      ),
  );

  it.effect("setCanonicalHead succeeds when ancestry exists only in base", () =>
    withIsolatedTrees((baseTree, overlayTree, overlay) =>
      Effect.gen(function* () {
        const { genesis, block1, block2 } = makeChain();

        yield* baseTree.putBlock(genesis);
        yield* baseTree.putBlock(block1);
        yield* baseTree.putBlock(block2);
        yield* baseTree.setCanonicalHead(block2.hash);
        yield* overlay.setCanonicalHead(block2.hash);

        const head = yield* overlay.getHeadBlockNumber();
        const canonical1 = yield* overlay.getCanonicalHash(
          block1.header.number,
        );

        assert.isTrue(yield* overlayTree.hasBlock(genesis.hash));
        assert.isTrue(yield* overlayTree.hasBlock(block1.hash));
        assert.isTrue(yield* overlayTree.hasBlock(block2.hash));
        assert.isTrue(Option.isSome(head));
        assert.strictEqual(Option.getOrThrow(head) as bigint, 2n);
        assert.isTrue(Option.isSome(canonical1));
        assert.strictEqual(
          Hex.fromBytes(Option.getOrThrow(canonical1)),
          Hex.fromBytes(block1.hash),
        );
      }),
    ),
  );

  it.effect("count helpers use union visibility without double-counting", () =>
    withIsolatedTrees((baseTree, _overlayTree, overlay) =>
      Effect.gen(function* () {
        const { genesis, block1, side1 } = makeChain();
        const side2 = makeBlock({
          number: 2n,
          hash: blockHashFromByte(0x22),
          parentHash: side1.hash,
        });

        yield* baseTree.putBlock(genesis);
        yield* baseTree.putBlock(block1);
        yield* baseTree.putBlock(side1);
        yield* baseTree.setCanonicalHead(block1.hash);

        assert.strictEqual(yield* baseTree.blockCount(), 3);
        assert.strictEqual(yield* baseTree.orphanCount(), 1);
        assert.strictEqual(yield* baseTree.canonicalChainLength(), 2);

        yield* overlay.setCanonicalHead(side1.hash);
        assert.strictEqual(yield* overlay.blockCount(), 3);
        assert.strictEqual(yield* overlay.orphanCount(), 0);
        assert.strictEqual(yield* overlay.canonicalChainLength(), 3);

        yield* overlay.putBlock(side2);
        yield* overlay.setCanonicalHead(side2.hash);
        assert.strictEqual(yield* overlay.blockCount(), 4);
        assert.strictEqual(yield* overlay.orphanCount(), 0);
        assert.strictEqual(yield* overlay.canonicalChainLength(), 4);
      }),
    ),
  );
});
