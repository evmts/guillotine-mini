# Context — [pass 2/5] Phase 4: Block Chain Management

This document aggregates the minimal, high-signal references needed to implement Phase 4 (Block Chain Management) using Voltaire primitives and the existing guillotine-mini EVM, while following Nethermind’s architecture idiomatically in Zig.

## Goals (from PRD: prd/GUILLOTINE_CLIENT_PLAN.md)
- Manage the block chain structure and validation.
- Planned components:
  - `client/blockchain/chain.zig` — chain management (canonical mapping, orphans, head selection).
  - `client/blockchain/validator.zig` — block validation against spec.
- Reference modules:
  - Nethermind: `nethermind/src/Nethermind/Nethermind.Blockchain/`
  - Voltaire: `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/`
- Test fixtures: `ethereum-tests/BlockchainTests/`

## Spec Anchors (from prd/ETHEREUM_SPECS_REFERENCE.md)
- execution-specs block validation logic per fork (authoritative):
  - `execution-specs/src/ethereum/forks/frontier/fork.py`
  - `execution-specs/src/ethereum/forks/homestead/fork.py`
  - `execution-specs/src/ethereum/forks/byzantium/fork.py`
  - `execution-specs/src/ethereum/forks/istanbul/fork.py`
  - `execution-specs/src/ethereum/forks/berlin/fork.py`
  - `execution-specs/src/ethereum/forks/london/fork.py`
  - `execution-specs/src/ethereum/forks/paris/fork.py` (Merge)
  - `execution-specs/src/ethereum/forks/shanghai/fork.py`
  - `execution-specs/src/ethereum/forks/cancun/fork.py`
  - `execution-specs/src/ethereum/forks/prague/fork.py`
- Yellow Paper Section 11 — Block finalization (conceptual reference only).

## Nethermind Reference (structure and responsibilities)
- Blockchain management (canonical chain, reorgs, head updates):
  - `nethermind/src/Nethermind/Nethermind.Blockchain/BlockTree.cs`
  - `nethermind/src/Nethermind/Nethermind.Blockchain/BlockTree.Initializer.cs`
  - `nethermind/src/Nethermind/Nethermind.Blockchain/BlockTreeOverlay.cs`
  - `nethermind/src/Nethermind/Nethermind.Blockchain/ReadOnlyBlockTree.cs`
  - `nethermind/src/Nethermind/Nethermind.Blockchain/IBlockTree.cs`
  - `nethermind/src/Nethermind/Nethermind.Blockchain/AddBlockResult.cs`
  - `nethermind/src/Nethermind/Nethermind.Blockchain/GenesisBuilder.cs`
  - `nethermind/src/Nethermind/Nethermind.Blockchain/BlockhashCache.cs`
- DB abstractions used by blockchain layer (for persistence patterns):
  - `nethermind/src/Nethermind/Nethermind.Db/IDb.cs`, `IDbProvider.cs`, `DbProvider.cs`, `ReadOnlyDbProvider.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/MemDb.cs`, `MemColumnsDb.cs`, `CompressingDb.cs`
  - `nethermind/src/Nethermind/Nethermind.Db/RocksDbSettings.cs`, `PruningConfig.cs`, `FullPruningCompletionBehavior.cs`, `Metrics.cs`

Key takeaways for Zig implementation:
- Keep chain logic separate from persistence; use dependency injection for DB providers.
- Model canonical mapping (number→hash), orphan handling, and head selection explicitly.
- Keep validation pure and fork-aware per execution-specs; storage writes after validation.

## Voltaire APIs to use (no custom primitives)
- Blockchain utilities:
  - `voltaire-zig/src/blockchain/Blockchain.zig` — unified read/writes over local store and optional fork cache.
  - `voltaire-zig/src/blockchain/BlockStore.zig` — local storage, canonical mapping, orphan tracking.
  - `voltaire-zig/src/blockchain/ForkBlockCache.zig` — remote read-through for pre-fork data.
- Primitives (types only; never custom):
  - `voltaire-zig/src/primitives/Block/root.zig` (imported via `primitives.Block`)
  - `voltaire-zig/src/primitives/BlockHeader/root.zig` (via `primitives.BlockHeader`)
  - `voltaire-zig/src/primitives/BlockBody/root.zig` (via `primitives.BlockBody`)
  - `voltaire-zig/src/primitives/Hash/root.zig` (via `primitives.Hash`)
  - `voltaire-zig/src/primitives/Address/root.zig`
  - RLP/hex helpers under `voltaire-zig/src/primitives/Rlp` and `voltaire-zig/src/primitives/Hex`

Notes:
- Voltaire’s `Blockchain` and `BlockStore` already model canonical chain and orphans; Phase 4 should integrate these, not re-create them.
- Prefer comptime DI to compose a `Chain` façade over `BlockStore` with pluggable persistence.
- Avoid storage encapsulation leakage: local-only reads must go through `client/blockchain/local_access.zig` instead of touching `Blockchain.block_store` directly. This concentrates knowledge of Voltaire internals in one place and preserves a stable façade for the client.

## guillotine-mini Host Interface (how EVM state is accessed)
- `src/host.zig` — Minimal HostInterface for balances, code, storage, nonces.
  - Provides vtable for `getBalance`, `getCode`, `getStorage`, `getNonce`, and mutators.
  - EVM nested calls are handled internally by `EVM.inner_call`; HostInterface is for external state access only.

Implication for Phase 4:
- Block validation must compute header fields and state transitions using the world-state APIs (later phases) but for structural work now, wire chain management to use Voltaire primitives and keep validation surface aligned with spec functions (`state_transition` / per-fork header checks).

## Test Fixtures
- Classic blockchain tests:
  - `ethereum-tests/BlockchainTests/`
- execution-specs generated symlink:
  - `execution-spec-tests/fixtures/blockchain_tests/` → symlink to `ethereum-tests/BlockchainTests`

## Immediate Implementation Targets (scope framing)
- `client/blockchain/chain.zig` — thin wrapper over Voltaire `BlockStore` + canonical helpers and persistence DI hooks. Head snapshot helpers expose `head_block_of_with_policy(chain, max_attempts)`; default is a single retry (2 attempts) to balance consistency and overhead under contention.
- `client/blockchain/validator.zig` — fork-dispatch + header/body checks mirroring `execution-specs/*/fork.py` (no EVM reimplementation; reuse existing EVM for tx execution in later phases).
