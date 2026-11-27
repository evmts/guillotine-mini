import { describe, expect, test } from "bun:test"
import {
  computeOverallScore,
  escapeHtml,
  renderLighthouseHtml,
  renderMarkdownSummary,
  scoreBand,
  type AuditReportDocument,
} from "./generate-audit-report.ts"
import { classifyExecution } from "./trust-policy.ts"

const sampleReport = (tierEnv: Record<string, string | undefined> = {}): AuditReportDocument => ({
  schemaVersion: 1,
  repository: "evmts/guillotine-mini",
  generatedAt: "2026-11-27T00:00:00.000Z",
  overallScore: 86,
  attestation: classifyExecution({ env: tierEnv, now: () => "2026-11-27T00:00:00.000Z" }),
  telemetry: {
    commitShort: "0a128cae",
    commitFull: "0a128caec2e24232ad20376f78b57003b9e0bf08",
    branch: "main",
    smithersPackages: 29,
    declaredFlows: 11,
    wikiPages: 8,
    leanTheorems: 60,
    leanSorryCount: 0,
    wasmBytes: 1_900_000,
    wasmBudgetBytes: 2_621_440,
    uphillVersion: "0.0.11",
  },
  categories: [
    {
      name: "safety",
      title: "Safety & TigerStyle",
      description: "Crash-free EVM execution.",
      score: 92,
      metrics: [
        {
          name: "zig-no-panic",
          title: "Zig no panic",
          description: "No @panic or unreachable.",
          kind: "check",
          unit: null,
          value: 0.91,
          score: 91,
          target: null,
          note: null,
          better: "lower",
          weight: 2,
          items: [
            { name: "src/evm.zig", value: false, target: null, note: "line 2107: <script>alert(1)</script>" },
            { name: "src/frame.zig", value: true, target: null, note: null },
          ],
        },
      ],
    },
    {
      name: "factory",
      title: "Factory & Trust",
      description: "Smithers Cloud trust boundaries.",
      score: 100,
      metrics: [],
    },
  ],
  opportunities: [
    { category: "verification", metric: "ts-test-ratio", item: null, items: 1, value: 72.5, target: 100, gain: 11 },
  ],
  baselineChanges: 0,
})

describe("Lighthouse Backpressure Audit Report", () => {
  test("maps score bands cleanly to Lighthouse thresholds", () => {
    expect(scoreBand(100)).toBe("pass")
    expect(scoreBand(90)).toBe("pass")
    expect(scoreBand(89)).toBe("average")
    expect(scoreBand(50)).toBe("average")
    expect(scoreBand(49)).toBe("fail")
    expect(scoreBand(0)).toBe("fail")
  })

  test("computes rounded composite score across categories", () => {
    const r = sampleReport()
    expect(computeOverallScore(r.categories)).toBe(96)
    expect(computeOverallScore([])).toBe(0)
  })

  test("escapes HTML in untrusted diagnostic notes and embeds safe JSON", () => {
    const html = renderLighthouseHtml(sampleReport())
    expect(html).toContain("<!DOCTYPE html>")
    expect(html).toContain("lh-gauge-svg")
    expect(html).toContain("UNTRUSTED CONTRIBUTOR")
    expect(html).toContain("&lt;script&gt;alert(1)&lt;/script&gt;")
    expect(html).not.toContain("<script>alert(1)</script>")
  })

  test("stamps trusted-sandbox badge on canonical main push", () => {
    const html = renderLighthouseHtml(
      sampleReport({
        GITHUB_ACTIONS: "true",
        GITHUB_REPOSITORY: "evmts/guillotine-mini",
        GITHUB_EVENT_NAME: "push",
        GITHUB_REF: "refs/heads/main",
        SMITHERS_CACHE_WRITE_TOKEN: "tok",
      })
    )
    expect(html).toContain("TRUSTED SANDBOX")
    expect(html).toContain("Authoritative")
  })

  test("renders concise Markdown summary for smithers.sh Home and PR comments", () => {
    const md = renderMarkdownSummary(sampleReport())
    expect(md).toContain("## Lighthouse Backpressure Audit (86 / 100)")
    expect(md).toContain("| Safety & TigerStyle | **92 / 100** (PASS) |")
    expect(md).toContain("https://mini.tevm.sh/audit/")
    expect(md).toContain("60 theorems (0 sorry)")
  })
})
