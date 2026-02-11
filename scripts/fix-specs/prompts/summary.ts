import type { TestSuite } from "../suites";

interface SuiteResult {
  name: string;
  passed: boolean;
  wasFixed: boolean;
}

export function buildSummaryPrompt(suiteResults: SuiteResult[], totalSuites: number): string {
  const passed = suiteResults.filter((r) => r.passed);
  const failed = suiteResults.filter((r) => !r.passed);
  const fixed = suiteResults.filter((r) => r.wasFixed);

  return `<task>
Write a concise narrative summary (3-4 paragraphs) of what happened in this spec-fixing run.
</task>

<audience>
Senior engineers and stakeholders tracking progress toward Ethereum execution-spec compliance.
</audience>

<style>
- Narrative prose, no bullet lists.
- 3-4 paragraphs, 250-500 words.
- Cover goals, what was attempted, key outcomes, notable blockers, and pragmatic next steps.
- Avoid code blocks; keep it readable and high level.
</style>

<results>
Total suites: ${totalSuites}
Passed: ${passed.length}
Failed: ${failed.length}
Fixed in this run: ${fixed.length}

Passed suites: ${passed.map((r) => r.name).join(", ") || "none"}
Failed suites: ${failed.map((r) => r.name).join(", ") || "none"}
Fixed suites: ${fixed.map((r) => r.name).join(", ") || "none"}
</results>

<output_format>
You MUST end your response with this exact JSON structure:
\`\`\`json
{
  "totalSuites": ${totalSuites},
  "totalPassed": ${passed.length},
  "totalFailed": ${failed.length},
  "narrative": "Your 3-4 paragraph narrative here"
}
\`\`\`
</output_format>`;
}
