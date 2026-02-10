# [pass 1/5] phase-5-txpool (Transaction Pool) — Context

This file gathers focused references to guide implementation of the Transaction Pool in Guillotine (Zig), following the repo’s constraints:
- Always use Voltaire primitives (no custom duplicate types)
- Always use existing guillotine-mini EVM (no reimplementation)
- Mirror Nethermind architecture idiomatically in Zig
- Prefer comptime dependency injection
- Write small, atomic, testable units

## Phase Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
Path: `prd/GUILLOTINE_CLIENT_PLAN.md` → “Phase 5: Transaction Pool (`phase-5-txpool`)
- Goal: Implement the transaction pool for pending transactions.
- Key Components:
  - `client/txpool/pool.zig` — Transaction pool core
  - `client/txpool/sorter.zig` — Priority sorting (by gas tip/price)
- Architectural Reference: `nethermind/src/Nethermind/Nethermind.TxPool/`

## Relevant Specs (from prd/ETHEREUM_SPECS_REFERENCE.md)
Path: `prd/ETHEREUM_SPECS_REFERENCE.md` → Phase 5 specs
- `EIPs/EIPS/eip-1559.md` — Fee market; defines base fee and `effective_gas_price` for inclusion policy
- `EIPs/EIPS/eip-2930.md` — Access lists; affects intrinsic gas and warm slots at tx start
- `EIPs/EIPS/eip-4844.md` — Blob transactions; blob gas accounting coexists with EIP-1559 base fee

Notes for txpool policy:
- Admission checks must validate type-specific static rules (signature, chain id, intrinsic gas, max fees relative to base fee, access lists format).
- Replacement rules must account for dynamic-fee semantics (e.g., bump thresholds evaluated on effective tip). Exact policy will mirror Nethermind and be configurable, but correctness is constrained by EIP-1559/4844.

## Nethermind Reference (DB module inventory)
Path: `nethermind/src/Nethermind/Nethermind.Db/`
Key files to understand storage/abstractions used elsewhere:
- `IDb.cs`, `IReadOnlyDb.cs`, `ITunableDb.cs` — DB interfaces
- `IDbProvider.cs`, `IReadOnlyDbProvider.cs`, `DbProvider.cs`, `DbProviderExtensions.cs` — Provider abstractions
- `DbNames.cs`, `MetadataDbKeys.cs` — Named column families/keys
- `RocksDbSettings.cs`, `CompressingDb.cs`, `RocksDbMergeEnumerator.cs` — RocksDB specifics
- `MemDb.cs`, `MemDbFactory.cs`, `InMemoryColumnBatch.cs`, `InMemoryWriteBatch.cs`, `MemColumnsDb.cs` — In-memory variants for tests
- `ReadOnlyDb.cs`, `ReadOnlyDbProvider.cs`, `NullDb.cs`, `NullRocksDbFactory.cs` — Special providers
- `ReceiptsColumns.cs`, `BlobTxsColumns.cs`, `Blooms/`, `FullPruning*/`, `SimpleFilePublicKeyDb.cs` — Columns and utilities

Purpose: Even though txpool is primarily memory-resident, persistence and indexing patterns follow these abstractions.

## Voltaire APIs (must-use primitives)
Root: `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/`
Key modules for txpool:
- Transactions & fees: `Transaction`, `AccessList`, `BaseFeePerGas`, `MaxFeePerGas`, `MaxPriorityFeePerGas`, `EffectiveGasPrice`, `FeeMarket`, `Gas`, `GasPrice`
- Identity & hashes: `Address`, `Hash`, `TransactionHash`, `Nonce`
- Encoding & validity: `Rlp`, `Hex`, `Signature`
- Blobs (EIP-4844): `Blob`
- Chain/fork helpers: `Hardfork`, `ForkTransition`, `Eips`

Do not introduce custom mirrors of these types. Reuse `primitives.*` consistently.

## Host Interface (existing EVM host adapter surface)
Path: `src/host.zig`
- `HostInterface` exposes external state access for EVM: `getBalance/setBalance`, `getCode/setCode`, `getStorage/setStorage`, `getNonce/setNonce` using `primitives.Address` and builtin `u256`.
- Note: Nested calls are handled internally by EVM and do not go through this host. Txpool should not depend on EVM internals; use primitives + chain state abstraction when validating admission (e.g., sender nonce, balance bounds for max upfront cost).

## Test Fixtures (ethereum-tests/) — useful paths
Root: `ethereum-tests/`
- `TransactionTests/ttEIP1559` — EIP-1559 transaction vectors
- `TransactionTests/ttEIP2930` — Access list transaction vectors
- `TransactionTests/ttGasPrice` — Gas price constraints
- `TransactionTests/ttNonce` — Nonce corner cases
- `TransactionTests/ttSignature` — Signature validation
- `TransactionTests/ttWrongRLP` — RLP decoding robustness
- `TrieTests/` — RLP/Trie helpers if needed for indexing
- `BlockchainTests/` — Integration context; not directly txpool, but useful for end-to-end

## Summary
- Goal: Implement `client/txpool/{pool.zig, sorter.zig}` per plan.
- Specs: EIP-1559, EIP-2930, EIP-4844 are the normative constraints for tx admission, pricing, and typed transactions.
- Architecture: Follow Nethermind module boundaries; DB abstractions inform indexing/caching patterns.
- Primitives: Rely exclusively on Voltaire primitives (`primitives.Transaction`, fee types, `Address`, `Nonce`, etc.).
- Host: `src/host.zig` gives current external state hooks; txpool validation will require world-state access for sender nonce and balance checks.
- Tests: Use `ethereum-tests/TransactionTests/*` for decoding/validation; add unit tests for pool policy (admission, replacement, eviction, sorting).
