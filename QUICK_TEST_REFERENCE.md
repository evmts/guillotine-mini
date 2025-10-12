# Quick Test Reference

## TL;DR

```bash
# State tests (default)
zig build specs                          # Run all state tests
zig build specs-cancun-tstore-basic      # Run specific state test

# Blockchain tests
zig build specs-blockchain               # Run all blockchain tests

# Fix specs
bun run scripts/fix-specs.ts                          # Fix state tests
BLOCKCHAIN_TESTS=true bun run scripts/fix-specs.ts    # Fix blockchain tests
```

## What Changed

| Command | Before | After |
|---------|--------|-------|
| `zig build specs` | Mixed state + blockchain | **STATE tests only** |
| `zig build specs-blockchain` | ❌ Didn't exist | **BLOCKCHAIN tests only** |
| `zig build specs-cancun-*` | Mixed | **STATE tests only** |

## File Locations

| Test Type | JSON Source | Generated Zig | Root Import |
|-----------|-------------|---------------|-------------|
| **State** | `execution-specs/tests/eest/static/state_tests/state_tests/` | `test/specs/generated_state/` | Set by build |
| **Blockchain** | `execution-specs/tests/eest/static/state_tests/blockchain_tests/` | `test/specs/generated_blockchain/` | Set by build |

## Key Differences

### State Tests
- Single transaction execution
- Has `post` field
- No `blocks` field
- Default for all commands

### Blockchain Tests
- Full block validation
- Has `blocks` field
- Has `postState` field
- Explicitly use `specs-blockchain` target

## Examples

```bash
# Run specific state test suites
zig build specs-cancun-mcopy
zig build specs-shanghai-push0
zig build specs-paris

# Run blockchain tests (when implemented)
zig build specs-blockchain

# Debug state tests
bun scripts/isolate-test.ts "test_name"

# Fix all state tests with AI
bun run scripts/fix-specs.ts

# Fix all blockchain tests with AI
BLOCKCHAIN_TESTS=true bun run scripts/fix-specs.ts

# Fix specific suite (state tests)
bun run scripts/fix-specs.ts suite cancun-tstore-basic

# Fix specific suite (blockchain tests)
BLOCKCHAIN_TESTS=true bun run scripts/fix-specs.ts suite cancun-tstore-basic
```

## Verification

Check what type of tests are loaded:

```bash
# Should show state tests
ls -la test/specs/generated_state/eest/

# Should show blockchain tests
ls -la test/specs/generated_blockchain/eest/

# Check root.zig - it will be regenerated based on which build target runs
cat test/specs/root.zig | head -5
```

## Environment Variables

| Variable | Use Case | Example |
|----------|----------|---------|
| `TEST_TYPE` | Set by build.zig automatically | `TEST_TYPE=state` |
| `TEST_FILTER` | Filter by test name | `TEST_FILTER="cancun" zig build specs` |
| `BLOCKCHAIN_TESTS` | Control fix-specs.ts | `BLOCKCHAIN_TESTS=true bun run scripts/fix-specs.ts` |

## Common Tasks

### I want to run only Cancun state tests
```bash
zig build specs-cancun-tstore-basic
# Or filter:
TEST_FILTER="cancun" zig build specs
```

### I want to run blockchain tests
```bash
zig build specs-blockchain
```

### I want to fix failing state tests automatically
```bash
bun run scripts/fix-specs.ts
```

### I want to fix failing blockchain tests automatically
```bash
BLOCKCHAIN_TESTS=true bun run scripts/fix-specs.ts
```

### I want to regenerate test files manually
```bash
# State tests
python3 scripts/generate_spec_tests.py state
python3 scripts/update_spec_root.py state

# Blockchain tests
python3 scripts/generate_spec_tests.py blockchain
python3 scripts/update_spec_root.py blockchain
```

## See Also

- `TEST_TYPE_SEPARATION.md` - Full technical details
- `CLAUDE.md` - General project documentation
