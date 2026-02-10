# [pass 1/5] phase-3-evm-state (EVM ↔ WorldState Integration (Transaction/Block Processing))

## Phase Goals (from `prd/GUILLOTINE_CLIENT_PLAN.md`)
- Connect the guillotine-mini EVM to WorldState for transaction and block processing.
- Target components:
  - `client/evm/host_adapter.zig` (HostInterface implementation over WorldState)
  - `client/evm/processor.zig` (transaction processing pipeline)
- Structural references:
  - Nethermind: `nethermind/src/Nethermind/Nethermind.Evm/`
  - Existing EVM behavior: `src/evm.zig`, `src/host.zig`

## Relevant Specs Read (from `prd/ETHEREUM_SPECS_REFERENCE.md` + source files)
- `execution-specs/src/ethereum/forks/prague/vm/__init__.py`
  - Defines `BlockEnvironment`, `TransactionEnvironment`, `Message`, `Evm`, and child-call merge behavior.
- `execution-specs/src/ethereum/forks/prague/fork.py`
  - Core flow for this phase: `state_transition`, `apply_body`, `check_transaction`, `process_transaction`, `process_withdrawals`.
  - Includes SetCode transaction checks and authorization handling.
- `execution-specs/src/ethereum/forks/cancun/fork.py`
  - Blob transaction rules (`max_fee_per_blob_gas`, versioned hash checks) and system tx pattern.
- `execution-specs/src/ethereum/forks/london/fork.py`
  - Baseline EIP-1559 transaction checks, fee accounting, gas refund flow.
- EIPs read for tx/block processing behavior:
  - `EIPs/EIPS/eip-1559.md` (base fee + effective gas price model)
  - `EIPs/EIPS/eip-2930.md` (access list semantics and intrinsic costs)
  - `EIPs/EIPS/eip-4844.md` (blob transaction format and blob gas accounting)
  - `EIPs/EIPS/eip-7702.md` (set-code transaction + authorization list rules)
  - `EIPs/EIPS/eip-2929.md`, `EIPs/EIPS/eip-3529.md`, `EIPs/EIPS/eip-3651.md`, `EIPs/EIPS/eip-3860.md` (warm/cold access, refunds, warm coinbase, initcode metering)
- devp2p status:
  - `devp2p/` exists but has no files in this checkout, so no phase-3-relevant devp2p spec file could be read locally.

## Nethermind DB Inventory (requested path: `nethermind/src/Nethermind/Nethermind.Db/`)
Key files noted:
- Interfaces and abstractions:
  - `IDb.cs`, `IColumnsDb.cs`, `IReadOnlyDb.cs`, `IReadOnlyDbProvider.cs`, `IDbProvider.cs`, `IDbFactory.cs`, `IFullDb.cs`, `ITunableDb.cs`
- Providers/implementations:
  - `DbProvider.cs`, `DbProviderExtensions.cs`, `MemDb.cs`, `MemColumnsDb.cs`, `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `NullDb.cs`
- Batching/settings/metadata:
  - `InMemoryWriteBatch.cs`, `InMemoryColumnBatch.cs`, `RocksDbSettings.cs`, `DbNames.cs`, `MetadataDbKeys.cs`
- Pruning and maintenance:
  - `PruningConfig.cs`, `PruningMode.cs`, `FullPruningTrigger.cs`, `FullPruningCompletionBehavior.cs`, `FullPruning/*`
- Domain columns:
  - `ReceiptsColumns.cs`, `BlobTxsColumns.cs`

## Voltaire Zig APIs (requested path: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`)
Path is present. Relevant APIs for EVM ↔ WorldState integration:
- Primitives exports (`/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/root.zig`)
  - `Address`, `Hash`, `Hex`, `Transaction`, `Block`, `Receipt`, `AccessList`, `Authorization`, `Nonce`, `Gas`, `GasUsed`, `BaseFeePerGas`, `StateRoot`, `Storage`, `StorageValue`, `Bytecode`, `Bytes`, `Rlp`, `Uint`.
- State manager surface (`/Users/williamcory/voltaire/packages/voltaire-zig/src/state-manager/root.zig`)
  - `StateManager`, `JournaledState`, `ForkBackend`, cache types.
- `StateManager` methods (`/Users/williamcory/voltaire/packages/voltaire-zig/src/state-manager/StateManager.zig`)
  - `getBalance`, `setBalance`, `getNonce`, `setNonce`, `getCode`, `setCode`, `getStorage`, `setStorage`, `checkpoint`, `revert`, `commit`, `snapshot`, `revertToSnapshot`.
- `JournaledState` behavior (`/Users/williamcory/voltaire/packages/voltaire-zig/src/state-manager/JournaledState.zig`)
  - Read cascade (local cache -> fork backend) and synchronized checkpoint/revert/commit.
- EVM host contract (`/Users/williamcory/voltaire/packages/voltaire-zig/src/evm/host.zig`)
  - Host vtable API mirrors guillotine-mini host methods for balance/code/storage/nonce.

## Existing Guillotine-mini Host + EVM Behavior (required reference)
- Host interface (`src/host.zig`)
  - `HostInterface` vtable functions: `getBalance`, `setBalance`, `getCode`, `setCode`, `getStorage`, `setStorage`, `getNonce`, `setNonce`.
- EVM host touch points (`src/evm.zig`)
  - Uses host methods across call/create paths for account/state mutations and reads.
  - Revert/snapshot logic restores storage, balances, warm access sets, transient state, and selfdestruct tracking.
  - CREATE/CREATE2 paths enforce initcode/code-size and nonce/collision behavior with host-backed writes.

## Test Fixtures Inventory
`ethereum-tests/` directories present:
- `ABITests/`, `BasicTests/`, `BlockchainTests/`, `DifficultyTests/`, `EOFTests/`, `GenesisTests/`, `KeyStoreTests/`, `LegacyTests/`, `PoWTests/`, `RLPTests/`, `TransactionTests/`, `TrieTests/`.
- Fixture bundles present: `ethereum-tests/fixtures_general_state_tests.tgz`, `ethereum-tests/fixtures_blockchain_tests.tgz`.
- `ethereum-tests/GeneralStateTests/` directory is not currently unpacked in this checkout.

`execution-spec-tests/` status:
- Directory exists with `execution-spec-tests/fixtures/`.
- No deeper fixture directories/files were found in this checkout (empty fixture tree at current depth scan).

## Summary
Collected phase-3 goals, execution-spec tx/block processing anchors (Prague/Cancun/London), relevant EIP rule files for gas/accounting and tx types, requested Nethermind.Db key files, Voltaire Zig primitives/state-manager APIs, guillotine-mini host/EVM integration points, and currently available fixture locations (including missing/unpacked fixtures).
