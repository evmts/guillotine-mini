# [Pass 1/5] Phase 4: Block Chain Management - Context

## Goal (from prd/GUILLOTINE_CLIENT_PLAN.md)
Manage the block chain structure and validation. Planned modules:
- client/blockchain/chain.zig (chain management)
- client/blockchain/validator.zig (block validation)

## Spec References (from prd/ETHEREUM_SPECS_REFERENCE.md)
Authoritative specs and tests:
- execution-specs/src/ethereum/forks/*/fork.py (block validation, state transition)
- yellowpaper/Paper.tex Section 11 (Block Finalisation)
- ethereum-tests/BlockchainTests/
- execution-spec-tests/fixtures/blockchain_tests/
- execution-spec-tests/fixtures/blockchain_tests_engine/

## execution-specs fork.py (cancun)
Key validation and transition touchpoints in execution-specs/src/ethereum/forks/cancun/fork.py:
- BlockChain dataclass: blocks list + state + chain_id
- state_transition: validate_header, apply_body, compute state root / tx root / receipts root / logs bloom / withdrawals root, then verify header fields
- validate_header: gas limit checks, base fee, timestamp monotonicity, block number increment, extra_data length, PoS header constraints (difficulty=0, nonce=0, ommers_hash = EMPTY_OMMER_HASH), parent_hash from parent header
- check_transaction: gas limit accounting, nonce/balance checks, max fee/max priority fee checks, blob gas checks, sender recovery
- apply_body: transaction loop, receipts/transactions trie roots, withdrawals processing

## Yellow Paper Section 11 (Block Finalisation)
Key block-level rules in yellowpaper/Paper.tex (Section 11):
- Finalisation stages: execute withdrawals, validate transactions, verify state
- Withdrawals increase recipient balance by gwei amount, no gas cost, no failure
- gasUsed in header must equal cumulative gas used per transaction
- State validation ties block state root to the post-transaction + post-withdrawal state via TRIE

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
- blockchain/Blockchain.zig: Blockchain
- blockchain/BlockStore.zig: BlockStore
- blockchain/ForkBlockCache.zig: ForkBlockCache
- primitives/Block/ (Block, Header, Transactions, Receipts)
- primitives/Hash/Hash.zig (Hash type)
- primitives/Address/Address.zig (Address)
- state-manager/ (state access and snapshots, if used by chain validation)
- evm/ (EVM execution integration)
- crypto/ (keccak256, hashes)

## Existing Zig files to integrate with
src/host.zig
- HostInterface vtable for get/set balance, code, storage, nonce
- Uses primitives.Address.Address and u256

## Test fixtures
ethereum-tests/BlockchainTests/
- Canonical JSON blockchain fixtures

execution-spec-tests fixtures:
- execution-spec-tests/fixtures/blockchain_tests/
- execution-spec-tests/fixtures/blockchain_tests_engine/

Additional ethereum-tests assets:
- ethereum-tests/fixtures_blockchain_tests.tgz (archived fixtures)

## Paths read in this pass
- prd/GUILLOTINE_CLIENT_PLAN.md
- prd/ETHEREUM_SPECS_REFERENCE.md
- execution-specs/src/ethereum/forks/cancun/fork.py
- yellowpaper/Paper.tex
- src/host.zig
- nethermind/src/Nethermind/Nethermind.Db/
- /Users/williamcory/voltaire/packages/voltaire-zig/src/
- ethereum-tests/
