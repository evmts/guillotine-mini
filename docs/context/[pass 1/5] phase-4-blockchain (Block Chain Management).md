# [Pass 1/5] Phase 4: Block Chain Management - Context

## Goal (from prd/GUILLOTINE_CLIENT_PLAN.md)
Manage the block chain structure and validation.

Planned modules:
- client/blockchain/chain.zig (chain management)
- client/blockchain/validator.zig (block validation)

## Spec references (from prd/ETHEREUM_SPECS_REFERENCE.md)
- execution-specs/src/ethereum/forks/*/fork.py (block validation, state transition)
- yellowpaper/Paper.tex Section 11 (Block Finalisation)
- ethereum-tests/BlockchainTests/
- execution-spec-tests/fixtures/blockchain_tests/

## execution-specs (prague fork) notes
Source: execution-specs/src/ethereum/forks/prague/fork.py

Key validation and transition touchpoints:
- state_transition validates header, enforces no ommers, builds BlockEnvironment, applies body, then checks:
  - gas_used, transactions_root, state_root, receipt_root, logs bloom, withdrawals_root, blob_gas_used, requests_hash
- validate_header checks parent linkage and header invariants:
  - gas_used <= gas_limit
  - base_fee_per_gas computed from parent
  - timestamp strictly increases
  - number increments by 1
  - extra_data length <= 32
  - difficulty == 0, nonce == 0, ommers_hash == EMPTY_OMMER_HASH
  - parent_hash matches keccak(rlp(parent_header))
- apply_body processes system transactions (beacon roots, history storage), user transactions, withdrawals, then requests

## EIP-1559 base fee and gas limit rules
Source: EIPs/EIPS/eip-1559.md

Relevant checks:
- gas_used must be <= gas_limit
- gas_limit change bounded by parent_gas_limit / 1024
- base_fee_per_gas adjusted by parent gas usage with BASE_FEE_MAX_CHANGE_DENOMINATOR = 8

## Yellow Paper Section 11 (Block Finalisation)
Source: yellowpaper/Paper.tex (Section 11)

Key rules:
- finalisation stages: execute withdrawals, validate transactions, verify state
- withdrawals increase recipient balance by the Gwei amount; no gas cost; cannot fail
- header gasUsed must match cumulative gas used after last transaction
- stateRoot must match the TRIE root after transactions and withdrawals

## devp2p eth protocol (caps/eth.md)
Source: devp2p/caps/eth.md

Relevant chain sync points:
- Status handshake required before other messages
- enforce message size limits (protocol recommends lower than RLPx max)
- header download via GetBlockHeaders; bodies via GetBlockBodies
- block bodies must validate against headers before execution

## Nethermind references
Primary architecture reference:
- nethermind/src/Nethermind/Nethermind.Blockchain/

Nethermind.Db listing (requested for context):
- IDb.cs, IReadOnlyDb.cs, IColumnsDb.cs, IFullDb.cs
- DbProvider.cs, DbProviderExtensions.cs, DbNames.cs
- RocksDbSettings.cs, RocksDbMergeEnumerator.cs
- MemDb.cs, MemDbFactory.cs, MemColumnsDb.cs
- ReadOnlyDb.cs, ReadOnlyColumnsDb.cs, ReadOnlyDbProvider.cs
- PruningConfig.cs, PruningMode.cs, FullPruning/
- BlobTxsColumns.cs, ReceiptsColumns.cs, MetadataDbKeys.cs
- InMemoryColumnBatch.cs, InMemoryWriteBatch.cs

## Voltaire primitives to use (never reimplement)
Relevant APIs under /Users/williamcory/voltaire/packages/voltaire-zig/src:
- blockchain/Blockchain.zig (Blockchain)
- blockchain/BlockStore.zig (BlockStore)
- blockchain/ForkBlockCache.zig (ForkBlockCache)
- primitives/Block (Block, BlockHeader, BlockBody, Transactions, Receipts)
- primitives/Hash (Hash)
- primitives/Address (Address)
- state-manager (world state, snapshots)
- evm (EVM execution integration)
- crypto (keccak256 and hashing primitives)

## Existing Zig files to integrate with
src/host.zig
- HostInterface vtable for get/set balance, code, storage, nonce
- Uses primitives.Address.Address and u256

## Test fixtures
- ethereum-tests/BlockchainTests/
- execution-spec-tests/fixtures/blockchain_tests/ (from spec reference; verify presence)
- ethereum-tests/fixtures_blockchain_tests.tgz (archived fixtures)

## Paths read in this pass
- prd/GUILLOTINE_CLIENT_PLAN.md
- prd/ETHEREUM_SPECS_REFERENCE.md
- execution-specs/src/ethereum/forks/prague/fork.py
- EIPs/EIPS/eip-1559.md
- yellowpaper/Paper.tex
- devp2p/caps/eth.md
- src/host.zig
- nethermind/src/Nethermind/Nethermind.Db/
- /Users/williamcory/voltaire/packages/voltaire-zig/src/
- /Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/
- ethereum-tests/
