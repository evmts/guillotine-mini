import { Smithers as S } from "@smthrs/targets"
import { Package as clientPkg } from "../PACKAGE.ts"
const bench_utils = clientPkg.bench_utils
import { Package as srcPkg } from "../../src/PACKAGE.ts"
const evm_srcs = srcPkg.evm_srcs

const srcs = S.Filegroup({
  srcs: [...S.glob(["**/*.zig", "**/*.md"])],
})

const bench = S.Shell.Test({
  bin: S.Host.bin("sh"),
  tools: [S.Host.bin("zig")],
  args: [".smithers/run-zig.sh", "build", "bench-evm", "-Doptimize=ReleaseFast"],
  env: { BENCH_JSON_OUT: "client/evm/.bench-result.json" },
  data: [S.file("//.smithers/run-zig.sh"), srcs, evm_srcs, bench_utils, S.file("//build.zig"), S.file("//build.zig.zon")],
  exclusive: true,
  sandbox: "none",
})

const test = S.Shell.Test({
  bin: S.Host.bin("sh"),
  tools: [S.Host.bin("zig")],
  args: [".smithers/run-zig.sh", "build", "test-evm-adapter"],
  data: [S.file("//.smithers/run-zig.sh"), srcs, evm_srcs, S.file("//build.zig"), S.file("//build.zig.zon")],
  sandbox: "none",
})

export const Package = S.Package({
  targets: { srcs, bench, test },
})
