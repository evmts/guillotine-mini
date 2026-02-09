# [pass 1/5] phase-3-evm-state (EVM <-> WorldState Integration (Transaction/Block Processing))

## Goals (from plan)
- Connect guillotine-mini EVM to WorldState for transaction and block processing.
- Key components: `client/evm/host_adapter.zig`, `client/evm/processor.zig`.
- Follow Nethermind.Evm architecture; use Voltaire primitives and state-manager.

## Spec References (execution-specs)
- `execution-specs/src/ethereum/forks/*/vm/__init__.py` (EVM data model).
- `execution-specs/src/ethereum/forks/*/fork.py` (transaction processing).
- Concrete fork reviewed: `execution-specs/src/ethereum/forks/prague/vm/__init__.py`:
  - `BlockEnvironment`, `BlockOutput`, `TransactionEnvironment`, `Message`, `Evm` dataclasses.
  - `incorporate_child_on_success` / `incorporate_child_on_error` merge logic.
- Concrete fork reviewed: `execution-specs/src/ethereum/forks/prague/fork.py`:
  - `execute_block` builds the block output, processes system txs, iterates transactions, withdrawals, and requests.
  - `process_transaction` validates, charges intrinsic gas/fees, increments nonce, runs EVM, builds receipt/logs/tries.

## Nethermind References (Nethermind.Db inventory)
Listed `nethermind/src/Nethermind/Nethermind.Db/` for storage patterns used by EVM/state integration:
- `IDb.cs`, `IColumnsDb.cs`, `IReadOnlyDb.cs`, `IDbProvider.cs`, `IFullDb.cs`, `ITunableDb.cs`.
- `DbProvider.cs`, `DbProviderExtensions.cs`, `DbExtensions.cs`, `DbNames.cs`.
- `MemDb.cs`, `MemColumnsDb.cs`, `MemDbFactory.cs`, `ReadOnlyDb.cs`, `ReadOnlyDbProvider.cs`.
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`, `NullDb.cs`, `NullRocksDbFactory.cs`.
- `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/*`.

## Voltaire primitives (voltaire-zig)
- Requested path `/Users/williamcory/voltaire/packages/voltaire-zig/src/` is not present in this workspace.
- Fallback location observed: `/Users/williamcory/voltaire/src/` with Zig modules:
  - `evm/` (`evm.zig`, `host.zig`, `fork_state_manager.zig`, `frame.zig`, `context/`, `precompiles/`).
  - `state-manager/` (`JournaledState.zig`, `StateManager.zig`, `StateCache.zig`, `ForkBackend.zig`, `root.zig`).
  - `primitives/` (core `Address`, `Hash`, `U256`, `Bytes`, `Transaction`, `Block`, `Receipt`, `Log`, `Bloom`, `Storage`, `StateRoot`).
  - `blockchain/` (`BlockStore.zig`, `Blockchain.zig`, `ForkBlockCache.zig`).

## Existing Zig Host Interface
- `src/host.zig` provides `HostInterface` VTable for balance/code/storage/nonce access.

## Test Fixtures
- `ethereum-tests/fixtures_general_state_tests.tgz` (GeneralStateTests archive). `ethereum-tests/GeneralStateTests/` directory is not present in this checkout.
- `ethereum-tests/fixtures_blockchain_tests.tgz`.
- `execution-spec-tests/` exists but has no fixtures directory in this checkout.

## Notes
- Phase 3 ties EVM execution to WorldState mutation; mirror `execution-specs` transaction/block processing flow when shaping host adapter and processor.
- Use Voltaire EVM/state-manager primitives and guillotine-mini HostInterface; avoid custom types.
