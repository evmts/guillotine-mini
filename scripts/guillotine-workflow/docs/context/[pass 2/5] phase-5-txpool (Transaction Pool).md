# Context: Phase 5 - Transaction Pool (pass 2/5)

## Plan goals (from prd/GUILLOTINE_CLIENT_PLAN.md)
- Phase 5 txpool goal: implement pending transaction pool.
- Key components: `client/txpool/pool.zig`, `client/txpool/sorter.zig`.
- Architecture reference: Nethermind `nethermind/src/Nethermind/Nethermind.TxPool/`.

## Spec references (from prd/ETHEREUM_SPECS_REFERENCE.md)
- Phase 5 specs: EIP-1559 (fee market), EIP-2930 (access lists), EIP-4844 (blob txs).
- Tests: unit tests + integration tests (no specific fixture called out in plan).

## Relevant spec files read
- `repo_link/EIPs/EIPS/eip-1559.md` (type-2 tx format, max fee and priority fee semantics).
- `repo_link/EIPs/EIPS/eip-2930.md` (type-1 tx format, access list structure and costs).
- `repo_link/EIPs/EIPS/eip-4844.md` (type-3 blob tx format, max_fee_per_blob_gas, blob_versioned_hashes, blob gas rules).
- `repo_link/execution-specs/src/ethereum/forks/berlin/transactions.py` (access list tx types and intrinsic gas constants).
- `repo_link/execution-specs/src/ethereum/forks/london/transactions.py` (EIP-1559 tx types and intrinsic gas constants).
- `repo_link/execution-specs/src/ethereum/forks/cancun/transactions.py` (EIP-4844 tx types and VersionedHash).

## Nethermind DB folder listing (nethermind/src/Nethermind/Nethermind.Db/)
Key files to mirror structural patterns and common DB interfaces:
- `repo_link/nethermind/src/Nethermind/Nethermind.Db/IDb.cs`
- `repo_link/nethermind/src/Nethermind/Nethermind.Db/IColumnsDb.cs`
- `repo_link/nethermind/src/Nethermind/Nethermind.Db/IFullDb.cs`
- `repo_link/nethermind/src/Nethermind/Nethermind.Db/IDbProvider.cs`
- `repo_link/nethermind/src/Nethermind/Nethermind.Db/IReadOnlyDb.cs`
- `repo_link/nethermind/src/Nethermind/Nethermind.Db/DbProvider.cs`
- `repo_link/nethermind/src/Nethermind/Nethermind.Db/MemDb.cs`
- `repo_link/nethermind/src/Nethermind/Nethermind.Db/MemColumnsDb.cs`
- `repo_link/nethermind/src/Nethermind/Nethermind.Db/RocksDbSettings.cs`
- `repo_link/nethermind/src/Nethermind/Nethermind.Db/DbNames.cs`

## Voltaire primitives (voltaire-zig/src)
Relevant APIs and modules to use instead of custom types:
- `primitives/Transaction` (typed transaction envelopes).
- `primitives/TransactionHash`, `primitives/Hash`.
- `primitives/Nonce`, `primitives/Gas`, `primitives/GasPrice`.
- `primitives/MaxFeePerGas`, `primitives/MaxPriorityFeePerGas`.
- `primitives/AccessList`.
- `primitives/Blob`, `primitives/VersionedHash` (EIP-4844).
- `primitives/ChainId`, `primitives/Address`.
- `primitives/Signature`, `primitives/Rlp` (encoding/decoding).

## Existing Zig host interface
- `repo_link/src/host.zig`: `HostInterface` vtable for balance, code, storage, nonce access. This is the EVM host ABI used by guillotine-mini.

## Ethereum tests fixture directories
Candidate fixtures for txpool-related validation and transaction parsing:
- `repo_link/ethereum-tests/TransactionTests/`
- `repo_link/ethereum-tests/BasicTests/`
- `repo_link/ethereum-tests/BlockchainTests/`
- `repo_link/ethereum-tests/LegacyTests/`
- `repo_link/ethereum-tests/RLPTests/`

## Summary
Collected the Phase 5 txpool goals, mapped EIP specs (1559/2930/4844) and execution-specs transaction definitions for Berlin/London/Cancun, noted Nethermind DB interfaces for structural reference, identified relevant Voltaire primitive modules for transaction pool types, captured the existing EVM HostInterface, and listed available ethereum-tests fixture directories likely to supply transaction-level test vectors.
