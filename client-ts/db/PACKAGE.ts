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
    "client-ts/db",
    "client-ts/db/Db.bench.ts",
    "client-ts/db/DbIterator.bench.ts",
  ],
  env: { BENCH_JSON_OUT: "client-ts/db/.bench-result.json" },
  data: [srcs, S.file("//scripts/run-client-ts-bench.ts")],
  outFiles: [".bench-result.json"],
  exclusive: true,
  sandbox: "none",
})

const test = S.Shell.Test({
  bin: S.Host.bin("bun"),
  args: ["--cwd", "client-ts", "exec", "vitest", "run", "db"],
  data: [srcs],
  sandbox: "none",
})

export const Package = S.Package({
  targets: { srcs, bench, test },
})
