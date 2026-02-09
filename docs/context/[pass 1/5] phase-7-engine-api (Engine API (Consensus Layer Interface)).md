# [Pass 1/5] Phase 7: Engine API (Consensus Layer Interface) — Implementation Context

## Phase Goal

Implement the Engine API for consensus layer communication (post-Merge EL <-> CL).

**Key Components** (from plan):
- `client/engine/api.zig` - Engine API implementation
- `client/engine/payload.zig` - Payload building/validation

**Reference Architecture**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.Merge.Plugin/`
- Engine API specs: `execution-apis/src/engine/`

---

## 1. Spec References (Read First)

### Engine API core specs (execution-apis)
Location: `execution-apis/src/engine/`

Primary documents to anchor behavior:
- `common.md` - base JSON-RPC rules, Engine namespace, error codes, capabilities exchange, ordering
- `authentication.md` - JWT auth rules, secret handling, allowed algs, iat requirements
- `identification.md` - `engine_getClientVersionV1` and `ClientVersionV1` schema
- Fork-scoped method specs:
  - `paris.md` - `engine_newPayloadV1`, `engine_forkchoiceUpdatedV1`, `engine_getPayloadV1`, transition config
  - `shanghai.md` - `ExecutionPayloadV2`, withdrawals, `engine_newPayloadV2`, `engine_getPayloadV2`, payload bodies
  - `cancun.md` / `prague.md` / `osaka.md` / `amsterdam.md` - newer payload versions and blob/aux structures

OpenRPC method/schemas (machine-readable definitions):
- `execution-apis/src/engine/openrpc/methods/`:
  - `payload.yaml`, `forkchoice.yaml`, `transition_configuration.yaml`, `capabilities.yaml`, `blob.yaml`
- `execution-apis/src/engine/openrpc/schemas/` for typed payload/body structures

### Merge/EVM semantics
Location: `EIPs/EIPS/`
- `eip-3675.md` - Merge transition rules, terminal PoW block handling, block field constants, forkchoice changes
- `eip-4399.md` - `PREVRANDAO` semantics; `mixHash`/`prevRandao` usage in post-merge blocks

---

## 2. Nethermind Reference (Engine API)

Location: `nethermind/src/Nethermind/Nethermind.Merge.Plugin/`

Key files and responsibilities:
- `EngineRpcModule.cs` + `EngineRpcModule.*.cs` - engine RPC surface per fork (Paris/Shanghai/Cancun/Prague/Osaka)
- `IEngineRpcModule.cs` + `IEngineRpcModule.*.cs` - interface contracts per fork
- `Handlers/` - per-method request handling flow
- `BlockProduction/` - payload building orchestration
- `MergeHeaderValidator.cs`, `MergeSealValidator.cs`, `MergeUnclesValidator.cs` - post-merge header validation rules
- `MergeFinalizationManager.cs`, `MergeFinalizedStateProvider.cs` - forkchoice/finalization logic
- `InvalidChainTracker/`, `Synchronization/` - invalid payload tracking and sync coupling
- `MergeErrorCodes.cs`, `MergeErrorMessages.cs` - Engine API error mapping

### Requested Listing: Nethermind DB Module Inventory
Location: `nethermind/src/Nethermind/Nethermind.Db/`

Key files (for cross-module reference):
- `IDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs` - core DB interfaces
- `IColumnsDb.cs`, `ITunableDb.cs` - column families and tuning
- `DbProvider.cs`, `IDbProvider.cs`, `IDbFactory.cs` - DB provider and factories
- `MemDb.cs`, `MemColumnsDb.cs`, `InMemoryWriteBatch.cs` - in-memory backends
- `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs` - read-only wrappers
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs` - RocksDB support
- `Metrics.cs` - DB metrics

---

## 3. Voltaire JSON-RPC Primitives (Must Use)

Location: `/Users/williamcory/voltaire/packages/voltaire-zig/src/jsonrpc/`

Relevant API surface:
- `root.zig` - re-exports `JsonRpcMethod`, `eth`, `engine`, `types`
- `JsonRpc.zig` - `JsonRpcMethod` union + `methodName()` helper
- `types.zig` - JSON-RPC base types (Address/Hash/Quantity/BlockTag/etc.)
- `engine/methods.zig` - Engine method union mapping Params/Result per method
- `engine/*/` method folders (must reuse):
  - `newPayloadV1..V5`, `forkchoiceUpdatedV1..V3`, `getPayloadV1..V6`
  - `getPayloadBodiesByHashV1`, `getPayloadBodiesByRangeV1`, `exchangeCapabilities`, `exchangeTransitionConfigurationV1`
  - `getBlobsV1`, `getBlobsV2`

Other relevant Voltaire modules (type sources, do not reimplement):
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/` - core Address/Hash/U256/Bytes primitives
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/` - chain headers/blocks helpers
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/evm/` - EVM core types and helpers

---

## 4. Existing Zig EVM Integration Surface

### Host Interface
File: `src/host.zig`

- Defines `HostInterface` (ptr + vtable) for external state access.
- EVM nested calls handled internally; host interface is a minimal state bridge.
- Vtable pattern is the reference for comptime DI-style polymorphism in Zig.

---

## 5. Test Fixtures and Engine API Suites

Engine API suites:
- `hive/` - Engine API integration tests
- `execution-spec-tests/fixtures/blockchain_tests_engine/` - Engine API blockchain fixtures

ethereum-tests inventory (requested listing):
- `ethereum-tests/ABITests/`
- `ethereum-tests/BasicTests/`
- `ethereum-tests/BlockchainTests/`
- `ethereum-tests/DifficultyTests/`
- `ethereum-tests/EOFTests/`
- `ethereum-tests/GenesisTests/`
- `ethereum-tests/JSONSchema/`
- `ethereum-tests/KeyStoreTests/`
- `ethereum-tests/LegacyTests/`
- `ethereum-tests/PoWTests/`
- `ethereum-tests/RLPTests/`
- `ethereum-tests/TransactionTests/`
- `ethereum-tests/TrieTests/`

Fixture tarballs:
- `ethereum-tests/fixtures_blockchain_tests.tgz`
- `ethereum-tests/fixtures_general_state_tests.tgz`

---

## Summary

Collected phase-7 Engine API goals and core Zig module targets, verified Engine API specs (common/auth/identification and fork-scoped Paris/Shanghai/Cancun+), and captured Merge-related EIPs (EIP-3675, EIP-4399). Mapped Nethermind’s Merge Plugin structure (RPC modules, handlers, validators, and sync/finalization pieces), inventoried Voltaire JSON-RPC engine primitives that must be reused, noted the existing `HostInterface` vtable DI pattern in `src/host.zig`, and recorded Engine API-oriented test fixture locations plus the requested `ethereum-tests` inventory.
