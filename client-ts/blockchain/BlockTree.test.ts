import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import { Hex } from "voltaire-effect/primitives";
import {
  BlockNotFoundError,
  BlockTreeMemoryTest,
  canonicalChainLength,
  CannotSetOrphanAsHeadError,
  getBlockByNumber,
  getCanonicalHash,
  getHeadBlockNumber,
  isOrphan,
  orphanCount,
  putBlock,
  setCanonicalHead,
} from "./BlockTree";
import { blockHashFromByte, makeBlock } from "./testUtils";

describe("BlockTree", () => {
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
    }).pipe(Effect.provide(BlockTreeMemoryTest)),
  );

  it.effect("resolves cascading orphan chains when the parent arrives", () =>
    Effect.gen(function* () {
      const genesis = makeBlock({
        number: 0n,
        hash: blockHashFromByte(0x30),
        parentHash: blockHashFromByte(0x00),
      });
      const block1 = makeBlock({
        number: 1n,
        hash: blockHashFromByte(0x31),
        parentHash: genesis.hash,
      });
      const block2 = makeBlock({
        number: 2n,
        hash: blockHashFromByte(0x32),
        parentHash: block1.hash,
      });
      const block3 = makeBlock({
        number: 3n,
        hash: blockHashFromByte(0x33),
        parentHash: block2.hash,
      });

      yield* putBlock(genesis);
      yield* putBlock(block3);
      yield* putBlock(block2);

      assert.isTrue(yield* isOrphan(block2.hash));
      assert.isTrue(yield* isOrphan(block3.hash));
      assert.strictEqual(yield* orphanCount(), 2);

      yield* putBlock(block1);

      assert.isFalse(yield* isOrphan(block2.hash));
      assert.isFalse(yield* isOrphan(block3.hash));
      assert.strictEqual(yield* orphanCount(), 0);
    }).pipe(Effect.provide(BlockTreeMemoryTest)),
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
    }).pipe(Effect.provide(BlockTreeMemoryTest)),
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
    }).pipe(Effect.provide(BlockTreeMemoryTest)),
  );

  it.effect(
    "setCanonicalHead prunes canonical entries above the new head",
    () =>
      Effect.gen(function* () {
        const genesis = makeBlock({
          number: 0n,
          hash: blockHashFromByte(0xd0),
          parentHash: blockHashFromByte(0x00),
        });
        const block1 = makeBlock({
          number: 1n,
          hash: blockHashFromByte(0xd1),
          parentHash: genesis.hash,
        });
        const block2 = makeBlock({
          number: 2n,
          hash: blockHashFromByte(0xd2),
          parentHash: block1.hash,
        });

        yield* putBlock(genesis);
        yield* putBlock(block1);
        yield* putBlock(block2);
        yield* setCanonicalHead(block2.hash);

        yield* setCanonicalHead(block1.hash);

        const canonicalHash = yield* getCanonicalHash(block2.header.number);
        assert.isTrue(Option.isNone(canonicalHash));
        assert.strictEqual(yield* canonicalChainLength(), 2);

        const headNumber = yield* getHeadBlockNumber();
        assert.isTrue(Option.isSome(headNumber));
        assert.strictEqual(Option.getOrThrow(headNumber) as bigint, 1n);
      }).pipe(Effect.provide(BlockTreeMemoryTest)),
  );

  it.effect("marks non-canonical blocks as orphaned after head is set", () =>
    Effect.gen(function* () {
      const genesis = makeBlock({
        number: 0n,
        hash: blockHashFromByte(0xf0),
        parentHash: blockHashFromByte(0x00),
      });
      const block1 = makeBlock({
        number: 1n,
        hash: blockHashFromByte(0xf1),
        parentHash: genesis.hash,
      });
      const block2 = makeBlock({
        number: 2n,
        hash: blockHashFromByte(0xf2),
        parentHash: block1.hash,
      });
      const side = makeBlock({
        number: 1n,
        hash: blockHashFromByte(0xf3),
        parentHash: genesis.hash,
      });

      yield* putBlock(genesis);
      yield* putBlock(block1);
      yield* putBlock(block2);
      yield* putBlock(side);
      yield* setCanonicalHead(block2.hash);

      assert.isFalse(yield* isOrphan(block1.hash));
      assert.isFalse(yield* isOrphan(block2.hash));
      assert.isTrue(yield* isOrphan(side.hash));
    }).pipe(Effect.provide(BlockTreeMemoryTest)),
  );
});
