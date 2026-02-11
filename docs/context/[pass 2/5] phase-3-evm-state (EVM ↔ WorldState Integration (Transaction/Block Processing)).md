# [Pass 2/5] Phase 3: EVM State Integration (EVM ↔ WorldState Integration (Transaction/Block Processing)) — Context

## Goal (from `prd/GUILLOTINE_CLIENT_PLAN.md`)

Phase: `phase-3-evm-state`

Primary goal: connect the EVM to WorldState for transaction/block processing.

Planned components:
- `client/evm/host_adapter.zig` — implement `HostInterface` using WorldState
- `client/evm/processor.zig` — transaction processor

Reference anchors:
- Nethermind module boundary: `nethermind/src/Nethermind/Nethermind.Evm/`
- Existing guillotine-mini behavior: `src/evm.zig`, `src/host.zig`

## Relevant Specs (from `prd/ETHEREUM_SPECS_REFERENCE.md` + direct reads)

Core execution-spec files (directly relevant to tx/block processing and EVM-state handoff):
- `execution-specs/src/ethereum/forks/osaka/fork.py`
- `execution-specs/src/ethereum/forks/osaka/vm/__init__.py`
- `execution-specs/src/ethereum/forks/osaka/state.py`

Additional fork templates to mirror per-fork behavior differences:
- `execution-specs/src/ethereum/forks/*/fork.py`
- `execution-specs/src/ethereum/forks/*/vm/__init__.py`
- `execution-specs/src/ethereum/forks/*/state.py`
- `execution-specs/src/ethereum/forks/*/transactions.py`

EIPs read for phase-3 execution semantics:
- `EIPs/EIPS/eip-1559.md` — effective gas price, base fee, intrinsic gas basis for typed txs
- `EIPs/EIPS/eip-2930.md` — access list typed tx and upfront access list costs
- `EIPs/EIPS/eip-2929.md` — warm/cold account/storage access sets and gas rules
- `EIPs/EIPS/eip-3529.md` — refund cap reduction and SELFDESTRUCT refund removal
- `EIPs/EIPS/eip-3651.md` — warm coinbase behavior
- `EIPs/EIPS/eip-3860.md` — initcode metering and max initcode constraints
- `EIPs/EIPS/eip-4844.md` — blob tx fields, blob gas accounting, excess blob gas flow
- `EIPs/EIPS/eip-6780.md` — SELFDESTRUCT account deletion constraints
- `EIPs/EIPS/eip-7702.md` — authorization tuples for set-code transactions

`devp2p/` relevance for this phase:
- No direct wire-protocol dependency for core EVM↔WorldState integration.
- Keep networking specs deferred to phase-8; only transaction execution semantics matter here.

## Execution-spec Behavioral Notes to Preserve

From `execution-specs/src/ethereum/forks/osaka/fork.py` and `execution-specs/src/ethereum/forks/osaka/vm/__init__.py`:

- `apply_body(...)` block flow:
  - initialize `BlockOutput`
  - execute system transactions (`BEACON_ROOTS_ADDRESS`, `HISTORY_STORAGE_ADDRESS`)
  - decode txs, call `process_transaction(...)` per tx
  - process withdrawals and general-purpose requests

- `process_transaction(...)` flow:
  - write tx into transactions trie via `trie_set`
  - `validate_transaction(...)` and `check_transaction(...)`
  - charge sender for execution gas + blob fee (if blob tx)
  - increment sender nonce before EVM call
  - seed tx-scoped access list sets and transient storage
  - build `TransactionEnvironment` and `Message`, execute `process_message_call(...)`
  - apply refund with cap (`min(gas_used // 5, refund_counter)`) and calldata floor adjustment
  - refund sender leftover gas, pay coinbase priority fee
  - process `accounts_to_delete` via `destroy_account(...)`
  - update gas totals, blob gas totals, receipts trie, and logs

- VM data model expectations:
  - `BlockEnvironment` holds chain + block + fee + randomness + beacon root context
  - `TransactionEnvironment` holds origin/gas/access-lists/transient-storage/blob-hashes/authorizations/tx-hash
  - `Evm` tracks runtime mutable state: gas, stack/memory, logs, refund counter, deletion set, accessed sets

- State touch points (`state.py`):
  - account read/write (`get_account`, `set_account`)
  - account deletion (`destroy_account`) and storage wipe (`destroy_storage`)
  - creation tracking (`mark_account_created`) affects SELFDESTRUCT semantics (EIP-6780)

## Nethermind DB Architecture Reference (requested listing)

Directory listed: `nethermind/src/Nethermind/Nethermind.Db/`

Key files (selected):
- Interfaces:
  - `nethermind/src/Nethermind/Nethermind.Db/IDb.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/IColumnsDb.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/IFullDb.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/IReadOnlyDb.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/IDbProvider.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/IDbFactory.cs`
- Providers/impls:
  - `nethermind/src/Nethermind/Nethermind.Db/DbProvider.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDb.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/MemDb.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/MemColumnsDb.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/NullDb.cs`
- Columns/config/pruning:
  - `nethermind/src/Nethermind/Nethermind.Db/DbNames.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/ReceiptsColumns.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/BlobTxsColumns.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/PruningConfig.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/PruningMode.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/FullPruning/`

Architecture takeaway for phase-3:
- keep host adapter and tx processor dependent on state abstractions, not concrete DB storage details.

## Voltaire Zig APIs (requested listing)

Listed root: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`

Relevant modules for phase-3 integration:
- Primitives exports (`/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/root.zig`):
  - `Address`, `Hash`, `Hex`, `Bytes`, `Bytes32`
  - `Transaction`, `Receipt`, `Block`, `BlockHeader`, `BlockBody`
  - `AccountState`, `State`, `Storage`, `AccessList`, `Authorization`
  - `Gas`, `GasPrice`, `BaseFeePerGas`, `EffectiveGasPrice`, `FeeMarket`
  - `Rlp`, `Bytecode`, `Opcode`, `EventLog`

- State manager exports (`/Users/williamcory/voltaire/packages/voltaire-zig/src/state-manager/root.zig`):
  - `StateManager`
  - `JournaledState`
  - `ForkBackend`, `CacheConfig`, `Transport`, `RpcClient`
  - cache-level types `AccountCache`, `StorageCache`, `ContractCache`, `AccountState`, `StorageKey`

- EVM implementation files:
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/evm/evm.zig`
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/evm/host.zig`

## Existing Guillotine-mini Host Interface (`src/host.zig`)

Current `HostInterface` is a vtable bridge with these required methods:
- `getBalance` / `setBalance`
- `getCode` / `setCode`
- `getStorage` / `setStorage`
- `getNonce` / `setNonce`

Design implication:
- phase-3 host adapter should map these methods directly to WorldState operations with tx-scoped semantics handled in processor/EVM flow.

## Ethereum Test Fixture Paths (requested directory listing)

Top-level directories currently present under `ethereum-tests/`:
- `ethereum-tests/ABITests/`
- `ethereum-tests/BasicTests/`
- `ethereum-tests/BlockchainTests/`
- `ethereum-tests/DifficultyTests/`
- `ethereum-tests/EOFTests/`
- `ethereum-tests/GenesisTests/`
- `ethereum-tests/JSONSchema/`
- `ethereum-tests/KeyStoreTests/`
- `ethereum-tests/LegacyTests/`
- `ethereum-tests/PoWTests/`
- `ethereum-tests/RLPTests/`
- `ethereum-tests/TransactionTests/`
- `ethereum-tests/TrieTests/`

Relevant fixture archives/paths for phase-3:
- `ethereum-tests/fixtures_general_state_tests.tgz` (contains `GeneralStateTests/...`)
- `ethereum-tests/fixtures_blockchain_tests.tgz` (contains `BlockchainTests/...`)

Execution-spec-tests in this checkout:
- `execution-spec-tests/fixtures/`
- `execution-spec-tests/fixtures/blockchain_tests/` (present, currently empty in this workspace)

## Summary

This pass gathered concrete phase-3 references for EVM↔WorldState wiring: authoritative Osaka execution flows, EIP constraints that directly affect gas/access/refund/account-deletion behavior, Nethermind DB module boundaries for layering discipline, Voltaire primitive/state APIs to reuse, existing guillotine-mini host vtable contract, and available fixture paths (including `GeneralStateTests` inside tarball archives).
