# Agent 16: Test Runner Setup and Fixes

## Objective
Fix and configure the test runner to successfully execute Ethereum official tests, ensuring all test infrastructure is working correctly.

## Scope
**Files to examine and fix**:
- Zig: `test/specs/runner.zig` (main test runner)
- Zig: `test/` directory structure
- JSON: Test vector files from ethereum/tests

## Current Status

The test runner needs updates to:
1. Parse the `fill` JSON output format (new format for test vectors)
2. Correctly load test fixtures
3. Report results in usable format

## Tasks

### 1. Test Vector Format

**Check current test file format**:
- [ ] Determine if tests use `fill` format (new) or legacy format
- [ ] Locate test vector files
- [ ] Understand JSON structure

**Fill format structure** (from ethereum/execution-spec-tests):
```json
{
  "test_name": {
    "_info": {
      "description": "...",
      "filling-transition-tool": "...",
    },
    "pre": {
      "address1": {
        "balance": "0x...",
        "code": "0x...",
        "nonce": "0x...",
        "storage": {...}
      }
    },
    "blocks": [
      {
        "transactions": [...],
        "expectedWithdrawals": [...],
      }
    ],
    "post": {
      "address1": {
        "balance": "0x...",
        "code": "0x...",
        "nonce": "0x...",
        "storage": {...}
      }
    },
    "lastblockhash": "0x..."
  }
}
```

**Action**: Update runner.zig to parse this format.

### 2. Test Runner Architecture

**Components needed**:
```zig
// Test state setup
fn setupState(pre: PreState) !State {
    // Create accounts
    // Set balances, nonces, code, storage
}

// Execute test
fn executeTest(test: TestCase) !TestResult {
    // 1. Setup pre-state
    // 2. Apply transactions
    // 3. Compare post-state
    // 4. Verify block hash
}

// Result reporting
fn reportResult(name: string, result: TestResult) void {
    // Print pass/fail
    // Show differences if failed
}
```

**Action**: Implement or fix these components.

### 3. State Setup

**Pre-state initialization**:
- [ ] Create accounts from `pre` field
- [ ] Set balance for each account
- [ ] Set nonce for each account
- [ ] Deploy code for contract accounts
- [ ] Initialize storage for each account

**Example**:
```zig
fn setupAccount(state: *State, address: Address, account: TestAccount) !void {
    try state.setBalance(address, account.balance);
    try state.setNonce(address, account.nonce);
    if (account.code.len > 0) {
        try state.setCode(address, account.code);
    }
    for (account.storage) |slot, value| {
        try state.setStorage(address, slot, value);
    }
}
```

**Action**: Verify state setup handles all fields.

### 4. Transaction Execution

**For each transaction in test**:
- [ ] Parse transaction (type, fields)
- [ ] Execute via EVM
- [ ] Collect receipts
- [ ] Update state

**Example**:
```zig
fn executeTransaction(env: *Environment, tx: Transaction) !Receipt {
    // This should use your EVM implementation
    return try evm.processTransaction(env, tx);
}
```

**Action**: Connect test runner to actual EVM.

### 5. Post-State Verification

**After executing all transactions**:
- [ ] Compare each account's balance
- [ ] Compare each account's nonce
- [ ] Compare each account's code
- [ ] Compare each account's storage
- [ ] Verify block hash matches expected

**Example**:
```zig
fn verifyPostState(state: State, expected: PostState) !bool {
    for (expected.accounts) |address, expected_account| {
        const actual_balance = state.getBalance(address);
        if (actual_balance != expected_account.balance) {
            std.debug.print("Balance mismatch at {}: expected {}, got {}\n",
                .{address, expected_account.balance, actual_balance});
            return false;
        }
        // ... check nonce, code, storage
    }
    return true;
}
```

**Action**: Implement comprehensive state comparison.

### 6. Test Discovery

**Locate and load tests**:
- [ ] Find all JSON test files in test directory
- [ ] Filter by hardfork (Prague)
- [ ] Filter by test category (optional)
- [ ] Load JSON and parse

**Example**:
```zig
fn discoverTests(allocator: Allocator, path: []const u8) ![]TestFile {
    var tests = ArrayList(TestFile).init(allocator);

    // Recursively find .json files
    // Filter for Prague tests
    // Load and parse

    return tests.toOwnedSlice();
}
```

**Action**: Implement test discovery.

### 7. Test Categories

**Ethereum tests are organized by category**:
- GeneralStateTests - Basic execution tests
- stArgsZeroOneBalance - Edge cases
- stAttackTest - Attack scenarios
- stBugs - Regression tests
- stCallCodes - CALL family tests
- stCreate - CREATE tests
- stEIP1153 - Transient storage tests
- stEIP2930 - Access list tests
- stEIP4844 - Blob transaction tests
- stPrecompiledContracts - Precompile tests
- stSelfBalance - SELFBALANCE tests
- stStaticCall - STATICCALL tests
- stSystemOperations - System opcode tests
- ... many more

**Action**: Decide which categories to run first (suggest starting with basic GeneralStateTests).

### 8. Build Integration

**Update build system**:
- [ ] Ensure test runner compiles: `zig build test`
- [ ] Test runner finds test vectors
- [ ] Can run all tests or filtered subset
- [ ] Reports results

**Example build.zig**:
```zig
const test_step = b.step("test", "Run the test suite");
const tests = b.addTest(.{
    .root_source_file = .{ .path = "test/specs/runner.zig" },
    .target = target,
    .optimize = optimize,
});
test_step.dependOn(&tests.step);
```

**Action**: Verify build configuration.

### 9. Error Handling

**Test runner should handle**:
- [ ] Malformed JSON
- [ ] Missing test fields
- [ ] EVM execution errors
- [ ] State comparison errors
- [ ] Timeouts

**Action**: Add robust error handling.

### 10. Output Format

**Reporting**:
```
Running Prague tests...

[PASS] GeneralStateTests/add.json::test_add_overflow
[PASS] GeneralStateTests/sub.json::test_sub_underflow
[FAIL] GeneralStateTests/mul.json::test_mul_overflow
  Expected balance: 0x1234567890abcdef
  Actual balance:   0x1234567890abcdee
  Difference:       -1

Summary:
  Total: 1234
  Passed: 1100
  Failed: 134
  Success rate: 89.14%

Failed tests by category:
  stPrecompiledContracts: 45 (BLS12-381 missing)
  stCreate: 23
  stSystemOperations: 15
  ...
```

**Action**: Implement clear output format.

## Expected Issues

Based on audit findings, expect test failures in:

1. **Precompiles** - BLS12-381 likely missing (8 operations)
2. **Transient storage** - May not be implemented
3. **SELFDESTRUCT** - Likely using old behavior (EIP-6780)
4. **CREATE** - May have edge case bugs
5. **SSTORE** - Complex refund logic may have bugs

## Deliverables

After fixing test runner, should be able to:
- [x] Run: `zig build test`
- [x] Execute all Prague tests
- [x] Get clear pass/fail results
- [x] See specific failure details
- [x] Identify high-priority bugs

## Output Format

```markdown
# Agent 16: Test Runner Setup Report

## Summary
- Test runner status: [WORKING / PARTIALLY WORKING / BROKEN]
- Total tests discovered: X
- Tests executed: Y
- Build status: [SUCCESS / FAILED]

## Fixes Applied

### 1. [Component]
**Issue**: [What was broken]
**Fix**: [What was changed]
**File**: path:line

## Test Execution Results

**Sample run**:
```
[Output from test run]
```

**Summary**:
- Total: X
- Passed: Y
- Failed: Z
- Success rate: N%

## Known Issues
[List of issues that prevent full test execution]

## Next Steps
1. [What to fix next]
2. [Priority order]

## Files Modified
- test/specs/runner.zig:lines
- [other files]
```

## Notes
- Focus on getting tests running, not passing
- Document all failures systematically
- This feeds into Agent 17 (Test Result Analyzer)
- Use official ethereum/execution-spec-tests repository for test vectors
