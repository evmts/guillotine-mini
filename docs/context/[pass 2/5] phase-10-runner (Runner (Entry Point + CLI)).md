# [pass 2/5] phase-10-runner (Runner (Entry Point + CLI))

## Phase goal (prd/GUILLOTINE_CLIENT_PLAN.md)
- Create the CLI entry point and configuration.
- Key components: `client/main.zig`, `client/config.zig`, `client/cli.zig`.
- Reference architecture: `nethermind/src/Nethermind/Nethermind.Runner/`.

## Specs read (prd/ETHEREUM_SPECS_REFERENCE.md)
- Phase 10 specs: N/A (CLI/configuration).
- Tests: integration tests and `hive/` full node suites.

## Nethermind Runner reference (nethermind/src/Nethermind/Nethermind.Runner/)
- `Program.cs`: CLI parsing (System.CommandLine), logging bootstrap, plugin loading, config provider creation (args/env/json file), data directory + DB path resolution, runner start/stop with graceful shutdown.
- `configs/`: shipped config files (mainnet/testnets).
- `Logging/`, `Monitoring/`, `JsonRpc/`, `Ethereum/`: module wiring for logging, metrics, RPC, and chain runner.
- `NethermindPlugins.cs`: embedded plugin list and plugin loader wiring.
- `NLog.config`: default logging configuration.

## Nethermind DB reference (nethermind/src/Nethermind/Nethermind.Db/)
- Key files: `IDb.cs`, `IReadOnlyDb.cs`, `IColumnsDb.cs`, `IFullDb.cs`, `IDbFactory.cs`, `IDbProvider.cs`, `DbProvider.cs`, `DbProviderExtensions.cs`, `DbNames.cs`, `DbExtensions.cs`, `MemDb.cs`, `MemColumnsDb.cs`, `InMemoryWriteBatch.cs`, `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`, `ReceiptsColumns.cs`, `BlobTxsColumns.cs`, `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/`.

## Voltaire APIs (voltaire/packages/voltaire-zig/src/)
- `log.zig`: logging primitives.
- `jsonrpc/` + `jsonrpc/JsonRpc.zig`: RPC method/type definitions for wiring RPC services in the runner.
- `primitives/Chain/Chain.zig`, `primitives/ChainId/ChainId.zig`, `primitives/NetworkId/NetworkId.zig`: chain selection and network identity.
- `primitives/NodeInfo/NodeInfo.zig`, `primitives/PeerInfo/PeerInfo.zig`, `primitives/SyncStatus/SyncStatus.zig`: node status + sync reporting used by CLI/RPC.
- `primitives/Bytes/Bytes.zig`, `primitives/Hash/Hash.zig`, `primitives/Address/Address.zig`: common CLI/RPC parameters and identifiers.
- `root.zig`: Voltaire public entrypoint for shared primitives.

## Existing Zig files
- `src/host.zig`: EVM HostInterface vtable (balance/code/storage/nonce access). EVM inner calls bypass HostInterface.

## Test fixtures (ethereum-tests/)
- Top-level dirs: `ABITests/`, `BasicTests/`, `BlockchainTests/`, `DifficultyTests/`, `EOFTests/`, `GenesisTests/`, `KeyStoreTests/`, `LegacyTests/`, `PoWTests/`, `RLPTests/`, `TransactionTests/`, `TrieTests/`.
- Full-node integration: `hive/` (per prd/ETHEREUM_SPECS_REFERENCE.md).

## Notes for implementation
- Mirror Nethermind flow: parse CLI, configure logging early, load plugins/config, resolve data/DB paths, build services (RPC/engine/sync), start runner, handle SIGTERM/ProcessExit for graceful shutdown.
- Config source precedence: CLI args -> env vars -> config file (Nethermind uses `configs/` with `.json` and legacy `.cfg`, warning on deprecated `.cfg`).
- Support `--help`/`--version` without noisy logs (Nethermind suppresses logging when help/version is requested).
- Keep plugin loading + dynamic option registration (Nethermind reflects config interfaces and adds `--{category}.{name}` options).
