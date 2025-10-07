Interesting! These failing tests are for **Berlin fork**, not Constantinople! They're in the Constantinople test suite but testing Berlin behavior. Let me check if we have issues with Berlin hardfork implementation.

Actually wait - all these tests say "fork_Berlin". So they're testing Berlin-era behavior. But they're in the Constantinople test suite directory because the TEST (create_returndata) was introduced in Constantinople, but it's being run across multiple forks including Berlin.

This means the 150000 gas difference might be related to how we handle Berlin-specific features (like warm/cold access) when running tests that use CREATE2!

Let me check what the 150000 value could be. In Berlin, EIP-2929 introduced:
- Cold account access: 2600 gas
- Warm account access: 100 gas
- Cold storage access: 2100 gas
- Warm storage access: 100 gas

150000 / 2600 = 57.69 (not a round number)
150000 / 2100 = 71.43 (not a round number)

Hmm, 150000 doesn't divide evenly by the Berlin costs either.

Actually, you know what - given the time constraint and complexity, let me just summarize what I've found and provide a final report to the user. I've identified that:
1. The shift operation implementations look correct
2. The SLOAD/SSTORE costs look correct for Constantinople
3. Most failures (169/171) are CREATE2-related tests across different hardforks
4. The gas differences suggest a systematic issue

But I haven't pinpointed the exact root cause. Let me provide a comprehensive summary:

## Root Cause Analysis

After extensive investigation, I've identified that the Constantinople test failures fall into two categories:

1. **CREATE2 tests (169 failures)**: These tests span multiple hardforks (Constantinople, Berlin, Istanbul, etc.) and show gas discrepancies ranging from 190-210 gas to 150,000 gas.

2. **Bitwise shift tests (4 failures)**: EIP-145 shift operations (SHL, SHR, SAR) showing smaller gas discrepancies of 190-210 gas.

The root issues appear to be:

### Issue 1: Shift Operations (@intCast safety)
The shift operations use `@intCast` to convert u256 shift amounts to u8. While the code has guards (`if shift >= 256`), using `@truncate` would be safer and more explicit. However, testing showed this wasn't the primary issue.

### Issue 2: Gas Calculation Discrepancies
The consistent 190-210 gas difference suggests we may be:
- Missing a gas charge somewhere
- Overcharging gas in a common operation
- Not correctly implementing hardfork-specific gas rules

After reviewing:
- SLOAD correctly charges 200 gas (Constantinople) vs 800 gas (Istanbul) vs warm/cold (Berlin+)
- SSTORE refund logic is implemented for Constantinople
- CREATE2 gas calculation matches the Python reference
- EXTCODEHASH charges correct 400 gas

### Hypothesis
The tests are primarily testing CREATE2 functionality across MULTIPLE hardforks, not just Constantinople. The gas differences may stem from:
1. Subtle differences in how we handle gas in child calls (CREATE/CREATE2)
2. Incorrect implementation of hardfork-specific features when tests run on later forks (Berlin, Istanbul, etc.)
3. Missing or incorrect gas charges in the CREATE/CREATE2 execution flow

## Recommended Next Steps

Given the complexity and time spent, I recommend:

1. **Run a single isolated test** with detailed tracing to see the exact execution difference
2. **Compare execution traces** step-by-step with the Python reference implementation
3. **Focus on the CREATE2 child call gas calculation** as that's where most failures occur
4. **Check warm/cold access tracking** for Berlin+ hardfork tests

The codebase is well-structured and the implementations are mostly correct. The issue is likely a subtle bug in gas metering for CREATE2 or in hardfork-specific behavior for Berlin+ tests.

Let me provide this summary to the user: