import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import { Hardfork, Hex } from "voltaire-effect/primitives";
import {
  BlockhashProviderTest,
  MissingBlockhashError,
  getBlockhash,
  getLast256BlockHashes,
} from "./BlockhashProvider";
import { putBlock } from "./BlockTree";
import { ReleaseSpecLive } from "../evm/ReleaseSpec";
import {
  blockHashFromByte,
  blockNumberFromBigInt,
  makeBlock,
} from "./testUtils";

const provideSpec =
  (hardfork: Hardfork.HardforkType) =>
  <A, E, R>(effect: Effect.Effect<A, E, R>) =>
    effect.pipe(
      Effect.provide(BlockhashProviderTest),
      Effect.provide(ReleaseSpecLive(hardfork)),
    );

describe("BlockhashProvider", () => {
  it.effect("returns the parent hash for recent blocks", () =>
    provideSpec(Hardfork.FRONTIER)(
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
        const current = makeBlock({
          number: 2n,
          hash: blockHashFromByte(0x12),
          parentHash: block1.hash,
        });

        yield* putBlock(genesis);
        yield* putBlock(block1);

        const hash = yield* getBlockhash(
          current.header,
          blockNumberFromBigInt(1n),
        );
        assert.isTrue(Option.isSome(hash));
        assert.strictEqual(
          Hex.fromBytes(Option.getOrThrow(hash)),
          Hex.fromBytes(block1.hash),
        );
      }),
    ),
  );

  it.effect("returns None for future or too-old requests", () =>
    provideSpec(Hardfork.FRONTIER)(
      Effect.gen(function* () {
        const current = makeBlock({
          number: 300n,
          hash: blockHashFromByte(0x20),
          parentHash: blockHashFromByte(0x21),
        });

        const future = yield* getBlockhash(
          current.header,
          blockNumberFromBigInt(300n),
        );
        assert.isTrue(Option.isNone(future));

        const tooOld = yield* getBlockhash(
          current.header,
          blockNumberFromBigInt(0n),
        );
        assert.isTrue(Option.isNone(tooOld));
      }),
    ),
  );

  it.effect("returns deeper ancestor hashes when available", () =>
    provideSpec(Hardfork.FRONTIER)(
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
        const current = makeBlock({
          number: 3n,
          hash: blockHashFromByte(0x33),
          parentHash: block2.hash,
        });

        yield* putBlock(genesis);
        yield* putBlock(block1);
        yield* putBlock(block2);

        const hash = yield* getBlockhash(
          current.header,
          blockNumberFromBigInt(1n),
        );
        assert.isTrue(Option.isSome(hash));
        assert.strictEqual(
          Hex.fromBytes(Option.getOrThrow(hash)),
          Hex.fromBytes(block1.hash),
        );
      }),
    ),
  );

  it.effect("fails when an ancestor is missing within range", () =>
    provideSpec(Hardfork.FRONTIER)(
      Effect.gen(function* () {
        const current = makeBlock({
          number: 3n,
          hash: blockHashFromByte(0x40),
          parentHash: blockHashFromByte(0x41),
        });

        const error = yield* Effect.flip(
          getBlockhash(current.header, blockNumberFromBigInt(1n)),
        );
        assert.instanceOf(error, MissingBlockhashError);
      }),
    ),
  );

  it.effect("returns ordered recent hashes for block env", () =>
    provideSpec(Hardfork.FRONTIER)(
      Effect.gen(function* () {
        const genesis = makeBlock({
          number: 0n,
          hash: blockHashFromByte(0x50),
          parentHash: blockHashFromByte(0x00),
        });
        const block1 = makeBlock({
          number: 1n,
          hash: blockHashFromByte(0x51),
          parentHash: genesis.hash,
        });
        const block2 = makeBlock({
          number: 2n,
          hash: blockHashFromByte(0x52),
          parentHash: block1.hash,
        });
        const current = makeBlock({
          number: 3n,
          hash: blockHashFromByte(0x53),
          parentHash: block2.hash,
        });

        yield* putBlock(genesis);
        yield* putBlock(block1);
        yield* putBlock(block2);

        const hashes = yield* getLast256BlockHashes(current.header);
        const hexes = hashes.map((hash) => Hex.fromBytes(hash));
        const expected = [genesis, block1, block2].map((block) =>
          Hex.fromBytes(block.hash),
        );
        assert.deepStrictEqual(hexes, expected);
      }),
    ),
  );

  it.effect("caps block env hashes at the 256-depth boundary", () =>
    provideSpec(Hardfork.FRONTIER)(
      Effect.gen(function* () {
        const blocks: Array<ReturnType<typeof makeBlock>> = [];
        let parentHash = blockHashFromByte(0x00);

        for (let index = 0; index < 256; index += 1) {
          const block = makeBlock({
            number: BigInt(index),
            hash: blockHashFromByte(index),
            parentHash,
          });
          blocks.push(block);
          parentHash = block.hash;
        }

        for (const block of blocks) {
          yield* putBlock(block);
        }

        const current = makeBlock({
          number: 256n,
          hash: blockHashFromByte(0xaa),
          parentHash: blocks[255]!.hash,
        });

        const hashes = yield* getLast256BlockHashes(current.header);
        assert.strictEqual(hashes.length, 256);

        const hexes = hashes.map((hash) => Hex.fromBytes(hash));
        const expected = blocks.map((block) => Hex.fromBytes(block.hash));
        assert.deepStrictEqual(hexes, expected);
      }),
    ),
  );
});
