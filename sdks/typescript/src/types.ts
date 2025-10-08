/**
 * 20-byte Ethereum address
 */
export type Address = Uint8Array;

/**
 * 32-byte value (u256)
 */
export type U256 = Uint8Array;

/**
 * Bytecode or calldata
 */
export type Bytes = Uint8Array;

/**
 * Execution context for an EVM call
 */
export interface ExecutionContext {
  /** Gas limit for execution */
  gas: bigint;
  /** Caller address (msg.sender) */
  caller: Address;
  /** Contract address (address(this)) */
  address: Address;
  /** Value transferred (msg.value) */
  value: bigint;
  /** Input data (msg.data) */
  calldata: Bytes;
}

/**
 * Blockchain context - all fields required
 */
export interface BlockchainContext {
  /** Chain ID (e.g., 1 for mainnet) */
  chainId: bigint;
  /** Block number */
  blockNumber: bigint;
  /** Block timestamp (seconds since epoch) */
  blockTimestamp: bigint;
  /** Block difficulty (or 0 for PoS) */
  blockDifficulty: bigint;
  /** Block prevrandao (replaces difficulty in PoS) */
  blockPrevrandao: bigint;
  /** Coinbase address (block.coinbase) */
  blockCoinbase: Address;
  /** Block gas limit */
  blockGasLimit: bigint;
  /** Base fee per gas (EIP-1559) */
  blockBaseFee: bigint;
  /** Blob base fee (EIP-4844) */
  blobBaseFee: bigint;
}

/**
 * Hardfork names - controls which EVM features are enabled
 */
export type Hardfork =
  | 'FRONTIER'
  | 'HOMESTEAD'
  | 'DAO'
  | 'TANGERINE_WHISTLE'
  | 'SPURIOUS_DRAGON'
  | 'BYZANTIUM'
  | 'CONSTANTINOPLE'
  | 'PETERSBURG'
  | 'ISTANBUL'
  | 'MUIR_GLACIER'
  | 'BERLIN'
  | 'LONDON'
  | 'ARROW_GLACIER'
  | 'GRAY_GLACIER'
  | 'MERGE'
  | 'SHANGHAI'
  | 'CANCUN'
  | 'PRAGUE'
  | 'OSAKA';

/**
 * Access list entry (EIP-2930)
 */
export interface AccessListEntry {
  /** Address to pre-warm */
  address: Address;
  /** Storage slots to pre-warm for this address */
  storageKeys: U256[];
}

/**
 * EVM creation options
 */
export interface EvmOptions {
  /** Hardfork to use (default: PRAGUE) */
  hardfork?: Hardfork;
}

/**
 * Result of EVM execution
 */
export interface ExecutionResult {
  /** Whether execution succeeded */
  success: boolean;
  /** Gas remaining after execution */
  gasRemaining: bigint;
  /** Gas used during execution */
  gasUsed: bigint;
  /** Output data (return value or revert reason) */
  output: Bytes;
}

/**
 * Main EVM interface
 */
export interface Evm {
  /**
   * Wait for WASM initialization to complete.
   * Called automatically by all methods, but can be called explicitly.
   */
  ready(): Promise<void>;

  /**
   * Set bytecode to execute
   */
  setBytecode(bytecode: Bytes): Promise<void>;

  /**
   * Set execution context (gas, caller, address, value, calldata)
   */
  setExecutionContext(ctx: ExecutionContext): Promise<void>;

  /**
   * Set blockchain context (chain_id, block number, timestamp, etc.)
   * REQUIRED before calling execute()
   */
  setBlockchainContext(ctx: BlockchainContext): Promise<void>;

  /**
   * Set access list (EIP-2930) - optional, call before execute()
   */
  setAccessList(accessList: AccessListEntry[]): Promise<void>;

  /**
   * Set blob versioned hashes (EIP-4844) - optional, call before execute()
   */
  setBlobHashes(hashes: Bytes[]): Promise<void>;

  /**
   * Execute the EVM with current context
   */
  execute(): Promise<ExecutionResult>;

  /**
   * Set storage value for an address
   */
  setStorage(address: Address, slot: U256, value: U256): Promise<void>;

  /**
   * Get storage value for an address
   */
  getStorage(address: Address, slot: U256): Promise<U256>;

  /**
   * Set account balance
   */
  setBalance(address: Address, balance: bigint): Promise<void>;

  /**
   * Set account code
   */
  setCode(address: Address, code: Bytes): Promise<void>;

  /**
   * Destroy the EVM instance and free resources
   */
  destroy(): Promise<void>;
}
