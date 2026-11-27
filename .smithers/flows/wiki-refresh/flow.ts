import { Flow } from "@smthrs/flow"
import { Node } from "@smthrs/plan"
import { CiJob } from "@smthrs/sandbox"
import { Schema } from "effect"

const wikiRefresh = CiJob.make("wiki-refresh", {
  steps: [
    { name: "validate-wiki-and-history", run: "bun .smithers/scripts/sync-wiki-feed.ts --check" },
    { name: "emit-wiki-feed", run: "bun .smithers/scripts/sync-wiki-feed.ts --out .smithers/reports/wiki-feed.json" },
  ],
})

export default Flow.make("wiki-refresh", {
  description: "Validate Obsidian wikilinks, refresh Mythical History metadata, and build the Smithers Cloud wiki feed bundle.",
  payload: {
    run: Schema.String,
    repo: Schema.String,
    sha: Schema.String,
    ref: Schema.String,
    event: Schema.String,
  },
  success: Schema.Struct({ wikiRefresh: CiJob.Result }),
  body: (run) => Node.all({ wikiRefresh: wikiRefresh.call(run) }),
})
