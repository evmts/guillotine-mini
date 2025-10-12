# Test Type Separation: State Tests vs Blockchain Tests

This document describes the complete separation of state tests and blockchain tests in the guillotine-mini EVM implementation.

## Overview

The codebase now fully separates **state tests** from **blockchain tests**, allowing you to run each type independently:

- **State tests**: Test single transaction execution (have `post` field, no `blocks` field)
- **Blockchain tests**: Test entire block processing (have `blocks` field)

## Usage

### Running Tests

```bash
# Run STATE tests (default)
zig build specs                          # All state tests
zig build specs-cancun-tstore-basic      # Specific state test suite
zig build specs-paris                    # Paris hardfork state tests

# Run BLOCKCHAIN tests
zig build specs-blockchain               # All blockchain tests (when implemented)
```

### Using fix-specs.ts

```bash
# Fix STATE tests (default)
bun run scripts/fix-specs.ts
bun run scripts/fix-specs.ts suite cancun-tstore-basic

# Fix BLOCKCHAIN tests
BLOCKCHAIN_TESTS=true bun run scripts/fix-specs.ts
BLOCKCHAIN_TESTS=true bun run scripts/fix-specs.ts suite cancun-tstore-basic
```

## Architecture Changes

### 1. Test Generation (`scripts/generate_spec_tests.py`)

**Before:**
```bash
python3 scripts/generate_spec_tests.py
# Generated all tests to test/specs/generated/
```

**After:**
```bash
python3 scripts/generate_spec_tests.py state
# Generates to test/specs/generated_state/ from state_tests/eest/

python3 scripts/generate_spec_tests.py blockchain
# Generates to test/specs/generated_blockchain/ from blockchain_tests/eest/
```

### 2. Root Update (`scripts/update_spec_root.py`)

**Before:**
```bash
python3 scripts/update_spec_root.py
# Updated test/specs/root.zig with all tests
```

**After:**
```bash
python3 scripts/update_spec_root.py state
# Updates root.zig with state test imports

python3 scripts/update_spec_root.py blockchain
# Updates root.zig with blockchain test imports
```

### 3. Build System (`build.zig`)

**Key Changes:**

1. **Separate test generation pipelines:**
   ```zig
   const generate_zig_state_tests = b.addSystemCommand(&.{
       "python3", "scripts/generate_spec_tests.py", "state",
   });

   const generate_zig_blockchain_tests = b.addSystemCommand(&.{
       "python3", "scripts/generate_spec_tests.py", "blockchain",
   });
   ```

2. **Separate test executables:**
   ```zig
   const spec_tests_state = b.addTest(.{ /* ... */ });
   const spec_tests_blockchain = b.addTest(.{ /* ... */ });
   ```

3. **Environment variable injection:**
   ```zig
   run_spec_tests_state.setEnvironmentVariable("TEST_TYPE", "state");
   run_spec_tests_blockchain.setEnvironmentVariable("TEST_TYPE", "blockchain");
   ```

4. **New build targets:**
   - `zig build specs` → STATE tests only
   - `zig build specs-blockchain` → BLOCKCHAIN tests only
   - All `specs-*` sub-targets → STATE tests by default

### 4. Test Runner (`test/specs/runner.zig`)

**Added test type filtering:**

```zig
// Check if we should filter by test type
if (std.posix.getenv("TEST_TYPE")) |expected_type| {
    const matches = if (is_blockchain_test)
        std.mem.eql(u8, expected_type, "blockchain")
    else
        std.mem.eql(u8, expected_type, "state");

    if (!matches) {
        return error.SkipZigTest;
    }
}
```

The runner:
1. Detects test type from JSON structure (`blocks` field presence)
2. Checks `TEST_TYPE` environment variable
3. Skips tests that don't match the expected type

### 5. Fix Specs Script (`scripts/fix-specs.ts`)

**Added BLOCKCHAIN_TESTS support:**

```typescript
class SpecFixerPipeline {
  private testType: "state" | "blockchain";

  constructor(testType: "state" | "blockchain" = "state") {
    this.testType = testType;
    // ...
  }
}

// In main():
const testType = process.env.BLOCKCHAIN_TESTS === "true"
  ? "blockchain"
  : "state";
const pipeline = new SpecFixerPipeline(testType);
```

## Directory Structure

```
test/specs/
├── generated_state/           # Generated STATE test files
│   └── eest/
│       ├── cancun/
│       ├── shanghai/
│       └── ...
├── generated_blockchain/      # Generated BLOCKCHAIN test files
│   └── eest/
│       ├── cancun/
│       ├── shanghai/
│       └── ...
├── root.zig                   # Imports either state or blockchain tests
├── runner.zig                 # Test runner with type filtering
└── test_host.zig             # Test host implementation
```

```
execution-specs/tests/eest/static/state_tests/
├── state_tests/              # STATE test JSON files
│   └── eest/
│       ├── cancun/
│       └── ...
└── blockchain_tests/         # BLOCKCHAIN test JSON files
    └── eest/
        ├── cancun/
        └── ...
```

## Implementation Details

### Test Type Detection

Tests are classified by their JSON structure:

**State Test:**
```json
{
  "env": { ... },
  "pre": { ... },
  "transaction": { ... },
  "post": { ... }
}
```

**Blockchain Test:**
```json
{
  "network": "Cancun",
  "genesisBlockHeader": { ... },
  "pre": { ... },
  "blocks": [ ... ],
  "postState": { ... }
}
```

The presence of `"blocks"` field indicates a blockchain test.

### Environment Variables

| Variable | Values | Effect |
|----------|--------|--------|
| `TEST_TYPE` | `state` or `blockchain` | Set by build.zig, filters tests in runner |
| `TEST_FILTER` | Any string | Filters tests by name (existing behavior) |
| `BLOCKCHAIN_TESTS` | `true` or unset | Controls fix-specs.ts test type |

## Benefits

1. **Clear separation**: State tests and blockchain tests are completely independent
2. **Faster iteration**: Run only the test type you need
3. **Better organization**: Separate directories and build targets
4. **Flexible debugging**: Use fix-specs.ts with either test type
5. **Explicit control**: Clear commands for each test type

## Migration Notes

### For existing workflows:

- **No changes needed**: `zig build specs` still works (runs state tests)
- **New capability**: Add `zig build specs-blockchain` when needed
- **fix-specs.ts**: Works exactly the same for state tests (default)

### For adding blockchain test support:

1. Generate blockchain tests: Already handled by build system
2. Implement blockchain-specific logic if needed in runner
3. Run: `zig build specs-blockchain`

## Future Enhancements

Potential improvements:

1. Add `-blockchain` suffix to all sub-targets (e.g., `specs-cancun-tstore-basic-blockchain`)
2. Create blockchain-specific fix-specs known issues database
3. Add blockchain test statistics to reports
4. Support running both types in parallel for comparison

## Troubleshooting

### Tests not found

**Issue**: `No generated state tests found`

**Solution**:
```bash
zig build specs  # This will auto-generate tests
# Or manually:
python3 scripts/generate_spec_tests.py state
python3 scripts/update_spec_root.py state
```

### Wrong test type running

**Issue**: Blockchain tests running when expecting state tests

**Check**:
1. `TEST_TYPE` environment variable is set correctly
2. Using correct build target (`specs` vs `specs-blockchain`)
3. Generated test directory matches (`generated_state` vs `generated_blockchain`)

### fix-specs.ts not using correct test type

**Issue**: Running wrong test type

**Solution**:
```bash
# For state tests (default)
bun run scripts/fix-specs.ts

# For blockchain tests
BLOCKCHAIN_TESTS=true bun run scripts/fix-specs.ts
```

## Summary

This separation provides:
- ✅ Complete independence between state and blockchain tests
- ✅ Clear, explicit control over which test type to run
- ✅ Better organization and faster iteration
- ✅ Support for both test types in fix-specs.ts
- ✅ Backward compatibility with existing workflows
