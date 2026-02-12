# [pass 1/5] phase-2-world-state (World State (Journal + Snapshot/Restore))

This context consolidates goals, specs, reference code, and local APIs to guide implementing Phase 2: World State with journal + snapshot/restore. It enforces: use Voltaire primitives, reuse existing guillotine-mini EVM, mirror Nethermind architecture, and apply comptime DI.

## Goals (from PRD)
- Implement journaled world state with snapshot/restore for transaction processing.
- Key components planned: `client/state/account.zig`, `client/state/journal.zig`, `client/state/state.zig`.
- Reference: Nethermind.State (architecture), Voltaire state-manager (APIs).

Source: prd/GUILLOTINE_CLIENT_PLAN.md → Phase 2: World State.

## Spec References (execution-specs)
Primary world-state semantics live in these files (begin/commit/rollback, account/storage operations, state/storage roots):
- execution-specs/src/ethereum/forks/frontier/state.py — canonical baseline (account vs EMPTY_ACCOUNT, snapshots, storage semantics).
- execution-specs/src/ethereum/forks/byzantium/state.py
- execution-specs/src/ethereum/forks/berlin/state.py
- execution-specs/src/ethereum/forks/london/state.py
- execution-specs/src/ethereum/forks/shanghai/state.py
- execution-specs/src/ethereum/forks/cancun/state.py
- execution-specs/src/ethereum/forks/paris/state.py
- execution-specs/src/ethereum/forks/prague/state.py (upcoming).

Key behaviors to mirror exactly:
- Snapshots are nestable; no state_root/storage_root calculation allowed when snapshots are active.
- `get_account` must return EMPTY_ACCOUNT for non-existent accounts; `get_account_optional` distinguishes None.
- `set_storage(address, key, value=0)` deletes the key; empty storage trie prunes from map.
- `destroy_account` removes account and all storage (SELFDESTRUCT semantics; subject to future EIPs).

Source map: prd/ETHEREUM_SPECS_REFERENCE.md → Phase 2 mapping.

## Nethermind Reference (architecture)
While this pass focuses on journaling/snapshots, persistence boundary will align with Nethermind.Db abstractions. Key files in `nethermind/src/Nethermind/Nethermind.Db/`:
- IDb.cs, IReadOnlyDb.cs, IColumnsDb.cs, ITunableDb.cs — interfaces.
- DbProvider.cs, IDbProvider.cs, ReadOnlyDbProvider.cs — provider layer.
- MemDb.cs, MemColumnsDb.cs, InMemoryWriteBatch.cs — in-memory backends.
- RocksDbSettings.cs, CompressingDb.cs, RocksDbMergeEnumerator.cs — RocksDB integration.
- PruningConfig.cs, PruningMode.cs, FullPruning (folder) — pruning model.
- BlobTxsColumns.cs, ReceiptsColumns.cs, MetadataDbKeys.cs — column schemas.

Implication: design a thin adapter boundary now so Phase 0/1/2 components compose cleanly with a DB provider later.

## Voltaire APIs to Use (no custom types)
State orchestration and primitives from `/Users/williamcory/voltaire/packages/voltaire-zig/src/`:
- state-manager/JournaledState.zig — dual-cache manager with checkpoint/revert/commit and optional fork backend.
- state-manager/StateCache.zig — `AccountCache`, `StorageCache`, `ContractCache` with journaling.
- state-manager/StateManager.zig — higher-level manager (commit pipeline).
- state-manager/ForkBackend.zig — read-through backend for remote state.
- primitives/* — Address, Hash, Uint/u256, State/Storage structs, RLP, Trie.

Do not duplicate: Account structs, Address, Hash, U256, trie, or storage types — import from Voltaire `primitives` and `state-manager`.

## Existing Zig Host Interface (guillotine-mini)
File: src/host.zig
- `HostInterface` vtable: `get/setBalance`, `get/setCode`, `get/setStorage`, `get/setNonce`.
- Uses `primitives.Address.Address` and `u256`.
- Note: Nested calls are handled internally by EVM; this Host is for external state access.
- Phase 3 will adapt WorldState to this vtable; Phase 2 should shape APIs accordingly.

## ethereum-tests fixtures available
Present directories under `ethereum-tests/` (subset relevant to state):
- `TrieTests/` — for trie behavior (Phase 1).
- `BlockchainTests/` — block/state transition in blockchain form.
- `TransactionTests/` — tx encoding/validation.
Note: `GeneralStateTests/` is not present in this checkout; rely on unit tests for journal/snapshot and selected `BlockchainTests` later.

## Implementation Guidance (for upcoming commits)
- Map `checkpoint/revert/commit` ↔ spec `begin/rollback/commit`.
- Enforce spec constraints: no root calculation during active checkpoints.
- Read cascade: normal cache → optional ForkBackend → default; writes only to normal cache.
- Use comptime DI similar to EVM for pluggable storage backends; keep units small/testable.
- Strict error handling; no silent catches; minimize allocations (arena per-tx).
- Tests: every public function has unit tests; add focused tests for nested checkpoints, cache eviction, and account existence semantics.

## Pointers
- PRD: prd/GUILLOTINE_CLIENT_PLAN.md (Phase 2: World State).
- Specs: execution-specs `*/state.py` across forks; Yellow Paper §4.
- Reference: Nethermind.Db interfaces; later Nethermind.State for structure.
- Voltaire: state-manager module and primitives hierarchy.
