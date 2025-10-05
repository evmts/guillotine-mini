# Automated Test Fix Pipeline

This document describes the automated test fixing infrastructure for Guillotine EVM.

## Overview

The test fix pipeline automatically debugs and fixes failing EVM tests using AI agents in isolated Git worktrees. Each test gets its own branch and worktree, where an agent iteratively fixes the issue until the test passes, then the fix is cherry-picked back to main.

## Test Results Summary

**Current Status** (from latest run):
- **Total Tests**: 9,703
- **Passed**: 5,846 (60.2%)
- **Failed**: 3,857 (39.8%)
- **Duration**: ~16.6 minutes

## Architecture

### Key Components

1. **Test Runner** (`test_runner.zig`)
   - Supports test filtering via `TEST_FILTER` environment variable
   - Runs tests in isolated processes with 60-second timeout
   - Process isolation prevents crashes from stopping entire suite

2. **Fix Pipeline** (`scripts/fix-tests.ts`)
   - Manages pool of 8 concurrent AI agents
   - Each agent works in isolated Git worktree
   - Automatic retry with up to 10 attempts per test
   - Independent verification before accepting fixes
   - Automatic cherry-pick to main branch

### Pipeline Flow

```
┌─────────────────┐
│  Load Failed    │
│  Tests List     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Create Pool    │
│  (8 concurrent) │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  For Each Test (in parallel):          │
│                                         │
│  1. Create Git worktree + branch       │
│  2. Run agent to debug & fix (retry    │
│     up to 10x)                         │
│  3. Verify test passes independently   │
│  4. Get commit SHA                      │
│  5. Cleanup worktree                    │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────┐
│  Cherry-pick    │
│  All Fixes to   │
│  Main Branch    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Generate       │
│  Report         │
└─────────────────┘
```

## Usage

### 1. Run Full Test Suite

```bash
zig build specs 2>&1 | tee test_results.log
```

### 2. Extract Failed Tests

```bash
grep 'FAIL.*›' test_results.log | \
  sed -E 's/.*› //; s/\x1b\[[0-9;]*m//g' | \
  sort -u > failed_tests.txt
```

### 3. Run Automated Fixes

```bash
# Using the convenience script
./scripts/fix-tests.sh

# Or directly
cd scripts
bun fix-tests.ts ../failed_tests.txt
```

### 4. Test Individual Test (with filter)

```bash
# Run a specific test
TEST_FILTER="stEIP1153" zig build specs

# Or run a single test by full name
TEST_FILTER="GeneralStateTests_Cancun_stEIP1153_transientStorage" zig build specs
```

## Configuration

Edit `scripts/fix-tests.ts` to adjust:

```typescript
const MAX_CONCURRENT = 8;    // Number of parallel agents
const MAX_RETRIES = 10;      // Max retry attempts per test
```

## Agent Behavior

Each fixing agent:

1. **Runs the test** with `TEST_FILTER` to see the failure
2. **Analyzes the output**:
   - Expected vs actual behavior
   - Root cause (opcodes, gas, state changes)
   - Error messages and stack traces
3. **Fixes the implementation**:
   - Minimal, targeted changes in `src/`
   - Considers edge cases
   - Avoids breaking other tests
4. **Verifies the fix** by re-running the test
5. **Commits** when test passes

### Example Agent Prompt

```
You are debugging a failing EVM test in the Guillotine EVM implementation.

**Failing Test**: <test-name>

**Your Task**:
1. First, run the test to see the failure:
   TEST_FILTER="<test-name>" zig build specs

2. Analyze the failure output...
3. Fix the implementation in src/...
4. Verify your fix...
5. Commit your changes...
```

## Verification Process

The pipeline performs **independent verification**:

```typescript
// After agent claims success, pipeline independently runs:
const testPasses = await verifyTestPasses(worktreePath, testName);

// Test must actually pass or retry
if (!testPasses) {
  console.log('❌ Test still FAILING');
  // Retry up to MAX_RETRIES
}
```

This prevents false positives from agents that claim success without actually fixing the test.

## Output and Reports

### Console Output

```
████████████████████████████████████████████████████████████████████████████████
🎯 AUTOMATED TEST FIX PIPELINE
████████████████████████████████████████████████████████████████████████████████
Total Failed Tests: 3854
Max Concurrent Agents: 8
Max Retries per Test: 10
████████████████████████████████████████████████████████████████████████████████

================================================================================
🔧 Fixing: generated.ethereum_tests...
📁 Worktree: worktrees/generated_ethereum_tests...
🌿 Branch: fix/generated_ethereum_tests...
================================================================================

🔄 Attempt 1/10
[Agent output...]
✅ Agent completed (Cost: $0.1234)

🧪 Independently verifying test passes...
✅ Test verified as PASSING!

📊 Progress: 1 fixed | 0 failed | 3853 remaining
```

### Generated Reports

1. **`fix-reports/test-fix-summary.md`** - High-level summary
   - Success rate
   - Cost breakdown
   - Average attempts
   - Fixed/failed test lists

2. **`fix-reports/test-fix-details.json`** - Detailed task data
   - Per-test status
   - Attempt counts
   - Cost per test
   - Error messages
   - Commit SHAs

## Cost Estimation

Based on typical agent behavior:

- **Average cost per test**: ~$0.10 - $0.30
- **Average attempts**: 1-3 for simple fixes
- **For 3,854 tests**: ~$400 - $1,200 total
  - Most tests will fix on first attempt
  - Some complex tests may hit max retries
  - Failed tests still incur cost

## Worktree Management

### Worktree Creation

```bash
git worktree add -b "fix/<test-name>" "worktrees/<test-name>" HEAD
```

### Automatic Cleanup

After each test (success or failure):
```bash
git worktree remove "worktrees/<test-name>" --force
git branch -D "fix/<test-name>"
```

### Manual Cleanup (if needed)

```bash
# List all worktrees
git worktree list

# Remove specific worktree
git worktree remove worktrees/<name> --force

# Prune stale worktrees
git worktree prune
```

## Cherry-Pick Process

After all tests are fixed:

```typescript
// For each successful fix:
git cherry-pick <commit-sha>
```

If cherry-pick fails:
- Conflict resolution required
- Review the fix manually
- May need to adjust for changes in main

## Best Practices

### Running the Pipeline

1. **Start with a small batch** to test the system:
   ```bash
   head -10 failed_tests.txt > failed_tests_sample.txt
   bun scripts/fix-tests.ts failed_tests_sample.txt
   ```

2. **Monitor first few fixes** to ensure agents are working correctly

3. **Run full suite** after cherry-picking to catch regressions

4. **Review cherry-pick conflicts** manually if they occur

### Cost Management

- Start with small batches
- Monitor cost in real-time from console output
- Adjust MAX_RETRIES if costs are too high
- Consider pausing if cost exceeds budget

### Debugging Failed Fixes

If a test fails after MAX_RETRIES:

1. Check the error in `fix-reports/test-fix-details.json`
2. Run the test manually:
   ```bash
   TEST_FILTER="<test-name>" zig build specs
   ```
3. Review if it needs architectural changes
4. Consider manual debugging

## Troubleshooting

### "Test still failing after verification"

Agent may have committed without actually running the test. The independent verification catches this. The pipeline will retry.

### "Cherry-pick conflicts"

```bash
# Manually resolve
git status
# Edit conflicted files
git add <files>
git cherry-pick --continue
```

### "Worktree already exists"

```bash
# Clean up manually
git worktree remove worktrees/<name> --force
git branch -D fix/<name>
```

### "Out of disk space"

The pipeline creates many worktrees. Each is ~50MB. Monitor disk space:

```bash
du -sh worktrees/
```

## Future Improvements

- [ ] Parallel cherry-picking with conflict detection
- [ ] Resume capability (save progress, restart from failure)
- [ ] Cost budget limits with auto-pause
- [ ] Test clustering (group similar failures)
- [ ] Smarter retry strategies (exponential backoff, different prompts)
- [ ] Post-fix validation (run related tests to catch regressions)

## See Also

- `test_runner.zig` - Test runner with filtering support
- `scripts/index.ts` - Audit pipeline (similar pattern)
- `build.zig` - Build configuration
- `failed_tests.txt` - Generated list of failing tests
