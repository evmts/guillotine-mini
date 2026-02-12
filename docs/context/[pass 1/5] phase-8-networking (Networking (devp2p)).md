# Context — [pass 1/5] phase-8-networking (Networking (devp2p))

This document summarizes goals, key specs, reference code, available primitives, and test fixtures for implementing devp2p networking in Guillotine (Phase 8). It will guide small, atomic implementation steps using Voltaire primitives and Nethermind’s architecture as reference.

## Goals from PRD (Phase 8)
- Implement devp2p networking for peer communication.
- Key components to implement in Zig (one unit per commit):
  - `client/net/rlpx.zig` — RLPx transport (handshake, framing, encryption, MAC)
  - `client/net/discovery.zig` — Discovery (discv4/v5), ENR handling
  - `client/net/eth.zig` — eth/68 subprotocol (status handshake, message codecs)

Source: `prd/GUILLOTINE_CLIENT_PLAN.md` (Phase 8: Networking)

## Relevant Specs (Phase 8)
- `devp2p/rlpx.md` — RLPx transport: ECIES-secp256k1 handshake, AES framing, keccak MAC.
- `devp2p/caps/eth.md` — eth/68 protocol: Status handshake, get/headers/bodies, txs, pings.
- `devp2p/caps/snap.md` — snap/1 protocol: state range queries; informs sync encoding.
- `devp2p/discv4.md` — Discovery v4: UDP Kademlia-style, ping/pong/findnode/neighbours.
- `devp2p/discv5/discv5.md` — Discovery v5: topic adverts, TALKREQ/RESP, handshake over UDP.
- `devp2p/enr.md` — Ethereum Node Records: identity scheme, record fields, RLP serialization.

Source: `prd/ETHEREUM_SPECS_REFERENCE.md` (Phase 8 mapping)

## Nethermind Reference (Architecture & Structure)
- DB module (interface boundaries and storage patterns): `nethermind/src/Nethermind/Nethermind.Db/`
  - Notable files: `IDb.cs`, `IDbProvider.cs`, `MemDb.cs`, `ReadOnlyDb.cs`, `RocksDbSettings.cs`, `CompressingDb.cs`, `PruningConfig.cs`.
- Networking module (structural reference for Phase 8): `nethermind/src/Nethermind/Nethermind.Network/`
  - RLPx: `Rlpx/Handshake/*`, `Rlpx/RlpxHost.cs`, `Rlpx/Frame*`, `Rlpx/Zero*`
  - P2P session & queues: `P2P/Session.cs`, `P2P/MessageDictionary.cs`, `P2P/PacketSender.cs`
  - Discovery scaffold: `Discovery/Messages/`
  - Fork/version: `ForkId.cs`, `ForkInfo.cs`, `P2P/P2PProtocolInfoProvider.cs`

Use Nethermind only for structure/flow; implementation must be idiomatic Zig with comptime DI.

## Voltaire Zig Primitives and APIs to Use (never custom types)
Root: `/Users/williamcory/voltaire/packages/voltaire-zig/src/`
- Primitives (identities and protocol values):
  - `primitives/PeerId` — Peer/Node identity.
  - `primitives/NodeInfo` — Local node info container.
  - `primitives/ForkId` — Fork id used in `eth` status.
  - `primitives/ProtocolVersion` — Protocol versioning helpers.
  - `primitives/Rlp` — RLP encoder/decoder for wire payloads.
  - `primitives/Bytes`, `primitives/Hash`, `primitives/Uint/*` — canonical byte and integer types.
- Crypto (handshake + framing):
  - `crypto/secp256k1.zig` — EC key operations for ECDH/ECIES.
  - `crypto/keccak256_*` — Keccak for MAC and ID hashing.
  - `crypto/aes_gcm.zig` (and AES primitives) — symmetric encryption building blocks.
  - `crypto/hash.zig`, `crypto/hash_algorithms.zig` — hashing utilities.

Ensure all message types and keys use Voltaire’s types (e.g., `PeerId`, `Bytes`, `Uint`).

## Existing Zig Host/EVM Integration Surface
- `src/host.zig` — Minimal `HostInterface` vtable for state access used by the EVM. Networking must not bypass EVM or reimplement it; only provide data to upper layers using Voltaire primitives and DI similar to existing vtable patterns.

## Specs & Test Fixture Paths to Reference
- DevP2P specs: `devp2p/rlpx.md`, `devp2p/caps/eth.md`, `devp2p/caps/snap.md`, `devp2p/discv4.md`, `devp2p/discv5/discv5.md`, `devp2p/enr.md`.
- Ethereum tests (available in repo):
  - `ethereum-tests/BlockchainTests/`
  - `ethereum-tests/TrieTests/`
  - `ethereum-tests/TransactionTests/`
  - Note: Devp2p/Hive tests live externally; plan unit tests for encoders/decoders and handshake logic.

## Immediate Implementation Notes
- Follow Nethermind’s separation: `Rlpx` (transport) → `P2P` (session/message) → `eth` (capability).
- Use comptime DI for pluggable cipher/mac, socket IO, and clock.
- Zero silent errors: propagate `!Error` everywhere; no `catch {}`.
- Performance: reuse buffers, avoid heap where possible, pre-size RLP encoders, and use arenas for per-session allocations.
- Security: constant-time crypto ops from Voltaire; validate lengths/types from untrusted peers.

