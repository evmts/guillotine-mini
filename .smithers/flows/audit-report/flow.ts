import { Flow } from "@smthrs/flow"
import { Node } from "@smthrs/plan"
import { CiJob } from "@smthrs/sandbox"
import { Schema } from "effect"

const auditReport = CiJob.make("audit-report", {
  steps: [
    { name: "verify-trust-policy", run: "bun .smithers/scripts/trust-policy.ts" },
    { name: "run-lighthouse-audit", run: "bun .smithers/scripts/generate-audit-report.ts --verify" },
  ],
})

export default Flow.make("audit-report", {
  description: "Generate the Lighthouse-style Backpressure Audit Report (HTML, JSON, and Markdown) with trust attestation.",
  payload: {
    run: Schema.String,
    repo: Schema.String,
    sha: Schema.String,
    ref: Schema.String,
    event: Schema.String,
  },
  success: Schema.Struct({ auditReport: CiJob.Result }),
  body: (run) => Node.all({ auditReport: auditReport.call(run) }),
})
