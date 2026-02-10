# [pass 1/5] phase-6-jsonrpc (JSON-RPC Server) — Context

This file consolidates the minimal, high-signal references to implement the JSON-RPC server while strictly using Voltaire primitives and the existing EVM. It maps PRD goals to spec sources, architectural references, and concrete code paths to accelerate implementation.

## Phase Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Goal: Implement the Ethereum JSON-RPC API.
- Key components (planned in this repo):
  - `client/rpc/server.zig` — HTTP/WebSocket server entry, request parsing, dispatch.
  - `client/rpc/eth.zig` — `eth_*` namespace handlers (delegate to chain/state/EVM).
  - `client/rpc/net.zig` — `net_*` namespace handlers.
  - `client/rpc/web3.zig` — `web3_*` namespace handlers.
- References:
  - Nethermind: `nethermind/src/Nethermind/Nethermind.JsonRpc/`
  - Execution APIs (OpenRPC): `execution-apis/src/eth/`

## Spec Files (authoritative sources to follow)
- JSON-RPC API definitions (OpenRPC): `execution-apis/src/eth/`
  - Examples present: `block.yaml`, `client.yaml`, `execute.yaml`, `fee_market.yaml`, `filter.yaml`, `sign.yaml`, `state.yaml`, `submit.yaml`, `transaction.yaml`.
- EIP-1474 (Remote procedure call specification): `EIPs/EIPS/eip-1474.md`
- EIP-1898 (Block identifier object for defaultBlock): `EIPs/EIPS/eip-1898.md` (required by EIP-1474 semantics for block params)

Notes:
- Follow EIP-1474 error codes and encoding rules (Quantity/Data) exactly.
- Accept both legacy block tags and EIP-1898 block object forms where applicable.

## Voltaire APIs to Use (no custom duplicates)
Root: `/Users/williamcory/voltaire/packages/voltaire-zig/src/jsonrpc/` and `/primitives`
- JSON-RPC surface:
  - `voltaire/packages/voltaire-zig/src/jsonrpc/root.zig` — exports `JsonRpc`, `eth`, `debug`, `engine`, `types`.
  - `voltaire/packages/voltaire-zig/src/jsonrpc/JsonRpc.zig` — `pub const JsonRpcMethod = union(enum) { engine, eth, debug }` with `.methodName()`.
  - Namespaced method enums: `jsonrpc/eth/methods.zig`, `jsonrpc/debug/methods.zig`, `jsonrpc/engine/methods.zig`.
  - Typed params/results under `jsonrpc/types/` (reusable JSON codecs: `jsonParseFromValue`, `jsonStringify`).
- Primitives (must use, never re-create):
  - `primitives/JsonRpcErrorCode`, `primitives/Block`, `BlockHeader`, `BlockHash`, `BlockNumber`, `Transaction`, `Receipt`, `Address`, `Bytes`, `Uint/*`, etc. via `primitives/root.zig`.

Implication: Implement server/dispatch only; method shapes and JSON codec logic come from Voltaire. No ad-hoc JSON parsing/types.

## Nethermind Reference (structure only)
- DB abstractions (used by RPC data queries): `nethermind/src/Nethermind/Nethermind.Db/`
  - Key files: `DbProvider.cs`, `IDbProvider.cs`, `IDb.cs`, `IReadOnlyDbProvider.cs`, `ReadOnlyDbProvider.cs`, `RocksDbSettings.cs`, `DbNames.cs`, `ReceiptsColumns.cs`, `BlobTxsColumns.cs`, `Blooms/`, `FullPruning/*`.
- JSON-RPC organization (module routing, batching, codecs): `nethermind/src/Nethermind/Nethermind.JsonRpc/`
  - Core: `JsonRpcProcessor.cs`, `JsonRpcRequest.cs`, `JsonRpcResponse.cs`, `Error.cs`, `ErrorCodes.cs`, `JsonRpcService.cs`, `WebSockets/`.
  - Modules (map to Zig files): `Modules/Eth`, `Modules/Net`, `Modules/Web3`, `Modules/Trace`, `Modules/TxPool`, etc.

Takeaway: mirror the modular layout and dispatch flow (method → module → service) idiomatically in Zig using comptime DI and Voltaire types.

## Existing Zig Surfaces Touched by RPC
- EVM host (for `eth_call`, tracing, code queries): `src/host.zig` — minimal external state vtable used by `src/evm.zig`.
  - Always drive execution via the existing `src/evm.zig` and friends (`call_params.zig`, `call_result.zig`). Never reimplement EVM.

## Test Fixtures and Suites
- `ethereum-tests/BlockchainTests/` — block/chain fixtures for data/receipt queries.
- `ethereum-tests/TrieTests/`, `ethereum-tests/TransactionTests/` — auxiliary verification.
- `execution-spec-tests/` — additional state/blockchain fixtures.
- RPC-specific:
  - `hive/` — RPC/Engine API test suites.
  - `execution-apis/src/eth/*.yaml` — method schemas and examples usable as request/response vectors.

Note: `ethereum-tests/fixtures_general_state_tests.tgz` suggests some suites are archived; unpack when needed.

## Implementation Pointers (non-normative)
- Server: build HTTP/WS server (`client/rpc/server.zig`) that parses requests into `voltaire.jsonrpc.JsonRpcMethod` via method-name → enum mapping from Voltaire, then dispatches to namespace-specific handlers.
- DI: use comptime injection (as in existing EVM) to wire services (chain/state/txpool) into handlers without globals.
- Errors: return `JsonRpcErrorCode` per EIP-1474; never silently catch or coerce errors.
- Performance: zero-copy parse/serialize with Voltaire codecs; reuse allocators; avoid per-request heap churn.
- Tests: every handler public fn must have unit tests; add golden vectors from OpenRPC examples.

## Paths Summary
- PRD plan: `prd/GUILLOTINE_CLIENT_PLAN.md`
- Specs: `execution-apis/src/eth/`, `EIPs/EIPS/eip-1474.md`, `EIPs/EIPS/eip-1898.md`
- Voltaire JSON-RPC: `/Users/williamcory/voltaire/packages/voltaire-zig/src/jsonrpc/`
- Voltaire primitives: `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/`
- Nethermind (structure): `nethermind/src/Nethermind/Nethermind.JsonRpc/`, `nethermind/src/Nethermind/Nethermind.Db/`
- Guillotine EVM host: `src/host.zig`
- Tests: `ethereum-tests/`, `execution-spec-tests/`, `hive/`
