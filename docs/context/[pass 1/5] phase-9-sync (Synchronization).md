# [pass 1/5] phase-9-sync (Synchronization) — Context

## Phase Goal (source: `prd/GUILLOTINE_CLIENT_PLAN.md`)
- `Phase 9: Synchronization (phase-9-sync)` goal: implement chain synchronization strategies.
- Planned module boundaries:
  - `client/sync/full.zig` (full sync)
  - `client/sync/snap.zig` (snap sync)
  - `client/sync/manager.zig` (coordination)
- Structural reference: `nethermind/src/Nethermind/Nethermind.Synchronization/`.

## Specs To Read First (source: `prd/ETHEREUM_SPECS_REFERENCE.md`)
- `devp2p/caps/eth.md`
  - Status handshake is mandatory before other ETH messages.
  - Chain sync flow uses:
    - `GetBlockHeaders` / `BlockHeaders`
    - `GetBlockBodies` / `BlockBodies`
    - `GetReceipts` / `Receipts`
  - Propagation and sync interaction:
    - `NewBlockHashes`, `NewBlock`
    - `BlockRangeUpdate` (eth/69)
  - Request/response correlation for modern versions includes request ids (eth/66+).
- `devp2p/caps/snap.md`
  - Snapshot/state sync protocol is `snap/1`.
  - Sync algorithm and proofs are defined around:
    - `GetAccountRange` / `AccountRange`
    - `GetStorageRanges` / `StorageRanges`
    - `GetByteCodes` / `ByteCodes`
    - `GetTrieNodes` / `TrieNodes`
  - `snap` depends on `eth` for block/header context.
- Test references for this phase:
  - `hive/` sync tests
  - integration tests (client-level)

## Nethermind DB Inventory (source: `nethermind/src/Nethermind/Nethermind.Db/`)
Requested listing reviewed. Key files to mirror conceptually in Effect TS sync persistence design:
- `IDb.cs`
  - Core DB interface: name, multi-get, enumeration, read-only wrapper creation.
- `IDbProvider.cs`, `DbProvider.cs`
  - Central registry/resolution pattern for named DBs.
- `IColumnsDb.cs`, `ReceiptsColumns.cs`, `BlobTxsColumns.cs`
  - Column-family separation for typed data domains.
- `InMemoryWriteBatch.cs`, `InMemoryColumnBatch.cs`
  - Batch write semantics for high-throughput ingestion.
- `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `IReadOnlyDb.cs`, `IReadOnlyDbProvider.cs`
  - Read isolation and optional in-memory write overlay patterns.
- `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/*`, `FullPruningTrigger.cs`
  - Long-running sync retention/pruning controls.
- `MetadataDbKeys.cs`
  - Sync/progress metadata keys (e.g., finalized/safe pivots, barriers).
- `Metrics.cs`, `DbExtensions.cs`, `DbNames.cs`
  - Operational telemetry and canonical DB naming.

## Voltaire Zig API Surface (source: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`)
Top-level modules:
- `blockchain/`
- `crypto/`
- `evm/`
- `jsonrpc/`
- `precompiles/`
- `primitives/`
- `state-manager/`

Relevant exported APIs for sync/reference alignment:
- `blockchain/root.zig`
  - `BlockStore`
  - `ForkBlockCache`
  - `Blockchain`
- `state-manager/root.zig`
  - `StateManager`
  - `JournaledState`
  - `ForkBackend`
  - `AccountCache`, `StorageCache`, `ContractCache`
- `primitives/root.zig`
  - Core primitives used by sync/data flow:
    - `Address`, `Hash`, `Hex`, `Bytes`, `Bytes32`
    - `Block`, `BlockHeader`, `BlockBody`, `BlockHash`, `BlockNumber`
    - `Transaction`, `Receipt`, `Rlp`
    - `ForkId`, `ChainHead`, `PeerId`, `PeerInfo`, `SyncStatus`
    - `StateRoot`, `Proof`, `StorageProof`, `StateProof`

## Existing Host Interface (source: `src/host.zig`)
- `HostInterface` is a `ptr + vtable` contract with:
  - `getBalance`, `setBalance`
  - `getCode`, `setCode`
  - `getStorage`, `setStorage`
  - `getNonce`, `setNonce`
- Current note in file: nested EVM calls use internal call machinery, not this host abstraction.
- Implication for sync design: host is state access glue, not sync orchestration.

## Ethereum Test Fixture Paths (source: `ethereum-tests/`)
Primary fixture areas relevant to sync and block import:
- `ethereum-tests/BlockchainTests/ValidBlocks/`
- `ethereum-tests/BlockchainTests/InvalidBlocks/`
- `ethereum-tests/DifficultyTests/`
- `ethereum-tests/RLPTests/`
- `ethereum-tests/TransactionTests/`
- `ethereum-tests/TrieTests/`

Additional fixture/filler paths worth mapping:
- `ethereum-tests/src/BlockchainTestsFiller/ValidBlocks/`
- `ethereum-tests/src/BlockchainTestsFiller/InvalidBlocks/`
- `ethereum-tests/src/DifficultyTestsFiller/`
- `ethereum-tests/src/TransactionTestsFiller/`

## Implementation-Oriented Summary
- Use `eth` protocol for header/body/receipt acquisition and peer status alignment.
- Use `snap` protocol for state range syncing with proof verification.
- Mirror Nethermind separation of concerns:
  - strategy modules (`full`, `snap`)
  - coordinator (`manager`)
  - explicit progress metadata + pruning-aware persistence
- Keep data model grounded in Voltaire primitive types and existing guillotine host/EVM boundaries.
