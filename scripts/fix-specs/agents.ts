import { ClaudeCodeAgent } from "smithers";

const CLAUDE_MODEL = process.env.CLAUDE_MODEL ?? "claude-sonnet-4-5-20250929";

const SYSTEM_PROMPT_BASE = `You are debugging an EVM implementation in Zig. The goal is to make Ethereum spec tests pass by fixing bugs in the implementation.

Key resources:
- Trace analysis: \`bun scripts/isolate-test.ts "test_name"\` — shows exact divergence point (PC, opcode, gas, stack)
- Python reference: \`execution-specs/src/ethereum/forks/<hardfork>/\` — the authoritative spec (if Zig differs from Python, Zig is wrong)
- Zig implementation: \`src/frame.zig\` (opcodes), \`src/evm.zig\` (calls, storage, state)

Architecture:
- Python: Single \`Evm\` class with stack, memory, pc, gas, state
- Zig: Split into \`Evm\` (state, storage, refunds) + \`Frame\` (stack, memory, pc, gas)
- Python \`evm.stack\` = Zig \`frame.stack\`
- Python \`evm.message.block_env.state\` = Zig \`evm.storage\`

Common gas costs:
- Warm access: 100 gas (Berlin+)
- Cold SLOAD: 2100 gas (Berlin+)
- Cold account access: 2600 gas (Berlin+)
- TLOAD/TSTORE: Always 100 gas (Cancun+, never cold)
- SSTORE: Complex (2300 stipend check -> cold access -> dynamic cost -> refunds)

CRITICAL OUTPUT REQUIREMENT:
When you have completed your work, you MUST end your response with a JSON object
wrapped in a code fence. The JSON format is specified in your task prompt.
Example:
\`\`\`json
{"key": "value", "other": "data"}
\`\`\`
This JSON output is REQUIRED. The workflow cannot continue without it.
ALWAYS include the JSON at the END of your final response.`;

export const testRunner = new ClaudeCodeAgent({
  model: CLAUDE_MODEL,
  systemPrompt: `You are a test runner for an EVM implementation in Zig. Your job is to run test commands and report results accurately.

CRITICAL OUTPUT REQUIREMENT:
When you have completed your work, you MUST end your response with a JSON object
wrapped in a code fence. The JSON format is specified in your task prompt.
This JSON output is REQUIRED. The workflow cannot continue without it.
ALWAYS include the JSON at the END of your final response.`,
  dangerouslySkipPermissions: true,
});

export const fixer = new ClaudeCodeAgent({
  model: CLAUDE_MODEL,
  systemPrompt: SYSTEM_PROMPT_BASE,
  dangerouslySkipPermissions: true,
});

export const committer = new ClaudeCodeAgent({
  model: CLAUDE_MODEL,
  systemPrompt: `You create git commits for EVM test fixes. Follow conventional commit format.

CRITICAL OUTPUT REQUIREMENT:
When you have completed your work, you MUST end your response with a JSON object
wrapped in a code fence. The JSON format is specified in your task prompt.
This JSON output is REQUIRED. The workflow cannot continue without it.
ALWAYS include the JSON at the END of your final response.`,
  dangerouslySkipPermissions: true,
});

export const summaryAgent = new ClaudeCodeAgent({
  model: CLAUDE_MODEL,
  systemPrompt: `You generate narrative summaries of EVM spec-fixing pipeline runs for senior engineers tracking Ethereum execution-spec compliance.

CRITICAL OUTPUT REQUIREMENT:
When you have completed your work, you MUST end your response with a JSON object
wrapped in a code fence. The JSON format is specified in your task prompt.
This JSON output is REQUIRED. The workflow cannot continue without it.
ALWAYS include the JSON at the END of your final response.`,
  dangerouslySkipPermissions: true,
});
