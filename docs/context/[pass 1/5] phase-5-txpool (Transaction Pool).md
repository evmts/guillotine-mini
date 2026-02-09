# [pass 1/5] phase-5-txpool (Transaction Pool) — Context

## Goals (from `prd/GUILLOTINE_CLIENT_PLAN.md`)
- Implement transaction pool for pending transactions.
- Core components:
  - `client/txpool/pool.zig`
  - `client/txpool/sorter.zig` (priority sorting by gas price/tip)
- Structural reference: `nethermind/src/Nethermind/Nethermind.TxPool/` (architecture only; Zig idioms + Voltaire primitives).

## Spec References (from `prd/ETHEREUM_SPECS_REFERENCE.md` + direct reads)
- EIP-1559 fee market (type-2 tx, base fee, max fee, priority fee): `EIPs/EIPS/eip-1559.md`.
- EIP-2930 access lists (type-1 tx + access list costs/validation): `EIPs/EIPS/eip-2930.md`.
- EIP-4844 blob transactions (type-3 tx + blob gas pricing + versioned hashes): `EIPs/EIPS/eip-4844.md`.
- Execution-specs transaction model (Cancun fork includes legacy + 2930 + 1559 + 4844): `execution-specs/src/ethereum/forks/cancun/transactions.py`.

## Nethermind DB layer (requested listing)
Directory: `nethermind/src/Nethermind/Nethermind.Db/`
Key files noted:
- `IDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs`, `IColumnsDb.cs`, `ITunableDb.cs` (core DB interfaces)
- `DbProvider.cs`, `IDbProvider.cs`, `IReadOnlyDbProvider.cs` (provider abstraction)
- `MemDb.cs`, `MemColumnsDb.cs`, `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs` (in-memory + read-only variants)
- `DbNames.cs`, `MetadataDbKeys.cs`, `Metrics.cs` (naming/metrics/metadata)
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs` (RocksDB wiring)
- `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/*` (pruning config/flows)

## Voltaire primitives (txpool-relevant candidates)
Root: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
Likely txpool APIs (from `primitives/` listing):
- `primitives/Transaction`, `primitives/TransactionHash`, `primitives/TransactionStatus`
- `primitives/AccessList`
- `primitives/GasPrice`, `primitives/MaxFeePerGas`, `primitives/MaxPriorityFeePerGas`, `primitives/BaseFeePerGas`, `primitives/EffectiveGasPrice`
- `primitives/Nonce`, `primitives/ChainId`, `primitives/Address`, `primitives/Signature`
- `primitives/Blob`, `primitives/Bytes`, `primitives/Bytes32`, `primitives/Hash`
- `primitives/FeeMarket`, `primitives/Gas`, `primitives/GasUsed`, `primitives/GasEstimate`

## Existing EVM Host interface
File: `src/host.zig`
- `HostInterface` is a minimal vtable-based host for external state access.
- Not used for nested calls (EVM handles nested calls internally).
- Functions: get/set balance, code, storage, nonce.

## Ethereum test fixtures
Top-level directories under `ethereum-tests/`:
- `TransactionTests/` (transaction validity/encoding fixtures)
- `BlockchainTests/`
- `BasicTests/`, `LegacyTests/`, `RLPTests/`, `TrieTests/`, `EOFTests/`
- Bundled fixtures: `fixtures_blockchain_tests.tgz`, `fixtures_general_state_tests.tgz`

## Notes for phase-5 implementation
- Txpool needs to handle legacy, EIP-2930, EIP-1559, and EIP-4844 transaction types (see EIP docs + Cancun tx model).
- Fee/priority sorting should align with EIP-1559 semantics (effective tip, max fee vs base fee) and EIP-4844 blob fee constraints.
- Must use Voltaire transaction/fee primitives; no custom transaction structs.
