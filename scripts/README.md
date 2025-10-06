# Test Scripts

This directory contains helper scripts for running and debugging execution-spec tests.

## Available Scripts

### 🎯 `test-subset.sh` - Main Test Runner

Run filtered subsets of execution-spec tests with nice formatting.

```bash
# Run by test name/pattern
./scripts/test-subset.sh push0
./scripts/test-subset.sh transientStorage
./scripts/test-subset.sh Cancun

# Using environment variable
TEST_FILTER=Shanghai ./scripts/test-subset.sh

# List available test categories
./scripts/test-subset.sh --list

# Show help
./scripts/test-subset.sh --help
```

**Features:**
- Colored output with progress indicators
- Automatic trace divergence on failures
- Support for both CLI args and env vars
- Built-in test category listing

### 🔍 `debug-test.sh` - Single Test Debugger

Debug a specific test with full trace output.

```bash
./scripts/debug-test.sh transStorageOK
./scripts/debug-test.sh push0Gas
```

**Use this when:**
- You know the exact test name
- You want detailed execution traces
- You need to debug a specific failure

### ⚡ `quick-test.sh` - Smoke Tests

Run a quick smoke test suite for rapid iteration.

```bash
./scripts/quick-test.sh
```

**Features:**
- Runs 3-5 representative tests
- Fast feedback (< 30 seconds)
- Good for checking basic functionality

### 📋 `run-filtered-tests.sh` - Simple Filter Runner

Basic wrapper around `zig build specs` with filtering.

```bash
./scripts/run-filtered-tests.sh push0
./scripts/run-filtered-tests.sh Cancun
```

**Simpler alternative to `test-subset.sh`** with minimal formatting.

## Common Workflows

### During Development

```bash
# 1. Make changes to src/evm.zig or src/frame.zig

# 2. Run quick smoke tests
./scripts/quick-test.sh

# 3. Run tests for the feature you're working on
./scripts/test-subset.sh transientStorage

# 4. If a test fails, debug it
./scripts/debug-test.sh specific_failing_test
```

### Before Committing

```bash
# Run all tests for affected hardfork
./scripts/test-subset.sh Cancun
./scripts/test-subset.sh Shanghai

# Or run full suite
zig build specs
```

### Exploring Tests

```bash
# See what's available
./scripts/test-subset.sh --list

# Try different categories
./scripts/test-subset.sh vmArithmeticTest
./scripts/test-subset.sh vmBitwiseLogicOperation
```

## Direct `zig build` Usage

You can also use `zig build` directly:

```bash
# Basic filter
zig build specs -- --test-filter "push0"

# With summary
zig build specs -- --test-filter "Cancun" --summary all

# Multiple filters
zig build specs -- --test-filter "add" --test-filter "sub"
```

## Environment Variables

All scripts support the `TEST_FILTER` environment variable:

```bash
export TEST_FILTER="transientStorage"
./scripts/test-subset.sh

# Or inline
TEST_FILTER="MCOPY" ./scripts/test-subset.sh
```

## Test Naming Patterns

Tests follow these naming patterns:

**By Hardfork:**
- `Cancun` - All Cancun tests
- `Shanghai` - All Shanghai tests

**By EIP:**
- `stEIP1153` - EIP-1153 (Transient Storage)
- `stEIP3855` - EIP-3855 (PUSH0)
- `stEIP5656` - EIP-5656 (MCOPY)

**By Category:**
- `vmArithmeticTest` - Arithmetic operations
- `vmBitwiseLogicOperation` - Bitwise operations
- `vmIOandFlowOperations` - Control flow

**By Opcode:**
- `add`, `sub`, `mul`, `div` - Specific opcodes
- `sstore`, `sload` - Storage operations
- `call`, `delegatecall` - Call operations

## Debugging Tips

1. **Use filters to narrow down failures**
   ```bash
   ./scripts/test-subset.sh Cancun  # Too broad
   ./scripts/test-subset.sh stEIP1153  # Better
   ./scripts/test-subset.sh transStorageOK  # Specific
   ```

2. **Read trace divergence output carefully**
   - Shows exact step where execution differs
   - Compares gas, PC, opcode, stack depth
   - Points to the root cause

3. **Run tests incrementally**
   - Fix one test at a time
   - Re-run after each fix
   - Don't try to fix everything at once

4. **Use quick-test.sh for fast feedback**
   - Run after every change
   - Catches basic regressions
   - Much faster than full suite

## See Also

- [../docs/TESTING.md](../docs/TESTING.md) - Comprehensive testing guide
- [../test/specs/runner.zig](../test/specs/runner.zig) - Test execution logic
- [../test/specs/root.zig](../test/specs/root.zig) - Test imports

---

## TypeScript/Bun Scripts

For TypeScript utilities:

```bash
# Install dependencies
bun install

# Run scripts
bun run index.ts
```
