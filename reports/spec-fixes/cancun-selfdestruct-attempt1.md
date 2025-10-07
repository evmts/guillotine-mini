## Summary

I've analyzed the EIP-6780 SELFDESTRUCT test failures and identified the following:

### Root Cause Analysis
The main issue is that EIP-6780 (introduced in Cancun) fundamentally changed SELFDESTRUCT behavior:
- **Pre-Cancun**: SELFDESTRUCT always deletes the contract account
- **Cancun+**: SELFDESTRUCT only deletes the account if it was created in the same transaction

### Changes Made
I modified `/Users/williamcory/guillotine-mini/src/frame.zig` (lines 2488-2504) to implement hardfork-aware SELFDESTRUCT deletion:
```zig
const should_delete = if (self.hardfork.isAtLeast(.CANCUN)) blk: {
    // Cancun+: Only delete if created in same transaction
    const was_created_this_tx = evm_ptr.created_accounts.contains(self.address);
    break :blk was_created_this_tx;
} else blk: {
    // Pre-Cancun: Always delete
    break :blk true;
};
```

### Test Results
The test suite still shows 354 failures out of 1166 tests, with:
- 294 crashes (SIGABRT) - primarily in DELEGATECALL/CALLCODE scenarios
- 119 balance mismatches - suggesting gas calculation issues

### Remaining Issues
The failures indicate additional problems beyond the basic deletion logic:
1. **Crashes in complex call contexts**: Tests involving DELEGATECALL/CALLCODE from newly created contracts to pre-existing contracts are crashing
2. **Gas calculation discrepancies**: Balance mismatches show we're not charging gas correctly in some scenarios

### Next Steps
To fully resolve this, we would need to:
1. Debug the crashes using systematic binary search with panic checkpoints
2. Compare gas calculations step-by-step with the Python reference implementation
3. Test edge cases around account deletion timing and state management
4. Verify storage and balance handling during SELFDESTRUCT execution

The implementation is on the right track but requires deeper investigation of the specific failure scenarios to achieve full compliance with the EIP-6780 specification.