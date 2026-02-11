# [pass 1/5] phase-0-db (DB Abstraction Layer) — Context

This document aggregates references and paths to guide the implementation of the DB Abstraction Layer for the Effect.ts Ethereum execution client. It mirrors Nethermind’s architecture while remaining idiomatic to Effect.ts and aligned with guillotine-mini and Voltaire modules.

## Phase Goals (from `prd/GUILLOTINE_CLIENT_PLAN.md`)
- Goal: Create a database abstraction layer for persistent storage.
- Key components (Zig-era plan, to be re-expressed in Effect.ts):
  - `client/db/adapter.zig` — generic DB interface
  - `client/db/rocksdb.zig` — RocksDB backend
  - `client/db/memory.zig` — in-memory backend for tests
- References:
  - Nethermind: `nethermind/src/Nethermind/Nethermind.Db/`
  - Voltaire (check for existing primitives): `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- Tests: N/A for external fixtures in this phase — focus on unit tests of the abstraction.

## Relevant Specs (from `prd/ETHEREUM_SPECS_REFERENCE.md`)
- Specs: N/A for Phase 0 (internal abstraction). No direct Yellow Paper or execution-specs linkage.
- Architecture reference only: Nethermind Db module.

## Nethermind Reference — key files in `nethermind/src/Nethermind/Nethermind.Db/`
Focus on interfaces and providers to mirror boundaries:
- Interfaces: `IDb.cs`, `IColumnsDb.cs`, `IFullDb.cs`, `IReadOnlyDb.cs`, `ITunableDb.cs`, `IMergeOperator.cs`
- Provider pattern: `IDbProvider.cs`, `IReadOnlyDbProvider.cs`, `DbProvider.cs`, `DbProviderExtensions.cs`
- Implementations/backends:
  - In-memory: `MemDb.cs`, `MemColumnsDb.cs`, `MemDbFactory.cs`, `InMemoryWriteBatch.cs`, `InMemoryColumnBatch.cs`
  - Null/No-op: `NullDb.cs`, `NullRocksDbFactory.cs`
  - RocksDB-related: `RocksDbSettings.cs`, `CompressingDb.cs`, `RocksDbMergeEnumerator.cs`
- Naming and metadata: `DbNames.cs`, `MetadataDbKeys.cs`
- Pruning and maintenance: `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/`, `FullPruningCompletionBehavior.cs`, `FullPruningTrigger.cs`
- Observability: `Metrics.cs`, `Blooms/`, `ReceiptsColumns.cs`, `BlobTxsColumns.cs`

Guidance for Effect.ts:
- Define a minimal, composable service interface (Context.Tag) for a KV store and a columns/namespace abstraction.
- Provide layers for `MemoryDb` and a placeholder `RocksDb` (wiring to real storage arrives later).
- Expose read-only and read-write variants via separate services or tags to mirror `IReadOnlyDb` vs `IFullDb`.

## Voltaire Zig — modules to reference (storage semantics)
Path: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- `blockchain/BlockStore.zig` — Local block storage and canonical chain tracking
- `blockchain/Blockchain.zig` — Orchestrator referencing local storage concepts
- `blockchain/root.zig` — Module surface for blockchain storage
- `state-manager/` — State access patterns; journaling/caching semantics
- No explicit DB drivers found; treat these as storage semantics references, not direct backends.

Recommended TS-facing API inspirations:
- "column" partitioning with typed codecs per logical dataset (headers, bodies, receipts, state trie nodes, etc.)
- Batching writes and atomic commit hooks (Effect.scoped with `Effect.acquireRelease` for write batches)

## guillotine-mini EVM host — `src/host.zig`
- Minimal HostInterface with balance, code, storage, nonce getters/setters via VTable.
- Not used for nested calls; EVM handles inner calls directly.
- While Phase 0 is DB-only, these call shapes inform future state access patterns that the DB should eventually support efficiently.

Signatures (selected):
- `getBalance(Address) -> u256`, `setBalance(Address, u256)`
- `getCode(Address) -> []const u8`, `setCode(Address, []const u8)`
- `getStorage(Address, u256) -> u256`, `setStorage(Address, u256, u256)`
- `getNonce(Address) -> u64`, `setNonce(Address, u64)`

## ethereum-tests — fixtures inventory (not used in Phase 0)
Path: `ethereum-tests/`
- Present: `TrieTests/`, `BlockchainTests/`, `TransactionTests/`, `DifficultyTests/`, `EOFTests/`, etc.
- Archives: `fixtures_blockchain_tests.tgz`, `fixtures_general_state_tests.tgz`
- Absent: `GeneralStateTests/` directory (use archives or execution-spec-tests when needed in later phases)

## Effect.ts Implementation Notes (Phase 0)
- Service boundaries:
  - `Db` (read-write KV with column/namespace support)
  - `ReadOnlyDb` (subset of `Db`)
  - `DbProvider` (factory + lifecycle via Layer)
- Effect idioms:
  - Use `Context.Tag` for service tokens; `Layer.succeed/effect/scoped` for DI
  - Define domain errors with `Data.TaggedError` (e.g., `DbOpenError`, `DbNotFound`, `DbCorruption`)
  - Prefer `Effect.gen` over long pipe chains
  - Manage resources with `Effect.acquireRelease` (open/close DB, managed write batches)
- Primitives:
  - ALWAYS use `voltaire-effect/primitives` (Address, Hash, Hex, etc.) at interfaces that touch Ethereum data
  - Codec boundaries should convert to binary keys/values internally; avoid ad-hoc types
- Testing:
  - Every public function must have `@effect/vitest` tests with `it.effect()`
  - For Phase 0, unit tests only (no external fixtures)

## Concrete Paths Snapshot
- Plan: `prd/GUILLOTINE_CLIENT_PLAN.md`
- Specs index: `prd/ETHEREUM_SPECS_REFERENCE.md` (Phase 0: N/A)
- Nethermind DB: `nethermind/src/Nethermind/Nethermind.Db/`
- Voltaire Zig root: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- Host interface: `src/host.zig`
- ethereum-tests root: `ethereum-tests/`

