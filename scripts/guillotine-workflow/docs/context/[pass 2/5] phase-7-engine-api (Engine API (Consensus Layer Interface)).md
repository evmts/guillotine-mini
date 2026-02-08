# Phase 7 Engine API Context (Pass 2/5)

## Plan goals (GUILLOTINE_CLIENT_PLAN)
- Implement Engine API for consensus-layer communication.
- Key components: `client/engine/api.zig`, `client/engine/payload.zig`.
- References: Nethermind Merge plugin and `execution-apis/src/engine/`.

Source: `repo_link/prd/GUILLOTINE_CLIENT_PLAN.md` (Phase 7 section).

## Spec references (ETHEREUM_SPECS_REFERENCE)
- `execution-apis/src/engine/` (Engine API spec).
- EIP-3675 (The Merge).
- EIP-4399 (PREVRANDAO).

Tests noted:
- `hive/` Engine API tests.
- `execution-spec-tests/fixtures/blockchain_tests_engine/`.

Source: `repo_link/prd/ETHEREUM_SPECS_REFERENCE.md` (Phase 7 section).

## Nethermind database module inventory
Listed contents of `nethermind/src/Nethermind/Nethermind.Db/`:
- Core db abstractions: `IDb.cs`, `IDbProvider.cs`, `IColumnsDb.cs`, `IFullDb.cs`, `IReadOnlyDb.cs`, `ITunableDb.cs`.
- Providers/factories: `DbProvider.cs`, `DbProviderExtensions.cs`, `IDbFactory.cs`, `MemDbFactory.cs`, `NullRocksDbFactory.cs`.
- Implementations: `MemDb.cs`, `MemColumnsDb.cs`, `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `NullDb.cs`.
- Pruning: `FullPruning/`, `FullPruningCompletionBehavior.cs`, `FullPruningTrigger.cs`, `PruningConfig.cs`, `PruningMode.cs`.
- RocksDB integration: `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`, `IMergeOperator.cs`.
- Misc: `DbExtensions.cs`, `DbNames.cs`, `MetadataDbKeys.cs`, `Metrics.cs`, `ReceiptsColumns.cs`, `BlobTxsColumns.cs`.

Source: `repo_link/nethermind/src/Nethermind/Nethermind.Db/` directory listing.

## Voltaire primitives (voltaire-zig)
Relevant modules under `/Users/williamcory/voltaire/packages/voltaire-zig/src/`:
- `jsonrpc/` (JSON-RPC primitives and method definitions).
- `jsonrpc/engine/` (Engine API method schemas and types).
- `primitives/` (core Ethereum types).
- `blockchain/`, `state-manager/`, `evm/` (supporting execution client modules).

Engine API method modules (selected):
- `jsonrpc/engine/methods.zig` (engine method registry).
- `jsonrpc/engine/newPayloadV1..V5`, `forkchoiceUpdatedV1..V3`, `getPayloadV1..V6`, `exchangeCapabilities`, `exchangeTransitionConfigurationV1`.

Source: `/Users/williamcory/voltaire/packages/voltaire-zig/src/jsonrpc/engine/` directory listing.

## Existing Zig host interface
- `repo_link/src/host.zig`: defines `HostInterface` with vtable for balance/code/storage/nonce access. EVM nested calls bypass this interface; `inner_call` uses `CallParams/CallResult` directly.

## Ethereum test fixture layout
Top-level directories under `repo_link/ethereum-tests/`:
- `BlockchainTests/`, `TransactionTests/`, `BasicTests/`, `EOFTests/`, `GenesisTests/`, `TrieTests/`, `RLPTests/`, `DifficultyTests/`, `PoWTests/`, `ABITests/`.
- Fixture archives: `fixtures_blockchain_tests.tgz`, `fixtures_general_state_tests.tgz`.

Engine API specific fixtures noted in spec reference:
- `execution-spec-tests/fixtures/blockchain_tests_engine/`.

## Notes for Phase 7 implementation
- Follow `execution-apis/src/engine/` OpenRPC definitions and EIP-3675/EIP-4399 semantics.
- Reuse Voltaire jsonrpc engine types and method schemas; do not define custom types.
- Conform to Nethermind Merge plugin architecture while implementing idiomatic Zig with comptime DI.

