# [pass 2/5] phase-5-txpool (Transaction Pool)

## Goal (from prd/GUILLOTINE_CLIENT_PLAN.md)

- Implement the transaction pool for pending transactions.
- Key components: `client/txpool/pool.zig` and `client/txpool/sorter.zig` (priority sorting by gas price/tip).

## Spec references (from prd/ETHEREUM_SPECS_REFERENCE.md)

- EIP-1559 fee market: `EIPs/EIPS/eip-1559.md`
- EIP-2930 access lists: `EIPs/EIPS/eip-2930.md`
- EIP-4844 blob transactions: `EIPs/EIPS/eip-4844.md`
- EIP-2718 typed transaction envelope: `EIPs/EIPS/eip-2718.md` (typed tx container for 2930/1559/4844)
- Transaction rules by fork (execution-specs):
  - `execution-specs/src/ethereum/forks/london/transactions.py` (EIP-1559)
  - `execution-specs/src/ethereum/forks/berlin/transactions.py` (EIP-2930)
  - `execution-specs/src/ethereum/forks/cancun/transactions.py` (EIP-4844 / blob txs)
  - Base fee math (reference): `execution-specs/src/ethereum/forks/london/base_fee.py`

## Nethermind reference (architecture)

- TxPool module: `nethermind/src/Nethermind/Nethermind.TxPool/`
  - Key files: `ITxPool.cs`, `TxPool.cs`, `TxPoolConfig.cs`, `ITxValidator.cs`,
    `NonceManager.cs`, `TxBroadcaster.cs`, `TxSealer.cs`, `TxPoolSender.cs`,
    `SpecDrivenTxGossipPolicy.cs`, `IBlobTxStorage.cs`, `BlobTxStorage.cs`.
- Db module (persistence primitives): `nethermind/src/Nethermind/Nethermind.Db/`
  - Key files (from ls): `IDb.cs`, `IColumnsDb.cs`, `IDbProvider.cs`, `IDbFactory.cs`,
    `DbProvider.cs`, `DbProviderExtensions.cs`, `DbNames.cs`, `ReadOnlyDb.cs`,
    `ReadOnlyDbProvider.cs`, `MemDb.cs`, `MemColumnsDb.cs`, `InMemoryWriteBatch.cs`,
    `InMemoryColumnBatch.cs`, `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`,
    `NullDb.cs`, `NullRocksDbFactory.cs`, pruning helpers (`PruningConfig.cs`, `PruningMode.cs`, `IPruningConfig.cs`),
    metrics (`Metrics.cs`), bloom/receipts columns helpers, and `SimpleFilePublicKeyDb.cs`.

## Voltaire primitives (from /Users/williamcory/voltaire/packages/voltaire-zig/src/)

- Exact APIs to use (no custom types):
  - `primitives/Transaction/Transaction.zig`: canonical tx structs (`LegacyTransaction`, `Eip2930Transaction`, `Eip1559Transaction`, `Eip4844Transaction`, `Eip7702Transaction`), helpers (`encode{Legacy,Eip1559,Eip4844}ForSigning`, `computeLegacyTransactionHash`, `encodeAccessList`).
  - `primitives/FeeMarket/fee_market.zig`: EIP-1559 math (`nextBaseFee`, `initialBaseFee`, `getEffectiveGasPrice`, `canIncludeTx`, constants `MIN_BASE_FEE`, `BASE_FEE_CHANGE_DENOMINATOR`, `ELASTICITY_MULTIPLIER`).
  - `primitives/Gas/Gas.zig`: `GasLimit`, `GasPrice` semantic wrappers.
  - `primitives/MaxFeePerGas/MaxFeePerGas.zig`, `primitives/MaxPriorityFeePerGas/MaxPriorityFeePerGas.zig`: typed fee caps/tips with safe ops.
  - `primitives/AccessList/` and `primitives/Address/`: access list items and addresses.
  - `primitives/Hash/`, `primitives/Rlp/`: hashing and RLP when needed (intake/serialization).
  - Optional for RPC-facing features later: `primitives/PendingTransactionFilter/`.

> Implementation rule: txpool must exclusively use these Voltaire types for txs, fees, addresses, and serialization. Do not introduce parallel fee/tx structs.

## Existing Zig code

- `client/txpool/pool.zig`: TxPoolConfig + TxPool vtable (pending_count, pending_blob_count) with tests.
- `client/txpool/sorter.zig`: Prioritization scaffolding for tip/max fee (to be wired to Voltaire FeeMarket).
- `client/txpool/limits.zig`: configurable limits mirrored from Nethermind.
- `src/host.zig`: HostInterface vtable for balance/code/storage/nonce; EVM inner_call bypasses host for nested calls.

Host integration notes (txpool → HostInterface):
- Use `getNonce(Address) u64` to derive expected sender nonce and enforce per-sender nonce gaps/promotion.
- Optionally read `getBalance(Address) u256` to pre-screen solvency vs. `gas_limit * effective_gas_price + value` (policy-dependent; mirror Nethermind’s semantics where feasible).

## Test fixtures (ethereum-tests/)

- Directories: `ABITests/`, `BasicTests/`, `BlockchainTests/`, `DifficultyTests/`,
  `EOFTests/`, `GenesisTests/`, `KeyStoreTests/`, `LegacyTests/`, `PoWTests/`,
  `RLPTests/`, `TransactionTests/`, `TrieTests/`.
- Likely txpool-relevant: `ethereum-tests/TransactionTests/`, `ethereum-tests/BasicTests/`,
  `ethereum-tests/RLPTests/` and fixture tarballs:
  `ethereum-tests/fixtures_blockchain_tests.tgz`, `ethereum-tests/fixtures_general_state_tests.tgz`.

`ethereum-tests/TransactionTests/` subdirs relevant for admission/validation:
- `ttEIP1559/`, `ttEIP2930/`, `ttGasPrice/`, `ttNonce/`, `ttSignature/`, `ttWrongRLP/`, `ttRSValue/`, `ttVValue/`.

These provide canonical vectors for signature validity, nonce handling, fee caps, and RLP shape that txpool intake must respect.
