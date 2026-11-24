import { Smithers as S } from "@smthrs/targets"
import { Package as clientTsPkg } from "../PACKAGE.ts"
const config_srcs = clientTsPkg.config_srcs

const srcs = S.Filegroup({
  srcs: [...S.glob(["**/*.ts"]), config_srcs],
})

const bench = S.Shell.Test({
  bin: S.Host.bin("bun"),
  args: [
    "scripts/run-client-ts-bench.ts",
    "client-ts/network",
    "client-ts/network/Network.bench.ts",
  ],
  env: { BENCH_JSON_OUT: "client-ts/network/.bench-result.json" },
  data: [srcs, S.file("//scripts/run-client-ts-bench.ts"), S.file("//scripts/bench-ts-utils.ts")],
  exclusive: true,
  sandbox: "none",
})

const test = S.Shell.Test({
  shell: "cd client-ts && bun x vitest run network",
  tools: [S.Host.bin("bun")],
  data: [srcs],
  sandbox: "none",
})

export const Package = S.Package({
  targets: { srcs, bench, test },
})
