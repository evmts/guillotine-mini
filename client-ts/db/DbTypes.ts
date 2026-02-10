import * as Schema from "effect/Schema";
import { Bytes } from "voltaire-effect/primitives";

/** Byte array type used for DB keys and values. */
export type BytesType = Schema.Schema.Type<typeof Bytes.Hex>;

/** Canonical DB names used by the execution client. */
export const DbNames = {
  storage: "storage",
  state: "state",
  code: "code",
  blocks: "blocks",
  headers: "headers",
  blockNumbers: "blockNumbers",
  receipts: "receipts",
  blockInfos: "blockInfos",
  badBlocks: "badBlocks",
  bloom: "bloom",
  metadata: "metadata",
  blobTransactions: "blobTransactions",
  discoveryNodes: "discoveryNodes",
  discoveryV5Nodes: "discoveryV5Nodes",
  peers: "peers",
} as const;

/** DB names backed by column databases in Nethermind. */
export const ColumnDbNames = {
  receipts: DbNames.receipts,
  blobTransactions: DbNames.blobTransactions,
} as const;

/** DB names backed by standard key/value stores. */
export const StandardDbNames = {
  storage: DbNames.storage,
  state: DbNames.state,
  code: DbNames.code,
  blocks: DbNames.blocks,
  headers: DbNames.headers,
  blockNumbers: DbNames.blockNumbers,
  blockInfos: DbNames.blockInfos,
  badBlocks: DbNames.badBlocks,
  bloom: DbNames.bloom,
  metadata: DbNames.metadata,
  discoveryNodes: DbNames.discoveryNodes,
  discoveryV5Nodes: DbNames.discoveryV5Nodes,
  peers: DbNames.peers,
} as const;

/** Schema for validating DB names at boundaries. */
export const DbNameSchema = Schema.Union(
  Schema.Literal(DbNames.storage),
  Schema.Literal(DbNames.state),
  Schema.Literal(DbNames.code),
  Schema.Literal(DbNames.blocks),
  Schema.Literal(DbNames.headers),
  Schema.Literal(DbNames.blockNumbers),
  Schema.Literal(DbNames.receipts),
  Schema.Literal(DbNames.blockInfos),
  Schema.Literal(DbNames.badBlocks),
  Schema.Literal(DbNames.bloom),
  Schema.Literal(DbNames.metadata),
  Schema.Literal(DbNames.blobTransactions),
  Schema.Literal(DbNames.discoveryNodes),
  Schema.Literal(DbNames.discoveryV5Nodes),
  Schema.Literal(DbNames.peers),
);

/** DB name union derived from the DB name schema. */
export type DbName = Schema.Schema.Type<typeof DbNameSchema>;

/** Column DB name union derived from the column DB name constants. */
export const ColumnDbNameSchema = Schema.Union(
  Schema.Literal(ColumnDbNames.receipts),
  Schema.Literal(ColumnDbNames.blobTransactions),
);

/** Column DB name union derived from the column DB name schema. */
export type ColumnDbName = Schema.Schema.Type<typeof ColumnDbNameSchema>;

/** Standard DB name union derived from the standard DB name constants. */
export type StandardDbName =
  (typeof StandardDbNames)[keyof typeof StandardDbNames];

/** Configuration for a DB layer. */
export interface DbConfig {
  readonly name: DbName;
  readonly path?: string;
  readonly basePath?: string;
}

/** Receipt DB columns (Nethermind ReceiptsColumns parity). */
export const ReceiptsColumns = {
  Default: "Default",
  Transactions: "Transactions",
  Blocks: "Blocks",
} as const;

/** Receipt DB column name union. */
export type ReceiptsColumn =
  (typeof ReceiptsColumns)[keyof typeof ReceiptsColumns];

/** Blob transaction DB columns (Nethermind BlobTxsColumns parity). */
export const BlobTxsColumns = {
  FullBlobTxs: "FullBlobTxs",
  LightBlobTxs: "LightBlobTxs",
  ProcessedTxs: "ProcessedTxs",
} as const;

/** Blob transaction DB column name union. */
export type BlobTxsColumn =
  (typeof BlobTxsColumns)[keyof typeof BlobTxsColumns];

/** Schema for validating DB configuration at boundaries. */
export const DbConfigSchema = Schema.Struct({
  name: DbNameSchema,
  path: Schema.optional(Schema.String),
  basePath: Schema.optional(Schema.String),
});

const readFlagsMask = 1 | 2 | 4 | 8 | 16;

/** Schema for validating read flags at boundaries. */
export const ReadFlagsSchema = Schema.Int.pipe(
  Schema.filter((value) => (value & ~readFlagsMask) === 0, {
    message: () => "Invalid ReadFlags value",
  }),
  Schema.brand("ReadFlags"),
);

/** Read flag bitset (Nethermind ReadFlags parity). */
export type ReadFlags = Schema.Schema.Type<typeof ReadFlagsSchema>;

/** Read flag constants. */
export const ReadFlags = {
  None: ReadFlagsSchema.make(0),
  HintCacheMiss: ReadFlagsSchema.make(1),
  HintReadAhead: ReadFlagsSchema.make(2),
  HintReadAhead2: ReadFlagsSchema.make(4),
  HintReadAhead3: ReadFlagsSchema.make(8),
  SkipDuplicateRead: ReadFlagsSchema.make(16),
  combine: (...flags: ReadFlags[]): ReadFlags =>
    ReadFlagsSchema.make(flags.reduce((acc, flag) => acc | flag, 0)),
} as const;

const writeFlagsMask = 1 | 2;

/** Schema for validating write flags at boundaries. */
export const WriteFlagsSchema = Schema.Int.pipe(
  Schema.filter((value) => (value & ~writeFlagsMask) === 0, {
    message: () => "Invalid WriteFlags value",
  }),
  Schema.brand("WriteFlags"),
);

/** Write flag bitset (Nethermind WriteFlags parity). */
export type WriteFlags = Schema.Schema.Type<typeof WriteFlagsSchema>;

/** Write flag constants. */
export const WriteFlags = {
  None: WriteFlagsSchema.make(0),
  LowPriority: WriteFlagsSchema.make(1),
  DisableWAL: WriteFlagsSchema.make(2),
  LowPriorityAndNoWAL: WriteFlagsSchema.make(3),
  combine: (...flags: WriteFlags[]): WriteFlags =>
    WriteFlagsSchema.make(flags.reduce((acc, flag) => acc | flag, 0)),
} as const;

/** Schema for DB metrics emitted by IDbMeta-compatible backends. */
export const DbMetricSchema = Schema.Struct({
  size: Schema.Number,
  cacheSize: Schema.Number,
  indexSize: Schema.Number,
  memtableSize: Schema.Number,
  totalReads: Schema.Number,
  totalWrites: Schema.Number,
});

/** DB metrics for maintenance/telemetry. */
export type DbMetric = Schema.Schema.Type<typeof DbMetricSchema>;
