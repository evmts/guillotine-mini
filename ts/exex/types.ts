// ============================================================================
// ETHEREUM PRIMITIVE TYPES
// ============================================================================

/** Hex-prefixed string type */
export type Hex = `0x${string}`;

/** 20-byte Ethereum address */
export type Address = Hex;

/** 32-byte hash */
export type Hash = Hex;

// ============================================================================
// BLOCK & TRANSACTION TYPES
// ============================================================================

export interface Log {
  address: Address;
  topics: Hash[];
  data: Hex;
  blockNumber: bigint;
  blockHash: Hash;
  transactionHash: Hash;
  transactionIndex: number;
  logIndex: number;
  removed: boolean;
}

export interface TransactionReceipt {
  transactionHash: Hash;
  transactionIndex: number;
  blockHash: Hash;
  blockNumber: bigint;
  from: Address;
  to: Address | null;
  cumulativeGasUsed: bigint;
  gasUsed: bigint;
  contractAddress: Address | null;
  logs: Log[];
  logsBloom: Hex;
  status: 0 | 1;
  effectiveGasPrice: bigint;
  type: number;
}

export interface Transaction {
  hash: Hash;
  nonce: bigint;
  blockHash: Hash | null;
  blockNumber: bigint | null;
  transactionIndex: number | null;
  from: Address;
  to: Address | null;
  value: bigint;
  gasPrice: bigint;
  gas: bigint;
  input: Hex;
  v: bigint;
  r: Hex;
  s: Hex;
  type: number;
  maxFeePerGas?: bigint;
  maxPriorityFeePerGas?: bigint;
  accessList?: Array<{ address: Address; storageKeys: Hash[] }>;
  maxFeePerBlobGas?: bigint;
  blobVersionedHashes?: Hash[];
}

export interface EVMBlock {
  number: bigint;
  hash: Hash;
  parentHash: Hash;
  nonce: Hex;
  sha3Uncles: Hash;
  logsBloom: Hex;
  transactionsRoot: Hash;
  stateRoot: Hash;
  receiptsRoot: Hash;
  miner: Address;
  difficulty: bigint;
  totalDifficulty: bigint;
  extraData: Hex;
  size: bigint;
  gasLimit: bigint;
  gasUsed: bigint;
  timestamp: bigint;
  transactions: Transaction[];
  uncles: Hash[];
  baseFeePerGas?: bigint;
  withdrawalsRoot?: Hash;
  blobGasUsed?: bigint;
  excessBlobGas?: bigint;
  parentBeaconBlockRoot?: Hash;
}

// ============================================================================
// STATE TYPES
// ============================================================================

export interface AccountState {
  balance: bigint;
  nonce: bigint;
  codeHash: Hash;
  storageRoot: Hash;
}

export interface StorageChange {
  address: Address;
  slot: Hash;
  previousValue: bigint;
  newValue: bigint;
}

export interface AccountChange {
  address: Address;
  previous: AccountState | null;
  current: AccountState | null;
}

export interface StateChangeset {
  accountChanges: AccountChange[];
  storageChanges: StorageChange[];
  createdContracts: Address[];
  destroyedContracts: Address[];
}

// ============================================================================
// STATE & BLOCK READERS
// ============================================================================

export interface StateReader {
  getBalance(address: Address): Promise<bigint>;
  getNonce(address: Address): Promise<bigint>;
  getCode(address: Address): Promise<Hex>;
  getCodeHash(address: Address): Promise<Hash>;
  getStorageAt(address: Address, slot: Hash): Promise<bigint>;
  getProof(
    address: Address,
    storageKeys: Hash[]
  ): Promise<{
    address: Address;
    accountProof: Hex[];
    balance: bigint;
    codeHash: Hash;
    nonce: bigint;
    storageHash: Hash;
    storageProof: Array<{
      key: Hash;
      value: bigint;
      proof: Hex[];
    }>;
  }>;
}

export interface BlockReader {
  getBlock(blockId: BlockId | bigint | 'latest' | 'finalized' | 'safe'): Promise<EVMBlock | null>;
  getBlockByHash(hash: Hash): Promise<EVMBlock | null>;
  getReceipts(blockHash: Hash): Promise<TransactionReceipt[]>;
  getTransaction(hash: Hash): Promise<Transaction | null>;
  getTransactionReceipt(hash: Hash): Promise<TransactionReceipt | null>;
}

// ============================================================================
// CORE EXEX TYPES
// ============================================================================

export interface BlockId {
  number: bigint;
  hash: Hash;
}

export interface Chain<Block = EVMBlock, Receipt = TransactionReceipt> {
  blocks: Block[];
  receipts: Map<Hash, Receipt[]>;
  stateChanges: StateChangeset;
  tip(): BlockId;
}

export type ExExNotification<Block = EVMBlock, Receipt = TransactionReceipt> =
  | { type: 'committed'; chain: Chain<Block, Receipt> }
  | { type: 'reverted'; chain: Chain<Block, Receipt> }
  | { type: 'reorged'; reverted: Chain<Block, Receipt>; committed: Chain<Block, Receipt> };

// ============================================================================
// EXEX CONTEXT & TYPE
// ============================================================================

/**
 * Context passed to the ExEx generator
 */
export interface ExExContext<Block = EVMBlock, Receipt = TransactionReceipt> {
  /** Stream of canonical state notifications */
  notifications: AsyncIterable<ExExNotification<Block, Receipt>>;

  /** Current head when ExEx started */
  head: BlockId;

  /** Chain ID */
  chainId: bigint;

  /** Read-only state access */
  state: StateReader;

  /** Historical block access */
  blocks: BlockReader;
}

/**
 * An ExEx is simply an async generator that:
 * - Receives notifications via the context
 * - Yields BlockId when it finishes processing (signals "finished height")
 * - Runs forever
 */
export type ExEx<Block = EVMBlock, Receipt = TransactionReceipt> = (
  ctx: ExExContext<Block, Receipt>
) => AsyncGenerator<BlockId, never, undefined>;

// ============================================================================
// EVENT SOURCE - What the node implements
// ============================================================================

export interface ChainEventSource<Block = EVMBlock, Receipt = TransactionReceipt> {
  subscribe(): AsyncIterable<ExExNotification<Block, Receipt>>;
  getHead(): Promise<BlockId>;
  replayRange(from: bigint, to: bigint): AsyncIterable<ExExNotification<Block, Receipt>>;
}
