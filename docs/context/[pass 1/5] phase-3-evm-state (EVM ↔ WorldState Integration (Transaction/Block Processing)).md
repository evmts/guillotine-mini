# [pass 1/5] phase-3-evm-state — EVM ↔ WorldState Integration (Transaction/Block Processing)

This context file aggregates the exact paths and authoritative references to implement Phase 3, focused on wiring the EVM to the WorldState for transaction and block processing in Effect.ts (client-ts), using the existing Guillotine EVM as behavioral reference and Nethermind for architectural boundaries.

## Phase Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Connect EVM to WorldState for transaction/block processing.
- Key components to implement/port:
  - `client/evm/host_adapter.zig` → Effect.ts Host adapter mirroring `src/host.zig` semantics.
  - `client/evm/processor.zig` → Effect.ts Transaction processor wrapping EVM execution over journaled state.
- Architectural references: `nethermind/src/Nethermind/Nethermind.Evm/` (module boundaries and responsibilities), plus DB surfaces from Nethermind.Db for persistence APIs used by higher layers.

## Specs To Follow (from prd/ETHEREUM_SPECS_REFERENCE.md)
Authoritative execution rules live in `execution-specs` per-fork. Prioritize latest activated hardforks for correctness, fall back to earlier forks for deltas.

- VM core (Cancun as current baseline):
  - `execution-specs/src/ethereum/forks/cancun/vm/__init__.py` — EVM entry (stack/memory/gas core)
  - `execution-specs/src/ethereum/forks/cancun/fork.py` — Transaction and block processing glue
- Additional per-fork references (when needed for pre/post-Cancun behavior):
  - `execution-specs/src/ethereum/forks/shanghai/vm/__init__.py`, `.../shanghai/fork.py`
- Cross-cutting:
  - `execution-specs/src/ethereum/forks/cancun/state.py` — World state transitions
  - `execution-specs/src/ethereum/forks/cancun/transactions.py` — TX validation/normalization

These files define the source of truth for gas accounting, access lists, warm/cold rules, refunds, receipts, logs, and state root updates.

## Guillotine EVM Reference (this repo)
- `src/evm.zig` — EVM engine (behavioral reference; do not reimplement semantics in TS)
- `src/host.zig` — Minimal HostInterface used by the EVM for external state access
  - Methods: `getBalance`, `setBalance`, `getCode`, `setCode`, `getStorage`, `setStorage`, `getNonce`, `setNonce`
  - Note: Nested calls are handled internally by `EVM.inner_call`; the HostInterface is for outer world-state interactions.

## Nethermind Architectural References
While this phase focuses on EVM↔State wiring, DB APIs and layering inform boundaries and lifecycles. Key DB files (for naming and separation of concerns):
- `nethermind/src/Nethermind/Nethermind.Db/IDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs` — DB surfaces
- `DbProvider.cs`, `IDbProvider.cs`, `ReadOnlyDbProvider.cs` — provider abstraction
- `MemDb.cs`, `MemColumnsDb.cs`, `MemDbFactory.cs` — in-memory impls (useful for tests)
- `RocksDbSettings.cs`, `CompressingDb.cs`, `SimpleFilePublicKeyDb.cs` — persistence details
- `PruningConfig.cs`, `IPruningConfig.cs`, `FullPruning/*` — pruning strategies
- `Metrics.cs` — instrumentation surfaces

EVM module (for structure, not code): `nethermind/src/Nethermind/Nethermind.Evm/` (use to mirror responsibilities like Host/State adapters, precompile handling, execution tracing, and gas accounting separation).

## Voltaire Zig APIs (upstream primitives and state manager)
Base path: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- EVM core:
  - `evm/evm.zig`, `evm/frame.zig`, `evm/host.zig`, `evm/precompiles/*`
- State management:
  - `state-manager/JournaledState.zig`, `state-manager/StateManager.zig`, `state-manager/ForkBackend.zig`
- Primitives used pervasively:
  - `primitives/Address`, `primitives/Hash`, `primitives/Hex`, `primitives/Transaction`, `primitives/Uint/*`, `primitives/Storage*`, `primitives/Receipt`, `primitives/Block*`

These inform how to shape the Effect.ts services and data models. In TS, always import from `voltaire-effect/primitives` rather than redefining types.

## Test Fixtures
- ethereum-tests (classic fixtures): `ethereum-tests/`
  - Present dirs: `ABITests/`, `BasicTests/`, `BlockchainTests/`, `DifficultyTests/`, `EOFTests/`, `GenesisTests/`, `RLPTests/`, `TransactionTests/`, `TrieTests/`, `PoWTests/`
  - General state tests (tarball present, not extracted): `ethereum-tests/fixtures_general_state_tests.tgz`
- execution-spec-tests (Python-generated fixtures): `execution-spec-tests/`
  - `execution-spec-tests/fixtures/blockchain_tests` → symlink to `ethereum-tests/BlockchainTests`
  - Additional state test fixtures may need to be generated/extracted if required for this pass.

## Implementation Notes for Effect.ts (client-ts)
- Services as `Context.Tag`s with `Layer`-based DI:
  - `HostAdapter` service: translates EVM host calls to WorldState reads/writes.
  - `EvmProcessor` service: validates+executes TXs, produces receipts, updates state roots.
- Composition style: `Effect.gen(function* () { ... })` and typed error channels (`Data.TaggedError`).
- Resource safety: use `Effect.acquireRelease` where world-state snapshots/journals require cleanup.
- Tests: `@effect/vitest` with `it.effect()`; cover each public function (host adapter methods, tx processing entry), and verify against canonical fixtures (start with small `BlockchainTests` cases; expand to `GeneralStateTests` once extracted).

## Quick Path Index
- Plan: `prd/GUILLOTINE_CLIENT_PLAN.md` (Phase 3 section)
- Specs: `execution-specs/src/ethereum/forks/cancun/vm/__init__.py`, `.../cancun/fork.py`, `.../cancun/state.py`, `.../cancun/transactions.py`
- EVM host (this repo): `src/host.zig`
- Nethermind DB surfaces: `nethermind/src/Nethermind/Nethermind.Db/`
- Voltaire Zig (reference APIs): `/Users/williamcory/voltaire/packages/voltaire-zig/src/{evm,state-manager,primitives}`
- Fixtures: `ethereum-tests/`, `execution-spec-tests/fixtures/blockchain_tests`

