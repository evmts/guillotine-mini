import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import { Hex } from "voltaire-effect/primitives";
import {
  BlockchainTest,
  getBlockByHash,
  getBlockByNumber,
  initializeGenesis,
  putBlock,
  setCanonicalHead,
} from "./Blockchain";
import { blockHashFromByte, makeBlock } from "./testUtils";

describe("Blockchain", () => {
  it.effect("getBlockByHash returns None for missing blocks", () =>
    Effect.gen(function* () {
      const missing = yield* getBlockByHash(blockHashFromByte(0x01));
      assert.isTrue(Option.isNone(missing));
    }).pipe(Effect.provide(BlockchainTest)),
  );

  it.effect("putBlock stores blocks retrievable by hash", () =>
    Effect.gen(function* () {
      const block = makeBlock({
        number: 0n,
        hash: blockHashFromByte(0x02),
        parentHash: blockHashFromByte(0x00),
      });

      yield* putBlock(block);

      const stored = yield* getBlockByHash(block.hash);
      assert.isTrue(Option.isSome(stored));
      assert.strictEqual(
        Hex.fromBytes(Option.getOrThrow(stored).hash),
        Hex.fromBytes(block.hash),
      );
    }).pipe(Effect.provide(BlockchainTest)),
  );

  it.effect("setCanonicalHead updates getBlockByNumber", () =>
    Effect.gen(function* () {
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

      yield* initializeGenesis(genesis);
      yield* putBlock(block1);
      yield* setCanonicalHead(block1.hash);

      const byNumber = yield* getBlockByNumber(block1.header.number);
      assert.isTrue(Option.isSome(byNumber));
      assert.strictEqual(
        Hex.fromBytes(Option.getOrThrow(byNumber).hash),
        Hex.fromBytes(block1.hash),
      );
    }).pipe(Effect.provide(BlockchainTest)),
  );
});
