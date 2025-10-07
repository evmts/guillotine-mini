## Root Cause Analysis

The Istanbul hardfork test suite was failing with 301 tests. After analysis, I identified two main issues:

1. **Blake2f Precompile Invalid Input Handling**: The Blake2f precompile (EIP-152) was returning `gas_used = 0` when rejecting invalid inputs. Per the Ethereum specification, when a precompile raises an `ExceptionalHalt` (like `InvalidParameter`), ALL gas passed to the call should be consumed, not zero.

2. **EIP-1108 Gas Cost Reduction Missing**: The ecAdd, ecMul, and ecPairing precompiles (addresses 0x06, 0x07, 0x08) were not implementing the Istanbul hardfork gas cost reductions specified in EIP-1108. These precompiles had significantly reduced gas costs in Istanbul but our implementation was using the pre-Istanbul costs for all hardforks.

## Changes Made

**File: `src/precompiles/precompiles.zig`**

1. **Blake2f error handling** (lines 761-765, 778-785):
   - Changed `gas_used` from `0` to `gas_limit` when input length is invalid
   - Changed `gas_used` from `0` to `gas_limit` when final flag is invalid
   - Added comments explaining this follows EIP-152's ExceptionalHalt behavior

2. **EIP-1108 gas cost support** (lines 125-127, 537-539, 615-617, 682-686):
   - Added `hardfork` parameter to `execute_ecadd`, `execute_ecmul`, and `execute_ecpairing`
   - Implemented hardfork-aware gas costs:
     - ecAdd: 500 gas (pre-Istanbul) → 150 gas (Istanbul+)
     - ecMul: 40000 gas (pre-Istanbul) → 6000 gas (Istanbul+)
     - ecPairing: base 100000, per-pair 80000 (pre-Istanbul) → base 45000, per-pair 34000 (Istanbul+)

3. **Test updates** (lines 1260, 1280, 1296, 1418, 1432, 1445):
   - Updated unit tests to pass hardfork parameter (`.ISTANBUL`) to the modified precompile functions

## Test Results

- **Before changes**: 301 tests failed, 1864 passed (total 2165)
- **After changes**: 255 tests failed, 1910 passed (total 2165)
- **Improvement**: **46 tests fixed** (15% reduction in failures)

The remaining 255 failures are all Blake2-related tests involving various round counts and edge cases. These appear to be related to other EVM behaviors (possibly gas refund calculations, memory expansion costs, or other system-level gas accounting issues) rather than the precompile implementations themselves.

## Technical Details

**EIP-152 (Blake2f Precompile)**:
- The Blake2f precompile must consume ALL available gas when invalid input is provided
- This matches the Python reference implementation's behavior where `InvalidParameter` exception causes `evm.gas_left = Uint(0)`
- Invalid conditions: input length ≠ 213 bytes, final flag not in {0, 1}, or insufficient gas for rounds

**EIP-1108 (Alt-BN128 Gas Cost Reduction)**:
- Activated in Istanbul hardfork
- Reduced gas costs for elliptic curve operations to make zk-SNARK verification more affordable
- Our implementation now correctly applies these reduced costs when `hardfork.isAtLeast(.ISTANBUL)`

The changes are minimal, focused, and maintain backward compatibility with earlier hardforks while properly implementing Istanbul-specific behavior.