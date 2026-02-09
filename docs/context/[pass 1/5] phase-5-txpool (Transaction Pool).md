# [pass 1/5] phase-5-txpool (Transaction Pool) — Context

## Goals (from `prd/GUILLOTINE_CLIENT_PLAN.md`)

- Implement the transaction pool for pending transactions.
- Core components: `client/txpool/pool.zig` and `client/txpool/sorter.zig` (priority sorting by gas price/tip).
- Structural reference: `nethermind/src/Nethermind/Nethermind.TxPool/` (architecture only, implement idiomatically in Zig).

## Spec References (from `prd/ETHEREUM_SPECS_REFERENCE.md` + direct reads)

- `prd/ETHEREUM_SPECS_REFERENCE.md`: EIP-1559 (fee market), EIP-2930 (access list), EIP-4844 (blob transactions).
- `execution-specs/src/ethereum/forks/berlin/transactions.py`: EIP-2930 access list tx type; intrinsic gas calculation; `validate_transaction` (gas and nonce bounds); typed transaction encoding.
- `execution-specs/src/ethereum/forks/london/transactions.py`: EIP-1559 fee market tx type; `calculate_intrinsic_cost`; `validate_transaction`; typed transaction encoding/hashing.
- `execution-specs/src/ethereum/forks/cancun/transactions.py`: EIP-4844 blob tx type; `FeeMarketTransaction` + `BlobTransaction` fields; access list + blob versioned hashes.
- `execution-specs/src/ethereum/forks/cancun/fork.py`: `check_transaction` includability checks (base fee vs max fee, priority fee vs max fee, blob gas limit, blob versioned hash validation, blob max-fee check, nonce/balance checks).
- `execution-specs/src/ethereum/forks/cancun/vm/gas.py`: `init_code_cost`, `calculate_total_blob_gas`, `calculate_blob_gas_price`, `calculate_data_fee`.
- `EIPs/` is empty in this checkout (submodule not initialized), so local `eip-1559.md`, `eip-2930.md`, `eip-4844.md` are unavailable.
- `devp2p/` is empty in this checkout (submodule not initialized), so ETH protocol tx gossip specs are unavailable locally.

## Nethermind TxPool (structural reference)

Directory: `nethermind/src/Nethermind/Nethermind.TxPool/`
Key files noted:

- `TxPool.cs`, `ITxPool.cs`, `TxPoolConfig.cs`, `TxPoolInfo.cs`, `TxPoolInfoProvider.cs`.
- `ITxValidator.cs`, `INonceManager.cs`, `NonceManager.cs`, `NonceLocker.cs`.
- `TxBroadcaster.cs`, `ITxSender.cs`, `TxPoolSender.cs`.
- `IBlobTxStorage.cs`, `BlobTxStorage.cs`, `NullBlobTxStorage.cs`.
- `ITxGossipPolicy.cs`, `SpecDrivenTxGossipPolicy.cs`.
- `LightTransaction.cs`, `LightTxDecoder.cs`.
- `TxFilteringState.cs`, `TxHandlingOptions.cs`, `TxNonceTxPoolReserveSealer.cs`.

## Nethermind DB layer (requested listing)

Directory: `nethermind/src/Nethermind/Nethermind.Db/`
Key files noted:

- Interfaces: `IDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs`, `IColumnsDb.cs`, `ITunableDb.cs`.
- Providers: `DbProvider.cs`, `IDbProvider.cs`, `IReadOnlyDbProvider.cs`.
- Implementations: `MemDb.cs`, `MemColumnsDb.cs`, `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`.
- Support: `DbNames.cs`, `MetadataDbKeys.cs`, `Metrics.cs`, `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`.
- Pruning: `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/*`.

## Voltaire Zig primitives (txpool-relevant)

- Requested path `/Users/williamcory/voltaire/packages/voltaire-zig/src/` does not exist in this checkout. The Zig primitives appear under `/Users/williamcory/voltaire/src/`.
- ` /Users/williamcory/voltaire/src/root.zig`: re-exports `primitives` and `crypto` modules.
- ` /Users/williamcory/voltaire/src/primitives/Transaction/Transaction.zig`: transaction types and helpers for Legacy, EIP-2930, EIP-1559, EIP-4844, EIP-7702; `TransactionType` enum; signing/encoding helpers.
- ` /Users/williamcory/voltaire/src/primitives/AccessList/`: access list structures.
- ` /Users/williamcory/voltaire/src/primitives/Nonce/`, `Address/`, `Hash/`, `Bytes/`, `Bytes32/`.
- ` /Users/williamcory/voltaire/src/primitives/Gas/`, `GasPrice/`, `MaxFeePerGas/`, `MaxPriorityFeePerGas/`, `BaseFeePerGas/`, `EffectiveGasPrice/`.
- ` /Users/williamcory/voltaire/src/primitives/Blob/` (includes `VersionedHash`).
- ` /Users/williamcory/voltaire/src/primitives/TransactionHash/`.

## Existing Zig host interface

- `src/host.zig`: `HostInterface` vtable for balance, code, storage, nonce access. Not used for nested EVM calls; EVM handles inner calls directly.

## Ethereum test fixtures (directories)

- `ethereum-tests/TransactionTests/` (transaction validity/encoding fixtures).
- `ethereum-tests/BlockchainTests/`.
- `ethereum-tests/RLPTests/`, `ethereum-tests/BasicTests/`, `ethereum-tests/LegacyTests/`, `ethereum-tests/TrieTests/`, `ethereum-tests/EOFTests/`.
- Bundled fixtures: `ethereum-tests/fixtures_blockchain_tests.tgz`, `ethereum-tests/fixtures_general_state_tests.tgz`.

## Notes for phase-5 implementation

- Txpool must accept and rank Legacy, EIP-2930, EIP-1559, and EIP-4844 (and likely EIP-7702) transactions using Voltaire Zig primitives only.
- Effective tip calculation must follow Cancun `check_transaction`: `priority_fee = min(max_priority_fee_per_gas, max_fee_per_gas - base_fee)`, `effective_gas_price = base_fee + priority_fee`.
- Blob txs must satisfy `max_fee_per_blob_gas >= calculate_blob_gas_price(excess_blob_gas)` and have non-empty `blob_versioned_hashes` with the correct version prefix.
- Intrinsic gas checks should include access list costs and init-code cost (EIP-3860 via Cancun `init_code_cost`).
