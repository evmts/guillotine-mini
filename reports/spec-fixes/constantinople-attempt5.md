## Root Cause Analysis

I identified and fixed a critical bug in the Istanbul hardfork's SSTORE gas metering:

**Bug**: The SSTORE gas cost for "no change" and "subsequent modification" operations was incorrectly set to 200 gas for Istanbul and London hardforks. According to EIP-2200, this should be 800 gas (GAS_SLOAD).

**Impact**: This caused gas calculation errors in tests that perform many SSTORE operations (like the bitwise shift combination tests), resulting in incorrect gas remaining values.

**Root Cause**: The `sstore_gas_cost_with_hardfork()` function in `src/primitives/gas_constants.zig` was hardcoded to use 200 gas for pre-Berlin hardforks, but EIP-2200 (Istanbul) changed SLOAD from 200 to 800 gas.

## Changes Made

1. **Fixed Istanbul SSTORE gas cost** (`src/primitives/gas_constants.zig` lines 1361 and 1371):
   - Changed from `200` to `800` for Istanbul and London hardforks
   - This correctly implements EIP-2200's gas metering rules
   - Berlin and later correctly use `WarmStorageReadCost` (100 gas)

2. **Added return_data clearing** (`src/frame.zig`):
   - Added `self.return_data = &[_]u8{};` at the start of CREATE (line 1396) and CREATE2 (line 1851) opcodes
   - This matches the Python reference implementation which clears return_data at the start of generic_create()
   - Ensures return_data from previous operations doesn't persist incorrectly

## Test Results

- **Before fixes**: 171 tests failed, 337 tests passed (66.3% pass rate)
- **After fixes**: 168 tests failed, 340 tests passed (66.9% pass rate)
- **Fixed**: 3 shift combination tests that were failing due to incorrect Istanbul SSTORE gas costs

**Remaining 168 failures**: All are state_tests (not blockchain_tests) for CREATE2/CREATE return data handling on Berlin and later hardforks. The interesting pattern is:
- ALL 168 blockchain_tests for the same scenarios PASS
- ALL 168 state_tests for the same scenarios FAIL
- Both test types use identical EVM code

This suggests the remaining issues are likely related to:
1. How state_tests validate results differently than blockchain_tests
2. Potential differences in test harness initialization or state checking
3. A subtle edge case in Berlin's EIP-2929 (cold/warm access) implementation that affects state_tests but not blockchain_tests

## Technical Details

**EIP-2200 (Istanbul)**: Introduced "net gas metering" for SSTORE, where:
- No-op writes (same value): 800 gas (GAS_SLOAD)
- First modification: 20,000 gas (if setting from 0) or 5,000 gas (if updating)
- Subsequent modifications: 800 gas (GAS_SLOAD)

**EIP-2929 (Berlin)**: Reduced warm SLOAD from 800 to 100 gas, with 2100 gas for cold access.

The fix correctly implements this progression: Constantinople/Petersburg use simple 5000/20000 rules, Istanbul/London use 800/5000/20000 rules, and Berlin+ use 100/2100/5000/20000 rules with cold/warm tracking.