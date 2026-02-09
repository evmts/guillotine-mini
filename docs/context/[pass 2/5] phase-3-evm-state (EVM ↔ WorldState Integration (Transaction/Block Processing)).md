# [Pass 2/5] Phase 3: EVM State Integration (EVM <-> WorldState Integration (Transaction/Block Processing)) — Context

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
- `execution-specs/src/ethereum/forks/*/fork.py` (transaction processing / block application)

**Tests:**
- `ethereum-tests/GeneralStateTests/` (full suite)
- `execution-spec-tests/fixtures/state_tests/`

## Execution-specs transaction processing notes (from Cancun fork)

Files read:
- `execution-specs/src/ethereum/forks/cancun/fork.py`
- `execution-specs/src/ethereum/forks/cancun/vm/__init__.py`

**Block-scoped environment (`vm.BlockEnvironment`):**
- Fields include `chain_id`, `state`, `block_gas_limit`, `block_hashes`, `coinbase`, `number`, `base_fee_per_gas`, `time`, `prev_randao`, `excess_blob_gas`, `parent_beacon_block_root`.

**Transaction-scoped environment (`vm.TransactionEnvironment`):**
- Fields include `origin`, `gas_price`, `gas`, `access_list_addresses`, `access_list_storage_keys`, `transient_storage`, `blob_versioned_hashes`, `index_in_block`, `tx_hash`.

**Message / EVM model (`vm.Message`, `vm.Evm`):**
- `Message` carries `block_env`, `tx_env`, `caller`, `target`, `current_target`, `gas`, `value`, `data`, `code_address`, `code`, `depth`, `is_static`, and access lists.
- `Evm` tracks runtime state: `pc`, `stack`, `memory`, `code`, `gas_left`, `logs`, `refund_counter`, `accounts_to_delete`, `return_data`, `error`.

**Block execution flow (`apply_body`):**
- Initialize a `BlockOutput` (tx trie, receipt trie, withdrawals trie, logs, gas used).
- Process system transaction for `BEACON_ROOTS_ADDRESS`.
- Loop decoded transactions and call `process_transaction`.
- Process withdrawals (apply balance deltas + withdrawal trie updates).

**Transaction execution flow (`process_transaction`):**
- Insert transaction into `transactions_trie`.
- `validate_transaction` returns intrinsic gas; `check_transaction` returns sender, effective gas price, blob hashes, blob gas used.
- `increment_nonce`, debit sender for gas fees and blob gas, build access list sets (coinbase + explicit access list).
- Build `TransactionEnvironment`, call `prepare_message`, then `process_message_call`.
- Gas refund: `min(gas_used // 5, refund_counter)`; refund sender; pay coinbase priority fee.
- `destroy_account` for `accounts_to_delete` in tx output.
- Update `block_output` (gas used, blob gas used, logs, receipts trie).

**State touch points to bridge in Zig:**
- `get_account`, `set_account_balance`, `increment_nonce`, `destroy_account`, `modify_state`.
- Receipt + trie updates rely on RLP encoding and trie operations (`trie_set`).
- `TransientStorage` participates in transaction scope and must be reset per transaction.

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

**Key takeaway for Zig:** keep state DB interfaces clean and layered; EVM host adapter should depend on WorldState abstractions, not DB specifics.

## Voltaire primitives and state-manager APIs (directory listing)

Root: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- `primitives/`
- `state-manager/`
- `evm/`
- `blockchain/`
- `crypto/`
- `jsonrpc/`
- `log.zig`, `root.zig`

**State-manager modules (public API):**
- `state-manager/JournaledState.zig` — `getAccount/getStorage/getCode`, `putAccount/putStorage/putCode`, `checkpoint/revert/commit`.
- `state-manager/StateManager.zig` — `getBalance/getNonce/getCode/getStorage` + setters; `snapshot()`/`revertToSnapshot()` wrappers.
- `state-manager/StateCache.zig` — cache types with `checkpoint/revert/commit`.
- `state-manager/ForkBackend.zig` — read-through backend for missing data.

**EVM helpers in Voltaire (for reference patterns):**
- `evm/host.zig` — HostInterface vtable pattern (identical to guillotine-mini style).
- `evm/fork_state_manager.zig` — HostInterface implementation with cache + RPC fallback.

**Relevant primitives to use (avoid custom types):**
- `primitives/Address`, `primitives/Hash`, `primitives/Bytes`, `primitives/Bytes32`
- `primitives/Uint` / `u256`, `primitives/Nonce`, `primitives/Gas`, `primitives/Transaction`, `primitives/Receipt`
- `primitives/State`, `primitives/StateRoot`, `primitives/Storage`, `primitives/StorageValue`

## Existing Zig Host Interface (vtable pattern)

File: `src/host.zig`
- `HostInterface` uses `ptr: *anyopaque` + `vtable: *const VTable`.
- VTable exposes `getBalance`, `setBalance`, `getCode`, `setCode`, `getStorage`, `setStorage`, `getNonce`, `setNonce`.
- Thin forwarding methods call through the vtable; reuse this DI pattern for WorldState-backed host.

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
- `fixtures_general_state_tests.tgz` (expected to unpack to `GeneralStateTests/`)
- `src/`

**Execution-spec-tests fixtures:**
- `execution-spec-tests/` contains the generator; fixtures are expected under `execution-spec-tests/fixtures/` once generated (see `execution-spec-tests/README.md`).

## Summary

Captured Phase 3 goals and key components, mapped the transaction/block-processing specs from execution-specs (Cancun `fork.py` + `vm/__init__.py`), noted the exact state touch points needed for the host adapter and tx processor (balances, nonce, storage, code, account deletion, transient storage), recorded Nethermind DB module files for architectural layering, enumerated Voltaire state-manager + primitives to reuse, confirmed the guillotine-mini HostInterface vtable pattern for DI, and listed Ethereum test fixture paths (including tarball/generator locations for state tests).
