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

---

## Agent Quick Reference: Python Reference vs Zig Implementation

This section provides critical implementation patterns to help agents efficiently debug and fix spec test failures.

### 🔍 Where to Look: File Location Mapping

When debugging a failing test, here's where to find the corresponding implementations:

| Problem Area | Python Reference | Zig Implementation |
|--------------|------------------|-------------------|
| Opcode logic (SSTORE, SLOAD, etc.) | `execution-specs/src/ethereum/forks/<hardfork>/vm/instructions/*.py` | `src/frame.zig` (search for opcode name) |
| Gas calculation errors | `execution-specs/src/ethereum/forks/<hardfork>/vm/gas.py` | `src/primitives/gas_constants.zig` + `src/frame.zig` (per-opcode) |
| Call/Create operations | `execution-specs/src/ethereum/forks/<hardfork>/vm/instructions/system.py` | `src/evm.zig` (`inner_call`, `inner_create`) |
| Storage operations | `execution-specs/src/ethereum/forks/<hardfork>/vm/instructions/storage.py` | `src/evm.zig` (`get_storage`, `set_storage`) |
| Transient storage (EIP-1153) | `execution-specs/src/ethereum/forks/cancun/vm/instructions/storage.py` | `src/evm.zig` (`get_transient_storage`, `set_transient_storage`) |
| State management | `execution-specs/src/ethereum/forks/<hardfork>/state.py` | `src/evm.zig` (balances, nonces, code maps) |
| Hardfork activation | `execution-specs/src/ethereum/forks/<hardfork>/` (directory structure) | `src/hardfork.zig` (`isAtLeast`, `isBefore`) |
| Warm/cold access tracking | `execution-specs/src/ethereum/forks/<hardfork>/vm/__init__.py` (Evm dataclass) | `src/evm.zig` (`warm_addresses`, `warm_storage_slots`) |
| Memory operations | `execution-specs/src/ethereum/forks/<hardfork>/vm/memory.py` | `src/frame.zig` (`expandMemory`, memory array) |
| Stack operations | `execution-specs/src/ethereum/forks/<hardfork>/vm/stack.py` | `src/frame.zig` (`pushStack`, `popStack`) |

### 📐 Key Architectural Differences

Understanding these differences prevents confusion when comparing implementations:

#### Python: Single `Evm` Class
- **Structure**: One `Evm` dataclass holds everything (stack, memory, pc, gas, state)
- **Location**: `execution-specs/src/ethereum/forks/<hardfork>/vm/__init__.py`
- **Pattern**: `evm.stack`, `evm.memory`, `evm.pc`, `evm.gas_left`, `evm.message.block_env.state`

#### Zig: Split `Evm` + `Frame` Architecture
- **Evm** (`src/evm.zig`): Orchestrator managing state, storage, gas refunds, nested calls
  - Storage maps: `storage`, `transient_storage`, `original_storage`
  - Warm/cold tracking: `warm_addresses`, `warm_storage_slots`
  - Gas accounting: `gas_refund`
  - Call stack management: `frames` (nested calls)
- **Frame** (`src/frame.zig`): Execution context for a single call frame
  - Stack: `stack` (ArrayList of u256)
  - Memory: `memory` (expandable byte array)
  - Execution: `pc`, `gas_remaining`, `bytecode`
  - Per-frame context: `caller`, `address`, `value`, `calldata`

**Key insight**: When Python code references `evm.stack`, in Zig that's `frame.stack`. When Python references `evm.message.block_env.state`, in Zig that's `evm.storage` / `evm.balances` / etc.

### 🔥 Common Bug Patterns (with Solutions)

#### 1. Gas Metering Bugs

**Python pattern (SSTORE example)**:
```python
# execution-specs/.../vm/instructions/storage.py
def sstore(evm: Evm) -> None:
    key = pop(evm.stack).to_be_bytes32()
    new_value = pop(evm.stack)

    # Check gas stipend FIRST
    if evm.gas_left <= GAS_CALL_STIPEND:
        raise OutOfGasError

    # Then calculate dynamic cost
    gas_cost = Uint(0)
    if (target, key) not in evm.accessed_storage_keys:
        evm.accessed_storage_keys.add((target, key))
        gas_cost += GAS_COLD_SLOAD

    if original_value == current_value and current_value != new_value:
        if original_value == 0:
            gas_cost += GAS_STORAGE_SET
        else:
            gas_cost += GAS_STORAGE_UPDATE - GAS_COLD_SLOAD
    else:
        gas_cost += GAS_WARM_ACCESS

    charge_gas(evm, gas_cost)
```

**Common Zig mistakes**:
- ❌ Forgetting to check `SstoreSentryGas` (2300) before SSTORE
- ❌ Not tracking `original_storage` separately from `storage`
- ❌ Wrong gas refund calculation (must check original vs current vs new)
- ❌ Not adding cold access cost before warm/set/update cost

**Correct Zig pattern**: See `src/frame.zig` SSTORE implementation

#### 2. Warm/Cold Access Tracking (EIP-2929)

**Python pattern**:
```python
# In Evm dataclass
accessed_addresses: Set[Address]
accessed_storage_keys: Set[Tuple[Address, Bytes]]

# Usage
if address not in evm.accessed_addresses:
    evm.accessed_addresses.add(address)
    charge_gas(evm, GAS_COLD_ACCOUNT_ACCESS)
else:
    charge_gas(evm, GAS_WARM_ACCESS)
```

**Zig pattern**:
```zig
// In Evm struct
warm_addresses: std.array_hash_map.ArrayHashMap(Address, void, AddressContext, false)
warm_storage_slots: std.array_hash_map.ArrayHashMap(StorageSlotKey, void, StorageSlotKeyContext, false)

// Usage
if (!self.warm_addresses.contains(address)) {
    try self.warm_addresses.put(address, {});
    return ColdAccountAccessCost;
} else {
    return WarmStorageReadCost;
}
```

**Key difference**: Python uses sets, Zig uses hash maps with `void` values.

#### 3. Transient Storage (EIP-1153)

**Python pattern**:
```python
# TLOAD
def tload(evm: Evm) -> None:
    key = pop(evm.stack).to_be_bytes32()
    charge_gas(evm, GAS_WARM_ACCESS)  # Always warm, never cold
    value = get_transient_storage(
        evm.message.tx_env.transient_storage,
        evm.message.current_target,
        key
    )
    push(evm.stack, value)

# TSTORE
def tstore(evm: Evm) -> None:
    key = pop(evm.stack).to_be_bytes32()
    new_value = pop(evm.stack)
    charge_gas(evm, GAS_WARM_ACCESS)  # Always warm
    if evm.message.is_static:
        raise WriteInStaticContext
    set_transient_storage(...)
```

**Critical rules**:
- ✅ Transient storage is ALWAYS warm (100 gas), never cold
- ✅ Cleared at transaction boundaries, NOT call boundaries
- ✅ Must check `is_static` for TSTORE (no writes in STATICCALL)
- ✅ No gas refunds for transient storage operations

#### 4. Hardfork-Specific Behavior

**Python pattern**:
```python
# Hardforks are separate directories:
# execution-specs/src/ethereum/forks/berlin/
# execution-specs/src/ethereum/forks/london/
# execution-specs/src/ethereum/forks/cancun/

# Each fork inherits from previous and overrides changed operations
# To find behavior for fork X, look in that fork's directory
```

**Zig pattern**:
```zig
// All forks in one codebase with runtime checks
if (self.hardfork.isAtLeast(.CANCUN)) {
    // Cancun-specific behavior (EIP-1153, EIP-4844, etc.)
} else if (self.hardfork.isAtLeast(.SHANGHAI)) {
    // Shanghai-specific behavior (PUSH0, warm coinbase, etc.)
}
```

**Common mistakes**:
- ❌ Implementing feature for wrong hardfork (e.g., PUSH0 before Shanghai)
- ❌ Not using `isAtLeast` for backward compatibility
- ❌ Breaking earlier hardforks when adding new feature

### 🎯 Gas Constant Quick Reference

Python and Zig gas constants must match EXACTLY. Here's the mapping:

| Operation | Python Constant | Zig Constant | Value | Hardfork |
|-----------|-----------------|--------------|-------|----------|
| Warm storage read | `GAS_WARM_ACCESS` | `WarmStorageReadCost` | 100 | Berlin+ |
| Cold SLOAD | `GAS_COLD_SLOAD` | `ColdSloadCost` | 2100 | Berlin+ |
| Cold account access | `GAS_COLD_ACCOUNT_ACCESS` | `ColdAccountAccessCost` | 2600 | Berlin+ |
| SSTORE set (0→nonzero) | `GAS_STORAGE_SET` | `SstoreSetGas` | 20000 | All |
| SSTORE update (nonzero→nonzero) | `GAS_STORAGE_UPDATE` | `SstoreResetGas` | 5000 | All |
| SSTORE clear refund | `GAS_STORAGE_CLEAR_REFUND` | `SstoreClearRefund` | 4800 | London+ |
| SSTORE stipend check | `GAS_CALL_STIPEND` | `SstoreSentryGas` | 2300 | All |
| Call value transfer | `GAS_CALL_VALUE` | `CallValueCost` | 9000 | All |
| Call stipend | `GAS_CALL_STIPEND` | `CallStipend` | 2300 | All |

**Location in code**:
- Python: `execution-specs/src/ethereum/forks/<hardfork>/vm/gas.py`
- Zig: `src/primitives/gas_constants.zig`

### 🧪 Debugging Workflow Cheat Sheet

When a test fails, follow this EXACT sequence:

1. **Run test with trace comparison**
   ```bash
   TEST_FILTER="exact_failing_test_name" zig build specs
   ```

2. **Identify divergence point from output**
   - Look for: "Trace divergence at step N"
   - Note: PC (program counter), opcode, gas remaining, stack state

3. **Find Python reference for that opcode**
   ```bash
   # For Cancun fork (adjust for your failing hardfork)
   cd execution-specs/src/ethereum/forks/cancun/vm/instructions/
   grep -r "def <opcode_name>" .
   ```

4. **Read Python implementation line-by-line**
   - Note gas charges (order matters!)
   - Note state modifications
   - Note refund counter updates
   - Note error conditions

5. **Compare with Zig implementation**
   - For opcodes: `src/frame.zig` (search for opcode constant)
   - For calls/creates: `src/evm.zig` (`inner_call`, `inner_create`)
   - For storage: `src/evm.zig` (storage getters/setters)

6. **Make minimal fix matching Python exactly**
   - Change only what diverges
   - Keep gas calculation order identical
   - Preserve hardfork guards

7. **Re-run test to verify**
   ```bash
   TEST_FILTER="exact_failing_test_name" zig build specs
   ```

### 💡 Pro Tips for Agents

1. **Gas calculation order matters**: Python calculates gas in a specific sequence. Match it exactly.
   - Example: SSTORE checks stipend → cold access → original/current/new value comparison → refunds

2. **Original vs Current storage**: Python tracks both `get_storage_original()` and `get_storage()`. Zig must do the same.
   - `original_storage`: Value at transaction start (for refund calculations)
   - `storage`: Current value (may have changed during transaction)

3. **Warm/cold tracking is cumulative**: Once an address/slot is marked warm in Python's set, it stays warm for the entire transaction. Zig's ArrayHashMap must persist across frames.

4. **Refund counter can be negative in intermediate steps**: Python's `evm.refund_counter` can go negative temporarily (gets capped at transaction end). Don't prematurely clamp it.

5. **Static context propagates**: `is_static` flag must propagate through nested calls. STATICCALL → any child call → all descendants.

6. **Memory expansion is quadratic**: Python uses `size_in_words ** 2 // 512`. Zig must match this exactly.
   ```python
   # Python
   linear_cost = size_in_words * GAS_MEMORY
   quadratic_cost = size_in_words ** 2 // 512
   total = linear_cost + quadratic_cost
   ```

7. **Call depth limit is 1024**: Python checks `evm.message.depth + 1 > STACK_DEPTH_LIMIT`. Zig must check depth before any CALL/CREATE.

### 🚨 Anti-Patterns (Things NOT to Do)

❌ **Don't guess gas costs** - Every gas value must match Python reference exactly
❌ **Don't skip trace comparison** - Traces show exact divergence point
❌ **Don't mix hardfork behaviors** - Use `isAtLeast` guards, test each fork
❌ **Don't ignore error conditions** - Python's `raise OutOfGasError` must map to Zig errors
❌ **Don't hardcode test-specific logic** - Fix the general implementation
❌ **Don't forget to charge gas before operations** - Python charges before executing
❌ **Don't modify test files** - Only change implementation in `src/`

### 📚 Essential Python Reference Files

When debugging, these are the most frequently consulted files:

**Cancun (latest tested hardfork)**:
- `execution-specs/src/ethereum/forks/cancun/vm/interpreter.py` - Main execution loop
- `execution-specs/src/ethereum/forks/cancun/vm/gas.py` - Gas calculation functions
- `execution-specs/src/ethereum/forks/cancun/vm/instructions/storage.py` - SLOAD, SSTORE, TLOAD, TSTORE
- `execution-specs/src/ethereum/forks/cancun/vm/instructions/system.py` - CALL, CREATE, SELFDESTRUCT
- `execution-specs/src/ethereum/forks/cancun/vm/instructions/arithmetic.py` - ADD, MUL, EXP, etc.
- `execution-specs/src/ethereum/forks/cancun/vm/instructions/memory.py` - MLOAD, MSTORE, MCOPY
- `execution-specs/src/ethereum/forks/cancun/state.py` - State management primitives

**For other hardforks**, replace `cancun` with: `shanghai`, `paris`, `london`, `berlin`, `istanbul`, etc.

---

**Remember**: The Python execution-specs are the authoritative source of truth. When in doubt, trust the Python code over intuition, documentation, or the Yellow Paper. The tests are generated from this reference implementation.
