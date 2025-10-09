/**
 * 20-byte Ethereum address (as hex string with 0x prefix)
 */
export type Address = string;

/**
 * 32-byte value (u256) as hex string with 0x prefix
 */
export type U256 = string;

/**
 * Bytecode or calldata as hex string with 0x prefix
 */
export type Bytes = string;

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
 * Custom opcode handler function
 * Handler receives frame context and must return success/failure
 */
export type OpcodeHandler = (framePtr: number) => boolean;

/**
 * Opcode override definition
 */
export interface OpcodeOverride {
  /** Opcode byte to override (0x00-0xFF) */
  opcode: number;
  /** Custom handler function */
  handler: OpcodeHandler;
}

/**
 * Precompile execution result
 */
export interface PrecompileResult {
  /** Execution success */
  success: boolean;
  /** Gas consumed */
  gasUsed: bigint;
  /** Output data as hex string */
  output: Bytes;
}

/**
 * Custom precompile handler function
 */
export type PrecompileHandler = (
  input: Bytes,
  gasLimit: bigint
) => Promise<PrecompileResult> | PrecompileResult;

/**
 * Precompile override definition
 */
export interface PrecompileOverride {
  /** Address of the precompile (20 bytes) */
  address: Address;
  /** Custom handler function */
  execute: PrecompileHandler;
}

/**
 * Log level for EVM execution
 */
export type LogLevel = 'none' | 'error' | 'warn' | 'info' | 'debug';

/**
 * EVM creation options
 */
export interface EvmOptions {
  /** Hardfork to use (default: PRAGUE) */
  hardfork?: Hardfork;

  /** Log level (default: none) */
  logLevel?: LogLevel;

  /** Custom opcode handlers (overrides default implementations) */
  opcodeOverrides?: OpcodeOverride[];

  /** Custom precompile handlers (overrides or adds precompiles) */
  precompileOverrides?: PrecompileOverride[];

  /** Maximum loop iterations before panic (null = disabled) */
  loopQuota?: number | null;

  /** Enable EIP-4788 beacon root contract updates */
  enableBeaconRoots?: boolean;

  /** Enable EIP-2935 historical block hash contract updates */
  enableHistoricalBlockHashes?: boolean;

  /** Enable validator deposit tracking */
  enableValidatorDeposits?: boolean;

  /** Enable validator withdrawal tracking */
  enableValidatorWithdrawals?: boolean;

  /**
   * Optional async state interface for storage injection
   * When provided, EVM will fetch state from this interface instead of internal maps
   */
  stateInterface?: StateInterface;
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
 * State changes from transaction execution
 */
export interface StateChanges {
  /** Storage slot changes */
  storage: Array<{
    address: Address;
    slot: U256;
    originalValue: U256;
    newValue: U256;
  }>;
  /** Balance changes */
  balances: Array<{
    address: Address;
    originalBalance: bigint;
    newBalance: bigint;
  }>;
  /** Nonce changes */
  nonces: Array<{
    address: Address;
    originalNonce: bigint;
    newNonce: bigint;
  }>;
  /** Code changes */
  codes: Array<{
    address: Address;
    code: Bytes;
  }>;
  /** Self-destructed accounts */
  selfDestructs: Address[];
}

/**
 * Async state interface - provides state access for EVM
 * All methods are async to support RPC, database, or cache lookups
 */
export interface StateInterface {
  /**
   * Get storage value at given address and slot
   * @returns Storage value as hex string (0x-prefixed, 32 bytes)
   */
  getStorage(address: Address, slot: U256): Promise<U256>;

  /**
   * Get account balance
   * @returns Balance as bigint
   */
  getBalance(address: Address): Promise<bigint>;

  /**
   * Get account code
   * @returns Code as hex string (0x-prefixed)
   */
  getCode(address: Address): Promise<Bytes>;

  /**
   * Get account nonce
   * @returns Nonce as bigint
   */
  getNonce(address: Address): Promise<bigint>;

  /**
   * Commit state changes after successful transaction
   * Called once at the end of transaction execution
   */
  commitChanges(changes: StateChanges): Promise<void>;
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
