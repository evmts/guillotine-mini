export type Target = {
  id: "zig" | "effect";
  name: string;
  clientDir: string;
  buildCmd: string;
  testCmd: string;
  fmtCmd: string;
  voltairePath: string;
  importStyle: string;
  diPattern: string;
  errorPattern: string;
  testPattern: string;
  codeStyle: string;
  reviewChecklist: string[];
  refactorChecklist: string[];
  referenceRepos: string[];
};

export const ZIG_TARGET: Target = {
  id: "zig",
  name: "Zig Execution Client",
  clientDir: "client/",
  buildCmd: "zig build",
  testCmd: "zig build test",
  fmtCmd: "zig fmt client/",
  voltairePath: "/Users/williamcory/voltaire/packages/voltaire-zig/",
  importStyle: '@import("voltaire"), @import("crypto")',
  diPattern: "comptime vtable dependency injection (like src/host.zig HostInterface pattern)",
  errorPattern: "explicit error unions, propagate with try, NEVER use catch {}",
  testPattern: 'inline test "..." blocks inside each source file',
  codeStyle: "snake_case functions/variables, PascalCase types, /// doc comments",
  reviewChecklist: [
    "Correctness against Ethereum specs (execution-specs/, EIPs/)",
    "Architecture consistency with Nethermind (nethermind/)",
    "Proper use of Voltaire primitives — flag any custom type that duplicates what Voltaire provides",
    "Proper use of comptime dependency injection",
    "Error handling — NEVER allow catch {} or silent error suppression",
    "Performance — this must be faster than Nethermind (C#), every allocation matters",
    "Test coverage — every public function must have tests",
    "Security — no secret leaks, no undefined behavior",
  ],
  refactorChecklist: [
    "Code duplication — extract shared logic",
    "Naming consistency — match Zig conventions (snake_case functions, PascalCase types)",
    "Public API surface — minimize what's public, keep internals private",
    "Documentation — add /// doc comments to all public APIs",
    "Import organization — clean up unused imports",
    "Dead code — remove any unused functions or types",
    "Consistent error handling patterns",
  ],
  referenceRepos: [],
};

export const EFFECT_TARGET: Target = {
  id: "effect",
  name: "Effect.ts Execution Client",
  clientDir: "client-ts/",
  buildCmd: "cd client-ts && bun run build",
  testCmd: "cd client-ts && bun test",
  fmtCmd: "cd client-ts && bunx prettier --write .",
  voltairePath: "/Users/williamcory/voltaire/voltaire-effect/",
  importStyle: 'import { Address, Hash, Hex, ... } from "voltaire-effect/primitives"',
  diPattern: "Effect Context.Tag + Layer dependency injection (Context.Tag for service interfaces, Layer.effect/Layer.succeed for implementations)",
  errorPattern: "Data.TaggedError for domain errors, typed error channels (never use Effect<A, never, R> when errors are possible), Effect.gen for composition",
  testPattern: "@effect/vitest it.effect() for Effect-returning tests, describe/it structure",
  codeStyle: "PascalCase for types/services/tags, camelCase for functions/variables, JSDoc comments",
  reviewChecklist: [
    "Correctness against Ethereum specs (execution-specs/, EIPs/)",
    "Architecture consistency with Nethermind (nethermind/) — mirror module boundaries",
    "Proper use of voltaire-effect primitives (Address, Hash, Hex, Block, Transaction, etc.) — NEVER create custom types",
    "Idiomatic Effect.ts: Context.Tag for services, Layer for DI, Effect.gen for composition",
    "NEVER use Effect.runPromise except at the application edge (main entry point / benchmarks)",
    "Error channels typed correctly with Data.TaggedError — not 'never' when errors are possible",
    "Effect.gen preferred over long pipe chains for readability",
    "Proper resource management — Effect.acquireRelease for cleanup, Layer.scoped for scoped services",
    "Test coverage — every public function must have @effect/vitest it.effect() tests",
    "No 'any' types — leverage Effect's type inference",
    "Use 'satisfies' to type-check service implementations",
  ],
  refactorChecklist: [
    "Code duplication — extract shared helpers",
    "Layer composition — use Layer.merge, Layer.provide for clean DI graphs",
    "Effect.gen vs pipe — use gen for complex logic, pipe for short chains",
    "Public API surface — export service Tags + convenience accessors, keep internals private",
    "Documentation — JSDoc comments on all public APIs",
    "Import organization — clean up unused imports",
    "Dead code — remove unused functions or types",
    "Consistent error handling — Data.TaggedError everywhere",
  ],
  referenceRepos: ["effect-repo/"],
};

export function getTarget(id: string): Target {
  switch (id) {
    case "effect":
      return EFFECT_TARGET;
    case "zig":
    default:
      return ZIG_TARGET;
  }
}
