# [pass 1/5] phase-5-txpool (Transaction Pool) — Context

## Goals (from `prd/GUILLOTINE_CLIENT_PLAN.md`)

- Implement the transaction pool for pending transactions.
- Core components: `client/txpool/pool.zig`, `client/txpool/sorter.zig` (priority sorting by gas price/tip).
- Structural reference: `nethermind/src/Nethermind/Nethermind.TxPool/` (architecture only; implement idiomatically with Effect.ts + voltaire-effect).

## Spec References (from `prd/ETHEREUM_SPECS_REFERENCE.md` + direct reads)

- `execution-specs/src/ethereum/forks/berlin/transactions.py`: EIP-2930 access list transaction type; intrinsic gas calculation; `validate_transaction` nonce/gas checks; `recover_sender` signature rules.
- `execution-specs/src/ethereum/forks/london/transactions.py`: EIP-1559 fee market transaction type; access list costing; `validate_transaction`; typed transaction hashing.
- `execution-specs/src/ethereum/forks/cancun/transactions.py`: EIP-4844 blob transaction definition; intrinsic gas includes init-code cost for CREATE; blob tx fields `max_fee_per_blob_gas` + `blob_versioned_hashes`.
- `execution-specs/src/ethereum/forks/cancun/fork.py`: `check_transaction` rules for includability: max fee vs base fee, priority fee vs max fee, blob gas limit, blob versioned hash validation, no-blob-data error, and blob fee check vs `calculate_blob_gas_price`.
- `execution-specs/src/ethereum/forks/cancun/vm/gas.py`: `init_code_cost`, `calculate_total_blob_gas`, `calculate_blob_gas_price`, and `calculate_data_fee` (blob data fee).
- `EIPs/` is empty in this repo checkout (submodule not initialized), so `eip-1559.md`, `eip-2930.md`, and `eip-4844.md` are not available locally.

## Nethermind TxPool (structural reference)

Directory: `nethermind/src/Nethermind/Nethermind.TxPool/`
Key files noted:

- `TxPool.cs`, `ITxPool.cs`, `TxPoolConfig.cs`, `TxPoolInfo.cs`, `TxPoolInfoProvider.cs`.
- `ITxValidator.cs`, `INonceManager.cs`, `NonceManager.cs`, `NonceLocker.cs`.
- `TxBroadcaster.cs`, `ITxSender.cs`, `TxPoolSender.cs`.
- `BlobTxStorage.cs`, `IBlobTxStorage.cs`, `NullBlobTxStorage.cs`.
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

## Voltaire-effect primitives and services (txpool-relevant)

Root: `/Users/williamcory/voltaire/voltaire-effect/src/`
Primitives (from `primitives/` listing + Transaction module read):

- `primitives/Transaction` with schemas for Legacy/EIP2930/EIP1559/EIP4844/EIP7702; type enum; helpers like `Transaction.getSender`, `Transaction.getGasPrice`, `Transaction.getChainId`, `Transaction.hash`, `Transaction.isContractCreation`, plus Effect validations (`validateGasPrice`, `validateNonce`, `validateChainId`, etc.).
- `primitives/TransactionHash`, `AccessList`, `Nonce`, `Address`, `Hash`, `Hex`, `Bytes`, `Bytes32`.
- `primitives/Gas`, `GasPrice`, `MaxFeePerGas`, `MaxPriorityFeePerGas`, `BaseFeePerGas`, `EffectiveGasPrice`.
- `primitives/Blob`, `VersionedHash`, `Balance`.

Services (from `services/` listing):

- `services/NonceManager`, `services/FeeEstimator`, `services/TransactionSerializer`.
- `services/Provider`, `services/Transport`, `services/TransactionStreamService` (pending/confirmed streaming).

## Effect.ts source patterns (from `effect-repo/packages/effect/src/` listing)

- Core DI: `Context.ts`, `Layer.ts`.
- Core runtime: `Effect.ts`, `Scope.ts`, `Schedule.ts`, `Duration.ts`, `Clock.ts`.
- Concurrency/state: `Ref.ts`, `MutableRef.ts`, `PubSub.ts`, `Queue.ts`, `Stream.ts`.
- Validation: `Schema.ts`.

## Existing client-ts patterns to follow

- `client-ts/evm/TransactionProcessor.ts`: fee + balance validation, blob max-fee checks, typed errors, Context.Tag service + Layer provider.
- `client-ts/evm/IntrinsicGasCalculator.ts`: intrinsic gas calculation with access list costs, init-code cost, hardfork gates via `ReleaseSpec`.
- `client-ts/evm/ReleaseSpec.ts`: hardfork feature toggles (EIP-2930, EIP-3860, EIP-7702, etc.).
- `client-ts/blockchain/Blockchain.ts`: `Ref` + `PubSub` state, event stream with `Queue`, service interface + Tag.
- `client-ts/db/Db.ts`: Schema-validated config/flags, tagged error types, Context.Tag service.
- `client-ts/state/State.ts`: journaled state with snapshots and tagged errors.

## Ethereum test fixtures

Top-level directories under `ethereum-tests/`:

- `TransactionTests/` (transaction validity/encoding fixtures).
- `RLPTests/`, `BasicTests/`, `LegacyTests/`, `BlockchainTests/`, `TrieTests/`, `EOFTests/`.
- Bundled fixtures: `fixtures_blockchain_tests.tgz`, `fixtures_general_state_tests.tgz`.

## Notes for phase-5 implementation

- Txpool must handle Legacy, EIP-2930, EIP-1559, EIP-4844, and EIP-7702 transactions as exposed by `voltaire-effect` primitives.
- Fee sorting should use effective tip = min(maxPriorityFee, maxFee - baseFee), and include blob fee constraints for EIP-4844 (see Cancun `check_transaction`).
- Validate intrinsic gas and CREATE init-code cost (EIP-3860 via Cancun `init_code_cost` and client-ts `IntrinsicGasCalculator`).
- Nonce handling should mirror `NonceManager` patterns and avoid Promise-based code; use Effect and proper error channels.
