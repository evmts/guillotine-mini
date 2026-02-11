import { readFileSync, existsSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const KNOWN_ISSUES_PATH = join(__dirname, "..", "known-issues.json");

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

let _knownIssues: KnownIssuesDatabase | null = null;

function loadKnownIssues(): KnownIssuesDatabase {
  if (_knownIssues) return _knownIssues;
  try {
    if (existsSync(KNOWN_ISSUES_PATH)) {
      const content = readFileSync(KNOWN_ISSUES_PATH, "utf-8");
      _knownIssues = JSON.parse(content);
      return _knownIssues!;
    }
  } catch (error) {
    console.warn(`Could not load known issues database: ${error}`);
  }
  _knownIssues = { issues: {} };
  return _knownIssues;
}

export function getKnownIssueContext(suiteName: string): string {
  const db = loadKnownIssues();
  const issue = db.issues[suiteName];
  if (!issue) return "";

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
