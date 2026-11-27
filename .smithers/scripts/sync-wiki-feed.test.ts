import { describe, expect, test } from "bun:test"
import { resolve } from "node:path"
import {
  buildWikiFeedPayload,
  extractWikilinks,
  loadAndValidateWiki,
  parseFrontmatter,
} from "./sync-wiki-feed.ts"

describe("Obsidian Wiki validator and Smithers Cloud feed builder", () => {
  test("parses YAML frontmatter title and tags", () => {
    const parsed = parseFrontmatter("---\ntitle: Test Note\ntags: [evm, zig, smithers]\n---\n\n# Body\n")
    expect(parsed.title).toBe("Test Note")
    expect(parsed.tags).toEqual(["evm", "zig", "smithers"])
    expect(parsed.body).toContain("# Body")
  })

  test("extracts wikilinks outside fenced code blocks only", () => {
    const md = [
      "See [[Architecture]] and [[Decisions|ADRs]] and [[Overview#Map]].",
      "```md",
      "[[NotALinkInsideCode]]",
      "```",
      "Also [[Mythical-History]].",
    ].join("\n")
    expect(extractWikilinks(md)).toEqual(["Architecture", "Decisions", "Overview", "Mythical-History"])
  })

  test("validates repository .smithers/wiki with zero broken links and builds feed payload", () => {
    const wikiDir = resolve(import.meta.dir, "../wiki")
    const result = loadAndValidateWiki(wikiDir, "2026-11-27T00:00:00.000Z")

    expect(result.missingRequired).toEqual([])
    expect(result.brokenLinks).toEqual([])
    expect(result.ok).toBe(true)
    expect(result.notes.length).toBeGreaterThanOrEqual(8)

    const overview = result.notes.find((n) => n.path === "Overview.md")
    expect(overview).toBeDefined()
    expect(overview!.linksOut.length).toBeGreaterThanOrEqual(6)
    expect(overview!.backlinks.length).toBeGreaterThanOrEqual(5)

    const payload = buildWikiFeedPayload(result.notes)
    expect(payload.name).toBe("wiki")
    expect(payload.visibility).toBe("public")
    expect(payload.body.notes.length).toBe(result.notes.length)
  })
})
