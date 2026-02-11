import type { TestSuite } from "../suites";

interface FixPromptOptions {
  suite: TestSuite;
  testOutput: string;
  knownIssueContext: string;
  previousFixAttempt: string | null;
}

export function buildFixPrompt(opts: FixPromptOptions): string {
  const { suite, testOutput, knownIssueContext, previousFixAttempt } = opts;

  return `<task>
Fix the failing tests in ${suite.description}.
Command: \`${suite.command}\`
</task>

${knownIssueContext}

${previousFixAttempt ? `
<previous_attempt>
A previous fix attempt was made but tests still fail. Here is what was tried:
${previousFixAttempt}
Do NOT repeat the same approach. Try a different strategy.
</previous_attempt>
` : ""}

<test_output>
${testOutput.slice(0, 50000)}
</test_output>

<context>
You're debugging an EVM implementation in Zig. The goal is to make all tests pass by fixing bugs in the implementation.

**Key resources:**
- **Trace analysis**: \`bun scripts/isolate-test.ts "test_name"\` - Shows exact divergence point (PC, opcode, gas, stack)
- **Python reference**: \`execution-specs/src/ethereum/forks/<hardfork>/\` - The authoritative spec (if Zig differs from Python, Zig is wrong)
- **Zig implementation**: \`src/frame.zig\` (opcodes), \`src/evm.zig\` (calls, storage, state)

**Common patterns:**
- Gas divergence -> Check gas calculation order, warm/cold tracking, missing charges
- Stack/memory divergence -> Check pop/push order, memory expansion cost
- Crashes -> Use binary search with panics to isolate exact line

**File mappings:**
| Issue Type | Python Location | Zig Location |
|------------|----------------|--------------|
| Opcodes | forks/<fork>/vm/instructions/*.py | src/frame.zig |
| Gas costs | forks/<fork>/vm/gas.py | src/primitives/gas_constants.zig + src/frame.zig |
| CALL/CREATE | forks/<fork>/vm/instructions/system.py | src/evm.zig (inner_call, inner_create) |
| Storage | forks/<fork>/vm/instructions/storage.py | src/evm.zig (get/set storage) |

**Debugging commands:**
\`\`\`bash
bun scripts/isolate-test.ts "test_name"  # Detailed trace + divergence analysis
TEST_FILTER="test_name" ${suite.command}  # Run single test
\`\`\`
</context>

<guidelines>
- Use trace comparison to identify exact divergence point
- Check Python reference implementation for correct behavior
- Make minimal, targeted fixes
- Use \`hardfork.isAtLeast()\` guards for fork-specific behavior
- Verify fixes by re-running tests
- If a fix doesn't work, analyze the new failure and iterate
</guidelines>

<execution_directive>
Fix the failing tests. Use your judgment on the best approach - trace analysis is usually the fastest path to identifying issues.
</execution_directive>

<output_format>
When done, you MUST end your response with this exact JSON structure:
\`\`\`json
{
  "success": true,
  "whatWasFixed": "Description of what was fixed",
  "filesModified": ["src/file1.zig", "src/file2.zig"]
}
\`\`\`
Set success=true if you believe the fix is correct (even if you haven't verified yet).
Set success=false if you could not identify or implement a fix.
</output_format>`;
}
