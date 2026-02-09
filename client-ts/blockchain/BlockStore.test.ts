import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import { Hex } from "voltaire-effect/primitives";
import {
  blockCount,
  BlockNotFoundError,
  BlockStoreMemoryTest,
  canonicalChainLength,
  CannotSetOrphanAsHeadError,
  getBlock,
  getBlockByNumber,
  getCanonicalHash,
  getHeadBlockNumber,
  hasBlock,
  isOrphan,
  orphanCount,
  putBlock,
  setCanonicalHead,
} from "./BlockStore";
import { blockHashFromByte, makeBlock } from "./testUtils";

describe("BlockStore", () => {
  it.effect("putBlock stores and getBlock returns the block", () =>
    Effect.gen(function* () {
      const genesis = makeBlock({
        number: 0n,
        hash: blockHashFromByte(0x01),
        parentHash: blockHashFromByte(0x00),
      });

      yield* putBlock(genesis);

      assert.isTrue(yield* hasBlock(genesis.hash));
      assert.strictEqual(yield* blockCount(), 1);

      const result = yield* getBlock(genesis.hash);
      assert.isTrue(Option.isSome(result));

      const stored = Option.getOrThrow(result);
      assert.strictEqual(
        Hex.fromBytes(stored.hash),
        Hex.fromBytes(genesis.hash),
      );
    }).pipe(Effect.provide(BlockStoreMemoryTest)),
  );

  it.effect("tracks and resolves orphans", () =>
    Effect.gen(function* () {
      const parentHash = blockHashFromByte(0x10);
      const orphan = makeBlock({
        number: 1n,
        hash: blockHashFromByte(0x11),
        parentHash,
      });

      yield* putBlock(orphan);

      assert.isTrue(yield* isOrphan(orphan.hash));
      assert.strictEqual(yield* orphanCount(), 1);

      const parent = makeBlock({
        number: 0n,
        hash: parentHash,
        parentHash: blockHashFromByte(0x00),
      });

      yield* putBlock(parent);

      assert.isFalse(yield* isOrphan(orphan.hash));
      assert.strictEqual(yield* orphanCount(), 0);
    }).pipe(Effect.provide(BlockStoreMemoryTest)),
  );

  it.effect("setCanonicalHead updates canonical lookups", () =>
    Effect.gen(function* () {
      const genesis = makeBlock({
        number: 0n,
        hash: blockHashFromByte(0x21),
        parentHash: blockHashFromByte(0x00),
      });
      const block1 = makeBlock({
        number: 1n,
        hash: blockHashFromByte(0x22),
        parentHash: genesis.hash,
      });

      yield* putBlock(genesis);
      yield* putBlock(block1);
      yield* setCanonicalHead(block1.hash);

      const byNumber = yield* getBlockByNumber(block1.header.number);
      assert.isTrue(Option.isSome(byNumber));

      const canonicalHash = yield* getCanonicalHash(block1.header.number);
      assert.isTrue(Option.isSome(canonicalHash));
      assert.strictEqual(
        Hex.fromBytes(Option.getOrThrow(canonicalHash)),
        Hex.fromBytes(block1.hash),
      );

      const headNumber = yield* getHeadBlockNumber();
      assert.isTrue(Option.isSome(headNumber));
      assert.strictEqual(Option.getOrThrow(headNumber) as bigint, 1n);
      assert.strictEqual(yield* canonicalChainLength(), 2);
    }).pipe(Effect.provide(BlockStoreMemoryTest)),
  );

  it.effect("setCanonicalHead fails for missing or orphan blocks", () =>
    Effect.gen(function* () {
      const missingHash = blockHashFromByte(0xaa);
      const missingError = yield* Effect.flip(setCanonicalHead(missingHash));
      assert.instanceOf(missingError, BlockNotFoundError);

      const orphanParent = blockHashFromByte(0xbb);
      const orphan = makeBlock({
        number: 1n,
        hash: blockHashFromByte(0xcc),
        parentHash: orphanParent,
      });

      yield* putBlock(orphan);

      const orphanError = yield* Effect.flip(setCanonicalHead(orphan.hash));
      assert.instanceOf(orphanError, CannotSetOrphanAsHeadError);
    }).pipe(Effect.provide(BlockStoreMemoryTest)),
  );
});
