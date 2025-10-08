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
zig build specs-berlin             # Aggregates all berlin-* sub-targets
zig build specs-paris              # Paris/Merge hardfork
zig build specs-shanghai           # Aggregates Shanghai EIPs
zig build specs-cancun             # Aggregates all cancun-* sub-targets
zig build specs-prague             # Aggregates all prague-* sub-targets
zig build specs-osaka              # Aggregates all osaka-* sub-targets
```

### Granular Sub-Targets (Fastest)

Use these for tight feedback loops on specific features:

```bash
# Berlin
zig build specs-berlin-acl
zig build specs-berlin-intrinsic-gas-cost
zig build specs-berlin-intrinsic-type0
zig build specs-berlin-intrinsic-type1

# Frontier
zig build specs-frontier-precompiles
zig build specs-frontier-identity
zig build specs-frontier-create
zig build specs-frontier-call
zig build specs-frontier-calldata
zig build specs-frontier-dup
zig build specs-frontier-push
zig build specs-frontier-stack
zig build specs-frontier-opcodes

# Shanghai
zig build specs-shanghai-push0
zig build specs-shanghai-warmcoinbase
zig build specs-shanghai-initcode
zig build specs-shanghai-withdrawals

# Cancun
zig build specs-cancun-tstore-basic
zig build specs-cancun-tstore-reentrancy
zig build specs-cancun-tstore-contexts
zig build specs-cancun-mcopy
zig build specs-cancun-selfdestruct
zig build specs-cancun-blobbasefee
zig build specs-cancun-blob-precompile
zig build specs-cancun-blob-opcodes
zig build specs-cancun-blob-tx-small
zig build specs-cancun-blob-tx-subtraction
zig build specs-cancun-blob-tx-insufficient
zig build specs-cancun-blob-tx-sufficient
zig build specs-cancun-blob-tx-valid-combos

# Prague
zig build specs-prague-calldata-cost-type0
zig build specs-prague-calldata-cost-type1-2
zig build specs-prague-calldata-cost-type3
zig build specs-prague-calldata-cost-type4
zig build specs-prague-calldata-cost-refunds
zig build specs-prague-bls-g1
zig build specs-prague-bls-g2
zig build specs-prague-bls-pairing
zig build specs-prague-bls-map
zig build specs-prague-bls-misc
zig build specs-prague-setcode-calls
zig build specs-prague-setcode-gas
zig build specs-prague-setcode-txs
zig build specs-prague-setcode-advanced

# Osaka
zig build specs-osaka-modexp-variable-gas
zig build specs-osaka-modexp-vectors-eip
zig build specs-osaka-modexp-vectors-legacy
zig build specs-osaka-modexp-misc
zig build specs-osaka-other
```

## Test Distribution (approximate)

| Hardfork        | Tests | Notes                                                  |
|-----------------|-------|--------------------------------------------------------|
| Frontier        | 19    | Base EVM opcodes, basic operations                     |
| Homestead       | 1     | DELEGATECALL introduction                              |
| Byzantium       | 1     | Precompile tests (MODEXP)                              |
| Constantinople  | 3     | Bitwise shifts, CREATE2                                |
| Istanbul        | 6     | Gas repricing, new opcodes                             |
| Berlin          | 4     | EIP-2929 (warm/cold access), EIP-2930 (access lists)   |
| Paris           | 1     | Merge transition                                       |
| Shanghai        | ~19   | PUSH0, warm coinbase, init code limits, withdrawals    |
| Cancun          | many  | Transient storage, blob txs, MCOPY, SELFDESTRUCT       |
| Prague          | many  | Latest hardfork features incl. BLS                     |
| Osaka           | some  | Future hardfork                                        |
| **Total**       | 300+  | Varies as specs evolve                                 |

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

## AI-Assisted Spec Fixing

To run the AI-assisted spec fixer:

```bash
cd scripts && bun install
export ANTHROPIC_API_KEY=sk-ant-...

bun run ../scripts/fix-specs.ts           # from scripts/ dir
# or from repo root
bun run scripts/fix-specs.ts suite cancun-blob-opcodes
```

If `ANTHROPIC_API_KEY` is not set, the fixer will still run tests but skip agent attempts.

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
