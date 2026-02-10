# Context: [pass 1/5] phase-4-blockchain (Block Chain Management)

## Goal (from prd/GUILLOTINE_CLIENT_PLAN.md)

- Manage the block chain structure and validation.
- Key components: `client/blockchain/chain.zig`, `client/blockchain/validator.zig`.
- Architecture reference: `nethermind/src/Nethermind/Nethermind.Blockchain/`.
- Voltaire reference: `voltaire/packages/voltaire-zig/src/blockchain/`.
- Test fixtures: `ethereum-tests/BlockchainTests/`.

## Specs to Read First (from prd/ETHEREUM_SPECS_REFERENCE.md + execution-specs)

- `execution-specs/src/ethereum/forks/*/fork.py` (block validation per fork).
- Yellow Paper Section 11 (Block Finalization) under `yellowpaper/`.
- Tests: `ethereum-tests/BlockchainTests/` and `execution-spec-tests/fixtures/blockchain_tests/`.

### execution-specs spot check (cancun fork)

Source: `execution-specs/src/ethereum/forks/cancun/fork.py`

- `BlockChain` dataclass holds `blocks`, `state`, `chain_id`.
- `state_transition(chain, block)`:
- Validates header with `validate_header` and rejects non-empty `ommers`.
- Builds `vm.BlockEnvironment` from header fields, applies body, computes roots/bloom.
- Validates `gas_used`, `transactions_root`, `state_root`, `receipt_root`, `bloom`, `withdrawals_root`, `blob_gas_used`.
- Appends block and keeps only the latest 255 blocks in `chain.blocks`.
- `validate_header(chain, header)`:
- Enforces `header.number >= 1` and proper parent linkage.
- Checks `excess_blob_gas`, `gas_used <= gas_limit`, and `base_fee_per_gas` via `calculate_base_fee_per_gas`.
- Enforces timestamp increase, number increment, `extra_data <= 32`.
- Requires `difficulty == 0`, `nonce == 0`, `ommers_hash == EMPTY_OMMER_HASH`.
- Verifies `parent_hash` via RLP of parent header.

## Nethermind.Db Reference Inventory

Listed from `nethermind/src/Nethermind/Nethermind.Db/`:

- Core DB interfaces: `IDb.cs`, `IColumnsDb.cs`, `IDbFactory.cs`, `IDbProvider.cs`, `IFullDb.cs`, `IReadOnlyDb.cs`, `IReadOnlyDbProvider.cs`, `ITunableDb.cs`, `IMergeOperator.cs`.
- Providers/config: `DbProvider.cs`, `DbProviderExtensions.cs`, `DbNames.cs`, `DbExtensions.cs`, `PruningConfig.cs`, `PruningMode.cs`, `RocksDbSettings.cs`.
- In-memory: `MemDb.cs`, `MemDbFactory.cs`, `MemColumnsDb.cs`, `InMemoryColumnBatch.cs`, `InMemoryWriteBatch.cs`.
- Read-only wrappers: `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `ReadOnlyDbProvider.cs`.
- Maintenance/metrics: `Metrics.cs`, `RocksDbMergeEnumerator.cs`, `FullPruning/`, `FullPruningTrigger.cs`, `FullPruningCompletionBehavior.cs`.
- Columns/metadata: `BlobTxsColumns.cs`, `ReceiptsColumns.cs`, `MetadataDbKeys.cs`.
- Other: `NullDb.cs`, `NullRocksDbFactory.cs`, `SimpleFilePublicKeyDb.cs`, `CompressingDb.cs`.

## Voltaire Zig Primitives

- Attempted to list `/Users/williamcory/voltaire/packages/voltaire-zig/src/` and `voltaire/packages/voltaire-zig/src`, but both paths do not exist in this workspace. The Voltaire Zig primitives need to be located or the submodule path updated before implementation.
- Available Voltaire root at `/Users/williamcory/voltaire/src/` contains `blockchain/`, `block/`, `state-manager/`, `primitives/`, `evm/`, `jsonrpc/`, and `crypto/` alongside Zig entrypoints (`root.zig`, `c_api.zig`, `log.zig`).

## Existing EVM Host Interface (src/host.zig)

- `HostInterface` vtable provides minimal external state access:
- `getBalance` / `setBalance`
- `getCode` / `setCode`
- `getStorage` / `setStorage`
- `getNonce` / `setNonce`

## Test Fixtures (filesystem)

- `ethereum-tests/ABITests/`
- `ethereum-tests/BasicTests/`
- `ethereum-tests/BlockchainTests/`
- `ethereum-tests/DifficultyTests/`
- `ethereum-tests/EOFTests/`
- `ethereum-tests/GenesisTests/`
- `ethereum-tests/JSONSchema/`
- `ethereum-tests/KeyStoreTests/`
- `ethereum-tests/LegacyTests/`
- `ethereum-tests/PoWTests/`
- `ethereum-tests/RLPTests/`
- `ethereum-tests/TransactionTests/`
- `ethereum-tests/TrieTests/`
- `ethereum-tests/fixtures_blockchain_tests.tgz`
- `ethereum-tests/fixtures_general_state_tests.tgz`
- `execution-spec-tests/` exists but is empty in this workspace (no fixtures present).

## Notes for Implementation

- Read fork-specific `fork.py` before coding validation logic; mirror logic per active fork.
- Use Voltaire Zig primitives for all Ethereum types (path currently missing).
- Use the existing EVM in `src/` and the `HostInterface` for external state access.
