# [Pass 1/5] Phase 8: Networking (devp2p) — Implementation Context

## Phase Goal

Implement devp2p networking for peer communication.

**Key Components** (from plan):
- `client/net/rlpx.zig` - RLPx transport (handshake + framing)
- `client/net/discovery.zig` - discv4/v5 discovery
- `client/net/eth.zig` - eth/68 protocol (note spec currently lists eth/69)

**Reference Architecture**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.Network/`
- devp2p specs: `devp2p/`

---

## 1. Spec References (Read First)

### Core devp2p specs
- `devp2p/rlpx.md` - RLPx transport: ECIES handshake, key derivation, AES-CTR framing, keccak-based MACs, capability multiplexing.
- `devp2p/caps/eth.md` - ETH protocol (current version eth/69): Status handshake, chain sync, tx exchange, message size limits.
- `devp2p/caps/snap.md` - SNAP protocol (snap/1): snapshot state sync requests and Merkle-proven ranges.
- `devp2p/discv4.md` - Discovery v4: UDP packets, Kademlia routing, ping/pong/FindNode/Neighbors, endpoint proof, 1280-byte max.
- `devp2p/discv5/discv5.md` - Discovery v5 overview and sub-spec pointers.
- `devp2p/discv5/discv5-wire.md` - Discovery v5 wire format: masked headers, AES-CTR masking, AES-GCM messages, WHOAREYOU handshake.
- `devp2p/enr.md` - ENR format: RLP list, max size 300 bytes, v4 identity scheme, key ordering rules.

### EIPs referenced by devp2p
- `EIPs/EIPS/eip-8.md` - Forward compatibility rules (ignore version mismatches, extra fields, RLPx auth/ack RLP encoding).
- `EIPs/EIPS/eip-778.md` - ENR canonical format, RLP encoding, v4 identity scheme.
- `EIPs/EIPS/eip-868.md` - discv4 ENR extension (ENRRequest/ENRResponse, ping/pong enr-seq field).

---

## 2. Nethermind Reference (Networking)

Location: `nethermind/src/Nethermind/Nethermind.Network/`

Key areas to mirror structurally:
- `Discovery/` - discovery v4/v5 logic, node table, ENR handling
- `Rlpx/` - RLPx handshake, framing, capability mux
- `P2P/` - devp2p base protocol, hello/status
- `IP/`, `Config/`, `StaticNodes/`, `TrustedNodes/` - endpoint handling and node sources
- Core management: `PeerManager.cs`, `PeerPool.cs`, `ProtocolsManager.cs`, `SessionMonitor.cs`

### Requested Listing: Nethermind DB Module Inventory
Location: `nethermind/src/Nethermind/Nethermind.Db/`

Key files (for cross-module reference):
- `IDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs` - core DB interfaces
- `IColumnsDb.cs`, `ITunableDb.cs` - column families and tuning
- `DbProvider.cs`, `IDbProvider.cs`, `IDbFactory.cs` - DB provider and factories
- `MemDb.cs`, `MemColumnsDb.cs`, `InMemoryWriteBatch.cs` - in-memory backends
- `ReadOnlyDb.cs`, `ReadOnlyColumnsDb.cs` - read-only wrappers
- `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs` - RocksDB support
- `Metrics.cs` - DB metrics

---

## 3. Voltaire Primitives (Must Use)

Location: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`

Relevant primitives for devp2p (do not reimplement):
- `primitives/Rlp/` - RLP encode/decode helpers
- `primitives/Bytes/`, `primitives/Bytes32/`, `primitives/Hash/`, `primitives/Hex/`
- `primitives/PublicKey/`, `primitives/PrivateKey/`, `primitives/Signature/`
- `primitives/PeerId/`, `primitives/PeerInfo/`, `primitives/NodeInfo/`
- `primitives/ProtocolVersion/`, `primitives/NetworkId/`, `primitives/ChainId/`

Relevant crypto primitives:
- `crypto/secp256k1.zig` - node identity keys, signatures, ECDH
- `crypto/keccak256_accel.zig` / `crypto/keccak256_c.zig` - RLPx MACs, ENR hashing
- `crypto/sha256_accel.zig` - ECIES/HMAC and discv5 specs
- `crypto/aes_gcm.zig` - discv5 packet encryption (AES-GCM)
- `crypto/chacha20_poly1305.zig` - available AEAD alternative (if needed by specs)
- `crypto/constant_time.zig` - constant-time helpers for crypto operations

---

## 4. Existing Zig EVM Integration Surface

### Host Interface
File: `src/host.zig`

- Defines `HostInterface` (ptr + vtable) for external state access.
- Vtable pattern is the reference for comptime DI-style polymorphism in Zig.

---

## 5. Test Fixtures and Networking Suites

devp2p suites:
- `hive/` - devp2p integration tests

ethereum-tests inventory (requested listing):
- `ethereum-tests/ABITests/`
- `ethereum-tests/BasicTests/`
- `ethereum-tests/BlockchainTests/`
- `ethereum-tests/DifficultyTests/`
- `ethereum-tests/EOFTests/`
- `ethereum-tests/GenesisTests/`
- `ethereum-tests/JSONSchema/`
- `ethereum-tests/KeyStoreTests/`
- `ethereum-tests/LegacyTests/`
- `ethereum-tests/PoWTests/`
- `ethereum-tests/RLPTests/`
- `ethereum-tests/TransactionTests/`
- `ethereum-tests/TrieTests/`

Fixture tarballs:
- `ethereum-tests/fixtures_blockchain_tests.tgz`
- `ethereum-tests/fixtures_general_state_tests.tgz`

---

## Summary

Collected phase-8 networking goals and Zig module targets, read devp2p specs for RLPx, ETH, SNAP, discv4/v5, and ENR, and pulled the related EIPs (EIP-8, EIP-778, EIP-868). Mapped Nethermind’s networking module structure (Discovery, RLPx, P2P, peer/session management) and captured the requested Nethermind DB inventory. Listed relevant Voltaire primitives and crypto building blocks required for devp2p, noted the `HostInterface` vtable DI pattern, and recorded devp2p and ethereum-tests fixture locations.
