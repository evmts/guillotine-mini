import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import { Hex } from "voltaire-effect/primitives";
import {
  BlockchainTest,
  CanonicalChainInvalidError,
  GenesisAlreadyInitializedError,
  GenesisMismatchError,
  GenesisNotInitializedError,
  InvalidGenesisBlockError,
  getBlockByHash,
  getBlockByNumber,
  getHead,
  initializeGenesis,
  putBlock,
  setCanonicalHead,
} from "./Blockchain";
import { BlockNotFoundError } from "./BlockTree";
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

  it.effect("initializeGenesis sets head and prevents re-initialization", () =>
    Effect.gen(function* () {
      const genesis = makeBlock({
        number: 0n,
        hash: blockHashFromByte(0x20),
        parentHash: blockHashFromByte(0x00),
      });

      const before = yield* getHead();
      assert.isTrue(Option.isNone(before));

      yield* initializeGenesis(genesis);

      const after = yield* getHead();
      assert.isTrue(Option.isSome(after));
      assert.strictEqual(
        Hex.fromBytes(Option.getOrThrow(after).hash),
        Hex.fromBytes(genesis.hash),
      );

      const error = yield* Effect.flip(initializeGenesis(genesis));
      assert.instanceOf(error, GenesisAlreadyInitializedError);
    }).pipe(Effect.provide(BlockchainTest)),
  );

  it.effect("initializeGenesis rejects invalid genesis blocks", () =>
    Effect.gen(function* () {
      const invalidNumber = makeBlock({
        number: 1n,
        hash: blockHashFromByte(0x30),
        parentHash: blockHashFromByte(0x00),
      });

      const invalidParent = makeBlock({
        number: 0n,
        hash: blockHashFromByte(0x31),
        parentHash: blockHashFromByte(0x99),
      });

      const numberError = yield* Effect.flip(initializeGenesis(invalidNumber));
      assert.instanceOf(numberError, InvalidGenesisBlockError);

      const parentError = yield* Effect.flip(initializeGenesis(invalidParent));
      assert.instanceOf(parentError, InvalidGenesisBlockError);
    }).pipe(Effect.provide(BlockchainTest)),
  );

  it.effect("setCanonicalHead fails without genesis", () =>
    Effect.gen(function* () {
      const genesis = makeBlock({
        number: 0n,
        hash: blockHashFromByte(0x40),
        parentHash: blockHashFromByte(0x00),
      });

      yield* putBlock(genesis);

      const error = yield* Effect.flip(setCanonicalHead(genesis.hash));
      assert.instanceOf(error, GenesisNotInitializedError);
    }).pipe(Effect.provide(BlockchainTest)),
  );

  it.effect("setCanonicalHead fails for missing or orphan blocks", () =>
    Effect.gen(function* () {
      const genesis = makeBlock({
        number: 0n,
        hash: blockHashFromByte(0x50),
        parentHash: blockHashFromByte(0x00),
      });

      yield* initializeGenesis(genesis);

      const missingHash = blockHashFromByte(0x51);
      const missingError = yield* Effect.flip(setCanonicalHead(missingHash));
      assert.instanceOf(missingError, BlockNotFoundError);

      const orphan = makeBlock({
        number: 1n,
        hash: blockHashFromByte(0x52),
        parentHash: blockHashFromByte(0xff),
      });

      yield* putBlock(orphan);

      const orphanError = yield* Effect.flip(setCanonicalHead(orphan.hash));
      assert.instanceOf(orphanError, CanonicalChainInvalidError);
    }).pipe(Effect.provide(BlockchainTest)),
  );

  it.effect(
    "setCanonicalHead fails when chain does not resolve to genesis",
    () =>
      Effect.gen(function* () {
        const genesisA = makeBlock({
          number: 0n,
          hash: blockHashFromByte(0x60),
          parentHash: blockHashFromByte(0x00),
        });
        const genesisB = makeBlock({
          number: 0n,
          hash: blockHashFromByte(0x61),
          parentHash: blockHashFromByte(0x00),
        });
        const block1 = makeBlock({
          number: 1n,
          hash: blockHashFromByte(0x62),
          parentHash: genesisB.hash,
        });

        yield* initializeGenesis(genesisA);
        yield* putBlock(genesisB);
        yield* putBlock(block1);

        const error = yield* Effect.flip(setCanonicalHead(block1.hash));
        assert.instanceOf(error, GenesisMismatchError);
      }).pipe(Effect.provide(BlockchainTest)),
  );
});
