# Phase 7 Engine API Context

## Goals (from plan)
- Implement the Engine API for consensus layer communication.
- Key components:
  - `client/engine/api.zig` (Engine API implementation)
  - `client/engine/payload.zig` (payload building/validation)
- Reference: Nethermind Merge plugin and Engine API specs.

## Relevant Specs and References
- Engine API spec: `execution-apis/src/engine/`
- Merge + randomness:
  - EIP-3675 (The Merge)
  - EIP-4399 (PREVRANDAO)
- Execution specs mapping:
  - `execution-specs/` (authoritative)
  - `EIPs/` (normative changes)
  - `execution-spec-tests/fixtures/blockchain_tests_engine/`
  - `hive/` Engine API tests

## Nethermind Db Directory Listing (for architectural context)
Path: `nethermind/src/Nethermind/Nethermind.Db/`
Key files:
- `DbProvider.cs`, `IDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs`
- `IColumnsDb.cs`, `IMergeOperator.cs`, `ITunableDb.cs`
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`
- `ReadOnlyDbProvider.cs`, `MemDb.cs`, `NullDb.cs`
- `MetadataDbKeys.cs`, `Metrics.cs`

## Voltaire Zig APIs (relevant modules)
Path: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- `jsonrpc/` (likely for Engine API transport or shared JSON handling)
- `primitives/` (Hash, Address, u256, RLP, etc.)
- `blockchain/` (block/header/payload primitives)
- `evm/` (EVM-related helpers, if needed)
- `crypto/` (hashing/signatures)
- `state-manager/` (state access patterns)

## Existing Zig Host Interface
Path: `src/host.zig`
- Defines `HostInterface` with vtable for balance/code/storage/nonce access.
- Minimal test host; EVM uses `CallParams/CallResult` internally for nested calls.

## Ethereum Tests Directories
Path: `ethereum-tests/`
- Relevant high-level fixtures: `BlockchainTests/`, `BasicTests/`, `TransactionTests/`, `TrieTests/`, `RLPTests/`
- Engine API specific: use `execution-spec-tests/fixtures/blockchain_tests_engine/` and `hive/` suites.

## Summary
This phase implements the Engine API (Consensus Layer interface) in Zig, using the Engine spec under `execution-apis/src/engine/`, Merge-related EIPs, and Engine-specific test fixtures. Voltaire provides primitives and JSON-RPC building blocks, while Nethermind’s Merge plugin guides structure. The existing `src/host.zig` host vtable defines the EVM-facing state access pattern to integrate with Engine payload processing.
