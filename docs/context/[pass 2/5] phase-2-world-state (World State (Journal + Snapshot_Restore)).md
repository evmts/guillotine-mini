# [Pass 2/5] Phase 2: World State (Journal + Snapshot/Restore) — Context

## Goal (from `prd/GUILLOTINE_CLIENT_PLAN.md`)

Implement journaled state with snapshot/restore for transaction processing.

**Key components:**
- `client/state/account.zig` — account state structure
- `client/state/journal.zig` — journal for tracking changes
- `client/state/state.zig` — world state manager

**Reference files:**
- Nethermind: `nethermind/src/Nethermind/Nethermind.State/`
- Voltaire: `voltaire/packages/voltaire-zig/src/state-manager/`

## Specs (from `prd/ETHEREUM_SPECS_REFERENCE.md`)

**Specs:**
- `execution-specs/src/ethereum/forks/*/state.py`
- Yellow Paper Section 4 (World State)

**Tests:**
- Unit tests for journal/snapshot behavior
- Subset of `ethereum-tests/GeneralStateTests/` (state manipulation)

## Execution-specs state model (notes from `execution-specs/src/ethereum/forks/{frontier,cancun}/state.py`)

**State structure:**
- Main account trie + per-account storage tries.
- Distinction between non-existent account and `EMPTY_ACCOUNT` (`get_account_optional` vs `get_account`).

**Transactions and snapshots:**
- `begin_transaction` copies the account trie + storage trie map onto a snapshot stack.
- `commit_transaction` pops a snapshot without restoring (keeps current state).
- `rollback_transaction` pops a snapshot and restores trie state from that snapshot.
- Cancun adds `TransientStorage` (per-transaction storage with its own snapshot stack) and `created_accounts` tracking.

**State accessors:**
- `get_account` / `get_account_optional` and `set_account` operate on the main trie.
- `get_storage` / `set_storage` operate on the per-account storage trie.

## Nethermind DB Architecture (directory listing)

Directory: `nethermind/src/Nethermind/Nethermind.Db/`

**Files present:**
- `BlobTxsColumns.cs`
- `Blooms/`
- `CompressingDb.cs`
- `DbExtensions.cs`
- `DbNames.cs`
- `DbProvider.cs`
- `DbProviderExtensions.cs`
- `FullPruning/`
- `FullPruningCompletionBehavior.cs`
- `FullPruningTrigger.cs`
- `IColumnsDb.cs`
- `IDb.cs`
- `IDbFactory.cs`
- `IDbProvider.cs`
- `IFullDb.cs`
- `IMergeOperator.cs`
- `IPruningConfig.cs`
- `IReadOnlyDb.cs`
- `IReadOnlyDbProvider.cs`
- `ITunableDb.cs`
- `InMemoryColumnBatch.cs`
- `InMemoryWriteBatch.cs`
- `MemColumnsDb.cs`
- `MemDb.cs`
- `MemDbFactory.cs`
- `MetadataDbKeys.cs`
- `Metrics.cs`
- `Nethermind.Db.csproj`
- `NullDb.cs`
- `NullRocksDbFactory.cs`
- `PruningConfig.cs`
- `PruningMode.cs`
- `ReadOnlyColumnsDb.cs`
- `ReadOnlyDb.cs`
- `ReadOnlyDbProvider.cs`
- `ReceiptsColumns.cs`
- `RocksDbMergeEnumerator.cs`
- `RocksDbSettings.cs`
- `SimpleFilePublicKeyDb.cs`

**Key takeaway for Zig:** preserve a clear DB interface layer while keeping world-state journaling on top.

## Voltaire primitives and state-manager APIs (directory listing)

Root: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- `primitives/`
- `state-manager/`
- `blockchain/`
- `crypto/`
- `evm/`
- `jsonrpc/`
- `log.zig`, `root.zig`

**State-manager modules (public API):**
- `state-manager/StateCache.zig`
  - `AccountCache`, `StorageCache`, `ContractCache` with `checkpoint/revert/commit`.
  - `AccountState` (nonce, balance, code_hash, storage_root).
  - `StorageKey` (address + slot hashing).
- `state-manager/JournaledState.zig`
  - `getAccount/getStorage/getCode`, `putAccount/putStorage/putCode`.
  - `checkpoint/revert/commit`, `clearCaches`.
  - Optional `ForkBackend` read-through for missing data.
- `state-manager/StateManager.zig`
  - High-level wrappers: `getBalance/getNonce/getCode/getStorage` and setters.
  - Snapshot API: `snapshot()` + `revertToSnapshot()` built on checkpoints.
- `state-manager/ForkBackend.zig`
  - Read-only forked state fetcher for missing accounts/storage/code.

**Relevant primitives to use (avoid custom types):**
- `primitives/Address`
- `primitives/Hash`
- `primitives/Bytes`, `primitives/Bytes32`
- `primitives/Uint` / `u256`

## Existing Zig Host Interface (vtable pattern)

File: `src/host.zig`
- `HostInterface` uses `ptr: *anyopaque` + `vtable: *const VTable`.
- VTable exposes `getBalance`, `setBalance`, `getCode`, `setCode`, `getStorage`, `setStorage`, `getNonce`, `setNonce`.
- Thin forwarding methods call through the vtable; same pattern should be reused for state DI.

## Ethereum tests directory listing (fixtures)

Directory: `ethereum-tests/`
- `ABITests/`
- `BasicTests/`
- `BlockchainTests/`
- `DifficultyTests/`
- `EOFTests/`
- `GenesisTests/`
- `JSONSchema/`
- `KeyStoreTests/`
- `LegacyTests/`
- `PoWTests/`
- `RLPTests/`
- `TransactionTests/`
- `TrieTests/`
- `fixtures_blockchain_tests.tgz`
- `fixtures_general_state_tests.tgz`
- `src/`

## Summary

Captured Phase 2 goals and key components, mapped the world-state specs (execution-specs `state.py` + Yellow Paper Section 4), noted transaction snapshot semantics and the EMPTY_ACCOUNT distinction, recorded Nethermind DB module files for interface layering, listed Voltaire state-manager APIs to reuse (StateCache/JournaledState/StateManager/ForkBackend), confirmed the HostInterface vtable pattern for DI, and enumerated `ethereum-tests/` fixture paths relevant to state tests.
