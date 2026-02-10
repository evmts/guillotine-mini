
# [pass 1/5] phase-5-txpool (Transaction Pool)

## Goal (from `prd/GUILLOTINE_CLIENT_PLAN.md`)
- Implement transaction pool for pending transactions.
- Key components: `client/txpool/pool.zig`, `client/txpool/sorter.zig`.
- Structural reference: `nethermind/src/Nethermind/Nethermind.TxPool/`.

## Specs (from `prd/ETHEREUM_SPECS_REFERENCE.md`)
- EIP-1559 fee market (type-2): max fee / priority fee, effective gas price.
- EIP-2930 access lists (type-1): access list structure and intrinsic gas costs.
- EIP-4844 blob transactions (type-3): `max_fee_per_blob_gas`, `blob_versioned_hashes` and blob gas domain.

### Execution-specs touch points (transaction validity/gas accounting)
- `execution-specs/src/ethereum/forks/london/transactions.py` — type-2 (1559) gas accounting + base fee interactions.
- `execution-specs/src/ethereum/forks/berlin/transactions.py` — access list (2930) format and costs.
- `execution-specs/src/ethereum/forks/cancun/transactions.py` — blob transaction fields (4844) and hashing.

## Nethermind reference (architecture only)
- TxPool module entry: `nethermind/src/Nethermind/Nethermind.TxPool/` (selection/sorting, sender nonce buckets, basefee-aware pricing).
- DB abstractions commonly used across modules: `nethermind/src/Nethermind/Nethermind.Db/` (for persistent tips like seen tx hashes, receipts, etc., if/when persisted).

### Nethermind.Db inventory (key files)
From `nethermind/src/Nethermind/Nethermind.Db/`:
- BlobTxsColumns.cs, CompressingDb.cs, DbExtensions.cs, DbNames.cs, DbProvider.cs, DbProviderExtensions.cs
- IColumnsDb.cs, IDb.cs, IDbFactory.cs, IDbProvider.cs, IFullDb.cs, IMergeOperator.cs, IPruningConfig.cs
- IReadOnlyDb.cs, IReadOnlyDbProvider.cs, ITunableDb.cs
- InMemoryColumnBatch.cs, InMemoryWriteBatch.cs, MemColumnsDb.cs, MemDb.cs, MemDbFactory.cs
- MetadataDbKeys.cs, Metrics.cs, NullDb.cs, NullRocksDbFactory.cs
- PruningConfig.cs, PruningMode.cs, ReadOnlyColumnsDb.cs, ReadOnlyDb.cs, ReadOnlyDbProvider.cs
- ReceiptsColumns.cs, RocksDbMergeEnumerator.cs, RocksDbSettings.cs, SimpleFilePublicKeyDb.cs
- Dirs: `Blooms/`, `FullPruning/`

## Voltaire Zig APIs (must-use primitives)
Root: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- primitives/Transaction/Transaction.zig — canonical transaction types (legacy, 2930, 1559, 4844, 7702), signing/encoding, type detection.
- primitives/AccessList/* — access list item types and RLP helpers.
- primitives/Address/* — `Address` parsing and bytes view used across tx structs.
- primitives/Rlp/* — RLP encode helpers used by tx encode paths.
- primitives/Hash/* — `Hash` (keccak256 digest type) utilities.
- primitives/Gas*, primitives/FeeMarket/* — gas units, fee representations for sorting rules.
- primitives/Blob/* — versioned blob hash type used by 4844.
- evm/* — not reimplemented here; txpool interacts with EVM via host/world state integration in later phases.

## Existing Zig Host Interface (guillotine-mini)
From `src/host.zig`:
- `HostInterface` exposes: `getBalance`, `setBalance`, `getCode`, `setCode`, `getStorage`, `setStorage`, `getNonce`, `setNonce`.
- Note: nested calls use `CallParams/CallResult` inside the EVM; this host is for outer state only.

## ethereum-tests fixtures (useful for tx validation)
Top-level `ethereum-tests/` dirs:
- `TransactionTests/` (primary for tx-level validity):
  - `ttEIP1559/`, `ttEIP2930/`, `ttGasLimit/`, `ttGasPrice/`, `ttNonce/`, `ttRSValue/`, `ttSignature/`, `ttVValue/`, `ttWrongRLP/`, plus `ttAddress/`, `ttData/`, `ttValue/`.
- `TrieTests/`, `BlockchainTests/`, `BasicTests/`, etc., for broader integration.

## Implementation notes for txpool (forward-looking, non-binding)
- Use Voltaire `Transaction` types for parsing, signature presence, and chainId extraction; do not duplicate primitives.
- Sorting policy must be 1559-aware: prioritize by `effective_tip = min(max_fee_per_gas, basefee + max_priority) - basefee`, then nonce ordering per sender.
- Enforce per-sender nonce gaps and capacity constraints; bucket transactions by sender and pop next executable by current account nonce.
- Blob txs (4844) require separate limit tracking for `max_fee_per_blob_gas`; pool should surface this for block builders.

## Summary
Collected txpool phase goals, definitive spec files (EIPs 1559/2930/4844 and execution-specs per-fork `transactions.py`), Nethermind.Db key files (for storage patterns), Voltaire primitives/APIs (Transaction, AccessList, Address, RLP, Hash, Gas/FeeMarket, Blob), host interface details, and ethereum-tests fixture paths focused on `TransactionTests/`.
