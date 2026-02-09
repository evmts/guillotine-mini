# [Pass 1/5] Phase 0: DB Abstraction Layer — Context

## Phase Goal (from `prd/GUILLOTINE_CLIENT_PLAN.md`)

Create a database abstraction layer for persistent storage. This is an internal interface that underpins later phases.

**Key Components (conceptual)**:

- `client/db/adapter.*` — generic DB interface
- `client/db/rocksdb.*` — RocksDB backend implementation
- `client/db/memory.*` — in-memory backend for tests

## Specs (from `prd/ETHEREUM_SPECS_REFERENCE.md`)

- Phase 0 has **no external protocol specs**.
- Tests: **unit tests only**.

## Nethermind DB Reference (from `nethermind/src/Nethermind/Nethermind.Db/`)

Use these as architectural guidance for interfaces, providers, and backends:

**Core interfaces / providers**

- `nethermind/src/Nethermind/Nethermind.Db/IDb.cs` — main DB interface
- `nethermind/src/Nethermind/Nethermind.Db/IReadOnlyDb.cs` — read-only DB interface
- `nethermind/src/Nethermind/Nethermind.Db/IColumnsDb.cs` — column-family DB abstraction
- `nethermind/src/Nethermind/Nethermind.Db/IDbFactory.cs` — factory for DB creation
- `nethermind/src/Nethermind/Nethermind.Db/IDbProvider.cs` — named DB registry/provider
- `nethermind/src/Nethermind/Nethermind.Db/IReadOnlyDbProvider.cs` — read-only provider
- `nethermind/src/Nethermind/Nethermind.Db/IFullDb.cs` — extended DB interface
- `nethermind/src/Nethermind/Nethermind.Db/IMergeOperator.cs` — merge operator abstraction
- `nethermind/src/Nethermind/Nethermind.Db/ITunableDb.cs` — tunable DB interface

**In-memory implementations / batches**

- `nethermind/src/Nethermind/Nethermind.Db/MemDb.cs` — in-memory DB reference impl
- `nethermind/src/Nethermind/Nethermind.Db/MemColumnsDb.cs` — in-memory column DB
- `nethermind/src/Nethermind/Nethermind.Db/MemDbFactory.cs` — in-memory DB factory
- `nethermind/src/Nethermind/Nethermind.Db/InMemoryWriteBatch.cs` — write batch impl
- `nethermind/src/Nethermind/Nethermind.Db/InMemoryColumnBatch.cs` — column batch impl

**Wrappers / utilities**

- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDb.cs` — read-only wrapper
- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyColumnsDb.cs` — read-only column wrapper
- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDbProvider.cs` — read-only provider
- `nethermind/src/Nethermind/Nethermind.Db/DbProvider.cs` — provider implementation
- `nethermind/src/Nethermind/Nethermind.Db/DbProviderExtensions.cs` — provider helpers
- `nethermind/src/Nethermind/Nethermind.Db/DbExtensions.cs` — DB helpers

**Configuration / metadata / metrics**

- `nethermind/src/Nethermind/Nethermind.Db/DbNames.cs` — canonical DB name constants
- `nethermind/src/Nethermind/Nethermind.Db/MetadataDbKeys.cs` — metadata key constants
- `nethermind/src/Nethermind/Nethermind.Db/RocksDbSettings.cs` — RocksDB settings
- `nethermind/src/Nethermind/Nethermind.Db/Metrics.cs` — DB metrics

**Pruning / maintenance (for later phases)**

- `nethermind/src/Nethermind/Nethermind.Db/FullPruning/` — pruning implementation
- `nethermind/src/Nethermind/Nethermind.Db/PruningConfig.cs` — pruning config
- `nethermind/src/Nethermind/Nethermind.Db/PruningMode.cs` — pruning modes
- `nethermind/src/Nethermind/Nethermind.Db/FullPruningTrigger.cs` — trigger config
- `nethermind/src/Nethermind/Nethermind.Db/FullPruningCompletionBehavior.cs` — completion policy

**Other DB helpers**

- `nethermind/src/Nethermind/Nethermind.Db/NullDb.cs` — null object DB
- `nethermind/src/Nethermind/Nethermind.Db/NullRocksDbFactory.cs` — null RocksDB factory
- `nethermind/src/Nethermind/Nethermind.Db/CompressingDb.cs` — compression wrapper
- `nethermind/src/Nethermind/Nethermind.Db/BlobTxsColumns.cs` — blob tx column defs
- `nethermind/src/Nethermind/Nethermind.Db/ReceiptsColumns.cs` — receipt column defs
- `nethermind/src/Nethermind/Nethermind.Db/SimpleFilePublicKeyDb.cs` — key store helper

## Voltaire-Effect APIs (from `/Users/williamcory/voltaire/voltaire-effect/src/`)

Use voltaire-effect primitives and services instead of custom Ethereum types:

**Primitives (see `voltaire-effect/src/primitives/index.ts`)**

- `Address`, `Hash`, `Hex`, `Bytes`, `Bytes32`
- `BlockHash`, `StateRoot`, `TransactionHash`
- `Slot`, `StorageValue`, `State`, `StateDiff`, `StateProof`
- `U256`, `Uint`, `Nonce`, `Gas`, `GasPrice`, `GasUsed`

**Services (see `voltaire-effect/src/services/index.ts`)**

- `CacheService` / `MemoryCache` if a small in-memory cache is needed for DB adapters
- `BlockchainService` interfaces for future integration (not required for phase 0)

## Effect.ts Patterns (from `effect-repo/packages/effect/src/`)

For idiomatic Effect.ts DI and resource management:

- `Context.ts` — `Context.Tag` for service definitions
- `Layer.ts` — `Layer.succeed`, `Layer.effect`, `Layer.merge`
- `Effect.ts` — `Effect.gen`, `Effect.acquireRelease`, `Effect.tryPromise`
- `Schema.ts` — boundary validation schemas
- `Resource.ts`, `Scope.ts` — lifetime management for DB connections

## Existing TypeScript Client Code

`client-ts/` does not exist in this repo. Relevant TS code is located here:

- `src/README_TYPESCRIPT.md` — TS setup and Voltaire integration notes
- `src/utils/voltaire-imports.ts` — placeholder Voltaire primitives (not voltaire-effect)
- `ts/exex/manager.ts` — async generator manager (Promise-based)
- `ts/exex/types.ts` — custom Ethereum types (Address/Hash/Hex) that must be replaced by voltaire-effect primitives later

## Ethereum Test Fixtures (from `ethereum-tests/`)

Phase 0 does not consume external fixtures, but these are available for later phases:

- `ethereum-tests/TrieTests/`
- `ethereum-tests/BlockchainTests/`
- `ethereum-tests/TransactionTests/`
- `ethereum-tests/BasicTests/`
- `ethereum-tests/GenesisTests/`
- `ethereum-tests/RLPTests/`
- `ethereum-tests/EOFTests/`
- `ethereum-tests/LegacyTests/`
- `ethereum-tests/fixtures_blockchain_tests.tgz`
- `ethereum-tests/fixtures_general_state_tests.tgz`
