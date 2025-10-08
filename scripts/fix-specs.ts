import { query } from "@anthropic-ai/claude-agent-sdk";
import { execSync } from "child_process";
import { writeFileSync, mkdirSync, existsSync, readFileSync, readdirSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

// Get repo root
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const REPO_ROOT = join(__dirname, "..");
const KNOWN_ISSUES_PATH = join(__dirname, "known-issues.json");

// Test suite configuration
interface TestSuite {
  name: string;
  command: string;
  description: string;
}

// Known issues database
interface KnownIssue {
  test_suite: string;
  description: string;
  common_causes: string[];
  relevant_files: string[];
  python_ref: string;
  key_invariants: string[];
  gas_costs?: Record<string, number>;
}

interface KnownIssuesDatabase {
  issues: Record<string, KnownIssue>;
}

const TEST_SUITES: TestSuite[] = [
  // These pass (commented out)
  { name: 'paris', command: 'zig build specs-paris', description: 'Paris/Merge hardfork tests' },
  { name: 'homestead', command: 'zig build specs-homestead', description: 'Homestead hardfork tests' },
  { name: 'shanghai-withdrawals', command: 'zig build specs-shanghai-withdrawals', description: 'Shanghai EIP-4895 withdrawal tests' },
  { name: 'shanghai-push0', command: 'zig build specs-shanghai-push0', description: 'Shanghai EIP-3855 PUSH0 tests' },

  // Cancun sub-targets (broken up from large test suite)
  { name: 'cancun-tstore-basic', command: 'zig build specs-cancun-tstore-basic', description: 'Cancun EIP-1153 basic TLOAD/TSTORE tests' },
  { name: 'cancun-tstore-reentrancy', command: 'zig build specs-cancun-tstore-reentrancy', description: 'Cancun EIP-1153 reentrancy tests' },
  { name: 'cancun-tstore-contexts', command: 'zig build specs-cancun-tstore-contexts', description: 'Cancun EIP-1153 execution context tests' },
  { name: 'cancun-mcopy', command: 'zig build specs-cancun-mcopy', description: 'Cancun EIP-5656 MCOPY tests' },
  { name: 'cancun-selfdestruct', command: 'zig build specs-cancun-selfdestruct', description: 'Cancun EIP-6780 SELFDESTRUCT tests' },
  { name: 'cancun-blobbasefee', command: 'zig build specs-cancun-blobbasefee', description: 'Cancun EIP-7516 BLOBBASEFEE tests' },
  { name: 'cancun-blob-precompile', command: 'zig build specs-cancun-blob-precompile', description: 'Cancun EIP-4844 point evaluation precompile tests' },
  { name: 'cancun-blob-opcodes', command: 'zig build specs-cancun-blob-opcodes', description: 'Cancun EIP-4844 BLOBHASH opcode tests' },
  { name: 'cancun-blob-tx-small', command: 'zig build specs-cancun-blob-tx-small', description: 'Cancun EIP-4844 small blob transaction tests' },
  { name: 'cancun-blob-tx-subtraction', command: 'zig build specs-cancun-blob-tx-subtraction', description: 'Cancun EIP-4844 blob gas subtraction tests' },
  { name: 'cancun-blob-tx-insufficient', command: 'zig build specs-cancun-blob-tx-insufficient', description: 'Cancun EIP-4844 insufficient balance tests' },
  { name: 'cancun-blob-tx-sufficient', command: 'zig build specs-cancun-blob-tx-sufficient', description: 'Cancun EIP-4844 sufficient balance tests' },
  { name: 'cancun-blob-tx-valid-combos', command: 'zig build specs-cancun-blob-tx-valid-combos', description: 'Cancun EIP-4844 valid combinations tests' },

  // Prague sub-targets (broken up from large test suite)
  { name: 'prague-calldata-cost-type0', command: 'zig build specs-prague-calldata-cost-type0', description: 'Prague EIP-7623 calldata cost type 0 tests' },
  { name: 'prague-calldata-cost-type1-2', command: 'zig build specs-prague-calldata-cost-type1-2', description: 'Prague EIP-7623 calldata cost type 1/2 tests' },
  { name: 'prague-calldata-cost-type3', command: 'zig build specs-prague-calldata-cost-type3', description: 'Prague EIP-7623 calldata cost type 3 tests' },
  { name: 'prague-calldata-cost-type4', command: 'zig build specs-prague-calldata-cost-type4', description: 'Prague EIP-7623 calldata cost type 4 tests' },
  { name: 'prague-calldata-cost-refunds', command: 'zig build specs-prague-calldata-cost-refunds', description: 'Prague EIP-7623 refunds and gas tests' },
  { name: 'prague-bls-g1', command: 'zig build specs-prague-bls-g1', description: 'Prague EIP-2537 BLS12-381 G1 tests' },
  { name: 'prague-bls-g2', command: 'zig build specs-prague-bls-g2', description: 'Prague EIP-2537 BLS12-381 G2 tests' },
  { name: 'prague-bls-pairing', command: 'zig build specs-prague-bls-pairing', description: 'Prague EIP-2537 BLS12-381 pairing tests' },
  { name: 'prague-bls-map', command: 'zig build specs-prague-bls-map', description: 'Prague EIP-2537 BLS12-381 map tests' },
  { name: 'prague-bls-misc', command: 'zig build specs-prague-bls-misc', description: 'Prague EIP-2537 BLS12-381 misc tests' },
  { name: 'prague-setcode-calls', command: 'zig build specs-prague-setcode-calls', description: 'Prague EIP-7702 set code call tests' },
  { name: 'prague-setcode-gas', command: 'zig build specs-prague-setcode-gas', description: 'Prague EIP-7702 set code gas tests' },
  { name: 'prague-setcode-txs', command: 'zig build specs-prague-setcode-txs', description: 'Prague EIP-7702 set code transaction tests' },
  { name: 'prague-setcode-advanced', command: 'zig build specs-prague-setcode-advanced', description: 'Prague EIP-7702 advanced set code tests' },

  // Osaka sub-targets (broken up from large test suite)
  { name: 'osaka-modexp-variable-gas', command: 'zig build specs-osaka-modexp-variable-gas', description: 'Osaka EIP-7883 modexp variable gas tests' },
  { name: 'osaka-modexp-vectors-eip', command: 'zig build specs-osaka-modexp-vectors-eip', description: 'Osaka EIP-7883 modexp vectors from EIP tests' },
  { name: 'osaka-modexp-vectors-legacy', command: 'zig build specs-osaka-modexp-vectors-legacy', description: 'Osaka EIP-7883 modexp vectors from legacy tests' },
  { name: 'osaka-modexp-misc', command: 'zig build specs-osaka-modexp-misc', description: 'Osaka EIP-7883 modexp misc tests' },
  { name: 'osaka-other', command: 'zig build specs-osaka-other', description: 'Osaka other EIP tests' },

  // Shanghai EIPs
  { name: 'shanghai-warmcoinbase', command: 'zig build specs-shanghai-warmcoinbase', description: 'Shanghai EIP-3651 warm coinbase tests' },
  { name: 'shanghai-initcode', command: 'zig build specs-shanghai-initcode', description: 'Shanghai EIP-3860 initcode tests' },

  // Smaller hardforks (no sub-targets needed)
  { name: 'byzantium', command: 'zig build specs-byzantium', description: 'Byzantium hardfork tests' },
  // Berlin sub-targets (broken up from large test suite)
  { name: 'berlin-acl', command: 'zig build specs-berlin-acl', description: 'Berlin EIP-2930 access list account storage tests' },
  { name: 'berlin-intrinsic-gas-cost', command: 'zig build specs-berlin-intrinsic-gas-cost', description: 'Berlin EIP-2930 transaction intrinsic gas cost tests' },
  { name: 'berlin-intrinsic-type0', command: 'zig build specs-berlin-intrinsic-type0', description: 'Berlin EIP-2930 intrinsic gas type 0 transaction tests' },
  { name: 'berlin-intrinsic-type1', command: 'zig build specs-berlin-intrinsic-type1', description: 'Berlin EIP-2930 intrinsic gas type 1 transaction tests' },

  // Frontier sub-targets (broken up from large test suite)
  { name: 'frontier-precompiles', command: 'zig build specs-frontier-precompiles', description: 'Frontier precompile tests' },
  { name: 'frontier-identity', command: 'zig build specs-frontier-identity', description: 'Frontier identity precompile tests' },
  { name: 'frontier-create', command: 'zig build specs-frontier-create', description: 'Frontier CREATE tests' },
  { name: 'frontier-call', command: 'zig build specs-frontier-call', description: 'Frontier CALL/CALLCODE tests' },
  { name: 'frontier-calldata', command: 'zig build specs-frontier-calldata', description: 'Frontier calldata opcode tests' },
  { name: 'frontier-dup', command: 'zig build specs-frontier-dup', description: 'Frontier DUP tests' },
  { name: 'frontier-push', command: 'zig build specs-frontier-push', description: 'Frontier PUSH tests' },
  { name: 'frontier-stack', command: 'zig build specs-frontier-stack', description: 'Frontier stack overflow tests' },
  { name: 'frontier-opcodes', command: 'zig build specs-frontier-opcodes', description: 'Frontier all opcodes tests' },
  { name: 'constantinople', command: 'zig build specs-constantinople', description: 'Constantinople hardfork tests' },
  { name: 'istanbul', command: 'zig build specs-istanbul', description: 'Istanbul hardfork tests' },
];

interface TestResult {
  suite: string;
  passed: boolean;
  output: string;
  error?: string;
}

interface FixAttempt {
  suite: string;
  attempt: number;
  success: boolean;
  agentCost: number;
  agentTurns: number;
  agentDuration: number;
  error?: string;
}

class SpecFixerPipeline {
  private reportsDir = join(REPO_ROOT, "reports", "spec-fixes");
  private maxAttemptsPerSuite = 5;
  private fixAttempts: FixAttempt[] = [];
  private knownIssues: KnownIssuesDatabase;

  constructor() {
    if (!existsSync(this.reportsDir)) {
      mkdirSync(this.reportsDir, { recursive: true });
    }

    // Load known issues database
    this.knownIssues = this.loadKnownIssues();
  }

  private loadKnownIssues(): KnownIssuesDatabase {
    try {
      if (existsSync(KNOWN_ISSUES_PATH)) {
        const content = readFileSync(KNOWN_ISSUES_PATH, "utf-8");
        return JSON.parse(content);
      }
    } catch (error) {
      console.warn(`⚠️  Could not load known issues database: ${error}`);
    }
    return { issues: {} };
  }

  private getKnownIssueContext(suiteName: string): string {
    const issue = this.knownIssues.issues[suiteName];
    if (!issue) {
      return "";
    }

    return `
<known_issues>
## Known Issues for ${suiteName}

**Description**: ${issue.description}

### Common Causes
${issue.common_causes.map((cause, i) => `${i + 1}. ${cause}`).join("\n")}

### Relevant Files to Check
${issue.relevant_files.map((file) => `- \`${file}\``).join("\n")}

### Python Reference Location
\`${issue.python_ref}\`

### Key Invariants
${issue.key_invariants.map((inv) => `- ${inv}`).join("\n")}

${issue.gas_costs ? `### Expected Gas Costs
${Object.entries(issue.gas_costs)
  .map(([op, cost]) => `- **${op}**: ${cost} gas`)
  .join("\n")}
` : ""}

**Note**: This historical context is based on previous debugging sessions. Use it as a guide, but always verify against the current test output and Python reference implementation.
</known_issues>
`;
  }

  runTest(suite: TestSuite): TestResult {
    console.log(`\n${"=".repeat(80)}`);
    console.log(`🧪 Running: ${suite.description}`);
    console.log(`${"=".repeat(80)}`);
    console.log(`Command: ${suite.command}\n`);

    try {
      const output = execSync(suite.command, {
        cwd: REPO_ROOT,
        encoding: "utf-8",
        stdio: "pipe",
        maxBuffer: 10 * 1024 * 1024, // 10MB buffer
      });

      console.log("✅ Tests passed!\n");
      return {
        suite: suite.name,
        passed: true,
        output,
      };
    } catch (error: any) {
      const output = error.stdout || "";
      const errorOutput = error.stderr || "";
      console.log("❌ Tests failed\n");

      return {
        suite: suite.name,
        passed: false,
        output,
        error: errorOutput,
      };
    }
  }

  async fixWithAgent(
    suite: TestSuite,
    testResult: TestResult,
    attemptNumber: number,
  ): Promise<FixAttempt> {
    console.log(`\n${"█".repeat(80)}`);
    console.log(
      `🤖 Starting Agent Fix - Attempt ${attemptNumber}/${this.maxAttemptsPerSuite}`,
    );
    console.log(`Suite: ${suite.description}`);
    console.log(`${"█".repeat(80)}\n`);

    const startTime = Date.now();

    // Include known issues context if available
    const knownIssueContext = this.getKnownIssueContext(suite.name);

    const prompt = `🚨 CRITICAL: Complete ALL checkpoints with ACTUAL data before ANY code changes. NO placeholders/TBDs.

<task>
Make EVM spec-compliant by passing ${suite.description} tests.
</task>

<context>
Suite: ${suite.description}
Command: \`${suite.command}\`
Tests: ethereum/tests (authoritative reference used by geth, erigon, nethermind)
</context>
${knownIssueContext}

<methodology>
🔴 MANDATORY WORKFLOW - NEVER SKIP STEPS 🔴

## ⚡ PRE-ANALYSIS PHASE (COMPLETE BEFORE CODE CHANGES)

⚠️ FAILURE TO COMPLETE = WASTED EFFORT. Provide ACTUAL data for each checkpoint (no "[TBD]", "[value]").

You must complete each checkpoint in order and explicitly confirm completion before moving to the next step. Each checkpoint requires ACTUAL data (not placeholders).

---

### ✅ CHECKPOINT 1: Run Test and Confirm Failure

**Required Actions**:
1. Run the test suite command: \`${suite.command}\`
2. Capture the complete failure output
3. Identify how many tests failed and their names
4. Record any error messages, stack traces, or crash information

**Checkpoint Confirmation** (you MUST provide this):
\`\`\`
✅ CHECKPOINT 1 COMPLETE
- Command executed: ${suite.command}
- Tests failed: [exact number]
- Test names: [exact list of failing tests]
- Failure type: [gas error | wrong output | crash | other]
\`\`\`

**DO NOT PROCEED** until you have confirmed this checkpoint with actual data.

---

### ✅ CHECKPOINT 2: Generate Trace Comparison and Identify Divergence

**Required Actions**:

**BEST PRACTICE**: Use the dedicated trace comparison tool for detailed divergence analysis:
\`\`\`bash
bun run scripts/compare-traces.ts "exact_test_name"
\`\`\`

This tool provides:
- Automatic trace capture and comparison
- Side-by-side divergence visualization
- Exact PC, opcode, gas, and stack details at divergence point
- Context showing steps before divergence
- Detailed markdown report with next-step guidance
- Saved reports in traces/<test_name>_analysis.md

**Alternative approach** - Use the test isolation helper:
\`\`\`bash
./scripts/isolate-test.sh "exact_test_name"
\`\`\`

This helper automatically:
- Sets TEST_FILTER to the exact test
- Runs with verbose tracing enabled
- Analyzes failure type (crash vs behavior divergence vs gas error)
- Extracts divergence details
- Provides next-step guidance

**Manual fallback** (if helpers unavailable):
\`\`\`bash
TEST_FILTER="exact_test_name" ${suite.command}
\`\`\`

**If tests are crashing** (segfault, panic, etc.):
1. Note that crash debugging will be required (see Phase 2, Strategy 6)
2. Skip to Checkpoint 4 with crash information
3. Mark this checkpoint as "SKIPPED (crash detected)"

**If tests are failing** with incorrect behavior/gas:
1. Pick ONE specific failing test to analyze
2. Run that single test in isolation using the helper script
3. The test runner automatically generates trace comparison
4. Identify the EXACT divergence point from the output

**Checkpoint Confirmation** (you MUST paste actual divergence output):
\`\`\`
✅ CHECKPOINT 2 COMPLETE
- Isolated test: [exact test name]
- Divergence PC: [actual PC value from trace]
- Diverging opcode: [actual opcode from trace]
- Expected gas: [actual value from trace]
- Actual gas: [actual value from trace]
- Gas difference: [calculated: expected - actual]
- Stack at divergence: [paste actual stack if different, or "no divergence"]
- Memory at divergence: [paste actual memory if different, or "no divergence"]
- Storage at divergence: [paste actual storage if different, or "no divergence"]
\`\`\`

OR (if crashing):
\`\`\`
✅ CHECKPOINT 2 SKIPPED (crash detected)
- Crash type: [segfault | panic | unreachable | other]
- Crash message: [paste actual error message]
- Stack trace: [paste relevant stack trace if available]
- Suspected location: [file/function if identifiable]
\`\`\`

**DO NOT PROCEED** until you have confirmed this checkpoint with ACTUAL data (no placeholders like "[TBD]" or "[Will check]").

---

### ✅ CHECKPOINT 3: Read Python Reference Implementation

**Required Actions**:
1. Navigate to \`execution-specs/src/ethereum/forks/<hardfork>/\`
2. Based on the divergence point, identify the relevant Python file:
   - Opcode logic: \`vm/instructions/*.py\`
   - Gas calculation: \`vm/gas.py\`
   - State changes: \`state.py\`
   - Call/Create: \`vm/instructions/system.py\`
3. Read the COMPLETE function implementation for the diverging operation
4. Quote the relevant Python code (not just summaries)

**Checkpoint Confirmation** (you MUST quote actual Python code):
\`\`\`
✅ CHECKPOINT 3 COMPLETE
- Reference file: [exact path in execution-specs, e.g., execution-specs/src/ethereum/forks/cancun/vm/instructions/storage.py]
- Function name: [exact function name, e.g., sstore]
- Relevant Python code (quote the actual implementation):
  ---
  [paste the actual Python function or relevant lines]
  ---
- Gas calculation order (from Python code, with line references):
  1. [First gas charge: quote Python line]
  2. [Second gas charge: quote Python line]
  3. [etc.]
- Hardfork guards: [quote any if/fork checks from Python, or "none"]
- Error conditions: [quote any raise statements from Python, or "none"]
\`\`\`

**DO NOT PROCEED** until you have quoted ACTUAL Python code (no summaries or paraphrases).

---

### ✅ CHECKPOINT 4: Locate and Compare Zig Implementation

**Required Actions**:
1. Based on the failure type, identify which Zig file to examine:
   - Opcodes: \`src/frame.zig\`
   - Call/Create: \`src/evm.zig\`
   - Storage: \`src/evm.zig\`
   - Gas constants: \`src/primitives/gas_constants.zig\`
2. Read the current Zig implementation
3. Compare line-by-line with Python reference from Checkpoint 3

**Checkpoint Confirmation** (you MUST identify SPECIFIC discrepancies):
\`\`\`
✅ CHECKPOINT 4 COMPLETE
- Zig file: [exact path, e.g., src/frame.zig]
- Zig function/section: [exact location with line numbers, e.g., SSTORE implementation lines 450-480]
- Current Zig implementation (quote relevant lines):
  ---
  [paste actual Zig code]
  ---
- Discrepancies identified (compare Python vs Zig line-by-line):
  1. Python does: [quote Python line from Checkpoint 3]
     Zig does: [quote Zig line from above]
     Problem: [explain the specific difference]
  2. [additional discrepancies with same format]
  3. [etc.]
- If no discrepancies: [explain why tests still fail despite matching logic]
\`\`\`

**DO NOT PROCEED** until you have identified CONCRETE discrepancies with actual code quotes.

---

### ✅ CHECKPOINT 5: Diagnose Root Cause and Propose Fix

**Required Actions**:
1. Based on the evidence from checkpoints 1-4, diagnose the root cause
2. Propose a specific fix that aligns Zig with Python reference
3. List all files that need modification with specific line ranges

**Checkpoint Confirmation** (you MUST provide clear diagnosis):
\`\`\`
✅ CHECKPOINT 5 COMPLETE

### Root Cause Diagnosis
[Explain in 2-4 sentences what is wrong, referencing specific evidence from checkpoints 2-4. Be specific about what diverges and why.]

### Proposed Fix
[Explain what will change to match Python reference. Be specific:
- What code will be added/removed/modified
- What gas values/logic will change
- Why this matches the Python reference]

### Files to Modify
- \`src/<file1>.zig\` (lines X-Y) - [specific change]
- \`src/<file2>.zig\` (lines X-Y) - [specific change] (if applicable)

### Expected Outcome
[What should happen after the fix:
- Expected gas value
- Expected behavior
- Which tests should pass]
\`\`\`

**DO NOT PROCEED** to implementation until you have provided this diagnosis.

---

### ✅ CHECKPOINT 6: Implement Fix

**Required Actions**:
1. Make the minimal changes identified in Checkpoint 5
2. Preserve existing behavior for other hardforks
3. Use proper hardfork guards if needed (e.g., \`if (self.hardfork.isAtLeast(.CANCUN))\`)
4. Do not make unrelated changes

**Checkpoint Confirmation**:
\`\`\`
✅ CHECKPOINT 6 COMPLETE
- Files modified: [list with line numbers]
- Changes made: [brief summary matching Checkpoint 5 proposal]
- Hardfork guards added: [yes/no, if yes quote the guard]
\`\`\`

---

### ✅ CHECKPOINT 7: Verify Fix

**Required Actions**:
1. Run the test command: \`${suite.command}\`
2. Confirm tests pass or identify new failures
3. If tests still fail, capture NEW failure output and return to Checkpoint 2

**Checkpoint Confirmation**:
\`\`\`
✅ CHECKPOINT 7 COMPLETE
- Command executed: ${suite.command}
- Tests passing: [yes/no]
- Number of tests passing: [exact count]
- Number of tests still failing: [exact count]

[IF TESTS STILL FAIL]:
- New failure type: [gas error | wrong output | crash | other]
- New divergence point: [paste new trace divergence]
- Action: Returning to Checkpoint 2 for iteration
\`\`\`

If tests still fail after the fix, you MUST iterate by returning to Checkpoint 2 with the NEW failure output.

---

## PRE-ANALYSIS REPORT (Final Summary)

After completing all checkpoints (or after Checkpoint 7 if iterating), provide this summary report:

\`\`\`markdown
## PRE-ANALYSIS REPORT

### Test Failure Summary
- **Total tests failed**: [from Checkpoint 1]
- **Test name(s)**: [from Checkpoint 1]
- **Failure type**: [from Checkpoint 1]

### Trace Divergence Analysis
[IF APPLICABLE - from Checkpoint 2]
- **Divergence PC**: [from Checkpoint 2]
- **Diverging opcode**: [from Checkpoint 2]
- **Expected gas**: [from Checkpoint 2]
- **Actual gas**: [from Checkpoint 2]
- **Gas difference**: [from Checkpoint 2]

OR

[IF CRASHING - from Checkpoint 2]
- **Crash type**: [from Checkpoint 2]
- **Crash location**: [from Checkpoint 2]
- **Crash message**: [from Checkpoint 2]

### Python Reference Behavior
- **Reference file**: [from Checkpoint 3]
- **Function name**: [from Checkpoint 3]
- **Key behavior**: [summarize from Checkpoint 3 Python code]
- **Gas calculation order**: [from Checkpoint 3]

### Zig Implementation Analysis
- **Current file**: [from Checkpoint 4]
- **Discrepancies identified**: [from Checkpoint 4]

### Root Cause and Fix
- **Root cause**: [from Checkpoint 5]
- **Proposed fix**: [from Checkpoint 5]
- **Files modified**: [from Checkpoint 6]
- **Verification result**: [from Checkpoint 7]

---
**Analysis complete. All checkpoints confirmed.**
\`\`\`

**Validation Rules**:
- ✅ ALL checkpoints MUST be explicitly confirmed before proceeding to the next
- ✅ Each checkpoint MUST include actual data (test output, code quotes, trace output)
- ✅ NO placeholders like "[TODO]", "[TBD]", "[Will investigate]", "[value]"
- ✅ If you cannot complete a checkpoint, STOP and explain what information is missing
- ✅ If tests fail after implementation, iterate by returning to Checkpoint 2
- ❌ DO NOT skip checkpoints
- ❌ DO NOT proceed to fixes without completing analysis checkpoints 1-5
- ❌ DO NOT use summaries instead of actual code/output quotes
- ❌ DO NOT guess values or use placeholders

## Phase 1: Understand the Failure
1. **Identify the failure type**:
   - Gas calculation error? → Check gas_constants.zig and gas metering logic
   - Wrong output/state? → Check opcode implementations in frame.zig
   - Wrong behavior? → Check EVM orchestration in evm.zig
   - Hardfork-specific? → Check hardfork.zig feature flags

2. **Analyze test names**: Test names often reveal what they're testing (e.g., "transientStorageReset" tests TSTORE/TLOAD opcodes, "warmCoinbase" tests EIP-3651)

3. **Read the error output carefully**: Look for:
   - Expected vs actual gas values
   - Stack differences
   - Memory/storage differences
   - Return data mismatches

## Phase 2: Locate the Bug

**CRITICAL**: Before making ANY changes, you MUST:

1. **Generate and compare traces**: Use the test runner's built-in trace comparison to see EXACTLY where our implementation diverges from the reference
   - The test runner automatically captures EIP-3155 traces
   - It shows the exact PC, opcode, gas, and stack state where divergence occurs
   - This is your PRIMARY debugging tool - use it FIRST, not as a last resort

2. **Study the Python reference implementation**: This is the authoritative specification
   - Location: \`execution-specs/src/ethereum/forks/<hardfork>/\`
   - Opcode implementations: \`vm/instructions/\`
   - Main interpreter: \`vm/interpreter.py\`
   - Gas metering: \`vm/gas.py\`
   - State management: \`state.py\`
   - Read the ACTUAL Python code - don't guess what it should do
   - The Python reference is battle-tested and correct; trust it over your intuition

3. **Use targeted file reading**: Based on the failure type AND trace divergence point, read the most relevant files

4. **Check hardfork activation**: Verify the feature is enabled for the correct hardfork using \`hardfork.isAtLeast()\`

**Why this order matters**:
- Traces show you the EXACT divergence point (saves hours of guessing)
- Python reference shows you the CORRECT behavior (eliminates ambiguity)
- Making changes without these two sources is effectively guessing

## Phase 3: Fix the Issue
1. **Make minimal, focused changes**: Fix only what's broken, don't refactor unnecessarily
2. **Preserve existing behavior**: Ensure your fix doesn't break other hardforks
3. **Add hardfork guards**: Use \`if (self.hardfork.isAtLeast(.FORK_NAME))\` for fork-specific behavior
4. **Update gas constants**: If gas costs changed in a hardfork, update gas_constants.zig

## Phase 4: Verify the Fix
1. **Run the test command**: \`${suite.command}\`
2. **Check for regressions**: If you fixed one test but broke others, refine your approach
3. **Iterate if needed**: If tests still fail, analyze the new output and adjust
4. **Use traces for debugging**: If gas differences persist, compare execution traces
5. **Filter to single test**: Use \`TEST_FILTER="test_name" ${suite.command}\` to focus on one failing test

## Important Guidelines

**MANDATORY DEBUGGING PROCESS**:
1. **ALWAYS generate traces FIRST** - Run the failing test and examine the trace divergence output
2. **ALWAYS read the Python reference** - Find the corresponding opcode/function in execution-specs
3. **ALWAYS compare step-by-step** - Match our Zig implementation against the Python reference line-by-line
4. **NEVER guess** - If you don't see trace divergence, you don't know what's wrong
5. **NEVER skip the reference** - The Python code IS the specification; trust it completely

**Debugging workflow**:
- Focus on ONE failing test at a time
- Generate trace comparison to see exact divergence point
- Read the Python reference implementation for that operation
- Compare our Zig code opcode-by-opcode or state change-by-state change
- Make minimal changes based on what the Python reference actually does
- Re-run test to verify fix
- If still failing, repeat with new trace divergence
</methodology>

<codebase_reference>
## Key Files and Their Responsibilities

| File | Primary Purpose | When to Modify |
|------|----------------|----------------|
| \`src/frame.zig\` | Opcode implementations, bytecode interpreter, stack/memory management | Fixing opcode logic, instruction behavior, gas metering per instruction |
| \`src/evm.zig\` | EVM orchestrator, call handling, storage, state transitions | Fixing CALL/CREATE behavior, storage access, account state, gas refunds |
| \`src/hardfork.zig\` | Hardfork detection and feature flags | Adding new hardfork support, fixing fork-specific activation |
| \`src/primitives/gas_constants.zig\` | Gas costs per operation and hardfork | Fixing gas cost errors, updating costs for new hardforks |
| \`src/host.zig\` | Host interface for external state access | Rarely modified (interface definition) |
| \`src/trace.zig\` | EIP-3155 tracing implementation | Only for debugging/tracing issues |
| \`src/opcode.zig\` | Opcode definitions and utilities | Adding new opcodes, updating opcode properties |
| \`test/specs/\` | Test infrastructure and runners | Only when changing test framework itself |

## Common Bug Patterns

1. **Gas Metering Bugs**:
   - Missing gas charges (e.g., forgetting memory expansion cost)
   - Wrong gas constants for hardfork
   - Incorrect warm/cold access tracking (EIP-2929)
   - Gas refund calculation errors (capped at 1/5 post-London)

2. **Hardfork Logic Bugs**:
   - Feature activated on wrong hardfork
   - Missing \`isAtLeast()\` checks
   - Incorrect feature flag precedence

3. **Opcode Implementation Bugs**:
   - Stack underflow/overflow not checked
   - Wrong arithmetic (e.g., modulo, signed operations)
   - Memory expansion not calculated correctly
   - Return data not handled properly

4. **State Management Bugs**:
   - Storage not persisted correctly
   - Transient storage not cleared properly (EIP-1153)
   - Balance transfers not atomic
   - Nonce increments missing or wrong

5. **Call/Create Bugs**:
   - Gas stipend not applied (2300 for value transfers)
   - Call depth not checked (max 1024)
   - Return data not copied back correctly
   - Revert not propagated properly
</codebase_reference>

<debugging_techniques>
## Advanced Debugging Strategies

### Strategy 1: Single Test Isolation ⭐ USE THE HELPER SCRIPT ⭐

**Recommended approach** - Use the test isolation helper:
\`\`\`bash
./scripts/isolate-test.sh "exact_failing_test_name"
\`\`\`

This helper script provides:
- Automatic test filtering
- Verbose trace output
- Failure type detection
- Divergence analysis
- Next-step guidance

**Manual approach** (if helper unavailable):
\`\`\`bash
TEST_FILTER="exact_failing_test_name" ${suite.command}
\`\`\`

### Strategy 2: Trace Comparison ⭐ PRIMARY DEBUGGING TOOL ⭐

**This should be your FIRST step for any failing test.**

For gas differences or behavior divergence:
1. The test runner **automatically generates both traces** (yours and Python reference)
2. It **automatically compares them step-by-step**
3. It **shows the exact divergence point** with:
   - Program counter (PC)
   - Opcode being executed
   - Gas remaining
   - Stack contents
   - Memory state
   - Storage changes

**Why this is critical**:
- Eliminates guesswork - you see EXACTLY where behavior differs
- Shows you which opcode or gas calculation is wrong
- Reveals the exact state (stack, memory, storage) at divergence
- Saves hours compared to reading code and guessing

**How to use it**:
\`\`\`bash
# Run the failing test - trace comparison happens automatically
TEST_FILTER="exact_test_name" ${suite.command}

# Look for output like:
# "Trace divergence at step N:"
# "PC: 42, Opcode: SSTORE"
# "Expected gas: 20000, Got: 22100"
# "Stack divergence: [...]"
\`\`\`

Once you see the divergence, read the Python reference for that specific opcode/operation.

### Strategy 3: Reference Implementation Comparison ⭐ REQUIRED FOR EVERY FIX ⭐

**NEVER skip this step. The Python code IS the specification.**

The official execution-specs Python implementation:
- Located in \`execution-specs/src/ethereum/forks/<hardfork>/\` submodule
- Contains the **authoritative, battle-tested** reference implementations
- Used by geth, nethermind, erigon, and all major clients
- If our code differs from Python, **we are wrong**

**How to use it**:
1. Identify the divergence point from trace comparison
2. Navigate to \`execution-specs/src/ethereum/forks/<hardfork>/\`
3. Find the relevant file:
   - Opcode logic: \`vm/instructions/*.py\`
   - Gas calculation: \`vm/gas.py\`
   - State changes: \`state.py\`
   - Interpreter loop: \`vm/interpreter.py\`
4. Read the Python function line-by-line
5. Compare with our Zig implementation
6. Adjust our code to match Python behavior EXACTLY

**Example**:
\`\`\`bash
# Trace shows SSTORE gas calculation is wrong at PC 42
# Navigate to:
cd execution-specs/src/ethereum/forks/cancun/vm/instructions/
# Read storage.py and find sstore() function
# Compare gas calculation with our src/frame.zig implementation
# Match the Python logic exactly
\`\`\`

### Strategy 4: Incremental Fixing
If many tests fail:
1. Group failures by similarity (same error type, same opcode)
2. Fix the most fundamental issue first (often a gas constant or missing check)
3. Re-run to see if it fixes multiple tests
4. Iterate on remaining failures

### Strategy 5: Gas Calculation Decomposition
For gas errors, trace the gas calculation step-by-step:
1. Base instruction cost
2. Memory expansion cost
3. Dynamic cost (e.g., SSTORE, CALL)
4. Warm/cold access cost (post-Berlin)
5. Gas refunds (check cap)

### Strategy 6: Crash Debugging (Systematic Approach)

⚠️ **CRITICAL**: Crash debugging requires a systematic, methodical approach. DO NOT guess, skip steps, or make assumptions. Crashes are often Zig-specific (memory safety, undefined behavior) and may not be obvious from Python reference code.

**Key Principles:**
- Crashes often swallow all output, including logs and debug prints
- DO NOT add logging to crashing code - it won't appear before the crash
- ALWAYS run crashing tests in complete isolation by themselves
- NEVER attempt to fix the bug until you know the EXACT line where it crashes
- Be methodical and patient - systematic debugging is faster than guessing

#### Step 1: Isolate the Crashing Test
**BEFORE ANYTHING ELSE**, run ONLY the crashing test:
\`\`\`bash
TEST_FILTER="exact_crashing_test_name" ${suite.command}
\`\`\`

This ensures:
- Faster iteration cycles
- No interference from other tests
- Clear, focused crash output

#### Step 2: Binary Search for Crash Location
Your ONLY goal is to find the exact line of code where the crash occurs.

**Method**: Use \`@panic("CHECKPOINT")\` as a binary search marker:

1. Add \`@panic("CHECKPOINT")\` halfway through the suspected code region
2. Run the test:
   - If you see "CHECKPOINT" panic → crash happens AFTER this line
   - If you see the original crash → crash happens BEFORE this line
3. Move the panic checkpoint and repeat
4. Continue binary search until you narrow it down to the exact line

**Example**:
\`\`\`zig
// Suspected region
line1();
line2();
@panic("CHECKPOINT");  // Add this
line3();
line4();
\`\`\`

Keep moving \`@panic("CHECKPOINT")\` until you identify the exact crashing line.

#### Step 3: Understand the Crash Type
Once you know WHERE it crashes, determine WHY:

**Common Zig crash types:**
- **Segmentation fault**: Invalid memory access (null pointer, out of bounds)
- **Integer overflow**: Arithmetic operation exceeded bounds (check \`@addWithOverflow\`, etc.)
- **Unreachable**: Code path marked unreachable was hit
- **Index out of bounds**: Array/slice access beyond length
- **Division by zero**: Self-explanatory
- **Stack overflow**: Recursion or excessive stack allocation

Read the crash message carefully to identify the type.

#### Step 4: Capture the Crashing Value
Now that you know the exact line, determine WHAT VALUE causes the crash:

1. **Add assertions BEFORE the crash line** to inspect values:
   \`\`\`zig
   std.debug.print("DEBUG: value = {}, len = {}\\n", .{value, slice.len});
   std.debug.assert(value < slice.len); // Will trigger with clear message
   const item = slice[value]; // This was crashing
   \`\`\`

2. **Temporarily convert crash to error return** (optional):
   - If you need to see more context, temporarily make it return an error
   - Pick a rarely-used error (e.g., \`error.TemporaryDebugError\`)
   - Add a comment: \`// TODO: TEMPORARY - Remove after debugging crash\`
   - This lets execution continue so you can see more state

#### Step 5: Add Preventive Assertions
Before fixing, add assertions that SHOULD have caught this:

\`\`\`zig
std.debug.assert(index < array.len); // Prevent out of bounds
std.debug.assert(denominator != 0);   // Prevent division by zero
std.debug.assert(ptr != null);        // Prevent null dereference
\`\`\`

These make future crashes easier to debug and document invariants.

#### Step 6: Fix the Root Cause
ONLY NOW should you fix the actual bug. Consider:

- **Bounds checking**: Add proper checks before array access
- **Null checking**: Verify pointers/optionals before dereferencing
- **Overflow handling**: Use checked arithmetic or validate ranges
- **Logic error**: Fix the algorithm if the crash reveals incorrect logic

**Zig-specific considerations:**
- Use \`@intCast\` carefully - can cause overflow crashes
- Check slice lengths before indexing
- Validate \`std.mem.readInt\` doesn't read past buffer end
- Ensure allocations succeeded before dereferencing

#### Step 7: Verify the Fix
After fixing:
1. Run the isolated test: \`TEST_FILTER="exact_test_name" ${suite.command}\`
2. Verify it passes
3. Run the full test suite to check for regressions
4. Remove any temporary debug code (search for "TODO: TEMPORARY")

#### Common Pitfalls to Avoid
❌ **DON'T** add \`std.debug.print\` at the crash site - output will be swallowed
❌ **DON'T** skip the binary search - guessing wastes time
❌ **DON'T** try to fix before knowing the exact crash line
❌ **DON'T** assume the Python reference shows the issue - this may be Zig-specific
❌ **DON'T** run multiple tests while debugging a crash - isolate it

✅ **DO** be systematic and methodical
✅ **DO** use binary search with \`@panic\`
✅ **DO** run tests in isolation
✅ **DO** add assertions to document invariants
✅ **DO** understand WHY before attempting to fix

</debugging_techniques>

<critical_reminders>
## Critical Rules - Do Not Violate

### Mandatory Process Rules (NEVER skip these):
1. ✅ **DO** generate and analyze trace comparison BEFORE making any changes
2. ✅ **DO** read the Python reference implementation for the diverging operation
3. ✅ **DO** compare your Zig code line-by-line with Python reference
4. ✅ **DO** trust the Python reference completely - if it differs from your intuition, the Python is correct

### Code Quality Rules:
5. ❌ **DO NOT** guess what the behavior should be - read traces and Python reference
6. ❌ **DO NOT** break existing passing tests - always verify your changes don't cause regressions
7. ❌ **DO NOT** hardcode test-specific logic - fix the underlying implementation
8. ❌ **DO NOT** skip hardfork checks - use proper \`isAtLeast()\` guards
9. ❌ **DO NOT** modify test files - only fix the implementation in \`src/\`
10. ✅ **DO** run the test command after every change to verify
11. ✅ **DO** make minimal, focused changes that directly address the failure
12. ✅ **DO** preserve backward compatibility with earlier hardforks
13. ✅ **DO** use the TodoWrite tool to track your progress through multiple test failures
14. ✅ **DO** read files before editing them to understand context
15. ✅ **DO** iterate if the first fix doesn't work - debugging is iterative

### The Golden Rule:
**Traces tell you WHERE the problem is. Python reference tells you WHAT the correct behavior is. Use both, always.**
</critical_reminders>

<output_requirements>
## Expected Final Report

At the end of your debugging session, provide a clear summary:

### Summary Structure:
\`\`\`markdown
## Root Cause Analysis
[Explain what was failing and why - be specific about the bug]

## Changes Made
[List each file modified and what was changed - be concise but complete]

## Test Results
[Confirm tests now pass, or explain remaining failures and next steps]

## Technical Details
[Any important implementation details, EIP references, or gotchas]
\`\`\`

### Quality Criteria:
- ✅ Root cause clearly identified and explained
- ✅ All changes necessary and sufficient (no more, no less)
- ✅ Test suite passes (or clear explanation of why not)
- ✅ No regressions introduced
- ✅ Changes are maintainable and follow codebase style
</output_requirements>

<execution_directive>
**Begin your analysis and fix now.**

Remember: You are an expert debugger. Be systematic, be thorough, and verify every change. The tests are correct - our implementation needs to match the specification.
</execution_directive>`;

    try {
      let totalCost = 0;
      let totalTurns = 0;
      let agentSuccess = false;

      const result = query({
        prompt,
        options: {
          model: "claude-sonnet-4-5-20250929",
          maxTurns: 500,
          permissionMode: "bypassPermissions",
          cwd: REPO_ROOT,
        },
      });

      // Stream agent output
      for await (const message of result) {
        if (message.type === "assistant") {
          const content = message.message.content;
          for (const block of content) {
            if (block.type === "text") {
              process.stdout.write(block.text);
            }
          }
        } else if (message.type === "result") {
          if (message.subtype === "success") {
            console.log(`\n\n✅ Agent completed`);
            console.log(`💰 Cost: $${message.total_cost_usd.toFixed(4)}`);
            console.log(`🔄 Turns: ${message.num_turns}`);
            totalCost = message.total_cost_usd;
            totalTurns = message.num_turns;
            agentSuccess = true;

            // Save agent report
            const reportPath = join(
              this.reportsDir,
              `${suite.name}-attempt${attemptNumber}.md`,
            );
            writeFileSync(reportPath, message.result, "utf-8");
            console.log(`📄 Report saved to: ${reportPath}`);
          } else {
            console.log(`\n\n⚠️  Agent did not complete successfully`);
            agentSuccess = false;
          }
        }
      }

      const duration = Date.now() - startTime;

      return {
        suite: suite.name,
        attempt: attemptNumber,
        success: agentSuccess,
        agentCost: totalCost,
        agentTurns: totalTurns,
        agentDuration: duration,
      };
    } catch (error) {
      const duration = Date.now() - startTime;
      console.error(`\n❌ Error running agent:`, error);

      return {
        suite: suite.name,
        attempt: attemptNumber,
        success: false,
        agentCost: 0,
        agentTurns: 0,
        agentDuration: duration,
        error: error instanceof Error ? error.message : String(error),
      };
    }
  }

  async commitWithAgent(suite: TestSuite): Promise<void> {
    console.log(`\n${"█".repeat(80)}`);
    console.log(`📝 Creating commit for: ${suite.name}`);
    console.log(`${"█".repeat(80)}\n`);

    const prompt = `<task>
The ${suite.description} test suite is now passing. Create a git commit for the changes that fixed these tests.
</task>

<context>
This commit represents a significant milestone - a previously failing test suite now passes, bringing us closer to full Ethereum specification compliance.
</context>

<instructions>
## Step 1: Review Changes
Use \`git status\` and \`git diff\` to understand:
- Which files were modified
- What specific changes were made
- The scope and nature of the fix

## Step 2: Craft Commit Message
Follow this structure:

**Format**: \`<type>: <description>\`

**Type Options**:
- \`fix\`: Bug fix in implementation (most common for test fixes)
- \`feat\`: New feature/opcode implementation
- \`perf\`: Performance improvement
- \`refactor\`: Code restructuring without behavior change

**Description Guidelines**:
- Start with "Pass ${suite.description}" or similar
- Mention specific EIP number if relevant (e.g., "EIP-1153", "EIP-3855")
- Mention hardfork if suite-specific (e.g., "Cancun", "Shanghai")
- Be specific about what was fixed (e.g., "Fix TSTORE gas calculation" not just "Fix gas")

**Examples**:
- \`fix: Pass Cancun EIP-1153 transient storage tests\`
- \`fix: Pass Shanghai EIP-3855 PUSH0 tests\`
- \`fix: Pass Istanbul hardfork tests - Fix SELFBALANCE and CHAINID opcodes\`
- \`fix: Pass Berlin EIP-2929 gas cost tests - Correct warm/cold access tracking\`

## Step 3: Include Body (if needed)
For complex fixes, add a commit body explaining:
- Root cause of the failure
- Key changes made
- Any important implementation details

Use the standard format:
\`\`\`
fix: Pass ${suite.description}

- Root cause: [brief explanation]
- Changes: [key changes]
- EIP: [EIP number and name if applicable]
\`\`\`

## Step 4: Create Commit
Use the standard commit format with co-author attribution.
</instructions>

<critical_reminders>
- ✅ **DO** be specific about what was fixed
- ✅ **DO** mention EIP numbers when relevant
- ✅ **DO** use conventional commit format (\`type: description\`)
- ✅ **DO** keep the first line under 72 characters
- ❌ **DO NOT** be vague (e.g., "fix tests")
- ❌ **DO NOT** forget to include the co-author line
- ❌ **DO NOT** commit unrelated changes
</critical_reminders>

<execution_directive>
Create the commit now using git commands.
</execution_directive>`;

    try {
      const result = query({
        prompt,
        options: {
          model: "claude-sonnet-4-5-20250929",
          maxTurns: 10,
          permissionMode: "bypassPermissions",
          cwd: REPO_ROOT,
        },
      });

      // Stream agent output
      for await (const message of result) {
        if (message.type === "assistant") {
          const content = message.message.content;
          for (const block of content) {
            if (block.type === "text") {
              process.stdout.write(block.text);
            }
          }
        } else if (message.type === "result") {
          if (message.subtype === "success") {
            console.log(`\n\n✅ Commit created successfully`);
          } else {
            console.log(`\n\n⚠️  Commit agent did not complete successfully`);
          }
        }
      }
    } catch (error) {
      console.error(`\n❌ Error creating commit:`, error);
    }
  }

  async processTestSuite(suite: TestSuite): Promise<boolean> {
    console.log(`\n${"█".repeat(80)}`);
    console.log(`📋 Processing: ${suite.name}`);
    console.log(`${"█".repeat(80)}`);

    let attemptNumber = 0;

    while (attemptNumber < this.maxAttemptsPerSuite) {
      attemptNumber++;

      // Run the test
      const testResult = this.runTest(suite);

      if (testResult.passed) {
        console.log(`✅ ${suite.name} - All tests passing!`);

        // Only commit if we made changes (attempt > 1 means we ran the agent)
        if (attemptNumber > 1) {
          await this.commitWithAgent(suite);
        } else {
          console.log(`ℹ️  Tests already passing on first run, skipping commit`);
        }

        return true;
      }

      console.log(`❌ ${suite.name} - Tests failing, launching agent fix...`);

      // Try to fix with agent
      const fixAttempt = await this.fixWithAgent(
        suite,
        testResult,
        attemptNumber,
      );
      this.fixAttempts.push(fixAttempt);

      if (!fixAttempt.success) {
        console.log(`⚠️  Agent did not complete successfully, retrying...`);
        continue;
      }

      // Loop will re-run the test to verify the fix
      console.log(`\n🔄 Re-running tests to verify fix...\n`);
    }

    console.log(
      `❌ ${suite.name} - Failed after ${this.maxAttemptsPerSuite} attempts`,
    );
    return false;
  }

  async runAll(): Promise<void> {
    console.log(`\n${"█".repeat(80)}`);
    console.log(`🎯 GUILLOTINE SPEC FIXER PIPELINE`);
    console.log(`${"█".repeat(80)}`);
    console.log(`Total Test Suites: ${TEST_SUITES.length}`);
    console.log(`Max Attempts Per Suite: ${this.maxAttemptsPerSuite}`);
    console.log(`${"█".repeat(80)}\n`);

    const pipelineStart = Date.now();
    const results: { suite: string; passed: boolean }[] = [];

    for (const suite of TEST_SUITES) {
      const passed = await this.processTestSuite(suite);
      results.push({ suite: suite.name, passed });

      if (!passed) {
        console.log(
          `\n⚠️  Continuing to next test suite despite failures in ${suite.name}...\n`,
        );
      }
    }

    const pipelineDuration = Date.now() - pipelineStart;

    // Final summary
    console.log(`\n${"█".repeat(80)}`);
    console.log(`🏁 PIPELINE COMPLETE`);
    console.log(`${"█".repeat(80)}`);

    const totalPassed = results.filter((r) => r.passed).length;
    const totalFailed = results.filter((r) => !r.passed).length;
    const totalCost = this.fixAttempts.reduce((sum, a) => sum + a.agentCost, 0);
    const totalAttempts = this.fixAttempts.length;

    console.log(`\n📊 Results:`);
    console.log(`  ✅ Passed: ${totalPassed}/${TEST_SUITES.length}`);
    console.log(`  ❌ Failed: ${totalFailed}/${TEST_SUITES.length}`);
    console.log(`  🤖 Agent Attempts: ${totalAttempts}`);
    console.log(`  💰 Total Cost: $${totalCost.toFixed(4)}`);
    console.log(
      `  ⏱️  Total Duration: ${(pipelineDuration / 1000 / 60).toFixed(1)} minutes`,
    );

    console.log(`\n📋 Detailed Results:`);
    for (const result of results) {
      const status = result.passed ? "✅" : "❌";
      console.log(`  ${status} ${result.suite}`);
    }

    // Save summary
    const summary = this.generateSummary(results, totalCost, pipelineDuration);
    const summaryPath = join(this.reportsDir, "pipeline-summary.md");
    writeFileSync(summaryPath, summary, "utf-8");
    console.log(`\n📊 Summary report: ${summaryPath}`);
    console.log(`${"█".repeat(80)}\n`);

    // Run AI narrative summary at the very end
    try {
      await this.generateAISummaryFromReports(results, totalCost, pipelineDuration);
    } catch (err) {
      console.error("❌ AI summary generation failed:", err);
    }
  }

  generateSummary(
    results: { suite: string; passed: boolean }[],
    totalCost: number,
    duration: number,
  ): string {
    const passed = results.filter((r) => r.passed);
    const failed = results.filter((r) => !r.passed);

    let summary = `# Guillotine Spec Fixer Pipeline - Summary Report

**Generated**: ${new Date().toISOString()}

## Overview

- **Total Test Suites**: ${results.length}
- **Passed**: ${passed.length}
- **Failed**: ${failed.length}
- **Total Agent Attempts**: ${this.fixAttempts.length}
- **Total Cost**: $${totalCost.toFixed(4)}
- **Total Duration**: ${(duration / 1000 / 60).toFixed(1)} minutes

## Test Suite Results

### ✅ Passed (${passed.length})

`;

    for (const result of passed) {
      summary += `- ${result.suite}\n`;
    }

    if (failed.length > 0) {
      summary += `\n### ❌ Failed (${failed.length})\n\n`;
      for (const result of failed) {
        summary += `- ${result.suite}\n`;
      }
    }

    summary += `\n## Agent Fix Attempts

| Suite | Attempt | Success | Cost | Turns | Duration |
|-------|---------|---------|------|-------|----------|
`;

    for (const attempt of this.fixAttempts) {
      const status = attempt.success ? "✅" : "❌";
      summary += `| ${attempt.suite} | ${attempt.attempt} | ${status} | $${attempt.agentCost.toFixed(4)} | ${attempt.agentTurns} | ${(attempt.agentDuration / 1000).toFixed(1)}s |\n`;
    }

    summary += `\n## Next Steps

`;

    if (failed.length > 0) {
      summary += `1. Review failed test suites and agent reports\n`;
      summary += `2. Manually investigate remaining failures\n`;
      summary += `3. Consider increasing maxTurns or maxAttempts for complex fixes\n`;
    } else {
      summary += `🎉 All test suites passing! Great work!\n`;
    }

    return summary;
  }

  // New: AI narrative summary at the very end of the pipeline
  private async generateAISummaryFromReports(
    results: { suite: string; passed: boolean }[],
    totalCost: number,
    durationMs: number,
  ): Promise<void> {
    console.log(`\n${"█".repeat(80)}`);
    console.log("🧠 Generating AI narrative summary (3–4 paragraphs)...");
    console.log(`${"█".repeat(80)}`);

    const pipelineSummaryPath = join(this.reportsDir, "pipeline-summary.md");
    const pipelineSummary = existsSync(pipelineSummaryPath)
      ? readFileSync(pipelineSummaryPath, "utf-8")
      : "";

    // Collect latest attempt report per suite (if available), truncated to keep prompt reasonable
    let attemptBundle = "";
    try {
      const files = readdirSync(this.reportsDir).filter((f) => f.endsWith(".md"));
      const bySuite: Record<string, { attempt: number; file: string }> = {};

      for (const r of results) {
        const prefix = `${r.suite}-attempt`;
        for (const f of files) {
          if (f.startsWith(prefix)) {
            const m = f.match(/attempt(\d+)\.md$/);
            const n = m ? parseInt(m[1], 10) : 0;
            if (!bySuite[r.suite] || n > bySuite[r.suite].attempt) {
              bySuite[r.suite] = { attempt: n, file: f };
            }
          }
        }
      }

      for (const [suite, meta] of Object.entries(bySuite)) {
        const fullPath = join(this.reportsDir, meta.file);
        if (!existsSync(fullPath)) continue;
        const content = readFileSync(fullPath, "utf-8");
        attemptBundle += `\n\n<attempt suite=\"${suite}\" file=\"${meta.file}\">\n`;
        attemptBundle += truncate(content, 20 * 1024); // 20KB per attempt
        attemptBundle += `\n</attempt>`;
      }
    } catch (_) {
      // Non-fatal; continue with whatever we have
    }

    const prompt = `
<task>
Read the pipeline summary and latest attempt reports, then write a concise narrative summary (3–4 paragraphs) of what happened in this spec-fixing run.
</task>

<audience>
Senior engineers and stakeholders tracking progress toward Ethereum execution-spec compliance.
</audience>

<style>
- Narrative prose, no bullet lists.
- 3–4 paragraphs, 250–500 words.
- Cover goals, what was attempted, key outcomes, notable blockers, and pragmatic next steps.
- Avoid code blocks; keep it readable and high level.
</style>

<context>
Total cost: $${totalCost.toFixed(4)}; Duration: ${(durationMs / 60000).toFixed(1)} minutes.
</context>

<pipeline_summary>
${truncate(pipelineSummary || "(no pipeline summary found)", 60 * 1024)}
</pipeline_summary>

<attempt_reports>
${attemptBundle || "(no attempt reports found)"}
</attempt_reports>

<output_requirements>
Only return the 3–4 paragraph narrative. Do not include headings, lists, or extraneous commentary.
</output_requirements>
`;

    try {
      const result = query({
        prompt,
        options: {
          model: "claude-sonnet-4-5-20250929",
          maxTurns: 3,
          permissionMode: "bypassPermissions",
          cwd: REPO_ROOT,
        },
      });

      let narrative = "";
      for await (const message of result) {
        if (message.type === "assistant") {
          const content = message.message.content;
          for (const block of content) {
            if (block.type === "text") {
              process.stdout.write(block.text);
              narrative += block.text;
            }
          }
        }
      }

      const outPath = join(this.reportsDir, "pipeline-summary-ai.md");
      writeFileSync(outPath, narrative.trim(), "utf-8");
      console.log(`\n\n📝 AI summary saved to: ${outPath}`);
    } catch (err) {
      console.error("Failed to run AI summary:", err);
    }
  }

  async runSingleSuite(suiteName: string): Promise<void> {
    const suite = TEST_SUITES.find((s) => s.name === suiteName);
    if (!suite) {
      console.error(`❌ Test suite '${suiteName}' not found`);
      console.log(`\nAvailable suites:`);
      for (const s of TEST_SUITES) {
        console.log(`  - ${s.name}: ${s.description}`);
      }
      return;
    }

    const passed = await this.processTestSuite(suite);

    console.log(`\n${"█".repeat(80)}`);
    if (passed) {
      console.log(`✅ ${suite.name} - All tests passing!`);
    } else {
      console.log(
        `❌ ${suite.name} - Tests still failing after ${this.maxAttemptsPerSuite} attempts`,
      );
    }
    console.log(`${"█".repeat(80)}\n`);
  }
}

// Helper: truncate long text safely
function truncate(text: string, maxBytes: number): string {
  // Simple truncation by code units is acceptable for markdown inputs
  if (Buffer.byteLength(text, "utf8") <= maxBytes) return text;
  let truncated = text;
  while (Buffer.byteLength(truncated, "utf8") > maxBytes) {
    truncated = truncated.slice(0, Math.floor(truncated.length * 0.95));
  }
  return truncated + "\n\n[...truncated for brevity...]";
}

// Extend pipeline with AI summarization

// CLI
async function main() {
  const args = process.argv.slice(2);
  const pipeline = new SpecFixerPipeline();

  if (args.length === 0) {
    // Run all test suites
    await pipeline.runAll();
  } else if (args[0] === "suite" && args[1]) {
    // Run specific test suite
    await pipeline.runSingleSuite(args[1]);
  } else {
    console.log(`
Guillotine Spec Fixer Pipeline

Usage:
  bun run scripts/fix-specs.ts              # Run all test suites
  bun run scripts/fix-specs.ts suite <name> # Run specific test suite

Available test suites:
${TEST_SUITES.map((s) => `  ${s.name.padEnd(25)} - ${s.description}`).join("\n")}

Examples:
  bun run scripts/fix-specs.ts suite cancun
  bun run scripts/fix-specs.ts suite shanghai-push0
    `);
  }
}

main().catch(console.error);
