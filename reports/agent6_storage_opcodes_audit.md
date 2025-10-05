# Agent 6: Storage Opcodes Audit Report

## Summary
- Total opcodes audited: 4 (SLOAD, SSTORE, TLOAD, TSTORE)
- ✅ Correct: 2 (SLOAD, partial SSTORE gas calculation)
- ⚠️ Issues found: 5
- ❌ Critical bugs: 3

## Executive Summary

This audit examined the implementation of storage opcodes (SLOAD, SSTORE, TLOAD, TSTORE) in the Zig EVM implementation against the Python execution specs. Critical issues were identified in:

1. **CRITICAL**: SSTORE missing complex refund logic (3 out of 4 refund scenarios not implemented)
2. **CRITICAL**: SSTORE missing sentry gas check (must require gas_left > 2300)
3. **CRITICAL**: SSTORE and TSTORE missing STATICCALL context checks
4. **HIGH**: TLOAD/TSTORE not using separate transient storage (using regular storage instead)
5. **MEDIUM**: SSTORE gas calculation has incorrect logic for UPDATE case

## Detailed Findings

### 1. SLOAD (0x54) - ✅ CORRECT

**Status**: Implementation is correct ✅

**Implementation**: `src/frame.zig:1048-1060`
```zig
0x54 => {
    const key = try self.popStack();
    const access_cost = try evm.accessStorageSlot(self.address, key);
    try self.consumeGas(access_cost);
    const value = evm.get_storage(self.address, key);
    try self.pushStack(value);
    self.pc += 1;
}
```

**Spec Reference**: `execution-specs/src/ethereum/forks/prague/vm/instructions/storage.py:37-66`

**Verification**:
- ✅ Pops key from stack
- ✅ Reads from persistent storage
- ✅ Cold access costs 2100 gas (via `accessStorageSlot`)
- ✅ Warm access costs 100 gas (via `accessStorageSlot`)
- ✅ Access tracking correct (handled by `evm.accessStorageSlot`)
- ✅ Returns 0 for unset keys (via `evm.get_storage`)

**Gas Constants Verified**:
- `ColdSloadCost = 2100` ✅ (`src/primitives/gas_constants.zig:72`)
- `WarmStorageReadCost = 100` ✅ (`src/primitives/gas_constants.zig:80`)

---

### 2. SSTORE (0x55) - ❌ CRITICAL ISSUES

**Status**: Multiple critical bugs ❌

**Implementation**: `src/frame.zig:1062-1091`

#### Issue 2.1: Missing Sentry Gas Check (CRITICAL)

**File**: `src/frame.zig:1063`
**Severity**: CRITICAL

**Issue**: SSTORE must check that `gas_left > GAS_CALL_STIPEND (2300)` BEFORE any operations, including stack pops. The implementation is missing this check entirely.

**Spec Reference**: `execution-specs/src/ethereum/forks/prague/vm/instructions/storage.py:82-83`
```python
if evm.gas_left <= GAS_CALL_STIPEND:
    raise OutOfGasError
```

**Current Code**:
```zig
// SSTORE
0x55 => {
    const key = try self.popStack();        // ❌ Pops before sentry check
    const value = try self.popStack();      // ❌ Pops before sentry check
    // Missing: sentry check!
```

**Required Fix**:
```zig
0x55 => {
    // EIP-2200: Sentry gas check MUST come first
    if (self.gas_remaining <= GasConstants.SstoreSentryGas) {
        return error.OutOfGas;
    }
    const key = try self.popStack();
    const value = try self.popStack();
    // ... rest of implementation
```

**Impact**: Without this check, SSTORE can execute when gas is nearly exhausted, violating EIP-2200 and potentially causing reentrancy vulnerabilities.

---

#### Issue 2.2: Missing STATICCALL Context Check (CRITICAL)

**File**: `src/frame.zig:1063-1091`
**Severity**: CRITICAL

**Issue**: SSTORE must revert if called within a STATICCALL context. The implementation has no such check.

**Spec Reference**: `execution-specs/src/ethereum/forks/prague/vm/instructions/storage.py:127-128`
```python
charge_gas(evm, gas_cost)
if evm.message.is_static:
    raise WriteInStaticContext
```

**Current Code**: No `is_static` check exists in the SSTORE implementation.

**Required Fix**: Add a Frame field to track static context and check it:
```zig
// After gas charging, before storage write
if (self.is_static) {
    return error.WriteInStaticContext;
}
try evm.set_storage(self.address, key, value);
```

**Impact**: STATICCALL is supposed to prevent state modifications. Without this check, contracts can violate the static guarantee and modify storage within static calls.

---

#### Issue 2.3: Incomplete Refund Logic (CRITICAL)

**File**: `src/frame.zig:1084-1087`
**Severity**: CRITICAL

**Issue**: SSTORE refund logic only implements 1 of 4 required scenarios. The Python spec has complex refund logic covering all state transitions.

**Current Code**:
```zig
// EIP-3529: Only clearing (non-zero -> zero) is eligible for refund
if (current_value != 0 and value == 0) {
    evm.add_refund(GasConstants.SstoreRefundGas);  // Only scenario 1
}
```

**Spec Reference**: `execution-specs/src/ethereum/forks/prague/vm/instructions/storage.py:105-124`

**Missing Scenarios**:

**Scenario 2 - Reverse Previous Clear Refund**:
```python
if original_value != 0 and current_value == 0:
    # Gas refund issued earlier to be reversed
    evm.refund_counter -= int(GAS_STORAGE_CLEAR_REFUND)  # -4800
```
**Use case**: If we previously cleared a slot (got +4800 refund), but now we're setting it to non-zero again, we must UNDO that refund.

**Scenario 3 - Restore Original Zero**:
```python
if original_value == new_value:
    if original_value == 0:
        # Slot was originally empty and was SET earlier
        evm.refund_counter += int(GAS_STORAGE_SET - GAS_WARM_ACCESS)  # +19900
```
**Use case**: If original was 0, we set it to X (paid 20000), and now we're setting it back to 0, refund the difference.

**Scenario 4 - Restore Original Non-Zero**:
```python
if original_value == new_value:
    if original_value != 0:
        # Slot was originally non-empty and was UPDATED earlier
        evm.refund_counter += int(
            GAS_STORAGE_UPDATE - GAS_COLD_SLOAD - GAS_WARM_ACCESS
        )  # +2800
```
**Use case**: If original was X, we set it to Y (paid 5000+2100), and now we're setting it back to X, refund the difference.

**Complete Required Implementation**:
```zig
// Refund calculation (after gas charge)
if (current_value != value) {
    // Scenario 1: Clearing storage for first time
    if (original_value != 0 and current_value != 0 and value == 0) {
        evm.add_refund(GasConstants.SstoreRefundGas);  // +4800
    }

    // Scenario 2: Reversing a previous clear
    if (original_value != 0 and current_value == 0) {
        evm.subtract_refund(GasConstants.SstoreRefundGas);  // -4800
    }

    // Scenario 3 & 4: Restoring original value
    if (original_value == value) {
        if (original_value == 0) {
            // Restore to original zero
            const refund = GasConstants.SstoreSetGas - GasConstants.WarmStorageReadCost;
            evm.add_refund(refund);  // +19900
        } else {
            // Restore to original non-zero
            const refund = GasConstants.SstoreResetGas - GasConstants.ColdSloadCost - GasConstants.WarmStorageReadCost;
            evm.add_refund(refund);  // +2800
        }
    }
}
```

**Impact**: Gas refunds are calculated incorrectly, leading to:
- Users not receiving refunds when restoring storage to original values
- Incorrect gas accounting for complex storage patterns
- Potential economic attacks exploiting incorrect refund logic

---

#### Issue 2.4: Incorrect Gas Calculation for SSTORE UPDATE

**File**: `src/primitives/gas_constants.zig:488-515`
**Severity**: MEDIUM

**Issue**: The `sstore_gas_cost` function has incorrect logic for the UPDATE case when modifying a non-zero value.

**Current Code**:
```zig
} else if (original == current and current != new) {
    // First modification in this transaction
    if (original == 0) {
        gas += SstoreSetGas;
    } else {
        gas += SstoreResetGas;  // ❌ Incorrect - should be SstoreResetGas only
    }
}
```

**Spec Reference**: `execution-specs/src/ethereum/forks/prague/vm/instructions/storage.py:97-103`
```python
if original_value == current_value and current_value != new_value:
    if original_value == 0:
        gas_cost += GAS_STORAGE_SET
    else:
        gas_cost += GAS_STORAGE_UPDATE - GAS_COLD_SLOAD  # ❌ Not just UPDATE!
else:
    gas_cost += GAS_WARM_ACCESS
```

**Problem**: When modifying a non-zero value for the first time in a transaction:
- **If COLD**: Total should be `GAS_COLD_SLOAD + (GAS_STORAGE_UPDATE - GAS_COLD_SLOAD)` = `GAS_STORAGE_UPDATE` (5000)
- **If WARM**: Total should be `0 + (GAS_STORAGE_UPDATE - GAS_COLD_SLOAD)` = `2900`

The current implementation charges `GAS_COLD_SLOAD + GAS_STORAGE_UPDATE` = 7100 for cold, which is WRONG!

**Required Fix**:
```zig
} else if (original == current and current != new) {
    // First modification in this transaction
    if (original == 0) {
        gas += SstoreSetGas;
    } else {
        // Subtract cold cost because it's already added if cold
        gas += SstoreResetGas - ColdSloadCost;  // ✅ Correct
    }
}
```

**Test Case to Verify**:
- Original: 100, Current: 100, New: 200 (COLD)
- Expected: 2100 (cold) + (5000 - 2100) = 5000
- Current: 2100 + 5000 = 7100 ❌

---

### 3. TLOAD (0x5C) - ⚠️ HIGH ISSUE

**Status**: Partially implemented with architectural issue ⚠️

**Implementation**: `src/frame.zig:1151-1163`

**Issue 3.1: Not Using Separate Transient Storage**

**File**: `src/frame.zig:1158-1160`
**Severity**: HIGH

**Issue**: TLOAD is reading from regular persistent storage instead of transient storage.

**Current Code**:
```zig
// TLOAD
0x5c => {
    if (evm.hardfork.isBefore(.CANCUN)) return error.InvalidOpcode;
    try self.consumeGas(GasConstants.WarmStorageReadCost);
    const key = try self.popStack();
    // For Evm tracer, we use regular storage for transient storage
    // In a real implementation, this would be separate
    const value = evm.get_storage(self.address, key);  // ❌ Wrong storage!
    try self.pushStack(value);
    self.pc += 1;
}
```

**Spec Reference**: `execution-specs/src/ethereum/forks/prague/vm/instructions/storage.py:153-155`
```python
value = get_transient_storage(
    evm.message.tx_env.transient_storage, evm.message.current_target, key
)
```

**Required Fix**:
1. Add transient storage map to `evm.zig`:
```zig
pub const Evm = struct {
    // ... existing fields
    transient_storage: std.AutoHashMap(StorageSlotKey, u256),
```

2. Implement getter:
```zig
pub fn get_transient_storage(self: *Self, address: Address, slot: u256) u256 {
    const key = StorageSlotKey{ .address = address, .slot = slot };
    return self.transient_storage.get(key) orelse 0;
}
```

3. Update TLOAD:
```zig
const value = evm.get_transient_storage(self.address, key);
```

**Verification**:
- ✅ Implemented (opcode exists)
- ✅ Hardfork check correct (CANCUN)
- ✅ Gas cost correct (100)
- ✅ Pops key
- ✅ Returns 0 for missing keys (via HashMap default)
- ❌ NOT using separate transient storage

**Impact**: TLOAD/TSTORE operations interfere with regular storage, causing incorrect behavior for contracts using transient storage.

---

### 4. TSTORE (0x5D) - ❌ CRITICAL ISSUES

**Status**: Multiple critical bugs ❌

**Implementation**: `src/frame.zig:1165-1177`

**Issue 4.1: Not Using Separate Transient Storage**

**File**: `src/frame.zig:1175`
**Severity**: HIGH

Same issue as TLOAD - using regular storage instead of transient storage.

**Current Code**:
```zig
// TSTORE
0x5d => {
    if (evm.hardfork.isBefore(.CANCUN)) return error.InvalidOpcode;
    try self.consumeGas(GasConstants.WarmStorageReadCost);
    const key = try self.popStack();
    const value = try self.popStack();
    // For Evm tracer, we can just track transient storage in the EVM
    // Transient storage behaves like regular storage but is cleared after tx
    try evm.set_storage(self.address, key, value);  // ❌ Wrong storage!
    self.pc += 1;
}
```

**Spec Reference**: `execution-specs/src/ethereum/forks/prague/vm/instructions/storage.py:180-185`
```python
set_transient_storage(
    evm.message.tx_env.transient_storage,
    evm.message.current_target,
    key,
    new_value,
)
```

**Required Fix**: Same as TLOAD - implement `set_transient_storage` and use it.

---

**Issue 4.2: Missing STATICCALL Context Check**

**File**: `src/frame.zig:1166-1177`
**Severity**: CRITICAL

**Issue**: TSTORE must revert if called within a STATICCALL context. The implementation has no such check.

**Spec Reference**: `execution-specs/src/ethereum/forks/prague/vm/instructions/storage.py:177-179`
```python
charge_gas(evm, GAS_WARM_ACCESS)
if evm.message.is_static:
    raise WriteInStaticContext
```

**Current Code**: No `is_static` check exists.

**Required Fix**:
```zig
0x5d => {
    if (evm.hardfork.isBefore(.CANCUN)) return error.InvalidOpcode;
    try self.consumeGas(GasConstants.WarmStorageReadCost);

    // Check static context BEFORE modification
    if (self.is_static) {
        return error.WriteInStaticContext;
    }

    const key = try self.popStack();
    const value = try self.popStack();
    try evm.set_transient_storage(self.address, key, value);
    self.pc += 1;
}
```

**Impact**: STATICCALL is violated - contracts can modify transient storage within static calls.

---

**Issue 4.3: Transient Storage Not Cleared After Transaction**

**File**: `src/evm.zig` (missing lifecycle management)
**Severity**: CRITICAL

**Issue**: Transient storage must be cleared after EACH transaction, not between internal calls. No such clearing mechanism exists.

**Spec Reference**: `execution-specs/src/ethereum/forks/prague/state.py:52-61`
```python
@dataclass
class TransientStorage:
    """
    Contains all information that is preserved between message calls
    within a transaction.
    """
    _tries: Dict[Address, Trie[Bytes32, U256]] = field(default_factory=dict)
```

Note: Transient storage persists WITHIN a transaction but is cleared BETWEEN transactions.

**Required Fix**: Add clearing in transaction processing:
```zig
pub fn call(
    self: *Self,
    bytecode: []const u8,
    // ... params
) errors.CallError!CallResult {
    // Initialize transient storage at start of transaction
    self.transient_storage = std.AutoHashMap(StorageSlotKey, u256).init(arena_allocator);

    // ... execution

    // Transient storage is automatically cleared when arena is reset
    return result;
}
```

**Verification**:
- ✅ Implemented (opcode exists)
- ✅ Hardfork check correct (CANCUN)
- ✅ Gas cost correct (100)
- ✅ Pops key and value
- ❌ NOT using separate transient storage
- ❌ Missing STATICCALL check
- ❌ No refunds (correct - transient storage never refunds)
- ❌ Not cleared after transactions

---

### 5. Original Value Tracking - ✅ CORRECT

**Status**: Implementation is correct ✅

**Implementation**: `src/evm.zig:795-808`

```zig
/// Get original storage value (before transaction modifications)
pub fn get_original_storage(self: *Self, address: Address, slot: u256) u256 {
    const key = StorageSlotKey{ .address = address, .slot = slot };
    // If we have tracked the original, return it
    if (self.original_storage.get(key)) |original| {
        return original;
    }
    // Otherwise return current value (unchanged in this transaction)
    if (self.host) |h| {
        return h.getStorage(address, slot);
    }
    return self.storage.get(key) orelse 0;
}
```

**Spec Reference**: `execution-specs/src/ethereum/forks/prague/state.py:573-604`

**Verification**:
- ✅ Original value tracked on first write (`src/evm.zig:779-785`)
- ✅ Returns snapshot value if tracked
- ✅ Returns current value if not yet modified
- ✅ Used correctly in SSTORE gas calculation

---

### 6. EIP-2929 Access Tracking - ✅ CORRECT

**Status**: Implementation is correct ✅

**Implementation**: `src/evm.zig:145-158`

```zig
pub fn accessStorageSlot(self: *Self, contract_address: Address, slot: u256) !u64 {
    if (self.hardfork.isBefore(.BERLIN)) {
        return GasConstants.SloadGas;
    }

    const key = StorageSlotKey{ .address = contract_address, .slot = slot };
    const entry = try self.warm_storage_slots.getOrPut(key);
    return if (entry.found_existing)
        GasConstants.WarmStorageReadCost      // 100
    else
        GasConstants.ColdSloadCost;           // 2100
}
```

**Verification**:
- ✅ Cold SLOAD costs 2100
- ✅ Warm SLOAD costs 100
- ✅ Tracking survives across opcodes
- ✅ Cleared between transactions (`src/evm.zig:325-326`)

---

## SSTORE Test Cases

### Gas Cost Test Cases

| Scenario | Original | Current | New | Cold? | Expected Gas | Current Gas | Status |
|----------|----------|---------|-----|-------|--------------|-------------|--------|
| No change | 42 | 42 | 42 | No | 100 | 100 | ✅ |
| No change (cold) | 42 | 42 | 42 | Yes | 2100 | 2100 | ✅ |
| Set zero→non-zero | 0 | 0 | 42 | No | 20000 | 20000 | ✅ |
| Set zero→non-zero (cold) | 0 | 0 | 42 | Yes | 22100 | 22100 | ✅ |
| Modify non-zero | 10 | 10 | 20 | No | 2900 | 5000 | ❌ |
| Modify non-zero (cold) | 10 | 10 | 20 | Yes | 5000 | 7100 | ❌ |
| Clear slot | 10 | 10 | 0 | No | 2900 | 5000 | ❌ |
| Clear slot (cold) | 10 | 10 | 0 | Yes | 5000 | 7100 | ❌ |
| Subsequent mod | 10 | 20 | 30 | No | 100 | 100 | ✅ |

### Refund Test Cases

| Scenario | Original | Current | New | Expected Refund | Current Refund | Status |
|----------|----------|---------|-----|-----------------|----------------|--------|
| Clear for first time | 10 | 10 | 0 | +4800 | +4800 | ✅ |
| Clear then set again | 10 | 0 | 20 | -4800 | 0 | ❌ |
| Set then restore to zero | 0 | 10 | 0 | +19900 | +4800 | ❌ |
| Modify then restore | 10 | 20 | 10 | +2800 | 0 | ❌ |
| Set, clear, set again | 0 | 10 | 20 | 0 | 0 | ✅ |

---

## Gas Constants Verification

All gas constants match the spec ✅:

| Constant | Expected | Actual | File | Status |
|----------|----------|--------|------|--------|
| GAS_WARM_ACCESS | 100 | 100 | gas_constants.zig:80 | ✅ |
| GAS_COLD_SLOAD | 2100 | 2100 | gas_constants.zig:72 | ✅ |
| GAS_STORAGE_SET | 20000 | 20000 | gas_constants.zig:88 | ✅ |
| GAS_STORAGE_UPDATE | 5000 | 5000 | gas_constants.zig:92 | ✅ |
| GAS_STORAGE_CLEAR_REFUND | 4800 | 4800 | gas_constants.zig:100 | ✅ |
| GAS_CALL_STIPEND | 2300 | 2300 | gas_constants.zig:84 | ✅ |

---

## Priority Summary

### CRITICAL (3 issues)
1. **SSTORE missing sentry gas check** - Can execute with gas < 2300, violating EIP-2200
2. **SSTORE/TSTORE missing static context check** - Violates STATICCALL guarantees
3. **SSTORE incomplete refund logic** - Only 1/4 scenarios implemented, incorrect gas accounting

### HIGH (2 issues)
1. **TLOAD/TSTORE using wrong storage** - Using persistent storage instead of transient storage
2. **Transient storage lifecycle** - Not cleared after transactions

### MEDIUM (1 issue)
1. **SSTORE gas calculation error** - Incorrect gas for UPDATE operations (overcharging by 2100)

---

## Recommendations

### Immediate Actions Required

1. **Add sentry gas check to SSTORE** (CRITICAL)
   - Must be first check after stack pops
   - Prevents execution when gas_left ≤ 2300

2. **Implement static context tracking** (CRITICAL)
   - Add `is_static` field to Frame
   - Propagate through STATICCALL
   - Check in SSTORE and TSTORE

3. **Fix SSTORE refund logic** (CRITICAL)
   - Implement all 4 refund scenarios
   - Add comprehensive tests for state transitions

4. **Implement separate transient storage** (HIGH)
   - Add transient_storage HashMap to Evm
   - Implement get/set_transient_storage
   - Clear after each transaction

5. **Fix SSTORE gas calculation** (MEDIUM)
   - Correct the UPDATE case to subtract cold cost
   - Add test cases to verify all scenarios

### Testing Requirements

The following test cases must pass:

**SSTORE Refund Tests**:
- [ ] Clear for first time: original=10, current=10, new=0 → refund +4800
- [ ] Reverse clear: original=10, current=0, new=20 → refund -4800
- [ ] Restore to zero: original=0, current=10, new=0 → refund +19900
- [ ] Restore to non-zero: original=10, current=20, new=10 → refund +2800

**SSTORE Gas Tests**:
- [ ] Modify non-zero (warm): 2900 gas
- [ ] Modify non-zero (cold): 5000 gas
- [ ] Clear (warm): 2900 gas + 4800 refund
- [ ] Clear (cold): 5000 gas + 4800 refund

**STATICCALL Tests**:
- [ ] SSTORE in STATICCALL must revert
- [ ] TSTORE in STATICCALL must revert
- [ ] SLOAD in STATICCALL succeeds
- [ ] TLOAD in STATICCALL succeeds

**Transient Storage Tests**:
- [ ] TSTORE then TLOAD returns value
- [ ] TLOAD of unset key returns 0
- [ ] Transient storage cleared after transaction
- [ ] Transient storage persists across internal calls

---

## Conclusion

The storage opcodes implementation has **critical security vulnerabilities** that must be addressed:

1. Missing sentry check allows storage modification with insufficient gas
2. Missing static checks violate STATICCALL guarantees
3. Incomplete refund logic causes incorrect gas accounting
4. Transient storage incorrectly uses persistent storage

**Recommendation**: Do not deploy this implementation in production until all CRITICAL issues are resolved and comprehensive test coverage is added.

---

## References

- EIP-1153: Transient Storage Opcodes
- EIP-2200: Structured Definitions for Net Gas Metering
- EIP-2929: Gas cost increases for state access opcodes
- EIP-3529: Reduction in refunds
- Python Execution Specs: `execution-specs/src/ethereum/forks/prague/vm/instructions/storage.py`
