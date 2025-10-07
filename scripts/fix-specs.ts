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
  { name: 'shanghai-initcode', command: 'zig build specs-shanghai-initcode', description: 'Shanghai EIP-3860 initcode tests' },
  { name: 'shanghai-warmcoinbase', command: 'zig build specs-shanghai-warmcoinbase', description: 'Shanghai EIP-3651 warm coinbase tests' },
  { name: 'shanghai-push0', command: 'zig build specs-shanghai-push0', description: 'Shanghai EIP-3855 PUSH0 tests' },
  { name: 'berlin-accesslist', command: 'zig build specs-berlin-accesslist', description: 'Berlin EIP-2930 access list tests' },
  { name: 'berlin-gas', command: 'zig build specs-berlin-gas', description: 'Berlin EIP-2929 gas cost tests' },
  { name: 'cancun-beacon', command: 'zig build specs-cancun-beacon', description: 'Cancun EIP-4788 beacon root tests' },
  { name: 'cancun-selfdestruct', command: 'zig build specs-cancun-selfdestruct', description: 'Cancun EIP-6780 SELFDESTRUCT tests' },
  { name: 'cancun-mcopy', command: 'zig build specs-cancun-mcopy', description: 'Cancun EIP-5656 MCOPY tests' },
  { name: 'cancun-blobs', command: 'zig build specs-cancun-blobs', description: 'Cancun EIP-4844 blob transaction tests' },
  { name: 'cancun-tstore', command: 'zig build specs-cancun-tstore', description: 'Cancun EIP-1153 transient storage tests' },
  { name: 'osaka', command: 'zig build specs-osaka', description: 'Osaka hardfork tests' },
  { name: 'prague', command: 'zig build specs-prague', description: 'Prague hardfork tests' },
  { name: 'cancun', command: 'zig build specs-cancun', description: 'Cancun hardfork tests (EIP-1153, EIP-4788, EIP-4844, EIP-5656, EIP-6780, EIP-7516)' },
  { name: 'shanghai', command: 'zig build specs-shanghai', description: 'Shanghai hardfork tests (EIP-3651, EIP-3855, EIP-3860, EIP-4895)' },
  { name: 'paris', command: 'zig build specs-paris', description: 'Paris/Merge hardfork tests' },
  { name: 'berlin', command: 'zig build specs-berlin', description: 'Berlin hardfork tests (EIP-2929, EIP-2930)' },
  { name: 'istanbul', command: 'zig build specs-istanbul', description: 'Istanbul hardfork tests' },
  { name: 'constantinople', command: 'zig build specs-constantinople', description: 'Constantinople hardfork tests' },
  { name: 'byzantium', command: 'zig build specs-byzantium', description: 'Byzantium hardfork tests' },
  { name: 'homestead', command: 'zig build specs-homestead', description: 'Homestead hardfork tests' },
  { name: 'frontier', command: 'zig build specs-frontier', description: 'Frontier hardfork tests' },
  { name: 'shanghai-withdrawals', command: 'zig build specs-shanghai-withdrawals', description: 'Shanghai EIP-4895 withdrawal tests' },
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

\`\`\`
${testResult.output}
${testResult.error || ''}
\`\`\`

## Your Task

1. **Analyze the test failures**: Understand what tests are failing and why
2. **Read relevant source code**: Use the Read tool to examine the EVM implementation in src/
3. **Identify the root cause**: Determine what's wrong with the implementation
4. **Fix the issue**: Edit the source files to fix the bug(s)
5. **Verify the fix**: Run the test suite again to confirm it passes

## Important Guidelines

- Focus on fixing the SPECIFIC failures shown above
- Read the implementation files in src/ (frame.zig, evm.zig, etc.)
- Check the hardfork-specific logic in src/hardfork.zig
- Review gas metering in src/primitives/gas_constants.zig if gas-related
- Look at opcode implementations in src/frame.zig
- Consider EIP compliance requirements
- After making changes, run the test command to verify the fix: \`${suite.command}\`
- If tests still fail after your fix, analyze the new output and iterate

## Codebase Structure

- \`src/frame.zig\`: Opcode implementations and bytecode interpreter
- \`src/evm.zig\`: EVM orchestrator (state, calls, creates)
- \`src/hardfork.zig\`: Hardfork detection and feature flags
- \`src/primitives/gas_constants.zig\`: Gas costs per operation
- \`src/host.zig\`: Host interface for state access
- \`src/trace.zig\`: EIP-3155 tracing
- \`test/specs/\`: Test infrastructure

## Debugging tips

The official specs has a python reference implementation for every hardfork. Comparing and looking at the reference implementation is a good way to find inconsistencies between ours and theirs.
You can filter for specific tests. I recomend filtering for a single failing test and debugging 1 at a time.
If you got a gas difference it's worth trying to look at a trace. The python cli in the ethereum specs submodule has the ability to produce a JSON trace. By producing a trace between both our evm and the official python evm you can compare

## Expected Output

Provide a summary of:
1. What was failing and why
2. What you changed to fix it
3. Confirmation that tests now pass (or explanation if they don't)

Begin your analysis and fix now.`;

    try {
      let totalCost = 0;
      let totalTurns = 0;
      let agentSuccess = false;

      const result = query({
        prompt,
        options: {
          model: 'claude-sonnet-4-5-20250929',
          maxTurns: 150,
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
