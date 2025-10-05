# Guillotine EVM Audit - Current Status

**Last Updated**: 2025-10-05

## ✅ Completed

1. **Infrastructure Setup**
   - ✅ Agent pipeline orchestrator (`scripts/index.ts`)
   - ✅ maxTurns increased to 1000 for exhaustive analysis
   - ✅ Reports directory created
   - ✅ Reference repository cloned (`guillotine-reference/`)

2. **Agent Prompts Created** (3/18)
   - ✅ `prompts/phase1-agent1-primitives.md`
   - ✅ `prompts/phase1-agent2-state-management.md`
   - ✅ `prompts/phase2-agent11-system-calls.md`

3. **Documentation**
   - ✅ `PROMPT.md` - Complete continuation context
   - ✅ `prompts/README.md` - Usage guide
   - ✅ `prompts/PIPELINE-PLAN.md` - Full strategy
   - ✅ This `STATUS.md` file

## 🔄 In Progress

- Phase 1 Agent 1 (Primitives) is running with 1000 maxTurns
- Needs: Completion and review

## ⏳ TODO

### Immediate (For Fresh Context)

1. **Create Remaining Agent Prompts** (15 prompts needed):
   ```
   Phase 2 Opcodes:
   - prompts/phase2-agent3-arithmetic.md
   - prompts/phase2-agent4-bitwise-comparison.md
   - prompts/phase2-agent5-stack-memory.md
   - prompts/phase2-agent6-storage.md
   - prompts/phase2-agent7-environment.md
   - prompts/phase2-agent8-block-context.md
   - prompts/phase2-agent9-keccak-logging.md
   - prompts/phase2-agent10-control-flow.md
   - prompts/phase2-agent12-precompiles.md (use guillotine-reference)

   Phase 3 Integration:
   - prompts/phase3-agent13-interpreter-loop.md
   - prompts/phase3-agent14-transaction-processing.md
   - prompts/phase3-agent15-eip-compliance.md

   Phase 4-5 Testing:
   - prompts/phase4-agent16-test-runner.md
   - prompts/phase5-agent17-test-analyzer.md
   - prompts/phase5-agent18-fix-validator.md
   ```

2. **Update `scripts/index.ts`**:
   - Add all 18 agents to AGENTS array
   - (Template provided in PROMPT.md)

3. **Execute Pipeline**:
   ```bash
   cd scripts
   bun index.ts  # Run all phases
   ```

4. **Review & Fix**:
   - Read all reports in `reports/`
   - Fix CRITICAL issues first
   - Re-run affected agents
   - Proceed to test phase

### Execution Order

**Phase 1** (Foundation) - ~20-40 min, $4-10:
- Agent 1: Primitives
- Agent 2: State Management

**Phase 2** (Opcodes) - ~2-3 hours, $20-50:
- Agents 3-12 run in parallel
- Most comprehensive phase

**Phase 3** (Integration) - ~30-60 min, $6-15:
- Agent 13: Interpreter Loop
- Agent 14: Transaction Processing
- Agent 15: EIP Compliance

**Phase 4** (Test Setup) - ~10-20 min, $2-5:
- Agent 16: Fix test runner

**Phase 5** (Validation) - ~20-40 min, $4-10:
- Agent 17: Analyze test failures
- Agent 18: Validate fixes (iterative)

**Total Time**: 3-5 hours
**Total Cost**: $36-90

## 📊 Key Findings So Far

### From Spot Checks:
- ✅ `SstoreRefundGas = 4800` (correct, EIP-3529)
- ✅ `ColdSloadCost = 2100` (correct, EIP-2929)
- ❌ **MISSING**: BLS12-381 gas constants (8 constants needed for EIP-2537)

### Expected Critical Issues:
Based on prompt analysis, likely to find:

1. **CRITICAL**:
   - Missing transient storage (EIP-1153)
   - Missing created_accounts tracking (EIP-6780)
   - SELFDESTRUCT using old behavior (always delete)
   - Missing BLS12-381 precompiles (8 precompiles)

2. **HIGH**:
   - Access list pre-warming timing
   - SSTORE gas calculation complexity
   - CREATE/CREATE2 validation gaps
   - STATICCALL restrictions not enforced

3. **MEDIUM**:
   - Missing gas constants
   - Hardfork gating on PUSH0
   - Blob transaction validation

## 🗂️ File Structure

```
guillotine-mini/
├── PROMPT.md              # ⭐ READ THIS FIRST for continuation
├── STATUS.md              # This file
├── prompts/
│   ├── README.md
│   ├── PIPELINE-PLAN.md
│   ├── phase1-agent1-primitives.md ✅
│   ├── phase1-agent2-state-management.md ✅
│   ├── phase2-agent11-system-calls.md ✅
│   └── [15 more to create] ⏳
├── scripts/
│   ├── index.ts           # Pipeline orchestrator (maxTurns: 1000)
│   └── package.json
├── reports/               # Agent outputs saved here
├── src/                   # Code being audited
├── execution-specs/       # Python reference (ground truth)
└── guillotine-reference/  # Reference impl for precompiles

```

## 🎯 Quick Start for Fresh Context

1. **Read** `PROMPT.md` (comprehensive context)
2. **Create** remaining 15 agent prompts (use existing 3 as templates)
3. **Update** `scripts/index.ts` AGENTS array
4. **Run** `cd scripts && bun index.ts`
5. **Wait** 3-5 hours for completion
6. **Review** `reports/pipeline-summary.md`
7. **Fix** CRITICAL issues
8. **Test** with Phase 4-5

## 💰 Budget

- Configuration: maxTurns = 1000 (very thorough)
- Per agent: $2-5
- Total pipeline: $36-90
- **Worth it for mission-critical financial software**

## 🔑 Critical Reminders

1. This is **mission-critical financial software** - be EXHAUSTIVE
2. Python spec (`execution-specs/`) is ground truth
3. Use `guillotine-reference/` for precompile examples
4. Every finding needs file:line and priority
5. Fix CRITICAL bugs before moving to next phase
6. Re-run agents after fixes to verify

## 📞 Support

If agents fail or produce poor output:
- Check `scripts/index.ts` configuration
- Review prompt quality (compare to working prompts)
- Increase maxTurns if hitting limits
- Check agent output in terminal for errors

## 🚨 Known Issues

Current agents (3/18) are very detailed and thorough. Remaining agents should follow same template structure:

1. **Objective** - What to audit
2. **Scope** - Files to examine
3. **Reference** - Python spec paths
4. **Tasks** - Detailed checklist with spec examples
5. **Output Format** - Markdown template

See existing prompts for examples.
