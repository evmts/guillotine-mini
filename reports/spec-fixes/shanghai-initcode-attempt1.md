Given the significant time investment and complexity, let me provide a status report on what I've discovered:

## Root Cause Analysis

I've identified multiple issues with the EIP-3860 initcode tests:

### 1. Segmentation Faults (Signal 6 - SIGABRT)
Multiple tests are crashing with SIGABRT. This is likely due to:
- Tests with "exact_execution_gas" or "exact_intrinsic_gas" that provide precisely the minimum gas required
- Our gas calculations may be slightly off, causing out-of-gas conditions that trigger panics
- The huge access lists (477 addresses) in test transactions may be causing issues during processing

### 2. Consistent 7000 Gas Discrepancy  
ALL non-crashing tests show we use 7000 MORE gas than expected. Analysis shows:
- The discrepancy is consistent across all test cases
- 7000 gas = 3500 words * 2 gas/word (the initcode word cost)
- This suggests we may be charging init code costs incorrectly somewhere

### Current State
- Initial failing tests: 134
- Test commented out initcode intrinsic gas: 155 failed (worse)
- The intrinsic gas calculation appears correct based on Python reference
- Need to investigate if there's double-charging elsewhere or if CREATE/CREATE2 opcodes are charging when they shouldn't for contract creation transactions

## Next Steps Required

To fix these issues, I would need to:
1. Add debug logging to trace exact gas calculations
2. Use the crash debugging methodology to isolate the exact line causing SIGABRT
3. Compare our execution trace with the Python reference for a single failing test
4. Investigate whether `inner_create` is charging initcode costs despite the comment saying it shouldn't

The tests ARE correctly checking EIP-3860 functionality, but our implementation has subtle bugs in either gas metering or execution logic that need systematic debugging.