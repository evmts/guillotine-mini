# Phase 2 World State (Journal + Snapshot/Restore) - Context

## Phase goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Implement journaled world state with snapshot/restore for transaction processing.
- Key components: client/state/account.zig, client/state/journal.zig, client/state/state.zig.
- Reference architecture: nethermind/src/Nethermind/Nethermind.State/.
- Use Voltaire state-manager primitives: /Users/williamcory/voltaire/packages/voltaire-zig/src/state-manager/.

## Relevant specs (from prd/ETHEREUM_SPECS_REFERENCE.md)
- execution-specs: execution-specs/src/ethereum/forks/*/state.py
- Yellow Paper: yellowpaper/Paper.tex (Section 4, World State)
- Tests: unit tests for journal/snapshot behavior, subset of ethereum-tests/GeneralStateTests/

## Spec notes (execution-specs)
Path: execution-specs/src/ethereum/forks/osaka/state.py
- State: main account trie + per-account storage tries; distinguishes non-existent account vs EMPTY_ACCOUNT.
- TransientStorage: per-tx storage with its own snapshots.
- begin_transaction/commit_transaction/rollback_transaction: snapshot stack via copy_trie for main + storage tries.
- get_account vs get_account_optional: EMPTY_ACCOUNT vs None distinction.
- set_account supports delete by setting None (implementation detail in spec).

## Spec notes (Yellow Paper)
Path: yellowpaper/Paper.tex (Section 4, World State)
- World state is a mapping Address -> AccountState stored in a modified Merkle Patricia Trie.
- AccountState fields: nonce, balance, storageRoot, codeHash.
- storageRoot is the root of a storage trie keyed by Keccak-256 of storage slots.
- Empty account: codeHash == KEC("") and nonce == 0 and balance == 0.
- Dead account: non-existent or empty.

## Nethermind DB directory listing (nethermind/src/Nethermind/Nethermind.Db/)
Key files in this directory:
- IDb.cs, IReadOnlyDb.cs, IColumnsDb.cs, IFullDb.cs, IDbFactory.cs, IDbProvider.cs
- DbProvider.cs, DbExtensions.cs, DbNames.cs, Metrics.cs
- MemDb.cs, MemDbFactory.cs, MemColumnsDb.cs, ReadOnlyDb.cs, ReadOnlyColumnsDb.cs
- RocksDbSettings.cs, RocksDbMergeEnumerator.cs, NullDb.cs
- FullPruning/*, BlobTxsColumns.cs, ReceiptsColumns.cs

## Voltaire state-manager APIs (voltaire/packages/voltaire-zig/src/state-manager/)
- root.zig re-exports:
  - StateCache: AccountCache, StorageCache, ContractCache, AccountState, StorageKey
  - ForkBackend: ForkBackend, CacheConfig, Transport, RpcClient
  - JournaledState
  - StateManager

- StateCache.zig:
  - AccountState { nonce, balance, code_hash, storage_root }
  - AccountCache/StorageCache/ContractCache with checkpoint(), revert(), commit()
  - StorageCache deletes zero values and removes empty per-address maps

- JournaledState.zig:
  - getAccount/putAccount, getStorage/putStorage, getCode/putCode
  - checkpoint/revert/commit across all caches
  - optional fork_backend for read-through fetch

- StateManager.zig:
  - High-level accessors: getBalance/getNonce/getCode/getStorage
  - Mutators: setBalance/setNonce/setCode/setStorage
  - Checkpoint operations + snapshot()/revertToSnapshot()
  - snapshot is implemented via checkpoint depth mapping

## Existing Zig interfaces
- src/host.zig: HostInterface for EVM external state access (get/set balance, code, storage, nonce). EVM inner_call bypasses this for nested calls.

## Test fixture locations
- ethereum-tests/fixtures_general_state_tests.tgz (GeneralStateTests archive)
- ethereum-tests/fixtures_blockchain_tests.tgz
- ethereum-tests/TrieTests/ (existing trie fixtures, may be relevant for storage tries)
- execution-spec-tests/fixtures/state_tests/ (see phase-3 mapping, still relevant for state behavior)
