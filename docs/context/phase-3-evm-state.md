# Phase 3: EVM ↔ WorldState Integration (Transaction/Block Processing)

## Goal

Connect guillotine-mini's EVM engine to the WorldState (from Phase 2) to process
transactions and blocks. This phase builds:

1. **HostAdapter** — implements guillotine-mini's `HostInterface` vtable backed by
   Voltaire's `StateManager` / `JournaledState`
2. **TransactionProcessor** — orchestrates intrinsic-gas, sender validation,
   nonce increment, gas buy/refund, value transfer, EVM execution, coinbase
   payment, and receipt creation for a single transaction
3. **BlockProcessor** — iterates over a block's transactions, invokes
   TransactionProcessor for each, processes system calls (e.g. beacon-roots
   EIP-4788), handles withdrawals, and produces the `BlockOutput` (gas used,
   receipt/tx trie roots, bloom, blob gas used)

---

## Key Components to Build

| File | Responsibility |
|------|----------------|
| `client/evm/host_adapter.zig` | Adapts Voltaire `StateManager` → guillotine-mini `HostInterface` vtable |
| `client/evm/processor.zig` | `TransactionProcessor`: validates, executes one TX, pays fees, produces receipt |
| `client/evm/block_processor.zig` | `BlockProcessor`: apply_body loop over transactions + withdrawals |

---

## Nethermind Architecture Reference

### TransactionProcessing

| File | Purpose | Key takeaways |
|------|---------|---------------|
| `nethermind/src/Nethermind/Nethermind.Evm/TransactionProcessing/ITransactionProcessor.cs` | Interface: `Execute`, `CallAndRestore`, `BuildUp`, `Trace`, `Warmup` | 5 execution modes differentiated by commit/restore/skip-validation flags |
| `nethermind/src/Nethermind/Nethermind.Evm/TransactionProcessing/TransactionProcessor.cs` | Core implementation (~350 lines visible) | `ExecuteCore` → `ValidateStatic` → `BuyGas` → `IncrementNonce` → `ExecuteEvmCall` → `PayFees` → commit/restore |
| `nethermind/src/Nethermind/Nethermind.Evm/TransactionProcessing/SystemTransactionProcessor.cs` | System transactions (beacon roots etc.) | Skips validation, separate gas handling |

### EVM / VM interface

| File | Purpose |
|------|---------|
| `nethermind/src/Nethermind/Nethermind.Evm/IVirtualMachine.cs` | `ExecuteTransaction`, `SetBlockExecutionContext`, `SetTxExecutionContext` |
| `nethermind/src/Nethermind/Nethermind.Evm/VirtualMachine.cs` | ~1470 lines, full opcode dispatch |
| `nethermind/src/Nethermind/Nethermind.Evm/ExecutionEnvironment.cs` | Per-call context: CodeInfo, ExecutingAccount, Caller, Value, CallDepth, InputData |
| `nethermind/src/Nethermind/Nethermind.Evm/BlockExecutionContext.cs` | Block context: Header, Coinbase, Number, GasLimit, PrevRandao, BlobBaseFee |
| `nethermind/src/Nethermind/Nethermind.Evm/IntrinsicGasCalculator.cs` | 21000 + calldata cost + create cost + access list cost + auth list cost + floor gas |

### State

| File | Purpose |
|------|---------|
| `nethermind/src/Nethermind/Nethermind.Evm/State/IWorldState.cs` | Journaled state interface: `TakeSnapshot`, `Get/Set storage`, `GetTransientState`, `Commit`, `Reset`, `WarmUp`, `CreateAccount`, `DeleteAccount`, `AddToBalance`, `SubtractFromBalance`, `IncrementNonce` |
| `nethermind/src/Nethermind/Nethermind.Evm/State/Snapshot.cs` | `Snapshot { StorageSnapshot { Persistent, Transient }, StateSnapshot }` |
| `nethermind/src/Nethermind/Nethermind.State/WorldState.cs` | Full implementation |
| `nethermind/src/Nethermind/Nethermind.State/TransientStorageProvider.cs` | EIP-1153 transient storage |

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
  6. Build access_list (add coinbase + tx access list entries)
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

### Block processing flow (`execution-specs/src/ethereum/forks/cancun/fork.py`)

```
apply_body(block_env, transactions, withdrawals):
  1. process_unchecked_system_transaction(BEACON_ROOTS_ADDRESS, parent_beacon_block_root)
  2. for each tx: process_transaction(block_env, block_output, tx, index)
  3. process_withdrawals(block_env, block_output, withdrawals)
  4. return BlockOutput
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
| `JournaledState.zig` | `JournaledState { getAccount, putAccount, getStorage, putStorage, getCode, putCode, checkpoint, revert, commit }` |
| `StateCache.zig` | `AccountState { nonce, balance, code_hash, storage_root }`, `AccountCache`, `StorageCache`, `ContractCache` |
| `ForkBackend.zig` | Remote state fetching |

### Primitives (`voltaire/packages/voltaire-zig/src/primitives/`)

| Module | Provides |
|--------|----------|
| `Transaction/Transaction.zig` | Transaction types (Legacy, EIP-2930, EIP-1559, EIP-4844) |
| `Receipt/Receipt.zig` | Transaction receipt |
| `Block/`, `BlockHeader/` | Block types |
| `Address/` | Address type |
| `GasConstants/` | Gas cost constants |
| `Hardfork/` | Hardfork enum |
| `AccessList/` | EIP-2930 access list |
| `Blob/` | EIP-4844 blob type |
| `Rlp/` | RLP encoding/decoding |
| `Hash/` | Hash types |

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
| `test/specs/test_host.zig` | Test host: simple HashMap-based `HostInterface` implementation |

### Critical Design Notes

1. **guillotine-mini EVM manages its own internal state** — balances, nonces, code, storage are stored inside the Evm struct via HashMaps. The `HostInterface` is used as an external state _backend_ to pre-populate and persist state.
2. **The HostInterface is minimal** — no error returns, no journaling, no transient storage. The EVM handles all that internally.
3. **The adapter pattern**: HostAdapter wraps `StateManager`, implements `HostInterface` vtable functions. When the EVM calls `getBalance(addr)`, HostAdapter reads from `StateManager`. When EVM calls `setBalance(addr, val)`, HostAdapter writes to `StateManager`.
4. **TransactionProcessor sits outside the EVM** — it handles pre-execution (validate, buy gas, increment nonce) and post-execution (refund, pay coinbase, destroy accounts) logic, calling `evm.call()` for the actual execution.

---

## Test Fixtures

| Fixture path | Purpose |
|-------------|---------|
| `ethereum-tests/BlockchainTests/ValidBlocks/` | Block-level validation (Phase 3+4) |
| `ethereum-tests/BlockchainTests/InvalidBlocks/` | Invalid block rejection |
| `execution-spec-tests/tests/cancun/` | Cancun-specific state tests |
| `execution-spec-tests/tests/prague/` | Prague-specific state tests |
| `execution-spec-tests/tests/shanghai/` | Shanghai-specific state tests |
| `execution-spec-tests/tests/berlin/` | Berlin-specific state tests |
| `execution-spec-tests/tests/frontier/` | Frontier-specific state tests |

**NOTE**: `ethereum-tests/GeneralStateTests/` directory does not exist in the current checkout.
Test fixtures from `execution-spec-tests/` are the primary validation source.

---

## Implementation Order

1. **`host_adapter.zig`** — Bridge Voltaire StateManager → guillotine-mini HostInterface
   - Wrap `StateManager` pointer
   - Implement all 8 vtable functions (getBalance/setBalance/getCode/setCode/getStorage/setStorage/getNonce/setNonce)
   - Handle errors from StateManager (which returns `!T`) by using catch to provide defaults

2. **`processor.zig`** — Transaction processor
   - `processTransaction(evm, state, block_env, tx) → Receipt`
   - Validate transaction (intrinsic gas, sender balance, nonce)
   - Buy gas (deduct from sender)
   - Execute via `evm.call()`
   - Calculate refund (min(gas_used/5, refund_counter))
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
5. **Access list pre-warming**: Coinbase always warmed, plus TX access list entries
6. **State journaling**: Checkpoint before TX execution, revert on failure, commit on success
7. **Nonce increment**: Before EVM execution, not after
8. **Blob gas fee**: Deducted from sender before execution (EIP-4844)
