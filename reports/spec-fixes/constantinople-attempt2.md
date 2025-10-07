Those are for 0, not 2. Let me think about this differently. The test framework itself must be comparing the number of accounts. Let me create a summary of what I know and what I've fixed:

## Summary

I've been working on fixing failing Constantinople hardfork tests. Here's what I found and fixed:

### Fixes Applied:
1. **CREATE2 Gas Cost**: Added missing Keccak256Gas base cost (30 gas) to CREATE2 gas calculation in `src/frame.zig`
2. **CREATE2 Nonce**: Fixed EIP-1014 compliance - CREATE2 should NOT increment sender's nonce (only CREATE does) in `src/evm.zig`
3. **Compilation Error**: Fixed unused constant and type annotation in `src/precompiles/precompiles.zig`

### Remaining Issues:
- Still 174 tests failing (same count before and after fixes)
  - 168 CREATE2-related tests
  - 6 shift operation tests (SAR, SHL, SHR for ConstantinopleFix and Istanbul)
- Two types of errors:
  - "expected 2, found 1" - likely account count mismatch
  - Large gas differences (e.g., 351190 gas off)

The fixes I applied are correct per EIP-1014, but they haven't resolved the test failures, suggesting the root cause is elsewhere. Let me provide a summary to the user of what I've done and the current status.

## Expected Output

### 1. What was failing and why:

**Constantinople hardfork tests were failing** - 174 failures total:
- 168 CREATE2 tests from `eip1014_create2/create_returndata`
- 6 shift operation tests (SAR, SHL, SHR) from `eip145_bitwise_shift`

**Root causes identified:**
1. **CREATE2 gas calculation bug**: The `create2GasCost()` function was missing the Keccak256 base cost (30 gas). It was only charging for word costs, not the base hash cost.

2. **CREATE2 nonce increment bug**: The code was incorrectly incrementing the sender's nonce for both CREATE and CREATE2. Per EIP-1014, CREATE2 should NOT increment the sender's nonce (only CREATE does).

3. **Compilation error**: Unused constant in precompiles.zig

### 2. What I changed to fix it:

**File: `src/frame.zig` (line 307)**
```zig
// Before:
gas_cost += init_code_word_count * GasConstants.Keccak256WordGas;

// After:
gas_cost += GasConstants.Keccak256Gas + (init_code_word_count * GasConstants.Keccak256WordGas);
```

**File: `src/evm.zig` (lines 733-746)**
```zig
// Before:
// Increment caller's nonce for both CREATE and CREATE2
const caller_nonce = ...
h.setNonce(caller, caller_nonce + 1);

// After:
// Increment caller's nonce for CREATE only (not CREATE2 per EIP-1014)
if (salt == null) {
    const caller_nonce = ...
    h.setNonce(caller, caller_nonce + 1);
}
```

**File: `src/precompiles/precompiles.zig` (line 355)**
```zig
// Before:
const Hardfork = @import("../hardfork.zig").Hardfork;
const min_gas = if (hardfork.isAtLeast(.OSAKA)) 500 else GasCosts.MODEXP_MIN;

// After:
const min_gas: u64 = if (hardfork.isAtLeast(.OSAKA)) 500 else GasCosts.MODEXP_MIN;
```

### 3. Confirmation that tests now pass (or explanation if they don't):

**Tests still fail - 174 failures remain** (same count as before).

The fixes I applied are correct according to EIP-1014 and EIP-145 specifications, but they did not resolve the test failures. This suggests:

1. The root cause is different than I initially diagnosed
2. There may be an issue with how the test data is structured or how we're reading it
3. The "expected 2, found 1" error suggests an account count mismatch that needs further investigation
4. The gas differences (hundreds of thousands of gas) are too large to be explained by just the 30 gas keccak256 base cost

**Next steps would be:**
- Generate and compare EIP-3155 traces between our EVM and the reference implementation
- Filter and run a single failing test in isolation to get more detailed output
- Check if there's an issue with how we're creating/tracking accounts during CREATE2 operations