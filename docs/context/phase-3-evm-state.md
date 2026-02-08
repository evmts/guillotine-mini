# Phase 3: EVM ↔ WorldState Integration (Transaction/Block Processing)

## Goal

Connect guillotine-mini's EVM engine to the WorldState (from Phase 2) to process
transactions and blocks. This phase builds:

1. **HostAdapter** — implements guillotine-mini's `HostInterface` vtable backed by
   Voltaire's `StateManager` / `JournaledState` (**DONE**)
2. **TransactionProcessor** — orchestrates intrinsic-gas, sender validation,
   nonce increment, gas buy/refund, value transfer, EVM execution, coinbase
   payment, and receipt creation for a single transaction
3. **BlockProcessor** — iterates over a block's transactions, invokes
   TransactionProcessor for each, processes system calls (e.g. beacon-roots
   EIP-4788), handles withdrawals, and produces the `BlockOutput` (gas used,
   receipt/tx trie roots, bloom, blob gas used)

---

## Current Implementation Status

### DONE

| File | Status | Tests |
|------|--------|-------|
| `client/evm/host_adapter.zig` | Complete | 7 passing (round-trips, checkpoint/revert, defaults, isolation) |
| `client/evm/root.zig` | Complete | Module re-exports |
| `client/state/journal.zig` | Complete | 19 passing (snapshot, restore, commit, just_cache preservation) |
| `client/state/account.zig` | Complete | 16 passing (is_empty, is_totally_empty, has_code_or_nonce) |
| `client/state/root.zig` | Complete | Module re-exports |

### TODO

| File | Purpose |
|------|---------|
| `client/evm/processor.zig` | Transaction processor |
| `client/evm/block_processor.zig` | Block processor (iterates txs, system calls, withdrawals) |

---

## Key Components to Build

| File | Responsibility |
|------|----------------|
| `client/evm/processor.zig` | `TransactionProcessor`: validates, executes one TX, pays fees, produces receipt |
| `client/evm/block_processor.zig` | `BlockProcessor`: apply_body loop over transactions + withdrawals |

---

## Nethermind Architecture Reference

### TransactionProcessing

| File | Purpose | Key takeaways |
|------|---------|---------------|
| `nethermind/src/Nethermind/Nethermind.Evm/TransactionProcessing/ITransactionProcessor.cs` | Interface: `Execute`, `CallAndRestore`, `BuildUp`, `Trace`, `Warmup` | 5 execution modes differentiated by commit/restore/skip-validation flags |
| `nethermind/src/Nethermind/Nethermind.Evm/TransactionProcessing/TransactionProcessor.cs` | Core implementation | `ValidateStatic` → `BuyGas` → `IncrementNonce` → `ExecuteEvmCall` → `PayFees` → commit/restore |
| `nethermind/src/Nethermind/Nethermind.Evm/TransactionProcessing/SystemTransactionProcessor.cs` | System transactions (beacon roots etc.) | Skips validation, separate gas handling |

### TransactionProcessor Detailed Flow (from Nethermind)

```
TransactionProcessor.Execute(tx)
  1. ValidateStatic(tx)             - check sender, nonce, gas limit, init code size
  2. CalculateEffectiveGasPrice(tx) - EIP-1559 handling
  3. SetTxExecutionContext()        - tell VM about tx-level context
  4. RecoverSenderIfNeeded(tx)      - handle missing sender account
  5. ValidateSender(tx)             - ensure sender doesn't have code
  6. BuyGas(tx)                     - deduct gasLimit * effectiveGasPrice from sender
  7. IncrementNonce(tx)             - increase sender nonce
  8. ProcessDelegations(tx)         - EIP-7702 SETCODE auth tuples (Prague)
  9. BuildExecutionEnvironment(tx)  - create env, warm sender/recipient/coinbase/precompiles/access_list
  10. ExecuteEvmCall()              - call VirtualMachine.ExecuteTransaction()
  11. PayFees(tx)                   - priority fee to miner + EIP-1559 burn
  12. Finalize state                - commit or restore based on execution mode
```

### Gas Handling in Nethermind

**BuyGas:** `sender.balance -= gasLimit * effectiveGasPrice + blobGas * blobBaseFee`

**Refund calculation:**
```
spentGas = gasLimit - unspentGas
totalRefund = substate.Refund + destroyList.Count * RefundOf.Destroy()
actualRefund = min(totalRefund, spentGas / 5)   # London+ (was /2 pre-London)
spentGas -= actualRefund
```

**Miner payment:**
```
priorityFee = effectiveGasPrice - baseFeePerGas
fees = priorityFee * spentGas
coinbase.balance += fees
```

**Sender refund:** `sender.balance += (gasLimit - spentGas) * effectiveGasPrice`

### EVM / VM interface

| File | Purpose |
|------|---------|
| `nethermind/src/Nethermind/Nethermind.Evm/IVirtualMachine.cs` | `ExecuteTransaction`, `SetBlockExecutionContext`, `SetTxExecutionContext` |
| `nethermind/src/Nethermind/Nethermind.Evm/VirtualMachine.cs` | ~1470 lines, full opcode dispatch |
| `nethermind/src/Nethermind/Nethermind.Evm/ExecutionEnvironment.cs` | Per-call context: CodeInfo, ExecutingAccount, Caller, Value, CallDepth, InputData |
| `nethermind/src/Nethermind/Nethermind.Evm/BlockExecutionContext.cs` | Block context: Header, Coinbase, Number, GasLimit, PrevRandao, BlobBaseFee |
| `nethermind/src/Nethermind/Nethermind.Evm/TxExecutionContext.cs` | Tx context: Origin, GasPrice, BlobVersionedHashes |
| `nethermind/src/Nethermind/Nethermind.Evm/IntrinsicGasCalculator.cs` | 21000 + calldata cost + create cost + access list cost + auth list cost + floor gas |
| `nethermind/src/Nethermind/Nethermind.Evm/TransactionSubstate.cs` | Result: Output, Refund, Logs, DestroyList, ShouldRevert, IsError |

### State

| File | Purpose |
|------|---------|
| `nethermind/src/Nethermind/Nethermind.Evm/State/IWorldState.cs` | Journaled state interface: `TakeSnapshot`, `Get/Set storage`, `GetTransientState`, `Commit`, `Reset`, `WarmUp`, `CreateAccount`, `DeleteAccount`, `AddToBalance`, `SubtractFromBalance`, `IncrementNonce` |
| `nethermind/src/Nethermind/Nethermind.Evm/State/Snapshot.cs` | `Snapshot { StorageSnapshot { Persistent, Transient }, StateSnapshot }` |
| `nethermind/src/Nethermind/Nethermind.State/WorldState.cs` | Full implementation |
| `nethermind/src/Nethermind/Nethermind.State/TransientStorageProvider.cs` | EIP-1153 transient storage |

### Other Key Nethermind Files

| File | Purpose |
|------|---------|
| `nethermind/src/Nethermind/Nethermind.Evm/GasCostOf.cs` | Gas cost constants |
| `nethermind/src/Nethermind/Nethermind.Evm/RefundHelper.cs` | Refund calculation |
| `nethermind/src/Nethermind/Nethermind.Evm/CodeDepositHandler.cs` | Contract creation code deposit |
| `nethermind/src/Nethermind/Nethermind.Evm/GasPolicy/EthereumGasPolicy.cs` | Gas policy |
| `nethermind/src/Nethermind/Nethermind.Evm/GasPolicy/IGasPolicy.cs` | Gas policy interface |

---

## Python Spec Reference (Authoritative)

### Transaction processing flow (`execution-specs/src/ethereum/forks/cancun/fork.py`)

```
process_transaction():
  1. validate_transaction(tx) → intrinsic_gas
  2. check_transaction(block_env, block_output, tx) → sender, effective_gas_price, blob_hashes, blob_gas
  3. gas = tx.gas - intrinsic_gas
  4. increment_nonce(state, sender)
  5. Deduct gas fee: sender_balance -= effective_gas_fee + blob_gas_fee
  6. Build access_list (add coinbase + tx access list entries + precompiles)
  7. Create TransactionEnvironment
  8. prepare_message(block_env, tx_env, tx)
  9. process_message_call(message) → tx_output
  10. Calculate refund: min(gas_used_before_refund // 5, refund_counter)
  11. Refund sender: balance += gas_left * effective_gas_price
  12. Pay coinbase: balance += gas_used_after_refund * priority_fee_per_gas
  13. Destroy selfdestructed accounts
  14. Accumulate block_gas_used, blob_gas_used
  15. Create receipt
```

### Intrinsic Gas Calculation (`execution-specs/src/ethereum/forks/cancun/transactions.py`)

```
intrinsic_gas = 21000                        # TX_BASE_COST
+ 4 per zero byte in tx.data                 # TX_DATA_COST_PER_ZERO
+ 16 per non-zero byte in tx.data            # TX_DATA_COST_PER_NON_ZERO
+ 32000 (if contract creation)               # TX_CREATE_COST
+ ceil(len(tx.data)/32) * 2 (if create, Shanghai+)  # INIT_CODE_WORD_COST (EIP-3860)
+ 2400 per access list address               # TX_ACCESS_LIST_ADDRESS_COST
+ 1900 per access list slot                  # TX_ACCESS_LIST_STORAGE_KEY_COST
```

### Block processing flow (`execution-specs/src/ethereum/forks/cancun/fork.py`)

```
apply_body(block_env, transactions, withdrawals):
  1. process_unchecked_system_transaction(BEACON_ROOTS_ADDRESS, parent_beacon_block_root)
  2. for each tx: process_transaction(block_env, block_output, tx, index)
  3. process_withdrawals(block_env, block_output, withdrawals)
  4. return BlockOutput
```

### VM Execution Flow (`execution-specs/src/ethereum/forks/cancun/vm/interpreter.py`)

```
process_message_call(message) → MessageCallOutput:
  if message.target == empty:
    evm = process_create_message(message)      # CREATE/CREATE2
  else:
    evm = process_message(message)              # CALL/STATICCALL/DELEGATECALL
  return MessageCallOutput(gas_left, refund_counter, logs, accounts_to_delete, error)

process_message(message):
  1. Check depth <= 1024
  2. begin_transaction(state)                   # Snapshot
  3. Transfer value if needed
  4. Execute bytecode
  5. On error: rollback_transaction(state)
  6. On success: commit_transaction(state)

process_create_message(message):
  1. begin_transaction(state)
  2. Clear preexisting storage
  3. Mark account created (EIP-6780)
  4. Increment nonce of creation address
  5. Execute constructor
  6. If success: charge code deposit gas (200/byte), check size, store code, commit
  7. If error: rollback
```

### Key Python files

| File | Content |
|------|---------|
| `execution-specs/src/ethereum/forks/cancun/fork.py` | `state_transition`, `apply_body`, `process_transaction`, `validate_header`, `check_transaction`, `make_receipt` |
| `execution-specs/src/ethereum/forks/cancun/vm/__init__.py` | `BlockEnvironment`, `TransactionEnvironment`, `Message`, `Evm` dataclasses, `incorporate_child_on_success/error` |
| `execution-specs/src/ethereum/forks/cancun/vm/interpreter.py` | `process_message_call`, `process_create_message` |
| `execution-specs/src/ethereum/forks/cancun/vm/gas.py` | Gas calculations, blob gas |
| `execution-specs/src/ethereum/forks/cancun/state.py` | `State`, `TransientStorage`, `get_account`, `set_account_balance`, `increment_nonce`, `destroy_account` |
| `execution-specs/src/ethereum/forks/cancun/transactions.py` | `validate_transaction`, `recover_sender`, TX types |
| `execution-specs/src/ethereum/forks/cancun/utils/message.py` | `prepare_message` — builds Message from TX + env |

---

## Voltaire APIs (Existing Zig Primitives)

### State Manager (`voltaire/packages/voltaire-zig/src/state-manager/`)

| Module | Key types/functions |
|--------|-------------------|
| `StateManager.zig` | `StateManager { getBalance, getNonce, getCode, getStorage, setBalance, setNonce, setCode, setStorage, checkpoint, revert, commit, snapshot, revertToSnapshot }` |
| `JournaledState.zig` | `JournaledState { getAccount, putAccount, getStorage, putStorage, getCode, putCode, checkpoint, revert, commit, clearCaches }` |
| `StateCache.zig` | `AccountState { nonce, balance, code_hash, storage_root }`, `AccountCache`, `StorageCache`, `ContractCache` |
| `ForkBackend.zig` | Remote state fetching (read-only) |

**Checkpoint vs Snapshot:**
- `checkpoint()` — low-level stack push (LIFO revert)
- `snapshot()` → `u64` — high-level named snapshot (arbitrary order, cleans up newer)

### Primitives (`voltaire/packages/voltaire-zig/src/primitives/`)

| Module | Provides |
|--------|----------|
| `Address` | 20-byte Ethereum address |
| `AccountState` | Account struct (nonce, balance, code_hash, storage_root), `createEmpty()`, `isEOA()`, `isContract()` |
| `Transaction` | Transaction types (Legacy, EIP-2930, EIP-1559, EIP-4844, EIP-7702) |
| `Receipt` | Transaction receipt |
| `Block`, `BlockHeader` | Block types |
| `GasConstants` | Per-opcode gas costs |
| `Hardfork`, `ForkTransition` | Hardfork enum |
| `AccessList` | EIP-2930 access list |
| `Blob` | EIP-4844 blob type |
| `Rlp` | RLP encoding/decoding |
| `Hash` | 32-byte hash type |
| `EventLog` | Contract event logs |
| `Crypto` | Keccak256, secp256k1, BLS12-381 |
| `FeeMarket` | EIP-1559 fee calculations |

### Blockchain (`voltaire/packages/voltaire-zig/src/blockchain/`)

| Module | Key API |
|--------|---------|
| `Blockchain.zig` | `getBlockByHash(hash)`, `getBlockByNumber(number)`, `putBlock(block)`, `setCanonicalHead(hash)` |
| `BlockStore.zig` | Local block storage |

### EVM Host (`voltaire/packages/voltaire-zig/src/evm/host.zig`)

Same `HostInterface` vtable pattern as `src/host.zig` — type-erased virtual dispatch.

---

## Guillotine-Mini Existing Files

| File | Relevant content |
|------|-----------------|
| `src/host.zig` | `HostInterface` vtable: `{ getBalance, setBalance, getCode, setCode, getStorage, setStorage, getNonce, setNonce }` — NOTE: all getters return values directly (no errors), setters return void |
| `src/evm.zig` | `Evm(config)` struct with `BlockContext`, `call()`, `inner_call()`, `inner_create()`, internal state maps (balances, nonces, code, storage, access_list_manager) |
| `src/frame.zig` | `Frame(config)` — single execution frame, bytecode interpreter |
| `src/call_params.zig` | `CallParams(config)` — parameters for EVM call |
| `src/call_result.zig` | `CallResult(config)` — result from EVM call |
| `src/evm_config.zig` | `EvmConfig` — comptime configuration |
| `src/storage.zig` | EVM internal storage management |
| `src/access_list_manager.zig` | EIP-2929 warm/cold tracking |
| `src/errors.zig` | `CallError` enum |
| `test/specs/test_host.zig` | Test host: simple HashMap-based `HostInterface` implementation |
| `test/specs/runner.zig` | Spec test runner (JSON parsing, trace comparison) |

### Critical Design Notes

1. **guillotine-mini EVM manages its own internal state** — balances, nonces, code, storage are stored inside the Evm struct via HashMaps. The `HostInterface` is used as an external state _backend_ to pre-populate and persist state.
2. **The HostInterface is minimal** — no error returns, no journaling, no transient storage. The EVM handles all that internally.
3. **The adapter pattern**: HostAdapter wraps `StateManager`, implements `HostInterface` vtable functions. When the EVM calls `getBalance(addr)`, HostAdapter reads from `StateManager`. When EVM calls `setBalance(addr, val)`, HostAdapter writes to `StateManager`.
4. **TransactionProcessor sits outside the EVM** — it handles pre-execution (validate, buy gas, increment nonce) and post-execution (refund, pay coinbase, destroy accounts) logic, calling `evm.call()` for the actual execution.

---

## Test Fixtures

| Fixture path | Purpose |
|-------------|---------|
| `ethereum-tests/TransactionTests/` | Transaction validation tests (intrinsic gas, signature recovery) |
| `ethereum-tests/BlockchainTests/ValidBlocks/` | Block-level validation (Phase 3+4) |
| `ethereum-tests/BlockchainTests/InvalidBlocks/` | Invalid block rejection |
| `execution-spec-tests/tests/cancun/` | Cancun-specific state tests |
| `execution-spec-tests/tests/prague/` | Prague-specific state tests |
| `execution-spec-tests/tests/shanghai/` | Shanghai-specific state tests |
| `execution-spec-tests/tests/berlin/` | Berlin-specific state tests |
| `execution-spec-tests/tests/frontier/` | Frontier-specific state tests |
| `test/specs/generated/` | Generated state test fixtures (existing) |

---

## Gas Constants Reference

| Constant | Value | EIP | Python Name |
|----------|-------|-----|-------------|
| TX_BASE_COST | 21000 | - | `TX_BASE_COST` |
| TX_DATA_COST_PER_ZERO | 4 | - | `TX_DATA_COST_PER_ZERO` |
| TX_DATA_COST_PER_NON_ZERO | 16 | EIP-2028 | `TX_DATA_COST_PER_NON_ZERO` |
| TX_CREATE_COST | 32000 | EIP-2 | `TX_CREATE_COST` |
| TX_ACCESS_LIST_ADDRESS_COST | 2400 | EIP-2930 | `TX_ACCESS_LIST_ADDRESS_COST` |
| TX_ACCESS_LIST_STORAGE_KEY_COST | 1900 | EIP-2930 | `TX_ACCESS_LIST_STORAGE_KEY_COST` |
| GAS_CODE_DEPOSIT | 200 | - | `GAS_CODE_DEPOSIT` |
| MAX_CODE_SIZE | 24576 | EIP-170 | `MAX_CODE_SIZE` |
| MAX_INIT_CODE_SIZE | 49152 | EIP-3860 | `MAX_INITCODE_SIZE` |
| INIT_CODE_WORD_COST | 2 | EIP-3860 | `INITCODE_WORD_COST` |
| GAS_REFUND_DIVISOR_LONDON | 5 | EIP-3529 | - |
| GAS_REFUND_DIVISOR_PRE_LONDON | 2 | - | - |
| STACK_DEPTH_LIMIT | 1024 | - | `STACK_DEPTH_LIMIT` |

---

## Implementation Order

1. **`host_adapter.zig`** — (**DONE**) Bridge Voltaire StateManager → guillotine-mini HostInterface

2. **`processor.zig`** — Transaction processor
   - `processTransaction(evm, state, block_env, tx) → TransactionResult`
   - Validate transaction (intrinsic gas, sender balance, nonce)
   - Buy gas (deduct from sender)
   - Warm addresses (sender, recipient, coinbase, precompiles, access list)
   - Execute via `evm.call()`
   - Calculate refund (`min(gas_used/5, refund_counter)` London+)
   - Refund sender, pay coinbase
   - Handle selfdestruct cleanup
   - Create receipt (status, gas_used, logs, bloom)

3. **`block_processor.zig`** — Block processor
   - `applyBody(block_env, transactions, withdrawals) → BlockOutput`
   - System transaction for beacon roots (EIP-4788)
   - Loop over transactions, call processTransaction
   - Process withdrawals (EIP-4895)
   - Accumulate gas_used, blob_gas_used

---

## Key Invariants to Maintain

1. **Gas refund cap**: `min(gas_used_before_refund // 5, refund_counter)` (London+, was //2 pre-London)
2. **Effective gas price**: `min(tx.max_fee_per_gas, tx.max_priority_fee_per_gas + block.base_fee)` for EIP-1559
3. **Priority fee to coinbase**: `(effective_gas_price - base_fee) * gas_used_after_refund`
4. **Transient storage reset**: Between transactions (not between calls)
5. **Access list pre-warming**: Coinbase always warmed (Shanghai+), plus TX access list entries, plus sender/recipient
6. **State journaling**: Checkpoint before TX execution, revert on failure, commit on success
7. **Nonce increment**: Before EVM execution, not after
8. **Blob gas fee**: Deducted from sender before execution (EIP-4844)
9. **Base fee burn**: Base fee portion is burned (not paid to miner)
10. **Failed transactions still consume gas**: Sender pays for intrinsic gas + execution gas on failure

---

## Open Questions

1. **Transaction type detection**: How does Voltaire's `Transaction` type distinguish Legacy/EIP-2930/EIP-1559/EIP-4844?
2. **Receipt generation**: Should processor generate full receipts, or just return enough data for the caller?
3. **Access list warm-up**: The EVM already has `access_list_manager` — how to integrate tx-level warm addresses?
4. **Transient storage reset**: Should processor call `evm.clearTransientStorage()` between txs, or is that block processor responsibility?
5. **EIP-7702 (Prague)**: Does the current EVM support SETCODE delegation transactions?
