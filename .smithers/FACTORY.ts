/**
 * The coding factory for evmts/guillotine-mini (https://smithers.sh/evmts/guillotine-mini):
 * featured flows, Dispatcher rules, GitHub switchover policy, saved issue views,
 * workflow transitions, and lane machine requirements.
 *
 * Projected into .smithers/factory.json by //.smithers:factory-write and verified
 * by //.smithers:factory-check. The personalized Maintainer / Contributor / Viewer
 * homepage lives in .smithers/HOME.ts and projects to .smithers/home.json via
 * //.smithers:home-check.
 */
import { Smithers as S } from "@smthrs/targets"
import { On, Trigger } from "@smthrs/triggers"
import Uphill from "./flows/uphill/flow.ts"

export const review = S.Flow({
  flow: "checks/review",
  featured: true,
  summary: "Review gas order, hardfork gating, state rollback, Zig memory safety, and C/WASM ABI changes.",
})

export const specFix = S.Flow({
  flow: "spec-fix",
  featured: true,
  summary: "Fix one failing ethereum/tests or execution-spec-tests case against the Python reference.",
})

export const issueRepro = S.Flow({
  flow: "issue/repro",
  featured: true,
  summary: "Reproduce an EVM defect with a minimal trace divergence before planning a fix.",
})

export const issuePoc = S.Flow({
  flow: "issue/poc",
  featured: true,
  summary: "Implement a bounded fix with a failing regression first, spec evidence, and memory-safety checks.",
})

export const prTriage = S.Flow({
  flow: "pr-triage",
  featured: true,
  summary: "Assess PR readiness from its diff and supplied CI evidence without approving or merging.",
})

export const ciFlow = S.Flow({
  flow: "ci",
  featured: true,
  summary: "Run Smithers Cloud CI gates: trust tests, wiki integrity, TypeScript SDK suites, and Lighthouse audit.",
})

export const uphillFlow = S.Flow({
  flow: "uphill",
  featured: true,
  summary: "Score TigerStyle safety, footprint, Lean 4 proofs, and docs with Uphill and Lighthouse backpressure.",
})

export const auditReportFlow = S.Flow({
  flow: "audit-report",
  featured: true,
  summary: "Generate the Lighthouse-style Backpressure Audit Report with execution trust provenance.",
})

export const wikiRefreshFlow = S.Flow({
  flow: "wiki-refresh",
  featured: false,
  summary: "Validate Obsidian wikilinks, refresh Mythical History, and emit the Smithers Cloud wiki feed.",
})

export const docsPublishFlow = S.Flow({
  flow: "docs-publish",
  featured: false,
  summary: "Rebuild the mini.tevm.sh Vocs site with fresh llms.txt and embedded Lighthouse audit report.",
})

export const releaseFlow = S.Flow({
  flow: "release",
  featured: false,
  summary: "Verify release readiness, checksums, and reproducible native and WASM artifacts before publishing.",
})

export const factory = S.Factory({
  triggers: { uphill: Trigger.bind({ flow: Uphill, on: On.manual(), title: "Run Uphill audit" }) },
  summary: "Spec-first Zig EVM with C/WASM ABI, Lean 4 oracle, shared Smithers Cloud cache, and Lighthouse backpressure.",
  flows: [
    review,
    specFix,
    issueRepro,
    issuePoc,
    prTriage,
    ciFlow,
    uphillFlow,
    auditReportFlow,
    wikiRefreshFlow,
    docsPublishFlow,
    releaseFlow,
  ],
  on: {
    "issue.labeled:todo": {
      flow: "issue/poc",
      description: "Build a failing regression and bounded PoC for every maintainer-accepted TODO",
    },
    "change.opened": {
      flow: "checks/review",
      description: "Review every Change for execution-specs parity, gas, memory safety, and ABI stability",
    },
    "change.updated": {
      flow: "checks/review",
      description: "Re-review every updated Change",
    },
    "change.landed": {
      flow: ["wiki-refresh", "audit-report", "docs-publish"],
      description: "Refresh the wiki, Mythical History, Lighthouse audit report, and docs after landing",
    },
    "github.push:main": {
      flow: ["wiki-refresh", "audit-report"],
      description: "Refresh wiki and Lighthouse audit report after pushes to main",
    },
    "schedule:0 3 * * *": {
      flow: "audit-report",
      description: "Run nightly Lighthouse backpressure audit on main",
    },
  },
  github: S.Github.Policy({
    mirror: "push",
    issues: "two-way",
    changes: "land",
    maintainers: ["roninjin10", "fucory"],
    dailyTokens: 1_000_000_000,
    protectedPaths: [
      "src/evm.zig",
      "src/frame.zig",
      "src/instructions",
      "src/precompiles",
      "src/root_c.zig",
      "build.zig",
      "build.zig.zon",
      "native-dependencies.json",
      ".smithers",
      ".github",
      ".agents/uphill",
      "PACKAGE.ts",
      "AGENTS.md",
      "CLAUDE.md",
    ],
  }),
  policy: {
    lifecycle: { docs: "evergreen", tests: "evergreen" },
    approvals: { approve: "person", merge: "person" },
  },
  machine: {
    vcpus: 4,
    memoryMiB: 8192,
    tools: ["zig", "bun", "node", "cargo", "rustc", "jj", "uphill"],
  },
  issueViews: [
    { id: "needs-triage", title: "Needs triage", state: "open", labels: ["proposed"] },
    { id: "todos", title: "Accepted TODOs", state: "open", labels: ["todo"] },
    { id: "spec-bugs", title: "Spec parity bugs", state: "open", labels: ["spec-bug"] },
    { id: "wasm-abi", title: "WASM and C ABI", state: "open", labels: ["wasm"] },
    { id: "lean-formal", title: "Lean 4 oracle", state: "open", labels: ["formal-verification"] },
    { id: "good-first", title: "Good first issues", state: "open", labels: ["good-first-issue"] },
  ],
  issueTransitions: [
    { id: "accept", title: "Accept issue", from: "proposed", to: "accepted", actor: "person" },
    { id: "queue-todo", title: "Queue on TODO stack", from: "accepted", to: "todo", actor: "person" },
    { id: "needs-repro", title: "Request minimal repro", to: "needs-repro", actor: "anyone" },
    { id: "mark-verified", title: "Mark spec verified", to: "verified", actor: "person" },
  ],
})
