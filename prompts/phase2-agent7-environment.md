# Agent 7: Environment Opcodes Auditor

## Objective
Audit all environment information opcodes (ADDRESS, CALLER, CALLVALUE, CALLDATALOAD, CALLDATASIZE, CALLDATACOPY, CODESIZE, CODECOPY, RETURNDATASIZE, RETURNDATACOPY, GASPRICE, EXTCODESIZE, EXTCODECOPY, EXTCODEHASH).

## Scope
**Files to examine**:
- Zig: `src/frame.zig`
- Python spec: `execution-specs/src/ethereum/forks/prague/vm/instructions/environment.py`
- Python spec: `execution-specs/src/ethereum/forks/prague/vm/gas.py`

## Tasks

### 1. ADDRESS (0x30)
**Check**:
- [ ] Pushes current contract address
- [ ] Gas cost: 2 (GAS_BASE)

### 2. CALLER (0x33)
**Check**:
- [ ] Pushes caller address (msg.sender)
- [ ] Gas cost: 2 (GAS_BASE)

### 3. CALLVALUE (0x34)
**Check**:
- [ ] Pushes value sent with message
- [ ] Gas cost: 2 (GAS_BASE)

### 4. CALLDATALOAD (0x35)
**Check**:
- [ ] Pops offset
- [ ] Loads 32 bytes from calldata[offset:offset+32]
- [ ] Pads with zeros if past end
- [ ] Gas cost: 3 (GAS_VERY_LOW)

**Spec**:
```python
def calldataload(evm: Evm) -> None:
    offset = pop(evm.stack)
    data = evm.message.data[offset:offset + 32]
    # Pad with zeros if needed
    data = data.ljust(32, b'\x00')
    value = Uint.from_bytes(data, 'big')
    push(evm.stack, value)
    evm.gas_left -= GAS_VERY_LOW
```

### 5. CALLDATASIZE (0x36)
**Check**:
- [ ] Pushes size of calldata
- [ ] Gas cost: 2 (GAS_BASE)

### 6. CALLDATACOPY (0x37)
**Check**:
- [ ] Pops dest_offset, offset, size
- [ ] Copies calldata[offset:offset+size] to memory[dest_offset:dest_offset+size]
- [ ] Pads with zeros if past end
- [ ] Memory expansion cost
- [ ] Gas cost: 3 + 3 * words + memory_expansion

**Spec**:
```python
def calldatacopy(evm: Evm) -> None:
    dest_offset = pop(evm.stack)
    offset = pop(evm.stack)
    size = pop(evm.stack)

    words = (size + 31) // 32
    gas_cost = GAS_VERY_LOW + GAS_COPY * words + calculate_memory_gas_cost(evm, dest_offset + size)
    charge_gas(evm, gas_cost)

    extend_memory(evm.memory, dest_offset + size)

    data = evm.message.data[offset:offset + size]
    # Pad with zeros
    data = data.ljust(size, b'\x00')

    evm.memory[dest_offset:dest_offset + size] = data
```

### 7. CODESIZE (0x38)
**Check**:
- [ ] Pushes size of current contract code
- [ ] Gas cost: 2 (GAS_BASE)

### 8. CODECOPY (0x39)
**Check**:
- [ ] Pops dest_offset, offset, size
- [ ] Copies code[offset:offset+size] to memory[dest_offset:dest_offset+size]
- [ ] Pads with zeros if past end
- [ ] Gas cost: 3 + 3 * words + memory_expansion

### 9. GASPRICE (0x3A)
**Check**:
- [ ] Pushes effective gas price
- [ ] For EIP-1559: min(tx.max_fee_per_gas, base_fee + tx.max_priority_fee_per_gas)
- [ ] Gas cost: 2 (GAS_BASE)

### 10. EXTCODESIZE (0x3B) - EIP-2929
**Check**:
- [ ] Pops address
- [ ] Pushes code size of external account
- [ ] Returns 0 for EOA and non-existent accounts
- [ ] Cold access: 2600 gas (GAS_COLD_ACCOUNT_ACCESS)
- [ ] Warm access: 100 gas (GAS_WARM_ACCESS)

**Spec**:
```python
def extcodesize(evm: Evm) -> None:
    address = pop(evm.stack).to_address()

    # Check if cold access
    if address not in evm.accessed_addresses:
        evm.accessed_addresses.add(address)
        gas_cost = GAS_COLD_ACCOUNT_ACCESS  # 2600
    else:
        gas_cost = GAS_WARM_ACCESS  # 100

    charge_gas(evm, gas_cost)

    code = evm.env.state.get_code(address)
    push(evm.stack, Uint(len(code)))
```

### 11. EXTCODECOPY (0x3C) - EIP-2929
**Check**:
- [ ] Pops address, dest_offset, offset, size
- [ ] Copies external code to memory
- [ ] Cold access: 2600 gas
- [ ] Warm access: 100 gas
- [ ] Plus copy cost: 3 * words
- [ ] Plus memory expansion

### 12. RETURNDATASIZE (0x3D)
**Check**:
- [ ] Pushes size of return data from last call
- [ ] Returns 0 if no previous call
- [ ] Gas cost: 2 (GAS_BASE)

### 13. RETURNDATACOPY (0x3E)
**Check**:
- [ ] Pops dest_offset, offset, size
- [ ] Copies returndata[offset:offset+size] to memory
- [ ] Reverts if offset + size > returndatasize
- [ ] Gas cost: 3 + 3 * words + memory_expansion

**Spec**:
```python
def returndatacopy(evm: Evm) -> None:
    dest_offset = pop(evm.stack)
    offset = pop(evm.stack)
    size = pop(evm.stack)

    if offset + size > len(evm.returndata):
        raise InvalidReturnDataAccess

    words = (size + 31) // 32
    gas_cost = GAS_VERY_LOW + GAS_COPY * words + calculate_memory_gas_cost(evm, dest_offset + size)
    charge_gas(evm, gas_cost)

    extend_memory(evm.memory, dest_offset + size)
    evm.memory[dest_offset:dest_offset + size] = evm.returndata[offset:offset + size]
```

**Action**: CRITICAL - Verify bounds check reverts.

### 14. EXTCODEHASH (0x3F) - EIP-2929
**Check**:
- [ ] Pops address
- [ ] Pushes keccak256(code) or 0 for empty/non-existent
- [ ] Returns 0 for non-existent accounts (not empty hash)
- [ ] Cold access: 2600 gas
- [ ] Warm access: 100 gas

**Spec**:
```python
def extcodehash(evm: Evm) -> None:
    address = pop(evm.stack).to_address()

    # Check if cold access
    if address not in evm.accessed_addresses:
        evm.accessed_addresses.add(address)
        gas_cost = GAS_COLD_ACCOUNT_ACCESS  # 2600
    else:
        gas_cost = GAS_WARM_ACCESS  # 100

    charge_gas(evm, gas_cost)

    if not evm.env.state.account_exists(address):
        hash_value = Uint(0)
    else:
        code = evm.env.state.get_code(address)
        hash_value = Uint.from_bytes(keccak256(code), 'big')

    push(evm.stack, hash_value)
```

**Action**: Verify returns 0 for non-existent, not empty hash.

## Output Format

```markdown
# Agent 7: Environment Opcodes Audit Report

## Summary
- Total opcodes audited: 14
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

## EIP-2929 Access Costs
- [ ] EXTCODESIZE: cold 2600, warm 100
- [ ] EXTCODECOPY: cold 2600, warm 100
- [ ] EXTCODEHASH: cold 2600, warm 100
- [ ] Access tracking correct

## Edge Cases
- [ ] CALLDATALOAD pads with zeros
- [ ] CALLDATACOPY pads with zeros
- [ ] RETURNDATACOPY bounds check
- [ ] EXTCODEHASH returns 0 for non-existent

## Priority Summary
- **CRITICAL**: [Count]
- **HIGH**: [Count]
```
