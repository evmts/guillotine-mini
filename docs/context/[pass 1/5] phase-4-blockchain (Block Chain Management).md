# [Pass 1/5] Phase 4: Block Chain Management - Context

## Phase Goal (from `prd/GUILLOTINE_CLIENT_PLAN.md`)
Manage block chain structure and validation.

Planned components:
- `client/blockchain/chain.zig` - chain management
- `client/blockchain/validator.zig` - block validation

Primary structural references:
- `nethermind/src/Nethermind/Nethermind.Blockchain/`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/`

Primary fixture set:
- `ethereum-tests/BlockchainTests/`

## Spec References (from `prd/ETHEREUM_SPECS_REFERENCE.md`)
Authoritative execution-layer references for this phase:
- `execution-specs/src/ethereum/forks/*/fork.py` - block validation + state transition
- `execution-specs/src/ethereum/forks/prague/fork.py` - current fork reference with `state_transition`, `validate_header`, `apply_body`, `check_transaction`, `check_gas_limit`
- `execution-specs/src/ethereum/forks/cancun/fork.py` - prior fork reference for same validation flow

Execution-spec tests / fixtures:
- `execution-spec-tests/fixtures/blockchain_tests` (symlink in this workspace)

Yellow Paper note:
- `yellowpaper/` exists in repo but no local paper file is present in this checkout, so Section 11 could not be inspected directly here.

## Nethermind DB Reference Snapshot
Listed directory:
- `nethermind/src/Nethermind/Nethermind.Db/`

Key files/modules to mirror DB boundaries when implementing chain persistence:
- Core DB contracts: `IDb.cs`, `IDbProvider.cs`, `IReadOnlyDb.cs`, `IFullDb.cs`, `IColumnsDb.cs`, `ITunableDb.cs`
- Provider + naming: `DbProvider.cs`, `DbProviderExtensions.cs`, `DbNames.cs`, `MetadataDbKeys.cs`
- Backend adapters: `MemDb.cs`, `MemDbFactory.cs`, `MemColumnsDb.cs`, `NullDb.cs`, `NullRocksDbFactory.cs`, `RocksDbSettings.cs`
- Read-only wrappers: `ReadOnlyDb.cs`, `ReadOnlyDbProvider.cs`, `ReadOnlyColumnsDb.cs`
- Pruning: `IPruningConfig.cs`, `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/FullPruningDb.cs`, `FullPruning/FullPruningInnerDbFactory.cs`
- Column families / specialized storage: `ReceiptsColumns.cs`, `BlobTxsColumns.cs`, `Blooms/BloomStorage.cs`
- Misc infrastructure: `CompressingDb.cs`, `RocksDbMergeEnumerator.cs`, `Metrics.cs`

## Voltaire Zig APIs (`/Users/williamcory/voltaire/packages/voltaire-zig/src/`)
Top-level modules observed:
- `blockchain/`, `crypto/`, `evm/`, `jsonrpc/`, `precompiles/`, `primitives/`, `state-manager/`, `root.zig`, `c_api.zig`, `log.zig`

Blockchain module files:
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/root.zig`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/Blockchain.zig`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/BlockStore.zig`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/ForkBlockCache.zig`
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/c_api.zig`

Relevant exported APIs to mirror at the Effect layer:
- `blockchain.root`: `BlockStore`, `ForkBlockCache`, `Blockchain`
- `BlockStore`: `init`, `deinit`, `getBlock`, `getBlockByNumber`, `getCanonicalHash`, `hasBlock`, `isOrphan`, `putBlock`, `setCanonicalHead`, `getHeadBlockNumber`, `blockCount`, `orphanCount`, `canonicalChainLength`
- `Blockchain`: `init`, `deinit`, `getBlockByHash`, `getBlockByNumber`, `getCanonicalHash`, `hasBlock`, `getHeadBlockNumber`, `putBlock`, `setCanonicalHead`, `localBlockCount`, `orphanCount`, `canonicalChainLength`, `isForkBlock`
- `ForkBlockCache`: `init`, `deinit`, `isForkBlock`, `getBlockByNumber`, `getBlockByHash`, `peekNextRequest`, `nextRequest`, `continueRequest`, `cacheSize`, `isCached`

## Existing Zig Host Interface (`src/host.zig`)
Observed host contract used by EVM-facing state access:
- `HostInterface` vtable methods:
  - `getBalance` / `setBalance`
  - `getCode` / `setCode`
  - `getStorage` / `setStorage`
  - `getNonce` / `setNonce`

Important behavior note in file:
- Nested calls are handled directly by `EVM.inner_call`; this host interface is a minimal external-state adapter.

## Ethereum Test Fixture Paths
Top-level test directories (`ethereum-tests/`):
- `ABITests`, `BasicTests`, `BlockchainTests`, `DifficultyTests`, `EOFTests`, `GenesisTests`, `KeyStoreTests`, `LegacyTests`, `PoWTests`, `RLPTests`, `TransactionTests`, `TrieTests`

Phase-4 relevant blockchain fixture paths:
- `ethereum-tests/BlockchainTests/ValidBlocks/`
- `ethereum-tests/BlockchainTests/InvalidBlocks/`
- `ethereum-tests/BlockchainTests/ValidBlocks/bcEIP1559/`
- `ethereum-tests/BlockchainTests/ValidBlocks/bcEIP3675/`
- `ethereum-tests/BlockchainTests/ValidBlocks/bcEIP4844-blobtransactions/`
- `ethereum-tests/BlockchainTests/InvalidBlocks/bcInvalidHeaderTest/`
- `ethereum-tests/BlockchainTests/InvalidBlocks/bcEIP1559/`
- `ethereum-tests/BlockchainTests/InvalidBlocks/bcEIP3675/`

Execution-spec fixture linkage in this checkout:
- `execution-spec-tests/fixtures/blockchain_tests -> /Users/williamcory/guillotine-mini/ethereum-tests/BlockchainTests`

## Summary
This pass captured the exact Phase-4 goal, authoritative execution-spec entry points for block validation, Nethermind DB contracts to mirror storage module boundaries, concrete Voltaire blockchain APIs to wrap/reimplement in Effect, host interface constraints from `src/host.zig`, and the local blockchain test fixture paths available for validation.
