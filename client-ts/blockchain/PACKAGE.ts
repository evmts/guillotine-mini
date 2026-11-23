import { Smithers as S } from "@smthrs/targets"
import { Package as clientTsPkg } from "../PACKAGE.ts"
const config_srcs = clientTsPkg.config_srcs
import { Package as evmSrcsPkg } from "../evm/PACKAGE.ts"
const evmSrcs = evmSrcsPkg.srcs
import { Package as stateSrcsPkg } from "../state/PACKAGE.ts"
const stateSrcs = stateSrcsPkg.srcs

const srcs = S.Filegroup({
  srcs: [...S.glob(["**/*.ts"]), config_srcs, evmSrcs, stateSrcs],
})

const bench = S.Shell.Test({
  bin: S.Host.bin("bun"),
  args: [
    "scripts/run-client-ts-bench.ts",
    "client-ts/blockchain",
    "client-ts/blockchain/Blockchain.bench.ts",
    "client-ts/blockchain/BlockProcessing.bench.ts",
  ],
  env: { BENCH_JSON_OUT: "client-ts/blockchain/.bench-result.json" },
  data: [srcs, S.file("//scripts/run-client-ts-bench.ts")],
  outFiles: [".bench-result.json"],
  exclusive: true,
  sandbox: "none",
})

const test = S.Shell.Test({
  bin: S.Host.bin("bun"),
  args: ["--cwd", "client-ts", "exec", "vitest", "run", "blockchain"],
  data: [srcs],
  sandbox: "none",
})

export const Package = S.Package({
  targets: { srcs, bench, test },
})
