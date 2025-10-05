# Guillotine EVM Exhaustive Audit - Continuation Context

## Mission
Perform **EXHAUSTIVE** audit and implementation review of the Guillotine EVM (`guillotine-mini`) against the Python execution-specs Prague reference implementation. This is **mission-critical financial software** requiring absolute thoroughness.

## Current Status

### ✅ Completed
1. **Agent pipeline infrastructure** created:
   - `scripts/index.ts` - Orchestration script with 1000 maxTurns for exhaustive analysis
   - `prompts/` - Detailed audit prompts for all phases
   - Can run: `cd scripts && bun index.ts agent <id>` or `bun index.ts phase <N>`

2. **3 detailed prompts created**:
   - `prompts/phase1-agent1-primitives.md` - Gas constants, U256, transactions
   - `prompts/phase1-agent2-state-management.md` - Storage, access lists, transient storage
   - `prompts/phase2-agent11-system-calls.md` - CREATE, CALL family, SELFDESTRUCT

3. **Reference repositories**:
   - `execution-specs/` - Python Prague spec (ground truth)
   - `guillotine-reference/` - Reference Guillotine with precompile implementations

### 🔄 In Progress
- Phase 1 Agent 1 (Primitives) was running but needs re-run with 1000 turns
- Need to complete all agent prompts and execute full pipeline

---

## Key Findings So Far

### Spot Checks Done:
- ✅ `SstoreRefundGas = 4800` (correct for EIP-3529)
- ✅ `ColdSloadCost = 2100` (correct for EIP-2929)
- ❌ **MISSING**: BLS12-381 gas constants (EIP-2537)

---

## Repository Structure

### guillotine-mini (Current - Being Audited)
```
src/
├── evm.zig (838 lines) - Orchestrates execution
├── frame.zig (2,180 lines) - Main execution loop with 86 opcodes
├── primitives/ (12,272 lines)
│   ├── gas_constants.zig (63,649 lines) - ALL gas constants
│   ├── uint.zig (137,870 lines) - U256 arithmetic
│   ├── transaction.zig - 5 transaction types
│   ├── authorization.zig - EIP-7702
│   ├── blob.zig - EIP-4844
│   ├── access_list.zig - EIP-2930
│   ├── rlp.zig, address.zig, state.zig, etc.
├── host.zig - Host interface
└── hardfork.zig - Hardfork configuration
```

### execution-specs (Python Reference - Ground Truth)
```
src/ethereum/forks/prague/
├── fork.py - Main transaction processing
├── state.py - State management, transient storage
├── transactions.py - All 5 transaction types
├── vm/
│   ├── interpreter.py - Main execution loop
│   ├── gas.py - ALL gas constants (ground truth)
│   ├── instructions/ - Opcodes by category
│   │   ├── arithmetic.py, bitwise.py, comparison.py
│   │   ├── storage.py - SLOAD/SSTORE/TLOAD/TSTORE
│   │   ├── system.py - CREATE/CALL/SELFDESTRUCT
│   │   └── [10 more files]
│   └── precompiled_contracts/
│       ├── mapping.py - All 18 precompiles
│       ├── bls12_381/ - EIP-2537 (8 operations)
│       └── [12 more files]
└── fork_types.py - Type definitions
```

### guillotine-reference (Reference Implementation)
```
src/
├── evm.zig (269k lines) - Full implementation
├── frame/ - Frame implementation
├── crypto/ - Crypto primitives including BLS12-381
└── Cargo.toml with rust-crypto submodules
```

**CRITICAL**: Use `guillotine-reference/` for precompile implementation examples, especially:
- BLS12-381 operations (0x0b-0x12)
- Which Rust crates are used (check Cargo.toml)
- How precompiles integrate with the EVM

---

## Critical Items Requiring Exhaustive Audit

### Phase 1: Primitives (PRIORITY)

#### 1. Gas Constants (`src/primitives/gas_constants.zig`)
**Reference**: `execution-specs/src/ethereum/forks/prague/vm/gas.py`

**MUST verify EVERY constant**:
```python
# From Prague spec - verify ALL of these exist and match:
GAS_JUMPDEST = 1
GAS_BASE = 2
GAS_VERY_LOW = 3
GAS_STORAGE_SET = 20000
GAS_STORAGE_UPDATE = 5000
GAS_STORAGE_CLEAR_REFUND = 4800  # EIP-3529
GAS_LOW = 5
GAS_MID = 8
GAS_HIGH = 10
GAS_EXPONENTIATION = 10
GAS_EXPONENTIATION_PER_BYTE = 50
GAS_MEMORY = 3
GAS_KECCAK256 = 30
GAS_KECCAK256_WORD = 6
GAS_COPY = 3
GAS_BLOCK_HASH = 20
GAS_LOG = 375
GAS_LOG_DATA = 8
GAS_LOG_TOPIC = 375
GAS_CREATE = 32000
GAS_CODE_DEPOSIT = 200
GAS_ZERO = 0
GAS_NEW_ACCOUNT = 25000
GAS_CALL_VALUE = 9000
GAS_CALL_STIPEND = 2300
GAS_SELF_DESTRUCT = 5000
GAS_SELF_DESTRUCT_NEW_ACCOUNT = 25000
GAS_ECRECOVER = 3000
GAS_SHA256 = 60
GAS_SHA256_WORD = 12
GAS_RIPEMD160 = 600
GAS_RIPEMD160_WORD = 120
GAS_IDENTITY = 15
GAS_IDENTITY_WORD = 3
GAS_RETURN_DATA_COPY = 3
GAS_FAST_STEP = 5
GAS_BLAKE2_PER_ROUND = 1
GAS_COLD_SLOAD = 2100  # EIP-2929
GAS_COLD_ACCOUNT_ACCESS = 2600  # EIP-2929
GAS_WARM_ACCESS = 100  # EIP-2929
GAS_INIT_CODE_WORD_COST = 2  # EIP-3860
GAS_BLOBHASH_OPCODE = 3
GAS_POINT_EVALUATION = 50000

# Blob gas (EIP-4844)
GAS_PER_BLOB = U64(2**17)  # 131072
TARGET_BLOB_GAS_PER_BLOCK = U64(786432)
MIN_BLOB_GASPRICE = Uint(1)
BLOB_BASE_FEE_UPDATE_FRACTION = Uint(5007716)

# BLS12-381 (EIP-2537) - CRITICAL: Likely missing
GAS_BLS_G1_ADD = 375
GAS_BLS_G1_MUL = 12000
GAS_BLS_G1_MAP = 5500
GAS_BLS_G2_ADD = 600
GAS_BLS_G2_MUL = 22500
GAS_BLS_G2_MAP = 23800
GAS_BLS_PAIRING_BASE = 43000
GAS_BLS_PAIRING_PER_PAIR = 65000
```

**Action**: Compare EVERY constant, flag missing/incorrect.

#### 2. Transaction Types (`src/primitives/transaction.zig`)
**Reference**: `execution-specs/src/ethereum/forks/prague/transactions.py`

**Verify all 5 types exist**:
- Type 0: `LegacyTransaction`
- Type 1: `AccessListTransaction` (EIP-2930)
- Type 2: `FeeMarketTransaction` (EIP-1559)
- Type 3: `BlobTransaction` (EIP-4844)
- Type 4: `SetCodeTransaction` (EIP-7702)

**Check**: RLP encoding, signature recovery, validation logic

#### 3. U256 Operations (`src/primitives/uint.zig`)
**Reference**: Python's native 256-bit behavior

**Critical edge cases**:
- Wrapping arithmetic (modulo 2^256)
- Division by zero → returns 0
- SDIV: MIN_INT / -1 → returns MIN_INT (overflow)
- Shift >= 256 → result is 0
- SAR sign extension

---

### Phase 2: State Management (CRITICAL)

#### Missing Features (High Probability):

**1. Transient Storage (EIP-1153)**
**Reference**: `execution-specs/.../state.py:TransientStorage`

Check if `src/evm.zig` has:
```zig
transient_storage: std.AutoHashMap(StorageSlotKey, u256)
```

If missing:
- Add to Evm struct
- Clear after each transaction
- Include in snapshot/rollback
- Implement TLOAD (0x5c) and TSTORE (0x5d)

**2. Created Accounts Tracking (EIP-6780)**
**Reference**: `execution-specs/.../state.py:State.created_accounts`

Check if `src/evm.zig` has:
```zig
created_accounts: std.AutoHashMap(Address, void)
```

**CRITICAL**: Used by SELFDESTRUCT to determine if account should be deleted.

**3. Access List Pre-warming (EIP-2929)**
Before transaction execution, must warm:
- All addresses in `tx.access_list.addresses`
- All keys in `tx.access_list.storage_keys`
- `tx.origin`, `tx.to`, `block.coinbase`

---

### Phase 3: Opcode Implementation (86/141 implemented)

#### System Calls (HIGHEST PRIORITY)
**Agent 11 prompt already created**: `prompts/phase2-agent11-system-calls.md`

**Critical bugs to find**:

**SELFDESTRUCT (0xff) - EIP-6780**:
```python
# OLD (wrong): Always delete account
# NEW (correct): Only delete if created in same transaction

if address in state.created_accounts:
    # Delete account
    evm.accounts_to_delete.add(address)
else:
    # Just send balance, DON'T delete
    pass
```

**CREATE/CREATE2**:
- Address collision detection
- EOF prefix (0xEF) rejection
- Init code size limit (49152 bytes, EIP-3860)
- Code deposit gas (200 per byte)
- Nonce increment timing (before execution)

**CALL family**:
- Gas forwarding (63/64 rule)
- Stipend (2300) added to forwarded gas
- STATICCALL restrictions enforced

#### Storage Opcodes (CRITICAL)
**Scope**: SLOAD, SSTORE, TLOAD, TSTORE

**SSTORE** is complex (EIP-2200 + EIP-2929 + EIP-3529):
- Sentry gas check (2300 minimum)
- Cold/warm tracking (+2100 for first access)
- Original value tracking for refunds
- Complex refund calculation

#### Other Opcodes
Create prompts for:
- Agent 3: Arithmetic (11 opcodes)
- Agent 4: Bitwise/Comparison (14 opcodes)
- Agent 5: Stack/Memory (68 opcodes)
- Agent 6: Storage (4 opcodes)
- Agent 7: Environment (16 opcodes)
- Agent 8: Block Context (11 opcodes)
- Agent 9: Keccak/Logging (6 opcodes)
- Agent 10: Control Flow (6 opcodes)
- Agent 12: Precompiles (18 precompiles)

---

### Phase 4: Precompiles (USE GUILLOTINE-REFERENCE)

**Location**: Check if implemented in `src/frame.zig` or separate files

**Required 18 precompiles**:
- 0x01: ecrecover (ECDSA)
- 0x02: sha256
- 0x03: ripemd160
- 0x04: identity
- 0x05: modexp
- 0x06: bn256Add (alt_bn128)
- 0x07: bn256Mul
- 0x08: bn256Pairing
- 0x09: blake2f
- 0x0a: pointEvaluation (EIP-4844 KZG)
- 0x0b-0x12: BLS12-381 (EIP-2537) - **8 operations**

**IMPORTANT**: Check `guillotine-reference/` for implementations:
- Look in `guillotine-reference/src/crypto/`
- Check `guillotine-reference/Cargo.toml` for Rust crypto dependencies
- See how precompiles are integrated in `guillotine-reference/src/evm.zig`

**For each precompile verify**:
- Gas calculation correct
- Input validation
- Output format
- Error handling

---

## EIP Compliance Checklist

All 8 Prague EIPs MUST be verified:

**EIP-1153: Transient Storage**
- [ ] TLOAD (0x5c) - 100 gas
- [ ] TSTORE (0x5d) - 100 gas
- [ ] Cleared after transaction
- [ ] No refunds

**EIP-2929: Gas cost increases**
- [ ] Cold SLOAD: 2100
- [ ] Warm SLOAD: 100
- [ ] Cold account access: 2600
- [ ] Warm account access: 100
- [ ] Pre-warming logic

**EIP-2930: Access Lists**
- [ ] Transaction type 1 parsed
- [ ] Addresses/slots pre-warmed

**EIP-3529: Gas refund reduction**
- [ ] SSTORE refund: 4800 (was 15000)
- [ ] Max refund: gas_used / 5 (was / 2)
- [ ] SELFDESTRUCT refund: 0 (was 24000)

**EIP-3860: Init code limit**
- [ ] Max size: 49152 bytes
- [ ] Gas: 2 per 32-byte word

**EIP-4844: Blob transactions**
- [ ] Type 3 transaction
- [ ] BLOBHASH (0x49)
- [ ] BLOBBASEFEE (0x4a)
- [ ] KZG precompile (0x0a)

**EIP-6780: SELFDESTRUCT same-transaction**
- [ ] Only delete if in `created_accounts`
- [ ] Otherwise just send balance

**EIP-7702: Set EOA code**
- [ ] Type 4 transaction
- [ ] Authorization validation
- [ ] Delegation prefix handling

**EIP-3855: PUSH0**
- [ ] Opcode 0x5f implemented
- [ ] Hardfork gated (Shanghai+)

**EIP-2537: BLS12-381**
- [ ] 8 precompiles (0x0b-0x12)
- [ ] Gas constants defined

---

## Execution Instructions

### Step 1: Complete Missing Agent Prompts

Create prompts for agents 3-10, 12-18 following the template:

**Template structure**:
```markdown
# Agent N: [Name]

## Objective
[What to audit]

## Scope
[Files to examine]

## Reference
- Zig: src/...
- Python spec: execution-specs/src/ethereum/forks/prague/...
- Reference (for precompiles): guillotine-reference/src/...

## Tasks
### 1. [Component]
**Check**:
- [ ] Item 1
- [ ] Item 2

**Spec**:
```python
# Python code
```

**Action**: Compare, flag issues

## Output Format
[Markdown template with ✅ ⚠️ ❌ sections, line numbers, priority]
```

**Copy from existing**:
- `prompts/phase1-agent1-primitives.md` (primitives example)
- `prompts/phase1-agent2-state-management.md` (state example)
- `prompts/phase2-agent11-system-calls.md` (opcodes example)

**For Agent 12 (Precompiles)**, add:
```markdown
## Reference Implementation
Check `guillotine-reference/` for working precompile code:
- Location: `guillotine-reference/src/crypto/`
- Dependencies: Check `guillotine-reference/Cargo.toml`
- Integration: See how precompiles are called in `guillotine-reference/src/evm.zig`

Use this as reference for:
- BLS12-381 operations (most complex)
- Crypto library usage
- Gas calculation patterns
```

### Step 2: Update AGENTS Array

In `scripts/index.ts`, add all agents:

```typescript
const AGENTS: AgentConfig[] = [
  // Phase 1
  { id: 'agent1', name: 'Primitives Auditor', promptFile: 'prompts/phase1-agent1-primitives.md', phase: 1, outputFile: 'reports/phase1-agent1-primitives-report.md' },
  { id: 'agent2', name: 'State Management Auditor', promptFile: 'prompts/phase1-agent2-state-management.md', phase: 1, outputFile: 'reports/phase1-agent2-state-management-report.md' },

  // Phase 2 - Opcodes
  { id: 'agent3', name: 'Arithmetic Opcodes', promptFile: 'prompts/phase2-agent3-arithmetic.md', phase: 2, dependsOn: ['agent1'], outputFile: 'reports/phase2-agent3-arithmetic-report.md' },
  { id: 'agent4', name: 'Bitwise/Comparison', promptFile: 'prompts/phase2-agent4-bitwise.md', phase: 2, dependsOn: ['agent1'], outputFile: 'reports/phase2-agent4-bitwise-report.md' },
  { id: 'agent5', name: 'Stack/Memory', promptFile: 'prompts/phase2-agent5-stack-memory.md', phase: 2, dependsOn: ['agent1'], outputFile: 'reports/phase2-agent5-stack-memory-report.md' },
  { id: 'agent6', name: 'Storage Opcodes', promptFile: 'prompts/phase2-agent6-storage.md', phase: 2, dependsOn: ['agent1', 'agent2'], outputFile: 'reports/phase2-agent6-storage-report.md' },
  { id: 'agent7', name: 'Environment Opcodes', promptFile: 'prompts/phase2-agent7-environment.md', phase: 2, dependsOn: ['agent1', 'agent2'], outputFile: 'reports/phase2-agent7-environment-report.md' },
  { id: 'agent8', name: 'Block Context', promptFile: 'prompts/phase2-agent8-block.md', phase: 2, dependsOn: ['agent1'], outputFile: 'reports/phase2-agent8-block-report.md' },
  { id: 'agent9', name: 'Keccak/Logging', promptFile: 'prompts/phase2-agent9-keccak-log.md', phase: 2, dependsOn: ['agent1', 'agent2'], outputFile: 'reports/phase2-agent9-keccak-log-report.md' },
  { id: 'agent10', name: 'Control Flow', promptFile: 'prompts/phase2-agent10-control.md', phase: 2, dependsOn: ['agent1'], outputFile: 'reports/phase2-agent10-control-report.md' },
  { id: 'agent11', name: 'System Calls', promptFile: 'prompts/phase2-agent11-system-calls.md', phase: 2, dependsOn: ['agent1', 'agent2'], outputFile: 'reports/phase2-agent11-system-calls-report.md' },
  { id: 'agent12', name: 'Precompiles', promptFile: 'prompts/phase2-agent12-precompiles.md', phase: 2, dependsOn: ['agent1'], outputFile: 'reports/phase2-agent12-precompiles-report.md' },

  // Phase 3 - Integration
  { id: 'agent13', name: 'Interpreter Loop', promptFile: 'prompts/phase3-agent13-interpreter.md', phase: 3, dependsOn: ['agent3', 'agent4', 'agent5', 'agent6', 'agent7', 'agent8', 'agent9', 'agent10', 'agent11'], outputFile: 'reports/phase3-agent13-interpreter-report.md' },
  { id: 'agent14', name: 'Transaction Processing', promptFile: 'prompts/phase3-agent14-transaction.md', phase: 3, dependsOn: ['agent1', 'agent2'], outputFile: 'reports/phase3-agent14-transaction-report.md' },
  { id: 'agent15', name: 'EIP Compliance', promptFile: 'prompts/phase3-agent15-eip-compliance.md', phase: 3, dependsOn: ['agent1', 'agent2', 'agent11'], outputFile: 'reports/phase3-agent15-eip-compliance-report.md' },

  // Phase 4 - Test Infrastructure
  { id: 'agent16', name: 'Test Runner Setup', promptFile: 'prompts/phase4-agent16-test-runner.md', phase: 4, dependsOn: [], outputFile: 'reports/phase4-agent16-test-runner-report.md' },

  // Phase 5 - Validation
  { id: 'agent17', name: 'Test Result Analyzer', promptFile: 'prompts/phase5-agent17-test-analyzer.md', phase: 5, dependsOn: ['agent16'], outputFile: 'reports/phase5-agent17-test-analyzer-report.md' },
  { id: 'agent18', name: 'Fix Validator', promptFile: 'prompts/phase5-agent18-fix-validator.md', phase: 5, dependsOn: ['agent17'], outputFile: 'reports/phase5-agent18-fix-validator-report.md' },
];
```

### Step 3: Execute Full Pipeline

```bash
cd scripts

# Run all agents
bun index.ts

# Or run specific phases:
bun index.ts phase 1  # Foundation
bun index.ts phase 2  # Opcodes (runs in parallel)
bun index.ts phase 3  # Integration
bun index.ts phase 4  # Test setup
bun index.ts phase 5  # Validation
```

**Each agent will**:
- Run for up to 1000 turns (very thorough)
- Take 10-20 minutes each
- Cost $2-5 per agent
- Generate detailed markdown report

**Total pipeline cost**: ~$30-60 for complete exhaustive audit

### Step 4: Review Agent Reports

After each phase:
1. Read all reports in `reports/`
2. Prioritize CRITICAL and HIGH issues
3. Implement fixes
4. Re-run affected agents to verify

### Step 5: Test Phase

After Phase 3 complete and fixes implemented:

**Agent 16**: Fix test runner
- Update `test/specs/runner.zig` to read `fill` JSON output
- Ensure can run: `zig build test`

**Agent 17**: Analyze test results
- Run all official tests
- Categorize failures
- Identify high-impact bugs

**Agent 18**: Iterative fixing
- After each fix, run this agent
- Validates fix
- Reports progress

---

## Key Files Reference

### Configuration
- `scripts/index.ts` - Pipeline orchestrator (maxTurns: 1000)
- `scripts/package.json` - Dependencies

### Prompts (Create remaining)
- `prompts/phase1-agent1-primitives.md` ✅
- `prompts/phase1-agent2-state-management.md` ✅
- `prompts/phase2-agent11-system-calls.md` ✅
- `prompts/phase2-agent3-arithmetic.md` ⏳
- `prompts/phase2-agent4-bitwise.md` ⏳
- [... 10 more to create]

### Source Code to Audit
- `src/evm.zig` - Main EVM orchestrator
- `src/frame.zig` - Execution loop with 86 opcodes
- `src/primitives/gas_constants.zig` - ALL gas constants
- `src/primitives/uint.zig` - U256 operations
- `src/primitives/transaction.zig` - Transaction types
- [... see structure above]

### Reference Specs
- `execution-specs/src/ethereum/forks/prague/` - Python ground truth
- `guillotine-reference/` - Working Zig implementation for precompiles

### Output
- `reports/` - All agent reports saved here
- `reports/pipeline-summary.md` - Overall summary

---

## Critical Success Factors

1. **Exhaustive Comparison**: Every constant, every opcode, every EIP
2. **Line Numbers**: All findings must include exact file:line
3. **Priority Levels**: CRITICAL (breaks consensus), HIGH (wrong behavior), MEDIUM (missing features), LOW (optimization)
4. **Spec References**: Every finding cites Python spec location
5. **Verification**: After fixes, re-run affected agents

---

## Known Issues to Watch For

Based on spot checks and analysis:

1. ❌ **Missing BLS12-381 constants** in gas_constants.zig
2. ⚠️ **Transient storage** may not be implemented
3. ⚠️ **Created accounts tracking** may not exist (breaks SELFDESTRUCT)
4. ⚠️ **Access list pre-warming** timing unclear
5. ⚠️ **SELFDESTRUCT** likely uses old behavior (always delete)

---

## Next Agent Instructions

When fresh context picks this up:

1. Read this entire PROMPT.md
2. Create remaining agent prompts (agents 3-10, 12-18)
3. Update `scripts/index.ts` AGENTS array
4. Run: `cd scripts && bun index.ts`
5. Let it run for 2-4 hours (18 agents × 10-15 min each)
6. Review all reports in `reports/`
7. Implement CRITICAL fixes first
8. Re-run affected agents to verify
9. Proceed to test phase (Phase 4-5)

---

## Emergency Shortcuts

If time/cost constrained:

**Minimum Viable Audit**:
1. Run Agent 1 (primitives) - Find gas constant issues
2. Run Agent 2 (state) - Find transient storage / created accounts issues
3. Run Agent 11 (system calls) - Find SELFDESTRUCT / CREATE bugs
4. Fix CRITICAL issues found
5. Jump to Phase 4 (test setup)
6. Let tests find remaining bugs

**Full Thoroughness** (Recommended for financial software):
- Run all 18 agents
- Fix all CRITICAL and HIGH
- Then test

---

## Cost Estimate

- **Per agent**: $2-5 (with 1000 maxTurns)
- **Phase 1**: 2 agents = $4-10
- **Phase 2**: 10 agents = $20-50
- **Phase 3**: 3 agents = $6-15
- **Phase 4**: 1 agent = $2-5
- **Phase 5**: 2 agents = $4-10

**Total**: $36-90 for complete exhaustive audit

For mission-critical financial software, this is negligible cost for correctness.

---

## Final Notes

- `maxTurns: 1000` allows for very deep analysis
- Agents will be thorough, taking 10-20 minutes each
- Reports will be comprehensive with specific line numbers
- Use `guillotine-reference/` for precompile implementations
- Python spec is ground truth for all behavior
- Every finding must be verified and prioritized

**This is mission-critical financial software. Be EXHAUSTIVE.**
