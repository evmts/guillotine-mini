import { ToolLoopAgent as Agent } from "ai";
import { anthropic } from "@ai-sdk/anthropic";
import { read, edit, bash, grep, write } from "smithers/tools";

const CLAUDE_MODEL = process.env.CLAUDE_MODEL ?? "claude-opus-4-6";

export const WHAT_WE_ARE_DOING = `We are building an Ethereum execution client in Zig.
You have access to the full codebase and all reference materials
All reference materials are in submodules
You ALWAYS use Voltaire primitives (from voltaire/packages/voltaire-zig/) — never create custom types.
You ALWAYS use the existing guillotine-mini EVM (in src/) — never reimplement the EVM.
You follow Nethermind's architecture (in nethermind/) as a structural reference but implement idiomatically in Zig.
You use comptime dependency injection patterns similar to the existing EVM code.
You write small, atomic, testable units of code. One function or one struct per commit.
You run zig fmt and zig build after every change.
When implementing, you read the relevant spec files first (execution-specs/, EIPs/, devp2p/) before writing any code.`;

export const claude = new Agent({
  model: anthropic(CLAUDE_MODEL),
  tools: { read, edit, bash, grep, write },
  instructions: WHAT_WE_ARE_DOING,
});
