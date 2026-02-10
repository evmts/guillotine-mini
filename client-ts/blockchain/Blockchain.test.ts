import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Option from "effect/Option";
import * as Queue from "effect/Queue";
import { Hex } from "voltaire-effect/primitives";
import {
  BlockchainTest,
  CanonicalChainInvalidError,
  ForkChoiceStateInconsistentError,
  GenesisAlreadyInitializedError,
  GenesisMismatchError,
  GenesisNotInitializedError,
  InvalidGenesisBlockError,
  forkChoiceUpdated,
  getBestKnownNumber,
  getBestSuggestedBlock,
  getForkChoiceState,
  getGenesis,
  getCanonicalHash,
  getBlockByHash,
  getBlockByNumber,
  getHead,
  hasBlock,
  insertBlock,
  initializeGenesis,
  putBlock,
  setCanonicalHead,
  subscribeEvents,
  suggestBlock,
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

  it.effect("hasBlock returns true for existing blocks", () =>
    Effect.gen(function* () {
      const block = makeBlock({
        number: 0n,
        hash: blockHashFromByte(0x03),
        parentHash: blockHashFromByte(0x00),
      });

      yield* putBlock(block);

      assert.isTrue(yield* hasBlock(block.hash));
    }).pipe(Effect.provide(BlockchainTest)),
  );

  it.effect("hasBlock returns false for missing blocks", () =>
    Effect.gen(function* () {
      const missing = blockHashFromByte(0x04);
      assert.isFalse(yield* hasBlock(missing));
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

  it.effect(
    "getCanonicalHash returns canonical hash and None for missing level",
    () =>
      Effect.gen(function* () {
        const genesis = makeBlock({
          number: 0n,
          hash: blockHashFromByte(0x12),
          parentHash: blockHashFromByte(0x00),
        });
        const block1 = makeBlock({
          number: 1n,
          hash: blockHashFromByte(0x13),
          parentHash: genesis.hash,
        });

        yield* initializeGenesis(genesis);
        yield* putBlock(block1);
        yield* setCanonicalHead(block1.hash);

        const canonical = yield* getCanonicalHash(block1.header.number);
        assert.isTrue(Option.isSome(canonical));
        assert.strictEqual(
          Hex.fromBytes(Option.getOrThrow(canonical)),
          Hex.fromBytes(block1.hash),
        );

        const missingNumber = 42n as unknown as typeof block1.header.number;
        const missing = yield* getCanonicalHash(missingNumber);
        assert.isTrue(Option.isNone(missing));
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

  it.effect("insertBlock stores blocks and updates best known number", () =>
    Effect.gen(function* () {
      const block = makeBlock({
        number: 3n,
        hash: blockHashFromByte(0x70),
        parentHash: blockHashFromByte(0x01),
      });

      yield* insertBlock(block);

      const byHash = yield* getBlockByHash(block.hash);
      assert.isTrue(Option.isSome(byHash));

      const bestKnown = yield* getBestKnownNumber();
      assert.isTrue(Option.isSome(bestKnown));
      assert.strictEqual(Option.getOrThrow(bestKnown), block.header.number);
    }).pipe(Effect.provide(BlockchainTest)),
  );

  it.effect("suggestBlock updates best suggested block and emits events", () =>
    Effect.gen(function* () {
      const genesis = makeBlock({
        number: 0n,
        hash: blockHashFromByte(0x71),
        parentHash: blockHashFromByte(0x00),
      });
      const block1 = makeBlock({
        number: 1n,
        hash: blockHashFromByte(0x72),
        parentHash: genesis.hash,
      });
      const block2 = makeBlock({
        number: 2n,
        hash: blockHashFromByte(0x73),
        parentHash: block1.hash,
      });

      yield* initializeGenesis(genesis);
      const queue = yield* subscribeEvents();

      yield* suggestBlock(block1);
      yield* suggestBlock(block2);

      const first = yield* Queue.take(queue);
      const second = yield* Queue.take(queue);
      const third = yield* Queue.take(queue);
      const fourth = yield* Queue.take(queue);

      assert.strictEqual(first._tag, "BlockSuggested");
      assert.strictEqual(second._tag, "BestSuggestedBlock");
      assert.strictEqual(third._tag, "BlockSuggested");
      assert.strictEqual(fourth._tag, "BestSuggestedBlock");

      const bestSuggested = yield* getBestSuggestedBlock();
      assert.isTrue(Option.isSome(bestSuggested));
      assert.strictEqual(
        Hex.fromBytes(Option.getOrThrow(bestSuggested).hash),
        Hex.fromBytes(block2.hash),
      );
    }).pipe(Effect.scoped, Effect.provide(BlockchainTest)),
  );

  it.effect("getGenesis returns None before init and Some after init", () =>
    Effect.gen(function* () {
      const genesis = makeBlock({
        number: 0n,
        hash: blockHashFromByte(0x74),
        parentHash: blockHashFromByte(0x00),
      });

      const before = yield* getGenesis();
      assert.isTrue(Option.isNone(before));

      yield* initializeGenesis(genesis);

      const after = yield* getGenesis();
      assert.isTrue(Option.isSome(after));
      assert.strictEqual(
        Hex.fromBytes(Option.getOrThrow(after).hash),
        Hex.fromBytes(genesis.hash),
      );
    }).pipe(Effect.provide(BlockchainTest)),
  );

  it.effect("forkChoiceUpdated applies canonical head and updates state", () =>
    Effect.gen(function* () {
      const genesis = makeBlock({
        number: 0n,
        hash: blockHashFromByte(0x75),
        parentHash: blockHashFromByte(0x00),
      });
      const block1 = makeBlock({
        number: 1n,
        hash: blockHashFromByte(0x76),
        parentHash: genesis.hash,
      });
      const block2 = makeBlock({
        number: 2n,
        hash: blockHashFromByte(0x77),
        parentHash: block1.hash,
      });

      yield* initializeGenesis(genesis);
      yield* putBlock(block1);
      yield* putBlock(block2);

      yield* forkChoiceUpdated({
        head: block2.hash,
        safe: Option.some(block1.hash),
        finalized: Option.some(genesis.hash),
      });

      const head = yield* getHead();
      assert.isTrue(Option.isSome(head));
      assert.strictEqual(
        Hex.fromBytes(Option.getOrThrow(head).hash),
        Hex.fromBytes(block2.hash),
      );

      const canonicalNumberTwo = yield* getBlockByNumber(block2.header.number);
      assert.isTrue(Option.isSome(canonicalNumberTwo));
      assert.strictEqual(
        Hex.fromBytes(Option.getOrThrow(canonicalNumberTwo).hash),
        Hex.fromBytes(block2.hash),
      );

      const forkChoice = yield* getForkChoiceState();
      assert.isTrue(Option.isSome(forkChoice.head));
      assert.isTrue(Option.isSome(forkChoice.safe));
      assert.isTrue(Option.isSome(forkChoice.finalized));
      assert.strictEqual(
        Hex.fromBytes(Option.getOrThrow(forkChoice.head)),
        Hex.fromBytes(block2.hash),
      );
      assert.strictEqual(
        Hex.fromBytes(Option.getOrThrow(forkChoice.safe)),
        Hex.fromBytes(block1.hash),
      );
      assert.strictEqual(
        Hex.fromBytes(Option.getOrThrow(forkChoice.finalized)),
        Hex.fromBytes(genesis.hash),
      );
    }).pipe(Effect.provide(BlockchainTest)),
  );

  it.effect(
    "forkChoiceUpdated rejects safe/finalized hashes that are off the head chain",
    () =>
      Effect.gen(function* () {
        const genesis = makeBlock({
          number: 0n,
          hash: blockHashFromByte(0x78),
          parentHash: blockHashFromByte(0x00),
        });
        const headParent = makeBlock({
          number: 1n,
          hash: blockHashFromByte(0x79),
          parentHash: genesis.hash,
        });
        const head = makeBlock({
          number: 2n,
          hash: blockHashFromByte(0x7a),
          parentHash: headParent.hash,
        });
        const forkParent = makeBlock({
          number: 1n,
          hash: blockHashFromByte(0x7b),
          parentHash: genesis.hash,
        });
        const forkHead = makeBlock({
          number: 2n,
          hash: blockHashFromByte(0x7c),
          parentHash: forkParent.hash,
        });

        yield* initializeGenesis(genesis);
        yield* putBlock(headParent);
        yield* putBlock(head);
        yield* putBlock(forkParent);
        yield* putBlock(forkHead);

        const safeError = yield* Effect.flip(
          forkChoiceUpdated({
            head: head.hash,
            safe: Option.some(forkParent.hash),
            finalized: Option.some(genesis.hash),
          }),
        );
        assert.instanceOf(safeError, ForkChoiceStateInconsistentError);

        const finalizedError = yield* Effect.flip(
          forkChoiceUpdated({
            head: head.hash,
            safe: Option.some(headParent.hash),
            finalized: Option.some(forkHead.hash),
          }),
        );
        assert.instanceOf(finalizedError, ForkChoiceStateInconsistentError);
      }).pipe(Effect.provide(BlockchainTest)),
  );

  it.effect("subscribeEvents emits canonical and forkchoice updates", () =>
    Effect.gen(function* () {
      const genesis = makeBlock({
        number: 0n,
        hash: blockHashFromByte(0x7d),
        parentHash: blockHashFromByte(0x00),
      });
      const block1 = makeBlock({
        number: 1n,
        hash: blockHashFromByte(0x7e),
        parentHash: genesis.hash,
      });

      yield* initializeGenesis(genesis);
      yield* putBlock(block1);

      const queue = yield* subscribeEvents();
      yield* forkChoiceUpdated({
        head: block1.hash,
        safe: Option.some(genesis.hash),
        finalized: Option.none(),
      });

      const canonicalEvent = yield* Queue.take(queue);
      const forkChoiceEvent = yield* Queue.take(queue);
      assert.strictEqual(canonicalEvent._tag, "CanonicalHeadUpdated");
      assert.strictEqual(forkChoiceEvent._tag, "ForkChoiceUpdated");
    }).pipe(Effect.scoped, Effect.provide(BlockchainTest)),
  );
});
