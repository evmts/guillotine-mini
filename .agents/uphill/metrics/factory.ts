/**
 * Uphill metrics script for the `factory` category ("Factory & Trust").
 * Appends metric lines to $UPHILL_METRICS.
 */
import { appendFileSync, existsSync, readdirSync, readFileSync } from "node:fs"
import { join, relative } from "node:path"
import { renderHomeJson, validateHomeDocument } from "../../../.smithers/scripts/project-home.ts"
import { homeDocument } from "../../../.smithers/HOME.ts"

const outPath = process.env.UPHILL_METRICS
if (!outPath) {
  console.error("UPHILL_METRICS env var is not set")
  process.exit(1)
}

const root = process.cwd()
const lines: string[] = []
const q = (s: string) => JSON.stringify(s.replace(/[\r\n\t]+/g, " "))
const emit = (metric: string, item: string, value: string | number, _target?: string | number, note?: string) => {
  const safeItem = /\s/.test(item) ? q(item) : item
  const base = `${metric} ${safeItem} ${String(value)}`
  lines.push(note !== undefined ? `${base} note ${q(note)}` : base)
}

// 1. factory-projection-sync: home.json + factory.json validity & sync
{
  const homeErrors = validateHomeDocument(homeDocument)
  const homeJsonPath = join(root, ".smithers/home.json")
  const factoryJsonPath = join(root, ".smithers/factory.json")

  if (!existsSync(homeJsonPath)) {
    emit("factory-projection-sync", ".smithers/home.json", "fail", "pass", "missing .smithers/home.json")
  } else if (homeErrors.length > 0) {
    emit("factory-projection-sync", ".smithers/home.json", "fail", "pass", homeErrors[0]!)
  } else if (readFileSync(homeJsonPath, "utf8") !== renderHomeJson()) {
    emit("factory-projection-sync", ".smithers/home.json", "fail", "pass", "drifted from .smithers/HOME.ts")
  } else {
    emit("factory-projection-sync", ".smithers/home.json", "pass", "pass")
  }

  if (!existsSync(factoryJsonPath)) {
    emit("factory-projection-sync", ".smithers/factory.json", "fail", "pass", "missing .smithers/factory.json")
  } else {
    try {
      const parsed = JSON.parse(readFileSync(factoryJsonPath, "utf8")) as Record<string, unknown>
      const ok =
        typeof parsed.summary === "string" &&
        Array.isArray(parsed.flows) &&
        parsed.flows.length > 0 &&
        typeof parsed.github === "object" &&
        parsed.github !== null
      emit(
        "factory-projection-sync",
        ".smithers/factory.json",
        ok ? "pass" : "fail",
        "pass",
        ok ? undefined : "invalid factory.json structure"
      )
    } catch {
      emit("factory-projection-sync", ".smithers/factory.json", "fail", "pass", "invalid JSON")
    }
  }
}

// 2. trust-boundary-guard: cache write isolation, person-only approvals, no conflicting WORKSPACE.smithers
{
  const wsConflict = existsSync(join(root, ".smithers/WORKSPACE.smithers"))
  emit(
    "trust-boundary-guard",
    ".smithers/WORKSPACE.ts",
    wsConflict ? "fail" : "pass",
    "pass",
    wsConflict ? "conflicting .smithers/WORKSPACE.smithers exists" : undefined
  )

  const factoryPath = join(root, ".smithers/factory.json")
  if (existsSync(factoryPath)) {
    const f = JSON.parse(readFileSync(factoryPath, "utf8")) as {
      github?: { protectedPaths?: string[]; maintainers?: string[] }
      policy?: { approvals?: { approve?: string; merge?: string } }
    }
    const protectedOk =
      Array.isArray(f.github?.protectedPaths) &&
      f.github!.protectedPaths.includes("src/evm.zig") &&
      f.github!.protectedPaths.includes(".smithers") &&
      f.github!.protectedPaths.includes(".github")
    const personOnly =
      f.policy?.approvals?.approve === "person" && f.policy?.approvals?.merge === "person"
    emit(
      "trust-boundary-guard",
      ".smithers/FACTORY.ts",
      protectedOk && personOnly ? "pass" : "fail",
      "pass",
      protectedOk && personOnly ? undefined : "missing protectedPaths or person-only approval policy"
    )
  } else {
    emit("trust-boundary-guard", ".smithers/FACTORY.ts", "fail", "pass", "missing factory.json")
  }

  const ciPath = join(root, ".github/workflows/ci.yml")
  if (existsSync(ciPath)) {
    const ciText = readFileSync(ciPath, "utf8")
    // Ensure SMITHERS_CACHE_WRITE_TOKEN is gated on push to canonical main
    const hasUnconditionalWrite =
      /SMITHERS_CACHE_WRITE_TOKEN:\s*\$\{\{\s*secrets\.SMITHERS_CACHE_WRITE_TOKEN\s*\}\}/.test(ciText)
    emit(
      "trust-boundary-guard",
      ".github/workflows/ci.yml",
      hasUnconditionalWrite ? "fail" : "pass",
      "pass",
      hasUnconditionalWrite
        ? "SMITHERS_CACHE_WRITE_TOKEN must be gated on canonical main push, never unconditional"
        : undefined
    )
  }

  const releasePath = join(root, ".github/workflows/release.yml")
  if (existsSync(releasePath)) {
    const relText = readFileSync(releasePath, "utf8")
    const hasRepoGuard = relText.includes("head_repository.full_name == github.repository")
    const hasCiGate = relText.includes('workflows: ["CI"]')
    emit(
      "trust-boundary-guard",
      ".github/workflows/release.yml",
      hasRepoGuard && hasCiGate ? "pass" : "fail",
      "pass",
      hasRepoGuard && hasCiGate ? undefined : "release workflow must gate on canonical CI workflow_run"
    )
  } else {
    emit("trust-boundary-guard", ".github/workflows/release.yml", "fail", "pass", "missing automated release workflow")
  }
}

// 3. wiki-link-integrity: required Obsidian wiki notes and zero broken [[wikilinks]]
{
  const wikiDir = join(root, ".smithers/wiki")
  const requiredNotes = [
    "Overview.md",
    "Architecture.md",
    "Mythical-History.md",
    "Decisions.md",
    "Trust-and-Security.md",
    "Factory-and-Operations.md",
    "Backpressure-and-Quality.md",
  ]
  const mdFiles: string[] = []
  const walk = (dir: string) => {
    if (!existsSync(dir)) return
    for (const entry of readdirSync(dir, { withFileTypes: true })) {
      const full = join(dir, entry.name)
      if (entry.isDirectory()) walk(full)
      else if (entry.name.endsWith(".md")) mdFiles.push(full)
    }
  }
  walk(wikiDir)

  const relPaths = mdFiles.map((f) => relative(wikiDir, f).replace(/\\/g, "/"))
  const lowerPaths = new Set(relPaths.map((p) => p.toLowerCase()))
  const lowerStems = new Set(relPaths.map((p) => p.split("/").at(-1)!.replace(/\.md$/i, "").toLowerCase()))

  for (const req of requiredNotes) {
    const present = lowerPaths.has(req.toLowerCase())
    emit(
      "wiki-link-integrity",
      `.smithers/wiki/${req}`,
      present ? "pass" : "fail",
      "pass",
      present ? undefined : `missing required wiki page ${req}`
    )
  }

  for (const file of mdFiles) {
    const rel = relative(root, file).replace(/\\/g, "/")
    const content = readFileSync(file, "utf8")
    let fenced = false
    const broken: string[] = []
    for (const line of content.split("\n")) {
      if (/^\s*```/.test(line)) {
        fenced = !fenced
        continue
      }
      if (fenced) continue
      const stripped = line.replace(/`[^`]*`/g, "")
      const pattern = /\[\[([^\]|#]+)(?:#[^\]|]*)?(?:\|[^\]]*)?\]\]/g
      let match: RegExpExecArray | null
      while ((match = pattern.exec(stripped)) !== null) {
        const target = match[1]!.trim().toLowerCase()
        const withExt = target.endsWith(".md") ? target : `${target}.md`
        if (!lowerPaths.has(withExt) && !lowerPaths.has(target) && !lowerStems.has(target)) {
          broken.push(match[1]!.trim())
        }
      }
    }
    emit(
      "wiki-link-integrity",
      `links:${rel}`,
      broken.length === 0 ? "pass" : "fail",
      "pass",
      broken.length === 0 ? undefined : `broken wikilinks: ${broken.slice(0, 3).join(", ")}`
    )
  }
}

// 4. mcp-and-agent-readiness: .mcp.json, AGENTS.md, one-time auth script
{
  const checks: ReadonlyArray<readonly [string, (text: string) => boolean, string]> = [
    [
      ".mcp.json",
      (t) => t.includes("https://smithers.sh/evmts/guillotine-mini/mcp"),
      "must configure https://smithers.sh/evmts/guillotine-mini/mcp",
    ],
    [
      "AGENTS.md",
      (t) => t.includes("smithers.sh/evmts/guillotine-mini/mcp") && t.includes("jj"),
      "must document Smithers Cloud MCP and jj workflow",
    ],
    [
      ".smithers/scripts/mint-sandbox-auth.ts",
      (t) => t.includes("/api/attach/") && t.includes("one-time"),
      "must support one-time sandbox auth minting",
    ],
  ]

  for (const [rel, pred, note] of checks) {
    const full = join(root, rel)
    if (!existsSync(full)) {
      emit("mcp-and-agent-readiness", rel, "fail", "pass", `missing ${rel}`)
    } else {
      const ok = pred(readFileSync(full, "utf8"))
      emit("mcp-and-agent-readiness", rel, ok ? "pass" : "fail", "pass", ok ? undefined : note)
    }
  }
}

appendFileSync(outPath, `${lines.join("\n")}\n`, "utf8")
