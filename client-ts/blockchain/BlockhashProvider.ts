import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Option from "effect/Option";
import * as Schema from "effect/Schema";
import {
  BlockHash,
  BlockHeader,
  BlockNumber,
} from "voltaire-effect/primitives";
import {
  BlockTree,
  type BlockTreeError,
  BlockTreeMemoryTest,
} from "./BlockTree";

/** Block header type used by the blockhash provider. */
export type BlockHeaderType = BlockHeader.BlockHeaderType;
/** Block hash type returned by the provider. */
export type BlockHashType = BlockHash.BlockHashType;
/** Block number type used for hash lookups. */
export type BlockNumberType = BlockNumber.BlockNumberType;

const BlockNumberSchema = BlockNumber.BigInt as unknown as Schema.Schema<
  BlockNumberType,
  bigint
>;
const MAX_BLOCKHASH_DEPTH = 256n;

/** Error raised when a block number is invalid. */
export class InvalidBlockhashNumberError extends Data.TaggedError(
  "InvalidBlockhashNumberError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Error raised when an expected ancestor hash is missing. */
export class MissingBlockhashError extends Data.TaggedError(
  "MissingBlockhashError",
)<{
  readonly missingHash: BlockHashType;
  readonly missingNumber: bigint;
}> {}

/** Union of blockhash provider errors. */
export type BlockhashProviderError =
  | BlockTreeError
  | InvalidBlockhashNumberError
  | MissingBlockhashError;

/** Blockhash provider service interface. */
export interface BlockhashProviderService {
  readonly getBlockhash: (
    currentHeader: BlockHeaderType,
    number: BlockNumberType,
  ) => Effect.Effect<Option.Option<BlockHashType>, BlockhashProviderError>;
}

/** Context tag for the blockhash provider service. */
export class BlockhashProvider extends Context.Tag("BlockhashProvider")<
  BlockhashProvider,
  BlockhashProviderService
>() {}

const decodeBlockNumber = (number: BlockNumberType, label: string) =>
  Schema.decode(BlockNumberSchema)(number).pipe(
    Effect.mapError(
      (cause) =>
        new InvalidBlockhashNumberError({
          message: `Invalid ${label} block number`,
          cause,
        }),
    ),
  );

const toBigInt = (number: BlockNumberType) =>
  Schema.encodeSync(BlockNumberSchema)(number);

const makeBlockhashProvider = Effect.gen(function* () {
  const blockTree = yield* BlockTree;

  const getBlockhash = (
    currentHeader: BlockHeaderType,
    number: BlockNumberType,
  ) =>
    Effect.gen(function* () {
      const currentNumberType = yield* decodeBlockNumber(
        currentHeader.number,
        "current",
      );
      const requestedNumberType = yield* decodeBlockNumber(number, "requested");

      const currentNumber = toBigInt(currentNumberType);
      const requestedNumber = toBigInt(requestedNumberType);

      if (requestedNumber >= currentNumber) {
        return Option.none();
      }

      const depth = currentNumber - requestedNumber;
      if (depth > MAX_BLOCKHASH_DEPTH) {
        return Option.none();
      }

      let currentHash = currentHeader.parentHash;
      let cursorNumber = currentNumber - 1n;

      while (cursorNumber > requestedNumber) {
        const block = yield* blockTree.getBlock(currentHash);
        if (Option.isNone(block)) {
          return yield* Effect.fail(
            new MissingBlockhashError({
              missingHash: currentHash,
              missingNumber: cursorNumber,
            }),
          );
        }

        const ancestor = Option.getOrThrow(block);
        const ancestorNumberType = yield* decodeBlockNumber(
          ancestor.header.number,
          "ancestor",
        );
        const ancestorNumber = toBigInt(ancestorNumberType);
        if (ancestorNumber !== cursorNumber) {
          return yield* Effect.fail(
            new MissingBlockhashError({
              missingHash: currentHash,
              missingNumber: cursorNumber,
            }),
          );
        }

        currentHash = ancestor.header.parentHash;
        cursorNumber -= 1n;
      }

      return Option.some(currentHash);
    });

  return { getBlockhash } satisfies BlockhashProviderService;
});

/** Production blockhash provider layer. */
export const BlockhashProviderLive: Layer.Layer<
  BlockhashProvider,
  BlockhashProviderError,
  BlockTree
> = Layer.effect(BlockhashProvider, makeBlockhashProvider);

/** Deterministic blockhash provider layer for tests. */
export const BlockhashProviderTest = Layer.provideMerge(BlockTreeMemoryTest)(
  BlockhashProviderLive,
);

const withBlockhashProvider = <A, E>(
  f: (service: BlockhashProviderService) => Effect.Effect<A, E>,
) => Effect.flatMap(BlockhashProvider, f);

/** Retrieve a recent block hash for BLOCKHASH semantics. */
export const getBlockhash = (
  currentHeader: BlockHeaderType,
  number: BlockNumberType,
) =>
  withBlockhashProvider((service) =>
    service.getBlockhash(currentHeader, number),
  );
