# [pass 2/5] phase-10-runner (Runner (Entry Point + CLI))

## Phase goal (prd/GUILLOTINE_CLIENT_PLAN.md)
- Goal: create the CLI entry point and configuration.
- Key components: `client/main.zig`, `client/config.zig`, `client/cli.zig`.
- Reference architecture: `nethermind/src/Nethermind/Nethermind.Runner/`.

## Specs read (prd/ETHEREUM_SPECS_REFERENCE.md)
- Phase 10 specs: N/A (CLI/configuration).
- Tests: integration tests and `hive/` full node suites.

## Nethermind Runner reference (nethermind/src/Nethermind/Nethermind.Runner/)
- `Program.cs`: CLI parsing, logging bootstrap, config providers, data/DB path resolution, runner start/stop with graceful shutdown.
- `configs/`: shipped config files (mainnet/testnets).
- `Logging/`, `Monitoring/`, `JsonRpc/`, `Ethereum/`: wiring for logging, metrics, RPC, and chain runner.
- `NethermindPlugins.cs`: embedded plugin list + plugin loader wiring.
- `NLog.config`: default logging configuration.

## Nethermind DB reference (nethermind/src/Nethermind/Nethermind.Db/)
- Interfaces: `IDb.cs`, `IReadOnlyDb.cs`, `IColumnsDb.cs`, `IFullDb.cs`, `IDbFactory.cs`, `IDbProvider.cs`, `IReadOnlyDbProvider.cs`, `ITunableDb.cs`.
- Providers/helpers: `DbProvider.cs`, `DbProviderExtensions.cs`, `DbNames.cs`, `DbExtensions.cs`.
- In-memory + null: `MemDb.cs`, `MemDbFactory.cs`, `MemColumnsDb.cs`, `InMemoryColumnBatch.cs`, `InMemoryWriteBatch.cs`, `NullDb.cs`, `NullRocksDbFactory.cs`.
- RocksDB + settings: `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`.
- Columns/metadata/pruning: `ReceiptsColumns.cs`, `BlobTxsColumns.cs`, `MetadataDbKeys.cs`, `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/`.
- Metrics + misc: `Metrics.cs`, `SimpleFilePublicKeyDb.cs`.

## Voltaire APIs (voltaire/packages/voltaire-zig/src/)
- Top-level modules: `blockchain/`, `crypto/`, `evm/`, `jsonrpc/`, `precompiles/`, `primitives/`, `state-manager/`, `log.zig`, `root.zig`, `c_api.zig`.
- Likely runner wiring: `log.zig`, `jsonrpc/`, `primitives/Chain/Chain.zig`, `primitives/ChainId/ChainId.zig`, `primitives/NetworkId/NetworkId.zig`, `primitives/NodeInfo/NodeInfo.zig`, `primitives/SyncStatus/SyncStatus.zig`.

## Existing Zig files
- `src/host.zig`: EVM HostInterface vtable (balance/code/storage/nonce access). EVM inner calls bypass HostInterface.

## Test fixtures (ethereum-tests/)
- Top-level dirs: `ABITests/`, `BasicTests/`, `BlockchainTests/`, `DifficultyTests/`, `EOFTests/`, `GenesisTests/`, `KeyStoreTests/`, `LegacyTests/`, `PoWTests/`, `RLPTests/`, `TransactionTests/`, `TrieTests/`.
- Full-node integration: `hive/` (per prd/ETHEREUM_SPECS_REFERENCE.md).

## Notes for implementation
- Mirror Nethermind flow: parse CLI, configure logging early, load plugins/config, resolve data/DB paths, build services (RPC/engine/sync), start runner, handle SIGTERM/ProcessExit for graceful shutdown.
- Config precedence: CLI args -> env vars -> config file (Nethermind uses `configs/` and warns on legacy formats).
- Support `--help`/`--version` without noisy logs; keep plugin loading and dynamic option registration aligned with Nethermind patterns.
