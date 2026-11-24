import { Smithers as S } from "@smthrs/targets"

const srcs = S.Filegroup({
  srcs: [...S.glob(["*.ts"])],
})

const bench = S.Shell.Test({
  bin: S.Host.bin("bun"),
  args: ["ts/exex/bench.ts"],
  env: { BENCH_JSON_OUT: "ts/exex/.bench-result.json" },
  data: [srcs, S.file("//scripts/bench-ts-utils.ts")],
  exclusive: true,
  sandbox: "none",
})

export const Package = S.Package({
  targets: { srcs, bench },
})
