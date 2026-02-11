import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import { Hex } from "voltaire-effect/primitives";
import { putBlock, setCanonicalHead, type BlockType } from "./BlockTree";
import {
  blockCount,
  canonicalChainLength,
  getBlock,
  getBlockByNumber,
  getCanonicalHash,
  getHeadBlockNumber,
  hasBlock,
  isOrphan,
  orphanCount,
  ReadOnlyBlockTreeTest,
} from "./ReadOnlyBlockTree";
import { blockHashFromByte, makeBlock } from "./testUtils";

describe("ReadOnlyBlockTree", () => {
  const buildChain = (): {
    readonly genesis: BlockType;
    readonly block1: BlockType;
    readonly block2: BlockType;
    readonly side: BlockType;
  } => {
    const genesis = makeBlock({
      number: 0n,
      hash: blockHashFromByte(0x41),
      parentHash: blockHashFromByte(0x00),
    });
    const block1 = makeBlock({
      number: 1n,
      hash: blockHashFromByte(0x42),
      parentHash: genesis.hash,
    });
    const block2 = makeBlock({
      number: 2n,
      hash: blockHashFromByte(0x43),
      parentHash: block1.hash,
    });
    const side = makeBlock({
      number: 1n,
      hash: blockHashFromByte(0x44),
      parentHash: genesis.hash,
    });

    return { genesis, block1, block2, side };
  };

  it.effect("getBlock and hasBlock expose hash lookups", () =>
    Effect.gen(function* () {
      const { genesis } = buildChain();
      yield* putBlock(genesis);

      const existing = yield* getBlock(genesis.hash);
      assert.isTrue(Option.isSome(existing));
      assert.strictEqual(
        Hex.fromBytes(Option.getOrThrow(existing).hash),
        Hex.fromBytes(genesis.hash),
      );
      assert.isTrue(yield* hasBlock(genesis.hash));

      const missingHash = blockHashFromByte(0xaa);
      assert.isFalse(yield* hasBlock(missingHash));
      assert.isTrue(Option.isNone(yield* getBlock(missingHash)));
    }).pipe(Effect.provide(ReadOnlyBlockTreeTest)),
  );

  it.effect(
    "getBlockByNumber and getCanonicalHash reflect canonical head",
    () =>
      Effect.gen(function* () {
        const { genesis, block1, block2 } = buildChain();
        yield* putBlock(genesis);
        yield* putBlock(block1);
        yield* putBlock(block2);
        yield* setCanonicalHead(block2.hash);

        const byNumber = yield* getBlockByNumber(block2.header.number);
        assert.isTrue(Option.isSome(byNumber));
        assert.strictEqual(
          Hex.fromBytes(Option.getOrThrow(byNumber).hash),
          Hex.fromBytes(block2.hash),
        );

        const canonicalHash = yield* getCanonicalHash(block2.header.number);
        assert.isTrue(Option.isSome(canonicalHash));
        assert.strictEqual(
          Hex.fromBytes(Option.getOrThrow(canonicalHash)),
          Hex.fromBytes(block2.hash),
        );
      }).pipe(Effect.provide(ReadOnlyBlockTreeTest)),
  );

  it.effect(
    "getHeadBlockNumber and canonicalChainLength expose chain view",
    () =>
      Effect.gen(function* () {
        const { genesis, block1, block2 } = buildChain();
        yield* putBlock(genesis);
        yield* putBlock(block1);
        yield* putBlock(block2);
        yield* setCanonicalHead(block2.hash);

        const head = yield* getHeadBlockNumber();
        assert.isTrue(Option.isSome(head));
        assert.strictEqual(Option.getOrThrow(head) as bigint, 2n);
        assert.strictEqual(yield* canonicalChainLength(), 3);
      }).pipe(Effect.provide(ReadOnlyBlockTreeTest)),
  );

  it.effect("isOrphan reports side-chain blocks after canonicalization", () =>
    Effect.gen(function* () {
      const { genesis, block1, block2, side } = buildChain();
      yield* putBlock(genesis);
      yield* putBlock(block1);
      yield* putBlock(block2);
      yield* putBlock(side);
      yield* setCanonicalHead(block2.hash);

      assert.isFalse(yield* isOrphan(genesis.hash));
      assert.isFalse(yield* isOrphan(block2.hash));
      assert.isTrue(yield* isOrphan(side.hash));
    }).pipe(Effect.provide(ReadOnlyBlockTreeTest)),
  );

  it.effect("blockCount and orphanCount expose aggregate counts", () =>
    Effect.gen(function* () {
      const { genesis, block1, block2, side } = buildChain();
      yield* putBlock(genesis);
      yield* putBlock(block1);
      yield* putBlock(block2);
      yield* putBlock(side);
      yield* setCanonicalHead(block2.hash);

      assert.strictEqual(yield* blockCount(), 4);
      assert.strictEqual(yield* orphanCount(), 1);
    }).pipe(Effect.provide(ReadOnlyBlockTreeTest)),
  );
});
