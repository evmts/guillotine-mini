# [Pass 1/5] Phase 6: JSON-RPC Server - Implementation Context

## Phase Goal (from plan)
Implement the Ethereum JSON-RPC API.

Key components:
- `client/rpc/server.zig` - HTTP/WebSocket server
- `client/rpc/eth.zig` - `eth_*` methods
- `client/rpc/net.zig` - `net_*` methods
- `client/rpc/web3.zig` - `web3_*` methods

Reference architecture:
- Nethermind: `nethermind/src/Nethermind/Nethermind.JsonRpc/`
- OpenRPC specs: `execution-apis/src/eth/`

---

## 1. Spec References (status in this workspace)

### OpenRPC Ethereum JSON-RPC (execution-apis)
Location: `execution-apis/src/eth/`
- `block.yaml`
- `client.yaml`
- `execute.yaml`
- `fee_market.yaml`
- `filter.yaml`
- `sign.yaml`
- `state.yaml`
- `submit.yaml`
- `transaction.yaml`

### EIP-1474 (Remote procedure call specification)
Location: `EIPs/EIPS/eip-1474.md`

### Execution specs (execution-specs)
- `execution-specs/` does not define JSON-RPC methods; use for execution semantics only.

---

## 2. Nethermind Reference (JSON-RPC + DB inventory)

### JSON-RPC module (structural reference)
Location: `nethermind/src/Nethermind/Nethermind.JsonRpc/`
Notable responsibilities (per Nethermind layout):
- Request/response models
- Module dispatch and method resolution
- Error code mapping and JSON-RPC 2.0 error payloads
- WebSocket transport plumbing

### Requested listing: Nethermind DB module
Location: `nethermind/src/Nethermind/Nethermind.Db/`
Key files:
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

---

## 3. Voltaire Zig APIs (must use)

### Requested path
Expected path: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- Status: path does not exist in this environment.

### Actual Zig JSON-RPC types in Voltaire
Observed Zig JSON-RPC sources at: `/Users/williamcory/voltaire/src/jsonrpc/`
Relevant Zig APIs:
- `/Users/williamcory/voltaire/src/jsonrpc/root.zig` - `JsonRpc` union and `eth`, `debug`, `engine` namespace exports.
- `/Users/williamcory/voltaire/src/jsonrpc/JsonRpc.zig` - `JsonRpcMethod` union with `.methodName()`.
- `/Users/williamcory/voltaire/src/jsonrpc/types.zig` - shared base types: `Address`, `Hash`, `Quantity`, `BlockTag`, `BlockSpec`.
- `/Users/williamcory/voltaire/src/jsonrpc/eth/methods.zig` - `EthMethod` union (per-method types under `eth/*`).
- `/Users/williamcory/voltaire/src/jsonrpc/debug/methods.zig` - `DebugMethod` union.
- `/Users/williamcory/voltaire/src/jsonrpc/engine/methods.zig` - `EngineMethod` union.

Namespace gaps:
- `/Users/williamcory/voltaire/src/jsonrpc/net/` and `/Users/williamcory/voltaire/src/jsonrpc/web3/` contain JS-only `methods.js`; no Zig method unions found.

---

## 4. Existing Zig EVM Integration Surface

### Host Interface
File: `src/host.zig`
- `HostInterface` is a vtable-based external state bridge: balances, code, storage, nonce.
- EVM nested calls are handled internally; `HostInterface` remains minimal.
- Vtable pattern is a canonical DI-style polymorphism reference for Zig.

---

## 5. Test Fixtures and RPC Suites

### RPC-oriented suites
- `hive/` is empty (RPC/Engine API suites not present in this workspace).
- `execution-spec-tests/` is empty (no RPC fixtures present).

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
Captured Phase 6 JSON-RPC goals and component targets from the plan. Confirmed OpenRPC specs under `execution-apis/src/eth/` and EIP-1474 at `EIPs/EIPS/eip-1474.md`. Noted Nethermind JSON-RPC module location and inventoried the Nethermind DB module. The requested Voltaire Zig path does not exist, but Zig JSON-RPC types are present under `/Users/williamcory/voltaire/src/jsonrpc/` (eth/debug/engine), while `net` and `web3` are JS-only. Recorded the existing `src/host.zig` host interface and available `ethereum-tests/` fixture directories; RPC-focused suites (`hive`, `execution-spec-tests`) are empty in this workspace.
