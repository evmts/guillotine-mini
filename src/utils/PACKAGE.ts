import { Smithers as S } from "@smthrs/targets"

const srcs = S.Filegroup({
  srcs: [...S.glob(["*.ts"])],
})

const bench = S.Shell.Test({
  bin: S.Host.bin("bun"),
  args: ["src/utils/bench.ts"],
  env: { BENCH_JSON_OUT: "src/utils/.bench-result.json" },
  data: [srcs, S.file("//scripts/bench-ts-utils.ts")],
  outFiles: [".bench-result.json"],
  exclusive: true,
  sandbox: "none",
})

const test = S.Shell.Test({
  bin: S.Host.bin("bun"),
  args: ["test", "src/utils/"],
  data: [srcs],
  sandbox: "none",
})

export const Package = S.Package({
  targets: { srcs, bench, test },
})
