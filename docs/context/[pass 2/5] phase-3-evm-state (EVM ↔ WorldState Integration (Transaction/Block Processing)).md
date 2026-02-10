# [Pass 2/5] Phase 3: EVM State Integration (EVM ↔ WorldState Integration (Transaction/Block Processing)) — Context

## Goal (from `prd/GUILLOTINE_CLIENT_PLAN.md`)

Connect the EVM to WorldState for transaction/block processing.

**Key components:**
- `client/evm/host_adapter.zig` — implement `HostInterface` using WorldState
- `client/evm/processor.zig` — transaction processor

**Reference files:**
- Nethermind: `nethermind/src/Nethermind/Nethermind.Evm/`
- guillotine-mini: `src/evm.zig`, `src/host.zig`

## Specs (from `prd/ETHEREUM_SPECS_REFERENCE.md`)

**Specs:**
- `execution-specs/src/ethereum/forks/*/vm/__init__.py`
- `execution-specs/src/ethereum/forks/*/fork.py` (transaction processing)

**Tests:**
- `ethereum-tests/GeneralStateTests/` (full suite)
- `execution-spec-tests/tests/static/state_tests/`

## Execution-specs transaction processing notes (from Osaka fork)

Files read:
- `execution-specs/src/ethereum/forks/osaka/vm/__init__.py`
- `execution-specs/src/ethereum/forks/osaka/fork.py`

**Block-scoped environment (`vm.BlockEnvironment`):**
- Fields include `chain_id`, `state`, `block_gas_limit`, `block_hashes`, `coinbase`, `number`, `base_fee_per_gas`, `time`, `prev_randao`, `excess_blob_gas`, `parent_beacon_block_root`.

**Transaction-scoped environment (`vm.TransactionEnvironment`):**
- Fields include `origin`, `gas_price`, `gas`, `access_list_addresses`, `access_list_storage_keys`, `transient_storage`, `blob_versioned_hashes`, `authorizations`, `index_in_block`, `tx_hash`.

**Message / EVM model (`vm.Message`, `vm.Evm`):**
- `Message` carries `block_env`, `tx_env`, `caller`, `target`, `current_target`, `gas`, `value`, `data`, `code_address`, `code`, `depth`, `is_static`, `accessed_addresses`, `accessed_storage_keys`, `disable_precompiles`, `parent_evm`.
- `Evm` tracks runtime state: `pc`, `stack`, `memory`, `code`, `gas_left`, `logs`, `refund_counter`, `accounts_to_delete`, `return_data`, `error`, `accessed_addresses`, `accessed_storage_keys`.

**Block execution flow (`apply_body`):**
- Initialize a `BlockOutput` (tx trie, receipt trie, withdrawals trie, logs, gas used, blob gas used, requests).
- Process system transactions (e.g., beacon roots, consolidation requests) before normal tx loop.
- Loop decoded transactions and call `process_transaction`.
- Process withdrawals (apply balance deltas + withdrawal trie updates).

**Transaction execution flow (`process_transaction`):**
- Insert transaction into `transactions_trie`.
- `validate_transaction` returns intrinsic gas and calldata floor gas cost; `check_transaction` returns sender, effective gas price, blob hashes, blob gas used.
- `increment_nonce`, debit sender for gas fees and blob gas, build access list sets (coinbase + explicit access list).
- Build `TransactionEnvironment`, call `prepare_message`, then `process_message_call`.
- Gas refund uses `min(gas_used // 5, refund_counter)`; adjust for calldata floor; refund sender; pay coinbase priority fee.
- `destroy_account` for `accounts_to_delete` in tx output.
- Update `block_output` (gas used, blob gas used, logs, receipts trie).

**State touch points to bridge in Zig:**
- Account load/store: `get_account`, `set_account_balance`, `increment_nonce`, `destroy_account`.
- Storage/code: per-call access list tracking plus `transient_storage` lifetime (per-tx reset).
- Receipt + trie updates depend on RLP encoding and trie operations (`trie_set`).

## Nethermind DB Architecture (directory listing)

Directory: `nethermind/src/Nethermind/Nethermind.Db/`

**Key files present (selected):**
- Interfaces: `IDb.cs`, `IColumnsDb.cs`, `IFullDb.cs`, `IReadOnlyDb.cs`, `ITunableDb.cs`, `IDbProvider.cs`, `IReadOnlyDbProvider.cs`, `IDbFactory.cs`, `IMergeOperator.cs`
- Providers/implementations: `DbProvider.cs`, `DbProviderExtensions.cs`, `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `MemDb.cs`, `MemColumnsDb.cs`, `NullDb.cs`
- Pruning/maintenance: `IPruningConfig.cs`, `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/`, `FullPruningTrigger.cs`
- Columns/metadata: `ReceiptsColumns.cs`, `BlobTxsColumns.cs`, `MetadataDbKeys.cs`, `DbNames.cs`
- Misc: `CompressingDb.cs`, `RocksDbSettings.cs`, `Metrics.cs`

**Key takeaway for Zig:** keep DB interfaces clean and layered; EVM host adapter should depend on WorldState abstractions, not DB specifics.

## Voltaire primitives and state-manager APIs (directory listing)

Root: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- `primitives/`
- `state-manager/`
- `evm/`
- `blockchain/`
- `crypto/`
- `jsonrpc/`
- `log.zig`, `root.zig`

**State-manager modules (public API from `state-manager/root.zig`):**
- `StateManager` (primary API)
- `JournaledState`
- `ForkBackend`, `CacheConfig`, `Transport`, `RpcClient`
- Cache types: `AccountCache`, `StorageCache`, `ContractCache`, `AccountState`, `StorageKey`

**Relevant primitives to use (avoid custom types):**
- `primitives.Address`, `primitives.Hash`, `primitives.Bytes`, `primitives.Bytes32`
- `primitives.ChainId`, `primitives.Nonce`, `primitives.Block`, `primitives.BlockHeader`, `primitives.BlockBody`
- `primitives.Transaction`, `primitives.Receipt`, `primitives.Log`
- `primitives.AccountState`, `primitives.State`

## Existing Zig Host Interface (vtable pattern)

File: `src/host.zig`
- `HostInterface` uses `ptr: *anyopaque` + `vtable: *const VTable`.
- VTable exposes `getBalance`, `setBalance`, `getCode`, `setCode`, `getStorage`, `setStorage`, `getNonce`, `setNonce`.
- Thin forwarding methods call through the vtable; reuse this DI pattern for WorldState-backed host.

## Ethereum tests directory listing (fixtures)

Directory: `ethereum-tests/`
- `ABITests/`, `BasicTests/`, `BlockchainTests/`, `DifficultyTests/`, `EOFTests/`, `GenesisTests/`, `JSONSchema/`, `KeyStoreTests/`, `LegacyTests/`, `PoWTests/`, `RLPTests/`, `TransactionTests/`, `TrieTests/`
- Tarballs: `fixtures_blockchain_tests.tgz`, `fixtures_general_state_tests.tgz` (expected to unpack to `GeneralStateTests/`)

**Execution-spec-tests paths observed:**
- `execution-spec-tests/tests/static/state_tests/`
- `execution-spec-tests/tests/benchmark/stateful/`

## Summary

Captured Phase 3 goals and key components; read Osaka execution-specs VM and transaction processing flow to identify EVM↔WorldState touch points (balances, nonces, storage/code, access lists, transient storage, account deletion, receipts/tries); recorded Nethermind DB interface layering files for architectural guidance; enumerated Voltaire state-manager API surface and primitives to reuse; confirmed guillotine-mini HostInterface vtable contract; and listed Ethereum/Execution-spec test fixture locations relevant to stateful EVM integration.
