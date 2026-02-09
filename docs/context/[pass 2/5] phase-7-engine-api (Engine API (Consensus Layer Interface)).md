# Phase 7: Engine API (Consensus Layer Interface) -- Context (Pass 2/5)

## Goal

Implement the Engine API for consensus layer communication.

Key components (from plan):
- `client/engine/api.zig` -- Engine API implementation
- `client/engine/payload.zig` -- Payload building/validation

## Specs and References

### Engine API specs (execution-apis)

- `execution-apis/src/engine/README.md` -- Fork-scoped Engine API spec index (Paris/Shanghai/Cancun/Prague/Osaka/Amsterdam).
- `execution-apis/src/engine/common.md` -- Shared requirements: port 8551, eth_* passthrough list, message ordering, errors, encoding, `engine_exchangeCapabilities`.
- `execution-apis/src/engine/authentication.md` -- JWT auth requirements and key distribution (`jwt-secret`, `jwt.hex`).
- `execution-apis/src/engine/identification.md` -- `engine_getClientVersionV1` and `ClientVersionV1`/`ClientCode`.
- `execution-apis/src/engine/paris.md` -- `ExecutionPayloadV1`, `engine_newPayloadV1`, `engine_forkchoiceUpdatedV1`, `engine_getPayloadV1`, transition config.
- `execution-apis/src/engine/shanghai.md` -- `ExecutionPayloadV2`, withdrawals, payload bodies, `engine_getPayloadBodiesBy*`.
- `execution-apis/src/engine/cancun.md` -- `ExecutionPayloadV3`, blob fields, `engine_getBlobsV1`, fork checks.
- `execution-apis/src/engine/openrpc/` -- OpenRPC schemas (method signatures and params).

### EIPs (consensus transition + randomness)

- `EIPs/EIPS/eip-3675.md` -- Merge transition rules (terminal total difficulty, transition block validity, PoS block header constants).
- `EIPs/EIPS/eip-4399.md` -- PREVRANDAO semantics (block header `mixHash` -> `prevRandao`).

### Execution-specs fixtures (engine payload tests)

- `execution-specs/src/ethereum_spec_tests/ethereum_test_fixtures/blockchain.py` -- `FixtureExecutionPayload` and `FixtureEngineNewPayload` shapes (V1/V3/V4 parameters).

### Nethermind architecture reference

Nethermind Engine API reference per plan:
- `nethermind/src/Nethermind/Nethermind.Merge.Plugin/`

Additional DB layer files (listed from `nethermind/src/Nethermind/Nethermind.Db/`):
- `IDb.cs`, `IReadOnlyDb.cs`, `IDbProvider.cs`, `DbProvider.cs`
- `DbNames.cs`, `MetadataDbKeys.cs`
- `MemDb.cs`, `NullDb.cs`, `ReadOnlyDb.cs`
- `RocksDbSettings.cs`, `DbExtensions.cs`, `Metrics.cs`

## Voltaire APIs (available primitives)

Top-level modules from `voltaire/packages/voltaire-zig/src/`:
- `primitives/` -- Address/Hash/u256/RLP/Block/Transaction/etc.
- `jsonrpc/` -- JSON-RPC server/client helpers (Engine API transport surface).
- `blockchain/` -- Chain types and block structures.
- `state-manager/` -- State access primitives and cache layers.
- `evm/` -- Existing EVM (must be used; no reimplementation).
- `crypto/`, `precompiles/`, `log.zig`, `root.zig`.

## Existing Zig Files

- `src/host.zig` -- `HostInterface` vtable for minimal state access (balance/code/storage/nonce). Notes: not used for nested calls; EVM handles nested calls internally.

## Test Fixtures

- `execution-spec-tests/fixtures/blockchain_tests_engine/` -- Engine API blockchain fixtures (per plan).
- `hive/` -- Engine API test suites (per plan).
- `ethereum-tests/BlockchainTests/` -- General blockchain tests (available in repo).
- `execution-specs/src/ethereum_spec_tests/ethereum_test_fixtures/` -- Fixture models used by execution-spec tests.

## Notes for Implementation Planning

- Engine API is fork-versioned: V1 (Paris), V2 (Shanghai), V3 (Cancun), with method/version gating based on payload timestamp.
- Payload validation rules rely on EIP-3675 (terminal PoW block checks) and EIP-4399 (prevRandao/mixHash semantics).
- `engine_exchangeCapabilities` and `engine_getClientVersionV1` are required support paths that should not log errors when unused.

