#!/usr/bin/env bun
/**
 * Projects .smithers/HOME.ts into .smithers/home.json and strictly validates
 * the projected document against the @smthrs/views Home specification
 * (sections/blocks limits, allowed audiences, no HTML in prose, safe URLs,
 * valid block types, and clean public copy without semicolons or em dashes).
 *
 * Usage:
 *   bun .smithers/scripts/project-home.ts --write
 *   bun .smithers/scripts/project-home.ts --check
 */

import { existsSync, readFileSync, writeFileSync } from "node:fs"
import { resolve } from "node:path"
import { homeDocument } from "../HOME.ts"

const MAX_SECTIONS = 8
const MAX_BLOCKS = 32
const MAX_TITLE = 120
const MAX_LINE = 280
const MAX_TEXT = 4096
const MAX_URL = 2048
const HTML_PATTERN = /<\/?[A-Za-z!?]/
const VALID_AUDIENCES = new Set(["everyone", "contributor", "maintainer"])
const VALID_CONTRIBUTORS = new Set(["role", "anyone"])
const VALID_BLOCK_TYPES = new Set([
  "text",
  "links",
  "flows",
  "prompt",
  "markdown",
  "stack",
  "app",
  "view",
  "hero",
  "code",
  "cards",
  "stats",
  "releases",
  "issues",
  "runs",
  "action",
])

export function validateHomeDocument(doc: unknown): string[] {
  const errors: string[] = []
  if (typeof doc !== "object" || doc === null || Array.isArray(doc)) {
    return ["Home document must be a JSON object"]
  }
  const d = doc as Record<string, unknown>

  if (d.docs !== undefined) {
    if (typeof d.docs !== "string" || !/^https:\/\/[^\s<>"'@]+$/i.test(d.docs) || d.docs.length > MAX_URL) {
      errors.push(`Invalid docs URL: ${String(d.docs)}`)
    }
  }
  if (d.contributors !== undefined && (typeof d.contributors !== "string" || !VALID_CONTRIBUTORS.has(d.contributors))) {
    errors.push(`Invalid contributors rule: ${String(d.contributors)}`)
  }
  if (!Array.isArray(d.sections) || d.sections.length === 0) {
    errors.push("Home document must declare a non-empty sections array")
    return errors
  }
  if (d.sections.length > MAX_SECTIONS) {
    errors.push(`Too many sections: ${d.sections.length} > ${MAX_SECTIONS}`)
  }

  let totalBlocks = 0
  const checkText = (value: unknown, where: string, maxLen: number, allowNewlines = false) => {
    if (typeof value !== "string" || value.length === 0) {
      errors.push(`${where}: must be a non-empty string`)
      return
    }
    if (value.length > maxLen) errors.push(`${where}: length ${value.length} exceeds ${maxLen}`)
    if (!allowNewlines && /[\r\n]/.test(value)) errors.push(`${where}: must be single-line`)
    if (HTML_PATTERN.test(value)) errors.push(`${where}: must not contain HTML`)
    if (value.includes(";") || value.includes("\u2014")) {
      errors.push(`${where}: public copy must not contain semicolons or em dashes`)
    }
  }

  const checkUrl = (value: unknown, where: string) => {
    if (typeof value !== "string" || value.length === 0 || value.length > MAX_URL) {
      errors.push(`${where}: invalid URL length`)
      return
    }
    if (!/^(?:https?:\/\/(?![/?#])|\/(?!\/))/i.test(value)) {
      errors.push(`${where}: URL must be http(s) or origin-relative`)
    }
  }

  for (let si = 0; si < d.sections.length; si++) {
    const section = d.sections[si] as Record<string, unknown>
    if (section.title !== undefined) checkText(section.title, `sections[${si}].title`, MAX_TITLE)
    if (section.audience !== undefined && !VALID_AUDIENCES.has(String(section.audience))) {
      errors.push(`sections[${si}].audience invalid: ${String(section.audience)}`)
    }
    if (!Array.isArray(section.blocks) || section.blocks.length === 0) {
      errors.push(`sections[${si}].blocks must be a non-empty array`)
      continue
    }
    for (let bi = 0; bi < section.blocks.length; bi++) {
      totalBlocks++
      const block = section.blocks[bi] as Record<string, unknown>
      const loc = `sections[${si}].blocks[${bi}]`
      if (typeof block.type !== "string" || !VALID_BLOCK_TYPES.has(block.type)) {
        errors.push(`${loc}: unknown block type ${String(block.type)}`)
        continue
      }
      if (block.title !== undefined) checkText(block.title, `${loc}.title`, MAX_TITLE)
      if (block.type === "hero") {
        checkText(block.title, `${loc}.title`, MAX_TITLE)
        if (block.tagline !== undefined) checkText(block.tagline, `${loc}.tagline`, MAX_LINE)
        if (block.text !== undefined) checkText(block.text, `${loc}.text`, MAX_LINE)
        if (Array.isArray(block.actions)) {
          if (block.actions.length > 3) errors.push(`${loc}.actions: max 3 actions`)
          block.actions.forEach((a: Record<string, unknown>, ai: number) => {
            checkText(a.label, `${loc}.actions[${ai}].label`, MAX_TITLE)
            checkUrl(a.url, `${loc}.actions[${ai}].url`)
          })
        }
      } else if (block.type === "text") {
        checkText(block.text, `${loc}.text`, MAX_TEXT, true)
      } else if (block.type === "links" && Array.isArray(block.links)) {
        block.links.forEach((l: Record<string, unknown>, li: number) => {
          checkText(l.label, `${loc}.links[${li}].label`, MAX_TITLE)
          checkUrl(l.url, `${loc}.links[${li}].url`)
        })
      } else if (block.type === "cards" && Array.isArray(block.cards)) {
        if (block.cards.length > 12) errors.push(`${loc}.cards: max 12 cards`)
        block.cards.forEach((c: Record<string, unknown>, ci: number) => {
          checkText(c.title, `${loc}.cards[${ci}].title`, MAX_TITLE)
          if (c.text !== undefined) checkText(c.text, `${loc}.cards[${ci}].text`, MAX_LINE)
          if (c.label !== undefined) checkText(c.label, `${loc}.cards[${ci}].label`, MAX_TITLE)
          if (c.url !== undefined) checkUrl(c.url, `${loc}.cards[${ci}].url`)
        })
      } else if (block.type === "stats" && Array.isArray(block.stats)) {
        if (block.stats.length > 6) errors.push(`${loc}.stats: max 6 stats`)
        block.stats.forEach((s: Record<string, unknown>, sti: number) => {
          checkText(s.value, `${loc}.stats[${sti}].value`, MAX_TITLE)
          checkText(s.label, `${loc}.stats[${sti}].label`, MAX_TITLE)
        })
      } else if (block.type === "releases" && Array.isArray(block.releases)) {
        block.releases.forEach((r: Record<string, unknown>, ri: number) => {
          checkText(r.name, `${loc}.releases[${ri}].name`, MAX_TITLE)
          checkUrl(r.url, `${loc}.releases[${ri}].url`)
          if (typeof r.date !== "string" || !/^\d{4}-\d{2}-\d{2}$/.test(r.date)) {
            errors.push(`${loc}.releases[${ri}].date must be YYYY-MM-DD`)
          }
          if (r.summary !== undefined) checkText(r.summary, `${loc}.releases[${ri}].summary`, MAX_LINE)
        })
      } else if (block.type === "markdown") {
        if (typeof block.path !== "string" || block.path.startsWith("/") || block.path.includes("..")) {
          errors.push(`${loc}.path must be a safe repo-relative path`)
        }
      }
    }
  }

  if (totalBlocks > MAX_BLOCKS) {
    errors.push(`Total blocks ${totalBlocks} exceeds maximum ${MAX_BLOCKS}`)
  }

  return errors
}

export const renderHomeJson = (): string => `${JSON.stringify(homeDocument, null, 2)}\n`

if (import.meta.main) {
  const mode = process.argv.includes("--write") ? "write" : "check"
  const errors = validateHomeDocument(homeDocument)
  if (errors.length > 0) {
    console.error("HOME.ts validation failed:")
    for (const err of errors) console.error(`  - ${err}`)
    process.exit(1)
  }

  const outPath = resolve(import.meta.dir, "../home.json")
  const expected = renderHomeJson()

  if (mode === "write") {
    writeFileSync(outPath, expected, "utf8")
    console.log(`Wrote ${outPath} (${homeDocument.sections.length} sections, valid @smthrs/views schema)`)
  } else {
    if (!existsSync(outPath)) {
      console.error(`Missing ${outPath}; run bun .smithers/scripts/project-home.ts --write`)
      process.exit(1)
    }
    const actual = readFileSync(outPath, "utf8")
    if (actual !== expected) {
      console.error(`.smithers/home.json drifted from .smithers/HOME.ts; run bun .smithers/scripts/project-home.ts --write`)
      process.exit(1)
    }
    console.log(`.smithers/home.json matches .smithers/HOME.ts (${homeDocument.sections.length} audience sections)`)
  }
}
