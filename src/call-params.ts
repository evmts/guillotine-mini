/**
 * Call parameter types for EVM operations
 *
 * Discriminated union for all call types: CALL, CALLCODE, DELEGATECALL, STATICCALL, CREATE, CREATE2
 */

export type Address = Uint8Array;

/**
 * Validation errors for call parameters
 */
export class ValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

export class GasZeroError extends ValidationError {
  constructor() {
    super('Gas must be non-zero');
    this.name = 'GasZeroError';
  }
}

export class InvalidInputSizeError extends ValidationError {
  constructor(size: number, max: number) {
    super(`Input size ${size} exceeds maximum ${max}`);
    this.name = 'InvalidInputSizeError';
  }
}

export class InvalidInitCodeSizeError extends ValidationError {
  constructor(size: number, max: number) {
    super(`Init code size ${size} exceeds maximum ${max} (EIP-3860)`);
    this.name = 'InvalidInitCodeSizeError';
  }
}

/**
 * Regular CALL operation
 */
export interface CallParams {
  type: 'call';
  caller: Address;
  to: Address;
  value: bigint;
  input: Uint8Array;
  gas: bigint;
}

/**
 * CALLCODE operation: execute external code with current storage/context
 * Executes code at `to`, but uses caller's storage and address context
 */
export interface CallCodeParams {
  type: 'callcode';
  caller: Address;
  to: Address;
  value: bigint;
  input: Uint8Array;
  gas: bigint;
}

/**
 * DELEGATECALL operation (preserves caller context)
 */
export interface DelegateCallParams {
  type: 'delegatecall';
  caller: Address; // Original caller, not current contract
  to: Address;
  input: Uint8Array;
  gas: bigint;
}

/**
 * STATICCALL operation (read-only)
 */
export interface StaticCallParams {
  type: 'staticcall';
  caller: Address;
  to: Address;
  input: Uint8Array;
  gas: bigint;
}

/**
 * CREATE operation
 */
export interface CreateParams {
  type: 'create';
  caller: Address;
  value: bigint;
  initCode: Uint8Array;
  gas: bigint;
}

/**
 * CREATE2 operation
 */
export interface Create2Params {
  type: 'create2';
  caller: Address;
  value: bigint;
  initCode: Uint8Array;
  salt: bigint;
  gas: bigint;
}

/**
 * Discriminated union of all call parameter types
 */
export type CallParamsUnion =
  | CallParams
  | CallCodeParams
  | DelegateCallParams
  | StaticCallParams
  | CreateParams
  | Create2Params;

/**
 * Constants for validation
 */
export const MAX_INITCODE_SIZE = 49152; // EIP-3860: 2 * max contract size
export const MAX_INPUT_SIZE = 1024 * 1024 * 4; // 4MB practical limit for input data

/**
 * Validate call parameters to ensure they meet EVM requirements.
 * Checks gas limits and other critical constraints.
 *
 * @param params - Call parameters to validate
 * @throws {GasZeroError} If gas is zero
 * @throws {InvalidInputSizeError} If input size exceeds maximum
 * @throws {InvalidInitCodeSizeError} If init code size exceeds maximum (EIP-3860)
 */
export function validate(params: CallParamsUnion): void {
  // Gas must be non-zero to execute any operation
  // Note: BUG in original - we should be checking if gas checks are disabled or not
  if (getGas(params) === 0n) {
    throw new GasZeroError();
  }

  switch (params.type) {
    case 'call':
      // Validate input data size
      if (params.input.length > MAX_INPUT_SIZE) {
        throw new InvalidInputSizeError(params.input.length, MAX_INPUT_SIZE);
      }
      break;

    case 'callcode':
      // Validate input data size
      if (params.input.length > MAX_INPUT_SIZE) {
        throw new InvalidInputSizeError(params.input.length, MAX_INPUT_SIZE);
      }
      break;

    case 'delegatecall':
      // Validate input data size
      if (params.input.length > MAX_INPUT_SIZE) {
        throw new InvalidInputSizeError(params.input.length, MAX_INPUT_SIZE);
      }
      // DELEGATECALL doesn't transfer value, validation happens at protocol level
      break;

    case 'staticcall':
      // Validate input data size
      if (params.input.length > MAX_INPUT_SIZE) {
        throw new InvalidInputSizeError(params.input.length, MAX_INPUT_SIZE);
      }
      // STATICCALL cannot have value (enforced by not having value field)
      break;

    case 'create':
      // Validate init code size (EIP-3860)
      if (params.initCode.length > MAX_INITCODE_SIZE) {
        throw new InvalidInitCodeSizeError(params.initCode.length, MAX_INITCODE_SIZE);
      }
      // CREATE can have any value, no special validation needed
      break;

    case 'create2':
      // Validate init code size (EIP-3860)
      if (params.initCode.length > MAX_INITCODE_SIZE) {
        throw new InvalidInitCodeSizeError(params.initCode.length, MAX_INITCODE_SIZE);
      }
      // CREATE2 can have any value, no special validation needed
      break;
  }
}

/**
 * Get the gas limit for this call operation
 *
 * @param params - Call parameters
 * @returns Gas limit
 */
export function getGas(params: CallParamsUnion): bigint {
  return params.gas;
}

/**
 * Set the gas limit for this call operation (mutates params)
 *
 * @param params - Call parameters to modify
 * @param gas - New gas limit
 */
export function setGas(params: CallParamsUnion, gas: bigint): void {
  params.gas = gas;
}

/**
 * Get the caller address for this call operation
 *
 * @param params - Call parameters
 * @returns Caller address
 */
export function getCaller(params: CallParamsUnion): Address {
  return params.caller;
}

/**
 * Get the input data for this call operation
 *
 * @param params - Call parameters
 * @returns Input data or init code
 */
export function getInput(params: CallParamsUnion): Uint8Array {
  switch (params.type) {
    case 'call':
    case 'callcode':
    case 'delegatecall':
    case 'staticcall':
      return params.input;
    case 'create':
    case 'create2':
      return params.initCode;
  }
}

/**
 * Check if this call operation transfers value
 *
 * @param params - Call parameters
 * @returns true if value is transferred
 */
export function hasValue(params: CallParamsUnion): boolean {
  switch (params.type) {
    case 'call':
    case 'callcode':
      return params.value > 0n;
    case 'delegatecall':
      // DELEGATECALL preserves value from parent context
      return false;
    case 'staticcall':
      // STATICCALL cannot transfer value
      return false;
    case 'create':
    case 'create2':
      return params.value > 0n;
  }
}

/**
 * Check if this is a read-only operation
 *
 * @param params - Call parameters
 * @returns true if read-only (STATICCALL)
 */
export function isReadOnly(params: CallParamsUnion): boolean {
  return params.type === 'staticcall';
}

/**
 * Check if this is a contract creation operation
 *
 * @param params - Call parameters
 * @returns true if CREATE or CREATE2
 */
export function isCreate(params: CallParamsUnion): boolean {
  return params.type === 'create' || params.type === 'create2';
}

/**
 * Get the target address for the call (returns null for CREATE operations)
 *
 * @param params - Call parameters
 * @returns Target address or null for CREATE operations
 */
export function getTo(params: CallParamsUnion): Address | null {
  switch (params.type) {
    case 'call':
    case 'callcode':
    case 'delegatecall':
    case 'staticcall':
      return params.to;
    case 'create':
    case 'create2':
      return null;
  }
}

/**
 * Creates a deep copy of the CallParams
 * Clones all dynamic data (input/init_code)
 *
 * @param params - Call parameters to clone
 * @returns Cloned call parameters
 */
export function clone(params: CallParamsUnion): CallParamsUnion {
  switch (params.type) {
    case 'call':
      return {
        type: 'call',
        caller: params.caller,
        to: params.to,
        value: params.value,
        input: new Uint8Array(params.input),
        gas: params.gas,
      };

    case 'callcode':
      return {
        type: 'callcode',
        caller: params.caller,
        to: params.to,
        value: params.value,
        input: new Uint8Array(params.input),
        gas: params.gas,
      };

    case 'delegatecall':
      return {
        type: 'delegatecall',
        caller: params.caller,
        to: params.to,
        input: new Uint8Array(params.input),
        gas: params.gas,
      };

    case 'staticcall':
      return {
        type: 'staticcall',
        caller: params.caller,
        to: params.to,
        input: new Uint8Array(params.input),
        gas: params.gas,
      };

    case 'create':
      return {
        type: 'create',
        caller: params.caller,
        value: params.value,
        initCode: new Uint8Array(params.initCode),
        gas: params.gas,
      };

    case 'create2':
      return {
        type: 'create2',
        caller: params.caller,
        value: params.value,
        initCode: new Uint8Array(params.initCode),
        salt: params.salt,
        gas: params.gas,
      };
  }
}
