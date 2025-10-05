# Guillotine EVM Audit Pipeline - Complete Plan

## Overview

This is an automated, agent-based audit system that systematically reviews the Guillotine EVM implementation against the Python execution-specs Prague reference, identifies missing features and bugs, then validates with official tests.

## Strategy

**Phase 1-3**: Thorough code review & feature implementation (audit against Python spec)
**Phase 4**: Test infrastructure setup
**Phase 5**: Validation against official execution-specs tests

This ensures:
1. Complete feature coverage first
2. Architectural issues caught early
3. Testing only when implementation is believed complete
4. Tests used for final validation, not discovery

## Phase Breakdown

### Phase 1: Foundation (Week 1)
**Goal**: Audit primitives and state management

**Agents**:
- **Agent 1**: Primitives Auditor - Gas constants, U256, transactions, RLP, types
- **Agent 2**: State Management Auditor - Storage, access lists, transient storage, snapshots

**Execution**: Parallel (both run simultaneously)

**Deliverables**:
- Missing gas constants identified
- Transient storage (EIP-1153) implementation status
- Created accounts tracking (EIP-6780) status
- Access list pre-warming verification

---

### Phase 2: Opcode Implementation Audit (Week 2-3)
**Goal**: Audit all 141 opcodes against spec

**Agents** (all run in parallel):
- **Agent 3**: Arithmetic (ADD, MUL, SUB, DIV, SDIV, MOD, SMOD, ADDMOD, MULMOD, EXP, SIGNEXTEND)
- **Agent 4**: Bitwise & Comparison (AND, OR, XOR, NOT, BYTE, SHL, SHR, SAR, LT, GT, SLT, SGT, EQ, ISZERO)
- **Agent 5**: Stack & Memory (PUSH0-32, POP, DUP1-16, SWAP1-16, MLOAD, MSTORE, MSTORE8, MSIZE)
- **Agent 6**: Storage (SLOAD, SSTORE, TLOAD, TSTORE) - CRITICAL
- **Agent 7**: Environment (ADDRESS, BALANCE, ORIGIN, CALLER, CALLVALUE, CALLDATALOAD, etc.)
- **Agent 8**: Block Context (BLOCKHASH, COINBASE, TIMESTAMP, NUMBER, PREVRANDAO, BASEFEE, BLOBHASH, BLOBBASEFEE)
- **Agent 9**: Keccak & Logging (KECCAK256, LOG0-4)
- **Agent 10**: Control Flow (STOP, JUMP, JUMPI, PC, GAS, JUMPDEST)
- **Agent 11**: System Calls (CREATE, CREATE2, CALL, CALLCODE, DELEGATECALL, STATICCALL, RETURN, REVERT, SELFDESTRUCT) - CRITICAL
- **Agent 12**: Precompiles (0x01-0x12)

**Priority Agents**:
1. **Agent 11** (System Calls) - Most complex, ~40% of bugs likely here
2. **Agent 6** (Storage) - EIP-2200/2929/1153 complexity
3. **Agent 12** (Precompiles) - Missing implementations

**Deliverables**:
- Line-by-line opcode correctness
- Gas calculation verification
- Missing opcode implementations
- EIP compliance status

---

### Phase 3: Integration & EIP Compliance (Week 4)
**Goal**: Verify cross-cutting concerns and EIP compliance

**Agents** (sequential):
- **Agent 13**: Interpreter Loop - Main execution loop correctness
- **Agent 14**: Transaction Processing - Intrinsic gas, nonce, refunds
- **Agent 15**: EIP Compliance - All 8 Prague EIPs verified

**EIPs Verified**:
- EIP-1153: Transient Storage (TLOAD/TSTORE)
- EIP-2929: Gas cost increases (cold/warm)
- EIP-2930: Access Lists
- EIP-3529: Refund reduction
- EIP-3860: Init code limit
- EIP-4844: Blob transactions (BLOBHASH/BLOBBASEFEE)
- EIP-6780: SELFDESTRUCT restrictions (CRITICAL)
- EIP-7702: Set EOA code
- EIP-3855: PUSH0 (hardfork gating)
- EIP-2537: BLS12-381 precompiles

**Deliverables**:
- EIP compliance matrix
- Missing features comprehensive list
- Production readiness assessment

---

### Phase 4: Test Infrastructure (Week 5)
**Goal**: Fix test runner to work with execution-specs output

**Agent**:
- **Agent 16**: Test Runner Fixer

**Tasks**:
1. Understand current test infrastructure (`test/specs/runner.zig`)
2. Fix JSON fixture loading for `fill` output format
3. Build test discovery (auto-find all fixtures)
4. Create test categorization (opcode → tests, EIP → tests)

**Deliverables**:
- Working `zig build test` command
- Test manifest (all available tests listed)
- Initial test pass/fail counts

---

### Phase 5: Test Validation & Iteration (Week 6+)
**Goal**: Achieve 100% spec test pass rate

**Agents**:
- **Agent 17**: Test Result Analyzer (one-time)
- **Agent 18**: Fix Validator (iterative, runs after each fix)

**Workflow**:
```
1. Agent 17: Analyze ALL test failures
   ↓
2. Generate priority bug list
   ↓
3. Developer implements fix
   ↓
4. Agent 18: Validate fix
   ↓
5. Report progress (tests fixed, tests regressed)
   ↓
6. Loop until 100% pass rate
```

**Deliverables**:
- Bug taxonomy (categorized failures)
- Priority fix list
- Incremental progress reports
- Production-ready EVM (100% spec tests passing)

---

## Current Implementation Status

### Created Prompts
✅ `prompts/phase1-agent1-primitives.md` - Complete, detailed
✅ `prompts/phase1-agent2-state-management.md` - Complete, detailed
✅ `prompts/phase2-agent11-system-calls.md` - Complete, detailed
⏳ Other agents - Need to be created following the same template

### Orchestration Script
✅ `scripts/index.ts` - Complete
- Reads prompt files
- Executes agents with Claude Agent SDK
- Saves reports to `reports/`
- Generates summary with costs
- Supports running individual agents, phases, or full pipeline

### Usage
```bash
cd scripts

# Run everything
bun run index.ts

# Run specific phase
bun run index.ts phase 1

# Run specific agent
bun run index.ts agent agent1
```

---

## Next Steps to Complete Setup

### 1. Create Remaining Opcode Prompts
Copy the template structure from existing prompts and create:

```bash
# Phase 2 opcodes
prompts/phase2-agent3-arithmetic.md
prompts/phase2-agent4-bitwise-comparison.md
prompts/phase2-agent5-stack-memory.md
prompts/phase2-agent6-storage.md
prompts/phase2-agent7-environment.md
prompts/phase2-agent8-block-context.md
prompts/phase2-agent9-keccak-logging.md
prompts/phase2-agent10-control-flow.md
prompts/phase2-agent12-precompiles.md

# Phase 3 integration
prompts/phase3-agent13-interpreter-loop.md
prompts/phase3-agent14-transaction-processing.md
prompts/phase3-agent15-eip-compliance.md

# Phase 4-5 testing
prompts/phase4-agent16-test-runner.md
prompts/phase5-agent17-test-analyzer.md
prompts/phase5-agent18-fix-validator.md
```

### 2. Add Agents to scripts/index.ts

After creating each prompt, add it to the `AGENTS` array:

```typescript
// Example:
{
  id: 'agent6',
  name: 'Storage Opcodes Auditor',
  promptFile: 'prompts/phase2-agent6-storage.md',
  phase: 2,
  dependsOn: ['agent1', 'agent2'],
  outputFile: 'reports/phase2-agent6-storage-report.md',
},
```

### 3. Prompt Template Structure

Each prompt should follow this structure:

```markdown
# Agent N: [Name]

## Objective
[What to audit]

## Scope
[Files to examine]
[Reference spec files]

## Tasks
### 1. [Component Name]
**Reference**: execution-specs path

**Check**:
- [ ] Specific item 1
- [ ] Specific item 2

**Spec Example**:
```python
# Python code from spec
```

**Audit**:
- Compare against Zig implementation
- Flag discrepancies

## Output Format
[Markdown template for report]
```

---

## Expected Outcomes

### After Phase 1-3 (Code Audit)
- ✅ All 141 opcodes implemented
- ✅ All 8 Prague EIPs compliant
- ✅ All 18 precompiles implemented
- ✅ Zero known missing features
- ✅ Comprehensive audit reports with line numbers

### After Phase 4 (Test Setup)
- ✅ Working test runner
- ✅ Test manifest generated
- ✅ Baseline test results

### After Phase 5 (Validation)
- ✅ 100% spec test pass rate
- ✅ Production-ready EVM
- ✅ All bugs fixed and validated

---

## Estimated Costs

### Agent Costs (using Claude Sonnet 4.5)
- Simple audits (arithmetic, bitwise): $0.10-0.20 each
- Medium audits (state, environment): $0.30-0.50 each
- Complex audits (system calls, precompiles): $0.50-1.00 each

### Phase Costs
- Phase 1 (2 agents): ~$0.80
- Phase 2 (10 agents): ~$4.00
- Phase 3 (3 agents): ~$1.50
- Phase 4 (1 agent): ~$0.50
- Phase 5 (varies): ~$2.00-5.00

**Total Pipeline**: ~$10-15

---

## Critical Success Factors

1. **Thoroughness**: Agents must check EVERY aspect of the spec
2. **Specificity**: Reports must include exact line numbers and fixes
3. **Prioritization**: CRITICAL bugs (like SELFDESTRUCT EIP-6780) addressed first
4. **Iteration**: Fix → Validate → Repeat until all tests pass
5. **Documentation**: All findings tracked in markdown reports

---

## Running the Pipeline

### First Run (Test Single Agent)
```bash
cd scripts
bun run index.ts agent agent1
# Review output in reports/phase1-agent1-primitives-report.md
```

### Full Phase 1
```bash
bun run index.ts phase 1
# Review all Phase 1 reports
# Implement fixes for CRITICAL issues
```

### Full Pipeline (When Ready)
```bash
bun run index.ts
# Sit back and let it run (30-60 minutes)
# Review reports/pipeline-summary.md
```

---

## Maintenance

As you implement fixes:
1. Re-run affected agents to verify
2. Update this plan with completed phases
3. Track progress in pipeline-summary.md
4. Use Agent 18 (Fix Validator) after each fix

---

## Files Created

```
prompts/
├── README.md                           # Usage guide
├── PIPELINE-PLAN.md                    # This file
├── phase1-agent1-primitives.md         # ✅ Complete
├── phase1-agent2-state-management.md   # ✅ Complete
├── phase2-agent11-system-calls.md      # ✅ Complete
└── [13 more to create]

scripts/
├── index.ts                            # ✅ Complete orchestrator
└── package.json

reports/                                 # Generated by pipeline
├── phase1-agent1-primitives-report.md
├── phase1-agent2-state-management-report.md
└── pipeline-summary.md
```

---

## Support

If agents produce poor quality reports:
- Increase `maxTurns` in scripts/index.ts
- Add more specific instructions to prompts
- Review and refine prompt templates
- Run agents individually for debugging

If costs are too high:
- Use `claude-3-5-sonnet-20241022` instead of `claude-sonnet-4-5-20250929`
- Reduce `maxTurns` to 15-20
- Split complex agents into smaller ones
