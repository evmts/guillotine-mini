# Agent 14: Transaction Processing Auditor

## Objective
Audit top-level transaction processing including validation, initialization, access list pre-warming, and finalization.

## Scope
**Files to examine**:
- Zig: `src/evm.zig` (transaction processing entry point)
- Zig: `src/primitives/transaction.zig` (transaction types)
- Python spec: `execution-specs/src/ethereum/forks/prague/fork.py` (apply_transaction, validate_transaction)
- Python spec: `execution-specs/src/ethereum/forks/prague/state.py`

## Dependencies
**Requires**: Agents 1 (primitives) and 2 (state management)

## Tasks

### 1. Transaction Types

**Check all 5 types exist**:
- [ ] Type 0: LegacyTransaction
- [ ] Type 1: AccessListTransaction (EIP-2930)
- [ ] Type 2: FeeMarketTransaction (EIP-1559)
- [ ] Type 3: BlobTransaction (EIP-4844)
- [ ] Type 4: SetCodeTransaction (EIP-7702)

**Action**: Verify all transaction types in `src/primitives/transaction.zig`.

### 2. Transaction Validation

**Check**:
- [ ] Nonce matches sender's account nonce
- [ ] Gas limit >= intrinsic gas
- [ ] Sender balance >= gas_limit * gas_price + value
- [ ] Signature valid (ecrecover)
- [ ] Chain ID matches (for EIP-155 and later)

**Spec**:
```python
def validate_transaction(tx: Transaction, state: State) -> None:
    # Validate nonce
    sender = recover_sender(tx)
    if tx.nonce != state.get_nonce(sender):
        raise InvalidNonce

    # Validate gas limit
    intrinsic_gas = calculate_intrinsic_gas(tx)
    if tx.gas_limit < intrinsic_gas:
        raise InvalidGasLimit

    # Validate balance
    gas_cost = tx.gas_limit * tx.gas_price  # Simplified
    if state.get_balance(sender) < gas_cost + tx.value:
        raise InsufficientBalance

    # Validate signature
    if not verify_signature(tx):
        raise InvalidSignature
```

**Action**: Verify all validation checks present.

### 3. Intrinsic Gas Calculation

**Check**:
- [ ] Base: 21000
- [ ] Per zero byte: 4
- [ ] Per non-zero byte: 16
- [ ] CREATE adds 32000
- [ ] Access list: 2400 per address + 1900 per storage key
- [ ] Init code (EIP-3860): 2 per 32-byte word

**Spec**:
```python
def calculate_intrinsic_gas(tx: Transaction) -> int:
    gas = GAS_TRANSACTION  # 21000

    # Count data bytes
    for byte in tx.data:
        if byte == 0:
            gas += GAS_TX_DATA_ZERO  # 4
        else:
            gas += GAS_TX_DATA_NONZERO  # 16

    # CREATE adds 32000
    if tx.to is None:
        gas += GAS_CREATE  # 32000

        # Init code cost (EIP-3860)
        init_code_words = (len(tx.data) + 31) // 32
        gas += GAS_INIT_CODE_WORD_COST * init_code_words  # 2 per word

    # Access list (EIP-2930)
    if hasattr(tx, 'access_list'):
        for address, storage_keys in tx.access_list:
            gas += GAS_ACCESS_LIST_ADDRESS  # 2400
            gas += GAS_ACCESS_LIST_STORAGE_KEY * len(storage_keys)  # 1900 each

    return gas
```

**Constants to verify**:
- GAS_TRANSACTION = 21000
- GAS_TX_DATA_ZERO = 4
- GAS_TX_DATA_NONZERO = 16
- GAS_CREATE = 32000
- GAS_ACCESS_LIST_ADDRESS = 2400
- GAS_ACCESS_LIST_STORAGE_KEY = 1900
- GAS_INIT_CODE_WORD_COST = 2

**Action**: CRITICAL - Verify intrinsic gas calculation.

### 4. Access List Pre-warming (EIP-2929)

**Check**:
- [ ] Access list addresses pre-warmed BEFORE execution
- [ ] Access list storage keys pre-warmed
- [ ] Sender address always pre-warmed
- [ ] Recipient address pre-warmed (if not CREATE)
- [ ] Coinbase address pre-warmed
- [ ] Precompiles (0x01-0x09) pre-warmed in Prague

**Spec**:
```python
def process_transaction(env: Environment, tx: Transaction) -> Receipt:
    sender = recover_sender(tx)

    # Initialize access sets (EIP-2929)
    accessed_addresses = {sender, env.coinbase}
    accessed_storage_keys = set()

    # Pre-warm recipient
    if tx.to is not None:
        accessed_addresses.add(tx.to)

    # Pre-warm precompiles (Prague)
    for addr in range(1, 10):
        accessed_addresses.add(Address(addr))

    # Pre-warm access list (EIP-2930)
    if hasattr(tx, 'access_list'):
        for address, storage_keys in tx.access_list:
            accessed_addresses.add(address)
            for key in storage_keys:
                accessed_storage_keys.add((address, key))

    # Execute...
```

**Action**: CRITICAL - Verify access list pre-warming happens BEFORE execution starts.

### 5. Transaction Initialization

**Check**:
- [ ] Nonce incremented
- [ ] Gas purchased (balance -= gas_limit * gas_price)
- [ ] Transient storage cleared
- [ ] Original storage values cleared (for this tx)
- [ ] Return data cleared

**Spec**:
```python
def apply_transaction(env: Environment, tx: Transaction) -> Receipt:
    sender = recover_sender(tx)

    # Increment nonce
    env.state.set_nonce(sender, env.state.get_nonce(sender) + 1)

    # Purchase gas
    gas_cost = tx.gas_limit * effective_gas_price(tx, env.block.base_fee)
    env.state.set_balance(sender, env.state.get_balance(sender) - gas_cost)

    # Clear transient storage (EIP-1153)
    env.state.transient_storage.clear()

    # Clear created accounts tracking (EIP-6780)
    env.state.created_accounts.clear()

    # Execute...
```

**Action**: Verify nonce increment and gas purchase happen at start.

### 6. Message Creation

**Check**:
- [ ] CREATE vs CALL message differentiation
- [ ] Value transfer
- [ ] Gas allocation
- [ ] Depth starts at 0
- [ ] is_static flag set correctly

**Spec**:
```python
if tx.to is None:
    # CREATE
    message = Message(
        caller=sender,
        target=compute_create_address(sender, nonce),
        value=tx.value,
        data=tx.data,  # init code
        gas=tx.gas_limit - intrinsic_gas,
        depth=0,
        is_static=False,
    )
else:
    # CALL
    message = Message(
        caller=sender,
        target=tx.to,
        value=tx.value,
        data=tx.data,
        gas=tx.gas_limit - intrinsic_gas,
        depth=0,
        is_static=False,
    )
```

**Action**: Verify CREATE address calculation and message initialization.

### 7. Transaction Finalization

**Check**:
- [ ] Gas refund calculation (max gas_used / 5)
- [ ] Gas refund applied
- [ ] Coinbase payment (gas_used * gas_price)
- [ ] Self-destructs processed (only if in created_accounts per EIP-6780)
- [ ] Logs collected
- [ ] Receipt created

**Spec**:
```python
def finalize_transaction(env: Environment, tx: Transaction, gas_used: int, gas_refund: int, logs: List[Log]) -> Receipt:
    sender = recover_sender(tx)

    # Calculate actual gas refund (EIP-3529: max refund = gas_used / 5)
    max_refund = gas_used // 5
    actual_refund = min(gas_refund, max_refund)

    # Refund gas
    gas_remaining = tx.gas_limit - gas_used + actual_refund
    refund_amount = gas_remaining * effective_gas_price(tx, env.block.base_fee)
    env.state.set_balance(sender, env.state.get_balance(sender) + refund_amount)

    # Pay coinbase
    coinbase_payment = gas_used * effective_gas_price(tx, env.block.base_fee)
    env.state.set_balance(env.coinbase, env.state.get_balance(env.coinbase) + coinbase_payment)

    # Process self-destructs (EIP-6780: only if created in same tx)
    for address in env.accounts_to_delete:
        if address in env.state.created_accounts:
            env.state.delete_account(address)

    # Create receipt
    return Receipt(
        success=not has_error,
        gas_used=gas_used,
        logs=logs,
        # ...
    )
```

**Action**: CRITICAL - Verify gas refund cap (gas_used / 5) per EIP-3529.

### 8. EIP-1559 Gas Price Calculation

**Check**:
- [ ] Effective gas price = min(max_fee_per_gas, base_fee + max_priority_fee_per_gas)
- [ ] Base fee burned (not paid to coinbase)
- [ ] Priority fee paid to coinbase

**Spec**:
```python
def effective_gas_price(tx: FeeMarketTransaction, base_fee: int) -> int:
    priority_fee = min(tx.max_priority_fee_per_gas, tx.max_fee_per_gas - base_fee)
    return base_fee + priority_fee

# Finalization
priority_fee_per_gas = min(tx.max_priority_fee_per_gas, tx.max_fee_per_gas - base_fee)
coinbase_payment = gas_used * priority_fee_per_gas  # Not base_fee
base_fee_burned = gas_used * base_fee  # Destroyed
```

**Action**: Verify EIP-1559 fee calculation for type 2 transactions.

### 9. EIP-4844 Blob Transactions

**Check**:
- [ ] Type 3 transaction parsed
- [ ] Blob versioned hashes available
- [ ] Blob gas price calculated separately
- [ ] Max fee per blob gas validated

**Spec**:
```python
# Type 3 specific fields
blob_tx.blob_versioned_hashes: List[Bytes32]
blob_tx.max_fee_per_blob_gas: int

# Validation
blob_gas_price = calculate_blob_gas_price(env.excess_blob_gas)
if blob_tx.max_fee_per_blob_gas < blob_gas_price:
    raise InsufficientBlobGas

# Charge blob gas
blob_gas_used = len(blob_tx.blob_versioned_hashes) * GAS_PER_BLOB  # 131072 per blob
blob_gas_cost = blob_gas_used * blob_gas_price
```

**Action**: Verify blob transaction handling for type 3.

### 10. EIP-7702 Set Code Transactions

**Check**:
- [ ] Type 4 transaction parsed
- [ ] Authorization list validated
- [ ] Delegation designators set
- [ ] Nonce handling for authorized accounts

**Action**: Verify EIP-7702 authorization handling for type 4.

## Output Format

```markdown
# Agent 14: Transaction Processing Audit Report

## Summary
- ✅ Correct: X
- ⚠️ Issues found: Y
- ❌ Critical bugs: Z

## Transaction Types
- [ ] Type 0: Legacy
- [ ] Type 1: Access List (EIP-2930)
- [ ] Type 2: Fee Market (EIP-1559)
- [ ] Type 3: Blob (EIP-4844)
- [ ] Type 4: Set Code (EIP-7702)

## Validation
- [ ] Nonce validation
- [ ] Gas limit validation
- [ ] Balance validation
- [ ] Signature validation

## Intrinsic Gas
- [ ] Base: 21000
- [ ] Data bytes: 4 (zero) / 16 (non-zero)
- [ ] CREATE: +32000
- [ ] Init code: 2 per word (EIP-3860)
- [ ] Access list: 2400 per address + 1900 per key

## Access List Pre-warming
- [ ] Sender always warm
- [ ] Recipient warm (if not CREATE)
- [ ] Coinbase warm
- [ ] Access list warmed BEFORE execution
- [ ] Precompiles warmed (Prague)

## Initialization
- [ ] Nonce incremented
- [ ] Gas purchased
- [ ] Transient storage cleared
- [ ] Message created correctly

## Finalization
- [ ] Gas refund capped (gas_used / 5)
- [ ] Coinbase payment correct
- [ ] Self-destructs (EIP-6780)
- [ ] Receipt created

## EIP-1559
- [ ] Effective gas price calculated
- [ ] Priority fee to coinbase
- [ ] Base fee burned

## Issues Found

#### [Priority] - [Issue]
**File**: [path:line]
**Issue**: [Description]
**Fix**: [Solution]

## Priority Summary
- **CRITICAL**: [Count]
- **HIGH**: [Count]
```
