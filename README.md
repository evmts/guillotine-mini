# Guillotine Mini

Minimal, spec‑focused EVM in Zig with rich tooling for execution‑spec tests, tracing, and diffing.

## Quick Start

```bash
zig build           # build
zig build specs     # run execution‑spec tests
zig build test      # unit + specs
```

Use `TEST_FILTER` to run a subset:

```bash
TEST_FILTER="push0" zig build specs
```

## Documentation

- **[CLAUDE.md](./CLAUDE.md)**: Comprehensive project documentation for AI assistants and developers
- **[TESTING.md](./TESTING.md)**: Testing and targets
- **[CONTRIBUTING.md](./CONTRIBUTING.md)**: Contributing guide, environment setup, and debugging
- **[src/precompiles/CLAUDE.md](./src/precompiles/CLAUDE.md)**: Precompiled contracts documentation
- **[src/crypto/CLAUDE.md](./src/crypto/CLAUDE.md)**: Cryptographic primitives documentation

## Test Status

| Hardfork | Status | Notes |
|----------|--------|-------|
| Frontier | ✅ **PASSING** | All tests pass |
| Homestead | ✅ **PASSING** | All tests pass |
| Byzantium | ⚠️ Partial (85%) | 54/352 failures (MODEXP edge cases) |
| Constantinople | ⚠️ Partial (78%) | 112/508 failures (CREATE2 return data) |
| Istanbul | ⚠️ Partial (95%) | 113/2165 failures (non-Blake2 tests) |
| Berlin | ✅ **PASSING** | All tests pass |
| Paris | ✅ **PASSING** | All tests pass |
| London | ✅ **PASSING** | All tests pass |
| Shanghai | ⚠️ Partial (93%) | 76/1090 failures (EIP-3860 initcode) |
| Cancun | ⏱️ Timeout | Needs investigation |
| Prague | ✅ **PASSING** | All tests pass |
| Osaka | ✅ **PASSING** | All tests pass |

**Recent Fix**: BLAKE2F precompile (EIP-152) - resolved 246 test failures by correcting sigma permutation table ✅

## Architecture

Minimal, correct, and well-tested Ethereum Virtual Machine (EVM) implementation in Zig, prioritizing specification compliance, clarity, and hardfork support (Berlin through Prague).

### Components

- **EVM Orchestrator** (`src/evm.zig`): State management, storage, gas accounting, call stack, transient storage
- **Execution Frame** (`src/frame.zig`): Bytecode interpreter, stack, memory, PC, gas tracking
- **Host Interface** (`src/host.zig`): Abstract state backend (balances, storage, code, nonces)
- **Hardfork Support** (`src/hardfork.zig`): Hardfork detection and feature flags

### Key Features

- **Specification Compliance**: Validated against ethereum/tests (GeneralStateTests)
- **Hardfork Support**: Berlin, London, Merge, Shanghai, Cancun, Prague
- **EIP Compliance**: EIP-1153, EIP-3855, EIP-5656, EIP-4844, EIP-152 (BLAKE2F), and more
- **Tracing**: Full EIP-3155 trace support for debugging
- **WASM Target**: Compiles to WebAssembly (~193 KB)

## License

See LICENSE file for details.
