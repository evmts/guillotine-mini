import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import { Hex } from "voltaire-effect/primitives";
import {
  blockCount,
  BlockStoreMemoryTest,
  getBlock,
  hasBlock,
  putBlock,
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

  it.effect("hasBlock returns false for missing hashes", () =>
    Effect.gen(function* () {
      const missing = blockHashFromByte(0xaa);
      assert.isFalse(yield* hasBlock(missing));

      const block = makeBlock({
        number: 0n,
        hash: blockHashFromByte(0xab),
        parentHash: blockHashFromByte(0x00),
      });

      yield* putBlock(block);
      assert.isTrue(yield* hasBlock(block.hash));
    }).pipe(Effect.provide(BlockStoreMemoryTest)),
  );

  it.effect("blockCount counts stored blocks", () =>
    Effect.gen(function* () {
      assert.strictEqual(yield* blockCount(), 0);

      const blockA = makeBlock({
        number: 0n,
        hash: blockHashFromByte(0xb1),
        parentHash: blockHashFromByte(0x00),
      });
      const blockB = makeBlock({
        number: 1n,
        hash: blockHashFromByte(0xb2),
        parentHash: blockA.hash,
      });

      yield* putBlock(blockA);
      yield* putBlock(blockB);

      assert.strictEqual(yield* blockCount(), 2);
    }).pipe(Effect.provide(BlockStoreMemoryTest)),
  );
});
