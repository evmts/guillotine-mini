# Agent 11: System Call Opcodes Auditor (CRITICAL)

## Objective
Audit the most complex and critical opcodes: CREATE, CREATE2, CALL family, RETURN, REVERT, and SELFDESTRUCT. These opcodes are likely the largest source of bugs and represent ~40% of implementation complexity.

## Priority
**CRITICAL** - System calls are the most complex opcodes and historically the biggest source of bugs.

## Scope
- Opcodes: CREATE (0xf0), CREATE2 (0xf5), CALL (0xf1), CALLCODE (0xf2), DELEGATECALL (0xf4), STATICCALL (0xfa), RETURN (0xf3), REVERT (0xfd), SELFDESTRUCT (0xff)
- Location: `src/frame.zig` (search for 0xf0, 0xf1, etc.)
- Reference: `execution-specs/src/ethereum/forks/prague/vm/instructions/system.py`

## Opcodes to Audit

### 1. CREATE (0xf0) & CREATE2 (0xf5)

**Python Spec Reference**: `system.py:create_message()`, `system.py:create2_message()`

#### Address Calculation

**CREATE**:
```python
# execution-specs/.../instructions/system.py
new_address = keccak256(rlp.encode([sender_address, sender_nonce]))[12:]
```

**CREATE2**:
```python
new_address = keccak256(
    b"\xff" + sender_address + salt + keccak256(init_code)
)[12:]
```

**Audit Checklist**:
- [ ] Address calculation implemented correctly?
- [ ] Uses correct hash function (keccak256)?
- [ ] CREATE uses nonce, CREATE2 uses salt?

#### Pre-Execution Checks

**From spec**:
```python
# 1. Depth limit
if message.depth >= 1024:
    return error

# 2. Balance check
if get_account(state, sender).balance < value:
    return error

# 3. Init code size limit (EIP-3860)
if len(init_code) > 2 * MAX_CODE_SIZE:  # 49152 bytes
    return error

# 4. Address collision
is_collision = (
    account_has_code_or_nonce(state, new_address) or
    account_has_storage(state, new_address)
)
if is_collision:
    return MessageCallOutput(
        gas_left=Uint(0),
        refund_counter=U256(0),
        logs=tuple(),
        accounts_to_delete=set(),
        error=AddressCollision(),
        return_data=Bytes(b""),
    )
```

**Audit Checklist**:
- [ ] Depth limit (1024) checked?
- [ ] Balance sufficient for value transfer?
- [ ] Init code size <= 49152? (EIP-3860)
- [ ] Address collision detection implemented?
  - Check for existing code
  - Check for non-zero nonce
  - Check for non-empty storage

#### Execution Flow

**From spec**:
```python
# 1. Increment nonce BEFORE execution
increment_nonce(state, sender)

# 2. Mark address as created (for EIP-6780)
mark_account_created(state, new_address)

# 3. Destroy any preexisting storage (edge case)
destroy_storage(state, new_address)

# 4. Execute init code
evm = process_message(message)

# 5. If successful, validate and store code
if not evm.error:
    contract_code = evm.output

    # Validate code size
    if len(contract_code) > MAX_CODE_SIZE:  # 24576 bytes
        raise OutOfGasError

    # Reject EOF prefix
    if len(contract_code) > 0 and contract_code[0] == 0xEF:
        raise InvalidContractPrefix

    # Charge code deposit gas
    code_deposit_gas = len(contract_code) * GAS_CODE_DEPOSIT  # 200 per byte
    charge_gas(evm, code_deposit_gas)

    # Store code
    set_code(state, new_address, contract_code)
```

**Audit Checklist**:
- [ ] Nonce incremented BEFORE execution?
- [ ] Address added to created_accounts set?
- [ ] Returned code size <= 24576?
- [ ] Code starting with 0xEF rejected?
- [ ] Code deposit gas charged (200 per byte)?
- [ ] Code set in state?

#### Gas Calculation

```python
# Base cost
gas_cost = GAS_CREATE  # 32000

# Init code cost (EIP-3860)
init_code_word_cost = 2 * ceil(len(init_code) / 32)
gas_cost += init_code_word_cost

# Memory expansion
gas_cost += memory_expansion_cost

# Gas forwarded to init code (after 1/64 rule)
gas_left_after_cost = evm.gas_left - gas_cost
gas_forwarded = gas_left_after_cost - (gas_left_after_cost // 64)
```

**Audit Checklist**:
- [ ] Base cost 32000 charged?
- [ ] Init code word cost charged?
- [ ] Memory expansion handled?
- [ ] Gas forwarding uses 63/64 rule?

---

### 2. CALL Family (CALL, CALLCODE, DELEGATECALL, STATICCALL)

**Python Spec Reference**: `system.py:call()`, `system.py:generic_call()`

#### Gas Forwarding (63/64 Rule)

**From spec**:
```python
# Available gas after charging for CALL operation
gas_left_after_cost = evm.gas_left - gas_cost

# Maximum that can be forwarded (63/64)
gas_available = gas_left_after_cost - (gas_left_after_cost // 64)

# Actual forwarded gas
gas_forwarded = min(gas_parameter_from_stack, gas_available)
```

**Audit Checklist**:
- [ ] 63/64 rule implemented?
- [ ] Minimum of gas_param and available gas?

#### CALL (0xf1) Specific

**Gas calculation**:
```python
gas_cost = calculate_message_call_gas(
    value, gas, gas_left, memory_cost, extra_gas, call_stipend
)

# If transferring value:
if value > 0:
    extra_gas += GAS_CALL_VALUE  # 9000
    call_stipend = GAS_CALL_STIPEND  # 2300

    # If creating new account:
    if not account_exists(recipient):
        extra_gas += GAS_NEW_ACCOUNT  # 25000

# Cold account access (EIP-2929):
if recipient not in accessed_addresses:
    extra_gas += GAS_COLD_ACCOUNT_ACCESS  # 2600
```

**Value transfer**:
```python
# Stipend is ADDED to forwarded gas, not deducted from caller
if value > 0:
    gas_forwarded += GAS_CALL_STIPEND  # 2300
```

**Audit Checklist**:
- [ ] Value transfer gas (9000) charged?
- [ ] New account gas (25000) charged if needed?
- [ ] Cold account access (2600) charged?
- [ ] Stipend (2300) ADDED to forwarded gas?
- [ ] Balance check before transfer?

#### STATICCALL (0xfa) Restrictions

**From spec**:
```python
# Set static mode
message.is_static = True

# In child execution, any of these cause revert:
# - SSTORE
# - LOG0, LOG1, LOG2, LOG3, LOG4
# - CREATE, CREATE2
# - SELFDESTRUCT
# - CALL with value > 0
```

**Audit Checklist**:
- [ ] `is_static` flag set in message?
- [ ] SSTORE checks is_static and reverts?
- [ ] LOG opcodes check is_static?
- [ ] CREATE opcodes check is_static?
- [ ] SELFDESTRUCT checks is_static?
- [ ] CALL checks is_static if value > 0?

#### DELEGATECALL (0xf4) Context

**From spec**:
```python
# Context preservation:
child_message.caller = parent_message.caller  # NOT parent's address
child_message.value = parent_message.value    # NOT new value
child_message.code_address = target
child_message.current_target = parent_message.current_target  # Storage modified here
```

**Audit Checklist**:
- [ ] caller is parent's caller (not parent)?
- [ ] value is parent's value?
- [ ] Storage modified in parent's context?

#### Return Data Handling

**From spec**:
```python
# After any call completes:
evm.return_data = child_evm.output

# RETURNDATASIZE (0x3d) returns len(evm.return_data)
# RETURNDATACOPY (0x3e) copies from evm.return_data
```

**Audit Checklist**:
- [ ] return_data updated after call?
- [ ] Available to RETURNDATASIZE/RETURNDATACOPY?

---

### 3. RETURN (0xf3) & REVERT (0xfd)

**From spec**:
```python
# RETURN
def ret(evm: Evm) -> None:
    memory_start_index = pop(evm.stack)
    size = pop(evm.stack)

    # Charge memory expansion
    extend_memory(evm, memory_start_index, size)

    # Copy output
    evm.output = memory_read_bytes(evm.memory, memory_start_index, size)

    # Stop execution
    evm.running = False

# REVERT (same, but sets error)
def revert(evm: Evm) -> None:
    # ... same memory expansion and output ...
    evm.error = Revert(evm.output)
    evm.running = False
```

**Audit Checklist**:
- [ ] Memory expansion charged?
- [ ] Output copied from memory?
- [ ] Execution stopped?
- [ ] REVERT sets error but keeps gas?
- [ ] RETURN succeeds without error?

---

### 4. SELFDESTRUCT (0xff) - EIP-6780 (CRITICAL)

**This is likely wrong in most implementations!**

**OLD behavior (pre-Prague)**:
- Delete account completely
- Send balance to beneficiary
- Gas refund of 24000

**NEW behavior (Prague - EIP-6780)**:
```python
def selfdestruct(evm: Evm) -> None:
    beneficiary = to_address(pop(evm.stack))
    originator = evm.message.current_target

    # Cold account access
    if beneficiary not in evm.accessed_addresses:
        charge_gas(evm, GAS_COLD_ACCOUNT_ACCESS)  # 2600
        evm.accessed_addresses.add(beneficiary)
    else:
        charge_gas(evm, GAS_WARM_ACCESS)  # 100

    # Static call check
    if evm.message.is_static:
        raise WriteInStaticContext

    # EIP-6780: ONLY delete if created in SAME transaction
    if originator in evm.message.state.created_accounts:
        evm.accounts_to_delete.add(originator)

    # ALWAYS send balance (even if not deleting)
    balance = get_account(evm.message.state, originator).balance
    move_ether(evm.message.state, originator, beneficiary, balance)

    # NO gas refund in Prague (EIP-3529)

    # Stop execution
    evm.running = False
```

**Critical Changes**:
1. **Only deletes if created in current transaction** (checks `created_accounts` set)
2. **No gas refund** (was 24000, now 0)
3. Still sends balance to beneficiary
4. Still charges cold/warm gas

**Audit Checklist**:
- [ ] Checks `created_accounts` set?
- [ ] Only adds to accounts_to_delete if created this tx?
- [ ] ALWAYS sends balance (even if not deleting)?
- [ ] NO gas refund given?
- [ ] Cold/warm account access gas charged?
- [ ] Static call restriction enforced?

**Most Common Bug**:
```zig
// WRONG (old behavior):
try self.getEvm().accounts_to_delete.put(address, {});

// CORRECT (EIP-6780):
if (self.getEvm().created_accounts.contains(address)) {
    try self.getEvm().accounts_to_delete.put(address, {});
}
// Always send balance regardless
```

---

### 5. Precompile Invocation

**From spec** (in `interpreter.py:execute_code()`):
```python
if evm.message.code_address in PRE_COMPILED_CONTRACTS:
    if message.disable_precompiles:  # EIP-7702 delegation
        return evm

    PRE_COMPILED_CONTRACTS[evm.message.code_address](evm)
    return evm
```

**Audit Checklist**:
- [ ] Precompiles called before interpreter loop?
- [ ] EIP-7702 disable_precompiles flag respected?
- [ ] Return immediately after precompile?

---

## Output Format

```markdown
# System Call Opcodes Audit - CRITICAL FINDINGS

## Executive Summary
- Opcodes audited: 9 (most complex)
- ✅ Correct: X
- ⚠️ Issues: Y
- ❌ Critical bugs: Z

## CRITICAL Issues (Fix Immediately)

### ❌ SELFDESTRUCT - EIP-6780 NOT IMPLEMENTED
**Severity**: CRITICAL
**Impact**: ~150 tests failing, wrong behavior in production

**Current Behavior** (src/frame.zig:XXXX):
```zig
// Deletes account unconditionally (old behavior)
try self.getEvm().accounts_to_delete.put(address, {});
```

**Expected Behavior**:
```zig
// Only delete if created in current transaction
const evm = self.getEvm();
if (evm.created_accounts.contains(address)) {
    try evm.accounts_to_delete.put(address, {});
}
// Always send balance to beneficiary
const balance = try evm.getBalance(address);
try evm.transferBalance(address, beneficiary, balance);
```

**Spec Reference**: `execution-specs/.../instructions/system.py:selfdestruct()`
**EIP**: EIP-6780

**Action Required**:
1. Add `created_accounts` Set to Evm struct (see Agent 2 report)
2. Check set in SELFDESTRUCT
3. Remove gas refund (now 0, was 24000)

---

### ❌ CREATE/CREATE2 - Missing Validation
**Severity**: HIGH
**Impact**: ~50 tests failing

**Issue 1: EOF Prefix Not Rejected**
- **Location**: CREATE/CREATE2 code validation
- **Missing Check**: `if (code[0] == 0xEF) return error;`
- **Impact**: Invalid code accepted
- **Spec**: `execution-specs/.../interpreter.py:process_create_message()`

**Issue 2: Address Collision Not Checked**
- **Location**: Before CREATE execution
- **Missing**:
  ```zig
  const has_code = evm.getCode(new_address).len > 0;
  const has_nonce = evm.getNonce(new_address) > 0;
  const has_storage = evm.hasStorage(new_address);
  if (has_code or has_nonce or has_storage) {
      return error.AddressCollision;
  }
  ```
- **Impact**: Overwrites existing accounts
- **Spec**: `execution-specs/.../interpreter.py:process_create_message()`

**Issue 3: Init Code Size Limit (EIP-3860)**
- **Location**: CREATE/CREATE2 pre-checks
- **Missing**: `if (init_code.len > 49152) return error;`
- **Impact**: Accepts oversized init code
- **EIP**: EIP-3860

---

### ⚠️ CALL - Gas Forwarding Issues
**Severity**: HIGH
**Impact**: ~30 tests with gas discrepancies

**Issue 1: 63/64 Rule**
- **Location**: CALL gas calculation
- **Expected**:
  ```zig
  const gas_available = gas_left - (gas_left / 64);
  const gas_forwarded = @min(gas_param, gas_available);
  ```
- **Verify**: Is denominator 64 (not 63)?

**Issue 2: CALL Stipend**
- **Location**: CALL with value > 0
- **Expected**: Stipend ADDED to forwarded gas (not subtracted from caller)
  ```zig
  if (value > 0) {
      gas_forwarded += 2300;  // GAS_CALL_STIPEND
  }
  ```
- **Common Bug**: Subtracting stipend from caller

---

### ⚠️ STATICCALL - Restrictions Not Enforced
**Severity**: HIGH
**Impact**: Static call violations not caught

**Missing Checks**:
1. In SSTORE: `if (is_static) return error;`
2. In LOG0-LOG4: `if (is_static) return error;`
3. In CREATE/CREATE2: `if (is_static) return error;`
4. In SELFDESTRUCT: `if (is_static) return error;`

**Location to Check**: Each of these opcodes
**Expected**: All should check frame's `is_static` flag

---

## Detailed Findings

### CREATE (0xf0)
**Status**: ⚠️ Partial Implementation

| Check | Status | Line |
|-------|--------|------|
| Address calculation | ✅ | frame.zig:XXXX |
| Depth limit | ✅ | frame.zig:XXXX |
| Balance check | ⚠️ | Verify needed |
| Init code size | ❌ | Missing |
| Address collision | ❌ | Missing |
| Nonce increment | ⚠️ | Verify timing |
| EOF prefix check | ❌ | Missing |
| Code deposit gas | ⚠️ | Verify |
| 63/64 gas rule | ⚠️ | Verify |

### CREATE2 (0xf5)
**Status**: ⚠️ Partial Implementation
- Same issues as CREATE
- Plus: Verify salt handling

### CALL (0xf1)
**Status**: ⚠️ Issues Found

| Check | Status | Issue |
|-------|--------|-------|
| Gas forwarding | ⚠️ | Verify 63/64 |
| Value transfer gas | ⚠️ | Verify 9000 |
| New account gas | ⚠️ | Verify 25000 |
| Stipend | ❌ | May be subtracted, should be added |
| Cold access | ⚠️ | Verify 2600 |

### CALLCODE (0xf2)
**Status**: ⚠️ Needs Review
- Similar to CALL, verify context handling

### DELEGATECALL (0xf4)
**Status**: ⚠️ Needs Review

| Check | Status |
|-------|--------|
| Caller preservation | ⚠️ |
| Value preservation | ⚠️ |
| Storage context | ⚠️ |

### STATICCALL (0xfa)
**Status**: ❌ Restrictions Not Enforced
- is_static flag may not be set
- Opcodes don't check flag
- Needs comprehensive review

### RETURN (0xf3)
**Status**: ✅ Likely Correct
- Simple opcode, verify memory expansion

### REVERT (0xfd)
**Status**: ✅ Likely Correct
- Verify gas preserved
- Verify output preserved

### SELFDESTRUCT (0xff)
**Status**: ❌ CRITICAL BUG - EIP-6780 NOT IMPLEMENTED
- Uses old behavior (always delete)
- Missing created_accounts check
- Gas refund may be wrong (should be 0)

---

## Priority Action Items

1. **IMMEDIATE**: Fix SELFDESTRUCT (EIP-6780)
   - Affects ~150 tests
   - Security critical

2. **HIGH**: Add CREATE/CREATE2 validation
   - EOF prefix rejection
   - Address collision detection
   - Init code size limit

3. **HIGH**: Fix STATICCALL restrictions
   - Add is_static checks to all state-modifying opcodes

4. **MEDIUM**: Verify CALL family gas calculations
   - 63/64 rule
   - Stipend handling
   - Cold/warm access

5. **MEDIUM**: Verify DELEGATECALL context preservation

## Estimated Test Impact
- SELFDESTRUCT bug: ~150 failures (12%)
- CREATE validation: ~50 failures (4%)
- STATICCALL: ~40 failures (3%)
- CALL gas: ~30 failures (2%)
- **Total**: ~270 failures (21% of all tests)

## Spec References
- `execution-specs/src/ethereum/forks/prague/vm/instructions/system.py`
- `execution-specs/src/ethereum/forks/prague/vm/interpreter.py`
- EIP-6780: https://eips.ethereum.org/EIPS/eip-6780
- EIP-3860: https://eips.ethereum.org/EIPS/eip-3860
