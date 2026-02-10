# [pass 2/5] phase-5-txpool (Transaction Pool)

## Goal (from prd/GUILLOTINE_CLIENT_PLAN.md)

- Implement the transaction pool for pending transactions.
- Key components: `client/txpool/pool.zig` and `client/txpool/sorter.zig` (priority sorting by gas price/tip).

## Spec references (from prd/ETHEREUM_SPECS_REFERENCE.md)

- EIP-1559 fee market: `EIPs/EIPS/eip-1559.md`
- EIP-2930 access lists: `EIPs/EIPS/eip-2930.md`
- EIP-4844 blob transactions: `EIPs/EIPS/eip-4844.md`
- Transaction rules by fork (execution-specs):
  - `execution-specs/src/ethereum/forks/london/transactions.py` (EIP-1559)
  - `execution-specs/src/ethereum/forks/berlin/transactions.py` (EIP-2930)
  - `execution-specs/src/ethereum/forks/cancun/transactions.py` (EIP-4844 / blob txs)

## Nethermind reference (architecture)

- TxPool module: `nethermind/src/Nethermind/Nethermind.TxPool/`
  - Key files: `ITxPool.cs`, `TxPool.cs`, `TxPoolConfig.cs`, `ITxValidator.cs`,
    `NonceManager.cs`, `TxBroadcaster.cs`, `TxSealer.cs`, `TxPoolSender.cs`,
    `SpecDrivenTxGossipPolicy.cs`, `IBlobTxStorage.cs`, `BlobTxStorage.cs`.
- Db module (persistence primitives): `nethermind/src/Nethermind/Nethermind.Db/`
  - Key files: `IDb.cs`, `IColumnsDb.cs`, `DbProvider.cs`, `DbNames.cs`,
    `RocksDbSettings.cs`, `ReadOnlyDb.cs`, `MemDb.cs`, `PruningConfig.cs`,
    `PruningMode.cs`, `Metrics.cs`.

## Voltaire primitives (from /Users/williamcory/voltaire/packages/voltaire-zig/src/)

- `primitives/` (txpool-critical types):
  - `Transaction`, `TransactionHash`, `FeeMarket`, `Gas`, `GasPrice`,
    `MaxFeePerGas`, `MaxPriorityFeePerGas`, `BaseFeePerGas`, `AccessList`,
    `Nonce`, `Hash`, `Blob`, `Receipt`, `PendingTransactionFilter`, `Rlp`,
    `ChainId`.
- Other relevant modules: `blockchain/` (chain head + block types),
  `state-manager/` (state access), `evm/` (execution types).

## Existing Zig code

- `client/txpool/pool.zig`: TxPoolConfig + TxPool vtable (pending_count, pending_blob_count) with tests.
- `src/host.zig`: HostInterface vtable for balance/code/storage/nonce; EVM inner_call bypasses host for nested calls.

## Test fixtures (ethereum-tests/)

- Directories: `ABITests/`, `BasicTests/`, `BlockchainTests/`, `DifficultyTests/`,
  `EOFTests/`, `GenesisTests/`, `KeyStoreTests/`, `LegacyTests/`, `PoWTests/`,
  `RLPTests/`, `TransactionTests/`, `TrieTests/`.
- Likely txpool-relevant: `ethereum-tests/TransactionTests/`, `ethereum-tests/BasicTests/`,
  `ethereum-tests/RLPTests/` and fixture tarballs:
  `ethereum-tests/fixtures_blockchain_tests.tgz`, `ethereum-tests/fixtures_general_state_tests.tgz`.
