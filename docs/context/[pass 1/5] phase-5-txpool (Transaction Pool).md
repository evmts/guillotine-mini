# [pass 1/5] phase-5-txpool (Transaction Pool)

## Phase Goal
Source: `prd/GUILLOTINE_CLIENT_PLAN.md`
- Goal: implement transaction pool for pending transactions.
- Key components:
- `client/txpool/pool.zig`
- `client/txpool/sorter.zig`
- Reference module boundary: `nethermind/src/Nethermind/Nethermind.TxPool/`.

## Spec Scope For This Phase
Source: `prd/ETHEREUM_SPECS_REFERENCE.md`
- EIP-1559 fee market.
- EIP-2930 access lists.
- EIP-4844 blob transactions.

Relevant spec files read:
- `EIPs/EIPS/eip-1559.md`
- `EIPs/EIPS/eip-2930.md`
- `EIPs/EIPS/eip-4844.md`
- `execution-specs/src/ethereum/forks/berlin/transactions.py`
- `execution-specs/src/ethereum/forks/london/transactions.py`
- `execution-specs/src/ethereum/forks/cancun/transactions.py`
- `execution-specs/src/ethereum/forks/prague/transactions.py`

Spec takeaways for txpool behavior:
- 1559: replacement/ordering logic must account for `max_fee_per_gas` and `max_priority_fee_per_gas`, with base-fee-dependent effective tip.
- 2930: access-list transactions are typed transactions with explicit intrinsic gas adders per address/storage key.
- 4844: blob txs add `max_fee_per_blob_gas` and `blob_versioned_hashes`; execution and gossip representations differ.

## Nethermind References
### Requested directory listing
Listed: `nethermind/src/Nethermind/Nethermind.Db/`

Key files noted:
- `nethermind/src/Nethermind/Nethermind.Db/DbProvider.cs`
- `nethermind/src/Nethermind/Nethermind.Db/DbNames.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IDbProvider.cs`
- `nethermind/src/Nethermind/Nethermind.Db/MemDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/BlobTxsColumns.cs`
- `nethermind/src/Nethermind/Nethermind.Db/ReceiptsColumns.cs`
- `nethermind/src/Nethermind/Nethermind.Db/MetadataDbKeys.cs`
- `nethermind/src/Nethermind/Nethermind.Db/RocksDbSettings.cs`
- `nethermind/src/Nethermind/Nethermind.Db/CompressingDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/PruningConfig.cs`
- `nethermind/src/Nethermind/Nethermind.Db/Metrics.cs`

Txpool architecture boundary (phase-specific):
- `nethermind/src/Nethermind/Nethermind.TxPool/TxPool.cs`
- `nethermind/src/Nethermind/Nethermind.TxPool/ITxPool.cs`
- `nethermind/src/Nethermind/Nethermind.TxPool/Filters/FeeTooLowFilter.cs`
- `nethermind/src/Nethermind/Nethermind.TxPool/Filters/PriorityFeeTooLowFilter.cs`
- `nethermind/src/Nethermind/Nethermind.TxPool/Filters/GapNonceFilter.cs`
- `nethermind/src/Nethermind/Nethermind.TxPool/Collections/TxDistinctSortedPool.cs`
- `nethermind/src/Nethermind/Nethermind.TxPool/Comparison/CompareReplacedTxByFee.cs`
- `nethermind/src/Nethermind/Nethermind.TxPool/NonceManager.cs`
- `nethermind/src/Nethermind/Nethermind.TxPool/BlobTxStorage.cs`

## Voltaire Zig APIs
Requested directory listing:
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/`

Relevant API modules noted:
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/root.zig`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/Transaction/Transaction.zig`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/FeeMarket/fee_market.zig`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/Blob/blob.zig`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/PendingTransactionFilter/pending_transaction_filter.zig`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/Blockchain.zig`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/BlockStore.zig`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/ForkBlockCache.zig`

## Existing Guillotine Host Interface
File read: `src/host.zig`
- `HostInterface` is a vtable-based state access boundary.
- Exposes balance/code/storage/nonce getters and setters.
- Nested EVM calls are not routed through this host interface (commented in file); EVM handles nested call flow internally.

## Ethereum Tests Fixture Paths
Requested directory listing: `ethereum-tests/` directories.

Txpool-relevant fixture roots:
- `ethereum-tests/TransactionTests/`
- `ethereum-tests/TransactionTests/ttEIP1559/`
- `ethereum-tests/TransactionTests/ttEIP2930/`
- `ethereum-tests/TransactionTests/ttNonce/`
- `ethereum-tests/TransactionTests/ttGasPrice/`
- `ethereum-tests/TransactionTests/ttGasLimit/`
- `ethereum-tests/TransactionTests/ttWrongRLP/`
- `ethereum-tests/BlockchainTests/`
- `ethereum-tests/src/TransactionTestsFiller/`

## Notes
- `devp2p/` is present but empty in this workspace checkout, so tx gossip wire details are taken from EIP-4844 networking section and phase references rather than local `devp2p/*.md` files.
- Existing txpool Zig sources already present for behavior reference:
- `client/txpool/pool.zig`
- `client/txpool/sorter.zig`
- `client/txpool/limits.zig`

## Summary
Collected phase-5 goals, txpool-relevant execution/EIP spec files, key Nethermind Db and TxPool reference files, Voltaire Zig API modules, host interface behavior, and ethereum-tests fixture paths needed to guide Effect.ts txpool implementation.
