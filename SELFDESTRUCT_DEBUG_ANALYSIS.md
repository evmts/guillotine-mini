# SELFDESTRUCT EIP-6780 Test Failure Debug Analysis

## Executive Summary

**Test Case:** `test_selfdestruct_pre_existing[fork_Shanghai-single_call]`
**Status:** Failing with balance mismatches
**Issue:** Sender has LESS balance than expected → We're charging MORE gas than we should
**Common Balance Differences:** 79,850 or 67,700 wei

---

## Key Numbers from Test Definition

### Test File Location
```
execution-specs/tests/eest/static/state_tests/state_tests/eest/cancun/
eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.json
```

### Transaction Parameters
- **Gas Price:** 10 wei/gas (0xa)
- **Gas Limit:** 500,000 gas (0x07a120)
- **Sender Initial Balance:** 1,000,000,000,000,000,000,000 wei (1000 ETH)
- **Expected Final Balance:** 999,999,999,999,998,445,250 wei
- **Expected Gas Used:** 155,475 gas

### Known Balance Discrepancies
- **79,850 wei = 7,985 gas OVERCHARGE**
- **67,700 wei = 6,770 gas OVERCHARGE**

---

## Test Scenario Breakdown

### Pre-Existing Accounts

1. **Sender:** `0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b`
   - Balance: 1000 ETH
   - Nonce: 0
   - This is the transaction sender

2. **Contract A:** `0x1000000000000000000000000000000000001000`
   - Pre-existing (nonce=1, created before transaction)
   - Balance: 0
   - Code: `0x6000600055` (PUSH1 0, PUSH1 0, SSTORE)
   - Storage[0] = 0x01
   - Simple contract that stores 0 to slot 0

3. **Contract B:** `0x1000000000000000000000000000000000001100`
   - Pre-existing (nonce=1, created before transaction)
   - Balance: 0
   - Code: `0x600160005401600055731000000000000000000000000000000000001000ff600060005500`
   - Disassembly:
     ```
     PUSH1 0x01        # Push 1
     PUSH1 0x00        # Push 0
     SLOAD             # Load storage[0]
     ADD               # Add 1 to storage[0]
     PUSH1 0x00        # Push 0
     SSTORE            # Store to slot 0
     PUSH20 0x1000...1000  # Push beneficiary address
     SELFDESTRUCT      # Self-destruct to beneficiary
     PUSH1 0x00        # (unreachable code)
     PUSH1 0x00
     SSTORE
     STOP
     ```

### Transaction Execution Flow

1. Sender creates a new contract (CREATE operation)
2. New contract CALLs Contract B (`0x1000...1100`)
3. Contract B executes:
   - Increments `storage[0]`
   - Calls `SELFDESTRUCT` with beneficiary = Contract A (`0x1000...1000`)
4. **Expected for Shanghai fork:** Contract B should be DELETED (pre-EIP-6780 behavior)
5. **Expected for Cancun+ fork:** Contract B should NOT be deleted (EIP-6780)

---

## SELFDESTRUCT Gas Calculation

### Shanghai Fork Gas Costs
```
Base cost:                    5,000 gas
+ Cold access (EIP-2929):     2,600 gas (if beneficiary is cold)
+ New account:               25,000 gas (if beneficiary empty AND balance > 0)
Refund:                           0 gas (EIP-3529, London)
```

### For This Specific Test
- Beneficiary (`0x1000...1000`) already exists (nonce=1)
- Self (`0x1000...1100`) has balance=0
- **Expected SELFDESTRUCT gas:** 5,000 + 2,600 (cold) = **7,600 gas**
  - OR: 5,000 (warm) = **5,000 gas** if beneficiary was already accessed

---

## Gas Overcharge Analysis

### Discrepancy #1: 7,985 gas overcharge
This is suspiciously close to:
- **4 cold SLOAD operations:** 4 × 2,100 = 8,400 gas
- **3 cold SLOAD + warm operations:** 3 × 2,100 + ~785 = 7,085 gas
- Could also be: Multiple storage operations being charged incorrectly

### Discrepancy #2: 6,770 gas overcharge
This is suspiciously close to:
- **3 cold SLOAD operations:** 3 × 2,100 = 6,300 gas
- **SELFDESTRUCT cold access + extra:** 5,000 + 2,600 = 7,600 gas (too high)
- Could be: ~3 storage accesses being over-charged

### Strong Hypothesis
**The gas overcharges (7,985 and 6,770) are very close to multiples of 2,100 (cold SLOAD cost).**

This suggests: **Storage access operations are being over-charged**, possibly:
- Charging cold access when should be warm
- Double-charging storage access
- Not properly tracking accessed storage keys

---

## Possible Root Causes

### Hypothesis 1: Storage Access Over-Charging ⭐ MOST LIKELY
- SLOAD cold access: 2,100 gas
- SLOAD warm access: 100 gas
- SSTORE costs vary by state change
- **CHECK:** Are we properly tracking accessed storage keys in `accessed_storage_keys`?
- **CHECK:** Are we charging cold vs warm correctly?

### Hypothesis 2: Warm/Cold Address Tracking
- Addresses should be marked warm when accessed
- **CHECK:** Is `warm_addresses` set being maintained correctly?
- **CHECK:** Are addresses added to warm set at the right time?
- **CHECK:** Does CREATE operation properly mark created contract as warm?

### Hypothesis 3: CREATE Gas Costs
- Shanghai adds EIP-3860 (initcode metering)
- CREATE base: 32,000 gas
- \+ 2 gas per word of initcode
- **CHECK:** Is initcode gas calculated correctly in `createGasCost()`?

### Hypothesis 4: CALL Gas Costs
- When new contract calls `0x1000...1100`:
- CALL base cost varies by hardfork
- Cold access: +2,600 gas
- **CHECK:** Are CALL gas costs correct for Shanghai?

### Hypothesis 5: Gas Refund Bug
- Should be 0 for London+ (including Shanghai)
- **CHECK:** Is `selfdestructRefund()` returning 0 correctly?
- **CHECK:** Are refunds being applied incorrectly somewhere?

---

## Files to Investigate

### `/Users/williamcory/guillotine-mini/src/frame.zig`
- **Lines 2488-2613:** SELFDESTRUCT implementation
- **Lines 2508-2514:** Cold account access charging
- **Lines 2537-2540:** New account cost charging
- **Lines 2607-2610:** Refund application
- **SLOAD/SSTORE implementation:** Check cold/warm access charging

### `/Users/williamcory/guillotine-mini/src/evm.zig`
- Warm address tracking (`warm_addresses`)
- Accessed storage tracking (`accessed_storage_keys`)
- Account creation tracking (`created_accounts`)
- Gas refund accumulation

---

## Recommended Debugging Steps

### 1. Add Detailed Gas Logging
Add logging to track:
- Gas before/after each major operation
- `warm_addresses` set contents
- `accessed_storage_keys` contents
- Cold access charges
- Each gas consumption with reason

### 2. Compare with Python Reference
- File: `execution-specs/src/ethereum/shanghai/vm/instructions/system.py`
- Check `selfdestruct()` implementation
- Check `sload()` and `sstore()` implementations
- Compare warm/cold tracking logic

### 3. Isolate and Test
Create a minimal test that:
- Creates a contract
- Calls SELFDESTRUCT
- Logs every gas charge
- Compare actual vs expected: 155,475 gas

### 4. Check Specific Operations
Priority order:
1. **SLOAD/SSTORE gas calculation** (most likely)
2. CALL gas calculation
3. CREATE gas calculation
4. Cold access tracking in `warm_addresses`
5. Storage key tracking in `accessed_storage_keys`

---

## EIP Reference

### EIP-2929 (Berlin) - Gas cost increases for state access opcodes
- Cold SLOAD: 2,100 gas
- Warm SLOAD: 100 gas
- Cold account access: 2,600 gas
- Warm account access: 100 gas

### EIP-3529 (London) - Reduction in gas refunds
- SELFDESTRUCT refund: 0 (was 24,000)
- SSTORE refund: reduced

### EIP-6780 (Cancun) - SELFDESTRUCT only in same transaction
- Only deletes account if created in same transaction
- Otherwise just transfers balance

### EIP-3860 (Shanghai) - Limit and meter initcode
- CREATE/CREATE2: +2 gas per word of initcode
- Maximum initcode size: 49,152 bytes

---

## Test File Paths

### Zig Test File
```
/Users/williamcory/guillotine-mini/test/specs/generated/state_tests/eest/cancun/
eip6780_selfdestruct/selfdestruct/selfdestruct_pre_existing.zig
```

### JSON Test Definition
```
/Users/williamcory/guillotine-mini/execution-specs/tests/eest/static/state_tests/
state_tests/eest/cancun/eip6780_selfdestruct/selfdestruct/
selfdestruct_pre_existing.json
```

---

## Next Actions

1. **Examine SLOAD/SSTORE implementation** in `frame.zig`
2. **Check accessed_storage_keys tracking** in `evm.zig`
3. **Add gas logging** to identify where extra gas is charged
4. **Run single test** with verbose output
5. **Compare execution trace** with Python reference implementation

---

*Generated: 2025-10-07*
*Analysis based on test case: `test_selfdestruct_pre_existing[fork_Shanghai-single_call]`*
