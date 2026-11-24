/**
 * The factory that develops evmts/guillotine-mini: featured flows, GitHub
 * policy, and the app home. Projected into .smithers/factory.json and
 * .smithers/home.json by //.smithers:factory-write and verified by
 * //.smithers:factory-check.
 */
import { Smithers as S } from "@smthrs/targets"

export const factory = S.Factory({
  summary: "guillotine-mini: spec-compliant Zig EVM with WASM/C bindings; incremental checks for execution-specs parity, gas and opcodes.",
  flows: [
    S.Flow({ flow: "checks/review", featured: true, summary: "Review gas, hardfork gating, state rollback, Zig memory safety and ABI changes." }),
    S.Flow({ flow: "spec-fix", featured: true, summary: "Fix a failing ethereum/tests or execution-spec-tests case against the Python reference." }),
    S.Flow({ flow: "issue/repro", featured: true, summary: "Reproduce an EVM defect with a trace divergence before planning a fix." }),
    S.Flow({ flow: "issue/poc", featured: true, summary: "Implement a bounded fix with a focused regression and spec evidence." }),
    S.Flow({ flow: "pr-triage", featured: true, summary: "Assess PR readiness from its diff and supplied CI evidence." }),
  ],
  on: {},
  github: S.Github.Policy({
    mirror: "pull",
    issues: "read",
    changes: "send-upstream",
    maintainers: ["roninjin10", "fucory"],
    protectedPaths: [
      "src/evm.zig",
      "src/frame.zig",
      "src/instructions",
      "src/precompiles",
      "src/root_c.zig",
      "build.zig.zon",
      "native-dependencies.json",
    ],
  }),
})

export const home = S.Factory.Home({
  blocks: [
    {
      type: "text",
      title: "guillotine-mini factory",
      text: "Python execution-specs are authoritative: gas order, hardfork guards and error mapping must match them exactly. Zig, WASM and client-ts checks run incrementally through Smithers with a local-first cache synced to build.smithers.sh; benchmarks are exclusive and always explicit.",
    },
    { type: "prompt", title: "Ask about guillotine-mini", placeholder: "Describe a failing spec test, opcode, gas or ABI issue…" },
    { type: "flows", title: "Review, fix specs and reproduce" },
    {
      type: "links",
      links: [
        { label: "Repository", url: "https://github.com/evmts/guillotine-mini" },
        { label: "CI", url: "https://github.com/evmts/guillotine-mini/actions/workflows/ci.yml" },
        { label: "Docs", url: "https://mini.tevm.sh" },
        { label: "execution-specs", url: "https://github.com/ethereum/execution-specs" },
      ],
    },
  ],
})
