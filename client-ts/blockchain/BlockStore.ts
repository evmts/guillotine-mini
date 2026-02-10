import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import * as Schema from "effect/Schema";
import { Block, BlockHash, Hex } from "voltaire-effect/primitives";

/** Block type handled by the block store. */
export type BlockType = Block.BlockType;
/** Hash type for identifying blocks. */
export type BlockHashType = BlockHash.BlockHashType;

type BlockHashKey = string;

const BlockSchema = Block.Schema as unknown as Schema.Schema<
  BlockType,
  unknown
>;
const BlockHashSchema = BlockHash.Bytes as unknown as Schema.Schema<
  BlockHashType,
  Uint8Array
>;

/** Error raised when a block fails validation. */
export class InvalidBlockError extends Data.TaggedError("InvalidBlockError")<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Error raised when a block hash is invalid. */
export class InvalidBlockHashError extends Data.TaggedError(
  "InvalidBlockHashError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Union of block store errors. */
export type BlockStoreError = InvalidBlockError | InvalidBlockHashError;

/** Block store service interface (local block storage). */
export interface BlockStoreService {
  readonly getBlock: (
    hash: BlockHashType,
  ) => Effect.Effect<Option.Option<BlockType>, BlockStoreError>;
  readonly hasBlock: (
    hash: BlockHashType,
  ) => Effect.Effect<boolean, BlockStoreError>;
  readonly putBlock: (block: BlockType) => Effect.Effect<void, BlockStoreError>;
  readonly blockCount: () => Effect.Effect<number>;
}

/** Context tag for the block store service. */
export class BlockStore extends Context.Tag("BlockStore")<
  BlockStore,
  BlockStoreService
>() {}

const decodeBlock = (block: BlockType) =>
  Schema.decode(BlockSchema)(block).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidBlockError({
          message: "Invalid block",
          cause,
        }),
    ),
  );

const decodeBlockHash = (hash: BlockHashType) =>
  Schema.decode(BlockHashSchema)(hash).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidBlockHashError({
          message: "Invalid block hash",
          cause,
        }),
    ),
  );

const blockHashKey = (hash: BlockHashType): BlockHashKey => Hex.fromBytes(hash);

const makeBlockStore = Effect.gen(function* () {
  const state = yield* Effect.acquireRelease(
    Effect.sync(() => ({
      blocks: new Map<BlockHashKey, BlockType>(),
    })),
    (store) =>
      Effect.sync(() => {
        store.blocks.clear();
      }),
  );

  const getBlock = (hash: BlockHashType) =>
    Effect.gen(function* () {
      const validated = yield* decodeBlockHash(hash);
      return Option.fromNullable(state.blocks.get(blockHashKey(validated)));
    });

  const hasBlock = (hash: BlockHashType) =>
    Effect.gen(function* () {
      const validated = yield* decodeBlockHash(hash);
      return state.blocks.has(blockHashKey(validated));
    });

  const putBlock = (block: BlockType) =>
    Effect.gen(function* () {
      const validated = yield* decodeBlock(block);
      const blockKey = blockHashKey(validated.hash);

      if (state.blocks.has(blockKey)) {
        return;
      }

      state.blocks.set(blockKey, validated);
    });

  const blockCount = () => Effect.sync(() => state.blocks.size);

  return {
    getBlock,
    hasBlock,
    putBlock,
    blockCount,
  } satisfies BlockStoreService;
});

/** In-memory production block store layer. */
export const BlockStoreMemoryLive: Layer.Layer<BlockStore, BlockStoreError> =
  Layer.scoped(BlockStore, makeBlockStore);

/** In-memory deterministic block store layer for tests. */
export const BlockStoreMemoryTest: Layer.Layer<BlockStore, BlockStoreError> =
  Layer.scoped(BlockStore, makeBlockStore);

const withBlockStore = <A, E, R>(
  f: (service: BlockStoreService) => Effect.Effect<A, E, R>,
) => Effect.flatMap(BlockStore, f);

/** Retrieve a block by hash. */
export const getBlock = (hash: BlockHashType) =>
  withBlockStore((store) => store.getBlock(hash));

/** Check whether a block exists by hash. */
export const hasBlock = (hash: BlockHashType) =>
  withBlockStore((store) => store.hasBlock(hash));

/** Put a block into local storage. */
export const putBlock = (block: BlockType) =>
  withBlockStore((store) => store.putBlock(block));

/** Get the total count of stored blocks. */
export const blockCount = () => withBlockStore((store) => store.blockCount());
