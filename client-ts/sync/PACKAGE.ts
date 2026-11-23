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
    "client-ts/sync",
    "client-ts/sync/Sync.bench.ts",
  ],
  env: { BENCH_JSON_OUT: "client-ts/sync/.bench-result.json" },
  data: [srcs, S.file("//scripts/run-client-ts-bench.ts"), S.file("//scripts/bench-ts-utils.ts")],
  outFiles: [".bench-result.json"],
  exclusive: true,
  sandbox: "none",
})

const test = S.Shell.Test({
  bin: S.Host.bin("bun"),
  args: ["--cwd", "client-ts", "exec", "vitest", "run", "sync"],
  data: [srcs],
  sandbox: "none",
})

export const Package = S.Package({
  targets: { srcs, bench, test },
})
