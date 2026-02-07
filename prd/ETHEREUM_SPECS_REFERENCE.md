# Ethereum Specifications Reference

This document maps each implementation phase to the relevant specification sources and test suites.

## Specification Sources

| Source | Location | Purpose |
|--------|----------|---------|
| execution-specs | `execution-specs/` | Authoritative Python EL spec |
| EIPs | `EIPs/` | Ethereum Improvement Proposals |
| devp2p | `devp2p/` | Networking specs (RLPx, eth/68, discv4/v5) |
| execution-apis | `execution-apis/` | JSON-RPC + Engine API specs |
| ethereum-tests | `ethereum-tests/` | Classic JSON test fixtures |
| execution-spec-tests | `execution-spec-tests/` | Python-generated test fixtures |

## Phase-to-Spec Mapping

### Phase 0: DB Abstraction (`phase-0-db`)

**Specs**: N/A (internal abstraction)

**References**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.Db/`

**Tests**: Unit tests only

---

### Phase 1: Merkle Patricia Trie (`phase-1-trie`)

**Specs**:
- Yellow Paper Appendix D (Trie spec)
- `execution-specs/src/ethereum/forks/frontier/trie.py` (reference implementation)

**References**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.Trie/`
- `execution-specs/src/ethereum/rlp.py` (RLP encoding)

**Tests**:
- `ethereum-tests/TrieTests/trietest.json`
- `ethereum-tests/TrieTests/trieanyorder.json`
- `ethereum-tests/TrieTests/hex_encoded_securetrie_test.json`

---

### Phase 2: World State (`phase-2-world-state`)

**Specs**:
- `execution-specs/src/ethereum/forks/*/state.py`
- Yellow Paper Section 4 (World State)

**References**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.State/`
- Voltaire: `voltaire/packages/voltaire-zig/src/state-manager/`

**Tests**:
- Unit tests for journal/snapshot behavior
- Subset of `ethereum-tests/GeneralStateTests/` (state manipulation)

---

### Phase 3: EVM State Integration (`phase-3-evm-state`)

**Specs**:
- `execution-specs/src/ethereum/forks/*/vm/__init__.py`
- `execution-specs/src/ethereum/forks/*/fork.py` (transaction processing)

**References**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.Evm/`
- guillotine-mini: `src/evm.zig`, `src/host.zig`

**Tests**:
- `ethereum-tests/GeneralStateTests/` (full suite)
- `execution-spec-tests/fixtures/state_tests/`

---

### Phase 4: Block Chain (`phase-4-blockchain`)

**Specs**:
- `execution-specs/src/ethereum/forks/*/fork.py` (block validation)
- Yellow Paper Section 11 (Block Finalization)

**References**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.Blockchain/`
- Voltaire: `voltaire/packages/voltaire-zig/src/blockchain/`

**Tests**:
- `ethereum-tests/BlockchainTests/`
- `execution-spec-tests/fixtures/blockchain_tests/`

---

### Phase 5: Transaction Pool (`phase-5-txpool`)

**Specs**:
- EIP-1559 (fee market)
- EIP-2930 (access lists)
- EIP-4844 (blob transactions)

**References**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.TxPool/`

**Tests**: Unit tests + integration tests

---

### Phase 6: JSON-RPC (`phase-6-jsonrpc`)

**Specs**:
- `execution-apis/src/eth/` (OpenRPC spec)
- EIP-1474 (Remote procedure call specification)

**References**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.JsonRpc/`

**Tests**:
- `hive/` test suites for RPC
- `execution-spec-tests/` RPC fixtures

---

### Phase 7: Engine API (`phase-7-engine-api`)

**Specs**:
- `execution-apis/src/engine/` (Engine API spec)
- EIP-3675 (The Merge)
- EIP-4399 (PREVRANDAO)

**References**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.Merge.Plugin/`

**Tests**:
- `hive/` Engine API tests
- `execution-spec-tests/fixtures/blockchain_tests_engine/`

---

### Phase 8: Networking (`phase-8-networking`)

**Specs**:
- `devp2p/rlpx.md` (RLPx transport)
- `devp2p/caps/eth.md` (eth/68 protocol)
- `devp2p/caps/snap.md` (snap/1 protocol)
- `devp2p/discv4.md` (node discovery v4)
- `devp2p/discv5/discv5.md` (node discovery v5)
- `devp2p/enr.md` (ENR format)

**References**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.Network/`

**Tests**:
- `hive/` devp2p tests
- Unit tests for protocol encoding

---

### Phase 9: Synchronization (`phase-9-sync`)

**Specs**:
- `devp2p/caps/eth.md` (block/header exchange)
- `devp2p/caps/snap.md` (snap sync)

**References**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.Synchronization/`

**Tests**:
- `hive/` sync tests
- Integration tests

---

### Phase 10: Runner (`phase-10-runner`)

**Specs**: N/A (CLI/configuration)

**References**:
- Nethermind: `nethermind/src/Nethermind/Nethermind.Runner/`

**Tests**: Integration tests, `hive/` full node tests

---

## Key EIPs by Hardfork

### Berlin (EIP-2929, EIP-2930)
- State access gas costs
- Access lists

### London (EIP-1559, EIP-3198, EIP-3529, EIP-3541)
- Fee market
- BASEFEE opcode
- Reduced gas refunds
- Reject 0xEF code

### Shanghai (EIP-3651, EIP-3855, EIP-3860)
- Warm coinbase
- PUSH0
- Limit init code size

### Cancun (EIP-1153, EIP-4844, EIP-5656, EIP-6780)
- Transient storage
- Blob transactions
- MCOPY
- SELFDESTRUCT changes

### Prague (upcoming)
- EIP-7702 (set code)
- BLS precompiles
- EOF

---

## Source Priority

When in doubt, trust sources in this order:
1. `execution-specs/` - Authoritative Python spec
2. `EIPs/` - Normative change specifications
3. `ethereum-tests/` + `execution-spec-tests/` - Test vectors
4. `devp2p/` - Networking wire formats
5. `execution-apis/` - RPC/Engine API
6. `nethermind/` - Architecture reference only
