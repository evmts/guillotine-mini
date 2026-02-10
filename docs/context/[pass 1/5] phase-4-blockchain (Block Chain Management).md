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

## execution-specs (Prague fork) highlights
Source: execution-specs/src/ethereum/forks/prague/fork.py
- state_transition: validate_header, reject non-empty ommers, build BlockEnvironment, apply_body, compute roots/bloom/requests hash, compare to header, append block.
- validate_header: header.number >= 1, parent header from chain tip; compute excess_blob_gas; gas_used <= gas_limit; base_fee_per_gas computed from parent; timestamp strictly increasing; number increments by 1; extra_data length <= 32; difficulty == 0; nonce == 0; ommers_hash == EMPTY_OMMER_HASH; parent_hash matches keccak(rlp(parent_header)).
- apply_body: executes system transactions, user transactions, withdrawals; returns block_gas_used, receipts trie, withdrawals trie, logs bloom, blob gas, and requests hash components used for header validation.

## EIP-1559 base fee and gas limit guardrails
Source: EIPs/EIPS/eip-1559.md
- gas_used must be <= gas_limit.
- gas_limit bounded by parent_gas_limit +/- parent_gas_limit // 1024.
- base_fee_per_gas computed from parent gas target (parent_gas_limit / ELASTICITY_MULTIPLIER), with BASE_FEE_MAX_CHANGE_DENOMINATOR = 8.
- fork block uses INITIAL_BASE_FEE; otherwise base fee follows parent gas used vs target formula.

## Yellow Paper Section 11 (Block Finalisation)
Source: yellowpaper/Paper.tex
- Finalisation stages: execute withdrawals, validate transactions, verify state.
- Withdrawals: balance increase by withdrawal amount in Gwei, no gas cost, cannot fail.
- gasUsed in header must equal cumulative gas used after last transaction.
- stateRoot equals trie root after executing transactions and withdrawals.

## devp2p ETH protocol notes (chain sync context)
Source: devp2p/caps/eth.md
- Status must be exchanged before other ETH messages.
- RLPx hard limit is 16.7 MiB; eth protocol practical limit ~10 MiB; enforce hard/soft message limits.
- Sync uses GetBlockHeaders then GetBlockBodies; block bodies must validate against headers before execution.
- Receipts are fetched separately (GetReceipts) when needed for non-executing sync paths.

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

## Voltaire primitives (must use; do not reimplement)
Relevant APIs under /Users/williamcory/voltaire/packages/voltaire-zig/src:
- blockchain/Blockchain.zig (Blockchain)
- blockchain/BlockStore.zig (BlockStore)
- blockchain/ForkBlockCache.zig (ForkBlockCache)
- primitives/Block.zig (Block, BlockHeader, BlockBody, Transactions, Receipts)
- primitives/Hash.zig (Hash)
- primitives/Address.zig (Address)
- state-manager/ (world state, snapshots)
- evm/ (EVM execution integration)
- crypto/ (keccak256 and hashing primitives)

## Existing Zig integration points
src/host.zig
- HostInterface vtable for get/set balance, code, storage, nonce.
- Uses primitives.Address.Address and u256.
- EVM inner_call does not use HostInterface for nested calls.

## Test fixtures
- ethereum-tests/BlockchainTests/
- execution-spec-tests/fixtures/blockchain_tests/
- ethereum-tests/fixtures_blockchain_tests.tgz

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
- execution-spec-tests/fixtures/
