import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import * as PubSub from "effect/PubSub";
import * as Ref from "effect/Ref";
import * as Schema from "effect/Schema";
import type * as Queue from "effect/Queue";
import type * as Scope from "effect/Scope";
import { Block, BlockHash, BlockNumber, Hex } from "voltaire-effect/primitives";
import {
  BlockNotFoundError,
  BlockTree,
  type BlockTreeError,
  BlockTreeMemoryTest,
} from "./BlockTree";

/** Block type used by the blockchain service. */
export type BlockType = Block.BlockType;
/** Hash type for identifying blocks. */
export type BlockHashType = BlockHash.BlockHashType;
/** Block number type used for chain state. */
export type BlockNumberType = BlockNumber.BlockNumberType;

/** Current fork-choice pointers. */
export type ForkChoiceState = {
  readonly head: Option.Option<BlockHashType>;
  readonly safe: Option.Option<BlockHashType>;
  readonly finalized: Option.Option<BlockHashType>;
};

/** Fork-choice update request. */
export type ForkChoiceUpdate = {
  readonly head: BlockHashType;
  readonly safe: Option.Option<BlockHashType>;
  readonly finalized: Option.Option<BlockHashType>;
};

/** Blockchain event emitted by the chain manager. */
export type BlockchainEvent =
  | {
      readonly _tag: "GenesisInitialized";
      readonly block: BlockType;
    }
  | {
      readonly _tag: "BlockSuggested";
      readonly block: BlockType;
    }
  | {
      readonly _tag: "BestSuggestedBlock";
      readonly block: BlockType;
    }
  | {
      readonly _tag: "CanonicalHeadUpdated";
      readonly block: BlockType;
    }
  | {
      readonly _tag: "ForkChoiceUpdated";
      readonly update: ForkChoiceUpdate;
    };

/** Constructors for blockchain events. */
export const BlockchainEvent = {
  genesisInitialized: (block: BlockType): BlockchainEvent => ({
    _tag: "GenesisInitialized",
    block,
  }),
  blockSuggested: (block: BlockType): BlockchainEvent => ({
    _tag: "BlockSuggested",
    block,
  }),
  bestSuggestedBlock: (block: BlockType): BlockchainEvent => ({
    _tag: "BestSuggestedBlock",
    block,
  }),
  canonicalHeadUpdated: (block: BlockType): BlockchainEvent => ({
    _tag: "CanonicalHeadUpdated",
    block,
  }),
  forkChoiceUpdated: (update: ForkChoiceUpdate): BlockchainEvent => ({
    _tag: "ForkChoiceUpdated",
    update,
  }),
} as const;

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
  | BlockTreeError
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
  readonly getCanonicalHash: (
    number: BlockNumberType,
  ) => Effect.Effect<Option.Option<BlockHashType>, BlockchainError>;
  readonly putBlock: (block: BlockType) => Effect.Effect<void, BlockchainError>;
  readonly insertBlock: (
    block: BlockType,
  ) => Effect.Effect<void, BlockchainError>;
  readonly suggestBlock: (
    block: BlockType,
  ) => Effect.Effect<void, BlockchainError>;
  readonly setCanonicalHead: (
    hash: BlockHashType,
  ) => Effect.Effect<void, BlockchainError>;
  readonly initializeGenesis: (
    genesis: BlockType,
  ) => Effect.Effect<void, BlockchainError>;
  readonly getBestKnownNumber: () => Effect.Effect<
    Option.Option<BlockNumberType>,
    BlockchainError
  >;
  readonly getBestSuggestedBlock: () => Effect.Effect<
    Option.Option<BlockType>,
    BlockchainError
  >;
  readonly getGenesis: () => Effect.Effect<
    Option.Option<BlockType>,
    BlockchainError
  >;
  readonly getHead: () => Effect.Effect<
    Option.Option<BlockType>,
    BlockchainError
  >;
  readonly getForkChoiceState: () => Effect.Effect<
    ForkChoiceState,
    BlockchainError
  >;
  readonly forkChoiceUpdated: (
    update: ForkChoiceUpdate,
  ) => Effect.Effect<void, BlockchainError>;
  readonly subscribe: () => Effect.Effect<
    Queue.Dequeue<BlockchainEvent>,
    never,
    Scope.Scope
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
  readonly bestKnownNumber: Option.Option<BlockNumberType>;
  readonly bestSuggestedHash: Option.Option<BlockHashType>;
  readonly bestSuggestedNumber: Option.Option<BlockNumberType>;
  readonly forkChoice: ForkChoiceState;
};

const ZERO_HASH_HEX = Hex.fromBytes(new Uint8Array(32));
const EMPTY_FORK_CHOICE: ForkChoiceState = {
  head: Option.none(),
  safe: Option.none(),
  finalized: Option.none(),
};
const BlockNumberBigIntSchema = BlockNumber.BigInt as unknown as Schema.Schema<
  BlockNumberType,
  bigint
>;

const makeBlockchain = Effect.gen(function* () {
  const store = yield* BlockTree;
  const events = yield* Effect.acquireRelease(
    PubSub.unbounded<BlockchainEvent>(),
    (pubsub) => PubSub.shutdown(pubsub),
  );
  const state = yield* Ref.make<BlockchainState>({
    genesisHash: Option.none(),
    headHash: Option.none(),
    headNumber: Option.none(),
    bestKnownNumber: Option.none(),
    bestSuggestedHash: Option.none(),
    bestSuggestedNumber: Option.none(),
    forkChoice: EMPTY_FORK_CHOICE,
  });

  const publishEvent = (event: BlockchainEvent) =>
    PubSub.publish(events, event).pipe(Effect.asVoid);

  const validateGenesisBlock = (genesis: BlockType) =>
    Effect.gen(function* () {
      const number = Schema.encodeSync(BlockNumberBigIntSchema)(
        genesis.header.number,
      );
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
        const number = Schema.encodeSync(BlockNumberBigIntSchema)(
          block.header.number,
        );

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
        const parentNumber = Schema.encodeSync(BlockNumberBigIntSchema)(
          parent.header.number,
        );
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

  const toBigInt = (number: BlockNumberType) =>
    Schema.encodeSync(BlockNumberBigIntSchema)(number);

  const updateBestKnownNumber = (number: BlockNumberType) =>
    Ref.update(state, (current) => {
      const shouldUpdate = Option.match(current.bestKnownNumber, {
        onNone: () => true,
        onSome: (existing) => toBigInt(number) > toBigInt(existing),
      });
      return shouldUpdate
        ? { ...current, bestKnownNumber: Option.some(number) }
        : current;
    });

  const updateBestSuggestedBlock = (block: BlockType) =>
    Ref.modify(state, (current) => {
      const shouldUpdate = Option.match(current.bestSuggestedNumber, {
        onNone: () => true,
        onSome: (existing) =>
          toBigInt(block.header.number) > toBigInt(existing),
      });
      const next = shouldUpdate
        ? {
            ...current,
            bestSuggestedHash: Option.some(block.hash),
            bestSuggestedNumber: Option.some(block.header.number),
          }
        : current;
      return [shouldUpdate, next] as const;
    });

  const getBlockFromHashOption = (hash: Option.Option<BlockHashType>) =>
    Option.match(hash, {
      onNone: () => Effect.succeed(Option.none()),
      onSome: (value) => store.getBlock(value),
    });

  const getBlockByHash = (hash: BlockHashType) => store.getBlock(hash);

  const getBlockByNumber = (number: BlockNumberType) =>
    store.getBlockByNumber(number);

  const getCanonicalHash = (number: BlockNumberType) =>
    store.getCanonicalHash(number);

  const getBestKnownNumber = () =>
    Ref.get(state).pipe(Effect.map((current) => current.bestKnownNumber));

  const getBestSuggestedBlock = () =>
    Ref.get(state).pipe(
      Effect.flatMap((current) =>
        getBlockFromHashOption(current.bestSuggestedHash),
      ),
    );

  const putBlock = (block: BlockType) =>
    Effect.gen(function* () {
      yield* store.putBlock(block);
      yield* updateBestKnownNumber(block.header.number);
    });

  const insertBlock = (block: BlockType) => putBlock(block);

  const suggestBlock = (block: BlockType) =>
    Effect.gen(function* () {
      yield* putBlock(block);
      yield* publishEvent(BlockchainEvent.blockSuggested(block));
      const updated = yield* updateBestSuggestedBlock(block);
      if (updated) {
        yield* publishEvent(BlockchainEvent.bestSuggestedBlock(block));
      }
    });

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
        bestKnownNumber: Option.some(genesis.header.number),
        bestSuggestedHash: Option.none(),
        bestSuggestedNumber: Option.none(),
        forkChoice: {
          head: Option.some(genesis.hash),
          safe: Option.none(),
          finalized: Option.none(),
        },
      });
      yield* publishEvent(BlockchainEvent.genesisInitialized(genesis));
      yield* publishEvent(BlockchainEvent.canonicalHeadUpdated(genesis));
    });

  const getGenesis = () =>
    Ref.get(state).pipe(
      Effect.flatMap((current) => getBlockFromHashOption(current.genesisHash)),
    );

  const getHead = () =>
    Ref.get(state).pipe(
      Effect.flatMap((current) => getBlockFromHashOption(current.headHash)),
    );

  const getForkChoiceState = () =>
    Ref.get(state).pipe(Effect.map((current) => current.forkChoice));

  const forkChoiceUpdated = (update: ForkChoiceUpdate) =>
    Effect.gen(function* () {
      yield* ensureGenesisInitialized();

      const headExists = yield* store.hasBlock(update.head);
      if (!headExists) {
        return yield* Effect.fail(
          new BlockNotFoundError({ hash: update.head }),
        );
      }

      yield* ensureCanonicalChain(update.head);

      if (Option.isSome(update.safe)) {
        const safeHash = Option.getOrThrow(update.safe);
        const safeExists = yield* store.hasBlock(safeHash);
        if (!safeExists) {
          return yield* Effect.fail(new BlockNotFoundError({ hash: safeHash }));
        }
      }

      if (Option.isSome(update.finalized)) {
        const finalizedHash = Option.getOrThrow(update.finalized);
        const finalizedExists = yield* store.hasBlock(finalizedHash);
        if (!finalizedExists) {
          return yield* Effect.fail(
            new BlockNotFoundError({ hash: finalizedHash }),
          );
        }
      }

      yield* Ref.update(state, (current) => ({
        ...current,
        forkChoice: {
          head: Option.some(update.head),
          safe: update.safe,
          finalized: update.finalized,
        },
      }));

      yield* publishEvent(BlockchainEvent.forkChoiceUpdated(update));
    });

  const subscribe = () => PubSub.subscribe(events);

  const setCanonicalHead = (hash: BlockHashType) =>
    Effect.gen(function* () {
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
        forkChoice: {
          ...current.forkChoice,
          head: Option.some(hash),
        },
      }));
      yield* updateBestKnownNumber(head.header.number);
      yield* publishEvent(BlockchainEvent.canonicalHeadUpdated(head));
    });

  return {
    getBlockByHash,
    getBlockByNumber,
    getCanonicalHash,
    putBlock,
    insertBlock,
    suggestBlock,
    setCanonicalHead,
    initializeGenesis,
    getBestKnownNumber,
    getBestSuggestedBlock,
    getGenesis,
    getHead,
    getForkChoiceState,
    forkChoiceUpdated,
    subscribe,
  } satisfies BlockchainService;
});

/** Production blockchain layer. */
export const BlockchainLive: Layer.Layer<Blockchain, never, BlockTree> =
  Layer.scoped(Blockchain, makeBlockchain);

/** Deterministic blockchain layer for tests. */
export const BlockchainTest = BlockchainLive.pipe(
  Layer.provide(BlockTreeMemoryTest),
);

const withBlockchain = <A, E, R>(
  f: (service: BlockchainService) => Effect.Effect<A, E, R>,
) => Effect.flatMap(Blockchain, f);

/** Retrieve a block by hash. */
export const getBlockByHash = (hash: BlockHashType) =>
  withBlockchain((service) => service.getBlockByHash(hash));

/** Retrieve a canonical block by number. */
export const getBlockByNumber = (number: BlockNumberType) =>
  withBlockchain((service) => service.getBlockByNumber(number));

/** Retrieve the canonical block hash by number. */
export const getCanonicalHash = (number: BlockNumberType) =>
  withBlockchain((service) => service.getCanonicalHash(number));

/** Put a block into local storage. */
export const putBlock = (block: BlockType) =>
  withBlockchain((service) => service.putBlock(block));

/** Insert a block into local storage. */
export const insertBlock = (block: BlockType) =>
  withBlockchain((service) => service.insertBlock(block));

/** Suggest a block for inclusion. */
export const suggestBlock = (block: BlockType) =>
  withBlockchain((service) => service.suggestBlock(block));

/** Set the canonical head hash. */
export const setCanonicalHead = (hash: BlockHashType) =>
  withBlockchain((service) => service.setCanonicalHead(hash));

/** Initialize genesis and set head to genesis. */
export const initializeGenesis = (genesis: BlockType) =>
  withBlockchain((service) => service.initializeGenesis(genesis));

/** Retrieve the highest known block number. */
export const getBestKnownNumber = () =>
  withBlockchain((service) => service.getBestKnownNumber());

/** Retrieve the best suggested block, if any. */
export const getBestSuggestedBlock = () =>
  withBlockchain((service) => service.getBestSuggestedBlock());

/** Retrieve the genesis block if initialized. */
export const getGenesis = () =>
  withBlockchain((service) => service.getGenesis());

/** Retrieve the canonical head block if set. */
export const getHead = () => withBlockchain((service) => service.getHead());

/** Retrieve fork-choice metadata. */
export const getForkChoiceState = () =>
  withBlockchain((service) => service.getForkChoiceState());

/** Update fork-choice metadata. */
export const forkChoiceUpdated = (update: ForkChoiceUpdate) =>
  withBlockchain((service) => service.forkChoiceUpdated(update));

/** Subscribe to blockchain events. */
export const subscribeEvents = () =>
  withBlockchain((service) => service.subscribe());
