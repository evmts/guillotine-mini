# [Pass 2/5] Phase 4: Block Chain Management — Context

## Goal

Manage the block chain structure and validation.

**Key deliverables (from `prd/GUILLOTINE_CLIENT_PLAN.md`):**
- `client/blockchain/chain.zig` — Chain management
- `client/blockchain/validator.zig` — Block validation

**Reference files:**
- Nethermind: `nethermind/src/Nethermind/Nethermind.Blockchain/`
- Voltaire: `voltaire/packages/voltaire-zig/src/blockchain/`

**Test fixtures:** `ethereum-tests/BlockchainTests/`

---

## Execution Specs (authoritative)

From `prd/ETHEREUM_SPECS_REFERENCE.md` (Phase 4):
- `execution-specs/src/ethereum/forks/*/fork.py` — block validation rules
- Yellow Paper Section 11 — Block Finalization

Adjacent specs worth keeping in view for later integration:
- `execution-spec-tests/fixtures/blockchain_tests/` — spec-aligned blockchain fixtures
- `execution-spec-tests/fixtures/blockchain_tests_engine/` — Engine API blockchain fixtures (Phase 7)
- `devp2p/caps/eth.md` — block/header exchange (Phase 9 sync)

---

## Nethermind DB Layer (reference for storage contracts)

Directory listing: `nethermind/src/Nethermind/Nethermind.Db/`

Key files to consult when mapping chain storage/DB boundaries:
- `IDb.cs`, `IDbProvider.cs`, `IReadOnlyDb.cs`, `IFullDb.cs` — DB interface contracts
- `DbProvider.cs`, `DbProviderExtensions.cs` — provider composition
- `DbNames.cs` — canonical DB names
- `RocksDbSettings.cs`, `NullRocksDbFactory.cs` — backend config and null backend
- `ReadOnlyDb.cs`, `ReadOnlyDbProvider.cs`, `ReadOnlyColumnsDb.cs` — read-only wrappers
- `MemDb.cs`, `MemDbFactory.cs`, `MemColumnsDb.cs` — in-memory backend
- `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/*` — pruning controls
- `ReceiptsColumns.cs`, `BlobTxsColumns.cs` — column families for receipts/blobs
- `Metrics.cs` — DB metrics exposure

---

## Voltaire Primitives (must use)

From `voltaire/packages/voltaire-zig/src/`:
- `blockchain/Blockchain.zig` — chain structure primitives
- `blockchain/BlockStore.zig` — block storage interface/implementation
- `blockchain/ForkBlockCache.zig` — fork-aware cache helpers
- `blockchain/root.zig`, `blockchain/c_api.zig` — module root and C-API wrapper
- `primitives/` — canonical types (hashes, addresses, headers, receipts, etc.)
- `state-manager/` — state primitives used by EVM host integration
- `evm/` — EVM primitives (do not reimplement)

Directory listing for context:
- `/Users/williamcory/voltaire/packages/voltaire-zig/src/` → `blockchain`, `crypto`, `evm`, `jsonrpc`, `log.zig`, `precompiles`, `primitives`, `state-manager`, `root.zig`, `c_api.zig`

---

## Existing EVM Host Interface (guillotine-mini)

From `src/host.zig`:
- `HostInterface` is a minimal vtable for external state access:
  - `getBalance/setBalance`, `getCode/setCode`, `getStorage/setStorage`, `getNonce/setNonce`
- Note: **not used for nested calls** — `EVM.inner_call` handles nested calls internally

---

## Test Fixtures (ethereum-tests)

Directory listing: `ethereum-tests/`
- `BlockchainTests/` (primary for this phase)
- `GenesisTests/`, `RLPTests/`, `TransactionTests/`, `TrieTests/`, `DifficultyTests/`, `EOFTests/`, `BasicTests/`, `LegacyTests/`, `PoWTests/`, `ABITests/`
- `fixtures_blockchain_tests.tgz`, `fixtures_general_state_tests.tgz` (local fixture archives)

---

## Summary

This pass identifies the Phase 4 blockchain goals, the authoritative block validation specs (execution-specs fork.py + Yellow Paper Section 11), the relevant Voltaire blockchain primitives to use, Nethermind DB layer contracts for storage boundaries, the existing host interface constraints, and the concrete fixture paths for blockchain validation tests.
