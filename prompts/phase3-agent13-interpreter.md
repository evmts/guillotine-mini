# Agent 13: Interpreter Loop Auditor

## Objective
Audit the main interpreter execution loop in `src/frame.zig` for correct instruction dispatch, PC management, gas handling, and stack/memory management.

## Scope
**Files to examine**:
- Zig: `src/frame.zig` (main execution loop)
- Zig: `src/evm.zig` (EVM state management)
- Python spec: `execution-specs/src/ethereum/forks/prague/vm/interpreter.py`

## Dependencies
**Requires completion of**: Agents 3-12 (all opcode audits)

## Tasks

### 1. Main Execution Loop

**Check**:
- [ ] Loop structure correct (while running)
- [ ] PC (program counter) management
- [ ] Opcode fetch and dispatch
- [ ] Gas tracking
- [ ] Stack overflow/underflow detection
- [ ] Exceptional halting conditions

**Spec**:
```python
def run(evm: Evm) -> None:
    while evm.running and evm.pc < len(evm.code):
        # Check gas
        if evm.gas_left < 0:
            raise OutOfGas

        # Fetch opcode
        opcode = evm.code[evm.pc]
        evm.pc += 1

        # Execute opcode
        OP_IMPLEMENTATIONS[opcode](evm)

        # Check stack depth
        if len(evm.stack) > 1024:
            raise StackOverflow
```

**Action**: Verify loop structure, gas checks, and error handling.

### 2. Program Counter (PC) Management

**Check**:
- [ ] PC starts at 0
- [ ] PC incremented BEFORE opcode execution
- [ ] JUMP/JUMPI set PC directly
- [ ] PUSH opcodes skip immediate bytes
- [ ] PC bounds checking

**Spec**:
```python
# PC is incremented BEFORE opcode execution
evm.pc += 1
execute_opcode(opcode, evm)

# PUSH opcodes increment PC by data size
if 0x60 <= opcode <= 0x7F:  # PUSH1-PUSH32
    num_bytes = opcode - 0x5F
    evm.pc += num_bytes

# JUMP sets PC directly
if opcode == 0x56:  # JUMP
    evm.pc = pop(evm.stack)
```

**Action**: Verify PC incremented at correct time, PUSH skips data, JUMP sets PC.

### 3. Stack Management

**Check**:
- [ ] Stack starts empty
- [ ] Maximum depth: 1024
- [ ] Stack overflow checked after each operation
- [ ] Stack underflow checked on pop
- [ ] Stack elements are U256

**Spec**:
```python
def push(stack: List[U256], value: U256) -> None:
    stack.append(value)
    if len(stack) > 1024:
        raise StackOverflow

def pop(stack: List[U256]) -> U256:
    if len(stack) == 0:
        raise StackUnderflow
    return stack.pop()
```

**Action**: Verify stack depth limits enforced.

### 4. Memory Management

**Check**:
- [ ] Memory starts empty
- [ ] Expands dynamically in 32-byte words
- [ ] Always initialized to zero
- [ ] Quadratic expansion cost
- [ ] No maximum size (only gas limit)

**Spec**:
```python
def extend_memory(memory: bytearray, size: int) -> None:
    if size > len(memory):
        # Round up to multiple of 32
        new_size = ((size + 31) // 32) * 32
        memory.extend(b'\x00' * (new_size - len(memory)))

def calculate_memory_gas_cost(current_size: int, new_size: int) -> int:
    if new_size <= current_size:
        return 0

    current_words = (current_size + 31) // 32
    new_words = (new_size + 31) // 32

    current_cost = 3 * current_words + current_words ** 2 // 512
    new_cost = 3 * new_words + new_words ** 2 // 512

    return new_cost - current_cost
```

**Action**: CRITICAL - Verify quadratic memory cost formula.

### 5. Gas Tracking

**Check**:
- [ ] Gas starts at tx.gas_limit
- [ ] Decremented for each opcode
- [ ] Checked BEFORE opcode execution
- [ ] OutOfGas reverts transaction
- [ ] Remaining gas refunded after execution

**Spec**:
```python
def execute_opcode(opcode: int, evm: Evm) -> None:
    gas_cost = calculate_gas_cost(opcode, evm)

    if evm.gas_left < gas_cost:
        raise OutOfGas

    evm.gas_left -= gas_cost

    # Execute opcode
    OP_IMPLEMENTATIONS[opcode](evm)
```

**Action**: Verify gas checked BEFORE execution, not after.

### 6. Exceptional Halting

**Check**:
- [ ] OutOfGas
- [ ] StackOverflow (> 1024)
- [ ] StackUnderflow
- [ ] InvalidJump
- [ ] InvalidOpcode
- [ ] WriteInStaticContext

**All exceptional halts**:
- Consume all remaining gas (except REVERT)
- Revert state changes
- Return empty output (except REVERT which can return data)

**Action**: Verify all exceptional conditions revert state and consume gas.

### 7. Call Stack Management

**Check**:
- [ ] Maximum call depth: 1024
- [ ] CREATE/CALL/DELEGATECALL/STATICCALL increment depth
- [ ] RETURN/REVERT/STOP decrement depth
- [ ] Call depth limit enforced

**Spec**:
```python
def call(evm: Evm, target: Address, gas: int, value: int, data: bytes, is_static: bool) -> Tuple[bool, bytes]:
    if evm.call_depth >= 1024:
        return False, b''

    # Create child EVM
    child = Evm(
        call_depth=evm.call_depth + 1,
        gas_left=gas,
        is_static=is_static or evm.is_static,
        # ... other fields
    )

    # Execute
    run(child)

    # Return result
    return not child.has_error, child.output
```

**Action**: Verify call depth limit (1024) enforced.

### 8. Return Data Management

**Check**:
- [ ] Return data saved after each call
- [ ] Available to RETURNDATASIZE/RETURNDATACOPY
- [ ] Cleared/updated on each new call
- [ ] Preserved across non-call opcodes

**Spec**:
```python
# After CALL/DELEGATECALL/STATICCALL
evm.returndata = child.output

# RETURNDATASIZE reads from last call
def returndatasize(evm: Evm) -> None:
    push(evm.stack, Uint(len(evm.returndata)))
```

**Action**: Verify return data updated after calls.

### 9. Code Validation

**Check**:
- [ ] EOF prefix (0xEF) rejected
- [ ] Code size limits enforced
- [ ] JUMPDEST analysis performed on code
- [ ] PUSH data not executable

**Spec**:
```python
def validate_code(code: bytes) -> None:
    # Reject EOF format
    if len(code) > 0 and code[0] == 0xEF:
        raise InvalidCode

    # Analyze valid JUMPDEST positions
    valid_jumpdests = analyze_jumpdests(code)
```

**Action**: Verify EOF rejection and JUMPDEST analysis.

### 10. Integration with EVM State

**Check**:
- [ ] Frame has reference to EVM state
- [ ] Storage operations update state
- [ ] Account modifications tracked
- [ ] Snapshots/rollbacks on call boundaries

**Action**: Verify frame integrates correctly with EVM state management.

## Output Format

```markdown
# Agent 13: Interpreter Loop Audit Report

## Summary
- ✅ Correct components: X
- ⚠️ Issues found: Y
- ❌ Critical bugs: Z

## Detailed Findings

### ✅ Correct Implementations
[List correct components]

### ⚠️ Issues Found

#### [Priority] - [Component]
**File**: src/frame.zig:LINE
**Issue**: [Description]
**Spec**: [Python reference]
**Fix**: [What needs to change]

## Execution Loop
- [ ] Loop structure correct
- [ ] PC management correct
- [ ] Gas tracking correct
- [ ] Error handling complete

## Stack and Memory
- [ ] Stack depth limit (1024)
- [ ] Memory expansion gas (quadratic)
- [ ] Stack underflow detection
- [ ] Memory zero-initialization

## Exceptional Halting
- [ ] OutOfGas
- [ ] StackOverflow/Underflow
- [ ] InvalidJump
- [ ] InvalidOpcode
- [ ] All consume gas and revert state

## Call Management
- [ ] Call depth limit (1024)
- [ ] Return data tracking
- [ ] Static call restrictions

## Code Validation
- [ ] EOF (0xEF) prefix rejected
- [ ] JUMPDEST analysis performed
- [ ] Valid jump destination checking

## Priority Summary
- **CRITICAL**: [Count]
- **HIGH**: [Count]
- **MEDIUM**: [Count]
```

## Notes
- This audit builds on all opcode audits (agents 3-12)
- Focus on orchestration and error handling
- Verify integration between components
- Check boundary conditions (depth limits, stack size, etc.)
