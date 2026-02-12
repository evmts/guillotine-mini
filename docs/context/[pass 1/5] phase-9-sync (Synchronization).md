# [pass 1/5] phase-9-sync (Synchronization) — Context

## Phase Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Implement chain synchronization strategies: Full sync (`client/sync/full.zig`), Snap sync (`client/sync/snap.zig`), and a Sync manager (`client/sync/manager.zig`).
- Mirror Nethermind structure but implement idiomatically in Zig.

## Relevant Specs (from prd/ETHEREUM_SPECS_REFERENCE.md)
- devp2p: `devp2p/caps/eth.md` (block/header exchange).
- devp2p: `devp2p/caps/snap.md` (snap/1 protocol, range/account/storage proofs).
- Additional context: `devp2p/rlpx.md` (transport) and `devp2p/discv4.md` / `devp2p/discv5/discv5.md` (discovery).
- Tests guidance: `hive/` sync tests; integration tests at node level.

## Nethermind Reference (nethermind/src/Nethermind/Nethermind.Db/)
Key files to mirror concepts and naming (do NOT reimplement in Zig; use as structure reference):
- Interfaces: `IDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs`, `IColumnsDb.cs`, `ITunableDb.cs`, `IMergeOperator.cs`, `IDbFactory.cs`, `IDbProvider.cs`, `IReadOnlyDbProvider.cs`.
- Providers/DBs: `DbProvider.cs`, `ReadOnlyDbProvider.cs`, `ReadOnlyDb.cs`, `MemDb.cs`, `MemColumnsDb.cs`, `NullDb.cs`, `NullRocksDbFactory.cs`, `CompressingDb.cs`.
- Settings/Config: `RocksDbSettings.cs`, `PruningConfig.cs`, `PruningMode.cs`, `FullPruningCompletionBehavior.cs`, `FullPruningTrigger.cs`, folder `FullPruning/`.
- Columns/Keys/Utils: `MetadataDbKeys.cs`, `ReceiptsColumns.cs`, `BlobTxsColumns.cs`, `DbExtensions.cs`, `DbProviderExtensions.cs`, `Metrics.cs`, `RocksDbMergeEnumerator.cs`, folder `Blooms/`.

These inform DB abstractions and naming used downstream by Synchronization modules in Nethermind (`Nethermind.Synchronization`).

## Voltaire Zig APIs (voltaire/packages/voltaire-zig/src/)
Prefer and reuse these primitives and modules during sync implementation:
- Primitives: `primitives/BlockHeader`, `primitives/Block`, `primitives/BlockHash`, `primitives/BlockNumber`, `primitives/Chain`, `primitives/ChainHead`, `primitives/Hash`, `primitives/Uint` (e.g., `u256`), `primitives/Receipt`, `primitives/Transaction`, `primitives/SyncStatus`.
- Blockchain: `blockchain/Blockchain.zig`, `blockchain/BlockStore.zig`, `blockchain/ForkBlockCache.zig` (use for header chain and side forks).
- Crypto/RLP: `crypto/*` and `primitives/Rlp/*` for encoding/decoding headers, bodies, receipts.
- State Manager (as needed): `state-manager/` for accessing state roots and proofs during snap sync validation.

Avoid custom types that duplicate the above. All IDs, hashes, numbers must use Voltaire primitives.

## Existing Zig Host Interface (src/host.zig)
- `HostInterface` uses a comptime vtable with methods: `getBalance(Address) u256`, `setBalance(Address, u256)`, `getCode(Address) []const u8`, `setCode(Address, []const u8)`, `getStorage(Address, u256) u256`, `setStorage(Address, u256, u256)`, `getNonce(Address) u64`, `setNonce(Address, u64)`.
- Uses Voltaire `Address`. Nested calls are handled internally by the EVM (`inner_call`), not via this host.
- Sync code must not modify EVM; instead, adapt world-state or storage layers to satisfy HostInterface and Voltaire Blockchain APIs.

## ethereum-tests Directories (fixtures)
Primary directories available for cross-checking state/block rules once sync downloads data:
- `ethereum-tests/BlockchainTests/` (blockchain validation vectors).
- `ethereum-tests/TrieTests/` (trie behavior).
- `ethereum-tests/TransactionTests/` (transaction parsing).
- `ethereum-tests/EOFTests/`, `ethereum-tests/DifficultyTests/`, `ethereum-tests/GenesisTests/` (misc).
- Compressed general state fixtures: `ethereum-tests/fixtures_general_state_tests.tgz`.

Note: Phase-9 relies more on `hive/` sync tests and integration; ethereum-tests remain useful for validating decoded payloads and post-download verification.

## Pointers and Next Steps for Phase-9
- Read `devp2p/caps/eth.md` header/body exchange flow (GetBlockHeaders, GetBlockBodies, NewBlockHeaders, etc.).
- Read `devp2p/caps/snap.md` sections on account/storage range proofs (GetAccountRange / GetStorageRanges / GetByteCodes / GetTrieNodes).
- Map Nethermind Synchronization architecture to Zig modules: `client/sync/manager.zig`, `client/sync/full.zig`, `client/sync/snap.zig`.
- Reuse Voltaire `blockchain/BlockStore.zig` and `ForkBlockCache.zig` for header chain and side forks; store minimal state for fast validation.
- Ensure all new public functions have unit tests; add integration tests that mock peer responses for deterministic sync flows.
