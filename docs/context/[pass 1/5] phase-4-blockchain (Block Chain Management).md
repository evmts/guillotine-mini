# Context — [pass 1/5] phase-4-blockchain (Block Chain Management)

This file collects the minimal, high-signal references needed to implement Phase 4 (Block Chain Management) in Guillotine. It ties PRD goals to spec sources, Nethermind structure, and Voltaire primitives that we MUST use. EVM reimplementation is forbidden; we integrate with the existing `src/` EVM and Voltaire types exclusively.

## Phase Goal (from PRD)
- Manage the block chain structure and validation.
- Key Zig components to implement next:
  - `client/blockchain/chain.zig` — chain management (canonical head selection, forks, reorgs)
  - `client/blockchain/validator.zig` — block/header validation pipeline
- References: `nethermind/src/Nethermind/Nethermind.Blockchain/`, Voltaire: `voltaire-zig/src/blockchain/`
- Tests: `ethereum-tests/BlockchainTests/`

Source: `prd/GUILLOTINE_CLIENT_PLAN.md` (Phase 4: Block Chain Management)

## Spec Files (authoritative)
Primary: per-fork validation logic lives in `execution-specs/src/ethereum/forks/*/fork.py`.
- Examples we will map against during validation:
  - `execution-specs/src/ethereum/forks/frontier/fork.py`
  - `execution-specs/src/ethereum/forks/homestead/fork.py`
  - `execution-specs/src/ethereum/forks/london/fork.py`
  - `execution-specs/src/ethereum/forks/paris/fork.py` (The Merge)
  - `execution-specs/src/ethereum/forks/shanghai/fork.py`
  - `execution-specs/src/ethereum/forks/cancun/fork.py`
  - `execution-specs/src/ethereum/forks/prague/fork.py` (upcoming)

Supporting (block processing/fields across forks):
- `execution-specs/src/ethereum/forks/*/blocks.py` — block assembly and per-fork block invariants

Yellow Paper: Section 11 (Block finalization) — for conceptual guidance only; Python specs are the source of truth.

Source: `prd/ETHEREUM_SPECS_REFERENCE.md`

## Nethermind Reference (structural only)
We mirror architecture, not types/behavior. Key areas for Phase 4:
- `nethermind/src/Nethermind/Nethermind.Blockchain/`
  - `BlockTree.cs`, `ReadOnlyBlockTree.cs`, `BlockTree.Initializer.cs` — chain/fork tree management
  - `Headers/` — header handling utilities
  - `Services/`, `Spec/`, `Utils/` — block import pipeline and helpers
  - `AddBlockResult.cs`, `BlockchainException.cs` — result and error surfaces

Additionally, database abstractions (used by BlockTree-like components):
- `nethermind/src/Nethermind/Nethermind.Db/` (key files noted)
  - `IDb.cs`, `IReadOnlyDb.cs`, `IColumnsDb.cs` — interfaces
  - `MemDb.cs`, `MemColumnsDb.cs`, `InMemory*Batch.cs` — in-memory implementations
  - `DbProvider.cs`, `IDbProvider.cs`, `ReadOnlyDbProvider.cs` — provider pattern
  - `RocksDb*` types, `Pruning*` — RocksDB integration and pruning

We will implement analogous functionality idiomatically in Zig with comptime DI, but persist data using our Phase 0 DB adapter and Voltaire primitives.

## Voltaire APIs to use (no custom duplicates)
Primitives (types/encodings):
- `voltaire-zig/src/primitives/Block.zig`
- `voltaire-zig/src/primitives/BlockHeader.zig`
- `voltaire-zig/src/primitives/BlockBody.zig`
- `voltaire-zig/src/primitives/BlockHash.zig`
- `voltaire-zig/src/primitives/Chain.zig`, `ChainHead.zig`
- `voltaire-zig/src/primitives/Receipt.zig`, `StateRoot.zig`, `Rlp.zig`
- `voltaire-zig/src/primitives/Hardfork.zig`

Blockchain helpers:
- `voltaire-zig/src/blockchain/Blockchain.zig`
- `voltaire-zig/src/blockchain/BlockStore.zig`
- `voltaire-zig/src/blockchain/ForkBlockCache.zig`

State manager (for header/state-root checks as needed via host integration):
- `voltaire-zig/src/state-manager/StateManager.zig`, `JournaledState.zig`

We MUST construct/consume only these Voltaire types. No parallel `struct` definitions for headers, blocks, hashes, receipts, etc.

## Existing Zig Host Interface (integration note)
`src/host.zig` exposes a minimal `HostInterface` with a vtable for `get/setBalance`, `get/setCode`, `get/setStorage`, `get/setNonce` using `primitives.Address` and `u256`.
- Nested calls are handled internally by EVM; the host is for external state access only.
- Our block import/validation will use Voltaire primitives and world-state integrations without bypassing this contract.

## Test Fixtures (to wire up during Phase 4)
- `ethereum-tests/BlockchainTests/` — canonical EL blockchain tests
- Additional (from PRD mapping; not required for this pass): `execution-spec-tests/fixtures/blockchain_tests/`

## Implementation Notes (for next pass planning)
- Start from header validation functions in `execution-specs/.../fork.py` and map invariants to Voltaire `BlockHeader` fields.
- Use comptime DI to abstract storage (Phase 0 adapter) and fork rules (select via `primitives.Hardfork`).
- Keep functions small and testable; every public function MUST have a unit test.
- Never silence errors; surface precise error unions and messages.
- Hot-path allocations are forbidden; reuse buffers and leverage `Rlp` primitives for encoding/decoding.

