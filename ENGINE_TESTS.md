# Engine API Test Filtering

## Overview

By default, guillotine-mini **skips** `blockchain_test_engine` format tests because they test consensus-layer functionality rather than core EVM execution. This is consistent with the scope of an EVM library like REVM, which focuses on transaction execution rather than block validation or Engine API server implementation.

## What are Engine API Tests?

The Engine API (`engine_newPayload`) is the interface between:
- **Consensus Layer** (beacon chain clients like Prysm, Lighthouse)
- **Execution Layer** (full node clients like Geth, Reth)

These tests validate:
- ❌ Block validation logic (consensus-layer)
- ❌ Engine API payload handling (consensus-layer)
- ❌ Withdrawal timing edge cases (consensus-layer)
- ❌ Fork transition mechanics (consensus-layer)

## What guillotine-mini Tests

**Default scope** (without `INCLUDE_ENGINE_TESTS`):
- ✅ Pure EVM execution (opcodes, gas metering, state transitions)
- ✅ Transaction processing (intrinsic gas, tx types, precompiles)
- ✅ Hardfork-specific EVM changes (PUSH0, TSTORE, MCOPY, etc.)
- ✅ Storage, memory, stack operations
- ✅ Call/Create mechanics

## Usage

### Default Behavior (Engine Tests Skipped)

```bash
zig build test           # Skips engine tests
zig build specs          # Skips engine tests
TEST_FILTER="Cancun" zig build specs  # Skips engine tests
```

### Include Engine Tests (Optional)

```bash
INCLUDE_ENGINE_TESTS=1 zig build test
INCLUDE_ENGINE_TESTS=1 zig build specs
INCLUDE_ENGINE_TESTS=1 TEST_FILTER="withdrawals" zig build specs
```

## Implementation Details

The filtering logic is in `test/specs/runner.zig`:

1. **Detection**: Tests are identified as "engine tests" if they:
   - Contain an `engineNewPayloads` field in the JSON
   - Have `blockchain_test_engine` in the test name or file path

2. **Behavior**: When `INCLUDE_ENGINE_TESTS` is not set:
   - Engine tests return `error.SkipZigTest`
   - Zig's test runner counts them as "skipped"
   - Regular tests continue to run normally

## Test Counts

Approximate test distribution:

| Category | Count (approx) | Default Enabled |
|----------|---------------|-----------------|
| Pure EVM tests | ~11,500 | ✅ Yes |
| Engine format tests | ~900 | ❌ No (optional) |
| **Total** | **~12,400** | - |

## Why Skip Engine Tests?

1. **Out of Scope**: EVM libraries (like REVM, guillotine-mini) don't implement Engine API
2. **Consensus vs Execution**: Block validation is handled by full nodes (Reth, Geth), not EVM libs
3. **Test Clarity**: Focusing on EVM-specific tests provides clearer signal on implementation correctness
4. **Performance**: Skipping ~900 irrelevant tests speeds up the test suite

## Analogy

Think of it like this:

- **REVM** (Rust EVM library) ← doesn't implement Engine API
- **Reth** (Rust full node) ← uses REVM + implements Engine API
- **guillotine-mini** (Zig EVM library) ← doesn't implement Engine API (this project)
- **Full Zig node** (hypothetical) ← would use guillotine-mini + implement Engine API

## Future Considerations

If guillotine-mini ever expands to include:
- Full node functionality
- Block validation
- Consensus-layer integration

Then enabling `INCLUDE_ENGINE_TESTS` by default would make sense. For now, these tests are kept available but opt-in for comprehensive validation purposes.
