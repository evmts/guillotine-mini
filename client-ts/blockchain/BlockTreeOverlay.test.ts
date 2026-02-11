import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import * as Schema from "effect/Schema";
import { BlockNumber, Hex } from "voltaire-effect/primitives";
import {
  type BlockHashType,
  type BlockNumberType,
  type BlockTreeService,
  type BlockType,
} from "./BlockTree";
import { makeBlockTreeOverlayService } from "./BlockTreeOverlay";
import type { ReadOnlyBlockTreeService } from "./ReadOnlyBlockTree";
import {
  blockHashFromByte,
  blockNumberFromBigInt,
  makeBlock,
} from "./testUtils";

const BlockNumberBigIntSchema = BlockNumber.BigInt as unknown as Schema.Schema<
  BlockNumberType,
  bigint
>;

type StubTreeState = {
  readonly blocks: Map<string, BlockType>;
  readonly canonicalByNumber: Map<bigint, BlockHashType>;
  readonly orphans: Set<string>;
  headNumber: Option.Option<BlockNumberType>;
  putCalls: number;
  setCanonicalHeadCalls: number;
};

type StubTree = {
  readonly service: BlockTreeService;
  readonly state: StubTreeState;
};

const hashKey = (hash: BlockHashType) => Hex.fromBytes(hash);
const numberKey = (number: BlockNumberType) =>
  Schema.encodeSync(BlockNumberBigIntSchema)(number);

const run = <A, E>(effect: Effect.Effect<A, E>) => Effect.runSync(effect);

const toReadOnly = (tree: BlockTreeService): ReadOnlyBlockTreeService => ({
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

const makeStubTree = (params?: {
  readonly blocks?: ReadonlyArray<BlockType>;
  readonly canonicalBlocks?: ReadonlyArray<BlockType>;
  readonly orphanHashes?: ReadonlyArray<BlockHashType>;
  readonly headNumber?: bigint;
}): StubTree => {
  const state: StubTreeState = {
    blocks: new Map<string, BlockType>(),
    canonicalByNumber: new Map<bigint, BlockHashType>(),
    orphans: new Set<string>(),
    headNumber:
      params?.headNumber === undefined
        ? Option.none()
        : Option.some(blockNumberFromBigInt(params.headNumber)),
    putCalls: 0,
    setCanonicalHeadCalls: 0,
  };

  for (const block of params?.blocks ?? []) {
    state.blocks.set(hashKey(block.hash), block);
  }
  for (const block of params?.canonicalBlocks ?? []) {
    state.canonicalByNumber.set(numberKey(block.header.number), block.hash);
  }
  for (const hash of params?.orphanHashes ?? []) {
    state.orphans.add(hashKey(hash));
  }

  const service = {
    getBlock: (hash) =>
      Effect.succeed(Option.fromNullable(state.blocks.get(hashKey(hash)))),
    getBlockByNumber: (number) =>
      Effect.gen(function* () {
        const canonicalHash = state.canonicalByNumber.get(numberKey(number));
        if (!canonicalHash) {
          return Option.none();
        }
        return Option.fromNullable(state.blocks.get(hashKey(canonicalHash)));
      }),
    getCanonicalHash: (number) =>
      Effect.succeed(
        Option.fromNullable(state.canonicalByNumber.get(numberKey(number))),
      ),
    hasBlock: (hash) => Effect.succeed(state.blocks.has(hashKey(hash))),
    isOrphan: (hash) => Effect.succeed(state.orphans.has(hashKey(hash))),
    putBlock: (block) =>
      Effect.sync(() => {
        state.putCalls += 1;
        state.blocks.set(hashKey(block.hash), block);
      }),
    setCanonicalHead: (hash) =>
      Effect.sync(() => {
        state.setCanonicalHeadCalls += 1;
        const head = state.blocks.get(hashKey(hash));
        if (!head) {
          return;
        }
        state.headNumber = Option.some(head.header.number);
        state.canonicalByNumber.set(numberKey(head.header.number), head.hash);
      }),
    getHeadBlockNumber: () => Effect.succeed(state.headNumber),
    blockCount: () => Effect.succeed(state.blocks.size),
    orphanCount: () => Effect.succeed(state.orphans.size),
    canonicalChainLength: () => Effect.succeed(state.canonicalByNumber.size),
  } satisfies BlockTreeService;

  return { service, state };
};

describe("BlockTreeOverlay", () => {
  it("prefers overlay canonical lookups and falls back to base", () => {
    const genesis = makeBlock({
      number: 0n,
      hash: blockHashFromByte(0x10),
      parentHash: blockHashFromByte(0x00),
    });
    const baseBlock1 = makeBlock({
      number: 1n,
      hash: blockHashFromByte(0x11),
      parentHash: genesis.hash,
    });
    const baseBlock2 = makeBlock({
      number: 2n,
      hash: blockHashFromByte(0x12),
      parentHash: baseBlock1.hash,
    });
    const overlayBlock1 = makeBlock({
      number: 1n,
      hash: blockHashFromByte(0x21),
      parentHash: genesis.hash,
    });

    const base = makeStubTree({
      blocks: [genesis, baseBlock1, baseBlock2],
      canonicalBlocks: [genesis, baseBlock1, baseBlock2],
      headNumber: 2n,
    });
    const overlay = makeStubTree({
      blocks: [overlayBlock1],
      canonicalBlocks: [overlayBlock1],
      headNumber: 1n,
    });
    const service = makeBlockTreeOverlayService(
      toReadOnly(base.service),
      overlay.service,
    );

    const overlayByHash = run(service.getBlock(overlayBlock1.hash));
    assert.strictEqual(Option.isSome(overlayByHash), true);
    assert.strictEqual(
      Hex.fromBytes(Option.getOrThrow(overlayByHash).hash),
      Hex.fromBytes(overlayBlock1.hash),
    );

    const fallbackByHash = run(service.getBlock(baseBlock2.hash));
    assert.strictEqual(Option.isSome(fallbackByHash), true);
    assert.strictEqual(
      Hex.fromBytes(Option.getOrThrow(fallbackByHash).hash),
      Hex.fromBytes(baseBlock2.hash),
    );

    const byNumberOverlay = run(
      service.getBlockByNumber(blockNumberFromBigInt(1n)),
    );
    assert.strictEqual(Option.isSome(byNumberOverlay), true);
    assert.strictEqual(
      Hex.fromBytes(Option.getOrThrow(byNumberOverlay).hash),
      Hex.fromBytes(overlayBlock1.hash),
    );

    const byNumberFallback = run(
      service.getBlockByNumber(blockNumberFromBigInt(2n)),
    );
    assert.strictEqual(Option.isSome(byNumberFallback), true);
    assert.strictEqual(
      Hex.fromBytes(Option.getOrThrow(byNumberFallback).hash),
      Hex.fromBytes(baseBlock2.hash),
    );

    const canonicalOverlay = run(
      service.getCanonicalHash(blockNumberFromBigInt(1n)),
    );
    assert.strictEqual(Option.isSome(canonicalOverlay), true);
    assert.strictEqual(
      Hex.fromBytes(Option.getOrThrow(canonicalOverlay)),
      Hex.fromBytes(overlayBlock1.hash),
    );

    const canonicalFallback = run(
      service.getCanonicalHash(blockNumberFromBigInt(2n)),
    );
    assert.strictEqual(Option.isSome(canonicalFallback), true);
    assert.strictEqual(
      Hex.fromBytes(Option.getOrThrow(canonicalFallback)),
      Hex.fromBytes(baseBlock2.hash),
    );
  });

  it("hasBlock and isOrphan OR across base and overlay", () => {
    const baseOnly = makeBlock({
      number: 1n,
      hash: blockHashFromByte(0x31),
      parentHash: blockHashFromByte(0x30),
    });
    const overlayOnly = makeBlock({
      number: 2n,
      hash: blockHashFromByte(0x41),
      parentHash: blockHashFromByte(0x31),
    });
    const missing = blockHashFromByte(0xff);

    const base = makeStubTree({
      blocks: [baseOnly],
      orphanHashes: [baseOnly.hash],
    });
    const overlay = makeStubTree({
      blocks: [overlayOnly],
      orphanHashes: [overlayOnly.hash],
    });
    const service = makeBlockTreeOverlayService(
      toReadOnly(base.service),
      overlay.service,
    );

    assert.strictEqual(run(service.hasBlock(baseOnly.hash)), true);
    assert.strictEqual(run(service.hasBlock(overlayOnly.hash)), true);
    assert.strictEqual(run(service.hasBlock(missing)), false);

    assert.strictEqual(run(service.isOrphan(baseOnly.hash)), true);
    assert.strictEqual(run(service.isOrphan(overlayOnly.hash)), true);
    assert.strictEqual(run(service.isOrphan(missing)), false);
  });

  it("putBlock and setCanonicalHead write only to overlay", () => {
    const block = makeBlock({
      number: 3n,
      hash: blockHashFromByte(0x51),
      parentHash: blockHashFromByte(0x50),
    });

    const base = makeStubTree();
    const overlay = makeStubTree();
    const service = makeBlockTreeOverlayService(
      toReadOnly(base.service),
      overlay.service,
    );

    run(service.putBlock(block));
    run(service.setCanonicalHead(block.hash));

    assert.strictEqual(run(base.service.hasBlock(block.hash)), false);
    assert.strictEqual(run(overlay.service.hasBlock(block.hash)), true);
    assert.strictEqual(base.state.putCalls, 0);
    assert.strictEqual(overlay.state.putCalls, 1);
    assert.strictEqual(base.state.setCanonicalHeadCalls, 0);
    assert.strictEqual(overlay.state.setCanonicalHeadCalls, 1);
  });

  it("getHeadBlockNumber prefers overlay and falls back to base", () => {
    const base = makeStubTree({ headNumber: 5n });
    const overlay = makeStubTree();
    const service = makeBlockTreeOverlayService(
      toReadOnly(base.service),
      overlay.service,
    );

    const fallbackHead = run(service.getHeadBlockNumber());
    assert.strictEqual(Option.isSome(fallbackHead), true);
    assert.strictEqual(
      Schema.encodeSync(BlockNumberBigIntSchema)(
        Option.getOrThrow(fallbackHead),
      ),
      5n,
    );

    overlay.state.headNumber = Option.some(blockNumberFromBigInt(6n));
    const overlayHead = run(service.getHeadBlockNumber());
    assert.strictEqual(Option.isSome(overlayHead), true);
    assert.strictEqual(
      Schema.encodeSync(BlockNumberBigIntSchema)(
        Option.getOrThrow(overlayHead),
      ),
      6n,
    );
  });

  it("count helpers merge base and overlay visibility", () => {
    const baseA = makeBlock({
      number: 0n,
      hash: blockHashFromByte(0x61),
      parentHash: blockHashFromByte(0x00),
    });
    const baseB = makeBlock({
      number: 1n,
      hash: blockHashFromByte(0x62),
      parentHash: baseA.hash,
    });
    const overlayA = makeBlock({
      number: 1n,
      hash: blockHashFromByte(0x71),
      parentHash: baseA.hash,
    });

    const base = makeStubTree({
      blocks: [baseA, baseB],
      canonicalBlocks: [baseA, baseB],
      orphanHashes: [baseB.hash],
    });
    const overlay = makeStubTree({
      blocks: [overlayA],
      canonicalBlocks: [overlayA],
      orphanHashes: [overlayA.hash],
    });
    const service = makeBlockTreeOverlayService(
      toReadOnly(base.service),
      overlay.service,
    );

    assert.strictEqual(run(service.blockCount()), 3);
    assert.strictEqual(run(service.orphanCount()), 2);
    assert.strictEqual(run(service.canonicalChainLength()), 2);
  });
});
