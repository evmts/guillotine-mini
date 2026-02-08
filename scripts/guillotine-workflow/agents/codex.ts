import { ToolLoopAgent as Agent, stepCountIs } from "ai";
import { openai } from "@ai-sdk/openai";
import { CodexAgent } from "smithers";
import { read, grep, bash } from "smithers/tools";
import { WHAT_WE_ARE_DOING } from "./claude";

const CODEX_MODEL = process.env.CODEX_MODEL ?? "gpt-5.2-codex";
const USE_CLI = process.env.USE_CLI_AGENTS !== "0" && process.env.USE_CLI_AGENTS !== "false";

const CODEX_INSTRUCTIONS = `${WHAT_WE_ARE_DOING}

You are a ruthless, meticulous code reviewer for a high-performance Ethereum execution client in Zig.
You review code for:
1. Correctness against Ethereum specs (execution-specs/, EIPs/)
2. Architecture consistency with Nethermind (nethermind/)
3. Proper use of Voltaire primitives — flag any custom type that duplicates what Voltaire provides
4. Proper use of comptime dependency injection
5. Error handling — NEVER allow catch {} or silent error suppression
6. Performance — this must be faster than Nethermind (C#), every allocation matters
7. Test coverage — every public function must have tests
8. Security — no secret leaks, no undefined behavior
You are EXTREMELY strict. If something can be improved, it MUST be flagged.

CRITICAL OUTPUT REQUIREMENT:
When you have completed your review, you MUST end your response with a JSON object
wrapped in a code fence. The JSON format is specified in your task prompt.
Example:
\`\`\`json
{"key": "value", "other": "data"}
\`\`\`
This JSON output is REQUIRED. The workflow cannot continue without it.
ALWAYS include the JSON at the END of your final response.`;

const apiAgent = new Agent({
  model: openai(CODEX_MODEL),
  tools: { read, grep, bash },
  instructions: CODEX_INSTRUCTIONS,
  stopWhen: stepCountIs(100),
  maxOutputTokens: 8192,
});

const cliAgent = new CodexAgent({
  model: CODEX_MODEL,
  systemPrompt: CODEX_INSTRUCTIONS,
  fullAuto: true,
});

export const codex = USE_CLI ? cliAgent : apiAgent;
