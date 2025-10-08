## Summary

I've identified and fixed critical EIP-4844 blob constant mismatches, but the tests still show a systematic balance calculation error that requires deeper investigation.

## Root Cause

Two critical constants in the codebase were incorrectly set:

1. **BLOB_BASE_FEE_UPDATE_FRACTION** was set to 5007716 instead of the spec-defined 3338477
   - Location: `src/primitives/blob.zig:14` and `src/primitives/gas_constants.zig:1661`
   - Impact: Would cause incorrect blob gas price calculations in any code using these constants
   - Python spec reference: `execution-specs/src/ethereum/forks/cancun/vm/gas.py` defines it as `Uint(3338477)`

2. **TARGET_BLOB_GAS_PER_BLOCK** was set to 786432 (3 * 2^18) instead of 393216 (3 * 2^17)
   - Location: `src/primitives/gas_constants.zig:1659`
   - Impact: Would cause incorrect excess blob gas calculations
   - Python spec reference: `TARGET_BLOB_GAS_PER_BLOCK = U64(393216)`

## Changes Made

- `src/primitives/blob.zig:14` - Changed BLOB_BASE_FEE_UPDATE_FRACTION from 5007716 → 3338477
- `src/primitives/gas_constants.zig:1661` - Changed BLOB_BASE_FEE_UPDATE_FRACTION from 5007716 → 3338477  
- `src/primitives/gas_constants.zig:1659` - Changed TARGET_BLOB_GAS_PER_BLOCK from 786432 → 393216

## Current Status

**Tests are running but not passing.** There is a systematic balance mismatch:
- Expected vs actual balance differs by exactly 16100 or 32200 wei
- At gas_price=7, this represents 2300 or 4600 gas
- 2300 gas is the CALL stipend amount, suggesting a gas accounting issue

The runner.zig file was already using the correct constant value (3338477) directly in its taylorExponential calls, which explains why tests run but still fail - the runner's blob gas calculation is correct, but there's a separate gas accounting bug causing the 2300 gas discrepancy.

## Technical Notes

- **EIP-4844 Reference**: The BLOB_BASE_FEE_UPDATE_FRACTION constant is used in the Taylor series approximation of the exponential pricing formula: `fake_exponential(MIN_BLOB_GASPRICE, excess_blob_gas, BLOB_BASE_FEE_UPDATE_FRACTION)`
- **Verified**: The taylorExponential function implementation correctly matches the Python spec
- **Verified**: For excess_blob_gas=917504, both implementations correctly return blob_gas_price=1
- **Remaining Issue**: The 2300 gas error appears related to CALL stipend handling but root cause not yet identified - requires deeper trace analysis of gas accounting during CALL operations

## Recommendation

The constant fixes are correct and necessary, but additional investigation is needed to resolve the 2300 gas accounting error before all blob subtraction tests will pass.