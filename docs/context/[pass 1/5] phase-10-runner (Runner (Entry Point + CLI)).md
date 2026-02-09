# [Pass 1/5] Phase 10: Runner (Runner (Entry Point + CLI)) - Implementation Context

## Phase Goal

Create the CLI entry point and configuration surface.

**Key Components** (from plan):
- `client/main.zig` - main entry point
- `client/config.zig` - configuration management
- `client/cli.zig` - CLI argument parsing

**Reference Architecture**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.Runner/`

---

## 1. Spec References (Read First)

**Specs**: N/A (CLI/configuration) per `prd/ETHEREUM_SPECS_REFERENCE.md`.

---

## 2. Nethermind Reference (Runner)

Location: `nethermind/src/Nethermind/Nethermind.Runner/`

Key areas to mirror structurally:
- `Program.cs` - main entry point wiring
- `configs/` - configuration files and templates
- `JsonRpc/` - JSON-RPC runner wiring
- `Logging/` - logging configuration and setup
- `Monitoring/` - metrics/monitoring bootstrapping
- `Ethereum/` - client bootstrap and services
- `NethermindPlugins.cs` - plugin loading/registration
- `ConsoleHelpers.cs` - console I/O helpers

### Requested Listing: Nethermind DB Module Inventory

Location: `nethermind/src/Nethermind/Nethermind.Db/`

Key files (for cross-module reference):
- `IDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs` - core DB interfaces
- `IColumnsDb.cs`, `ITunableDb.cs` - column families and tuning
- `DbProvider.cs`, `IDbProvider.cs`, `IDbFactory.cs` - DB providers and factories
- `MemDb.cs`, `MemColumnsDb.cs`, `InMemoryWriteBatch.cs` - in-memory backends
- `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs` - read-only wrappers
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs` - RocksDB support
- `Metrics.cs` - DB metrics

---

## 3. Voltaire Primitives (Must Use)

Location: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`

Relevant primitives and modules for runner/CLI/config:
- `primitives/ChainId/ChainId.zig`
- `primitives/NetworkId/NetworkId.zig`
- `primitives/Chain/chain.zig`
- `primitives/ForkId/ForkId.zig`
- `primitives/Hardfork/hardfork.zig`, `primitives/Hardfork/Eips.zig`
- `primitives/NodeInfo/NodeInfo.zig`
- `primitives/PeerId/PeerId.zig`, `primitives/PeerInfo/PeerInfo.zig`
- `primitives/TraceConfig/trace_config.zig`
- `jsonrpc/` - JSON-RPC server types
- `log.zig` - logging primitives

---

## 4. Existing Zig EVM Integration Surface

### Host Interface

File: `src/host.zig`

- Defines `HostInterface` (ptr + vtable) for external state access.
- Vtable pattern is the reference for comptime DI-style polymorphism in Zig.

---

## 5. Test Fixtures and Runner Suites

Runner-related suites:
- Integration tests
- `hive/` full node tests

ethereum-tests inventory (requested listing):
- `ethereum-tests/ABITests/`
- `ethereum-tests/BasicTests/`
- `ethereum-tests/BlockchainTests/`
- `ethereum-tests/DifficultyTests/`
- `ethereum-tests/EOFTests/`
- `ethereum-tests/GenesisTests/`
- `ethereum-tests/JSONSchema/`
- `ethereum-tests/KeyStoreTests/`
- `ethereum-tests/LegacyTests/`
- `ethereum-tests/PoWTests/`
- `ethereum-tests/RLPTests/`
- `ethereum-tests/TransactionTests/`
- `ethereum-tests/TrieTests/`

Fixture tarballs:
- `ethereum-tests/fixtures_blockchain_tests.tgz`
- `ethereum-tests/fixtures_general_state_tests.tgz`

---

## Summary

Collected phase-10 runner goals and Zig module targets, confirmed specs are N/A for CLI/config, mapped Nethermind runner structure and key entry points, captured the requested Nethermind DB inventory, listed relevant Voltaire primitives and subsystems for configuration, noted the HostInterface vtable DI pattern, and recorded hive plus ethereum-tests fixture locations.
