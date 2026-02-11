# Context - [pass 2/5] Phase 4: Block Chain Management

## 1) Phase Goal (from `prd/GUILLOTINE_CLIENT_PLAN.md`)
- Goal: manage blockchain structure and block validation.
- Planned components:
  - `client/blockchain/chain.zig` - chain management (canonical mapping, head updates, reorg handling).
  - `client/blockchain/validator.zig` - block/header/body validation.
- Architecture references:
  - `nethermind/src/Nethermind/Nethermind.Blockchain/`
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/`
- Primary fixture root: `ethereum-tests/BlockchainTests/`

## 2) Spec References (from `prd/ETHEREUM_SPECS_REFERENCE.md` + direct spec files)

### 2.1 Execution-specs block processing entrypoints
These are the canonical validation entrypoints to mirror:
- `execution-specs/src/ethereum/forks/frontier/fork.py`
- `execution-specs/src/ethereum/forks/london/fork.py`
- `execution-specs/src/ethereum/forks/paris/fork.py`
- `execution-specs/src/ethereum/forks/shanghai/fork.py`
- `execution-specs/src/ethereum/forks/cancun/fork.py`
- `execution-specs/src/ethereum/forks/prague/fork.py`
- `execution-specs/src/ethereum/forks/osaka/fork.py`

Common function anchors across fork specs:
- `state_transition(chain, block)`
- `validate_header(chain, header)`
- `apply_body(...)`
- `get_last_256_block_hashes(chain)`
- `calculate_base_fee_per_gas(...)` (post-London forks)

### 2.2 EIPs relevant to chain/header validation
- `EIPs/EIPS/eip-1559.md` - base fee and London header rules.
- `EIPs/EIPS/eip-3675.md` - Merge transition constraints.
- `EIPs/EIPS/eip-4399.md` - `PREVRANDAO` semantics in post-Merge headers/env.
- `EIPs/EIPS/eip-4844.md` - blob gas accounting and Cancun block/header fields.
- `EIPs/EIPS/eip-4788.md` - beacon root system contract integration.

### 2.3 devp2p relevance for chain management context
- `devp2p/caps/eth.md`
  - Header/body sync flows (`GetBlockHeaders`, `GetBlockBodies`, receipts).
  - Header-chain validity constraints (parent linkage, gas/time bounds, fork-specific header fields).
  - Useful for external sync assumptions; local validation remains execution-specs authoritative.

## 3) Nethermind Reference Inventory

### 3.1 `nethermind/src/Nethermind/Nethermind.Db/` key files
Core abstractions and providers:
- `IDb.cs`, `IColumnsDb.cs`, `IReadOnlyDb.cs`
- `IDbProvider.cs`, `DbProvider.cs`, `ReadOnlyDbProvider.cs`
- `DbNames.cs`, `DbExtensions.cs`

In-memory/testing implementations:
- `MemDb.cs`, `MemColumnsDb.cs`, `MemDbFactory.cs`
- `InMemoryWriteBatch.cs`, `InMemoryColumnBatch.cs`
- `NullDb.cs`

Operational concerns:
- `CompressingDb.cs`
- `PruningConfig.cs`, `PruningMode.cs`, `IPruningConfig.cs`
- `FullPruning/` (triggering and full-prune workflows)
- `Metrics.cs`

Domain DB columns:
- `BlobTxsColumns.cs`
- `ReceiptsColumns.cs`
- `MetadataDbKeys.cs`

### 3.2 `nethermind/src/Nethermind/Nethermind.Blockchain/` key files
Chain structure and canonicality:
- `BlockTree.cs`
- `BlockTree.Initializer.cs`
- `BlockTreeOverlay.cs`
- `ReadOnlyBlockTree.cs`
- `IBlockTree.cs`
- `AddBlockResult.cs`

Stores and caches:
- `Blocks/BlockStore.cs`
- `Headers/HeaderStore.cs`
- `BlockhashCache.cs`
- `BlockhashProvider.cs`

Genesis/finalization/pruning integration:
- `GenesisBuilder.cs`
- `IBlockFinalizationManager.cs`
- `ManualFinalizationManager.cs`
- `ReceiptCanonicalityMonitor.cs`
- `FullPruning/FullPruner.cs`

## 4) Voltaire Zig APIs (`/Users/williamcory/voltaire/packages/voltaire-zig/src/`)
Top-level modules present:
- `blockchain/`, `state-manager/`, `evm/`, `primitives/`, `jsonrpc/`, `crypto/`, `precompiles/`, `c_api.zig`

Phase-4 relevant blockchain APIs:
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/Blockchain.zig`
  - Unified read flow: local `BlockStore` then optional `ForkBlockCache`.
  - Write flow: local store only (`putBlock`, `setCanonicalHead`).
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/BlockStore.zig`
  - Canonical chain mapping and orphan handling primitives.
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/ForkBlockCache.zig`
  - Remote fetch/caching for forked historical reads.
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/root.zig`
  - Re-exports: `BlockStore`, `ForkBlockCache`, `Blockchain`.

Relevant primitive modules to rely on (no custom types):
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/`
  - `Block`, `BlockHeader`, `Hash`, `Address`, transaction/body-related primitives.

## 5) Existing guillotine-mini Host Interface (`src/host.zig`)
`HostInterface` provides vtable accessors for:
- `getBalance` / `setBalance`
- `getCode` / `setCode`
- `getStorage` / `setStorage`
- `getNonce` / `setNonce`

Important note in file:
- Nested call execution is handled by `EVM.inner_call`; `HostInterface` is for external state access.

Phase-4 implication:
- Keep chain/header validation decoupled from host internals; integrate execution/state transitions through existing EVM/state services, not direct host hacks.

## 6) Test Fixture Paths

Primary blockchain fixtures:
- `ethereum-tests/BlockchainTests/ValidBlocks/`
  - `bcBlockGasLimitTest`
  - `bcEIP1559`
  - `bcEIP3675`
  - `bcEIP4844-blobtransactions`
  - `bcStateTests`
  - `bcForkStressTest`
  - `bcRandomBlockhashTest`
- `ethereum-tests/BlockchainTests/InvalidBlocks/`
  - `bcBlockGasLimitTest`
  - `bcEIP1559`
  - `bcEIP3675`
  - `bcInvalidHeaderTest`
  - `bcMultiChainTest`
  - `bcStateTests`
  - `bcUncleHeaderValidity`
  - `bcUncleSpecialTests`
  - `bcUncleTest`
  - `bc4895-withdrawals`

Filler source roots:
- `ethereum-tests/src/BlockchainTestsFiller/ValidBlocks/`
- `ethereum-tests/src/BlockchainTestsFiller/InvalidBlocks/`

Execution-spec-tests status in this checkout:
- `execution-spec-tests/fixtures/` exists, but no `blockchain_tests` directory is currently present here.
- Continue using `ethereum-tests/BlockchainTests/` as primary block-chain fixture source for this phase.

## 7) Implementation Guidance for Next Step
- Mirror Nethermind boundaries (`chain` orchestration vs `validator`) but implement idiomatically for this codebase.
- Use Voltaire blockchain primitives/modules for block storage and canonical chain operations instead of inventing new storage semantics.
- Treat execution-specs `fork.py` functions as behavioral source of truth for header/body validation logic.
