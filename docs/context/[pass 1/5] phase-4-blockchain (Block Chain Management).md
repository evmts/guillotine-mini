# Context: Phase 4 Block Chain Management

## Goal (from prd/GUILLOTINE_CLIENT_PLAN.md)

- Manage the block chain structure and validation.
- Key components: `client/blockchain/chain.zig`, `client/blockchain/validator.zig` (Zig reference for parity).
- References: `nethermind/src/Nethermind/Nethermind.Blockchain/`, `voltaire/packages/voltaire-zig/src/blockchain/`.
- Test fixtures: `ethereum-tests/BlockchainTests/`.

## Specs to Read First (from prd/ETHEREUM_SPECS_REFERENCE.md)

- `execution-specs/src/ethereum/forks/*/fork.py` (block validation per fork).
- Yellow Paper Section 11 (Block Finalization) — locate under `yellowpaper/` if present.
- Tests: `execution-spec-tests/fixtures/blockchain_tests/`.
- Related: `execution-spec-tests/fixtures/blockchain_tests_engine/` (engine-focused blockchain tests).
- P2P context if needed later: `devp2p/caps/eth.md` (block/header exchange).

## Nethermind.Db Reference Inventory

Listed from `nethermind/src/Nethermind/Nethermind.Db/`:

- Core DB interfaces: `IDb.cs`, `IColumnsDb.cs`, `IDbFactory.cs`, `IDbProvider.cs`, `IFullDb.cs`, `IReadOnlyDb.cs`, `IReadOnlyDbProvider.cs`, `ITunableDb.cs`, `IMergeOperator.cs`.
- Providers/config: `DbProvider.cs`, `DbProviderExtensions.cs`, `DbNames.cs`, `DbExtensions.cs`, `PruningConfig.cs`, `PruningMode.cs`, `RocksDbSettings.cs`.
- In-memory: `MemDb.cs`, `MemDbFactory.cs`, `MemColumnsDb.cs`, `InMemoryColumnBatch.cs`, `InMemoryWriteBatch.cs`.
- Read-only wrappers: `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `ReadOnlyDbProvider.cs`.
- Maintenance/metrics: `Metrics.cs`, `RocksDbMergeEnumerator.cs`, `FullPruning/*`, `FullPruningTrigger.cs`, `FullPruningCompletionBehavior.cs`.
- Columns/metadata: `BlobTxsColumns.cs`, `ReceiptsColumns.cs`, `MetadataDbKeys.cs`.
- Other: `NullDb.cs`, `NullRocksDbFactory.cs`, `SimpleFilePublicKeyDb.cs`, `CompressingDb.cs`.

## voltaire-effect APIs (source: /Users/williamcory/voltaire/voltaire-effect/src/index.ts)

Focus on primitives and modules needed for chain management and validation. Relevant exports:

- Primitives: `Block`, `BlockHeader`, `BlockBody`, `BlockHash`, `BlockNumber`, `BloomFilter`, `Receipt`, `Transaction`, `Chain`, `ChainHead`, `StateRoot`, `Gas`, `GasUsed`, `GasPrice`, `BaseFeePerGas`, `Nonce`, `Hash`, `Hex`, `Bytes`, `Rlp`.
- Crypto: `Keccak256` (block/tx hashing), `KZG` (blob-related validation if used), `Secp256k1` (signature checks).
- Utilities: `BlockUtils` (block streaming/fetching helper layer).

Use voltaire-effect primitives only for Ethereum types (Address/Hash/Hex/etc.) — no custom Ethereum types.

## Effect.ts Patterns (source: effect-repo/packages/effect/src/)

Notable modules/patterns for idiomatic implementation:

- DI: `Context`, `Layer` (use `Context.Tag` + `Layer.scoped/effect/succeed/merge`).
- Composition: `Effect`, `Effect.gen`, `pipe` (`Function.ts`).
- Validation: `Schema`, `ParseResult`.
- Resource safety: `Scope`, `Effect.acquireRelease`.
- Errors: `Data` (TaggedError), `Cause`, `Exit`.
- Collections: `Option`, `Either`, `Chunk`, `HashMap`, `HashSet`.

## Existing client-ts Patterns (Effect.ts client)

Files reviewed:

- `client-ts/evm/TransactionProcessor.ts`: Context.Tag service + Layer.effect; Schema decoding at boundary; Effect.gen for sequential logic; explicit error union.
- `client-ts/db/Db.ts`: Context.Tag Db service; Schema validation; Effect.acquireRelease for in-memory store; write batch APIs; scoped Layer.
- `client-ts/state/State.ts`: WorldState service using Journal; snapshot handling; uses voltaire-effect primitives (Address/Storage/etc.).
- `client-ts/state/Journal.ts`: Change journal with snapshots; Effect.gen; TaggedError for InvalidSnapshot.
- Tests: `client-ts/db/Db.test.ts` uses `@effect/vitest` `it.effect` and provides Layer in tests.

## Test Fixtures (filesystem)

- `ethereum-tests/BlockchainTests/`
- `ethereum-tests/fixtures_blockchain_tests.tgz` (archived fixtures)
- `execution-spec-tests/fixtures/blockchain_tests/`
- `execution-spec-tests/fixtures/blockchain_tests_engine/`

## Notes for Implementation

- Read fork-specific block validation in `execution-specs/src/ethereum/forks/*/fork.py` before coding.
- Use Nethermind blockchain architecture for structure (not implementation details) and map it into Effect.ts services/layers.
- Maintain voltaire-effect primitives throughout (Block/BlockHeader/etc.).
- Follow existing client-ts layering/style and avoid `Effect.runPromise` except at the app edge.
