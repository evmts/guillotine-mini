# [Pass 1/5] Phase 6: JSON-RPC Server - Implementation Context

## Phase Goal (from plan)
Implement the Ethereum JSON-RPC API, including HTTP/WebSocket transports and the `eth_*`, `net_*`, and `web3_*` namespaces.

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
Expected location: `execution-apis/src/eth/`
- Status: `execution-apis/` submodule is empty (no `src/` present). Initialize/update submodules to access OpenRPC YAMLs.

### EIP-1474 (Remote procedure call specification)
Expected location: `EIPs/EIPS/eip-1474.md`
- Status: `EIPs/` submodule is empty. Initialize/update submodules to read EIP-1474.

### Execution specs (execution-specs)
- `execution-specs/` is present, but it does not contain JSON-RPC definitions. Use for execution semantics only; not a JSON-RPC spec source.

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
- `IDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs`, `IColumnsDb.cs`, `ITunableDb.cs`
- `DbProvider.cs`, `IDbProvider.cs`, `IDbFactory.cs`
- `MemDb.cs`, `MemColumnsDb.cs`, `InMemoryWriteBatch.cs`, `InMemoryColumnBatch.cs`
- `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `ReadOnlyDbProvider.cs`
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`
- `Metrics.cs`, `DbNames.cs`, `DbExtensions.cs`

---

## 3. Voltaire Zig APIs (must use)

### Requested path
Expected path: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- Status: path does not exist in this environment.

### Actual Voltaire Zig root
Observed Zig sources at: `/Users/williamcory/voltaire/src/`
JSON-RPC Zig types live under: `/Users/williamcory/voltaire/src/jsonrpc/`

Key Zig files:
- `/Users/williamcory/voltaire/src/jsonrpc/root.zig` - re-exports JsonRpc union and `eth`, `debug`, `engine` namespaces.
- `/Users/williamcory/voltaire/src/jsonrpc/JsonRpc.zig` - JsonRpcMethod union (method name mapping).
- `/Users/williamcory/voltaire/src/jsonrpc/types.zig` - shared base types: Address, Hash, Quantity, BlockTag, BlockSpec.
- `/Users/williamcory/voltaire/src/jsonrpc/eth/methods.zig` - `EthMethod` union; per-method Zig types in `eth/*/eth_*.zig`.
- `/Users/williamcory/voltaire/src/jsonrpc/debug/methods.zig` - debug namespace Zig types.
- `/Users/williamcory/voltaire/src/jsonrpc/engine/methods.zig` - engine namespace Zig types.

Namespace gaps:
- `/Users/williamcory/voltaire/src/jsonrpc/net/` and `/Users/williamcory/voltaire/src/jsonrpc/web3/` contain JS only; no Zig types found. Expect to confirm or add Zig equivalents before implementing `net_*` and `web3_*` methods.

---

## 4. Existing Zig EVM Integration Surface

### Host Interface
File: `src/host.zig`
- `HostInterface` is a vtable-based external state bridge (balances, code, storage, nonce).
- EVM nested calls are handled internally; HostInterface remains minimal.
- Vtable pattern here is the canonical DI-style polymorphism reference for Zig.

---

## 5. Test Fixtures and RPC Suites

### RPC-oriented suites (submodule status)
- `hive/` submodule is empty (RPC/Engine API suites not present).
- `execution-spec-tests/` submodule is empty (no RPC fixtures present).

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
Captured Phase 6 JSON-RPC goals and component targets from the plan. The OpenRPC spec (`execution-apis`) and EIP-1474 (`EIPs`) submodules are missing in this workspace, so they must be initialized before implementation. Voltaire Zig JSON-RPC types are available under `/Users/williamcory/voltaire/src/jsonrpc/` (eth/debug/engine), with no Zig `net` or `web3` namespace types found. Recorded the existing `src/host.zig` vtable host interface and inventoried available `ethereum-tests/` fixtures; RPC-oriented submodules (`hive`, `execution-spec-tests`) are empty.
