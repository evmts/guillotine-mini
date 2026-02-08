# [pass 2/5] phase-6-jsonrpc (JSON-RPC Server) Context

## Goals (from plan)
- Implement Ethereum JSON-RPC API.
- Key components: `client/rpc/server.zig`, `client/rpc/eth.zig`, `client/rpc/net.zig`, `client/rpc/web3.zig`.
- References: `nethermind/src/Nethermind/Nethermind.JsonRpc/`, `execution-apis/src/eth/`.

## Specs (phase-6 JSON-RPC)
- `execution-apis/src/eth/block.yaml` — block query methods (by hash/number, receipts, tx counts).
- `execution-apis/src/eth/client.yaml` — chainId, syncing, coinbase, accounts, blockNumber, net_version.
- `execution-apis/src/eth/execute.yaml` — eth_call, estimateGas, createAccessList.
- `execution-apis/src/eth/fee_market.yaml` — feeHistory, gasPrice, maxPriorityFeePerGas, blobBaseFee.
- `execution-apis/src/eth/filter.yaml` — filter lifecycle and logs queries.
- `execution-apis/src/eth/sign.yaml` — sign, signTransaction (client-managed).
- `execution-apis/src/eth/state.yaml` — getBalance, getCode, getStorageAt, getProof, getTransactionCount.
- `execution-apis/src/eth/submit.yaml` — sendTransaction, sendRawTransaction.
- `execution-apis/src/eth/transaction.yaml` — tx queries by hash/block/index, receipts.
- `EIPs/EIPS/eip-1474.md` — JSON-RPC method set + encoding rules (Quantity/Data) and standard error codes.

## Nethermind reference (DB list requested)
Directory listing for `nethermind/src/Nethermind/Nethermind.Db/`:
- `BlobTxsColumns.cs`
- `CompressingDb.cs`
- `DbExtensions.cs`
- `DbNames.cs`
- `DbProvider.cs`
- `DbProviderExtensions.cs`
- `IColumnsDb.cs`
- `IDb.cs`
- `IDbFactory.cs`
- `IDbProvider.cs`
- `IFullDb.cs`
- `IReadOnlyDb.cs`
- `IReadOnlyDbProvider.cs`
- `ITunableDb.cs`
- `MemDb.cs`
- `MemDbFactory.cs`
- `MetadataDbKeys.cs`
- `Metrics.cs`
- `Nethermind.Db.csproj`
- `NullDb.cs`
- `PruningConfig.cs`
- `PruningMode.cs`
- `ReadOnlyColumnsDb.cs`
- `ReadOnlyDb.cs`
- `ReadOnlyDbProvider.cs`
- `ReceiptsColumns.cs`
- `RocksDbSettings.cs`
- `SimpleFilePublicKeyDb.cs`
- plus auxiliary folders: `Blooms/`, `FullPruning/`

## Voltaire primitives (do not reimplement)
- `voltaire/packages/voltaire-zig/src/jsonrpc/JsonRpc.zig` — `JsonRpcMethod` union over namespaces.
- `voltaire/packages/voltaire-zig/src/jsonrpc/types.zig` — `Address`, `Hash`, `Quantity`, `BlockTag`, `BlockSpec` re-exports.
- `voltaire/packages/voltaire-zig/src/jsonrpc/eth/methods.zig` — eth_* method enum + dispatch helpers.
- `voltaire/packages/voltaire-zig/src/jsonrpc/engine/methods.zig` — engine_* method enum (for later phase).

## Existing Zig host interface
- `src/host.zig` — `HostInterface` vtable for external state access (balances, code, storage, nonce). Not used for nested calls (handled by EVM.inner_call).

## Test fixtures
`ethereum-tests/` top-level directories:
- `ABITests/`, `BasicTests/`, `BlockchainTests/`, `DifficultyTests/`, `EOFTests/`, `GenesisTests/`, `KeyStoreTests/`, `LegacyTests/`, `PoWTests/`, `RLPTests/`, `TransactionTests/`, `TrieTests/`
- Additional fixture archives: `fixtures_blockchain_tests.tgz`, `fixtures_general_state_tests.tgz`
Other relevant RPC test sources:
- `hive/` (RPC suites)
- `execution-spec-tests/` (RPC fixtures)

## Summary
Collected phase-6 JSON-RPC goals, execution-apis OpenRPC method specs, EIP-1474 encoding/error rules, Nethermind DB directory index (as requested), Voltaire JSON-RPC primitives to reuse, the existing host interface, and available ethereum-tests/hive/execution-spec-tests fixture paths.
