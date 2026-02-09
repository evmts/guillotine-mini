# [Pass 1/5] Phase 9: Synchronization (Synchronization) - Implementation Context

## Phase Goal

Implement chain synchronization strategies.

**Key Components** (from plan):
- `client/sync/full.zig` - full sync
- `client/sync/snap.zig` - snap sync
- `client/sync/manager.zig` - sync coordination

**Reference Architecture**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.Synchronization/`
- devp2p specs: `devp2p/caps/eth.md`, `devp2p/caps/snap.md`

---

## 1. Spec References (Read First)

### ETH protocol chain/state sync
- `devp2p/caps/eth.md` - eth/69 protocol.
  - Session requires `Status` exchange before other messages.
  - Chain sync uses `GetBlockHeaders` (start by number or hash, `limit`, `skip`, `reverse`) and `GetBlockBodies`.
  - Header/body responses have recommended soft limits of 2 MiB; RLPx hard limit is 16.7 MiB; practical eth limit ~10 MiB.
  - State sync no longer uses eth after eth/67; state is fetched via `snap`.
  - Receipts are fetched with `GetReceipts` / `Receipts` (recommended soft limit 2 MiB).
  - eth/69 (EIP-7642, April 2025) adds `BlockRangeUpdate` and extends `Status` to include available block range.

### SNAP protocol (state snapshot sync)
- `devp2p/caps/snap.md` - snap/1 protocol (runs side-by-side with eth).
  - Snapshot sync retrieves contiguous account and storage ranges with Merkle proofs, then heals inconsistencies via trie node retrieval.
  - Data is ephemeral: peers should only serve state within ~128 recent blocks.
  - Accounts use a slim encoding (empty list for code hash and storage root when empty).
  - Request/response pairs:
    - `GetAccountRange` / `AccountRange` - contiguous accounts + boundary proofs.
    - `GetStorageRanges` / `StorageRanges` - storage slots for one or more accounts, proofs for partial ranges.
    - `GetByteCodes` / `ByteCodes` - contract bytecode by hash (response preserves request order).
    - `GetTrieNodes` / `TrieNodes` - trie node healing for inconsistent ranges.
  - Requests include `responseBytes` soft limits; peers must always respond (possibly empty).

---

## 2. Nethermind Reference (Synchronization)

Location: `nethermind/src/Nethermind/Nethermind.Synchronization/`

Key areas to mirror structurally:
- `FastSync/`, `SnapSync/`, `StateSync/` - sync strategy implementations
- `Blocks/`, `FastBlocks/`, `ParallelSync/` - header/body pipelines and concurrency
- `Peers/` - peer selection and reputation
- `SyncServer.cs`, `Synchronizer.cs`, `Sync.cs` - coordination and orchestration
- `Pivot.cs`, `ISyncPointers.cs` - pivot block and sync head tracking
- `Reporting/`, `Metrics.cs` - progress reporting and metrics

### Requested Listing: Nethermind DB Module Inventory
Location: `nethermind/src/Nethermind/Nethermind.Db/`

Key files (for cross-module reference):
- `IDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs` - core DB interfaces
- `IColumnsDb.cs`, `ITunableDb.cs` - column families and tuning
- `DbProvider.cs`, `IDbProvider.cs`, `IDbFactory.cs` - DB provider and factories
- `MemDb.cs`, `MemColumnsDb.cs`, `InMemoryWriteBatch.cs` - in-memory backends
- `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs` - read-only wrappers
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs` - RocksDB support
- `Metrics.cs` - DB metrics

---

## 3. Voltaire Primitives (Must Use)

Location: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`

Relevant primitives and modules for sync:
- `primitives/BlockHeader/`, `primitives/BlockBody/`, `primitives/BlockNumber/`, `primitives/BlockHash/`
- `primitives/Receipt/`, `primitives/Transaction/`, `primitives/StateRoot/`
- `primitives/SyncStatus/` - sync progress/state
- `primitives/PeerId/`, `primitives/PeerInfo/`, `primitives/ProtocolVersion/`
- `primitives/ChainId/`, `primitives/NetworkId/`
- `primitives/Rlp/`, `primitives/Bytes/`, `primitives/Bytes32/`, `primitives/Hash/`

Related Voltaire subsystems:
- `blockchain/BlockStore.zig`, `blockchain/Blockchain.zig`
- `state-manager/StateManager.zig`, `state-manager/JournaledState.zig`

---

## 4. Existing Zig EVM Integration Surface

### Host Interface
File: `src/host.zig`

- Defines `HostInterface` (ptr + vtable) for external state access.
- Vtable pattern is the reference for comptime DI-style polymorphism in Zig.

---

## 5. Test Fixtures and Sync Suites

Sync-related suites:
- `hive/` - sync integration tests

ethereum-tests inventory (requested listing):
- `ethereum-tests/ABITests/`
- `ethereum-tests/BasicTests/`
- `ethereum-tests/BlockchainTests/`
- `ethereum-tests/DifficultyTests/`
- `ethereum-tests/EOFTests/`
- `ethereum-tests/GenesisTests/`
- `ethereum-tests/JSONSchema/`
- `ethereum-tests/KeyStoreTests/`
- `ethereum-tests/LegacyTests/`
- `ethereum-tests/PoWTests/`
- `ethereum-tests/RLPTests/`
- `ethereum-tests/TransactionTests/`
- `ethereum-tests/TrieTests/`

Fixture tarballs:
- `ethereum-tests/fixtures_blockchain_tests.tgz`
- `ethereum-tests/fixtures_general_state_tests.tgz`

---

## Summary

Collected phase-9 synchronization goals and Zig module targets, reviewed eth and snap sync specs (headers/bodies/receipts, block range updates, snapshot account/storage ranges with proofs), mapped Nethermind's synchronization module structure, captured the requested Nethermind DB inventory, listed relevant Voltaire primitives and subsystems, noted the HostInterface vtable DI pattern, and recorded hive + ethereum-tests fixture locations.
