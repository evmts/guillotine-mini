Interesting observation: The "Slowest Tests" section shows that blockchain_tests for CREATE2 are PASSING (✓) but the corresponding state_tests are FAILING (✖). This is a crucial clue!

The difference between blockchain_tests and state_tests is:
- **blockchain_tests**: Full blockchain simulation with blocks
- **state_tests**: Individual transactions with state transitions

This suggests the issue might be in how we handle state transitions or account state management, not in the core opcode logic itself.

## Summary

Let me provide a summary of what I found and fixed:

### What Was Failing

1. **174 tests failing** out of 508 total (65.7% passing)
2. Main categories of failures:
   - CREATE2 return data tests (most failures)
   - EIP-145 bitwise shift tests (6 failures, only for ConstantinopleFix and Istanbul forks in state_tests)

### What I Fixed

1. **CREATE/CREATE2 return_data handling**: Fixed a bug where return_data was being set to the child's output for both success and failure cases. According to EIP-1014 and the Python reference implementation:
   - On success: `return_data` should be empty (`&[_]u8{}`)
   - On failure: `return_data` should be the child's output

   This fix was applied to both CREATE (opcode 0xF0) and CREATE2 (opcode 0xF5).

### Analysis of Remaining Issues

1. **Balance/Gas discrepancies**: The failing tests show balance mismatches (e.g., expected 999999999999999391070, found 999999999999998874740), suggesting we're consuming too much gas (~516,330 gas difference in some cases). The exact cause remains unclear, but it's likely related to:
   - State transition handling
   - Account state management (since blockchain_tests pass but state_tests fail)
   - Possible issues with how we track gas refunds or state reverts

2. **EIP-145 shift operations**: The shift operations (SHL, SHR, SAR) appear to be implemented correctly based on:
   - Comparison with Python reference implementation
   - Verification against EIP-145 specification
   - Blockchain tests passing (36/36 tests)
   - Only state_tests failing for specific forks

   The failures are likely not due to the shift logic itself, but possibly due to state management issues similar to the CREATE2 tests.

### Conclusion

The core CREATE/CREATE2 return_data bug has been fixed, which aligns the implementation with the Ethereum specification. However, 174 tests are still failing, primarily due to gas/balance discrepancies that suggest issues with state management in the test framework or EVM implementation. The fact that blockchain_tests pass while state_tests fail points to a systematic issue with how state transitions are handled, rather than fundamental opcode implementation bugs.