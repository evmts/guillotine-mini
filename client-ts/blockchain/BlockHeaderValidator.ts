import * as Context from "effect/Context";
import * as Data from "effect/Data";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";
import type { BlockHash } from "voltaire-effect/primitives";
import { BlockHeader, Hex } from "voltaire-effect/primitives";

/** Block header type handled by the validator. */
export type BlockHeaderType = BlockHeader.BlockHeaderType;
/** Block hash type used for parent linkage validation. */
export type BlockHashType = BlockHash.BlockHashType;

const BlockHeaderSchema = BlockHeader.Schema as unknown as Schema.Schema<
  BlockHeaderType,
  unknown
>;
const EmptyOmmerHashHex = Hex.fromString(
  "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
);

const BASE_FEE_MAX_CHANGE_DENOMINATOR = 8n;
const ELASTICITY_MULTIPLIER = 2n;
const GAS_LIMIT_ADJUSTMENT_FACTOR = 1024n;
const GAS_LIMIT_MINIMUM = 5000n;
const TARGET_BLOB_GAS_PER_BLOCK = 786_432n;

/** Error raised when a header fails schema validation. */
export class InvalidBlockHeaderError extends Data.TaggedError(
  "InvalidBlockHeaderError",
)<{
  readonly message: string;
  readonly cause?: unknown;
}> {}

/** Error raised when a header violates consensus validation rules. */
export class BlockHeaderValidationError extends Data.TaggedError(
  "BlockHeaderValidationError",
)<{
  readonly field: string;
  readonly message: string;
  readonly expected?: unknown;
  readonly actual?: unknown;
}> {}

/** Union of header validation errors. */
export type BlockHeaderValidatorError =
  | InvalidBlockHeaderError
  | BlockHeaderValidationError;

/** Block header validator service interface. */
export interface BlockHeaderValidatorService {
  readonly validateHeader: (
    header: BlockHeaderType,
    parent: BlockHeaderType,
  ) => Effect.Effect<void, BlockHeaderValidatorError>;
}

/** Context tag for the block header validator service. */
export class BlockHeaderValidator extends Context.Tag("BlockHeaderValidator")<
  BlockHeaderValidator,
  BlockHeaderValidatorService
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

const requireField = <T>(field: string, value: T | undefined) =>
  value === undefined
    ? Effect.fail(
        new BlockHeaderValidationError({
          field,
          message: "Missing required header field",
        }),
      )
    : Effect.succeed(value);

const failField = (
  field: string,
  message: string,
  expected?: unknown,
  actual?: unknown,
) =>
  Effect.fail(
    new BlockHeaderValidationError({
      field,
      message,
      expected,
      actual,
    }),
  );

const checkGasLimit = (gasLimit: bigint, parentGasLimit: bigint): boolean => {
  const maxAdjustmentDelta = parentGasLimit / GAS_LIMIT_ADJUSTMENT_FACTOR;
  if (gasLimit >= parentGasLimit + maxAdjustmentDelta) return false;
  if (gasLimit <= parentGasLimit - maxAdjustmentDelta) return false;
  if (gasLimit < GAS_LIMIT_MINIMUM) return false;
  return true;
};

const calculateBaseFeePerGas = (
  blockGasLimit: bigint,
  parentGasLimit: bigint,
  parentGasUsed: bigint,
  parentBaseFeePerGas: bigint,
) =>
  Effect.gen(function* () {
    if (!checkGasLimit(blockGasLimit, parentGasLimit)) {
      return yield* failField(
        "gasLimit",
        "Block gas limit exceeds adjustment bounds",
        parentGasLimit,
        blockGasLimit,
      );
    }

    const parentGasTarget = parentGasLimit / ELASTICITY_MULTIPLIER;

    if (parentGasUsed === parentGasTarget) {
      return parentBaseFeePerGas;
    }

    if (parentGasUsed > parentGasTarget) {
      const gasUsedDelta = parentGasUsed - parentGasTarget;
      const parentFeeGasDelta = parentBaseFeePerGas * gasUsedDelta;
      const targetFeeGasDelta = parentFeeGasDelta / parentGasTarget;
      const baseFeePerGasDelta =
        targetFeeGasDelta / BASE_FEE_MAX_CHANGE_DENOMINATOR;

      return (
        parentBaseFeePerGas +
        (baseFeePerGasDelta > 0n ? baseFeePerGasDelta : 1n)
      );
    }

    const gasUsedDelta = parentGasTarget - parentGasUsed;
    const parentFeeGasDelta = parentBaseFeePerGas * gasUsedDelta;
    const targetFeeGasDelta = parentFeeGasDelta / parentGasTarget;
    const baseFeePerGasDelta =
      targetFeeGasDelta / BASE_FEE_MAX_CHANGE_DENOMINATOR;

    return parentBaseFeePerGas - baseFeePerGasDelta;
  });

const calculateExcessBlobGas = (
  parentExcessBlobGas: bigint,
  parentBlobGasUsed: bigint,
): bigint => {
  const parentBlobGas = parentExcessBlobGas + parentBlobGasUsed;
  if (parentBlobGas < TARGET_BLOB_GAS_PER_BLOCK) return 0n;
  return parentBlobGas - TARGET_BLOB_GAS_PER_BLOCK;
};

const isZeroNonce = (nonce: Uint8Array): boolean =>
  nonce.length === 8 && nonce.every((value) => value === 0);

const makeBlockHeaderValidator = Effect.gen(function* () {
  const validateHeader = (header: BlockHeaderType, parent: BlockHeaderType) =>
    Effect.gen(function* () {
      const validatedHeader = yield* decodeHeader(header);
      const validatedParent = yield* decodeHeader(parent);

      const headerNumber = validatedHeader.number as bigint;
      if (headerNumber < 1n) {
        return yield* failField(
          "number",
          "Block number must be at least 1",
          1n,
          headerNumber,
        );
      }

      const expectedExcessBlobGas = calculateExcessBlobGas(
        yield* requireField("excessBlobGas", validatedParent.excessBlobGas),
        yield* requireField("blobGasUsed", validatedParent.blobGasUsed),
      );

      const headerExcessBlobGas = yield* requireField(
        "excessBlobGas",
        validatedHeader.excessBlobGas,
      );

      if (headerExcessBlobGas !== expectedExcessBlobGas) {
        return yield* failField(
          "excessBlobGas",
          "Excess blob gas does not match expected value",
          expectedExcessBlobGas,
          headerExcessBlobGas,
        );
      }

      if (
        (validatedHeader.gasUsed as bigint) >
        (validatedHeader.gasLimit as bigint)
      ) {
        return yield* failField(
          "gasUsed",
          "Gas used exceeds gas limit",
          validatedHeader.gasLimit,
          validatedHeader.gasUsed,
        );
      }

      const expectedBaseFee = yield* calculateBaseFeePerGas(
        validatedHeader.gasLimit as bigint,
        validatedParent.gasLimit as bigint,
        validatedParent.gasUsed as bigint,
        yield* requireField("baseFeePerGas", validatedParent.baseFeePerGas),
      );

      const headerBaseFee = yield* requireField(
        "baseFeePerGas",
        validatedHeader.baseFeePerGas,
      );

      if (headerBaseFee !== expectedBaseFee) {
        return yield* failField(
          "baseFeePerGas",
          "Base fee per gas does not match expected value",
          expectedBaseFee,
          headerBaseFee,
        );
      }

      if (
        (validatedHeader.timestamp as bigint) <=
        (validatedParent.timestamp as bigint)
      ) {
        return yield* failField(
          "timestamp",
          "Block timestamp must be greater than parent timestamp",
          validatedParent.timestamp,
          validatedHeader.timestamp,
        );
      }

      if (headerNumber !== (validatedParent.number as bigint) + 1n) {
        return yield* failField(
          "number",
          "Block number must be parent number + 1",
          (validatedParent.number as bigint) + 1n,
          headerNumber,
        );
      }

      if (validatedHeader.extraData.length > 32) {
        return yield* failField(
          "extraData",
          "Extra data exceeds 32 bytes",
          32,
          validatedHeader.extraData.length,
        );
      }

      if ((validatedHeader.difficulty as bigint) !== 0n) {
        return yield* failField(
          "difficulty",
          "Difficulty must be zero for post-merge blocks",
          0n,
          validatedHeader.difficulty,
        );
      }

      if (!isZeroNonce(validatedHeader.nonce)) {
        return yield* failField(
          "nonce",
          "Nonce must be zero for post-merge blocks",
          new Uint8Array(8),
          validatedHeader.nonce,
        );
      }

      if (Hex.fromBytes(validatedHeader.ommersHash) !== EmptyOmmerHashHex) {
        return yield* failField(
          "ommersHash",
          "Ommers hash must be the empty list hash",
          EmptyOmmerHashHex,
          Hex.fromBytes(validatedHeader.ommersHash),
        );
      }

      const expectedParentHash = BlockHeader.calculateHash(validatedParent);
      const expectedParentHashHex = Hex.fromBytes(expectedParentHash);
      const actualParentHashHex = Hex.fromBytes(validatedHeader.parentHash);
      if (actualParentHashHex !== expectedParentHashHex) {
        return yield* failField(
          "parentHash",
          "Parent hash does not match parent header hash",
          expectedParentHashHex,
          actualParentHashHex,
        );
      }
    });

  return { validateHeader } satisfies BlockHeaderValidatorService;
});

/** Production block header validator layer. */
export const BlockHeaderValidatorLive: Layer.Layer<
  BlockHeaderValidator,
  BlockHeaderValidatorError
> = Layer.effect(BlockHeaderValidator, makeBlockHeaderValidator);

/** Deterministic test block header validator layer. */
export const BlockHeaderValidatorTest: Layer.Layer<
  BlockHeaderValidator,
  BlockHeaderValidatorError
> = Layer.succeed(BlockHeaderValidator, {
  validateHeader: () => Effect.succeed(undefined),
});

const withBlockHeaderValidator = <A, E, R>(
  f: (service: BlockHeaderValidatorService) => Effect.Effect<A, E, R>,
) => Effect.flatMap(BlockHeaderValidator, f);

/** Validate a block header against its parent header. */
export const validateHeader = (
  header: BlockHeaderType,
  parent: BlockHeaderType,
) =>
  withBlockHeaderValidator((service) => service.validateHeader(header, parent));
