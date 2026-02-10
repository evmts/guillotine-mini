# [pass 2/5] phase-9-sync (Synchronization)

## Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Implement chain synchronization strategies for the execution client.
- Planned components: `client/sync/full.zig`, `client/sync/snap.zig`, `client/sync/manager.zig`.
- Reference architecture: `nethermind/src/Nethermind/Nethermind.Synchronization/`.

## Specs (from prd/ETHEREUM_SPECS_REFERENCE.md + read spec files)
### `devp2p/caps/eth.md`
- Current protocol version is `eth/69`. Status exchange is required before session is active.
- Sync uses `GetBlockHeaders` + `GetBlockBodies`; receipts via `GetReceipts` during state sync.
- Message size hard limit is 16.7 MiB (RLPx); practical recommended limit ~10 MiB, plus per-message soft limits.
- State sync is no longer served by `eth` as of `eth/67`; uses `snap` instead.

### `devp2p/caps/snap.md`
- `snap/1` runs side-by-side with `eth`; it is a dependent protocol.
- Fetches contiguous account/storage ranges with Merkle proofs; supports bytecode batch retrieval.
- Serving peers must have recent state (only last ~128 blocks); if state root unavailable, response must be empty.
- Requests are byte-size limited, and responders must return at least one account when possible.

## Nethermind reference inventory (sync + DB)
- Sync reference path: `nethermind/src/Nethermind/Nethermind.Synchronization/`.
- DB path (listed): `nethermind/src/Nethermind/Nethermind.Db/`.
  - Key files for data access patterns and DB abstractions:
    - `DbProvider.cs`, `IDb.cs`, `IDbFactory.cs`, `IDbProvider.cs`, `IColumnsDb.cs`, `IFullDb.cs`.
    - `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `ReadOnlyDbProvider.cs`.
    - `MemDb.cs`, `MemColumnsDb.cs`, `MemDbFactory.cs`.
    - `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`.
    - `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/`.

## Voltaire APIs (from /Users/williamcory/voltaire/packages/voltaire-zig/src/)
- Top-level modules: `blockchain/`, `crypto/`, `evm/`, `jsonrpc/`, `precompiles/`, `primitives/`, `state-manager/`.
- Likely sync-relevant primitives (examples):
  - Chain and block types: `primitives/Block`, `BlockHeader`, `BlockBody`, `BlockHash`, `BlockNumber`, `Chain`, `ChainHead`.
  - State and receipts: `primitives/State`, `StateRoot`, `Receipt`, `Storage`, `StorageProof`, `StateProof`.
  - Transactions: `primitives/Transaction`, `TransactionHash`, `TransactionIndex`, `TransactionStatus`.
  - Network/sync metadata: `primitives/PeerId`, `PeerInfo`, `NodeInfo`, `NetworkId`, `ProtocolVersion`, `ForkId`, `SyncStatus`.
  - Encoding: `primitives/Rlp`, `Bytes`, `Hash`, `Hex`.

## Existing Zig host interface (src/host.zig)
- `HostInterface` is a minimal vtable-based host for EVM state access.
- Provides `get/set` for balance, code, storage, nonce; uses `primitives.Address`.
- Note in file: inner EVM nested calls are handled internally, not via `HostInterface`.

## Test fixtures and harnesses
- `ethereum-tests/` directories available: `ABITests`, `BasicTests`, `BlockchainTests`, `DifficultyTests`, `EOFTests`, `GenesisTests`, `KeyStoreTests`, `LegacyTests`, `PoWTests`, `RLPTests`, `TransactionTests`, `TrieTests`.
- `hive/` mentioned for devp2p/sync tests in `prd/ETHEREUM_SPECS_REFERENCE.md`.

## Notes for implementation pass
- For Phase 9, sync spans `eth` message exchange and `snap` state retrieval; ensure message-size and response-limit rules are enforced.
- Follow Nethermind module boundaries but implement idiomatically in Zig with comptime DI and Voltaire primitives only.
