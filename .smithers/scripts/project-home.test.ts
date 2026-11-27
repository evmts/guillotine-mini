import { describe, expect, test } from "bun:test"
import { homeDocument } from "../HOME.ts"
import { renderHomeJson, validateHomeDocument } from "./project-home.ts"

describe("HOME.ts personalized Smithers Cloud UI projection", () => {
  test("validates maintainer, contributor, and viewer sections cleanly", () => {
    expect(validateHomeDocument(homeDocument)).toEqual([])
    expect(homeDocument.docs).toBe("https://mini.tevm.sh/llms.txt")
    expect(homeDocument.contributors).toBe("role")
    expect(homeDocument.sections.map((s) => s.audience)).toEqual([
      "maintainer",
      "contributor",
      "everyone",
    ])
  })

  test("rejects HTML tags, semicolons, and em dashes in public copy", () => {
    const bad = {
      docs: "https://mini.tevm.sh/llms.txt",
      sections: [
        {
          audience: "everyone",
          blocks: [
            { type: "text", title: "Bad — title", text: "<b>no html</b>; bad" },
          ],
        },
      ],
    }
    const errs = validateHomeDocument(bad)
    expect(errs.length).toBeGreaterThanOrEqual(2)
  })

  test("renders canonical 2-space indented JSON with trailing newline", () => {
    const json = renderHomeJson()
    expect(json.endsWith("\n")).toBe(true)
    expect(JSON.parse(json).docs).toBe("https://mini.tevm.sh/llms.txt")
  })
})
