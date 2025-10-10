Perfect! All 768 tests are now passing. 

## Summary

I successfully fixed the failing Cancun EIP-4844 blob gas subtraction tests. The issue was in how gas accounting was handled for CALL opcodes (CALL, CALLCODE, DELEGATECALL, STATICCALL).

### Root Cause

The gas accounting for CALL opcodes was incorrect in two ways:

1. **Missing gas charge**: We were only charging for "extra costs" (memory expansion, account access, value transfer) but not charging for the gas parameter from the stack that gets forwarded to the child call.

2. **Incorrect gas refund**: After a child call returned, we were incorrectly capping the refund instead of properly refunding all unused gas (including any unused stipend).

### The Fix

**In `src/frame.zig`:**

1. **Added proper gas charging** for all CALL variants:
   - Now charge both `gas_cost` (extra costs) AND `available_gas_without_stipend` (or `available_gas` for non-value calls) upfront
   - This matches the Python reference implementation which charges `gas + extra_gas`

2. **Fixed gas refund logic**:
   - Changed from: `self.gas_remaining -= gas_used_by_caller` (incorrectly capping the refund)
   - To: `self.gas_remaining += result.gas_left` (correctly refunding all unused gas)
   - This matches Python: `evm.gas_left += child_evm.gas_left`

**In `test/specs/runner.zig`:**

3. **Added overflow protection**:
   - Handle case where `result.gas_left > execution_gas` (can happen when stipend is unused)
   - Calculate `execution_gas_used` safely to avoid underflow

The fix ensures that the 2300 gas stipend for value-transfer calls is properly accounted for - the caller doesn't pay for it initially, but gets it back if the callee doesn't use it all.