# [pass 1/5] Phase 4 — Block Chain Management

Purpose: establish chain data structures and validation flow (structure, header checks, body execution wiring) using Voltaire primitives and guillotine-mini EVM, with Nethermind as architectural reference.

## Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Manage the block chain structure and validation.
- Implement:
  - `client/blockchain/chain.zig` — chain management (canonical head, fork choice input surface, reorg handling scaffolding).
  - `client/blockchain/validator.zig` — block/header validation against spec; integrate with EVM for body execution.
- Reference modules: `nethermind/src/Nethermind/Nethermind.Blockchain/`, Voltaire blockchain primitives.
- Test fixtures: `ethereum-tests/BlockchainTests/`.

## Spec References (from prd/ETHEREUM_SPECS_REFERENCE.md)
- Block validation entry points:
  - `execution-specs/src/ethereum/forks/*/fork.py` (validate_header, state_transition, validate_ommers, PoW for pre-merge).
  - Yellow Paper §11 “Block Finalization”.
- Supporting spec components frequently used during validation:
  - `execution-specs/src/ethereum/forks/*/blocks.py` (Block/Header types),
  - `.../state.py` (state_root, balances),
  - `.../transactions.py` (receipt roots, tx validation),
  - `.../bloom.py` (logs bloom),
  - `.../trie.py` (root calculations).
- Fixture suites:
  - `ethereum-tests/BlockchainTests/{ValidBlocks,InvalidBlocks}`
  - `execution-spec-tests/fixtures/blockchain_tests/{ValidBlocks,InvalidBlocks}`

## Nethermind Reference (Nethermind.Db focus per step)
Path: `nethermind/src/Nethermind/Nethermind.Db/`
- Key abstractions and helpers to mirror conceptually in Zig (storage layer behind chain index/headers):
  - Interfaces: `IDb.cs`, `IColumnsDb.cs`, `IFullDb.cs`, `IReadOnlyDb.cs`, `IDbFactory.cs`, `IDbProvider.cs`, `IReadOnlyDbProvider.cs`, `ITunableDb.cs`, `IMergeOperator.cs`.
  - Providers/impls: `DbProvider.cs`, `DbProviderExtensions.cs`, `ReadOnlyDb.cs`, `ReadOnlyDbProvider.cs`, `MemDb.cs`, `MemDbFactory.cs`, `NullDb.cs`, `CompressingDb.cs`.
  - RocksDB config: `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`, `NullRocksDbFactory.cs`.
  - Pruning & meta: `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/`, `FullPruningTrigger.cs`, `FullPruningCompletionBehavior.cs`, `MetadataDbKeys.cs`, `Metrics.cs`, `DbExtensions.cs`, `DbNames.cs`.
  - Columns examples: `ReceiptsColumns.cs`, `BlobTxsColumns.cs`, `Blooms/`.
Notes:
- For Phase 4, plan chain data storage with column families (headers by hash, total difficulty by hash/number, bodies by hash, canonical index by number→hash), but use Voltaire primitives for all keys/values and our Phase 0 DB adapter when integrating.

## Voltaire Zig APIs (must-use primitives and blockchain helpers)
Base path: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- `blockchain/Blockchain.zig` — canonical chain orchestration surface.
- `blockchain/BlockStore.zig` — block persistence abstraction.
- `blockchain/ForkBlockCache.zig` — fork-aware caching.
- `primitives/` types to prefer everywhere:
  - `Block`, `BlockHeader`, `BlockBody`, `Uncle`, `Receipt`, `Transaction`.
  - `Hash`, `BlockHash`, `StateRoot`, `Bytes32`, `BloomFilter`.
  - `Gas`, `GasUsed`, `BaseFeePerGas`, `ChainId`, `BlockNumber`, `Nonce`.
  - `Rlp` utilities (`primitives/Rlp`).
- `state-manager/` — for state-root and account interactions surfaced via Host/EVM integration.

## Host Interface (src/host.zig) summary
Path: `src/host.zig`
- Minimal external state interface for EVM integration:
  - Balance/code/storage/nonce getters and setters via `HostInterface.VTable`.
  - Uses `primitives.Address.Address` for addresses; returns `u256` for balances/storage (ensure alignment with Voltaire `Uint` wrappers when bridging).
- Note: Nested calls are handled internally by EVM (`inner_call`) and do not use `HostInterface`.
Implications for Phase 4:
- Block validation triggers EVM execution for transactions. The validator must prepare a host adapter backed by World State/DB using Voltaire primitives and feed it into the existing EVM.

## Test Fixtures (local paths to use)
- `ethereum-tests/BlockchainTests/InvalidBlocks`
- `ethereum-tests/BlockchainTests/ValidBlocks`
- Additional supporting suites (present):
  - `ethereum-tests/TrieTests/{trietest.json, trieanyorder.json, ...}`
  - `execution-spec-tests/fixtures/blockchain_tests/{InvalidBlocks,ValidBlocks}`

## Implementation Notes (forward-looking, non-binding)
- Follow Nethermind boundaries: separate `chain.zig` (canonical/fork choice persistence) from `validator.zig` (spec checks + body execution).
- No custom numeric/address/hash types — always import from Voltaire `primitives`.
- Use comptime DI patterns as in `src/` EVM (vtable/host-style) for plugging DB/State beneath validator.
- Strict error propagation; no silent catches. Validate headers before bodies; compute/compare roots using Voltaire RLP/trie.
- Performance: columnar lookups, avoid heap churn; consider `ForkBlockCache` for short-lived validation paths.
