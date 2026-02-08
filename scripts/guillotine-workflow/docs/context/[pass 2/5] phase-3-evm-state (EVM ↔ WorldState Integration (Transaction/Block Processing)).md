# [pass 2/5] phase-3-evm-state (EVM <-> WorldState Integration (Transaction/Block Processing))

## Goals (from plan)
- Connect guillotine-mini EVM to WorldState for transaction and block processing.
- Key components: `client/evm/host_adapter.zig`, `client/evm/processor.zig`.
- Follow Nethermind.Evm architecture; use Voltaire primitives and state-manager.

## Spec References
- `repo_link/prd/ETHEREUM_SPECS_REFERENCE.md`:
  - `execution-specs/src/ethereum/forks/*/vm/__init__.py`
  - `execution-specs/src/ethereum/forks/*/fork.py` (transaction processing)
- Concrete fork EVM specs (current tree):
  - `repo_link/execution-specs/src/ethereum/forks/frontier/vm/__init__.py`
  - `repo_link/execution-specs/src/ethereum/forks/homestead/vm/__init__.py`
  - `repo_link/execution-specs/src/ethereum/forks/dao_fork/vm/__init__.py`
  - `repo_link/execution-specs/src/ethereum/forks/tangerine_whistle/vm/__init__.py`
  - `repo_link/execution-specs/src/ethereum/forks/spurious_dragon/vm/__init__.py`
  - `repo_link/execution-specs/src/ethereum/forks/byzantium/vm/__init__.py`
  - `repo_link/execution-specs/src/ethereum/forks/constantinople/vm/__init__.py`
  - `repo_link/execution-specs/src/ethereum/forks/istanbul/vm/__init__.py`
  - `repo_link/execution-specs/src/ethereum/forks/berlin/vm/__init__.py`
  - `repo_link/execution-specs/src/ethereum/forks/london/vm/__init__.py`
  - `repo_link/execution-specs/src/ethereum/forks/arrow_glacier/vm/__init__.py`
  - `repo_link/execution-specs/src/ethereum/forks/gray_glacier/vm/__init__.py`
  - `repo_link/execution-specs/src/ethereum/forks/muir_glacier/vm/__init__.py`
  - `repo_link/execution-specs/src/ethereum/forks/shanghai/vm/__init__.py`
  - `repo_link/execution-specs/src/ethereum/forks/cancun/vm/__init__.py`
  - `repo_link/execution-specs/src/ethereum/forks/prague/vm/__init__.py`
  - `repo_link/execution-specs/src/ethereum/forks/paris/vm/__init__.py`
  - `repo_link/execution-specs/src/ethereum/forks/osaka/vm/__init__.py`
- Concrete fork transaction processing specs (current tree):
  - `repo_link/execution-specs/src/ethereum/forks/frontier/fork.py`
  - `repo_link/execution-specs/src/ethereum/forks/homestead/fork.py`
  - `repo_link/execution-specs/src/ethereum/forks/dao_fork/fork.py`
  - `repo_link/execution-specs/src/ethereum/forks/tangerine_whistle/fork.py`
  - `repo_link/execution-specs/src/ethereum/forks/spurious_dragon/fork.py`
  - `repo_link/execution-specs/src/ethereum/forks/byzantium/fork.py`
  - `repo_link/execution-specs/src/ethereum/forks/constantinople/fork.py`
  - `repo_link/execution-specs/src/ethereum/forks/istanbul/fork.py`
  - `repo_link/execution-specs/src/ethereum/forks/berlin/fork.py`
  - `repo_link/execution-specs/src/ethereum/forks/london/fork.py`
  - `repo_link/execution-specs/src/ethereum/forks/arrow_glacier/fork.py`
  - `repo_link/execution-specs/src/ethereum/forks/gray_glacier/fork.py`
  - `repo_link/execution-specs/src/ethereum/forks/muir_glacier/fork.py`
  - `repo_link/execution-specs/src/ethereum/forks/shanghai/fork.py`
  - `repo_link/execution-specs/src/ethereum/forks/cancun/fork.py`
  - `repo_link/execution-specs/src/ethereum/forks/prague/fork.py`
  - `repo_link/execution-specs/src/ethereum/forks/paris/fork.py`
  - `repo_link/execution-specs/src/ethereum/forks/osaka/fork.py`

## Nethermind References (DB module inventory)
Listed `repo_link/nethermind/src/Nethermind/Nethermind.Db/` for storage patterns used by EVM/state integration:
- `IDb.cs`, `IColumnsDb.cs`, `IReadOnlyDb.cs`, `IDbProvider.cs`, `IFullDb.cs`
- `DbProvider.cs`, `DbProviderExtensions.cs`, `DbExtensions.cs`
- `MemDb.cs`, `MemColumnsDb.cs`, `MemDbFactory.cs`, `ReadOnlyDb.cs`
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`, `NullDb.cs`
- `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/*`

## Voltaire APIs (EVM + state-manager)
`/Users/williamcory/voltaire/packages/voltaire-zig/src/evm/`:
- `host.zig`
- `fork_state_manager.zig`
- `evm.zig`
- `frame.zig`
- `context/` (block/tx context scaffolding)

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
- `repo_link/ethereum-tests/GeneralStateTests/`
- `repo_link/execution-spec-tests/tests/static/state_tests/`

## Notes
- Phase 3 ties EVM execution to WorldState mutation; mirror `execution-specs` vm + fork transaction processing APIs when shaping host adapter and processor.
- Use Voltaire EVM/state-manager primitives and guillotine-mini HostInterface; avoid custom types.
