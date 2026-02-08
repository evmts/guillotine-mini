# Context: Phase 8 Networking (devp2p)

## Plan goals (from `repo_link/prd/GUILLOTINE_CLIENT_PLAN.md`)
- Implement devp2p networking for peer communication.
- Key components: `client/net/rlpx.zig`, `client/net/discovery.zig`, `client/net/eth.zig`.
- Nethermind architectural reference: `repo_link/nethermind/src/Nethermind/Nethermind.Network/`.

## Relevant specs (from `repo_link/prd/ETHEREUM_SPECS_REFERENCE.md`)
- `devp2p/rlpx.md` (RLPx transport)
- `devp2p/caps/eth.md` (eth/68 protocol)
- `devp2p/caps/snap.md` (snap/1 protocol)
- `devp2p/discv4.md` (node discovery v4)
- `devp2p/discv5/discv5.md` (node discovery v5)
- `devp2p/enr.md` (ENR format)
- Tests: `hive/` devp2p tests; unit tests for protocol encoding.

## Nethermind Db module snapshot (for structural reference)
Directory listing: `repo_link/nethermind/src/Nethermind/Nethermind.Db/`
- `BlobTxsColumns.cs`
- `Blooms/`
- `CompressingDb.cs`
- `DbExtensions.cs`
- `DbNames.cs`
- `DbProvider.cs`
- `DbProviderExtensions.cs`
- `FullPruning/`
- `FullPruningCompletionBehavior.cs`
- `FullPruningTrigger.cs`
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
- `Nethermind.Db.csproj`
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

## Voltaire Zig modules (for primitives and APIs)
Directory listing: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- `blockchain/`
- `c_api.zig`
- `crypto/`
- `evm/`
- `jsonrpc/`
- `log.zig`
- `precompiles/`
- `primitives/`
- `root.zig`
- `state-manager/`

## Existing Zig host interface
File: `repo_link/src/host.zig`
- Defines `HostInterface` with a vtable of minimal state access (balance, code, storage, nonce).
- Uses `primitives.Address.Address` and `u256` types.
- Host interface is for external state access only; nested calls are handled inside the EVM.

## Ethereum test fixtures
Directory listing: `repo_link/ethereum-tests/`
- `BlockchainTests/`
- `TrieTests/`
- `TransactionTests/`
- `RLPTests/`
- `GenesisTests/`
- `EOFTests/`
- `DifficultyTests/`
- `KeyStoreTests/`
- `ABITests/`
- `BasicTests/`
- `LegacyTests/`
- `PoWTests/`
- `fixtures_blockchain_tests.tgz`
- `fixtures_general_state_tests.tgz`

## Summary
Captured phase-8 networking goals, the specific devp2p specs to consult, Nethermind Db module structure snapshot, Voltaire Zig module surface, the existing EVM HostInterface, and available ethereum-tests fixtures for future networking-related validation.
