# Context: Phase 8 Networking (devp2p)

## Plan Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Goal: Implement devp2p networking for peer communication.
- Key components:
  - client/net/rlpx.zig (RLPx protocol)
  - client/net/discovery.zig (discv4/v5)
  - client/net/eth.zig (eth/68 protocol)
- Reference files: nethermind/src/Nethermind/Nethermind.Network/

## Spec References (from prd/ETHEREUM_SPECS_REFERENCE.md)
- devp2p/rlpx.md (RLPx transport)
- devp2p/caps/eth.md (eth/68 protocol)
- devp2p/caps/snap.md (snap/1 protocol)
- devp2p/discv4.md (node discovery v4)
- devp2p/discv5/discv5.md (node discovery v5)
- devp2p/enr.md (ENR format)
- Tests: hive/ devp2p tests; unit tests for protocol encoding

## Nethermind Db Directory Listing (nethermind/src/Nethermind/Nethermind.Db/)
- BlobTxsColumns.cs
- Blooms/
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
- Nethermind.Db.csproj
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

## Voltaire Zig APIs (voltaire/packages/voltaire-zig/src/)
- blockchain/
- c_api.zig
- crypto/
- evm/
- jsonrpc/
- log.zig
- precompiles/
- primitives/
- root.zig
- state-manager/

## Existing Zig File Reviewed
- src/host.zig
  - HostInterface with vtable for balance, code, storage, nonce access.
  - Note: EVM handles nested calls internally; HostInterface is for external state access.

## Ethereum Tests Fixtures
- ethereum-tests/ABITests
- ethereum-tests/BasicTests
- ethereum-tests/BlockchainTests
- ethereum-tests/DifficultyTests
- ethereum-tests/EOFTests
- ethereum-tests/GenesisTests
- ethereum-tests/JSONSchema
- ethereum-tests/KeyStoreTests
- ethereum-tests/LegacyTests
- ethereum-tests/PoWTests
- ethereum-tests/RLPTests
- ethereum-tests/TransactionTests
- ethereum-tests/TrieTests
- ethereum-tests/ansible
- ethereum-tests/docs
- ethereum-tests/src
- ethereum-tests/fixtures_blockchain_tests.tgz
- ethereum-tests/fixtures_general_state_tests.tgz

## Notes
- Phase 8 focuses on devp2p networking, using RLPx transport, eth/68, discovery v4/v5, and ENR format.
- Follow Nethermind network architecture for structure; use Voltaire primitives and existing EVM/host patterns for integration.
