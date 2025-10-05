# Guillotine EVM Exhaustive Audit - READY TO EXECUTE

## Status: ✅ ALL SYSTEMS GO

The complete audit infrastructure is now set up with 18 specialized agents ready to perform an exhaustive analysis of the Guillotine EVM implementation.

## What's Been Created

### ✅ Agent Prompts (18 total)

**Phase 1: Foundation (2 agents)**
- ✅ `prompts/phase1-agent1-primitives.md` - Gas constants, U256, transactions
- ✅ `prompts/phase1-agent2-state-management.md` - Storage, access lists, transient storage

**Phase 2: Opcodes (10 agents)** - Run in parallel
- ✅ `prompts/phase2-agent3-arithmetic.md` - ADD, MUL, SUB, DIV, SDIV, MOD, SMOD, ADDMOD, MULMOD, EXP, SIGNEXTEND
- ✅ `prompts/phase2-agent4-bitwise.md` - LT, GT, SLT, SGT, EQ, ISZERO, AND, OR, XOR, NOT, BYTE, SHL, SHR, SAR
- ✅ `prompts/phase2-agent5-stack-memory.md` - PUSH0-32, DUP1-16, SWAP1-16, POP, MLOAD, MSTORE, MSTORE8, MSIZE
- ✅ `prompts/phase2-agent6-storage.md` - SLOAD, SSTORE, TLOAD, TSTORE (with complex refund logic)
- ✅ `prompts/phase2-agent7-environment.md` - ADDRESS, CALLER, CALLVALUE, CALLDATALOAD, CALLDATASIZE, etc.
- ✅ `prompts/phase2-agent8-block.md` - BLOCKHASH, COINBASE, TIMESTAMP, BLOBHASH, BLOBBASEFEE
- ✅ `prompts/phase2-agent9-keccak-log.md` - KECCAK256, LOG0-LOG4
- ✅ `prompts/phase2-agent10-control.md` - JUMP, JUMPI, PC, JUMPDEST, GAS, STOP, RETURN, REVERT, INVALID
- ✅ `prompts/phase2-agent11-system-calls.md` - CREATE, CREATE2, CALL, DELEGATECALL, STATICCALL, SELFDESTRUCT
- ✅ `prompts/phase2-agent12-precompiles.md` - All 18 precompiles including BLS12-381

**Phase 3: Integration (3 agents)**
- ✅ `prompts/phase3-agent13-interpreter.md` - Main execution loop, PC management, stack/memory
- ✅ `prompts/phase3-agent14-transaction.md` - Transaction processing, validation, finalization
- ✅ `prompts/phase3-agent15-eip-compliance.md` - All 8 Prague EIPs

**Phase 4: Test Infrastructure (1 agent)**
- ✅ `prompts/phase4-agent16-test-runner.md` - Fix and run official Ethereum tests

**Phase 5: Validation (2 agents)**
- ✅ `prompts/phase5-agent17-test-analyzer.md` - Categorize failures, prioritize fixes
- ✅ `prompts/phase5-agent18-fix-validator.md` - Iterative fix validation

### ✅ Orchestration Scripts

- ✅ `scripts/index.ts` - Pipeline orchestrator with all 18 agents configured
- ✅ `scripts/package.json` - Dependencies installed
- ✅ Dependency graph configured (agents run in correct order)

## How to Execute

### Option 1: Run Everything (Recommended)
```bash
cd scripts
bun index.ts
```

**This will**:
- Run all 18 agents in order
- Phase 2 agents run in parallel (10 agents simultaneously)
- Generate detailed markdown reports for each
- Create `reports/pipeline-summary.md` with overall findings
- **Estimated time**: 2-4 hours
- **Estimated cost**: $36-90

### Option 2: Run Phase by Phase
```bash
cd scripts

# Phase 1: Foundation (2 agents, ~20-30 min, ~$8-15)
bun index.ts phase 1

# Review reports, then continue...

# Phase 2: Opcodes (10 agents in parallel, ~30-45 min, ~$20-50)
bun index.ts phase 2

# Phase 3: Integration (3 agents, ~30-45 min, ~$6-15)
bun index.ts phase 3

# Phase 4: Test Infrastructure (1 agent, ~10-15 min, ~$2-5)
bun index.ts phase 4

# Phase 5: Validation (2 agents, iterative, ~$4-10 per iteration)
bun index.ts phase 5
```

### Option 3: Run Single Agent
```bash
cd scripts
bun index.ts agent agent1    # Primitives
bun index.ts agent agent12   # Precompiles
# ... etc
```

## What Each Phase Does

### Phase 1: Foundation
**Audits**: Gas constants, U256 operations, transaction types, state management, transient storage

**Critical findings expected**:
- Missing BLS12-381 gas constants
- Transient storage not implemented
- Created accounts tracking missing

### Phase 2: Opcodes (Runs in Parallel)
**Audits**: All 86 implemented opcodes + 18 precompiles

**Critical findings expected**:
- SELFDESTRUCT using old behavior (EIP-6780)
- SSTORE refund logic bugs
- BLS12-381 precompiles missing
- TLOAD/TSTORE not implemented

### Phase 3: Integration
**Audits**: How everything works together

**Critical findings expected**:
- Access list pre-warming timing
- Transaction finalization bugs
- EIP compliance gaps

### Phase 4: Test Infrastructure
**Fixes**: Test runner to execute official tests

**Deliverable**: Working test suite showing pass/fail rates

### Phase 5: Validation
**Iterative**: Analyze failures → fix → validate → repeat

**Deliverable**: 100% test compliance

## Expected Output

Each agent generates a detailed markdown report like:

```markdown
# Agent X: [Name] Audit Report

## Summary
- Total items audited: X
- ✅ Correct: Y
- ⚠️ Issues found: Z
- ❌ Critical bugs: N

## Detailed Findings

### ⚠️ Issues Found

#### [CRITICAL] - Missing BLS12-381 Gas Constants
**File**: src/primitives/gas_constants.zig
**Issue**: All 8 BLS12-381 gas constants missing
**Spec**: execution-specs/src/ethereum/forks/prague/vm/gas.py:45-52
**Fix required**: Add GAS_BLS_G1_ADD = 375, GAS_BLS_G1_MUL = 12000, ...
**Priority**: CRITICAL - Blocks 30 precompile tests

[... more findings with exact file:line references]
```

## Priority Levels

**CRITICAL**: Breaks consensus, must fix
**HIGH**: Wrong behavior, important to fix
**MEDIUM**: Missing features, should fix
**LOW**: Optimizations, nice to have

## Next Steps After Execution

1. **Review `reports/pipeline-summary.md`** - Overall findings
2. **Review individual agent reports** - Specific issues
3. **Prioritize CRITICAL and HIGH issues**
4. **Implement fixes** based on agent recommendations
5. **Run Phase 4** (test infrastructure) after critical fixes
6. **Iterate with Phase 5** until 100% test compliance

## Known Issues to Watch For

Based on preliminary analysis, expect these CRITICAL findings:

1. **BLS12-381 Missing** (30 tests)
   - 8 gas constants missing
   - 8 precompiles not implemented
   - Reference: `guillotine-reference/src/crypto/`

2. **Transient Storage Missing** (12 tests)
   - TLOAD/TSTORE opcodes not found
   - No transient_storage map in state

3. **SELFDESTRUCT Wrong** (23 tests)
   - Not implementing EIP-6780
   - Always deletes instead of checking created_accounts

4. **Created Accounts Tracking Missing**
   - Required for EIP-6780
   - CREATE doesn't track

5. **Access List Pre-warming Timing**
   - May not warm before execution

## Cost Breakdown

**Per agent with maxTurns: 1000**:
- Simple agents (constants check): $2-3
- Medium agents (opcodes): $3-5
- Complex agents (integration): $4-7

**Total pipeline**:
- Phase 1: 2 agents × $4 = ~$8
- Phase 2: 10 agents × $4 = ~$40
- Phase 3: 3 agents × $5 = ~$15
- Phase 4: 1 agent × $3 = ~$3
- Phase 5: 2 agents × $4 = ~$8

**Grand total**: ~$70 for exhaustive audit of mission-critical financial software

This is negligible compared to the value of correctness.

## Files Created

```
prompts/
├── phase1-agent1-primitives.md
├── phase1-agent2-state-management.md
├── phase2-agent3-arithmetic.md
├── phase2-agent4-bitwise.md
├── phase2-agent5-stack-memory.md
├── phase2-agent6-storage.md
├── phase2-agent7-environment.md
├── phase2-agent8-block.md
├── phase2-agent9-keccak-log.md
├── phase2-agent10-control.md
├── phase2-agent11-system-calls.md
├── phase2-agent12-precompiles.md
├── phase3-agent13-interpreter.md
├── phase3-agent14-transaction.md
├── phase3-agent15-eip-compliance.md
├── phase4-agent16-test-runner.md
├── phase5-agent17-test-analyzer.md
└── phase5-agent18-fix-validator.md

scripts/
├── index.ts (orchestrator with all 18 agents)
├── package.json
└── bun.lock

reports/ (created after execution)
├── phase1-agent1-primitives-report.md
├── phase1-agent2-state-management-report.md
├── ... (18 total reports)
└── pipeline-summary.md
```

## Ready to Execute!

Everything is configured and ready. To start the exhaustive audit:

```bash
cd scripts
bun index.ts
```

Then sit back and let the 18 specialized agents perform a thorough, systematic audit of every component of the Guillotine EVM against the Prague execution-specs reference implementation.

**This is mission-critical financial software. The audit will be EXHAUSTIVE.**
