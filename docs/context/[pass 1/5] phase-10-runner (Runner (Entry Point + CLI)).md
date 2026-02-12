# [pass 1/5] phase-10-runner (Runner (Entry Point + CLI)) — Focused Context

This note captures the exact files and references to guide implementation of the Runner (CLI entry point + configuration) while staying consistent with Nethermind’s structure and using only Voltaire primitives and the existing guillotine-mini EVM.

## Phase Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Goal: Create the CLI entry point and configuration.
- Key components:
  - `client/main.zig` — process entry point
  - `client/config.zig` — runner configuration (chain/network/hardfork/trace)
  - `client/cli.zig` — CLI argument parsing
- Reference: Nethermind `Nethermind.Runner` (structure and responsibility split)
- Tests: Integration-level invocation; compatible with `hive/` full node tests later

## Relevant Specs (from prd/ETHEREUM_SPECS_REFERENCE.md)
- Phase 10 has no normative protocol specs (CLI/config only)
- Architectural reference: `nethermind/src/Nethermind/Nethermind.Runner/`

## Nethermind Reference — Db folder (requested listing snapshot)
Key types for DB layering (useful cross-phase context):
- `nethermind/src/Nethermind/Nethermind.Db/IDb.cs` — DB interface
- `nethermind/src/Nethermind/Nethermind.Db/IDbProvider.cs` — Provider interface
- `nethermind/src/Nethermind/Nethermind.Db/DbProvider.cs` — Provider implementation
- `nethermind/src/Nethermind/Nethermind.Db/MemDb.cs` — In-memory DB
- `nethermind/src/Nethermind/Nethermind.Db/ReadOnlyDb.cs` — Read-only wrapper
- `nethermind/src/Nethermind/Nethermind.Db/RocksDbSettings.cs` — RocksDB settings
- `nethermind/src/Nethermind/Nethermind.Db/CompressingDb.cs` — Compression layer
- (Also present: `IColumnsDb.cs`, `InMemoryWriteBatch.cs`, `RocksDbMergeEnumerator.cs`, pruning configs)

## Voltaire Zig APIs (for Runner + config wiring)
Under `/Users/williamcory/voltaire/packages/voltaire-zig/src/`:
- `primitives.ChainId` → `primitives/ChainId/ChainId.zig`
- `primitives.NetworkId` → `primitives/NetworkId/NetworkId.zig`
- `primitives.Hardfork` → `primitives/Hardfork/hardfork.zig`
- `primitives.Hex` → `primitives/Hex/Hex.zig`
- `primitives.Chain` → `primitives/Chain/chain.zig`
- `primitives.FeeMarket` → EIP-1559 helpers (base fee calc)
- `primitives.Blob` → EIP-4844 helpers (blob gas price)
- `jsonrpc.JsonRpc` + `jsonrpc/types/*.zig` → JSON-RPC typing (future phases)
- `log` → structured logging and platform-aware panic

These are the only primitives we will use in Runner; no custom duplicates allowed.

## Existing EVM Host Interface (guillotine-mini)
- File: `src/host.zig`
- Minimal vtable-based host for external state (balance/code/storage/nonce)
- EVM handles nested calls internally; host is for external state access
- We must not reimplement EVM; only integrate via provided interfaces

## Existing Runner Files (already present)
- `client/main.zig` — parses args, resolves chain/hardfork, configures `BlockContext`, boots EVM, optional tracer
- `client/config.zig` — `RunnerConfig` with sensible defaults; uses Voltaire primitives
- `client/cli.zig` — robust CLI parsing with tests for errors/help and trace flags

## Ethereum Test Fixtures (paths to use later)
- `ethereum-tests/BlockchainTests/`
- `ethereum-tests/TrieTests/`
- `ethereum-tests/TransactionTests/`
- (Plus `execution-spec-tests/fixtures/` for spec-generated vectors in later phases)

## Notes/Constraints
- Always use Voltaire primitives; no custom Address/Hash/u256/etc
- Follow Nethermind structure; keep CLI/config at Runner responsibility level
- Use comptime DI patterns consistent with existing EVM usage
- No silent error suppression; surface unknown options/invalid inputs
- Run `zig fmt` and `zig build` after changes

