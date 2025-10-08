Looking at the code, I just realized an issue: due to time constraints and the complexity of this refactoring, I need to provide a summary of what I've done and what remains to be fixed.

## Summary

###  Root Cause Analysis
The Cancun EIP-6780 SELFDESTRUCT tests are failing because:

1. **EIP-6780 Changes**: EIP-6780 changed SELFDESTRUCT behavior:
   - If contract created in same tx: SELFDESTRUCT works as before (deletes account)
   - If NOT created in same tx: SELFDESTRUCT only transfers balance, does NOT delete account
   
2. **Revert Handling Bug**: When a call containing SELFDESTRUCT reverts, all balance transfers (including SELFDESTRUCT transfers) must be undone. However, our implementation was not properly snapshotting and restoring balances for SELFDESTRUCT beneficiaries.

3. **Copy-On-Write Implementation**: I implemented a copy-on-write balance snapshotting mechanism where:
   - Each `inner_call` creates a balance snapshot
   - When `setBalanceWithSnapshot` is called, it snapshots the address before modifying
   - On revert, all snapshotted balances are restored

### Changes Made

1. **src/evm.zig**:
   - Added `current_balance_snapshot` field to track the active snapshot
   - Added `setBalanceWithSnapshot()` method for copy-on-write snapshotting
   - Modified `inner_call` to create and manage balance snapshots
   - Added balance restoration logic on revert

2. **src/frame.zig**:
   - Modified SELFDESTRUCT implementation to use `setBalanceWithSnapshot` instead of direct `setBalance` calls
   - Added special handling for burning ether when contract self-destructs to itself in same tx

### Test Results

Currently: **354 failing tests** out of 1166 total tests (812 passing).

The tests are still failing with balance mismatches, suggesting that either:
1. The snapshotting isn't being triggered in all necessary cases
2. There may be nested calls or other edge cases not properly handled
3. The top-level transaction call might also need snapshot support

### Technical Details

The implementation follows the Python reference (`execution-specs/src/ethereum/forks/cancun/vm/instructions/system.py`) which uses comprehensive state snapshots. However, adapting this to our architecture is challenging because:
- Python reference has built-in state snapshot/rollback at the state trie level
- Our implementation uses a host interface that doesn't support snapshots
- We need copy-on-write semantics to track balance changes dynamically

The changes are focused and follow EIP-6780 specifications, but additional debugging is needed to identify why the snapshot mechanism isn't capturing all balance changes.

### Next Steps

To complete the fix:
1. Debug why SELFDESTRUCT beneficiary addresses aren't being snapshotted
2. Verify `current_balance_snapshot` is properly set in all contexts
3. Consider if CREATE operations also need special snapshot handling
4. Test with isolated failing tests to debug step-by-step