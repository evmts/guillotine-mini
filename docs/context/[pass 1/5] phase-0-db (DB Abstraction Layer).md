# [Pass 1/5] Phase 0: DB Abstraction Layer - Context

## Phase Goal (from `prd/GUILLOTINE_CLIENT_PLAN.md`)

Create a database abstraction layer for persistent storage.

Key components called out by the plan:

- `client/db/adapter.zig` - generic database interface
- `client/db/rocksdb.zig` - RocksDB backend implementation
- `client/db/memory.zig` - in-memory backend for tests

## Specs (from `prd/ETHEREUM_SPECS_REFERENCE.md`)

- Phase 0 has no external protocol specs.
- Tests: unit tests only.

## Nethermind DB Reference (from `nethermind/src/Nethermind/Nethermind.Db/`)

- `nethermind/` submodule directory is empty in this workspace.
- The path `nethermind/src/Nethermind/Nethermind.Db/` does not exist here, so no files could be listed.
- Action needed before implementation: initialize/update the Nethermind submodule to access DB interfaces and backends.

## Voltaire-effect APIs (from `/Users/williamcory/voltaire/voltaire-effect/src/`)

Relevant primitives to use for DB-facing types (do not create custom Ethereum types):

- `primitives/Bytes`
- `primitives/Hex`
- `primitives/Hash`
- `primitives/Address`
- `primitives/Storage` and `primitives/StorageValue`
- `primitives/U256` and `primitives/Uint`
- `primitives/StateRoot`, `primitives/BlockHash`, `primitives/TransactionHash`

Service / layer patterns to mirror for the DB abstraction:

- `services/Cache/CacheService.ts` - Context.Tag service shape for key-value operations.
- `services/Cache/MemoryCache.ts` and `services/Cache/NoopCache.ts` - Layer-based implementations.
- `blockchain/BlockchainService.ts` - Context.Tag + Data.TaggedError + Effect-returning API shape.
- `blockchain/Blockchain.ts` - `Layer.succeed` in-memory store pattern.

## Effect.ts Patterns (from `effect-repo/packages/effect/src/`)

Core modules to reference for idioms:

- `Context.ts` for `Context.Tag` service definitions.
- `Layer.ts` for `Layer.succeed`, `Layer.effect`, `Layer.merge` composition.
- `Effect.ts` for `Effect.gen` sequential composition and typed error channels.
- `Data.ts` for `Data.TaggedError` error types.
- `Schema.ts` for validation at boundaries.
- `Resource.ts` and `Scope.ts` for `Effect.acquireRelease` patterns.

## Existing TypeScript Client Code

- `client-ts/` directory is not present in this workspace.
- Only `ts/exex/manager.ts` and `ts/exex/types.ts` exist; they use Promise/async generator patterns and define custom Ethereum types (not Effect.ts, not voltaire-effect).
- Action needed: locate or initialize the intended `client-ts/` source tree before implementation work.

## Ethereum Test Fixtures (from `ethereum-tests/`)

- `ethereum-tests/` submodule only contains `.git` in this workspace; no fixtures are available yet.
- Action needed: initialize/update the `ethereum-tests` submodule to access fixture directories.
