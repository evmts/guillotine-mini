# Agent 15: EIP Compliance Auditor

## Objective
Verify complete implementation of all 8 Prague EIPs, focusing on cross-cutting concerns and integration.

## Scope
**Files to examine**:
- All source files in `src/`
- Python spec: `execution-specs/src/ethereum/forks/prague/`
- EIP specifications for reference

## Dependencies
**Requires**: Agents 1, 2, 11 (primitives, state, system calls)

## EIPs to Verify

### EIP-1153: Transient Storage

**Check**:
- [ ] TLOAD (0x5C) implemented
- [ ] TSTORE (0x5D) implemented
- [ ] Gas cost: 100 for both (GAS_WARM_ACCESS)
- [ ] No refunds for TSTORE
- [ ] Cleared after each transaction
- [ ] NOT cleared between internal calls
- [ ] Reverts in STATICCALL
- [ ] Survives reverts within transaction

**Test scenario**:
```solidity
contract Test {
    function test() public {
        assembly {
            tstore(0, 123)
            let val := tload(0)  // Should be 123
        }
        this.inner();  // Call self
    }

    function inner() public {
        assembly {
            let val := tload(0)  // Should still be 123
            tstore(0, 456)
        }
        revert();  // Revert
    }
}
// After test() completes (reverts), tload(0) should be 0 (cleared)
```

**Files to check**:
- Transient storage map in `src/evm.zig`
- TLOAD/TSTORE in `src/frame.zig`
- Clear logic in transaction processing

**Action**: Verify complete implementation.

---

### EIP-2929: Gas Cost Increases for State Access

**Check**:
- [ ] GAS_COLD_SLOAD = 2100
- [ ] GAS_COLD_ACCOUNT_ACCESS = 2600
- [ ] GAS_WARM_ACCESS = 100
- [ ] Access tracking for addresses
- [ ] Access tracking for storage keys
- [ ] SLOAD: cold 2100, warm 100
- [ ] SSTORE: adds 2100 if cold
- [ ] EXTCODESIZE/HASH: cold 2600, warm 100
- [ ] CALL/DELEGATECALL/STATICCALL: cold 2600, warm 100
- [ ] BALANCE: cold 2600, warm 100

**Pre-warming**:
- [ ] Sender always warm
- [ ] Recipient warm (if exists)
- [ ] Coinbase warm
- [ ] Precompiles warm
- [ ] Access list entries warm

**Files to check**:
- Access sets in `src/evm.zig`
- Cold/warm logic in opcodes
- Pre-warming in transaction init

**Action**: Verify all access tracking correct.

---

### EIP-2930: Optional Access Lists

**Check**:
- [ ] Type 1 transaction (AccessListTransaction)
- [ ] access_list field: [(address, [storage_keys])]
- [ ] Intrinsic gas: +2400 per address, +1900 per key
- [ ] Pre-warming logic
- [ ] RLP encoding/decoding

**Test scenario**:
```python
tx = AccessListTransaction(
    chain_id=1,
    nonce=0,
    gas_price=10,
    gas_limit=100000,
    to=contract_address,
    value=0,
    data=b'',
    access_list=[
        (contract_address, [slot1, slot2]),
        (other_address, []),
    ]
)

# Intrinsic gas should include:
# 21000 (base) + 2400 (contract_address) + 1900*2 (two keys) + 2400 (other_address) = 29600
```

**Files to check**:
- `src/primitives/transaction.zig` (type 1)
- `src/primitives/access_list.zig`
- Intrinsic gas calculation

**Action**: Verify type 1 transaction complete.

---

### EIP-3529: Reduction in Refunds

**Check**:
- [ ] SSTORE clear refund: 4800 (was 15000)
- [ ] SELFDESTRUCT refund: 0 (was 24000)
- [ ] Max refund: gas_used / 5 (was gas_used / 2)
- [ ] Constants updated in gas_constants.zig

**Test scenario**:
```python
# Setting storage slot to zero
# Old: 5000 gas cost, 15000 refund (net -10000!)
# New: 5000 gas cost, 4800 refund (net +200)

# SELFDESTRUCT
# Old: 5000 gas cost, 24000 refund (net -19000!)
# New: 5000 gas cost, 0 refund (net +5000)
```

**Files to check**:
- `src/primitives/gas_constants.zig`
- SSTORE refund logic in `src/frame.zig`
- Max refund calculation in transaction finalization

**Action**: Verify refund values updated.

---

### EIP-3860: Limit and Meter Initcode

**Check**:
- [ ] Max init code size: 49152 bytes (0xC000)
- [ ] Gas cost: 2 per 32-byte word (GAS_INIT_CODE_WORD_COST)
- [ ] Applies to CREATE and CREATE2
- [ ] Rejection if init code too large

**Test scenario**:
```python
# CREATE with 50000 bytes of init code
# Should fail with code too large error

# CREATE with 49152 bytes of init code
# Should charge: 32000 (CREATE) + 2 * (49152 // 32) = 32000 + 3072 = 35072 gas
```

**Files to check**:
- CREATE/CREATE2 opcodes
- Init code validation
- Intrinsic gas calculation

**Action**: Verify init code limits.

---

### EIP-4844: Shard Blob Transactions

**Check**:
- [ ] Type 3 transaction (BlobTransaction)
- [ ] blob_versioned_hashes field
- [ ] max_fee_per_blob_gas field
- [ ] BLOBHASH opcode (0x49)
- [ ] BLOBBASEFEE opcode (0x4A)
- [ ] Point evaluation precompile (0x0A)
- [ ] Blob gas constants:
  - GAS_PER_BLOB = 131072
  - TARGET_BLOB_GAS_PER_BLOCK = 786432
  - MIN_BLOB_GASPRICE = 1
  - BLOB_BASE_FEE_UPDATE_FRACTION = 5007716

**Test scenario**:
```solidity
contract Test {
    function getBlobHash(uint256 index) public returns (bytes32) {
        return blobhash(index);  // Should return tx.blob_versioned_hashes[index]
    }

    function getBlobBaseFee() public returns (uint256) {
        return blobbasefee();  // Should return current blob base fee
    }
}
```

**Files to check**:
- `src/primitives/transaction.zig` (type 3)
- `src/primitives/blob.zig`
- BLOBHASH/BLOBBASEFEE opcodes
- Precompile 0x0A

**Action**: Verify blob transaction support.

---

### EIP-6780: SELFDESTRUCT Only in Same Transaction

**Check**:
- [ ] created_accounts set in state
- [ ] Accounts added to set on CREATE
- [ ] SELFDESTRUCT checks created_accounts
- [ ] Only deletes if address in created_accounts
- [ ] Otherwise just sends balance

**Spec**:
```python
def selfdestruct(evm: Evm) -> None:
    beneficiary = pop(evm.stack).to_address()

    # Always send balance
    balance = evm.env.state.get_balance(evm.message.current_target)
    evm.env.state.set_balance(beneficiary, evm.env.state.get_balance(beneficiary) + balance)
    evm.env.state.set_balance(evm.message.current_target, 0)

    # Only delete if created in same transaction (EIP-6780)
    if evm.message.current_target in evm.env.state.created_accounts:
        evm.env.accounts_to_delete.add(evm.message.current_target)

    evm.running = False
```

**Test scenario**:
```python
# Existing contract calls SELFDESTRUCT
# Result: Balance sent, but code/storage NOT deleted

# Contract created in same tx calls SELFDESTRUCT
# Result: Balance sent AND account deleted
```

**Files to check**:
- created_accounts set in `src/evm.zig`
- CREATE adds to set
- SELFDESTRUCT checks set
- Transaction finalization processes deletions

**Action**: CRITICAL - Verify SELFDESTRUCT new behavior.

---

### EIP-7702: Set EOA Account Code

**Check**:
- [ ] Type 4 transaction (SetCodeTransaction)
- [ ] authorization_list field
- [ ] Authorization structure: (chain_id, address, nonce, v, r, s)
- [ ] Delegation designator: 0xef0100 + address
- [ ] Account code set to delegation designator
- [ ] Nonce must match

**Test scenario**:
```python
# EOA authorizes delegation to contract
auth = Authorization(
    chain_id=1,
    address=contract_address,
    nonce=account_nonce,
    signature=(v, r, s)
)

tx = SetCodeTransaction(
    authorization_list=[auth],
    # ... other fields
)

# After tx, EOA code should be: 0xef0100 + contract_address (23 bytes)
# Calls to EOA now execute contract code
```

**Files to check**:
- `src/primitives/transaction.zig` (type 4)
- `src/primitives/authorization.zig`
- Authorization processing logic

**Action**: Verify EIP-7702 implementation.

---

### EIP-3855: PUSH0 Instruction

**Check**:
- [ ] PUSH0 opcode (0x5F) implemented
- [ ] Pushes 0 to stack
- [ ] Gas cost: 2 (GAS_BASE)
- [ ] Available in Shanghai+ hardfork
- [ ] Hardfork gating correct

**Test scenario**:
```solidity
contract Test {
    function test() public pure returns (uint256) {
        assembly {
            push0  // Should push 0
            push0
            add    // Should result in 0
        }
    }
}
```

**Files to check**:
- PUSH0 in `src/frame.zig`
- Hardfork check in `src/hardfork.zig`

**Action**: Verify PUSH0 implemented.

---

## Integration Checks

### Cross-EIP Interactions

**Check**:
- [ ] Access lists (2930) work with cold access costs (2929)
- [ ] Transient storage (1153) works with STATICCALL restrictions
- [ ] SELFDESTRUCT (6780) integrates with CREATE tracking
- [ ] Blob transactions (4844) work with fee market (1559)
- [ ] All refund calculations use EIP-3529 values

### Hardfork Activation

**Check**:
- [ ] All Prague features only active in Prague+
- [ ] Hardfork configuration in `src/hardfork.zig`
- [ ] Feature flags correct

## Output Format

```markdown
# Agent 15: EIP Compliance Audit Report

## Summary
- Total EIPs: 8
- ✅ Fully compliant: X
- ⚠️ Partially implemented: Y
- ❌ Not implemented: Z

## EIP Status

### EIP-1153: Transient Storage
- [ ] TLOAD/TSTORE implemented
- [ ] Cleared after transaction
- [ ] Static call restriction
**Status**: [COMPLETE / INCOMPLETE / MISSING]
**Issues**: [List any issues]

### EIP-2929: Gas Cost Increases
- [ ] Cold/warm tracking
- [ ] All opcodes updated
- [ ] Pre-warming correct
**Status**: [COMPLETE / INCOMPLETE / MISSING]
**Issues**: [List any issues]

[... repeat for all 8 EIPs]

## Critical Findings

#### [Priority] - [EIP] - [Issue]
**Description**: [Detailed issue]
**Impact**: [What breaks without this]
**Fix**: [What needs to be done]

## Integration Issues
[Cross-EIP interaction problems]

## Priority Summary
- **CRITICAL**: [Count] - Breaks consensus
- **HIGH**: [Count] - Wrong behavior
- **MEDIUM**: [Count] - Missing features
```
