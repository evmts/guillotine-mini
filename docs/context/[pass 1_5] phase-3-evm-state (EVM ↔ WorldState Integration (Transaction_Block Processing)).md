# [pass 1/5] Phase 3 — EVM ↔ WorldState Integration (Transaction/Block Processing)

This context file gathers the exact paths and references needed to implement Phase 3. It focuses on connecting the existing guillotine-mini EVM to the WorldState layer using Voltaire primitives and Nethermind as structural reference.

## Goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Connect the EVM to WorldState for transaction and block processing.
- Implement `client/evm/host_adapter.zig` to back `src/host.zig` using the StateManager/JournaledState.
- Implement `client/evm/processor.zig` to orchestrate per-transaction execution using guillotine-mini EVM.
- Use Voltaire primitives exclusively for Ethereum types; do not introduce custom types.

Plan source: `prd/GUILLOTINE_CLIENT_PLAN.md` → Phase 3: EVM State Integration (`phase-3-evm-state`).

## Relevant Specs (from prd/ETHEREUM_SPECS_REFERENCE.md)
Primary sources for transaction processing and VM block/tx hooks:
- execution-specs: `execution-specs/src/ethereum/forks/*/vm/__init__.py`
- execution-specs: `execution-specs/src/ethereum/forks/*/fork.py` (transaction processing rules)

Concrete files present in the repo for major forks (non-exhaustive, validated by search):
- Frontier: `execution-specs/src/ethereum/forks/frontier/vm/__init__.py`, `.../frontier/fork.py`
- Homestead: `execution-specs/src/ethereum/forks/homestead/vm/__init__.py`, `.../homestead/fork.py`
- TangerineWhistle: `execution-specs/src/ethereum/forks/tangerine_whistle/vm/__init__.py`, `.../tangerine_whistle/fork.py`
- SpuriousDragon: `execution-specs/src/ethereum/forks/spurious_dragon/vm/__init__.py`, `.../spurious_dragon/fork.py`
- Byzantium: `execution-specs/src/ethereum/forks/byzantium/vm/__init__.py`, `.../byzantium/fork.py`
- Istanbul: `execution-specs/src/ethereum/forks/istanbul/vm/__init__.py`, `.../istanbul/fork.py`
- Berlin: `execution-specs/src/ethereum/forks/berlin/vm/__init__.py`, `.../berlin/fork.py`
- London: `execution-specs/src/ethereum/forks/london/vm/__init__.py`, `.../london/fork.py`
- Paris: `execution-specs/src/ethereum/forks/paris/vm/__init__.py`, `.../paris/fork.py`
- Shanghai: `execution-specs/src/ethereum/forks/shanghai/vm/__init__.py`, `.../shanghai/fork.py`
- Cancun: `execution-specs/src/ethereum/forks/cancun/vm/__init__.py`, `.../cancun/fork.py`
- Prague/Osaka (as present): `execution-specs/src/ethereum/forks/prague/vm/__init__.py`, `.../prague/fork.py`, `.../osaka/vm/__init__.py`, `.../osaka/fork.py`

Cross-check gas and warm/cold access: see EIP-2929 (Berlin), EIP-3651 (Shanghai), EIP-4844 (Cancun) behavior in corresponding fork modules.

## Nethermind Architecture Reference (Db layer; for storage structure cohesion)
List of key files in `nethermind/src/Nethermind/Nethermind.Db/` to mirror boundaries and naming (we do not port code):
- `IDb.cs`, `IReadOnlyDb.cs`, `IColumnsDb.cs`, `ITunableDb.cs`
- `IDbFactory.cs`, `DbProvider.cs`, `IDbProvider.cs`, `ReadOnlyDbProvider.cs`
- `MemDb.cs`, `MemColumnsDb.cs`, `InMemoryWriteBatch.cs`, `InMemoryColumnBatch.cs`
- `RocksDbSettings.cs`, `NullRocksDbFactory.cs`, `CompressingDb.cs`
- `PruningMode.cs`, `IPruningConfig.cs`, `PruningConfig.cs`, `FullPruning/`*, `FullPruningTrigger.cs`, `FullPruningCompletionBehavior.cs`
- `DbExtensions.cs`, `DbProviderExtensions.cs`, `DbNames.cs`, `MetadataDbKeys.cs`, `Metrics.cs`
- Receipt/blob columns: `ReceiptsColumns.cs`, `BlobTxsColumns.cs`

Purpose here: ensure our WorldState backend aligns with these concerns (columns, providers, pruning) even though Phase 3 focuses on the Host ↔ State wiring.

## Voltaire Zig APIs to Use (never custom types)
Top-level: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- primitives:
  - `Address` (20-byte type + helpers)
  - `Hash`, `Bytes`, `Rlp` (encoding/decoding), `BloomFilter`
  - `Uint` family and fixed-size `uint{128,256}` wrappers
  - `Transaction` (typed txs incl. EIP-1559, EIP-4844); `Receipt`
  - `State`, `Storage`, `AccountState`, `Nonce`, `Gas`, `GasConstants`
- state-manager:
  - `JournaledState.zig` — dual-cache with checkpoint/revert/commit
  - `StateManager.zig` — convenience accessors + snapshot API for tests
  - `ForkBackend.zig` — optional read-through to remote state
- evm:
  - Use for reference only; we MUST use guillotine-mini’s EVM in `src/`.

These APIs are authoritative for types and helpers used by the HostAdapter and Processor.

## guillotine-mini EVM Host Interface (src/host.zig)
- Type: `HostInterface` (pointer + vtable; comptime-friendly DI)
- Methods (all required by vtable):
  - `getBalance(Address) u256`, `setBalance(Address, u256) void`
  - `getCode(Address) []const u8`, `setCode(Address, []const u8) void`
  - `getStorage(Address, u256) u256`, `setStorage(Address, u256, u256) void`
  - `getNonce(Address) u64`, `setNonce(Address, u64) void`
- Notes:
  - Nested calls are handled internally by EVM (`inner_call`); Host is for external state reads/writes.
  - Must back these methods with Voltaire StateManager/JournaledState and Voltaire primitives only.

## Test Fixtures
- ethereum-tests (present):
  - `ethereum-tests/BlockchainTests/`
  - `ethereum-tests/TrieTests/`
  - `ethereum-tests/TransactionTests/`
  - `ethereum-tests/EOFTests/`
  - General state fixtures compressed: `ethereum-tests/fixtures_general_state_tests.tgz`
- execution-spec-tests:
  - `execution-spec-tests/fixtures/` contains a symlink: `blockchain_tests -> ethereum-tests/BlockchainTests`
  - No `state_tests` directory is currently present; plan to derive from execution-specs or use ethereum-tests general-state tgz.

## Implementation Pointers (Phase 3)
- Host Adapter (`client/evm/host_adapter.zig`):
  - Implement an object whose vtable matches `src/host.zig` and forwards to `state-manager.StateManager`.
  - Zero-copy where possible; avoid heap allocations in hot paths (balance/nonce/storage reads).
  - Strict error surfaces: never silently catch; propagate errors explicitly.
- Processor (`client/evm/processor.zig`):
  - Construct EVM with comptime config; inject `HostInterface` instance.
  - Initialize tx-scoped arena; call `initTransactionState()` and `preWarmTransaction()` per spec.
  - Use Voltaire `Transaction` and `Receipt`. Keep logs in Voltaire formats.
  - Respect fork transitions from header/context using Voltaire `Hardfork` and `ForkTransition`.

## Paths Recap
- Plan: `prd/GUILLOTINE_CLIENT_PLAN.md`
- Specs: `execution-specs/src/ethereum/forks/*/(vm/__init__.py|fork.py)`
- Nethermind reference: `nethermind/src/Nethermind/Nethermind.Evm/` (structure) and `Nethermind.Db/` (listed above)
- Voltaire primitives + state-manager: `/Users/williamcory/voltaire/packages/voltaire-zig/src/{primitives,state-manager}`
- guillotine-mini Host: `src/host.zig`
- Tests: `ethereum-tests/` (dirs listed), `execution-spec-tests/fixtures/`

