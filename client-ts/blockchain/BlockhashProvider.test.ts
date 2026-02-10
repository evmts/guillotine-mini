import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import { Hardfork, Hex } from "voltaire-effect/primitives";
import {
  BlockhashProviderTest,
  InvalidBlockhashNumberError,
  MissingBlockhashError,
  getBlockhash,
  getLast256BlockHashes,
} from "./BlockhashProvider";
import { putHeader } from "./BlockHeaderStore";
import { putBlock, setCanonicalHead } from "./BlockTree";
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

  it.effect("rejects invalid block numbers", () =>
    provideSpec(Hardfork.FRONTIER)(
      Effect.gen(function* () {
        const current = makeBlock({
          number: 2n,
          hash: blockHashFromByte(0x60),
          parentHash: blockHashFromByte(0x61),
        });

        const invalidNumber = -1n as unknown as Parameters<
          typeof getBlockhash
        >[1];
        const error = yield* Effect.flip(
          getBlockhash(current.header, invalidNumber),
        );
        assert.instanceOf(error, InvalidBlockhashNumberError);
      }),
    ),
  );

  it.effect("fails when block env hashes are missing ancestors", () =>
    provideSpec(Hardfork.FRONTIER)(
      Effect.gen(function* () {
        const current = makeBlock({
          number: 2n,
          hash: blockHashFromByte(0x62),
          parentHash: blockHashFromByte(0x63),
        });

        const error = yield* Effect.flip(getLast256BlockHashes(current.header));
        assert.instanceOf(error, MissingBlockhashError);
      }),
    ),
  );

  it.effect("resolves hashes on non-canonical branches", () =>
    provideSpec(Hardfork.FRONTIER)(
      Effect.gen(function* () {
        const genesis = makeBlock({
          number: 0n,
          hash: blockHashFromByte(0x70),
          parentHash: blockHashFromByte(0x00),
        });
        const blockA1 = makeBlock({
          number: 1n,
          hash: blockHashFromByte(0x71),
          parentHash: genesis.hash,
        });
        const blockA2 = makeBlock({
          number: 2n,
          hash: blockHashFromByte(0x72),
          parentHash: blockA1.hash,
        });
        const blockA3 = makeBlock({
          number: 3n,
          hash: blockHashFromByte(0x73),
          parentHash: blockA2.hash,
        });
        const blockB1 = makeBlock({
          number: 1n,
          hash: blockHashFromByte(0x81),
          parentHash: genesis.hash,
        });
        const blockB2 = makeBlock({
          number: 2n,
          hash: blockHashFromByte(0x82),
          parentHash: blockB1.hash,
        });
        const blockB3 = makeBlock({
          number: 3n,
          hash: blockHashFromByte(0x83),
          parentHash: blockB2.hash,
        });

        yield* putBlock(genesis);
        yield* putBlock(blockA1);
        yield* putBlock(blockA2);
        yield* putBlock(blockA3);
        yield* putBlock(blockB1);
        yield* putBlock(blockB2);
        yield* setCanonicalHead(blockA3.hash);

        const hash = yield* getBlockhash(
          blockB3.header,
          blockNumberFromBigInt(1n),
        );
        assert.isTrue(Option.isSome(hash));
        assert.strictEqual(
          Hex.fromBytes(Option.getOrThrow(hash)),
          Hex.fromBytes(blockB1.hash),
        );
      }),
    ),
  );

  it.effect("serves hashes from headers-only storage", () =>
    provideSpec(Hardfork.FRONTIER)(
      Effect.gen(function* () {
        const genesis = makeBlock({
          number: 0n,
          hash: blockHashFromByte(0x90),
          parentHash: blockHashFromByte(0x00),
        });
        const block1 = makeBlock({
          number: 1n,
          hash: blockHashFromByte(0x91),
          parentHash: genesis.hash,
        });
        const block2 = makeBlock({
          number: 2n,
          hash: blockHashFromByte(0x92),
          parentHash: block1.hash,
        });
        const current = makeBlock({
          number: 3n,
          hash: blockHashFromByte(0x93),
          parentHash: block2.hash,
        });

        yield* putHeader(genesis.hash, genesis.header);
        yield* putHeader(block1.hash, block1.header);
        yield* putHeader(block2.hash, block2.header);

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
