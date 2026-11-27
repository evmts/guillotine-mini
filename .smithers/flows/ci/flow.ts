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

const clientTs = CiJob.make("client-ts", {
  steps: [
    { name: "install-client-ts", run: "cd client-ts && bun install --frozen-lockfile" },
    { name: "test-client-ts", run: "cd client-ts && bun run test" },
    { name: "test-exex", run: "bun test ./ts/exex/manager.test.ts" },
  ],
})

const audit = CiJob.make("audit", {
  needs: ["factory-and-trust"],
  steps: [
    { name: "generate-audit", run: "bun .smithers/scripts/generate-audit-report.ts" },
  ],
})

export default Flow.make("ci", {
  description: "Run Smithers Cloud CI gates: factory trust tests, wiki integrity, TypeScript client suites, and Lighthouse audit.",
  payload: {
    run: Schema.String,
    repo: Schema.String,
    sha: Schema.String,
    ref: Schema.String,
    event: Schema.String,
  },
  success: Schema.Struct({
    factoryAndTrust: CiJob.Result,
    clientTs: CiJob.Result,
    audit: CiJob.Result,
  }),
  body: (run) =>
    Node.all({
      factoryAndTrust: factoryAndTrust.call(run),
      clientTs: clientTs.call(run),
      audit: audit.call(run),
    }),
})
