# [pass 1/5] phase-6-jsonrpc (JSON-RPC Server) — Context

This file collects focused references to implement the JSON-RPC server using Voltaire primitives and guillotine-mini’s existing EVM, following Nethermind’s architecture.

## Phase Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Implement Ethereum JSON-RPC API.
- Key components to add:
  - `client/rpc/server.zig` — HTTP/WebSocket server
  - `client/rpc/eth.zig` — `eth_*` methods
  - `client/rpc/net.zig` — `net_*` methods
  - `client/rpc/web3.zig` — `web3_*` methods
- References:
  - Nethermind: `nethermind/src/Nethermind/Nethermind.JsonRpc/`
  - Specs: `execution-apis/src/eth/`

## Spec References (from prd/ETHEREUM_SPECS_REFERENCE.md)
- EIP-1474 — Ethereum JSON-RPC specification (method shapes, error codes).
- execution-apis OpenRPC YAMLs: `execution-apis/src/eth/`
  - Files: `block.yaml`, `client.yaml`, `execute.yaml`, `fee_market.yaml`, `filter.yaml`, `sign.yaml`, `state.yaml`, `submit.yaml`, `transaction.yaml`.
  - Example (state.yaml): includes `eth_getBalance`, `eth_getStorageAt`, `eth_getTransactionCount`, `eth_getCode`, `eth_getProof` parameter/result schemas.

## Nethermind Architecture (reference only)
- DB abstractions (used by RPC reads/writes via our state/blockchain layers): `nethermind/src/Nethermind/Nethermind.Db/`
  - Key interfaces/classes observed:
    - `IDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs`, `ITunableDb.cs`
    - Providers/factories: `IDbProvider.cs`, `DbProvider.cs`, `ReadOnlyDbProvider.cs`, `IDbFactory.cs`, `MemDbFactory.cs`, `NullRocksDbFactory.cs`
    - Implementations/utilities: `MemDb.cs`, `MemColumnsDb.cs`, `CompressingDb.cs`, `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`
    - Pruning/metrics: `IPruningConfig.cs`, `PruningConfig.cs`, `Metrics.cs`, `FullPruning/*`, `FullPruningCompletionBehavior.cs`, `FullPruningTrigger.cs`
    - Columns/keys: `ReceiptsColumns.cs`, `BlobTxsColumns.cs`, `MetadataDbKeys.cs`
- JSON-RPC module structure (mirror for Zig): see `Nethermind.JsonRpc` in repo (not listed here to keep context minimal). Adopt similar namespace split: `eth`, `debug`, `engine` in Voltaire.

## Voltaire Zig APIs to use (never custom types)
- Root: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- JSON-RPC entry + namespaces: `/jsonrpc/JsonRpc.zig`
  - `pub const JsonRpcMethod = union(enum) { engine, eth, debug, ... }` with `.methodName()` helper.
  - Namespaces: `/jsonrpc/eth/`, `/jsonrpc/engine/`, `/jsonrpc/debug/` (method enums + dispatch).
  - Shared RPC types: `/jsonrpc/types.zig` and `/jsonrpc/types/*` (e.g., `Address.zig`, `Hash.zig`, `Quantity.zig`, `BlockTag.zig`, `BlockSpec.zig`).
- Primitives needed for results/params:
  - `/primitives/Address`, `/primitives/Hash`, `/primitives/Block`, `/primitives/Transaction`, `/primitives/Bytes`, `/primitives/BlockNumber`, `/primitives/Nonce`, `/primitives/Receipt`, `/primitives/AccessList`, etc.
- Blockchain/state helpers (for backing data): `/blockchain`, `/state-manager`.

## Existing guillotine-mini surfaces
- Host interface: `src/host.zig`
  - Minimal external state access vtable with required methods:
    - `getBalance(Address) u256`, `setBalance(Address, u256)`
    - `getCode(Address) []const u8`, `setCode(Address, []const u8)`
    - `getStorage(Address, slot: u256) u256`, `setStorage(Address, slot: u256, value: u256)`
    - `getNonce(Address) u64`, `setNonce(Address, u64)`
  - Note: Nested calls are handled internally by the EVM; HostInterface is for external state. JSON-RPC `eth_getBalance`, `eth_getStorageAt`, `eth_getCode`, `eth_getTransactionCount` should be backed by our world-state/blockchain layers using Voltaire primitives; do not introduce custom types.

## Test Fixtures & Paths
- Classic ethereum-tests (useful for state/tx validation underpinning RPC answers): `ethereum-tests/`
  - `BlockchainTests/`, `TransactionTests/`, `TrieTests/`, `DifficultyTests/`, etc.
- Execution spec tests (contains RPC-specific tools/fixtures): `execution-spec-tests/`
  - RPC-specific helpers: `execution-spec-tests/src/ethereum_test_rpc/`
  - General fixtures directory: `execution-spec-tests/fixtures/`
- Hive (RPC/Engine API integration suites): `hive/`

## Implementation Notes (guidance for upcoming code)
- Use comptime DI similar to EVM for RPC handlers and adapters (e.g., inject state/readers/providers at comptime where possible to avoid virtual dispatch).
- Map OpenRPC schemas to Voltaire JSON-RPC types exactly; avoid re-shaping.
- Ensure zero-allocation hot paths in request parsing/serialization when possible; prefer arena allocators scoped to request handling.
- All public functions must have tests; plan table-driven tests per `eth_*` method against in-memory state.
- Error handling: follow EIP-1474 error codes; never `catch {}` or suppress.

### Key Paths Summarized
- Plan: `prd/GUILLOTINE_CLIENT_PLAN.md` — Phase 6 goals/components
- Specs: `execution-apis/src/eth/` (OpenRPC YAML), `EIPs/` (EIP-1474)
- Nethermind DB reference: `nethermind/src/Nethermind/Nethermind.Db/`
- Voltaire JSON-RPC: `/Users/williamcory/voltaire/packages/voltaire-zig/src/jsonrpc/`
- Voltaire primitives: `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/`
- Guillotine host: `src/host.zig`
- Tests: `ethereum-tests/`, `execution-spec-tests/src/ethereum_test_rpc/`, `hive/`
