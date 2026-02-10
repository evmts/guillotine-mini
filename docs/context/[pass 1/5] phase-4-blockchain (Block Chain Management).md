# Context: Phase 4 — Block Chain Management (pass 1/5)

This file gathers the minimal, high-signal references to guide implementation of Block Chain Management. Sources below are authoritative in this priority: execution-specs → EIPs/Yellow Paper → ethereum-tests/execution-spec-tests → Nethermind (architecture only) → Voltaire (APIs/primitives to use).

## Phase Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Goal: Manage the block chain structure and validation.
- Key components to implement:
  - `client/blockchain/chain.zig` — Chain management (block insertion, canonical head selection, fork handling)
  - `client/blockchain/validator.zig` — Block/header validation per fork rules
- References: `nethermind/src/Nethermind/Nethermind.Blockchain/`, `voltaire/packages/voltaire-zig/src/blockchain/`
- Tests: `ethereum-tests/BlockchainTests/`

## Relevant Specs (from prd/ETHEREUM_SPECS_REFERENCE.md)
- execution-specs: `execution-specs/src/ethereum/forks/*/fork.py` — block validation rules by fork
- Yellow Paper: Section 11 — Block finalization/validation overview
- execution-spec-tests: `execution-spec-tests/fixtures/blockchain_tests/` (symlink to `ethereum-tests/BlockchainTests`)

## Nethermind (reference architecture)
Directory listing snapshot: `nethermind/src/Nethermind/Nethermind.Db/`
- Key files (DB abstractions used by Blockchain module):
  - `IDb.cs`, `IDbProvider.cs`, `DbProvider.cs` — database provider interfaces
  - `ReadOnlyDb.cs`, `ReadOnlyDbProvider.cs` — read-only variants
  - `MemDb.cs`, `MemColumnsDb.cs`, `MemDbFactory.cs` — in-memory DBs (useful for tests)
  - `RocksDbSettings.cs`, `CompressingDb.cs` — persistent backend configuration/utilities
  - `MetadataDbKeys.cs` — common metadata keys
- Note: For Phase 4, mirror architecture (provider interfaces, column families) but implement idiomatically in Zig and always use Voltaire primitives.

## Voltaire primitives/APIs to use (no custom duplicates)
From `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/`:
- `blockchain.Blockchain` — high-level chain coordination
- `blockchain.BlockStore` — persisted block storage abstraction
- `blockchain.ForkBlockCache` — fork-oriented caching

Related primitives likely required:
- `primitives.*` (hashes, addresses, rlp, uint types)

## Host Interface (existing, do not reimplement EVM)
- `src/host.zig` — Minimal external state interface used by the EVM; keep comptime DI patterns consistent with existing EVM code. EVM nested calls handled internally by `inner_call` per current implementation notes.

## Test Fixtures
- Classic tests: `ethereum-tests/BlockchainTests/` (subfolders: `ValidBlocks/`, `InvalidBlocks/`)
- Spec-generated: `execution-spec-tests/fixtures/blockchain_tests/` (symlink → `ethereum-tests/BlockchainTests`)

## Notes & Gaps To Verify Next Pass
- Map `execution-specs` fork-specific validation (header fields, BASEFEE, time/gas limits, withdrawals/ blobs where applicable) to validator function boundaries.
- Confirm Voltaire `blockchain` APIs cover canonical chain selection and reorg signalling we need; extend glue only, never primitives.
- Align DB key layout with Nethermind columns but keep Zig types strictly from Voltaire.
