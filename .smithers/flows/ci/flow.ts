import { Flow } from "@smthrs/flow"
import { Node } from "@smthrs/plan"
import { CiJob } from "@smthrs/sandbox"
import { Schema } from "effect"

const factoryAndTrust = CiJob.make("factory-and-trust", {
  steps: [
    { name: "trust-and-auth-tests", run: "bun test ./.smithers/scripts/" },
    { name: "wiki-integrity", run: "bun .smithers/scripts/sync-wiki-feed.ts --check" },
    { name: "factory-plan", run: "npx --yes -p @smthrs/cli@1.0.0-rc.18 smthrs ci '//.smithers:factory-check' --plan" },
  ],
})

const tsSdk = CiJob.make("ts-sdk", {
  steps: [
    { name: "test-ts", run: "bun test ./ts/" },
  ],
})

const audit = CiJob.make("audit", {
  needs: ["factory-and-trust"],
  steps: [
    { name: "generate-audit", run: "bun .smithers/scripts/generate-audit-report.ts" },
  ],
})

export default Flow.make("ci", {
  description: "Run Smithers Cloud CI gates: factory trust tests, wiki integrity, TypeScript SDK suites, and Lighthouse audit.",
  payload: {
    run: Schema.String,
    repo: Schema.String,
    sha: Schema.String,
    ref: Schema.String,
    event: Schema.String,
  },
  success: Schema.Struct({
    factoryAndTrust: CiJob.Result,
    tsSdk: CiJob.Result,
    audit: CiJob.Result,
  }),
  body: (run) =>
    Node.all({
      factoryAndTrust: factoryAndTrust.call(run),
      tsSdk: tsSdk.call(run),
      audit: audit.call(run),
    }),
})
