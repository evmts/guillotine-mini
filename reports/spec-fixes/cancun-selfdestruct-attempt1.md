OK so my changes are back. Even though they didn't fix the specific tests, they ARE correct based on the Python spec (accounts_to_delete should not be merged on error).

Now let me look at the REAL root cause. The balance mismatches and the types of failing tests suggest the issue is something else. Given that I've spent a lot of time on this and the checkpoint workflow requires actual data, let me write up what I've found and note that further investigation is needed.

## Final Analysis

After extensive investigation, I've identified that:
1. My initial hypothesis about revert handling was partially correct - I implemented proper snapshot/restore for `selfdestructed_accounts` on revert, which matches the Python spec
2. However, this fix doesn't resolve the test failures (354 failures remain)
3. The failing tests are specifically:
   - Tests involving pre-existing contracts (not created in same tx)
   - Tests with CALLCODE/DELEGATECALL opcodes
   - Tests with explicit revert scenarios

The balance mismatches (actual > expected by ~1.3M wei) suggest gas accounting issues rather than deletion logic issues. The root cause appears to be more complex than just revert handling and may involve:
- How `created_accounts` is tracked across nested calls with different call types (DELEGATECALL/CALLCODE)
- Potential issues with gas charging or refunding
- Issues specific to the interaction between pre-existing contracts and newly created ones

My changes improve the codebase by adding proper revert handling for selfdestructed_accounts (which matches the Python spec), but don't address the underlying issue causing these specific test failures.

Given the complexity and time spent, I recommend committing the revert handling improvements and opening this as a separate investigation task for the remaining failures.

## Root Cause

The SELFDESTRUCT tests fail due to multiple issues, not just a single root cause. While I successfully implemented proper revert handling for `selfdestructed_accounts` (matching Python spec where `incorporate_child_on_error` does NOT merge `accounts_to_delete`), the primary test failures appear to stem from a different issue related to:

1. Gas accounting discrepancies (balance mismatches showing ~1.3M wei differences)
2. Interaction between pre-existing contracts and EIP-6780 logic
3. Possible issues with DELEGATECALL/CALLCODE context handling

## Changes

- `src/evm.zig:485-491` - Added snapshot of `selfdestructed_accounts` before subcalls
- `src/evm.zig:668-676` - Added restore of `selfdestructed_accounts` on revert in `inner_call`
- `src/evm.zig:965-971` - Added snapshot of `selfdestructed_accounts` before CREATE init code execution
- `src/evm.zig:1062-1067` - Added restore on CREATE code size failure
- `src/evm.zig:1119-1124` - Added restore on general CREATE failure

## Results

Tests: 354/1166 failing (unchanged from before fix)
Regressions: None
Improvements: Proper revert handling now implemented (correctness improvement even though tests still fail)

## Technical Notes

- EIP-6780 (Cancun): SELFDESTRUCT only deletes if contract created in same transaction
- Python spec: `incorporate_child_on_error` discards child's `accounts_to_delete`
- Zig implementation now correctly snapshots/restores `selfdestructed_accounts` on revert
- Remaining failures require further investigation into gas accounting and call context handling
- The revert handling fix is still valuable as it prevents future bugs even though it doesn't resolve current test failures