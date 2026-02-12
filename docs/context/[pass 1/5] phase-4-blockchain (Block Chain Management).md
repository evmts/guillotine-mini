# [pass 1/5] Phase 4 — Block Chain Management (Focused Context)

This context consolidates the exact references and APIs needed to implement Phase 4 (Block Chain Management) using Voltaire primitives and the existing guillotine-mini EVM. It is intentionally narrow and implementation‑oriented.

## Goals (from PRD)
- Manage the block chain structure and validation.
- Key components to implement in this phase:
  - `client/blockchain/chain.zig` — chain management
  - `client/blockchain/validator.zig` — block validation
- Architectural references:
  - Nethermind: `nethermind/src/Nethermind/Nethermind.Blockchain/`
  - Voltaire: `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/`
- Test fixtures:
  - `ethereum-tests/BlockchainTests/`

Source: prd/GUILLOTINE_CLIENT_PLAN.md (Phase 4 section)

## Spec References
Primary sources to drive correctness (do not diverge):
- execution-specs (block validation across forks):
  - `execution-specs/src/ethereum/forks/*/fork.py` (header + ommers validation, basefee where applicable)
    - Examples located under: `frontier`, `homestead`, `byzantium`, `constantinople`, `istanbul`, `muir_glacier`, `gray_glacier`, `london`, `arrow_glacier`, etc.
- Yellow Paper: Section 11 (Block Finalization) — canonical chain and block validity conditions.
- EIPs affecting block header semantics for PoS era:
  - `EIPs/EIPS/eip-3675.md` (The Merge — removes PoW fields, constant ommers, total difficulty handling frozen, consensus via CL)
  - `EIPs/EIPS/eip-4399.md` (PREVRANDAO — replaces DIFFICULTY semantics, header field update)

Ancillary sources (for helpers / serialization):
- `execution-specs/src/ethereum/rlp.py` (reference RLP behavior)
- `execution-specs/src/ethereum_spec_tools/evm_tools/loaders/fixture_loader.py` (how blockchain fixtures compute header/hash)

## Nethermind — Db Layer (for storage patterns)
List of key files to mirror interfaces/concerns (read-only architectural reference):
- `nethermind/src/Nethermind/Nethermind.Db/IDb.cs` — base DB interface
- `nethermind/src/Nethermind/Nethermind.Db/IDbProvider.cs` — provider composition
- `nethermind/src/Nethermind/Nethermind.Db/DbProvider.cs` — provider implementation
- `nethermind/src/Nethermind/Nethermind.Db/MemDb.cs` — in-memory DB
- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDb.cs` — read-only facade
- `nethermind/src/Nethermind/Nethermind.Db/RocksDbSettings.cs` — RocksDB configuration
- `nethermind/src/Nethermind/Nethermind.Db/PruningConfig.cs` — pruning concerns

These inform how we slice read/write surfaces and column abstractions. We will implement idiomatically in Zig using existing Phase 0 DB adapter.

## Voltaire APIs to Use (no custom types)
Prefer these modules/types for chain management:
- `primitives.Block.Block` — full block type
- `primitives.BlockHeader.BlockHeader` — header fields
- `primitives.BlockHash.BlockHash` and `primitives.Hash.Hash` — hashing
- `primitives.Rlp` — RLP encode/decode
- `primitives.StateRoot.StateRoot`, `primitives.BloomFilter.BloomFilter`
- `blockchain.Blockchain` — unified local/remote view
- `blockchain.BlockStore` — local storage/canonical tracking
- `blockchain.ForkBlockCache` — optional remote read cache

Filesystem locations:
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/`

## Host Interface (guillotine-mini)
File: `src/host.zig`
- Minimal host for EVM state access (balance, code, storage, nonce) via vtable.
- EVM nested calls are handled internally; host is for external state reads/writes.
- For Phase 4, host informs how we’ll surface canonical state to the EVM during block execution in later phases (integration points only — do not reimplement EVM).

## Test Fixtures (execution driven)
- `ethereum-tests/BlockchainTests/` — canonical JSON fixtures for block validation and chain canonicalization.
- `execution-spec-tests/fixtures/blockchain_tests/` — spec-derived blockchain fixtures (when enabling Python-driven tests).

## Implementation Notes
- Always use Voltaire primitives; never introduce ad-hoc `struct`s for header/hash/bodies.
- Validation logic must follow `execution-specs` per-fork rules (e.g., ommer rules, base fee post-London, DIFFICULTY/PREVRANDAO semantics post-Merge).
- Structure mirrors Nethermind: `client/blockchain/{chain.zig,validator.zig}` with clear read/write separation and fork-choice friendly surfaces.
- Use comptime DI patterns consistent with the EVM code (vtable-like injection for storage/provider surfaces).
- Error handling: return typed errors; no silent catches.
- Performance: minimize allocations; prefer arenas for per-block scoped work; avoid unnecessary copies in RLP.
- Tests: every public function accompanied by `test "..." {}` unit tests and scenario coverage from BlockchainTests.

## Pointers to Open the Exact Files
- PRD goals: `prd/GUILLOTINE_CLIENT_PLAN.md` (Phase 4 section)
- Specs:
  - `execution-specs/src/ethereum/forks/*/fork.py`
  - `EIPs/EIPS/eip-3675.md`
  - `EIPs/EIPS/eip-4399.md`
- Nethermind Db (structure reference): `nethermind/src/Nethermind/Nethermind.Db/`
- Voltaire Zig APIs:
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/Blockchain.zig`
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/BlockStore.zig`
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/BlockHeader`
- Host: `src/host.zig`
- Tests: `ethereum-tests/BlockchainTests/`

