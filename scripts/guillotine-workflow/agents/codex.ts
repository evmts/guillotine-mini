import { ToolLoopAgent as Agent, stepCountIs } from "ai";
import { openai } from "@ai-sdk/openai";
import { CodexAgent } from "smithers";
import { read, grep, bash } from "smithers/tools";
import { getInstructions } from "./claude";
import type { Target } from "../targets";
import { ZIG_TARGET } from "../targets";

const CODEX_MODEL = process.env.CODEX_MODEL ?? "gpt-5.2-codex";
const USE_CLI = process.env.USE_CLI_AGENTS !== "0" && process.env.USE_CLI_AGENTS !== "false";
const REPO_ROOT = new URL("../../..", import.meta.url).pathname.replace(/\/$/, "");

function getCodexInstructions(target: Target): string {
  const base = getInstructions(target);
  const checklist = target.reviewChecklist.map((item, i) => `${i + 1}. ${item}`).join("\n");

  return `${base}

You are a ruthless, meticulous code reviewer for a high-performance Ethereum execution client in ${target.id === "effect" ? "Effect.ts" : "Zig"}.
You review code for:
${checklist}
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
}

export function makeCodex(target: Target) {
  const instructions = getCodexInstructions(target);

  const apiAgent = new Agent({
    model: openai(CODEX_MODEL),
    tools: { read, grep, bash },
    instructions,
    stopWhen: stepCountIs(100),
    maxOutputTokens: 8192,
  });

  const cliAgent = new CodexAgent({
    model: CODEX_MODEL,
    systemPrompt: instructions,
    yolo: true,
    cwd: REPO_ROOT,
    config: { model_reasoning_effort: "xhigh" },
  });

  return USE_CLI ? cliAgent : apiAgent;
}

export const codex = makeCodex(ZIG_TARGET);
