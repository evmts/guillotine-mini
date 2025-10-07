Given the complexity of this issue and the time spent debugging, let me provide a summary of what I've found so far and next steps.

## Root Cause Analysis

After extensive investigation, I've identified and fixed one bug but there's still an issue:

### Fixed Issue #1: Gas Refund Cap Calculation
**Location**: `test/specs/runner.zig` lines 1082-1084

**Problem**: The gas refund cap was being calculated based on execution gas only, not total gas used (intrinsic + execution). According to EIP-3529, the refund should be capped at a fraction of TOTAL gas used.

**Fix Applied**: Changed from:
```zig
@min(gas_refund, execution_gas_used / 2)  // WRONG
```
To:
```zig
@min(gas_refund, gas_used_before_refunds / 2)  // CORRECT
```

### Remaining Issue: Persistent Gas Differences  
**Status**: Still investigating

**Observations**:
1. All 124 failing tests are `state_tests` for MODEXP precompile
2. All `blockchain_tests` (144 tests) pass
3. Gas differences vary by test (not a constant offset):
   - Some tests: ~12,396 gas difference
   - Others: ~500-5,000 gas difference
4. The MODEXP gas calculation logic appears correct when compared to Python reference
5. Tests span multiple hardforks (Berlin, Istanbul, London, etc.)

**Potential Areas to Investigate**:
1. Hardfork-specific calldata cost changes (EIP-2028: 68→16 gas for non-zero bytes in Istanbul)
2. Subtle differences in how state tests vs blockchain tests calculate final balances
3. Possible rounding errors in large number arithmetic in MODEXP gas calculations
4. Memory expansion costs for MODEXP calls

The refund cap fix I made is definitely correct and needed, even though it didn't resolve all the MODEXP test failures. The remaining issue requires deeper investigation into the exact gas accounting differences between our implementation and the reference.

## Summary

**Changes Made:**
- Fixed gas refund cap calculation in `test/specs/runner.zig` to use total gas used instead of execution gas only

**Test Results:**
- Byzantium tests: Still 124 failing (all MODEXP state_tests), 228 passing
- The refund cap fix is correct but doesn't address the MODEXP-specific gas calculation issue

**Next Steps:**
- Need to trace through a specific failing MODEXP test step-by-step
- Compare exact gas calculations with Python reference implementation
- May need to add detailed logging to gas calculations to find the discrepancy