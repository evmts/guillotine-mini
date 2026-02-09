# [pass 1/5] phase-2-world-state (World State (Journal + Snapshot/Restore))

## Goal (from prd/GUILLOTINE_CLIENT_PLAN.md)
Implement journaled world state with snapshot/restore for transaction processing.

## Primary Specs
- execution-specs/src/ethereum/forks/*/state.py (reviewed: execution-specs/src/ethereum/forks/cancun/state.py)
- Yellow Paper Section 4 (world state) — not present in repo (yellowpaper/ is empty)

### Key behaviors from execution-specs/src/ethereum/forks/cancun/state.py
- State uses a main account trie and per-account storage tries.
- State keeps a snapshot stack: begin_transaction copies main trie + storage tries; commit pops snapshot; rollback restores snapshot.
- Distinguishes non-existent account from EMPTY_ACCOUNT via get_account_optional vs get_account.
- created_accounts set is cleared when exiting the outermost transaction.
- TransientStorage mirrors snapshot/rollback semantics for transaction-scoped storage.

## Relevant EIP
- EIPs/EIPS/eip-1153.md (Transient storage opcodes)
- Specifies transient storage discarded after each transaction.
- Revert semantics require journaling + checkpoints; suggested structure: current map + journal + checkpoints.

## Nethermind DB (nethermind/src/Nethermind/Nethermind.Db/)
- IDb.cs, IReadOnlyDb.cs, IColumnsDb.cs, IDbProvider.cs, IDbFactory.cs
- DbProvider.cs, DbProviderExtensions.cs, DbExtensions.cs
- MemDb.cs, MemDbFactory.cs, MemColumnsDb.cs, InMemoryWriteBatch.cs
- ReadOnlyDb.cs, ReadOnlyDbProvider.cs
- RocksDbSettings.cs, RocksDbMergeEnumerator.cs
- PruningConfig.cs, PruningMode.cs, FullPruning/*, Metrics.cs
- DbNames.cs, MetadataDbKeys.cs, ReceiptsColumns.cs, BlobTxsColumns.cs

## Voltaire zig state-manager APIs
- NOTE: /Users/williamcory/voltaire/packages/voltaire-zig/src/ does not exist in this checkout.
- Used /Users/williamcory/voltaire/src/state-manager as the closest matching source.
- /Users/williamcory/voltaire/src/state-manager/StateManager.zig
- Provides high-level snapshot API (snapshot/revertToSnapshot) on top of checkpoints.
- State accessors: getBalance/getNonce/getCode/getStorage; mutators: setBalance/setNonce/setCode/setStorage.
- /Users/williamcory/voltaire/src/state-manager/JournaledState.zig
- Wraps StateCache for account/storage/contract caches; checkpoint/revert/commit across caches.
- Supports optional ForkBackend for read-through caching (remote state), writes go to normal cache.
- /Users/williamcory/voltaire/src/state-manager/StateCache.zig, ForkBackend.zig (supporting caches + fork fetch APIs).

## Existing EVM Host Interface
- src/host.zig defines HostInterface with get/set for balance, nonce, code, storage.
- Note: inner_call bypasses HostInterface; only used for external state access.

## Ethereum Tests
- ethereum-tests/ (top-level dirs: ABITests, BasicTests, BlockchainTests, DifficultyTests, EOFTests, GenesisTests, JSONSchema, KeyStoreTests, LegacyTests, PoWTests, RLPTests, TransactionTests, TrieTests)
- ethereum-tests/fixtures_general_state_tests.tgz (GeneralStateTests fixtures are packaged; ethereum-tests/GeneralStateTests/ is not present)
- ethereum-tests/fixtures_blockchain_tests.tgz

## Context Notes
- Phase-2 world state should mirror execution-specs snapshot/rollback semantics and EIP-1153 journal behavior.
- HostInterface methods map directly to world state accessors (balance, nonce, code, storage).
- Voltaire StateManager/JournaledState provide a concrete pattern for checkpoint/snapshot layering and fork-backend read-through caching.
