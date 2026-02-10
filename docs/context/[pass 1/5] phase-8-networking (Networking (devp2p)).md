# [Pass 1/5] Phase 8: Networking (devp2p) - Focused Context

## 1. Phase Goal and Scope

Source: `prd/GUILLOTINE_CLIENT_PLAN.md`

- Goal: implement devp2p networking for peer communication.
- Planned Zig component targets:
- `client/net/rlpx.zig` (RLPx transport)
- `client/net/discovery.zig` (discv4/discv5)
- `client/net/eth.zig` (eth protocol)
- Structural reference for this phase: `nethermind/src/Nethermind/Nethermind.Network/`.

## 2. Spec Files to Anchor Implementation

Source: `prd/ETHEREUM_SPECS_REFERENCE.md` (Phase 8 section)

- `devp2p/rlpx.md`
- `devp2p/caps/eth.md`
- `devp2p/caps/snap.md`
- `devp2p/discv4.md`
- `devp2p/discv5/discv5.md`
- `devp2p/enr.md`

Quick extraction from the docs above:

- `devp2p/rlpx.md`: handshake (auth/ack), ECDH-derived secrets, AES-CTR frame encryption, keccak-based ingress/egress MAC streams, capability negotiation.
- `devp2p/caps/eth.md`: status handshake gate, sync and tx exchange semantics, request/response size constraints, current protocol text documents `eth/69`.
- `devp2p/caps/snap.md`: `snap/1` state-range and trie retrieval protocol; explicitly designed to run side-by-side with `eth`.
- `devp2p/discv4.md`: UDP wire packets, Kademlia table with `k=16`, endpoint proof, `Ping/Pong/FindNode/Neighbors/ENRRequest/ENRResponse`.
- `devp2p/discv5/discv5.md`: v5 overview; points to dedicated wire/theory/rationale specs.
- `devp2p/enr.md`: ENR encoding/signing constraints, sorted unique key/value pairs, 300-byte max encoded size.

Relevant EIPs read for compatibility and ENR behavior:

- `EIPs/EIPS/eip-8.md` (devp2p/discovery/RLPx forward compatibility rules)
- `EIPs/EIPS/eip-778.md` (ENR canonical format)
- `EIPs/EIPS/eip-868.md` (discv4 ENR extension packets/fields)
- `EIPs/EIPS/eip-1459.md` (DNS-based ENR tree bootstrapping; status: stagnant)

Execution-specs note:

- `execution-specs/` is primarily execution/fork semantics and tests; phase-8 wire/networking authority is `devp2p/` + networking EIPs above.

## 3. Requested Nethermind DB Inventory

Requested path: `nethermind/src/Nethermind/Nethermind.Db/`

Key files from directory listing:

- DB interfaces: `IDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs`, `IColumnsDb.cs`, `ITunableDb.cs`
- Providers/factories: `DbProvider.cs`, `IDbProvider.cs`, `IDbFactory.cs`, `DbProviderExtensions.cs`
- Implementations: `MemDb.cs`, `MemColumnsDb.cs`, `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs`, `NullDb.cs`
- Batching/writes: `InMemoryWriteBatch.cs`, `InMemoryColumnBatch.cs`
- Pruning: `IPruningConfig.cs`, `PruningConfig.cs`, `PruningMode.cs`, `FullPruning/FullPruningDb.cs`
- RocksDB support: `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`, `NullRocksDbFactory.cs`
- Misc support: `DbNames.cs`, `MetadataDbKeys.cs`, `Metrics.cs`, `SimpleFilePublicKeyDb.cs`

## 4. Voltaire Zig API Surface (Requested Listing + Relevant APIs)

Requested path listed: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`

Top-level API anchors:

- `/Users/williamcory/voltaire/packages/voltaire-zig/src/root.zig`
- Exposes `Primitives` and `Crypto` modules.

- `/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/root.zig`
- Notable networking-relevant exports: `Address`, `Hash`, `Hex`, `Rlp`, `Bytes`, `Bytes32`, `PublicKey`, `PrivateKey`, `Signature`, `ForkId`, `PeerId`, `ProtocolVersion`, `NetworkId`, `Transaction`, `Block`, `BlockHeader`.

- `/Users/williamcory/voltaire/packages/voltaire-zig/src/crypto/root.zig`
- Notable exports: `secp256k1`, `HashUtils`, `Crypto`, `aes_gcm`, `chacha20_poly1305`, `keccak_asm`, `Keccak256_Accel`.

- `/Users/williamcory/voltaire/packages/voltaire-zig/src/blockchain/root.zig`
- Exposes `BlockStore`, `ForkBlockCache`, `Blockchain`.

- `/Users/williamcory/voltaire/packages/voltaire-zig/src/jsonrpc/root.zig`
- Exposes typed `JsonRpc`, `eth`, `debug`, `engine` method modules.

- `/Users/williamcory/voltaire/packages/voltaire-zig/src/c_api.zig`
- Exposes C bindings for core primitives (`primitives_address_*`, `primitives_hash_*`, `primitives_keccak256`, `primitives_hex_*`, etc.).

## 5. Existing Zig Host Interface

Source: `src/host.zig`

- `HostInterface` is a pointer + vtable abstraction for external state access.
- Vtable methods: `get/setBalance`, `get/setCode`, `get/setStorage`, `get/setNonce`.
- File explicitly notes nested EVM calls are handled by `EVM.inner_call` and not routed through this host interface.

## 6. Ethereum Tests Fixture Paths (Requested Listing)

Top-level and immediate subdirs under `ethereum-tests/`:

- `ethereum-tests/ABITests`
- `ethereum-tests/BasicTests`
- `ethereum-tests/BlockchainTests` (`InvalidBlocks`, `ValidBlocks`)
- `ethereum-tests/DifficultyTests` (`dfArrowGlacier`, `dfByzantium`, `dfConstantinople`, `dfEIP2384`, `dfFrontier`, `dfGrayGlacier`, `dfHomestead`)
- `ethereum-tests/EOFTests` (`EIP5450`, `efExample`, `efStack`, `efValidation`, `ori`)
- `ethereum-tests/GenesisTests`
- `ethereum-tests/JSONSchema`
- `ethereum-tests/KeyStoreTests`
- `ethereum-tests/LegacyTests`
- `ethereum-tests/PoWTests`
- `ethereum-tests/RLPTests` (`RandomRLPTests`)
- `ethereum-tests/TransactionTests` (`ttAddress`, `ttData`, `ttEIP1559`, `ttEIP2028`, `ttEIP2930`, `ttEIP3860`, `ttGasLimit`, `ttGasPrice`, `ttNonce`, `ttRSValue`, `ttSignature`, `ttVValue`, `ttValue`, `ttWrongRLP`)
- `ethereum-tests/TrieTests`
- `ethereum-tests/src` (`BlockchainTestsFiller`, `DifficultyTestsFiller`, `EOFTestsFiller`, `InvalidRLP`, `Templates`, `TransactionTestsFiller`)

## Summary

Collected phase-8 goals from the PRD, confirmed the exact devp2p specs and networking EIPs to drive implementation, captured the requested Nethermind DB file inventory, enumerated relevant Voltaire Zig API modules and exports, summarized `src/host.zig` HostInterface behavior, and documented concrete `ethereum-tests` fixture paths to support future networking and sync validation work.
