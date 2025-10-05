# Agent 3: Arithmetic Opcodes Auditor

## Objective
Exhaustively audit all arithmetic opcodes (ADD, MUL, SUB, DIV, SDIV, MOD, SMOD, ADDMOD, MULMOD, EXP, SIGNEXTEND) against the Prague execution-specs reference implementation.

## Scope
**Files to examine**:
- Zig: `src/frame.zig` (search for arithmetic opcodes)
- Python spec: `execution-specs/src/ethereum/forks/prague/vm/instructions/arithmetic.py`
- Python spec: `execution-specs/src/ethereum/forks/prague/vm/gas.py`

## Reference
All arithmetic operations MUST use 256-bit unsigned integers with wrapping (modulo 2^256) behavior.

## Tasks

### 1. ADD (0x01)
**Check**:
- [ ] Pops 2 values from stack
- [ ] Wrapping addition (modulo 2^256)
- [ ] Gas cost: 3 (GAS_VERY_LOW)
- [ ] Stack underflow check

**Spec**:
```python
def add(evm: Evm) -> None:
    a = pop(evm.stack)
    b = pop(evm.stack)
    c = a.wrapping_add(b)
    push(evm.stack, c)
    evm.gas_left -= GAS_VERY_LOW
```

**Action**: Locate ADD implementation in `src/frame.zig`, verify exact behavior, check gas cost matches.

### 2. MUL (0x02)
**Check**:
- [ ] Pops 2 values from stack
- [ ] Wrapping multiplication (modulo 2^256)
- [ ] Gas cost: 5 (GAS_LOW)

**Spec**:
```python
def mul(evm: Evm) -> None:
    a = pop(evm.stack)
    b = pop(evm.stack)
    c = a.wrapping_mul(b)
    push(evm.stack, c)
    evm.gas_left -= GAS_LOW
```

**Action**: Verify multiplication wraps correctly, check gas cost.

### 3. SUB (0x03)
**Check**:
- [ ] Pops 2 values from stack
- [ ] Wrapping subtraction (modulo 2^256)
- [ ] Gas cost: 3 (GAS_VERY_LOW)

**Spec**:
```python
def sub(evm: Evm) -> None:
    a = pop(evm.stack)
    b = pop(evm.stack)
    c = a.wrapping_sub(b)
    push(evm.stack, c)
    evm.gas_left -= GAS_VERY_LOW
```

**Action**: Verify subtraction wraps (e.g., 0 - 1 = 2^256 - 1).

### 4. DIV (0x04)
**Check**:
- [ ] Pops 2 values from stack
- [ ] Integer division (truncate)
- [ ] Division by zero returns 0
- [ ] Gas cost: 5 (GAS_LOW)

**Spec**:
```python
def div(evm: Evm) -> None:
    a = pop(evm.stack)
    b = pop(evm.stack)
    if b == 0:
        quotient = Uint(0)
    else:
        quotient = a // b
    push(evm.stack, quotient)
    evm.gas_left -= GAS_LOW
```

**Action**: CRITICAL - Verify division by zero returns 0, not error.

### 5. SDIV (0x05)
**Check**:
- [ ] Pops 2 values from stack
- [ ] Signed division using two's complement
- [ ] Division by zero returns 0
- [ ] Overflow case: MIN_INT / -1 returns MIN_INT
- [ ] Gas cost: 5 (GAS_LOW)

**Spec**:
```python
def sdiv(evm: Evm) -> None:
    a = pop(evm.stack).to_signed()
    b = pop(evm.stack).to_signed()

    if b == 0:
        quotient = 0
    elif a == -2**255 and b == -1:
        # Overflow case
        quotient = -2**255
    else:
        sign = -1 if (a < 0) ^ (b < 0) else 1
        quotient = sign * (abs(a) // abs(b))

    push(evm.stack, quotient.to_unsigned())
    evm.gas_left -= GAS_LOW
```

**Action**: CRITICAL - Verify overflow case (MIN_INT / -1) returns MIN_INT, not error.

### 6. MOD (0x06)
**Check**:
- [ ] Pops 2 values from stack
- [ ] Modulo operation
- [ ] Modulo by zero returns 0
- [ ] Gas cost: 5 (GAS_LOW)

**Spec**:
```python
def mod(evm: Evm) -> None:
    a = pop(evm.stack)
    b = pop(evm.stack)
    if b == 0:
        remainder = Uint(0)
    else:
        remainder = a % b
    push(evm.stack, remainder)
    evm.gas_left -= GAS_LOW
```

**Action**: Verify modulo by zero returns 0.

### 7. SMOD (0x07)
**Check**:
- [ ] Pops 2 values from stack
- [ ] Signed modulo using two's complement
- [ ] Modulo by zero returns 0
- [ ] Result has same sign as dividend
- [ ] Gas cost: 5 (GAS_LOW)

**Spec**:
```python
def smod(evm: Evm) -> None:
    a = pop(evm.stack).to_signed()
    b = pop(evm.stack).to_signed()

    if b == 0:
        remainder = 0
    else:
        remainder = (abs(a) % abs(b))
        if a < 0:
            remainder = -remainder

    push(evm.stack, remainder.to_unsigned())
    evm.gas_left -= GAS_LOW
```

**Action**: Verify result sign matches dividend sign.

### 8. ADDMOD (0x08)
**Check**:
- [ ] Pops 3 values from stack (a, b, N)
- [ ] Computes (a + b) % N with arbitrary precision
- [ ] Modulo by zero returns 0
- [ ] Gas cost: 8 (GAS_MID)

**Spec**:
```python
def addmod(evm: Evm) -> None:
    a = pop(evm.stack)
    b = pop(evm.stack)
    n = pop(evm.stack)

    if n == 0:
        result = Uint(0)
    else:
        # Note: intermediate addition does NOT wrap
        result = (a + b) % n

    push(evm.stack, result)
    evm.gas_left -= GAS_MID
```

**Action**: CRITICAL - Verify intermediate sum uses arbitrary precision (doesn't wrap at 2^256).

### 9. MULMOD (0x09)
**Check**:
- [ ] Pops 3 values from stack (a, b, N)
- [ ] Computes (a * b) % N with arbitrary precision
- [ ] Modulo by zero returns 0
- [ ] Gas cost: 8 (GAS_MID)

**Spec**:
```python
def mulmod(evm: Evm) -> None:
    a = pop(evm.stack)
    b = pop(evm.stack)
    n = pop(evm.stack)

    if n == 0:
        result = Uint(0)
    else:
        # Note: intermediate product does NOT wrap
        result = (a * b) % n

    push(evm.stack, result)
    evm.gas_left -= GAS_MID
```

**Action**: CRITICAL - Verify intermediate product uses arbitrary precision (doesn't wrap at 2^256).

### 10. EXP (0x0A)
**Check**:
- [ ] Pops 2 values from stack (base, exponent)
- [ ] Computes base^exponent mod 2^256
- [ ] Gas cost: 10 + 50 * exponent_byte_size
- [ ] Gas calculation correct

**Spec**:
```python
def exp(evm: Evm) -> None:
    base = pop(evm.stack)
    exponent = pop(evm.stack)

    result = pow(base, exponent, 2**256)

    exponent_bytes = (exponent.bit_length() + 7) // 8
    gas_cost = GAS_EXPONENTIATION + GAS_EXPONENTIATION_PER_BYTE * exponent_bytes

    charge_gas(evm, gas_cost)
    push(evm.stack, result)
```

**Action**: Verify gas cost calculation (10 + 50 * byte_size).

### 11. SIGNEXTEND (0x0B)
**Check**:
- [ ] Pops 2 values from stack (byte_num, value)
- [ ] Extends sign bit at position byte_num
- [ ] If byte_num >= 31, returns value unchanged
- [ ] Gas cost: 5 (GAS_LOW)

**Spec**:
```python
def signextend(evm: Evm) -> None:
    byte_num = pop(evm.stack)
    value = pop(evm.stack)

    if byte_num >= 31:
        result = value
    else:
        bit_position = 8 * byte_num + 7
        sign_bit = (value >> bit_position) & 1

        if sign_bit == 1:
            # Negative: set all higher bits to 1
            mask = (1 << (bit_position + 1)) - 1
            result = value | (~mask & ((1 << 256) - 1))
        else:
            # Positive: clear all higher bits
            mask = (1 << (bit_position + 1)) - 1
            result = value & mask

    push(evm.stack, result)
    evm.gas_left -= GAS_LOW
```

**Action**: Verify sign extension logic, especially boundary case (byte_num >= 31).

## Output Format

```markdown
# Agent 3: Arithmetic Opcodes Audit Report

## Summary
- Total opcodes audited: 11
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
- [ ] All gas costs match gas.py
- [ ] Dynamic gas calculations correct (EXP)

## Edge Cases Verified
- [ ] Division/modulo by zero returns 0
- [ ] SDIV overflow (MIN_INT / -1) handled
- [ ] ADDMOD/MULMOD use arbitrary precision
- [ ] SIGNEXTEND boundary cases correct

## Priority Summary
- **CRITICAL**: [Count] - [Brief list]
- **HIGH**: [Count] - [Brief list]
- **MEDIUM**: [Count] - [Brief list]
- **LOW**: [Count] - [Brief list]
```

## Notes
- Be EXHAUSTIVE - check every detail
- Include exact line numbers
- Test edge cases mentally
- Verify gas costs against gas.py
- Flag ANY deviation from spec
