# [pass 2/5] phase-5-txpool (Transaction Pool)

## Goal (from `prd/GUILLOTINE_CLIENT_PLAN.md`)

- Phase 5 goal: implement pending transaction pool behavior.
- Planned Zig references: `client/txpool/pool.zig` and `client/txpool/sorter.zig`.
- Structural reference module: `nethermind/src/Nethermind/Nethermind.TxPool/`.

## Relevant specs (from `prd/ETHEREUM_SPECS_REFERENCE.md` + direct files)

- `EIPs/EIPS/eip-1559.md`
  - Introduces type-2 transactions (`0x02`) and fee market fields `max_priority_fee_per_gas` + `max_fee_per_gas`.
  - Recommends ordering by effective tip and stable tie-breaking for same tip.
- `EIPs/EIPS/eip-2930.md`
  - Introduces type-1 transactions (`0x01`) and access list validation + intrinsic gas additions.
- `EIPs/EIPS/eip-4844.md`
  - Introduces blob transactions (`0x03`), separate blob fee market, and special mempool network representation.
  - Explicit mempool guidance: blob tx replacement bump recommendation and no automatic full rebroadcasting.
- `EIPs/EIPS/eip-2718.md`
  - Typed transaction envelope; tx type byte must be recognized and handled.
- `EIPs/EIPS/eip-7702.md`
  - Prague-era set-code transaction type (`0x04`) relevant for forward-compatible txpool admission checks.

- `execution-specs/src/ethereum/forks/london/transactions.py`
  - Canonical `validate_transaction`, `calculate_intrinsic_cost`, `recover_sender` for legacy/2930/1559.
- `execution-specs/src/ethereum/forks/cancun/transactions.py`
  - Extends validation for blob transactions and init-code size checks.
- `execution-specs/src/ethereum/forks/prague/transactions.py`
  - Extends validation for set-code transactions and calldata floor gas (`EIP-7623`) return shape.
- `devp2p/caps/eth.md`
  - Txpool gossip protocol: `Transactions (0x02)`, `NewPooledTransactionHashes (0x08)`,
    `GetPooledTransactions (0x09)`, `PooledTransactions (0x0a)`.
  - Admission baseline: recognized tx type, valid signature, intrinsic gas coverage, balance, nonce policy.

## Nethermind DB inventory (`nethermind/src/Nethermind/Nethermind.Db/`)

- Core DB abstractions:
  - `IDb.cs`, `IColumnsDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs`, `IDbFactory.cs`, `IDbProvider.cs`.
- Provider + naming:
  - `DbProvider.cs`, `DbProviderExtensions.cs`, `DbNames.cs`.
  - `DbNames.cs` includes `BlobTransactions` DB key used by txpool blob storage flows.
- Blob-related columns:
  - `BlobTxsColumns.cs` with `FullBlobTxs`, `LightBlobTxs`, `ProcessedTxs`.
- In-memory/test backends:
  - `MemDb.cs`, `MemColumnsDb.cs`, `InMemoryWriteBatch.cs`, `InMemoryColumnBatch.cs`, `NullDb.cs`.
- Read-only and operational DB wrappers:
  - `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `ReadOnlyDbProvider.cs`, `RocksDbSettings.cs`,
    `RocksDbMergeEnumerator.cs`, `CompressingDb.cs`, `DbExtensions.cs`, `Metrics.cs`.
- Supporting modules discovered:
  - `Blooms/*`, `FullPruning/*`, `ReceiptsColumns.cs`, `MetadataDbKeys.cs`, `SimpleFilePublicKeyDb.cs`.

## Nethermind txpool architecture anchors

- `nethermind/src/Nethermind/Nethermind.TxPool/ITxPool.cs`
  - Defines pending counts, grouped-by-sender queries, blob retrieval, submission/removal,
    gossip hooks, and nonce queries.
- `nethermind/src/Nethermind/Nethermind.TxPool/ITxValidator.cs`
  - Defines release-spec-aware well-formedness validation boundary.
- `nethermind/src/Nethermind/Nethermind.TxPool/BlobTxStorage.cs`
  - Uses `IColumnsDb<BlobTxsColumns>` for full/light/processed blob tx persistence and
    mempool-form RLP encoding.
- Additional relevant files:
  - `TxPool.cs`, `TxPoolConfig.cs`, `NonceManager.cs`, `TxBroadcaster.cs`,
    `SpecDrivenTxGossipPolicy.cs`, `TxPoolSender.cs`, `IBlobTxStorage.cs`.

## Voltaire Zig API inventory (`/Users/williamcory/voltaire/packages/voltaire-zig/src/`)

- Top-level modules present:
  - `blockchain/`, `crypto/`, `evm/`, `jsonrpc/`, `precompiles/`, `primitives/`, `state-manager/`.
- Txpool-relevant primitive APIs:
  - `primitives/root.zig` re-exports `Address`, `Hash`, `Hex`, `Transaction`, `AccessList`,
    `Authorization`, `Blob`, `FeeMarket`, `Gas`, `Nonce`, `TransactionHash`, `Rlp`.
  - `primitives/Transaction/Transaction.zig` defines legacy + typed tx structs
    (2930/1559/4844/7702) and signing/encoding helpers.
  - `primitives/FeeMarket/fee_market.zig` provides base-fee and effective-gas-price logic
    (`initialBaseFee`, `nextBaseFee`, `getEffectiveGasPrice`, `canIncludeTx`).
  - `primitives/PendingTransactionFilter/pending_transaction_filter.zig` is relevant for pending-tx RPC/filter flows.
- RPC surface already includes tx submission + pending filter methods:
  - `jsonrpc/eth/sendRawTransaction/eth_sendRawTransaction.zig`
  - `jsonrpc/eth/newPendingTransactionFilter/eth_newPendingTransactionFilter.zig`

## Existing guillotine-mini Zig reference

- `src/host.zig`
  - `HostInterface` vtable exposes state entry points: `getBalance`, `setBalance`,
    `getCode`, `setCode`, `getStorage`, `setStorage`, `getNonce`, `setNonce`.
  - Important note in file: nested EVM inner calls bypass this host interface; host is for
    external state access boundaries.

## Ethereum test fixture directories (`ethereum-tests/`)

- Root directories discovered:
  - `ABITests/`, `BasicTests/`, `BlockchainTests/`, `DifficultyTests/`, `EOFTests/`,
    `GenesisTests/`, `JSONSchema/`, `KeyStoreTests/`, `LegacyTests/`, `PoWTests/`,
    `RLPTests/`, `TransactionTests/`, `TrieTests/`, plus `src/*Filler` and docs/ansible tooling dirs.
- Txpool-focused fixture paths:
  - `ethereum-tests/TransactionTests/ttEIP1559`
  - `ethereum-tests/TransactionTests/ttEIP2930`
  - `ethereum-tests/TransactionTests/ttGasPrice`
  - `ethereum-tests/TransactionTests/ttNonce`
  - `ethereum-tests/TransactionTests/ttSignature`
  - `ethereum-tests/TransactionTests/ttWrongRLP`
  - `ethereum-tests/TransactionTests/ttRSValue`
  - `ethereum-tests/TransactionTests/ttVValue`
  - `ethereum-tests/RLPTests/RandomRLPTests`

## Implementation constraints to carry into Effect.ts

- Use `voltaire-effect/primitives` in TypeScript (`Address`, `Hash`, `Hex`, etc.); no custom parallel primitive types.
- Mirror Nethermind txpool boundaries as service interfaces, but implement with Effect idioms:
  `Context.Tag` services, `Layer` wiring, `Effect.gen`, typed `Data.TaggedError` failures.
- Keep txpool split into small services:
  - admission validation,
  - per-sender nonce queues,
  - price/tip sorting,
  - gossip inventory tracking,
  - blob sidecar-aware storage policy.
