# [pass 2/5] phase-6-jsonrpc (JSON-RPC Server)

## Goal (from plan)

Implement the Ethereum JSON-RPC API, including:
- `client/rpc/server.zig` — HTTP/WebSocket server
- `client/rpc/eth.zig` — `eth_*` methods
- `client/rpc/net.zig` — `net_*` methods
- `client/rpc/web3.zig` — `web3_*` methods

---

## Specs to Anchor Behavior

### execution-apis (OpenRPC)

Primary RPC method definitions (names, params, result schemas, error cases):
- `execution-apis/src/eth/client.yaml`
  - Core identity + network queries: `eth_chainId`, `eth_syncing`, `eth_coinbase`, `eth_accounts`, `eth_blockNumber`, `net_version`.
- `execution-apis/src/eth/block.yaml`
  - Block fetch (`eth_getBlockByHash`, `eth_getBlockByNumber`), hydration flag, pruned history error, and full block schema fields (withdrawals, blob gas fields, etc).
- `execution-apis/src/eth/filter.yaml`
  - Filter lifecycle and polling (`eth_newFilter`, `eth_newBlockFilter`, `eth_newPendingTransactionFilter`, `eth_getFilterChanges`, `eth_getFilterLogs`, `eth_uninstallFilter`) + `Filter`/`FilterResults` schema details.

Additional method groups live in the same directory and must be covered during implementation:
- `execution-apis/src/eth/execute.yaml`, `fee_market.yaml`, `state.yaml`, `transaction.yaml`, `submit.yaml`, `sign.yaml`.

### EIPs (JSON-RPC rules + block spec)

- `EIPs/EIPS/eip-1474.md`
  - JSON-RPC method set, standard/non-standard error codes, `Quantity`/`Data` encoding rules, and default block identifier behavior.
- `EIPs/EIPS/eip-1898.md`
  - `blockHash` / `blockNumber` object form for default block parameters and canonicality handling for state queries.

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
- `IDb.cs`, `IReadOnlyDb.cs`, `IColumnsDb.cs` — DB abstractions.
- `DbProvider.cs`, `DbProviderExtensions.cs` — DB lifecycle/wiring.
- `MemDb.cs`, `MemColumnsDb.cs`, `InMemoryWriteBatch.cs` — in-memory implementations and batching.
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs` — persistent storage tuning.

---

## Voltaire Primitives (must-use)

Relevant APIs in `/Users/williamcory/voltaire/packages/voltaire-zig/src/`:
- `jsonrpc/root.zig` and `jsonrpc/JsonRpc.zig` — root JSON-RPC union + method definitions.
- `jsonrpc/eth/methods.zig` — typed `eth_*` method definitions.
- `jsonrpc/types.zig` — shared base types:
  - `types/Address.zig`, `types/Hash.zig`, `types/Quantity.zig`, `types/BlockTag.zig`, `types/BlockSpec.zig`.
- `primitives/` and `crypto/` (where needed for hashes/encodings referenced by JSON-RPC types).

---

## Existing Zig Integration Points

- `src/host.zig` — EVM `HostInterface` vtable for state access. RPC paths that need EVM execution (`eth_call`, `eth_estimateGas`, etc.) must reuse the existing host/EVM integration patterns.

---

## Test Fixtures to Reuse

From `ethereum-tests/` (available directories):
- `ethereum-tests/BasicTests/`
- `ethereum-tests/BlockchainTests/`
- `ethereum-tests/TransactionTests/`
- `ethereum-tests/RLPTests/`
- `ethereum-tests/TrieTests/`
- `ethereum-tests/EOFTests/`
- `ethereum-tests/DifficultyTests/`
- `ethereum-tests/GenesisTests/`
- `ethereum-tests/LegacyTests/`
- `ethereum-tests/PoWTests/`
- `ethereum-tests/KeyStoreTests/`

Additional RPC coverage:
- `hive/` — RPC conformance suites.
- `execution-spec-tests/` — RPC-related fixtures (if present for state/tx/block queries).
