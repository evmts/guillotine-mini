import { Flow } from "@smthrs/flow"
import { Node } from "@smthrs/plan"
import { CiJob } from "@smthrs/sandbox"
import { Schema } from "effect"

const uphill = CiJob.make("uphill", {
  steps: [{ name: "uphill-audit", run: "sh .smithers/scripts/hosted-uphill.sh" }],
})

export default Flow.make("uphill", {
  description: "Run Uphill continuous metrics and generate the Lighthouse-style backpressure audit report.",
  payload: {
    run: Schema.String,
    repo: Schema.String,
    sha: Schema.String,
    ref: Schema.String,
    event: Schema.String,
  },
  success: Schema.Struct({ uphill: CiJob.Result }),
  body: (run) => Node.all({ uphill: uphill.call(run) }),
})
