# [Pass 1/5] Phase 4: Block Chain Management - Context

## Goal (from prd/GUILLOTINE_CLIENT_PLAN.md)
Manage the block chain structure and validation.
Planned modules:
- client/blockchain/chain.zig (chain management)
- client/blockchain/validator.zig (block validation)

Reference files:
- nethermind/src/Nethermind/Nethermind.Blockchain/
- /Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/

Test fixtures:
- ethereum-tests/BlockchainTests/

## Spec References (from prd/ETHEREUM_SPECS_REFERENCE.md)
Specs:
- execution-specs/src/ethereum/forks/*/fork.py (block validation)
- yellowpaper/Paper.tex Section 11 (Block Finalization)

Tests:
- ethereum-tests/BlockchainTests/
- execution-spec-tests/fixtures/blockchain_tests/

## Nethermind.Db listing (nethermind/src/Nethermind/Nethermind.Db/)
Key files:
- BlobTxsColumns.cs
- CompressingDb.cs
- DbExtensions.cs
- DbNames.cs
- DbProvider.cs
- DbProviderExtensions.cs
- FullPruning/
- FullPruningCompletionBehavior.cs
- FullPruningTrigger.cs
- IColumnsDb.cs
- IDb.cs
- IDbFactory.cs
- IDbProvider.cs
- IFullDb.cs
- IMergeOperator.cs
- IPruningConfig.cs
- IReadOnlyDb.cs
- IReadOnlyDbProvider.cs
- ITunableDb.cs
- InMemoryColumnBatch.cs
- InMemoryWriteBatch.cs
- MemColumnsDb.cs
- MemDb.cs
- MemDbFactory.cs
- MetadataDbKeys.cs
- Metrics.cs
- NullDb.cs
- NullRocksDbFactory.cs
- PruningConfig.cs
- PruningMode.cs
- ReadOnlyColumnsDb.cs
- ReadOnlyDb.cs
- ReadOnlyDbProvider.cs
- ReceiptsColumns.cs
- RocksDbMergeEnumerator.cs
- RocksDbSettings.cs
- SimpleFilePublicKeyDb.cs

## Voltaire Zig APIs
Requested path: /Users/williamcory/voltaire/packages/voltaire-zig/src/ (not found in this environment).
Fallback listing from /Users/williamcory/voltaire/src/:
- blockchain/
- crypto/
- evm/
- jsonrpc/
- primitives/
- state-manager/
- root.zig
- c_api.zig
- log.zig

Blockchain module contents from /Users/williamcory/voltaire/src/blockchain/:
- BlockStore.zig
- Blockchain.zig
- ForkBlockCache.zig
- c_api.zig
- root.zig
- Blockchain/index.ts

## Existing Zig Host Interface (src/host.zig)
HostInterface provides a vtable for external state access:
- getBalance, setBalance
- getCode, setCode
- getStorage, setStorage
- getNonce, setNonce
Notes:
- Uses primitives.Address.Address and u256
- Not used for nested calls (EVM handles inner calls directly)

## ethereum-tests directory listing
Top-level directories and fixtures:
- ABITests
- BasicTests
- BlockchainTests
- DifficultyTests
- EOFTests
- GenesisTests
- JSONSchema
- KeyStoreTests
- LegacyTests
- PoWTests
- RLPTests
- TransactionTests
- TrieTests
- fixtures_blockchain_tests.tgz
- fixtures_general_state_tests.tgz

## Paths read in this pass
- prd/GUILLOTINE_CLIENT_PLAN.md
- prd/ETHEREUM_SPECS_REFERENCE.md
- nethermind/src/Nethermind/Nethermind.Db/
- /Users/williamcory/voltaire/packages/voltaire-zig/src/ (missing)
- /Users/williamcory/voltaire/src/
- /Users/williamcory/voltaire/src/blockchain/
- src/host.zig
- ethereum-tests/
