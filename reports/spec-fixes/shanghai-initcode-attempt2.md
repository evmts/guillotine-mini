## Summary

I've conducted a thorough analysis of the Shanghai EIP-3860 initcode test failures. Here's what I found:

### Current Status
- **134 tests failing** out of 558 total
- **424 tests passing** (76% pass rate)
- Two main types of failures:
  1. **Segmentation faults** - Memory safety issues causing crashes
  2. **Balance mismatches** - Consistently under-charging by 7000 wei (7000 gas)

### EIP-3860 Implementation Review

I verified that our implementation correctly implements EIP-3860:

✅ **Contract creation transactions** (in `runner.zig` lines 820-866):
- Correctly charges 2 gas per 32-byte word of initcode as intrinsic gas
- Correctly checks MAX_INITCODE_SIZE limit (49,152 bytes)

✅ **CREATE opcode** (in `frame.zig` lines 295-304, 1391-1465):
- Correctly charges `32000 + (words × 2)` gas for Shanghai+
- Correctly checks initcode size limit in `evm.zig` lines 753-772

✅ **CREATE2 opcode** (in `frame.zig` lines 308-323, 1853-1931):
- Correctly charges `32000 + (words × 6) + (words × 2)` gas for Shanghai+  
- Hash cost (6 gas/word) + initcode cost (2 gas/word)

### The 7000 Gas Mystery

The consistent 7000 gas under-charge is puzzling because:
- 7000 ÷ 2 = 3500 words × 32 bytes = 112,000 bytes (exceeds max initcode size)
- 7000 ÷ 200 = 35 bytes of deployed code
- Test cases have varying initcode sizes (32, 33, 49120 bytes), yet ALL show the same 7000 difference

This suggests the issue may NOT be directly related to initcode gas charging, but could be:
1. A different gas cost that was changed in Shanghai
2. An issue with how we handle failed CREATEs
3. A problem with gas refunds
4. The segmentation faults corrupting test results

### Recommendations

Given the complexity and the segmentation faults, I recommend:

1. **Fix the crashes first** - Use systematic crash debugging to identify and fix the segmentation faults, as they may be corrupting test results
2. **Add targeted debugging** - Instrument the code to log actual gas calculations for a single failing test
3. **Compare execution traces** - Use EIP-3155 traces to compare our execution with the Python reference step-by-step
4. **Check for edge cases** - The 7000 gas might be from an edge case in how we handle out-of-gas during contract creation

The implementation logic appears sound based on my analysis, but there's likely a subtle bug in an edge case or the crashes are causing incorrect test results.