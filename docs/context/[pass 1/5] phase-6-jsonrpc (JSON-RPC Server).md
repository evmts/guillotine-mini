# [pass 1/5] phase-6-jsonrpc (JSON-RPC Server) — Context

## Phase Goal (PRD)
Source: `prd/GUILLOTINE_CLIENT_PLAN.md`
- Goal: implement Ethereum JSON-RPC API for phase `phase-6-jsonrpc`.
- Planned components:
  - `client/rpc/server.zig` (HTTP/WebSocket transport + request routing)
  - `client/rpc/eth.zig` (`eth_*` methods)
  - `client/rpc/net.zig` (`net_*` methods)
  - `client/rpc/web3.zig` (`web3_*` methods)
- Structural references:
  - `nethermind/src/Nethermind/Nethermind.JsonRpc/`
  - `execution-apis/src/eth/`

## Relevant Specs Read

### PRD spec map
Source: `prd/ETHEREUM_SPECS_REFERENCE.md`
- Phase 6 references:
  - `execution-apis/src/eth/` (OpenRPC source files)
  - `EIPs/EIPS/eip-1474.md`
  - Test references: `hive/`, `execution-spec-tests/`

### JSON-RPC canonical method specs
Source: `execution-apis/src/eth/*.yaml`
- Files discovered:
  - `execution-apis/src/eth/block.yaml`
  - `execution-apis/src/eth/client.yaml`
  - `execution-apis/src/eth/execute.yaml`
  - `execution-apis/src/eth/fee_market.yaml`
  - `execution-apis/src/eth/filter.yaml`
  - `execution-apis/src/eth/sign.yaml`
  - `execution-apis/src/eth/state.yaml`
  - `execution-apis/src/eth/submit.yaml`
  - `execution-apis/src/eth/transaction.yaml`
- Method inventory extracted from these files includes:
  - chain/client: `eth_chainId`, `eth_syncing`, `eth_accounts`, `eth_blockNumber`, `net_version`
  - block/tx queries: `eth_getBlockByHash`, `eth_getBlockByNumber`, `eth_getTransactionByHash`, `eth_getTransactionReceipt`, `eth_getBlockReceipts`, etc.
  - state: `eth_getBalance`, `eth_getStorageAt`, `eth_getTransactionCount`, `eth_getCode`, `eth_getProof`
  - execution/submit: `eth_call`, `eth_estimateGas`, `eth_sendRawTransaction`, `eth_sendTransaction`
  - fee/filter/sign: `eth_feeHistory`, `eth_gasPrice`, `eth_getLogs`, `eth_newFilter`, `eth_sign`, etc.

### EIP requirements for behavior and wire format
- `EIPs/EIPS/eip-1474.md`
  - JSON-RPC 2.0 request/response shape requirements.
  - Error code set (`-32700 ... -32006`) and message semantics.
  - Strict `Quantity` and `Data` hex encoding constraints.
  - Default block identifier behavior references EIP-1898.
- `EIPs/EIPS/eip-1898.md`
  - `blockHash`/`blockNumber` object form for default block parameter.
  - `requireCanonical` semantics and recommended error handling order.
- `EIPs/EIPS/eip-1193.md`
  - Provider-side request/error/event semantics useful for wallet/provider interoperability, but server implementation source of truth remains `execution-apis` + EIP-1474/1898.

### Execution-specs and devp2p notes
- `execution-specs/README.md` explicitly states JSON-RPC spec is maintained in `execution-apis`.
- `devp2p/` is empty in this workspace checkout; no additional phase-6 RPC constraints were available there.

## Nethermind DB Reference Inventory
Source directory listed: `nethermind/src/Nethermind/Nethermind.Db/`

Key files for phase-6 data access boundaries:
- Provider/abstractions:
  - `nethermind/src/Nethermind/Nethermind.Db/IDb.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/IDbProvider.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/IReadOnlyDbProvider.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/DbProvider.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDbProvider.cs`
- DB naming/columns/config:
  - `nethermind/src/Nethermind/Nethermind.Db/DbNames.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/ReceiptsColumns.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/BlobTxsColumns.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/RocksDbSettings.cs`
- Pruning/read behavior:
  - `nethermind/src/Nethermind/Nethermind.Db/FullPruning/FullPruningDb.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/PruningConfig.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDb.cs`
- Bloom/log support:
  - `nethermind/src/Nethermind/Nethermind.Db/Blooms/BloomStorage.cs`

Implication for Effect.ts:
- Mirror module boundaries (provider/read-only/pruning/columns) while using `Context.Tag` + `Layer` service wiring.

## Voltaire Zig API Inventory (Reference)
Source directory listed: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`

Top-level modules:
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/crypto`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/evm`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/jsonrpc`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/state-manager`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/c_api.zig`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/root.zig`

JSON-RPC-specific APIs discovered:
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/jsonrpc/root.zig`
  - re-exports `JsonRpc`, `eth`, `debug`, `engine`, `types`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/jsonrpc/JsonRpc.zig`
  - root tagged union `JsonRpcMethod` for namespace dispatch
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/jsonrpc/eth/methods.zig`
  - tagged union for `eth_*` methods with typed params/results
- Example method type module:
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/jsonrpc/eth/getBalance/eth_getBalance.zig`

Implementation takeaway for client-ts:
- Use `voltaire-effect/primitives` for Address/Hash/Hex/etc and keep method-level typing aligned to execution-apis semantics.
- Reuse existing guillotine EVM behavior for execution-backed methods (`eth_call`, `eth_estimateGas`) instead of re-deriving semantics.

## Existing Zig Host Interface (Current EVM Integration)
Source read: `src/host.zig`

`HostInterface` summary:
- Vtable-based external state access for EVM:
  - `getBalance` / `setBalance`
  - `getCode` / `setCode`
  - `getStorage` / `setStorage`
  - `getNonce` / `setNonce`
- Important note in file:
  - nested calls are handled internally by EVM (`inner_call` with `CallParams/CallResult`), not through this host interface.

Phase-6 implication:
- RPC handlers should query chain/state services and route execution requests into existing EVM transaction/call paths, not bypassing core execution semantics.

## Ethereum Test Fixture Paths (Directory Inventory)
Top-level directories in `ethereum-tests/`:
- `ethereum-tests/ABITests`
- `ethereum-tests/BasicTests`
- `ethereum-tests/BlockchainTests`
- `ethereum-tests/DifficultyTests`
- `ethereum-tests/EOFTests`
- `ethereum-tests/GenesisTests`
- `ethereum-tests/JSONSchema`
- `ethereum-tests/KeyStoreTests`
- `ethereum-tests/LegacyTests`
- `ethereum-tests/PoWTests`
- `ethereum-tests/RLPTests`
- `ethereum-tests/TransactionTests`
- `ethereum-tests/TrieTests`
- `ethereum-tests/src` (fillers/templates)

Notable fixture subpaths for RPC-relevant state/chain queries:
- `ethereum-tests/BlockchainTests/ValidBlocks/bcEIP1559`
- `ethereum-tests/BlockchainTests/ValidBlocks/bcEIP4844-blobtransactions`
- `ethereum-tests/BlockchainTests/ValidBlocks/bcStateTests`
- `ethereum-tests/BlockchainTests/InvalidBlocks/bcEIP1559`
- `ethereum-tests/BlockchainTests/InvalidBlocks/bcStateTests`
- `ethereum-tests/TransactionTests/ttEIP1559`
- `ethereum-tests/TransactionTests/ttEIP2930`
- `ethereum-tests/TransactionTests/ttEIP3860`
- `ethereum-tests/TrieTests`

Additional RPC fixture path noted in workspace:
- `execution-spec-tests/fixtures/blockchain_tests`

## Immediate Implementation Guardrails (for upcoming phase work)
- Follow method signatures and payload schemas from `execution-apis/src/eth/*.yaml`.
- Enforce EIP-1474 encoding/error rules and EIP-1898 block parameter handling.
- Mirror Nethermind JSON-RPC modular boundaries structurally, but implement idiomatically with Effect (`Context.Tag`, `Layer`, typed errors).
- Keep execution behavior anchored to existing guillotine EVM and world-state services.
