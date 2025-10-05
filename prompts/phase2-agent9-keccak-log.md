# Agent 9: Keccak256 and Logging Opcodes Auditor

## Objective
Audit KECCAK256 (SHA3) and all logging opcodes (LOG0-LOG4).

## Scope
**Files to examine**:
- Zig: `src/frame.zig`
- Python spec: `execution-specs/src/ethereum/forks/prague/vm/instructions/keccak.py`
- Python spec: `execution-specs/src/ethereum/forks/prague/vm/instructions/log.py`

## Tasks

### 1. KECCAK256 (0x20) / SHA3
**Check**:
- [ ] Pops offset and size
- [ ] Reads memory[offset:offset+size]
- [ ] Pushes keccak256 hash
- [ ] Gas cost: 30 + 6 * words + memory_expansion
- [ ] Formula: words = (size + 31) // 32

**Spec**:
```python
def keccak256(evm: Evm) -> None:
    offset = pop(evm.stack)
    size = pop(evm.stack)

    words = (size + 31) // 32
    gas_cost = GAS_KECCAK256 + GAS_KECCAK256_WORD * words + calculate_memory_gas_cost(evm, offset + size)
    charge_gas(evm, gas_cost)

    extend_memory(evm.memory, offset + size)
    data = evm.memory[offset:offset + size]
    hash_value = Uint.from_bytes(keccak256(data), 'big')
    push(evm.stack, hash_value)
```

**Constants to verify**:
- GAS_KECCAK256 = 30
- GAS_KECCAK256_WORD = 6

**Action**: Verify gas calculation and keccak256 implementation.

### 2. LOG0 (0xA0)
**Check**:
- [ ] Pops offset and size
- [ ] Emits log with 0 topics
- [ ] Reverts in STATICCALL context
- [ ] Gas cost: 375 + 8 * size + memory_expansion

**Spec**:
```python
def log0(evm: Evm) -> None:
    if evm.message.is_static:
        raise WriteInStaticContext

    offset = pop(evm.stack)
    size = pop(evm.stack)

    gas_cost = GAS_LOG + GAS_LOG_DATA * size + calculate_memory_gas_cost(evm, offset + size)
    charge_gas(evm, gas_cost)

    extend_memory(evm.memory, offset + size)
    data = evm.memory[offset:offset + size]

    evm.logs.append(Log(
        address=evm.message.current_target,
        topics=[],
        data=data
    ))
```

**Constants to verify**:
- GAS_LOG = 375
- GAS_LOG_DATA = 8

**Action**: Verify STATICCALL restriction.

### 3. LOG1 (0xA1)
**Check**:
- [ ] Pops offset, size, topic1
- [ ] Emits log with 1 topic
- [ ] Gas cost: 375 + 375 * 1 + 8 * size + memory_expansion

**Spec**:
```python
def log1(evm: Evm) -> None:
    if evm.message.is_static:
        raise WriteInStaticContext

    offset = pop(evm.stack)
    size = pop(evm.stack)
    topic1 = pop(evm.stack)

    gas_cost = GAS_LOG + GAS_LOG_TOPIC * 1 + GAS_LOG_DATA * size + calculate_memory_gas_cost(evm, offset + size)
    charge_gas(evm, gas_cost)

    extend_memory(evm.memory, offset + size)
    data = evm.memory[offset:offset + size]

    evm.logs.append(Log(
        address=evm.message.current_target,
        topics=[topic1.to_bytes(32, 'big')],
        data=data
    ))
```

**Constants to verify**:
- GAS_LOG_TOPIC = 375

### 4. LOG2 (0xA2)
**Check**:
- [ ] 2 topics
- [ ] Gas cost: 375 + 375 * 2 + 8 * size + memory_expansion

### 5. LOG3 (0xA3)
**Check**:
- [ ] 3 topics
- [ ] Gas cost: 375 + 375 * 3 + 8 * size + memory_expansion

### 6. LOG4 (0xA4)
**Check**:
- [ ] 4 topics (maximum)
- [ ] Gas cost: 375 + 375 * 4 + 8 * size + memory_expansion

## Gas Formula Verification

**LOG gas cost**:
```
total_gas = GAS_LOG + (GAS_LOG_TOPIC * num_topics) + (GAS_LOG_DATA * size) + memory_expansion_cost
          = 375     + (375 * num_topics)          + (8 * size)           + memory_expansion_cost
```

**Examples**:
- LOG0 with 100 bytes: 375 + 0 + 800 = 1175
- LOG1 with 100 bytes: 375 + 375 + 800 = 1550
- LOG4 with 100 bytes: 375 + 1500 + 800 = 2675

**Action**: Verify gas calculation for all LOG variants.

## Log Structure

**Check**:
- [ ] Each log contains: address, topics, data
- [ ] Address is current contract
- [ ] Topics are indexed (searchable)
- [ ] Data is not indexed
- [ ] Logs included in receipt

**Spec**:
```python
@dataclass
class Log:
    address: Address
    topics: List[Bytes32]
    data: bytes
```

## STATICCALL Restriction

**Check**:
- [ ] All LOG opcodes check is_static flag
- [ ] Raise WriteInStaticContext if static
- [ ] Same restriction as SSTORE, CREATE, SELFDESTRUCT

**Action**: Verify all 5 LOG opcodes enforce static restriction.

## Output Format

```markdown
# Agent 9: Keccak256 and Logging Opcodes Audit Report

## Summary
- Total opcodes audited: 6 (KECCAK256 + LOG0-LOG4)
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

## KECCAK256 Verification
- [ ] Gas: 30 + 6 * words
- [ ] Memory expansion cost included
- [ ] Keccak256 implementation correct

## LOG Verification
- [ ] All 5 variants (LOG0-LOG4)
- [ ] STATICCALL restriction enforced
- [ ] Gas formula correct for each
- [ ] Log structure includes address, topics, data
- [ ] Topics limited to 0-4

## Gas Constants
- [ ] GAS_KECCAK256 = 30
- [ ] GAS_KECCAK256_WORD = 6
- [ ] GAS_LOG = 375
- [ ] GAS_LOG_DATA = 8
- [ ] GAS_LOG_TOPIC = 375

## Priority Summary
- **CRITICAL**: [Count]
- **HIGH**: [Count]
```
