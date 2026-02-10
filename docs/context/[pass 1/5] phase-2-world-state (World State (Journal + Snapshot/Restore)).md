# [pass 1/5] phase-2-world-state (World State (Journal + Snapshot/Restore))

## Goal (from `prd/GUILLOTINE_CLIENT_PLAN.md`)
Implement journaled world state with snapshot/restore for transaction processing. Key components are `client/state/account.zig`, `client/state/journal.zig`, and `client/state/state.zig`.

## Spec References (from `prd/ETHEREUM_SPECS_REFERENCE.md`)
- `execution-specs/src/ethereum/forks/*/state.py`
- Yellow Paper Section 4 (World State)

## Execution-Specs Highlights (reviewed: `execution-specs/src/ethereum/forks/cancun/state.py`)
- `State` stores `_main_trie`, per-account `_storage_tries`, and `_snapshots` (stack of trie copies).
- `TransientStorage` mirrors snapshot/rollback semantics for transaction-scoped storage.
- `begin_transaction` deep-copies main and storage tries; `commit_transaction` pops snapshot; `rollback_transaction` restores snapshot.
- `created_accounts` is cleared when leaving the outermost transaction.
- `get_account_optional` distinguishes non-existent account (`None`) from `EMPTY_ACCOUNT`.
- `destroy_account` removes account and its storage.

## Nethermind DB Listing (from `nethermind/src/Nethermind/Nethermind.Db/`)
- Interfaces: `IDb.cs`, `IReadOnlyDb.cs`, `IColumnsDb.cs`, `IFullDb.cs`, `IDbProvider.cs`, `IDbFactory.cs`, `IMergeOperator.cs`, `ITunableDb.cs`
- Providers/impls: `DbProvider.cs`, `DbProviderExtensions.cs`, `DbExtensions.cs`, `MemDb.cs`, `MemDbFactory.cs`, `MemColumnsDb.cs`, `ReadOnlyDb.cs`, `ReadOnlyDbProvider.cs`, `NullDb.cs`, `NullRocksDbFactory.cs`
- Config/metadata: `DbNames.cs`, `MetadataDbKeys.cs`, `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`, `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/*`, `Metrics.cs`
- Columns: `ReceiptsColumns.cs`, `BlobTxsColumns.cs`

## Voltaire Zig State Manager (path mismatch)
- Requested path `/Users/williamcory/voltaire/packages/voltaire-zig/src/` does not exist in this checkout.
- Closest matching source: `/Users/williamcory/voltaire/src/state-manager/`
- Relevant APIs:
- `StateManager.zig`: high-level accessors (`getBalance`, `getNonce`, `getCode`, `getStorage`) and mutators (`setBalance`, `setNonce`, `setCode`, `setStorage`); checkpoint (`checkpoint`, `revert`, `commit`); snapshot (`snapshot`, `revertToSnapshot`).
- `JournaledState.zig`: manages account/storage/code caches with checkpoint stack.
- `StateCache.zig`: underlying caches and change tracking.
- `ForkBackend.zig`: optional read-through backend.

## Existing guillotine-mini Host Interface
- `src/host.zig` defines `HostInterface` vtable for `get/set` on balance, nonce, code, and storage.
- Note: nested calls bypass this interface; `Evm.inner_call` handles nested state internally.

## Ethereum Tests (fixtures and directories)
- Directories: `ethereum-tests/ABITests`, `BasicTests`, `BlockchainTests`, `DifficultyTests`, `EOFTests`, `GenesisTests`, `JSONSchema`, `KeyStoreTests`, `LegacyTests`, `PoWTests`, `RLPTests`, `TransactionTests`, `TrieTests`
- Fixture archives: `ethereum-tests/fixtures_general_state_tests.tgz`, `ethereum-tests/fixtures_blockchain_tests.tgz`

## Notes for Phase-2 Implementation
- Mirror execution-specs snapshot semantics and account-vs-empty distinctions.
- Journal should support snapshot/restore for both persistent and transient storage (EIP-1153).
- World state API should align with `HostInterface` accessors/mutators.
