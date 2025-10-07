## Summary

I've been working to make the EVM implementation compliant with EIP-6780 (SELFDESTRUCT changes in Cancun). Here's what I've accomplished and what remains:

### Changes Made:

1. **Fixed SELFDESTRUCT refund logic** (`src/frame.zig` lines 2488-2517):
   - Added check to prevent double-refunding if SELFDESTRUCT is called multiple times on the same address in a transaction
   - Refunds are now only given if the address hasn't been marked for selfdestruct yet (per Berlin spec)
   - Refund amount correctly returns 0 for London+ (EIP-3529)

2. **Added revert handling** (`src/evm.zig` lines 427-449, 609-632):
   - Added snapshot/restore mechanism for `selfdestructed_accounts` on call revert
   - Added snapshot/restore mechanism for `created_accounts` on call revert
   - This ensures that if a subcall reverts, accounts marked for deletion or creation within that call are properly reverted

3. **Removed interfering debug output**:
   - Commented out DEBUG print statements that were interfering with test output

### Current Status:

- **812 tests passing** (unchanged from before my fixes)
- **354 tests failing**:
  - 119 balance mismatches (sender getting too much gas refunded)
  - Multiple crashes with signal 6 (SIGABRT) on revert-related tests

### Root Cause Analysis:

The EIP-6780 specification changes SELFDESTRUCT behavior such that:
1. In Cancun+, SELFDESTRUCT only deletes account data if the contract was created in the same transaction
2. Otherwise, it only transfers the balance (no deletion)
3. In London (EIP-3529), SELFDESTRUCT refunds were removed entirely

My implementation correctly:
- Checks if account was created in same transaction
- Returns 0 refund for London+
- Prevents double-refunding

However, there are still unresolved issues causing the test failures. The balance mismatches suggest there may be additional refund-related bugs beyond SELFDESTRUCT (possibly SSTORE refunds or other gas accounting issues). The crashes on revert tests suggest there may be additional edge cases in the revert handling that need attention.

### Next Steps (for continued debugging):

1. Investigate the specific balance mismatch patterns to identify if they're related to SSTORE, SELFDESTRUCT, or other refund mechanisms
2. Debug the signal 6 crashes using binary search with `@panic` to find exact crash locations
3. Compare gas refund calculations step-by-step with the Python reference implementation for failing test cases