import { Smithers as S } from "@smthrs/targets"
import { Package as clientPkg } from "../PACKAGE.ts"
const bench_utils = clientPkg.bench_utils

const srcs = S.Filegroup({
  srcs: [...S.glob(["**/*.zig", "**/*.md"])],
})

const bench = S.Shell.Test({
  bin: S.Host.bin("sh"),
  tools: [S.Host.bin("zig")],
  args: [".smithers/run-zig.sh", "build", "bench-rpc", "-Doptimize=ReleaseFast"],
  env: { BENCH_JSON_OUT: "client/rpc/.bench-result.json" },
  data: [S.file("//.smithers/run-zig.sh"), srcs, bench_utils, S.file("//build.zig"), S.file("//build.zig.zon")],
  exclusive: true,
  sandbox: "none",
})

const test = S.Shell.Test({
  bin: S.Host.bin("sh"),
  tools: [S.Host.bin("zig")],
  args: [".smithers/run-zig.sh", "build", "test-rpc"],
  data: [S.file("//.smithers/run-zig.sh"), srcs, S.file("//build.zig"), S.file("//build.zig.zon")],
  sandbox: "none",
})

export const Package = S.Package({
  targets: { srcs, bench, test },
})
