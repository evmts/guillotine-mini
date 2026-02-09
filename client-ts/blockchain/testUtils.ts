import * as Schema from "effect/Schema";
import {
  Address,
  Block,
  BlockBody,
  BlockHash,
  BlockHeader,
  BlockNumber,
  Hash,
  Uint,
} from "voltaire-effect/primitives";

type HashType = Hash.HashType;
type BlockHashType = BlockHash.BlockHashType;
type AddressType = Address.AddressType;
type Uint256Type = Schema.Schema.Type<typeof Uint.BigInt>;
type BlockNumberType = BlockNumber.BlockNumberType;
type BlockHeaderType = BlockHeader.BlockHeaderType;
type BlockBodyType = BlockBody.BlockBodyType;
type BlockType = Block.BlockType;

const HashBytesSchema = Hash.Bytes as unknown as Schema.Schema<
  HashType,
  Uint8Array
>;
const BlockHashBytesSchema = BlockHash.Bytes as unknown as Schema.Schema<
  BlockHashType,
  Uint8Array
>;
const AddressBytesSchema = Address.Bytes as unknown as Schema.Schema<
  AddressType,
  Uint8Array
>;
const UintBigIntSchema = Uint.BigInt as unknown as Schema.Schema<
  Uint256Type,
  bigint
>;
const BlockNumberBigIntSchema = BlockNumber.BigInt as unknown as Schema.Schema<
  BlockNumberType,
  bigint
>;
const BlockHeaderSchema = BlockHeader.Schema as unknown as Schema.Schema<
  BlockHeaderType,
  unknown
>;
const BlockBodySchema = BlockBody.Schema as unknown as Schema.Schema<
  BlockBodyType,
  unknown
>;
const BlockSchema = Block.Schema as unknown as Schema.Schema<
  BlockType,
  unknown
>;

const bytes = (length: number, fill: number) =>
  new Uint8Array(length).fill(fill);

export const hashFromByte = (byte: number) =>
  Schema.decodeSync(HashBytesSchema)(bytes(32, byte));

export const blockHashFromByte = (byte: number) =>
  Schema.decodeSync(BlockHashBytesSchema)(bytes(32, byte));

export const addressFromByte = (byte: number) =>
  Schema.decodeSync(AddressBytesSchema)(bytes(20, byte));

export const uint256FromBigInt = (value: bigint) =>
  Schema.decodeSync(UintBigIntSchema)(value);

export const blockNumberFromBigInt = (value: bigint) =>
  Schema.decodeSync(BlockNumberBigIntSchema)(value);

export const makeBlock = (params: {
  readonly number: bigint;
  readonly hash: BlockHash.BlockHashType;
  readonly parentHash: BlockHash.BlockHashType;
}): Block.BlockType => {
  const header = Schema.decodeSync(BlockHeaderSchema)({
    parentHash: params.parentHash,
    ommersHash: hashFromByte(0x11),
    beneficiary: addressFromByte(0x22),
    stateRoot: hashFromByte(0x33),
    transactionsRoot: hashFromByte(0x44),
    receiptsRoot: hashFromByte(0x55),
    logsBloom: bytes(256, 0),
    difficulty: uint256FromBigInt(1n),
    number: blockNumberFromBigInt(params.number),
    gasLimit: uint256FromBigInt(30_000_000n),
    gasUsed: uint256FromBigInt(0n),
    timestamp: uint256FromBigInt(1n),
    extraData: bytes(0, 0),
    mixHash: hashFromByte(0x66),
    nonce: bytes(8, 0),
  });

  const body = Schema.decodeSync(BlockBodySchema)({
    transactions: [],
    ommers: [],
  });

  return Schema.decodeSync(BlockSchema)({
    header,
    body,
    hash: params.hash,
    size: uint256FromBigInt(1n),
  });
};
