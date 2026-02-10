# [pass 1/5] phase-5-txpool (Transaction Pool) — Context

## Goals (from `prd/GUILLOTINE_CLIENT_PLAN.md`)

- Implement the transaction pool for pending transactions.
- Core components: `client/txpool/pool.zig` and `client/txpool/sorter.zig` (priority sorting by gas price/tip).
- Structural reference: `nethermind/src/Nethermind/Nethermind.TxPool/` (architecture only, implement idiomatically in Effect.ts).

## Spec References (from `prd/ETHEREUM_SPECS_REFERENCE.md` + direct reads)

- `prd/ETHEREUM_SPECS_REFERENCE.md`: EIP-1559 (fee market), EIP-2930 (access lists), EIP-4844 (blob transactions).
- EIP texts in repo: `EIPs/EIPS/eip-1559.md`, `EIPs/EIPS/eip-2930.md`, `EIPs/EIPS/eip-4844.md`.
- Execution-specs: `execution-specs/src/ethereum/forks/berlin/transactions.py` (`AccessListTransaction`, `validate_transaction`, `calculate_intrinsic_cost`, typed tx encode/decode).
- Execution-specs: `execution-specs/src/ethereum/forks/london/transactions.py` (`FeeMarketTransaction`, typed tx encode/decode, intrinsic gas + access list cost, `validate_transaction` nonce/gas checks).
- Execution-specs: `execution-specs/src/ethereum/forks/cancun/transactions.py` (`BlobTransaction`, `validate_transaction` includes init-code size checks, `calculate_intrinsic_cost` includes `init_code_cost`).
- Execution-specs: `execution-specs/src/ethereum/forks/cancun/fork.py` (`check_transaction` includability: base fee vs max fee, priority fee clamp, blob gas limit, blob versioned hash validation, nonce/balance/EOA checks).
- Execution-specs: `execution-specs/src/ethereum/forks/cancun/vm/gas.py` (`init_code_cost`, `calculate_total_blob_gas`, `calculate_blob_gas_price`, `calculate_data_fee`, `calculate_excess_blob_gas`).
- `devp2p/` is empty in this checkout (no local tx gossip specs available).

## Nethermind TxPool (structural reference)

Directory: `nethermind/src/Nethermind/Nethermind.TxPool/`
Key files noted:

- Core: `TxPool.cs`, `ITxPool.cs`, `TxPoolConfig.cs`, `TxPoolInfo.cs`, `TxPoolInfoProvider.cs`.
- Validation + nonce mgmt: `ITxValidator.cs`, `INonceManager.cs`, `NonceManager.cs`, `NonceLocker.cs`.
- Gossip/sender: `TxBroadcaster.cs`, `ITxSender.cs`, `TxPoolSender.cs`, `SpecDrivenTxGossipPolicy.cs`, `ITxGossipPolicy.cs`.
- Blob storage: `IBlobTxStorage.cs`, `BlobTxStorage.cs`, `NullBlobTxStorage.cs`.
- Types/utilities: `LightTransaction.cs`, `LightTxDecoder.cs`, `TransactionExtensions.cs`, `TxHandlingOptions.cs`, `TxFilteringState.cs`, `TxNonceTxPoolReserveSealer.cs`.

## Nethermind DB layer (requested listing)

Directory: `nethermind/src/Nethermind/Nethermind.Db/`
Key files noted:

- Interfaces: `IDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs`, `IColumnsDb.cs`, `ITunableDb.cs`.
- Providers: `DbProvider.cs`, `IDbProvider.cs`, `IReadOnlyDbProvider.cs`.
- Implementations: `MemDb.cs`, `MemColumnsDb.cs`, `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `NullDb.cs`.
- Support: `DbNames.cs`, `MetadataDbKeys.cs`, `Metrics.cs`, `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`.
- Pruning: `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/*`.

## Voltaire Zig primitives (txpool-relevant)

- Requested path `/Users/williamcory/voltaire/packages/voltaire-zig/src/` does not exist in this checkout.
- Zig sources are available under `/Users/williamcory/voltaire/src/` (txpool-relevant paths below).
- `/Users/williamcory/voltaire/src/root.zig`: re-exports `primitives` and `crypto` modules.
- `/Users/williamcory/voltaire/src/primitives/Transaction/Transaction.zig`: tx structs for Legacy, EIP-2930, EIP-1559, EIP-4844, EIP-7702; `TransactionType` enum; access list item type; signing/encoding helpers.
- `/Users/williamcory/voltaire/src/primitives/AccessList/`: access list structures.
- `/Users/williamcory/voltaire/src/primitives/Blob/blob.zig`: `VersionedHash`, blob gas constants, `calculateBlobGasPrice`, blob validation.
- `/Users/williamcory/voltaire/src/primitives/Gas/`, `GasPrice/`, `MaxFeePerGas/`, `MaxPriorityFeePerGas/`, `BaseFeePerGas/`, `EffectiveGasPrice/`.
- `/Users/williamcory/voltaire/src/primitives/TransactionHash/`.

## Existing Zig host interface

- `src/host.zig`: `HostInterface` vtable for balance, code, storage, nonce access. Not used for nested EVM calls; EVM handles inner calls directly.

## Ethereum test fixtures (directories)

- `ethereum-tests/TransactionTests/` (transaction validity/encoding fixtures).
- `ethereum-tests/BlockchainTests/`.
- `ethereum-tests/RLPTests/`, `ethereum-tests/BasicTests/`, `ethereum-tests/LegacyTests/`, `ethereum-tests/TrieTests/`, `ethereum-tests/EOFTests/`.
- Bundled fixtures: `ethereum-tests/fixtures_blockchain_tests.tgz`, `ethereum-tests/fixtures_general_state_tests.tgz`.

## Notes for phase-5 implementation

- Txpool must accept and rank Legacy, EIP-2930, EIP-1559, EIP-4844 (and optionally EIP-7702) transactions using Voltaire primitives.
- Effective tip calculation must follow Cancun `check_transaction` rules: `priority_fee = min(max_priority_fee_per_gas, max_fee_per_gas - base_fee)`; `effective_gas_price = base_fee + priority_fee`.
- Blob txs must satisfy `max_fee_per_blob_gas >= calculate_blob_gas_price(excess_blob_gas)` and have non-empty `blob_versioned_hashes` with valid version prefix.
- Intrinsic gas checks should include access list costs and init-code cost (EIP-3860 via Cancun `init_code_cost`).
