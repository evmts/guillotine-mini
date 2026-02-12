# [pass 1/5] phase-5-txpool (Transaction Pool) — Context

This document gathers focused references to implement the Transaction Pool following Ethereum specs, Voltaire primitives, and Nethermind architecture. It will guide small, atomic, testable Zig units with comptime DI, using the existing EVM in `src/` and Voltaire types.

## Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Implement the transaction pool for pending transactions.
- Key components: `client/txpool/pool.zig`, `client/txpool/sorter.zig`.
- Architectural reference: Nethermind `Nethermind.TxPool`.

Source: prd/GUILLOTINE_CLIENT_PLAN.md (Phase 5: Transaction Pool)

## Relevant Specs (from prd/ETHEREUM_SPECS_REFERENCE.md)
- EIPs impacting tx acceptance, pricing, and typing:
  - EIP-1559: fee market changes — base fee, max_fee_per_gas, max_priority_fee_per_gas
    - Path: `EIPs/EIPS/eip-1559.md`
  - EIP-2930: access lists — affects intrinsic gas and warm set
    - Path: `EIPs/EIPS/eip-2930.md`
  - EIP-4844: blob transactions — typed tx v3, blob gas and versioned hashes
    - Path: `EIPs/EIPS/eip-4844.md`
- Transaction validation and intrinsic cost (latest fork reference):
  - `execution-specs/src/ethereum/forks/cancun/transactions.py`

## Nethermind References
- Database abstractions (used by TxPool for persistence/metrics where applicable): `nethermind/src/Nethermind/Nethermind.Db/`
  - Key files:
    - `IDb.cs`, `IDbProvider.cs`, `DbProvider.cs` — DB provider abstractions
    - `ReadOnlyDb.cs`, `ReadOnlyDbProvider.cs` — read-only layers
    - `MemDb.cs`, `MemDbFactory.cs`, `InMemoryWriteBatch.cs` — in-memory implementations for tests
    - `RocksDbSettings.cs`, `CompressingDb.cs`, `IMergeOperator.cs` — RocksDB integration
    - `ReceiptsColumns.cs`, `BlobTxsColumns.cs`, `MetadataDbKeys.cs` — column families / keyspaces
    - `PruningConfig.cs`, `PruningMode.cs`, `FullPruning*` — pruning controls
- Architectural shape for TxPool (structural reference only): `nethermind/src/Nethermind/Nethermind.TxPool/` (not listed here; use repo for structure).

## Voltaire Zig APIs (must use; no custom duplicates)
Located at `/Users/williamcory/voltaire/packages/voltaire-zig/src/`.
- Primitives essential for TxPool logic:
  - `primitives/Transaction` — typed tx support (legacy, 2930, 1559, 4844, 7702)
  - `primitives/AccessList` — EIP-2930 list ops and gas costs
  - `primitives/EffectiveGasPrice` — EIP-1559 effective gas computation
  - `primitives/Gas`, `primitives/GasPrice`, `primitives/MaxFeePerGas`, `primitives/MaxPriorityFeePerGas`
  - `primitives/Hash`, `primitives/TransactionHash`, `primitives/Nonce`, `primitives/Address`
  - `primitives/Rlp` — encoding/decoding for tx serialization
  - `primitives/Blob`, `primitives/BaseFeePerGas` — EIP-4844 and base fee
  - `primitives/Receipt` — downstream integration checks
- Other modules present and available if needed: `blockchain/`, `evm/`, `jsonrpc/`, `crypto/`, `state-manager/`.

## Existing Zig Interfaces
- Host interface (used by EVM integration; not for nested calls): `src/host.zig`
  - `HostInterface` with vtable: `getBalance`, `setBalance`, `getCode`, `setCode`, `getStorage`, `setStorage`, `getNonce`, `setNonce`.
  - Uses Voltaire `Address` and u256 for balances/storage. Nested calls handled by EVM internally.

## Test Fixtures (ethereum-tests/)
- Transaction and encoding focused suites:
  - `ethereum-tests/TransactionTests/`
  - `ethereum-tests/RLPTests/`
- Additional context (not primary for txpool acceptance but useful indirectly):
  - `ethereum-tests/TrieTests/`, `ethereum-tests/BlockchainTests/`

## Notes and Constraints
- ALWAYS use Voltaire primitives for all types (Transaction, Fee fields, AccessList, Hash, Address, Nonce, Rlp, etc.).
- NEVER reimplement EVM. Integrate with existing engine in `src/`.
- Follow Nethermind’s structuring for TxPool (admission, replacement, per-sender queues, basefee-aware sorting), but implement idiomatically in Zig with comptime DI as in the EVM code.
- Validate transactions per `execution-specs` rules (intrinsic gas, nonce bounds, contract-creation size, typed tx prefixes) and EIPs above.
- Performance: prioritize zero/low-allocation paths; design data structures for O(log n) insertion/sorting by effective tip; leverage `EffectiveGasPrice` for ordering under EIP-1559.

