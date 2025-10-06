# Testing Guide

## Running Execution-Spec Tests

### Quick Start

```bash
# Run all tests (takes a long time!)
zig build specs

# Run filtered subset of tests
./scripts/test-subset.sh <filter>

# Using environment variable
TEST_FILTER=<pattern> ./scripts/test-subset.sh
```

### Filtering Tests

The test runner supports Zig's `--test-filter` flag to run subsets of tests:

#### By Hardfork
```bash
./scripts/test-subset.sh Cancun    # All Cancun tests
./scripts/test-subset.sh Shanghai  # All Shanghai tests
```

#### By EIP/Feature
```bash
./scripts/test-subset.sh transientStorage  # EIP-1153 tests
./scripts/test-subset.sh push0            # EIP-3855 tests
./scripts/test-subset.sh MCOPY            # EIP-5656 tests
./scripts/test-subset.sh warmcoinbase     # EIP-3651 tests
```

#### By Opcode
```bash
./scripts/test-subset.sh add              # Addition opcode tests
./scripts/test-subset.sh mul              # Multiplication tests
./scripts/test-subset.sh sstore           # Storage tests
```

#### By Test Category
```bash
./scripts/test-subset.sh vmArithmeticTest        # All arithmetic tests
./scripts/test-subset.sh vmBitwiseLogicOperation # Bitwise tests
./scripts/test-subset.sh vmIOandFlowOperations   # Control flow tests
```

### Listing Available Tests

```bash
./scripts/test-subset.sh --list
```

### Direct Zig Build Command

You can also use `zig build` directly:

```bash
# Run with filter
zig build specs -- --test-filter "push0"

# Run with summary
zig build specs -- --test-filter "Cancun" --summary all

# Multiple filters (tests matching any pattern)
zig build specs -- --test-filter "add" --test-filter "sub"
```

### Environment Variables

The test subset script supports environment variables:

```bash
# Using environment variable
export TEST_FILTER="transientStorage"
./scripts/test-subset.sh

# Inline
TEST_FILTER="MCOPY" ./scripts/test-subset.sh
```

## Debugging Test Failures

### Automatic Trace Comparison

When a test fails, the test runner automatically:

1. Captures a trace of the EVM execution
2. Runs the reference Python implementation
3. Compares the traces step-by-step
4. Prints the divergence point with details

Example output:
```
⚠ Trace Divergence at step 42
Difference in: gas

Our EVM:
  PC: 0x1a  Op: 0x55 (SSTORE)  Gas: 2300
  Stack depth: 3

Reference:
  PC: 0x1a  Op: 0x55 (SSTORE)  Gas: 5000
  Stack depth: 3
```

### Running Individual Tests

To debug a single test:

```bash
# Find the exact test name from root.zig
grep "test_name" test/specs/root.zig

# Run just that test
./scripts/test-subset.sh "exact_test_name"
```

### Example Debugging Session

```bash
# 1. Run a category to find failures
./scripts/test-subset.sh transientStorage

# 2. Identify the failing test name from output
# e.g., "transStorageReset"

# 3. Run just that test
./scripts/test-subset.sh transStorageReset

# 4. Examine the trace divergence output
# 5. Fix the issue in src/evm.zig or src/frame.zig
# 6. Re-run the test
```

## Test Structure

Tests are located in:
- `test/specs/root.zig` - Main test file that imports all generated tests
- `test/specs/generated/` - Auto-generated test files from ethereum-tests
- `test/specs/runner.zig` - Test execution logic

Each test:
1. Loads JSON test case from ethereum-tests
2. Sets up pre-state (accounts, balances, storage)
3. Executes the transaction
4. Validates post-state matches expected values

## Common Test Patterns

### Testing a Specific Opcode

```bash
# Test all arithmetic opcodes
./scripts/test-subset.sh vmArithmeticTest

# Test specific operation
./scripts/test-subset.sh add
./scripts/test-subset.sh sub
./scripts/test-subset.sh mul
```

### Testing New EIP Implementation

```bash
# When implementing a new EIP:
# 1. Find related tests
./scripts/test-subset.sh --list | grep -i "eip"

# 2. Run those tests
./scripts/test-subset.sh stEIP1153

# 3. Debug failures one by one
./scripts/test-subset.sh "specific_failing_test"
```

### Regression Testing

```bash
# After making changes, run full test suite for affected hardfork
./scripts/test-subset.sh Cancun

# Or run all tests if unsure
zig build specs
```

## Performance Tips

- Use filters to run only relevant tests during development
- Full test suite takes 5-10 minutes
- Individual test categories run in seconds
- Use `--list` to explore available test groups

## CI/CD Integration

```bash
# In CI, you might want to run tests in groups:
./scripts/test-subset.sh Cancun
./scripts/test-subset.sh Shanghai
./scripts/test-subset.sh vmArithmeticTest
./scripts/test-subset.sh vmBitwiseLogicOperation

# Or run all tests:
zig build specs
```

## Updating Tests

To update the ethereum-tests submodule and regenerate tests:

```bash
# Update submodule
git submodule update --remote ethereum-tests

# Regenerate test files (if you have generation scripts)
# ... (add generation command here when available)
```

## Troubleshooting

### Tests Hanging

If tests seem to hang:
- Check if you're running the full suite (use filters!)
- Increase timeout in scripts if needed
- Use Ctrl+C to cancel

### Missing Reference Implementation

Some trace comparisons require the Python execution-specs:
```bash
cd execution-specs
python -m venv .venv
source .venv/bin/activate
pip install -e .
```

### Test Filter Not Matching

- Test filters are case-sensitive
- Use `--list` to see exact test names
- Try broader filters if specific ones don't work
