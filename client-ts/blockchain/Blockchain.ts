import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import * as Ref from "effect/Ref";
import { Block, BlockHash, BlockNumber, Hex } from "voltaire-effect/primitives";
import {
  BlockNotFoundError,
  BlockStore,
  type BlockStoreError,
  BlockStoreMemoryTest,
  CannotSetOrphanAsHeadError,
} from "./BlockStore";

export type BlockType = Block.BlockType;
export type BlockHashType = BlockHash.BlockHashType;
export type BlockNumberType = BlockNumber.BlockNumberType;

/** Error raised when genesis is already initialized. */
export class GenesisAlreadyInitializedError extends Data.TaggedError(
  "GenesisAlreadyInitializedError",
)<{
  readonly existing: BlockHashType;
}> {}

/** Error raised when genesis is missing for head operations. */
export class GenesisNotInitializedError extends Data.TaggedError(
  "GenesisNotInitializedError",
)<{}> {}

/** Error raised when a block fails genesis invariants. */
export class InvalidGenesisBlockError extends Data.TaggedError(
  "InvalidGenesisBlockError",
)<{
  readonly message: string;
}> {}

/** Error raised when the canonical chain does not resolve to genesis. */
export class CanonicalChainInvalidError extends Data.TaggedError(
  "CanonicalChainInvalidError",
)<{
  readonly head: BlockHashType;
  readonly message: string;
  readonly missingHash?: BlockHashType;
}> {}

/** Error raised when the canonical chain reaches a different genesis. */
export class GenesisMismatchError extends Data.TaggedError(
  "GenesisMismatchError",
)<{
  readonly expected: BlockHashType;
  readonly actual: BlockHashType;
}> {}

/** Union of blockchain errors. */
export type BlockchainError =
  | BlockStoreError
  | GenesisAlreadyInitializedError
  | GenesisNotInitializedError
  | InvalidGenesisBlockError
  | CanonicalChainInvalidError
  | GenesisMismatchError;

/** Blockchain service interface (chain manager). */
export interface BlockchainService {
  readonly getBlockByHash: (
    hash: BlockHashType,
  ) => Effect.Effect<Option.Option<BlockType>, BlockchainError>;
  readonly getBlockByNumber: (
    number: BlockNumberType,
  ) => Effect.Effect<Option.Option<BlockType>, BlockchainError>;
  readonly putBlock: (block: BlockType) => Effect.Effect<void, BlockchainError>;
  readonly setCanonicalHead: (
    hash: BlockHashType,
  ) => Effect.Effect<void, BlockchainError>;
  readonly initializeGenesis: (
    genesis: BlockType,
  ) => Effect.Effect<void, BlockchainError>;
  readonly getGenesis: () => Effect.Effect<
    Option.Option<BlockType>,
    BlockchainError
  >;
  readonly getHead: () => Effect.Effect<
    Option.Option<BlockType>,
    BlockchainError
  >;
}

/** Context tag for blockchain service. */
export class Blockchain extends Context.Tag("Blockchain")<
  Blockchain,
  BlockchainService
>() {}

type BlockchainState = {
  readonly genesisHash: Option.Option<BlockHashType>;
  readonly headHash: Option.Option<BlockHashType>;
  readonly headNumber: Option.Option<BlockNumberType>;
};

const ZERO_HASH_HEX = Hex.fromBytes(new Uint8Array(32));

const makeBlockchain = Effect.gen(function* () {
  const store = yield* BlockStore;
  const state = yield* Ref.make<BlockchainState>({
    genesisHash: Option.none(),
    headHash: Option.none(),
    headNumber: Option.none(),
  });

  const validateGenesisBlock = (genesis: BlockType) =>
    Effect.gen(function* () {
      const number = genesis.header.number as bigint;
      if (number !== 0n) {
        return yield* Effect.fail(
          new InvalidGenesisBlockError({
            message: "Genesis block number must be 0",
          }),
        );
      }

      if (Hex.fromBytes(genesis.header.parentHash) !== ZERO_HASH_HEX) {
        return yield* Effect.fail(
          new InvalidGenesisBlockError({
            message: "Genesis parent hash must be zero",
          }),
        );
      }
    });

  const ensureGenesisInitialized = () =>
    pipe(
      Ref.get(state),
      Effect.flatMap((current) =>
        Option.match(current.genesisHash, {
          onNone: () => Effect.fail(new GenesisNotInitializedError()),
          onSome: (hash) => Effect.succeed(hash),
        }),
      ),
    );

  const ensureCanonicalChain = (headHash: BlockHashType) =>
    Effect.gen(function* () {
      const genesisHash = yield* ensureGenesisInitialized();
      let currentHash = headHash;

      while (true) {
        const currentBlock = yield* store.getBlock(currentHash);
        if (Option.isNone(currentBlock)) {
          return yield* Effect.fail(
            new BlockNotFoundError({ hash: currentHash }),
          );
        }

        const block = Option.getOrThrow(currentBlock);
        const number = block.header.number as bigint;

        if (number === 0n) {
          if (Hex.fromBytes(block.hash) !== Hex.fromBytes(genesisHash)) {
            return yield* Effect.fail(
              new GenesisMismatchError({
                expected: genesisHash,
                actual: block.hash,
              }),
            );
          }
          return;
        }

        const parentHash = block.header.parentHash;
        const parentBlock = yield* store.getBlock(parentHash);
        if (Option.isNone(parentBlock)) {
          return yield* Effect.fail(
            new CanonicalChainInvalidError({
              head: headHash,
              message: "Missing ancestor while walking canonical chain",
              missingHash: parentHash,
            }),
          );
        }

        const parent = Option.getOrThrow(parentBlock);
        const parentNumber = parent.header.number as bigint;
        if (parentNumber !== number - 1n) {
          return yield* Effect.fail(
            new CanonicalChainInvalidError({
              head: headHash,
              message: "Non-contiguous block numbers in canonical chain",
            }),
          );
        }

        currentHash = parentHash;
      }
    });

  const getBlockByHash = (hash: BlockHashType) => store.getBlock(hash);

  const getBlockByNumber = (number: BlockNumberType) =>
    store.getBlockByNumber(number);

  const putBlock = (block: BlockType) => store.putBlock(block);

  const initializeGenesis = (genesis: BlockType) =>
    Effect.gen(function* () {
      const current = yield* Ref.get(state);
      if (Option.isSome(current.genesisHash)) {
        return yield* Effect.fail(
          new GenesisAlreadyInitializedError({
            existing: Option.getOrThrow(current.genesisHash),
          }),
        );
      }

      yield* validateGenesisBlock(genesis);
      yield* store.putBlock(genesis);
      yield* store.setCanonicalHead(genesis.hash);
      yield* Ref.set(state, {
        genesisHash: Option.some(genesis.hash),
        headHash: Option.some(genesis.hash),
        headNumber: Option.some(genesis.header.number),
      });
    });

  const getGenesis = () =>
    Effect.gen(function* () {
      const current = yield* Ref.get(state);
      if (Option.isNone(current.genesisHash)) {
        return Option.none();
      }

      return yield* store.getBlock(Option.getOrThrow(current.genesisHash));
    });

  const getHead = () =>
    Effect.gen(function* () {
      const current = yield* Ref.get(state);
      if (Option.isNone(current.headHash)) {
        return Option.none();
      }

      return yield* store.getBlock(Option.getOrThrow(current.headHash));
    });

  const setCanonicalHead = (hash: BlockHashType) =>
    Effect.gen(function* () {
      const orphaned = yield* store.isOrphan(hash);
      if (orphaned) {
        return yield* Effect.fail(new CannotSetOrphanAsHeadError({ hash }));
      }

      yield* ensureCanonicalChain(hash);
      yield* store.setCanonicalHead(hash);

      const headBlock = yield* store.getBlock(hash);
      if (Option.isNone(headBlock)) {
        return yield* Effect.fail(new BlockNotFoundError({ hash }));
      }

      const head = Option.getOrThrow(headBlock);
      yield* Ref.update(state, (current) => ({
        ...current,
        headHash: Option.some(hash),
        headNumber: Option.some(head.header.number),
      }));
    });

  return {
    getBlockByHash,
    getBlockByNumber,
    putBlock,
    setCanonicalHead,
    initializeGenesis,
    getGenesis,
    getHead,
  } satisfies BlockchainService;
});

/** Production blockchain layer. */
export const BlockchainLive: Layer.Layer<Blockchain, never, BlockStore> =
  Layer.effect(Blockchain, makeBlockchain);

/** Deterministic blockchain layer for tests. */
export const BlockchainTest = BlockchainLive.pipe(
  Layer.provide(BlockStoreMemoryTest),
);

const withBlockchain = <A, E>(
  f: (service: BlockchainService) => Effect.Effect<A, E>,
) => Effect.flatMap(Blockchain, f);

/** Retrieve a block by hash. */
export const getBlockByHash = (hash: BlockHashType) =>
  withBlockchain((service) => service.getBlockByHash(hash));

/** Retrieve a canonical block by number. */
export const getBlockByNumber = (number: BlockNumberType) =>
  withBlockchain((service) => service.getBlockByNumber(number));

/** Put a block into local storage. */
export const putBlock = (block: BlockType) =>
  withBlockchain((service) => service.putBlock(block));

/** Set the canonical head hash. */
export const setCanonicalHead = (hash: BlockHashType) =>
  withBlockchain((service) => service.setCanonicalHead(hash));

/** Initialize genesis and set head to genesis. */
export const initializeGenesis = (genesis: BlockType) =>
  withBlockchain((service) => service.initializeGenesis(genesis));

/** Retrieve the genesis block if initialized. */
export const getGenesis = () =>
  withBlockchain((service) => service.getGenesis());

/** Retrieve the canonical head block if set. */
export const getHead = () => withBlockchain((service) => service.getHead());
