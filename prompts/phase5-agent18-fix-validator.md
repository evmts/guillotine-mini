# Agent 18: Fix Validator and Iterative Improvement

## Objective
After each fix is implemented, validate the fix by re-running tests and tracking progress toward 100% compliance.

## Scope
**Input**:
- Agent 17 fix roadmap
- Implemented fixes
**Output**:
- Validation results
- Progress tracking
- Next fix recommendation

## Iterative Process

This agent runs in a loop:
1. Fix is implemented
2. Agent validates fix
3. Re-runs affected tests
4. Reports progress
5. Recommends next fix

## Tasks

### 1. Pre-Fix Validation

**Before applying a fix**:
- [ ] Document current test results for affected tests
- [ ] Identify all tests that should improve
- [ ] Create baseline metrics

**Example**:
```markdown
## Pre-Fix Status: SSTORE Refund

**Affected tests**: 25
- stRefund/refund_sstore_clear.json ❌
- stRefund/refund_sstore_reset_zero.json ❌
[... list all 25]

**Current failures**:
- All 25 tests expect refund of 4800, getting 15000
- Root cause: Using old EIP-2200 refund value

**Expected improvement**: +25 tests
```

**Action**: Document baseline before each fix.

### 2. Fix Implementation Review

**After fix is implemented**:
- [ ] Review code changes
- [ ] Verify fix addresses root cause
- [ ] Check for unintended side effects
- [ ] Confirm follows spec

**Example**:
```zig
// BEFORE (wrong)
const SSTORE_CLEAR_REFUND = 15000;

// AFTER (correct)
const SSTORE_CLEAR_REFUND = 4800; // EIP-3529

// Validation:
// ✓ Value matches Prague spec
// ✓ Constant used in SSTORE refund calculation
// ✓ No other constants affected
```

**Action**: Code review each fix.

### 3. Targeted Test Execution

**Run only affected tests**:
```bash
# Run specific test category
zig build test -- --filter "stRefund"

# Run specific test file
zig build test -- --file "stRefund/refund_sstore_clear.json"
```

**Action**: Re-run affected tests.

### 4. Result Validation

**Compare before/after**:

```markdown
## Post-Fix Results: SSTORE Refund

**Tests run**: 25
**Before**: 0/25 passing (0%)
**After**: 25/25 passing (100%) ✅

**Fixed tests**:
- stRefund/refund_sstore_clear.json ✅
- stRefund/refund_sstore_reset_zero.json ✅
[... all 25]

**Regression check**:
- Ran full test suite: 1089 → 1114 passing
- No new failures detected ✅

**Status**: Fix successful ✅
```

**Action**: Validate improvement and check for regressions.

### 5. Regression Detection

**After each fix, run full suite**:
- [ ] Count total passing before
- [ ] Count total passing after
- [ ] Identify any new failures
- [ ] Investigate regressions

**If regressions occur**:
```markdown
## Regression Detected ⚠️

**Fix**: Implemented TLOAD/TSTORE
**Intended improvement**: +12 tests (stEIP1153)
**Actual improvement**: +12 tests
**Regressions**: -3 tests (stStackOps)

**New failures**:
- stStackOps/stack_limit.json
  - Cause: TLOAD/TSTORE don't check stack overflow
  - Fix: Add stack depth check

**Action**: Fix regression before proceeding
```

**Action**: Detect and address regressions.

### 6. Progress Tracking

**Maintain running stats**:

```markdown
## Overall Progress

**Start**: 1089/1234 (88.2%)

**Fixes applied**:
1. Gas constants: 1089 → 1114 (+25)
2. RETURNDATACOPY bounds: 1114 → 1119 (+5)
3. Transient storage: 1119 → 1131 (+12)
4. SELFDESTRUCT EIP-6780: 1131 → 1154 (+23)
5. SSTORE refund: 1154 → 1179 (+25)

**Current**: 1179/1234 (95.5%)
**Remaining**: 55 tests
**Improvement**: +90 tests (7.3%)

**Remaining failures by category**:
- stPrecompiledContracts: 30 (BLS12-381)
- stCreate: 10 (edge cases)
- stAccessList: 8 (pre-warming)
- stEdgeCases: 7 (misc)
```

**Action**: Track progress after each fix.

### 7. Fix Verification Checklist

**For each fix, verify**:

- [ ] **Correctness**: Behavior matches spec exactly
- [ ] **Completeness**: All related code updated
- [ ] **Tests**: Targeted tests passing
- [ ] **Regressions**: No new failures
- [ ] **Performance**: No significant slowdown
- [ ] **Code quality**: Clean, readable, commented

**Example checklist for SELFDESTRUCT fix**:
```markdown
## SELFDESTRUCT EIP-6780 Fix Verification

- [x] created_accounts set added to state
- [x] CREATE adds address to set
- [x] CREATE2 adds address to set
- [x] SELFDESTRUCT checks set
- [x] SELFDESTRUCT only deletes if in set
- [x] Balance always transferred
- [x] Set cleared between transactions
- [x] All 23 SELFDESTRUCT tests passing
- [x] No regressions in CREATE tests
- [x] Code reviewed and commented
```

**Action**: Complete checklist for each fix.

### 8. Next Fix Recommendation

**After validating a fix**:
- [ ] Update remaining test count
- [ ] Recalculate priorities
- [ ] Recommend next fix

**Example**:
```markdown
## Next Recommended Fix

**Current status**: 1179/1234 (95.5%)

**Top remaining issues**:
1. BLS12-381 precompiles: 30 tests (HARD, 2-3 days)
2. CREATE edge cases: 10 tests (MEDIUM, 4 hours)
3. Access list pre-warming: 8 tests (EASY, 2 hours)

**Recommendation**: Fix access list pre-warming next
- **Reason**: Quick win, high impact per hour
- **Effort**: 2 hours
- **Tests**: +8 (95.5% → 96.2%)
- **Confidence**: High (well-defined issue)

**After that**: CREATE edge cases
**Save for last**: BLS12-381 (requires library integration)
```

**Action**: Recommend next fix based on current state.

### 9. Blockers and Risks

**Track issues that block progress**:

```markdown
## Current Blockers

### BLS12-381 Library (30 tests blocked)
**Issue**: No Zig BLS12-381 library available

**Options**:
1. Write Zig implementation from scratch (1-2 weeks)
2. Bind to Rust blst library via C FFI (2-3 days)
3. Use reference implementation from guillotine-reference (2-3 days)

**Recommendation**: Option 3 - use reference implementation
**Risk**: Medium - need to integrate existing code
**Timeline**: 2-3 days

### Memory Expansion Edge Case (3 tests)
**Issue**: Unclear why tests fail
**Status**: Needs investigation
**Risk**: Low - rare edge case
**Priority**: After main features complete
```

**Action**: Track and plan for blockers.

### 10. Final Validation

**When all tests pass**:

```markdown
## Final Validation Report

**Test Results**: 1234/1234 (100%) ✅

**Validation steps**:
1. [x] Full test suite passing
2. [x] All EIPs implemented
3. [x] All opcodes correct
4. [x] All precompiles working
5. [x] Gas calculations correct
6. [x] Edge cases handled

**Fixes applied**: 15
**Total improvement**: +145 tests (11.8%)
**Time spent**: 6 days

**Final EIP compliance**:
- EIP-1153 (Transient Storage): 12/12 ✅
- EIP-2929 (Access Lists): 51/51 ✅
- EIP-2930 (Access List Tx): 18/18 ✅
- EIP-3529 (Refunds): 45/45 ✅
- EIP-3860 (Init Code): 15/15 ✅
- EIP-4844 (Blobs): 33/33 ✅
- EIP-6780 (SELFDESTRUCT): 23/23 ✅
- EIP-7702 (Set Code): 8/8 ✅

**Code quality**:
- All code reviewed
- All changes documented
- No technical debt
- Performance acceptable

**Status**: READY FOR PRODUCTION ✅
```

**Action**: Comprehensive final validation.

## Iteration Template

**For each fix iteration**:

```markdown
# Fix Iteration N: [Fix Name]

## Pre-Fix Status
- Tests affected: X
- Current passing: 0/X
- Root cause: [description]

## Fix Implementation
- Files changed: [list]
- Changes: [summary]
- Spec reference: [citation]

## Test Results
- Tests run: X
- Before: Y/X passing
- After: Z/X passing
- Improvement: +N tests

## Regression Check
- Full suite before: A/B
- Full suite after: C/B
- New failures: [list or "none"]

## Verification
- [x] Fix correct
- [x] Tests passing
- [x] No regressions
- [x] Code reviewed

## Next Steps
- Current total: C/B (Z%)
- Remaining: B-C tests
- Recommended next fix: [name]
```

## Output Format

```markdown
# Agent 18: Fix Validation Report - Iteration N

## Fix: [Name]
**Priority**: [CRITICAL/HIGH/MEDIUM/LOW]
**Effort estimate**: X hours
**Actual effort**: Y hours

## Results
**Tests affected**: X
**Improvement**: A/X → B/X (+N tests)
**Regressions**: [count or "none"]

## Overall Progress
**Total**: M/N (Z%)
**Change**: +N tests
**Remaining**: N-M tests

## Verification Status
- [x] Fix implemented correctly
- [x] Tests passing
- [x] No regressions
- [x] Code reviewed

## Next Recommended Fix
**Fix**: [name]
**Reason**: [why this one next]
**Estimated impact**: +N tests
**Estimated effort**: X hours

## Notes
[Any observations, issues, or recommendations]
```

## Notes
- Run after EACH fix
- Validate before moving to next fix
- Track regressions immediately
- Maintain momentum with quick wins
- Document all progress
- This is the final agent - iterate until 100%
