# Phase 4 Context: Block Chain Management

## Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Manage the block chain structure and validation.
- Key components: `client/blockchain/chain.zig`, `client/blockchain/validator.zig`.
- Architecture reference: Nethermind blockchain module.
- Voltaire primitives: `voltaire/packages/voltaire-zig/src/blockchain/`.
- Test fixtures: `ethereum-tests/BlockchainTests/`.

## Relevant Specs (from prd/ETHEREUM_SPECS_REFERENCE.md)
- Block validation logic: `execution-specs/src/ethereum/forks/*/fork.py`.
- Block finalization: Yellow Paper Section 11 (see `yellowpaper/Paper.tex`).
- Test fixtures: `ethereum-tests/BlockchainTests/` and `execution-spec-tests/fixtures/blockchain_tests/`.

### Fork Spec Files (examples)
- `execution-specs/src/ethereum/forks/cancun/fork.py`
- `execution-specs/src/ethereum/forks/prague/fork.py`
- `execution-specs/src/ethereum/forks/osaka/fork.py`
- `execution-specs/src/ethereum/forks/shanghai/fork.py`
- `execution-specs/src/ethereum/forks/london/fork.py`

## Nethermind Db Files (nethermind/src/Nethermind/Nethermind.Db/)
- `BlobTxsColumns.cs`
- `CompressingDb.cs`
- `DbExtensions.cs`
- `DbNames.cs`
- `DbProvider.cs`
- `DbProviderExtensions.cs`
- `IColumnsDb.cs`
- `IDb.cs`
- `IDbFactory.cs`
- `IDbProvider.cs`
- `IFullDb.cs`
- `IMergeOperator.cs`
- `IPruningConfig.cs`
- `IReadOnlyDb.cs`
- `IReadOnlyDbProvider.cs`
- `ITunableDb.cs`
- `InMemoryColumnBatch.cs`
- `InMemoryWriteBatch.cs`
- `MemColumnsDb.cs`
- `MemDb.cs`
- `MemDbFactory.cs`
- `MetadataDbKeys.cs`
- `Metrics.cs`
- `NullDb.cs`
- `NullRocksDbFactory.cs`
- `PruningConfig.cs`
- `PruningMode.cs`
- `ReadOnlyColumnsDb.cs`
- `ReadOnlyDb.cs`
- `ReadOnlyDbProvider.cs`
- `ReceiptsColumns.cs`
- `RocksDbMergeEnumerator.cs`
- `RocksDbSettings.cs`
- `SimpleFilePublicKeyDb.cs`

## Voltaire APIs (voltaire/packages/voltaire-zig/src/)
- Blockchain: `blockchain/BlockStore.zig`, `blockchain/Blockchain.zig`, `blockchain/ForkBlockCache.zig`.
- Primitives to reuse: `primitives/Block`, `primitives/BlockHeader`, `primitives/BlockBody`, `primitives/BlockHash`, `primitives/Chain`, `primitives/ChainHead`, `primitives/Receipt`, `primitives/Transaction`, `primitives/StateRoot`, `primitives/Hash`, `primitives/Nonce`, `primitives/Gas`.

## Existing Zig Files
- `src/host.zig` (HostInterface vtable for EVM state access).

## Test Fixtures
- `ethereum-tests/BlockchainTests/ValidBlocks/`
- `ethereum-tests/BlockchainTests/InvalidBlocks/`
- `ethereum-tests/BlockchainTests/.meta/`
- `execution-spec-tests/fixtures/blockchain_tests/`

## Notes
- Host interface is a minimal vtable for balance/code/storage/nonce access and should remain the entry point for external state interaction.
- Phase 4 should integrate with the existing world state and EVM host interface rather than re-implementing EVM logic.
