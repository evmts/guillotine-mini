import { query } from '@anthropic-ai/claude-agent-sdk';
import { execSync } from 'child_process';
import { writeFileSync, mkdirSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

// Get repo root
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const REPO_ROOT = join(__dirname, '..');

// Test suite configuration
interface TestSuite {
  name: string;
  command: string;
  description: string;
}

const TEST_SUITES: TestSuite[] = [
  // These pass (commented out)
  // { name: 'paris', command: 'zig build specs-paris', description: 'Paris/Merge hardfork tests' },
  // { name: 'homestead', command: 'zig build specs-homestead', description: 'Homestead hardfork tests' },
  // { name: 'shanghai-withdrawals', command: 'zig build specs-shanghai-withdrawals', description: 'Shanghai EIP-4895 withdrawal tests' },
  // { name: 'shanghai-push0', command: 'zig build specs-shanghai-push0', description: 'Shanghai EIP-3855 PUSH0 tests' },

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
  { name: 'constantinople', command: 'zig build specs-constantinople', description: 'Constantinople hardfork tests' },
  { name: 'istanbul', command: 'zig build specs-istanbul', description: 'Istanbul hardfork tests' },
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
  private reportsDir = join(REPO_ROOT, 'reports', 'spec-fixes');
  private maxAttemptsPerSuite = 5;
  private fixAttempts: FixAttempt[] = [];

  constructor() {
    if (!existsSync(this.reportsDir)) {
      mkdirSync(this.reportsDir, { recursive: true });
    }
  }

  runTest(suite: TestSuite): TestResult {
    console.log(`\n${'='.repeat(80)}`);
    console.log(`🧪 Running: ${suite.description}`);
    console.log(`${'='.repeat(80)}`);
    console.log(`Command: ${suite.command}\n`);

    try {
      const output = execSync(suite.command, {
        cwd: REPO_ROOT,
        encoding: 'utf-8',
        stdio: 'pipe',
        maxBuffer: 10 * 1024 * 1024, // 10MB buffer
      });

      console.log('✅ Tests passed!\n');
      return {
        suite: suite.name,
        passed: true,
        output,
      };
    } catch (error: any) {
      const output = error.stdout || '';
      const errorOutput = error.stderr || '';
      console.log('❌ Tests failed\n');

      return {
        suite: suite.name,
        passed: false,
        output,
        error: errorOutput,
      };
    }
  }

  async fixWithAgent(suite: TestSuite, testResult: TestResult, attemptNumber: number): Promise<FixAttempt> {
    console.log(`\n${'█'.repeat(80)}`);
    console.log(`🤖 Starting Agent Fix - Attempt ${attemptNumber}/${this.maxAttemptsPerSuite}`);
    console.log(`Suite: ${suite.description}`);
    console.log(`${'█'.repeat(80)}\n`);

    const startTime = Date.now();

    const prompt = `<task>
Your goal is to make our EVM ethereum spec compliant by passing the execution tests.

You are an expert EVM implementation debugger tasked with fixing failing Ethereum specification tests.
</task>

<context>
The ethereum specification tests are the official tests we are using as a submodule. They are battle-hardened and used by every major EVM implementation (geth, erigon, nethermind, etc.), so we know they are authoritative.

## Test Suite Information

**Test Suite**: ${suite.description}
**Command**: \`${suite.command}\`
**Hardfork Context**: This test suite targets specific hardfork rules and EIP requirements that must be satisfied.
</context>

<test_failure_output>
The test failures will appear below. Pay careful attention to:
- Which specific tests are failing (test names often indicate what they're testing)
- Gas differences (actual vs expected gas usage)
- State differences (storage, balances, nonces, code)
- Return values or revert reasons
- Trace divergence points (if available)

## Test Failure Output

[Test output will be provided here]
</test_failure_output>

<methodology>
Follow this systematic debugging approach:

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
1. **Use targeted file reading**: Based on the failure type, read the most relevant files first
2. **Check hardfork activation**: Verify the feature is enabled for the correct hardfork using \`hardfork.isAtLeast()\`
3. **Review EIP specifications**: If the test relates to a specific EIP, ensure our implementation matches the spec
4. **Compare with Python reference implementation**:
   - Location: \`execution-specs/src/ethereum/forks/<hardfork>/\`
   - Opcode implementations: \`vm/instructions/\`
   - Main interpreter: \`vm/interpreter.py\`
   - Gas metering: \`vm/gas.py\`
   - State management: \`state.py\`

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
- Focus on ONE failing test at a time
- **Think hard about what the behavior SHOULD be** based on the reference implementation
- Compare opcode-by-opcode or state change-by-state change with the Python reference
- After making changes, run the test command to verify
- If tests still fail, analyze the new output and iterate
- Use traces to pinpoint the exact divergence point
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

### Strategy 1: Single Test Isolation
If multiple tests fail, filter to ONE failing test for focused debugging:
\`\`\`bash
TEST_FILTER="exact_failing_test_name" ${suite.command}
\`\`\`

### Strategy 2: Trace Comparison
For gas differences or behavior divergence:
1. Generate our EVM trace (EIP-3155 format)
2. Generate reference Python EVM trace
3. Compare step-by-step to find exact divergence point

The test runner automatically does this for you and shows the divergence point.

### Strategy 3: Reference Implementation Comparison
Check the official execution-specs Python implementation:
- Located in \`execution-specs/\` submodule
- Contains reference implementations for all hardforks
- Look for the equivalent opcode/function and compare logic

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
</debugging_techniques>

<critical_reminders>
## Critical Rules - Do Not Violate

1. ❌ **DO NOT** break existing passing tests - always verify your changes don't cause regressions
2. ❌ **DO NOT** hardcode test-specific logic - fix the underlying implementation
3. ❌ **DO NOT** skip hardfork checks - use proper \`isAtLeast()\` guards
4. ❌ **DO NOT** modify test files - only fix the implementation in \`src/\`
5. ✅ **DO** run the test command after every change to verify
6. ✅ **DO** make minimal, focused changes that directly address the failure
7. ✅ **DO** preserve backward compatibility with earlier hardforks
8. ✅ **DO** use the TodoWrite tool to track your progress through multiple test failures
9. ✅ **DO** read files before editing them to understand context
10. ✅ **DO** iterate if the first fix doesn't work - debugging is iterative
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
          model: 'claude-sonnet-4-5-20250929',
          maxTurns: 500,
          permissionMode: 'bypassPermissions',
          cwd: REPO_ROOT,
        }
      });

      // Stream agent output
      for await (const message of result) {
        if (message.type === 'assistant') {
          const content = message.message.content;
          for (const block of content) {
            if (block.type === 'text') {
              process.stdout.write(block.text);
            }
          }
        } else if (message.type === 'result') {
          if (message.subtype === 'success') {
            console.log(`\n\n✅ Agent completed`);
            console.log(`💰 Cost: $${message.total_cost_usd.toFixed(4)}`);
            console.log(`🔄 Turns: ${message.num_turns}`);
            totalCost = message.total_cost_usd;
            totalTurns = message.num_turns;
            agentSuccess = true;

            // Save agent report
            const reportPath = join(this.reportsDir, `${suite.name}-attempt${attemptNumber}.md`);
            writeFileSync(reportPath, message.result, 'utf-8');
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
    console.log(`\n${'█'.repeat(80)}`);
    console.log(`📝 Creating commit for: ${suite.name}`);
    console.log(`${'█'.repeat(80)}\n`);

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
          model: 'claude-sonnet-4-5-20250929',
          maxTurns: 10,
          permissionMode: 'bypassPermissions',
          cwd: REPO_ROOT,
        }
      });

      // Stream agent output
      for await (const message of result) {
        if (message.type === 'assistant') {
          const content = message.message.content;
          for (const block of content) {
            if (block.type === 'text') {
              process.stdout.write(block.text);
            }
          }
        } else if (message.type === 'result') {
          if (message.subtype === 'success') {
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
    console.log(`\n${'█'.repeat(80)}`);
    console.log(`📋 Processing: ${suite.name}`);
    console.log(`${'█'.repeat(80)}`);

    let attemptNumber = 0;

    while (attemptNumber < this.maxAttemptsPerSuite) {
      attemptNumber++;

      // Run the test
      const testResult = this.runTest(suite);

      if (testResult.passed) {
        console.log(`✅ ${suite.name} - All tests passing!`);

        // Commit the changes
        await this.commitWithAgent(suite);

        return true;
      }

      console.log(`❌ ${suite.name} - Tests failing, launching agent fix...`);

      // Try to fix with agent
      const fixAttempt = await this.fixWithAgent(suite, testResult, attemptNumber);
      this.fixAttempts.push(fixAttempt);

      if (!fixAttempt.success) {
        console.log(`⚠️  Agent did not complete successfully, retrying...`);
        continue;
      }

      // Loop will re-run the test to verify the fix
      console.log(`\n🔄 Re-running tests to verify fix...\n`);
    }

    console.log(`❌ ${suite.name} - Failed after ${this.maxAttemptsPerSuite} attempts`);
    return false;
  }

  async runAll(): Promise<void> {
    console.log(`\n${'█'.repeat(80)}`);
    console.log(`🎯 GUILLOTINE SPEC FIXER PIPELINE`);
    console.log(`${'█'.repeat(80)}`);
    console.log(`Total Test Suites: ${TEST_SUITES.length}`);
    console.log(`Max Attempts Per Suite: ${this.maxAttemptsPerSuite}`);
    console.log(`${'█'.repeat(80)}\n`);

    const pipelineStart = Date.now();
    const results: { suite: string; passed: boolean }[] = [];

    for (const suite of TEST_SUITES) {
      const passed = await this.processTestSuite(suite);
      results.push({ suite: suite.name, passed });

      if (!passed) {
        console.log(`\n⚠️  Continuing to next test suite despite failures in ${suite.name}...\n`);
      }
    }

    const pipelineDuration = Date.now() - pipelineStart;

    // Final summary
    console.log(`\n${'█'.repeat(80)}`);
    console.log(`🏁 PIPELINE COMPLETE`);
    console.log(`${'█'.repeat(80)}`);

    const totalPassed = results.filter(r => r.passed).length;
    const totalFailed = results.filter(r => !r.passed).length;
    const totalCost = this.fixAttempts.reduce((sum, a) => sum + a.agentCost, 0);
    const totalAttempts = this.fixAttempts.length;

    console.log(`\n📊 Results:`);
    console.log(`  ✅ Passed: ${totalPassed}/${TEST_SUITES.length}`);
    console.log(`  ❌ Failed: ${totalFailed}/${TEST_SUITES.length}`);
    console.log(`  🤖 Agent Attempts: ${totalAttempts}`);
    console.log(`  💰 Total Cost: $${totalCost.toFixed(4)}`);
    console.log(`  ⏱️  Total Duration: ${(pipelineDuration / 1000 / 60).toFixed(1)} minutes`);

    console.log(`\n📋 Detailed Results:`);
    for (const result of results) {
      const status = result.passed ? '✅' : '❌';
      console.log(`  ${status} ${result.suite}`);
    }

    // Save summary
    const summary = this.generateSummary(results, totalCost, pipelineDuration);
    const summaryPath = join(this.reportsDir, 'pipeline-summary.md');
    writeFileSync(summaryPath, summary, 'utf-8');
    console.log(`\n📊 Summary report: ${summaryPath}`);
    console.log(`${'█'.repeat(80)}\n`);
  }

  generateSummary(results: { suite: string; passed: boolean }[], totalCost: number, duration: number): string {
    const passed = results.filter(r => r.passed);
    const failed = results.filter(r => !r.passed);

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
      const status = attempt.success ? '✅' : '❌';
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

  async runSingleSuite(suiteName: string): Promise<void> {
    const suite = TEST_SUITES.find(s => s.name === suiteName);
    if (!suite) {
      console.error(`❌ Test suite '${suiteName}' not found`);
      console.log(`\nAvailable suites:`);
      for (const s of TEST_SUITES) {
        console.log(`  - ${s.name}: ${s.description}`);
      }
      return;
    }

    const passed = await this.processTestSuite(suite);

    console.log(`\n${'█'.repeat(80)}`);
    if (passed) {
      console.log(`✅ ${suite.name} - All tests passing!`);
    } else {
      console.log(`❌ ${suite.name} - Tests still failing after ${this.maxAttemptsPerSuite} attempts`);
    }
    console.log(`${'█'.repeat(80)}\n`);
  }
}

// CLI
async function main() {
  const args = process.argv.slice(2);
  const pipeline = new SpecFixerPipeline();

  if (args.length === 0) {
    // Run all test suites
    await pipeline.runAll();
  } else if (args[0] === 'suite' && args[1]) {
    // Run specific test suite
    await pipeline.runSingleSuite(args[1]);
  } else {
    console.log(`
Guillotine Spec Fixer Pipeline

Usage:
  bun run scripts/fix-specs.ts              # Run all test suites
  bun run scripts/fix-specs.ts suite <name> # Run specific test suite

Available test suites:
${TEST_SUITES.map(s => `  ${s.name.padEnd(25)} - ${s.description}`).join('\n')}

Examples:
  bun run scripts/fix-specs.ts suite cancun
  bun run scripts/fix-specs.ts suite shanghai-push0
    `);
  }
}

main().catch(console.error);
