# Agent 6: Storage Opcodes Auditor (SLOAD, SSTORE, TLOAD, TSTORE)

## Objective
Exhaustively audit storage opcodes including EIP-1153 transient storage and complex SSTORE gas refund logic.

## Scope
**Files to examine**:
- Zig: `src/frame.zig` (SLOAD, SSTORE, TLOAD, TSTORE)
- Zig: `src/evm.zig` (transient_storage map)
- Python spec: `execution-specs/src/ethereum/forks/prague/vm/instructions/storage.py`
- Python spec: `execution-specs/src/ethereum/forks/prague/state.py` (TransientStorage)

## Dependencies
**Requires**:
- Agent 1 (gas constants verified)
- Agent 2 (state management verified)

## Tasks

### 1. TLOAD (0x5C) - EIP-1153
**Check**:
- [ ] Implemented
- [ ] Pops address and key
- [ ] Reads from transient storage
- [ ] Returns 0 if key not set
- [ ] Gas cost: 100 (GAS_WARM_ACCESS)
- [ ] No cold/warm tracking

**Spec**:
```python
def tload(evm: Evm) -> None:
    key = pop(evm.stack)
    value = evm.env.state.get_transient_storage(evm.message.current_target, key)
    push(evm.stack, value)
    evm.gas_left -= GAS_WARM_ACCESS  # 100
```

**Action**: Verify transient storage map exists in evm.zig, returns 0 for missing keys.

### 2. TSTORE (0x5D) - EIP-1153
**Check**:
- [ ] Implemented
- [ ] Pops address and key and value
- [ ] Writes to transient storage
- [ ] Gas cost: 100 (GAS_WARM_ACCESS)
- [ ] No refunds
- [ ] Reverts in STATICCALL context

**Spec**:
```python
def tstore(evm: Evm) -> None:
    if evm.message.is_static:
        raise WriteInStaticContext

    key = pop(evm.stack)
    value = pop(evm.stack)

    evm.env.state.set_transient_storage(evm.message.current_target, key, value)
    evm.gas_left -= GAS_WARM_ACCESS  # 100
```

**Action**: Verify STATICCALL restriction, no refunds given.

### 3. SLOAD (0x54) - EIP-2929
**Check**:
- [ ] Pops key
- [ ] Reads from persistent storage
- [ ] Cold access: 2100 gas (GAS_COLD_SLOAD)
- [ ] Warm access: 100 gas (GAS_WARM_ACCESS)
- [ ] Access tracking correct

**Spec**:
```python
def sload(evm: Evm) -> None:
    key = pop(evm.stack)

    # Check if cold access
    if (evm.message.current_target, key) not in evm.accessed_storage_keys:
        evm.accessed_storage_keys.add((evm.message.current_target, key))
        gas_cost = GAS_COLD_SLOAD  # 2100
    else:
        gas_cost = GAS_WARM_ACCESS  # 100

    charge_gas(evm, gas_cost)

    value = evm.env.state.get_storage(evm.message.current_target, key)
    push(evm.stack, value)
```

**Action**: CRITICAL - Verify cold/warm tracking and gas costs.

### 4. SSTORE (0x55) - EIP-2200 + EIP-2929 + EIP-3529
**This is the most complex opcode in the EVM.**

**Check**:
- [ ] Pops key and value
- [ ] Reverts in STATICCALL context
- [ ] Sentry check: requires gas_left > 2300
- [ ] Cold access adds 2100 gas
- [ ] Complex refund calculation
- [ ] Original value tracking

**Spec**:
```python
def sstore(evm: Evm) -> None:
    if evm.message.is_static:
        raise WriteInStaticContext

    key = pop(evm.stack)
    new_value = pop(evm.stack)

    # Sentry gas check (EIP-2200)
    if evm.gas_left <= GAS_CALL_STIPEND:  # 2300
        raise OutOfGas

    current_value = evm.env.state.get_storage(evm.message.current_target, key)
    original_value = evm.env.state.get_storage_original(evm.message.current_target, key)

    # Base gas cost
    gas_cost = 0

    # Cold access cost (EIP-2929)
    if (evm.message.current_target, key) not in evm.accessed_storage_keys:
        evm.accessed_storage_keys.add((evm.message.current_target, key))
        gas_cost += GAS_COLD_SLOAD  # 2100

    # Storage modification cost
    if current_value == new_value:
        # No change
        gas_cost += GAS_WARM_ACCESS  # 100
    else:
        if original_value == current_value:
            # First write to this slot in transaction
            if original_value == 0:
                # Create slot
                gas_cost += GAS_STORAGE_SET  # 20000
            else:
                # Modify existing slot
                gas_cost += GAS_STORAGE_UPDATE  # 5000
        else:
            # Slot was already modified in this transaction
            gas_cost += GAS_WARM_ACCESS  # 100

    charge_gas(evm, gas_cost)

    # Refund calculation (EIP-3529)
    refund = 0
    if current_value != new_value:
        if original_value != 0:
            if current_value != 0 and new_value == 0:
                # Deleting storage
                refund += GAS_STORAGE_CLEAR_REFUND  # 4800

            if original_value != current_value:
                if original_value != 0 and current_value == 0:
                    # We previously got a refund for clearing, undo it
                    refund -= GAS_STORAGE_CLEAR_REFUND  # -4800

                if original_value == new_value:
                    # Restoring original value
                    if original_value == 0:
                        # Reset to zero
                        refund += GAS_STORAGE_SET - GAS_WARM_ACCESS  # 19900
                    else:
                        # Reset to non-zero
                        refund += GAS_STORAGE_UPDATE - GAS_WARM_ACCESS  # 4900

    evm.gas_refund += refund

    # Store value
    evm.env.state.set_storage(evm.message.current_target, key, new_value)
```

**Action**: CRITICAL - Verify every condition in this complex logic.

**Key refund scenarios**:
1. Setting to zero: +4800 refund
2. Previously set to zero, now resetting back: +19900 refund
3. Previously modified, now restoring original non-zero: +4900 refund
4. Previously got refund for clearing, now undoing: -4800 refund

**Constants to verify**:
- GAS_STORAGE_SET = 20000
- GAS_STORAGE_UPDATE = 5000
- GAS_STORAGE_CLEAR_REFUND = 4800 (EIP-3529, was 15000)
- GAS_COLD_SLOAD = 2100
- GAS_WARM_ACCESS = 100
- GAS_CALL_STIPEND = 2300 (sentry check)

### 5. Original Value Tracking
**Check**:
- [ ] State maintains original storage values
- [ ] Original value is value at start of transaction
- [ ] Used for SSTORE refund calculations

**Spec**:
```python
class State:
    _storage_original: Dict[Tuple[Address, Bytes32], U256]

    def get_storage_original(self, address: Address, key: Bytes32) -> U256:
        if (address, key) in self._storage_original:
            return self._storage_original[(address, key)]
        else:
            # First access - record current value as original
            value = self.get_storage(address, key)
            self._storage_original[(address, key)] = value
            return value
```

**Action**: Verify original value tracking exists in state management.

### 6. Transient Storage Lifecycle
**Check**:
- [ ] Transient storage cleared after EACH transaction
- [ ] NOT cleared between internal calls
- [ ] Survives reverts within transaction
- [ ] Not included in state root

**Spec**:
```python
# In transaction processing:
def process_transaction(env: Environment, tx: Transaction) -> None:
    # Clear transient storage at start
    env.state.transient_storage.clear()

    # Execute transaction
    ...

    # Transient storage automatically discarded at end
```

**Action**: Verify transient storage cleared in transaction processing loop.

## Output Format

```markdown
# Agent 6: Storage Opcodes Audit Report

## Summary
- Total opcodes audited: 4 (SLOAD, SSTORE, TLOAD, TSTORE)
- ✅ Correct: X
- ⚠️ Issues found: Y
- ❌ Critical bugs: Z

## Detailed Findings

### EIP-1153 Transient Storage
- [ ] TLOAD implemented
- [ ] TSTORE implemented
- [ ] Transient storage map exists in evm.zig
- [ ] Cleared after each transaction
- [ ] STATICCALL restriction enforced

### EIP-2929 Access Tracking
- [ ] Cold SLOAD costs 2100
- [ ] Warm SLOAD costs 100
- [ ] Cold SSTORE adds 2100
- [ ] Access tracking works correctly

### SSTORE Refund Logic (EIP-3529)
- [ ] Sentry check (gas > 2300)
- [ ] Original value tracking
- [ ] Clear refund: 4800 (not 15000)
- [ ] Reset refunds correct
- [ ] All refund scenarios handled

### Issues Found

#### [Priority] - [Issue]
**File**: [path:line]
**Issue**: [Description]
**Spec**: [Python reference]
**Fix required**: [What to change]

## SSTORE Test Cases
Verify these scenarios:
- [ ] Setting zero slot to non-zero: 20000 + cold
- [ ] Modifying non-zero slot: 5000 + cold
- [ ] Setting to same value: 100 + cold
- [ ] Clearing slot (to zero): 5000 + cold, +4800 refund
- [ ] Restoring original zero: +19900 refund
- [ ] Restoring original non-zero: +4900 refund

## Priority Summary
- **CRITICAL**: [Count]
- **HIGH**: [Count]
- **MEDIUM**: [Count]
```
