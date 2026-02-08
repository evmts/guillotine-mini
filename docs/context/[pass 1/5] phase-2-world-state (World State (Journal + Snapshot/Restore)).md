# [pass 1/5] phase-2-world-state (World State (Journal + Snapshot/Restore))

## Phase goal (prd/GUILLOTINE_CLIENT_PLAN.md)
- Implement journaled state with snapshot/restore for transaction processing.
- Key components: `client/state/account.zig`, `client/state/journal.zig`, `client/state/state.zig`.
- Structural reference: `nethermind/src/Nethermind/Nethermind.State/`.
- Voltaire reference: `voltaire/packages/voltaire-zig/src/state-manager/`.

## Spec references (prd/ETHEREUM_SPECS_REFERENCE.md)
- `execution-specs/src/ethereum/forks/*/state.py` (world state + journaling semantics).
- Yellow Paper Section 4 (World State).
- Tests: unit tests for journal/snapshot behavior, subset of `ethereum-tests/GeneralStateTests/`.

### execution-specs: `execution-specs/src/ethereum/forks/prague/state.py`
- `State` maintains `_main_trie`, `_storage_tries`, `_snapshots`, `created_accounts`.
- `TransientStorage` keeps transient storage tries + `_snapshots`.
- Transaction lifecycle:
  - `begin_transaction()` copies main/storage tries and transient tries into snapshots.
  - `commit_transaction()` pops snapshots; clears `created_accounts` when depth returns to 0.
  - `rollback_transaction()` restores tries from snapshots and clears `created_accounts` when depth returns to 0.
- Distinguishes non-existent accounts vs `EMPTY_ACCOUNT` via `get_account_optional`.

## Nethermind Db surface (nethermind/src/Nethermind/Nethermind.Db)
Key files to mirror structure and layering decisions:
- Interfaces: `IDb.cs`, `IReadOnlyDb.cs`, `IColumnsDb.cs`, `IFullDb.cs`, `IDbProvider.cs`, `IReadOnlyDbProvider.cs`.
- Providers/config: `DbProvider.cs`, `DbProviderExtensions.cs`, `DbNames.cs`, `RocksDbSettings.cs`.
- In-memory implementations: `MemDb.cs`, `MemColumnsDb.cs`, `InMemoryWriteBatch.cs`.
- Pruning hooks: `IPruningConfig.cs`, `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/*`.

## Voltaire state-manager APIs (voltaire/packages/voltaire-zig/src/state-manager)
Relevant modules:
- `root.zig` re-exports `JournaledState`, `StateManager`, `StateCache`, `ForkBackend` + cache types.
- `JournaledState.zig`:
  - Dual-cache orchestration: `account_cache`, `storage_cache`, `contract_cache` + optional `fork_backend`.
  - Read cascade: cache → fork backend → default (empty/zero).
  - Write flow: normal cache only.
  - Checkpoint flow: `checkpoint()`, `revert()`, `commit()` across all caches.
- `StateCache.zig` (per-type caches + journaling) and `StateManager.zig` (public API) are the likely primary entry points.

## Existing guillotine-mini host interface (src/host.zig)
- `HostInterface` with vtable: `get/setBalance`, `get/setCode`, `get/setStorage`, `get/setNonce`.
- Uses `primitives.Address` + `u256` types; no nested-call path (inner EVM handles).

## Test fixtures (ethereum-tests/)
- Fixture archives: `ethereum-tests/fixtures_general_state_tests.tgz`, `ethereum-tests/fixtures_blockchain_tests.tgz`.
- Other directories present: `ABITests/`, `BlockchainTests/`, `BasicTests/`, `TrieTests/`, `TransactionTests/`, etc.
- World-state focus: GeneralStateTests (fixture tarball) + unit tests for journal/snapshot behavior.

## Summary
Gathered phase-2 goal, execution-specs journaling semantics, Nethermind DB surface, Voltaire state-manager APIs, current HostInterface, and test fixture locations for world-state journaling + snapshot/restore.
