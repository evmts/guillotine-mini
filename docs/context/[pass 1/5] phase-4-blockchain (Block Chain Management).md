# Context: [pass 1/5] phase-4-blockchain (Block Chain Management)

## Goal (from prd/GUILLOTINE_CLIENT_PLAN.md)

- Manage the block chain structure and validation.
- Key components: `client/blockchain/chain.zig`, `client/blockchain/validator.zig` (Zig reference only).
- Architecture reference: `nethermind/src/Nethermind/Nethermind.Blockchain/`.
- Voltaire reference: `voltaire/packages/voltaire-zig/src/blockchain/`.
- Test fixtures: `ethereum-tests/BlockchainTests/`.

## Specs to Read First (from prd/ETHEREUM_SPECS_REFERENCE.md + execution-specs)

- `execution-specs/src/ethereum/forks/*/fork.py` (block validation per fork).
- Yellow Paper Section 11 (Block Finalization) under `yellowpaper/`.
- Tests: `ethereum-tests/BlockchainTests/` and `execution-spec-tests/fixtures/blockchain_tests/`.

### execution-specs spot check (prague fork)

Source: `execution-specs/src/ethereum/forks/prague/fork.py`

- `state_transition(chain, block)`
  - Calls `validate_header`.
  - Requires `block.ommers` to be empty.
  - Builds `BlockEnvironment` and calls `apply_body`.
  - Validates header/body derived fields: `gas_used`, `transactions_root`, `state_root`, `receipt_root`, `bloom`, `withdrawals_root`, `blob_gas_used`, `requests_hash`.
  - Appends block to chain (spec retains only last 255 blocks).
- `validate_header(chain, header)`
  - `header.number >= 1` and parent header checks.
  - Validates `excess_blob_gas`, `gas_used <= gas_limit`, `base_fee_per_gas` via `calculate_base_fee_per_gas`.
  - Enforces timestamp increase, number increments, `extra_data <= 32`, `difficulty == 0`, `nonce == 0`, `ommers_hash == EMPTY_OMMER_HASH`.
- `apply_body(block_env, transactions, withdrawals)`
  - Runs system transactions, processes transactions, withdrawals, and general purpose requests.

## Nethermind.Db Reference Inventory

Listed from `nethermind/src/Nethermind/Nethermind.Db/`:

- Core DB interfaces: `IDb.cs`, `IColumnsDb.cs`, `IDbFactory.cs`, `IDbProvider.cs`, `IFullDb.cs`, `IReadOnlyDb.cs`, `IReadOnlyDbProvider.cs`, `ITunableDb.cs`, `IMergeOperator.cs`.
- Providers/config: `DbProvider.cs`, `DbProviderExtensions.cs`, `DbNames.cs`, `DbExtensions.cs`, `PruningConfig.cs`, `PruningMode.cs`, `RocksDbSettings.cs`.
- In-memory: `MemDb.cs`, `MemDbFactory.cs`, `MemColumnsDb.cs`, `InMemoryColumnBatch.cs`, `InMemoryWriteBatch.cs`.
- Read-only wrappers: `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `ReadOnlyDbProvider.cs`.
- Maintenance/metrics: `Metrics.cs`, `RocksDbMergeEnumerator.cs`, `FullPruning/`, `FullPruningTrigger.cs`, `FullPruningCompletionBehavior.cs`.
- Columns/metadata: `BlobTxsColumns.cs`, `ReceiptsColumns.cs`, `MetadataDbKeys.cs`.
- Other: `NullDb.cs`, `NullRocksDbFactory.cs`, `SimpleFilePublicKeyDb.cs`, `CompressingDb.cs`.

## voltaire-effect APIs (source: /Users/williamcory/voltaire/voltaire-effect/src/)

Key primitives and services to reuse (no custom Ethereum types):

- `primitives/`: `Block`, `BlockHeader`, `BlockBody`, `BlockHash`, `BlockNumber`, `Chain`, `ChainHead`, `Receipt`, `Transaction`, `Withdrawal`, `StateRoot`, `BloomFilter`, `Gas`, `GasUsed`, `BaseFeePerGas`, `Nonce`, `Hash`, `Hex`, `Bytes`, `Rlp`, `Hardfork`, `ForkId`.
- `blockchain/BlockchainService.ts`: `BlockchainService` Context.Tag and `BlockchainShape` for storage/canonical management (Hex-based block representation).
- `block/`: `fetchBlock`, `fetchBlockByHash`, `fetchBlockReceipts`, `toLightBlock` helpers (RPC integration).
- `services/`: `Chain`, `Provider`, `RawProvider`, `Signer`, `RpcBatch`, `Transport` (for network-backed block retrieval if needed).

## Effect.ts Patterns (source: effect-repo/packages/effect/src/)

- DI: `Context.ts`, `Layer.ts`.
- Sequential logic: `Effect.ts` with `Effect.gen` and `Function.ts` (`pipe`).
- Validation: `Schema.ts`, `ParseResult.ts`.
- State + events: `Ref.ts`, `PubSub.ts`.
- Resource safety: `Scope.ts`, `Effect.acquireRelease`.
- Errors: `Data.ts` (TaggedError), `Cause.ts`, `Exit.ts`.
- Data types: `Option.ts`, `Either.ts`, `HashMap.ts`, `HashSet.ts`.

## Existing client-ts Code (Effect.ts client)

Files reviewed:

- `client-ts/blockchain/BlockStore.ts`
  - Context.Tag service; in-memory maps for blocks, canonical chain, and orphans.
  - Schema validation for block/hash/number boundaries.
  - `Effect.acquireRelease` for store lifecycle; `setCanonicalHead` walks ancestors.
- `client-ts/blockchain/Blockchain.ts`
  - Context.Tag chain manager with `Ref` state + `PubSub` event stream.
  - Genesis validation (number 0, zero parent hash), canonical chain checks, fork-choice state updates.
- `client-ts/blockchain/testUtils.ts`
  - Uses `Schema.decodeSync` with voltaire-effect primitives to build test blocks.
- Tests: `client-ts/blockchain/BlockStore.test.ts`, `client-ts/blockchain/Blockchain.test.ts` use `@effect/vitest` and `it.effect`.
- DB patterns: `client-ts/db/Db.ts` shows Context.Tag + Layer.scoped + Schema-based validation for DB boundaries.

## Test Fixtures (filesystem)

- `ethereum-tests/BlockchainTests/`
- `ethereum-tests/fixtures_blockchain_tests.tgz`
- `execution-spec-tests/` is currently empty in this workspace (no fixtures present).

## Notes for Implementation

- Read fork-specific `fork.py` before coding validation logic; mirror logic per active fork.
- Stick to voltaire-effect primitives and services for all Ethereum types.
- Follow existing client-ts service + Layer patterns and avoid `Effect.runPromise` outside app entry points.
