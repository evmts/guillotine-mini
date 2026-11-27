import { Flow } from "@smthrs/flow"
import { Node } from "@smthrs/plan"
import { CiJob } from "@smthrs/sandbox"
import { Schema } from "effect"

const releaseVerify = CiJob.make("release-verify", {
  steps: [
    { name: "verify-factory", run: "bun test ./.smithers/scripts/" },
    { name: "verify-wiki", run: "bun .smithers/scripts/sync-wiki-feed.ts --check" },
    { name: "verify-audit", run: "bun .smithers/scripts/generate-audit-report.ts --verify" },
  ],
})

export default Flow.make("release", {
  description: "Verify release readiness, reproducible native/WASM manifests, checksums, and docs before GitHub Release publication.",
  payload: {
    run: Schema.String,
    repo: Schema.String,
    sha: Schema.String,
    ref: Schema.String,
    event: Schema.String,
  },
  success: Schema.Struct({ releaseVerify: CiJob.Result }),
  body: (run) => Node.all({ releaseVerify: releaseVerify.call(run) }),
})
