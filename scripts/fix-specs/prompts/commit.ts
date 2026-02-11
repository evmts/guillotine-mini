import type { TestSuite } from "../suites";

export function buildCommitPrompt(suite: TestSuite): string {
  return `<task>
The ${suite.description} test suite is now passing. Create a git commit for the changes that fixed these tests.
</task>

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
- Mention specific EIP number if relevant
- Mention hardfork if suite-specific
- Be specific about what was fixed

**Examples**:
- \`fix: Pass Cancun EIP-1153 transient storage tests\`
- \`fix: Pass Shanghai EIP-3855 PUSH0 tests\`
- \`fix: Pass Berlin EIP-2929 gas cost tests - Correct warm/cold access tracking\`

## Step 3: Include Body (if needed)
For complex fixes, add a commit body:
\`\`\`
fix: Pass ${suite.description}

- Root cause: [brief explanation]
- Changes: [key changes]
\`\`\`

## Step 4: Create Commit
Use git add and git commit. Include co-author attribution.
</instructions>

<critical_reminders>
- Be specific about what was fixed
- Mention EIP numbers when relevant
- Use conventional commit format
- Keep the first line under 72 characters
- Do not commit unrelated changes
- Do not commit .db files
</critical_reminders>

<output_format>
When done, you MUST end your response with this exact JSON structure:
\`\`\`json
{
  "committed": true,
  "commitMessage": "fix: Pass suite description - what was fixed"
}
\`\`\`
Set committed=false if there were no changes to commit or if the commit failed.
</output_format>`;
}
