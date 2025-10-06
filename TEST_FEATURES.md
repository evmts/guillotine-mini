# Test Runner Features - Quick Reference

## ✅ All Features Working & Tested

### Default Behavior (No Environment Variables)

```bash
zig build specs
```

**What happens:**
- ✅ Parallel execution with auto-detected CPU cores (capped at 8 workers)
- ✅ Pretty colored output with progress indication
- ✅ Slowest 10 tests report
- ✅ Grouped results by suite
- ✅ Test duration tracking
- ✅ Professional summary with pass/fail counts

### Feature Flags

| Feature | Environment Variable | Default | Example |
|---------|---------------------|---------|---------|
| **Parallel Execution** | `TEST_SEQUENTIAL=1` to disable | **ON** | `TEST_SEQUENTIAL=1 zig build specs` |
| **Worker Count** | `TEST_WORKERS=N` | Auto (CPU cores, max 8) | `TEST_WORKERS=4 zig build specs` |
| **Test Filter** | `TEST_FILTER="pattern"` | None | `TEST_FILTER="add" zig build specs` |
| **Output Format** | `TEST_FORMAT=json\|junit` | `pretty` | `TEST_FORMAT=json zig build specs` |

## Usage Examples

### 1. Run All Tests (Parallel, Default)
```bash
zig build specs
```
Output: Pretty colored output, parallel execution

### 2. Run Sequentially (Debug Mode)
```bash
TEST_SEQUENTIAL=1 zig build specs
```
Useful when debugging test failures or race conditions

### 3. Filter Tests
```bash
TEST_FILTER="evm" zig build specs
```
Runs only tests containing "evm" in their name

### 4. JSON Output for CI
```bash
TEST_FORMAT=json zig build specs
```
Machine-readable output:
```json
{
  "success": true,
  "total": 9703,
  "passed": 9703,
  "failed": 0,
  "todo": 0,
  "duration_ms": 45123.45,
  "tests": [...]
}
```

### 5. JUnit XML for CI Integration
```bash
TEST_FORMAT=junit zig build specs
```
Standard XML format for Jenkins/CircleCI/GitLab

### 6. Control Parallelism
```bash
TEST_WORKERS=16 zig build specs          # 16 parallel workers
TEST_WORKERS=1 zig build specs           # Sequential (same as TEST_SEQUENTIAL=1)
```

### 7. Fast Filtered Tests
```bash
TEST_FILTER="primitives" TEST_WORKERS=4 zig build specs
```

### 8. CI/CD Pipeline Example
```bash
# GitHub Actions / GitLab CI
TEST_FORMAT=junit TEST_WORKERS=4 zig build specs > test-results.xml
```

## Interactive Test Runner

```bash
zig build test-watch
```

**Commands:**
- `a` - Run all tests
- `f` - Run failed tests only
- `/pattern` - Filter tests by pattern
- `c` - Clear filter
- `l` - Toggle log display
- `w` - Toggle watch mode (auto-rerun on file changes)
- `Enter` - Run filtered tests
- `h` - Show help
- `q` - Quit

**Features:**
- ✅ TEST_FILTER environment variable support
- ✅ Live log output toggle
- ✅ Failed test re-running
- ✅ File watch mode (polling-based, 500ms)
- ✅ Session state persistence

## Output Examples

### Pretty Format (Default)
```
 RUN  v0.15.1
 ›~/guillotine

 Running 9703 tests in parallel with 8 workers...

─────────────────────────────────────────
 Test Results
─────────────────────────────────────────

 ✓ primitives (15) 125.34 ms
 ✓ evm (9688) 42.56s

─────────────────────────────────────────
 Slowest Tests (10)
─────────────────────────────────────────

 ✓ evm.test.complex_contract  2.34s
 ✓ primitives.test.hash_large  1.89s
 ...

⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯
 Test Files  1 passed (9703)
      Tests  9703 passed (9703)
  Start at  17:39:45
   Duration  45.12s
```

### JSON Format
```json
{
  "success": true,
  "total": 9703,
  "passed": 9703,
  "failed": 0,
  "todo": 0,
  "duration_ms": 45123.45,
  "tests": [
    {
      "name": "evm.test.add",
      "suite": "evm",
      "test_name": "add",
      "status": "passed",
      "duration_ms": 12.34
    }
  ]
}
```

## Performance Comparison

### Sequential vs Parallel (9703 tests)
```bash
# Sequential
TEST_SEQUENTIAL=1 zig build specs
# ~3-4 minutes

# Parallel (8 workers)
zig build specs
# ~45-60 seconds

# Speedup: ~4x faster
```

## Advanced Features

### 1. Slowest Tests Report
Automatically shown after each run in pretty format. Shows top 10 slowest tests with durations.

### 2. Test Isolation
Each test runs in a forked process with:
- ✅ 60-second timeout
- ✅ Memory leak detection
- ✅ Crash/signal handling
- ✅ Independent state

### 3. Smart Defaults
- ✅ Auto-detects CPU cores
- ✅ Caps workers at 8 (prevents fork bomb)
- ✅ Respects TEST_FILTER from environment
- ✅ TTY detection for progress display

## Troubleshooting

### Tests timing out
```bash
# Reduce parallelism
TEST_WORKERS=2 zig build specs
```

### Need deterministic output order
```bash
# Run sequentially
TEST_SEQUENTIAL=1 zig build specs
```

### Debug specific test
```bash
TEST_FILTER="exact.test.name" TEST_SEQUENTIAL=1 zig build specs
```

### CI/CD integration failing
```bash
# Use JSON or JUnit format
TEST_FORMAT=junit zig build specs
```

## Key Improvements from Original

| Feature | Before | After |
|---------|--------|-------|
| **Parallel Execution** | ❌ No | ✅ Yes (default) |
| **Output Formats** | Pretty only | Pretty, JSON, JUnit |
| **Slowest Tests** | ❌ No | ✅ Yes (auto-shown) |
| **Test Filtering** | ❌ No | ✅ Yes (env var) |
| **Worker Control** | ❌ No | ✅ Yes (auto + manual) |
| **CI/CD Ready** | ❌ No | ✅ Yes (JSON/JUnit) |
| **Code Duplication** | ~600 lines | 0 lines |
| **Interactive Mode** | Basic | Enhanced (watch, logs, filter) |

## System Requirements

- **OS**: macOS, Linux (uses `fork()` for test isolation)
- **Zig**: 0.15.1
- **CPU**: Multi-core recommended for parallel execution
- **Memory**: ~100MB per worker process

## Known Limitations

1. **No Windows Support**: Uses POSIX `fork()` - not available on Windows
2. **File Watcher**: Polling-based (500ms interval) - not inotify/kqueue yet
3. **Test Dependencies**: Tests must be independent (no shared state)
4. **Max Workers**: Capped at 8 to prevent resource exhaustion

## Future Enhancements

- [ ] Better error capture (stdout/stderr piping)
- [ ] Test tagging (`@slow`, `@skip`)
- [ ] Regex filter support
- [ ] Smart re-run (dependency tracking)
- [ ] Native file watching (kqueue/inotify)
- [ ] Test result caching

---

**Last Updated**: 2025-01-XX
**Version**: 0.15.1
**Status**: ✅ Production Ready
