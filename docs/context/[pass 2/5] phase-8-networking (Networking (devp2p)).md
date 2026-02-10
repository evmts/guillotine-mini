# [Pass 2/5] Phase 8: Networking (devp2p) -- Implementation Context

## Phase Goal

Implement devp2p networking (RLPx transport, discv4/v5 discovery, eth/68+ and snap/1 capabilities) for peer communication. This phase wires protocol framing, handshakes, capability negotiation, and message encoding.

**Key Components (from plan)**:
- `client/net/rlpx.zig` -- RLPx transport
- `client/net/discovery.zig` -- discv4/v5 discovery
- `client/net/eth.zig` -- eth protocol (status, headers, bodies, tx exchange)

---

## 1. Specs (devp2p/)

### RLPx transport
- `devp2p/rlpx.md`
  - RLPx protocol v5 over TCP.
  - ECIES handshake using secp256k1; derives `aes-secret` and `mac-secret`.
  - Framing: header and frame ciphertext with per-direction MAC states.
  - Capability multiplexing uses message ID space; hello is uncompressed; all other messages Snappy compressed.
  - Enforce max uncompressed payload size (16 MiB) by checking Snappy length header.

### ETH capability
- `devp2p/caps/eth.md`
  - Current protocol version listed as eth/69.
  - Session is active only after both sides exchange Status message.
  - Message size limits: RLPx 16.7 MiB hard limit, typical soft limit ~10 MiB.
  - Chain sync uses GetBlockHeaders/Bodies; receipts via GetReceipts during state sync.
  - Post-merge note: block propagation via eth is deprecated for PoS networks.

### SNAP capability
- `devp2p/caps/snap.md`
  - snap/1 runs side-by-side with eth, not standalone.
  - Allows account range, storage range, and bytecode retrieval with proofs.
  - Key requirement: peers must respond, even if returning empty data when state root is unavailable.

### Discovery v4
- `devp2p/discv4.md`
  - UDP packets signed by secp256k1 key; packet header includes hash and signature.
  - Kademlia routing with k-buckets (k=16), endpoint proof by recent pong (12h window).
  - Packet types: Ping, Pong, FindNode, Neighbors, ENRRequest, ENRResponse.

### Discovery v5
- `devp2p/discv5/discv5.md`
  - v5.1 spec overview; wire/theory/rationale split into `discv5-wire.md`, `discv5-theory.md`, `discv5-rationale.md`.
  - Encrypted communication, topic advertisements, extensible node identity.

### ENR
- `devp2p/enr.md`
  - ENR format: RLP list `[signature, seq, k, v, ...]` with key ordering.
  - Max record size 300 bytes.
  - v4 identity scheme: keccak256(content) -> secp256k1 signature.
  - Text form `enr:` + URL-safe base64 (no padding).

---

## 2. Nethermind Architecture References

**Primary module**:
- `nethermind/src/Nethermind/Nethermind.Network/` (overall networking architecture and protocol handlers)

**Db module (requested listing for cross-cutting storage)**:
- `nethermind/src/Nethermind/Nethermind.Db/` files (from `ls`):
  - `DbNames.cs` (includes `DiscoveryNodes`, `DiscoveryV5Nodes`, `Peers` DB names)
  - `DbProvider.cs`, `IDbProvider.cs`, `IDb.cs`, `IColumnsDb.cs`, `IFullDb.cs`
  - `MemDb.cs`, `MemDbFactory.cs`, `NullDb.cs`, `ReadOnlyDb.cs`
  - `RocksDbSettings.cs`, `RocksDbMergeEnumerator.cs`
  - `Metrics.cs`, `DbExtensions.cs`, `DbProviderExtensions.cs`
  - `ReceiptsColumns.cs`, `BlobTxsColumns.cs`, `MetadataDbKeys.cs`

`DbNames.cs` defines discovery and peer storage names: `discoveryNodes`, `discoveryV5Nodes`, `peers`.

---

## 3. Voltaire APIs (must use, no custom types)

**Primitives** (`/Users/williamcory/voltaire/packages/voltaire-zig/src/primitives/`):
- `PeerId.PeerId` -- 64-byte public key node ID; enode parsing/formatting helpers
- `PeerInfo.PeerInfo` and `PeerInfo.NetworkInfo` -- peer metadata and connection info
- `ProtocolVersion.ProtocolVersion` -- capability versioning (eth/xx, snap/1)
- `HandshakeRole.HandshakeRole` -- initiator vs recipient
- `Rlp` -- RLP encode/decode for handshake, p2p, eth, snap, discv4 packets
- `Base64` -- ENR text encoding
- `PublicKey`, `PrivateKey`, `Signature`, `Hash`, `Bytes`, `Bytes32` -- protocol payloads
- `SnappyParameters.MaxSnappyLength` -- 16 MiB uncompressed cap

**Crypto** (`/Users/williamcory/voltaire/packages/voltaire-zig/src/crypto/`):
- `secp256k1.zig` -- node identity and signatures
- `hash.zig`, `keccak256_*` -- RLPx/ENR hashing
- `sha256_accel.zig` -- RLPx HMAC-SHA256

---

## 4. Existing Zig Files (integration points)

- `src/host.zig` -- HostInterface vtable pattern used for comptime DI; mirror this pattern for networking interfaces.

---

## 5. Test Fixtures and References

**devp2p tests**:
- `hive/` (devp2p and sync scenarios)

**Ethereum test fixtures** (directory listing from `ethereum-tests/`):
- `ethereum-tests/ABITests`
- `ethereum-tests/BasicTests`
- `ethereum-tests/BlockchainTests`
- `ethereum-tests/DifficultyTests`
- `ethereum-tests/EOFTests`
- `ethereum-tests/GenesisTests`
- `ethereum-tests/KeyStoreTests`
- `ethereum-tests/LegacyTests`
- `ethereum-tests/PoWTests`
- `ethereum-tests/RLPTests`
- `ethereum-tests/TransactionTests`
- `ethereum-tests/TrieTests`
- `ethereum-tests/JSONSchema`

---

## 6. Notes for Implementation

- RLPx framing and MAC updates are strict; verify MAC before decrypting header/body.
- Snappy compression required after Hello; enforce uncompressed size limit.
- Status exchange gates ETH session activation.
- Discovery v4 relies on endpoint proof; v5 introduces encrypted packets and topic ads.
- Store discovery nodes and peers in DB names aligned with Nethermind (see `DbNames.cs`).
