# [pass 1/5] phase-3-evm-state (EVM <-> WorldState Integration (Transaction/Block Processing))

## Goals (from plan)
- Connect guillotine-mini EVM to WorldState for transaction and block processing.
- Key components: `client/evm/host_adapter.zig`, `client/evm/processor.zig`.
- Follow Nethermind.Evm architecture; use Voltaire primitives and state-manager.

## Spec References (from prd/ETHEREUM_SPECS_REFERENCE.md)
- `execution-specs/src/ethereum/forks/*/vm/__init__.py` (EVM data model).
- `execution-specs/src/ethereum/forks/*/fork.py` (transaction/block processing).

## Spec Notes (execution-specs, Prague fork)
- `execution-specs/src/ethereum/forks/prague/vm/__init__.py`:
  - `BlockEnvironment`, `BlockOutput`, `TransactionEnvironment`, `Message`, `Evm` dataclasses define state passed into EVM execution.
  - `incorporate_child_on_success`/`incorporate_child_on_error` merge gas/log/refund/access lists from child evm.
- `execution-specs/src/ethereum/forks/prague/fork.py`:
  - `execute_block` runs system transactions, loops transactions, processes withdrawals, and general purpose requests.
  - `process_transaction` handles intrinsic gas, upfront fee accounting, access list population, message preparation, EVM execution, gas refund floor (EIP-7623), miner fee transfer, account deletions, and receipts/tries updates.

## Nethermind References (Nethermind.Db inventory)
Listed `nethermind/src/Nethermind/Nethermind.Db/` for storage patterns used by EVM/state integration:
- `IDb.cs`, `IColumnsDb.cs`, `IReadOnlyDb.cs`, `IDbProvider.cs`, `IFullDb.cs`, `ITunableDb.cs`.
- `DbProvider.cs`, `DbProviderExtensions.cs`, `DbExtensions.cs`, `DbNames.cs`.
- `MemDb.cs`, `MemColumnsDb.cs`, `MemDbFactory.cs`, `ReadOnlyDb.cs`, `ReadOnlyDbProvider.cs`.
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`, `NullDb.cs`, `NullRocksDbFactory.cs`.
- `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/*`.

## Voltaire primitives (voltaire-zig)
- Requested path `/Users/williamcory/voltaire/packages/voltaire-zig/src/` is not present in this workspace.
- Fallback location observed: `/Users/williamcory/voltaire/src/` with relevant Zig/TS modules:
  - `evm/` (`evm.zig`, `host.zig`, `fork_state_manager.zig`, `frame.zig`, `context/`, `precompiles/`).
  - `state-manager/` (`JournaledState.zig`, `StateManager.zig`, `StateCache.zig`, `ForkBackend.zig`, `root.zig`).
  - `primitives/` (core `Address`, `Hash`, `U256`, `Bytes`, `Transaction`, `Block`, `Receipt`, `Log`, `Bloom`, `Storage`, `StateRoot`).
  - `blockchain/` (blockchain module root exists under `/Users/williamcory/voltaire/src/blockchain`).

## Existing Zig Host Interface
- `src/host.zig` provides `HostInterface` vtable for balance/code/storage/nonce access:
  - `getBalance`, `setBalance`, `getCode`, `setCode`, `getStorage`, `setStorage`, `getNonce`, `setNonce`.
  - Used for external state access; nested calls are handled internally by the EVM.

## Test Fixtures (ethereum-tests / execution-spec-tests)
- `ethereum-tests/` top-level directories include: `BasicTests/`, `BlockchainTests/`, `TransactionTests/`, `TrieTests/`, `EOFTests/`, `GenesisTests/`, `DifficultyTests/`, `LegacyTests/`, `PoWTests/`, `RLPTests/`, `KeyStoreTests/`, `ABITests/`.
- Archives present: `ethereum-tests/fixtures_general_state_tests.tgz`, `ethereum-tests/fixtures_blockchain_tests.tgz`.
- `ethereum-tests/GeneralStateTests/` directory is not present in this checkout (must unpack archive).
- `execution-spec-tests/` exists but is empty; expected fixtures path: `execution-spec-tests/fixtures/state_tests/`.

## Notes
- Phase 3 ties EVM execution to WorldState mutation; mirror `execution-specs` transaction/block processing flow when shaping host adapter and processor.
- Use Voltaire EVM/state-manager primitives and guillotine-mini HostInterface; avoid custom types.
