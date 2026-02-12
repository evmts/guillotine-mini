# Context — [pass 1/5] phase-9-sync (Synchronization)

This file captures the minimal, high-signal references to implement Phase 9 (Synchronization) using Voltaire primitives and the existing guillotine-mini EVM, while mirroring Nethermind’s architecture.

## Phase Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Goal: Implement chain synchronization strategies
- Components to implement:
  - `client/sync/full.zig` — Full sync via headers → bodies → receipts → execute
  - `client/sync/snap.zig` — Snap sync (state via snap/1)
  - `client/sync/manager.zig` — Sync coordination/orchestration
- Reference: `nethermind/src/Nethermind/Nethermind.Synchronization/`

## Specs Relevant To Phase 9 (from prd/ETHEREUM_SPECS_REFERENCE.md)
- devp2p wire protocols
  - `devp2p/caps/eth.md` — Header/body/receipt exchange (eth/69 current)
  - `devp2p/caps/snap.md` — Snap state sync (account/storage ranges, proofs)
- Notes:
  - Post‑Merge: block propagation is not via eth; focus on header/body/receipts.
  - Snap requires proof verification and range iteration; ensure RLP correctness.

## Nethermind Reference (structure & naming)
Directory: `nethermind/src/Nethermind/Nethermind.Synchronization/` (for architecture) and DB layer for storage patterns:
- `nethermind/src/Nethermind/Nethermind.Db/` key files:
  - `DbProvider.cs`, `IDbProvider.cs`, `IColumnsDb.cs`, `IDb.cs`
  - `MemDb.cs`, `MemColumnsDb.cs`, `InMemoryWriteBatch.cs`
  - `RocksDbSettings.cs`, `CompressingDb.cs`
  - `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/*`
  - Column descriptors: `ReceiptsColumns.cs`, `BlobTxsColumns.cs`, `Blooms/`
- Use these to mirror: provider interfaces, column families, read‑only views, pruning hooks.

## Voltaire Zig — Primitives & APIs to Use
Root: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- Primitives for sync data:
  - `primitives.BlockHeader`, `primitives.BlockBody`, `primitives.Block`, `primitives.BlockHash`
  - `primitives.Transaction`, `primitives.Receipt`, `primitives.StateRoot`, `primitives.Bytes`, `primitives.Bytes32`
  - `primitives.Hash`, `primitives.Rlp`, `primitives.Uint`, `primitives.Nonce`
  - `primitives.SyncStatus`, `primitives.PeerId`, `primitives.PeerInfo`, `primitives.ChainId`
- Blockchain helpers:
  - `blockchain.Blockchain`, `blockchain.BlockStore`, `blockchain.ForkBlockCache`
- State manager (used during validation, not reimplementation):
  - `state-manager.StateManager`, `state-manager.JournaledState`
- Logging:
  - `log.zig` (`info`, `warn`, `err`, `debug`)

Strict rule: Do not define custom duplicates of these types.

## Host Interface (existing EVM integration)
File: `src/host.zig`
- `HostInterface` provides external state access for EVM (balances, code, storage, nonce)
- Uses a vtable with explicit functions and Zig built‑in `u256`/`u64` where applicable
- Note: Nested calls are handled internally by the EVM (`inner_call` path); host is for pre/post state access
- For sync: host is not extended; block execution must adapt to world‑state components that already implement this interface

## Test Fixtures (available locally)
- `ethereum-tests/BlockchainTests/` — Block header/body/receipt validation vectors
- `ethereum-tests/TrieTests/` — State trie structure reference
- `ethereum-tests/TransactionTests/`, `ethereum-tests/RLPTests/` — RLP/tx parsing
- Tarballs: `ethereum-tests/fixtures_blockchain_tests.tgz`, `ethereum-tests/fixtures_general_state_tests.tgz`
- Execution-spec test fixtures: `execution-spec-tests/fixtures/` (Python‑generated)

## Implementation Notes (actionable)
- Header sync:
  - Use `devp2p/caps/eth.md` GetBlockHeaders response limits; support skeleton + gap fill
  - Validate header fields using `primitives.BlockHeader` + `primitives.Rlp`
- Bodies/receipts:
  - Request via eth; validate bodies vs. headers; download receipts during snap per spec
- Snap sync:
  - Implement range requests and proof verification using trie primitives and RLP
  - Ensure byte/size soft‑limits, and handle peers with partial history windows
- Storage:
  - Mirror Nethermind DB provider layering for chain data and indices
  - Keep allocations minimal; batch writes where possible

## Pointers (paths)
- Plan: `prd/GUILLOTINE_CLIENT_PLAN.md`
- Specs: `devp2p/caps/eth.md`, `devp2p/caps/snap.md`
- Nethermind DB ref: `nethermind/src/Nethermind/Nethermind.Db/`
- Voltaire primitives: `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/`
- Voltaire blockchain: `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/`
- Host interface: `src/host.zig`
- Tests: `ethereum-tests/`, `execution-spec-tests/`

