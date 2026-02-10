export default function EffectImplementPrompt(props: {
  phase: string;
  contextFilePath: string;
  previousWork: { whatWasDone: string; nextSmallestUnit: string } | null;
  failingTests: string | null;
  reviewFixes: string | null;
  implementPass?: number;
}): string {
  const pass = props.implementPass ?? 1;
  return `IMPLEMENTATION PHASE (Pass ${pass}): ${props.phase}

Context file: ${props.contextFilePath}
Read that context file first for full reference.

RULES:
- Implement the SMALLEST ATOMIC UNIT of work possible — one service, one function, one interface
- Use Effect Context.Tag + Layer dependency injection pattern
- Import from voltaire-effect: import { Address, Hash, Hex, ... } from "voltaire-effect/primitives" — NEVER create custom types
- Read the Nethermind equivalent code first, then implement in idiomatic Effect.ts
- After implementing, run: cd client-ts && bun run build && bun test
- Write @effect/vitest it.effect() tests for every public function
- Define services as Context.Tag, provide via Layer
- Use Effect.gen(function* () { ... }) for sequential composition
- Use Data.TaggedError for all domain errors
- NEVER use Effect.runPromise except at app edge (main entry, benchmarks)
- Use 'satisfies' to type-check service implementations against interfaces
- Proper resource management — Effect.acquireRelease for cleanup

${props.previousWork ? `\nPrevious implementation did: ${props.previousWork.whatWasDone}\nNext smallest unit to implement: ${props.previousWork.nextSmallestUnit}` : "Start with the first item from the plan."}

${props.failingTests ? `\nFIX THESE FAILING TESTS FIRST:\n${props.failingTests}` : ""}

${props.reviewFixes ? `\nReview fixes just applied: ${props.reviewFixes}` : ""}

GIT COMMIT RULES:
- Make atomic commits — one logical change per commit
- Commit EACH smallest unit of work separately, do NOT batch everything into one commit
- Use emoji prefixes: 🐛 fix, ♻️ refactor, 🧪 test, ⚡ perf
- Format: "EMOJI type(scope): description"
- Examples:
  - "♻️ refactor(phase-0-db): add Db service with Context.Tag and memory Layer"
  - "🧪 test(phase-0-db): add it.effect() tests for Db service"
  - "🐛 fix(phase-0-db): handle missing key edge case in get()"
- git add the specific files changed, then git commit with the emoji message

IMPORTANT: After completing the implementation and committing, you MUST output a JSON object:
\`\`\`json
{
  "filesCreated": ["client-ts/path/to/new_file.ts"],
  "filesModified": ["client-ts/existing_file.ts"],
  "commitMessage": "♻️ refactor(phase-X): Description of what was implemented",
  "whatWasDone": "Detailed description of what was implemented",
  "nextSmallestUnit": "Description of the next smallest atomic unit of work to implement"
}
\`\`\``;
}
