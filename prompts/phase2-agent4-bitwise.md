# Agent 4: Bitwise and Comparison Opcodes Auditor

## Objective
Exhaustively audit all bitwise and comparison opcodes against the Prague execution-specs reference implementation.

## Scope
**Files to examine**:
- Zig: `src/frame.zig`
- Python spec: `execution-specs/src/ethereum/forks/prague/vm/instructions/bitwise.py`
- Python spec: `execution-specs/src/ethereum/forks/prague/vm/instructions/comparison.py`
- Python spec: `execution-specs/src/ethereum/forks/prague/vm/gas.py`

## Tasks

### Bitwise Operations

#### 1. LT (0x10) - Less Than
**Check**:
- [ ] Pops 2 values (a, b)
- [ ] Pushes 1 if a < b, else 0
- [ ] Unsigned comparison
- [ ] Gas cost: 3 (GAS_VERY_LOW)

**Spec**:
```python
def lt(evm: Evm) -> None:
    a = pop(evm.stack)
    b = pop(evm.stack)
    result = Uint(1) if a < b else Uint(0)
    push(evm.stack, result)
    evm.gas_left -= GAS_VERY_LOW
```

#### 2. GT (0x11) - Greater Than
**Check**:
- [ ] Pops 2 values (a, b)
- [ ] Pushes 1 if a > b, else 0
- [ ] Unsigned comparison
- [ ] Gas cost: 3 (GAS_VERY_LOW)

#### 3. SLT (0x12) - Signed Less Than
**Check**:
- [ ] Pops 2 values (a, b)
- [ ] Converts to signed (two's complement)
- [ ] Pushes 1 if a < b, else 0
- [ ] Gas cost: 3 (GAS_VERY_LOW)

**Spec**:
```python
def slt(evm: Evm) -> None:
    a = pop(evm.stack).to_signed()
    b = pop(evm.stack).to_signed()
    result = Uint(1) if a < b else Uint(0)
    push(evm.stack, result)
    evm.gas_left -= GAS_VERY_LOW
```

#### 4. SGT (0x13) - Signed Greater Than
**Check**:
- [ ] Pops 2 values (a, b)
- [ ] Converts to signed (two's complement)
- [ ] Pushes 1 if a > b, else 0
- [ ] Gas cost: 3 (GAS_VERY_LOW)

#### 5. EQ (0x14) - Equality
**Check**:
- [ ] Pops 2 values (a, b)
- [ ] Pushes 1 if a == b, else 0
- [ ] Gas cost: 3 (GAS_VERY_LOW)

#### 6. ISZERO (0x15)
**Check**:
- [ ] Pops 1 value
- [ ] Pushes 1 if value == 0, else 0
- [ ] Gas cost: 3 (GAS_VERY_LOW)

#### 7. AND (0x16)
**Check**:
- [ ] Pops 2 values (a, b)
- [ ] Pushes bitwise AND (a & b)
- [ ] Gas cost: 3 (GAS_VERY_LOW)

#### 8. OR (0x17)
**Check**:
- [ ] Pops 2 values (a, b)
- [ ] Pushes bitwise OR (a | b)
- [ ] Gas cost: 3 (GAS_VERY_LOW)

#### 9. XOR (0x18)
**Check**:
- [ ] Pops 2 values (a, b)
- [ ] Pushes bitwise XOR (a ^ b)
- [ ] Gas cost: 3 (GAS_VERY_LOW)

#### 10. NOT (0x19)
**Check**:
- [ ] Pops 1 value
- [ ] Pushes bitwise NOT (~value)
- [ ] Result is (2^256 - 1 - value)
- [ ] Gas cost: 3 (GAS_VERY_LOW)

**Spec**:
```python
def not_(evm: Evm) -> None:
    a = pop(evm.stack)
    result = ~a  # Bitwise NOT
    push(evm.stack, result)
    evm.gas_left -= GAS_VERY_LOW
```

#### 11. BYTE (0x1A)
**Check**:
- [ ] Pops 2 values (byte_offset, value)
- [ ] Pushes byte at position byte_offset from left
- [ ] If byte_offset >= 32, returns 0
- [ ] Gas cost: 3 (GAS_VERY_LOW)

**Spec**:
```python
def byte(evm: Evm) -> None:
    byte_offset = pop(evm.stack)
    value = pop(evm.stack)

    if byte_offset >= 32:
        result = Uint(0)
    else:
        # Get byte from left (MSB)
        shift = 8 * (31 - byte_offset)
        result = (value >> shift) & 0xFF

    push(evm.stack, result)
    evm.gas_left -= GAS_VERY_LOW
```

**Action**: CRITICAL - Verify byte indexing (0 = leftmost/MSB).

#### 12. SHL (0x1B) - Shift Left
**Check**:
- [ ] Pops 2 values (shift, value)
- [ ] Pushes value << shift
- [ ] If shift >= 256, returns 0
- [ ] Gas cost: 3 (GAS_VERY_LOW)

**Spec**:
```python
def shl(evm: Evm) -> None:
    shift = pop(evm.stack)
    value = pop(evm.stack)

    if shift >= 256:
        result = Uint(0)
    else:
        result = (value << shift) & ((1 << 256) - 1)

    push(evm.stack, result)
    evm.gas_left -= GAS_VERY_LOW
```

**Action**: Verify shift >= 256 returns 0.

#### 13. SHR (0x1C) - Shift Right (Logical)
**Check**:
- [ ] Pops 2 values (shift, value)
- [ ] Pushes value >> shift (logical)
- [ ] If shift >= 256, returns 0
- [ ] Gas cost: 3 (GAS_VERY_LOW)

**Action**: Verify logical shift (fills with zeros).

#### 14. SAR (0x1D) - Shift Right (Arithmetic)
**Check**:
- [ ] Pops 2 values (shift, value)
- [ ] Pushes value >> shift (arithmetic)
- [ ] Sign extends (fills with sign bit)
- [ ] If shift >= 256, returns all 0s or all 1s (based on sign)
- [ ] Gas cost: 3 (GAS_VERY_LOW)

**Spec**:
```python
def sar(evm: Evm) -> None:
    shift = pop(evm.stack)
    value = pop(evm.stack).to_signed()

    if shift >= 256:
        result = 0 if value >= 0 else -1
    else:
        result = value >> shift  # Arithmetic shift

    push(evm.stack, result.to_unsigned())
    evm.gas_left -= GAS_VERY_LOW
```

**Action**: CRITICAL - Verify sign extension behavior.

## Output Format

```markdown
# Agent 4: Bitwise and Comparison Opcodes Audit Report

## Summary
- Total opcodes audited: 14
- ✅ Correct: X
- ⚠️ Issues found: Y
- ❌ Critical bugs: Z

## Detailed Findings

### ✅ Correct Implementations
[List opcodes that match spec exactly]

### ⚠️ Issues Found

#### [Priority: CRITICAL/HIGH/MEDIUM/LOW] - [Opcode Name]
**File**: src/frame.zig:LINE
**Issue**: [Description]
**Spec**: [Python reference]
**Current**: [What Zig code does]
**Fix required**: [What needs to change]

## Gas Cost Verification
- [ ] All gas costs are GAS_VERY_LOW (3)

## Edge Cases Verified
- [ ] BYTE with offset >= 32 returns 0
- [ ] SHL/SHR/SAR with shift >= 256 handled correctly
- [ ] SAR sign extension correct
- [ ] Signed comparisons use two's complement

## Priority Summary
- **CRITICAL**: [Count]
- **HIGH**: [Count]
- **MEDIUM**: [Count]
- **LOW**: [Count]
```
