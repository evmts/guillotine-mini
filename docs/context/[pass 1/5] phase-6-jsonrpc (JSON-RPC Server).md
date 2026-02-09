# [Pass 1/5] Phase 6: JSON-RPC Server — Implementation Context

## Phase Goal

Implement the Ethereum JSON-RPC API, including HTTP and WebSocket transports, plus `eth_*`, `net_*`, and `web3_*` namespaces.

**Key Components** (from plan):
- `client/rpc/server.zig` - HTTP/WebSocket server
- `client/rpc/eth.zig` - `eth_*` methods
- `client/rpc/net.zig` - `net_*` methods
- `client/rpc/web3.zig` - `web3_*` methods

**Reference Architecture**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.JsonRpc/`
- OpenRPC specs: `execution-apis/src/eth/`

---

## 1. Spec References (Read First)

### OpenRPC Ethereum JSON-RPC (execution-apis)
Location: `execution-apis/src/eth/`

Key files (method definitions, params/results, examples):
- `block.yaml` - block queries and block/tx metadata responses
- `client.yaml` - client metadata methods
- `execute.yaml` - call/estimate execution pathways
- `fee_market.yaml` - fee history and fee market fields
- `filter.yaml` - filters, logs, and subscriptions
- `sign.yaml` - signing methods
- `state.yaml` - account/storage/state queries
- `submit.yaml` - transaction submission
- `transaction.yaml` - tx queries and receipt responses

### EIP-1474 (Remote procedure call specification)
Location: `EIPs/EIPS/eip-1474.md`

Key rules to carry into implementation:
- JSON-RPC 2.0 request/response schema and error object shape.
- Standard and non-standard error codes (e.g., -32601, -32602, -32001, -32003).
- `Quantity` and `Data` encoding requirements (hex, prefix, minimal digits).
- Block identifier rules reference EIP-1898 for hash/number disambiguation.

---

## 2. Nethermind Reference (JSON-RPC)

Location: `nethermind/src/Nethermind/Nethermind.JsonRpc/`

Key files and responsibilities:
- `JsonRpcProcessor.cs` - request dispatch, method resolution, and error handling
- `JsonRpcRequest.cs` / `JsonRpcResponse.cs` - request/response models
- `JsonRpcService.cs` - service orchestration for RPC modules
- `JsonRpcConfig.cs` / `JsonRpcConfigExtension.cs` - configuration and defaults
- `ErrorCodes.cs` / `Error.cs` - JSON-RPC error codes and payloads
- `Modules/` - per-namespace method implementations (eth/net/web3/debug)
- `WebSockets/` - websocket transport plumbing
- `Client/` - RPC client bindings

### Requested Listing: Nethermind DB Module Inventory
Location: `nethermind/src/Nethermind/Nethermind.Db/`

Key files (for cross-module reference):
- `IDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs` - core DB interfaces
- `IColumnsDb.cs`, `ITunableDb.cs` - column families and tuning
- `DbProvider.cs`, `IDbProvider.cs`, `IDbFactory.cs` - DB provider and factories
- `MemDb.cs`, `MemColumnsDb.cs`, `InMemoryWriteBatch.cs` - in-memory backends
- `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs` - read-only wrappers
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs` - RocksDB support
- `Metrics.cs` - DB metrics

---

## 3. Voltaire JSON-RPC Primitives (Must Use)

Location: `/Users/williamcory/voltaire/packages/voltaire-zig/src/jsonrpc/`

Relevant API surface:
- `root.zig` - re-exports `JsonRpcMethod`, `eth`, `debug`, `engine`, and `types`
- `JsonRpc.zig` - `JsonRpcMethod` union + `methodName()` helper
- `types.zig` - shared JSON-RPC base types:
  - `types.Address`
  - `types.Hash`
  - `types.Quantity`
  - `types.BlockTag`
  - `types.BlockSpec`
- `eth/methods.zig` - `EthMethod` union mapping `Params`/`Result` per method
- `eth/*/` - per-method param/result structs (e.g., `getBalance`, `getLogs`, `sendRawTransaction`)

Notes:
- Voltaire JSON-RPC currently covers `eth`, `debug`, and `engine` namespaces only.
- `net_*` and `web3_*` typed methods are not present in this module; confirm if they exist elsewhere in Voltaire before adding new types.

---

## 4. Existing Zig EVM Integration Surface

### Host Interface
File: `src/host.zig`

- Defines `HostInterface` (ptr + vtable) used for external state access.
- EVM nested calls are handled internally; `HostInterface` is a minimal external state bridge.
- Vtable pattern here is the reference for DI-style polymorphism in Zig.

---

## 5. Test Fixtures and RPC Suites

### RPC-oriented suites
- `hive/` - RPC and Engine API integration tests
- `execution-spec-tests/src/ethereum_test_rpc/` - RPC client types
- `execution-spec-tests/src/pytest_plugins/execute/rpc/` - RPC test harness plugins

### ethereum-tests inventory (requested listing)
Top-level directories:
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

Collected phase-6 JSON-RPC goals and key Zig module targets, verified OpenRPC specs in `execution-apis/src/eth/`, and captured EIP-1474 encoding/error requirements. Mapped Nethermind JSON-RPC architecture for structural reference, inventoried Voltaire JSON-RPC primitives that must be used, noted the existing vtable HostInterface in `src/host.zig`, and recorded available RPC-related test harness paths and ethereum-tests fixtures.
