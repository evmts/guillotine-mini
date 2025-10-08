# Guillotine Mini

A minimal, correct, and well-tested Ethereum Virtual Machine (EVM) implementation in Zig, designed for clarity and specification compliance.

## Overview

**Guillotine Mini** is a pure Zig implementation of the Ethereum Virtual Machine that prioritizes:

- **Specification Compliance**: Validated against ethereum/tests (GeneralStateTests)
- **Clarity**: Clean architecture with separation of concerns
- **Hardfork Support**: Berlin, London, Merge, Shanghai, Cancun, Prague
- **EIP Compliance**: Modern EIPs including transient storage (EIP-1153), PUSH0 (EIP-3855), MCOPY (EIP-5656)
- **Tracing**: Full EIP-3155 trace support for debugging
- **WASM Target**: Compiles to WebAssembly for browser/edge deployment

## Quick Start

### Prerequisites

- Zig 0.15.1 or later
- Python 3.8+ (for test generation)

### Building

```bash
# Build the project
zig build

# Build WASM library
zig build wasm

# Run all tests
zig build test

# Run execution-spec tests
zig build specs

# Run filtered tests
TEST_FILTER="Cancun" zig build specs
```

## Project Structure

```
src/
├── root.zig              # Main module exports
├── evm.zig               # EVM orchestrator (state, calls, gas)
├── frame.zig             # Execution frame (bytecode interpreter)
├── host.zig              # Host interface for external state
├── hardfork.zig          # Hardfork detection and feature flags
├── opcode.zig            # Opcode definitions
├── trace.zig             # EIP-3155 trace generation
├── precompiles/          # Precompiled contracts (0x01-0x09)
├── crypto/               # Cryptographic primitives
└── primitives/           # Reusable types (Address, u256, RLP, ABI)
```

## WASM Build

The project compiles to WebAssembly for use in browsers or edge environments:

```bash
zig build wasm
# Output: zig-out/bin/guillotine_mini.wasm (~193 KB)
```

### WASM Limitations

⚠️ **Important**: The WASM build currently uses `wasm32-wasi` instead of `wasm32-freestanding` due to C library dependencies. This means:

- **Requires WASI runtime**: wasmtime, wasmer, or browser with WASI polyfills
- **Larger bundle size**: Includes WASI libc overhead
- **Disabled features**: BN254 and C-KZG precompiles are not available

See [Issue #15](https://github.com/evmts/guillotine-mini/issues/15) for details and planned improvements.

### Exported WASM Functions

```javascript
// Create and manage EVM instances
evm_create()
evm_destroy(handle)

// Configure execution
evm_set_bytecode(handle, bytecode, len)
evm_set_execution_context(handle, gas, caller, address, value, calldata, len)
evm_set_blockchain_context(handle, block_number, timestamp, coinbase, difficulty, gas_limit, chain_id)

// Execute and retrieve results
evm_execute(handle)
evm_get_gas_remaining(handle)
evm_get_gas_used(handle)
evm_is_success(handle)
evm_get_output(handle, output_buf, output_len)

// Manage state
evm_set_storage(handle, address, key, value)
evm_get_storage(handle, address, key)
evm_set_balance(handle, address, balance)
evm_set_code(handle, address, code, len)
```

See `src/root_c.zig` for the complete C-compatible API.

## Testing

### Spec Tests

The project uses ethereum/tests for comprehensive validation:

```bash
# Run all spec tests
zig build specs

# Filter by hardfork
TEST_FILTER="Cancun" zig build specs
TEST_FILTER="Shanghai" zig build specs

# Filter by EIP
TEST_FILTER="transientStorage" zig build specs  # EIP-1153
TEST_FILTER="push0" zig build specs              # EIP-3855
TEST_FILTER="MCOPY" zig build specs              # EIP-5656

# Filter by opcode
TEST_FILTER="sstore" zig build specs
TEST_FILTER="call" zig build specs
```

### Test Runner

The custom test runner provides:
- Vitest-style output formatting
- Parallel test execution
- EIP-3155 trace comparison on failures
- Progress indicators
- Multiple output formats (pretty, JSON, JUnit)

When a test fails, the runner automatically:
1. Captures an EIP-3155 trace of your execution
2. Runs the reference Python implementation
3. Compares traces step-by-step
4. Shows exact divergence point with PC, opcode, gas, stack

## Supported EIPs

| EIP | Feature | Hardfork |
|-----|---------|----------|
| EIP-2929 | Gas cost increases for state access | Berlin |
| EIP-2930 | Access lists | Berlin |
| EIP-1559 | Fee market | London |
| EIP-3198 | BASEFEE opcode | London |
| EIP-3529 | Reduced gas refunds | London |
| EIP-3541 | Reject code starting with 0xEF | London |
| EIP-3651 | Warm coinbase | Shanghai |
| EIP-3855 | PUSH0 instruction | Shanghai |
| EIP-3860 | Limit init code size | Shanghai |
| EIP-1153 | Transient storage (TLOAD/TSTORE) | Cancun |
| EIP-4844 | Blob transactions | Cancun |
| EIP-5656 | MCOPY instruction | Cancun |
| EIP-6780 | SELFDESTRUCT only in same tx | Cancun |
| EIP-7516 | BLOBBASEFEE opcode | Cancun |

## Documentation

- **[CLAUDE.md](./CLAUDE.md)**: Comprehensive project documentation for AI assistants and developers
- **[src/precompiles/CLAUDE.md](./src/precompiles/CLAUDE.md)**: Precompiled contracts documentation
- **[src/crypto/CLAUDE.md](./src/crypto/CLAUDE.md)**: Cryptographic primitives documentation

## Architecture

### EVM Orchestrator (`src/evm.zig`)

Manages state, storage, gas accounting, call stack, and transient storage. Handles nested CALL/CREATE operations with proper context switching.

### Execution Frame (`src/frame.zig`)

Interprets bytecode instruction-by-instruction. Manages the 256-word stack, expandable memory, program counter, and gas tracking.

### Host Interface (`src/host.zig`)

Abstract interface for external state access (balances, storage, code, nonces). Allows pluggable backends for testing and production.

### Hardfork Support (`src/hardfork.zig`)

Automatic detection and feature flags for all hardforks from Frontier to Prague. Gas costs adjust automatically based on active hardfork.

## Performance

This implementation prioritizes correctness and clarity over raw performance. However:

- Arena allocation minimizes overhead
- Stack-based execution with fixed-size buffers
- Minimal copying with extensive slice usage
- Warm/cold access tracking with ArrayHashMap

For production use with high throughput requirements, consider profiling with `-Doptimize=ReleaseFast` and benchmarking against reference implementations.

## Contributing

When making changes:

1. Ensure all tests pass: `zig build test`
2. Run spec tests for affected hardfork
3. Format code: `zig fmt src/ test/`
4. Add tests for new features
5. Update documentation as needed

## Resources

- [ethereum/tests](https://github.com/ethereum/tests) - Official test suite
- [execution-specs](https://github.com/ethereum/execution-specs) - Executable Python specs
- [EIP Index](https://eips.ethereum.org/) - Ethereum Improvement Proposals
- [EIP-3155](https://eips.ethereum.org/EIPS/eip-3155) - Execution trace format
- [Zig Documentation](https://ziglang.org/documentation/)

## License

See LICENSE file for details.
