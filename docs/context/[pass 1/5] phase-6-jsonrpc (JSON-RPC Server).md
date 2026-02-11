# Context: [pass 1/5] phase-6-jsonrpc (JSON-RPC Server)

## Phase Goal (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Implement the Ethereum JSON-RPC API.
- Target components:
  - `client/rpc/server.zig` — HTTP/WebSocket server
  - `client/rpc/eth.zig` — eth_* methods
  - `client/rpc/net.zig` — net_* methods
  - `client/rpc/web3.zig` — web3_* methods
- Primary references:
  - Nethermind: `nethermind/src/Nethermind/Nethermind.JsonRpc/`
  - Execution APIs: `execution-apis/src/eth/`

## Relevant Specs (from prd/ETHEREUM_SPECS_REFERENCE.md)
- EIP-1474 — Remote procedure call specification.
- execution-apis OpenRPC definitions: `execution-apis/src/eth/`.
- Additional: Engine API lives in `execution-apis/src/engine/` (later phase, cross-referenced by Voltaire jsonrpc.engine for types).

## Nethermind References — Db module scan (ls nethermind/src/Nethermind/Nethermind.Db)
Key files (storage interfaces/impls often used by RPC subsystems, e.g., filters, blocks, receipts):
- `IDb.cs`, `IDbProvider.cs`, `IReadOnlyDb.cs`, `IColumnsDb.cs`, `ITunableDb.cs` — abstractions
- `MemDb.cs`, `MemColumnsDb.cs`, `InMemoryWriteBatch.cs` — in-memory backends
- `RocksDbSettings.cs`, `CompressingDb.cs`, `RocksDbMergeEnumerator.cs` — RocksDB-related
- `ReadOnlyDb.cs`, `ReadOnlyDbProvider.cs`, `DbProvider.cs` — providers and wrappers
- `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/*` — pruning controls
- `BlobTxsColumns.cs`, `ReceiptsColumns.cs`, `MetadataDbKeys.cs` — column definitions/keys

Note: While JSON-RPC maps to Nethermind.JsonRpc in architecture, its data access mirrors Db contracts above. We will mirror this separation in Zig via our own adapters using Voltaire primitives.

## Voltaire Zig APIs (ls /Users/williamcory/voltaire/packages/voltaire-zig/src)
Core modules relevant to Phase 6:
- `jsonrpc/` — Typed JSON-RPC method unions and base types:
  - `jsonrpc/root.zig` → exports `JsonRpc`, namespaces `eth`, `debug`, `engine`, and shared `types`.
  - `jsonrpc/JsonRpc.zig` → `JsonRpcMethod` union combining namespaces with `.methodName()`.
  - `jsonrpc/eth/methods.zig` → `EthMethod` tagged union, parsing via `fromMethodName`, per-method param/result types.
  - `jsonrpc/engine/methods.zig` and `jsonrpc/debug/methods.zig` — available for completeness; engine is used next phase.
  - `jsonrpc/types.zig` with Address, Hash, Quantity, BlockTag, BlockSpec.
- `primitives/` — canonical Ethereum types used by RPC handlers:
  - Address, Hash, Uint (u256 family under `primitives/Uint`), Rlp, Block*, Receipt, Log/Event, Transaction, Bloom, etc.
- `crypto/` — keccak/rlp-related crypto utilities when needed by encoders/ID lookups.
- `state-manager/` — will back handler implementations via Host/WorldState adapters in earlier phases.

Strict rule: ALWAYS use Voltaire primitives for JSON-RPC request/response types and domain values. Do not introduce parallel types.

## Existing Zig Host Interface (src/host.zig)
- `HostInterface` with vtable providing: `getBalance`, `setBalance`, `getCode`, `setCode`, `getStorage`, `setStorage`, `getNonce`, `setNonce`.
- Uses `primitives.Address.Address` and `u256` for values.
- EVM handles nested calls internally (note in comments); Host is for external state access. RPC handlers should integrate through world-state/chain services that utilize this Host.

## Test Fixtures
- ethereum-tests directories (ls ethereum-tests/):
  - `BlockchainTests/`, `TrieTests/`, plus `TransactionTests/`, `EOFTests/`, `BasicTests/`.
  - General state tests are provided as archives: `ethereum-tests/fixtures_blockchain_tests.tgz`, `ethereum-tests/fixtures_general_state_tests.tgz`.
- execution-apis (OpenRPC schemas) at `execution-apis/src/eth/`.
- execution-spec-tests available under `execution-spec-tests/` (RPC fixtures noted in specs doc).
- hive test suites under `hive/` for integration (RPC + Engine API).

## Paths Summary
- Plan: `prd/GUILLOTINE_CLIENT_PLAN.md`
- Specs: `prd/ETHEREUM_SPECS_REFERENCE.md`, `execution-apis/src/eth/`, EIP-1474 in `EIPs/`
- Nethermind reference: `nethermind/src/Nethermind/Nethermind.JsonRpc/`, `nethermind/src/Nethermind/Nethermind.Db/`
- Voltaire APIs: `/Users/williamcory/voltaire/packages/voltaire-zig/src/jsonrpc/`, `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/`
- Host: `src/host.zig`
