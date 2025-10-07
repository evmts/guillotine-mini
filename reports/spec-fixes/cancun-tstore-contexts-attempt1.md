Excellent! All tests are passing. Now let me create a summary of the changes:

## Root Cause Analysis

The EVM implementation had a bug in how it handled SELFDESTRUCT for contracts created in the same transaction (EIP-6780). The issue was that when a contract self-destructed, the code was being cleared **immediately** during the SELFDESTRUCT operation, rather than being deferred until the end of the transaction.

This caused problems with transient storage (EIP-1153) interactions: when a contract self-destructed and was then called again in the same transaction, the subsequent call would find no code and return immediately with no output, instead of executing the contract code and accessing the transient storage that should still be available throughout the transaction.

The failing tests were checking scenarios where:
1. A contract stores a value in transient storage (TSTORE)
2. The contract self-destructs (but was created in the same transaction)
3. The contract is called again and tries to load from transient storage (TLOAD)

Expected behavior: The contract code should still execute (deletion happens at transaction end), transient storage should still be accessible, and TLOAD should return the previously stored value.

Actual behavior (buggy): The contract code was deleted immediately, so the call returned with no execution, leaving stale data in the caller's memory.

## Changes Made

### 1. `/Users/williamcory/guillotine-mini/build.zig` (lines 310-326)
- **Fixed test filters** for Cancun sub-targets to use simple substring matching instead of regex-style patterns
- Changed filters from patterns like `"cancun.*tstore.*(contexts|selfdestruct)"` to simple substrings like `"eip1153_tstore_test_tstorage_"`
- Added comment explaining that filters use simple substring matching, not regex
- This was necessary because the test runner's `matchesFilter` function only does substring matching

### 2. `/Users/williamcory/guillotine-mini/src/evm.zig` (multiple locations)
- **Added `selfdestructed_accounts` field** (line 90) to track accounts marked for deletion per EIP-6780
- **Initialized the field** in the `init` function (line 124) and `execute` function (line 268)
- **Added deletion logic** at the end of transaction (lines 385-404) to actually delete selfdestructed accounts after transient storage is cleared

### 3. `/Users/williamcory/guillotine-mini/src/frame.zig` (lines 2488-2497)
- **Changed SELFDESTRUCT implementation** to mark accounts for deletion instead of deleting immediately
- Replaced immediate deletion code with `try evm_ptr.selfdestructed_accounts.put(self.address, {});`
- Added comments explaining that actual deletion happens at transaction end to allow code to persist during the transaction

## Test Results

✅ **All 410 tests in specs-cancun-tstore-contexts now pass**
- 0 failed, 410 passed
- This includes all the transient storage execution contexts tests that were previously failing
- The 6 selfdestruct-related test failures are now fixed

✅ **No regressions** in other test suites:
- specs-cancun-tstore-basic: 66/66 passed
- specs-cancun-tstore-reentrancy: 144/144 passed

## Technical Details

The fix properly implements EIP-6780's semantics for SELFDESTRUCT:
- **Balance transfer happens immediately** when SELFDESTRUCT is executed
- **Code, nonce, and storage persist** until the end of the transaction
- **Actual account deletion is deferred** to transaction end, only for accounts created in the same transaction
- **Transient storage (EIP-1153) remains accessible** throughout the entire transaction, even after SELFDESTRUCT

This is critical for reentrancy scenarios where a contract may self-destruct and then be called again in the same transaction. The contract code must remain executable, and transient storage must remain accessible, until the transaction completes.