# Agent 5: Stack and Memory Opcodes Auditor

## Objective
Exhaustively audit all stack manipulation, memory operations, and PUSH/DUP/SWAP opcodes.

## Scope
**Files to examine**:
- Zig: `src/frame.zig`
- Python spec: `execution-specs/src/ethereum/forks/prague/vm/instructions/stack.py`
- Python spec: `execution-specs/src/ethereum/forks/prague/vm/instructions/memory.py`
- Python spec: `execution-specs/src/ethereum/forks/prague/vm/gas.py`

## Tasks

### Stack Operations

#### PUSH0 (0x5F) - EIP-3855
**Check**:
- [ ] Pushes 0 to stack
- [ ] Gas cost: 2 (GAS_BASE)
- [ ] Available in Shanghai+ hardfork

**Spec**:
```python
def push0(evm: Evm) -> None:
    push(evm.stack, Uint(0))
    evm.gas_left -= GAS_BASE
```

#### PUSH1-PUSH32 (0x60-0x7F)
**Check**:
- [ ] Reads N bytes from code after opcode
- [ ] Pushes value to stack
- [ ] PC incremented by N
- [ ] Gas cost: 3 (GAS_VERY_LOW)
- [ ] All 32 variants implemented

**Spec**:
```python
def push_n(evm: Evm, num_bytes: int) -> None:
    data = evm.code[evm.pc + 1 : evm.pc + 1 + num_bytes]
    value = Uint.from_bytes(data, 'big')
    push(evm.stack, value)
    evm.pc += num_bytes
    evm.gas_left -= GAS_VERY_LOW
```

**Action**: Verify all 32 PUSH variants read correct byte count.

#### DUP1-DUP16 (0x80-0x8F)
**Check**:
- [ ] Duplicates stack item at position N
- [ ] DUP1 duplicates top, DUP2 duplicates 2nd, etc.
- [ ] Gas cost: 3 (GAS_VERY_LOW)
- [ ] All 16 variants implemented

**Spec**:
```python
def dup_n(evm: Evm, position: int) -> None:
    value = evm.stack[-position]
    push(evm.stack, value)
    evm.gas_left -= GAS_VERY_LOW
```

**Action**: Verify DUP1 duplicates stack[-1], DUP2 duplicates stack[-2], etc.

#### SWAP1-SWAP16 (0x90-0x9F)
**Check**:
- [ ] Swaps top with item at position N+1
- [ ] SWAP1 swaps top with 2nd, SWAP2 swaps top with 3rd, etc.
- [ ] Gas cost: 3 (GAS_VERY_LOW)
- [ ] All 16 variants implemented

**Spec**:
```python
def swap_n(evm: Evm, position: int) -> None:
    evm.stack[-1], evm.stack[-position - 1] = evm.stack[-position - 1], evm.stack[-1]
    evm.gas_left -= GAS_VERY_LOW
```

**Action**: Verify SWAP1 swaps stack[-1] and stack[-2], SWAP2 swaps stack[-1] and stack[-3], etc.

#### POP (0x50)
**Check**:
- [ ] Removes top stack item
- [ ] Gas cost: 2 (GAS_BASE)

### Memory Operations

#### MLOAD (0x51)
**Check**:
- [ ] Pops offset
- [ ] Reads 32 bytes from memory[offset:offset+32]
- [ ] Expands memory if needed
- [ ] Gas cost: 3 + memory_expansion_cost
- [ ] Memory expansion gas calculation correct

**Spec**:
```python
def mload(evm: Evm) -> None:
    offset = pop(evm.stack)

    # Calculate memory expansion
    new_size = ceil_32((offset + 32) / 32)
    gas_cost = GAS_VERY_LOW + calculate_memory_gas_cost(evm, new_size)
    charge_gas(evm, gas_cost)

    # Expand memory if needed
    extend_memory(evm.memory, offset + 32)

    # Load 32 bytes
    value = Uint.from_bytes(evm.memory[offset:offset + 32], 'big')
    push(evm.stack, value)
```

**Action**: CRITICAL - Verify memory expansion gas calculation.

#### MSTORE (0x52)
**Check**:
- [ ] Pops offset and value
- [ ] Writes 32 bytes to memory[offset:offset+32]
- [ ] Expands memory if needed
- [ ] Gas cost: 3 + memory_expansion_cost

**Spec**:
```python
def mstore(evm: Evm) -> None:
    offset = pop(evm.stack)
    value = pop(evm.stack)

    # Calculate memory expansion
    new_size = ceil_32((offset + 32) / 32)
    gas_cost = GAS_VERY_LOW + calculate_memory_gas_cost(evm, new_size)
    charge_gas(evm, gas_cost)

    # Expand memory if needed
    extend_memory(evm.memory, offset + 32)

    # Store 32 bytes
    evm.memory[offset:offset + 32] = value.to_bytes(32, 'big')
```

#### MSTORE8 (0x53)
**Check**:
- [ ] Pops offset and value
- [ ] Writes lowest byte of value to memory[offset]
- [ ] Expands memory if needed
- [ ] Gas cost: 3 + memory_expansion_cost

**Spec**:
```python
def mstore8(evm: Evm) -> None:
    offset = pop(evm.stack)
    value = pop(evm.stack)

    # Calculate memory expansion
    new_size = ceil_32((offset + 1) / 32)
    gas_cost = GAS_VERY_LOW + calculate_memory_gas_cost(evm, new_size)
    charge_gas(evm, gas_cost)

    # Expand memory if needed
    extend_memory(evm.memory, offset + 1)

    # Store 1 byte (LSB)
    evm.memory[offset] = value & 0xFF
```

#### MSIZE (0x59)
**Check**:
- [ ] Pushes current memory size in bytes
- [ ] Size is always multiple of 32
- [ ] Gas cost: 2 (GAS_BASE)

**Spec**:
```python
def msize(evm: Evm) -> None:
    push(evm.stack, Uint(len(evm.memory)))
    evm.gas_left -= GAS_BASE
```

### Memory Expansion Gas

**Check**:
- [ ] Memory expansion gas formula correct
- [ ] Formula: words = (size + 31) // 32; cost = 3 * words + words^2 / 512
- [ ] Only charges for expansion, not existing memory

**Spec**:
```python
def calculate_memory_gas_cost(evm: Evm, new_size: int) -> int:
    if new_size <= len(evm.memory):
        return 0

    old_words = (len(evm.memory) + 31) // 32
    new_words = (new_size + 31) // 32

    old_cost = 3 * old_words + old_words * old_words // 512
    new_cost = 3 * new_words + new_words * new_words // 512

    return new_cost - old_cost
```

**Action**: CRITICAL - Verify quadratic memory expansion cost.

## Output Format

```markdown
# Agent 5: Stack and Memory Opcodes Audit Report

## Summary
- Total opcodes audited: 68 (1 PUSH0 + 32 PUSH + 16 DUP + 16 SWAP + 1 POP + 4 memory)
- ✅ Correct: X
- ⚠️ Issues found: Y
- ❌ Critical bugs: Z

## Detailed Findings

### ✅ Correct Implementations
[List correct opcodes]

### ⚠️ Issues Found

#### [Priority] - [Opcode Name]
**File**: src/frame.zig:LINE
**Issue**: [Description]
**Fix required**: [What needs to change]

## PUSH/DUP/SWAP Verification
- [ ] All 32 PUSH variants (0x60-0x7F)
- [ ] All 16 DUP variants (0x80-0x8F)
- [ ] All 16 SWAP variants (0x90-0x9F)
- [ ] PUSH0 (0x5F) available in Shanghai+

## Memory Expansion
- [ ] Quadratic cost formula correct
- [ ] Only charges for expansion
- [ ] Memory always expanded to multiple of 32

## Priority Summary
- **CRITICAL**: [Count]
- **HIGH**: [Count]
- **MEDIUM**: [Count]
- **LOW**: [Count]
```
