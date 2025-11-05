/**
 * System opcode handlers for the EVM
 *
 * Implements CALL, CALLCODE, DELEGATECALL, STATICCALL, CREATE, CREATE2,
 * RETURN, REVERT, and SELFDESTRUCT opcodes.
 *
 * These are the most complex handlers as they:
 * - Call into evm.inner_call() and evm.inner_create()
 * - Perform complex gas calculation (EIP-2929 warm/cold, value transfer, memory expansion)
 * - Handle call depth limits (1024)
 * - Implement SELFDESTRUCT with EIP-6780 (Cancun+) - only deletes if created in same tx
 * - Calculate CREATE/CREATE2 addresses
 * - Manage nested execution contexts
 *
 * Port of src/instructions/handlers_system.zig to TypeScript
 */

import { CallError, EvmError } from '../errors';
import type { Address } from '../host';

/**
 * Gas constants for system operations
 * Must match primitives/gas_constants.zig exactly
 */
export const GasConstants = {
  // Call costs
  CallGas: 700n,                       // EIP-150: CALL base cost
  CallValueTransferGas: 9000n,         // Cost for non-zero value transfer
  CallNewAccountGas: 25000n,           // Cost for calling non-existent account with value
  CallStipend: 2300n,                  // Gas stipend for calls with value (free, not charged to caller)

  // Access costs (EIP-2929)
  WarmStorageReadCost: 100n,           // Warm access cost
  ColdAccountAccessCost: 2600n,        // Cold account access cost

  // CREATE costs
  CreateGas: 32000n,                   // CREATE/CREATE2 base cost
  Create2Gas: 32000n,                  // CREATE2 base cost (same as CREATE)
  InitCodeWordGas: 2n,                 // Per-word cost for init code (EIP-3860)
  MaxInitcodeSize: 49152,              // Maximum init code size (EIP-3860, Shanghai+)

  // SELFDESTRUCT costs
  SelfdestructGas: 5000n,              // SELFDESTRUCT base cost
  SelfdestructRefundGas: 24000n,       // Refund for SELFDESTRUCT (pre-London)
} as const;

/**
 * Hardfork enum for version checks
 * Must match primitives.Hardfork
 */
export enum Hardfork {
  FRONTIER = 0,
  HOMESTEAD = 1,
  TANGERINE = 2,
  SPURIOUS = 3,
  BYZANTIUM = 4,
  CONSTANTINOPLE = 5,
  ISTANBUL = 6,
  BERLIN = 7,
  LONDON = 8,
  MERGE = 9,
  SHANGHAI = 10,
  CANCUN = 11,
  PRAGUE = 12,
}

/**
 * Call parameter types for inner_call
 */
export interface CallParams {
  caller: Address;
  to: Address;
  value: bigint;
  input: Uint8Array;
  gas: bigint;
}

export interface CallCodeParams {
  caller: Address;
  to: Address;
  value: bigint;
  input: Uint8Array;
  gas: bigint;
}

export interface DelegateCallParams {
  caller: Address;
  to: Address;
  input: Uint8Array;
  gas: bigint;
}

export interface StaticCallParams {
  caller: Address;
  to: Address;
  input: Uint8Array;
  gas: bigint;
}

/**
 * Call result from inner_call
 */
export interface CallResult {
  success: boolean;
  gas_left: bigint;
  output: Uint8Array;
}

/**
 * Create result from inner_create
 */
export interface CreateResult {
  address: Address;
  success: boolean;
  gas_left: bigint;
  output: Uint8Array;
}

/**
 * EVM interface (subset needed for system handlers)
 */
export interface EvmInterface {
  hardfork: Hardfork;
  gas_refund: bigint;

  // State access
  getBalance(address: Address): bigint;
  getCode(address: Address): Uint8Array;
  getNonce(address: Address): bigint;

  // Warm/cold tracking (EIP-2929)
  isAddressWarm(address: Address): boolean;
  warmAddress(address: Address): void;
  accessAddress(address: Address): bigint;  // Returns 0 for pre-Berlin, 100 for warm, 2600 for cold

  // Account existence check
  accountExists(address: Address): boolean;

  // Created accounts tracking (EIP-6780)
  wasCreatedThisTransaction(address: Address): boolean;

  // Nested call execution
  inner_call(params: CallParams | CallCodeParams | DelegateCallParams | StaticCallParams): CallResult;
  inner_create(value: bigint, init_code: Uint8Array, gas: bigint, salt: bigint | null): CreateResult;
}

/**
 * Frame interface (subset needed for system handlers)
 */
export interface FrameInterface {
  // Stack operations
  popStack(): bigint;
  pushStack(value: bigint): void;

  // Memory operations
  readMemory(offset: number): number;
  writeMemory(offset: number, value: number): void;
  memory_size: number;

  // Gas operations
  gas_remaining: bigint;
  consumeGas(amount: bigint): void;

  // Memory expansion cost calculation
  memoryExpansionCost(end_bytes: bigint): bigint;

  // Gas cost helpers
  createGasCost(length: number): bigint;
  create2GasCost(length: number): bigint;
  selfdestructGasCost(): bigint;
  selfdestructRefund(): bigint;

  // Execution state
  is_static: boolean;
  stopped: boolean;
  return_data: Uint8Array;
  address: Address;
  caller: Address;
  pc: number;

  // Allocator
  allocator: any;

  // Access to EVM
  getEvm(): EvmInterface;
}

/**
 * Helper functions
 */

function wordCount(bytes: bigint): bigint {
  return (bytes + 31n) / 32n;
}

function wordAlignedSize(bytes: bigint): number {
  const words = wordCount(bytes);
  return Number(words * 32n);
}

function add_u32(a: number, b: number): number {
  const result = a + b;
  if (result > 0xFFFFFFFF) {
    throw new Error('OutOfBounds');
  }
  return result;
}

/**
 * System handler implementations
 */

/**
 * CREATE opcode (0xf0) - Create a new contract
 *
 * Stack input:
 *   value: u256      - Wei to transfer to new contract
 *   offset: u256     - Byte offset in memory (init code start)
 *   length: u256     - Byte length of init code
 *
 * Stack output:
 *   address: u256    - Address of created contract (0 if failed)
 */
export function create(frame: FrameInterface): void {
  // EIP-214: CREATE cannot be executed in static call context
  if (frame.is_static) {
    throw new Error(CallError.StaticCallViolation);
  }

  // Clear return_data at the start (per Python reference implementation)
  frame.return_data = new Uint8Array(0);

  const value = frame.popStack();
  const offset = frame.popStack();
  const length = frame.popStack();

  // Convert length to u32
  if (length > 0xFFFFFFFFn) {
    throw new Error(EvmError.OutOfBounds);
  }
  const len = Number(length);

  // Charge for CREATE operation
  const gas_cost = frame.createGasCost(len);
  frame.consumeGas(gas_cost);

  // Read init code from memory
  let init_code = new Uint8Array(0);
  if (length > 0n && length <= 0xFFFFFFFFn) {
    if (offset > 0xFFFFFFFFn) {
      throw new Error(EvmError.OutOfBounds);
    }
    const off = Number(offset);

    // Check memory bounds and charge for expansion
    const end_bytes = BigInt(off) + BigInt(len);
    const mem_cost = frame.memoryExpansionCost(end_bytes);
    frame.consumeGas(mem_cost);

    // Update logical memory size
    const aligned = wordAlignedSize(end_bytes);
    if (aligned > frame.memory_size) {
      frame.memory_size = aligned;
    }

    // Read init code
    const code = new Uint8Array(len);
    for (let j = 0; j < len; j++) {
      const addr = add_u32(off, j);
      code[j] = frame.readMemory(addr);
    }
    init_code = code;
  }

  const evm = frame.getEvm();

  // Calculate available gas
  // EIP-150: all but 1/64th (introduced in Tangerine Whistle)
  // Before EIP-150: forward all remaining gas
  const remaining_gas = BigInt(Math.max(Number(frame.gas_remaining), 0));
  const max_gas = evm.hardfork >= Hardfork.TANGERINE
    ? remaining_gas - (remaining_gas / 64n)
    : remaining_gas;

  // Perform CREATE
  const result = evm.inner_create(value, init_code, max_gas, null);

  // Update gas
  const gas_used = max_gas - result.gas_left;
  frame.gas_remaining -= gas_used;

  // Set return_data according to CREATE semantics:
  // - On success: return_data is empty
  // - On failure: return_data is the child's output
  if (result.success) {
    frame.return_data = new Uint8Array(0);
  } else {
    frame.return_data = result.output;
  }

  // Push address onto stack (0 if failed)
  let addr_u256 = 0n;
  if (result.success) {
    for (const b of result.address.bytes) {
      addr_u256 = (addr_u256 << 8n) | BigInt(b);
    }
  }
  frame.pushStack(addr_u256);

  frame.pc += 1;
}

/**
 * CALL opcode (0xf1) - Message call into an account
 *
 * Stack input:
 *   gas: u256           - Gas to forward to callee
 *   address: u256       - Target address
 *   value: u256         - Wei to transfer
 *   in_offset: u256     - Input data offset in memory
 *   in_length: u256     - Input data length
 *   out_offset: u256    - Output data offset in memory
 *   out_length: u256    - Output data length
 *
 * Stack output:
 *   success: u256       - 1 if call succeeded, 0 if failed
 */
export function call(frame: FrameInterface): void {
  // Pop all 7 arguments
  const gas = frame.popStack();
  const address_u256 = frame.popStack();
  const value_arg = frame.popStack();
  const in_offset = frame.popStack();
  const in_length = frame.popStack();
  const out_offset = frame.popStack();
  const out_length = frame.popStack();

  // EIP-214: CALL with non-zero value cannot be executed in static call context
  if (frame.is_static && value_arg > 0n) {
    throw new Error(CallError.StaticCallViolation);
  }

  // Convert address
  const addr_bytes = new Uint8Array(20);
  for (let i = 0; i < 20; i++) {
    addr_bytes[19 - i] = Number((address_u256 >> BigInt(i * 8)) & 0xFFn);
  }
  const call_address: Address = { bytes: addr_bytes };

  const evm = frame.getEvm();

  // Gas cost calculation based on hardfork
  let gas_cost = 0n;

  // EIP-2929 (Berlin+): Use warm/cold access costs instead of flat base cost
  // EIP-150 (Tangerine Whistle): Changed base cost from 40 to 700
  // Pre-Tangerine Whistle: Use 40 gas base cost
  if (evm.hardfork < Hardfork.BERLIN) {
    gas_cost = evm.hardfork < Hardfork.TANGERINE ? 40n : GasConstants.CallGas;
  }

  if (value_arg > 0n) {
    gas_cost += GasConstants.CallValueTransferGas;

    // Check if target account exists
    // If calling non-existent account with value, add account creation cost
    const target_exists = evm.accountExists(call_address);
    if (!target_exists) {
      gas_cost += GasConstants.CallNewAccountGas; // +25000 for creating new account
    }
  }

  // EIP-2929 (Berlin+): access target account (warm/cold)
  // Returns 0 for pre-Berlin, 100 for warm, 2600 for cold in Berlin+
  const access_cost = evm.accessAddress(call_address);
  gas_cost += access_cost;

  // Calculate memory expansion cost for BOTH input and output regions together
  const in_end = in_length > 0n ? in_offset + in_length : 0n;
  const out_end = out_length > 0n ? out_offset + out_length : 0n;
  const max_end = in_end > out_end ? in_end : out_end;

  if (max_end > 0n) {
    const mem_cost = frame.memoryExpansionCost(max_end);
    gas_cost += mem_cost;

    // Update memory_size immediately after charging
    const aligned_size = wordAlignedSize(max_end);
    if (aligned_size > frame.memory_size) {
      frame.memory_size = aligned_size;
    }
  }

  // Calculate available gas BEFORE charging (per Python execution-specs)
  const gas_limit = gas > 0xFFFFFFFFFFFFFFFFn ? 0xFFFFFFFFFFFFFFFFn : gas;
  const remaining_gas_before_charge = BigInt(Math.max(Number(frame.gas_remaining), 0));
  const gas_after_charge = remaining_gas_before_charge >= gas_cost
    ? remaining_gas_before_charge - gas_cost
    : 0n;

  // EIP-150: all but 1/64th (introduced in Tangerine Whistle)
  const max_gas = evm.hardfork >= Hardfork.TANGERINE
    ? gas_after_charge - (gas_after_charge / 64n)
    : gas_after_charge;

  const available_gas_without_stipend = gas_limit < max_gas ? gas_limit : max_gas;

  // Add gas stipend for value transfers (stipend is free, caller doesn't pay for it)
  const available_gas = value_arg > 0n
    ? available_gas_without_stipend + GasConstants.CallStipend
    : available_gas_without_stipend;

  // NOW charge the total cost
  const total_cost = gas_cost + available_gas_without_stipend;
  frame.consumeGas(total_cost);

  // Read input data from memory
  let input_data = new Uint8Array(0);
  if (in_length > 0n && in_length <= 0xFFFFFFFFn) {
    const in_off = Number(in_offset);
    const in_len = Number(in_length);

    if (in_off + in_len >= in_off) {
      const data = new Uint8Array(in_len);
      for (let j = 0; j < in_len; j++) {
        const addr = add_u32(in_off, j);
        data[j] = frame.readMemory(addr);
      }
      input_data = data;
    }
  }

  // Perform the inner call (regular CALL)
  const params: CallParams = {
    caller: frame.address,
    to: call_address,
    value: value_arg,
    input: input_data,
    gas: available_gas,
  };
  const result = evm.inner_call(params);

  // Write output to memory
  if (out_length > 0n && result.output.length > 0) {
    const out_off = Number(out_offset);
    const out_len_u32 = Number(out_length);
    const result_len_u32 = result.output.length;
    const copy_len = Math.min(out_len_u32, result_len_u32);

    for (let k = 0; k < copy_len; k++) {
      const addr = add_u32(out_off, k);
      frame.writeMemory(addr, result.output[k]);
    }
  }

  // Store return data
  frame.return_data = result.output;

  // Push success status
  frame.pushStack(result.success ? 1n : 0n);

  // Refund unused gas (including any unused stipend)
  const gas_to_refund = result.gas_left < available_gas ? result.gas_left : available_gas;
  frame.gas_remaining += gas_to_refund;

  frame.pc += 1;
}

/**
 * CALLCODE opcode (0xf2) - Message call into this account with another account's code
 * Similar to CALL but executes code in current context
 */
export function callcode(frame: FrameInterface): void {
  // Pop all 7 arguments
  const gas = frame.popStack();
  const address_u256 = frame.popStack();
  const value_arg = frame.popStack();
  const in_offset = frame.popStack();
  const in_length = frame.popStack();
  const out_offset = frame.popStack();
  const out_length = frame.popStack();

  // Convert address
  const addr_bytes = new Uint8Array(20);
  for (let i = 0; i < 20; i++) {
    addr_bytes[19 - i] = Number((address_u256 >> BigInt(i * 8)) & 0xFFn);
  }
  const call_address: Address = { bytes: addr_bytes };

  const evm = frame.getEvm();

  // Gas cost calculation based on hardfork
  let gas_cost = 0n;

  if (evm.hardfork < Hardfork.BERLIN) {
    gas_cost = evm.hardfork < Hardfork.TANGERINE ? 40n : GasConstants.CallGas;
  }

  if (value_arg > 0n) {
    gas_cost += GasConstants.CallValueTransferGas;
  }

  const access_cost = evm.accessAddress(call_address);
  gas_cost += access_cost;

  // Calculate memory expansion cost
  const in_end = in_length > 0n ? in_offset + in_length : 0n;
  const out_end = out_length > 0n ? out_offset + out_length : 0n;
  const max_end = in_end > out_end ? in_end : out_end;

  if (max_end > 0n) {
    const mem_cost = frame.memoryExpansionCost(max_end);
    gas_cost += mem_cost;
    const aligned_size = wordAlignedSize(max_end);
    if (aligned_size > frame.memory_size) {
      frame.memory_size = aligned_size;
    }
  }

  // Calculate available gas
  const gas_limit = gas > 0xFFFFFFFFFFFFFFFFn ? 0xFFFFFFFFFFFFFFFFn : gas;
  const remaining_gas_before_charge = BigInt(Math.max(Number(frame.gas_remaining), 0));
  const gas_after_charge = remaining_gas_before_charge >= gas_cost
    ? remaining_gas_before_charge - gas_cost
    : 0n;

  const max_gas = evm.hardfork >= Hardfork.TANGERINE
    ? gas_after_charge - (gas_after_charge / 64n)
    : gas_after_charge;

  const available_gas_without_stipend = gas_limit < max_gas ? gas_limit : max_gas;
  const available_gas = value_arg > 0n
    ? available_gas_without_stipend + GasConstants.CallStipend
    : available_gas_without_stipend;

  const total_cost = gas_cost + available_gas_without_stipend;
  frame.consumeGas(total_cost);

  // Read input data
  let input_data = new Uint8Array(0);
  if (in_length > 0n && in_length <= 0xFFFFFFFFn) {
    const in_off = Number(in_offset);
    const in_len = Number(in_length);

    if (in_off + in_len >= in_off) {
      const data = new Uint8Array(in_len);
      for (let j = 0; j < in_len; j++) {
        const addr = add_u32(in_off, j);
        data[j] = frame.readMemory(addr);
      }
      input_data = data;
    }
  }

  // Perform the inner call (CALLCODE)
  const params: CallCodeParams = {
    caller: frame.address,
    to: call_address,
    value: value_arg,
    input: input_data,
    gas: available_gas,
  };
  const result = evm.inner_call(params);

  // Write output to memory
  if (out_length > 0n && result.output.length > 0) {
    const out_off = Number(out_offset);
    const out_len_u32 = Number(out_length);
    const result_len_u32 = result.output.length;
    const copy_len = Math.min(out_len_u32, result_len_u32);

    for (let k = 0; k < copy_len; k++) {
      const addr = add_u32(out_off, k);
      frame.writeMemory(addr, result.output[k]);
    }
  }

  frame.return_data = result.output;
  frame.pushStack(result.success ? 1n : 0n);

  const gas_to_refund = result.gas_left < available_gas ? result.gas_left : available_gas;
  frame.gas_remaining += gas_to_refund;

  frame.pc += 1;
}

/**
 * DELEGATECALL opcode (0xf4) - Message call with another account's code,
 * but keep current msg.sender and msg.value
 *
 * EIP-7: Introduced in Homestead hardfork
 */
export function delegatecall(frame: FrameInterface): void {
  const evm = frame.getEvm();

  // EIP-7: DELEGATECALL was introduced in Homestead hardfork
  if (evm.hardfork < Hardfork.HOMESTEAD) {
    throw new Error(EvmError.InvalidOpcode);
  }

  // Pop all 6 arguments (no value)
  const gas = frame.popStack();
  const address_u256 = frame.popStack();
  const in_offset = frame.popStack();
  const in_length = frame.popStack();
  const out_offset = frame.popStack();
  const out_length = frame.popStack();

  // Convert address
  const addr_bytes = new Uint8Array(20);
  for (let i = 0; i < 20; i++) {
    addr_bytes[19 - i] = Number((address_u256 >> BigInt(i * 8)) & 0xFFn);
  }
  const call_address: Address = { bytes: addr_bytes };

  // Gas cost calculation
  let gas_cost = 0n;

  if (evm.hardfork < Hardfork.BERLIN) {
    gas_cost = evm.hardfork < Hardfork.TANGERINE ? 40n : GasConstants.CallGas;
  }

  const access_cost = evm.accessAddress(call_address);
  gas_cost += access_cost;

  // Calculate memory expansion cost
  const in_end = in_length > 0n ? in_offset + in_length : 0n;
  const out_end = out_length > 0n ? out_offset + out_length : 0n;
  const max_end = in_end > out_end ? in_end : out_end;

  if (max_end > 0n) {
    const mem_cost = frame.memoryExpansionCost(max_end);
    gas_cost += mem_cost;
    const aligned_size = wordAlignedSize(max_end);
    if (aligned_size > frame.memory_size) {
      frame.memory_size = aligned_size;
    }
  }

  // Calculate available gas
  const gas_limit = gas > 0xFFFFFFFFFFFFFFFFn ? 0xFFFFFFFFFFFFFFFFn : gas;
  const remaining_gas_before_charge = BigInt(Math.max(Number(frame.gas_remaining), 0));
  const gas_after_charge = remaining_gas_before_charge >= gas_cost
    ? remaining_gas_before_charge - gas_cost
    : 0n;

  const max_gas = evm.hardfork >= Hardfork.TANGERINE
    ? gas_after_charge - (gas_after_charge / 64n)
    : gas_after_charge;

  const available_gas = gas_limit < max_gas ? gas_limit : max_gas;

  const total_cost = gas_cost + available_gas;
  frame.consumeGas(total_cost);

  // Read input data
  let input_data = new Uint8Array(0);
  if (in_length > 0n && in_length <= 0xFFFFFFFFn) {
    const in_off = Number(in_offset);
    const in_len = Number(in_length);

    if (in_off + in_len >= in_off) {
      const data = new Uint8Array(in_len);
      for (let j = 0; j < in_len; j++) {
        const addr = add_u32(in_off, j);
        data[j] = frame.readMemory(addr);
      }
      input_data = data;
    }
  }

  // Perform the inner call (DELEGATECALL)
  const params: DelegateCallParams = {
    caller: frame.caller,
    to: call_address,
    input: input_data,
    gas: available_gas,
  };
  const result = evm.inner_call(params);

  // Write output to memory
  if (out_length > 0n && result.output.length > 0) {
    const out_off = Number(out_offset);
    const out_len_u32 = Number(out_length);
    const result_len_u32 = result.output.length;
    const copy_len = Math.min(out_len_u32, result_len_u32);

    for (let k = 0; k < copy_len; k++) {
      const addr = add_u32(out_off, k);
      frame.writeMemory(addr, result.output[k]);
    }
  }

  frame.return_data = result.output;
  frame.pushStack(result.success ? 1n : 0n);

  const gas_to_refund = result.gas_left < available_gas ? result.gas_left : available_gas;
  frame.gas_remaining += gas_to_refund;

  frame.pc += 1;
}

/**
 * STATICCALL opcode (0xfa) - Static message call (no state modifications allowed)
 *
 * EIP-214: Introduced in Byzantium hardfork
 */
export function staticcall(frame: FrameInterface): void {
  const evm = frame.getEvm();

  // EIP-214: STATICCALL was introduced in Byzantium hardfork
  if (evm.hardfork < Hardfork.BYZANTIUM) {
    throw new Error(EvmError.InvalidOpcode);
  }

  // Pop all 6 arguments (no value for static call)
  const gas = frame.popStack();
  const address_u256 = frame.popStack();
  const in_offset = frame.popStack();
  const in_length = frame.popStack();
  const out_offset = frame.popStack();
  const out_length = frame.popStack();

  // Convert address
  const addr_bytes = new Uint8Array(20);
  for (let i = 0; i < 20; i++) {
    addr_bytes[19 - i] = Number((address_u256 >> BigInt(i * 8)) & 0xFFn);
  }
  const call_address: Address = { bytes: addr_bytes };

  // Gas cost calculation
  let call_gas_cost = 0n;

  if (evm.hardfork < Hardfork.BERLIN) {
    call_gas_cost = evm.hardfork < Hardfork.TANGERINE ? 40n : GasConstants.CallGas;
  }

  const access_cost = evm.accessAddress(call_address);
  call_gas_cost += access_cost;

  // Calculate memory expansion cost
  const in_end = in_length > 0n ? in_offset + in_length : 0n;
  const out_end = out_length > 0n ? out_offset + out_length : 0n;
  const max_end = in_end > out_end ? in_end : out_end;

  if (max_end > 0n) {
    const mem_cost = frame.memoryExpansionCost(max_end);
    call_gas_cost += mem_cost;
    const aligned_size = wordAlignedSize(max_end);
    if (aligned_size > frame.memory_size) {
      frame.memory_size = aligned_size;
    }
  }

  // Calculate available gas
  const gas_limit = gas > 0xFFFFFFFFFFFFFFFFn ? 0xFFFFFFFFFFFFFFFFn : gas;
  const remaining_gas_before_charge = BigInt(Math.max(Number(frame.gas_remaining), 0));
  const gas_after_charge = remaining_gas_before_charge >= call_gas_cost
    ? remaining_gas_before_charge - call_gas_cost
    : 0n;

  const max_gas = evm.hardfork >= Hardfork.TANGERINE
    ? gas_after_charge - (gas_after_charge / 64n)
    : gas_after_charge;

  const available_gas = gas_limit < max_gas ? gas_limit : max_gas;

  const total_cost = call_gas_cost + available_gas;
  frame.consumeGas(total_cost);

  // Read input data
  let input_data = new Uint8Array(0);
  if (in_length > 0n && in_length <= 0xFFFFFFFFn) {
    const in_off = Number(in_offset);
    const in_len = Number(in_length);

    if (in_off + in_len >= in_off) {
      const data = new Uint8Array(in_len);
      for (let j = 0; j < in_len; j++) {
        const addr = add_u32(in_off, j);
        data[j] = frame.readMemory(addr);
      }
      input_data = data;
    }
  }

  // Perform the inner call (STATICCALL)
  const params: StaticCallParams = {
    caller: frame.address,
    to: call_address,
    input: input_data,
    gas: available_gas,
  };
  const result = evm.inner_call(params);

  // Write output to memory
  if (out_length > 0n && result.output.length > 0) {
    const out_off = Number(out_offset);
    const out_len_u32 = Number(out_length);
    const result_len_u32 = result.output.length;
    const copy_len = Math.min(out_len_u32, result_len_u32);

    for (let k = 0; k < copy_len; k++) {
      const addr = add_u32(out_off, k);
      frame.writeMemory(addr, result.output[k]);
    }
  }

  frame.return_data = result.output;
  frame.pushStack(result.success ? 1n : 0n);

  const gas_to_refund = result.gas_left < available_gas ? result.gas_left : available_gas;
  frame.gas_remaining += gas_to_refund;

  frame.pc += 1;
}

/**
 * CREATE2 opcode (0xf5) - Create a new contract with deterministic address
 *
 * EIP-1014: Introduced in Constantinople hardfork
 */
export function create2(frame: FrameInterface): void {
  const evm = frame.getEvm();

  // EIP-1014: CREATE2 opcode was introduced in Constantinople hardfork
  if (evm.hardfork < Hardfork.CONSTANTINOPLE) {
    throw new Error(EvmError.InvalidOpcode);
  }

  // EIP-214: CREATE2 cannot be executed in static call context
  if (frame.is_static) {
    throw new Error(CallError.StaticCallViolation);
  }

  // Clear return_data at the start
  frame.return_data = new Uint8Array(0);

  const value = frame.popStack();
  const offset = frame.popStack();
  const length = frame.popStack();
  const salt = frame.popStack();

  if (length > 0xFFFFFFFFn) {
    throw new Error(EvmError.OutOfBounds);
  }
  const len = Number(length);

  const gas_cost = frame.create2GasCost(len);
  frame.consumeGas(gas_cost);

  // Read init code from memory
  let init_code = new Uint8Array(0);
  if (length > 0n && length <= 0xFFFFFFFFn) {
    if (offset > 0xFFFFFFFFn) {
      throw new Error(EvmError.OutOfBounds);
    }
    const off = Number(offset);

    const end_bytes = BigInt(off) + BigInt(len);
    const mem_cost = frame.memoryExpansionCost(end_bytes);
    frame.consumeGas(mem_cost);

    const aligned = wordAlignedSize(end_bytes);
    if (aligned > frame.memory_size) {
      frame.memory_size = aligned;
    }

    const code = new Uint8Array(len);
    for (let j = 0; j < len; j++) {
      const addr = add_u32(off, j);
      code[j] = frame.readMemory(addr);
    }
    init_code = code;
  }

  // Calculate available gas
  const remaining_gas = BigInt(Math.max(Number(frame.gas_remaining), 0));
  const max_gas = evm.hardfork >= Hardfork.TANGERINE
    ? remaining_gas - (remaining_gas / 64n)
    : remaining_gas;

  // Perform CREATE2 with salt
  const result = evm.inner_create(value, init_code, max_gas, salt);

  // Update gas
  const gas_used = max_gas - result.gas_left;
  frame.gas_remaining -= gas_used;

  // Set return_data according to EIP-1014:
  // - On success: return_data is empty
  // - On failure: return_data is the child's output
  if (result.success) {
    frame.return_data = new Uint8Array(0);
  } else {
    frame.return_data = result.output;
  }

  // Push address onto stack (0 if failed)
  let addr_u256 = 0n;
  if (result.success) {
    for (const b of result.address.bytes) {
      addr_u256 = (addr_u256 << 8n) | BigInt(b);
    }
  }
  frame.pushStack(addr_u256);

  frame.pc += 1;
}

/**
 * SELFDESTRUCT opcode (0xff) - Halt execution and register account for deletion
 *
 * EIP-6780 (Cancun+): Only deletes account if created in same transaction
 * Pre-Cancun: Always deletes account at end of transaction
 */
export function selfdestruct(frame: FrameInterface): void {
  const beneficiary_u256 = frame.popStack();

  // Convert beneficiary to address
  const beneficiary_bytes = new Uint8Array(20);
  for (let i = 0; i < 20; i++) {
    beneficiary_bytes[19 - i] = Number((beneficiary_u256 >> BigInt(i * 8)) & 0xFFn);
  }
  const beneficiary: Address = { bytes: beneficiary_bytes };

  const evm = frame.getEvm();

  // Calculate gas cost
  let gas_cost = frame.selfdestructGasCost();

  // EIP-2929 (Berlin): Check if beneficiary is warm, add cold access cost if needed
  // IMPORTANT: Unlike CALL which always charges an access cost,
  // SELFDESTRUCT only charges if the beneficiary is cold
  if (evm.hardfork >= Hardfork.BERLIN) {
    const is_warm = evm.isAddressWarm(beneficiary);
    if (!is_warm) {
      // Mark as warm and charge cold access cost
      evm.warmAddress(beneficiary);
      gas_cost += GasConstants.ColdAccountAccessCost; // +2600
    }
  }

  const self_balance = evm.getBalance(frame.address);

  // Check if beneficiary is alive (has code, balance, or nonce)
  // Add new account cost if not alive and we have balance
  if (self_balance > 0n) {
    const beneficiary_is_alive = evm.accountExists(beneficiary);
    if (!beneficiary_is_alive) {
      gas_cost += GasConstants.CallNewAccountGas; // +25000
    }
  }

  frame.consumeGas(gas_cost);

  // EIP-214: SELFDESTRUCT cannot be executed in static call context
  // This check must happen AFTER gas charging
  if (frame.is_static) {
    throw new Error(CallError.StaticCallViolation);
  }

  // NOTE: Balance transfer and account deletion are handled in evm.inner_call
  // The frame only needs to signal that SELFDESTRUCT was executed
  // The EVM will handle the actual balance transfer and account marking

  // Apply refund to EVM's gas_refund counter
  const refund = frame.selfdestructRefund();
  if (refund > 0n) {
    evm.gas_refund += refund;
  }

  frame.stopped = true;
}
