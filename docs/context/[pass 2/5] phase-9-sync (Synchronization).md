# [pass 2/5] phase-9-sync (Synchronization)

## Phase goal (prd/GUILLOTINE_CLIENT_PLAN.md)
- Implement chain synchronization strategies.
- Key components: `client/sync/full.zig`, `client/sync/snap.zig`, `client/sync/manager.zig`.
- Reference architecture: `nethermind/src/Nethermind/Nethermind.Synchronization/`.

## Specs read (devp2p/ and EIPs/)
- `devp2p/caps/eth.md`: chain sync via GetBlockHeaders/GetBlockBodies/GetReceipts, header-first (skeleton + fill) strategy, message size limits (RLPx 16.7 MiB; eth practical ~10 MiB), status handshake required, snap sync moved out of eth after eth/67.
- `devp2p/caps/snap.md`: snap/1 state sync satellite to eth (must run both), account/storage range requests with Merkle proofs, responseBytes soft cap, must return at least one account if any exists, empty reply if root unknown (>128 blocks), dynamic snapshots requirement, self-healing via trie node retrieval.

## Nethermind DB reference (nethermind/src/Nethermind/Nethermind.Db/)
- Key files: `IDb.cs`, `IColumnsDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs`, `IDbFactory.cs`, `DbProvider.cs`, `DbProviderExtensions.cs`, `DbNames.cs`, `MemDb.cs`, `MemColumnsDb.cs`, `ReadOnlyDb.cs`, `RocksDbSettings.cs`, `NullDb.cs`, `ReceiptsColumns.cs`, `BlobTxsColumns.cs`, `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/`.
- Useful for understanding how Nethermind stores headers/bodies/receipts and pruning behaviors that affect sync guarantees.

## Voltaire APIs (voltaire/packages/voltaire-zig/src/)
- `primitives/BlockHeader/BlockHeader.zig`, `primitives/BlockBody/BlockBody.zig`, `primitives/Block/Block.zig`: block components used in header/body sync.
- `primitives/BlockHash/BlockHash.zig`, `primitives/BlockNumber/BlockNumber.zig`, `primitives/Hash/Hash.zig`, `primitives/Bytes32/Bytes32.zig`: identifiers for requests and validation.
- `primitives/Receipt/Receipt.zig`: receipts download during snap/fast sync.
- `primitives/StateRoot/StateRoot.zig`, `primitives/StateProof/StateProof.zig`, `primitives/StorageProof/StorageProof.zig`: snap range proofs and verification.
- `primitives/Chain/Chain.zig`, `primitives/ChainHead/ChainHead.zig`, `primitives/SyncStatus/SyncStatus.zig`: chain metadata and sync status reporting.
- `primitives/PeerId/PeerId.zig`, `primitives/PeerInfo/PeerInfo.zig`, `primitives/ProtocolVersion/ProtocolVersion.zig`: per-peer sync coordination.
- `primitives/Rlp/Rlp.zig`: encoding/decoding for eth/snap payloads.
- `state-manager/`: state access primitives for verifying snapshots and applying block execution.

## Existing Zig files
- `src/host.zig`: EVM HostInterface vtable (balance/code/storage/nonce getters/setters). EVM inner calls bypass HostInterface.

## Test fixtures (ethereum-tests/)
- Top-level dirs: `ABITests/`, `BasicTests/`, `BlockchainTests/`, `DifficultyTests/`, `EOFTests/`, `GenesisTests/`, `KeyStoreTests/`, `LegacyTests/`, `PoWTests/`, `RLPTests/`, `TransactionTests/`, `TrieTests/`.
- Sync-specific integration tests are expected under `hive/` (per prd/ETHEREUM_SPECS_REFERENCE.md).

## Notes for implementation
- Eth sync: must handshake Status before other messages; fetch headers (skeleton + fill), then bodies; validate bodies against header tx/ommers roots; download receipts if snap/fast sync.
- Snap sync: requires eth running in parallel; account/storage range replies must include Merkle proofs and are bounded by responseBytes; handle empty reply when root is unavailable (>128 blocks).
- Enforce eth/snap soft and hard message size limits; disconnect on oversized messages per spec guidance.
