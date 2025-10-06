# Guillotine Mini - EVM Implementation

A minimal, correct, and well-tested Ethereum Virtual Machine (EVM) implementation in Zig, designed for clarity and specification compliance.

## Project Overview

**Guillotine Mini** is a pure Zig implementation of the Ethereum Virtual Machine that prioritizes:

- **Specification Compliance**: Validated against ethereum/tests (GeneralStateTests)
- **Clarity**: Clean architecture with separation of concerns
- **Hardfork Support**: Berlin, London, Merge, Shanghai, Cancun, Prague
- **EIP Compliance**: Implements modern EIPs including transient storage (EIP-1153), PUSH0 (EIP-3855), MCOPY (EIP-5656), and more
- **Tracing**: Full EIP-3155 trace support for debugging
- **WASM Target**: Compiles to WebAssembly for browser/edge deployment

## Architecture

```
src/
├── root.zig              # Main module exports
├── evm.zig               # EVM orchestrator (manages execution, state, calls)
├── frame.zig             # Execution frame (bytecode interpreter)
├── host.zig              # Host interface for external state access
├── hardfork.zig          # Hardfork detection and feature flags
├── opcode.zig            # Opcode definitions and utilities
├── trace.zig             # EIP-3155 trace generation
├── errors.zig            # Error types
└── primitives/           # Reusable primitives
    ├── root.zig          # Primitives exports
    ├── address.zig       # Ethereum address type
    ├── gas_constants.zig # Gas costs per opcode/operation
    ├── uint.zig          # Arbitrary precision uint (u256, u512)
    ├── rlp.zig           # RLP encoding/decoding
    ├── abi.zig           # ABI encoding/decoding
    ├── transaction.zig   # Transaction types
    ├── access_list.zig   # EIP-2930 access lists
    ├── blob.zig          # EIP-4844 blob support
    └── ...
```

### Key Design Decisions

1. **Evm orchestrates, Frame executes**: The `Evm` struct manages state, storage, gas refunds, and nested calls. The `Frame` struct interprets bytecode and executes opcodes.

2. **Arena allocation**: Uses an arena allocator for transaction-scoped memory management. All temporary allocations are freed at transaction end.

3. **Host interface**: Abstract host interface (`HostInterface`) allows pluggable state backends (test host, production host, etc.)

4. **Hardfork-aware gas metering**: Gas costs automatically adjust based on the configured hardfork (e.g., Berlin warm/cold access, London gas refund caps).

## Building and Testing

### Prerequisites

- Zig 0.15.1 or later
- Python 3.8+ (for test generation and reference implementation)

### Quick Start

```bash
# Build the project
zig build

# Build WASM library
zig build wasm

# Run all unit tests
zig build test

# Run execution-spec tests
zig build specs

# Run interactive test watcher
zig build test-watch
```

### Test Commands

#### Running Spec Tests

The project uses ethereum/tests GeneralStateTests for validation:

```bash
# Run all spec tests (~5-10 minutes)
zig build specs

# Run filtered tests (recommended during development)
TEST_FILTER="Cancun" zig build specs
TEST_FILTER="transientStorage" zig build specs
TEST_FILTER="push0" zig build specs

# Using helper scripts
./scripts/test-subset.sh Cancun
./scripts/test-subset.sh Shanghai
./scripts/test-subset.sh transientStorage
./scripts/test-subset.sh MCOPY

# Run a specific test
./scripts/test-subset.sh "exact_test_name"
```

#### Test Filtering Patterns

Filter by:
- **Hardfork**: `Cancun`, `Shanghai`, `London`, `Berlin`, `Merge`, `Prague`
- **EIP**: `transientStorage` (EIP-1153), `push0` (EIP-3855), `MCOPY` (EIP-5656), `warmcoinbase` (EIP-3651)
- **Opcode**: `add`, `mul`, `sstore`, `sload`, `call`, `create2`
- **Category**: `vmArithmeticTest`, `vmBitwiseLogicOperation`, `vmIOandFlowOperations`

#### Debugging Failed Tests

When a test fails, the runner automatically:
1. Captures an EIP-3155 trace of your EVM execution
2. Runs the reference Python implementation
3. Compares traces step-by-step
4. Shows the exact divergence point with PC, opcode, gas, and stack details

Example workflow:
```bash
# 1. Run category to find failures
./scripts/test-subset.sh transientStorage

# 2. Run specific failing test
./scripts/test-subset.sh "transStorageReset"

# 3. Review trace divergence output
# 4. Fix the issue in src/frame.zig or src/evm.zig
# 5. Re-run to verify
./scripts/test-subset.sh "transStorageReset"
```

### Build Targets

The build system (build.zig:9-232) defines several targets:

- **`zig build`**: Build all modules
- **`zig build test`**: Run unit tests + spec tests
- **`zig build specs`**: Run execution-spec tests only
- **`zig build test-watch`**: Interactive test runner with auto-reload
- **`zig build wasm`**: Build WASM library + show size
- **`zig build test-trace`**: Run trace capture tests

## Core Components

### EVM (src/evm.zig)

The `Evm` struct is the main orchestrator that manages:

- **State management**: Storage, balances, nonces, code
- **Call stack**: Nested CALL/CREATE operations (max depth 1024)
- **Gas accounting**: Gas refunds, warm/cold access (EIP-2929)
- **Transient storage**: EIP-1153 transaction-scoped storage
- **Hardfork rules**: Automatic gas adjustment, feature flags

Key methods:
- `call()`: Execute bytecode (main entry point)
- `inner_call()`: Handle nested CALL/STATICCALL/DELEGATECALL operations
- `inner_create()`: Handle CREATE/CREATE2 operations
- `accessAddress()`, `accessStorageSlot()`: EIP-2929 warm/cold access tracking
- `get_storage()`, `set_storage()`: Persistent storage
- `get_transient_storage()`, `set_transient_storage()`: EIP-1153 transient storage

### Frame (src/frame.zig)

The `Frame` struct represents a single execution context (call frame) that:

- Interprets bytecode instruction-by-instruction
- Manages the 256-word stack
- Manages expandable memory
- Tracks program counter (PC) and gas
- Handles RETURN/REVERT/STOP

Key methods:
- `execute()`: Main execution loop
- `step()`: Execute single instruction (for tracing)
- Various opcode implementations (arithmetic, bitwise, storage, control flow, calls)

### Host Interface (src/host.zig)

Abstract interface for external state access:

```zig
pub const HostInterface = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        getBalance: *const fn (*anyopaque, Address) u256,
        setBalance: *const fn (*anyopaque, Address, u256) void,
        getStorage: *const fn (*anyopaque, Address, u256) u256,
        setStorage: *const fn (*anyopaque, Address, u256, u256) void,
        getCode: *const fn (*anyopaque, Address) []const u8,
        getNonce: *const fn (*anyopaque, Address) u64,
        setNonce: *const fn (*anyopaque, Address, u64) void,
        emitLog: *const fn (*anyopaque, Address, []const u8, []const u256) void,
        selfDestruct: *const fn (*anyopaque, Address, Address) void,
    };
};
```

Test implementation in `test/specs/test_host.zig`.

### Hardfork Support (src/hardfork.zig)

```zig
pub const Hardfork = enum(u8) {
    FRONTIER = 0,
    HOMESTEAD = 1,
    TANGERINE = 2,
    SPURIOUS = 3,
    BYZANTIUM = 4,
    CONSTANTINOPLE = 5,
    ISTANBUL = 6,
    BERLIN = 7,
    LONDON = 8,
    MERGE = 9,
    SHANGHAI = 10,
    CANCUN = 11,
    PRAGUE = 12,

    pub const DEFAULT = Hardfork.CANCUN;
};
```

Methods:
- `isAtLeast(fork)`: Check if current fork >= specified fork
- `isBefore(fork)`: Check if current fork < specified fork
- `fromString(name)`: Parse hardfork from string

### Primitives Module

The `primitives` module provides reusable Ethereum types:

- **Address**: 20-byte Ethereum address with comparison, formatting
- **Uint(N)**: Arbitrary precision unsigned integers (u256, u512, etc.)
- **GasConstants**: Per-opcode gas costs, adjusted for hardforks
- **Rlp**: RLP encoding/decoding for transactions, addresses, nonces
- **Abi**: ABI encoding/decoding for contract calls
- **Transaction**: Legacy, EIP-2930, EIP-1559, EIP-4844 transaction types
- **AccessList**: EIP-2930 access list support
- **Blob**: EIP-4844 blob transaction support
- **Hex**: Hex encoding/decoding utilities

## EIP Support

| EIP | Feature | Status | Hardfork |
|-----|---------|--------|----------|
| EIP-2929 | Gas cost increases for state access | ✅ Implemented | Berlin |
| EIP-2930 | Access lists | ✅ Implemented | Berlin |
| EIP-1559 | Fee market | ✅ Implemented | London |
| EIP-3198 | BASEFEE opcode | ✅ Implemented | London |
| EIP-3529 | Reduced gas refunds | ✅ Implemented | London |
| EIP-3541 | Reject code starting with 0xEF | ✅ Implemented | London |
| EIP-3651 | Warm coinbase | ✅ Implemented | Shanghai |
| EIP-3855 | PUSH0 instruction | ✅ Implemented | Shanghai |
| EIP-3860 | Limit init code size | ✅ Implemented | Shanghai |
| EIP-1153 | Transient storage (TLOAD/TSTORE) | ✅ Implemented | Cancun |
| EIP-4844 | Blob transactions (BLOBHASH, BLOBBASEFEE) | ✅ Implemented | Cancun |
| EIP-5656 | MCOPY instruction | ✅ Implemented | Cancun |
| EIP-6780 | SELFDESTRUCT only in same tx | ✅ Implemented | Cancun |
| EIP-7516 | BLOBBASEFEE opcode | ✅ Implemented | Cancun |

## Gas Metering

Gas costs are defined in `src/primitives/gas_constants.zig` and automatically adjust based on hardfork:

- **Base costs**: Per-opcode execution costs (ADD, MUL, SSTORE, etc.)
- **Memory expansion**: Quadratic cost for memory growth
- **Call stipend**: 2300 gas for value transfers
- **Warm/Cold access**: EIP-2929 (Berlin+) differentiates warm (100 gas) vs cold (2600 gas)
- **Gas refunds**: Capped at 1/2 (pre-London) or 1/5 (London+) of gas used
- **Intrinsic gas**: Base transaction cost (21000 + calldata costs)

## Tracing

Full EIP-3155 trace support for debugging:

```bash
# Enable tracing in tests
zig build test-trace

# Traces include:
# - Program counter (PC)
# - Opcode
# - Gas remaining
# - Stack contents
# - Memory contents (if modified)
# - Storage changes
```

Trace files can be compared against reference implementations (geth, execution-specs) to identify divergences.

## WASM Build

The project compiles to WebAssembly for use in browsers or edge environments:

```bash
# Build WASM module
zig build wasm

# Output: zig-out/bin/guillotine_mini.wasm
# Typical size: ~100-200 KB (ReleaseSmall)

# Exported C API functions:
# - evm_create()
# - evm_destroy()
# - evm_set_bytecode()
# - evm_set_execution_context()
# - evm_set_blockchain_context()
# - evm_execute()
# - evm_get_gas_remaining()
# - evm_get_gas_used()
# - evm_is_success()
# - evm_get_output_len()
# - evm_get_output()
# - evm_set_storage()
# - evm_get_storage()
# - evm_set_balance()
# - evm_set_code()
```

See `src/root_c.zig` for the C-compatible WASM API.

## Testing Infrastructure

### Test Types

1. **Unit tests**: Inline `test` blocks in source files
2. **Spec tests**: ethereum/tests GeneralStateTests (test/specs/)
3. **Interactive tests**: Watch mode with auto-reload (build.zig:147-161)
4. **Trace tests**: Capture and compare EIP-3155 traces

### Test Runner (test_runner.zig)

Custom test runner with:
- Vitest-style output formatting
- Parallel test execution
- Test filtering via `TEST_FILTER` env var
- Progress indicators
- Detailed failure reporting
- Multiple output formats (pretty, JSON, JUnit)

Output formats:
```bash
# Pretty output (default)
zig build specs

# JSON output
TEST_FORMAT=json zig build specs

# JUnit XML output (for CI)
TEST_FORMAT=junit zig build specs
```

### Test Organization

```
test/
├── specs/
│   ├── root.zig              # Main test entry (includes generated tests)
│   ├── runner.zig            # Test execution logic
│   ├── assembler.zig         # Bytecode assembly helpers
│   ├── test_host.zig         # Test host implementation
│   └── generated/            # Auto-generated from ethereum-tests
└── utils.zig                 # Test utilities (colors, formatting, etc.)
```

## Development Workflow

### Common Tasks

```bash
# Build and run all tests
zig build test

# Work on a specific EIP/feature
TEST_FILTER="transientStorage" zig build specs

# Debug a failing test
./scripts/test-subset.sh "specific_test_name"

# Build WASM and check size
zig build wasm

# Format code
zig fmt src/ test/

# Check for compilation errors
zig build
```

### Adding New Features

1. **Implement the feature** in `src/frame.zig` (for opcodes) or `src/evm.zig` (for behavior)
2. **Update gas constants** in `src/primitives/gas_constants.zig` if needed
3. **Add hardfork checks** using `self.hardfork.isAtLeast(.FORK_NAME)`
4. **Run relevant tests** to validate
5. **Check trace divergence** if tests fail

### Debugging Tips

- Use `std.debug.print()` sparingly (suppressed in release builds)
- Enable trace capture to see step-by-step execution
- Compare traces with reference implementation (execution-specs or geth)
- Use the interactive test runner (`zig build test-watch`) for rapid iteration
- Filter tests to the smallest reproducing case

## Performance Considerations

This implementation prioritizes correctness and clarity over raw performance. However:

- **Arena allocation**: Minimizes allocation overhead
- **Stack-based execution**: Frame uses fixed-size stack (1024 items)
- **Warm/cold tracking**: ArrayHashMap for fast access
- **Minimal copying**: Slices used throughout to avoid copies
- **Branch hints**: `@branchHint()` for hardfork checks (common case is latest fork)

For production use, consider:
- Profiling with `zig build -Doptimize=ReleaseFast`
- Benchmarking against reference implementations
- Memory pooling for high-throughput scenarios

## Code Style

- **Naming**: `snake_case` for functions/variables, `PascalCase` for types
- **Error handling**: Explicit error unions, propagate with `try`
- **Comments**: Explain "why", not "what" (code should be self-documenting)
- **Documentation comments**: Use `///` for public APIs
- **Formatting**: `zig fmt` (always run before commit)

## Resources

- **ethereum/tests**: https://github.com/ethereum/tests
- **execution-specs**: https://github.com/ethereum/execution-specs
- **EIP Index**: https://eips.ethereum.org/
- **EIP-3155 (Trace Format)**: https://eips.ethereum.org/EIPS/eip-3155
- **Yellow Paper**: https://ethereum.github.io/yellowpaper/paper.pdf
- **Zig Documentation**: https://ziglang.org/documentation/

## File Summary

| File | Purpose | Key Exports |
|------|---------|-------------|
| `src/root.zig` | Main module entry | `Evm`, `Frame`, `Host`, `Hardfork`, `Tracer` |
| `src/evm.zig` | EVM orchestrator | `Evm` struct, `call()`, `inner_call()`, `inner_create()` |
| `src/frame.zig` | Bytecode interpreter | `Frame` struct, `execute()`, `step()` |
| `src/host.zig` | Host interface | `HostInterface`, `CallResult`, `CallType` |
| `src/hardfork.zig` | Hardfork logic | `Hardfork` enum, `isAtLeast()`, `fromString()` |
| `src/opcode.zig` | Opcode utilities | `getOpName()`, opcode constants |
| `src/trace.zig` | EIP-3155 tracing | `Tracer`, `TraceEntry` |
| `src/errors.zig` | Error types | `CallError` enum |
| `src/primitives/root.zig` | Primitives exports | All primitive types |
| `build.zig` | Build configuration | Build targets, dependencies |
| `test_runner.zig` | Custom test runner | Test execution and reporting |
| `test/specs/runner.zig` | Spec test execution | `runJsonTest()`, trace comparison |

## License

See LICENSE file for details.

## Contributing

This is a reference implementation. When making changes:

1. Ensure all tests pass (`zig build test`)
2. Run spec tests for affected hardfork
3. Format code with `zig fmt`
4. Add tests for new features
5. Update this documentation as needed

For questions or issues, refer to the test output and trace divergence analysis.
