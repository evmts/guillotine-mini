# [Pass 1/5] Phase 4: Block Chain Management - Context

## Goal (from prd/GUILLOTINE_CLIENT_PLAN.md)
Manage the block chain structure and validation. Planned modules:
- client/blockchain/chain.zig (chain management)
- client/blockchain/validator.zig (block validation)

## Spec References (from prd/ETHEREUM_SPECS_REFERENCE.md)
Authoritative specs and tests:
- execution-specs/src/ethereum/forks/*/fork.py (block validation, state transition)
- yellowpaper/Paper.tex Section 11 (Block Finalisation)
- devp2p/caps/eth.md (block and header exchange)
- ethereum-tests/BlockchainTests/
- execution-spec-tests/fixtures/blockchain_tests/
- execution-spec-tests/fixtures/blockchain_tests_engine/ (listed in PRD; not present in this repo)

## execution-specs fork.py (prague)
Key validation and transition touchpoints in execution-specs/src/ethereum/forks/prague/fork.py:
- BlockChain structure: chain_id, state, blocks list
- state_transition: validate_header, apply_body, compute state root / tx root / receipts root / logs bloom / withdrawals root / requests hash, then verify header fields
- validate_header: gas limit checks, base fee calculation, timestamp monotonicity, block number increment, extra_data length, PoS header constraints (difficulty=0, nonce=0, ommers_hash=EMPTY_OMMER_HASH), parent_hash from parent header
- calculate_base_fee_per_gas: gas target logic and bounded base fee change
- apply_body and transaction processing: block gas used, blob gas used, sender recovery, fee checks

## EIP-1559 base fee rules
Relevant base fee and gas limit checks in EIPs/EIPS/eip-1559.md:
- header gas_used must be <= gas_limit
- gas_limit change bounds vs parent (delta <= parent / 1024)
- base fee computed from parent gas used and target, with MAX_CHANGE_DENOMINATOR bounds

## Yellow Paper Section 11 (Block Finalisation)
Key block-level rules in yellowpaper/Paper.tex (Section 11):
- Finalisation stages: execute withdrawals, validate transactions, verify state
- Withdrawals increase recipient balance by gwei amount, no gas cost, no failure
- gasUsed in header equals accumulated gas used after final transaction
- State validation ties header state root to post-transaction and post-withdrawal state via TRIE

## devp2p ETH protocol (caps/eth.md)
Chain and header exchange details:
- Status exchange gates session activation; size limits on messages
- Header sync by GetBlockHeaders, then bodies via GetBlockBodies
- Retrieved block bodies must validate against headers before execution
- Block header encoding fields used for validation and body matching

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
- primitives/Block/ (Block, Header, Transactions, Receipts)
- primitives/Hash/Hash.zig (Hash)
- primitives/Address/Address.zig (Address)
- state-manager/ (state access and snapshots)
- evm/ (EVM execution integration)
- crypto/ (keccak256 and hashing primitives)

## Existing Zig files to integrate with
src/host.zig
- HostInterface vtable for get/set balance, code, storage, nonce
- Uses primitives.Address.Address and u256

## Test fixtures
ethereum-tests/BlockchainTests/
- Canonical JSON blockchain fixtures

execution-spec-tests fixtures:
- execution-spec-tests/fixtures/blockchain_tests/ (symlink to ethereum-tests/BlockchainTests)
- execution-spec-tests/fixtures/blockchain_tests_engine/ (missing in this repo)

Additional ethereum-tests assets:
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
- execution-spec-tests/fixtures/
