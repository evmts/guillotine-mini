import type { TestSuite } from "../suites";

export function buildTestPrompt(suite: TestSuite): string {
  return `<task>
Run the following test suite and report the results.
Command: \`${suite.command}\`
Description: ${suite.description}
</task>

<instructions>
1. Run the command: \`${suite.command}\`
2. Capture both stdout and stderr
3. Parse the output to determine:
   - Whether all tests passed
   - How many tests passed
   - How many tests failed
4. Report the results as JSON

If the command exits with a non-zero status, the tests failed.
Look for patterns like "X passed" and "X failed" in the output.
</instructions>

<output_format>
You MUST end your response with this exact JSON structure:
\`\`\`json
{
  "passed": false,
  "output": "full test output here",
  "passedCount": 0,
  "failedCount": 0
}
\`\`\`
</output_format>`;
}
