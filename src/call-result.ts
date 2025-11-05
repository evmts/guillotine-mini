/**
 * EVM Call Result Types
 *
 * Represents the result of an EVM execution, including:
 * - Success/failure status
 * - Gas remaining
 * - Output data
 * - Gas refunds
 * - Event logs
 * - Storage access tracking
 * - Execution traces
 */

/**
 * 20-byte Ethereum address
 */
export type Address = Uint8Array;

/**
 * Zero address constant (0x0000...0000)
 */
export const ZERO_ADDRESS: Address = new Uint8Array(20);

/**
 * Log entry structure for EVM events (LOG0-LOG4 opcodes)
 */
export interface Log {
  /** Contract address that emitted the log */
  address: Address;
  /** Indexed topics (0-4 topics) */
  topics: bigint[];
  /** Non-indexed event data */
  data: Uint8Array;
}

/**
 * Record of a SELFDESTRUCT operation
 */
export interface SelfDestructRecord {
  /** Address of the contract being destroyed */
  contract: Address;
  /** Address receiving the remaining balance */
  beneficiary: Address;
}

/**
 * Record of a storage slot access (for EIP-2929 tracking)
 */
export interface StorageAccess {
  /** Contract address */
  address: Address;
  /** Storage slot key */
  slot: bigint;
}

/**
 * Storage read operation in trace
 */
export interface StorageRead {
  address: Address;
  slot: bigint;
  value: bigint;
}

/**
 * Storage write operation in trace
 */
export interface StorageWrite {
  address: Address;
  slot: bigint;
  old_value: bigint;
  new_value: bigint;
}

/**
 * Represents a single execution step in the trace (EIP-3155 format)
 */
export interface TraceStep {
  /** Program counter */
  pc: number;
  /** Opcode byte value */
  opcode: number;
  /** Human-readable opcode name */
  opcode_name: string;
  /** Gas remaining before this step */
  gas: bigint;
  /** Call depth (0 = top-level) */
  depth: number;
  /** Gas cost of this operation */
  gas_cost: bigint;
  /** Stack state (top to bottom) */
  stack: bigint[];
  /** Memory contents */
  memory: Uint8Array;
  /** Memory size in bytes */
  mem_size: number;
  /** Storage reads in this step */
  storage_reads: StorageRead[];
  /** Storage writes in this step */
  storage_writes: StorageWrite[];
}

/**
 * Complete execution trace
 */
export interface ExecutionTrace {
  /** All execution steps */
  steps: TraceStep[];
}

/**
 * Result of an EVM call or create operation
 */
export interface CallResult {
  /** Whether the execution succeeded */
  success: boolean;
  /** Gas remaining after execution */
  gas_left: bigint;
  /** Return data (empty if no output) */
  output: Uint8Array;
  /** Gas refund counter (for SSTORE refunds) */
  refund_counter: bigint;
  /** Event logs emitted during execution */
  logs: Log[];
  /** Self-destruct operations recorded */
  selfdestructs: SelfDestructRecord[];
  /** Addresses accessed (for EIP-2929) */
  accessed_addresses: Address[];
  /** Storage slots accessed (for EIP-2929) */
  accessed_storage: StorageAccess[];
  /** Execution trace (if enabled) */
  trace?: ExecutionTrace;
  /** Error information (if failed) */
  error_info?: string;
  /** Created contract address (for CREATE/CREATE2) */
  created_address?: Address;
}

/**
 * Helper functions for creating CallResult instances
 */
export const CallResultHelpers = {
  /**
   * Create a successful call result with output
   */
  successWithOutput(gas_left: bigint, output: Uint8Array): CallResult {
    return {
      success: true,
      gas_left,
      output: output.length > 0 ? new Uint8Array(output) : new Uint8Array(0),
      refund_counter: 0n,
      logs: [],
      selfdestructs: [],
      accessed_addresses: [],
      accessed_storage: [],
    };
  },

  /**
   * Create a successful call result with no output
   */
  successEmpty(gas_left: bigint): CallResult {
    return {
      success: true,
      gas_left,
      output: new Uint8Array(0),
      refund_counter: 0n,
      logs: [],
      selfdestructs: [],
      accessed_addresses: [],
      accessed_storage: [],
    };
  },

  /**
   * Create a failed call result
   */
  failure(gas_left: bigint): CallResult {
    return {
      success: false,
      gas_left,
      output: new Uint8Array(0),
      refund_counter: 0n,
      logs: [],
      selfdestructs: [],
      accessed_addresses: [],
      accessed_storage: [],
    };
  },

  /**
   * Create a failed call result with error information
   */
  failureWithError(gas_left: bigint, error_info: string): CallResult {
    return {
      success: false,
      gas_left,
      output: new Uint8Array(0),
      refund_counter: 0n,
      logs: [],
      selfdestructs: [],
      accessed_addresses: [],
      accessed_storage: [],
      error_info,
    };
  },

  /**
   * Create a reverted call result with revert data
   */
  revertWithData(gas_left: bigint, revert_data: Uint8Array): CallResult {
    return {
      success: false,
      gas_left,
      output: revert_data.length > 0 ? new Uint8Array(revert_data) : new Uint8Array(0),
      refund_counter: 0n,
      logs: [],
      selfdestructs: [],
      accessed_addresses: [],
      accessed_storage: [],
    };
  },

  /**
   * Create a successful call result with output and logs
   */
  successWithLogs(gas_left: bigint, output: Uint8Array, logs: Log[]): CallResult {
    // Deep copy logs
    const logs_copy = logs.map((log) => ({
      address: new Uint8Array(log.address),
      topics: [...log.topics],
      data: new Uint8Array(log.data),
    }));

    return {
      success: true,
      gas_left,
      output: new Uint8Array(output),
      refund_counter: 0n,
      logs: logs_copy,
      selfdestructs: [],
      accessed_addresses: [],
      accessed_storage: [],
    };
  },

  /**
   * Check if the call succeeded
   */
  isSuccess(result: CallResult): boolean {
    return result.success;
  },

  /**
   * Check if the call failed
   */
  isFailure(result: CallResult): boolean {
    return !result.success;
  },

  /**
   * Check if the call has output data
   */
  hasOutput(result: CallResult): boolean {
    return result.output.length > 0;
  },

  /**
   * Get the amount of gas consumed
   */
  gasConsumed(result: CallResult, original_gas: bigint): bigint {
    if (result.gas_left > original_gas) return 0n; // Sanity check
    return original_gas - result.gas_left;
  },

  /**
   * Create a deep copy of a CallResult
   */
  clone(result: CallResult): CallResult {
    return {
      success: result.success,
      gas_left: result.gas_left,
      output: new Uint8Array(result.output),
      refund_counter: result.refund_counter,
      logs: result.logs.map((log) => ({
        address: new Uint8Array(log.address),
        topics: [...log.topics],
        data: new Uint8Array(log.data),
      })),
      selfdestructs: result.selfdestructs.map((sd) => ({
        contract: new Uint8Array(sd.contract),
        beneficiary: new Uint8Array(sd.beneficiary),
      })),
      accessed_addresses: result.accessed_addresses.map((addr) => new Uint8Array(addr)),
      accessed_storage: result.accessed_storage.map((sa) => ({
        address: new Uint8Array(sa.address),
        slot: sa.slot,
      })),
      trace: result.trace
        ? {
            steps: result.trace.steps.map((step) => ({
              pc: step.pc,
              opcode: step.opcode,
              opcode_name: step.opcode_name,
              gas: step.gas,
              depth: step.depth,
              gas_cost: step.gas_cost,
              stack: [...step.stack],
              memory: new Uint8Array(step.memory),
              mem_size: step.mem_size,
              storage_reads: step.storage_reads.map((sr) => ({
                address: new Uint8Array(sr.address),
                slot: sr.slot,
                value: sr.value,
              })),
              storage_writes: step.storage_writes.map((sw) => ({
                address: new Uint8Array(sw.address),
                slot: sw.slot,
                old_value: sw.old_value,
                new_value: sw.new_value,
              })),
            })),
          }
        : undefined,
      error_info: result.error_info,
      created_address: result.created_address ? new Uint8Array(result.created_address) : undefined,
    };
  },

  /**
   * Create an empty execution trace
   */
  emptyTrace(): ExecutionTrace {
    return {
      steps: [],
    };
  },
};

/**
 * Export helper functions as top-level exports for convenience
 */
export const {
  successWithOutput,
  successEmpty,
  failure,
  failureWithError,
  revertWithData,
  successWithLogs,
  isSuccess,
  isFailure,
  hasOutput,
  gasConsumed,
  clone,
  emptyTrace,
} = CallResultHelpers;
