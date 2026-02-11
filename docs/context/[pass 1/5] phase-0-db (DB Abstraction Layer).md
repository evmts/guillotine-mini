# [pass 1/5] phase-0-db (DB Abstraction Layer)

This context file gathers references and structure needed to implement the database abstraction layer for the Effect.ts Ethereum execution client (wrapping/re-implementing `guillotine-mini` in idiomatic Effect).

## Goals (from `prd/GUILLOTINE_CLIENT_PLAN.md`)
- Create a database abstraction layer for persistent storage.
- Provide interchangeable backends:
  - `rocksdb` (production-ready persistent store)
  - `memory` (test-only, deterministic)
- Follow Nethermind’s DB architecture for structure and naming.
- Phase scope: internal abstraction; no direct Ethereum spec dependencies.

Key plan references:
- Nethermind: `nethermind/src/Nethermind/Nethermind.Db/`
- Voltaire Zig: `/Users/williamcory/voltaire/packages/voltaire-zig/src/` (no DB module; use as primitives/structure reference)
- Test fixtures: N/A for this phase (unit tests only)

## Relevant Specs (`prd/ETHEREUM_SPECS_REFERENCE.md`)
- Phase 0 lists Specs: N/A (internal abstraction).
- Use this phase to set foundations for later spec-driven phases (Trie, State, EVM integration).

## Nethermind reference (key files)
Directory: `nethermind/src/Nethermind/Nethermind.Db/`
- `IDb.cs` — Base key/value database interface
- `IColumnsDb.cs` — Column-family abstraction
- `IDbProvider.cs` — Aggregation of named databases/columns
- `DbProvider.cs` — Default provider implementation
- `ReadOnlyDb.cs`, `IReadOnlyDb.cs` — Read-only wrappers
- `ReadOnlyDbProvider.cs`, `IReadOnlyDbProvider.cs` — Read-only provider
- `MemDb.cs`, `MemColumnsDb.cs`, `MemDbFactory.cs` — In-memory backends
- `CompressingDb.cs` — Write-time compression decorator
- `RocksDbSettings.cs`, `NullRocksDbFactory.cs` — RocksDB integration points
- `ITunableDb.cs` — Tuning hooks
- `FullPruning/*` (`IFullPruningDb.cs`, `FullPruningDb.cs`, etc.) — Pruning support
- `DbNames.cs`, `MetadataDbKeys.cs`, `ReceiptsColumns.cs`, `BlobTxsColumns.cs` — Well-known logical column sets
- `Metrics.cs` — DB metrics hooks

Implication for Effect.ts design:
- Provide `Db` service (K/V), `ColumnsDb` (column families), and `DbProvider` for named databases (world state, headers, bodies, receipts, etc.).
- Keep read-only variants via wrapper layers.
- Defer pruning/compression to later phases; design extension points now (decorators in Layer composition).

## Voltaire Zig reference (APIs of interest)
Directory: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- `blockchain/BlockStore.zig` — In-memory block storage pattern (Hash -> Block, canonical chain map). Useful shape reference for Effect models but not a DB backend.
- `state-manager/*` — `StateManager.zig`, `JournaledState.zig`, `StateCache.zig` give insight into access patterns that DB must serve in later phases.
- `evm/host.zig` — Host callbacks surface (see below) that will later be implemented against state+DB.
- `primitives/*` — Canonical Ethereum primitives (Address, Hash, Block, Tx, etc.). Effect.ts must continue to use voltaire-effect primitives in TypeScript.

No dedicated DB module exists in Voltaire Zig; treat it as semantic/shape reference only.

## guillotine-mini Host interface (current repo)
File: `src/host.zig`
- Minimal host exposing state access required by EVM:
  - `getBalance/setBalance(Address, u256)`
  - `getCode/setCode(Address, []u8)`
  - `getStorage/setStorage(Address, slot: u256, value: u256)`
  - `getNonce/setNonce(Address, u64)`
- Note: Nested calls are handled internally by the EVM; Host is for external state access. The DB layer must make these operations efficient once wired through world state in later phases.

## ethereum-tests (fixtures overview)
Directory: `ethereum-tests/`
- Present top-level suites: `TrieTests/`, `GeneralStateTests` (via `fixtures_general_state_tests.tgz`), `BlockchainTests/`, `TransactionTests/`, etc.
- For Phase 0, no direct fixtures are used; rely on unit tests for the DB abstraction itself. Later phases will consume these paths.

## Implementation notes for Effect.ts (preview)
- Service interfaces via `Context.Tag`:
  - `Db` (basic K/V), `ColumnsDb` (namespaced/column families), `DbProvider` (named column sets)
- Layers for concrete backends:
  - `Layer.succeed` for in-memory
  - `Layer.scoped` + `Effect.acquireRelease` for persistent (RocksDB/Libmdbx) resource mgmt
- Errors: define domain errors via `Data.TaggedError` (e.g., `DbOpenError`, `DbReadError`, `DbWriteError`).
- No custom primitives: always use `Address`, `Hash`, `Hex`, `Block`, `Transaction` from `voltaire-effect/primitives` for typed keys/values where applicable (or `Uint8Array`/`Hex` for raw bytes with clear codecs).
- Testing: `@effect/vitest` `it.effect()` for all public API functions; memory backend used for deterministic tests.

## Paths snapshot
- Plan: `prd/GUILLOTINE_CLIENT_PLAN.md`
- Specs map: `prd/ETHEREUM_SPECS_REFERENCE.md`
- Nethermind DB: `nethermind/src/Nethermind/Nethermind.Db/`
- Voltaire Zig: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- Host Interface: `src/host.zig`
- Ethereum tests root: `ethereum-tests/`

