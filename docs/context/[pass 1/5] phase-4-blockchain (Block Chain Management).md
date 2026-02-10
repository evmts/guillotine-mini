# Context — [pass 1/5] phase-4-blockchain (Block Chain Management)

This file captures the specific goals, specs, references, primitives, and fixtures needed to implement Phase 4: Block Chain Management. It is derived from the product plan and in-repo spec sources, and it maps them to concrete file paths for quick navigation and implementation.

## Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Scope: Manage the block chain structure and validation.
- Components to implement:
  - `client/blockchain/chain.zig` — Chain management (canonical head, lookups).
  - `client/blockchain/validator.zig` — Block validation (header/body/withdrawals checks).
- References:
  - Nethermind architecture: `nethermind/src/Nethermind/Nethermind.Blockchain/` (structure), DB coupling via `Nethermind.Db`.
  - Voltaire primitives/APIs: `voltaire/packages/voltaire-zig/src/blockchain/` and `.../src/primitives/`.
- Test fixtures:
  - `ethereum-tests/BlockchainTests/` (ValidBlocks, InvalidBlocks).

## Relevant Specs (from prd/ETHEREUM_SPECS_REFERENCE.md)
- Block validation and processing logic:
  - `execution-specs/src/ethereum/forks/frontier/fork.py` — baseline block processing.
  - `execution-specs/src/ethereum/forks/london/fork.py` — EIP-1559 fee market block rules.
  - `execution-specs/src/ethereum/forks/paris/fork.py` — post-Merge execution-layer rules.
  - `execution-specs/src/ethereum/forks/shanghai/fork.py` — EIP-4895 withdrawals rules.
  - `execution-specs/src/ethereum/forks/cancun/fork.py` — EIP-4844 related header fields.
- Yellow Paper (normative background):
  - `yellowpaper/Paper.tex` — “Block Finalisation” (§\ref{ch:finalisation}) and fork-choice notes after Paris.
- Supplemental EIPs directly impacting block structure/validation:
  - `EIPs/EIPS/eip-3675.md` — Upgrade consensus to proof of stake (Paris, forkchoice integration points).
  - `EIPs/EIPS/eip-4895.md` — Beacon chain withdrawals in EL blocks (Shanghai).

## Nethermind Reference — DB Layer (for storage coupling)
Located at `nethermind/src/Nethermind/Nethermind.Db/`. Key files influencing how chain storage should be abstracted and composed:
- `DbProvider.cs`, `IDb.cs`, `IDbProvider.cs`, `IColumnsDb.cs` — DB abstraction boundaries.
- `ReadOnlyDb.cs`, `ReadOnlyDbProvider.cs` — read-only views (useful for fork-cache semantics).
- `MemDb.cs`, `MemColumnsDb.cs`, `MemDbFactory.cs` — in-memory DB patterns for tests.
- `RocksDbSettings.cs`, `CompressingDb.cs`, `RocksDbMergeEnumerator.cs` — on-disk backend considerations.
- `Metrics.cs`, pruning configs (`PruningConfig.cs`, `IPruningConfig.cs`) — performance and lifecycle.

## Voltaire Zig — Blockchain + Primitives APIs
- Blockchain orchestrators (re-use, do not reimplement):
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/Blockchain.zig` — unified read (local→fork cache), write (local), canonical head.
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/BlockStore.zig` — canonical/side-chain storage.
  - `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/ForkBlockCache.zig` — remote/fork-aware read cache.
- Core primitives to use (never define custom equivalents):
  - Blocks/headers/bodies: `primitives/Block/Block.zig`, `primitives/BlockHeader/BlockHeader.zig`, `primitives/BlockBody/BlockBody.zig`.
  - Hashing/IDs: `primitives/Hash/Hash.zig`, `primitives/BlockHash/`, `primitives/BlockNumber/`.
  - Roots and encoding: `primitives/StateRoot/`, `primitives/Rlp/Rlp.zig`.
  - Integers: `primitives/Uint/` family, `primitives/Bytes*/` as needed.

Implementation must import through Voltaire’s module boundaries (e.g., `const primitives = @import("primitives");`) and types from there, following existing client/EVM patterns.

## HostInterface (src/host.zig) — integration note
Path: `src/host.zig`
- Provides a minimal vtable-based `HostInterface` for external state access:
  - `getBalance/setBalance`, `getCode/setCode`, `getStorage/setStorage`, `getNonce/setNonce`.
- Nested calls are handled internally by the EVM (`inner_call`) and do not go through `HostInterface`.
- For Phase 4, block validation that executes state transitions must wire world-state access via existing EVM + HostInterface; do not duplicate state types — always use Voltaire primitives.

## Test Fixtures
- Canonical blockchain fixtures:
  - `ethereum-tests/BlockchainTests/` → `.meta/`, `ValidBlocks/`, `InvalidBlocks/`.
  - Symlinked mirror for execution-spec tests: `execution-spec-tests/fixtures/blockchain_tests/` → points to the above.

## Implementation Implications (Phase 4)
- Chain manager should compose Voltaire `Blockchain` + `BlockStore` and (optionally) `ForkBlockCache` behind a comptime-injected storage adapter, mirroring Nethermind’s separation of storage/provider concerns.
- Block validator must:
  - Validate headers/body using Voltaire primitives + execution-spec rules per fork (Paris/Shanghai/Cancun awareness).
  - Apply withdrawals (EIP-4895) post-tx processing as per Yellow Paper §Finalisation and EIP-4895.
  - Never create custom hashes/ids/uints — import from `primitives`.
- Testing: each public function requires Zig unit tests; integration should run `BlockchainTests` subsets.

