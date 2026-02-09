# [pass 2/5] phase-4-blockchain (Block Chain Management)

## Phase goal (from `prd/GUILLOTINE_CLIENT_PLAN.md`)
- Manage the block chain structure and validation.
- Key components: `client/blockchain/chain.zig`, `client/blockchain/validator.zig`.

## Spec references (from `prd/ETHEREUM_SPECS_REFERENCE.md`)
- `execution-specs/src/ethereum/forks/*/fork.py` (block validation)
- `yellowpaper/Paper.tex` Section “Block Finalisation”

### Execution specs details (read)
- `execution-specs/src/ethereum/forks/prague/fork.py`
  - `state_transition(...)`: validates header, rejects ommers, executes body, checks `state_root`, `transactions_root`, `receipt_root`, `bloom`, `withdrawals_root`, `blob_gas_used`, `requests_hash`, and `gas_used`, then appends to chain with last-255 retention.
  - `validate_header(...)`: checks number sequencing, timestamp monotonicity, gas-used <= gas-limit, base fee (via `calculate_base_fee_per_gas`), PoS fields (difficulty 0, nonce 0), ommers hash, parent hash, excess blob gas, extra_data length.
  - `check_transaction(...)`: gas/blob-gas availability, sender recovery, fee rules (legacy vs EIP-1559), blob versioned hash rules, max fee per blob gas, nonce equality, sender balance sufficiency, and tx-type restrictions.
  - `check_gas_limit(...)`: bounds against parent gas limit +/- adjustment factor and minimum gas limit.
  - `get_last_256_block_hashes(...)`: blockhash window rules for EVM BLOCKHASH.

### Yellow Paper details (read)
- `yellowpaper/Paper.tex` Section “Blocktree to Blockchain” + “Block Finalisation”
  - Canonical chain selection after Paris driven by beacon chain forkchoice events; head and finalized block updates are event-driven (no optimistic head updates).
  - Finalisation stages: execute withdrawals, validate transactions (gasUsed), verify state (state root via trie).
  - Formal functions: withdrawal transition `E`, block-level withdrawal transition `K`, block transition `Φ` and initial state `Γ`.

## Nethermind references
- `nethermind/src/Nethermind/Nethermind.Blockchain/`
  - Key files to mirror architecturally: `BlockTree.cs`, `BlockTree.Initializer.cs`, `BlockTree.AcceptVisitor.cs`, `BlockTreeOverlay.cs`, `BlockhashCache.cs`, `ChainHeadInfoProvider.cs`, `GenesisBuilder.cs`, `InvalidBlockException.cs`, `ReceiptCanonicalityMonitor.cs`, `ReorgDepthFinalizedStateProvider.cs`.
- `nethermind/src/Nethermind/Nethermind.Db/` (required by instructions)
  - Core DB abstractions and implementations: `IDb.cs`, `IColumnsDb.cs`, `IReadOnlyDb.cs`, `IDbProvider.cs`, `DbProvider.cs`, `DbProviderExtensions.cs`, `MemDb.cs`, `MemColumnsDb.cs`, `RocksDbSettings.cs`, `FullPruning/`, `ReadOnlyDb.cs`.

## Voltaire primitives & APIs
- `voltaire/packages/voltaire-zig/src/blockchain/`
  - `BlockStore.zig`, `Blockchain.zig`, `ForkBlockCache.zig` (core chain storage + fork cache helpers)
- `voltaire/packages/voltaire-zig/src/primitives/`
  - Block/chain types: `Block`, `BlockHeader`, `BlockBody`, `BlockHash`, `BlockNumber`, `ChainId`, `ChainHead`, `Hardfork`, `Uncle`.
  - Execution artifacts: `Transaction`, `Receipt`, `Withdrawal`, `BloomFilter`, `Logs`, `StateRoot`, `Gas`, `GasUsed`, `BaseFeePerGas`.
- `voltaire/packages/voltaire-zig/src/state-manager/`
  - `StateManager.zig`, `JournaledState.zig`, `StateCache.zig` (state access needed for validation and receipts/roots).

## Existing guillotine-mini EVM interface
- `src/host.zig`
  - `HostInterface` with vtable methods for `get/setBalance`, `get/setCode`, `get/setStorage`, `get/setNonce`.
  - Note: host interface is **not** used for nested calls; EVM handles nested calls internally.

## Test fixtures
- `ethereum-tests/BlockchainTests/`
- `execution-spec-tests/fixtures/blockchain_tests/`
- `ethereum-tests/fixtures_blockchain_tests.tgz` (archived blockchain fixtures)

## Notes for implementation planning
- Chain validation must follow fork-specific rules (`fork.py`) and Yellow Paper finalisation flow.
- Chain head/finality handling must be consistent with PoS forkchoice events (Yellow Paper “Blocktree to Blockchain”).
- Use Voltaire primitives for all block/receipt/tx/chain types; no custom duplicates.
