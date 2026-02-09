import * as Context from "effect/Context";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import { Block, BlockHash, BlockNumber } from "voltaire-effect/primitives";
import {
  BlockStore,
  type BlockStoreError,
  BlockStoreMemoryTest,
} from "./BlockStore";

export type BlockType = Block.BlockType;
export type BlockHashType = BlockHash.BlockHashType;
export type BlockNumberType = BlockNumber.BlockNumberType;

/** Union of blockchain errors. */
export type BlockchainError = BlockStoreError;

/** Blockchain service interface (minimal chain wrapper). */
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
}

/** Context tag for blockchain service. */
export class Blockchain extends Context.Tag("Blockchain")<
  Blockchain,
  BlockchainService
>() {}

const makeBlockchain = Effect.gen(function* () {
  const store = yield* BlockStore;

  const getBlockByHash = (hash: BlockHashType) => store.getBlock(hash);

  const getBlockByNumber = (number: BlockNumberType) =>
    store.getBlockByNumber(number);

  const putBlock = (block: BlockType) => store.putBlock(block);

  const setCanonicalHead = (hash: BlockHashType) =>
    store.setCanonicalHead(hash);

  return {
    getBlockByHash,
    getBlockByNumber,
    putBlock,
    setCanonicalHead,
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
