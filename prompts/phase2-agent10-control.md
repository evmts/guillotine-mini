# Agent 10: Control Flow Opcodes Auditor

## Objective
Audit all control flow opcodes: JUMP, JUMPI, PC, JUMPDEST, GAS, STOP, RETURN, REVERT, INVALID.

## Scope
**Files to examine**:
- Zig: `src/frame.zig`
- Python spec: `execution-specs/src/ethereum/forks/prague/vm/instructions/control_flow.py`
- Python spec: `execution-specs/src/ethereum/forks/prague/vm/interpreter.py`

## Tasks

### 1. STOP (0x00)
**Check**:
- [ ] Halts execution
- [ ] Returns empty output
- [ ] Gas cost: 0 (GAS_ZERO)
- [ ] Success status

**Spec**:
```python
def stop(evm: Evm) -> None:
    evm.running = False
    evm.output = b''
```

### 2. JUMP (0x56)
**Check**:
- [ ] Pops destination
- [ ] Sets PC to destination
- [ ] Destination MUST be JUMPDEST
- [ ] Reverts if invalid destination
- [ ] Gas cost: 8 (GAS_MID)

**Spec**:
```python
def jump(evm: Evm) -> None:
    destination = pop(evm.stack)

    if destination >= len(evm.code) or evm.code[destination] != 0x5B:  # JUMPDEST
        raise InvalidJump

    evm.pc = destination
    evm.gas_left -= GAS_MID
```

**Action**: CRITICAL - Verify JUMPDEST validation.

### 3. JUMPI (0x57)
**Check**:
- [ ] Pops destination and condition
- [ ] Jumps if condition != 0
- [ ] Destination MUST be JUMPDEST
- [ ] Gas cost: 10 (GAS_HIGH)

**Spec**:
```python
def jumpi(evm: Evm) -> None:
    destination = pop(evm.stack)
    condition = pop(evm.stack)

    if condition != 0:
        if destination >= len(evm.code) or evm.code[destination] != 0x5B:
            raise InvalidJump
        evm.pc = destination

    evm.gas_left -= GAS_HIGH
```

**Action**: CRITICAL - Verify conditional jump logic and JUMPDEST validation.

### 4. JUMPDEST (0x5B)
**Check**:
- [ ] Marks valid jump destination
- [ ] Does nothing when executed
- [ ] Gas cost: 1 (GAS_JUMPDEST)
- [ ] Must be marked during code analysis

**Spec**:
```python
def jumpdest(evm: Evm) -> None:
    # This is a valid jump target
    # No operation performed
    evm.gas_left -= GAS_JUMPDEST
```

**Action**: Verify jump destination analysis happens during initialization.

### 5. PC (0x58)
**Check**:
- [ ] Pushes current program counter
- [ ] Value BEFORE incrementing for next instruction
- [ ] Gas cost: 2 (GAS_BASE)

**Spec**:
```python
def pc(evm: Evm) -> None:
    push(evm.stack, Uint(evm.pc))
    evm.gas_left -= GAS_BASE
```

### 6. GAS (0x5A)
**Check**:
- [ ] Pushes remaining gas
- [ ] Value AFTER subtracting GAS opcode cost
- [ ] Gas cost: 2 (GAS_BASE)

**Spec**:
```python
def gas(evm: Evm) -> None:
    evm.gas_left -= GAS_BASE
    push(evm.stack, Uint(evm.gas_left))
```

**Action**: Verify gas is reported AFTER subtracting GAS opcode cost.

### 7. RETURN (0xF3)
**Check**:
- [ ] Pops offset and size
- [ ] Returns memory[offset:offset+size]
- [ ] Halts execution successfully
- [ ] Gas cost: 0 + memory_expansion

**Spec**:
```python
def return_(evm: Evm) -> None:
    offset = pop(evm.stack)
    size = pop(evm.stack)

    gas_cost = calculate_memory_gas_cost(evm, offset + size)
    charge_gas(evm, gas_cost)

    extend_memory(evm.memory, offset + size)
    evm.output = evm.memory[offset:offset + size]
    evm.running = False
```

### 8. REVERT (0xFD)
**Check**:
- [ ] Pops offset and size
- [ ] Returns memory[offset:offset+size] as error data
- [ ] Halts execution with failure
- [ ] Reverts state changes
- [ ] Refunds remaining gas
- [ ] Gas cost: 0 + memory_expansion

**Spec**:
```python
def revert(evm: Evm) -> None:
    offset = pop(evm.stack)
    size = pop(evm.stack)

    gas_cost = calculate_memory_gas_cost(evm, offset + size)
    charge_gas(evm, gas_cost)

    extend_memory(evm.memory, offset + size)
    evm.output = evm.memory[offset:offset + size]
    evm.error = Revert()
    evm.running = False
```

**Action**: Verify state rollback and gas refund.

### 9. INVALID (0xFE)
**Check**:
- [ ] Immediately halts execution
- [ ] Consumes all remaining gas
- [ ] Reverts state changes
- [ ] No gas refund

**Spec**:
```python
def invalid(evm: Evm) -> None:
    evm.gas_left = 0
    evm.error = InvalidOpcode()
    evm.running = False
```

**Action**: Verify all gas consumed.

### 10. Unknown Opcodes
**Check**:
- [ ] Any opcode not defined should act like INVALID
- [ ] Consume all gas
- [ ] Revert state

## JUMPDEST Analysis

**Check**:
- [ ] Valid jump destinations are pre-calculated
- [ ] JUMPDEST inside PUSH data is NOT valid
- [ ] Example: PUSH2 0x5B5B pushes two bytes (both 0x5B), neither is a valid JUMPDEST

**Spec**:
```python
def analyze_jumpdests(code: bytes) -> Set[int]:
    valid_jumpdests = set()
    pc = 0
    while pc < len(code):
        opcode = code[pc]
        if opcode == 0x5B:
            valid_jumpdests.add(pc)
        elif 0x60 <= opcode <= 0x7F:  # PUSH1-PUSH32
            # Skip data bytes
            pc += opcode - 0x5F
        pc += 1
    return valid_jumpdests
```

**Action**: CRITICAL - Verify JUMPDEST analysis skips PUSH data.

## Output Format

```markdown
# Agent 10: Control Flow Opcodes Audit Report

## Summary
- Total opcodes audited: 9
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

## JUMPDEST Validation
- [ ] JUMPDEST analysis implemented
- [ ] Skips PUSH data bytes
- [ ] JUMP/JUMPI validate destination
- [ ] Invalid jump reverts

## State Management
- [ ] STOP/RETURN: success, keep state
- [ ] REVERT: failure, rollback state, refund gas
- [ ] INVALID: failure, rollback state, consume all gas

## Gas Reporting
- [ ] GAS opcode reports gas AFTER its own cost

## Priority Summary
- **CRITICAL**: [Count]
- **HIGH**: [Count]
```
