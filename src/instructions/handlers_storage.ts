/**
 * Storage opcode handlers for the EVM
 *
 * Implements SLOAD, SSTORE, TLOAD, and TSTORE opcodes with full EIP support:
 * - EIP-2929: State access gas costs (warm/cold tracking)
 * - EIP-2200: Net gas metering for SSTORE (Istanbul+)
 * - EIP-3529: Reduced gas refunds (London+)
 * - EIP-1153: Transient storage (Cancun+)
 *
 * Port of src/instructions/handlers_storage.zig to TypeScript
 */

import { CallError, EvmError } from '../errors';
import type { Address } from '../host';

/**
 * Gas constants for storage operations
 * Must match primitives/gas_constants.zig exactly
 */
export const GasConstants = {
  // Storage access costs (EIP-2929)
  WarmStorageReadCost: 100n,        // Warm SLOAD cost
  ColdSloadCost: 2100n,             // Cold SLOAD cost (warm + cold surcharge)
  ColdAccountAccessCost: 2600n,     // Cold account access cost

  // SSTORE costs
  SstoreSetGas: 20000n,             // Set storage slot from 0 to non-zero
  SstoreResetGas: 5000n,            // Update storage slot (non-zero to non-zero or non-zero to zero pre-refund)
  SstoreSentryGas: 2300n,           // Minimum gas required for SSTORE (EIP-2200)
  SstoreRefundGas: 4800n,           // Refund for clearing storage (London+, was 15000 pre-London)

  // Transient storage costs (EIP-1153)
  TLoadGas: 100n,                   // TLOAD cost (always warm)
  TStoreGas: 100n,                  // TSTORE cost (always warm)
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
 * Storage key for persistent and transient storage
 * Combination of address and slot for HashMap lookups
 */
export interface StorageKey {
  address: Uint8Array;  // 20 bytes
  slot: bigint;         // u256
}

/**
 * Creates a string key for storage HashMap lookups
 * Combines address bytes and slot for unique identification
 */
export function storageKeyToString(key: StorageKey): string {
  const addrHex = Array.from(key.address)
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
  const slotHex = key.slot.toString(16).padStart(64, '0');
  return `${addrHex}:${slotHex}`;
}

/**
 * Storage interface (subset needed for handlers)
 * Full implementation in storage.ts
 */
export interface StorageInterface {
  // Persistent storage
  get(address: Address, slot: bigint): bigint;
  set(address: Address, slot: bigint, value: bigint): void;
  getOriginal(address: Address, slot: bigint): bigint;

  // Transient storage (EIP-1153)
  getTransient(address: Address, slot: bigint): bigint;
  setTransient(address: Address, slot: bigint, value: bigint): void;
}

/**
 * EVM interface (subset needed for storage handlers)
 * Provides access to hardfork, storage, warm/cold tracking, and refunds
 */
export interface EvmInterface {
  hardfork: Hardfork;
  storage: StorageInterface;
  gas_refund: bigint;

  // Warm/cold access tracking (EIP-2929)
  accessStorageSlot(address: Address, slot: bigint): bigint;

  // Refund management
  addRefund(amount: bigint): void;
  subtractRefund(amount: bigint): void;
}

/**
 * Frame interface (subset needed for storage handlers)
 * Represents a single execution context (stack, memory, PC, gas)
 */
export interface FrameInterface {
  // Stack operations
  popStack(): bigint;
  pushStack(value: bigint): void;

  // Gas management
  gas_remaining: bigint;
  consumeGas(amount: bigint): void;

  // Context
  address: Address;
  is_static: boolean;
  pc: number;

  // EVM access
  getEvm(): EvmInterface;
}

/**
 * Calculate SSTORE gas cost with hardfork-aware logic
 * Matches GasConstants.sstoreGasCostWithHardfork from primitives
 *
 * @param current - Current storage value
 * @param original - Original storage value (at transaction start)
 * @param value - New value to set
 * @param is_cold - Whether this is a cold storage access (EIP-2929)
 * @param is_berlin_or_later - Berlin+ hardfork flag
 * @param is_istanbul_or_later - Istanbul+ hardfork flag
 * @returns Gas cost for SSTORE operation
 */
export function sstoreGasCostWithHardfork(
  current: bigint,
  original: bigint,
  value: bigint,
  is_cold: boolean,
  is_berlin_or_later: boolean,
  is_istanbul_or_later: boolean
): bigint {
  // Base cost: cold access if needed (Berlin+)
  let gas = is_cold ? GasConstants.ColdSloadCost : 0n;

  if (!is_istanbul_or_later) {
    // Pre-Istanbul: Simple logic
    // If setting zero to non-zero: 20,000 gas
    // Otherwise: 5,000 gas
    return gas + (current === 0n && value !== 0n
      ? GasConstants.SstoreSetGas
      : GasConstants.SstoreResetGas);
  }

  // EIP-2200/EIP-3529: Complex net gas metering
  // See execution-specs/forks/cancun/vm/instructions/storage.py

  // No-op: Current value unchanged
  if (current === value) {
    return gas + GasConstants.WarmStorageReadCost; // Just warm access cost (100)
  }

  // Setting to original value (restoring)
  if (original === value) {
    if (original === 0n) {
      // Was 0, became non-zero, now back to 0
      return gas + GasConstants.WarmStorageReadCost; // 100
    } else {
      // Was non-zero, changed, now restoring
      return gas + GasConstants.WarmStorageReadCost; // 100
    }
  }

  // Original value was never changed before in this transaction
  if (original === current) {
    if (original === 0n) {
      // Fresh zero → non-zero: Full SET cost
      return gas + GasConstants.SstoreSetGas; // 20,000 (+ cold if applicable)
    } else {
      // Fresh non-zero → different: RESET cost
      return gas + GasConstants.SstoreResetGas; // 5,000 (+ cold if applicable)
    }
  }

  // Value was already dirty (changed earlier in transaction)
  // Just charge warm access
  return gas + GasConstants.WarmStorageReadCost; // 100 (+ cold if applicable)
}

/**
 * SLOAD opcode (0x54) - Load word from storage
 *
 * Gas: Warm (100) or Cold (2100) depending on EIP-2929 access list
 *
 * Stack:
 * - Input: [slot]
 * - Output: [value]
 *
 * @param frame - Execution frame
 */
export function sload(frame: FrameInterface): void {
  const evm = frame.getEvm();
  const key = frame.popStack();

  // EIP-2929: charge warm/cold storage access cost and warm the slot
  const access_cost = evm.accessStorageSlot(frame.address, key);
  // Access cost already includes the full SLOAD gas cost (100 for warm, 2100 for cold)
  frame.consumeGas(access_cost);

  const value = evm.storage.get(frame.address, key);
  frame.pushStack(value);
  frame.pc += 1;
}

/**
 * SSTORE opcode (0x55) - Save word to storage
 *
 * Complex gas metering with hardfork-dependent logic:
 * - Pre-Istanbul: Simple 20k/5k costs + 15k refund on clear
 * - Istanbul-London: EIP-2200 net gas metering with complex refunds
 * - London+: EIP-3529 reduced refunds (4800 instead of 15000)
 *
 * Stack:
 * - Input: [slot, value]
 * - Output: []
 *
 * Errors:
 * - StaticCallViolation: If is_static is true (EIP-214)
 * - OutOfGas: If gas_remaining <= 2300 (EIP-2200 sentry check)
 *
 * @param frame - Execution frame
 */
export function sstore(frame: FrameInterface): void {
  const evm = frame.getEvm();

  // EIP-214: SSTORE cannot modify state in static call context
  if (frame.is_static) {
    throw new EvmError(CallError.StaticCallViolation);
  }

  // EIP-2200 (Istanbul+): SSTORE sentry gas check
  // SSTORE requires at least GAS_CALL_STIPEND (2300) gas remaining
  if (evm.hardfork >= Hardfork.ISTANBUL) {
    if (frame.gas_remaining <= GasConstants.SstoreSentryGas) {
      throw new EvmError(CallError.OutOfGas);
    }
  }

  const key = frame.popStack();
  const value = frame.popStack();

  // Get current value for gas calculation
  const current_value = evm.storage.get(frame.address, key);

  // Calculate gas cost based on hardfork
  let gas_cost: bigint;

  if (evm.hardfork >= Hardfork.ISTANBUL) {
    // EIP-2200 (Istanbul+): Complex storage gas metering with dirty tracking
    const original_value = evm.storage.getOriginal(frame.address, key);

    // EIP-2929 (Berlin+): Check if storage slot is cold and warm it
    const access_cost = evm.accessStorageSlot(frame.address, key);
    const is_cold = access_cost === GasConstants.ColdSloadCost;

    // Use EIP-2200/EIP-3529 logic with hardfork-aware gas costs
    const is_berlin_or_later = evm.hardfork >= Hardfork.BERLIN;
    const is_istanbul_or_later = evm.hardfork >= Hardfork.ISTANBUL;
    gas_cost = sstoreGasCostWithHardfork(
      current_value,
      original_value,
      value,
      is_cold,
      is_berlin_or_later,
      is_istanbul_or_later,
    );
  } else {
    // Pre-Istanbul (Constantinople, Petersburg): Simple storage gas rules
    // If setting zero to non-zero: 20,000 gas
    // Otherwise: 5,000 gas
    gas_cost = (current_value === 0n && value !== 0n)
      ? GasConstants.SstoreSetGas   // 20,000
      : GasConstants.SstoreResetGas; // 5,000
  }

  frame.consumeGas(gas_cost);

  // Refund logic (hardfork-dependent)
  if (evm.hardfork >= Hardfork.ISTANBUL && evm.hardfork < Hardfork.LONDON) {
    // EIP-2200 (Istanbul-London): Complex net gas metering refund logic
    const original_value = evm.storage.getOriginal(frame.address, key);

    if (current_value !== value) {
      // Case 1: Clearing storage for the first time in the transaction
      if (original_value !== 0n && current_value !== 0n && value === 0n) {
        evm.addRefund(15000n); // GAS_STORAGE_CLEAR_REFUND
      }

      // Case 2: Reversing a previous clear (was cleared earlier, now non-zero)
      if (original_value !== 0n && current_value === 0n) {
        // Subtract the refund that was given earlier
        evm.subtractRefund(15000n);
      }

      // Case 3: Restoring to original value
      if (original_value === value) {
        if (original_value === 0n) {
          // Slot was originally empty and was SET earlier (cost 20000)
          // Now restored to 0, refund the difference: 20000 - 100 = 19900
          evm.addRefund(20000n - 100n); // GAS_STORAGE_SET - GAS_SLOAD
        } else {
          // Slot was originally non-empty and was UPDATED earlier (cost 5000)
          // Now restored to original, refund: 5000 - 100 = 4900
          evm.addRefund(5000n - 100n); // GAS_STORAGE_UPDATE - GAS_SLOAD
        }
      }
    }
  } else if (evm.hardfork >= Hardfork.LONDON) {
    // EIP-3529 (London+): Refund logic matching Python cancun/vm/instructions/storage.py lines 106-124
    // IMPORTANT: All three refund cases are independent checks (not else-if), matching Python
    const original_value = evm.storage.getOriginal(frame.address, key);

    // Refund Counter Calculation (only when value changes)
    if (current_value !== value) {
      // Case 1: Clearing storage for the first time in the transaction (line 107-109)
      if (original_value !== 0n && current_value !== 0n && value === 0n) {
        evm.addRefund(GasConstants.SstoreRefundGas); // 4,800 (GAS_STORAGE_CLEAR_REFUND)
      }

      // Case 2: Reversing a previous clear (line 111-113)
      // This is a separate independent check, not else-if
      if (original_value !== 0n && current_value === 0n) {
        // Subtract the refund that was given earlier
        evm.subtractRefund(GasConstants.SstoreRefundGas);
      }

      // Case 3: Restoring to original value (line 115-124)
      // This is also a separate independent check, not else-if
      if (original_value === value) {
        if (original_value === 0n) {
          // Slot was originally empty and was SET earlier (cost 20000)
          // Now restored to 0, refund: 20000 - 100 = 19900
          evm.addRefund(GasConstants.SstoreSetGas - GasConstants.WarmStorageReadCost);
        } else {
          // Slot was originally non-empty and was UPDATED earlier
          // Now restored to original, refund: 5000 - 2100 - 100 = 2800
          evm.addRefund(
            GasConstants.SstoreResetGas -
            GasConstants.ColdSloadCost -
            GasConstants.WarmStorageReadCost
          );
        }
      }
    }
  } else {
    // Pre-Istanbul (Frontier-Constantinople-Petersburg): Simple clear refund
    if (current_value !== 0n && value === 0n) {
      evm.addRefund(15000n); // GAS_STORAGE_CLEAR_REFUND
    }
  }

  evm.storage.set(frame.address, key, value);
  frame.pc += 1;
}

/**
 * TLOAD opcode (0x5c) - Load word from transient storage (EIP-1153)
 *
 * Transient storage is cleared at transaction boundaries (not call boundaries).
 * Always warm (100 gas), never cold.
 *
 * Introduced: Cancun hardfork
 * Gas: 100 (always warm)
 *
 * Stack:
 * - Input: [slot]
 * - Output: [value]
 *
 * Errors:
 * - InvalidOpcode: If hardfork < Cancun
 *
 * @param frame - Execution frame
 */
export function tload(frame: FrameInterface): void {
  const evm = frame.getEvm();

  // EIP-1153: TLOAD was introduced in Cancun hardfork
  if (evm.hardfork < Hardfork.CANCUN) {
    throw new EvmError(CallError.InvalidOpcode);
  }

  frame.consumeGas(GasConstants.TLoadGas);
  const key = frame.popStack();
  const value = evm.storage.getTransient(frame.address, key);
  frame.pushStack(value);
  frame.pc += 1;
}

/**
 * TSTORE opcode (0x5d) - Save word to transient storage (EIP-1153)
 *
 * Transient storage is cleared at transaction boundaries (not call boundaries).
 * Always warm (100 gas), never cold.
 *
 * Introduced: Cancun hardfork
 * Gas: 100 (always warm)
 *
 * Stack:
 * - Input: [slot, value]
 * - Output: []
 *
 * Errors:
 * - InvalidOpcode: If hardfork < Cancun
 * - StaticCallViolation: If is_static is true
 *
 * @param frame - Execution frame
 */
export function tstore(frame: FrameInterface): void {
  const evm = frame.getEvm();

  // EIP-1153: TSTORE was introduced in Cancun hardfork
  if (evm.hardfork < Hardfork.CANCUN) {
    throw new EvmError(CallError.InvalidOpcode);
  }

  // EIP-1153: TSTORE cannot modify state in static call context
  if (frame.is_static) {
    throw new EvmError(CallError.StaticCallViolation);
  }

  frame.consumeGas(GasConstants.TStoreGas);
  const key = frame.popStack();
  const value = frame.popStack();
  evm.storage.setTransient(frame.address, key, value);
  frame.pc += 1;
}
