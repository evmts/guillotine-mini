# [pass 1/5] phase-0-db (DB Abstraction Layer)

This context file aggregates the minimal, high-signal references to implement Phase 0 (DB Abstraction Layer) in Effect.ts while mirroring Nethermind’s module boundaries and reusing the existing guillotine-mini EVM semantics.

## Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Create a database abstraction layer for persistent storage.
- Provide a generic DB interface, plus at least two backends:
  - RocksDB backend for production
  - In-memory backend for testing
- Expected module mapping (Zig → Effect.ts):
  - `client/db/adapter.zig` → `client-ts/src/db/Adapter.ts` (Context.Tag + Layer)
  - `client/db/rocksdb.zig` → `client-ts/src/db/RocksDb.ts`
  - `client/db/memory.zig` → `client-ts/src/db/Memory.ts`

## Specs (from prd/ETHEREUM_SPECS_REFERENCE.md)
- Phase 0 has no external normative specs; design is an internal abstraction.
- Primary architectural reference: Nethermind Db.

## Nethermind reference (nethermind/src/Nethermind/Nethermind.Db/)
Key interfaces and components to mirror idiomatically in Effect.ts (interfaces, providers, factories, implementations, tuning):
- Interfaces:
  - `IDb.cs` — base key/value database interface
  - `IColumnsDb.cs` — multi-column/column-family interface
  - `IFullDb.cs` — full-featured DB abstraction
  - `IReadOnlyDb.cs`, `IReadOnlyDbProvider.cs` — read-only surfaces
  - `IDbProvider.cs` — orchestrates access to named databases
  - `IDbFactory.cs` — factory for opening DBs
  - `ITunableDb.cs` — tuning hooks (compaction, cache sizes, etc.)
  - `IMergeOperator.cs` — merge semantics for specific columns
- Providers/Factories/Settings:
  - `DbProvider.cs`, `DbProviderExtensions.cs`, `DbExtensions.cs`
  - `RocksDbSettings.cs`, `NullRocksDbFactory.cs`, `MemDbFactory.cs`
- Implementations:
  - `MemDb.cs`, `MemColumnsDb.cs`, `InMemoryWriteBatch.cs`, `InMemoryColumnBatch.cs`
  - `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `NullDb.cs`
  - `CompressingDb.cs`, `RocksDbMergeEnumerator.cs`
- Schema/Columns & Meta:
  - `DbNames.cs`, `MetadataDbKeys.cs`, `ReceiptsColumns.cs`, `BlobTxsColumns.cs`
- Pruning:
  - `PruningMode.cs`, `PruningConfig.cs`, `FullPruning`, `FullPruningTrigger.cs`, `FullPruningCompletionBehavior.cs`
- Metrics:
  - `Metrics.cs`

Design implications for Effect.ts:
- Expose a small, typed `Db` service (Context.Tag) with column-aware operations and batched writes.
- Separate `DbProvider` (opens named DBs with schema/columns) from concrete backends.
- Provide `MemoryDb` for tests and `RocksDb` (or equivalent) for prod; surface tuning via config.
- Model merge operators and pruning as optional capabilities.

## Voltaire Zig sources (for adjacent storage/state patterns)
Located at `/Users/williamcory/voltaire/packages/voltaire-zig/src/`.
Relevant APIs and code patterns (for naming and data flow, not persistence):
- `blockchain.BlockStore` — local in-memory block storage with canonical chain mapping
  - Path: `.../blockchain/BlockStore.zig`
- `blockchain.Blockchain`, `blockchain.ForkBlockCache` — orchestration + fork cache
  - Path: `.../blockchain/{Blockchain.zig,ForkBlockCache.zig,root.zig}`
- `state-manager.StateManager` & `state-manager.JournaledState` — overlay caches + journaling
  - Path: `.../state-manager/{StateManager.zig,JournaledState.zig,root.zig}`

These show clean separation of orchestration vs. storage concerns and favor typed modules and explicit lifecycles — patterns to emulate in the Effect.ts service design.

## guillotine-mini EVM host (for state I/O surface)
- Path: `src/host.zig`
- `HostInterface.VTable` methods (vtable-based):
  - `getBalance(addr) -> u256`, `setBalance(addr, u256)`
  - `getCode(addr) -> []const u8`, `setCode(addr, []const u8)`
  - `getStorage(addr, slot) -> u256`, `setStorage(addr, slot, u256)`
  - `getNonce(addr) -> u64`, `setNonce(addr, u64)`
Implication: DB layer must support account/storage/code/nonce primitives efficiently and atomically; the Effect.ts state layer will adapt this onto the EVM host.

## Spec and tests directories (for future phases; none required for Phase 0)
- `execution-specs/` — authoritative Python EL spec (no direct DB spec)
- `ethereum-tests/` — classic JSON fixtures
  - `ethereum-tests/TrieTests/` (e.g., `trietest.json`, `hex_encoded_securetrie_test.json`)
  - `ethereum-tests/BlockchainTests/`
  - `ethereum-tests/TransactionTests/`
  - Tarballs present: `fixtures_blockchain_tests.tgz`, `fixtures_general_state_tests.tgz`
- `execution-spec-tests/fixtures/` → symlink to `ethereum-tests/BlockchainTests`

## What we will implement in Effect.ts (next)
- `Db` (Context.Tag): get/put/delete, column families, iterators, batch writes
- `DbProvider` (Context.Tag): open named DBs with schema; lifecycle via `Layer.scoped`
- Backends:
  - `MemoryDb` (pure TS; for unit tests)
  - `RocksDb` (native binding or pure-TS alternative) with tuning options
- Errors as `Data.TaggedError`; no `never` error channels
- All public functions covered with `@effect/vitest` tests (`it.effect()`)

