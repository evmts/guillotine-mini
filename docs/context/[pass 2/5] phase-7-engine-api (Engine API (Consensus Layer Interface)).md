# Phase 7: Engine API (Consensus Layer Interface) -- Context (Pass 2/5)

## Goal

Implement the Engine API for consensus layer communication.

Key components (from plan):
- `client/engine/api.zig` - Engine API implementation
- `client/engine/payload.zig` - Payload building/validation

## Plan References

- `prd/GUILLOTINE_CLIENT_PLAN.md` - Phase 7 goals and component paths.

## Specs and References

### Engine API specs (execution-apis)

- `execution-apis/src/engine/README.md` - Fork-scoped Engine API index (Paris, Shanghai, Cancun, Prague, Osaka, Amsterdam).
- `execution-apis/src/engine/common.md` - Shared requirements: port 8551, `engine` namespace, eth_* passthrough list, message ordering, errors, encoding, `engine_exchangeCapabilities`.
- `execution-apis/src/engine/authentication.md` - JWT auth requirements (`jwt-secret`, `jwt.hex`, HS256 only).
- `execution-apis/src/engine/identification.md` - `engine_getClientVersionV1`, `ClientVersionV1`, and `ClientCode` mapping.
- `execution-apis/src/engine/paris.md` - V1 structures and methods (`ExecutionPayloadV1`, `engine_newPayloadV1`, `engine_forkchoiceUpdatedV1`, `engine_getPayloadV1`, `engine_exchangeTransitionConfigurationV1`), payload validation and forkchoice rules.
- `execution-apis/src/engine/shanghai.md` - V2 payloads and withdrawals (`ExecutionPayloadV2`, `PayloadAttributesV2`), plus `engine_getPayloadBodiesByHashV1` and `engine_getPayloadBodiesByRangeV1`.
- `execution-apis/src/engine/cancun.md` - V3 payloads and blobs (`ExecutionPayloadV3`, `PayloadAttributesV3`, `engine_getPayloadV3`, `engine_getBlobsV1`), and deprecation of `engine_exchangeTransitionConfigurationV1`.
- `execution-apis/src/engine/openrpc/` - OpenRPC schemas for method signatures and params.
- Additional fork docs to consult later: `execution-apis/src/engine/prague.md`, `execution-apis/src/engine/osaka.md`, `execution-apis/src/engine/amsterdam.md`.

### EIPs (consensus transition + randomness)

- `EIPs/EIPS/eip-3675.md` - Merge transition rules (terminal total difficulty, transition block validity, PoS block header constants, forkchoice updates).
- `EIPs/EIPS/eip-4399.md` - PREVRANDAO semantics (mixHash -> prevRandao, DIFFICULTY opcode semantics after transition).

### Execution-specs fixtures

- `execution-specs/src/ethereum_spec_tests/ethereum_test_fixtures/blockchain.py` - Fixture models used by engine tests.
  - `FixtureExecutionPayload` shape mirrors payload fields (transactions, withdrawals, blob gas fields, block access list).
  - `FixtureEngineNewPayload` parameter tuples: V1 `(payload)`, V3 `(payload, blob_hashes, parent_beacon_root)`, V4 `(payload, blob_hashes, parent_beacon_root, requests)`.

### Nethermind architecture reference

Engine API reference per plan:
- `nethermind/src/Nethermind/Nethermind.Merge.Plugin/`

DB layer files listed from `nethermind/src/Nethermind/Nethermind.Db/` (key examples):
- `IDb.cs`, `IReadOnlyDb.cs`, `IDbProvider.cs`, `DbProvider.cs`, `DbProviderExtensions.cs`
- `DbNames.cs`, `MetadataDbKeys.cs`, `DbExtensions.cs`, `Metrics.cs`
- `MemDb.cs`, `NullDb.cs`, `ReadOnlyDb.cs`, `ReadOnlyDbProvider.cs`, `MemColumnsDb.cs`
- `IColumnsDb.cs`, `ReceiptsColumns.cs`, `BlobTxsColumns.cs`, `InMemoryWriteBatch.cs`
- `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/`, `RocksDbSettings.cs`

## Voltaire APIs (available primitives)

Top-level modules from `voltaire/packages/voltaire-zig/src/`:
- `primitives/` - Address, Hash, u256, RLP, block/tx structures.
- `jsonrpc/` - JSON-RPC transport helpers for Engine API surface.
- `blockchain/` - Chain types and block structures.
- `state-manager/` - State access primitives and cache layers.
- `evm/` - Existing EVM implementation (must be used; no reimplementation).
- `crypto/`, `precompiles/`, `log.zig`, `root.zig`.

## Existing Zig Files

- `src/host.zig` - `HostInterface` vtable for minimal state access (balance/code/storage/nonce). Notes: not used for nested calls; EVM handles nested calls internally.

## Test Fixtures

- `execution-spec-tests/fixtures/blockchain_tests_engine/` - Engine API blockchain fixtures (per plan).
- `hive/` - Engine API test suites (per plan).
- `ethereum-tests/` directories (selected):
  - `ethereum-tests/BlockchainTests/` (valid/invalid blocks), `ethereum-tests/TransactionTests/`, `ethereum-tests/RLPTests/`, `ethereum-tests/DifficultyTests/`, `ethereum-tests/GenesisTests/`, `ethereum-tests/TrieTests/`.

## Notes for Implementation Planning

- Engine API is fork-versioned: V1 (Paris), V2 (Shanghai), V3 (Cancun); method selection depends on payload timestamp and fork rules.
- `engine_exchangeCapabilities` and `engine_getClientVersionV1` are required support paths and must not log errors when unused.
- JWT auth is mandatory for HTTP/WS on the Engine port (default 8551), with `jwt-secret` or `jwt.hex` provisioning.
- Payload validation and forkchoice updates rely on EIP-3675 (terminal PoW block checks) and EIP-4399 (prevRandao/mixHash semantics).
