# Agent 8: Block Context Opcodes Auditor

## Objective
Audit all block and transaction context opcodes including EIP-4844 BLOBHASH and BLOBBASEFEE.

## Scope
**Files to examine**:
- Zig: `src/frame.zig`
- Python spec: `execution-specs/src/ethereum/forks/prague/vm/instructions/block.py`
- Python spec: `execution-specs/src/ethereum/forks/prague/vm/instructions/eip4844.py`

## Tasks

### 1. BLOCKHASH (0x40)
**Check**:
- [ ] Pops block number
- [ ] Returns hash of given block
- [ ] Returns 0 if block number out of range (> 256 blocks ago or future)
- [ ] Gas cost: 20 (GAS_BLOCK_HASH)

**Spec**:
```python
def blockhash(evm: Evm) -> None:
    block_number = pop(evm.stack)

    # Only last 256 blocks are accessible
    if block_number >= evm.env.block.number or block_number < evm.env.block.number - 256:
        hash_value = Uint(0)
    else:
        hash_value = evm.env.get_block_hash(block_number)

    push(evm.stack, hash_value)
    evm.gas_left -= GAS_BLOCK_HASH
```

**Action**: Verify 256 block limit.

### 2. COINBASE (0x41)
**Check**:
- [ ] Pushes block.coinbase (fee recipient)
- [ ] Gas cost: 2 (GAS_BASE)

### 3. TIMESTAMP (0x42)
**Check**:
- [ ] Pushes block.timestamp
- [ ] Gas cost: 2 (GAS_BASE)

### 4. NUMBER (0x43)
**Check**:
- [ ] Pushes block.number
- [ ] Gas cost: 2 (GAS_BASE)

### 5. PREVRANDAO (0x44)
**Check**:
- [ ] Pushes block.prevrandao (replaces DIFFICULTY post-merge)
- [ ] Gas cost: 2 (GAS_BASE)
- [ ] Renamed from DIFFICULTY in Paris (merge)

### 6. GASLIMIT (0x45)
**Check**:
- [ ] Pushes block.gas_limit
- [ ] Gas cost: 2 (GAS_BASE)

### 7. CHAINID (0x46)
**Check**:
- [ ] Pushes chain ID
- [ ] Gas cost: 2 (GAS_BASE)

### 8. SELFBALANCE (0x47)
**Check**:
- [ ] Pushes balance of current contract
- [ ] Does NOT charge cold access cost (accesses self)
- [ ] Gas cost: 5 (GAS_LOW)

**Spec**:
```python
def selfbalance(evm: Evm) -> None:
    balance = evm.env.state.get_balance(evm.message.current_target)
    push(evm.stack, balance)
    evm.gas_left -= GAS_LOW
```

**Action**: Verify no cold access cost.

### 9. BASEFEE (0x48)
**Check**:
- [ ] Pushes block.base_fee_per_gas (EIP-1559)
- [ ] Gas cost: 2 (GAS_BASE)

### 10. BLOBHASH (0x49) - EIP-4844
**Check**:
- [ ] Implemented
- [ ] Pops index
- [ ] Returns tx.blob_versioned_hashes[index]
- [ ] Returns 0 if index >= len(blob_versioned_hashes)
- [ ] Only available in type 3 (blob) transactions
- [ ] Gas cost: 3 (GAS_BLOBHASH_OPCODE)

**Spec**:
```python
def blobhash(evm: Evm) -> None:
    index = pop(evm.stack)

    if index >= len(evm.message.blob_versioned_hashes):
        hash_value = Uint(0)
    else:
        hash_value = Uint.from_bytes(evm.message.blob_versioned_hashes[index], 'big')

    push(evm.stack, hash_value)
    evm.gas_left -= GAS_BLOBHASH_OPCODE  # 3
```

**Action**: CRITICAL - Verify BLOBHASH is implemented for EIP-4844.

### 11. BLOBBASEFEE (0x4A) - EIP-4844
**Check**:
- [ ] Implemented
- [ ] Pushes current blob base fee
- [ ] Gas cost: 2 (GAS_BASE)

**Spec**:
```python
def blobbasefee(evm: Evm) -> None:
    push(evm.stack, evm.env.block.blob_base_fee)
    evm.gas_left -= GAS_BASE
```

**Action**: CRITICAL - Verify BLOBBASEFEE is implemented for EIP-4844.

## EIP-4844 Blob Gas Calculation

**Check**:
- [ ] Blob gas is separate from execution gas
- [ ] Blob base fee calculated separately
- [ ] Formula uses exponential curve

**Spec**:
```python
def calculate_blob_gas_price(excess_blob_gas: Uint) -> Uint:
    return fake_exponential(
        MIN_BLOB_GASPRICE,
        excess_blob_gas,
        BLOB_BASE_FEE_UPDATE_FRACTION
    )

def fake_exponential(factor: Uint, numerator: Uint, denominator: Uint) -> Uint:
    output = Uint(0)
    numerator_accumulator = factor * denominator
    for i in range(1, 50):
        if numerator_accumulator == 0:
            break
        output += numerator_accumulator
        numerator_accumulator = (numerator_accumulator * numerator) // (denominator * i)
    return output // denominator
```

**Constants to verify**:
- GAS_PER_BLOB = 131072 (2^17)
- TARGET_BLOB_GAS_PER_BLOCK = 786432
- MIN_BLOB_GASPRICE = 1
- BLOB_BASE_FEE_UPDATE_FRACTION = 5007716

**Action**: Verify blob gas constants in gas_constants.zig.

## Output Format

```markdown
# Agent 8: Block Context Opcodes Audit Report

## Summary
- Total opcodes audited: 11
- ✅ Correct: X
- ⚠️ Issues found: Y

## Detailed Findings

### ✅ Correct Implementations
[List]

### ⚠️ Issues Found

#### [Priority] - [Opcode]
**File**: src/frame.zig:LINE
**Issue**: [Description]
**Fix**: [Solution]

## EIP-4844 Blob Opcodes
- [ ] BLOBHASH (0x49) implemented
- [ ] BLOBBASEFEE (0x4A) implemented
- [ ] Blob versioned hashes accessible
- [ ] Blob gas constants defined

## Block Context
- [ ] PREVRANDAO (not DIFFICULTY)
- [ ] BLOCKHASH 256 block limit
- [ ] SELFBALANCE no cold cost

## Priority Summary
- **CRITICAL**: [Count]
- **HIGH**: [Count]
```
