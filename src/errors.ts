/**
 * Error types for EVM operations
 *
 * This enum defines all possible error conditions that can occur during
 * EVM execution, including validation, execution, and resource errors.
 */
export enum CallError {
  /** Invalid jump destination in bytecode */
  InvalidJump = 'InvalidJump',

  /** Insufficient gas to complete operation */
  OutOfGas = 'OutOfGas',

  /** Attempted to pop from empty stack */
  StackUnderflow = 'StackUnderflow',

  /** Stack exceeded maximum size of 1024 items */
  StackOverflow = 'StackOverflow',

  /** Contract code not found at address */
  ContractNotFound = 'ContractNotFound',

  /** Precompiled contract execution failed */
  PrecompileError = 'PrecompileError',

  /** Memory allocation or expansion failed */
  MemoryError = 'MemoryError',

  /** Storage operation failed */
  StorageError = 'StorageError',

  /** Call depth exceeded maximum of 1024 */
  CallDepthExceeded = 'CallDepthExceeded',

  /** Account balance insufficient for value transfer */
  InsufficientBalance = 'InsufficientBalance',

  /** Contract creation at address with existing code/nonce */
  ContractCollision = 'ContractCollision',

  /** Bytecode format is invalid */
  InvalidBytecode = 'InvalidBytecode',

  /** Attempted state modification in STATICCALL context */
  StaticCallViolation = 'StaticCallViolation',

  /** Encountered undefined or invalid opcode */
  InvalidOpcode = 'InvalidOpcode',

  /** Execution reverted (REVERT opcode) */
  RevertExecution = 'RevertExecution',

  /** System out of memory */
  OutOfMemory = 'OutOfMemory',

  /** Memory allocation failed */
  AllocationError = 'AllocationError',

  /** Account does not exist */
  AccountNotFound = 'AccountNotFound',

  /** Jump destination is not valid JUMPDEST */
  InvalidJumpDestination = 'InvalidJumpDestination',

  /** Jump destination metadata not available */
  MissingJumpDestMetadata = 'MissingJumpDestMetadata',

  /** Init code size exceeds EIP-3860 limit */
  InitcodeTooLarge = 'InitcodeTooLarge',

  /** PUSH opcode data is truncated */
  TruncatedPush = 'TruncatedPush',

  /** Memory or array access out of bounds */
  OutOfBounds = 'OutOfBounds',

  /** Attempted write in read-only context */
  WriteProtection = 'WriteProtection',

  /** Contract bytecode exceeds maximum size */
  BytecodeTooLarge = 'BytecodeTooLarge',

  /** Invalid PUSH opcode data */
  InvalidPush = 'InvalidPush',

  /** CREATE init code exceeds size limit */
  CreateInitCodeSizeLimit = 'CreateInitCodeSizeLimit',

  /** Created contract code exceeds size limit */
  CreateContractSizeLimit = 'CreateContractSizeLimit',

  /** Execution exceeded time limit */
  ExecutionTimeout = 'ExecutionTimeout',

  // CallParams validation errors

  /** Gas parameter is zero */
  GasZeroError = 'GasZeroError',

  /** Input size is invalid */
  InvalidInputSize = 'InvalidInputSize',

  /** Init code size is invalid */
  InvalidInitCodeSize = 'InvalidInitCodeSize',

  /** Value parameter invalid for CREATE */
  InvalidCreateValue = 'InvalidCreateValue',

  /** Non-zero value in STATICCALL */
  InvalidStaticCallValue = 'InvalidStaticCallValue',

  // IO errors

  /** Disk/storage is full */
  NoSpaceLeft = 'NoSpaceLeft',

  // Async storage injection

  /** Async data required to continue */
  NeedAsyncData = 'NeedAsyncData',
}

/**
 * Custom error class for EVM execution errors
 */
export class EvmError extends Error {
  constructor(
    public readonly errorType: CallError,
    message?: string
  ) {
    super(message || errorType);
    this.name = 'EvmError';
  }
}
