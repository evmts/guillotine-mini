# [pass 2/5] phase-6-jsonrpc (JSON-RPC Server)

## Goal (from plan)

Implement the Ethereum JSON-RPC API:
- `client/rpc/server.zig` — HTTP/WebSocket server
- `client/rpc/eth.zig` — `eth_*` methods
- `client/rpc/net.zig` — `net_*` methods
- `client/rpc/web3.zig` — `web3_*` methods

---

## Specs to Anchor Behavior

### execution-apis (OpenRPC)

Method definitions, params, result schemas, and error cases live in:
- `execution-apis/src/eth/block.yaml`
- `execution-apis/src/eth/client.yaml`
- `execution-apis/src/eth/execute.yaml`
- `execution-apis/src/eth/fee_market.yaml`
- `execution-apis/src/eth/filter.yaml`
- `execution-apis/src/eth/sign.yaml`
- `execution-apis/src/eth/state.yaml`
- `execution-apis/src/eth/submit.yaml`
- `execution-apis/src/eth/transaction.yaml`

### EIPs (JSON-RPC rules + block identifiers)

- `EIPs/EIPS/eip-1474.md`
  - JSON-RPC method set, error codes, and `Quantity`/`Data` encoding rules.
- `EIPs/EIPS/eip-1898.md`
  - `blockHash` / `blockNumber` object form for default block parameters and canonicality handling.

---

## Nethermind Architecture References

### JsonRpc module

Key files in `nethermind/src/Nethermind/Nethermind.JsonRpc/`:
- `JsonRpcProcessor.cs`, `JsonRpcRequest.cs`, `JsonRpcResponse.cs` — request parsing/dispatch and response formatting.
- `Error.cs`, `ErrorCodes.cs` — error mapping and canonical codes.
- `Modules/` — per-namespace RPC method implementations.
- `Converters/` — JSON serialization helpers.
- `WebSockets/` — WS transport and subscriptions.
- `JsonRpcService.cs`, `JsonRpcConfig.cs` — service wiring and configuration.

### Nethermind.Db (storage backing primitives)

Files in `nethermind/src/Nethermind/Nethermind.Db/` relevant for patterns:
- `IDb.cs`, `IReadOnlyDb.cs`, `IColumnsDb.cs`, `IFullDb.cs` — DB abstractions.
- `DbProvider.cs`, `DbProviderExtensions.cs`, `ReadOnlyDbProvider.cs` — DB lifecycle/wiring.
- `MemDb.cs`, `MemColumnsDb.cs`, `InMemoryWriteBatch.cs`, `InMemoryColumnBatch.cs` — in-memory implementations and batching.
- `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs` — read-only adapters.
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs` — persistent storage tuning.

---

## Voltaire Primitives (must-use)

Relevant APIs in `/Users/williamcory/voltaire/packages/voltaire-zig/src/`:
- `jsonrpc/JsonRpc.zig` — `JsonRpcMethod` union combining `engine`, `eth`, and `debug` namespaces.
- `jsonrpc/eth/methods.zig` — `EthMethod` union with typed params/results for each `eth_*` call.
- `jsonrpc/engine/methods.zig`, `jsonrpc/debug/methods.zig` — method definitions for other namespaces.
- `jsonrpc/types.zig` — shared base types:
  - `jsonrpc/types/Address.zig`
  - `jsonrpc/types/Hash.zig`
  - `jsonrpc/types/Quantity.zig`
  - `jsonrpc/types/BlockTag.zig`
  - `jsonrpc/types/BlockSpec.zig`
- `primitives/` and `crypto/` — core Address/Hash/keccak types used by RPC payloads.

---

## Existing Zig Integration Points

- `src/host.zig` — EVM `HostInterface` vtable for state access. RPC calls that need execution (`eth_call`, `eth_estimateGas`) must reuse existing host/EVM integration patterns.

---

## Test Fixtures to Reuse

From `ethereum-tests/` (available directories):
- `ethereum-tests/ABITests/`
- `ethereum-tests/BasicTests/`
- `ethereum-tests/BlockchainTests/`
- `ethereum-tests/DifficultyTests/`
- `ethereum-tests/EOFTests/`
- `ethereum-tests/GenesisTests/`
- `ethereum-tests/KeyStoreTests/`
- `ethereum-tests/LegacyTests/`
- `ethereum-tests/PoWTests/`
- `ethereum-tests/RLPTests/`
- `ethereum-tests/TransactionTests/`
- `ethereum-tests/TrieTests/`

Additional RPC coverage:
- `hive/` — RPC conformance suites.
- `execution-spec-tests/` — RPC-related fixtures (state/tx/block query expectations).
