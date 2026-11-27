#!/usr/bin/env bun
/**
 * Lighthouse-style Backpressure Audit Report generator for evmts/guillotine-mini.
 *
 * Consumes live Uphill continuous metrics (.uphill/report.json), collects repo
 * telemetry (Lean 4 formal oracle, Smithers targets/flows, WASM byte budget, jj
 * commit metadata), stamps an ExecutionAttestation (trusted vs untrusted), and
 * writes four synchronized deliverables:
 *   1. .smithers/audit/index.html      (self-contained Lighthouse-style interactive HTML)
 *   2. .smithers/audit/report.json     (machine-readable audit report + trust attestation)
 *   3. .smithers/audit/latest.md       (compact summary rendered on smithers.sh Home)
 *   4. .smithers/audit/pr-comment.md   (ready-to-post PR backpressure comment)
 *
 * With --publish-docs, also copies index.html and report.json into docs/public/audit/
 * so https://mini.tevm.sh/audit/ always serves the latest report on merge to main.
 *
 * Usage:
 *   bun .smithers/scripts/generate-audit-report.ts [--untrusted] [--publish-docs] [--verify] [--skip-uphill]
 */

import { existsSync, mkdirSync, readdirSync, readFileSync, statSync, writeFileSync } from "node:fs"
import { homedir } from "node:os"
import { dirname, join, resolve } from "node:path"
import { classifyExecution, type ExecutionAttestation } from "./trust-policy.ts"

export interface UphillItem {
  readonly name: string
  readonly value: unknown
  readonly target: unknown
  readonly note: string | null
}

export interface UphillMetric {
  readonly name: string
  readonly title: string
  readonly description: string
  readonly kind: string
  readonly unit: string | null
  readonly value: unknown
  readonly score: number
  readonly target: unknown
  readonly note: string | null
  readonly better: string
  readonly weight: number
  readonly items: ReadonlyArray<UphillItem>
}

export interface UphillCategory {
  readonly name: string
  readonly title: string
  readonly description: string
  readonly score: number
  readonly metrics: ReadonlyArray<UphillMetric>
}

export interface UphillOpportunity {
  readonly category: string
  readonly metric: string
  readonly item: string | null
  readonly items: number
  readonly value: unknown
  readonly target: unknown
  readonly gain: number
}

export interface UphillRawReport {
  readonly version: number
  readonly categories: ReadonlyArray<UphillCategory>
  readonly opportunities: ReadonlyArray<UphillOpportunity>
  readonly changes: ReadonlyArray<unknown>
}

export interface RepoTelemetry {
  readonly commitShort: string
  readonly commitFull: string
  readonly branch: string
  readonly smithersPackages: number
  readonly declaredFlows: number
  readonly wikiPages: number
  readonly leanTheorems: number
  readonly leanSorryCount: number
  readonly wasmBytes: number | null
  readonly wasmBudgetBytes: number
  readonly uphillVersion: string
}

export interface AuditReportDocument {
  readonly schemaVersion: 1
  readonly repository: "evmts/guillotine-mini"
  readonly generatedAt: string
  readonly overallScore: number
  readonly attestation: ExecutionAttestation
  readonly telemetry: RepoTelemetry
  readonly categories: ReadonlyArray<UphillCategory>
  readonly opportunities: ReadonlyArray<UphillOpportunity>
  readonly baselineChanges: number
}

export type ScoreBand = "pass" | "average" | "fail"

export const scoreBand = (score: number): ScoreBand =>
  score >= 90 ? "pass" : score >= 50 ? "average" : "fail"

export const escapeHtml = (input: unknown): string =>
  String(input ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;")

export const formatMetricValue = (value: unknown, unit?: string | null): string => {
  if (value === null || value === undefined) return "-"
  if (typeof value === "boolean") return value ? "pass" : "fail"
  if (typeof value === "number") {
    const rounded = Number.isInteger(value) ? String(value) : value.toFixed(2).replace(/\.?0+$/, "")
    return unit ? `${rounded} ${unit}` : rounded
  }
  return String(value)
}

export const computeOverallScore = (categories: ReadonlyArray<UphillCategory>): number => {
  const valid = categories.filter((c) => typeof c.score === "number" && Number.isFinite(c.score))
  if (valid.length === 0) return 0
  const sum = valid.reduce((acc, c) => acc + c.score, 0)
  return Math.round(sum / valid.length)
}

function runCmd(cmd: string[], cwd: string): { ok: boolean; stdout: string; stderr: string } {
  try {
    const res = Bun.spawnSync(cmd, { cwd, stdout: "pipe", stderr: "pipe" })
    return {
      ok: res.exitCode === 0,
      stdout: new TextDecoder().decode(res.stdout).trim(),
      stderr: new TextDecoder().decode(res.stderr).trim(),
    }
  } catch {
    return { ok: false, stdout: "", stderr: "" }
  }
}

function findUphillBin(): string | null {
  const candidates = [
    process.env.UPHILL_BIN,
    "uphill",
    join(homedir(), ".uphill", "bin", "uphill"),
  ].filter((x): x is string => Boolean(x))
  for (const bin of candidates) {
    const check = runCmd([bin, "--version"], process.cwd())
    if (check.ok) return bin
  }
  return null
}

function countFilesNamed(root: string, filename: string, skipDirs: Set<string>): number {
  let count = 0
  const walk = (dir: string) => {
    if (!existsSync(dir)) return
    for (const entry of readdirSync(dir, { withFileTypes: true })) {
      if (entry.isDirectory()) {
        if (skipDirs.has(entry.name)) continue
        walk(join(dir, entry.name))
      } else if (entry.name === filename) {
        count++
      }
    }
  }
  walk(root)
  return count
}

function collectTelemetry(root: string, uphillBin: string | null): RepoTelemetry {
  const jjRev = runCmd(
    ["jj", "--no-pager", "log", "-r", "@", "--no-graph", "-T", 'commit_id.short(12) ++ "\\n" ++ commit_id ++ "\\n" ++ local_bookmarks'],
    root
  )
  const revLines = jjRev.ok ? jjRev.stdout.split("\n") : []
  const commitShort = (revLines[0] || process.env.GITHUB_SHA?.slice(0, 12) || "working-copy").trim()
  const commitFull = (revLines[1] || process.env.GITHUB_SHA || "working-copy").trim()
  const branch = (revLines[2] || process.env.GITHUB_REF_NAME || "main").trim() || "main"

  const skip = new Set([
    ".git",
    ".jj",
    "node_modules",
    ".zig-cache",
    "zig-out",
    "execution-specs",
    "ethereum-tests",
    "target",
    ".flows",
    ".uphill",
  ])
  const smithersPackages = countFilesNamed(root, "PACKAGE.ts", skip)

  let declaredFlows = 0
  const factoryPath = join(root, ".smithers/factory.json")
  if (existsSync(factoryPath)) {
    try {
      const f = JSON.parse(readFileSync(factoryPath, "utf8")) as { flows?: unknown[] }
      declaredFlows = Array.isArray(f.flows) ? f.flows.length : 0
    } catch {
      declaredFlows = 0
    }
  }

  let wikiPages = 0
  const wikiDir = join(root, ".smithers/wiki")
  if (existsSync(wikiDir)) {
    const walkWiki = (dir: string) => {
      for (const entry of readdirSync(dir, { withFileTypes: true })) {
        const full = join(dir, entry.name)
        if (entry.isDirectory()) walkWiki(full)
        else if (entry.name.endsWith(".md")) wikiPages++
      }
    }
    walkWiki(wikiDir)
  }

  let leanTheorems = 0
  let leanSorryCount = 0
  const leanDir = join(root, "spec/lean")
  if (existsSync(leanDir)) {
    const walkLean = (dir: string) => {
      for (const entry of readdirSync(dir, { withFileTypes: true })) {
        if (entry.name === ".lake") continue
        const full = join(dir, entry.name)
        if (entry.isDirectory()) walkLean(full)
        else if (entry.name.endsWith(".lean")) {
          const text = readFileSync(full, "utf8")
          const thmMatches = text.match(/^\s*(?:theorem|lemma)\s+/gm)
          leanTheorems += thmMatches ? thmMatches.length : 0
          const sorryMatches = text.match(/\bsorry\b/g)
          leanSorryCount += sorryMatches ? sorryMatches.length : 0
        }
      }
    }
    walkLean(leanDir)
  }

  const wasmPath = join(root, "zig-out/bin/guillotine_mini.wasm")
  const wasmBytes = existsSync(wasmPath) ? statSync(wasmPath).size : null

  const verRes = uphillBin ? runCmd([uphillBin, "--version"], root) : { ok: false, stdout: "" }
  const uphillVersion = verRes.ok && verRes.stdout ? verRes.stdout.split("\n")[0]!.trim() : "unknown"

  return {
    commitShort,
    commitFull,
    branch,
    smithersPackages,
    declaredFlows,
    wikiPages,
    leanTheorems,
    leanSorryCount,
    wasmBytes,
    wasmBudgetBytes: 2_621_440,
    uphillVersion,
  }
}

function gaugeSvg(score: number, size: number, strokeWidth: number): string {
  const radius = (size - strokeWidth) / 2
  const circumference = 2 * Math.PI * radius
  const clamped = Math.max(0, Math.min(100, Math.round(score)))
  const dashOffset = circumference * (1 - clamped / 100)
  const band = scoreBand(clamped)
  const center = size / 2
  return `
    <svg class="lh-gauge-svg band-${band}" width="${size}" height="${size}" viewBox="0 0 ${size} ${size}" aria-hidden="true">
      <circle class="lh-gauge-base" cx="${center}" cy="${center}" r="${radius}" stroke-width="${strokeWidth}" />
      <circle class="lh-gauge-arc" cx="${center}" cy="${center}" r="${radius}" stroke-width="${strokeWidth}"
        stroke-dasharray="${circumference.toFixed(2)}"
        stroke-dashoffset="${dashOffset.toFixed(2)}"
        transform="rotate(-90 ${center} ${center})" />
      <text class="lh-gauge-num" x="${center}" y="${center}" dominant-baseline="central" text-anchor="middle">${clamped}</text>
    </svg>`
}

function metricFailingItems(metric: UphillMetric): ReadonlyArray<UphillItem> {
  if (!Array.isArray(metric.items)) return []
  return metric.items.filter((item) => {
    if (typeof item.value === "boolean") return item.value === false
    if (typeof item.value === "string") return item.value === "fail"
    if (typeof item.value === "number" && typeof item.target === "number") {
      return metric.better === "higher" ? item.value < item.target : item.value > item.target
    }
    return Boolean(item.note)
  })
}

export function renderLighthouseHtml(report: AuditReportDocument): string {
  const { attestation, telemetry, categories, opportunities, overallScore } = report
  const trustClass =
    attestation.tier === "trusted-sandbox"
      ? "trust-sandbox"
      : attestation.tier === "trusted-maintainer"
        ? "trust-maintainer"
        : "trust-untrusted"
  const trustLabel =
    attestation.tier === "trusted-sandbox"
      ? "TRUSTED SANDBOX"
      : attestation.tier === "trusted-maintainer"
        ? "TRUSTED MAINTAINER"
        : "UNTRUSTED CONTRIBUTOR"

  const allMetrics = categories.flatMap((c) => (Array.isArray(c.metrics) ? c.metrics : []))
  const passingMetrics = allMetrics.filter((m) => typeof m.score === "number" && m.score >= 90).length
  const warningMetrics = allMetrics.filter((m) => typeof m.score === "number" && m.score >= 50 && m.score < 90).length
  const failingMetrics = allMetrics.filter((m) => typeof m.score === "number" && m.score < 50).length

  const gaugeCards = categories
    .map(
      (cat) => `
      <a class="lh-gauge-card" href="#cat-${escapeHtml(cat.name)}" data-band="${scoreBand(cat.score)}">
        ${gaugeSvg(cat.score, 84, 7)}
        <span class="lh-gauge-label">${escapeHtml(cat.title)}</span>
      </a>`
    )
    .join("")

  const opportunityRows =
    opportunities.length === 0
      ? `<div class="empty-ok">All metrics meet their targets. Zero remaining score opportunities.</div>`
      : opportunities
          .slice(0, 12)
          .map((opp) => {
            const pct = Math.min(100, Math.max(8, opp.gain * 6))
            const itemSuffix = opp.item ? ` <code>${escapeHtml(opp.item)}</code>` : opp.items > 1 ? ` (${opp.items} items)` : ""
            return `
            <div class="opp-row">
              <div class="opp-main">
                <span class="opp-gain">+${escapeHtml(opp.gain)}</span>
                <span class="opp-cat">${escapeHtml(opp.category)}</span>
                <span class="opp-name">${escapeHtml(opp.metric)}${itemSuffix}</span>
              </div>
              <div class="opp-meta">
                <span class="opp-delta">${escapeHtml(formatMetricValue(opp.value))} &rarr; ${escapeHtml(formatMetricValue(opp.target))}</span>
                <div class="opp-bar"><div class="opp-bar-fill" style="width:${pct}%"></div></div>
              </div>
            </div>`
          })
          .join("")

  const categorySections = categories
    .map((cat) => {
      const rows = cat.metrics
        .map((m) => {
          const band = scoreBand(m.score)
          const failed = metricFailingItems(m)
          const statusFilter = band === "pass" && failed.length === 0 ? "passed" : band === "fail" ? "failed" : "opportunities"
          const displayVal =
            m.kind === "check" && m.items.length > 0
              ? `${m.items.length - failed.length} / ${m.items.length} pass`
              : `${formatMetricValue(m.value, m.unit)}${m.target !== null && m.target !== undefined ? ` (target ${formatMetricValue(m.target, m.unit)})` : ""}`
          const searchHaystack = `${cat.title} ${m.name} ${m.title} ${m.description} ${failed.map((f) => `${f.name} ${f.note ?? ""}`).join(" ")}`.toLowerCase()
          const detailsTable =
            failed.length > 0
              ? `
                <div class="diag-table-wrap">
                  <table class="diag-table">
                    <thead>
                      <tr><th>Item</th><th>Measured</th><th>Target</th><th>Diagnostic</th></tr>
                    </thead>
                    <tbody>
                      ${failed
                        .slice(0, 40)
                        .map(
                          (it) => `
                        <tr>
                          <td><code>${escapeHtml(it.name)}</code></td>
                          <td>${escapeHtml(formatMetricValue(it.value, m.unit))}</td>
                          <td>${escapeHtml(formatMetricValue(it.target ?? m.target, m.unit))}</td>
                          <td>${escapeHtml(it.note ?? "Below target")}</td>
                        </tr>`
                        )
                        .join("")}
                    </tbody>
                  </table>
                  ${failed.length > 40 ? `<p class="diag-more">Showing first 40 of ${failed.length} items. Download JSON for the complete list.</p>` : ""}
                </div>`
              : `<p class="diag-pass-note">All ${Math.max(1, m.items.length)} measured check(s) passed target thresholds.</p>`

          return `
            <details class="audit-item band-${band}" data-status="${statusFilter}" data-search="${escapeHtml(searchHaystack)}" ${failed.length > 0 && m.score < 90 ? "open" : ""}>
              <summary class="audit-summary">
                <span class="audit-glyph glyph-${band}" aria-hidden="true"></span>
                <span class="audit-title-group">
                  <span class="audit-title">${escapeHtml(m.title)}</span>
                  <span class="audit-display">${escapeHtml(displayVal)}</span>
                </span>
                <span class="audit-right">
                  <span class="audit-weight">w${escapeHtml(m.weight)}</span>
                  <span class="audit-score pill-${band}">${Math.round(m.score)}</span>
                </span>
              </summary>
              <div class="audit-body">
                <p class="audit-desc">${escapeHtml(m.description)}</p>
                ${detailsTable}
              </div>
            </details>`
        })
        .join("")

      return `
        <section class="cat-section" id="cat-${escapeHtml(cat.name)}">
          <div class="cat-header">
            <div class="cat-header-left">
              ${gaugeSvg(cat.score, 56, 5)}
              <div>
                <h2>${escapeHtml(cat.title)}</h2>
                <p>${escapeHtml(cat.description)}</p>
              </div>
            </div>
            <span class="cat-count">${cat.metrics.length} audits</span>
          </div>
          <div class="audit-list">${rows}</div>
        </section>`
    })
    .join("")

  const embeddedJson = JSON.stringify(report).replace(/</g, "\\u003c")

  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>Guillotine Mini Backpressure Audit Report (${overallScore}/100)</title>
<style>
  :root {
    --bg: #f8f9fa;
    --surface: #ffffff;
    --surface-2: #f1f3f4;
    --border: #dadce0;
    --text: #202124;
    --muted: #5f6368;
    --pass: #0cce6b;
    --pass-text: #018642;
    --pass-bg: rgba(12, 206, 107, 0.12);
    --avg: #ffa400;
    --avg-text: #b85d00;
    --avg-bg: rgba(255, 164, 0, 0.14);
    --fail: #ff4e42;
    --fail-text: #c7221f;
    --fail-bg: rgba(255, 78, 66, 0.13);
    --accent: #0588f0;
    --mono: ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, monospace;
    --sans: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Inter, sans-serif;
  }
  [data-theme="dark"] {
    --bg: #111318;
    --surface: #181c23;
    --surface-2: #20252f;
    --border: #2c3340;
    --text: #e8eaed;
    --muted: #9aa0a6;
    --pass-text: #45e28d;
    --avg-text: #ffb938;
    --fail-text: #ff7970;
    --accent: #4aa8ff;
  }
  * { box-sizing: border-box; }
  body {
    margin: 0;
    background: var(--bg);
    color: var(--text);
    font-family: var(--sans);
    line-height: 1.5;
    -webkit-font-smoothing: antialiased;
  }
  a { color: var(--accent); text-decoration: none; }
  a:hover { text-decoration: underline; }
  code { font-family: var(--mono); font-size: 0.88em; background: var(--surface-2); padding: 0.1em 0.35em; border-radius: 4px; }

  .topbar {
    position: sticky; top: 0; z-index: 20;
    background: var(--surface);
    border-bottom: 1px solid var(--border);
    padding: 0.75rem 1.5rem;
    display: flex; align-items: center; justify-content: space-between; gap: 1rem; flex-wrap: wrap;
  }
  .brand { display: flex; align-items: center; gap: 0.75rem; }
  .brand-mark {
    width: 30px; height: 30px; border-radius: 8px;
    background: linear-gradient(135deg, #0588f0, #0cce6b);
    color: #fff; font-weight: 800; font-size: 0.9rem;
    display: grid; place-items: center; font-family: var(--mono);
  }
  .brand-title { font-weight: 700; font-size: 0.98rem; letter-spacing: -0.01em; }
  .brand-sub { font-size: 0.78rem; color: var(--muted); font-family: var(--mono); }
  .topbar-right { display: flex; align-items: center; gap: 0.6rem; flex-wrap: wrap; }
  .btn {
    border: 1px solid var(--border); background: var(--surface); color: var(--text);
    padding: 0.35rem 0.75rem; border-radius: 6px; font-size: 0.8rem; font-weight: 600;
    cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 0.35rem;
  }
  .btn:hover { background: var(--surface-2); text-decoration: none; }
  .trust-pill {
    padding: 0.25rem 0.65rem; border-radius: 999px; font-size: 0.72rem; font-weight: 700;
    font-family: var(--mono); letter-spacing: 0.03em;
  }
  .trust-sandbox { background: var(--pass-bg); color: var(--pass-text); border: 1px solid var(--pass); }
  .trust-maintainer { background: rgba(5, 136, 240, 0.14); color: var(--accent); border: 1px solid var(--accent); }
  .trust-untrusted { background: var(--avg-bg); color: var(--avg-text); border: 1px solid var(--avg); }

  .container { max-width: 1120px; margin: 0 auto; padding: 1.5rem; display: flex; flex-direction: column; gap: 1.5rem; }

  .hero-panel {
    background: var(--surface); border: 1px solid var(--border); border-radius: 14px;
    padding: 1.5rem; display: flex; flex-direction: column; gap: 1.25rem;
  }
  .hero-gauges {
    display: grid; grid-template-columns: 160px 1fr; gap: 1.5rem; align-items: center;
  }
  @media (max-width: 780px) { .hero-gauges { grid-template-columns: 1fr; } }
  .composite-box {
    display: flex; flex-direction: column; align-items: center; gap: 0.4rem;
    padding-right: 1.25rem; border-right: 1px solid var(--border);
  }
  @media (max-width: 780px) { .composite-box { border-right: 0; border-bottom: 1px solid var(--border); padding: 0 0 1rem 0; } }
  .composite-label { font-size: 0.82rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted); }
  .gauge-grid {
    display: grid; grid-template-columns: repeat(auto-fit, minmax(128px, 1fr)); gap: 0.75rem;
  }
  .lh-gauge-card {
    display: flex; flex-direction: column; align-items: center; gap: 0.45rem;
    padding: 0.75rem 0.5rem; border-radius: 10px; border: 1px solid transparent;
    color: var(--text); text-decoration: none; transition: background 0.15s, border-color 0.15s;
  }
  .lh-gauge-card:hover { background: var(--surface-2); border-color: var(--border); text-decoration: none; }
  .lh-gauge-label { font-size: 0.8rem; font-weight: 600; text-align: center; line-height: 1.25; }

  .lh-gauge-base { fill: none; opacity: 0.18; }
  .lh-gauge-arc { fill: none; stroke-linecap: round; transition: stroke-dashoffset 0.6s ease; }
  .lh-gauge-num { font-family: var(--mono); font-weight: 700; font-size: 22px; }
  .lh-gauge-svg.band-pass .lh-gauge-base, .lh-gauge-svg.band-pass .lh-gauge-arc { stroke: var(--pass); }
  .lh-gauge-svg.band-pass .lh-gauge-num { fill: var(--pass-text); }
  .lh-gauge-svg.band-average .lh-gauge-base, .lh-gauge-svg.band-average .lh-gauge-arc { stroke: var(--avg); }
  .lh-gauge-svg.band-average .lh-gauge-num { fill: var(--avg-text); }
  .lh-gauge-svg.band-fail .lh-gauge-base, .lh-gauge-svg.band-fail .lh-gauge-arc { stroke: var(--fail); }
  .lh-gauge-svg.band-fail .lh-gauge-num { fill: var(--fail-text); }

  .legend {
    display: flex; justify-content: center; gap: 1.5rem; flex-wrap: wrap;
    font-size: 0.78rem; color: var(--muted); border-top: 1px solid var(--border); padding-top: 0.85rem;
  }
  .legend-item { display: inline-flex; align-items: center; gap: 0.4rem; font-family: var(--mono); }
  .audit-glyph { display: inline-block; width: 11px; height: 11px; flex-shrink: 0; }
  .glyph-pass { border-radius: 50%; background: var(--pass); }
  .glyph-average { border-radius: 2px; background: var(--avg); }
  .glyph-fail { width: 0; height: 0; border-left: 6px solid transparent; border-right: 6px solid transparent; border-bottom: 11px solid var(--fail); background: transparent; }

  .trust-strip {
    display: grid; grid-template-columns: repeat(auto-fit, minmax(230px, 1fr)); gap: 0.85rem;
  }
  .meta-card {
    background: var(--surface); border: 1px solid var(--border); border-radius: 10px;
    padding: 0.9rem 1rem; display: flex; flex-direction: column; gap: 0.25rem;
  }
  .meta-card-k { font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted); font-weight: 700; }
  .meta-card-v { font-size: 0.95rem; font-weight: 700; font-family: var(--mono); }
  .meta-card-sub { font-size: 0.78rem; color: var(--muted); }

  .panel {
    background: var(--surface); border: 1px solid var(--border); border-radius: 12px; padding: 1.25rem;
  }
  .panel h2 { margin: 0 0 0.25rem 0; font-size: 1.05rem; }
  .panel-sub { margin: 0 0 1rem 0; font-size: 0.84rem; color: var(--muted); }

  .opp-row {
    display: flex; align-items: center; justify-content: space-between; gap: 1rem; flex-wrap: wrap;
    padding: 0.65rem 0; border-top: 1px solid var(--border);
  }
  .opp-main { display: flex; align-items: center; gap: 0.55rem; flex-wrap: wrap; }
  .opp-gain {
    background: var(--avg-bg); color: var(--avg-text); font-family: var(--mono);
    font-weight: 700; font-size: 0.78rem; padding: 0.15rem 0.45rem; border-radius: 5px; min-width: 40px; text-align: center;
  }
  .opp-cat {
    font-size: 0.72rem; font-family: var(--mono); text-transform: uppercase;
    background: var(--surface-2); color: var(--muted); padding: 0.15rem 0.45rem; border-radius: 4px;
  }
  .opp-name { font-size: 0.88rem; font-weight: 600; }
  .opp-meta { display: flex; align-items: center; gap: 0.75rem; }
  .opp-delta { font-family: var(--mono); font-size: 0.8rem; color: var(--muted); }
  .opp-bar { width: 110px; height: 8px; background: var(--surface-2); border-radius: 99px; overflow: hidden; }
  .opp-bar-fill { height: 100%; background: var(--avg); border-radius: 99px; }

  .controls {
    display: flex; align-items: center; justify-content: space-between; gap: 0.75rem; flex-wrap: wrap;
  }
  .filter-group { display: flex; gap: 0.4rem; flex-wrap: wrap; }
  .filter-btn {
    border: 1px solid var(--border); background: var(--surface); color: var(--text);
    padding: 0.35rem 0.75rem; border-radius: 999px; font-size: 0.8rem; font-weight: 600; cursor: pointer;
  }
  .filter-btn.active { background: var(--text); color: var(--surface); border-color: var(--text); }
  .search-input {
    border: 1px solid var(--border); background: var(--surface); color: var(--text);
    padding: 0.4rem 0.75rem; border-radius: 8px; font-size: 0.84rem; min-width: 240px;
  }

  .cat-section {
    background: var(--surface); border: 1px solid var(--border); border-radius: 12px; overflow: hidden;
  }
  .cat-header {
    padding: 1rem 1.25rem; border-bottom: 1px solid var(--border);
    display: flex; align-items: center; justify-content: space-between; gap: 1rem;
    background: var(--surface-2);
  }
  .cat-header-left { display: flex; align-items: center; gap: 0.9rem; }
  .cat-header h2 { margin: 0; font-size: 1.05rem; }
  .cat-header p { margin: 0.15rem 0 0 0; font-size: 0.82rem; color: var(--muted); }
  .cat-count { font-family: var(--mono); font-size: 0.78rem; color: var(--muted); }

  .audit-list { display: flex; flex-direction: column; }
  .audit-item { border-bottom: 1px solid var(--border); }
  .audit-item:last-child { border-bottom: 0; }
  .audit-item.hidden { display: none; }
  .audit-summary {
    list-style: none; cursor: pointer; padding: 0.8rem 1.25rem;
    display: flex; align-items: center; gap: 0.75rem;
  }
  .audit-summary::-webkit-details-marker { display: none; }
  .audit-summary:hover { background: var(--surface-2); }
  .audit-title-group { display: flex; flex-direction: column; flex: 1; min-width: 0; }
  .audit-title { font-weight: 600; font-size: 0.9rem; }
  .audit-display { font-size: 0.8rem; color: var(--muted); font-family: var(--mono); }
  .audit-right { display: flex; align-items: center; gap: 0.5rem; }
  .audit-weight { font-family: var(--mono); font-size: 0.72rem; color: var(--muted); }
  .audit-score {
    font-family: var(--mono); font-weight: 700; font-size: 0.78rem;
    padding: 0.15rem 0.5rem; border-radius: 6px; min-width: 36px; text-align: center;
  }
  .pill-pass { background: var(--pass-bg); color: var(--pass-text); }
  .pill-average { background: var(--avg-bg); color: var(--avg-text); }
  .pill-fail { background: var(--fail-bg); color: var(--fail-text); }

  .audit-body { padding: 0 1.25rem 1rem 2.75rem; }
  .audit-desc { margin: 0 0 0.75rem 0; font-size: 0.84rem; color: var(--muted); }
  .diag-pass-note { margin: 0; font-size: 0.82rem; color: var(--pass-text); }
  .diag-table-wrap { overflow-x: auto; }
  .diag-table { width: 100%; border-collapse: collapse; font-size: 0.8rem; }
  .diag-table th, .diag-table td { text-align: left; padding: 0.45rem 0.6rem; border-bottom: 1px solid var(--border); }
  .diag-table th { font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.04em; color: var(--muted); background: var(--surface-2); }
  .diag-more { margin: 0.5rem 0 0 0; font-size: 0.78rem; color: var(--muted); }
  .empty-ok { color: var(--pass-text); font-weight: 600; font-size: 0.88rem; }
  footer { text-align: center; font-size: 0.78rem; color: var(--muted); padding: 1rem 0 2rem 0; }
</style>
</head>
<body>
  <header class="topbar">
    <div class="brand">
      <div class="brand-mark">GM</div>
      <div>
        <div class="brand-title">evmts/guillotine-mini Backpressure Audit</div>
        <div class="brand-sub">${escapeHtml(telemetry.branch)} @ ${escapeHtml(telemetry.commitShort)} &middot; ${escapeHtml(report.generatedAt)}</div>
      </div>
    </div>
    <div class="topbar-right">
      <span class="trust-pill ${trustClass}">${trustLabel}</span>
      <a class="btn" href="https://smithers.sh/evmts/guillotine-mini" target="_blank" rel="noopener noreferrer">Smithers Factory</a>
      <a class="btn" href="https://mini.tevm.sh" target="_blank" rel="noopener noreferrer">Docs</a>
      <button class="btn" id="download-json" type="button">Download JSON</button>
      <button class="btn" id="theme-toggle" type="button">Dark mode</button>
    </div>
  </header>

  <main class="container">
    <section class="hero-panel">
      <div class="hero-gauges">
        <div class="composite-box">
          ${gaugeSvg(overallScore, 112, 9)}
          <div class="composite-label">Overall Score</div>
        </div>
        <div class="gauge-grid">${gaugeCards}</div>
      </div>
      <div class="legend">
        <span class="legend-item"><span class="audit-glyph glyph-fail"></span> 0-49 Failing (${failingMetrics})</span>
        <span class="legend-item"><span class="audit-glyph glyph-average"></span> 50-89 Opportunity (${warningMetrics})</span>
        <span class="legend-item"><span class="audit-glyph glyph-pass"></span> 90-100 Passing (${passingMetrics})</span>
      </div>
    </section>

    <section class="trust-strip">
      <div class="meta-card">
        <span class="meta-card-k">Execution Trust Tier</span>
        <span class="meta-card-v">${escapeHtml(attestation.tier)}</span>
        <span class="meta-card-sub">${escapeHtml(attestation.reasons[0] ?? "")}</span>
      </div>
      <div class="meta-card">
        <span class="meta-card-k">Shared Object Store</span>
        <span class="meta-card-v">${escapeHtml(attestation.cacheMode)} (build.smithers.sh)</span>
        <span class="meta-card-sub">Cache write allowed: ${attestation.cacheWriteAllowed ? "yes (trusted)" : "no (protected against poisoning)"}</span>
      </div>
      <div class="meta-card">
        <span class="meta-card-k">Merge Gate Authority</span>
        <span class="meta-card-v">${attestation.gateEligible ? "Authoritative" : "Informational only"}</span>
        <span class="meta-card-sub">Actor: ${escapeHtml(attestation.actor)} via ${escapeHtml(attestation.source)}</span>
      </div>
      <div class="meta-card">
        <span class="meta-card-k">Factory &amp; Formal Telemetry</span>
        <span class="meta-card-v">${telemetry.leanTheorems} Lean proofs &middot; ${telemetry.leanSorryCount} sorry</span>
        <span class="meta-card-sub">${telemetry.smithersPackages} Smithers packages &middot; ${telemetry.declaredFlows} flows &middot; ${telemetry.wikiPages} wiki notes</span>
      </div>
    </section>

    <section class="panel">
      <h2>Top Score Opportunities</h2>
      <p class="panel-sub">Highest-leverage changes ordered by weighted Lighthouse score gain across Uphill categories.</p>
      ${opportunityRows}
    </section>

    <section class="controls">
      <div class="filter-group" role="group" aria-label="Filter audits">
        <button class="filter-btn active" data-filter="all" type="button">All (${allMetrics.length})</button>
        <button class="filter-btn" data-filter="failed" type="button">Failed (${failingMetrics})</button>
        <button class="filter-btn" data-filter="opportunities" type="button">Opportunities (${warningMetrics})</button>
        <button class="filter-btn" data-filter="passed" type="button">Passed (${passingMetrics})</button>
      </div>
      <input class="search-input" id="audit-search" type="search" placeholder="Search metrics, files, or notes..." aria-label="Search audits" />
    </section>

    ${categorySections}

    <footer>
      Generated by Smithers Cloud Backpressure Audit (uphill ${escapeHtml(telemetry.uphillVersion)}) for evmts/guillotine-mini.
      Untrusted contributor runs are encouraged locally; only Smithers-controlled sandboxes and maintainers write the shared cache or satisfy merge gates.
    </footer>
  </main>

  <script id="audit-data" type="application/json">${embeddedJson}</script>
  <script>
    (() => {
      const root = document.documentElement;
      const themeBtn = document.getElementById("theme-toggle");
      const saved = localStorage.getItem("gm-audit-theme");
      const setTheme = (t) => {
        root.setAttribute("data-theme", t);
        localStorage.setItem("gm-audit-theme", t);
        themeBtn.textContent = t === "dark" ? "Light mode" : "Dark mode";
      };
      if (saved === "dark") setTheme("dark");
      themeBtn.addEventListener("click", () => setTheme(root.getAttribute("data-theme") === "dark" ? "light" : "dark"));

      document.getElementById("download-json").addEventListener("click", () => {
        const text = document.getElementById("audit-data").textContent || "{}";
        const blob = new Blob([text], { type: "application/json" });
        const url = URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = "guillotine-mini-audit-${escapeHtml(telemetry.commitShort)}.json";
        a.click();
        URL.revokeObjectURL(url);
      });

      let activeFilter = "all";
      const searchEl = document.getElementById("audit-search");
      const items = [...document.querySelectorAll(".audit-item")];
      const applyFilters = () => {
        const q = (searchEl.value || "").trim().toLowerCase();
        for (const el of items) {
          const st = el.getAttribute("data-status");
          const hay = el.getAttribute("data-search") || "";
          const matchStatus = activeFilter === "all" || st === activeFilter;
          const matchQuery = !q || hay.includes(q);
          el.classList.toggle("hidden", !(matchStatus && matchQuery));
        }
      };
      for (const btn of document.querySelectorAll(".filter-btn")) {
        btn.addEventListener("click", () => {
          for (const b of document.querySelectorAll(".filter-btn")) b.classList.remove("active");
          btn.classList.add("active");
          activeFilter = btn.getAttribute("data-filter") || "all";
          applyFilters();
        });
      }
      searchEl.addEventListener("input", applyFilters);
    })();
  </script>
</body>
</html>
`
}

export function renderMarkdownSummary(report: AuditReportDocument): string {
  const { overallScore, categories, opportunities, attestation, telemetry } = report
  const glyph = (s: number) => (s >= 90 ? "PASS" : s >= 50 ? "WARN" : "FAIL")
  const rows = categories
    .map((c) => `| ${c.title} | **${Math.round(c.score)} / 100** (${glyph(c.score)}) | ${c.metrics.length} audits |`)
    .join("\n")
  const oppLines = opportunities
    .slice(0, 5)
    .map((o) => `- **+${o.gain}** \`${o.category}/${o.metric}\`: ${formatMetricValue(o.value)} -> ${formatMetricValue(o.target)}`)
    .join("\n")

  return [
    `## Lighthouse Backpressure Audit (${overallScore} / 100)`,
    "",
    `Trust tier: \`${attestation.tier}\` | Shared cache: \`${attestation.cacheMode}\` | Merge gate: \`${attestation.gateEligible ? "authoritative" : "informational"}\` | Commit: \`${telemetry.commitShort}\``,
    "",
    "| Category | Score | Scope |",
    "| --- | --- | --- |",
    rows,
    "",
    "### Top Opportunities",
    "",
    oppLines || "- All tracked targets currently pass.",
    "",
    `Full interactive Lighthouse report: [mini.tevm.sh/audit](https://mini.tevm.sh/audit/) | Lean 4 oracle: **${telemetry.leanTheorems} theorems (${telemetry.leanSorryCount} sorry)** | Factory: **${telemetry.smithersPackages} packages, ${telemetry.declaredFlows} flows, ${telemetry.wikiPages} wiki notes**.`,
    "",
  ].join("\n")
}

export function loadOrRunUphill(root: string, skipUphill: boolean): { raw: UphillRawReport; bin: string | null } {
  const bin = findUphillBin()
  const reportPath = join(root, ".uphill/report.json")
  if (!skipUphill && bin) {
    const res = runCmd([bin, "--compact"], root)
    if (!res.ok && !existsSync(reportPath)) {
      throw new Error(`uphill failed: ${res.stderr || res.stdout}`)
    }
  }
  if (!existsSync(reportPath)) {
    throw new Error(`Missing ${reportPath}. Install uphill or run with an existing .uphill/report.json.`)
  }
  const raw = JSON.parse(readFileSync(reportPath, "utf8")) as UphillRawReport
  return { raw, bin }
}

if (import.meta.main) {
  const root = process.cwd()
  const forceUntrusted = process.argv.includes("--untrusted")
  const publishDocs = process.argv.includes("--publish-docs")
  const skipUphill = process.argv.includes("--skip-uphill")
  const verifyMode = process.argv.includes("--verify")

  const { raw, bin } = loadOrRunUphill(root, skipUphill)
  const telemetry = collectTelemetry(root, bin)
  const attestation = classifyExecution({
    forceUntrusted,
    sha: telemetry.commitFull,
    ref: telemetry.branch,
  })

  const report: AuditReportDocument = {
    schemaVersion: 1,
    repository: "evmts/guillotine-mini",
    generatedAt: attestation.timestamp,
    overallScore: computeOverallScore(raw.categories),
    attestation,
    telemetry,
    categories: raw.categories,
    opportunities: raw.opportunities,
    baselineChanges: Array.isArray(raw.changes) ? raw.changes.length : 0,
  }

  const auditDir = resolve(root, ".smithers/audit")
  mkdirSync(auditDir, { recursive: true })

  const html = renderLighthouseHtml(report)
  const jsonText = `${JSON.stringify(report, null, 2)}\n`
  const mdSummary = renderMarkdownSummary(report)

  writeFileSync(join(auditDir, "index.html"), html, "utf8")
  writeFileSync(join(auditDir, "report.json"), jsonText, "utf8")
  writeFileSync(join(auditDir, "latest.md"), mdSummary, "utf8")
  writeFileSync(join(auditDir, "pr-comment.md"), mdSummary, "utf8")

  if (publishDocs) {
    const docsAuditDir = resolve(root, "docs/public/audit")
    mkdirSync(docsAuditDir, { recursive: true })
    writeFileSync(join(docsAuditDir, "index.html"), html, "utf8")
    writeFileSync(join(docsAuditDir, "report.json"), jsonText, "utf8")
  }

  if (verifyMode) {
    if (!html.includes("<!DOCTYPE html>") || !html.includes("lh-gauge-svg") || report.categories.length === 0) {
      console.error("Audit report verification failed: missing Lighthouse gauges or categories")
      process.exit(1)
    }
  }

  console.log(
    `Generated Lighthouse Backpressure Audit: overall=${report.overallScore}/100 ` +
      `categories=${report.categories.length} tier=${attestation.tier} cache=${attestation.cacheMode}`
  )
}
