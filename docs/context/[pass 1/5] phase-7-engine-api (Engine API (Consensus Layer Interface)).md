# Context — [pass 1/5] phase-7-engine-api (Engine API (Consensus Layer Interface))

This file gathers targeted references to implement the Engine API surface used by the Consensus Layer. It aligns with Guillotine’s rules: use Voltaire primitives, reuse the existing EVM, mirror Nethermind’s architecture, and keep units small and testable.

## Phase Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Objective: Implement the Engine API that the CL calls into.
- Planned modules:
  - `client/engine/api.zig` — Engine API method handling and dispatch.
  - `client/engine/payload.zig` — Payload construction/validation helpers.
- References to follow:
  - Nethermind Merge plugin: `nethermind/src/Nethermind/Nethermind.Merge.Plugin/` (structure and responsibilities).
  - Execution APIs spec: `execution-apis/src/engine/` (method, params, results, versioning).

## Relevant Specs (from prd/ETHEREUM_SPECS_REFERENCE.md)
- Engine API spec: `execution-apis/src/engine/`.
- Merge: EIP-3675 `EIPs/EIPS/eip-3675.md`.
- PREVRANDAO: EIP-4399 `EIPs/EIPS/eip-4399.md`.
- Blobs (Cancun): EIP-4844 `EIPs/EIPS/eip-4844.md`.
- Tests guidance: Hive Engine API tests; execution-spec-tests fixtures (engine formats) when available/documented.

## Nethermind Reference — Db package inventory (ls)
Path: `nethermind/src/Nethermind/Nethermind.Db/` — key files/classes for storage abstractions used across components (useful for understanding dependency boundaries):
- `IDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs`, `ITunableDb.cs` — core DB interfaces.
- `IDbProvider.cs`, `DbProvider.cs`, `ReadOnlyDbProvider.cs` — provider pattern for composing logical databases.
- `MemDb.cs`, `MemColumnsDb.cs`, `InMemoryWriteBatch.cs`, `InMemoryColumnBatch.cs` — in-memory backends.
- `CompressingDb.cs`, `RocksDbSettings.cs`, `NullRocksDbFactory.cs` — storage and settings.
- `PruningMode.cs`, `IPruningConfig.cs`, `PruningConfig.cs`, `FullPruning*/` — pruning controls.
- `DbExtensions.cs`, `DbProviderExtensions.cs`, `DbNames.cs`, `MetadataDbKeys.cs`, `Metrics.cs` — utilities/metadata.

Rationale: Even though this phase targets Engine API, Nethermind’s modularization around providers and clean interfaces informs our Zig comptime DI surfaces and boundaries between RPC, engine, mempool, and chain/state.

## Voltaire Zig — Relevant APIs
Root: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- JSON-RPC core:
  - `jsonrpc/JsonRpc.zig` — union-dispatch for namespaces; includes `engine` methods.
  - `jsonrpc/types.zig` and `jsonrpc/types/*.zig` — common JSON-RPC value types (Address, Hash, Quantity, BlockTag, BlockSpec).
- Engine API surface (versions per spec):
  - `jsonrpc/engine/methods.zig` — union of all `engine_*` methods and name<->tag mapping.
  - `jsonrpc/engine/*/engine_*.zig` — concrete param/result types + (de)serialization for:
    - `engine_exchangeCapabilities`, `engine_exchangeTransitionConfigurationV1`
    - `engine_forkchoiceUpdatedV1..V3`
    - `engine_getPayloadV1..V6`
    - `engine_getPayloadBodiesByHashV1`, `engine_getPayloadBodiesByRangeV1`
    - `engine_newPayloadV1..V5`
    - `engine_getBlobsV1`, `engine_getBlobsV2`
- Primitives used by Engine API payloads and validations:
  - `primitives/Block*`, `primitives/Hash`, `primitives/Blob`, `primitives/Hardfork`, and related EVM/crypto utilities.

Notes:
- We MUST use these modules and types directly — do not mirror or redefine any Engine API or primitive structures locally.
- The JSON-RPC engine modules already model the versioned param/result shapes we need to pipe into our internal logic.

## Existing Zig Host Interface
Path: `src/host.zig`
- Provides `HostInterface` with vtable methods for `get/set Balance/Code/Storage/Nonce` using Voltaire `Address` and `u256`.
- EVM nested calls bypass this host and use `CallParams/CallResult` internally; the host is for external state access.
- Implication: Engine API → transaction/block processing must adapt to this host/EVM boundary without re-implementing call machinery.

## Test Fixtures — What exists locally
- Classic JSON tests (checked out):
  - `ethereum-tests/BlockchainTests/` (via `execution-spec-tests/fixtures/blockchain_tests -> ethereum-tests/BlockchainTests`).
  - Additional suites present under `ethereum-tests/` include `TrieTests/`, `TransactionTests/`, `EOFTests/`, etc.
- Engine API–specific fixtures:
  - Documentation present in `execution-spec-tests/docs/running_tests/test_formats/blockchain_test_engine.md` and `..._engine_x.md`.
  - Engine fixtures directory not materialized in this checkout; plan to rely on Hive engine harness and/or generate via execution-spec-tests when needed.

## Immediate Implementation Guidance
- Wire our Engine API layer to Voltaire `jsonrpc/engine/*` types and use comptime union dispatch from `jsonrpc/JsonRpc.zig`.
- Keep boundaries: Engine API (RPC surface) → orchestrator (forkchoice/payload mgmt) → chain/state/txpool.
- Reuse Voltaire primitives exclusively for all payloads, hashes, blobs, headers, and JSON-RPC quantities.
- Follow Nethermind’s separation for providers/managers to avoid stateful coupling in Engine handlers.

## Pointers (paths)
- Plan: `prd/GUILLOTINE_CLIENT_PLAN.md`
- Specs: `execution-apis/src/engine/`, `EIPs/EIPS/eip-3675.md`, `EIPs/EIPS/eip-4399.md`, `EIPs/EIPS/eip-4844.md`
- Nethermind ref: `nethermind/src/Nethermind/Nethermind.Db/`
- Voltaire API: `/Users/williamcory/voltaire/packages/voltaire-zig/src/jsonrpc/engine/`, `/Users/williamcory/voltaire/packages/voltaire-zig/src/jsonrpc/JsonRpc.zig`, `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/`
- Host interface: `src/host.zig`
- Tests present: `ethereum-tests/BlockchainTests/`, `ethereum-tests/TrieTests/`, `ethereum-tests/TransactionTests/`, `ethereum-tests/EOFTests/`

