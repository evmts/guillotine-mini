# [pass 2/5] phase-4-blockchain (Block Chain Management) — Context

## Phase goals (from plan)
- Implement block chain management and validation.
- Key components: `client/blockchain/chain.zig`, `client/blockchain/validator.zig`.
- Architecture reference: Nethermind `Nethermind.Blockchain`.
- Use Voltaire blockchain primitives.
- Test fixtures: `ethereum-tests/BlockchainTests/`.

## Specs to anchor validation behavior
- `execution-specs/src/ethereum/forks/cancun/fork.py`
  - `state_transition(...)`, `validate_header(...)`, `check_transaction(...)` define block validation flow, header rules, and inclusion checks.
  - Base fee, gas limit/used, timestamp, parent linkage, and PoS-era constants (difficulty/nonce/ommers) are validated here.
- `yellowpaper/Paper.tex` (Section “Blocks, State and Transactions”, “Block Header Validity”, “Block Finalisation”)
  - Formal definitions of header fields, holistic validity (state root / tx root / receipts / logs bloom / withdrawals), and header validity constraints.

## Nethermind DB reference (requested listing)
Directory: `nethermind/src/Nethermind/Nethermind.Db/`
Key files:
- `IDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs`, `IDbFactory.cs`, `IDbProvider.cs`, `IReadOnlyDbProvider.cs`
- `DbProvider.cs`, `DbProviderExtensions.cs`, `DbExtensions.cs`, `DbNames.cs`
- `IColumnsDb.cs`, `InMemoryColumnBatch.cs`, `InMemoryWriteBatch.cs`, `MemColumnsDb.cs`, `MemDb.cs`, `MemDbFactory.cs`
- `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `ReadOnlyDbProvider.cs`
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`, `NullRocksDbFactory.cs`
- `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/`, `FullPruningCompletionBehavior.cs`, `FullPruningTrigger.cs`
- `MetadataDbKeys.cs`, `ReceiptsColumns.cs`, `BlobTxsColumns.cs`, `Metrics.cs`

## Voltaire APIs (blockchain primitives)
Module root: `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/`
- `blockchain.BlockStore` — local block storage, canonical head tracking.
- `blockchain.ForkBlockCache` — remote/fork reads with caching.
- `blockchain.Blockchain` — orchestrator combining local store + optional fork cache.
- Files: `BlockStore.zig`, `ForkBlockCache.zig`, `Blockchain.zig`, `root.zig`, `c_api.zig`.

## Existing Zig host interface
- `src/host.zig` — `HostInterface` vtable with balance/code/storage/nonce getters+setters; used for external state access (not nested calls). 

## Test fixtures (ethereum-tests)
- `ethereum-tests/BlockchainTests/`
- Additional nearby fixture roots: `ethereum-tests/GenesisTests/`, `ethereum-tests/TransactionTests/`, `ethereum-tests/TrieTests/`.

## Notes for phase-4 implementation alignment
- Header validation must enforce PoS constants (difficulty=0, nonce=0, ommers hash = KEC(RLP(()))).
- Parent linkage uses keccak256(RLP(parent_header)).
- Base fee and gas-limit adjustment logic must match Yellow Paper + `execution-specs` fork implementations.
- Holistic block validity includes state root, tx root, receipts root, logs bloom, withdrawals root, and ommers empty.
