# Guillotine Mini - EVM Implementation

Follow the [Uphill rules](.agents/uphill/rules.md), which `uphill rules --write` rewrites from each metric's description: @.agents/uphill/rules.md

> **Smithers Cloud Coding Factory**: This repository runs publicly on Smithers Cloud at [smithers.sh/evmts/guillotine-mini](https://smithers.sh/evmts/guillotine-mini) with an authenticated MCP server at `https://smithers.sh/evmts/guillotine-mini/mcp` (configured in `.mcp.json`). See [AGENTS.md](AGENTS.md) for the Smithers-first dogfooding contract, one-time sandbox auth (`.smithers/scripts/mint-sandbox-auth.ts`), Obsidian Wiki and Mythical History (`.smithers/wiki/`), and the Lighthouse Backpressure Audit (`bun .smithers/scripts/generate-audit-report.ts`).

Minimal, correct, and well-tested Ethereum Virtual Machine (EVM) implementation in Zig, prioritizing specification compliance, clarity, and hardfork support (Frontier through Amsterdam in the Voltaire enum, with Osaka as the default).

## Quick Start

```bash
zig build unit         # Fast unit tests (plain `zig build` installs nothing)
zig build test         # Native suite (state fixtures and Nethermind are opt-in)
zig build specs        # Run execution-specs state tests
zig build wasm         # Build WebAssembly library
zig build run-examples # Run all ten Zig examples
zig build lean-diff    # Compare the Zig EVM against the Lean 4 oracle

# Debug failing tests (recommended)
bun scripts/isolate-test.ts "test_name"  # Max debug output + analysis
bun scripts/test-subset.ts "pattern"     # Filter test categories
```

## Prerequisites

- Zig 0.15.2
- Cargo (required for BN254/ARK cryptographic dependencies)
- A `../voltaire` checkout at the revision pinned in `native-dependencies.json`
- Python 3 (spec test generation and reference implementation)
- uv (Python package manager for spec fixture generation; execution-specs needs Python 3.11+): `brew install uv`
- Bun (TS helpers/agents): `brew install bun`
- Elan for the `lean-diff` target, which uses the Lean toolchain pinned in `spec/lean/lean-toolchain`

## Architecture

```
src/
├── root.zig              # Public module exports
├── root_c.zig            # C/WASM ABI (native static lib + WASI reactor)
├── evm.zig               # Orchestrator: state, storage, gas refunds, nested calls
├── evm_config.zig        # Comptime EvmConfig limits & opcode/precompile overrides
├── hardfork_hooks.zig    # Fork feature gates, gas schedules, and Glamsterdam transition hooks
├── frame.zig             # Bytecode interpreter: stack, memory, PC, per-opcode logic
├── host.zig              # Abstract state backend interface
├── opcode.zig            # Opcode definitions and utilities
├── trace.zig             # EIP-3155 step tracing, JSONL streaming, ring buffer & TraceDiff
├── inspector.zig         # 15-hook Inspector vtable, 256-bit OpcodeMask, MuxInspector, RevertDecoder
├── tracers.zig           # Built-in tracers (CallTracer, FourByteTracer, PrestateTracer, AccessListInspector, GasProfiler, CoverageInspector)
├── simulation.zig        # StateOverlayHost, state/block overrides, eth_call/estimateGas/createAccessList/simulateV1
├── live_tracer.zig       # BlockHooks, MuxBlockHooks, SupplyTracer (modeled on Geth’s --vmtrace supply)
├── trace_store.zig       # Retention-bounded, reorg-aware, indexed Parity trace_filter store
├── debugger.zig          # Time-travel ExecutionRecorder & DebugSession with 7 breakpoint types
├── flamegraph.zig        # Call-stack & opcode gas FlamegraphCollector (folded stacks + interactive SVG)
├── evmc_adapter.zig      # EVMC ABI 12 types and EvmcHostBridge
└── errors.zig            # Error types

External Dependencies (Voltaire, path dependency on ../voltaire in build.zig.zon):
├── voltaire (primitives) # Ethereum types (Address, u256, Hardfork, gas constants, RLP, ABI, etc.)
├── crypto                # Cryptographic primitives (keccak256, secp256k1, BLS12-381)
└── precompiles           # Ethereum precompiled contracts
```

### Core Responsibilities

| Component | Responsibility |
|-----------|----------------|
| **Evm** (`evm.zig`) | State management, storage, gas refunds, warm/cold tracking, nested calls |
| **Frame** (`frame.zig`) | Stack, memory, PC, bytecode interpretation, opcode execution |
| **HostInterface** (`host.zig`) | Pluggable state backend (balances, nonces, code, storage, account lifecycle) |
| **Hardfork** (`voltaire`) | Gas cost adjustments, feature flag guards (`isAtLeast()`, `isBefore()`, `DEFAULT = .OSAKA`, includes `.AMSTERDAM`) |
| **Tracer** (`trace.zig`) | EIP-3155 step snapshots, JSONL streaming, ring-buffer bounds, `TraceDiff` |
| **Inspector & Tracers** (`inspector.zig`, `tracers.zig`) | Read-only 15-hook vtable, `OpcodeMask`, `MuxInspector`, `RevertDecoder`, and 6 native tracers |
| **Simulation** (`simulation.zig`) | Isolated `StateOverlayHost`, `AccountOverride`/`BlockOverride`, `eth_call`/`estimateGas`/`createAccessList`/`simulateV1` |
| **Live Tracing & Store** (`live_tracer.zig`, `trace_store.zig`) | `BlockHooks`, `MuxBlockHooks`, `SupplyTracer`, and indexed `TraceStore` with `rollbackReorg` |
| **Devtools & EVMC** (`debugger.zig`, `flamegraph.zig`, `evmc_adapter.zig`) | Time-travel `ExecutionRecorder` and `DebugSession`, folded/SVG `FlamegraphCollector`, and EVMC ABI 12 `EvmcHostBridge` |

**Allocation strategy**: Arena allocator for transaction-scoped memory (freed at transaction end).

## Testing and Debugging

### Test Types

| Type | Purpose | Command |
|------|---------|---------|
| Unit tests | Inline `test` blocks | `zig build unit` |
| Spec tests | execution-specs state fixtures | `zig build specs` |
| Filtered tests | By hardfork/EIP/opcode | `TEST_FILTER="Cancun" zig build specs` |
| Trace tests | EIP-3155 trace capture/comparison | `zig build test-trace` |
| Engine tests | Consensus-layer format tests | `INCLUDE_ENGINE_TESTS=1 zig build specs` |

State fixtures and Nethermind are opt-in for `zig build test`. Enable them
with `-Dspecs=true` and `-Dnethermind-diff=true`. A successful full state fill
writes `.filled` in the state fixture directory. For a scoped fill, use the
matching `specs-<fork>-<area>` step with `-Dspecs-use-existing=true`. State
and blockchain test roots are generated independently in Zig's cache.

The [Lean 4 reference specification](spec/lean/README.md) contains executable
semantics and machine-checked theorems. `zig build lean-diff` builds the oracle
and compares it with Zig. `zig build lean-diff-unit` exercises the harness
without Lean.

### Engine API Tests (Optional)

`blockchain_test_engine` format tests are disabled by default because they test consensus-layer functionality (block validation, Engine API payloads) rather than core EVM execution. To include them:

```bash
INCLUDE_ENGINE_TESTS=1 zig build specs
```

### Test Scope and Filtering

- **Hardfork**: `Cancun`, `Shanghai`, `London`, `Berlin`, `Merge`, `Prague`, `Osaka`
- **EIP**: `transientStorage`, `push0`, `MCOPY`, `warmcoinbase`
- **Opcode**: `add`, `mul`, `sstore`, `sload`, `call`, `create2`
- **Category**: `vmArithmeticTest`, `vmBitwiseLogicOperation`, `vmIOandFlowOperations`

### Helper Scripts

<details>
<summary><b>isolate-test.ts - Test Isolation Helper (recommended)</b></summary>

```bash
bun scripts/isolate-test.ts "exact_test_name"
```

**Features:**
- Runs a single test with maximum debug output
- Automatic failure type detection (crash/gas/behavior)
- Trace divergence analysis (PC, opcode, gas, stack)
- Next-step debugging guidance
- Quick reference commands

</details>

<details>
<summary><b>test-subset.ts - Test Subset Runner</b></summary>

```bash
# Using helper scripts
bun scripts/test-subset.ts Cancun
bun scripts/test-subset.ts transientStorage
bun scripts/test-subset.ts MCOPY

# Or using shell scripts
./scripts/test-subset.sh Cancun
./scripts/test-subset.sh "exact_test_name"

# Direct filtering with zig build
TEST_FILTER="Cancun" zig build specs
TEST_FILTER="transientStorage" zig build specs
TEST_FILTER="push0" zig build specs
```

**Use for:** Running entire test categories by hardfork, EIP, or pattern.

</details>

### Granular Spec Targets

`build.zig` defines a `specs-<fork>` step per hardfork and finer `specs-<fork>-<area>`
sub-steps for faster iteration. List them with:

```bash
zig build -l | grep specs-
```

Examples: `specs-shanghai-push0`, `specs-cancun-tstore-basic`,
`specs-cancun-selfdestruct-basic`, `specs-byzantium-modexp`, `specs-istanbul-blake2`.

**Known issue:** the Berlin, Frontier, Prague and Osaka sub-steps (and their
`specs-berlin`, `specs-frontier`, `specs-prague` and `specs-osaka` aggregates)
use regex-style filters such as `berlin.*acl.*`, but `test/utils.zig`
`matchesFilter` does plain substring matching, so those steps select no tests.
Use `TEST_FILTER` with a literal substring for those forks.

### Debugging Workflow

```bash
# 1. Find failures
bun scripts/test-subset.ts transientStorage

# 2. Isolate and debug (get automated analysis)
bun scripts/isolate-test.ts "transStorageReset"

# 3. Fix in src/frame.zig or src/evm.zig
# 4. Verify
bun scripts/isolate-test.ts "transStorageReset"
```

## Spec Fixer (AI-Assisted)

The `scripts/fix-specs.ts` pipeline enforces a mandatory 7-checkpoint methodology for systematic, evidence-based debugging.

### Prereqs

- `bun` installed and `cd scripts && bun install`
- `ANTHROPIC_API_KEY` exported in your shell (or `.env` at repo root)

### Run

```bash
# All suites
bun run scripts/fix-specs.ts

# One suite
bun run scripts/fix-specs.ts suite shanghai-push0
```

Reports are saved in `reports/spec-fixes/`. If no API key is set, it skips auto-fix and just runs the tests.

### 7-Checkpoint System

Each checkpoint requires actual data (no placeholders):

1. Run test and confirm failure (capture output, identify failing tests)
2. Generate trace comparison (`bun scripts/isolate-test.ts`, identify divergence)
3. Read Python reference (quote actual code)
4. Compare Zig implementation (quote actual code)
5. Diagnose root cause and propose fix
6. Implement fix (minimal changes, preserve hardfork guards)
7. Verify fix (re-run tests)

### Known Issues Database

**Location:** `scripts/known-issues.json`

Tracks historical debugging insights:
- Common failure patterns and root causes
- Relevant file locations (with line ranges)
- Python reference locations
- Key invariants
- Expected gas costs

**Schema:**
```json
{
  "test-suite-name": {
    "test_suite": "test-suite-name",
    "description": "Brief description",
    "common_causes": ["Cause 1", "Cause 2"],
    "relevant_files": ["src/file.zig:function", "src/other.zig:line-range"],
    "python_ref": "execution-specs/.../reference.py",
    "key_invariants": ["Invariant 1", "Invariant 2"],
    "gas_costs": { "OPERATION": 100 }
  }
}
```

## Core Components

<details>
<summary><b>Evm (src/evm.zig)</b></summary>

**Orchestrates:**
- State management (storage, balances, nonces, code)
- Call stack (nested CALL/CREATE, max depth 1024)
- Gas accounting (refunds, warm/cold access via EIP-2929)
- Transient storage (EIP-1153, transaction-scoped)
- Hardfork rules (automatic gas adjustment)

**Key methods:**
- `call()` - Main entry point
- `inner_call()` - CALL/STATICCALL/DELEGATECALL
- `inner_create()` - CREATE/CREATE2
- `accessAddress()`, `accessStorageSlot()` - EIP-2929 tracking
- `vm.storage.get()`, `vm.storage.set()` - Persistent storage
- `vm.storage.get_transient()`, `vm.storage.set_transient()` - EIP-1153

</details>

<details>
<summary><b>Frame (src/frame.zig)</b></summary>

**Manages single execution context:**
- 1,024-word default stack (`std.ArrayList(u256)`)
- Expandable contiguous memory (`std.ArrayListUnmanaged(u8)`)
- Program counter (PC) and gas tracking
- Bytecode interpretation

**Key methods:**
- `execute()` - Main execution loop
- `step()` - Single instruction (for tracing)
- Opcode implementations (arithmetic, bitwise, storage, control flow, calls)

</details>

<details>
<summary><b>Host Interface (src/host.zig)</b></summary>

Abstract interface for external state access:

```zig
pub const HostInterface = struct {
    ptr: *anyopaque,
    vtable: *const VTable,
    pub const VTable = struct {
        getBalance: *const fn (ptr: *anyopaque, address: Address) u256,
        setBalance: *const fn (ptr: *anyopaque, address: Address, balance: u256) void,
        getCode: *const fn (ptr: *anyopaque, address: Address) []const u8,
        setCode: *const fn (ptr: *anyopaque, address: Address, code: []const u8) void,
        getStorage: *const fn (ptr: *anyopaque, address: Address, slot: u256) u256,
        setStorage: *const fn (ptr: *anyopaque, address: Address, slot: u256, value: u256) void,
        getNonce: *const fn (ptr: *anyopaque, address: Address) u64,
        setNonce: *const fn (ptr: *anyopaque, address: Address, nonce: u64) void,
        accountExists: ?*const fn (ptr: *anyopaque, address: Address) bool = null,
        accountHasStorage: ?*const fn (ptr: *anyopaque, address: Address) bool = null,
        deleteAccount: ?*const fn (ptr: *anyopaque, address: Address) void = null,
    };
};
```

`Evm.inner_call()` executes nested calls internally. When a host is configured, `HostInterface` provides the external state backend during nested execution as well.

Test implementation: `test/specs/test_host.zig`

</details>

<details>
<summary><b>Hardfork Support (voltaire.Hardfork)</b></summary>

```zig
pub const Hardfork = enum {
    FRONTIER, HOMESTEAD, DAO, TANGERINE_WHISTLE, SPURIOUS_DRAGON,
    BYZANTIUM, CONSTANTINOPLE, PETERSBURG, ISTANBUL, MUIR_GLACIER,
    BERLIN, LONDON, ARROW_GLACIER, GRAY_GLACIER, MERGE,
    SHANGHAI, CANCUN, PRAGUE, OSAKA, AMSTERDAM,
    pub const DEFAULT = Hardfork.OSAKA;
};
```

**Methods:** `isAtLeast(fork)`, `isBefore(fork)`, `fromString(name)`

</details>

<details>
<summary><b>Primitives Module (External Dependency)</b></summary>

Primitives, crypto and precompiles come from Voltaire (https://github.com/evmts/voltaire). `build.zig.zon` resolves it as a path dependency on the sibling `../voltaire` checkout, pinned to the revision in `native-dependencies.json`. Its Zig sources live under `packages/voltaire-zig/src/`.

**Modules provided:**
- **Address** - 20-byte Ethereum address
- **Uint(N)** - Arbitrary precision (u256, u512)
- **GasConstants** - Per-opcode costs, hardfork-aware
- **Rlp** - RLP encoding/decoding
- **Abi** - ABI encoding/decoding
- **Transaction** - Legacy, EIP-2930, EIP-1559, EIP-4844
- **AccessList** - EIP-2930 support
- **Blob** - EIP-4844 blob transactions
- **Hex** - Hex encoding/decoding
- **Crypto** - Cryptographic primitives (keccak256, secp256k1, BLS12-381)
- **Precompiles** - Ethereum precompiled contracts

</details>

## EIP Support

| EIP | Feature | Hardfork | Status |
|-----|---------|----------|--------|
| EIP-2929 | State access gas costs | Berlin | OK |
| EIP-2930 | Access lists | Berlin | OK |
| EIP-1559 | Fee market | London | OK |
| EIP-3198 | BASEFEE opcode | London | OK |
| EIP-3529 | Reduced gas refunds | London | OK |
| EIP-3541 | Reject code starting with 0xEF | London | OK |
| EIP-3651 | Warm coinbase | Shanghai | OK |
| EIP-3855 | PUSH0 instruction | Shanghai | OK |
| EIP-3860 | Limit init code size | Shanghai | OK |
| EIP-1153 | Transient storage (TLOAD/TSTORE) | Cancun | OK |
| EIP-4844 | Blob transactions (BLOBHASH/BLOBBASEFEE) | Cancun | OK |
| EIP-5656 | MCOPY instruction | Cancun | OK |
| EIP-6780 | SELFDESTRUCT only in same tx | Cancun | OK |
| EIP-7516 | BLOBBASEFEE opcode | Cancun | OK |

## Gas Metering

**Location:** Voltaire’s `packages/voltaire-zig/src/primitives/GasConstants/gas_constants.zig`

- Base costs: per-opcode execution (ADD, MUL, SSTORE)
- Memory expansion: quadratic cost for growth
- Call stipend: 2300 gas for value transfers
- Warm/cold access: EIP-2929 (Berlin+): warm=100, cold=2600
- Gas refunds: capped at 1/2 (pre-London) or 1/5 (London+)
- Intrinsic gas: 21000 + calldata costs

## Tracing

Full EIP-3155 trace support:

```bash
zig build test-trace
```

Includes PC, opcode, gas remaining, stack, memory, storage changes. Compare traces against reference implementations (geth, execution-specs) to identify divergences.

## WASM Build

```bash
zig build wasm
# zig-out/bin/guillotine_mini.wasm includes all precompiles.
zig build wasm-core wasm-precompile-02  # Small core plus SHA-256
zig build test-wasm-size                # Raw byte budgets for every artifact
```

<details>
<summary><b>Exported C API Functions</b></summary>

- `evm_create()`, `evm_destroy()`
- `evm_set_bytecode()`, `evm_set_execution_context()`, `evm_set_blockchain_context()`
- `evm_execute()`, `evm_get_gas_remaining()`, `evm_get_gas_used()`
- `evm_is_success()`, `evm_get_output_len()`, `evm_get_output()`
- `evm_set_storage()`, `evm_get_storage()`, `evm_set_balance()`, `evm_set_code()`

See `src/root_c.zig` for full API.

</details>

## Development Workflow

### Build Targets

| Command | Purpose |
|---------|---------|
| `zig build unit` | Unit tests only (fast) |
| `zig build test` | Native tests |
| `zig build test-utils` | Test runner utility tests |
| `zig build check-bench-evm` | Compile and link the EVM benchmark |
| `zig build run-examples` | Run the ten Zig examples |
| `zig build specs` | Spec tests only |
| `zig build native` | C ABI static library |
| `zig build wasm` | WASI reactor library |
| `zig build test-wasm` | WASM execution and crypto regression tests (Node 22+) |
| `zig build test-trace` | Trace capture tests |

Smithers discovers incremental CI and benchmark targets in `PACKAGE.ts`.
See the [workspace guide](.smithers/README.md) for setup and commands.

### Adding New Features

1. Implement in `src/frame.zig` (opcodes) or `src/evm.zig` (behavior)
2. Update gas in Voltaire’s `packages/voltaire-zig/src/primitives/GasConstants/gas_constants.zig` if needed
3. Add guards: `self.hardfork.isAtLeast(.FORK_NAME)`
4. Test: run relevant spec tests
5. Debug: use trace divergence analysis

### Code Style

- Naming: `snake_case` (functions/variables), `PascalCase` (types)
- Errors: explicit unions, propagate with `try`
- Comments: explain why, not what
- Docs: use `///` for public APIs
- Format: run `zig fmt` before commit

## Agent Reference: Python Specs vs Zig Implementation

**Critical for debugging:** Python execution-specs are authoritative. When in doubt, trust Python code over intuition, docs, or the Yellow Paper.

**Important:** `execution-specs/` is a git submodule containing official Ethereum execution specs. Never commit, clean, or modify any files within this submodule.

### File Location Mapping

| Problem Area | Python Reference | Zig Implementation |
|--------------|------------------|-------------------|
| Opcode logic | `execution-specs/.../vm/instructions/*.py` | `src/frame.zig` |
| Gas calculation | `execution-specs/.../vm/gas.py` | Voltaire’s `packages/voltaire-zig/src/primitives/GasConstants/gas_constants.zig` + `src/frame.zig` |
| Call/Create | `execution-specs/.../vm/instructions/system.py` | `src/evm.zig` (`inner_call`, `inner_create`) |
| Storage ops | `execution-specs/.../vm/instructions/storage.py` | `vm.storage.get()` and `vm.storage.set()` in `src/storage.zig` |
| Transient storage | `execution-specs/forks/cancun/.../storage.py` | `vm.storage.get_transient()` and `vm.storage.set_transient()` in `src/storage.zig` |
| State management | `execution-specs/.../state.py` | `src/evm.zig` (balances, nonces, code) |
| Hardfork activation | `execution-specs/forks/<hardfork>/` | Voltaire’s `packages/voltaire-zig/src/primitives/Hardfork/hardfork.zig` |
| Warm/cold tracking | `execution-specs/.../vm/__init__.py` | `vm.access_list_manager` in `src/evm.zig` |
| Memory ops | `execution-specs/.../vm/memory.py` | `Frame.ensureMemoryBytes()` in `src/frame.zig` |
| Stack ops | `execution-specs/.../vm/stack.py` | `src/frame.zig` (pushStack, popStack) |

### Architectural Differences

**Python: Single `Evm` class**
- Location: `execution-specs/.../vm/__init__.py`
- One dataclass: `evm.stack`, `evm.memory`, `evm.pc`, `evm.gas_left`, `evm.message.block_env.state`

**Zig: Split `Evm` + `Frame`**
- **Evm** (`src/evm.zig`): State, storage, gas refunds, nested calls
  - Persistent, transient, and original slot state: `vm.storage`
  - Warm/cold tracking: `vm.access_list_manager`
  - Gas: `gas_refund`
- **Frame** (`src/frame.zig`): Single call frame execution
  - Stack, memory, PC, gas, bytecode
  - Per-frame context: caller, address, value, calldata

**Key mapping:** Python's `evm.stack` -> Zig's `frame.stack`. Python's `evm.message.block_env.state` -> Zig's `evm.storage`/`evm.balances`.

## Common Bug Patterns

<details>
<summary><b>1. Gas Metering Bugs (SSTORE example)</b></summary>

**Python pattern:**
```python
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

**Common mistakes:**
- Forgetting `SstoreSentryGas` (2300) check
- Not tracking `original_storage` separately from `storage`
- Wrong gas refund calculation
- Not adding cold access cost before warm/set/update

</details>

<details>
<summary><b>2. Warm/Cold Access Tracking (EIP-2929)</b></summary>

**Python:**
```python
accessed_addresses: Set[Address]
accessed_storage_keys: Set[Tuple[Address, Bytes]]

if address not in evm.accessed_addresses:
    evm.accessed_addresses.add(address)
    charge_gas(evm, GAS_COLD_ACCOUNT_ACCESS)
else:
    charge_gas(evm, GAS_WARM_ACCESS)
```

**Zig:**
```zig
warm_addresses: ArrayHashMap(Address, void, AddressContext, false)
warm_storage_slots: ArrayHashMap(StorageSlotKey, void, StorageSlotKeyContext, false)

if (!self.warm_addresses.contains(address)) {
    try self.warm_addresses.put(address, {});
    return ColdAccountAccessCost;
} else {
    return WarmStorageReadCost;
}
```

**Key difference:** Python uses sets; Zig uses hash maps with `void` values.

</details>

<details>
<summary><b>3. Transient Storage (EIP-1153)</b></summary>

**Python:**
```python
def tload(evm: Evm) -> None:
    key = pop(evm.stack).to_be_bytes32()
    charge_gas(evm, GAS_WARM_ACCESS)  # Always warm, never cold
    value = get_transient_storage(...)
    push(evm.stack, value)

def tstore(evm: Evm) -> None:
    key = pop(evm.stack).to_be_bytes32()
    new_value = pop(evm.stack)
    charge_gas(evm, GAS_WARM_ACCESS)  # Always warm
    if evm.message.is_static:
        raise WriteInStaticContext
    set_transient_storage(...)
```

**Critical rules:**
- Transient storage is always warm (100 gas), never cold
- Cleared at transaction boundaries, not call boundaries
- Must check `is_static` for TSTORE
- No gas refunds

</details>

<details>
<summary><b>4. Hardfork-Specific Behavior</b></summary>

**Python:** Separate directories (`execution-specs/forks/berlin/`, `cancun/`), each fork inherits and overrides.

**Zig:** Runtime checks in one codebase:
```zig
if (self.hardfork.isAtLeast(.CANCUN)) {
    // Cancun-specific (EIP-1153, EIP-4844)
} else if (self.hardfork.isAtLeast(.SHANGHAI)) {
    // Shanghai-specific (PUSH0, warm coinbase)
}
```

**Common mistakes:**
- Wrong hardfork for feature (e.g., PUSH0 before Shanghai)
- Not using `isAtLeast` for backward compatibility
- Breaking earlier hardforks when adding new feature

</details>

## Gas Constant Reference

Must match exactly between Python and Zig.

<details>
<summary><b>Gas Constants Table</b></summary>

| Operation | Python | Zig | Value | Hardfork |
|-----------|--------|-----|-------|----------|
| Warm storage read | `GAS_WARM_ACCESS` | `WarmStorageReadCost` | 100 | Berlin+ |
| Cold SLOAD | `GAS_COLD_SLOAD` | `ColdSloadCost` | 2100 | Berlin+ |
| Cold account access | `GAS_COLD_ACCOUNT_ACCESS` | `ColdAccountAccessCost` | 2600 | Berlin+ |
| SSTORE set (0->nonzero) | `GAS_STORAGE_SET` | `SstoreSetGas` | 20000 | All |
| SSTORE update (nonzero->nonzero) | `GAS_STORAGE_UPDATE` | `SstoreResetGas` | 5000 | All |
| SSTORE clear refund | `GAS_STORAGE_CLEAR_REFUND` | `SstoreRefundGas` | 4800 | London+ |
| SSTORE stipend check | `GAS_CALL_STIPEND` | `SstoreSentryGas` | 2300 | All |
| Call value transfer | `GAS_CALL_VALUE` | `CallValueCost` | 9000 | All |
| Call stipend | `GAS_CALL_STIPEND` | `CallStipend` | 2300 | All |

**Locations:**
- Python: `execution-specs/src/ethereum/forks/<hardfork>/vm/gas.py`
- Zig: Voltaire’s `packages/voltaire-zig/src/primitives/GasConstants/gas_constants.zig`

</details>

## Debugging Workflow Cheat Sheet

1. Run with trace
   ```bash
   TEST_FILTER="exact_test_name" zig build specs
   # Or: bun scripts/isolate-test.ts "exact_test_name"
   ```
2. Identify divergence (PC, opcode, gas remaining, stack state)
3. Find Python reference
   ```bash
   cd execution-specs/src/ethereum/forks/cancun/vm/instructions/
   grep -r "def <opcode_name>" .
   ```
4. Compare Zig implementation
   - Opcodes: `src/frame.zig`
   - Calls/creates: `src/evm.zig`
   - Storage: `src/storage.zig`
5. Fix minimally, preserve hardfork guards
6. Verify
   ```bash
   TEST_FILTER="exact_test_name" zig build specs
   ```

## Pro Tips

1. Gas calculation order matters: match Python's exact sequence
2. Original vs current storage: track both for refund calculations
3. Warm/cold is cumulative: once warm, stays warm for entire transaction
4. Refund counter can go negative: cap only at transaction end
5. Static context propagates: STATICCALL -> all child calls inherit `is_static`
6. Memory expansion is quadratic: `size_in_words ** 2 // 512`
7. Call depth limit is 1024: check before any CALL/CREATE

## Anti-Patterns

- Guessing gas costs (must match Python exactly)
- Skipping trace comparison (shows exact divergence point)
- Mixing hardfork behaviors (use `isAtLeast` guards)
- Ignoring error conditions (Python `raise` must map to Zig errors)
- Hardcoding test-specific logic (fix general implementation)
- Forgetting to charge gas before operations (Python charges first)
- Modifying test files (only change `src/` implementations)
- Silently ignoring errors with `catch {}` (forbidden; handle or `try`)
- Creating `.backup`/`.bak`/`.old` files (use git instead)

## Resources

- ethereum/tests: https://github.com/ethereum/tests
- execution-specs: https://github.com/ethereum/execution-specs
- EIP Index: https://eips.ethereum.org/
- EIP-3155 (Trace Format): https://eips.ethereum.org/EIPS/eip-3155
- Yellow Paper: https://ethereum.github.io/yellowpaper/paper.pdf
- Zig Documentation: https://ziglang.org/documentation/
- [Glamsterdam hardfork roadmap](docs/HARDFORK_ROADMAP.md)
- [Three rounds of audit reviews](docs/reviews/)

## File Summary

<details>
<summary><b>Core Implementation Files</b></summary>

| File | Purpose | Key Exports |
|------|---------|-------------|
| `src/root.zig` | Main module | Evm, Frame, HostInterface, Hardfork, Tracer, Inspector, tracers, simulation, live_tracer, trace_store, ExecutionRecorder, DebugSession, debugger, flamegraph, evmc_adapter |
| `src/root_c.zig` | C & WASM FFI | `evm_*` exports for execution, pre-state, tracing, call/access-list tracers, and async injection |
| `src/evm.zig` | EVM orchestrator | Evm struct, call(), callWithBytecodeOverride(), inner_call(), inner_create(), setInspector() |
| `src/evm_config.zig` | EVM config | EvmConfig (wired limits & overrides), fromBuildOptions() |
| `src/frame.zig` | Bytecode interpreter | Frame struct, execute(), step() |
| `src/host.zig` | Host interface | HostInterface |
| `src/opcode.zig` | Opcode utilities | getOpName(), opcode constants |
| `src/trace.zig` | EIP-3155 tracing | Tracer, TraceEntry, TraceSummary, TraceDiff |
| `src/inspector.zig` | Execution hooks | Inspector, MuxInspector, OpcodeMask, CallType, RevertDecoder, DecodedRevert |
| `src/tracers.zig` | Built-in tracers | CallTracer, FourByteTracer, PrestateTracer, AccessListInspector, GasProfiler, CoverageInspector |
| `src/simulation.zig` | Simulation engine | StateOverlayHost, AccountOverride, BlockOverride, CallRequest, simulateCall, estimateGas, createAccessList, simulateV1 |
| `src/live_tracer.zig` | Live block tracing | BlockHooks, MuxBlockHooks, SupplyTracer |
| `src/trace_store.zig` | Trace indexing | TraceStore, TraceFilter, rollbackReorg |
| `src/debugger.zig` | Time-travel debugger | ExecutionRecorder, DebugSession, Breakpoint, SourceMapResolver |
| `src/flamegraph.zig` | Gas flamegraphs | FlamegraphCollector, AddressLabeler (folded stacks + SVG) |
| `src/evmc_adapter.zig` | EVMC ABI 12 bridge | EvmcHostBridge, EvmcHostInterface, EvmcMessage, EvmcResult, EvmcRevision |
| `src/errors.zig` | Error types | CallError error set |
| `src/primitives/root.zig` | Primitives exports | All primitive types |
| `build.zig` | Build config | Build targets, dependencies |
| `test_runner.zig` | Test runner | Test execution, reporting |
| `test/specs/runner.zig` | Spec test execution | runJsonTest(), trace comparison |

</details>

In EVMC ABI 12, `EvmcRevision.experimental` has value `15`. `evmc_adapter.fromHardfork` maps forks newer than Osaka, including `.AMSTERDAM`, to `.experimental`. `evmc_adapter.toHardfork(.experimental)` returns the newest fork in Voltaire.

## Contributing

When making changes:

1. Ensure all tests pass (`zig build test`)
2. Run spec tests for affected hardfork
3. Format code (`zig fmt src/ test/`)
4. Add tests for new features
5. Update documentation

## Full Client (Guillotine) - Specs and Submodules

This repo is evolving from an EVM-only library into a full Ethereum execution client ("Guillotine"), mirroring Nethermind's architecture in Zig.

**Plan:** See `prd/GUILLOTINE_CLIENT_PLAN.md` for the phased implementation plan.
**Spec reference:** See `prd/ETHEREUM_SPECS_REFERENCE.md` for the full source map.

### Submodules for specs and tests

| Submodule | Purpose |
|---|---|
| `execution-specs/` | EELS - authoritative Python EL spec (state transitions, fork rules) |
| `EIPs/` | Ethereum Improvement Proposals (normative change log) |
| `execution-apis/` | JSON-RPC + Engine API (OpenRPC spec) |
| `ethereum-tests/` | Classic JSON test fixtures (TrieTests, GeneralStateTests, BlockchainTests) |
| `execution-spec-tests/` | Python-generated EVM + state transition test fixtures |

External references include devp2p for networking formats, Hive for integration
tests, the consensus specs for beacon chain and SSZ, the Yellow Paper for
historical background, and Nethermind for architecture.

### Existing Zig Libraries

| Library | Location | Provides |
|---|---|---|
| **Voltaire** | `../voltaire/packages/voltaire-zig/` | All primitives, RLP, SSZ, Crypto, Precompiles, JSON-RPC types, JournaledState, Blockchain, StateManager |
| **Guillotine-Mini** | `src/` (this repo) | EVM engine (frame, opcodes, gas, Voltaire hardforks with Osaka as the default) |

### Source Priority (when in doubt)

1. `execution-specs/` + `EIPs/` - for EVM + state transition behavior
2. devp2p - for networking wire formats
3. `execution-apis/` - for JSON-RPC and Engine API
4. `ethereum-tests/` + `execution-spec-tests/` - for correctness validation
5. Nethermind - external architecture reference

### Key Rules for Full Client Work

- Never modify files in submodules (`execution-specs`, `EIPs`, etc.)
- Use Voltaire primitives for all types (Address, Block, Tx, Hash, RLP, Crypto, etc.)
- Use guillotine-mini EVM for execution (do not build a new EVM)
- Validate every phase against official test suites (see plan for mapping)
- Mirror Nethermind's module boundaries for architecture consistency
