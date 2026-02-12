# Context — [pass 1/5] phase-4-blockchain (Block Chain Management)

This file aggregates the most relevant paths and specs to guide implementation of Phase 4 (Block Chain Management) using Voltaire primitives and the existing guillotine-mini EVM, aligned with Nethermind’s architecture.

## Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Manage the block chain structure and validation.
- Key components to build in this phase:
  - `client/blockchain/chain.zig` — chain management (canonical head, forks, reorgs)
  - `client/blockchain/validator.zig` — block/header validation
- Reference impl layout: `nethermind/src/Nethermind/Nethermind.Blockchain/`.
- Use Voltaire blockchain primitives from `voltaire/packages/voltaire-zig/src/blockchain/`.

Source: prd/GUILLOTINE_CLIENT_PLAN.md

## Specs (from prd/ETHEREUM_SPECS_REFERENCE.md)
- execution-specs block validation logic:
  - `execution-specs/src/ethereum/forks/*/fork.py`
- Yellow Paper Section 11 (Block Finalization)
- Tests:
  - `ethereum-tests/BlockchainTests/`
  - `execution-spec-tests/fixtures/blockchain_tests/`

Source: prd/ETHEREUM_SPECS_REFERENCE.md

## Nethermind reference (Nethermind.Db — storage patterns used by Blockchain)
Key files to understand DB provider abstractions used by Nethermind’s Blockchain module:
- `nethermind/src/Nethermind/Nethermind.Db/IDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/IDbProvider.cs`
- `nethermind/src/Nethermind/Nethermind.Db/DbProvider.cs`
- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDbProvider.cs`
- `nethermind/src/Nethermind/Nethermind.Db/MemDb.cs`
- `nethermind/src/Nethermind/Nethermind.Db/RocksDbSettings.cs`
- `nethermind/src/Nethermind/Nethermind.Db/CompressingDb.cs`

Note: While Phase 4 consumes DB abstractions, Phase 0 establishes our DB adapter; keep interfaces similar to support chain indices (by hash, number, total difficulty, canonical mapping, receipts, etc.).

## Voltaire Zig — relevant APIs
Location: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- blockchain:
  - `blockchain.Blockchain` — chain orchestration helpers
  - `blockchain.BlockStore` — storage helpers for blocks/indices
  - `blockchain.ForkBlockCache` — fork choice caching
- primitives (types to ALWAYS use):
  - `primitives.Block.Block`
  - `primitives.BlockHeader.BlockHeader`
  - `primitives.BlockHash.BlockHash`
  - `primitives.BlockNumber.BlockNumber`
  - `primitives.StateRoot.StateRoot`
  - `primitives.Receipt.Receipt`
  - `primitives.Rlp` — canonical encoding/decoding where needed

Implementation MUST not introduce parallel custom structs for any of the above.

## Existing Zig integration surface
- `src/host.zig` — minimal HostInterface vtable used by EVM for external state access (balances, code, storage, nonces). Nested calls are handled internally by EVM and do not use HostInterface.

Implication: Chain validation must feed world-state roots and header fields to the EVM using Voltaire primitives; do NOT modify EVM or HostInterface in Phase 4.

## ethereum-tests — fixture directories of interest
- `ethereum-tests/BlockchainTests/`
- Also present for broader coverage (other phases):
  - `ethereum-tests/TrieTests/`
  - `ethereum-tests/TransactionTests/`

## Working notes for implementation
- Mirror Nethermind module boundaries: `blockchain/chain.zig` and `blockchain/validator.zig`.
- Use comptime DI patterns as in existing EVM: pass in storage/DB adapters and consensus parameters at comptime where possible.
- Keep all data representations in Voltaire primitives; convert once at boundaries.
- Avoid allocations in hot paths (validation, fork choice); prefer stack/arena.
- Explicit error handling; surface precise validation errors (no silent catches).
