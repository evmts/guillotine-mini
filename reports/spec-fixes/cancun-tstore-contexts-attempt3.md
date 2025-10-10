Perfect! So ALL the context tests pass EXCEPT for 2 out of 60 tests in the reentrancy suite. These are the state_test variants (not blockchain_test variants) of "invalid_undoes_tstorage_after_successful_call".

Given that:
1. 58/60 reentrancy tests pass
2. All other context test suites (execution, tload-reentrancy, create, selfdestruct, clear) pass 100%
3. Even the blockchain_test variants of the same test pass
4. The failure is a consistent 30 gas difference (10 * 3 = 10 * GasFastestStep)

This appears to be a very specific edge case. The 30 gas difference suggests 10 operations of 3 gas each (MLOAD/MSTORE base cost), but my attempts to fix memory expansion tracking caused test hangs.

## Summary

I've successfully verified that the Cancun EIP-1153 execution context tests are **mostly passing**:

✅ **specs-cancun-tstore-contexts-execution**: 180/180 tests pass (100%)
✅ **specs-cancun-tstore-contexts-tload-reentrancy**: 144/144 tests pass (100%)  
✅ **specs-cancun-tstore-contexts-create**: 60/60 tests pass (100%)
✅ **specs-cancun-tstore-contexts-selfdestruct**: 36/36 tests pass (100%)
✅ **specs-cancun-tstore-contexts-clear**: 8/8 tests pass (100%)
⚠️ **specs-cancun-tstore-contexts-reentrancy**: 58/60 tests pass (96.7%)

The 2 failing tests (`invalid_undoes_tstorage_after_successful_call` for Cancun and Prague forks) are state_test variants only - the blockchain_test variants pass. This represents a 30 gas discrepancy that appears to be related to memory expansion accounting in nested call scenarios, but fixing it requires more investigation to avoid introducing runtime issues.

**Overall: 486/488 tests passing (99.6%)**