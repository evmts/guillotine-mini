# Context: [pass 1/5] phase-4-blockchain (Block Chain Management)

This file captures the minimal, implementation-ready context for Phase 4 — Block Chain Management — to guide coding work in small, atomic units while strictly adhering to Voltaire primitives and guillotine-mini’s existing EVM.

## Goals (from PRD: prd/GUILLOTINE_CLIENT_PLAN.md)
- Manage the block chain structure and validation.
- Initial targets (files to implement in this phase):
  - `client/blockchain/chain.zig` — chain management (canonical head, forks, reorgs, headers, bodies, receipts linkage)
  - `client/blockchain/validator.zig` — block validation (header/bodies, PoS-era rules via execution-specs)
- Architectural guidance: Mirror Nethermind’s module boundaries, implement idiomatically in Zig with comptime DI.

## Spec References (from prd/ETHEREUM_SPECS_REFERENCE.md)
Primary sources for block validation and chain rules (Python EL spec):
- `execution-specs/src/ethereum/forks/frontier/fork.py`
- `execution-specs/src/ethereum/forks/frontier/blocks.py`
- `execution-specs/src/ethereum/forks/london/fork.py`
- `execution-specs/src/ethereum/forks/shanghai/fork.py`
- `execution-specs/src/ethereum/forks/cancun/fork.py`
- `execution-specs/src/ethereum/forks/paris/fork.py`
Notes:
- Use the fork-specific `fork.py` and `blocks.py` for block/header validation logic per hardfork.
- Yellow Paper Section 11 (Block Finalization) informs high-level invariants but we implement from execution-specs behavior.

## Nethermind Reference (structure only)
- Listed for this pass per instructions: `nethermind/src/Nethermind/Nethermind.Db/`
  - Key interfaces and types relevant for storage wiring and abstraction boundaries:
    - `IDb.cs`, `IColumnsDb.cs`, `IDbProvider.cs`, `DbProvider.cs`, `ReadOnlyDb.cs`, `ReadOnlyDbProvider.cs`
    - `MemDb.cs`, `MemColumnsDb.cs`, `InMemoryWriteBatch.cs`, `InMemoryColumnBatch.cs`
    - `RocksDbSettings.cs`, `CompressingDb.cs`, `Metrics.cs`
  - Rationale for Phase 4: Chain data (headers, bodies, receipts) persist via DB; align boundaries with these abstractions.
- Additional architecture to mirror (not listed in step but relevant): `nethermind/src/Nethermind/Nethermind.Blockchain/` for chain/validator structure and naming.

## Voltaire Primitives and Blockchain APIs (must use — never custom types)
From `/Users/williamcory/voltaire/packages/voltaire-zig/src/`:
- `blockchain/Blockchain.zig` — canonical chain management APIs
- `blockchain/BlockStore.zig` — block storage abstraction
- `blockchain/ForkBlockCache.zig` — fork-aware caching utilities
- `primitives/` (selected, relevant types only):
  - `BlockHeader/`, `Block/`, `BlockHash/`, `BlockNumber/`
  - `Rlp/`, `Hash/`, `Uint/` (`uint256` et al.), `StateRoot/`, `BloomFilter/`, `Receipt/`
- `crypto/` (for hashing as required by specs; e.g., keccak)
- Strict Rule: Do not introduce custom structs that duplicate these primitives.

## Host Interface (existing guillotine-mini EVM integration)
Source: `src/host.zig`
- Provides minimal `HostInterface` with vtable for: `getBalance`, `setBalance`, `getCode`, `setCode`, `getStorage`, `setStorage`, `getNonce`, `setNonce` using Voltaire `Address` and `u256`.
- Note: Nested calls are handled internally by EVM (`inner_call`); HostInterface is for external state access only.
- Implication for Phase 4: Block validation should not reimplement EVM; instead, wire world-state access/DB via HostInterface-compatible adapters if execution is needed by validator.

## Test Fixtures
- `ethereum-tests/BlockchainTests/` (classic JSON tests)
- `execution-spec-tests/fixtures/blockchain_tests/` (symlinked to `ethereum-tests/BlockchainTests` in this repo)

## Immediate Implementation Notes
- Use comptime dependency injection patterns consistent with EVM modules.
- Keep units small and testable; every public function must have `test` coverage.
- No silent error handling; propagate errors explicitly.
- Performance: Avoid allocations in hot paths; reuse buffers; prefer arenas where applicable.

## Paths Summary
- PRD: `prd/GUILLOTINE_CLIENT_PLAN.md`
- Specs: `prd/ETHEREUM_SPECS_REFERENCE.md`, `execution-specs/src/ethereum/forks/*/(fork.py|blocks.py)`
- Nethermind: `nethermind/src/Nethermind/Nethermind.Db/` (plus `Nethermind.Blockchain` for structure)
- Voltaire: `/Users/williamcory/voltaire/packages/voltaire-zig/src/(blockchain|primitives|crypto)`
- EVM Host: `src/host.zig`
- Tests: `ethereum-tests/BlockchainTests/`, `execution-spec-tests/fixtures/blockchain_tests/`
