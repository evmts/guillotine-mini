# Context — [pass 1/5] Phase 4: Block Chain Management

This file gathers the minimal, high-signal references required to implement `phase-4-blockchain` (Block Chain Management) in guillotine-mini using Voltaire primitives and Nethermind structure.

## Goals (from PRD)
- Manage canonical chain structure and forks.
- Validate blocks and headers per hardfork rules.
- Files to implement in this phase:
  - `client/blockchain/chain.zig` — chain management API
  - `client/blockchain/validator.zig` — block/header validation

Source: `prd/GUILLOTINE_CLIENT_PLAN.md`.

## Spec Anchors (authoritative)
- execution-specs (block validation flow, fork rules):
  - `execution-specs/src/ethereum/forks/*/fork.py`
  - `execution-specs/src/ethereum/forks/*/blocks.py`
- Yellow Paper: Section 11 (Block Finalization) — `yellowpaper/`.

Secondary references (for shape, not truth):
- Nethermind architecture (Blockchain module): `nethermind/src/Nethermind/Nethermind.Blockchain/`.

## Nethermind DB (storage patterns referenced by Blockchain)
Key files in `nethermind/src/Nethermind/Nethermind.Db/` used as structural reference for how chain data is persisted (do not port directly):
- `IDb.cs`, `IColumnsDb.cs`, `ITunableDb.cs`, `IDbProvider.cs`, `IReadOnlyDb.cs`, `IReadOnlyDbProvider.cs` — core interfaces.
- `DbProvider.cs`, `DbProviderExtensions.cs`, `DbExtensions.cs`, `DbNames.cs` — composition and naming.
- `MemDb.cs`, `MemColumnsDb.cs`, `InMemoryWriteBatch.cs`, `InMemoryColumnBatch.cs`, `MemDbFactory.cs` — in-memory backend patterns.
- `RocksDbSettings.cs`, `CompressingDb.cs`, `IMergeOperator.cs`, `RocksDbMergeEnumerator.cs` — RocksDB specifics.
- `PruningMode.cs`, `PruningConfig.cs`, `IFullDb.cs`, `FullPruning*` — pruning knobs.
- `Metrics.cs`, `MetadataDbKeys.cs`, `SimpleFilePublicKeyDb.cs` — misc utilities.

These inform how we slice columns (headers, bodies, receipts, total difficulty, canonical index) when designing `client/blockchain/chain.zig` over our DB abstraction.

## Voltaire APIs (must-use types)
Prefer these from Voltaire — do not create duplicates:
- Blockchain module:
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/Blockchain.zig`
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/BlockStore.zig`
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/ForkBlockCache.zig`
- Primitives (selected):
  - `primitives/BlockHeader`, `primitives/BlockBody`, `primitives/Block`, `primitives/BlockHash`, `primitives/BlockNumber`, `primitives/StateRoot`, `primitives/Receipt`, `primitives/Uncle`, `primitives/Chain`, `primitives/ChainHead`, `primitives/Hardfork`, `primitives/Rlp`.

Use Voltaire’s `root.zig` re-exports where applicable.

## Existing guillotine-mini surface for integration
- Host interface (used by EVM integration phases; review for consistency): `src/host.zig` — minimal vtable for balance/code/storage/nonce. Ensure chain validator does not bypass Voltaire primitives when reading headers/bodies.

## Test Fixtures to drive TDD
- Classic tests: `ethereum-tests/BlockchainTests/` with `ValidBlocks/` and `InvalidBlocks/` categories.
- Generated tests: `execution-spec-tests/fixtures/blockchain_tests/` (where present).

Start with small subsets in `bcValidBlockTest/`, `bcInvalidHeaderTest/`, then expand.

## Concrete file paths captured
- PRD: `prd/GUILLOTINE_CLIENT_PLAN.md`, `prd/ETHEREUM_SPECS_REFERENCE.md`
- Specs (examples for immediate reading):
  - `execution-specs/src/ethereum/forks/frontier/fork.py`
  - `execution-specs/src/ethereum/forks/london/fork.py`
  - `execution-specs/src/ethereum/forks/paris/fork.py`
  - `execution-specs/src/ethereum/forks/shanghai/blocks.py`
  - `execution-specs/src/ethereum/forks/cancun/blocks.py`
- Nethermind (DB): `nethermind/src/Nethermind/Nethermind.Db/` key interfaces and backends (see above list).
- Voltaire (blockchain): see files listed in “Voltaire APIs”.
- Tests: `ethereum-tests/BlockchainTests/`, `execution-spec-tests/fixtures/blockchain_tests/`.

## Notes and constraints for implementation
- Always use Voltaire primitives; never duplicate types (Address, Hash, BlockHeader, u256, Rlp, etc.).
- Follow Nethermind’s module boundaries: headers/bodies/td/canonical index separation; fork-choice via total difficulty / terminal PoS rules for post-Paris.
- Use comptime DI patterns consistent with existing EVM code; no global singletons.
- Strict error handling; no silent `catch {}`.
- Performance: minimize allocations (arena per validation batch), batch DB accesses.
- Every public function must ship with unit tests and selected fixture tests.
