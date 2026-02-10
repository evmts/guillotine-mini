# [pass 1/5] phase-2-world-state (World State (Journal + Snapshot/Restore))

## Phase Goal (`prd/GUILLOTINE_CLIENT_PLAN.md`)
Implement journaled world state with snapshot/restore for transaction processing.

Target components:
- `client/state/account.zig`
- `client/state/journal.zig`
- `client/state/state.zig`

Reference modules:
- `nethermind/src/Nethermind/Nethermind.State/` (state architecture)
- `voltaire/packages/voltaire-zig/src/state-manager/` (journal/snapshot API shape)

## Required Specs (`prd/ETHEREUM_SPECS_REFERENCE.md`)
Primary:
- `execution-specs/src/ethereum/forks/*/state.py`
- Yellow Paper Section 4 (World State)

Relevant EIPs for world-state behavior:
- `EIPs/EIPS/eip-158.md` (State clearing)
- `EIPs/EIPS/eip-161.md` (State trie clearing)
- `EIPs/EIPS/eip-2200.md` (SSTORE net metering semantics)
- `EIPs/EIPS/eip-2929.md` (warm/cold state access)
- `EIPs/EIPS/eip-2930.md` (access lists)
- `EIPs/EIPS/eip-3529.md` (refund reduction)
- `EIPs/EIPS/eip-1153.md` (transient storage)
- `EIPs/EIPS/eip-6780.md` (SELFDESTRUCT restrictions)
- `EIPs/EIPS/eip-2681.md` (nonce limit)

## Execution-Spec World-State API (reviewed in `execution-specs/src/ethereum/forks/cancun/state.py`)
Core transaction boundaries:
- `begin_transaction(state, transient_storage)`
- `commit_transaction(state, transient_storage)`
- `rollback_transaction(state, transient_storage)`

Account and storage operations:
- `get_account`, `get_account_optional`, `set_account`
- `destroy_account`, `destroy_storage`, `mark_account_created`
- `get_storage`, `set_storage`, `get_storage_original`
- `set_account_balance`, `increment_nonce`, `set_code`
- `state_root`, `storage_root`

Important semantics to preserve:
- Distinguish non-existent account from empty account (`get_account_optional` vs `get_account`).
- Snapshot stack must support nested begin/commit/rollback.
- `created_accounts` is outer-transaction scoped and reset when leaving outermost transaction.
- Cancun+ adds transaction-scoped transient storage snapshot stack (`get_transient_storage`, `set_transient_storage`).

Spec files present per fork:
- `execution-specs/src/ethereum/forks/frontier/state.py`
- `execution-specs/src/ethereum/forks/homestead/state.py`
- `execution-specs/src/ethereum/forks/tangerine_whistle/state.py`
- `execution-specs/src/ethereum/forks/spurious_dragon/state.py`
- `execution-specs/src/ethereum/forks/byzantium/state.py`
- `execution-specs/src/ethereum/forks/constantinople/state.py`
- `execution-specs/src/ethereum/forks/istanbul/state.py`
- `execution-specs/src/ethereum/forks/berlin/state.py`
- `execution-specs/src/ethereum/forks/london/state.py`
- `execution-specs/src/ethereum/forks/paris/state.py`
- `execution-specs/src/ethereum/forks/shanghai/state.py`
- `execution-specs/src/ethereum/forks/cancun/state.py`
- `execution-specs/src/ethereum/forks/prague/state.py`
- `execution-specs/src/ethereum/forks/osaka/state.py`

## Nethermind DB Directory (`nethermind/src/Nethermind/Nethermind.Db/`)
Key files to mirror for DB boundary design (state service depends on this abstraction):
- Contracts/interfaces: `IDb.cs`, `IColumnsDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs`, `IDbProvider.cs`, `IDbFactory.cs`, `IMergeOperator.cs`, `ITunableDb.cs`
- Providers/composition: `DbProvider.cs`, `DbProviderExtensions.cs`, `ReadOnlyDbProvider.cs`
- Implementations: `MemDb.cs`, `MemDbFactory.cs`, `MemColumnsDb.cs`, `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `NullDb.cs`, `NullRocksDbFactory.cs`
- Config/metadata/pruning: `DbNames.cs`, `MetadataDbKeys.cs`, `RocksDbSettings.cs`, `PruningConfig.cs`, `PruningMode.cs`, `FullPruningTrigger.cs`, `FullPruningCompletionBehavior.cs`
- Column enums: `ReceiptsColumns.cs`, `BlobTxsColumns.cs`

## Voltaire Zig APIs (`/Users/williamcory/voltaire/packages/voltaire-zig/src/`)
Top-level modules:
- `blockchain/`
- `crypto/`
- `evm/`
- `jsonrpc/`
- `precompiles/`
- `primitives/`
- `state-manager/`
- `c_api.zig`
- `log.zig`
- `root.zig`

Relevant `state-manager` files:
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/state-manager/root.zig`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/state-manager/StateCache.zig`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/state-manager/JournaledState.zig`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/state-manager/StateManager.zig`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/state-manager/ForkBackend.zig`

API shape to carry into Effect implementation:
- `StateCache`: per-domain cache + `checkpoint/revert/commit`
- `JournaledState`: read cascade (cache -> optional fork backend), write to local cache, synchronized checkpoint stack
- `StateManager`: domain getters/setters (`getBalance`, `setNonce`, `getStorage`, `setCode`), `snapshot()`, `revertToSnapshot(id)`
- `ForkBackend`: lazy remote fetch for account/storage/code + request continuation hooks

## Existing guillotine-mini Host Interface (`src/host.zig`)
`HostInterface` vtable currently exposes:
- `getBalance` / `setBalance`
- `getCode` / `setCode`
- `getStorage` / `setStorage`
- `getNonce` / `setNonce`

Constraint noted in file comments:
- Nested calls are handled by EVM internal call logic; host interface is for external state access.

## Ethereum Test Fixtures (`ethereum-tests/`)
General directory coverage:
- `ethereum-tests/TrieTests/`
- `ethereum-tests/TransactionTests/`
- `ethereum-tests/BlockchainTests/`
- `ethereum-tests/EOFTests/`
- `ethereum-tests/BasicTests/`
- `ethereum-tests/RLPTests/`
- `ethereum-tests/DifficultyTests/`

World-state relevant fixture paths:
- `ethereum-tests/fixtures_general_state_tests.tgz` (GeneralStateTests archive)
- `ethereum-tests/docs/test_types/TestStructures/GeneralStateTests`
- `ethereum-tests/BlockchainTests/ValidBlocks/bcStateTests/`
- `ethereum-tests/BlockchainTests/InvalidBlocks/bcStateTests/`

Execution-spec-tests in this checkout:
- `execution-spec-tests/fixtures/` (currently only `blockchain_tests/` present; no `state_tests/` directory found)

## Implementation Notes For Next Step
- Mirror execution-spec transaction boundary semantics first (`begin/commit/rollback` + nested depth).
- Keep account existence semantics explicit (non-existent vs empty account).
- Include transient storage journal path from Cancun+ to avoid redesign when EIP-1153 tests are enabled.
- Keep world-state surface aligned with `src/host.zig` operations for straightforward EVM host wiring.
