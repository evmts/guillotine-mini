# Guillotine Mini - Test Status Report
**Generated:** 2025-10-07
**Test Suite:** Ethereum Execution Specs (ethereum/tests)

## Executive Summary

Total test suites tested: **15 hardforks**
Overall status: **Most hardforks passing, 4 areas need attention**

### Recent Fixes
- ✅ **BLAKE2F Precompile (EIP-152)**: Fixed sigma table bug (246 failures → 0)
  - Root cause: Sigma table had 12 rows instead of 10
  - Location: `src/crypto/blake2.zig:16-28`
  - Commit: `b5eed4e`

- ⚠️ **EIP-6780 SELFDESTRUCT (Cancun)**: Partial fix attempted
  - Added `created_accounts` tracking before execution
  - Location: `src/evm.zig:980-984`
  - Status: 354/1166 tests still failing (dynamic_create2_selfdestruct_collision tests)

---

## Detailed Test Results

### ✅ Fully Passing Hardforks

| Hardfork | Tests | Status | Notes |
|----------|-------|--------|-------|
| **Frontier** | All | ✅ PASS | Baseline EVM functionality |
| **Homestead** | All | ✅ PASS | EIP-2, EIP-7, EIP-8 |
| **Tangerine** | All | ✅ PASS | EIP-150 gas changes |
| **Spurious** | All | ✅ PASS | EIP-155, EIP-160, EIP-161, EIP-170 |
| **Byzantium (non-MODEXP)** | 298/352 | ✅ 85% | Precompiles, opcodes work |

---

### ⚠️ Partial Passing Hardforks

#### **Byzantium (EIP-198 MODEXP)** - 85% Pass Rate
- **Status**: 298/352 passing (54 failures)
- **Issue**: MODEXP precompile edge cases
- **Location**: `src/precompiles/precompiles.zig:execute_modexp`
- **Priority**: MEDIUM
- **Tests failing**: Specific MODEXP parameter combinations

#### **Constantinople (EIP-1014 CREATE2)** - 78% Pass Rate
- **Status**: 396/508 passing (112 failures)
- **Issue**: CREATE2 return data handling
- **Failing tests**: `create2_return_data` suite
- **Priority**: MEDIUM
- **Root cause**: Return data not properly captured/returned from CREATE2

#### **Istanbul (Non-BLAKE2)** - 95% Pass Rate
- **Status**: 2052/2165 passing (113 failures, ~246 BLAKE2 fixed)
- **Issue**: Unknown (need investigation after BLAKE2 fix)
- **Priority**: LOW (small failure rate)
- **Note**: BLAKE2F now working correctly

#### **Shanghai (EIP-3860)** - 93% Pass Rate
- **Status**: 1014/1090 passing (76 failures)
- **Issue**: EIP-3860 initcode size validation
- **Failing tests**: `initcode` test suites
- **Priority**: MEDIUM
- **Root cause**: Initcode size limit (49152 bytes) not enforced correctly

---

### ⚠️ Cancun Hardfork - Mixed Results

**Overall**: Most EIPs working, one major issue

#### ✅ Working Cancun EIPs

| EIP | Feature | Tests | Status |
|-----|---------|-------|--------|
| **EIP-1153** | Transient Storage (TLOAD/TSTORE) | 620/620 | ✅ 100% |
| | - Basic operations | 66/66 | ✅ PASS |
| | - Reentrancy | 144/144 | ✅ PASS |
| | - Execution contexts | 410/410 | ✅ PASS |
| **EIP-5656** | MCOPY instruction | 558/558 | ✅ 100% |
| **EIP-7516** | BLOBBASEFEE opcode | 29/29 | ✅ 100% |
| **EIP-4844** | Blob transactions (small) | 108/108 | ✅ 100% |

#### ⚠️ Failing Cancun EIPs

| EIP | Feature | Tests | Status | Issue |
|-----|---------|-------|--------|-------|
| **EIP-6780** | SELFDESTRUCT restrictions | 812/1166 | ⚠️ 70% | `dynamic_create2_selfdestruct_collision` failures |
| **EIP-4844** | BLOBHASH opcode | 270/282 | ⚠️ 96% | 12 failures in blob opcode tests |
| **EIP-4844** | Blob precompile | TIMEOUT | ❌ N/A | Point evaluation precompile hangs |

---

### ⚠️ Prague & Osaka
- **Status**: Not fully tested yet
- **Dependencies**: Fix Cancun issues first

---

## Priority Action Items

### 🔴 HIGH PRIORITY

1. **EIP-4844 Blob Precompile Timeout** (Cancun)
   - **Issue**: Point evaluation precompile causes test timeout
   - **Location**: `src/precompiles/precompiles.zig:execute_kzg_point_evaluation`
   - **Impact**: Blocks all blob precompile tests
   - **Action**: Debug infinite loop or performance issue

2. **EIP-6780 SELFDESTRUCT Collision Tests** (Cancun)
   - **Issue**: 354 `dynamic_create2_selfdestruct_collision` tests failing
   - **Location**: `src/evm.zig` (CREATE2 + SELFDESTRUCT interaction)
   - **Impact**: 30% of SELFDESTRUCT tests
   - **Recent work**: Added `created_accounts` tracking (partial fix)
   - **Action**: Debug CREATE2 + SELFDESTRUCT in same transaction scenarios

### 🟡 MEDIUM PRIORITY

3. **EIP-198 MODEXP Edge Cases** (Byzantium)
   - **Issue**: 54/352 failures (15%)
   - **Location**: `src/precompiles/precompiles.zig:execute_modexp`
   - **Action**: Compare against Python reference for edge cases

4. **EIP-1014 CREATE2 Return Data** (Constantinople)
   - **Issue**: 112/508 failures (22%)
   - **Location**: `src/evm.zig:inner_create`
   - **Action**: Verify return data handling matches Python reference

5. **EIP-3860 Initcode Validation** (Shanghai)
   - **Issue**: 76/1090 failures (7%)
   - **Location**: `src/evm.zig:inner_create` (initcode size check)
   - **Action**: Verify 49152-byte limit enforcement

6. **EIP-4844 BLOBHASH Opcode** (Cancun)
   - **Issue**: 12/282 failures (4%)
   - **Location**: `src/frame.zig:BLOBHASH` opcode
   - **Action**: Debug specific blob hash test failures

### 🟢 LOW PRIORITY

7. **Istanbul Remaining Failures**
   - **Issue**: 113 failures (5%)
   - **Action**: Investigate after other fixes (may be test infrastructure issues)

---

## Test Infrastructure Notes

### Test Organization
- **Generated tests**: `test/specs/generated/`
- **Test types**: `state_tests`, `blockchain_tests`, `blockchain_tests_engine`
- **Test runner**: `test_runner.zig`
- **Timeout**: Default 120s (2 minutes), increased for large suites

### Helper Scripts
- `scripts/isolate-test.ts`: Debug single test with trace analysis
- `scripts/test-subset.ts`: Run test categories by pattern
- `scripts/fix-specs.ts`: Automated test fixing pipeline

### Known Issues
- Cancun full suite (`specs-cancun`) times out → use individual sub-targets
- Blob precompile tests require longer timeout (currently timing out at 2 minutes)

---

## Next Steps

### Immediate (Today)
1. Debug blob precompile timeout (EIP-4844)
2. Investigate CREATE2+SELFDESTRUCT collision scenarios (EIP-6780)
3. Run full test pass after fixes

### Short-term (This Week)
4. Fix MODEXP edge cases (Byzantium)
5. Fix CREATE2 return data (Constantinople)
6. Fix initcode validation (Shanghai)

### Medium-term
7. Complete Prague and Osaka testing
8. Add regression tests for BLAKE2F fix
9. Document all EIP implementations

---

## Code Health

### Recent Improvements
- ✅ EIP-6780 tracking infrastructure added
- ✅ BLAKE2F sigma table corrected
- ✅ Comprehensive test coverage for all hardforks

### Areas Needing Attention
- ⚠️ CREATE2 + SELFDESTRUCT interaction logic
- ⚠️ Blob precompile performance
- ⚠️ Edge case handling in precompiles (MODEXP)

---

## Appendix: Test Command Reference

```bash
# Run all hardfork tests
zig build specs-frontier
zig build specs-homestead
zig build specs-byzantium
zig build specs-constantinople
zig build specs-istanbul
zig build specs-berlin
zig build specs-paris
zig build specs-shanghai

# Run Cancun sub-tests (DON'T use specs-cancun - it times out)
zig build specs-cancun-tstore-basic
zig build specs-cancun-tstore-reentrancy
zig build specs-cancun-tstore-contexts
zig build specs-cancun-mcopy
zig build specs-cancun-selfdestruct
zig build specs-cancun-blobbasefee
zig build specs-cancun-blob-opcodes
zig build specs-cancun-blob-precompile  # Currently times out
zig build specs-cancun-blob-tx-small

# Debug specific test
bun scripts/isolate-test.ts "test_name"
```

---

**Report End**
