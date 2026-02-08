# Context: Phase 5 - Transaction Pool (phase-5-txpool)

## Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Implement the transaction pool for pending transactions.
- Key components:
  - client/txpool/pool.zig - Transaction pool
  - client/txpool/sorter.zig - Priority sorting (by gas price/tip)
- Reference: nethermind/src/Nethermind/Nethermind.TxPool/

## Specs (from prd/ETHEREUM_SPECS_REFERENCE.md)
- EIP-1559 (fee market)
- EIP-2930 (access lists)
- EIP-4844 (blob transactions)
- Execution-specs transaction logic by fork:
  - execution-specs/src/ethereum/forks/berlin/transactions.py (EIP-2930 access lists)
  - execution-specs/src/ethereum/forks/london/transactions.py (EIP-1559 fee market + EIP-2930)
  - execution-specs/src/ethereum/forks/cancun/transactions.py (EIP-4844 blob tx)

## EIPs (local paths)
- EIPs/EIPS/eip-1559.md
- EIPs/EIPS/eip-2930.md
- EIPs/EIPS/eip-4844.md

## Nethermind Db Directory Listing (nethermind/src/Nethermind/Nethermind.Db/)
Key files noted from listing:
- DbProvider.cs, DbProviderExtensions.cs, DbExtensions.cs
- IDb.cs, IDbFactory.cs, IDbProvider.cs, IReadOnlyDb.cs, IReadOnlyDbProvider.cs, IColumnsDb.cs, IFullDb.cs, ITunableDb.cs
- MemDb.cs, MemDbFactory.cs, MemColumnsDb.cs, InMemoryWriteBatch.cs, InMemoryColumnBatch.cs
- ReadOnlyDb.cs, ReadOnlyDbProvider.cs, ReadOnlyColumnsDb.cs
- RocksDbSettings.cs, RocksDbMergeEnumerator.cs, NullDb.cs, NullRocksDbFactory.cs
- PruningConfig.cs, PruningMode.cs, FullPruning/*
- ReceiptsColumns.cs, BlobTxsColumns.cs, MetadataDbKeys.cs, DbNames.cs, Metrics.cs

## Voltaire Zig APIs (voltaire/packages/voltaire-zig/src/)
Relevant modules for txpool:
- primitives/Transaction/Transaction.zig (transaction types, encoding/signing/hash)
- primitives/FilterId/filter_id.zig (pending tx filters)
- primitives/CallTrace/call_trace.zig (trace types; may be used by debug APIs later)
- blockchain/*, state-manager/*, evm/* (core primitives and EVM integration)

## Existing Guillotine EVM Host Interface
- src/host.zig
  - HostInterface vtable for balance/code/storage/nonce access
  - Note: nested calls handled internally by EVM; host is minimal

## Ethereum Tests Fixtures (ethereum-tests/)
- ABITests/
- BasicTests/
- BlockchainTests/
- DifficultyTests/
- EOFTests/
- GenesisTests/
- JSONSchema/
- KeyStoreTests/
- LegacyTests/
- PoWTests/
- RLPTests/
- TransactionTests/
- TrieTests/
- fixtures_blockchain_tests.tgz
- fixtures_general_state_tests.tgz

## Summary
Collected the Phase 5 txpool goals, identified EIP-1559/2930/4844 spec references, and located execution-specs transaction files by fork. Listed Nethermind Db directory contents for architectural reference, noted Voltaire primitives (especially Transaction) as required APIs, captured existing EVM host interface path, and enumerated ethereum-tests fixture directories relevant for txpool validation.
