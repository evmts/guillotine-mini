# [pass 2/5] phase-2-world-state (World State (Journal + Snapshot/Restore))

## Goals (from plan)
- Implement journaled state with snapshot/restore for transaction processing.
- Key components: `client/state/account.zig`, `client/state/journal.zig`, `client/state/state.zig`.
- Follow Nethermind.State architecture; use Voltaire primitives and state-manager.

## Spec References
- `repo_link/prd/ETHEREUM_SPECS_REFERENCE.md`:
  - `execution-specs/src/ethereum/forks/*/state.py`
  - Yellow Paper Section 4 (World State)
- Concrete fork state specs (current tree):
  - `repo_link/execution-specs/src/ethereum/forks/frontier/state.py`
  - `repo_link/execution-specs/src/ethereum/forks/homestead/state.py`
  - `repo_link/execution-specs/src/ethereum/forks/byzantium/state.py`
  - `repo_link/execution-specs/src/ethereum/forks/istanbul/state.py`
  - `repo_link/execution-specs/src/ethereum/forks/berlin/state.py`
  - `repo_link/execution-specs/src/ethereum/forks/london/state.py`
  - `repo_link/execution-specs/src/ethereum/forks/shanghai/state.py`
  - `repo_link/execution-specs/src/ethereum/forks/cancun/state.py`
  - `repo_link/execution-specs/src/ethereum/forks/prague/state.py`
  - `repo_link/execution-specs/src/ethereum/forks/osaka/state.py`

## Nethermind References (DB module inventory)
Listed `repo_link/nethermind/src/Nethermind/Nethermind.Db/` for cross-module storage patterns:
- `IDb.cs`, `IColumnsDb.cs`, `IReadOnlyDb.cs`, `IDbProvider.cs`, `IFullDb.cs`
- `DbProvider.cs`, `DbProviderExtensions.cs`, `DbExtensions.cs`
- `MemDb.cs`, `MemColumnsDb.cs`, `MemDbFactory.cs`, `ReadOnlyDb.cs`
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`, `NullDb.cs`
- `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/*`

## Voltaire APIs (state-manager)
`/Users/williamcory/voltaire/packages/voltaire-zig/src/state-manager/`:
- `JournaledState.zig`
- `StateManager.zig`
- `StateCache.zig`
- `ForkBackend.zig`
- `root.zig`
- `c_api.zig`

## Existing Zig Host Interface
- `repo_link/src/host.zig` provides `HostInterface` VTable for balance/code/storage/nonce access.

## Test Fixtures
- `repo_link/ethereum-tests/fixtures_general_state_tests.tgz` (GeneralStateTests fixture archive)
- `repo_link/ethereum-tests/BlockchainTests/` (secondary cross-check)

## Notes
- Phase 2 emphasizes journaling + snapshot/restore behavior; align with `execution-specs` state.py patterns and Yellow Paper world state definitions.
- Prefer Voltaire state-manager primitives; avoid custom types.
