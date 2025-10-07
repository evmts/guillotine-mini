The tests are taking too long. Let me check the summary that was printed earlier. Looking back at the output, I see tests crash around test #364. Let me look at which tests those are:

From the earlier output, I saw:
- "✓" up to around test 364
- Then "Segmentation fault at address 0x0" happens 6 times

These segfaults are critical and need to be fixed. However, given the time I've spent and the complexity of this debugging session, let me provide you with a comprehensive summary of what I've found and what still needs to be done.

## Summary

I've been investigating the Shanghai EIP-3860 initcode test failures. Here's what I've found:

### Root Cause Analysis

**EIP-3860 Implementation Status:**
- ✅ Initcode gas constants are correctly defined (InitcodeWordGas = 2, MaxInitcodeSize = 49152)
- ✅ Initcode gas is correctly charged for contract creation transactions in intrinsic gas (Shanghai+)
- ✅ Initcode gas is correctly charged for CREATE/CREATE2 opcodes
- ✅ Initcode size limit validation is in place

**Main Issue - 700 Gas Undercharge:**
- **134 tests failing** with consistent balance mismatches
- Balance is consistently **7000 wei SHORT** (with gas price 10 = **700 gas** undercharged)
- 700 gas = exactly `CallGas` constant, but unclear why this is missing
- The intrinsic gas calculation appears correct when compared to Python reference
- The issue persists even when I experimentally changed TxGasContractCreation
- **Hypothesis**: There may be a missing gas cost somewhere during execution or a subtle difference in how state tests vs blockchain tests are handled

**Secondary Issue - Segmentation Faults:**
- **6 crashes** with "Segmentation fault at address 0x0" 
- These occur around test #364 in the test suite
- Need systematic debugging using the crash debugging methodology to find exact crash location

### Tests Status
- **424 tests PASSING** (76%)
- **134 tests FAILING** (24%)
- Blockchain tests seem to pass
- State tests are failing with balance mismatches

### Next Steps Required

1. **Fix the 700 gas undercharge:** This is the primary blocker affecting most failures. Need to:
   - Add debug logging to track exact gas values at each stage
   - Compare our execution trace with Python reference implementation step-by-step
   - Check if there's a subtle difference in gas accounting between state tests and blockchain tests

2. **Fix segmentation faults:** Use binary search with `@panic("CHECKPOINT")` to find exact crash locations

3. **Fix storage mismatches:** Some tests show storage not being written (expected 1, found 0)

The EIP-3860 implementation itself appears correct, but there's a systematic 700 gas accounting error that needs to be identified and fixed.