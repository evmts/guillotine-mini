# Context: [pass 1/5] phase-6-jsonrpc (JSON-RPC Server)

## Phase Goal (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Implement the Ethereum JSON-RPC API.
- Target components:
  - \ — HTTP/WebSocket server
  - \ — eth_* methods
  - \ — net_* methods
  - \ — web3_* methods
- Primary references:
  - Nethermind: \
  - Execution APIs: \

## Relevant Specs (from prd/ETHEREUM_SPECS_REFERENCE.md)
- EIP-1474 — Remote procedure call specification.
- execution-apis OpenRPC definitions: \.
- Additional: Engine API lives in \ (later phase, cross-referenced by Voltaire jsonrpc.engine for types).

## Nethermind References — Db module scan (ls nethermind/src/Nethermind/Nethermind.Db)
Key files (storage interfaces/impls often used by RPC subsystems, e.g., filters, blocks, receipts):
- \, \, \, \, \ — abstractions
- \, \, \ — in-memory backends
- \, \, \ — RocksDB-related
- \, \, \ — providers and wrappers
- \, \, \ — pruning controls
- \, \, \ — column definitions/keys

Note: While JSON-RPC maps to Nethermind.JsonRpc in architecture, its data access mirrors Db contracts above. We will mirror this separation in Zig via our own adapters using Voltaire primitives.

## Voltaire Zig APIs (ls /Users/williamcory/voltaire/packages/voltaire-zig/src)
Core modules relevant to Phase 6:
- \ — Typed JSON-RPC method unions and base types:
  - \ → exports \, namespaces \, \, \, and shared \.
  - \ → \ union combining namespaces with \.
  - \ → \ tagged union, parsing via \, per-method param/result types.
  - \ and \ — available for completeness; engine is used next phase.
  - \ with Address, Hash, Quantity, BlockTag, BlockSpec.
- \ — canonical Ethereum types used by RPC handlers:
  - Address, Hash, Uint (u256 family under \), Rlp, Block*, Receipt, Log/Event, Transaction, Bloom, etc.
- \ — keccak/rlp-related crypto utilities when needed by encoders/ID lookups.
- \ — will back handler implementations via Host/WorldState adapters in earlier phases.

Strict rule: ALWAYS use Voltaire primitives for JSON-RPC request/response types and domain values. Do not introduce parallel types.

## Existing Zig Host Interface (src/host.zig)
- \ with vtable providing: \, \, \, \, \, \, \, \.
- Uses \ and \ for values.
- EVM handles nested calls internally (note in comments); Host is for external state access. RPC handlers should integrate through world-state/chain services that utilize this Host.

## Test Fixtures
- ethereum-tests directories (ls ethereum-tests/):
  - \, \ (tgz in repo: \), \, plus \, \, \.
- execution-apis (OpenRPC schemas) at \.
- execution-spec-tests available under \ (RPC fixtures noted in specs doc).
- hive test suites under \ for integration (RPC + Engine API).

## Implementation Notes for Phase 6
- Dispatch: Parse method → Voltaire \/namespace union → route to handler using comptime DI (match existing EVM pattern).
- Types: Use Voltaire \ and \ throughout; never define Address/Hash/u256 duplicates.
- Errors: Map to Voltaire \ where appropriate; no silent handling.
- Performance: Zero-copy decode where possible; reuse arena allocators for request scope; avoid heap on hot paths.
- Tests: Each public handler function has unit tests; add protocol-level tests targeting known methods (e.g., \, \).

## Paths Summary
- Plan: \
- Specs: \, \, EIP-1474 in \
- Nethermind reference: \, \
- Voltaire APIs: \, \
- Host: \

