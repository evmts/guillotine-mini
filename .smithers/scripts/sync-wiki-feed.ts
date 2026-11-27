#!/usr/bin/env bun
/**
 * Obsidian-compatible Wiki validator and Smithers Cloud `wiki` feed publisher
 * for evmts/guillotine-mini.
 *
 * Mirrors the exact frontmatter and [[wikilink]] rules in apps/mvp/plugins/wiki/src/model.ts:
 * - Reads all Markdown notes under .smithers/wiki/
 * - Verifies all required core notes exist (including Mythical-History.md)
 * - Verifies zero broken [[wikilinks]] outside fenced code blocks
 * - Computes outgoing links and backlinks
 * - Emits a Smithers Cloud `wiki` feed document `{ name: "wiki", visibility: "public", body: { notes } }`
 * - Optionally pushes to POST https://smithers.sh/api/repos/evmts/guillotine-mini/feeds
 *   when `--push` is passed with `SMITHERS_FEED_KEY` in a trusted maintainer environment.
 *
 * Usage:
 *   bun .smithers/scripts/sync-wiki-feed.ts --check
 *   bun .smithers/scripts/sync-wiki-feed.ts --out .smithers/reports/wiki-feed.json
 *   bun .smithers/scripts/sync-wiki-feed.ts --push
 */

import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from "node:fs"
import { dirname, join, relative, resolve } from "node:path"
import { canWriteSharedCache, classifyExecution } from "./trust-policy.ts"

export const REQUIRED_WIKI_NOTES: ReadonlyArray<string> = [
  "Overview.md",
  "Architecture.md",
  "Mythical-History.md",
  "Hardforks-and-Specs.md",
  "Decisions.md",
  "Trust-and-Security.md",
  "Factory-and-Operations.md",
  "Backpressure-and-Quality.md",
]

export interface WikiFeedNote {
  readonly path: string
  readonly title: string
  readonly markdown: string
  readonly tags: ReadonlyArray<string>
  readonly linksOut: ReadonlyArray<string>
  readonly backlinks: ReadonlyArray<string>
  readonly updatedAt: string
}

export interface WikiValidationResult {
  readonly ok: boolean
  readonly notes: ReadonlyArray<WikiFeedNote>
  readonly missingRequired: ReadonlyArray<string>
  readonly brokenLinks: ReadonlyArray<{ readonly from: string; readonly target: string }>
}

const stemOf = (path: string): string => path.split("/").at(-1)!.replace(/\.md$/i, "")

export function parseFrontmatter(source: string): {
  readonly title?: string
  readonly tags: ReadonlyArray<string>
  readonly body: string
} {
  if (!source.startsWith("---\n") && !source.startsWith("---\r\n")) {
    return { tags: [], body: source }
  }
  const end = source.indexOf("\n---", 3)
  if (end === -1) return { tags: [], body: source }
  const header = source.slice(4, end)
  const body = source.slice(end + 4).replace(/^\r?\n/, "")
  let title: string | undefined
  const tags: string[] = []
  for (const rawLine of header.split(/\r?\n/)) {
    const line = rawLine.trim()
    if (line.startsWith("title:")) {
      const value = line.slice("title:".length).trim().replace(/^["']|["']$/g, "")
      if (value !== "") title = value
    } else if (line.startsWith("tags:")) {
      const value = line.slice("tags:".length).trim().replace(/^\[|\]$/g, "")
      for (const tag of value.split(",")) {
        const clean = tag.trim().replace(/^["']|["']$/g, "")
        if (clean !== "") tags.push(clean)
      }
    }
  }
  return { title, tags, body }
}

export function extractWikilinks(markdown: string): ReadonlyArray<string> {
  const targets: string[] = []
  let fenced = false
  for (const line of markdown.split("\n")) {
    if (/^\s*```/.test(line)) {
      fenced = !fenced
      continue
    }
    if (fenced) continue
    const stripped = line.replace(/`[^`]*`/g, "")
    const pattern = /\[\[([^\]|#]+)(?:#[^\]|]*)?(?:\|[^\]]*)?\]\]/g
    let match: RegExpExecArray | null
    while ((match = pattern.exec(stripped)) !== null) {
      const target = match[1]!.trim()
      if (target !== "" && !targets.includes(target)) targets.push(target)
    }
  }
  return targets
}

export function loadAndValidateWiki(wikiDir: string, nowIso = new Date().toISOString()): WikiValidationResult {
  const files: string[] = []
  const walk = (dir: string) => {
    if (!existsSync(dir)) return
    for (const entry of readdirSync(dir, { withFileTypes: true })) {
      const full = join(dir, entry.name)
      if (entry.isDirectory()) walk(full)
      else if (entry.name.endsWith(".md")) files.push(full)
    }
  }
  walk(wikiDir)

  const rawEntries = files
    .map((file) => {
      const rel = relative(wikiDir, file).replace(/\\/g, "/")
      const raw = readFileSync(file, "utf8")
      const fm = parseFrontmatter(raw)
      return {
        path: rel,
        title: fm.title ?? stemOf(rel),
        tags: fm.tags,
        markdown: raw,
        body: fm.body,
      }
    })
    .sort((a, b) => a.path.localeCompare(b.path))

  const allPaths = rawEntries.map((e) => e.path)
  const lowerPathSet = new Set(allPaths.map((p) => p.toLowerCase()))

  const missingRequired = REQUIRED_WIKI_NOTES.filter((req) => !lowerPathSet.has(req.toLowerCase()))

  const resolveTarget = (target: string): string | undefined => {
    const lower = target.toLowerCase()
    const withExt = lower.endsWith(".md") ? lower : `${lower}.md`
    return (
      allPaths.find((p) => p.toLowerCase() === withExt || p.toLowerCase() === lower) ??
      allPaths.find((p) => stemOf(p).toLowerCase() === lower)
    )
  }

  const brokenLinks: Array<{ readonly from: string; readonly target: string }> = []
  const incoming = new Map<string, string[]>()

  const intermediate = rawEntries.map((entry) => {
    const rawTargets = extractWikilinks(entry.body)
    const linksOut: string[] = []
    for (const t of rawTargets) {
      const resolved = resolveTarget(t)
      if (!resolved) {
        brokenLinks.push({ from: entry.path, target: t })
      } else if (resolved !== entry.path && !linksOut.includes(resolved)) {
        linksOut.push(resolved)
        const list = incoming.get(resolved) ?? []
        list.push(entry.path)
        incoming.set(resolved, list)
      }
    }
    return { ...entry, linksOut }
  })

  const notes: WikiFeedNote[] = intermediate.map((entry) => ({
    path: entry.path,
    title: entry.title,
    markdown: entry.markdown,
    tags: entry.tags,
    linksOut: entry.linksOut,
    backlinks: incoming.get(entry.path) ?? [],
    updatedAt: nowIso,
  }))

  return {
    ok: missingRequired.length === 0 && brokenLinks.length === 0 && notes.length > 0,
    notes,
    missingRequired,
    brokenLinks,
  }
}

export function buildWikiFeedPayload(notes: ReadonlyArray<WikiFeedNote>) {
  return {
    name: "wiki",
    visibility: "public" as const,
    body: {
      notes: notes.map((n) => ({
        path: n.path,
        title: n.title,
        markdown: n.markdown,
        tags: n.tags,
        updatedAt: n.updatedAt,
      })),
    },
  }
}

if (import.meta.main) {
  const args = process.argv.slice(2)
  const wikiDir = resolve(process.cwd(), ".smithers/wiki")
  const result = loadAndValidateWiki(wikiDir)

  if (!result.ok) {
    console.error("Wiki validation failed:")
    for (const m of result.missingRequired) console.error(`  - Missing required page: .smithers/wiki/${m}`)
    for (const b of result.brokenLinks) console.error(`  - Broken wikilink in ${b.from}: [[${b.target}]]`)
    process.exit(1)
  }

  const totalLinks = result.notes.reduce((sum, n) => sum + n.linksOut.length, 0)
  console.log(`Wiki valid: ${result.notes.length} notes, ${totalLinks} resolved wikilinks, 0 broken.`)

  const outIdx = args.indexOf("--out")
  if (outIdx !== -1 && args[outIdx + 1]) {
    const outPath = resolve(process.cwd(), args[outIdx + 1]!)
    mkdirSync(dirname(outPath), { recursive: true })
    const payload = buildWikiFeedPayload(result.notes)
    writeFileSync(outPath, `${JSON.stringify(payload, null, 2)}\n`, "utf8")
    console.log(`Wrote Smithers Cloud wiki feed bundle to ${outPath}`)
  }

  if (args.includes("--push")) {
    const attestation = classifyExecution()
    if (!canWriteSharedCache(attestation)) {
      console.error(`Refusing to push wiki feed from untrusted tier (${attestation.tier}).`)
      process.exit(1)
    }
    const feedKey = process.env.SMITHERS_FEED_KEY?.trim()
    if (!feedKey) {
      console.error("SMITHERS_FEED_KEY is not set; skipping remote feed push.")
      process.exit(1)
    }
    const origin = (process.env.SMITHERS_ORIGIN ?? "https://smithers.sh").replace(/\/+$/, "")
    const url = `${origin}/api/repos/evmts/guillotine-mini/feeds`
    const res = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${feedKey}`,
        "User-Agent": "guillotine-mini-factory/1.0",
      },
      body: JSON.stringify(buildWikiFeedPayload(result.notes)),
    })
    if (!res.ok) {
      console.error(`Failed to push wiki feed: HTTP ${res.status}`)
      process.exit(1)
    }
    console.log(`Published ${result.notes.length} wiki notes to ${url}`)
  }
}
