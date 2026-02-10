import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import { Hex } from "voltaire-effect/primitives";
import {
  BlockhashProviderTest,
  MissingBlockhashError,
  getBlockhash,
} from "./BlockhashProvider";
import { putBlock } from "./BlockTree";
import {
  blockHashFromByte,
  blockNumberFromBigInt,
  makeBlock,
} from "./testUtils";

describe("BlockhashProvider", () => {
  it.effect("returns the parent hash for recent blocks", () =>
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
    }).pipe(Effect.provide(BlockhashProviderTest)),
  );

  it.effect("returns None for future or too-old requests", () =>
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
    }).pipe(Effect.provide(BlockhashProviderTest)),
  );

  it.effect("returns deeper ancestor hashes when available", () =>
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
    }).pipe(Effect.provide(BlockhashProviderTest)),
  );

  it.effect("fails when an ancestor is missing within range", () =>
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
    }).pipe(Effect.provide(BlockhashProviderTest)),
  );
});
