import { assert, describe, it } from "@effect/vitest";
import * as Effect from "effect/Effect";
import * as Schema from "effect/Schema";
import { BlockHeader, Hash } from "voltaire-effect/primitives";
import {
  BlockHeaderValidationError,
  BlockHeaderValidatorLive,
  validateHeader,
} from "./BlockHeaderValidator";
import {
  addressFromByte,
  blockHashFromByte,
  blockNumberFromBigInt,
  hashFromByte,
  uint256FromBigInt,
} from "./testUtils";

type BlockHeaderType = BlockHeader.BlockHeaderType;

const BlockHeaderSchema = BlockHeader.Schema as unknown as Schema.Schema<
  BlockHeaderType,
  unknown
>;
const HashHexSchema = Hash.Hex as unknown as Schema.Schema<
  Hash.HashType,
  string
>;
const EmptyOmmerHash = Schema.decodeSync(HashHexSchema)(
  "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
);

const makeHeader = (overrides: Partial<BlockHeaderType>) =>
  Schema.decodeSync(BlockHeaderSchema)({
    parentHash: blockHashFromByte(0x00),
    ommersHash: EmptyOmmerHash,
    beneficiary: addressFromByte(0x10),
    stateRoot: hashFromByte(0x11),
    transactionsRoot: hashFromByte(0x12),
    receiptsRoot: hashFromByte(0x13),
    logsBloom: new Uint8Array(256),
    difficulty: uint256FromBigInt(0n),
    number: blockNumberFromBigInt(1n),
    gasLimit: uint256FromBigInt(30_000_000n),
    gasUsed: uint256FromBigInt(15_000_000n),
    timestamp: uint256FromBigInt(1_000n),
    extraData: new Uint8Array(0),
    mixHash: hashFromByte(0x14),
    nonce: new Uint8Array(8),
    baseFeePerGas: uint256FromBigInt(100n),
    blobGasUsed: uint256FromBigInt(0n),
    excessBlobGas: uint256FromBigInt(0n),
    parentBeaconBlockRoot: hashFromByte(0x15),
    ...overrides,
  });

describe("BlockHeaderValidator", () => {
  it.effect("accepts a valid header", () =>
    Effect.gen(function* () {
      const parent = makeHeader({});
      const child = makeHeader({
        parentHash: BlockHeader.calculateHash(parent),
        number: blockNumberFromBigInt(2n),
        gasUsed: uint256FromBigInt(0n),
        timestamp: uint256FromBigInt(1_100n),
      });

      yield* validateHeader(child, parent);
    }).pipe(Effect.provide(BlockHeaderValidatorLive)),
  );

  it.effect("rejects headers with incorrect base fee", () =>
    Effect.gen(function* () {
      const parent = makeHeader({});
      const child = makeHeader({
        parentHash: BlockHeader.calculateHash(parent),
        number: blockNumberFromBigInt(2n),
        gasUsed: uint256FromBigInt(0n),
        timestamp: uint256FromBigInt(1_100n),
        baseFeePerGas: uint256FromBigInt(101n),
      });

      const error = yield* Effect.flip(validateHeader(child, parent));
      assert.instanceOf(error, BlockHeaderValidationError);
      if (error._tag === "BlockHeaderValidationError") {
        assert.strictEqual(error.field, "baseFeePerGas");
      }
    }).pipe(Effect.provide(BlockHeaderValidatorLive)),
  );
});
