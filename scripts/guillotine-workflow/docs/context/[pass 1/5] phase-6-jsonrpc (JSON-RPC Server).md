# Context: Phase 6 - JSON-RPC Server (phase-6-jsonrpc)

## Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Implement the Ethereum JSON-RPC API.
- Key components:
  - client/rpc/server.zig - HTTP/WebSocket server
  - client/rpc/eth.zig - eth_* methods
  - client/rpc/net.zig - net_* methods
  - client/rpc/web3.zig - web3_* methods
- References:
  - nethermind/src/Nethermind/Nethermind.JsonRpc/
  - execution-apis/src/eth/

## Specs (from prd/ETHEREUM_SPECS_REFERENCE.md)
- execution-apis/src/eth/ (OpenRPC spec)
  - block.yaml
  - client.yaml
  - execute.yaml
  - fee_market.yaml
  - filter.yaml
  - sign.yaml
  - state.yaml
  - submit.yaml
  - transaction.yaml
- EIP-1474 (Remote procedure call specification)

## EIPs (local paths)
- EIPs/EIPS/eip-1474.md

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
Relevant modules for JSON-RPC:
- jsonrpc/JsonRpc.zig (core JSON-RPC types/helpers)
- jsonrpc/types.zig (shared JSON-RPC types)
- jsonrpc/eth/* (eth_* method types)
- jsonrpc/engine/* (engine_* types; adjacent API)
- jsonrpc/root.zig (module root)
- primitives/*, blockchain/*, state-manager/*, evm/* (core primitives and EVM integration)

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
Collected the Phase 6 JSON-RPC goals, identified the execution-apis OpenRPC specs and EIP-1474 as the primary spec references, listed Nethermind Db directory contents for architectural grounding, noted Voltaire JSON-RPC modules and adjacent primitives, captured the existing EVM host interface path, and enumerated ethereum-tests fixture directories relevant for RPC validation.
