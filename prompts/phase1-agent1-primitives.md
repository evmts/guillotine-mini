# Agent 1: Primitives Auditor & Implementer

## Objective
Audit all primitive types and constants in `/src/primitives/` against the Python execution-specs Prague implementation, identifying missing features, incorrect implementations, and gas constant mismatches.

## Scope
- `/src/primitives/` directory (12,272 lines)
- Reference: `execution-specs/src/ethereum/forks/prague/`

## Files to Audit

### 1. U256 Operations (`uint.zig` - 137,870 lines)
**Reference**: Python's native 256-bit integer behavior

**Check**:
- Wrapping arithmetic (add, sub, mul) - Ethereum uses modulo 2^256
- Division by zero → returns 0 (not error)
- Signed operations edge cases:
  - SDIV: MIN_INT / -1 should return MIN_INT (overflow case)
  - SMOD: Sign handling matches spec
- Bit operations: SHL, SHR, SAR
  - Shift >= 256 → result is 0
  - SAR sign extension correct

**Action**: Compare critical operations against Python spec behavior, flag discrepancies.

---

### 2. Gas Constants (`gas_constants.zig` - 63,649 lines)
**Reference**: `execution-specs/src/ethereum/forks/prague/vm/gas.py`

**Critical Constants to Verify**:
```zig
// EIP-2929 (Prague)
GAS_COLD_SLOAD = 2100
GAS_COLD_ACCOUNT_ACCESS = 2600
GAS_WARM_ACCESS = 100

// EIP-3529 (Gas refund reduction)
SSTORE_REFUND_GAS = 4800  // Was 15000 before
SSTORE_CLEAR_REFUND = 4800

// Storage
GAS_STORAGE_SET = 20000
GAS_STORAGE_UPDATE = 5000
SSTORE_SENTRY_GAS = 2300

// Calls
GAS_CALL_VALUE = 9000
GAS_NEW_ACCOUNT = 25000
GAS_CALL_STIPEND = 2300

// CREATE
GAS_CREATE = 32000
GAS_CODE_DEPOSIT = 200

// EIP-4844 Blob gas
GAS_PER_BLOB = 131072  // 2^17
TARGET_BLOB_GAS_PER_BLOCK = 786432

// EIP-2537 BLS12-381
GAS_BLS_G1_ADD = 375
GAS_BLS_G1_MUL = 12000
GAS_BLS_G2_ADD = 600
GAS_BLS_G2_MUL = 22500
// ... etc
```

**Action**:
- Read Python `gas.py` completely
- Compare EVERY constant
- Flag missing or incorrect values
- Check if constants are hardfork-gated appropriately

---

### 3. Transaction Types (`transaction.zig` - 18,867 lines)
**Reference**: `execution-specs/src/ethereum/forks/prague/transactions.py`

**Required Transaction Types**:
- Type 0: LegacyTransaction
- Type 1: AccessListTransaction (EIP-2930)
- Type 2: FeeMarketTransaction (EIP-1559)
- Type 3: BlobTransaction (EIP-4844)
- Type 4: SetCodeTransaction (EIP-7702)

**Check**:
- All 5 types defined?
- RLP encoding/decoding matches spec
- Signature recovery (v, r, s handling)
- Transaction validation
- Gas limit checks
- Intrinsic gas calculation

**Action**: Verify all transaction types exist and match spec structure.

---

### 4. EIP-7702 Authorization (`authorization.zig` - 12,494 lines)
**Reference**: `execution-specs/src/ethereum/forks/prague/fork_types.py:Authorization`

**Check**:
```python
@dataclass
class Authorization:
    chain_id: U64
    address: Address
    nonce: U256
    y_parity: U256
    r: U256
    s: U256
```

**Validation** (`execution-specs/.../vm/eoa_delegation.py:is_valid_delegation()`):
- Signature validation
- Chain ID matching
- Nonce checking
- Address recovery

**Action**: Verify Authorization struct and validation logic exists.

---

### 5. Blob Handling (`blob.zig` - 10,647 lines)
**Reference**: `execution-specs/src/ethereum/forks/prague/fork_types.py:VersionedHash`

**Check**:
- VersionedHash type (32 bytes, version prefix 0x01)
- Blob versioned hashes in transactions
- KZG commitment handling hooks
- BLOBHASH opcode support

**Action**: Verify blob infrastructure exists.

---

### 6. Access Lists (`access_list.zig` - 12,162 lines)
**Reference**: `execution-specs/src/ethereum/forks/prague/transactions.py:AccessListTransaction`

**Check**:
```python
@dataclass
class AccessList:
    addresses: Tuple[Address, ...]
    storage_keys: Tuple[Tuple[Address, Bytes32], ...]
```

**Action**: Verify access list parsing and structure.

---

### 7. Address Utilities (`address.zig` - 30,480 lines)
**Reference**: `execution-specs/src/ethereum/forks/prague/fork_types.py:Address`

**Check**:
- 20-byte address type
- Zero address constant
- CREATE address calculation: `keccak256(rlp([sender, nonce]))[12:]`
- CREATE2 address calculation: `keccak256(0xff ++ sender ++ salt ++ keccak256(init_code))[12:]`

**Action**: Verify address calculations if implemented here.

---

### 8. RLP Encoding (`rlp.zig` - 23,832 lines)
**Reference**: `ethereum_rlp` library used by Python spec

**Check**:
- Encoding integers (big-endian, no leading zeros)
- Encoding byte arrays
- Encoding lists
- Decoding with proper error handling

**Action**: Spot-check RLP implementation against spec examples.

---

### 9. State Types (`state.zig` - 5,988 lines)
**Reference**: `execution-specs/src/ethereum/forks/prague/state.py`

**Check**:
```python
@dataclass
class State:
    _main_trie: Trie[Address, Optional[Account]]
    _storage_tries: Dict[Address, Trie[Bytes32, U256]]
    _snapshots: List[...]
    created_accounts: Set[Address]  # For EIP-6780
```

**Check**:
- State structure matches
- Snapshot mechanism
- Created accounts tracking

**Action**: Verify state structure and methods.

---

## Output Format

Create a detailed markdown report:

```markdown
# Primitives Audit Report

## Executive Summary
- Total files audited: X
- ✅ Correct: Y components
- ⚠️ Issues: Z components
- ❌ Missing: W components

## Detailed Findings

### ✅ uint.zig - CORRECT
- Wrapping arithmetic: Verified correct
- Division by zero: Returns 0 ✓
- Bit operations: Match spec ✓

### ⚠️ gas_constants.zig - ISSUES FOUND
**Issue 1: Incorrect SSTORE refund**
- **Location**: `gas_constants.zig:99`
- **Current**: `SSTORE_REFUND_GAS = 15000`
- **Expected**: `4800` (EIP-3529)
- **Spec Reference**: `execution-specs/.../vm/gas.py:32`
- **Impact**: Gas refund calculations incorrect
- **Priority**: HIGH

**Issue 2: Missing BLS12-381 constants**
- **Location**: `gas_constants.zig` (entire file)
- **Missing**: 8 BLS constants for EIP-2537
- **Spec Reference**: `execution-specs/.../vm/gas.py:76-82`
- **Impact**: BLS precompiles cannot calculate gas
- **Priority**: MEDIUM

### ❌ authorization.zig - MISSING VALIDATION
**Missing**: `is_valid_authorization()` function
- **Spec Reference**: `execution-specs/.../vm/eoa_delegation.py:is_valid_delegation()`
- **Required For**: EIP-7702 Set Code transactions
- **Action**: Implement signature validation logic
- **Priority**: HIGH

## Summary Table

| Component | Status | Critical Issues | Priority |
|-----------|--------|-----------------|----------|
| uint.zig | ✅ | 0 | - |
| gas_constants.zig | ⚠️ | 2 | HIGH |
| transaction.zig | ✅ | 0 | - |
| authorization.zig | ❌ | 1 | HIGH |
| blob.zig | ⚠️ | 1 | MEDIUM |
| access_list.zig | ✅ | 0 | - |
| address.zig | ✅ | 0 | - |
| rlp.zig | ✅ | 0 | - |
| state.zig | ✅ | 0 | - |

## Recommended Actions (Priority Order)

1. **HIGH**: Fix SSTORE_REFUND_GAS (gas_constants.zig:99)
2. **HIGH**: Implement authorization validation (authorization.zig)
3. **MEDIUM**: Add BLS12-381 gas constants
4. **MEDIUM**: Add blob validation hooks

## Estimated Impact
- Gas calculation bugs: ~30% of tests likely affected
- Missing validation: EIP-7702 transactions will fail
```

## Tools Available
- Read: Read Zig and Python source files
- Grep: Search for constants, patterns
- Bash: Run checks, count occurrences

## Success Criteria
- Every primitive file audited
- All gas constants compared against spec
- All missing features identified with line numbers
- Priority assigned to each issue
