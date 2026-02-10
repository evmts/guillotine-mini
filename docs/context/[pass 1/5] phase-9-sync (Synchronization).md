# [pass 1/5] phase-9-sync (Synchronization) — Context

This file aggregates the minimal but sufficient context to implement Phase 9 (Synchronization) using Voltaire primitives, the existing EVM, and Nethermind structure.

## Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Path: `prd/GUILLOTINE_CLIENT_PLAN.md:154`
- Summary: Implement chain synchronization strategies and coordination.
- Target files to implement in this phase:
  - `client/sync/full.zig` — Full sync
  - `client/sync/snap.zig` — Snap sync
  - `client/sync/manager.zig` — Sync coordination
- Architectural reference: `nethermind/src/Nethermind/Nethermind.Synchronization/`

## Specs (from prd/ETHEREUM_SPECS_REFERENCE.md)
- `devp2p/caps/eth.md` — ETH subprotocol (e.g., `GetBlockHeaders`, `BlockHeaders`, `GetBlockBodies`, `BlockBodies`, status exchange, total difficulty/terminal PoS handling). Use for header/body download logic, request pagination, and response validation.
- `devp2p/caps/snap.md` — Snap protocol (state sync via range proofs and trie segments). Use for state range downloads (accounts/storage), proof validation, and pivot logic.
- Tests called out: `hive/` sync tests; integration tests.

## Nethermind DB (inventory for sync persistence needs)
Path: `nethermind/src/Nethermind/Nethermind.Db/` (selected key files)
- `IDb.cs`, `IReadOnlyDb.cs`, `IDbProvider.cs`, `DbProvider.cs` — DB abstraction/provider boundaries.
- `MemDb.cs`, `MemDbFactory.cs` — In-memory DB used in tests/bootstrap.
- `CompressingDb.cs`, `RocksDbSettings.cs`, `IMergeOperator.cs` — Storage tuning and merges.
- `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/*` — Pruning strategies relevant to long-running sync.
- `ReadOnlyDb*.cs`, `IColumnsDb.cs`, `InMemoryWriteBatch.cs` — Column/batch patterns for high-throughput ingestion.
- `Metrics.cs`, `MetadataDbKeys.cs`, `DbExtensions.cs` — Operational telemetry and common keys.

These patterns guide: separation of read/write DBs, batch ingestion, pruning modes, and metrics — mirror the structure idiomatically in Zig with Voltaire primitives.

## Voltaire Zig APIs likely used
Root: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- `primitives/` core types:
  - `BlockHeader`, `BlockBody`, `Block`, `Uncle`, `Hash`, `Bytes32`, `Rlp/` (encoding/decoding), `Uint/` (fixed-width ints), `PeerId`, `SyncStatus`, `HandshakeRole`, `SnappyParameters`.
  - `Transaction`, `Receipt`, `BloomFilter`, `StateRoot`, `Storage*`, `AccountState` as needed for validation.
- `blockchain/` ingestion & chain mgmt: `Blockchain.zig`, `BlockStore.zig`, `ForkBlockCache.zig`.
- `evm/` and `state-manager/` are kept as-is; EVM is not reimplemented — only invoked where needed for validation post-sync if applicable.
- Logging: `log.zig`.

Use these directly — do not introduce custom duplicates. Prefer RLP from `primitives.Rlp`, integers from `primitives.Uint`, IDs and hashes from `primitives` folders.

## Host Interface (existing Zig surface)
Path: `src/host.zig`
- Provides `HostInterface` with vtable hooks:
  - `getBalance/setBalance`, `getCode/setCode`, `getStorage/setStorage`, `getNonce/setNonce`.
- Note: EVM nested calls use `inner_call` and bypass this host; host is for external state access. Ensure sync uses state-manager + primitives types rather than ad-hoc maps.

## Test Fixtures (ethereum-tests/)
Path: `ethereum-tests/` (submodule)
- `BlockchainTests/` — canonical block/header/body validation vectors.
- `TransactionTests/` — tx encoding/validation.
- `TrieTests/` — trie correctness.
- `RLPTests/` — RLP edge cases.
- `BasicTests/`, `DifficultyTests/`, `EOFTests/`, `GenesisTests/`, `PoWTests/`, etc. — additional coverage.
- Archives: `fixtures_blockchain_tests.tgz`, `fixtures_general_state_tests.tgz` — large fixture bundles.

For Phase 9, prioritize `BlockchainTests` and any `hive/` sync tests for protocol-level validation.

## Pointers for implementation (Phase 9)
- Follow Nethermind structure: separate sync strategies (full/snap) behind a `manager` with clear state machine and metrics; batch DB operations; pruning awareness.
- Use Voltaire primitives exclusively for blocks/headers/rlp/ids/integers.
- Wire to existing networking (`devp2p`) caps: `eth` for headers/bodies; `snap` for state ranges.
- Ensure strict error handling: no silent catches; bubble typed errors; add unit tests per public function.
- Keep units small and injectable via comptime (match existing EVM patterns).

