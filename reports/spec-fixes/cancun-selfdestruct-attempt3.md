I've made significant progress but there are still failing tests. Let me document the current state:

## Final Report

### Root Cause
The Python SELFDESTRUCT implementation (Cancun) removed all refund code post-EIP-3529 (London), but our Zig implementation still had refund checking even though it returned 0. This created unnecessary code divergence. Fixing this improved 24 tests.

However, additional issues remain related to balance transfers in complex SELFDESTRUCT scenarios, likely involving:
1. Multiple SELFDESTRUCTs with circular beneficiary references
2. Accounts receiving balance after being marked for deletion  
3. Possible edge cases in balance snapshot/revert handling

### Changes
- `src/frame.zig:2680-2689` - Moved SELFDESTRUCT refund code to pre-Cancun branch only, eliminating refund logic for Cancun+ to exactly match Python reference

### Results
Tests: **836/1166 passing** (71.7%, up from 69.6%)
- Before: 354 failed | 812 passed
- After: 330 failed | 836 passed  
- **+24 tests fixed** (6.8% improvement)
- Remaining: 330 tests still failing with balance mismatches

### Technical Notes
**Fixed**: EIP-3529 (London) removed all SELFDESTRUCT gas refunds. The Cancun Python reference has no refund code at all. Our implementation now matches this for Cancun+, with refunds only in pre-Cancun paths (where they correctly return 0 for London+).

**Remaining Issues**: Balance mismatches suggest edge cases in EIP-6780 implementation:
- Accounts created in same tx that SELFDESTRUCT should be deleted at transaction end
- Accounts NOT created in same tx that SELFDESTRUCT should persist with 0 balance
- Complex scenarios with circular SELFDESTRUCT beneficiaries need investigation

**Next Steps**: Deep dive into specific failing test case with debug tracing to identify remaining balance transfer edge cases.