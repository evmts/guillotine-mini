# Testing Guide

## Quick Reference

### Run All Tests
```bash
zig build specs                    # All 338 spec tests (~5-10 minutes)
```

### Run Hardfork-Specific Tests
```bash
zig build specs-frontier           # 19 tests - Frontier hardfork
zig build specs-homestead          # 1 test - Homestead hardfork
zig build specs-byzantium          # 1 test - Byzantium hardfork
zig build specs-constantinople     # 3 tests - Constantinople hardfork
zig build specs-istanbul           # 6 tests - Istanbul hardfork
zig build specs-berlin             # 4 tests - Berlin hardfork (EIP-2929, EIP-2930)
zig build specs-paris              # 1 test - Paris/Merge hardfork
zig build specs-shanghai           # 19 tests - Shanghai hardfork
zig build specs-cancun             # 105 tests - Cancun hardfork (~1-2 minutes)
zig build specs-prague             # 169 tests - Prague hardfork (~2-3 minutes)
zig build specs-osaka              # 10 tests - Osaka hardfork
```

### Run EIP-Specific Tests (Faster than full hardfork)

#### Berlin (4 tests total)
```bash
zig build specs-berlin-gas          # EIP-2929: Gas cost increases for state access
zig build specs-berlin-accesslist   # EIP-2930: Access lists
```

#### Shanghai (19 tests total)
```bash
zig build specs-shanghai-push0         # EIP-3855: PUSH0 instruction
zig build specs-shanghai-warmcoinbase  # EIP-3651: Warm coinbase
zig build specs-shanghai-initcode      # EIP-3860: Limit init code size
zig build specs-shanghai-withdrawals   # EIP-4895: Withdrawals
```

#### Cancun (105 tests total)
```bash
zig build specs-cancun-tstore        # EIP-1153: Transient storage (TLOAD/TSTORE) - 21 tests
zig build specs-cancun-blobs         # EIP-4844: Blob transactions - 50 tests
zig build specs-cancun-mcopy         # EIP-5656: MCOPY instruction - 6 tests
zig build specs-cancun-selfdestruct  # EIP-6780: SELFDESTRUCT only in same tx - 16 tests
zig build specs-cancun-beacon        # EIP-4788: Beacon root contract - 11 tests
```

## Test Distribution

| Hardfork        | Tests | Notes                                                  |
|-----------------|-------|--------------------------------------------------------|
| Frontier        | 19    | Base EVM opcodes, basic operations                     |
| Homestead       | 1     | DELEGATECALL introduction                              |
| Byzantium       | 1     | Precompile tests (MODEXP)                              |
| Constantinople  | 3     | Bitwise shifts, CREATE2                                |
| Istanbul        | 6     | Gas repricing, new opcodes                             |
| Berlin          | 4     | EIP-2929 (warm/cold access), EIP-2930 (access lists)   |
| Paris           | 1     | Merge transition                                       |
| Shanghai        | 19    | PUSH0, warm coinbase, init code limits, withdrawals    |
| Cancun          | 105   | Transient storage, blob txs, MCOPY, SELFDESTRUCT       |
| Prague          | 169   | Latest hardfork features                               |
| Osaka           | 10    | Future hardfork                                        |
| **Total**       | **338** |                                                      |

## Development Workflow

### Working on a Specific Feature

1. **Identify the hardfork/EIP**: Check CLAUDE.md EIP support table
2. **Run targeted tests**: Use the appropriate `specs-*` target
3. **Iterate quickly**: Subset targets run in seconds vs minutes

Example workflow for EIP-1153 (transient storage):
```bash
# Fast iteration on specific EIP
zig build specs-cancun-tstore

# Once passing, verify full Cancun hardfork
zig build specs-cancun

# Finally, run all specs before commit
zig build specs
```

### Running Tests with Environment Variables

You can also use the TEST_FILTER environment variable directly:
```bash
TEST_FILTER="tstore" zig build specs
TEST_FILTER="Shanghai" zig build specs
TEST_FILTER="eip4844" zig build specs
```

## Build Targets Summary

```bash
# Main targets
zig build                      # Build all modules
zig build test                 # Run unit tests + spec tests
zig build wasm                 # Build WASM library

# Spec test targets (22 total)
zig build specs                # All execution-specs tests
zig build specs-<hardfork>     # 11 hardfork-specific targets
zig build specs-<hardfork-eip> # 11 EIP-specific targets

# Other test targets
zig build test-watch           # Interactive test runner
zig build test-trace           # Trace capture tests
```

## Tips

- **Speed**: EIP-specific targets (e.g., `specs-cancun-mcopy`) are fastest for development
- **Coverage**: Hardfork targets (e.g., `specs-cancun`) test full hardfork compatibility
- **CI/CD**: Use `zig build specs` for comprehensive validation
- **Debugging**: Failed tests show EIP-3155 trace divergence for easy diagnosis
