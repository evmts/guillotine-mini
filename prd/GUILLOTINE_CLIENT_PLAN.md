# Guillotine Client Implementation Plan

This document outlines the phased implementation plan for building a full Ethereum execution client in Zig.

## Overview

Guillotine is a high-performance Ethereum execution client built in Zig, leveraging:
- **guillotine-mini**: The EVM engine (already implemented)
- **Voltaire**: Ethereum primitives library
- **Nethermind**: C# reference implementation for architectural guidance

## Implementation Phases

### Phase 0: DB Abstraction Layer (`phase-0-db`)

**Goal**: Create a database abstraction layer for persistent storage.

**Key Components**:
- `client/db/adapter.zig` - Generic database interface
- `client/db/rocksdb.zig` - RocksDB backend implementation
- `client/db/memory.zig` - In-memory backend for testing

**Reference Files**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.Db/`
- Voltaire: Check `/Users/williamcory/voltaire/packages/voltaire-zig/src/` for existing DB primitives

**Test Fixtures**: N/A for this phase (internal abstraction)

---

### Phase 1: Merkle Patricia Trie (`phase-1-trie`)

**Goal**: Implement the Merkle Patricia Trie for state storage.

**Key Components**:
- `client/trie/node.zig` - Trie node types (leaf, extension, branch)
- `client/trie/trie.zig` - Main trie implementation
- `client/trie/hash.zig` - Trie hashing (RLP + keccak256)

**Reference Files**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.Trie/`
- execution-specs: `execution-specs/src/ethereum/forks/*/trie.py`
- Voltaire: `voltaire/packages/voltaire-zig/src/primitives/trie.zig` (check if exists)

**Test Fixtures**: `ethereum-tests/TrieTests/`

---

### Phase 2: World State (`phase-2-world-state`)

**Goal**: Implement journaled state with snapshot/restore for transaction processing.

**Key Components**:
- `client/state/account.zig` - Account state structure
- `client/state/journal.zig` - Journal for tracking changes
- `client/state/state.zig` - World state manager

**Reference Files**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.State/`
- Voltaire: `voltaire/packages/voltaire-zig/src/state-manager/`

---

### Phase 3: EVM State Integration (`phase-3-evm-state`)

**Goal**: Connect the EVM to WorldState for transaction/block processing.

**Key Components**:
- `client/evm/host_adapter.zig` - Implement HostInterface using WorldState
- `client/evm/processor.zig` - Transaction processor

**Reference Files**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.Evm/`
- guillotine-mini: `src/evm.zig`, `src/host.zig`

**Test Fixtures**: `ethereum-tests/GeneralStateTests/`, `execution-spec-tests/`

---

### Phase 4: Block Chain Management (`phase-4-blockchain`)

**Goal**: Manage the block chain structure and validation.

**Key Components**:
- `client/blockchain/chain.zig` - Chain management
- `client/blockchain/validator.zig` - Block validation

**Reference Files**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.Blockchain/`
- Voltaire: `voltaire/packages/voltaire-zig/src/blockchain/`

**Test Fixtures**: `ethereum-tests/BlockchainTests/`

---

### Phase 5: Transaction Pool (`phase-5-txpool`)

**Goal**: Implement the transaction pool for pending transactions.

**Key Components**:
- `client/txpool/pool.zig` - Transaction pool
- `client/txpool/sorter.zig` - Priority sorting (by gas price/tip)

**Reference Files**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.TxPool/`

---

### Phase 6: JSON-RPC Server (`phase-6-jsonrpc`)

**Goal**: Implement the Ethereum JSON-RPC API.

**Key Components**:
- `client/rpc/server.zig` - HTTP/WebSocket server
- `client/rpc/eth.zig` - eth_* methods
- `client/rpc/net.zig` - net_* methods
- `client/rpc/web3.zig` - web3_* methods

**Reference Files**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.JsonRpc/`
- execution-apis: `execution-apis/src/eth/`

---

### Phase 7: Engine API (`phase-7-engine-api`)

**Goal**: Implement the Engine API for consensus layer communication.

**Key Components**:
- `client/engine/api.zig` - Engine API implementation
- `client/engine/payload.zig` - Payload building/validation

**Reference Files**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.Merge.Plugin/`
- execution-apis: `execution-apis/src/engine/`

---

### Phase 8: Networking (`phase-8-networking`)

**Goal**: Implement devp2p networking for peer communication.

**Key Components**:
- `client/net/rlpx.zig` - RLPx protocol
- `client/net/discovery.zig` - discv4/v5
- `client/net/eth.zig` - eth/68 protocol

**Reference Files**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.Network/`
- devp2p: `devp2p/`

---

### Phase 9: Synchronization (`phase-9-sync`)

**Goal**: Implement chain synchronization strategies.

**Key Components**:
- `client/sync/full.zig` - Full sync
- `client/sync/snap.zig` - Snap sync
- `client/sync/manager.zig` - Sync coordination

**Reference Files**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.Synchronization/`

---

### Phase 10: Runner (`phase-10-runner`)

**Goal**: Create the CLI entry point and configuration.

**Key Components**:
- `client/main.zig` - Main entry point
- `client/config.zig` - Configuration management
- `client/cli.zig` - CLI argument parsing

**Reference Files**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.Runner/`

---

## Design Principles

1. **Use Voltaire primitives** - Never reinvent Address, Hash, u256, RLP, etc.
2. **Use guillotine-mini EVM** - Don't reimplement the EVM
3. **Follow Nethermind architecture** - Mirror module boundaries
4. **Comptime dependency injection** - Use HostInterface vtable pattern
5. **Arena allocators** - Transaction-scoped memory
6. **Explicit error handling** - No silent failures

## Testing Strategy

Each phase should:
1. Have inline unit tests (`test "..." {}`)
2. Pass relevant ethereum-tests fixtures
3. Pass execution-spec-tests where applicable
4. Match Nethermind output for differential testing
