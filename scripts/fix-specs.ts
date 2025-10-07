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
  private maxAttemptsPerSuite = 3;
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

    const prompt = `You are an expert EVM implementation debugger. Your task is to fix failing Ethereum specification tests.

## Test Suite Information

**Test Suite**: ${suite.description}
**Command**: ${suite.command}

## Test Failure Output

## Your Task

1. **Analyze the test failures**: Understand what tests are failing and why
2. **Understand the failure type**: Is it a poststate mismatch? Gas difference? Return data issue?
3. **Read relevant source code**: Use the Read tool to examine the EVM implementation in src/
4. **Compare with Python reference**: Look at the execution-specs reference implementation
5. **Identify the root cause**: Determine what's wrong with the implementation
6. **Fix the issue**: Edit the source files to fix the bug(s)
7. **Verify the fix**: Run the test suite again to confirm it passes

## Debugging Strategy

**Step 1: Understand WHY it's failing**
- Is the poststate (storage, balance, nonce) incorrect?
- Is the gas consumption wrong?
- Is the return data different?
- Is there an exception that shouldn't happen (or vice versa)?

**Step 2: Read our implementation**
- Read the relevant code in \`src/frame.zig\` (opcode implementations)
- Check \`src/evm.zig\` for state management and call handling
- Review \`src/primitives/gas_constants.zig\` for gas costs

**Step 3: Compare with Python reference implementation**

The Python reference implementations are in the execution-specs submodule:
- **Location**: \`execution-specs/src/ethereum/forks/<hardfork>/\`
- **Example paths**:
  - \`execution-specs/src/ethereum/forks/cancun/vm/instructions/\` - Opcode implementations
  - \`execution-specs/src/ethereum/forks/cancun/vm/interpreter.py\` - Main interpreter
  - \`execution-specs/src/ethereum/forks/cancun/vm/gas.py\` - Gas metering
  - \`execution-specs/src/ethereum/forks/cancun/fork.py\` - State transition logic
  - \`execution-specs/src/ethereum/forks/cancun/state.py\` - State management

Available hardforks in execution-specs:
- frontier, homestead, byzantium, constantinople, istanbul
- berlin, london, paris, shanghai, cancun, prague, osaka

**Step 4: Use tracing when needed**

If you have a gas difference or need to see step-by-step execution, use the Python reference implementation's trace feature:

\`\`\`bash
cd execution-specs
uv run -m ethereum_spec_tools.evm_tools t8n \\
  --input.alloc <alloc.json> \\
  --input.env <env.json> \\
  --input.txs <txs.json> \\
  --state.fork <Cancun|Berlin|etc> \\
  --trace \\
  --trace.memory \\
  --trace.returndata
\`\`\`

This produces an EIP-3155 compatible trace that you can compare with our trace output.

**Step 5: Filter to a single test**

Don't try to fix all failures at once. Filter to ONE failing test:
\`\`\`bash
TEST_FILTER="exact_test_name" ${suite.command}
\`\`\`

## Codebase Structure

**Our implementation**:
- \`src/frame.zig\`: Opcode implementations and bytecode interpreter
- \`src/evm.zig\`: EVM orchestrator (state, calls, creates)
- \`src/hardfork.zig\`: Hardfork detection and feature flags
- \`src/primitives/gas_constants.zig\`: Gas costs per operation
- \`src/host.zig\`: Host interface for state access
- \`src/trace.zig\`: EIP-3155 tracing

**Python reference** (execution-specs):
- \`execution-specs/src/ethereum/forks/<hardfork>/vm/\`: VM implementation
- \`execution-specs/src/ethereum/forks/<hardfork>/vm/instructions/\`: Opcodes
- \`execution-specs/src/ethereum/forks/<hardfork>/vm/interpreter.py\`: Main loop
- \`execution-specs/src/ethereum/forks/<hardfork>/vm/gas.py\`: Gas metering
- \`execution-specs/src/ethereum/forks/<hardfork>/state.py\`: State management

## Important Guidelines

- Focus on ONE failing test at a time
- **Think hard about what the behavior SHOULD be** based on the reference implementation
- Compare opcode-by-opcode or state change-by-state change with the Python reference
- After making changes, run the test command to verify: \`${suite.command}\`
- If tests still fail, analyze the new output and iterate
- Use traces to pinpoint the exact divergence point

## Expected Output

Provide a summary of:
1. What was failing and why (be specific: poststate? gas? exception?)
2. What the Python reference does differently
3. What you changed to fix it
4. Confirmation that tests now pass (or explanation if they don't)

Begin your analysis and fix now.`;

    try {
      let totalCost = 0;
      let totalTurns = 0;
      let agentSuccess = false;

      const result = query({
        prompt,
        options: {
          model: 'claude-sonnet-4-5-20250929',
          maxTurns: 300,
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

    const prompt = `The ${suite.description} test suite is now passing. Please create a git commit for the changes that fixed these tests.

Your task:
1. Review what files were changed using git status and git diff
2. Create a descriptive commit message that explains what was fixed
3. Commit the changes with an appropriate message

The commit message should:
- Clearly indicate which test suite is now passing
- Mention the hardfork or EIP if relevant
- Be concise but informative

Example format: "fix: Pass ${suite.description}"

Create the commit now.`;

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
