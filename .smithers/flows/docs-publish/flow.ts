import { Flow } from "@smthrs/flow"
import { Node } from "@smthrs/plan"
import { CiJob } from "@smthrs/sandbox"
import { Schema } from "effect"

const docsBuild = CiJob.make("docs-build", {
  steps: [
    { name: "refresh-audit-page", run: "bun .smithers/scripts/generate-audit-report.ts --publish-docs" },
    { name: "install-docs", run: "cd docs && npm ci" },
    { name: "build-docs", run: "cd docs && npm run build" },
    { name: "verify-llms-and-audit", run: "test -s docs/dist/public/llms.txt && test -s docs/dist/public/audit/index.html" },
  ],
})

export default Flow.make("docs-publish", {
  description: "Rebuild the mini.tevm.sh Vocs documentation site with fresh llms.txt and Lighthouse audit report.",
  payload: {
    run: Schema.String,
    repo: Schema.String,
    sha: Schema.String,
    ref: Schema.String,
    event: Schema.String,
  },
  success: Schema.Struct({ docsBuild: CiJob.Result }),
  body: (run) => Node.all({ docsBuild: docsBuild.call(run) }),
})
