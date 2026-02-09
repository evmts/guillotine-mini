# [pass 2/5] phase-8-networking (Networking (devp2p))

## Phase goal (prd/GUILLOTINE_CLIENT_PLAN.md)
- Implement devp2p networking for peer communication.
- Key components: `client/net/rlpx.zig`, `client/net/discovery.zig`, `client/net/eth.zig`.
- Reference architecture: `nethermind/src/Nethermind/Nethermind.Network/`.

## Specs read (devp2p/ and EIPs/)
- `devp2p/rlpx.md`: RLPx handshake (ECIES, KDF, AES-CTR, HMAC-SHA256), framing/MAC rules, Hello negotiation, Snappy compression, 16 MiB message ceiling.
- `devp2p/caps/eth.md`: eth protocol (current eth/69), Status handshake required, size limits, block/tx propagation rules, tx validation summary.
- `devp2p/caps/snap.md`: snap/1 protocol, account/storage range retrieval with proofs, response size rules.
- `devp2p/discv4.md`: discovery v4 Kademlia table (k=16), endpoint proof (12h), UDP packet format, Ping/Pong/FindNode/Neighbors/ENRRequest/ENRResponse.
- `devp2p/discv5/discv5.md`: discovery v5 overview and scope, v5.1 protocol.
- `devp2p/discv5/discv5-wire.md`: v5 wire format, AES-CTR header masking, AES-GCM message auth, WHOAREYOU handshake, packet size bounds (min 63, max 1280).
- `devp2p/enr.md`: ENR structure, 300-byte max, v4 identity scheme, base64 `enr:` text format.
- `EIPs/EIPS/eip-8.md`: forward-compat rules for devp2p, discv4, RLPx handshake (ignore extra fields and version mismatch).
- `EIPs/EIPS/eip-778.md`: ENR definition (keys, ordering, RLP encoding, signature scheme).
- `EIPs/EIPS/eip-868.md`: discv4 ENRRequest/ENRResponse and ping/pong enr-seq extension.

## Nethermind DB reference (nethermind/src/Nethermind/Nethermind.Db/)
- Key files: `IDb.cs`, `IColumnsDb.cs`, `IReadOnlyDb.cs`, `IFullDb.cs`, `IDbFactory.cs`, `DbProvider.cs`, `DbProviderExtensions.cs`, `DbNames.cs`, `MemDb.cs`, `MemColumnsDb.cs`, `ReadOnlyDb.cs`, `RocksDbSettings.cs`, `NullDb.cs`.
- Useful for later persistent peer/enr storage or network metadata DB layout.

## Voltaire APIs (voltaire/packages/voltaire-zig/src/)
- `crypto/crypto.zig`: secp256k1, keccak256, sha256, signing/recovery helpers.
- `crypto/aes_gcm.zig`: AES-GCM (used by discv5 wire protocol).
- `primitives/Rlp/Rlp.zig`: RLP encoding/decoding.
- `primitives/PeerId/PeerId.zig`: devp2p peer identifier and enode parsing/formatting.
- `primitives/ProtocolVersion/ProtocolVersion.zig`: capability version strings (eth/xx, snap/1).
- `primitives/PeerInfo/PeerInfo.zig`: peer metadata for admin_peers-style views.
- `primitives/NodeInfo/NodeInfo.zig`: local node info (enode, ports, protocols).
- `primitives/NetworkId/NetworkId.zig`: network IDs for eth protocol.
- `primitives/HandshakeRole/HandshakeRole.zig`: initiator/recipient role for RLPx handshake.
- `primitives/PublicKey/PublicKey.zig`, `primitives/PrivateKey/PrivateKey.zig`, `primitives/Signature/Signature.zig`: key/signature types.
- `primitives/Hash/Hash.zig`, `primitives/Hex/Hex.zig`, `primitives/Bytes/Bytes.zig`, `primitives/base64.zig`: supporting primitives.

## Existing Zig files
- `src/host.zig`: EVM HostInterface vtable (balance/code/storage/nonce getters/setters). EVM inner calls bypass HostInterface.

## Test fixtures (ethereum-tests/)
- Top-level dirs: `ABITests/`, `BasicTests/`, `BlockchainTests/`, `DifficultyTests/`, `EOFTests/`, `GenesisTests/`, `KeyStoreTests/`, `LegacyTests/`, `PoWTests/`, `RLPTests/`, `TransactionTests/`, `TrieTests/`.
- Networking-specific integration tests are in `hive/` (devp2p suites), not in ethereum-tests.

## Notes for implementation
- RLPx: handshake uses ECIES over secp256k1, AES-128-CTR + HMAC-SHA256; framing MAC rules must be exact; post-Hello messages Snappy-compressed; reject uncompressed payloads > 16 MiB.
- eth: require Status before any other messages; enforce soft/hard message size limits; eth/69 is current spec.
- discv4: UDP packet signing, 1280-byte max, endpoint proof freshness window (12h), EIP-8 permissive decoding rules.
- discv5: masked headers, AES-GCM authenticated payloads, WHOAREYOU handshake; packet min size 63 and max 1280; recommended timeouts (500ms/1s) per spec.
- ENR: RLP list `[signature, seq, k, v, ...]`, keys sorted, max size 300 bytes; v4 identity uses keccak256 + secp256k1.
