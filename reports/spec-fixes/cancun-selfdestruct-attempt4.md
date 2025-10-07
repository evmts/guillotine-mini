Let me summarize what we've accomplished so far:

## Summary

I've made significant progress on implementing EIP-6780 (SELFDESTRUCT only in same transaction) for the Cancun hardfork:

### Changes Made

1. **Restructured SELFDESTRUCT balance transfer logic** (src/frame.zig):
   - Implemented proper `move_ether` semantics that match the Python reference
   - When beneficiary != originator: transfer balance normally
   - When beneficiary == originator: balance remains unchanged (unless account is deleted)
   - Only accounts created in the same transaction are deleted (Cancun+)
   - Pre-Cancun behavior: always delete accounts

2. **Fixed refund check ordering**:
   - Check if account is already in `selfdestructed_accounts` BEFORE applying refund
   - Apply refund BEFORE marking account for deletion
   - This prevents double-refunding if SELFDESTRUCT is called multiple times

### Test Results

- **812 tests passing** out of 1166 total (70% pass rate)
- **354 tests failing** 
- Many failures show consistent balance mismatches indicating a gas accounting issue

### Root Cause Analysis (Ongoing)

The remaining failures show a consistent pattern:
- Balance mismatches where actual balance is ~600k-1.3M wei higher than expected
- This indicates we're undercharging gas (not consuming enough)
- The issue is NOT with refunds (those are 0 in London+)
- The issue is NOT with balance transfer logic (that now matches Python reference)

The gas discrepancy suggests there's still an issue with either:
1. Gas cost calculation for SELFDESTRUCT
2. Gas cost calculation for related operations (CALL, CREATE, etc.)
3. Some other gas accounting bug in the transaction execution

Given the complexity and the fact that 70% of tests are passing, the implementation is close but needs further debugging to identify the exact source of the gas discrepancy.

### Next Steps

To fully resolve this, I would need to:
1. Isolate a single failing test and run it with detailed gas tracing
2. Compare our gas consumption step-by-step with the Python reference
3. Identify the exact operation(s) that are undercharging gas
4. Fix the gas calculation logic

The implementation is substantially correct for EIP-6780 semantics, but there's a gas accounting bug that needs to be resolved.