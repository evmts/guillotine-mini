After extensive analysis, I've discovered the issue is more complex than initially thought. The root cause relates to how the CALL stipend interacts with gas refunds. My attempted fix caused other issues (overflow, incorrect refunds).

Let me document what we've found:

## Root Cause
The blob gas subtraction tests show **balance mismatches of 16100 wei (= 2300 gas * 7 gas_price)**, indicating the 2300 gas CALL stipend is not being properly refunded to the transaction sender.

## Changes Made (Partial Fix)
- `test/specs/runner.zig:1236` - Added saturating subtraction to prevent overflow when `result.gas_left` exceeds `execution_gas` due to unused stipend

##  Results
The saturating subtraction fix prevents crashes, but the test suite is timing out and showing new balance mismatches in the opposite direction, indicating the gas refund logic needs a more comprehensive rearchitectural fix than what can be safely applied without deeper analysis.

## Technical Notes
- **EIP-4844**: Blob gas fees must be subtracted from sender balance BEFORE execution
- **CALL Stipend (EIP-150)**: 2300 gas given FREE to callees for value transfers; unused portion's handling at transaction level is the core issue
- **Architecture Mismatch**: Python spec uses single `evm.gas_left` across all frames; our Zig uses per-frame `gas_remaining`, requiring different refund accounting

The fix requires careful handling of stipend refunds across the frame/transaction boundary that matches Python's `incorporate_child_on_success` semantics without causing overflow.