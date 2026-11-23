import { Smithers as S } from "@smthrs/targets"
import { Package as clientPkg } from "../PACKAGE.ts"
const bench_utils = clientPkg.bench_utils
import { Package as srcPkg } from "../../src/PACKAGE.ts"
const evm_srcs = srcPkg.evm_srcs

const srcs = S.Filegroup({
  srcs: [...S.glob(["**/*.zig", "**/*.md"])],
})

const bench = S.Shell.Test({
  bin: S.Host.bin("zig"),
  args: ["build", "bench-evm", "-Doptimize=ReleaseFast"],
  env: { BENCH_JSON_OUT: "client/evm/.bench-result.json" },
  data: [srcs, evm_srcs, bench_utils, S.file("//build.zig"), S.file("//build.zig.zon")],
  outFiles: [".bench-result.json"],
  exclusive: true,
  sandbox: "none",
})

const test = S.Shell.Test({
  bin: S.Host.bin("zig"),
  args: ["build", "test-evm-adapter"],
  data: [srcs, evm_srcs, S.file("//build.zig"), S.file("//build.zig.zon")],
  sandbox: "none",
})

export const Package = S.Package({
  targets: { srcs, bench, test },
})
