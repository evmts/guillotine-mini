# [pass 1/5] phase-5-txpool (Transaction Pool)

## Goal (from `prd/GUILLOTINE_CLIENT_PLAN.md`)
- Implement transaction pool for pending transactions.
- Key components: `client/txpool/pool.zig`, `client/txpool/sorter.zig`.
- Reference: `nethermind/src/Nethermind/Nethermind.TxPool/`.

## Specs (from `prd/ETHEREUM_SPECS_REFERENCE.md`)
- EIP-1559 fee market (type-2 tx, base fee / max fee / priority fee).
- EIP-2930 access lists (type-1 tx with access list costing).
- EIP-4844 blob transactions (type-3 tx with blob fields + blob gas accounting).

### Relevant spec files
- `EIPs/EIPS/eip-1559.md`
  - Defines type-2 tx payload fields `max_priority_fee_per_gas`, `max_fee_per_gas` and intrinsic gas rules (inherits EIP-2930 access list costs).
  - `GASPRICE` opcode returns effective gas price (txpool sorting should use max fee / tip semantics).
- `EIPs/EIPS/eip-2930.md`
  - Defines type-1 tx payload + access list format and intrinsic access list gas costs.
- `EIPs/EIPS/eip-4844.md`
  - Defines type-3 blob tx payload (adds `max_fee_per_blob_gas`, `blob_versioned_hashes`) and header fields `blob_gas_used` / `excess_blob_gas`.

## Nethermind reference
- TxPool module: `nethermind/src/Nethermind/Nethermind.TxPool/` (primary architecture reference).

## Nethermind.Db inventory (requested listing)
From `nethermind/src/Nethermind/Nethermind.Db/`:
- `BlobTxsColumns.cs`
- `CompressingDb.cs`
- `DbProvider.cs`
- `DbExtensions.cs`
- `DbNames.cs`
- `IColumnsDb.cs`
- `IDb.cs`
- `IDbFactory.cs`
- `IDbProvider.cs`
- `IFullDb.cs`
- `IMergeOperator.cs`
- `IPruningConfig.cs`
- `IReadOnlyDb.cs`
- `IReadOnlyDbProvider.cs`
- `ITunableDb.cs`
- `InMemoryColumnBatch.cs`
- `InMemoryWriteBatch.cs`
- `MemColumnsDb.cs`
- `MemDb.cs`
- `MemDbFactory.cs`
- `MetadataDbKeys.cs`
- `Metrics.cs`
- `Nethermind.Db.csproj`
- `NullDb.cs`
- `NullRocksDbFactory.cs`
- `PruningConfig.cs`
- `PruningMode.cs`
- `ReadOnlyColumnsDb.cs`
- `ReadOnlyDb.cs`
- `ReadOnlyDbProvider.cs`
- `ReceiptsColumns.cs`
- `RocksDbMergeEnumerator.cs`
- `RocksDbSettings.cs`
- `SimpleFilePublicKeyDb.cs`
- Directories: `Blooms/`, `FullPruning/`

## Voltaire Zig APIs
- Requested path `/Users/williamcory/voltaire/packages/voltaire-zig/src/` does not exist on disk.
  - Checked `/Users/williamcory/voltaire` and searched for `voltaire-zig` in that repo; no matches found.
  - If this should point elsewhere, update path before next pass.

## Existing Zig Host Interface
From `src/host.zig`:
- `HostInterface` provides minimal EVM host access: `getBalance`, `setBalance`, `getCode`, `setCode`, `getStorage`, `setStorage`, `getNonce`, `setNonce`.
- The EVM `inner_call` uses `CallParams/CallResult` and does not call this host interface for nested calls.

## Test fixtures (ethereum-tests)
Top-level directories under `ethereum-tests/`:
- `ABITests/`
- `BasicTests/`
- `BlockchainTests/`
- `DifficultyTests/`
- `EOFTests/`
- `GenesisTests/`
- `JSONSchema/`
- `KeyStoreTests/`
- `LegacyTests/`
- `PoWTests/`
- `RLPTests/`
- `TransactionTests/`
- `TrieTests/`
- `docs/`
- `src/`
- `fixtures_blockchain_tests.tgz`
- `fixtures_general_state_tests.tgz`

## Summary
Collected phase-5 txpool goals, relevant EIP specs (1559/2930/4844), Nethermind.Db inventory, host interface details, and ethereum-tests fixture locations. The Voltaire Zig path specified in the instructions is missing in `/Users/williamcory/voltaire` and needs correction before pulling Zig API references.
