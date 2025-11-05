/**
 * Execution context opcode handlers for the EVM
 *
 * This module implements opcodes that access execution context:
 * - ADDRESS (0x30): Get currently executing account address
 * - BALANCE (0x31): Get account balance
 * - ORIGIN (0x32): Get transaction origination address
 * - CALLER (0x33): Get caller address
 * - CALLVALUE (0x34): Get value sent with call
 * - CALLDATALOAD (0x35): Load 32 bytes from calldata
 * - CALLDATASIZE (0x36): Get calldata size
 * - CALLDATACOPY (0x37): Copy calldata to memory
 * - CODESIZE (0x38): Get executing code size
 * - CODECOPY (0x39): Copy executing code to memory
 * - GASPRICE (0x3a): Get gas price
 * - EXTCODESIZE (0x3b): Get external account code size
 * - EXTCODECOPY (0x3c): Copy external account code to memory
 * - RETURNDATASIZE (0x3d): Get return data size (Byzantium+)
 * - RETURNDATACOPY (0x3e): Copy return data to memory (Byzantium+)
 * - EXTCODEHASH (0x3f): Get external account code hash (Constantinople+)
 * - SELFBALANCE (0x47): Get current contract balance (Istanbul+)
 * - GAS (0x5a): Get remaining gas
 */

import { keccak256 } from 'ox/Hash';

// Gas constants
const GasFastestStep = 3n;
const GasQuickStep = 2n;
const CopyGas = 3n;
const WarmStorageReadCost = 100n;
const ColdAccountAccessCost = 2600n;

/**
 * Hardfork enum for feature detection
 */
export enum Hardfork {
  FRONTIER = 0,
  HOMESTEAD = 1,
  TANGERINE_WHISTLE = 2,
  SPURIOUS_DRAGON = 3,
  BYZANTIUM = 4,
  CONSTANTINOPLE = 5,
  PETERSBURG = 6,
  ISTANBUL = 7,
  BERLIN = 8,
  LONDON = 9,
  MERGE = 10,
  SHANGHAI = 11,
  CANCUN = 12,
  PRAGUE = 13,
}

/**
 * Bytecode interface
 */
export interface Bytecode {
  length: number;
  getOpcode(pc: number): number | null;
}

/**
 * EVM interface for accessing state and context
 */
export interface Evm {
  hardfork: Hardfork;
  origin: Uint8Array; // 20 bytes
  gas_price: bigint;

  // Warm/cold access tracking (EIP-2929, Berlin+)
  accessAddress(address: Uint8Array): bigint; // Returns gas cost

  // State access
  get_balance(address: Uint8Array): bigint;
  get_code(address: Uint8Array): Uint8Array;
}

/**
 * Frame interface that handlers operate on
 */
export interface Frame {
  // Gas and PC
  consumeGas(amount: bigint): void;
  gas_remaining: bigint;
  pc: number;

  // Stack operations
  popStack(): bigint;
  pushStack(value: bigint): void;

  // Memory operations
  writeMemory(offset: number, value: number): void;
  memoryExpansionCost(size: bigint): bigint;
  memory_size: number;

  // Execution context
  address: Uint8Array; // 20 bytes
  caller: Uint8Array; // 20 bytes
  value: bigint;
  calldata: Uint8Array;
  bytecode: Bytecode;
  return_data: Uint8Array;

  // Access to EVM state
  getEvm(): Evm;
}

/**
 * Helper functions
 */

/**
 * Add two u32 values with overflow checking
 */
function addU32(a: number, b: number): number {
  const result = a + b;
  if (result > 0xFFFFFFFF) {
    throw new Error('OutOfBounds');
  }
  return result;
}

/**
 * Calculate copy gas cost based on size
 */
function copyGasCost(size: number): bigint {
  const words = wordCount(BigInt(size));
  return CopyGas * words;
}

/**
 * Calculate number of 32-byte words needed for size bytes
 */
function wordCount(size: bigint): bigint {
  return (size + 31n) / 32n;
}

/**
 * Calculate word-aligned memory size for EVM compliance
 */
function wordAlignedSize(bytes: bigint): number {
  const words = wordCount(bytes);
  return Number(words * 32n);
}

/**
 * Convert 20-byte address to u256 (for stack)
 */
function addressToU256(address: Uint8Array): bigint {
  if (address.length !== 20) {
    throw new Error('Invalid address length');
  }
  let result = 0n;
  for (let i = 0; i < 20; i++) {
    result = (result << 8n) | BigInt(address[i]);
  }
  return result;
}

/**
 * Convert u256 to 20-byte address
 */
function u256ToAddress(value: bigint): Uint8Array {
  const address = new Uint8Array(20);
  for (let i = 19; i >= 0; i--) {
    address[i] = Number(value & 0xFFn);
    value >>= 8n;
  }
  return address;
}

/**
 * Helper to check hardfork version
 */
function isAtLeast(current: Hardfork, target: Hardfork): boolean {
  return current >= target;
}

function isBefore(current: Hardfork, target: Hardfork): boolean {
  return current < target;
}

/**
 * ADDRESS opcode (0x30) - Get address of currently executing account
 *
 * Gas: 2 (GasQuickStep)
 * Stack: [] -> [address]
 */
export function address(frame: Frame): void {
  frame.consumeGas(GasQuickStep);
  const addr_u256 = addressToU256(frame.address);
  frame.pushStack(addr_u256);
  frame.pc += 1;
}

/**
 * BALANCE opcode (0x31) - Get balance of an account
 *
 * Gas cost (hardfork-aware):
 * - Berlin+: cold/warm access (2600/100) - EIP-2929
 * - Istanbul-Berlin: 700 gas - EIP-1884
 * - Tangerine Whistle-Petersburg: 400 gas
 * - Pre-Tangerine Whistle: 20 gas
 *
 * Stack: [address] -> [balance]
 */
export function balance(frame: Frame): void {
  const evm = frame.getEvm();
  const addr_int = frame.popStack();
  const addr = u256ToAddress(addr_int);

  // Calculate gas cost based on hardfork
  let access_cost: bigint;
  if (isAtLeast(evm.hardfork, Hardfork.BERLIN)) {
    access_cost = evm.accessAddress(addr);
  } else if (isAtLeast(evm.hardfork, Hardfork.ISTANBUL)) {
    access_cost = 700n;
  } else if (isAtLeast(evm.hardfork, Hardfork.TANGERINE_WHISTLE)) {
    access_cost = 400n;
  } else {
    access_cost = 20n;
  }

  frame.consumeGas(access_cost);
  const bal = evm.get_balance(addr);
  frame.pushStack(bal);
  frame.pc += 1;
}

/**
 * ORIGIN opcode (0x32) - Get execution origination address
 *
 * Returns the address of the account that originated the transaction.
 *
 * Gas: 2 (GasQuickStep)
 * Stack: [] -> [origin]
 */
export function origin(frame: Frame): void {
  const evm = frame.getEvm();
  frame.consumeGas(GasQuickStep);
  const origin_u256 = addressToU256(evm.origin);
  frame.pushStack(origin_u256);
  frame.pc += 1;
}

/**
 * CALLER opcode (0x33) - Get caller address
 *
 * Returns the address that directly called the current context.
 *
 * Gas: 2 (GasQuickStep)
 * Stack: [] -> [caller]
 */
export function caller(frame: Frame): void {
  frame.consumeGas(GasQuickStep);
  const caller_u256 = addressToU256(frame.caller);
  frame.pushStack(caller_u256);
  frame.pc += 1;
}

/**
 * CALLVALUE opcode (0x34) - Get deposited value
 *
 * Returns the value sent with this call.
 *
 * Gas: 2 (GasQuickStep)
 * Stack: [] -> [value]
 */
export function callvalue(frame: Frame): void {
  frame.consumeGas(GasQuickStep);
  frame.pushStack(frame.value);
  frame.pc += 1;
}

/**
 * CALLDATALOAD opcode (0x35) - Get input data
 *
 * Loads 32 bytes from calldata at the specified offset.
 * If offset is out of bounds, the result is padded with zeros.
 *
 * Gas: 3 (GasFastestStep)
 * Stack: [offset] -> [data]
 */
export function calldataload(frame: Frame): void {
  frame.consumeGas(GasFastestStep);
  const offset = frame.popStack();

  // If offset is too large, return 0
  if (offset > 0xFFFFFFFFn) {
    frame.pushStack(0n);
  } else {
    const off = Number(offset);
    let result = 0n;

    // Read 32 bytes (or less if past end of calldata)
    for (let i = 0; i < 32; i++) {
      const idx = addU32(off, i);
      const byte = idx < frame.calldata.length ? frame.calldata[idx] : 0;
      result = (result << 8n) | BigInt(byte);
    }

    frame.pushStack(result);
  }

  frame.pc += 1;
}

/**
 * CALLDATASIZE opcode (0x36) - Get size of input data
 *
 * Gas: 2 (GasQuickStep)
 * Stack: [] -> [size]
 */
export function calldatasize(frame: Frame): void {
  frame.consumeGas(GasQuickStep);
  frame.pushStack(BigInt(frame.calldata.length));
  frame.pc += 1;
}

/**
 * CALLDATACOPY opcode (0x37) - Copy input data to memory
 *
 * Copies input data from the specified offset to memory.
 * Out-of-bounds reads are padded with zeros.
 *
 * Gas: 3 (base) + memory expansion + copy cost (3 per word)
 * Stack: [destOffset, offset, length] -> []
 */
export function calldatacopy(frame: Frame): void {
  const dest_offset = frame.popStack();
  const offset = frame.popStack();
  const length = frame.popStack();

  // Check bounds
  if (dest_offset > 0xFFFFFFFFn || offset > 0xFFFFFFFFn || length > 0xFFFFFFFFn) {
    throw new Error('OutOfBounds');
  }

  const dest_off = Number(dest_offset);
  const src_off = Number(offset);
  const len = Number(length);

  // Calculate gas costs
  const end_bytes_copy = BigInt(dest_off) + BigInt(len);
  const mem_cost = frame.memoryExpansionCost(end_bytes_copy);
  const copy_cost = copyGasCost(len);
  frame.consumeGas(GasFastestStep + mem_cost + copy_cost);

  // Copy calldata to memory
  for (let i = 0; i < len; i++) {
    const src_idx = addU32(src_off, i);
    const byte = src_idx < frame.calldata.length ? frame.calldata[src_idx] : 0;
    const dst_idx = addU32(dest_off, i);
    frame.writeMemory(dst_idx, byte);
  }

  frame.pc += 1;
}

/**
 * CODESIZE opcode (0x38) - Get size of code running in current environment
 *
 * Gas: 2 (GasQuickStep)
 * Stack: [] -> [size]
 */
export function codesize(frame: Frame): void {
  frame.consumeGas(GasQuickStep);
  frame.pushStack(BigInt(frame.bytecode.length));
  frame.pc += 1;
}

/**
 * CODECOPY opcode (0x39) - Copy code to memory
 *
 * Copies code from the specified offset to memory.
 * Out-of-bounds reads are padded with zeros.
 *
 * Gas: 3 (base) + memory expansion + copy cost (3 per word)
 * Stack: [destOffset, offset, length] -> []
 */
export function codecopy(frame: Frame): void {
  const dest_offset = frame.popStack();
  const offset = frame.popStack();
  const length = frame.popStack();

  // Check bounds
  if (dest_offset > 0xFFFFFFFFn || offset > 0xFFFFFFFFn || length > 0xFFFFFFFFn) {
    throw new Error('OutOfBounds');
  }

  const dest_off = Number(dest_offset);
  const src_off = Number(offset);
  const len = Number(length);

  // Calculate gas costs
  const end_bytes_code = BigInt(dest_off) + BigInt(len);
  const mem_cost = frame.memoryExpansionCost(end_bytes_code);
  const copy_cost = copyGasCost(len);
  frame.consumeGas(GasFastestStep + mem_cost + copy_cost);

  // Copy code to memory
  for (let i = 0; i < len; i++) {
    const src_idx = addU32(src_off, i);
    const byte = frame.bytecode.getOpcode(src_idx) ?? 0;
    const dst_idx = addU32(dest_off, i);
    frame.writeMemory(dst_idx, byte);
  }

  frame.pc += 1;
}

/**
 * GASPRICE opcode (0x3a) - Get price of gas
 *
 * Gas: 2 (GasQuickStep)
 * Stack: [] -> [gasPrice]
 */
export function gasprice(frame: Frame): void {
  const evm = frame.getEvm();
  frame.consumeGas(GasQuickStep);
  frame.pushStack(evm.gas_price);
  frame.pc += 1;
}

/**
 * EXTCODESIZE opcode (0x3b) - Get size of an account's code
 *
 * Gas cost (hardfork-aware):
 * - Berlin+: cold/warm access (2600/100) - EIP-2929
 * - Tangerine Whistle-Berlin: 700 gas - EIP-150
 * - Pre-Tangerine Whistle: 20 gas
 *
 * Stack: [address] -> [size]
 */
export function extcodesize(frame: Frame): void {
  const evm = frame.getEvm();
  const addr_int = frame.popStack();
  const ext_addr = u256ToAddress(addr_int);

  // Calculate gas cost based on hardfork
  let access_cost: bigint;
  if (isAtLeast(evm.hardfork, Hardfork.BERLIN)) {
    access_cost = evm.accessAddress(ext_addr);
  } else if (isAtLeast(evm.hardfork, Hardfork.TANGERINE_WHISTLE)) {
    access_cost = 700n;
  } else {
    access_cost = 20n;
  }

  frame.consumeGas(access_cost);

  // Get the code from the external address
  const code = evm.get_code(ext_addr);
  frame.pushStack(BigInt(code.length));
  frame.pc += 1;
}

/**
 * EXTCODECOPY opcode (0x3c) - Copy an account's code to memory
 *
 * Gas cost (hardfork-aware):
 * - Berlin+: cold/warm access (2600/100) - EIP-2929
 * - Tangerine Whistle-Berlin: 700 gas - EIP-150
 * - Pre-Tangerine Whistle: 20 gas
 * Plus: memory expansion + copy cost
 *
 * Stack: [address, destOffset, offset, size] -> []
 */
export function extcodecopy(frame: Frame): void {
  const evm = frame.getEvm();
  const addr_int = frame.popStack();
  const dest_offset = frame.popStack();
  const offset = frame.popStack();
  const size = frame.popStack();

  const ext_addr = u256ToAddress(addr_int);

  // Check bounds
  if (dest_offset > 0xFFFFFFFFn || offset > 0xFFFFFFFFn || size > 0xFFFFFFFFn) {
    throw new Error('OutOfBounds');
  }

  const dest = Number(dest_offset);
  const off = Number(offset);
  const len = Number(size);

  // Calculate ALL gas costs at once: access + copy + memory expansion
  let access_cost: bigint;
  if (isAtLeast(evm.hardfork, Hardfork.BERLIN)) {
    access_cost = evm.accessAddress(ext_addr);
  } else if (isAtLeast(evm.hardfork, Hardfork.TANGERINE_WHISTLE)) {
    access_cost = 700n;
  } else {
    access_cost = 20n;
  }

  const copy_cost = copyGasCost(len);
  const end_bytes = BigInt(dest) + BigInt(len);
  const mem_cost = frame.memoryExpansionCost(end_bytes);

  // Charge all costs at once
  frame.consumeGas(access_cost + copy_cost + mem_cost);

  // Get the code from the external address
  const code = evm.get_code(ext_addr);

  // Copy code to memory
  for (let i = 0; i < len; i++) {
    const dst_idx = addU32(dest, i);
    const src_idx = off + i;
    // If src_idx is beyond the code length, write 0 (per EVM spec)
    const byte = src_idx < code.length ? code[src_idx] : 0;
    frame.writeMemory(dst_idx, byte);
  }

  frame.pc += 1;
}

/**
 * RETURNDATASIZE opcode (0x3d) - Get size of output data from previous call
 *
 * EIP-211: RETURNDATASIZE was introduced in Byzantium hardfork
 *
 * Gas: 2 (GasQuickStep)
 * Stack: [] -> [size]
 */
export function returndatasize(frame: Frame): void {
  const evm = frame.getEvm();

  // Check hardfork
  if (isBefore(evm.hardfork, Hardfork.BYZANTIUM)) {
    throw new Error('InvalidOpcode');
  }

  frame.consumeGas(GasQuickStep);
  frame.pushStack(BigInt(frame.return_data.length));
  frame.pc += 1;
}

/**
 * RETURNDATACOPY opcode (0x3e) - Copy output data from previous call to memory
 *
 * EIP-211: RETURNDATACOPY was introduced in Byzantium hardfork
 *
 * Gas: 3 (base) + memory expansion + copy cost (3 per word)
 * Stack: [destOffset, offset, length] -> []
 */
export function returndatacopy(frame: Frame): void {
  const evm = frame.getEvm();

  // Check hardfork
  if (isBefore(evm.hardfork, Hardfork.BYZANTIUM)) {
    throw new Error('InvalidOpcode');
  }

  const dest_offset = frame.popStack();
  const offset = frame.popStack();
  const length = frame.popStack();

  // Check bounds
  if (dest_offset > 0xFFFFFFFFn || offset > 0xFFFFFFFFn || length > 0xFFFFFFFFn) {
    throw new Error('OutOfBounds');
  }

  const dest_off = Number(dest_offset);
  const src_off = Number(offset);
  const len = Number(length);

  // Check bounds with overflow-safety
  const rd_len = frame.return_data.length;
  if (src_off > rd_len || len > rd_len - src_off) {
    throw new Error('OutOfBounds');
  }

  const end_bytes_ret = BigInt(dest_off) + BigInt(len);
  const mem_cost = frame.memoryExpansionCost(end_bytes_ret);
  const copy_cost = copyGasCost(len);
  frame.consumeGas(GasFastestStep + mem_cost + copy_cost);

  // Update memory size after charging for expansion
  const aligned_ret = wordAlignedSize(end_bytes_ret);
  if (aligned_ret > frame.memory_size) {
    frame.memory_size = aligned_ret;
  }

  // Copy return data to memory
  for (let i = 0; i < len; i++) {
    const src_idx = src_off + i;
    const byte = frame.return_data[src_idx];
    const dst_idx = addU32(dest_off, i);
    frame.writeMemory(dst_idx, byte);
  }

  frame.pc += 1;
}

/**
 * EXTCODEHASH opcode (0x3f) - Get hash of an account's code
 *
 * EIP-1052: EXTCODEHASH opcode was introduced in Constantinople hardfork
 *
 * Special case: Returns 0 for empty accounts (no code)
 *
 * Gas cost (hardfork-aware):
 * - Berlin+: cold/warm access (2600/100) - EIP-2929
 * - Istanbul-Berlin: 700 gas - EIP-1884
 * - Constantinople-Petersburg: 400 gas
 *
 * Stack: [address] -> [codeHash]
 */
export function extcodehash(frame: Frame): void {
  const evm = frame.getEvm();

  // Check hardfork
  if (isBefore(evm.hardfork, Hardfork.CONSTANTINOPLE)) {
    throw new Error('InvalidOpcode');
  }

  const addr_int = frame.popStack();
  const ext_addr = u256ToAddress(addr_int);

  // Calculate gas cost based on hardfork
  let access_cost: bigint;
  if (isAtLeast(evm.hardfork, Hardfork.BERLIN)) {
    access_cost = evm.accessAddress(ext_addr);
  } else if (isAtLeast(evm.hardfork, Hardfork.ISTANBUL)) {
    access_cost = 700n;
  } else {
    access_cost = 400n;
  }

  frame.consumeGas(access_cost);

  // Get the code from the external address
  const code = evm.get_code(ext_addr);

  if (code.length === 0) {
    // Return 0 for empty accounts (no code)
    frame.pushStack(0n);
  } else {
    // Compute keccak256 hash of the code
    const hash = keccak256(code);

    // Convert hash bytes to u256 (big-endian)
    let hash_u256 = 0n;
    for (let i = 0; i < hash.length; i++) {
      hash_u256 = (hash_u256 << 8n) | BigInt(hash[i]);
    }

    frame.pushStack(hash_u256);
  }

  frame.pc += 1;
}

/**
 * GAS opcode (0x5a) - Get the amount of available gas
 *
 * Gas: 2 (GasQuickStep)
 * Stack: [] -> [gas]
 */
export function gas(frame: Frame): void {
  frame.consumeGas(GasQuickStep);
  frame.pushStack(frame.gas_remaining);
  frame.pc += 1;
}
