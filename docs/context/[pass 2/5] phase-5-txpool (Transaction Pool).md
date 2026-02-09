# [pass 2/5] phase-5-txpool (Transaction Pool)

## Goal (from plan)

Implement the transaction pool for pending transactions, including:
- `client/txpool/pool.zig` — pool storage, admission, eviction
- `client/txpool/sorter.zig` — prioritization (gas price / tip / blob fee)

---

## Specs to Anchor Behavior

### EIPs (core transaction formats + pricing)

- `EIPs/EIPS/eip-1559.md` — type 2 fee market transactions (`max_fee_per_gas`, `max_priority_fee_per_gas`), effective gas price, base fee checks.
- `EIPs/EIPS/eip-2930.md` — type 1 access list transactions; access list structure + intrinsic cost additions.
- `EIPs/EIPS/eip-4844.md` — type 3 blob transactions; `max_fee_per_blob_gas`, `blob_versioned_hashes`, blob gas accounting, non-null `to`.

### Execution-specs (authoritative validation + intrinsic gas)

- `execution-specs/src/ethereum/forks/prague/transactions.py`
  - Defines all transaction types (legacy, 2930, 1559, 4844, 7702).
  - Intrinsic gas constants: `TX_BASE_COST`, `TX_ACCESS_LIST_*`, calldata costs, create cost, and post-Prague rules (EIP-7623 floor calldata cost).
  - Signature validation + error surfaces (invalid signature, nonce overflow, insufficient intrinsic gas).

Note: If targeting pre-Prague fork, use the corresponding fork’s `transactions.py` for the active chain rules.

---

## Nethermind Architecture References

### TxPool module

Key files in `nethermind/src/Nethermind/Nethermind.TxPool/`:
- `TxPool.cs`, `ITxPool.cs` — core pool interface + implementation.
- `TxPoolConfig.cs` — pool sizing, eviction, and policy configuration.
- `TxSealer.cs`, `ITxSealer.cs` — sealing/extraction of best transactions for block assembly.
- `TxBroadcaster.cs` — gossip/broadcast integration.
- `ITxValidator.cs`, `TransactionExtensions.cs` — validation hooks, sender recovery, and tx utilities.
- `NonceManager.cs`, `INonceManager.cs`, `NonceLocker.cs` — per-sender nonce tracking and reservation.
- `SpecDrivenTxGossipPolicy.cs`, `ITxGossipPolicy.cs` — fork-aware gossip rules.
- `BlobTxStorage.cs`, `IBlobTxStorage.cs` — blob tx storage and pruning.
- `TxFilteringState.cs`, `TxHandlingOptions.cs` — filter policies (underpriced, replaced, etc).

### Nethermind.Db (storage backing primitives)

Files in `nethermind/src/Nethermind/Nethermind.Db/` relevant for storage patterns:
- `IDb.cs`, `IReadOnlyDb.cs`, `IColumnsDb.cs` — DB abstraction.
- `DbProvider.cs`, `DbProviderExtensions.cs` — DB lifecycle and wiring.
- `MemDb.cs`, `MemColumnsDb.cs` — in-memory implementations (useful for tests).
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs` — persistent storage tuning.

---

## Voltaire Primitives (must-use)

Relevant APIs in `/Users/williamcory/voltaire/packages/voltaire-zig/src/`:
- `primitives/Transaction/Transaction.zig`
  - `TransactionType`
  - `LegacyTransaction`, `Eip2930Transaction`, `Eip1559Transaction`, `Eip4844Transaction`, `Eip7702Transaction`
  - `AccessListItem`
  - signing/encoding helpers (RLP)
- `primitives/AccessList/`, `primitives/Nonce/`, `primitives/Address/`, `primitives/Hash/`, `primitives/Signature/`
- `primitives/Gas/`, `primitives/GasPrice/`, `primitives/MaxFeePerGas/`, `primitives/MaxPriorityFeePerGas/`, `primitives/EffectiveGasPrice/`
- `primitives/BaseFeePerGas/`, `primitives/Blob/` (e.g., `VersionedHash`)
- `primitives/Rlp/` for encoding/decoding

---

## Existing Zig Integration Points

- `src/host.zig` — EVM `HostInterface` vtable for state access. Any txpool simulation/validation that needs EVM execution must reuse the existing EVM + host patterns (no reimplementation).

---

## Test Fixtures to Reuse

From `ethereum-tests/`:
- `ethereum-tests/TransactionTests/` — transaction format + signature correctness.
- `ethereum-tests/RLPTests/` — RLP decoding/encoding corner cases for raw txs.
- `ethereum-tests/BasicTests/` — basic transaction validity patterns (if needed).

Additional available fixtures:
- `execution-spec-tests/` (if tx validity fixtures are needed beyond classic tests).

