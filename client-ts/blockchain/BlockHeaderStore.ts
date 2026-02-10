import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import * as Schema from "effect/Schema";
import { BlockHash, BlockHeader, Hex } from "voltaire-effect/primitives";

/** Block header type handled by the header store. */
export type BlockHeaderType = BlockHeader.BlockHeaderType;
/** Hash type for identifying headers. */
export type BlockHashType = BlockHash.BlockHashType;

type BlockHashKey = string;

const BlockHeaderSchema = BlockHeader.Schema as unknown as Schema.Schema<
  BlockHeaderType,
  unknown
>;
const BlockHashSchema = BlockHash.Bytes as unknown as Schema.Schema<
  BlockHashType,
  Uint8Array
>;

/** Error raised when a header fails validation. */
export class InvalidBlockHeaderError extends Data.TaggedError(
  "InvalidBlockHeaderError",
)<{
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

/** Union of header store errors. */
export type BlockHeaderStoreError =
  | InvalidBlockHeaderError
  | InvalidBlockHashError;

/** Block header store service interface. */
export interface BlockHeaderStoreService {
  readonly getHeader: (
    hash: BlockHashType,
  ) => Effect.Effect<Option.Option<BlockHeaderType>, BlockHeaderStoreError>;
  readonly hasHeader: (
    hash: BlockHashType,
  ) => Effect.Effect<boolean, BlockHeaderStoreError>;
  readonly putHeader: (
    hash: BlockHashType,
    header: BlockHeaderType,
  ) => Effect.Effect<void, BlockHeaderStoreError>;
  readonly headerCount: () => Effect.Effect<number>;
}

/** Context tag for the block header store service. */
export class BlockHeaderStore extends Context.Tag("BlockHeaderStore")<
  BlockHeaderStore,
  BlockHeaderStoreService
>() {}

const decodeHeader = (header: BlockHeaderType) =>
  Schema.decode(BlockHeaderSchema)(header).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidBlockHeaderError({
          message: "Invalid block header",
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

const makeBlockHeaderStore = Effect.gen(function* () {
  const state = yield* Effect.acquireRelease(
    Effect.sync(() => ({
      headers: new Map<BlockHashKey, BlockHeaderType>(),
    })),
    (store) =>
      Effect.sync(() => {
        store.headers.clear();
      }),
  );

  const getHeader = (hash: BlockHashType) =>
    Effect.gen(function* () {
      const validated = yield* decodeBlockHash(hash);
      return Option.fromNullable(state.headers.get(blockHashKey(validated)));
    });

  const hasHeader = (hash: BlockHashType) =>
    Effect.gen(function* () {
      const validated = yield* decodeBlockHash(hash);
      return state.headers.has(blockHashKey(validated));
    });

  const putHeader = (hash: BlockHashType, header: BlockHeaderType) =>
    Effect.gen(function* () {
      const validatedHash = yield* decodeBlockHash(hash);
      const validatedHeader = yield* decodeHeader(header);
      const key = blockHashKey(validatedHash);
      if (state.headers.has(key)) {
        return;
      }
      state.headers.set(key, validatedHeader);
    });

  const headerCount = () => Effect.sync(() => state.headers.size);

  return {
    getHeader,
    hasHeader,
    putHeader,
    headerCount,
  } satisfies BlockHeaderStoreService;
});

const BlockHeaderStoreMemoryLayer: Layer.Layer<
  BlockHeaderStore,
  BlockHeaderStoreError
> = Layer.scoped(BlockHeaderStore, makeBlockHeaderStore);

/** In-memory production block header store layer. */
export const BlockHeaderStoreMemoryLive: Layer.Layer<
  BlockHeaderStore,
  BlockHeaderStoreError
> = BlockHeaderStoreMemoryLayer;

/** In-memory deterministic block header store layer for tests. */
export const BlockHeaderStoreMemoryTest: Layer.Layer<
  BlockHeaderStore,
  BlockHeaderStoreError
> = BlockHeaderStoreMemoryLayer;

const withBlockHeaderStore = <A, E, R>(
  f: (service: BlockHeaderStoreService) => Effect.Effect<A, E, R>,
) => Effect.flatMap(BlockHeaderStore, f);

/** Retrieve a header by hash. */
export const getHeader = (hash: BlockHashType) =>
  withBlockHeaderStore((store) => store.getHeader(hash));

/** Check whether a header exists by hash. */
export const hasHeader = (hash: BlockHashType) =>
  withBlockHeaderStore((store) => store.hasHeader(hash));

/** Store a header by hash. */
export const putHeader = (hash: BlockHashType, header: BlockHeaderType) =>
  withBlockHeaderStore((store) => store.putHeader(hash, header));

/** Return the number of stored headers. */
export const headerCount = () =>
  withBlockHeaderStore((store) => store.headerCount());
