# [pass 1/5] phase-2-world-state (World State (Journal + Snapshot/Restore)) — Context & References

## Phase Goal (prd/GUILLOTINE_CLIENT_PLAN.md)
Implement journaled world state with snapshot/restore for transaction processing.

Target components (Zig plan):
- `client/state/account.zig`
- `client/state/journal.zig`
- `client/state/state.zig`

Reference modules:
- `nethermind/src/Nethermind/Nethermind.State/` (state architecture)
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/state-manager/` (journal/snapshot API shape)

Effect.ts adaptation notes:
- Service-oriented world state with `Context.Tag` and `Layer`.
- Journal with nested `begin/commit/rollback` and snapshot IDs.
- Use `voltaire-effect/primitives` (Address, Hash, Hex, State, AccountState, Storage...).

## Specs (prd/ETHEREUM_SPECS_REFERENCE.md)
Primary:
- `execution-specs/src/ethereum/forks/*/state.py`
- Yellow Paper Section 4 (World State)

World-state semantics to mirror (cancun/prague):
- Transaction boundaries: `begin_transaction`, `commit_transaction`, `rollback_transaction`.
- Account ops: `get_account(_optional)`, `set_account`, `destroy_account`, `increment_nonce`, `set_account_balance`, `set_code`.
- Storage ops: `get_storage`, `set_storage`, `get_storage_original`, `destroy_storage`.
- Distinguish non-existent vs empty accounts.
- Transient storage journal for EIP-1153 (Cancun+).

Spec files present per fork (examples):
- `execution-specs/src/ethereum/forks/frontier/state.py`
- `execution-specs/src/ethereum/forks/berlin/state.py`
- `execution-specs/src/ethereum/forks/london/state.py`
- `execution-specs/src/ethereum/forks/paris/state.py`
- `execution-specs/src/ethereum/forks/shanghai/state.py`
- `execution-specs/src/ethereum/forks/cancun/state.py`
- `execution-specs/src/ethereum/forks/prague/state.py`

Related EIPs to keep in view:
- EIP-158/161 (state trie clearing), EIP-2200 (SSTORE metering),
  EIP-2929/2930 (warm access/access lists), EIP-3529 (refunds),
  EIP-1153 (transient storage), EIP-6780 (SELFDESTRUCT changes), EIP-2681 (nonce cap).

## Nethermind Db (nethermind/src/Nethermind/Nethermind.Db/)
Key files shaping the DB boundary our state service will depend on:
- Interfaces: `IDb.cs`, `IColumnsDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs`, `IDbProvider.cs`, `IDbFactory.cs`, `IMergeOperator.cs`, `ITunableDb.cs`.
- Providers: `DbProvider.cs`, `DbProviderExtensions.cs`, `ReadOnlyDbProvider.cs`.
- Implementations: `MemDb.cs`, `MemColumnsDb.cs`, `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `NullDb.cs`.
- Config/metadata/pruning: `DbNames.cs`, `MetadataDbKeys.cs`, `RocksDbSettings.cs`, `PruningConfig.cs`, `PruningMode.cs`, pruning triggers.
- Column enums: `ReceiptsColumns.cs`, `BlobTxsColumns.cs`.

Note: For world-state specifics, also see `nethermind/src/Nethermind/Nethermind.State/` (e.g., `WorldState.cs`, `WorldStateManager.cs`, `StateProvider.cs`, `StorageTree.cs`).

## Voltaire Zig APIs (/Users/williamcory/voltaire/packages/voltaire-zig/src)
State-related modules:
- `state-manager/JournaledState.zig` — journal stack + checkpoints.
- `state-manager/StateManager.zig` — high-level getters/setters and snapshots.
- `state-manager/StateCache.zig` — per-domain caches with `checkpoint/commit/revert`.
- `state-manager/ForkBackend.zig` — lazy remote fetch when cache misses.

Primitives to mirror in Effect.ts via `voltaire-effect/primitives`:
- `Address`, `Hash`, `Hex`, and state types like `AccountState`, `State`, `Storage`, `StateRoot`.

## Host Interface (guillotine-mini/src/host.zig)
VTable methods used for external state access:
- `getBalance` / `setBalance`
- `getCode` / `setCode`
- `getStorage` / `setStorage`
- `getNonce` / `setNonce`
Note: EVM nested calls are handled internally; host is for top-level external state.

## Ethereum Test Fixtures (ethereum-tests/)
Present directories:
- `TrieTests/`, `TransactionTests/`, `BlockchainTests/`, `EOFTests/`, `BasicTests/`, `RLPTests/`, `DifficultyTests/`.
World-state sources:
- `fixtures_general_state_tests.tgz` (archive with GeneralStateTests).
- Blockchain state subtests: `BlockchainTests/*/bcStateTests/`.

Cross-repo fixtures:
- `execution-spec-tests/fixtures/blockchain_tests` → symlink to `ethereum-tests/BlockchainTests` (used by spec-driven tests).

## What This Enables Next
- Define an Effect service `WorldState` (Context.Tag) exposing the host-aligned API plus `snapshot()/revert(snapshotId)` and transient storage journal.
- Back with a small `Journal` component implementing nested begin/commit/rollback.
- Integrate `voltaire-effect/primitives` for all types; no custom Address/Hash/Hex.
- Map semantics directly to execution-specs, with tests using @effect/vitest and targeted ethereum-tests fixtures.
